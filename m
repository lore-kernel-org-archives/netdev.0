From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 4/6] sky2: fe+ chip support
Date: Wed, 19 Sep 2007 15:36:45 -0700
Message-ID: <20070919223746.662191392@linux-foundation.org>
References: <20070919223641.860189786@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzk <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:47369 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754413AbXISXQp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 19:16:45 -0400
Content-Disposition: inline; filename=sky2-fe-p.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for newest Marvell chips.
The Yukon FE plus chip is found in some not yet released laptops.
Tested on hardware evaluation boards.

This version of the patch is for 2.6.23. It supersedes
the two previous patches that are sitting in netdev-2.6 (upstream branch).

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/drivers/net/sky2.c	2007-09-19 10:01:34.000000000 -0700
+++ b/drivers/net/sky2.c	2007-09-19 10:05:15.000000000 -0700
@@ -118,12 +118,15 @@ static const struct pci_device_id sky2_i
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4351) }, /* 88E8036 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4352) }, /* 88E8038 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4353) }, /* 88E8039 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4354) }, /* 88E8040 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4356) }, /* 88EC033 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x435A) }, /* 88E8048 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4360) }, /* 88E8052 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4361) }, /* 88E8050 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4362) }, /* 88E8053 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4363) }, /* 88E8055 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4364) }, /* 88E8056 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4365) }, /* 88E8070 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4366) }, /* 88EC036 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4367) }, /* 88EC032 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4368) }, /* 88EC034 */
@@ -147,6 +150,7 @@ static const char *yukon2_name[] = {
 	"Extreme",	/* 0xb5 */
 	"EC",		/* 0xb6 */
 	"FE",		/* 0xb7 */
+	"FE+",		/* 0xb8 */
 };
 
 static void sky2_set_multicast(struct net_device *dev);
@@ -331,7 +335,7 @@ static void sky2_phy_init(struct sky2_hw
 
 	ctrl = gm_phy_read(hw, port, PHY_MARV_PHY_CTRL);
 	if (sky2_is_copper(hw)) {
-		if (hw->chip_id == CHIP_ID_YUKON_FE) {
+		if (!(hw->flags & SKY2_HW_GIGABIT)) {
 			/* enable automatic crossover */
 			ctrl |= PHY_M_PC_MDI_XMODE(PHY_M_PC_ENA_AUTO) >> 1;
 		} else {
@@ -450,7 +454,7 @@ static void sky2_phy_init(struct sky2_hw
 
 	gma_write16(hw, port, GM_GP_CTRL, reg);
 
-	if (hw->chip_id != CHIP_ID_YUKON_FE)
+	if (hw->flags & SKY2_HW_GIGABIT)
 		gm_phy_write(hw, port, PHY_MARV_1000T_CTRL, ct1000);
 
 	gm_phy_write(hw, port, PHY_MARV_AUNE_ADV, adv);
@@ -474,6 +478,23 @@ static void sky2_phy_init(struct sky2_hw
 		gm_phy_write(hw, port, PHY_MARV_FE_LED_PAR, ctrl);
 		break;
 
+	case CHIP_ID_YUKON_FE_P:
+		/* Enable Link Partner Next Page */
+		ctrl = gm_phy_read(hw, port, PHY_MARV_PHY_CTRL);
+		ctrl |= PHY_M_PC_ENA_LIP_NP;
+
+		/* disable Energy Detect and enable scrambler */
+		ctrl &= ~(PHY_M_PC_ENA_ENE_DT | PHY_M_PC_DIS_SCRAMB);
+		gm_phy_write(hw, port, PHY_MARV_PHY_CTRL, ctrl);
+
+		/* set LED2 -> ACT, LED1 -> LINK, LED0 -> SPEED */
+		ctrl = PHY_M_FELP_LED2_CTRL(LED_PAR_CTRL_ACT_BL) |
+			PHY_M_FELP_LED1_CTRL(LED_PAR_CTRL_LINK) |
+			PHY_M_FELP_LED0_CTRL(LED_PAR_CTRL_SPEED);
+
+		gm_phy_write(hw, port, PHY_MARV_FE_LED_PAR, ctrl);
+		break;
+
 	case CHIP_ID_YUKON_XL:
 		pg = gm_phy_read(hw, port, PHY_MARV_EXT_ADR);
 
@@ -543,7 +564,13 @@ static void sky2_phy_init(struct sky2_hw
 
 		/* set page register to 0 */
 		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 0);
+	} else if (hw->chip_id == CHIP_ID_YUKON_FE_P &&
+		   hw->chip_rev == CHIP_REV_YU_FE2_A0) {
+		/* apply workaround for integrated resistors calibration */
+		gm_phy_write(hw, port, PHY_MARV_PAGE_ADDR, 17);
+		gm_phy_write(hw, port, PHY_MARV_PAGE_DATA, 0x3f60);
 	} else if (hw->chip_id != CHIP_ID_YUKON_EX) {
+		/* no effect on Yukon-XL */
 		gm_phy_write(hw, port, PHY_MARV_LED_CTRL, ledctrl);
 
 		if (sky2->autoneg == AUTONEG_DISABLE || sky2->speed == SPEED_100) {
@@ -664,25 +691,25 @@ static void sky2_wol_init(struct sky2_po
 
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
 
@@ -768,7 +795,8 @@ static void sky2_mac_init(struct sky2_hw
 	/* Configure Rx MAC FIFO */
 	sky2_write8(hw, SK_REG(port, RX_GMF_CTRL_T), GMF_RST_CLR);
 	rx_reg = GMF_OPER_ON | GMF_RX_F_FL_ON;
-	if (hw->chip_id == CHIP_ID_YUKON_EX)
+	if (hw->chip_id == CHIP_ID_YUKON_EX ||
+	    hw->chip_id == CHIP_ID_YUKON_FE_P)
 		rx_reg |= GMF_RX_OVER_ON;
 
 	sky2_write32(hw, SK_REG(port, RX_GMF_CTRL_T), rx_reg);
@@ -777,7 +805,12 @@ static void sky2_mac_init(struct sky2_hw
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
@@ -1704,8 +1737,12 @@ static u16 sky2_phy_speed(const struct s
 	if (hw->flags & SKY2_HW_FIBRE_PHY)
 		return SPEED_1000;
 
-	if (hw->chip_id == CHIP_ID_YUKON_FE)
-		return (aux & PHY_M_PS_SPEED_100) ? SPEED_100 : SPEED_10;
+	if (!(hw->flags & SKY2_HW_GIGABIT)) {
+		if (aux & PHY_M_PS_SPEED_100)
+			return SPEED_100;
+		else
+			return SPEED_10;
+	}
 
 	switch (aux & PHY_M_PS_SPEED_MSK) {
 	case PHY_M_PS_SPEED_1000:
@@ -1949,7 +1986,9 @@ static int sky2_change_mtu(struct net_de
 	if (new_mtu < ETH_ZLEN || new_mtu > ETH_JUMBO_MTU)
 		return -EINVAL;
 
-	if (new_mtu > ETH_DATA_LEN && hw->chip_id == CHIP_ID_YUKON_FE)
+	if (new_mtu > ETH_DATA_LEN &&
+	    (hw->chip_id == CHIP_ID_YUKON_FE ||
+	     hw->chip_id == CHIP_ID_YUKON_FE_P))
 		return -EINVAL;
 
 	if (!netif_running(dev)) {
@@ -1966,7 +2005,7 @@ static int sky2_change_mtu(struct net_de
 
 	synchronize_irq(hw->pdev->irq);
 
-	if (hw->chip_id == CHIP_ID_YUKON_EC_U || hw->chip_id == CHIP_ID_YUKON_EX)
+	if (!(hw->flags & SKY2_HW_RAMBUFFER))
 		sky2_set_tx_stfwd(hw, port);
 
 	ctl = gma_read16(hw, port, GM_GP_CTRL);
@@ -2205,7 +2244,7 @@ static int sky2_status_intr(struct sky2_
 			}
 
 			/* This chip reports checksum status differently */
-			if (hw->chip_id == CHIP_ID_YUKON_EX) {
+			if (hw->flags & SKY2_HW_NEW_LE) {
 				if (sky2->rx_csum &&
 				    (le->css & (CSS_ISIPV4 | CSS_ISIPV6)) &&
 				    (le->css & CSS_TCPUDPCSOK))
@@ -2246,8 +2285,14 @@ static int sky2_status_intr(struct sky2_
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
@@ -2549,17 +2594,25 @@ static void sky2_netpoll(struct net_devi
 #endif
 
 /* Chip internal frequency for clock calculations */
-static inline u32 sky2_mhz(const struct sky2_hw *hw)
+static u32 sky2_mhz(const struct sky2_hw *hw)
 {
 	switch (hw->chip_id) {
 	case CHIP_ID_YUKON_EC:
 	case CHIP_ID_YUKON_EC_U:
 	case CHIP_ID_YUKON_EX:
-		return 125;	/* 125 Mhz */
+		return 125;
+
 	case CHIP_ID_YUKON_FE:
-		return 100;	/* 100 Mhz */
-	default:		/* YUKON_XL */
-		return 156;	/* 156 Mhz */
+		return 100;
+
+	case CHIP_ID_YUKON_FE_P:
+		return 50;
+
+	case CHIP_ID_YUKON_XL:
+		return 156;
+
+	default:
+		BUG();
 	}
 }
 
@@ -2623,6 +2676,12 @@ static int __devinit sky2_init(struct sk
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
@@ -2827,7 +2886,9 @@ static int sky2_set_wol(struct net_devic
 
 	sky2->wol = wol->wolopts;
 
-	if (hw->chip_id == CHIP_ID_YUKON_EC_U || hw->chip_id == CHIP_ID_YUKON_EX)
+	if (hw->chip_id == CHIP_ID_YUKON_EC_U ||
+	    hw->chip_id == CHIP_ID_YUKON_EX ||
+	    hw->chip_id == CHIP_ID_YUKON_FE_P)
 		sky2_write32(hw, B0_CTST, sky2->wol
 			     ? Y2_HW_WOL_ON : Y2_HW_WOL_OFF);
 
@@ -3820,6 +3881,13 @@ static __devinit struct net_device *sky2
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
@@ -4189,7 +4257,9 @@ static int sky2_resume(struct pci_dev *p
 	pci_enable_wake(pdev, PCI_D0, 0);
 
 	/* Re-enable all clocks */
-	if (hw->chip_id == CHIP_ID_YUKON_EX || hw->chip_id == CHIP_ID_YUKON_EC_U)
+	if (hw->chip_id == CHIP_ID_YUKON_EX ||
+	    hw->chip_id == CHIP_ID_YUKON_EC_U ||
+	    hw->chip_id == CHIP_ID_YUKON_FE_P)
 		sky2_pci_write32(hw, PCI_DEV_REG3, 0);
 
 	sky2_reset(hw);
--- a/drivers/net/sky2.h	2007-09-19 10:01:34.000000000 -0700
+++ b/drivers/net/sky2.h	2007-09-19 10:03:46.000000000 -0700
@@ -470,18 +470,24 @@ enum {
 	CHIP_ID_YUKON_EX   = 0xb5, /* Chip ID for YUKON-2 Extreme */
 	CHIP_ID_YUKON_EC   = 0xb6, /* Chip ID for YUKON-2 EC */
  	CHIP_ID_YUKON_FE   = 0xb7, /* Chip ID for YUKON-2 FE */
-
+ 	CHIP_ID_YUKON_FE_P = 0xb8, /* Chip ID for YUKON-2 FE+ */
+};
+enum yukon_ec_rev {
 	CHIP_REV_YU_EC_A1    = 0,  /* Chip Rev. for Yukon-EC A1/A0 */
 	CHIP_REV_YU_EC_A2    = 1,  /* Chip Rev. for Yukon-EC A2 */
 	CHIP_REV_YU_EC_A3    = 2,  /* Chip Rev. for Yukon-EC A3 */
-
+};
+enum yukon_ec_u_rev {
 	CHIP_REV_YU_EC_U_A0  = 1,
 	CHIP_REV_YU_EC_U_A1  = 2,
 	CHIP_REV_YU_EC_U_B0  = 3,
-
+};
+enum yukon_fe_rev {
 	CHIP_REV_YU_FE_A1    = 1,
 	CHIP_REV_YU_FE_A2    = 2,
-
+};
+enum yukon_fe_p_rev {
+	CHIP_REV_YU_FE2_A0   = 0,
 };
 enum yukon_ex_rev {
 	CHIP_REV_YU_EX_A0    = 1,
@@ -1729,6 +1735,10 @@ enum {
 	GMF_RX_CTRL_DEF	= GMF_OPER_ON | GMF_RX_F_FL_ON,
 };
 
+/*	TX_GMF_EA		32 bit	Tx GMAC FIFO End Address */
+enum {
+	TX_DYN_WM_ENA	= 3,	/* Yukon-FE+ specific */
+};
 
 /*	TX_GMF_CTRL_T	32 bit	Tx GMAC FIFO Control/Test */
 enum {

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

