From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH] ixgbe: Allow Priority Flow Control settings to
	survive a device reset
Date: Thu, 26 Mar 2009 01:10:42 -0700
Message-ID: <20090326081042.30689.93164.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.westchester.pa.mail.comcast.net ([76.96.62.56]:45180
	"EHLO QMTA06.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752210AbZCZILE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 04:11:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

When changing DCB parameters, ixgbe needs to have the MAC reset.  The way
the flow control code is setup today, PFC will be disabled on a reset.
This patch adds a new flow control type for PFC, and then has the netlink
layer take care of toggling which type of flow control to enable.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_common.c    |   23 +++++++++++++++++++++--
 drivers/net/ixgbe/ixgbe_dcb_82598.c |    1 -
 drivers/net/ixgbe/ixgbe_dcb_82599.c |    3 ---
 drivers/net/ixgbe/ixgbe_dcb_nl.c    |    2 ++
 drivers/net/ixgbe/ixgbe_type.h      |    3 +++
 5 files changed, 26 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index 245db0e..8cfd3fd 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -1654,9 +1654,10 @@ s32 ixgbe_fc_enable(struct ixgbe_hw *hw, s32 packetbuf_num)
 	 * 0: Flow control is completely disabled
 	 * 1: Rx flow control is enabled (we can receive pause frames,
 	 *    but not send pause frames).
-	 * 2:  Tx flow control is enabled (we can send pause frames but
-	 *     we do not support receiving pause frames).
+	 * 2: Tx flow control is enabled (we can send pause frames but
+	 *    we do not support receiving pause frames).
 	 * 3: Both Rx and Tx flow control (symmetric) are enabled.
+	 * 4: Priority Flow Control is enabled.
 	 * other: Invalid.
 	 */
 	switch (hw->fc.current_mode) {
@@ -1686,6 +1687,11 @@ s32 ixgbe_fc_enable(struct ixgbe_hw *hw, s32 packetbuf_num)
 		mflcn_reg |= IXGBE_MFLCN_RFCE;
 		fccfg_reg |= IXGBE_FCCFG_TFCE_802_3X;
 		break;
+#ifdef CONFIG_DCB
+	case ixgbe_fc_pfc:
+		goto out;
+		break;
+#endif
 	default:
 		hw_dbg(hw, "Flow control param set incorrectly\n");
 		ret_val = -IXGBE_ERR_CONFIG;
@@ -1746,6 +1752,7 @@ s32 ixgbe_fc_autoneg(struct ixgbe_hw *hw)
 	 * 2:  Tx flow control is enabled (we can send pause frames but
 	 *     we do not support receiving pause frames).
 	 * 3:  Both Rx and Tx flow control (symmetric) are enabled.
+	 * 4:  Priority Flow Control is enabled.
 	 * other: Invalid.
 	 */
 	switch (hw->fc.current_mode) {
@@ -1776,6 +1783,11 @@ s32 ixgbe_fc_autoneg(struct ixgbe_hw *hw)
 		/* Flow control (both Rx and Tx) is enabled by SW override. */
 		reg |= (IXGBE_PCS1GANA_SYM_PAUSE | IXGBE_PCS1GANA_ASM_PAUSE);
 		break;
+#ifdef CONFIG_DCB
+	case ixgbe_fc_pfc:
+		goto out;
+		break;
+#endif
 	default:
 		hw_dbg(hw, "Flow control param set incorrectly\n");
 		ret_val = -IXGBE_ERR_CONFIG;
@@ -1874,6 +1886,13 @@ s32 ixgbe_setup_fc_generic(struct ixgbe_hw *hw, s32 packetbuf_num)
 	ixgbe_link_speed speed;
 	bool link_up;
 
+#ifdef CONFIG_DCB
+	if (hw->fc.requested_mode == ixgbe_fc_pfc) {
+		hw->fc.current_mode = hw->fc.requested_mode;
+		goto out;
+	}
+
+#endif
 	/* Validate the packetbuf configuration */
 	if (packetbuf_num < 0 || packetbuf_num > 7) {
 		hw_dbg(hw, "Invalid packet buffer number [%d], expected range "
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82598.c b/drivers/net/ixgbe/ixgbe_dcb_82598.c
index df35955..6220627 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_82598.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_82598.c
@@ -298,7 +298,6 @@ s32 ixgbe_dcb_config_pfc_82598(struct ixgbe_hw *hw,
 	reg = IXGBE_READ_REG(hw, IXGBE_RMCS);
 	reg &= ~IXGBE_RMCS_TFCE_802_3X;
 	/* correct the reporting of our flow control status */
-	hw->fc.current_mode = ixgbe_fc_none;
 	reg |= IXGBE_RMCS_TFCE_PRIORITY;
 	IXGBE_WRITE_REG(hw, IXGBE_RMCS, reg);
 
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82599.c b/drivers/net/ixgbe/ixgbe_dcb_82599.c
index adcbac4..470b676 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_82599.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_82599.c
@@ -299,9 +299,6 @@ s32 ixgbe_dcb_config_pfc_82599(struct ixgbe_hw *hw,
 		goto out;
 	}
 
-	/* PFC is mutually exclusive with link flow control */
-	hw->fc.current_mode = ixgbe_fc_none;
-
 	/* Configure PFC Tx thresholds per TC */
 	for (i = 0; i < MAX_TRAFFIC_CLASS; i++) {
 		/* Config and remember Tx */
diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index 8a9939e..0a8731f 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -130,6 +130,7 @@ static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 		adapter->tx_ring = NULL;
 		adapter->rx_ring = NULL;
 
+		adapter->hw.fc.requested_mode = ixgbe_fc_pfc;
 		adapter->flags &= ~IXGBE_FLAG_RSS_ENABLED;
 		adapter->flags |= IXGBE_FLAG_DCB_ENABLED;
 		ixgbe_init_interrupt_scheme(adapter);
@@ -138,6 +139,7 @@ static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 	} else {
 		/* Turn off DCB */
 		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
+			adapter->hw.fc.requested_mode = ixgbe_fc_default;
 			if (netif_running(netdev))
 				netdev->netdev_ops->ndo_stop(netdev);
 			ixgbe_reset_interrupt_capability(adapter);
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 95fc36c..2b2ecba 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -1939,6 +1939,9 @@ enum ixgbe_fc_mode {
 	ixgbe_fc_rx_pause,
 	ixgbe_fc_tx_pause,
 	ixgbe_fc_full,
+#ifdef CONFIG_DCB
+	ixgbe_fc_pfc,
+#endif
 	ixgbe_fc_default
 };
 

