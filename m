From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 2/8] ftgmac100: Add pause frames configuration and support
Date: Thu, 13 Apr 2017 08:44:37 +1000
Message-ID: <20170412224443.17906-3-benh@kernel.crashing.org>
References: <20170412224443.17906-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:33731 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752851AbdDLWqn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 18:46:43 -0400
In-Reply-To: <20170412224443.17906-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hopefully my understanding of how the hardware works is correct,
as the documentation isn't completely clear. So far I have seen
no obvious issue. Pause seem to also work with NC-SI.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 96 +++++++++++++++++++++++++++++++-
 drivers/net/ethernet/faraday/ftgmac100.h |  7 +++
 2 files changed, 102 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index bbeb8e7..4f3ec2c 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -97,6 +97,11 @@ struct ftgmac100 {
 	int cur_duplex;
 	bool use_ncsi;
 
+	/* Flow control settings */
+	bool tx_pause;
+	bool rx_pause;
+	bool aneg_pause;
+
 	/* Misc */
 	bool need_mac_restart;
 	bool is_aspeed;
@@ -217,6 +222,23 @@ static int ftgmac100_set_mac_addr(struct net_device *dev, void *p)
 	return 0;
 }
 
+static void ftgmac100_config_pause(struct ftgmac100 *priv)
+{
+	u32 fcr = FTGMAC100_FCR_PAUSE_TIME(16);
+
+	/* Throttle tx queue when receiving pause frames */
+	if (priv->rx_pause)
+		fcr |= FTGMAC100_FCR_FC_EN;
+
+	/* Enables sending pause frames when the RX queue is past a
+	 * certain threshold.
+	 */
+	if (priv->tx_pause)
+		fcr |= FTGMAC100_FCR_FCTHR_EN;
+
+	iowrite32(fcr, priv->base + FTGMAC100_OFFSET_FCR);
+}
+
 static void ftgmac100_init_hw(struct ftgmac100 *priv)
 {
 	u32 reg, rfifo_sz, tfifo_sz;
@@ -910,6 +932,7 @@ static void ftgmac100_adjust_link(struct net_device *netdev)
 {
 	struct ftgmac100 *priv = netdev_priv(netdev);
 	struct phy_device *phydev = netdev->phydev;
+	bool tx_pause, rx_pause;
 	int new_speed;
 
 	/* We store "no link" as speed 0 */
@@ -918,8 +941,21 @@ static void ftgmac100_adjust_link(struct net_device *netdev)
 	else
 		new_speed = phydev->speed;
 
+	/* Grab pause settings from PHY if configured to do so */
+	if (priv->aneg_pause) {
+		rx_pause = tx_pause = phydev->pause;
+		if (phydev->asym_pause)
+			tx_pause = !rx_pause;
+	} else {
+		rx_pause = priv->rx_pause;
+		tx_pause = priv->tx_pause;
+	}
+
+	/* Link hasn't changed, do nothing */
 	if (phydev->speed == priv->cur_speed &&
-	    phydev->duplex == priv->cur_duplex)
+	    phydev->duplex == priv->cur_duplex &&
+	    rx_pause == priv->rx_pause &&
+	    tx_pause == priv->tx_pause)
 		return;
 
 	/* Print status if we have a link or we had one and just lost it,
@@ -930,6 +966,8 @@ static void ftgmac100_adjust_link(struct net_device *netdev)
 
 	priv->cur_speed = new_speed;
 	priv->cur_duplex = phydev->duplex;
+	priv->rx_pause = rx_pause;
+	priv->tx_pause = tx_pause;
 
 	/* Link is down, do nothing else */
 	if (!new_speed)
@@ -961,6 +999,12 @@ static int ftgmac100_mii_probe(struct ftgmac100 *priv)
 		return PTR_ERR(phydev);
 	}
 
+	/* Indicate that we support PAUSE frames (see comment in
+	 * Documentation/networking/phy.txt)
+	 */
+	phydev->supported |= SUPPORTED_Pause | SUPPORTED_Asym_Pause;
+	phydev->advertising = phydev->supported;
+
 	return 0;
 }
 
@@ -1083,6 +1127,48 @@ static int ftgmac100_set_ringparam(struct net_device *netdev,
 	return 0;
 }
 
+static void ftgmac100_get_pauseparam(struct net_device *netdev,
+				     struct ethtool_pauseparam *pause)
+{
+	struct ftgmac100 *priv = netdev_priv(netdev);
+
+	pause->autoneg = priv->aneg_pause;
+	pause->tx_pause = priv->tx_pause;
+	pause->rx_pause = priv->rx_pause;
+}
+
+static int ftgmac100_set_pauseparam(struct net_device *netdev,
+				    struct ethtool_pauseparam *pause)
+{
+	struct ftgmac100 *priv = netdev_priv(netdev);
+	struct phy_device *phydev = netdev->phydev;
+
+	priv->aneg_pause = pause->autoneg;
+	priv->tx_pause = pause->tx_pause;
+	priv->rx_pause = pause->rx_pause;
+
+	if (phydev) {
+		phydev->advertising &= ~ADVERTISED_Pause;
+		phydev->advertising &= ~ADVERTISED_Asym_Pause;
+
+		if (pause->rx_pause) {
+			phydev->advertising |= ADVERTISED_Pause;
+			phydev->advertising |= ADVERTISED_Asym_Pause;
+		}
+
+		if (pause->tx_pause)
+			phydev->advertising ^= ADVERTISED_Asym_Pause;
+	}
+	if (netif_running(netdev)) {
+		if (phydev && priv->aneg_pause)
+			phy_start_aneg(phydev);
+		else
+			ftgmac100_config_pause(priv);
+	}
+
+	return 0;
+}
+
 static const struct ethtool_ops ftgmac100_ethtool_ops = {
 	.get_drvinfo		= ftgmac100_get_drvinfo,
 	.get_link		= ethtool_op_get_link,
@@ -1091,6 +1177,8 @@ static const struct ethtool_ops ftgmac100_ethtool_ops = {
 	.nway_reset		= ftgmac100_nway_reset,
 	.get_ringparam		= ftgmac100_get_ringparam,
 	.set_ringparam		= ftgmac100_set_ringparam,
+	.get_pauseparam		= ftgmac100_get_pauseparam,
+	.set_pauseparam		= ftgmac100_set_pauseparam,
 };
 
 static irqreturn_t ftgmac100_interrupt(int irq, void *dev_id)
@@ -1222,6 +1310,7 @@ static int ftgmac100_init_all(struct ftgmac100 *priv, bool ignore_alloc_err)
 
 	/* Reinit and restart HW */
 	ftgmac100_init_hw(priv);
+	ftgmac100_config_pause(priv);
 	ftgmac100_start_hw(priv);
 
 	/* Re-enable the device */
@@ -1551,6 +1640,11 @@ static int ftgmac100_probe(struct platform_device *pdev)
 
 	netdev->irq = irq;
 
+	/* Enable pause */
+	priv->tx_pause = true;
+	priv->rx_pause = true;
+	priv->aneg_pause = true;
+
 	/* MAC address from chip or random one */
 	ftgmac100_initial_mac(priv);
 
diff --git a/drivers/net/ethernet/faraday/ftgmac100.h b/drivers/net/ethernet/faraday/ftgmac100.h
index 97912c4..0653d81 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.h
+++ b/drivers/net/ethernet/faraday/ftgmac100.h
@@ -199,6 +199,13 @@
 #define FTGMAC100_PHYDATA_MIIRDATA(phydata)	(((phydata) >> 16) & 0xffff)
 
 /*
+ * Flow control register
+ */
+#define FTGMAC100_FCR_FC_EN		(1 << 0)
+#define FTGMAC100_FCR_FCTHR_EN		(1 << 2)
+#define FTGMAC100_FCR_PAUSE_TIME(x)	(((x) & 0xffff) << 16)
+
+/*
  * Transmit descriptor, aligned to 16 bytes
  */
 struct ftgmac100_txdes {
-- 
2.9.3
