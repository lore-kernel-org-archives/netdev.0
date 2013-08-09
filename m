From: Lutz Jaenicke <ljaenicke@innominate.com>
Subject: [PATCH] gianfar: implement flow control handling
Date: Fri,  9 Aug 2013 10:26:29 +0200
Message-ID: <1376036790-18238-2-git-send-email-ljaenicke@innominate.com>
References: <1375987549.2853.67.camel@deadeye.wl.decadent.org.uk>
 <1376036790-18238-1-git-send-email-ljaenicke@innominate.com>
Cc: Claudiu Manoil <claudiu.manoil@freescale.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>,
	Lutz Jaenicke <ljaenicke@innominate.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from home.innominate.com ([77.245.32.75]:51857 "EHLO
	home.innominate.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030559Ab3HII0k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 04:26:40 -0400
In-Reply-To: <1376036790-18238-1-git-send-email-ljaenicke@innominate.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This implementation is inspired by the tg3 driver!
---
 drivers/net/ethernet/freescale/gianfar.c         |   31 +++++++++-
 drivers/net/ethernet/freescale/gianfar.h         |    7 ++-
 drivers/net/ethernet/freescale/gianfar_ethtool.c |   71 ++++++++++++++++++++++
 3 files changed, 107 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 91bd6da..0da003c 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -1065,7 +1065,11 @@ static int gfar_probe(struct platform_device *ofdev)
 	/* We need to delay at least 3 TX clocks */
 	udelay(2);
 
-	tempval = (MACCFG1_TX_FLOW | MACCFG1_RX_FLOW);
+	tempval = 0;
+	if (!priv->pause_aneg_en && priv->tx_pause_en)
+		tempval |= MACCFG1_TX_FLOW;
+	if (!priv->pause_aneg_en && priv->rx_pause_en)
+		tempval |= MACCFG1_RX_FLOW;
 	gfar_write(&regs->maccfg1, tempval);
 
 	/* Initialize MACCFG2. */
@@ -3042,6 +3046,7 @@ static void adjust_link(struct net_device *dev)
 	lock_tx_qs(priv);
 
 	if (phydev->link) {
+		u32 tempval1 = gfar_read(&regs->maccfg1);
 		u32 tempval = gfar_read(&regs->maccfg2);
 		u32 ecntrl = gfar_read(&regs->ecntrl);
 
@@ -3088,6 +3093,30 @@ static void adjust_link(struct net_device *dev)
 			priv->oldspeed = phydev->speed;
 		}
 
+		tempval1 &= ~(MACCFG1_TX_FLOW | MACCFG1_RX_FLOW);
+		if (phydev->duplex) {
+			if (!priv->pause_aneg_en) {
+				if (priv->tx_pause_en)
+					tempval1 |= MACCFG1_TX_FLOW;
+				if (priv->rx_pause_en)
+					tempval1 |= MACCFG1_RX_FLOW;
+			} else {
+				u8 flowctrl;
+				u32 lcl_adv = mii_advertise_flowctrl(phydev->advertising);
+				u32 rmt_adv = 0;
+				if (phydev->pause)
+					rmt_adv = LPA_PAUSE_CAP;
+				if (phydev->asym_pause)
+					rmt_adv |= LPA_PAUSE_ASYM;
+				flowctrl = mii_resolve_flowctrl_fdx(lcl_adv, rmt_adv);
+				if (flowctrl & FLOW_CTRL_TX)
+					tempval1 |= MACCFG1_TX_FLOW;
+				if (flowctrl & FLOW_CTRL_RX)
+					tempval1 |= MACCFG1_RX_FLOW;
+			}
+		}
+
+		gfar_write(&regs->maccfg1, tempval1);
 		gfar_write(&regs->maccfg2, tempval);
 		gfar_write(&regs->ecntrl, ecntrl);
 
diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index aedfcc4..41740e2 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -148,6 +148,8 @@ extern const char gfar_driver_version[];
 		| SUPPORTED_100baseT_Half \
 		| SUPPORTED_100baseT_Full \
 		| SUPPORTED_Autoneg \
+		| SUPPORTED_Pause \
+		| SUPPORTED_Asym_Pause \
 		| SUPPORTED_MII)
 
 /* TBI register addresses */
@@ -1105,7 +1107,10 @@ struct gfar_private {
 		extended_hash:1,
 		bd_stash_en:1,
 		rx_filer_enable:1,
-		wol_en:1; /* Wake-on-LAN enabled */
+		wol_en:1, /* Wake-on-LAN enabled */
+		pause_aneg_en:1,
+		tx_pause_en:1,
+		rx_pause_en:1;
 	unsigned short padding;
 
 	/* PHY stuff */
diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
index 01748d1..0fc1c65d 100644
--- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
+++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
@@ -1836,6 +1836,75 @@ static int gfar_nway_reset(struct net_device *dev)
 	return phy_start_aneg(priv->phydev);
 }
 
+static void gfar_get_pauseparam(struct net_device *dev, struct ethtool_pauseparam *epause)
+{
+	struct gfar_private *priv = netdev_priv(dev);
+
+	epause->autoneg = !!priv->pause_aneg_en;
+	epause->rx_pause = !!priv->rx_pause_en;
+	epause->tx_pause = !!priv->tx_pause_en;
+
+}
+
+
+static int gfar_set_pauseparam(struct net_device *dev, struct ethtool_pauseparam *epause)
+{
+	struct gfar_private *priv = netdev_priv(dev);
+	struct phy_device *phydev = priv->phydev;
+	struct gfar __iomem *regs = priv->gfargrp[0].regs;
+	u32 oldadv, newadv;
+	int err = 0;
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
+			newadv = ADVERTISED_Pause;
+		} else
+			newadv = ADVERTISED_Pause | ADVERTISED_Asym_Pause;
+	} else if (epause->tx_pause) {
+		priv->tx_pause_en = 1;
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
+		if (phydev->autoneg) {
+			return phy_start_aneg(phydev);
+		}
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
+	return err;
+}
+
 const struct ethtool_ops gfar_ethtool_ops = {
 	.get_settings = gfar_gsettings,
 	.set_settings = gfar_ssettings,
@@ -1861,4 +1930,6 @@ const struct ethtool_ops gfar_ethtool_ops = {
 	.get_priv_flags = gfar_get_priv_flags,
 	.set_priv_flags = gfar_set_priv_flags,
 	.nway_reset = gfar_nway_reset,
+	.get_pauseparam = gfar_get_pauseparam,
+	.set_pauseparam = gfar_set_pauseparam,
 };
-- 
1.7.10.4
