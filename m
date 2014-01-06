From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/15] i40e: Do not allow AQ calls from ndo-ops
Date: Mon,  6 Jan 2014 04:30:36 -0800
Message-ID: <1389011436-18424-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1389011436-18424-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:22497 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753739AbaAFMaq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jan 2014 07:30:46 -0500
In-Reply-To: <1389011436-18424-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

If the device is not in a working state avoid making admin
queue (AQ) calls that rely on a working AQ.

Change-Id: Ifbba6d257b3a5b51bfe92938c04088c0baa21433
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 30 +++++++++++++----------------
 1 file changed, 13 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index fd24ee4..483126c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1215,6 +1215,10 @@ static int i40e_set_mac(struct net_device *netdev, void *p)
 	if (ether_addr_equal(netdev->dev_addr, addr->sa_data))
 		return 0;
 
+	if (test_bit(__I40E_DOWN, &vsi->back->state) ||
+	    test_bit(__I40E_RESET_RECOVERY_PENDING, &vsi->back->state))
+		return -EADDRNOTAVAIL;
+
 	if (vsi->type == I40E_VSI_MAIN) {
 		i40e_status ret;
 		ret = i40e_aq_mac_address_write(&vsi->back->hw,
@@ -1779,7 +1783,6 @@ int i40e_vsi_add_vlan(struct i40e_vsi *vsi, s16 vid)
 {
 	struct i40e_mac_filter *f, *add_f;
 	bool is_netdev, is_vf;
-	int ret;
 
 	is_vf = (vsi->type == I40E_VSI_SRIOV);
 	is_netdev = !!(vsi->netdev);
@@ -1805,13 +1808,6 @@ int i40e_vsi_add_vlan(struct i40e_vsi *vsi, s16 vid)
 		}
 	}
 
-	ret = i40e_sync_vsi_filters(vsi);
-	if (ret) {
-		dev_info(&vsi->back->pdev->dev,
-			 "Could not sync filters for vid %d\n", vid);
-		return ret;
-	}
-
 	/* Now if we add a vlan tag, make sure to check if it is the first
 	 * tag (i.e. a "tag" -1 does exist) and if so replace the -1 "tag"
 	 * with 0, so we now accept untagged and specified tagged traffic
@@ -1848,10 +1844,13 @@ int i40e_vsi_add_vlan(struct i40e_vsi *vsi, s16 vid)
 				}
 			}
 		}
-		ret = i40e_sync_vsi_filters(vsi);
 	}
 
-	return ret;
+	if (test_bit(__I40E_DOWN, &vsi->back->state) ||
+	    test_bit(__I40E_RESET_RECOVERY_PENDING, &vsi->back->state))
+		return 0;
+
+	return i40e_sync_vsi_filters(vsi);
 }
 
 /**
@@ -1867,7 +1866,6 @@ int i40e_vsi_kill_vlan(struct i40e_vsi *vsi, s16 vid)
 	struct i40e_mac_filter *f, *add_f;
 	bool is_vf, is_netdev;
 	int filter_count = 0;
-	int ret;
 
 	is_vf = (vsi->type == I40E_VSI_SRIOV);
 	is_netdev = !!(netdev);
@@ -1878,12 +1876,6 @@ int i40e_vsi_kill_vlan(struct i40e_vsi *vsi, s16 vid)
 	list_for_each_entry(f, &vsi->mac_filter_list, list)
 		i40e_del_filter(vsi, f->macaddr, vid, is_vf, is_netdev);
 
-	ret = i40e_sync_vsi_filters(vsi);
-	if (ret) {
-		dev_info(&vsi->back->pdev->dev, "Could not sync filters\n");
-		return ret;
-	}
-
 	/* go through all the filters for this VSI and if there is only
 	 * vid == 0 it means there are no other filters, so vid 0 must
 	 * be replaced with -1. This signifies that we should from now
@@ -1926,6 +1918,10 @@ int i40e_vsi_kill_vlan(struct i40e_vsi *vsi, s16 vid)
 		}
 	}
 
+	if (test_bit(__I40E_DOWN, &vsi->back->state) ||
+	    test_bit(__I40E_RESET_RECOVERY_PENDING, &vsi->back->state))
+		return 0;
+
 	return i40e_sync_vsi_filters(vsi);
 }
 
-- 
1.8.3.1
