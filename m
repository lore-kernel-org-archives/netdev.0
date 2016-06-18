From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/2] net: ethernet: nb8800: use phydev from struct net_device
Date: Sat, 18 Jun 2016 23:16:54 +0200
Message-ID: <1466284615-7045-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: mans@mansr.com, davem@davemloft.net, sf84@laposte.net,
	arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The private structure contain a pointer to phydev, but the structure
net_device already contain such pointer. So we can remove the pointer
phydev in the private structure, and update the driver to use the
one contained in struct net_device.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/aurora/nb8800.c |   57 +++++++++++++++++----------------
 drivers/net/ethernet/aurora/nb8800.h |    1 -
 2 files changed, 29 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethernet/aurora/nb8800.c
index 08a23e6..4989d31 100644
--- a/drivers/net/ethernet/aurora/nb8800.c
+++ b/drivers/net/ethernet/aurora/nb8800.c
@@ -631,7 +631,7 @@ static void nb8800_mac_config(struct net_device *dev)
 static void nb8800_pause_config(struct net_device *dev)
 {
 	struct nb8800_priv *priv = netdev_priv(dev);
-	struct phy_device *phydev = priv->phydev;
+	struct phy_device *phydev = dev->phydev;
 	u32 rxcr;
 
 	if (priv->pause_aneg) {
@@ -664,7 +664,7 @@ static void nb8800_pause_config(struct net_device *dev)
 static void nb8800_link_reconfigure(struct net_device *dev)
 {
 	struct nb8800_priv *priv = netdev_priv(dev);
-	struct phy_device *phydev = priv->phydev;
+	struct phy_device *phydev = dev->phydev;
 	int change = 0;
 
 	if (phydev->link) {
@@ -690,7 +690,7 @@ static void nb8800_link_reconfigure(struct net_device *dev)
 	}
 
 	if (change)
-		phy_print_status(priv->phydev);
+		phy_print_status(phydev);
 }
 
 static void nb8800_update_mac_addr(struct net_device *dev)
@@ -935,9 +935,10 @@ static int nb8800_dma_stop(struct net_device *dev)
 static void nb8800_pause_adv(struct net_device *dev)
 {
 	struct nb8800_priv *priv = netdev_priv(dev);
+	struct phy_device *phydev = dev->phydev;
 	u32 adv = 0;
 
-	if (!priv->phydev)
+	if (!phydev)
 		return;
 
 	if (priv->pause_rx)
@@ -945,13 +946,14 @@ static void nb8800_pause_adv(struct net_device *dev)
 	if (priv->pause_tx)
 		adv ^= ADVERTISED_Asym_Pause;
 
-	priv->phydev->supported |= adv;
-	priv->phydev->advertising |= adv;
+	phydev->supported |= adv;
+	phydev->advertising |= adv;
 }
 
 static int nb8800_open(struct net_device *dev)
 {
 	struct nb8800_priv *priv = netdev_priv(dev);
+	struct phy_device *phydev;
 	int err;
 
 	/* clear any pending interrupts */
@@ -969,10 +971,10 @@ static int nb8800_open(struct net_device *dev)
 	nb8800_mac_rx(dev, true);
 	nb8800_mac_tx(dev, true);
 
-	priv->phydev = of_phy_connect(dev, priv->phy_node,
-				      nb8800_link_reconfigure, 0,
-				      priv->phy_mode);
-	if (!priv->phydev)
+	phydev = of_phy_connect(dev, priv->phy_node,
+				nb8800_link_reconfigure, 0,
+				priv->phy_mode);
+	if (!phydev)
 		goto err_free_irq;
 
 	nb8800_pause_adv(dev);
@@ -982,7 +984,7 @@ static int nb8800_open(struct net_device *dev)
 	netif_start_queue(dev);
 
 	nb8800_start_rx(dev);
-	phy_start(priv->phydev);
+	phy_start(phydev);
 
 	return 0;
 
@@ -997,8 +999,9 @@ err_free_dma:
 static int nb8800_stop(struct net_device *dev)
 {
 	struct nb8800_priv *priv = netdev_priv(dev);
+	struct phy_device *phydev = dev->phydev;
 
-	phy_stop(priv->phydev);
+	phy_stop(phydev);
 
 	netif_stop_queue(dev);
 	napi_disable(&priv->napi);
@@ -1007,8 +1010,7 @@ static int nb8800_stop(struct net_device *dev)
 	nb8800_mac_rx(dev, false);
 	nb8800_mac_tx(dev, false);
 
-	phy_disconnect(priv->phydev);
-	priv->phydev = NULL;
+	phy_disconnect(phydev);
 
 	free_irq(dev->irq, dev);
 
@@ -1019,9 +1021,7 @@ static int nb8800_stop(struct net_device *dev)
 
 static int nb8800_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct nb8800_priv *priv = netdev_priv(dev);
-
-	return phy_mii_ioctl(priv->phydev, rq, cmd);
+	return phy_mii_ioctl(dev->phydev, rq, cmd);
 }
 
 static const struct net_device_ops nb8800_netdev_ops = {
@@ -1037,32 +1037,32 @@ static const struct net_device_ops nb8800_netdev_ops = {
 
 static int nb8800_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct nb8800_priv *priv = netdev_priv(dev);
+	struct phy_device *phydev = dev->phydev;
 
-	if (!priv->phydev)
+	if (!phydev)
 		return -ENODEV;
 
-	return phy_ethtool_gset(priv->phydev, cmd);
+	return phy_ethtool_gset(phydev, cmd);
 }
 
 static int nb8800_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct nb8800_priv *priv = netdev_priv(dev);
+	struct phy_device *phydev = dev->phydev;
 
-	if (!priv->phydev)
+	if (!phydev)
 		return -ENODEV;
 
-	return phy_ethtool_sset(priv->phydev, cmd);
+	return phy_ethtool_sset(phydev, cmd);
 }
 
 static int nb8800_nway_reset(struct net_device *dev)
 {
-	struct nb8800_priv *priv = netdev_priv(dev);
+	struct phy_device *phydev = dev->phydev;
 
-	if (!priv->phydev)
+	if (!phydev)
 		return -ENODEV;
 
-	return genphy_restart_aneg(priv->phydev);
+	return genphy_restart_aneg(phydev);
 }
 
 static void nb8800_get_pauseparam(struct net_device *dev,
@@ -1079,6 +1079,7 @@ static int nb8800_set_pauseparam(struct net_device *dev,
 				 struct ethtool_pauseparam *pp)
 {
 	struct nb8800_priv *priv = netdev_priv(dev);
+	struct phy_device *phydev = dev->phydev;
 
 	priv->pause_aneg = pp->autoneg;
 	priv->pause_rx = pp->rx_pause;
@@ -1088,8 +1089,8 @@ static int nb8800_set_pauseparam(struct net_device *dev,
 
 	if (!priv->pause_aneg)
 		nb8800_pause_config(dev);
-	else if (priv->phydev)
-		phy_start_aneg(priv->phydev);
+	else if (phydev)
+		phy_start_aneg(phydev);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/aurora/nb8800.h b/drivers/net/ethernet/aurora/nb8800.h
index e5adbc2..6ec4a95 100644
--- a/drivers/net/ethernet/aurora/nb8800.h
+++ b/drivers/net/ethernet/aurora/nb8800.h
@@ -284,7 +284,6 @@ struct nb8800_priv {
 
 	struct mii_bus			*mii_bus;
 	struct device_node		*phy_node;
-	struct phy_device		*phydev;
 
 	/* PHY connection type from DT */
 	int				phy_mode;
-- 
1.7.4.4
