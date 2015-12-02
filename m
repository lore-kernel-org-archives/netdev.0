From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 16/17] i40e: fix: do not sleep in netdev_ops
Date: Wed,  2 Dec 2015 00:25:34 -0800
Message-ID: <1449044735-68599-17-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449044735-68599-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:55200 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757579AbbLBIZn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Dec 2015 03:25:43 -0500
In-Reply-To: <1449044735-68599-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The driver was being called by VLAN, bonding, teaming operations
that expected to be able to hold locks like rcu_read_lock().

This causes the driver to be held to the requirement to not sleep,
and was found by the kernel debug options for checking sleep
inside critical section, and the locking validator.

Change-ID: Ibc68c835f5ffa8ffe0638ffe910a66fc5649a7f7
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 44 +++++++++++++----------------
 1 file changed, 20 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 7759703..3119ee4 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1552,9 +1552,11 @@ static int i40e_set_mac(struct net_device *netdev, void *p)
 		spin_unlock_bh(&vsi->mac_filter_list_lock);
 	}
 
-	i40e_sync_vsi_filters(vsi, false);
 	ether_addr_copy(netdev->dev_addr, addr->sa_data);
-
+	/* schedule our worker thread which will take care of
+	 * applying the new filter changes
+	 */
+	i40e_service_event_schedule(vsi->back);
 	return 0;
 }
 
@@ -2118,12 +2120,7 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi, bool grab_rtnl)
 			 */
 			if (pf->cur_promisc != cur_promisc) {
 				pf->cur_promisc = cur_promisc;
-				if (grab_rtnl)
-					i40e_do_reset_safe(pf,
-						BIT(__I40E_PF_RESET_REQUESTED));
-				else
-					i40e_do_reset(pf,
-						BIT(__I40E_PF_RESET_REQUESTED));
+				set_bit(__I40E_PF_RESET_REQUESTED, &pf->state);
 			}
 		} else {
 			ret = i40e_aq_set_vsi_unicast_promiscuous(
@@ -2383,16 +2380,13 @@ int i40e_vsi_add_vlan(struct i40e_vsi *vsi, s16 vid)
 		}
 	}
 
-	/* Make sure to release before sync_vsi_filter because that
-	 * function will lock/unlock as necessary
-	 */
 	spin_unlock_bh(&vsi->mac_filter_list_lock);
 
-	if (test_bit(__I40E_DOWN, &vsi->back->state) ||
-	    test_bit(__I40E_RESET_RECOVERY_PENDING, &vsi->back->state))
-		return 0;
-
-	return i40e_sync_vsi_filters(vsi, false);
+	/* schedule our worker thread which will take care of
+	 * applying the new filter changes
+	 */
+	i40e_service_event_schedule(vsi->back);
+	return 0;
 }
 
 /**
@@ -2465,16 +2459,13 @@ int i40e_vsi_kill_vlan(struct i40e_vsi *vsi, s16 vid)
 		}
 	}
 
-	/* Make sure to release before sync_vsi_filter because that
-	 * function with lock/unlock as necessary
-	 */
 	spin_unlock_bh(&vsi->mac_filter_list_lock);
 
-	if (test_bit(__I40E_DOWN, &vsi->back->state) ||
-	    test_bit(__I40E_RESET_RECOVERY_PENDING, &vsi->back->state))
-		return 0;
-
-	return i40e_sync_vsi_filters(vsi, false);
+	/* schedule our worker thread which will take care of
+	 * applying the new filter changes
+	 */
+	i40e_service_event_schedule(vsi->back);
+	return 0;
 }
 
 /**
@@ -2717,6 +2708,11 @@ static void i40e_config_xps_tx_ring(struct i40e_ring *ring)
 		netif_set_xps_queue(ring->netdev, mask, ring->queue_index);
 		free_cpumask_var(mask);
 	}
+
+	/* schedule our worker thread which will take care of
+	 * applying the new filter changes
+	 */
+	i40e_service_event_schedule(vsi->back);
 }
 
 /**
-- 
2.5.0
