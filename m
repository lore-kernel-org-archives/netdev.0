From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH][net-next v2] gianfar: Add flow control support
Date: Mon, 12 Aug 2013 13:53:26 +0300
Message-ID: <1376304806-8504-1-git-send-email-claudiu.manoil@freescale.com>
References: <1376068786-29868-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Lutz Jaenicke <ljaenicke@innominate.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe004.messaging.microsoft.com ([216.32.181.184]:51276
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755524Ab3HLKyZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Aug 2013 06:54:25 -0400
In-Reply-To: <1376068786-29868-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

eTSEC has Rx and Tx flow control capabilities that may be enabled
through MACCFG1[Rx_Flow, Tx_Flow] bits.  These bits must not be set
however when eTSEC is operated in Half-Duplex mode.  Unfortunately,
the driver currently sets these bits unconditionally.
This patch adds the proper handling of the PAUSE frame capability
register bits by implementing the ethtool -A interface.  When pause
autoneg is enabled, the controller uses the phy's capability to
negotiate PAUSE frame settings with the link partner and reconfigures
its Rx_Flow and Tx_Flow settings to match the capabilities of the
link partner.  If pause autoneg is off, the PAUSE frame generation
may be forced manually (ethtool -A).  Flow control is disabled by
default now.
This implementation is inspired by the tg3 driver.

Signed-off-by: Lutz Jaenicke <ljaenicke@innominate.com>
Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
v1 - Cleaned-up version of:
http://patchwork.ozlabs.org/patch/265940/
v2 - move code to gfar_get_flowctrl_cfg()
   - remove unused 'err'


 drivers/net/ethernet/freescale/gianfar.c         | 51 +++++++++++++++-
 drivers/net/ethernet/freescale/gianfar.h         | 10 +++-
 drivers/net/ethernet/freescale/gianfar_ethtool.c | 74 ++++++++++++++++++++++++
 3 files changed, 132 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index edf06f1..808b6a2 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -1016,7 +1016,14 @@ static int gfar_probe(struct platform_device *ofdev)
 	/* We need to delay at least 3 TX clocks */
 	udelay(2);
 
-	tempval = (MACCFG1_TX_FLOW | MACCFG1_RX_FLOW);
+	tempval = 0;
+	if (!priv->pause_aneg_en && priv->tx_pause_en)
+		tempval |= MACCFG1_TX_FLOW;
+	if (!priv->pause_aneg_en && priv->rx_pause_en)
+		tempval |= MACCFG1_RX_FLOW;
+	/* the soft reset bit is not self-resetting, so we need to
+	 * clear it before resuming normal operation
+	 */
 	gfar_write(&regs->maccfg1, tempval);
 
 	/* Initialize MACCFG2. */
@@ -1462,7 +1469,7 @@ static int init_phy(struct net_device *dev)
 	struct gfar_private *priv = netdev_priv(dev);
 	uint gigabit_support =
 		priv->device_flags & FSL_GIANFAR_DEV_HAS_GIGABIT ?
-		SUPPORTED_1000baseT_Full : 0;
+		GFAR_SUPPORTED_GBIT : 0;
 	phy_interface_t interface;
 
 	priv->oldlink = 0;
@@ -3025,6 +3032,41 @@ static irqreturn_t gfar_interrupt(int irq, void *grp_id)
 	return IRQ_HANDLED;
 }
 
+static u32 gfar_get_flowctrl_cfg(struct gfar_private *priv)
+{
+	struct phy_device *phydev = priv->phydev;
+	u32 val = 0;
+
+	if (!phydev->duplex)
+		return val;
+
+	if (!priv->pause_aneg_en) {
+		if (priv->tx_pause_en)
+			val |= MACCFG1_TX_FLOW;
+		if (priv->rx_pause_en)
+			val |= MACCFG1_RX_FLOW;
+	} else {
+		u16 lcl_adv, rmt_adv;
+		u8 flowctrl;
+		/* get link partner capabilities */
+		rmt_adv = 0;
+		if (phydev->pause)
+			rmt_adv = LPA_PAUSE_CAP;
+		if (phydev->asym_pause)
+			rmt_adv |= LPA_PAUSE_ASYM;
+
+		lcl_adv = mii_advertise_flowctrl(phydev->advertising);
+
+		flowctrl = mii_resolve_flowctrl_fdx(lcl_adv, rmt_adv);
+		if (flowctrl & FLOW_CTRL_TX)
+			val |= MACCFG1_TX_FLOW;
+		if (flowctrl & FLOW_CTRL_RX)
+			val |= MACCFG1_RX_FLOW;
+	}
+
+	return val;
+}
+
 /* Called every time the controller might need to be made
  * aware of new link state.  The PHY code conveys this
  * information through variables in the phydev structure, and this
@@ -3043,6 +3085,7 @@ static void adjust_link(struct net_device *dev)
 	lock_tx_qs(priv);
 
 	if (phydev->link) {
+		u32 tempval1 = gfar_read(&regs->maccfg1);
 		u32 tempval = gfar_read(&regs->maccfg2);
 		u32 ecntrl = gfar_read(&regs->ecntrl);
 
@@ -3091,6 +3134,10 @@ static void adjust_link(struct net_device *dev)
 			priv->oldspeed = phydev->speed;
 		}
 
+		tempval1 &= ~(MACCFG1_TX_FLOW | MACCFG1_RX_FLOW);
+		tempval1 |= gfar_get_flowctrl_cfg(priv);
+
+		gfar_write(&regs->maccfg1, tempval1);
 		gfar_write(&regs->maccfg2, tempval);
 		gfar_write(&regs->ecntrl, ecntrl);
 
diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index ee19f2c..46f56f3 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -146,6 +146,10 @@ extern const char gfar_driver_version[];
 		| SUPPORTED_Autoneg \
 		| SUPPORTED_MII)
 
+#define GFAR_SUPPORTED_GBIT (SUPPORTED_1000baseT_Full \
+		| SUPPORTED_Pause \
+		| SUPPORTED_Asym_Pause)
+
 /* TBI register addresses */
 #define MII_TBICON		0x11
 
@@ -1100,7 +1104,11 @@ struct gfar_private {
 		/* Wake-on-LAN enabled */
 		wol_en:1,
 		/* Enable priorty based Tx scheduling in Hw */
-		prio_sched_en:1;
+		prio_sched_en:1,
+		/* Flow control flags */
+		pause_aneg_en:1,
+		tx_pause_en:1,
+		rx_pause_en:1;
 
 	/* The total tx and rx ring size for the enabled queues */
 	unsigned int total_tx_ring_size;
diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
index 21cd881..d3d7ede 100644
--- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
+++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
@@ -535,6 +535,78 @@ static int gfar_sringparam(struct net_device *dev,
 	return err;
 }
 
+static void gfar_gpauseparam(struct net_device *dev,
+			     struct ethtool_pauseparam *epause)
+{
+	struct gfar_private *priv = netdev_priv(dev);
+
+	epause->autoneg = !!priv->pause_aneg_en;
+	epause->rx_pause = !!priv->rx_pause_en;
+	epause->tx_pause = !!priv->tx_pause_en;
+}
+
+static int gfar_spauseparam(struct net_device *dev,
+			    struct ethtool_pauseparam *epause)
+{
+	struct gfar_private *priv = netdev_priv(dev);
+	struct phy_device *phydev = priv->phydev;
+	struct gfar __iomem *regs = priv->gfargrp[0].regs;
+	u32 oldadv, newadv;
+
+	if (!(phydev->supported & SUPPORTED_Pause) ||
+	    (!(phydev->supported & SUPPORTED_Asym_Pause) &&
+	     (epause->rx_pause != epause->tx_pause)))
+		return -EINVAL;
+
+	priv->rx_pause_en = priv->tx_pause_en = 0;
+	if (epause->rx_pause) {
+		priv->rx_pause_en = 1;
+
+		if (epause->tx_pause) {
+			priv->tx_pause_en = 1;
+			/* FLOW_CTRL_RX & TX */
+			newadv = ADVERTISED_Pause;
+		} else  /* FLOW_CTLR_RX */
+			newadv = ADVERTISED_Pause | ADVERTISED_Asym_Pause;
+	} else if (epause->tx_pause) {
+		priv->tx_pause_en = 1;
+		/* FLOW_CTLR_TX */
+		newadv = ADVERTISED_Asym_Pause;
+	} else
+		newadv = 0;
+
+	if (epause->autoneg)
+		priv->pause_aneg_en = 1;
+	else
+		priv->pause_aneg_en = 0;
+
+	oldadv = phydev->advertising &
+		(ADVERTISED_Pause | ADVERTISED_Asym_Pause);
+	if (oldadv != newadv) {
+		phydev->advertising &=
+			~(ADVERTISED_Pause | ADVERTISED_Asym_Pause);
+		phydev->advertising |= newadv;
+		if (phydev->autoneg)
+			/* inform link partner of our
+			 * new flow ctrl settings
+			 */
+			return phy_start_aneg(phydev);
+
+		if (!epause->autoneg) {
+			u32 tempval;
+			tempval = gfar_read(&regs->maccfg1);
+			tempval &= ~(MACCFG1_TX_FLOW | MACCFG1_RX_FLOW);
+			if (priv->tx_pause_en)
+				tempval |= MACCFG1_TX_FLOW;
+			if (priv->rx_pause_en)
+				tempval |= MACCFG1_RX_FLOW;
+			gfar_write(&regs->maccfg1, tempval);
+		}
+	}
+
+	return 0;
+}
+
 int gfar_set_features(struct net_device *dev, netdev_features_t features)
 {
 	struct gfar_private *priv = netdev_priv(dev);
@@ -1806,6 +1878,8 @@ const struct ethtool_ops gfar_ethtool_ops = {
 	.set_coalesce = gfar_scoalesce,
 	.get_ringparam = gfar_gringparam,
 	.set_ringparam = gfar_sringparam,
+	.get_pauseparam = gfar_gpauseparam,
+	.set_pauseparam = gfar_spauseparam,
 	.get_strings = gfar_gstrings,
 	.get_sset_count = gfar_sset_count,
 	.get_ethtool_stats = gfar_fill_stats,
-- 
1.7.11.7
