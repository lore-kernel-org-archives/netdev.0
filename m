From: shemminger@osdl.org
Subject: [RFT 5/5] sky2: fix fiber support
Date: Tue, 05 Sep 2006 15:27:39 -0700
Message-ID: <20060905223001.761973656@localhost.localdomain>
References: <20060905222734.082143263@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:152 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965243AbWIEWd4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2006 18:33:56 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-fiber.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix support for fiber based devices.  Needed to keep track of PMD type to
add workaround in setup. Add support for gigabit half duplex fiber.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 drivers/net/sky2.c |   81 ++++++++++++++++++++++++++++++++---------------------
 drivers/net/sky2.h |   15 +++++++++
 2 files changed, 63 insertions(+), 33 deletions(-)

--- sky2.orig/drivers/net/sky2.c	2006-09-05 13:57:44.000000000 -0700
+++ sky2/drivers/net/sky2.c	2006-09-05 14:00:04.000000000 -0700
@@ -308,7 +308,7 @@
 	}
 
 	ctrl = gm_phy_read(hw, port, PHY_MARV_PHY_CTRL);
-	if (hw->copper) {
+	if (sky2_is_copper(hw)) {
 		if (hw->chip_id == CHIP_ID_YUKON_FE) {
 			/* enable automatic crossover */
 			ctrl |= PHY_M_PC_MDI_XMODE(PHY_M_PC_ENA_AUTO) >> 1;
@@ -325,25 +325,37 @@
 				ctrl |= PHY_M_PC_DSC(2) | PHY_M_PC_DOWN_S_ENA;
 			}
 		}
-		gm_phy_write(hw, port, PHY_MARV_PHY_CTRL, ctrl);
 	} else {
 		/* workaround for deviation #4.88 (CRC errors) */
 		/* disable Automatic Crossover */
 
 		ctrl &= ~PHY_M_PC_MDIX_MSK;
-		gm_phy_write(hw, port, PHY_MARV_PHY_CTRL, ctrl);
+	}
 
-		if (hw->chip_id == CHIP_ID_YUKON_XL) {
-			/* Fiber: select 1000BASE-X only mode MAC Specific Ctrl Reg. */
-			gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 2);
-			ctrl = gm_phy_read(hw, port, PHY_MARV_PHY_CTRL);
-			ctrl &= ~PHY_M_MAC_MD_MSK;
-			ctrl |= PHY_M_MAC_MODE_SEL(PHY_M_MAC_MD_1000BX);
-			gm_phy_write(hw, port, PHY_MARV_PHY_CTRL, ctrl);
+	gm_phy_write(hw, port, PHY_MARV_PHY_CTRL, ctrl);
+
+	/* special setup for PHY 88E1112 Fiber */
+	if (hw->chip_id == CHIP_ID_YUKON_XL && !sky2_is_copper(hw)) {
+		pg = gm_phy_read(hw, port, PHY_MARV_EXT_ADR);
 
+		/* Fiber: select 1000BASE-X only mode MAC Specific Ctrl Reg. */
+		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 2);
+		ctrl = gm_phy_read(hw, port, PHY_MARV_PHY_CTRL);
+		ctrl &= ~PHY_M_MAC_MD_MSK;
+		ctrl |= PHY_M_MAC_MODE_SEL(PHY_M_MAC_MD_1000BX);
+		gm_phy_write(hw, port, PHY_MARV_PHY_CTRL, ctrl);
+
+		if (hw->pmd_type  == 'P') {
 			/* select page 1 to access Fiber registers */
 			gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 1);
+
+			/* for SFP-module set SIGDET polarity to low */
+			ctrl = gm_phy_read(hw, port, PHY_MARV_PHY_CTRL);
+			ctrl |= PHY_M_FIB_SIGD_POL;
+			gm_phy_write(hw, port, PHY_MARV_CTRL, ctrl);
 		}
+
+		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, pg);
 	}
 
 	ctrl = gm_phy_read(hw, port, PHY_MARV_CTRL);
@@ -361,7 +373,7 @@
 	reg = 0;
 
 	if (sky2->autoneg == AUTONEG_ENABLE) {
-		if (hw->copper) {
+		if (sky2_is_copper(hw)) {
 			if (sky2->advertising & ADVERTISED_1000baseT_Full)
 				ct1000 |= PHY_M_1000C_AFD;
 			if (sky2->advertising & ADVERTISED_1000baseT_Half)
@@ -374,8 +386,12 @@
 				adv |= PHY_M_AN_10_FD;
 			if (sky2->advertising & ADVERTISED_10baseT_Half)
 				adv |= PHY_M_AN_10_HD;
-		} else		/* special defines for FIBER (88E1011S only) */
-			adv |= PHY_M_AN_1000X_AHD | PHY_M_AN_1000X_AFD;
+		} else {	/* special defines for FIBER (88E1040S only) */
+			if (sky2->advertising & ADVERTISED_1000baseT_Full)
+				adv |= PHY_M_AN_1000X_AFD;
+			if (sky2->advertising & ADVERTISED_1000baseT_Half)
+				adv |= PHY_M_AN_1000X_AHD;
+		}
 
 		/* Set Flow-control capabilities */
 		if (sky2->tx_pause && sky2->rx_pause)
@@ -1494,7 +1510,7 @@
 
 static u16 sky2_phy_speed(const struct sky2_hw *hw, u16 aux)
 {
-	if (!hw->copper)
+	if (!sky2_is_copper(hw))
 		return SPEED_1000;
 
 	if (hw->chip_id == CHIP_ID_YUKON_FE)
@@ -2266,7 +2282,7 @@
 static int sky2_reset(struct sky2_hw *hw)
 {
 	u16 status;
-	u8 t8, pmd_type;
+	u8 t8;
 	int i;
 
 	sky2_write8(hw, B0_CTST, CS_RST_CLR);
@@ -2312,9 +2328,7 @@
 		sky2_pci_write32(hw, PEX_UNC_ERR_STAT, 0xffffffffUL);
 
 
-	pmd_type = sky2_read8(hw, B2_PMD_TYP);
-	hw->copper = !(pmd_type == 'L' || pmd_type == 'S');
-
+	hw->pmd_type = sky2_read8(hw, B2_PMD_TYP);
 	hw->ports = 1;
 	t8 = sky2_read8(hw, B2_Y2_HW_RES);
 	if ((t8 & CFG_DUAL_MAC_MSK) == CFG_DUAL_MAC_MSK) {
@@ -2411,21 +2425,22 @@
 
 static u32 sky2_supported_modes(const struct sky2_hw *hw)
 {
-	u32 modes;
-	if (hw->copper) {
-		modes = SUPPORTED_10baseT_Half
-		    | SUPPORTED_10baseT_Full
-		    | SUPPORTED_100baseT_Half
-		    | SUPPORTED_100baseT_Full
-		    | SUPPORTED_Autoneg | SUPPORTED_TP;
+	if (sky2_is_copper(hw)) {
+		u32 modes = SUPPORTED_10baseT_Half
+			| SUPPORTED_10baseT_Full
+			| SUPPORTED_100baseT_Half
+			| SUPPORTED_100baseT_Full
+			| SUPPORTED_Autoneg | SUPPORTED_TP;
 
 		if (hw->chip_id != CHIP_ID_YUKON_FE)
 			modes |= SUPPORTED_1000baseT_Half
-			    | SUPPORTED_1000baseT_Full;
+				| SUPPORTED_1000baseT_Full;
+		return modes;
 	} else
-		modes = SUPPORTED_1000baseT_Full | SUPPORTED_FIBRE
-		    | SUPPORTED_Autoneg;
-	return modes;
+		return  SUPPORTED_1000baseT_Half
+			| SUPPORTED_1000baseT_Full
+			| SUPPORTED_Autoneg
+			| SUPPORTED_FIBRE;
 }
 
 static int sky2_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
@@ -2436,7 +2451,7 @@
 	ecmd->transceiver = XCVR_INTERNAL;
 	ecmd->supported = sky2_supported_modes(hw);
 	ecmd->phy_address = PHY_ADDR_MARV;
-	if (hw->copper) {
+	if (sky2_is_copper(hw)) {
 		ecmd->supported = SUPPORTED_10baseT_Half
 		    | SUPPORTED_10baseT_Full
 		    | SUPPORTED_100baseT_Half
@@ -2445,12 +2460,14 @@
 		    | SUPPORTED_1000baseT_Full
 		    | SUPPORTED_Autoneg | SUPPORTED_TP;
 		ecmd->port = PORT_TP;
-	} else
+		ecmd->speed = sky2->speed;
+	} else {
+		ecmd->speed = SPEED_1000;
 		ecmd->port = PORT_FIBRE;
+	}
 
 	ecmd->advertising = sky2->advertising;
 	ecmd->autoneg = sky2->autoneg;
-	ecmd->speed = sky2->speed;
 	ecmd->duplex = sky2->duplex;
 	return 0;
 }
--- sky2.orig/drivers/net/sky2.h	2006-09-05 13:55:55.000000000 -0700
+++ sky2/drivers/net/sky2.h	2006-09-05 14:00:04.000000000 -0700
@@ -1318,6 +1318,14 @@
 };
 
 /* for Yukon-2 Gigabit Ethernet PHY (88E1112 only) */
+/*****  PHY_MARV_PHY_CTRL (page 1)		16 bit r/w	Fiber Specific Ctrl *****/
+enum {
+	PHY_M_FIB_FORCE_LNK	= 1<<10,/* Force Link Good */
+	PHY_M_FIB_SIGD_POL	= 1<<9,	/* SIGDET Polarity */
+	PHY_M_FIB_TX_DIS	= 1<<3,	/* Transmitter Disable */
+};
+
+/* for Yukon-2 Gigabit Ethernet PHY (88E1112 only) */
 /*****  PHY_MARV_PHY_CTRL (page 2)		16 bit r/w	MAC Specific Ctrl *****/
 enum {
 	PHY_M_MAC_MD_MSK	= 7<<7, /* Bit  9.. 7: Mode Select Mask */
@@ -1867,7 +1875,7 @@
 	int		     pm_cap;
 	u8	     	     chip_id;
 	u8		     chip_rev;
-	u8		     copper;
+	u8		     pmd_type;
 	u8		     ports;
 
 	struct sky2_status_le *st_le;
@@ -1879,6 +1887,11 @@
 	wait_queue_head_t    msi_wait;
 };
 
+static inline int sky2_is_copper(const struct sky2_hw *hw)
+{
+	return !(hw->pmd_type == 'L' || hw->pmd_type == 'S' || hw->pmd_type == 'P');
+}
+
 /* Register accessor for memory mapped device */
 static inline u32 sky2_read32(const struct sky2_hw *hw, unsigned reg)
 {

--
Stephen Hemminger <shemminger@osdl.org>

