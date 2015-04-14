From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 20/25] fm10k: update xcast mode before synchronizing multicast addresses
Date: Tue, 14 Apr 2015 16:51:06 -0700
Message-ID: <1429055471-401-21-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1429055471-401-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jacob Keller <jacob.e.keller@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:20409 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754960AbbDNXv0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Apr 2015 19:51:26 -0400
In-Reply-To: <1429055471-401-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the PF receives a request to update a multicast address for the VF,
it checks the enabled multicast mode first. Fix a bug where the VF tried
to set a multicast address before requesting the required xcast mode.
This ensures the multicast addresses are honored as long as the xcast
mode was allowed.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Acked-by: Matthew Vick <matthew.vick@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index 6981964..2f4f41b 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -970,14 +970,7 @@ static void fm10k_set_rx_mode(struct net_device *dev)
 
 	fm10k_mbx_lock(interface);
 
-	/* synchronize all of the addresses */
-	if (xcast_mode != FM10K_XCAST_MODE_PROMISC) {
-		__dev_uc_sync(dev, fm10k_uc_sync, fm10k_uc_unsync);
-		if (xcast_mode != FM10K_XCAST_MODE_ALLMULTI)
-			__dev_mc_sync(dev, fm10k_mc_sync, fm10k_mc_unsync);
-	}
-
-	/* if we aren't changing modes there is nothing to do */
+	/* update xcast mode first, but only if it changed */
 	if (interface->xcast_mode != xcast_mode) {
 		/* update VLAN table */
 		if (xcast_mode == FM10K_XCAST_MODE_PROMISC)
@@ -992,6 +985,13 @@ static void fm10k_set_rx_mode(struct net_device *dev)
 		interface->xcast_mode = xcast_mode;
 	}
 
+	/* synchronize all of the addresses */
+	if (xcast_mode != FM10K_XCAST_MODE_PROMISC) {
+		__dev_uc_sync(dev, fm10k_uc_sync, fm10k_uc_unsync);
+		if (xcast_mode != FM10K_XCAST_MODE_ALLMULTI)
+			__dev_mc_sync(dev, fm10k_mc_sync, fm10k_mc_unsync);
+	}
+
 	fm10k_mbx_unlock(interface);
 }
 
@@ -1051,6 +1051,9 @@ void fm10k_restore_rx_state(struct fm10k_intfc *interface)
 					   vid, true, 0);
 	}
 
+	/* update xcast mode before syncronizing addresses */
+	hw->mac.ops.update_xcast_mode(hw, glort, xcast_mode);
+
 	/* synchronize all of the addresses */
 	if (xcast_mode != FM10K_XCAST_MODE_PROMISC) {
 		__dev_uc_sync(netdev, fm10k_uc_sync, fm10k_uc_unsync);
@@ -1058,9 +1061,6 @@ void fm10k_restore_rx_state(struct fm10k_intfc *interface)
 			__dev_mc_sync(netdev, fm10k_mc_sync, fm10k_mc_unsync);
 	}
 
-	/* update xcast mode */
-	hw->mac.ops.update_xcast_mode(hw, glort, xcast_mode);
-
 	fm10k_mbx_unlock(interface);
 
 	/* record updated xcast mode state */
-- 
1.9.3
