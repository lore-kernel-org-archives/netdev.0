From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/2] net: ethernet: ftgmac100: use phydev from struct net_device
Date: Mon, 16 May 2016 01:35:13 +0200
Message-ID: <1463355314-20889-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: andrew@lunn.ch, davem@davemloft.net, f.fainelli@gmail.com,
	linux@roeck-us.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The private structure contain a pointer to phydev, but the structure
net_device already contain such pointer. So we can remove the pointer
phydev in the private structure, and update the driver to use the
one contained in struct net_device.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/faraday/ftgmac100.c |   24 ++++++++----------------
 1 files changed, 8 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 84384e1..9cc23c3 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -71,7 +71,6 @@ struct ftgmac100 {
 	struct napi_struct napi;
 
 	struct mii_bus *mii_bus;
-	struct phy_device *phydev;
 	int old_speed;
 };
 
@@ -807,7 +806,7 @@ err:
 static void ftgmac100_adjust_link(struct net_device *netdev)
 {
 	struct ftgmac100 *priv = netdev_priv(netdev);
-	struct phy_device *phydev = priv->phydev;
+	struct phy_device *phydev = netdev->phydev;
 	int ier;
 
 	if (phydev->speed == priv->old_speed)
@@ -850,7 +849,6 @@ static int ftgmac100_mii_probe(struct ftgmac100 *priv)
 		return PTR_ERR(phydev);
 	}
 
-	priv->phydev = phydev;
 	return 0;
 }
 
@@ -942,17 +940,13 @@ static void ftgmac100_get_drvinfo(struct net_device *netdev,
 static int ftgmac100_get_settings(struct net_device *netdev,
 				  struct ethtool_cmd *cmd)
 {
-	struct ftgmac100 *priv = netdev_priv(netdev);
-
-	return phy_ethtool_gset(priv->phydev, cmd);
+	return phy_ethtool_gset(netdev->phydev, cmd);
 }
 
 static int ftgmac100_set_settings(struct net_device *netdev,
 				  struct ethtool_cmd *cmd)
 {
-	struct ftgmac100 *priv = netdev_priv(netdev);
-
-	return phy_ethtool_sset(priv->phydev, cmd);
+	return phy_ethtool_sset(netdev->phydev, cmd);
 }
 
 static const struct ethtool_ops ftgmac100_ethtool_ops = {
@@ -1085,7 +1079,7 @@ static int ftgmac100_open(struct net_device *netdev)
 	ftgmac100_init_hw(priv);
 	ftgmac100_start_hw(priv, 10);
 
-	phy_start(priv->phydev);
+	phy_start(netdev->phydev);
 
 	napi_enable(&priv->napi);
 	netif_start_queue(netdev);
@@ -1111,7 +1105,7 @@ static int ftgmac100_stop(struct net_device *netdev)
 
 	netif_stop_queue(netdev);
 	napi_disable(&priv->napi);
-	phy_stop(priv->phydev);
+	phy_stop(netdev->phydev);
 
 	ftgmac100_stop_hw(priv);
 	free_irq(priv->irq, netdev);
@@ -1152,9 +1146,7 @@ static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
 /* optional */
 static int ftgmac100_do_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 {
-	struct ftgmac100 *priv = netdev_priv(netdev);
-
-	return phy_mii_ioctl(priv->phydev, ifr, cmd);
+	return phy_mii_ioctl(netdev->phydev, ifr, cmd);
 }
 
 static const struct net_device_ops ftgmac100_netdev_ops = {
@@ -1275,7 +1267,7 @@ static int ftgmac100_probe(struct platform_device *pdev)
 	return 0;
 
 err_register_netdev:
-	phy_disconnect(priv->phydev);
+	phy_disconnect(netdev->phydev);
 err_mii_probe:
 	mdiobus_unregister(priv->mii_bus);
 err_register_mdiobus:
@@ -1301,7 +1293,7 @@ static int __exit ftgmac100_remove(struct platform_device *pdev)
 
 	unregister_netdev(netdev);
 
-	phy_disconnect(priv->phydev);
+	phy_disconnect(netdev->phydev);
 	mdiobus_unregister(priv->mii_bus);
 	mdiobus_free(priv->mii_bus);
 
-- 
1.7.4.4
