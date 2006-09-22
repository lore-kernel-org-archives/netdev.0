From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: sky2 hangs, hw csum errors with 2.6.18
Date: Fri, 22 Sep 2006 11:50:08 -0700
Message-ID: <20060922115008.5060c599@localhost.localdomain>
References: <20060922112442.GB4161@dezo.moloch.sk>
	<20060922095642.5acf4ac9@dxpl.pdx.osdl.net>
	<20060922182924.GE4161@dezo.moloch.sk>
	<20060922113152.02874cbc@localhost.localdomain>
	<20060922183812.GF4161@dezo.moloch.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:56991 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932073AbWIVSuX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2006 14:50:23 -0400
To: Martin Lucina <mato@kotelna.sk>
In-Reply-To: <20060922183812.GF4161@dezo.moloch.sk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 22 Sep 2006 20:38:13 +0200
Martin Lucina <mato@kotelna.sk> wrote:

> shemminger@osdl.org said:
> > To get tx flow control to turn off. You need a patch (already in netdev-2.6 upstream)
> > and then you can do:
> > 
> > 	ethtool -A eth1 autoneg off tx off
> 
> Sorry, you've lost me.  Which patch?  You're saying that turning off tx
> flow control will fix the hangs I'm seeing?
> 
> -mato

Subject: sky2: handle forced settings

Handle cases where pause parameters are forced correctly.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- sky2.orig/drivers/net/sky2.c	2006-09-06 09:45:45.000000000 -0700
+++ sky2/drivers/net/sky2.c	2006-09-06 10:20:50.000000000 -0700
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
@@ -390,21 +391,46 @@
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
+		} else if (sky2->speed != SPEED_1000 && hw->chip_id != CHIP_ID_YUKON_EC_U) {
+			/* Turn off flow control for 10/100mbps */
+			sky2->rx_pause = 0;
+			sky2->tx_pause = 0;
+		}
+
+		if (!sky2->rx_pause)
+			reg |= GM_GPCR_FC_RX_DIS;
+
+		if (!sky2->tx_pause)
+			reg |= GM_GPCR_FC_TX_DIS;
+
+		/* Forward pause packets to GMAC? */
+		if (sky2->tx_pause || sky2->rx_pause)
+			sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_PAUSE_ON);
+		else
+			sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_PAUSE_OFF);
+
 		ctrl |= PHY_CT_RESET;
 	}
 
+	gma_write16(hw, port, GM_GP_CTRL, reg);
+
 	if (hw->chip_id != CHIP_ID_YUKON_FE)
 		gm_phy_write(hw, port, PHY_MARV_1000T_CTRL, ct1000);
 
@@ -508,6 +534,7 @@
 			gm_phy_write(hw, port, PHY_MARV_LED_OVER, ledover);
 
 	}
+
 	/* Enable phy interrupt on auto-negotiation complete (or link up) */
 	if (sky2->autoneg == AUTONEG_ENABLE)
 		gm_phy_write(hw, port, PHY_MARV_INT_MASK, PHY_M_IS_AN_COMPL);
@@ -570,49 +597,11 @@
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
@@ -1529,40 +1518,10 @@
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
 
@@ -1616,7 +1575,6 @@
 	reg = gma_read16(hw, port, GM_GP_CTRL);
 	reg &= ~(GM_GPCR_RX_ENA | GM_GPCR_TX_ENA);
 	gma_write16(hw, port, GM_GP_CTRL, reg);
-	gma_read16(hw, port, GM_GP_CTRL);	/* PCI post */
 
 	if (sky2->rx_pause && !sky2->tx_pause) {
 		/* restore Asymmetric Pause bit */
@@ -1633,6 +1591,7 @@
 
 	if (netif_msg_link(sky2))
 		printk(KERN_INFO PFX "%s: Link is down.\n", sky2->netdev->name);
+
 	sky2_phy_init(hw, port);
 }
 
@@ -1673,8 +1632,11 @@
 	sky2->rx_pause = (aux & PHY_M_PS_RX_P_EN) != 0;
 	sky2->tx_pause = (aux & PHY_M_PS_TX_P_EN) != 0;
 
-	if ((sky2->tx_pause || sky2->rx_pause)
-	    && !(sky2->speed < SPEED_1000 && sky2->duplex == DUPLEX_HALF))
+	if (sky2->duplex == DUPLEX_HALF && sky2->speed != SPEED_1000
+	    && hw->chip_id != CHIP_ID_YUKON_EC_U)
+		sky2->rx_pause = sky2->tx_pause = 0;
+
+	if (sky2->rx_pause || sky2->tx_pause)
 		sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_PAUSE_ON);
 	else
 		sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_PAUSE_OFF);
@@ -1700,7 +1662,7 @@
 		printk(KERN_INFO PFX "%s: phy interrupt status 0x%x 0x%x\n",
 		       sky2->netdev->name, istatus, phystat);
 
-	if (istatus & PHY_M_IS_AN_COMPL) {
+	if (sky2->autoneg == AUTONEG_ENABLE && (istatus & PHY_M_IS_AN_COMPL)) {
 		if (sky2_autoneg_done(sky2, phystat) == 0)
 			sky2_link_up(sky2);
 		goto out;
@@ -2890,7 +2852,6 @@
 			       struct ethtool_pauseparam *ecmd)
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
-	int err = 0;
 
 	sky2->autoneg = ecmd->autoneg;
 	sky2->tx_pause = ecmd->tx_pause != 0;
@@ -2898,7 +2859,7 @@
 
 	sky2_phy_reinit(sky2);
 
-	return err;
+	return 0;
 }
 
 static int sky2_get_coalesce(struct net_device *dev,

 


-- 
Stephen Hemminger <shemminger@osdl.org>
