From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 4/5] sky2: 88E8057 chip support
Date: Tue, 17 Jun 2008 09:04:27 -0700
Message-ID: <20080617160503.599384948@vyatta.com>
References: <20080617160423.205070938@vyatta.com>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([69.59.150.140]:45988 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752093AbYFQQIp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 12:08:45 -0400
Content-Disposition: inline; filename=sky2-ul2-chip.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for Yukon 2 Ultra 2 chip set (88E8057) based on code in latest
version of vendor driver (sk98lin 10.60.2.3).  Untested on real hardware.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/sky2.c	2008-06-17 09:03:55.000000000 -0700
+++ b/drivers/net/sky2.c	2008-06-17 09:03:56.000000000 -0700
@@ -136,6 +136,7 @@ static DEFINE_PCI_DEVICE_TABLE(sky2_id_t
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x436C) }, /* 88E8072 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x436D) }, /* 88E8055 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4370) }, /* 88E8075 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4380) }, /* 88E8057 */
 	{ 0 }
 };
 
@@ -647,7 +648,7 @@ static void sky2_phy_init(struct sky2_hw
 		ledover |= PHY_M_LED_MO_RX(MO_LED_OFF);
 	}
 
-	if (hw->chip_id == CHIP_ID_YUKON_EC_U) {
+	if (hw->chip_id == CHIP_ID_YUKON_EC_U || hw->chip_id == CHIP_ID_YUKON_UL_2) {
 		/* apply fixes in PHY AFE */
 		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 255);
 
@@ -655,9 +656,11 @@ static void sky2_phy_init(struct sky2_hw
 		gm_phy_write(hw, port, 0x18, 0xaa99);
 		gm_phy_write(hw, port, 0x17, 0x2011);
 
-		/* fix for IEEE A/B Symmetry failure in 1000BASE-T */
-		gm_phy_write(hw, port, 0x18, 0xa204);
-		gm_phy_write(hw, port, 0x17, 0x2002);
+		if (hw->chip_id == CHIP_ID_YUKON_EC_U) {
+			/* fix for IEEE A/B Symmetry failure in 1000BASE-T */
+			gm_phy_write(hw, port, 0x18, 0xa204);
+			gm_phy_write(hw, port, 0x17, 0x2002);
+		}
 
 		/* set page register to 0 */
 		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 0);
@@ -2807,6 +2810,7 @@ static u32 sky2_mhz(const struct sky2_hw
 	case CHIP_ID_YUKON_EC_U:
 	case CHIP_ID_YUKON_EX:
 	case CHIP_ID_YUKON_SUPR:
+	case CHIP_ID_YUKON_UL_2:
 		return 125;
 
 	case CHIP_ID_YUKON_FE:
@@ -2899,6 +2903,11 @@ static int __devinit sky2_init(struct sk
 			| SKY2_HW_ADV_POWER_CTL;
 		break;
 
+	case CHIP_ID_YUKON_UL_2:
+		hw->flags = SKY2_HW_GIGABIT
+			| SKY2_HW_ADV_POWER_CTL;
+		break;
+
 	default:
 		dev_err(&hw->pdev->dev, "unsupported chip type 0x%x\n",
 			hw->chip_id);
@@ -4265,9 +4274,10 @@ static const char *sky2_name(u8 chipid, 
 		"FE",		/* 0xb7 */
 		"FE+",		/* 0xb8 */
 		"Supreme",	/* 0xb9 */
+		"UL 2",		/* 0xba */
 	};
 
-	if (chipid >= CHIP_ID_YUKON_XL && chipid < CHIP_ID_YUKON_SUPR)
+	if (chipid >= CHIP_ID_YUKON_XL && chipid < CHIP_ID_YUKON_UL_2)
 		strncpy(buf, name[chipid - CHIP_ID_YUKON_XL], sz);
 	else
 		snprintf(buf, sz, "(chip %#x)", chipid);
--- a/drivers/net/sky2.h	2008-06-17 08:32:26.000000000 -0700
+++ b/drivers/net/sky2.h	2008-06-17 09:03:56.000000000 -0700
@@ -441,6 +441,7 @@ enum {
  	CHIP_ID_YUKON_FE   = 0xb7, /* YUKON-2 FE */
  	CHIP_ID_YUKON_FE_P = 0xb8, /* YUKON-2 FE+ */
 	CHIP_ID_YUKON_SUPR = 0xb9, /* YUKON-2 Supreme */
+	CHIP_ID_YUKON_UL_2 = 0xba, /* YUKON-2 Ultra 2 */
 };
 enum yukon_ec_rev {
 	CHIP_REV_YU_EC_A1    = 0,  /* Chip Rev. for Yukon-EC A1/A0 */

-- 

