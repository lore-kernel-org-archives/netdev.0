From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 4/5] sky2: put PHY in sleep when down
Date: Wed, 14 May 2008 17:04:16 -0700
Message-ID: <20080515000433.136758134@vyatta.com>
References: <20080515000412.984337700@vyatta.com>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([69.59.150.140]:49969 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760159AbYEOAIU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2008 20:08:20 -0400
Content-Disposition: inline; filename=sky2-deep-sleep.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Put PHY int sleep mode (from vendor sk98lin 10.50 driver) when the
network device is brought down.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
---
This can wait for next release (#upstream) and go in -mm

--- a/drivers/net/sky2.c	2008-05-14 16:29:46.000000000 -0700
+++ b/drivers/net/sky2.c	2008-05-14 16:29:48.000000000 -0700
@@ -641,11 +641,47 @@ static void sky2_phy_power_up(struct sky
 static void sky2_phy_power_down(struct sky2_hw *hw, unsigned port)
 {
 	u32 reg1;
+	u16 ctrl;
+
+	/* release GPHY Control reset */
+	sky2_write8(hw, SK_REG(port, GPHY_CTRL), GPC_RST_CLR);
+
+	/* release GMAC reset */
+	sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_RST_CLR);
+
+	if (hw->flags & SKY2_HW_NEWER_PHY) {
+		/* select page 2 to access MAC control register */
+		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 2);
+
+		ctrl = gm_phy_read(hw, port, PHY_MARV_PHY_CTRL);
+		/* allow GMII Power Down */
+		ctrl &= ~PHY_M_MAC_GMIF_PUP;
+		gm_phy_write(hw, port, PHY_MARV_PHY_CTRL, ctrl);
+
+		/* set page register back to 0 */
+		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 0);
+	}
+
+	/* setup General Purpose Control Register */
+	gma_write16(hw, port, GM_GP_CTRL,
+		    GM_GPCR_FL_PASS | GM_GPCR_SPEED_100 | GM_GPCR_AU_ALL_DIS);
+
+	if (hw->chip_id != CHIP_ID_YUKON_EC) {
+		if (hw->chip_id == CHIP_ID_YUKON_EC_U) {
+			ctrl = gm_phy_read(hw, port, PHY_MARV_PHY_CTRL);
+
+			/* enable Power Down */
+			ctrl |= PHY_M_PC_POW_D_ENA;
+			gm_phy_write(hw, port, PHY_MARV_PHY_CTRL, ctrl);
+		}
+
+		/* set IEEE compatible Power Down Mode (dev. #4.99) */
+		gm_phy_write(hw, port, PHY_MARV_CTRL, PHY_CT_PDOWN);
+	}
 
 	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
 	reg1 = sky2_pci_read32(hw, PCI_DEV_REG1);
-	reg1 |= phy_power[port];
-
+	reg1 |= phy_power[port];		/* set PHY to PowerDown/COMA Mode */
 	sky2_pci_write32(hw, PCI_DEV_REG1, reg1);
 	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
 }
--- a/drivers/net/sky2.h	2008-05-14 16:29:12.000000000 -0700
+++ b/drivers/net/sky2.h	2008-05-14 16:29:48.000000000 -0700
@@ -1143,6 +1143,12 @@ enum {
 	PHY_M_PC_ENA_AUTO	= 3, /* 11 = Enable Automatic Crossover */
 };
 
+/* for Yukon-EC Ultra Gigabit Ethernet PHY (88E1149 only) */
+enum {
+	PHY_M_PC_COP_TX_DIS	= 1<<3, /* Copper Transmitter Disable */
+	PHY_M_PC_POW_D_ENA	= 1<<2,	/* Power Down Enable */
+};
+
 /* for 10/100 Fast Ethernet PHY (88E3082 only) */
 enum {
 	PHY_M_PC_ENA_DTE_DT	= 1<<15, /* Enable Data Terminal Equ. (DTE) Detect */
@@ -1411,6 +1417,7 @@ enum {
 /*****  PHY_MARV_PHY_CTRL (page 2)		16 bit r/w	MAC Specific Ctrl *****/
 enum {
 	PHY_M_MAC_MD_MSK	= 7<<7, /* Bit  9.. 7: Mode Select Mask */
+	PHY_M_MAC_GMIF_PUP	= 1<<3,	/* GMII Power Up (88E1149 only) */
 	PHY_M_MAC_MD_AUTO	= 3,/* Auto Copper/1000Base-X */
 	PHY_M_MAC_MD_COPPER	= 5,/* Copper only */
 	PHY_M_MAC_MD_1000BX	= 7,/* 1000Base-X only */

-- 

