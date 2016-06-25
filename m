From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/2] net: ethernet: r6040: use phydev from struct net_device
Date: Sat, 25 Jun 2016 21:09:01 +0200
Message-ID: <1466881742-13414-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: florian@openwrt.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The private structure contain a pointer to phydev, but the structure
net_device already contain such pointer. So we can remove the pointer
phydev in the private structure, and update the driver to use the
one contained in struct net_device.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/rdc/r6040.c |   22 +++++++---------------
 1 files changed, 7 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index 6b541e5..f2bc7b0 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -200,7 +200,6 @@ struct r6040_private {
 	struct mii_bus *mii_bus;
 	struct napi_struct napi;
 	void __iomem *base;
-	struct phy_device *phydev;
 	int old_link;
 	int old_duplex;
 };
@@ -474,7 +473,7 @@ static void r6040_down(struct net_device *dev)
 	iowrite16(adrp[1], ioaddr + MID_0M);
 	iowrite16(adrp[2], ioaddr + MID_0H);
 
-	phy_stop(lp->phydev);
+	phy_stop(dev->phydev);
 }
 
 static int r6040_close(struct net_device *dev)
@@ -515,12 +514,10 @@ static int r6040_close(struct net_device *dev)
 
 static int r6040_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct r6040_private *lp = netdev_priv(dev);
-
-	if (!lp->phydev)
+	if (!dev->phydev)
 		return -EINVAL;
 
-	return phy_mii_ioctl(lp->phydev, rq, cmd);
+	return phy_mii_ioctl(dev->phydev, rq, cmd);
 }
 
 static int r6040_rx(struct net_device *dev, int limit)
@@ -732,7 +729,7 @@ static int r6040_up(struct net_device *dev)
 	/* Initialize all MAC registers */
 	r6040_init_mac_regs(dev);
 
-	phy_start(lp->phydev);
+	phy_start(dev->phydev);
 
 	return 0;
 }
@@ -959,16 +956,12 @@ static void netdev_get_drvinfo(struct net_device *dev,
 
 static int netdev_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct r6040_private *rp = netdev_priv(dev);
-
-	return  phy_ethtool_gset(rp->phydev, cmd);
+	return  phy_ethtool_gset(dev->phydev, cmd);
 }
 
 static int netdev_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct r6040_private *rp = netdev_priv(dev);
-
-	return phy_ethtool_sset(rp->phydev, cmd);
+	return phy_ethtool_sset(dev->phydev, cmd);
 }
 
 static const struct ethtool_ops netdev_ethtool_ops = {
@@ -998,7 +991,7 @@ static const struct net_device_ops r6040_netdev_ops = {
 static void r6040_adjust_link(struct net_device *dev)
 {
 	struct r6040_private *lp = netdev_priv(dev);
-	struct phy_device *phydev = lp->phydev;
+	struct phy_device *phydev = dev->phydev;
 	int status_changed = 0;
 	void __iomem *ioaddr = lp->base;
 
@@ -1057,7 +1050,6 @@ static int r6040_mii_probe(struct net_device *dev)
 				| SUPPORTED_TP);
 
 	phydev->advertising = phydev->supported;
-	lp->phydev = phydev;
 	lp->old_link = 0;
 	lp->old_duplex = -1;
 
-- 
1.7.4.4
