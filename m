From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 3/4] sky2: support for Yukon Supreme
Date: Thu, 10 Jan 2008 16:14:14 -0800
Message-ID: <20080111001550.913815702@linux-foundation.org>
References: <20080111001411.158113585@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:32882 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754301AbYAKDP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 22:15:28 -0500
Content-Disposition: inline; filename=sky2-supreme.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support from sk98lin vendor driver 10.50.1.3 for 88E8055 and
88E8075 chips.  I don't have this hardware to test, so this changes
are untested.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
Please add to staging tree for 2.6.25.

--- a/drivers/net/sky2.c	2008-01-10 15:49:20.000000000 -0800
+++ b/drivers/net/sky2.c	2008-01-10 15:49:27.000000000 -0800
@@ -134,6 +134,8 @@ static const struct pci_device_id sky2_i
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x436A) }, /* 88E8058 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x436B) }, /* 88E8071 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x436C) }, /* 88E8072 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x436D) }, /* 88E8055 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4370) }, /* 88E8075 */
 	{ 0 }
 };
 
@@ -547,6 +549,7 @@ static void sky2_phy_init(struct sky2_hw
 
 	case CHIP_ID_YUKON_EC_U:
 	case CHIP_ID_YUKON_EX:
+	case CHIP_ID_YUKON_SUPR:
 		pg = gm_phy_read(hw, port, PHY_MARV_EXT_ADR);
 
 		/* select page 3 to access LED control register */
@@ -713,23 +716,33 @@ static void sky2_set_tx_stfwd(struct sky
 {
 	struct net_device *dev = hw->dev[port];
 
-	if (dev->mtu <= ETH_DATA_LEN)
-		sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
-			     TX_JUMBO_DIS | TX_STFW_ENA);
+	if ( (hw->chip_id == CHIP_ID_YUKON_EX &&
+	      hw->chip_rev != CHIP_REV_YU_EX_A0) ||
+	     hw->chip_id == CHIP_ID_YUKON_FE_P ||
+	     hw->chip_id == CHIP_ID_YUKON_SUPR) {
+		/* Yukon-Extreme B0 and further Extreme devices */
+		/* enable Store & Forward mode for TX */
+
+		if (dev->mtu <= ETH_DATA_LEN)
+			sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
+				     TX_JUMBO_DIS | TX_STFW_ENA);
 
-	else if (hw->chip_id != CHIP_ID_YUKON_EC_U)
-		sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
-			     TX_STFW_ENA | TX_JUMBO_ENA);
-	else {
-		/* set Tx GMAC FIFO Almost Empty Threshold */
-		sky2_write32(hw, SK_REG(port, TX_GMF_AE_THR),
-			     (ECU_JUMBO_WM << 16) | ECU_AE_THR);
+		else
+			sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
+				     TX_JUMBO_ENA| TX_STFW_ENA);
+	} else {
+		if (dev->mtu <= ETH_DATA_LEN)
+			sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T), TX_STFW_ENA);
+		else {
+			/* set Tx GMAC FIFO Almost Empty Threshold */
+			sky2_write32(hw, SK_REG(port, TX_GMF_AE_THR),
+				     (ECU_JUMBO_WM << 16) | ECU_AE_THR);
 
-		sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
-			     TX_JUMBO_ENA | TX_STFW_DIS);
+			sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T), TX_STFW_DIS);
 
-		/* Can't do offload because of lack of store/forward */
-		dev->features &= ~(NETIF_F_TSO | NETIF_F_SG | NETIF_F_ALL_CSUM);
+			/* Can't do offload because of lack of store/forward */
+			dev->features &= ~(NETIF_F_TSO | NETIF_F_SG | NETIF_F_ALL_CSUM);
+		}
 	}
 }
 
@@ -2660,6 +2673,7 @@ static u32 sky2_mhz(const struct sky2_hw
 	case CHIP_ID_YUKON_EC:
 	case CHIP_ID_YUKON_EC_U:
 	case CHIP_ID_YUKON_EX:
+	case CHIP_ID_YUKON_SUPR:
 		return 125;
 
 	case CHIP_ID_YUKON_FE:
@@ -2743,6 +2757,15 @@ static int __devinit sky2_init(struct sk
 			| SKY2_HW_AUTO_TX_SUM
 			| SKY2_HW_ADV_POWER_CTL;
 		break;
+
+	case CHIP_ID_YUKON_SUPR:
+		hw->flags = SKY2_HW_GIGABIT
+			| SKY2_HW_NEWER_PHY
+			| SKY2_HW_NEW_LE
+			| SKY2_HW_AUTO_TX_SUM
+			| SKY2_HW_ADV_POWER_CTL;
+		break;
+
 	default:
 		dev_err(&hw->pdev->dev, "unsupported chip type 0x%x\n",
 			hw->chip_id);
@@ -2813,7 +2836,8 @@ static void sky2_reset(struct sky2_hw *h
 		sky2_write8(hw, SK_REG(i, GMAC_LINK_CTRL), GMLC_RST_SET);
 		sky2_write8(hw, SK_REG(i, GMAC_LINK_CTRL), GMLC_RST_CLR);
 
-		if (hw->chip_id == CHIP_ID_YUKON_EX)
+		if (hw->chip_id == CHIP_ID_YUKON_EX ||
+		    hw->chip_id == CHIP_ID_YUKON_SUPR)
 			sky2_write16(hw, SK_REG(i, GMAC_CTRL),
 				     GMC_BYP_MACSECRX_ON | GMC_BYP_MACSECTX_ON
 				     | GMC_BYP_RETR_ON);
--- a/drivers/net/sky2.h	2008-01-10 15:49:12.000000000 -0800
+++ b/drivers/net/sky2.h	2008-01-10 15:49:27.000000000 -0800
@@ -425,12 +425,13 @@ enum {
 
 /*	B2_CHIP_ID		 8 bit 	Chip Identification Number */
 enum {
-	CHIP_ID_YUKON_XL   = 0xb3, /* Chip ID for YUKON-2 XL */
-	CHIP_ID_YUKON_EC_U = 0xb4, /* Chip ID for YUKON-2 EC Ultra */
-	CHIP_ID_YUKON_EX   = 0xb5, /* Chip ID for YUKON-2 Extreme */
-	CHIP_ID_YUKON_EC   = 0xb6, /* Chip ID for YUKON-2 EC */
- 	CHIP_ID_YUKON_FE   = 0xb7, /* Chip ID for YUKON-2 FE */
- 	CHIP_ID_YUKON_FE_P = 0xb8, /* Chip ID for YUKON-2 FE+ */
+	CHIP_ID_YUKON_XL   = 0xb3, /* YUKON-2 XL */
+	CHIP_ID_YUKON_EC_U = 0xb4, /* YUKON-2 EC Ultra */
+	CHIP_ID_YUKON_EX   = 0xb5, /* YUKON-2 Extreme */
+	CHIP_ID_YUKON_EC   = 0xb6, /* YUKON-2 EC */
+ 	CHIP_ID_YUKON_FE   = 0xb7, /* YUKON-2 FE */
+ 	CHIP_ID_YUKON_FE_P = 0xb8, /* YUKON-2 FE+ */
+	CHIP_ID_YUKON_SUPR = 0xb9, /* YUKON-2 Supreme */
 };
 enum yukon_ec_rev {
 	CHIP_REV_YU_EC_A1    = 0,  /* Chip Rev. for Yukon-EC A1/A0 */

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>

