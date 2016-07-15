From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH v2 1/2] net: ethernet: ethoc: use phydev from struct net_device
Date: Fri, 15 Jul 2016 09:59:11 +0200
Message-ID: <1468569552-24824-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, andrew@lunn.ch, tklauser@distanz.ch,
	colin.king@canonical.com, f.fainelli@gmail.com, jcmvbkbc@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The private structure contain a pointer to phydev, but the structure
net_device already contain such pointer. So we can remove the pointer
phy in the private structure, and update the driver to use the
one contained in struct net_device.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
Changelog:
v2:
- remove the definition of phy in the ethoc private struct (thanks Tobias Klauser)

 drivers/net/ethernet/ethoc.c |   20 +++++++-------------
 1 files changed, 7 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 4edb98c..317168a 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -192,7 +192,6 @@ MODULE_PARM_DESC(buffer_size, "DMA buffer allocation size");
  * @napi:	NAPI structure
  * @msg_enable:	device state flags
  * @lock:	device lock
- * @phy:	attached PHY
  * @mdio:	MDIO bus for PHY access
  * @phy_id:	address of attached PHY
  */
@@ -219,7 +218,6 @@ struct ethoc {
 
 	spinlock_t lock;
 
-	struct phy_device *phy;
 	struct mii_bus *mdio;
 	struct clk *clk;
 	s8 phy_id;
@@ -694,7 +692,6 @@ static int ethoc_mdio_probe(struct net_device *dev)
 		return err;
 	}
 
-	priv->phy = phy;
 	phy->advertising &= ~(ADVERTISED_1000baseT_Full |
 			      ADVERTISED_1000baseT_Half);
 	phy->supported &= ~(SUPPORTED_1000baseT_Full |
@@ -724,7 +721,7 @@ static int ethoc_open(struct net_device *dev)
 		netif_start_queue(dev);
 	}
 
-	phy_start(priv->phy);
+	phy_start(dev->phydev);
 	napi_enable(&priv->napi);
 
 	if (netif_msg_ifup(priv)) {
@@ -741,8 +738,8 @@ static int ethoc_stop(struct net_device *dev)
 
 	napi_disable(&priv->napi);
 
-	if (priv->phy)
-		phy_stop(priv->phy);
+	if (dev->phydev)
+		phy_stop(dev->phydev);
 
 	ethoc_disable_rx_and_tx(priv);
 	free_irq(dev->irq, dev);
@@ -770,7 +767,7 @@ static int ethoc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		if (!phy)
 			return -ENODEV;
 	} else {
-		phy = priv->phy;
+		phy = dev->phydev;
 	}
 
 	return phy_mii_ioctl(phy, ifr, cmd);
@@ -899,8 +896,7 @@ out:
 
 static int ethoc_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct ethoc *priv = netdev_priv(dev);
-	struct phy_device *phydev = priv->phy;
+	struct phy_device *phydev = dev->phydev;
 
 	if (!phydev)
 		return -EOPNOTSUPP;
@@ -910,8 +906,7 @@ static int ethoc_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 static int ethoc_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct ethoc *priv = netdev_priv(dev);
-	struct phy_device *phydev = priv->phy;
+	struct phy_device *phydev = dev->phydev;
 
 	if (!phydev)
 		return -EOPNOTSUPP;
@@ -1261,8 +1256,7 @@ static int ethoc_remove(struct platform_device *pdev)
 
 	if (netdev) {
 		netif_napi_del(&priv->napi);
-		phy_disconnect(priv->phy);
-		priv->phy = NULL;
+		phy_disconnect(netdev->phydev);
 
 		if (priv->mdio) {
 			mdiobus_unregister(priv->mdio);
-- 
1.7.4.4
