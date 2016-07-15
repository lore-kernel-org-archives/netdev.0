From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/2] net: ethernet: smsc9420: use phydev from struct net_device
Date: Fri, 15 Jul 2016 10:36:20 +0200
Message-ID: <1468571781-11136-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: steve.glendinning@shawell.net, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The private structure contain a pointer to phydev, but the structure
net_device already contain such pointer. So we can remove the pointer
phy in the private structure, and update the driver to use the
one contained in struct net_device.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/smsc/smsc9420.c |   44 +++++++++++++--------------------
 1 files changed, 17 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc9420.c b/drivers/net/ethernet/smsc/smsc9420.c
index 8594b9e..3e5f533 100644
--- a/drivers/net/ethernet/smsc/smsc9420.c
+++ b/drivers/net/ethernet/smsc/smsc9420.c
@@ -76,7 +76,6 @@ struct smsc9420_pdata {
 	bool rx_csum;
 	u32 msg_enable;
 
-	struct phy_device *phy_dev;
 	struct mii_bus *mii_bus;
 	int last_duplex;
 	int last_carrier;
@@ -226,36 +225,30 @@ static int smsc9420_eeprom_reload(struct smsc9420_pdata *pd)
 /* Standard ioctls for mii-tool */
 static int smsc9420_do_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
-	struct smsc9420_pdata *pd = netdev_priv(dev);
-
-	if (!netif_running(dev) || !pd->phy_dev)
+	if (!netif_running(dev) || !dev->phydev)
 		return -EINVAL;
 
-	return phy_mii_ioctl(pd->phy_dev, ifr, cmd);
+	return phy_mii_ioctl(dev->phydev, ifr, cmd);
 }
 
 static int smsc9420_ethtool_get_settings(struct net_device *dev,
 					 struct ethtool_cmd *cmd)
 {
-	struct smsc9420_pdata *pd = netdev_priv(dev);
-
-	if (!pd->phy_dev)
+	if (!dev->phydev)
 		return -ENODEV;
 
 	cmd->maxtxpkt = 1;
 	cmd->maxrxpkt = 1;
-	return phy_ethtool_gset(pd->phy_dev, cmd);
+	return phy_ethtool_gset(dev->phydev, cmd);
 }
 
 static int smsc9420_ethtool_set_settings(struct net_device *dev,
 					 struct ethtool_cmd *cmd)
 {
-	struct smsc9420_pdata *pd = netdev_priv(dev);
-
-	if (!pd->phy_dev)
+	if (!dev->phydev)
 		return -ENODEV;
 
-	return phy_ethtool_sset(pd->phy_dev, cmd);
+	return phy_ethtool_sset(dev->phydev, cmd);
 }
 
 static void smsc9420_ethtool_get_drvinfo(struct net_device *netdev,
@@ -283,12 +276,10 @@ static void smsc9420_ethtool_set_msglevel(struct net_device *netdev, u32 data)
 
 static int smsc9420_ethtool_nway_reset(struct net_device *netdev)
 {
-	struct smsc9420_pdata *pd = netdev_priv(netdev);
-
-	if (!pd->phy_dev)
+	if (!netdev->phydev)
 		return -ENODEV;
 
-	return phy_start_aneg(pd->phy_dev);
+	return phy_start_aneg(netdev->phydev);
 }
 
 static int smsc9420_ethtool_getregslen(struct net_device *dev)
@@ -302,7 +293,7 @@ smsc9420_ethtool_getregs(struct net_device *dev, struct ethtool_regs *regs,
 			 void *buf)
 {
 	struct smsc9420_pdata *pd = netdev_priv(dev);
-	struct phy_device *phy_dev = pd->phy_dev;
+	struct phy_device *phy_dev = dev->phydev;
 	unsigned int i, j = 0;
 	u32 *data = buf;
 
@@ -736,7 +727,7 @@ static int smsc9420_stop(struct net_device *dev)
 	ulong flags;
 
 	BUG_ON(!pd);
-	BUG_ON(!pd->phy_dev);
+	BUG_ON(!dev->phydev);
 
 	/* disable master interrupt */
 	spin_lock_irqsave(&pd->int_lock, flags);
@@ -757,10 +748,9 @@ static int smsc9420_stop(struct net_device *dev)
 
 	smsc9420_dmac_soft_reset(pd);
 
-	phy_stop(pd->phy_dev);
+	phy_stop(dev->phydev);
 
-	phy_disconnect(pd->phy_dev);
-	pd->phy_dev = NULL;
+	phy_disconnect(dev->phydev);
 	mdiobus_unregister(pd->mii_bus);
 	mdiobus_free(pd->mii_bus);
 
@@ -1093,7 +1083,8 @@ static void smsc9420_set_multicast_list(struct net_device *dev)
 
 static void smsc9420_phy_update_flowcontrol(struct smsc9420_pdata *pd)
 {
-	struct phy_device *phy_dev = pd->phy_dev;
+	struct net_device *dev = pd->dev;
+	struct phy_device *phy_dev = dev->phydev;
 	u32 flow;
 
 	if (phy_dev->duplex == DUPLEX_FULL) {
@@ -1122,7 +1113,7 @@ static void smsc9420_phy_update_flowcontrol(struct smsc9420_pdata *pd)
 static void smsc9420_phy_adjust_link(struct net_device *dev)
 {
 	struct smsc9420_pdata *pd = netdev_priv(dev);
-	struct phy_device *phy_dev = pd->phy_dev;
+	struct phy_device *phy_dev = dev->phydev;
 	int carrier;
 
 	if (phy_dev->duplex != pd->last_duplex) {
@@ -1155,7 +1146,7 @@ static int smsc9420_mii_probe(struct net_device *dev)
 	struct smsc9420_pdata *pd = netdev_priv(dev);
 	struct phy_device *phydev = NULL;
 
-	BUG_ON(pd->phy_dev);
+	BUG_ON(dev->phydev);
 
 	/* Device only supports internal PHY at address 1 */
 	phydev = mdiobus_get_phy(pd->mii_bus, 1);
@@ -1179,7 +1170,6 @@ static int smsc9420_mii_probe(struct net_device *dev)
 
 	phy_attached_info(phydev);
 
-	pd->phy_dev = phydev;
 	pd->last_duplex = -1;
 	pd->last_carrier = -1;
 
@@ -1440,7 +1430,7 @@ static int smsc9420_open(struct net_device *dev)
 	}
 
 	/* Bring the PHY up */
-	phy_start(pd->phy_dev);
+	phy_start(dev->phydev);
 
 	napi_enable(&pd->napi);
 
-- 
1.7.4.4
