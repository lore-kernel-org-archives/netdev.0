From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 12/21] ixgbe: DCB: enable RSS to be used with DCB
Date: Sat, 12 Mar 2011 04:20:19 -0800
Message-ID: <1299932428-3114-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299932428-3114-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:58767 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753962Ab1CLMU5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Mar 2011 07:20:57 -0500
In-Reply-To: <1299932428-3114-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

RSS had previously been disabled when DCB was enabled because
DCB was single queued per traffic class. Now that DCB implements
multiple Tx/Rx rings per traffic class enable RSS.

Here RSS hashes across the queues in the traffic class.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain.@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_dcb_nl.c |    2 --
 drivers/net/ixgbe/ixgbe_main.c   |   32 +++++++++++++++++++++++++-------
 2 files changed, 25 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index b7b6db3..91ff51c 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -129,7 +129,6 @@ static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 			netdev->netdev_ops->ndo_stop(netdev);
 		ixgbe_clear_interrupt_scheme(adapter);
 
-		adapter->flags &= ~IXGBE_FLAG_RSS_ENABLED;
 		switch (adapter->hw.mac.type) {
 		case ixgbe_mac_82598EB:
 			adapter->last_lfc_mode = adapter->hw.fc.current_mode;
@@ -162,7 +161,6 @@ static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 			adapter->temp_dcb_cfg.pfc_mode_enable = false;
 			adapter->dcb_cfg.pfc_mode_enable = false;
 			adapter->flags &= ~IXGBE_FLAG_DCB_ENABLED;
-			adapter->flags |= IXGBE_FLAG_RSS_ENABLED;
 			switch (adapter->hw.mac.type) {
 			case ixgbe_mac_82599EB:
 			case ixgbe_mac_X540:
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 3ce0f4f..be2e145 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2892,17 +2892,20 @@ static void ixgbe_setup_mrqc(struct ixgbe_adapter *adapter)
 					);
 
 	switch (mask) {
+#ifdef CONFIG_IXGBE_DCB
+	case (IXGBE_FLAG_DCB_ENABLED | IXGBE_FLAG_RSS_ENABLED):
+		mrqc = IXGBE_MRQC_RTRSS8TCEN;
+		break;
+	case (IXGBE_FLAG_DCB_ENABLED):
+		mrqc = IXGBE_MRQC_RT8TCEN;
+		break;
+#endif /* CONFIG_IXGBE_DCB */
 	case (IXGBE_FLAG_RSS_ENABLED):
 		mrqc = IXGBE_MRQC_RSSEN;
 		break;
 	case (IXGBE_FLAG_SRIOV_ENABLED):
 		mrqc = IXGBE_MRQC_VMDQEN;
 		break;
-#ifdef CONFIG_IXGBE_DCB
-	case (IXGBE_FLAG_DCB_ENABLED):
-		mrqc = IXGBE_MRQC_RT8TCEN;
-		break;
-#endif /* CONFIG_IXGBE_DCB */
 	default:
 		break;
 	}
@@ -3672,6 +3675,23 @@ static void ixgbe_configure_dcb(struct ixgbe_adapter *adapter)
 
 	/* reconfigure the hardware */
 	ixgbe_dcb_hw_config(hw, &adapter->dcb_cfg);
+
+	/* Enable RSS Hash per TC */
+	if (hw->mac.type != ixgbe_mac_82598EB) {
+		int i;
+		u32 reg = 0;
+
+		for (i = 0; i < MAX_TRAFFIC_CLASS; i++) {
+			u8 msb = 0;
+			u8 cnt = adapter->netdev->tc_to_txq[i].count;
+
+			while (cnt >>= 1)
+				msb++;
+
+			reg |= msb << IXGBE_RQTC_SHIFT_TC(i);
+		}
+		IXGBE_WRITE_REG(hw, IXGBE_RQTC, reg);
+	}
 }
 
 #endif
@@ -7343,8 +7363,6 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)
 		adapter->flags &= ~(IXGBE_FLAG_RSS_ENABLED |
 				    IXGBE_FLAG_DCB_ENABLED);
-	if (adapter->flags & IXGBE_FLAG_DCB_ENABLED)
-		adapter->flags &= ~IXGBE_FLAG_RSS_ENABLED;
 
 #ifdef CONFIG_IXGBE_DCB
 	netdev->dcbnl_ops = &dcbnl_ops;
-- 
1.7.4

