From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/2] net: ethernet: greth: use phydev from struct net_device
Date: Sat, 30 Jul 2016 16:22:05 +0200
Message-ID: <1469888526-8089-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: andreas@gaisler.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34778 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919AbcG3OWO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jul 2016 10:22:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The private structure contain a pointer to phydev, but the structure
net_device already contain such pointer. So we can remove the pointer
phy in the private structure, and update the driver to use the
one contained in struct net_device.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/aeroflex/greth.c |   23 +++++++++++------------
 drivers/net/ethernet/aeroflex/greth.h |    1 -
 2 files changed, 11 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/aeroflex/greth.c b/drivers/net/ethernet/aeroflex/greth.c
index bca07c5..010978b 100644
--- a/drivers/net/ethernet/aeroflex/greth.c
+++ b/drivers/net/ethernet/aeroflex/greth.c
@@ -1107,8 +1107,7 @@ static void greth_set_msglevel(struct net_device *dev, u32 value)
 }
 static int greth_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct greth_private *greth = netdev_priv(dev);
-	struct phy_device *phy = greth->phy;
+	struct phy_device *phy = dev->phydev;
 
 	if (!phy)
 		return -ENODEV;
@@ -1118,8 +1117,7 @@ static int greth_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 static int greth_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct greth_private *greth = netdev_priv(dev);
-	struct phy_device *phy = greth->phy;
+	struct phy_device *phy = dev->phydev;
 
 	if (!phy)
 		return -ENODEV;
@@ -1224,7 +1222,7 @@ static int greth_mdio_write(struct mii_bus *bus, int phy, int reg, u16 val)
 static void greth_link_change(struct net_device *dev)
 {
 	struct greth_private *greth = netdev_priv(dev);
-	struct phy_device *phydev = greth->phy;
+	struct phy_device *phydev = dev->phydev;
 	unsigned long flags;
 	int status_change = 0;
 	u32 ctrl;
@@ -1307,7 +1305,6 @@ static int greth_mdio_probe(struct net_device *dev)
 	greth->link = 0;
 	greth->speed = 0;
 	greth->duplex = -1;
-	greth->phy = phy;
 
 	return 0;
 }
@@ -1325,6 +1322,7 @@ static int greth_mdio_init(struct greth_private *greth)
 {
 	int ret;
 	unsigned long timeout;
+	struct net_device *ndev = greth->netdev;
 
 	greth->mdio = mdiobus_alloc();
 	if (!greth->mdio) {
@@ -1349,15 +1347,16 @@ static int greth_mdio_init(struct greth_private *greth)
 		goto unreg_mdio;
 	}
 
-	phy_start(greth->phy);
+	phy_start(ndev->phydev);
 
 	/* If Ethernet debug link is used make autoneg happen right away */
 	if (greth->edcl && greth_edcl == 1) {
-		phy_start_aneg(greth->phy);
+		phy_start_aneg(ndev->phydev);
 		timeout = jiffies + 6*HZ;
-		while (!phy_aneg_done(greth->phy) && time_before(jiffies, timeout)) {
+		while (!phy_aneg_done(ndev->phydev) &&
+		       time_before(jiffies, timeout)) {
 		}
-		phy_read_status(greth->phy);
+		phy_read_status(ndev->phydev);
 		greth_link_change(greth->netdev);
 	}
 
@@ -1569,8 +1568,8 @@ static int greth_of_remove(struct platform_device *of_dev)
 
 	dma_free_coherent(&of_dev->dev, 1024, greth->tx_bd_base, greth->tx_bd_base_phys);
 
-	if (greth->phy)
-		phy_stop(greth->phy);
+	if (ndev->phydev)
+		phy_stop(ndev->phydev);
 	mdiobus_unregister(greth->mdio);
 
 	unregister_netdev(ndev);
diff --git a/drivers/net/ethernet/aeroflex/greth.h b/drivers/net/ethernet/aeroflex/greth.h
index 92dd918..9c07140 100644
--- a/drivers/net/ethernet/aeroflex/greth.h
+++ b/drivers/net/ethernet/aeroflex/greth.h
@@ -123,7 +123,6 @@ struct greth_private {
 	struct napi_struct napi;
 	spinlock_t devlock;
 
-	struct phy_device *phy;
 	struct mii_bus *mdio;
 	unsigned int link;
 	unsigned int speed;
-- 
1.7.4.4
