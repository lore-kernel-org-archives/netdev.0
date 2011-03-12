From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 15/21] ixgbe: DCB during ifup use correct CEE or IEEE mode
Date: Sat, 12 Mar 2011 04:20:22 -0800
Message-ID: <1299932428-3114-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299932428-3114-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:2695 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753514Ab1CLMUz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Mar 2011 07:20:55 -0500
In-Reply-To: <1299932428-3114-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

DCB settings are cleared in the hardware across link events
during ifup ixgbe reprograms the hardware for DCB if it is
enabled. Now that we have two modes CEE or IEEE we need to
use the correct set of configuration data.

This patch checks the dcbx_cap bits and then enables the
device in the correct mode.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_main.c |   30 ++++++++++++++++++++----------
 1 files changed, 20 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index be2e145..38f9758 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3658,15 +3658,6 @@ static void ixgbe_configure_dcb(struct ixgbe_adapter *adapter)
 	if (hw->mac.type == ixgbe_mac_82598EB)
 		netif_set_gso_max_size(adapter->netdev, 32768);
 
-#ifdef CONFIG_FCOE
-	if (adapter->netdev->features & NETIF_F_FCOE_MTU)
-		max_frame = max(max_frame, IXGBE_FCOE_JUMBO_FRAME_SIZE);
-#endif
-
-	ixgbe_dcb_calculate_tc_credits(hw, &adapter->dcb_cfg, max_frame,
-					DCB_TX_CONFIG);
-	ixgbe_dcb_calculate_tc_credits(hw, &adapter->dcb_cfg, max_frame,
-					DCB_RX_CONFIG);
 
 	/* Enable VLAN tag insert/strip */
 	adapter->netdev->features |= NETIF_F_HW_VLAN_RX;
@@ -3674,7 +3665,26 @@ static void ixgbe_configure_dcb(struct ixgbe_adapter *adapter)
 	hw->mac.ops.set_vfta(&adapter->hw, 0, 0, true);
 
 	/* reconfigure the hardware */
-	ixgbe_dcb_hw_config(hw, &adapter->dcb_cfg);
+	if (adapter->dcbx_cap & (DCB_CAP_DCBX_HOST | DCB_CAP_DCBX_VER_CEE)) {
+#ifdef CONFIG_FCOE
+		if (adapter->netdev->features & NETIF_F_FCOE_MTU)
+			max_frame = max(max_frame, IXGBE_FCOE_JUMBO_FRAME_SIZE);
+#endif
+		ixgbe_dcb_calculate_tc_credits(hw, &adapter->dcb_cfg, max_frame,
+						DCB_TX_CONFIG);
+		ixgbe_dcb_calculate_tc_credits(hw, &adapter->dcb_cfg, max_frame,
+						DCB_RX_CONFIG);
+		ixgbe_dcb_hw_config(hw, &adapter->dcb_cfg);
+	} else {
+		struct net_device *dev = adapter->netdev;
+
+		if (adapter->ixgbe_ieee_ets)
+			dev->dcbnl_ops->ieee_setets(dev,
+						    adapter->ixgbe_ieee_ets);
+		if (adapter->ixgbe_ieee_pfc)
+			dev->dcbnl_ops->ieee_setpfc(dev,
+						    adapter->ixgbe_ieee_pfc);
+	}
 
 	/* Enable RSS Hash per TC */
 	if (hw->mac.type != ixgbe_mac_82598EB) {
-- 
1.7.4

