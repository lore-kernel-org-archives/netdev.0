From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/2] net: ethernet: dnet: use phydev from struct net_device
Date: Thu, 23 Jun 2016 23:48:58 +0200
Message-ID: <1466718539-6526-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: andrew@lunn.ch, davem@davemloft.net, f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The private structure contain a pointer to phydev, but the structure
net_device already contain such pointer. So we can remove the pointer
phydev in the private structure, and update the driver to use the
one contained in struct net_device.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/dnet.c |   28 ++++++++++++----------------
 drivers/net/ethernet/dnet.h |    1 -
 2 files changed, 12 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/dnet.c b/drivers/net/ethernet/dnet.c
index b69a9ea..9c6955f 100644
--- a/drivers/net/ethernet/dnet.c
+++ b/drivers/net/ethernet/dnet.c
@@ -173,7 +173,7 @@ static int dnet_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
 static void dnet_handle_link_change(struct net_device *dev)
 {
 	struct dnet *bp = netdev_priv(dev);
-	struct phy_device *phydev = bp->phy_dev;
+	struct phy_device *phydev = dev->phydev;
 	unsigned long flags;
 	u32 mode_reg, ctl_reg;
 
@@ -295,7 +295,6 @@ static int dnet_mii_probe(struct net_device *dev)
 	bp->link = 0;
 	bp->speed = 0;
 	bp->duplex = -1;
-	bp->phy_dev = phydev;
 
 	return 0;
 }
@@ -629,16 +628,16 @@ static int dnet_open(struct net_device *dev)
 	struct dnet *bp = netdev_priv(dev);
 
 	/* if the phy is not yet register, retry later */
-	if (!bp->phy_dev)
+	if (!dev->phydev)
 		return -EAGAIN;
 
 	napi_enable(&bp->napi);
 	dnet_init_hw(bp);
 
-	phy_start_aneg(bp->phy_dev);
+	phy_start_aneg(dev->phydev);
 
 	/* schedule a link state check */
-	phy_start(bp->phy_dev);
+	phy_start(dev->phydev);
 
 	netif_start_queue(dev);
 
@@ -652,8 +651,8 @@ static int dnet_close(struct net_device *dev)
 	netif_stop_queue(dev);
 	napi_disable(&bp->napi);
 
-	if (bp->phy_dev)
-		phy_stop(bp->phy_dev);
+	if (dev->phydev)
+		phy_stop(dev->phydev);
 
 	dnet_reset_hw(bp);
 	netif_carrier_off(dev);
@@ -733,8 +732,7 @@ static struct net_device_stats *dnet_get_stats(struct net_device *dev)
 
 static int dnet_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct dnet *bp = netdev_priv(dev);
-	struct phy_device *phydev = bp->phy_dev;
+	struct phy_device *phydev = dev->phydev;
 
 	if (!phydev)
 		return -ENODEV;
@@ -744,8 +742,7 @@ static int dnet_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 static int dnet_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct dnet *bp = netdev_priv(dev);
-	struct phy_device *phydev = bp->phy_dev;
+	struct phy_device *phydev = dev->phydev;
 
 	if (!phydev)
 		return -ENODEV;
@@ -755,8 +752,7 @@ static int dnet_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 static int dnet_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct dnet *bp = netdev_priv(dev);
-	struct phy_device *phydev = bp->phy_dev;
+	struct phy_device *phydev = dev->phydev;
 
 	if (!netif_running(dev))
 		return -EINVAL;
@@ -875,7 +871,7 @@ static int dnet_probe(struct platform_device *pdev)
 	       (bp->capabilities & DNET_HAS_IRQ) ? "" : "no ",
 	       (bp->capabilities & DNET_HAS_GIGABIT) ? "" : "no ",
 	       (bp->capabilities & DNET_HAS_DMA) ? "" : "no ");
-	phydev = bp->phy_dev;
+	phydev = dev->phydev;
 	phy_attached_info(phydev);
 
 	return 0;
@@ -899,8 +895,8 @@ static int dnet_remove(struct platform_device *pdev)
 
 	if (dev) {
 		bp = netdev_priv(dev);
-		if (bp->phy_dev)
-			phy_disconnect(bp->phy_dev);
+		if (dev->phydev)
+			phy_disconnect(dev->phydev);
 		mdiobus_unregister(bp->mii_bus);
 		mdiobus_free(bp->mii_bus);
 		unregister_netdev(dev);
diff --git a/drivers/net/ethernet/dnet.h b/drivers/net/ethernet/dnet.h
index 37f5b30..d985080 100644
--- a/drivers/net/ethernet/dnet.h
+++ b/drivers/net/ethernet/dnet.h
@@ -216,7 +216,6 @@ struct dnet {
 
 	/* PHY stuff */
 	struct mii_bus			*mii_bus;
-	struct phy_device		*phy_dev;
 	unsigned int			link;
 	unsigned int			speed;
 	unsigned int			duplex;
-- 
1.7.4.4
