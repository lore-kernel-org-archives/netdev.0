From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 4/6] sky2: EC-U performance and jumbo support
Date: Wed, 11 Apr 2007 14:48:01 -0700
Message-ID: <20070411214900.000007386@linux-foundation.org>
References: <20070411214757.194710334@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:34872 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030501AbXDKWas (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Apr 2007 18:30:48 -0400
Content-Disposition: inline; filename=sky2-ecu-jumbo.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Yukon EC Ultra chips have transmit settings for store and
forward and PCI buffering. By setting these appropriately, normal
performance goes from 750Mbytes/sec to 940Mbytes/sec (non-jumbo).

It is also possible to do Jumbo mode, but it means turning off
TSO and checksum offload so the performance gets worse. There isn't
enough buffering for checksum offload to work.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
---
 drivers/net/sky2.c |   85 +++++++++++++++++++++++++++++++++++++----------------
 drivers/net/sky2.h |    8 ++++
 2 files changed, 68 insertions(+), 25 deletions(-)

--- sky2-2.6.21.orig/drivers/net/sky2.c	2007-04-11 14:11:48.000000000 -0700
+++ sky2-2.6.21/drivers/net/sky2.c	2007-04-11 14:28:30.000000000 -0700
@@ -743,12 +743,17 @@ static void sky2_mac_init(struct sky2_hw
 	if (hw->chip_id == CHIP_ID_YUKON_EC_U || hw->chip_id == CHIP_ID_YUKON_EX) {
 		sky2_write8(hw, SK_REG(port, RX_GMF_LP_THR), 768/8);
 		sky2_write8(hw, SK_REG(port, RX_GMF_UP_THR), 1024/8);
-		if (hw->dev[port]->mtu > ETH_DATA_LEN) {
-			/* set Tx GMAC FIFO Almost Empty Threshold */
-			sky2_write32(hw, SK_REG(port, TX_GMF_AE_THR), 0x180);
-			/* Disable Store & Forward mode for TX */
-			sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T), TX_STFW_DIS);
-		}
+
+		/* set Tx GMAC FIFO Almost Empty Threshold */
+		sky2_write32(hw, SK_REG(port, TX_GMF_AE_THR),
+			     (ECU_JUMBO_WM << 16) | ECU_AE_THR);
+
+		if (hw->dev[port]->mtu > ETH_DATA_LEN)
+			sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
+				     TX_JUMBO_ENA | TX_STFW_DIS);
+		else
+			sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
+				     TX_JUMBO_DIS | TX_STFW_ENA);
 	}
 
 }
@@ -1281,7 +1286,7 @@ static int sky2_up(struct net_device *de
 	/* Set almost empty threshold */
 	if (hw->chip_id == CHIP_ID_YUKON_EC_U
 	    && hw->chip_rev == CHIP_REV_YU_EC_U_A0)
-		sky2_write16(hw, Q_ADDR(txqaddr[port], Q_AL), 0x1a0);
+		sky2_write16(hw, Q_ADDR(txqaddr[port], Q_AL), ECU_TXFF_LEV);
 
 	sky2_prefetch_init(hw, txqaddr[port], sky2->tx_le_map,
 			   TX_RING_SIZE - 1);
@@ -1587,13 +1592,6 @@ static int sky2_down(struct net_device *
 	sky2_write32(hw, RB_ADDR(txqaddr[port], RB_CTRL),
 		     RB_RST_SET | RB_DIS_OP_MD);
 
-	/* WA for dev. #4.209 */
-	if (hw->chip_id == CHIP_ID_YUKON_EC_U
-	    && (hw->chip_rev == CHIP_REV_YU_EC_U_A1 || hw->chip_rev == CHIP_REV_YU_EC_U_B0))
-		sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
-			     sky2->speed != SPEED_1000 ?
-			     TX_STFW_ENA : TX_STFW_DIS);
-
 	ctrl = gma_read16(hw, port, GM_GP_CTRL);
 	ctrl &= ~(GM_GPCR_TX_ENA | GM_GPCR_RX_ENA);
 	gma_write16(hw, port, GM_GP_CTRL, ctrl);
@@ -1893,6 +1891,7 @@ static int sky2_change_mtu(struct net_de
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
 	struct sky2_hw *hw = sky2->hw;
+	unsigned port = sky2->port;
 	int err;
 	u16 ctl, mode;
 	u32 imask;
@@ -1900,10 +1899,6 @@ static int sky2_change_mtu(struct net_de
 	if (new_mtu < ETH_ZLEN || new_mtu > ETH_JUMBO_MTU)
 		return -EINVAL;
 
-	/* TSO on Yukon Ultra and MTU > 1500 not supported */
-	if (hw->chip_id == CHIP_ID_YUKON_EC_U && new_mtu > ETH_DATA_LEN)
-		dev->features &= ~NETIF_F_TSO;
-
 	if (!netif_running(dev)) {
 		dev->mtu = new_mtu;
 		return 0;
@@ -1918,8 +1913,18 @@ static int sky2_change_mtu(struct net_de
 
 	synchronize_irq(hw->pdev->irq);
 
-	ctl = gma_read16(hw, sky2->port, GM_GP_CTRL);
-	gma_write16(hw, sky2->port, GM_GP_CTRL, ctl & ~GM_GPCR_RX_ENA);
+	if (hw->chip_id == CHIP_ID_YUKON_EC_U || hw->chip_id == CHIP_ID_YUKON_EX) {
+		if (new_mtu > ETH_DATA_LEN) {
+			sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
+				     TX_JUMBO_ENA | TX_STFW_DIS);
+			dev->features &= NETIF_F_TSO | NETIF_F_SG | NETIF_F_IP_CSUM;
+		} else
+			sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
+				     TX_JUMBO_DIS | TX_STFW_ENA);
+	}
+
+	ctl = gma_read16(hw, port, GM_GP_CTRL);
+	gma_write16(hw, port, GM_GP_CTRL, ctl & ~GM_GPCR_RX_ENA);
 	sky2_rx_stop(sky2);
 	sky2_rx_clean(sky2);
 
@@ -1931,9 +1936,9 @@ static int sky2_change_mtu(struct net_de
 	if (dev->mtu > ETH_DATA_LEN)
 		mode |= GM_SMOD_JUMBO_ENA;
 
-	gma_write16(hw, sky2->port, GM_SERIAL_MODE, mode);
+	gma_write16(hw, port, GM_SERIAL_MODE, mode);
 
-	sky2_write8(hw, RB_ADDR(rxqaddr[sky2->port], RB_CTRL), RB_ENA_OP_MD);
+	sky2_write8(hw, RB_ADDR(rxqaddr[port], RB_CTRL), RB_ENA_OP_MD);
 
 	err = sky2_rx_start(sky2);
 	sky2_write32(hw, B0_IMSK, imask);
@@ -1941,7 +1946,7 @@ static int sky2_change_mtu(struct net_de
 	if (err)
 		dev_close(dev);
 	else {
-		gma_write16(hw, sky2->port, GM_GP_CTRL, ctl);
+		gma_write16(hw, port, GM_GP_CTRL, ctl);
 
 		netif_poll_enable(hw->dev[0]);
 		netif_wake_queue(dev);
@@ -3334,6 +3339,36 @@ static void sky2_get_regs(struct net_dev
 		      regs->len - B3_RI_WTO_R1);
 }
 
+/* In order to do Jumbo packets on these chips, need to turn off the
+ * transmit store/forward. Therefore checksum offload won't work.
+ */
+static int no_tx_offload(struct net_device *dev)
+{
+	const struct sky2_port *sky2 = netdev_priv(dev);
+	const struct sky2_hw *hw = sky2->hw;
+
+	return dev->mtu > ETH_DATA_LEN &&
+		(hw->chip_id == CHIP_ID_YUKON_EX
+		 || hw->chip_id == CHIP_ID_YUKON_EC_U);
+}
+
+static int sky2_set_tx_csum(struct net_device *dev, u32 data)
+{
+	if (data && no_tx_offload(dev))
+		return -EINVAL;
+
+	return ethtool_op_set_tx_csum(dev, data);
+}
+
+
+static int sky2_set_tso(struct net_device *dev, u32 data)
+{
+	if (data && no_tx_offload(dev))
+		return -EINVAL;
+
+	return ethtool_op_set_tso(dev, data);
+}
+
 static const struct ethtool_ops sky2_ethtool_ops = {
 	.get_settings = sky2_get_settings,
 	.set_settings = sky2_set_settings,
@@ -3349,9 +3384,9 @@ static const struct ethtool_ops sky2_eth
 	.get_sg = ethtool_op_get_sg,
 	.set_sg = ethtool_op_set_sg,
 	.get_tx_csum = ethtool_op_get_tx_csum,
-	.set_tx_csum = ethtool_op_set_tx_csum,
+	.set_tx_csum = sky2_set_tx_csum,
 	.get_tso = ethtool_op_get_tso,
-	.set_tso = ethtool_op_set_tso,
+	.set_tso = sky2_set_tso,
 	.get_rx_csum = sky2_get_rx_csum,
 	.set_rx_csum = sky2_set_rx_csum,
 	.get_strings = sky2_get_strings,
--- sky2-2.6.21.orig/drivers/net/sky2.h	2007-04-11 14:10:13.000000000 -0700
+++ sky2-2.6.21/drivers/net/sky2.h	2007-04-11 14:14:35.000000000 -0700
@@ -741,6 +741,11 @@ enum {
 	TX_GMF_RP	= 0x0d70,/* 32 bit 	Tx GMAC FIFO Read Pointer */
 	TX_GMF_RSTP	= 0x0d74,/* 32 bit 	Tx GMAC FIFO Restart Pointer */
 	TX_GMF_RLEV	= 0x0d78,/* 32 bit 	Tx GMAC FIFO Read Level */
+
+	/* Threshold values for Yukon-EC Ultra and Extreme */
+	ECU_AE_THR	= 0x0070, /* Almost Empty Threshold */
+	ECU_TXFF_LEV	= 0x01a0, /* Tx BMU FIFO Level */
+	ECU_JUMBO_WM	= 0x0080, /* Jumbo Mode Watermark */
 };
 
 /* Descriptor Poll Timer Registers */
@@ -1634,6 +1639,9 @@ enum {
 	TX_VLAN_TAG_ON	= 1<<25,/* enable  VLAN tagging */
 	TX_VLAN_TAG_OFF	= 1<<24,/* disable VLAN tagging */
 
+	TX_JUMBO_ENA	= 1<<23,/* PCI Jumbo Mode enable (Yukon-EC Ultra) */
+	TX_JUMBO_DIS	= 1<<22,/* PCI Jumbo Mode enable (Yukon-EC Ultra) */
+
 	GMF_WSP_TST_ON	= 1<<18,/* Write Shadow Pointer Test On */
 	GMF_WSP_TST_OFF	= 1<<17,/* Write Shadow Pointer Test Off */
 	GMF_WSP_STEP	= 1<<16,/* Write Shadow Pointer Step/Increment */

--
Stephen Hemminger <shemminger@linux-foundation.org>

