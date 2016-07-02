From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/2] net: ethernet: arc: emac: use phydev from struct net_device
Date: Sat,  2 Jul 2016 20:06:51 +0200
Message-ID: <1467482812-13917-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, wxt@rock-chips.com, heiko@sntech.de,
	al.kochet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The private structure contain a pointer to phydev, but the structure
net_device already contain such pointer. So we can remove the pointer
phy in the private structure, and update the driver to use the
one contained in struct net_device.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/arc/emac.h      |    1 -
 drivers/net/ethernet/arc/emac_main.c |   29 ++++++++++++-----------------
 2 files changed, 12 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/arc/emac.h b/drivers/net/ethernet/arc/emac.h
index ca562bc..e4feb71 100644
--- a/drivers/net/ethernet/arc/emac.h
+++ b/drivers/net/ethernet/arc/emac.h
@@ -134,7 +134,6 @@ struct arc_emac_priv {
 
 	/* Devices */
 	struct device *dev;
-	struct phy_device *phy_dev;
 	struct mii_bus *bus;
 	struct arc_emac_mdio_bus_data bus_data;
 
diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
index a3a9392..a8a1dc9 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -47,7 +47,7 @@ static inline int arc_emac_tx_avail(struct arc_emac_priv *priv)
 static void arc_emac_adjust_link(struct net_device *ndev)
 {
 	struct arc_emac_priv *priv = netdev_priv(ndev);
-	struct phy_device *phy_dev = priv->phy_dev;
+	struct phy_device *phy_dev = ndev->phydev;
 	unsigned int reg, state_changed = 0;
 
 	if (priv->link != phy_dev->link) {
@@ -92,9 +92,7 @@ static void arc_emac_adjust_link(struct net_device *ndev)
 static int arc_emac_get_settings(struct net_device *ndev,
 				 struct ethtool_cmd *cmd)
 {
-	struct arc_emac_priv *priv = netdev_priv(ndev);
-
-	return phy_ethtool_gset(priv->phy_dev, cmd);
+	return phy_ethtool_gset(ndev->phydev, cmd);
 }
 
 /**
@@ -111,12 +109,10 @@ static int arc_emac_get_settings(struct net_device *ndev,
 static int arc_emac_set_settings(struct net_device *ndev,
 				 struct ethtool_cmd *cmd)
 {
-	struct arc_emac_priv *priv = netdev_priv(ndev);
-
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
 
-	return phy_ethtool_sset(priv->phy_dev, cmd);
+	return phy_ethtool_sset(ndev->phydev, cmd);
 }
 
 /**
@@ -403,7 +399,7 @@ static void arc_emac_poll_controller(struct net_device *dev)
 static int arc_emac_open(struct net_device *ndev)
 {
 	struct arc_emac_priv *priv = netdev_priv(ndev);
-	struct phy_device *phy_dev = priv->phy_dev;
+	struct phy_device *phy_dev = ndev->phydev;
 	int i;
 
 	phy_dev->autoneg = AUTONEG_ENABLE;
@@ -474,7 +470,7 @@ static int arc_emac_open(struct net_device *ndev)
 	/* Enable EMAC */
 	arc_reg_or(priv, R_CTRL, EN_MASK);
 
-	phy_start_aneg(priv->phy_dev);
+	phy_start_aneg(ndev->phydev);
 
 	netif_start_queue(ndev);
 
@@ -772,6 +768,7 @@ int arc_emac_probe(struct net_device *ndev, int interface)
 	struct device *dev = ndev->dev.parent;
 	struct resource res_regs;
 	struct device_node *phy_node;
+	struct phy_device *phydev = NULL;
 	struct arc_emac_priv *priv;
 	const char *mac_addr;
 	unsigned int id, clock_frequency, irq;
@@ -887,16 +884,16 @@ int arc_emac_probe(struct net_device *ndev, int interface)
 		goto out_clken;
 	}
 
-	priv->phy_dev = of_phy_connect(ndev, phy_node, arc_emac_adjust_link, 0,
-				       interface);
-	if (!priv->phy_dev) {
+	phydev = of_phy_connect(ndev, phy_node, arc_emac_adjust_link, 0,
+				interface);
+	if (!phydev) {
 		dev_err(dev, "of_phy_connect() failed\n");
 		err = -ENODEV;
 		goto out_mdio;
 	}
 
 	dev_info(dev, "connected to %s phy with id 0x%x\n",
-		 priv->phy_dev->drv->name, priv->phy_dev->phy_id);
+		 phydev->drv->name, phydev->phy_id);
 
 	netif_napi_add(ndev, &priv->napi, arc_emac_poll, ARC_EMAC_NAPI_WEIGHT);
 
@@ -910,8 +907,7 @@ int arc_emac_probe(struct net_device *ndev, int interface)
 
 out_netif_api:
 	netif_napi_del(&priv->napi);
-	phy_disconnect(priv->phy_dev);
-	priv->phy_dev = NULL;
+	phy_disconnect(phydev);
 out_mdio:
 	arc_mdio_remove(priv);
 out_clken:
@@ -925,8 +921,7 @@ int arc_emac_remove(struct net_device *ndev)
 {
 	struct arc_emac_priv *priv = netdev_priv(ndev);
 
-	phy_disconnect(priv->phy_dev);
-	priv->phy_dev = NULL;
+	phy_disconnect(ndev->phydev);
 	arc_mdio_remove(priv);
 	unregister_netdev(ndev);
 	netif_napi_del(&priv->napi);
-- 
1.7.4.4
