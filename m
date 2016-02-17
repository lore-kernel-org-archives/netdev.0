From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/15] i40e: fix: do not sleep in netdev_ops
Date: Wed, 17 Feb 2016 09:51:37 -0800
Message-ID: <1455731506-62165-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455731506-62165-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:17063 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161613AbcBQRvv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 12:51:51 -0500
In-Reply-To: <1455731506-62165-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
Reviewed-by: Nelson, Shannon <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index fe67b90..ac89739 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1542,7 +1542,11 @@ static int i40e_set_mac(struct net_device *netdev, void *p)
 
 	ether_addr_copy(netdev->dev_addr, addr->sa_data);
 
-	return i40e_sync_vsi_filters(vsi);
+	/* schedule our worker thread which will take care of
+	 * applying the new filter changes
+	 */
+	i40e_service_event_schedule(vsi->back);
+	return 0;
 }
 
 /**
@@ -1766,6 +1770,11 @@ bottom_of_search_loop:
 		vsi->flags |= I40E_VSI_FLAG_FILTER_CHANGED;
 		vsi->back->flags |= I40E_FLAG_FILTER_SYNC;
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
