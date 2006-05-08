From: Stephen Hemminger <shemminger@osdl.org>
Subject: [patch 8/9] Add more support for the Yukon Ultra chip found in dual core centino laptops.
Date: Mon, 08 May 2006 15:11:33 -0700
Message-ID: <20060508221229.616771000@localhost.localdomain>
References: <20060508221125.177816000@localhost.localdomain>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:13501 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751326AbWEHWXy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 May 2006 18:23:54 -0400
Received: from shell0.pdx.osdl.net (fw.osdl.org [65.172.181.6])
	by smtp.osdl.org (8.12.8/8.12.8) with ESMTP id k48MNntH003759
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 8 May 2006 15:23:49 -0700
Received: from shell0.pdx.osdl.net (localhost [127.0.0.1])
	by shell0.pdx.osdl.net (8.13.1/8.11.6) with ESMTP id k48MNm9p023570
	for <netdev@vger.kernel.org>; Mon, 8 May 2006 15:23:48 -0700
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=sky2-ultra-phy.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The newest Yukon Ultra chipset's require more special tweaks.
They seem to be like the Yukon XL chipsets. This code is transliterated
from the latest SysKonnect driver; I don't have any Ultra hardware.

Signed-off-by: Stephe Hemminger <shemminger@osdl.org>


--- sky2.orig/drivers/net/sky2.c
+++ sky2/drivers/net/sky2.c
@@ -304,7 +304,8 @@ static void sky2_phy_init(struct sky2_hw
 	struct sky2_port *sky2 = netdev_priv(hw->dev[port]);
 	u16 ctrl, ct1000, adv, pg, ledctrl, ledover;
 
-	if (sky2->autoneg == AUTONEG_ENABLE && hw->chip_id != CHIP_ID_YUKON_XL) {
+	if (sky2->autoneg == AUTONEG_ENABLE &&
+	    (hw->chip_id != CHIP_ID_YUKON_XL || hw->chip_id == CHIP_ID_YUKON_EC_U)) {
 		u16 ectrl = gm_phy_read(hw, port, PHY_MARV_EXT_CTRL);
 
 		ectrl &= ~(PHY_M_EC_M_DSC_MSK | PHY_M_EC_S_DSC_MSK |
@@ -332,7 +333,7 @@ static void sky2_phy_init(struct sky2_hw
 			ctrl |= PHY_M_PC_MDI_XMODE(PHY_M_PC_ENA_AUTO);
 
 			if (sky2->autoneg == AUTONEG_ENABLE &&
-			    hw->chip_id == CHIP_ID_YUKON_XL) {
+			    (hw->chip_id == CHIP_ID_YUKON_XL || hw->chip_id == CHIP_ID_YUKON_EC_U)) {
 				ctrl &= ~PHY_M_PC_DSC_MSK;
 				ctrl |= PHY_M_PC_DSC(2) | PHY_M_PC_DOWN_S_ENA;
 			}
@@ -448,10 +449,11 @@ static void sky2_phy_init(struct sky2_hw
 		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 3);
 
 		/* set LED Function Control register */
-		gm_phy_write(hw, port, PHY_MARV_PHY_CTRL, (PHY_M_LEDC_LOS_CTRL(1) |	/* LINK/ACT */
-							   PHY_M_LEDC_INIT_CTRL(7) |	/* 10 Mbps */
-							   PHY_M_LEDC_STA1_CTRL(7) |	/* 100 Mbps */
-							   PHY_M_LEDC_STA0_CTRL(7)));	/* 1000 Mbps */
+		gm_phy_write(hw, port, PHY_MARV_PHY_CTRL,
+			     (PHY_M_LEDC_LOS_CTRL(1) |	/* LINK/ACT */
+			      PHY_M_LEDC_INIT_CTRL(7) |	/* 10 Mbps */
+			      PHY_M_LEDC_STA1_CTRL(7) |	/* 100 Mbps */
+			      PHY_M_LEDC_STA0_CTRL(7)));	/* 1000 Mbps */
 
 		/* set Polarity Control register */
 		gm_phy_write(hw, port, PHY_MARV_PHY_STAT,
@@ -465,6 +467,25 @@ static void sky2_phy_init(struct sky2_hw
 		/* restore page register */
 		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, pg);
 		break;
+	case CHIP_ID_YUKON_EC_U:
+		pg = gm_phy_read(hw, port, PHY_MARV_EXT_ADR);
+
+		/* select page 3 to access LED control register */
+		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 3);
+
+		/* set LED Function Control register */
+		gm_phy_write(hw, port, PHY_MARV_PHY_CTRL,
+			     (PHY_M_LEDC_LOS_CTRL(1) |	/* LINK/ACT */
+			      PHY_M_LEDC_INIT_CTRL(8) |	/* 10 Mbps */
+			      PHY_M_LEDC_STA1_CTRL(7) |	/* 100 Mbps */
+			      PHY_M_LEDC_STA0_CTRL(7)));/* 1000 Mbps */
+
+		/* set Blink Rate in LED Timer Control Register */
+		gm_phy_write(hw, port, PHY_MARV_INT_MASK,
+			     ledctrl | PHY_M_LED_BLINK_RT(BLINK_84MS));
+		/* restore page register */
+		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, pg);
+		break;
 
 	default:
 		/* set Tx LED (LED_TX) to blink mode on Rx OR Tx activity */
@@ -473,19 +494,21 @@ static void sky2_phy_init(struct sky2_hw
 		ledover |= PHY_M_LED_MO_RX(MO_LED_OFF);
 	}
 
-	if (hw->chip_id == CHIP_ID_YUKON_EC_U && hw->chip_rev >= 2) {
+	if (hw->chip_id == CHIP_ID_YUKON_EC_U && hw->chip_rev == CHIP_REV_YU_EC_A1) {
 		/* apply fixes in PHY AFE */
-		gm_phy_write(hw, port, 22, 255);
+		pg = gm_phy_read(hw, port, PHY_MARV_EXT_ADR);
+		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 255);
+
 		/* increase differential signal amplitude in 10BASE-T */
-		gm_phy_write(hw, port, 24, 0xaa99);
-		gm_phy_write(hw, port, 23, 0x2011);
+		gm_phy_write(hw, port, 0x18, 0xaa99);
+		gm_phy_write(hw, port, 0x17, 0x2011);
 
 		/* fix for IEEE A/B Symmetry failure in 1000BASE-T */
-		gm_phy_write(hw, port, 24, 0xa204);
-		gm_phy_write(hw, port, 23, 0x2002);
+		gm_phy_write(hw, port, 0x18, 0xa204);
+		gm_phy_write(hw, port, 0x17, 0x2002);
 
 		/* set page register to 0 */
-		gm_phy_write(hw, port, 22, 0);
+		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, pg);
 	} else {
 		gm_phy_write(hw, port, PHY_MARV_LED_CTRL, ledctrl);
 
@@ -559,6 +582,11 @@ static void sky2_mac_init(struct sky2_hw
 
 		if (sky2->duplex == DUPLEX_FULL)
 			reg |= GM_GPCR_DUP_FULL;
+
+		/* turn off pause in 10/100mbps half duplex */
+		else if (sky2->speed != SPEED_1000 &&
+			 hw->chip_id != CHIP_ID_YUKON_EC_U)
+			sky2->tx_pause = sky2->rx_pause = 0;
 	} else
 		reg = GM_GPCR_SPEED_1000 | GM_GPCR_SPEED_100 | GM_GPCR_DUP_FULL;
 
@@ -1504,17 +1532,26 @@ static void sky2_link_up(struct sky2_por
 	sky2_write8(hw, SK_REG(port, LNK_LED_REG),
 		    LINKLED_ON | LINKLED_BLINK_OFF | LINKLED_LINKSYNC_OFF);
 
-	if (hw->chip_id == CHIP_ID_YUKON_XL) {
+	if (hw->chip_id == CHIP_ID_YUKON_XL || hw->chip_id == CHIP_ID_YUKON_EC_U) {
 		u16 pg = gm_phy_read(hw, port, PHY_MARV_EXT_ADR);
+		u16 led = PHY_M_LEDC_LOS_CTRL(1);	/* link active */
+
+		switch(sky2->speed) {
+		case SPEED_10:
+			led |= PHY_M_LEDC_INIT_CTRL(7);
+			break;
+
+		case SPEED_100:
+			led |= PHY_M_LEDC_STA1_CTRL(7);
+			break;
+
+		case SPEED_1000:
+			led |= PHY_M_LEDC_STA0_CTRL(7);
+			break;
+		}
 
 		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 3);
-		gm_phy_write(hw, port, PHY_MARV_PHY_CTRL, PHY_M_LEDC_LOS_CTRL(1) |	/* LINK/ACT */
-			     PHY_M_LEDC_INIT_CTRL(sky2->speed ==
-						  SPEED_10 ? 7 : 0) |
-			     PHY_M_LEDC_STA1_CTRL(sky2->speed ==
-						  SPEED_100 ? 7 : 0) |
-			     PHY_M_LEDC_STA0_CTRL(sky2->speed ==
-						  SPEED_1000 ? 7 : 0));
+		gm_phy_write(hw, port, PHY_MARV_PHY_CTRL, led);
 		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, pg);
 	}
 
@@ -1589,7 +1626,7 @@ static int sky2_autoneg_done(struct sky2
 	sky2->speed = sky2_phy_speed(hw, aux);
 
 	/* Pause bits are offset (9..8) */
-	if (hw->chip_id == CHIP_ID_YUKON_XL)
+	if (hw->chip_id == CHIP_ID_YUKON_XL || hw->chip_id == CHIP_ID_YUKON_EC_U)
 		aux >>= 6;
 
 	sky2->rx_pause = (aux & PHY_M_PS_RX_P_EN) != 0;
@@ -2226,13 +2263,6 @@ static int __devinit sky2_reset(struct s
 		return -EOPNOTSUPP;
 	}
 
-	/* This chip is new and not tested yet */
-	if (hw->chip_id == CHIP_ID_YUKON_EC_U) {
-		pr_info(PFX "%s: is a version of Yukon 2 chipset that has not been tested yet.\n",
-			pci_name(hw->pdev));
-		pr_info("Please report success/failure to maintainer <shemminger@osdl.org>\n");
-	}
-
 	/* disable ASF */
 	if (hw->chip_id <= CHIP_ID_YUKON_EC) {
 		sky2_write8(hw, B28_Y2_ASF_STAT_CMD, Y2_ASF_RESET);
--- sky2.orig/drivers/net/sky2.h
+++ sky2/drivers/net/sky2.h
@@ -378,6 +378,9 @@ enum {
 	CHIP_REV_YU_EC_A1    = 0,  /* Chip Rev. for Yukon-EC A1/A0 */
 	CHIP_REV_YU_EC_A2    = 1,  /* Chip Rev. for Yukon-EC A2 */
 	CHIP_REV_YU_EC_A3    = 2,  /* Chip Rev. for Yukon-EC A3 */
+
+	CHIP_REV_YU_EC_U_A0  = 0,
+	CHIP_REV_YU_EC_U_A1  = 1,
 };
 
 /*	B2_Y2_CLK_GATE	 8 bit	Clock Gating (Yukon-2 only) */

--

