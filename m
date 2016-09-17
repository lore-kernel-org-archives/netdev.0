From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/2] net: ethernet: broadcom: b44: use phydev from struct net_device
Date: Sun, 18 Sep 2016 00:11:34 +0200
Message-ID: <1474150295-24622-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: zambrano@broadcom.com, davem@davemloft.net, f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The private structure contain a pointer to phydev, but the structure
net_device already contain such pointer. So we can remove the pointer
phydev in the private structure, and update the driver to use the
one contained in struct net_device.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/broadcom/b44.c |   22 +++++++++++-----------
 drivers/net/ethernet/broadcom/b44.h |    1 -
 2 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
index 74f0a37..936f06f 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -1486,7 +1486,7 @@ static int b44_open(struct net_device *dev)
 	b44_enable_ints(bp);
 
 	if (bp->flags & B44_FLAG_EXTERNAL_PHY)
-		phy_start(bp->phydev);
+		phy_start(dev->phydev);
 
 	netif_start_queue(dev);
 out:
@@ -1651,7 +1651,7 @@ static int b44_close(struct net_device *dev)
 	netif_stop_queue(dev);
 
 	if (bp->flags & B44_FLAG_EXTERNAL_PHY)
-		phy_stop(bp->phydev);
+		phy_stop(dev->phydev);
 
 	napi_disable(&bp->napi);
 
@@ -1837,8 +1837,8 @@ static int b44_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	struct b44 *bp = netdev_priv(dev);
 
 	if (bp->flags & B44_FLAG_EXTERNAL_PHY) {
-		BUG_ON(!bp->phydev);
-		return phy_ethtool_gset(bp->phydev, cmd);
+		BUG_ON(!dev->phydev);
+		return phy_ethtool_gset(dev->phydev, cmd);
 	}
 
 	cmd->supported = (SUPPORTED_Autoneg);
@@ -1886,12 +1886,12 @@ static int b44_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	int ret;
 
 	if (bp->flags & B44_FLAG_EXTERNAL_PHY) {
-		BUG_ON(!bp->phydev);
+		BUG_ON(!dev->phydev);
 		spin_lock_irq(&bp->lock);
 		if (netif_running(dev))
 			b44_setup_phy(bp);
 
-		ret = phy_ethtool_sset(bp->phydev, cmd);
+		ret = phy_ethtool_sset(dev->phydev, cmd);
 
 		spin_unlock_irq(&bp->lock);
 
@@ -2137,8 +2137,8 @@ static int b44_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 
 	spin_lock_irq(&bp->lock);
 	if (bp->flags & B44_FLAG_EXTERNAL_PHY) {
-		BUG_ON(!bp->phydev);
-		err = phy_mii_ioctl(bp->phydev, ifr, cmd);
+		BUG_ON(!dev->phydev);
+		err = phy_mii_ioctl(dev->phydev, ifr, cmd);
 	} else {
 		err = generic_mii_ioctl(&bp->mii_if, if_mii(ifr), cmd, NULL);
 	}
@@ -2206,7 +2206,7 @@ static const struct net_device_ops b44_netdev_ops = {
 static void b44_adjust_link(struct net_device *dev)
 {
 	struct b44 *bp = netdev_priv(dev);
-	struct phy_device *phydev = bp->phydev;
+	struct phy_device *phydev = dev->phydev;
 	bool status_changed = 0;
 
 	BUG_ON(!phydev);
@@ -2303,7 +2303,6 @@ static int b44_register_phy_one(struct b44 *bp)
 			      SUPPORTED_MII);
 	phydev->advertising = phydev->supported;
 
-	bp->phydev = phydev;
 	bp->old_link = 0;
 	bp->phy_addr = phydev->mdio.addr;
 
@@ -2323,9 +2322,10 @@ err_out:
 
 static void b44_unregister_phy_one(struct b44 *bp)
 {
+	struct net_device *dev = bp->dev;
 	struct mii_bus *mii_bus = bp->mii_bus;
 
-	phy_disconnect(bp->phydev);
+	phy_disconnect(dev->phydev);
 	mdiobus_unregister(mii_bus);
 	mdiobus_free(mii_bus);
 }
diff --git a/drivers/net/ethernet/broadcom/b44.h b/drivers/net/ethernet/broadcom/b44.h
index 65d88d7..89d2cf3 100644
--- a/drivers/net/ethernet/broadcom/b44.h
+++ b/drivers/net/ethernet/broadcom/b44.h
@@ -404,7 +404,6 @@ struct b44 {
 	u32			tx_pending;
 	u8			phy_addr;
 	u8			force_copybreak;
-	struct phy_device	*phydev;
 	struct mii_bus		*mii_bus;
 	int			old_link;
 	struct mii_if_info	mii_if;
-- 
1.7.4.4
