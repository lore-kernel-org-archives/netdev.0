From: shemminger@osdl.org
Subject: [RFT 3/5] sky2: handle forced settings
Date: Tue, 05 Sep 2006 15:27:37 -0700
Message-ID: <20060905223001.332416537@localhost.localdomain>
References: <20060905222734.082143263@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:3736 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1422662AbWIEWeQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2006 18:34:16 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-forced-pause.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Handle cases where pause parameters are forced. Need to program
the GMAC before starting the PHY, not after.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- sky2.orig/drivers/net/sky2.c	2006-09-05 12:10:18.000000000 -0700
+++ sky2/drivers/net/sky2.c	2006-09-05 13:32:59.000000000 -0700
@@ -289,7 +289,7 @@
 static void sky2_phy_init(struct sky2_hw *hw, unsigned port)
 {
 	struct sky2_port *sky2 = netdev_priv(hw->dev[port]);
-	u16 ctrl, ct1000, adv, pg, ledctrl, ledover;
+	u16 ctrl, ct1000, adv, pg, ledctrl, ledover, reg;
 
 	if (sky2->autoneg == AUTONEG_ENABLE &&
 	    !(hw->chip_id == CHIP_ID_YUKON_XL || hw->chip_id == CHIP_ID_YUKON_EC_U)) {
@@ -358,6 +358,7 @@
 	ctrl = 0;
 	ct1000 = 0;
 	adv = PHY_AN_CSMA;
+	reg = 0;
 
 	if (sky2->autoneg == AUTONEG_ENABLE) {
 		if (hw->copper) {
@@ -390,21 +391,44 @@
 		/* forced speed/duplex settings */
 		ct1000 = PHY_M_1000C_MSE;
 
-		if (sky2->duplex == DUPLEX_FULL)
-			ctrl |= PHY_CT_DUP_MD;
+		/* Disable auto update for duplex flow control and speed */
+		reg |= GM_GPCR_AU_ALL_DIS;
 
 		switch (sky2->speed) {
 		case SPEED_1000:
 			ctrl |= PHY_CT_SP1000;
+			reg |= GM_GPCR_SPEED_1000;
 			break;
 		case SPEED_100:
 			ctrl |= PHY_CT_SP100;
+			reg |= GM_GPCR_SPEED_100;
 			break;
 		}
 
+		if (sky2->duplex == DUPLEX_FULL) {
+			reg |= GM_GPCR_DUP_FULL;
+			ctrl |= PHY_CT_DUP_MD;
+		}
+
+		if (!sky2->rx_pause)
+			reg |= GM_GPCR_FC_RX_DIS;
+
+		if (!sky2->tx_pause)
+			reg |= GM_GPCR_FC_TX_DIS;
+
+		/* Forward pause packets to GMAC? */
+		if (!sky2->tx_pause ||
+		    (hw->chip_id != CHIP_ID_YUKON_EC_U &&
+		     sky2->duplex == DUPLEX_HALF && sky2->speed != SPEED_1000))
+			sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_PAUSE_OFF);
+		else
+			sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_PAUSE_ON);
+
 		ctrl |= PHY_CT_RESET;
 	}
 
+	gma_write16(hw, port, GM_GP_CTRL, reg);
+
 	if (hw->chip_id != CHIP_ID_YUKON_FE)
 		gm_phy_write(hw, port, PHY_MARV_1000T_CTRL, ct1000);
 
@@ -508,6 +532,7 @@
 			gm_phy_write(hw, port, PHY_MARV_LED_OVER, ledover);
 
 	}
+
 	/* Enable phy interrupt on auto-negotiation complete (or link up) */
 	if (sky2->autoneg == AUTONEG_ENABLE)
 		gm_phy_write(hw, port, PHY_MARV_INT_MASK, PHY_M_IS_AN_COMPL);
@@ -570,49 +595,11 @@
 			 gm_phy_read(hw, 1, PHY_MARV_INT_MASK) != 0);
 	}
 
-	if (sky2->autoneg == AUTONEG_DISABLE) {
-		reg = gma_read16(hw, port, GM_GP_CTRL);
-		reg |= GM_GPCR_AU_ALL_DIS;
-		gma_write16(hw, port, GM_GP_CTRL, reg);
-		gma_read16(hw, port, GM_GP_CTRL);
-
-		switch (sky2->speed) {
-		case SPEED_1000:
-			reg &= ~GM_GPCR_SPEED_100;
-			reg |= GM_GPCR_SPEED_1000;
-			break;
-		case SPEED_100:
-			reg &= ~GM_GPCR_SPEED_1000;
-			reg |= GM_GPCR_SPEED_100;
-			break;
-		case SPEED_10:
-			reg &= ~(GM_GPCR_SPEED_1000 | GM_GPCR_SPEED_100);
-			break;
-		}
-
-		if (sky2->duplex == DUPLEX_FULL)
-			reg |= GM_GPCR_DUP_FULL;
-
-		/* turn off pause in 10/100mbps half duplex */
-		else if (sky2->speed != SPEED_1000 &&
-			 hw->chip_id != CHIP_ID_YUKON_EC_U)
-			sky2->tx_pause = sky2->rx_pause = 0;
-	} else
-		reg = GM_GPCR_SPEED_1000 | GM_GPCR_SPEED_100 | GM_GPCR_DUP_FULL;
-
-	if (!sky2->tx_pause && !sky2->rx_pause) {
-		sky2_write32(hw, SK_REG(port, GMAC_CTRL), GMC_PAUSE_OFF);
-		reg |=
-		    GM_GPCR_FC_TX_DIS | GM_GPCR_FC_RX_DIS | GM_GPCR_AU_FCT_DIS;
-	} else if (sky2->tx_pause && !sky2->rx_pause) {
-		/* disable Rx flow-control */
-		reg |= GM_GPCR_FC_RX_DIS | GM_GPCR_AU_FCT_DIS;
-	}
-
-	gma_write16(hw, port, GM_GP_CTRL, reg);
-
 	sky2_read16(hw, SK_REG(port, GMAC_IRQ_SRC));
 
+	/* Enable Transmit FIFO Underrun */
+	sky2_write8(hw, SK_REG(port, GMAC_IRQ_MSK), GMAC_DEF_MSK);
+
 	spin_lock_bh(&sky2->phy_lock);
 	sky2_phy_init(hw, port);
 	spin_unlock_bh(&sky2->phy_lock);
@@ -1529,40 +1516,10 @@
 	unsigned port = sky2->port;
 	u16 reg;
 
-	/* Enable Transmit FIFO Underrun */
-	sky2_write8(hw, SK_REG(port, GMAC_IRQ_MSK), GMAC_DEF_MSK);
-
-	reg = gma_read16(hw, port, GM_GP_CTRL);
-	if (sky2->autoneg == AUTONEG_DISABLE) {
-		reg |= GM_GPCR_AU_ALL_DIS;
-
-		/* Is write/read necessary?  Copied from sky2_mac_init */
-		gma_write16(hw, port, GM_GP_CTRL, reg);
-		gma_read16(hw, port, GM_GP_CTRL);
-
-		switch (sky2->speed) {
-		case SPEED_1000:
-			reg &= ~GM_GPCR_SPEED_100;
-			reg |= GM_GPCR_SPEED_1000;
-			break;
-		case SPEED_100:
-			reg &= ~GM_GPCR_SPEED_1000;
-			reg |= GM_GPCR_SPEED_100;
-			break;
-		case SPEED_10:
-			reg &= ~(GM_GPCR_SPEED_1000 | GM_GPCR_SPEED_100);
-			break;
-		}
-	} else
-		reg &= ~GM_GPCR_AU_ALL_DIS;
-
-	if (sky2->duplex == DUPLEX_FULL || sky2->autoneg == AUTONEG_ENABLE)
-		reg |= GM_GPCR_DUP_FULL;
-
 	/* enable Rx/Tx */
+	reg = gma_read16(hw, port, GM_GP_CTRL);
 	reg |= GM_GPCR_RX_ENA | GM_GPCR_TX_ENA;
 	gma_write16(hw, port, GM_GP_CTRL, reg);
-	gma_read16(hw, port, GM_GP_CTRL);
 
 	gm_phy_write(hw, port, PHY_MARV_INT_MASK, PHY_M_DEF_MSK);
 
@@ -1616,7 +1573,6 @@
 	reg = gma_read16(hw, port, GM_GP_CTRL);
 	reg &= ~(GM_GPCR_RX_ENA | GM_GPCR_TX_ENA);
 	gma_write16(hw, port, GM_GP_CTRL, reg);
-	gma_read16(hw, port, GM_GP_CTRL);	/* PCI post */
 
 	if (sky2->rx_pause && !sky2->tx_pause) {
 		/* restore Asymmetric Pause bit */
@@ -1633,6 +1589,7 @@
 
 	if (netif_msg_link(sky2))
 		printk(KERN_INFO PFX "%s: Link is down.\n", sky2->netdev->name);
+
 	sky2_phy_init(hw, port);
 }
 
@@ -1673,11 +1630,13 @@
 	sky2->rx_pause = (aux & PHY_M_PS_RX_P_EN) != 0;
 	sky2->tx_pause = (aux & PHY_M_PS_TX_P_EN) != 0;
 
-	if ((sky2->tx_pause || sky2->rx_pause)
-	    && !(sky2->speed < SPEED_1000 && sky2->duplex == DUPLEX_HALF))
-		sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_PAUSE_ON);
-	else
+	if (!sky2->tx_pause ||
+	    /* disable Pause also for 10/100 Mbps in half duplex mode */
+	    ((hw->chip_id != CHIP_ID_YUKON_EC_U &&
+	      sky2->speed < SPEED_1000 && sky2->duplex == DUPLEX_HALF)))
 		sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_PAUSE_OFF);
+	else
+		sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_PAUSE_ON);
 
 	return 0;
 }
@@ -1700,7 +1659,7 @@
 		printk(KERN_INFO PFX "%s: phy interrupt status 0x%x 0x%x\n",
 		       sky2->netdev->name, istatus, phystat);
 
-	if (istatus & PHY_M_IS_AN_COMPL) {
+	if (sky2->autoneg == AUTONEG_ENABLE && (istatus & PHY_M_IS_AN_COMPL)) {
 		if (sky2_autoneg_done(sky2, phystat) == 0)
 			sky2_link_up(sky2);
 		goto out;
@@ -2890,7 +2849,6 @@
 			       struct ethtool_pauseparam *ecmd)
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
-	int err = 0;
 
 	sky2->autoneg = ecmd->autoneg;
 	sky2->tx_pause = ecmd->tx_pause != 0;
@@ -2898,7 +2856,7 @@
 
 	sky2_phy_reinit(sky2);
 
-	return err;
+	return 0;
 }
 
 static int sky2_get_coalesce(struct net_device *dev,

--
Stephen Hemminger <shemminger@osdl.org>

