From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/2] net: ethernet: hix5hd2: use phydev from struct net_device
Date: Sat, 25 Jun 2016 16:55:12 +0200
Message-ID: <1466866513-4351-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, mugunthanvnm@ti.com, a@unstable.cc,
	fw@strlen.de, felipe.balbi@linux.intel.com, arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The private structure contain a pointer to phydev, but the structure
net_device already contain such pointer. So we can remove the pointer
phy in the private structure, and update the driver to use the
one contained in struct net_device.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/hisilicon/hix5hd2_gmac.c |   30 ++++++++++--------------
 1 files changed, 13 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c b/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c
index b9f2ea5..fed1c0f 100644
--- a/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c
+++ b/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c
@@ -218,7 +218,6 @@ struct hix5hd2_priv {
 	struct device *dev;
 	struct net_device *netdev;
 
-	struct phy_device *phy;
 	struct device_node *phy_node;
 	phy_interface_t	phy_mode;
 
@@ -402,7 +401,7 @@ static int hix5hd2_net_set_mac_address(struct net_device *dev, void *p)
 static void hix5hd2_adjust_link(struct net_device *dev)
 {
 	struct hix5hd2_priv *priv = netdev_priv(dev);
-	struct phy_device *phy = priv->phy;
+	struct phy_device *phy = dev->phydev;
 
 	if ((priv->speed != phy->speed) || (priv->duplex != phy->duplex)) {
 		hix5hd2_config_port(dev, phy->speed, phy->duplex);
@@ -679,6 +678,7 @@ static void hix5hd2_free_dma_desc_rings(struct hix5hd2_priv *priv)
 static int hix5hd2_net_open(struct net_device *dev)
 {
 	struct hix5hd2_priv *priv = netdev_priv(dev);
+	struct phy_device *phy;
 	int ret;
 
 	ret = clk_prepare_enable(priv->clk);
@@ -687,12 +687,12 @@ static int hix5hd2_net_open(struct net_device *dev)
 		return ret;
 	}
 
-	priv->phy = of_phy_connect(dev, priv->phy_node,
-				   &hix5hd2_adjust_link, 0, priv->phy_mode);
-	if (!priv->phy)
+	phy = of_phy_connect(dev, priv->phy_node,
+			     &hix5hd2_adjust_link, 0, priv->phy_mode);
+	if (!phy)
 		return -ENODEV;
 
-	phy_start(priv->phy);
+	phy_start(phy);
 	hix5hd2_hw_init(priv);
 	hix5hd2_rx_refill(priv);
 
@@ -716,9 +716,9 @@ static int hix5hd2_net_close(struct net_device *dev)
 	netif_stop_queue(dev);
 	hix5hd2_free_dma_desc_rings(priv);
 
-	if (priv->phy) {
-		phy_stop(priv->phy);
-		phy_disconnect(priv->phy);
+	if (dev->phydev) {
+		phy_stop(dev->phydev);
+		phy_disconnect(dev->phydev);
 	}
 
 	clk_disable_unprepare(priv->clk);
@@ -753,23 +753,19 @@ static const struct net_device_ops hix5hd2_netdev_ops = {
 static int hix5hd2_get_settings(struct net_device *net_dev,
 				struct ethtool_cmd *cmd)
 {
-	struct hix5hd2_priv *priv = netdev_priv(net_dev);
-
-	if (!priv->phy)
+	if (!net_dev->phydev)
 		return -ENODEV;
 
-	return phy_ethtool_gset(priv->phy, cmd);
+	return phy_ethtool_gset(net_dev->phydev, cmd);
 }
 
 static int hix5hd2_set_settings(struct net_device *net_dev,
 				struct ethtool_cmd *cmd)
 {
-	struct hix5hd2_priv *priv = netdev_priv(net_dev);
-
-	if (!priv->phy)
+	if (!net_dev->phydev)
 		return -ENODEV;
 
-	return phy_ethtool_sset(priv->phy, cmd);
+	return phy_ethtool_sset(net_dev->phydev, cmd);
 }
 
 static struct ethtool_ops hix5hd2_ethtools_ops = {
-- 
1.7.4.4
