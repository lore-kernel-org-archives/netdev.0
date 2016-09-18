From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/2] net: ethernet: broadcom: bcm63xx: use phydev from struct net_device
Date: Sun, 18 Sep 2016 16:59:06 +0200
Message-ID: <1474210747-19627-1-git-send-email-tremyfr@gmail.com>
Cc: bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: f.fainelli@gmail.com, davem@davemloft.net, andrew@lunn.ch,
        treding@nvidia.com, ivecera@redhat.com, xypron.glpk@gmx.de,
        simon@fire.lp0.eu
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The private structure contain a pointer to phydev, but the structure
net_device already contain such pointer. So we can remove the pointer
phydev in the private structure, and update the driver to use the
one contained in struct net_device.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/broadcom/bcm63xx_enet.c |   31 +++++++++++--------------
 drivers/net/ethernet/broadcom/bcm63xx_enet.h |    1 -
 2 files changed, 14 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index 6c8bc5f..082f3f0 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -791,7 +791,7 @@ static void bcm_enet_adjust_phy_link(struct net_device *dev)
 	int status_changed;
 
 	priv = netdev_priv(dev);
-	phydev = priv->phydev;
+	phydev = dev->phydev;
 	status_changed = 0;
 
 	if (priv->old_link != phydev->link) {
@@ -913,7 +913,6 @@ static int bcm_enet_open(struct net_device *dev)
 		priv->old_link = 0;
 		priv->old_duplex = -1;
 		priv->old_pause = -1;
-		priv->phydev = phydev;
 	}
 
 	/* mask all interrupts and request them */
@@ -1085,7 +1084,7 @@ static int bcm_enet_open(struct net_device *dev)
 			 ENETDMAC_IRMASK, priv->tx_chan);
 
 	if (priv->has_phy)
-		phy_start(priv->phydev);
+		phy_start(phydev);
 	else
 		bcm_enet_adjust_link(dev);
 
@@ -1127,7 +1126,7 @@ out_freeirq:
 	free_irq(dev->irq, dev);
 
 out_phy_disconnect:
-	phy_disconnect(priv->phydev);
+	phy_disconnect(phydev);
 
 	return ret;
 }
@@ -1190,7 +1189,7 @@ static int bcm_enet_stop(struct net_device *dev)
 	netif_stop_queue(dev);
 	napi_disable(&priv->napi);
 	if (priv->has_phy)
-		phy_stop(priv->phydev);
+		phy_stop(dev->phydev);
 	del_timer_sync(&priv->rx_timeout);
 
 	/* mask all interrupts */
@@ -1234,10 +1233,8 @@ static int bcm_enet_stop(struct net_device *dev)
 	free_irq(dev->irq, dev);
 
 	/* release phy */
-	if (priv->has_phy) {
-		phy_disconnect(priv->phydev);
-		priv->phydev = NULL;
-	}
+	if (priv->has_phy)
+		phy_disconnect(dev->phydev);
 
 	return 0;
 }
@@ -1437,9 +1434,9 @@ static int bcm_enet_nway_reset(struct net_device *dev)
 
 	priv = netdev_priv(dev);
 	if (priv->has_phy) {
-		if (!priv->phydev)
+		if (!dev->phydev)
 			return -ENODEV;
-		return genphy_restart_aneg(priv->phydev);
+		return genphy_restart_aneg(dev->phydev);
 	}
 
 	return -EOPNOTSUPP;
@@ -1456,9 +1453,9 @@ static int bcm_enet_get_settings(struct net_device *dev,
 	cmd->maxtxpkt = 0;
 
 	if (priv->has_phy) {
-		if (!priv->phydev)
+		if (!dev->phydev)
 			return -ENODEV;
-		return phy_ethtool_gset(priv->phydev, cmd);
+		return phy_ethtool_gset(dev->phydev, cmd);
 	} else {
 		cmd->autoneg = 0;
 		ethtool_cmd_speed_set(cmd, ((priv->force_speed_100)
@@ -1483,9 +1480,9 @@ static int bcm_enet_set_settings(struct net_device *dev,
 
 	priv = netdev_priv(dev);
 	if (priv->has_phy) {
-		if (!priv->phydev)
+		if (!dev->phydev)
 			return -ENODEV;
-		return phy_ethtool_sset(priv->phydev, cmd);
+		return phy_ethtool_sset(dev->phydev, cmd);
 	} else {
 
 		if (cmd->autoneg ||
@@ -1604,9 +1601,9 @@ static int bcm_enet_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 
 	priv = netdev_priv(dev);
 	if (priv->has_phy) {
-		if (!priv->phydev)
+		if (!dev->phydev)
 			return -ENODEV;
-		return phy_mii_ioctl(priv->phydev, rq, cmd);
+		return phy_mii_ioctl(dev->phydev, rq, cmd);
 	} else {
 		struct mii_if_info mii;
 
diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.h b/drivers/net/ethernet/broadcom/bcm63xx_enet.h
index f55af43..0a1b7b2 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.h
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.h
@@ -290,7 +290,6 @@ struct bcm_enet_priv {
 
 	/* used when a phy is connected (phylib used) */
 	struct mii_bus *mii_bus;
-	struct phy_device *phydev;
 	int old_link;
 	int old_duplex;
 	int old_pause;
-- 
1.7.4.4
