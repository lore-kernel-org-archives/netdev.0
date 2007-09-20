From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 4/6] sky2: fe+ chip support
Date: Wed, 19 Sep 2007 22:06:03 -0700
Message-ID: <20070920050700.494339457@linux-foundation.org>
References: <20070920050559.763089637@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzk <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:56824 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752213AbXITFH6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 01:07:58 -0400
Content-Disposition: inline; filename=sky2-fe-p.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Modifications to support for Yukon FE plus chip.
Earlier code was speculative, this is tested on hardware evaluation boards.

This version of the patch is for 2.6.23. It supersedes
the two previous patches that are sitting in netdev-2.6 (upstream branch).

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/drivers/net/sky2.c	2007-09-19 21:57:59.000000000 -0700
+++ b/drivers/net/sky2.c	2007-09-19 21:58:08.000000000 -0700
@@ -119,7 +119,7 @@ static const struct pci_device_id sky2_i
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4351) }, /* 88E8036 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4352) }, /* 88E8038 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4353) }, /* 88E8039 */
-	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4356) }, /* 88E8033 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4354) }, /* 88E8040 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4356) }, /* 88EC033 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x435A) }, /* 88E8048 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4360) }, /* 88E8052 */
@@ -337,8 +337,7 @@ static void sky2_phy_init(struct sky2_hw
 
 	ctrl = gm_phy_read(hw, port, PHY_MARV_PHY_CTRL);
 	if (sky2_is_copper(hw)) {
-		if (hw->chip_id == CHIP_ID_YUKON_FE ||
-		    hw->chip_id == CHIP_ID_YUKON_FE_P) {
+ 		if (!(hw->flags & SKY2_HW_GIGABIT)) {
 			/* enable automatic crossover */
 			ctrl |= PHY_M_PC_MDI_XMODE(PHY_M_PC_ENA_AUTO) >> 1;
 		} else {
@@ -457,7 +456,7 @@ static void sky2_phy_init(struct sky2_hw
 
 	gma_write16(hw, port, GM_GP_CTRL, reg);
 
-	if (sky2_is_gigabit(hw))
+	if (hw->flags & SKY2_HW_GIGABIT)
 		gm_phy_write(hw, port, PHY_MARV_1000T_CTRL, ct1000);
 
 	gm_phy_write(hw, port, PHY_MARV_AUNE_ADV, adv);
@@ -483,11 +482,12 @@ static void sky2_phy_init(struct sky2_hw
 
 	case CHIP_ID_YUKON_FE_P:
 		/* Enable Link Partner Next Page */
+		ctrl = gm_phy_read(hw, port, PHY_MARV_PHY_CTRL);
 		ctrl |= PHY_M_PC_ENA_LIP_NP;
 
 		/* disable Energy Detect and enable scrambler */
 		ctrl &= ~(PHY_M_PC_ENA_ENE_DT | PHY_M_PC_DIS_SCRAMB);
-		gm_phy_write(hw, port, PHY_MARV_CTRL, ctrl);
+		gm_phy_write(hw, port, PHY_MARV_PHY_CTRL, ctrl);
 
 		/* set LED2 -> ACT, LED1 -> LINK, LED0 -> SPEED */
 		ctrl = PHY_M_FELP_LED2_CTRL(LED_PAR_CTRL_ACT_BL) |
@@ -691,25 +691,25 @@ static void sky2_wol_init(struct sky2_po
 
 static void sky2_set_tx_stfwd(struct sky2_hw *hw, unsigned port)
 {
-	if (hw->chip_id == CHIP_ID_YUKON_EX && hw->chip_rev != CHIP_REV_YU_EX_A0) {
+	struct net_device *dev = hw->dev[port];
+
+	if (dev->mtu <= ETH_DATA_LEN)
 		sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
-			     TX_STFW_ENA |
-			     (hw->dev[port]->mtu > ETH_DATA_LEN) ? TX_JUMBO_ENA : TX_JUMBO_DIS);
-	} else {
-		if (hw->dev[port]->mtu > ETH_DATA_LEN) {
-			/* set Tx GMAC FIFO Almost Empty Threshold */
-			sky2_write32(hw, SK_REG(port, TX_GMF_AE_THR),
-				     (ECU_JUMBO_WM << 16) | ECU_AE_THR);
-
-			sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
-				     TX_JUMBO_ENA | TX_STFW_DIS);
-
-			/* Can't do offload because of lack of store/forward */
-			hw->dev[port]->features &= ~(NETIF_F_TSO | NETIF_F_SG
-						     | NETIF_F_ALL_CSUM);
-		} else
-			sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
-				     TX_JUMBO_DIS | TX_STFW_ENA);
+			     TX_JUMBO_DIS | TX_STFW_ENA);
+
+	else if (hw->chip_id != CHIP_ID_YUKON_EC_U)
+		sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
+			     TX_STFW_ENA | TX_JUMBO_ENA);
+	else {
+		/* set Tx GMAC FIFO Almost Empty Threshold */
+		sky2_write32(hw, SK_REG(port, TX_GMF_AE_THR),
+			     (ECU_JUMBO_WM << 16) | ECU_AE_THR);
+
+		sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
+			     TX_JUMBO_ENA | TX_STFW_DIS);
+
+		/* Can't do offload because of lack of store/forward */
+		dev->features &= ~(NETIF_F_TSO | NETIF_F_SG | NETIF_F_ALL_CSUM);
 	}
 }
 
@@ -795,7 +795,8 @@ static void sky2_mac_init(struct sky2_hw
 	/* Configure Rx MAC FIFO */
 	sky2_write8(hw, SK_REG(port, RX_GMF_CTRL_T), GMF_RST_CLR);
 	rx_reg = GMF_OPER_ON | GMF_RX_F_FL_ON;
-	if (hw->chip_id == CHIP_ID_YUKON_EX)
+	if (hw->chip_id == CHIP_ID_YUKON_EX ||
+	    hw->chip_id == CHIP_ID_YUKON_FE_P)
 		rx_reg |= GMF_RX_OVER_ON;
 
 	sky2_write32(hw, SK_REG(port, RX_GMF_CTRL_T), rx_reg);
@@ -804,7 +805,12 @@ static void sky2_mac_init(struct sky2_hw
 	sky2_write16(hw, SK_REG(port, RX_GMF_FL_MSK), GMR_FS_ANY_ERR);
 
 	/* Set threshold to 0xa (64 bytes) + 1 to workaround pause bug  */
-	sky2_write16(hw, SK_REG(port, RX_GMF_FL_THR), RX_GMF_FL_THR_DEF+1);
+	reg = RX_GMF_FL_THR_DEF + 1;
+	/* Another magic mystery workaround from sk98lin */
+	if (hw->chip_id == CHIP_ID_YUKON_FE_P &&
+	    hw->chip_rev == CHIP_REV_YU_FE2_A0)
+		reg = 0x178;
+	sky2_write16(hw, SK_REG(port, RX_GMF_FL_THR), reg);
 
 	/* Configure Tx MAC FIFO */
 	sky2_write8(hw, SK_REG(port, TX_GMF_CTRL_T), GMF_RST_CLR);
@@ -1737,7 +1743,7 @@ static u16 sky2_phy_speed(const struct s
 	if (hw->flags & SKY2_HW_FIBRE_PHY)
 		return SPEED_1000;
 
-	if (!sky2_is_gigabit(hw)) {
+	if (!(hw->flags & SKY2_HW_GIGABIT)) {
 		if (aux & PHY_M_PS_SPEED_100)
 			return SPEED_100;
 		else
@@ -2005,7 +2011,7 @@ static int sky2_change_mtu(struct net_de
 
 	synchronize_irq(hw->pdev->irq);
 
-	if (hw->chip_id == CHIP_ID_YUKON_EC_U || hw->chip_id == CHIP_ID_YUKON_EX)
+	if (!(hw->flags & SKY2_HW_RAMBUFFER))
 		sky2_set_tx_stfwd(hw, port);
 
 	ctl = gma_read16(hw, port, GM_GP_CTRL);
@@ -2248,7 +2254,7 @@ static int sky2_status_intr(struct sky2_
 			}
 
 			/* This chip reports checksum status differently */
-			if (hw->chip_id == CHIP_ID_YUKON_EX) {
+			if (hw->flags & SKY2_HW_NEW_LE) {
 				if (sky2->rx_csum &&
 				    (le->css & (CSS_ISIPV4 | CSS_ISIPV6)) &&
 				    (le->css & CSS_TCPUDPCSOK))
@@ -2289,8 +2295,14 @@ static int sky2_status_intr(struct sky2_
 			if (!sky2->rx_csum)
 				break;
 
-			if (hw->chip_id == CHIP_ID_YUKON_EX)
+			/* If this happens then driver assuming wrong format */
+			if (unlikely(hw->flags & SKY2_HW_NEW_LE)) {
+				if (net_ratelimit())
+					printk(KERN_NOTICE "%s: unexpected"
+					       " checksum status\n",
+					       dev->name);
 				break;
+			}
 
 			/* Both checksum counters are programmed to start at
 			 * the same offset, so unless there is a problem they
@@ -2657,6 +2669,12 @@ static int __devinit sky2_init(struct sk
 		hw->flags = SKY2_HW_RAMBUFFER;
 		break;
 
+	case CHIP_ID_YUKON_FE_P:
+		hw->flags = SKY2_HW_NEWER_PHY
+			| SKY2_HW_NEW_LE
+			| SKY2_HW_AUTO_TX_SUM
+			| SKY2_HW_ADV_POWER_CTL;
+		break;
 	default:
 		dev_err(&hw->pdev->dev, "unsupported chip type 0x%x\n",
 			hw->chip_id);
@@ -2864,7 +2882,9 @@ static int sky2_set_wol(struct net_devic
 
 	sky2->wol = wol->wolopts;
 
-	if (hw->chip_id == CHIP_ID_YUKON_EC_U || hw->chip_id == CHIP_ID_YUKON_EX)
+	if (hw->chip_id == CHIP_ID_YUKON_EC_U ||
+	    hw->chip_id == CHIP_ID_YUKON_EX ||
+	    hw->chip_id == CHIP_ID_YUKON_FE_P)
 		sky2_write32(hw, B0_CTST, sky2->wol
 			     ? Y2_HW_WOL_ON : Y2_HW_WOL_OFF);
 
@@ -3848,6 +3868,13 @@ static __devinit struct net_device *sky2
 	sky2->hw = hw;
 	sky2->msg_enable = netif_msg_init(debug, default_msg);
 
+	/* This chip has hardware problems that generates
+	 * bogus PHY receive status so by default shut up the message.
+	 */
+	if (hw->chip_id == CHIP_ID_YUKON_FE_P &&
+	    hw->chip_rev == CHIP_REV_YU_FE2_A0)
+		sky2->msg_enable &= ~NETIF_MSG_RX_ERR;
+
 	/* Auto speed and flow control */
 	sky2->autoneg = AUTONEG_ENABLE;
 	sky2->flow_mode = FC_BOTH;
@@ -4214,7 +4241,7 @@ static int sky2_resume(struct pci_dev *p
 	pci_enable_wake(pdev, PCI_D0, 0);
 
 	/* Re-enable all clocks */
-	if (hw->chip_id == CHIP_ID_YUKON_EX || hw->chip_id == CHIP_ID_YUKON_EC_U)
+	if (hw->flags & SKY2_HW_ADV_POWER_CTL)
 		pci_write_config_dword(pdev, PCI_DEV_REG3, 0);
 
 	sky2_reset(hw);
--- a/drivers/net/sky2.h	2007-09-19 21:57:42.000000000 -0700
+++ b/drivers/net/sky2.h	2007-09-19 21:58:08.000000000 -0700
@@ -1694,6 +1694,10 @@ enum {
 	GMF_RX_CTRL_DEF	= GMF_OPER_ON | GMF_RX_F_FL_ON,
 };
 
+/*	TX_GMF_EA		32 bit	Tx GMAC FIFO End Address */
+enum {
+	TX_DYN_WM_ENA	= 3,	/* Yukon-FE+ specific */
+};
 
 /*	TX_GMF_CTRL_T	32 bit	Tx GMAC FIFO Control/Test */
 enum {
@@ -2058,12 +2062,6 @@ static inline int sky2_is_copper(const s
 	return !(hw->flags & SKY2_HW_FIBRE_PHY);
 }
 
-static inline int sky2_is_gigabit(const struct sky2_hw *hw)
-{
-	return !(hw->chip_id == CHIP_ID_YUKON_FE
-		 || hw->chip_id == CHIP_ID_YUKON_FE_P);
-}
-
 /* Register accessor for memory mapped device */
 static inline u32 sky2_read32(const struct sky2_hw *hw, unsigned reg)
 {

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

