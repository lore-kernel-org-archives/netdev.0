From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 08/10] sky2: flow control setting fixes
Date: Wed, 11 Oct 2006 14:22:33 -0700
Message-ID: <20061011212311.365293806@osdl.org>
References: <20061011212225.941046083@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:20175 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1161504AbWJKV36 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2006 17:29:58 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-fc-auto.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The result of flow control negotiation should not limit the next
negotiatition. If board is plugged into an old half duplex 10Mbit port,
without pause, then replugged into a gigabit port, it should negotiate
what is desired, not inherit that last negotiation.

P.s: many other drivers have this bug.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 drivers/net/sky2.c |  132 ++++++++++++++++++++++++++++++-----------------------
 drivers/net/sky2.h |   13 ++++-
 2 files changed, 86 insertions(+), 59 deletions(-)

--- sky2.orig/drivers/net/sky2.c	2006-10-11 12:00:37.000000000 -0700
+++ sky2/drivers/net/sky2.c	2006-10-11 12:05:46.000000000 -0700
@@ -284,6 +284,31 @@
 	gma_write16(hw, port, GM_RX_CTRL, reg);
 }
 
+/* flow control to advertise bits */
+static const u16 copper_fc_adv[] = {
+	[FC_NONE]	= 0,
+	[FC_TX]		= PHY_M_AN_ASP,
+	[FC_RX]		= PHY_M_AN_PC,
+	[FC_BOTH]	= PHY_M_AN_PC | PHY_M_AN_ASP,
+};
+
+/* flow control to advertise bits when using 1000BaseX */
+static const u16 fiber_fc_adv[] = {
+	[FC_BOTH] = PHY_M_P_BOTH_MD_X,
+	[FC_TX]   = PHY_M_P_ASYM_MD_X,
+	[FC_RX]	  = PHY_M_P_SYM_MD_X,
+	[FC_NONE] = PHY_M_P_NO_PAUSE_X,
+};
+
+/* flow control to GMA disable bits */
+static const u16 gm_fc_disable[] = {
+	[FC_NONE] = GM_GPCR_FC_RX_DIS | GM_GPCR_FC_TX_DIS,
+	[FC_TX]	  = GM_GPCR_FC_RX_DIS,
+	[FC_RX]	  = GM_GPCR_FC_TX_DIS,
+	[FC_BOTH] = 0,
+};
+
+
 static void sky2_phy_init(struct sky2_hw *hw, unsigned port)
 {
 	struct sky2_port *sky2 = netdev_priv(hw->dev[port]);
@@ -376,29 +401,14 @@
 			if (sky2->advertising & ADVERTISED_10baseT_Half)
 				adv |= PHY_M_AN_10_HD;
 
-			/* desired flow control */
-			if (sky2->tx_pause && sky2->rx_pause)	/* both */
-				adv |= PHY_M_AN_PC | PHY_M_AN_ASP;
-			else if (sky2->tx_pause)
-				adv |= PHY_M_AN_ASP;
-			else if (sky2->rx_pause)
-				adv |= PHY_M_AN_PC;
-
-
+			adv |= copper_fc_adv[sky2->flow_mode];
 		} else {	/* special defines for FIBER (88E1040S only) */
 			if (sky2->advertising & ADVERTISED_1000baseT_Full)
 				adv |= PHY_M_AN_1000X_AFD;
 			if (sky2->advertising & ADVERTISED_1000baseT_Half)
 				adv |= PHY_M_AN_1000X_AHD;
 
-			if (sky2->tx_pause && sky2->rx_pause)	/* both */
- 				adv |= PHY_M_P_BOTH_MD_X;
-			else if (sky2->tx_pause)
-				adv |= PHY_M_P_ASYM_MD_X;
-			else if (sky2->rx_pause)
- 				adv |= PHY_M_P_SYM_MD_X;
-			else
-				adv |= PHY_M_P_NO_PAUSE_X;
+			adv |= fiber_fc_adv[sky2->flow_mode];
 		}
 
 		/* Restart Auto-negotiation */
@@ -424,20 +434,14 @@
 		if (sky2->duplex == DUPLEX_FULL) {
 			reg |= GM_GPCR_DUP_FULL;
 			ctrl |= PHY_CT_DUP_MD;
-		} else if (sky2->speed != SPEED_1000 && hw->chip_id != CHIP_ID_YUKON_EC_U) {
-			/* Turn off flow control for 10/100mbps */
-			sky2->rx_pause = 0;
-			sky2->tx_pause = 0;
-		}
+		} else if (sky2->speed < SPEED_1000)
+			sky2->flow_mode = FC_NONE;
 
-		if (!sky2->rx_pause)
-			reg |= GM_GPCR_FC_RX_DIS;
 
-		if (!sky2->tx_pause)
-			reg |= GM_GPCR_FC_TX_DIS;
+ 		reg |= gm_fc_disable[sky2->flow_mode];
 
 		/* Forward pause packets to GMAC? */
-		if (sky2->tx_pause || sky2->rx_pause)
+		if (sky2->flow_mode & FC_RX)
 			sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_PAUSE_ON);
 		else
 			sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_PAUSE_OFF);
@@ -1605,6 +1609,12 @@
 	struct sky2_hw *hw = sky2->hw;
 	unsigned port = sky2->port;
 	u16 reg;
+	static const char *fc_name[] = {
+		[FC_NONE]	= "none",
+		[FC_TX]		= "tx",
+		[FC_RX]		= "rx",
+		[FC_BOTH]	= "both",
+	};
 
 	/* enable Rx/Tx */
 	reg = gma_read16(hw, port, GM_GP_CTRL);
@@ -1648,8 +1658,7 @@
 		       "%s: Link is up at %d Mbps, %s duplex, flow control %s\n",
 		       sky2->netdev->name, sky2->speed,
 		       sky2->duplex == DUPLEX_FULL ? "full" : "half",
-		       (sky2->tx_pause && sky2->rx_pause) ? "both" :
-		       sky2->tx_pause ? "tx" : sky2->rx_pause ? "rx" : "none");
+		       fc_name[sky2->flow_status]);
 }
 
 static void sky2_link_down(struct sky2_port *sky2)
@@ -1664,7 +1673,7 @@
 	reg &= ~(GM_GPCR_RX_ENA | GM_GPCR_TX_ENA);
 	gma_write16(hw, port, GM_GP_CTRL, reg);
 
-	if (sky2->rx_pause && !sky2->tx_pause) {
+	if (sky2->flow_status == FC_RX) {
 		/* restore Asymmetric Pause bit */
 		gm_phy_write(hw, port, PHY_MARV_AUNE_ADV,
 			     gm_phy_read(hw, port, PHY_MARV_AUNE_ADV)
@@ -1683,6 +1692,14 @@
 	sky2_phy_init(hw, port);
 }
 
+static enum flow_control sky2_flow(int rx, int tx)
+{
+	if (rx)
+		return tx ? FC_BOTH : FC_RX;
+	else
+		return tx ? FC_TX : FC_NONE;
+}
+
 static int sky2_autoneg_done(struct sky2_port *sky2, u16 aux)
 {
 	struct sky2_hw *hw = sky2->hw;
@@ -1709,14 +1726,14 @@
 	if (hw->chip_id == CHIP_ID_YUKON_XL || hw->chip_id == CHIP_ID_YUKON_EC_U)
 		aux >>= 6;
 
-	sky2->rx_pause = (aux & PHY_M_PS_RX_P_EN) != 0;
-	sky2->tx_pause = (aux & PHY_M_PS_TX_P_EN) != 0;
+	sky2->flow_status = sky2_flow(aux & PHY_M_PS_RX_P_EN,
+				      aux & PHY_M_PS_TX_P_EN);
 
-	if (sky2->duplex == DUPLEX_HALF && sky2->speed != SPEED_1000
+	if (sky2->duplex == DUPLEX_HALF && sky2->speed < SPEED_1000
 	    && hw->chip_id != CHIP_ID_YUKON_EC_U)
-		sky2->rx_pause = sky2->tx_pause = 0;
+		sky2->flow_status = FC_NONE;
 
-	if (sky2->rx_pause || sky2->tx_pause)
+	if (aux & PHY_M_PS_RX_P_EN)
 		sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_PAUSE_ON);
 	else
 		sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_PAUSE_OFF);
@@ -2729,7 +2746,7 @@
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
 
-	if (sky2->autoneg != AUTONEG_ENABLE)
+	if (!netif_running(dev) || sky2->autoneg != AUTONEG_ENABLE)
 		return -EINVAL;
 
 	sky2_phy_reinit(sky2);
@@ -2971,8 +2988,20 @@
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
 
-	ecmd->tx_pause = sky2->tx_pause;
-	ecmd->rx_pause = sky2->rx_pause;
+	switch (sky2->flow_mode) {
+	case FC_NONE:
+		ecmd->tx_pause = ecmd->rx_pause = 0;
+		break;
+	case FC_TX:
+		ecmd->tx_pause = 1, ecmd->rx_pause = 0;
+		break;
+	case FC_RX:
+		ecmd->tx_pause = 0, ecmd->rx_pause = 1;
+		break;
+	case FC_BOTH:
+		ecmd->tx_pause = ecmd->rx_pause = 1;
+	}
+
 	ecmd->autoneg = sky2->autoneg;
 }
 
@@ -2982,10 +3011,10 @@
 	struct sky2_port *sky2 = netdev_priv(dev);
 
 	sky2->autoneg = ecmd->autoneg;
-	sky2->tx_pause = ecmd->tx_pause != 0;
-	sky2->rx_pause = ecmd->rx_pause != 0;
+	sky2->flow_mode = sky2_flow(ecmd->rx_pause, ecmd->tx_pause);
 
-	sky2_phy_reinit(sky2);
+	if (netif_running(dev))
+		sky2_phy_reinit(sky2);
 
 	return 0;
 }
@@ -3215,8 +3244,8 @@
 
 	/* Auto speed and flow control */
 	sky2->autoneg = AUTONEG_ENABLE;
-	sky2->tx_pause = 1;
-	sky2->rx_pause = 1;
+	sky2->flow_mode = FC_BOTH;
+
 	sky2->duplex = -1;
 	sky2->speed = -1;
 	sky2->advertising = sky2_supported_modes(hw);
--- sky2.orig/drivers/net/sky2.h	2006-10-11 11:59:32.000000000 -0700
+++ sky2/drivers/net/sky2.h	2006-10-11 12:01:20.000000000 -0700
@@ -1828,6 +1828,13 @@
 	dma_addr_t	frag_addr[ETH_JUMBO_MTU >> PAGE_SHIFT];
 };
 
+enum flow_control {
+	FC_NONE	= 0,
+	FC_TX	= 1,
+	FC_RX	= 2,
+	FC_BOTH	= 3,
+};
+
 struct sky2_port {
 	struct sky2_hw	     *hw;
 	struct net_device    *netdev;
@@ -1864,9 +1871,9 @@
 	u16		     speed;	/* SPEED_1000, SPEED_100, ... */
 	u8		     autoneg;	/* AUTONEG_ENABLE, AUTONEG_DISABLE */
 	u8		     duplex;	/* DUPLEX_HALF, DUPLEX_FULL */
-	u8		     rx_pause;
-	u8		     tx_pause;
 	u8		     rx_csum;
+ 	enum flow_control    flow_mode;
+ 	enum flow_control    flow_status;
 
 	struct net_device_stats net_stats;
 

--
Stephen Hemminger <shemminger@osdl.org>

