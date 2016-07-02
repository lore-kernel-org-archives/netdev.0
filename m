From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/2] net: ethernet: lantiq_etop: use phydev from struct net_device
Date: Sun,  3 Jul 2016 00:05:04 +0200
Message-ID: <1467497105-19935-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, andrew@lunn.ch, sudipm.mukherjee@gmail.com,
	mugunthanvnm@ti.com, felipe.balbi@linux.intel.com, fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36226 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751420AbcGBWFP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jul 2016 18:05:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The private structure contain a pointer to phydev, but the structure
net_device already contain such pointer. So we can remove the pointer
phy in the private structure, and update the driver to use the
one contained in struct net_device.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/lantiq_etop.c |   24 +++++++-----------------
 1 files changed, 7 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
index 0d2f8e9..ad715a4 100644
--- a/drivers/net/ethernet/lantiq_etop.c
+++ b/drivers/net/ethernet/lantiq_etop.c
@@ -102,7 +102,6 @@ struct ltq_etop_priv {
 	struct resource *res;
 
 	struct mii_bus *mii_bus;
-	struct phy_device *phydev;
 
 	struct ltq_etop_chan ch[MAX_DMA_CHAN];
 	int tx_free[MAX_DMA_CHAN >> 1];
@@ -307,25 +306,19 @@ ltq_etop_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 static int
 ltq_etop_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct ltq_etop_priv *priv = netdev_priv(dev);
-
-	return phy_ethtool_gset(priv->phydev, cmd);
+	return phy_ethtool_gset(dev->phydev, cmd);
 }
 
 static int
 ltq_etop_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct ltq_etop_priv *priv = netdev_priv(dev);
-
-	return phy_ethtool_sset(priv->phydev, cmd);
+	return phy_ethtool_sset(dev->phydev, cmd);
 }
 
 static int
 ltq_etop_nway_reset(struct net_device *dev)
 {
-	struct ltq_etop_priv *priv = netdev_priv(dev);
-
-	return phy_start_aneg(priv->phydev);
+	return phy_start_aneg(dev->phydev);
 }
 
 static const struct ethtool_ops ltq_etop_ethtool_ops = {
@@ -401,7 +394,6 @@ ltq_etop_mdio_probe(struct net_device *dev)
 			      | SUPPORTED_TP);
 
 	phydev->advertising = phydev->supported;
-	priv->phydev = phydev;
 	phy_attached_info(phydev);
 
 	return 0;
@@ -450,7 +442,7 @@ ltq_etop_mdio_cleanup(struct net_device *dev)
 {
 	struct ltq_etop_priv *priv = netdev_priv(dev);
 
-	phy_disconnect(priv->phydev);
+	phy_disconnect(dev->phydev);
 	mdiobus_unregister(priv->mii_bus);
 	mdiobus_free(priv->mii_bus);
 }
@@ -469,7 +461,7 @@ ltq_etop_open(struct net_device *dev)
 		ltq_dma_open(&ch->dma);
 		napi_enable(&ch->napi);
 	}
-	phy_start(priv->phydev);
+	phy_start(dev->phydev);
 	netif_tx_start_all_queues(dev);
 	return 0;
 }
@@ -481,7 +473,7 @@ ltq_etop_stop(struct net_device *dev)
 	int i;
 
 	netif_tx_stop_all_queues(dev);
-	phy_stop(priv->phydev);
+	phy_stop(dev->phydev);
 	for (i = 0; i < MAX_DMA_CHAN; i++) {
 		struct ltq_etop_chan *ch = &priv->ch[i];
 
@@ -556,10 +548,8 @@ ltq_etop_change_mtu(struct net_device *dev, int new_mtu)
 static int
 ltq_etop_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct ltq_etop_priv *priv = netdev_priv(dev);
-
 	/* TODO: mii-toll reports "No MII transceiver present!." ?!*/
-	return phy_mii_ioctl(priv->phydev, rq, cmd);
+	return phy_mii_ioctl(dev->phydev, rq, cmd);
 }
 
 static int
-- 
1.7.4.4
