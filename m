From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH 2/2][net-next] gianfar: Add ethtool -A support for pause frame
Date: Wed, 7 Aug 2013 13:24:16 +0300
Message-ID: <1375871056-10420-2-git-send-email-claudiu.manoil@freescale.com>
References: <1375871056-10420-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe004.messaging.microsoft.com ([207.46.163.27]:57233
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932491Ab3HGKZD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 06:25:03 -0400
In-Reply-To: <1375871056-10420-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow Rx/Tx pause frame configuration via ethtool.
The gfar devices feature link autonegotioation by default.
The device is being configured with the new pause frame
parameters if the link is up, depending on link duplex (no
pause frames for half-duplex links), or during link autoneg
(see adjust_link()).

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.h         |  1 +
 drivers/net/ethernet/freescale/gianfar_ethtool.c | 30 ++++++++++++++++++++++++
 2 files changed, 31 insertions(+)

diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index e6a03f4..aaac843 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -1186,6 +1186,7 @@ void gfar_init_sysfs(struct net_device *dev);
 int gfar_set_features(struct net_device *dev, netdev_features_t features);
 extern void gfar_check_rx_parser_mode(struct gfar_private *priv);
 extern void gfar_vlan_mode(struct net_device *dev, netdev_features_t features);
+void gfar_configure_pause(struct gfar_private *priv, bool en);
 
 extern const struct ethtool_ops gfar_ethtool_ops;
 
diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
index 21cd881..6cf89c1 100644
--- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
+++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
@@ -535,6 +535,34 @@ static int gfar_sringparam(struct net_device *dev,
 	return err;
 }
 
+static void gfar_gpauseparam(struct net_device *dev,
+			     struct ethtool_pauseparam *pause)
+{
+	struct gfar_private *priv = netdev_priv(dev);
+
+	pause->autoneg = AUTONEG_ENABLE;
+	if (priv->rx_pause)
+		pause->rx_pause = 1;
+	if (priv->tx_pause)
+		pause->tx_pause = 1;
+}
+
+static int gfar_spauseparam(struct net_device *dev,
+			    struct ethtool_pauseparam *pause)
+{
+	struct gfar_private *priv = netdev_priv(dev);
+	struct phy_device *phydev = priv->phydev;
+
+	priv->rx_pause = !!pause->rx_pause;
+	priv->tx_pause = !!pause->tx_pause;
+
+	/* update h/w settings, if link is up */
+	if (phydev && phydev->link)
+		gfar_configure_pause(priv, !!phydev->duplex);
+
+	return 0;
+}
+
 int gfar_set_features(struct net_device *dev, netdev_features_t features)
 {
 	struct gfar_private *priv = netdev_priv(dev);
@@ -1806,6 +1834,8 @@ const struct ethtool_ops gfar_ethtool_ops = {
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
