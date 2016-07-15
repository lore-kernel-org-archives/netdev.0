From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/2] net: ethernet: ti: cpmac: use phydev from struct net_device
Date: Fri, 15 Jul 2016 12:39:01 +0200
Message-ID: <1468579142-14138-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: florian@openwrt.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The private structure contain a pointer to phydev, but the structure
net_device already contain such pointer. So we can remove the pointer
phy in the private structure, and update the driver to use the
one contained in struct net_device.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/ti/cpmac.c |   46 +++++++++++++++++----------------------
 1 files changed, 20 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cpmac.c
index 7eef45e..f48e43b 100644
--- a/drivers/net/ethernet/ti/cpmac.c
+++ b/drivers/net/ethernet/ti/cpmac.c
@@ -205,7 +205,6 @@ struct cpmac_priv {
 	dma_addr_t dma_ring;
 	void __iomem *regs;
 	struct mii_bus *mii_bus;
-	struct phy_device *phy;
 	char phy_name[MII_BUS_ID_SIZE + 3];
 	int oldlink, oldspeed, oldduplex;
 	u32 msg_enable;
@@ -830,35 +829,29 @@ static void cpmac_tx_timeout(struct net_device *dev)
 
 static int cpmac_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
-	struct cpmac_priv *priv = netdev_priv(dev);
-
 	if (!(netif_running(dev)))
 		return -EINVAL;
-	if (!priv->phy)
+	if (!dev->phydev)
 		return -EINVAL;
 
-	return phy_mii_ioctl(priv->phy, ifr, cmd);
+	return phy_mii_ioctl(dev->phydev, ifr, cmd);
 }
 
 static int cpmac_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct cpmac_priv *priv = netdev_priv(dev);
-
-	if (priv->phy)
-		return phy_ethtool_gset(priv->phy, cmd);
+	if (dev->phydev)
+		return phy_ethtool_gset(dev->phydev, cmd);
 
 	return -EINVAL;
 }
 
 static int cpmac_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct cpmac_priv *priv = netdev_priv(dev);
-
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
 
-	if (priv->phy)
-		return phy_ethtool_sset(priv->phy, cmd);
+	if (dev->phydev)
+		return phy_ethtool_sset(dev->phydev, cmd);
 
 	return -EINVAL;
 }
@@ -914,16 +907,16 @@ static void cpmac_adjust_link(struct net_device *dev)
 	int new_state = 0;
 
 	spin_lock(&priv->lock);
-	if (priv->phy->link) {
+	if (dev->phydev->link) {
 		netif_tx_start_all_queues(dev);
-		if (priv->phy->duplex != priv->oldduplex) {
+		if (dev->phydev->duplex != priv->oldduplex) {
 			new_state = 1;
-			priv->oldduplex = priv->phy->duplex;
+			priv->oldduplex = dev->phydev->duplex;
 		}
 
-		if (priv->phy->speed != priv->oldspeed) {
+		if (dev->phydev->speed != priv->oldspeed) {
 			new_state = 1;
-			priv->oldspeed = priv->phy->speed;
+			priv->oldspeed = dev->phydev->speed;
 		}
 
 		if (!priv->oldlink) {
@@ -938,7 +931,7 @@ static void cpmac_adjust_link(struct net_device *dev)
 	}
 
 	if (new_state && netif_msg_link(priv) && net_ratelimit())
-		phy_print_status(priv->phy);
+		phy_print_status(dev->phydev);
 
 	spin_unlock(&priv->lock);
 }
@@ -1016,8 +1009,8 @@ static int cpmac_open(struct net_device *dev)
 	cpmac_hw_start(dev);
 
 	napi_enable(&priv->napi);
-	priv->phy->state = PHY_CHANGELINK;
-	phy_start(priv->phy);
+	dev->phydev->state = PHY_CHANGELINK;
+	phy_start(dev->phydev);
 
 	return 0;
 
@@ -1053,7 +1046,7 @@ static int cpmac_stop(struct net_device *dev)
 
 	cancel_work_sync(&priv->reset_work);
 	napi_disable(&priv->napi);
-	phy_stop(priv->phy);
+	phy_stop(dev->phydev);
 
 	cpmac_hw_stop(dev);
 
@@ -1106,6 +1099,7 @@ static int cpmac_probe(struct platform_device *pdev)
 	struct cpmac_priv *priv;
 	struct net_device *dev;
 	struct plat_cpmac_data *pdata;
+	struct phy_device *phydev = NULL;
 
 	pdata = dev_get_platdata(&pdev->dev);
 
@@ -1162,14 +1156,14 @@ static int cpmac_probe(struct platform_device *pdev)
 	snprintf(priv->phy_name, MII_BUS_ID_SIZE, PHY_ID_FMT,
 						mdio_bus_id, phy_id);
 
-	priv->phy = phy_connect(dev, priv->phy_name, cpmac_adjust_link,
-				PHY_INTERFACE_MODE_MII);
+	phydev = phy_connect(dev, priv->phy_name, cpmac_adjust_link,
+			     PHY_INTERFACE_MODE_MII);
 
-	if (IS_ERR(priv->phy)) {
+	if (IS_ERR(phydev)) {
 		if (netif_msg_drv(priv))
 			dev_err(&pdev->dev, "Could not attach to PHY\n");
 
-		rc = PTR_ERR(priv->phy);
+		rc = PTR_ERR(phydev);
 		goto out;
 	}
 
-- 
1.7.4.4
