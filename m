From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 8/9] sky2: fix pause negotiation
Date: Fri, 14 Aug 2009 08:15:19 -0700
Message-ID: <20090814151608.525338064@vyatta.com>
References: <20090814151511.992669598@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:44119 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932520AbZHNPTv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Aug 2009 11:19:51 -0400
Content-Disposition: inline; filename=sky2-pause.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sky2 driver combines auto speed negotiation with automatic negotiation
of pause parameters; but the ethtool interface expects them to be
split. This patch allows autonegotiation to be used for speed, but
manually disable flow control.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/sky2.c	2009-08-14 07:58:49.410251274 -0700
+++ b/drivers/net/sky2.c	2009-08-14 07:58:50.471356910 -0700
@@ -321,7 +321,7 @@ static void sky2_phy_init(struct sky2_hw
 	struct sky2_port *sky2 = netdev_priv(hw->dev[port]);
 	u16 ctrl, ct1000, adv, pg, ledctrl, ledover, reg;
 
-	if (sky2->autoneg == AUTONEG_ENABLE &&
+	if ( (sky2->flags & SKY2_FLAG_AUTO_SPEED) &&
 	    !(hw->flags & SKY2_HW_NEWER_PHY)) {
 		u16 ectrl = gm_phy_read(hw, port, PHY_MARV_EXT_CTRL);
 
@@ -363,7 +363,7 @@ static void sky2_phy_init(struct sky2_hw
 			ctrl |= PHY_M_PC_MDI_XMODE(PHY_M_PC_ENA_AUTO);
 
 			/* downshift on PHY 88E1112 and 88E1149 is changed */
-			if (sky2->autoneg == AUTONEG_ENABLE
+			if ( (sky2->flags & SKY2_FLAG_AUTO_SPEED)
 			    && (hw->flags & SKY2_HW_NEWER_PHY)) {
 				/* set downshift counter to 3x and enable downshift */
 				ctrl &= ~PHY_M_PC_DSC_MSK;
@@ -408,7 +408,7 @@ static void sky2_phy_init(struct sky2_hw
 	adv = PHY_AN_CSMA;
 	reg = 0;
 
-	if (sky2->autoneg == AUTONEG_ENABLE) {
+	if (sky2->flags & SKY2_FLAG_AUTO_SPEED) {
 		if (sky2_is_copper(hw)) {
 			if (sky2->advertising & ADVERTISED_1000baseT_Full)
 				ct1000 |= PHY_M_1000C_AFD;
@@ -423,14 +423,11 @@ static void sky2_phy_init(struct sky2_hw
 			if (sky2->advertising & ADVERTISED_10baseT_Half)
 				adv |= PHY_M_AN_10_HD;
 
-			adv |= copper_fc_adv[sky2->flow_mode];
 		} else {	/* special defines for FIBER (88E1040S only) */
 			if (sky2->advertising & ADVERTISED_1000baseT_Full)
 				adv |= PHY_M_AN_1000X_AFD;
 			if (sky2->advertising & ADVERTISED_1000baseT_Half)
 				adv |= PHY_M_AN_1000X_AHD;
-
-			adv |= fiber_fc_adv[sky2->flow_mode];
 		}
 
 		/* Restart Auto-negotiation */
@@ -439,8 +436,8 @@ static void sky2_phy_init(struct sky2_hw
 		/* forced speed/duplex settings */
 		ct1000 = PHY_M_1000C_MSE;
 
-		/* Disable auto update for duplex flow control and speed */
-		reg |= GM_GPCR_AU_ALL_DIS;
+		/* Disable auto update for duplex flow control and duplex */
+		reg |= GM_GPCR_AU_DUP_DIS | GM_GPCR_AU_SPD_DIS;
 
 		switch (sky2->speed) {
 		case SPEED_1000:
@@ -458,8 +455,15 @@ static void sky2_phy_init(struct sky2_hw
 			ctrl |= PHY_CT_DUP_MD;
 		} else if (sky2->speed < SPEED_1000)
 			sky2->flow_mode = FC_NONE;
+	}
 
-
+	if (sky2->flags & SKY2_FLAG_AUTO_PAUSE) {
+		if (sky2_is_copper(hw))
+			adv |= copper_fc_adv[sky2->flow_mode];
+		else
+			adv |= fiber_fc_adv[sky2->flow_mode];
+	} else {
+		reg |= GM_GPCR_AU_FCT_DIS;
  		reg |= gm_fc_disable[sky2->flow_mode];
 
 		/* Forward pause packets to GMAC? */
@@ -594,7 +598,8 @@ static void sky2_phy_init(struct sky2_hw
 		/* no effect on Yukon-XL */
 		gm_phy_write(hw, port, PHY_MARV_LED_CTRL, ledctrl);
 
-		if (sky2->autoneg == AUTONEG_DISABLE || sky2->speed == SPEED_100) {
+		if ( !(sky2->flags & SKY2_FLAG_AUTO_SPEED)
+		     || sky2->speed == SPEED_100) {
 			/* turn on 100 Mbps LED (LED_LINK100) */
 			ledover |= PHY_M_LED_MO_100(MO_LED_ON);
 		}
@@ -605,7 +610,7 @@ static void sky2_phy_init(struct sky2_hw
 	}
 
 	/* Enable phy interrupt on auto-negotiation complete (or link up) */
-	if (sky2->autoneg == AUTONEG_ENABLE)
+	if (sky2->flags & SKY2_FLAG_AUTO_SPEED)
 		gm_phy_write(hw, port, PHY_MARV_INT_MASK, PHY_M_IS_AN_COMPL);
 	else
 		gm_phy_write(hw, port, PHY_MARV_INT_MASK, PHY_M_DEF_MSK);
@@ -661,7 +666,9 @@ static void sky2_phy_power_down(struct s
 
 	/* setup General Purpose Control Register */
 	gma_write16(hw, port, GM_GP_CTRL,
-		    GM_GPCR_FL_PASS | GM_GPCR_SPEED_100 | GM_GPCR_AU_ALL_DIS);
+		    GM_GPCR_FL_PASS | GM_GPCR_SPEED_100 |
+		    GM_GPCR_AU_DUP_DIS | GM_GPCR_AU_FCT_DIS |
+		    GM_GPCR_AU_SPD_DIS);
 
 	if (hw->chip_id != CHIP_ID_YUKON_EC) {
 		if (hw->chip_id == CHIP_ID_YUKON_EC_U) {
@@ -1117,7 +1124,8 @@ static void rx_set_checksum(struct sky2_
 
 	sky2_write32(sky2->hw,
 		     Q_ADDR(rxqaddr[sky2->port], Q_CSR),
-		     sky2->rx_csum ? BMU_ENA_RX_CHKSUM : BMU_DIS_RX_CHKSUM);
+		     (sky2->flags & SKY2_FLAG_RX_CHECKSUM)
+		     ? BMU_ENA_RX_CHKSUM : BMU_DIS_RX_CHKSUM);
 }
 
 /*
@@ -2076,7 +2084,7 @@ static void sky2_phy_intr(struct sky2_hw
 		printk(KERN_INFO PFX "%s: phy interrupt status 0x%x 0x%x\n",
 		       sky2->netdev->name, istatus, phystat);
 
-	if (sky2->autoneg == AUTONEG_ENABLE && (istatus & PHY_M_IS_AN_COMPL)) {
+	if (istatus & PHY_M_IS_AN_COMPL) {
 		if (sky2_autoneg_done(sky2, phystat) == 0)
 			sky2_link_up(sky2);
 		goto out;
@@ -2442,7 +2450,7 @@ static int sky2_status_intr(struct sky2_
 
 			/* This chip reports checksum status differently */
 			if (hw->flags & SKY2_HW_NEW_LE) {
-				if (sky2->rx_csum &&
+				if ((sky2->flags & SKY2_FLAG_RX_CHECKSUM) &&
 				    (le->css & (CSS_ISIPV4 | CSS_ISIPV6)) &&
 				    (le->css & CSS_TCPUDPCSOK))
 					skb->ip_summed = CHECKSUM_UNNECESSARY;
@@ -2469,7 +2477,7 @@ static int sky2_status_intr(struct sky2_
 			/* fall through */
 #endif
 		case OP_RXCHKS:
-			if (!sky2->rx_csum)
+			if (!(sky2->flags & SKY2_FLAG_RX_CHECKSUM))
 				break;
 
 			/* If this happens then driver assuming wrong format */
@@ -2494,7 +2502,8 @@ static int sky2_status_intr(struct sky2_
 				printk(KERN_NOTICE PFX "%s: hardware receive "
 				       "checksum problem (status = %#x)\n",
 				       dev->name, status);
-				sky2->rx_csum = 0;
+				sky2->flags &= ~SKY2_FLAG_RX_CHECKSUM;
+
 				sky2_write32(sky2->hw,
 					     Q_ADDR(rxqaddr[port], Q_CSR),
 					     BMU_DIS_RX_CHKSUM);
@@ -3195,7 +3204,8 @@ static int sky2_get_settings(struct net_
 	}
 
 	ecmd->advertising = sky2->advertising;
-	ecmd->autoneg = sky2->autoneg;
+	ecmd->autoneg = (sky2->flags & SKY2_FLAG_AUTO_SPEED)
+		? AUTONEG_ENABLE : AUTONEG_DISABLE;
 	ecmd->duplex = sky2->duplex;
 	return 0;
 }
@@ -3207,6 +3217,7 @@ static int sky2_set_settings(struct net_
 	u32 supported = sky2_supported_modes(hw);
 
 	if (ecmd->autoneg == AUTONEG_ENABLE) {
+		sky2->flags |= SKY2_FLAG_AUTO_SPEED;
 		ecmd->advertising = supported;
 		sky2->duplex = -1;
 		sky2->speed = -1;
@@ -3248,9 +3259,9 @@ static int sky2_set_settings(struct net_
 
 		sky2->speed = ecmd->speed;
 		sky2->duplex = ecmd->duplex;
+		sky2->flags &= ~SKY2_FLAG_AUTO_SPEED;
 	}
 
-	sky2->autoneg = ecmd->autoneg;
 	sky2->advertising = ecmd->advertising;
 
 	if (netif_running(dev)) {
@@ -3320,14 +3331,17 @@ static u32 sky2_get_rx_csum(struct net_d
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
 
-	return sky2->rx_csum;
+	return !!(sky2->flags & SKY2_FLAG_RX_CHECKSUM);
 }
 
 static int sky2_set_rx_csum(struct net_device *dev, u32 data)
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
 
-	sky2->rx_csum = data;
+	if (data)
+		sky2->flags |= SKY2_FLAG_RX_CHECKSUM;
+	else
+		sky2->flags &= ~SKY2_FLAG_RX_CHECKSUM;
 
 	sky2_write32(sky2->hw, Q_ADDR(rxqaddr[sky2->port], Q_CSR),
 		     data ? BMU_ENA_RX_CHKSUM : BMU_DIS_RX_CHKSUM);
@@ -3345,7 +3359,7 @@ static int sky2_nway_reset(struct net_de
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
 
-	if (!netif_running(dev) || sky2->autoneg != AUTONEG_ENABLE)
+	if (!netif_running(dev) || !(sky2->flags & SKY2_FLAG_AUTO_SPEED))
 		return -EINVAL;
 
 	sky2_phy_reinit(sky2);
@@ -3585,7 +3599,8 @@ static void sky2_get_pauseparam(struct n
 		ecmd->tx_pause = ecmd->rx_pause = 1;
 	}
 
-	ecmd->autoneg = sky2->autoneg;
+	ecmd->autoneg = (sky2->flags & SKY2_FLAG_AUTO_PAUSE)
+		? AUTONEG_ENABLE : AUTONEG_DISABLE;
 }
 
 static int sky2_set_pauseparam(struct net_device *dev,
@@ -3593,7 +3608,11 @@ static int sky2_set_pauseparam(struct ne
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
 
-	sky2->autoneg = ecmd->autoneg;
+	if (ecmd->autoneg == AUTONEG_ENABLE)
+		sky2->flags |= SKY2_FLAG_AUTO_PAUSE;
+	else
+		sky2->flags &= ~SKY2_FLAG_AUTO_PAUSE;
+
 	sky2->flow_mode = sky2_flow(ecmd->rx_pause, ecmd->tx_pause);
 
 	if (netif_running(dev))
@@ -4283,13 +4302,15 @@ static __devinit struct net_device *sky2
 	sky2->msg_enable = netif_msg_init(debug, default_msg);
 
 	/* Auto speed and flow control */
-	sky2->autoneg = AUTONEG_ENABLE;
+	sky2->flags = SKY2_FLAG_AUTO_SPEED | SKY2_FLAG_AUTO_PAUSE;
+	if (hw->chip_id != CHIP_ID_YUKON_XL)
+		sky2->flags |= SKY2_FLAG_RX_CHECKSUM;
+
 	sky2->flow_mode = FC_BOTH;
 
 	sky2->duplex = -1;
 	sky2->speed = -1;
 	sky2->advertising = sky2_supported_modes(hw);
-	sky2->rx_csum = (hw->chip_id != CHIP_ID_YUKON_XL);
 	sky2->wol = wol;
 
 	spin_lock_init(&sky2->phy_lock);
--- a/drivers/net/sky2.h	2009-08-14 07:58:07.357063846 -0700
+++ b/drivers/net/sky2.h	2009-08-14 07:58:50.472100125 -0700
@@ -1583,7 +1583,6 @@ enum {
 };
 
 #define GM_GPCR_SPEED_1000	(GM_GPCR_GIGS_ENA | GM_GPCR_SPEED_100)
-#define GM_GPCR_AU_ALL_DIS	(GM_GPCR_AU_DUP_DIS | GM_GPCR_AU_FCT_DIS|GM_GPCR_AU_SPD_DIS)
 
 /*	GM_TX_CTRL			16 bit r/w	Transmit Control Register */
 enum {
@@ -2042,15 +2041,18 @@ struct sky2_port {
 		u8	fifo_lev;
 	} check;
 
-
 	dma_addr_t	     rx_le_map;
 	dma_addr_t	     tx_le_map;
+
 	u16		     advertising;	/* ADVERTISED_ bits */
-	u16		     speed;	/* SPEED_1000, SPEED_100, ... */
-	u8		     autoneg;	/* AUTONEG_ENABLE, AUTONEG_DISABLE */
-	u8		     duplex;	/* DUPLEX_HALF, DUPLEX_FULL */
-	u8		     rx_csum;
-	u8		     wol;
+	u16		     speed;		/* SPEED_1000, SPEED_100, ... */
+	u8		     wol;		/* WAKE_ bits */
+	u8		     duplex;		/* DUPLEX_HALF, DUPLEX_FULL */
+	u16		     flags;
+#define SKY2_FLAG_RX_CHECKSUM		0x0001
+#define SKY2_FLAG_AUTO_SPEED		0x0002
+#define SKY2_FLAG_AUTO_PAUSE		0x0004
+
  	enum flow_control    flow_mode;
  	enum flow_control    flow_status;
 

-- 

