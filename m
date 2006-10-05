From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 3/4] skge: better flow control negotiation
Date: Thu, 05 Oct 2006 15:49:52 -0700
Message-ID: <20061005225209.596941597@osdl.org>
References: <20061005224949.456192755@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:19408 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932440AbWJEX4U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2006 19:56:20 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=skge-default-both.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Do flow control negotiation properly. Don't let auto negotiation
status limit renegotiation. Separate desired pause values from
the result of auto negotiation.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 drivers/net/skge.c |  129 ++++++++++++++++++++++++++++++++---------------------
 drivers/net/skge.h |   22 ++++++---
 2 files changed, 95 insertions(+), 56 deletions(-)

--- linux-2.6.orig/drivers/net/skge.c
+++ linux-2.6/drivers/net/skge.c
@@ -487,31 +487,37 @@ static void skge_get_pauseparam(struct n
 {
 	struct skge_port *skge = netdev_priv(dev);
 
-	ecmd->tx_pause = (skge->flow_control == FLOW_MODE_LOC_SEND)
-		|| (skge->flow_control == FLOW_MODE_SYMMETRIC);
-	ecmd->rx_pause = (skge->flow_control == FLOW_MODE_REM_SEND)
-		|| (skge->flow_control == FLOW_MODE_SYMMETRIC);
+	ecmd->rx_pause = (skge->flow_control == FLOW_MODE_SYMMETRIC)
+		|| (skge->flow_control == FLOW_MODE_SYM_OR_REM);
+	ecmd->tx_pause = ecmd->rx_pause || (skge->flow_control == FLOW_MODE_LOC_SEND);
 
-	ecmd->autoneg = skge->autoneg;
+	ecmd->autoneg = ecmd->rx_pause || ecmd->tx_pause;
 }
 
 static int skge_set_pauseparam(struct net_device *dev,
 			       struct ethtool_pauseparam *ecmd)
 {
 	struct skge_port *skge = netdev_priv(dev);
+	struct ethtool_pauseparam old;
 
-	skge->autoneg = ecmd->autoneg;
-	if (ecmd->rx_pause && ecmd->tx_pause)
-		skge->flow_control = FLOW_MODE_SYMMETRIC;
-	else if (ecmd->rx_pause && !ecmd->tx_pause)
-		skge->flow_control = FLOW_MODE_REM_SEND;
-	else if (!ecmd->rx_pause && ecmd->tx_pause)
-		skge->flow_control = FLOW_MODE_LOC_SEND;
-	else
-		skge->flow_control = FLOW_MODE_NONE;
+	skge_get_pauseparam(dev, &old);
+
+	if (ecmd->autoneg != old.autoneg)
+		skge->flow_control = ecmd->autoneg ? FLOW_MODE_NONE : FLOW_MODE_SYMMETRIC;
+	else {
+		if (ecmd->rx_pause && ecmd->tx_pause)
+			skge->flow_control = FLOW_MODE_SYMMETRIC;
+		else if (ecmd->rx_pause && !ecmd->tx_pause)
+			skge->flow_control = FLOW_MODE_SYM_OR_REM;
+		else if (!ecmd->rx_pause && ecmd->tx_pause)
+			skge->flow_control = FLOW_MODE_LOC_SEND;
+		else
+			skge->flow_control = FLOW_MODE_NONE;
+	}
 
 	if (netif_running(dev))
 		skge_phy_reset(skge);
+
 	return 0;
 }
 
@@ -854,6 +860,23 @@ static int skge_rx_fill(struct net_devic
 	return 0;
 }
 
+static const char *skge_pause(enum pause_status status)
+{
+	switch(status) {
+	case FLOW_STAT_NONE:
+		return "none";
+	case FLOW_STAT_REM_SEND:
+		return "rx only";
+	case FLOW_STAT_LOC_SEND:
+		return "tx_only";
+	case FLOW_STAT_SYMMETRIC:		/* Both station may send PAUSE */
+		return "both";
+	default:
+		return "indeterminated";
+	}
+}
+
+
 static void skge_link_up(struct skge_port *skge)
 {
 	skge_write8(skge->hw, SK_REG(skge->port, LNK_LED_REG),
@@ -862,16 +885,13 @@ static void skge_link_up(struct skge_por
 	netif_carrier_on(skge->netdev);
 	netif_wake_queue(skge->netdev);
 
-	if (netif_msg_link(skge))
+	if (netif_msg_link(skge)) {
 		printk(KERN_INFO PFX
 		       "%s: Link is up at %d Mbps, %s duplex, flow control %s\n",
 		       skge->netdev->name, skge->speed,
 		       skge->duplex == DUPLEX_FULL ? "full" : "half",
-		       (skge->flow_control == FLOW_MODE_NONE) ? "none" :
-		       (skge->flow_control == FLOW_MODE_LOC_SEND) ? "tx only" :
-		       (skge->flow_control == FLOW_MODE_REM_SEND) ? "rx only" :
-		       (skge->flow_control == FLOW_MODE_SYMMETRIC) ? "tx and rx" :
-		       "unknown");
+		       skge_pause(skge->flow_status));
+	}
 }
 
 static void skge_link_down(struct skge_port *skge)
@@ -1015,7 +1035,7 @@ static const u16 phy_pause_map[] = {
 	[FLOW_MODE_NONE] =	0,
 	[FLOW_MODE_LOC_SEND] =	PHY_AN_PAUSE_ASYM,
 	[FLOW_MODE_SYMMETRIC] = PHY_AN_PAUSE_CAP,
-	[FLOW_MODE_REM_SEND]  = PHY_AN_PAUSE_CAP | PHY_AN_PAUSE_ASYM,
+	[FLOW_MODE_SYM_OR_REM]  = PHY_AN_PAUSE_CAP | PHY_AN_PAUSE_ASYM,
 };
 
 /* special defines for FIBER (88E1011S only) */
@@ -1023,7 +1043,7 @@ static const u16 fiber_pause_map[] = {
 	[FLOW_MODE_NONE]	= PHY_X_P_NO_PAUSE,
 	[FLOW_MODE_LOC_SEND]	= PHY_X_P_ASYM_MD,
 	[FLOW_MODE_SYMMETRIC]	= PHY_X_P_SYM_MD,
-	[FLOW_MODE_REM_SEND]	= PHY_X_P_BOTH_MD,
+	[FLOW_MODE_SYM_OR_REM]	= PHY_X_P_BOTH_MD,
 };
 
 
@@ -1072,20 +1092,19 @@ static void bcom_check_link(struct skge_
 			return;
 		}
 
-
 		/* We are using IEEE 802.3z/D5.0 Table 37-4 */
 		switch (aux & PHY_B_AS_PAUSE_MSK) {
 		case PHY_B_AS_PAUSE_MSK:
-			skge->flow_control = FLOW_MODE_SYMMETRIC;
+			skge->flow_status = FLOW_STAT_SYMMETRIC;
 			break;
 		case PHY_B_AS_PRR:
-			skge->flow_control = FLOW_MODE_REM_SEND;
+			skge->flow_status = FLOW_STAT_REM_SEND;
 			break;
 		case PHY_B_AS_PRT:
-			skge->flow_control = FLOW_MODE_LOC_SEND;
+			skge->flow_status = FLOW_STAT_LOC_SEND;
 			break;
 		default:
-			skge->flow_control = FLOW_MODE_NONE;
+			skge->flow_status = FLOW_STAT_NONE;
 		}
 		skge->speed = SPEED_1000;
 	}
@@ -1283,15 +1302,20 @@ static void xm_check_link(struct net_dev
 		}
 
 		/* We are using IEEE 802.3z/D5.0 Table 37-4 */
-		if (lpa & PHY_X_P_SYM_MD)
-			skge->flow_control = FLOW_MODE_SYMMETRIC;
-		else if ((lpa & PHY_X_RS_PAUSE) == PHY_X_P_ASYM_MD)
-			skge->flow_control = FLOW_MODE_REM_SEND;
-		else if ((lpa & PHY_X_RS_PAUSE) == PHY_X_P_BOTH_MD)
-			skge->flow_control = FLOW_MODE_LOC_SEND;
+		if ((skge->flow_control == FLOW_MODE_SYMMETRIC ||
+		     skge->flow_control == FLOW_MODE_SYM_OR_REM) &&
+		    (lpa & PHY_X_P_SYM_MD))
+			skge->flow_status = FLOW_STAT_SYMMETRIC;
+		else if (skge->flow_control == FLOW_MODE_SYM_OR_REM &&
+			 (lpa & PHY_X_RS_PAUSE) == PHY_X_P_ASYM_MD)
+			/* Enable PAUSE receive, disable PAUSE transmit */
+			skge->flow_status  = FLOW_STAT_REM_SEND;
+		else if (skge->flow_control == FLOW_MODE_LOC_SEND &&
+			 (lpa & PHY_X_RS_PAUSE) == PHY_X_P_BOTH_MD)
+			/* Disable PAUSE receive, enable PAUSE transmit */
+			skge->flow_status = FLOW_STAT_LOC_SEND;
 		else
-			skge->flow_control = FLOW_MODE_NONE;
-
+			skge->flow_status = FLOW_STAT_NONE;
 
 		skge->speed = SPEED_1000;
 	}
@@ -1602,8 +1626,8 @@ static void genesis_link_up(struct skge_
 	 * enabling pause frame reception is required for 1000BT
 	 * because the XMAC is not reset if the link is going down
 	 */
-	if (skge->flow_control == FLOW_MODE_NONE ||
-	    skge->flow_control == FLOW_MODE_LOC_SEND)
+	if (skge->flow_status == FLOW_STAT_NONE ||
+	    skge->flow_status == FLOW_STAT_LOC_SEND)
 		/* Disable Pause Frame Reception */
 		cmd |= XM_MMU_IGN_PF;
 	else
@@ -1613,8 +1637,8 @@ static void genesis_link_up(struct skge_
 	xm_write16(hw, port, XM_MMU_CMD, cmd);
 
 	mode = xm_read32(hw, port, XM_MODE);
-	if (skge->flow_control == FLOW_MODE_SYMMETRIC ||
-	    skge->flow_control == FLOW_MODE_LOC_SEND) {
+	if (skge->flow_status== FLOW_STAT_SYMMETRIC ||
+	    skge->flow_status == FLOW_STAT_LOC_SEND) {
 		/*
 		 * Configure Pause Frame Generation
 		 * Use internal and external Pause Frame Generation.
@@ -1938,6 +1962,11 @@ static void yukon_mac_init(struct skge_h
 	case FLOW_MODE_LOC_SEND:
 		/* disable Rx flow-control */
 		reg |= GM_GPCR_FC_RX_DIS | GM_GPCR_AU_FCT_DIS;
+		break;
+	case FLOW_MODE_SYMMETRIC:
+	case FLOW_MODE_SYM_OR_REM:
+		/* enable Tx & Rx flow-control */
+		break;
 	}
 
 	gma_write16(hw, port, GM_GP_CTRL, reg);
@@ -2132,13 +2161,11 @@ static void yukon_link_down(struct skge_
 	ctrl &= ~(GM_GPCR_RX_ENA | GM_GPCR_TX_ENA);
 	gma_write16(hw, port, GM_GP_CTRL, ctrl);
 
-	if (skge->flow_control == FLOW_MODE_REM_SEND) {
+	if (skge->flow_status == FLOW_STAT_REM_SEND) {
+		ctrl = gm_phy_read(hw, port, PHY_MARV_AUNE_ADV);
+		ctrl |= PHY_M_AN_ASP;
 		/* restore Asymmetric Pause bit */
-		gm_phy_write(hw, port, PHY_MARV_AUNE_ADV,
-				  gm_phy_read(hw, port,
-						   PHY_MARV_AUNE_ADV)
-				  | PHY_M_AN_ASP);
-
+		gm_phy_write(hw, port, PHY_MARV_AUNE_ADV, ctrl);
 	}
 
 	yukon_reset(hw, port);
@@ -2185,19 +2212,19 @@ static void yukon_phy_intr(struct skge_p
 		/* We are using IEEE 802.3z/D5.0 Table 37-4 */
 		switch (phystat & PHY_M_PS_PAUSE_MSK) {
 		case PHY_M_PS_PAUSE_MSK:
-			skge->flow_control = FLOW_MODE_SYMMETRIC;
+			skge->flow_status = FLOW_STAT_SYMMETRIC;
 			break;
 		case PHY_M_PS_RX_P_EN:
-			skge->flow_control = FLOW_MODE_REM_SEND;
+			skge->flow_status = FLOW_STAT_REM_SEND;
 			break;
 		case PHY_M_PS_TX_P_EN:
-			skge->flow_control = FLOW_MODE_LOC_SEND;
+			skge->flow_status = FLOW_STAT_LOC_SEND;
 			break;
 		default:
-			skge->flow_control = FLOW_MODE_NONE;
+			skge->flow_status = FLOW_STAT_NONE;
 		}
 
-		if (skge->flow_control == FLOW_MODE_NONE ||
+		if (skge->flow_status == FLOW_STAT_NONE ||
 		    (skge->speed < SPEED_1000 && skge->duplex == DUPLEX_HALF))
 			skge_write8(hw, SK_REG(port, GMAC_CTRL), GMC_PAUSE_OFF);
 		else
@@ -3420,7 +3447,7 @@ static struct net_device *skge_devinit(s
 
 	/* Auto speed and flow control */
 	skge->autoneg = AUTONEG_ENABLE;
-	skge->flow_control = FLOW_MODE_SYMMETRIC;
+	skge->flow_control = FLOW_MODE_SYM_OR_REM;
 	skge->duplex = -1;
 	skge->speed = -1;
 	skge->advertising = skge_supported_modes(hw);
--- linux-2.6.orig/drivers/net/skge.h
+++ linux-2.6/drivers/net/skge.h
@@ -2427,13 +2427,24 @@ struct skge_hw {
 	struct mutex	     phy_mutex;
 };
 
-enum {
-	FLOW_MODE_NONE 		= 0, /* No Flow-Control */
-	FLOW_MODE_LOC_SEND	= 1, /* Local station sends PAUSE */
-	FLOW_MODE_REM_SEND	= 2, /* Symmetric or just remote */
+enum pause_control {
+	FLOW_MODE_NONE 		= 1, /* No Flow-Control */
+	FLOW_MODE_LOC_SEND	= 2, /* Local station sends PAUSE */
 	FLOW_MODE_SYMMETRIC	= 3, /* Both stations may send PAUSE */
+	FLOW_MODE_SYM_OR_REM	= 4, /* Both stations may send PAUSE or
+				      * just the remote station may send PAUSE
+				      */
 };
 
+enum pause_status {
+	FLOW_STAT_INDETERMINATED=0,	/* indeterminated */
+	FLOW_STAT_NONE,			/* No Flow Control */
+	FLOW_STAT_REM_SEND,		/* Remote Station sends PAUSE */
+	FLOW_STAT_LOC_SEND,		/* Local station sends PAUSE */
+	FLOW_STAT_SYMMETRIC,		/* Both station may send PAUSE */
+};
+
+
 struct skge_port {
 	u32		     msg_enable;
 	struct skge_hw	     *hw;
@@ -2446,9 +2457,10 @@ struct skge_port {
 	struct net_device_stats net_stats;
 
 	struct work_struct   link_thread;
+	enum pause_control   flow_control;
+	enum pause_status    flow_status;
 	u8		     rx_csum;
 	u8		     blink_on;
-	u8		     flow_control;
 	u8		     wol;
 	u8		     autoneg;	/* AUTONEG_ENABLE, AUTONEG_DISABLE */
 	u8		     duplex;	/* DUPLEX_HALF, DUPLEX_FULL */

--
Stephen Hemminger <shemminger@osdl.org>

