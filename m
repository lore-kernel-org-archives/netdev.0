From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/17] fm10k: Fix multicast mode sync issues
Date: Wed, 20 Apr 2016 23:09:19 -0700
Message-ID: <1461218969-68578-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1461218969-68578-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Ngai-Mint Kwan <ngai-mint.kwan@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:24794 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751604AbcDUGJe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2016 02:09:34 -0400
In-Reply-To: <1461218969-68578-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ngai-Mint Kwan <ngai-mint.kwan@intel.com>

Multicast mode checking is no longer a requirement to perform unicast
and multicast address syncs. Specifically, a device operating in
promiscuous and/or all multicast mode is not excluded. The issue occurs
when the netdev is pre-configured to either multicast mode and is
enabled for the first time. The multicast-group table in the Switch
Manager will be missing obvious multicast entries associated to this
netdev.

Changes were also made to disallow unicast and multicast syncs with
VLAN 0. The Switch Manager considers VLAN 0 to be an invalid entry.
Requests with VLAN 0 by the netdev are only generated when the driver is
freshly installed and the default VID is not set.

Signed-off-by: Ngai-Mint Kwan <ngai-mint.kwan@intel.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c | 20 +++++++-------------
 1 file changed, 7 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index 32778dd..bf229d5 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -877,7 +877,7 @@ static int __fm10k_uc_sync(struct net_device *dev,
 		return -EADDRNOTAVAIL;
 
 	/* update table with current entries */
-	for (vid = hw->mac.default_vid ? fm10k_find_next_vlan(interface, 0) : 0;
+	for (vid = hw->mac.default_vid ? fm10k_find_next_vlan(interface, 0) : 1;
 	     vid < VLAN_N_VID;
 	     vid = fm10k_find_next_vlan(interface, vid)) {
 		err = hw->mac.ops.update_uc_addr(hw, glort, addr,
@@ -940,7 +940,7 @@ static int __fm10k_mc_sync(struct net_device *dev,
 	u16 vid, glort = interface->glort;
 
 	/* update table with current entries */
-	for (vid = hw->mac.default_vid ? fm10k_find_next_vlan(interface, 0) : 0;
+	for (vid = hw->mac.default_vid ? fm10k_find_next_vlan(interface, 0) : 1;
 	     vid < VLAN_N_VID;
 	     vid = fm10k_find_next_vlan(interface, vid)) {
 		hw->mac.ops.update_mc_addr(hw, glort, addr, vid, sync);
@@ -995,11 +995,8 @@ static void fm10k_set_rx_mode(struct net_device *dev)
 	}
 
 	/* synchronize all of the addresses */
-	if (xcast_mode != FM10K_XCAST_MODE_PROMISC) {
-		__dev_uc_sync(dev, fm10k_uc_sync, fm10k_uc_unsync);
-		if (xcast_mode != FM10K_XCAST_MODE_ALLMULTI)
-			__dev_mc_sync(dev, fm10k_mc_sync, fm10k_mc_unsync);
-	}
+	__dev_uc_sync(dev, fm10k_uc_sync, fm10k_uc_unsync);
+	__dev_mc_sync(dev, fm10k_mc_sync, fm10k_mc_unsync);
 
 	fm10k_mbx_unlock(interface);
 }
@@ -1037,7 +1034,7 @@ void fm10k_restore_rx_state(struct fm10k_intfc *interface)
 	hw->mac.ops.update_vlan(hw, 0, 0, true);
 
 	/* update table with current entries */
-	for (vid = hw->mac.default_vid ? fm10k_find_next_vlan(interface, 0) : 0;
+	for (vid = hw->mac.default_vid ? fm10k_find_next_vlan(interface, 0) : 1;
 	     vid < VLAN_N_VID;
 	     vid = fm10k_find_next_vlan(interface, vid)) {
 		hw->mac.ops.update_vlan(hw, vid, 0, true);
@@ -1049,11 +1046,8 @@ void fm10k_restore_rx_state(struct fm10k_intfc *interface)
 	hw->mac.ops.update_xcast_mode(hw, glort, xcast_mode);
 
 	/* synchronize all of the addresses */
-	if (xcast_mode != FM10K_XCAST_MODE_PROMISC) {
-		__dev_uc_sync(netdev, fm10k_uc_sync, fm10k_uc_unsync);
-		if (xcast_mode != FM10K_XCAST_MODE_ALLMULTI)
-			__dev_mc_sync(netdev, fm10k_mc_sync, fm10k_mc_unsync);
-	}
+	__dev_uc_sync(netdev, fm10k_uc_sync, fm10k_uc_unsync);
+	__dev_mc_sync(netdev, fm10k_mc_sync, fm10k_mc_unsync);
 
 	fm10k_mbx_unlock(interface);
 
-- 
2.5.5
