From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/2] net: ethernet: smsc: smsc911x: use phydev from struct net_device
Date: Sun,  3 Jul 2016 01:14:20 +0200
Message-ID: <1467501261-8839-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, steve.glendinning@shawell.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The private structure contain a pointer to phydev, but the structure
net_device already contain such pointer. So we can remove the pointer
phy in the private structure, and update the driver to use the
one contained in struct net_device.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/smsc/smsc911x.c |   66 ++++++++++++++++------------------
 1 files changed, 31 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index b5ab5e1..6fded67 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -114,7 +114,6 @@ struct smsc911x_data {
 	/* spinlock to ensure register accesses are serialised */
 	spinlock_t dev_lock;
 
-	struct phy_device *phy_dev;
 	struct mii_bus *mii_bus;
 	unsigned int using_extphy;
 	int last_duplex;
@@ -833,7 +832,7 @@ static int smsc911x_phy_reset(struct smsc911x_data *pdata)
 static int smsc911x_phy_loopbacktest(struct net_device *dev)
 {
 	struct smsc911x_data *pdata = netdev_priv(dev);
-	struct phy_device *phy_dev = pdata->phy_dev;
+	struct phy_device *phy_dev = dev->phydev;
 	int result = -EIO;
 	unsigned int i, val;
 	unsigned long flags;
@@ -903,7 +902,8 @@ static int smsc911x_phy_loopbacktest(struct net_device *dev)
 
 static void smsc911x_phy_update_flowcontrol(struct smsc911x_data *pdata)
 {
-	struct phy_device *phy_dev = pdata->phy_dev;
+	struct net_device *ndev = pdata->dev;
+	struct phy_device *phy_dev = ndev->phydev;
 	u32 afc = smsc911x_reg_read(pdata, AFC_CFG);
 	u32 flow;
 	unsigned long flags;
@@ -944,7 +944,7 @@ static void smsc911x_phy_update_flowcontrol(struct smsc911x_data *pdata)
 static void smsc911x_phy_adjust_link(struct net_device *dev)
 {
 	struct smsc911x_data *pdata = netdev_priv(dev);
-	struct phy_device *phy_dev = pdata->phy_dev;
+	struct phy_device *phy_dev = dev->phydev;
 	unsigned long flags;
 	int carrier;
 
@@ -1037,7 +1037,6 @@ static int smsc911x_mii_probe(struct net_device *dev)
 			      SUPPORTED_Asym_Pause);
 	phydev->advertising = phydev->supported;
 
-	pdata->phy_dev = phydev;
 	pdata->last_duplex = -1;
 	pdata->last_carrier = -1;
 
@@ -1338,9 +1337,11 @@ static void smsc911x_rx_multicast_update_workaround(struct smsc911x_data *pdata)
 
 static int smsc911x_phy_general_power_up(struct smsc911x_data *pdata)
 {
+	struct net_device *ndev = pdata->dev;
+	struct phy_device *phy_dev = ndev->phydev;
 	int rc = 0;
 
-	if (!pdata->phy_dev)
+	if (!phy_dev)
 		return rc;
 
 	/* If the internal PHY is in General Power-Down mode, all, except the
@@ -1350,7 +1351,7 @@ static int smsc911x_phy_general_power_up(struct smsc911x_data *pdata)
 	 * In that case, clear the bit 0.11, so the PHY powers up and we can
 	 * access to the phy registers.
 	 */
-	rc = phy_read(pdata->phy_dev, MII_BMCR);
+	rc = phy_read(phy_dev, MII_BMCR);
 	if (rc < 0) {
 		SMSC_WARN(pdata, drv, "Failed reading PHY control reg");
 		return rc;
@@ -1360,7 +1361,7 @@ static int smsc911x_phy_general_power_up(struct smsc911x_data *pdata)
 	 * disable the general power down-mode.
 	 */
 	if (rc & BMCR_PDOWN) {
-		rc = phy_write(pdata->phy_dev, MII_BMCR, rc & ~BMCR_PDOWN);
+		rc = phy_write(phy_dev, MII_BMCR, rc & ~BMCR_PDOWN);
 		if (rc < 0) {
 			SMSC_WARN(pdata, drv, "Failed writing PHY control reg");
 			return rc;
@@ -1374,12 +1375,14 @@ static int smsc911x_phy_general_power_up(struct smsc911x_data *pdata)
 
 static int smsc911x_phy_disable_energy_detect(struct smsc911x_data *pdata)
 {
+	struct net_device *ndev = pdata->dev;
+	struct phy_device *phy_dev = ndev->phydev;
 	int rc = 0;
 
-	if (!pdata->phy_dev)
+	if (!phy_dev)
 		return rc;
 
-	rc = phy_read(pdata->phy_dev, MII_LAN83C185_CTRL_STATUS);
+	rc = phy_read(phy_dev, MII_LAN83C185_CTRL_STATUS);
 
 	if (rc < 0) {
 		SMSC_WARN(pdata, drv, "Failed reading PHY control reg");
@@ -1389,7 +1392,7 @@ static int smsc911x_phy_disable_energy_detect(struct smsc911x_data *pdata)
 	/* Only disable if energy detect mode is already enabled */
 	if (rc & MII_LAN83C185_EDPWRDOWN) {
 		/* Disable energy detect mode for this SMSC Transceivers */
-		rc = phy_write(pdata->phy_dev, MII_LAN83C185_CTRL_STATUS,
+		rc = phy_write(phy_dev, MII_LAN83C185_CTRL_STATUS,
 			       rc & (~MII_LAN83C185_EDPWRDOWN));
 
 		if (rc < 0) {
@@ -1405,12 +1408,14 @@ static int smsc911x_phy_disable_energy_detect(struct smsc911x_data *pdata)
 
 static int smsc911x_phy_enable_energy_detect(struct smsc911x_data *pdata)
 {
+	struct net_device *ndev = pdata->dev;
+	struct phy_device *phy_dev = ndev->phydev;
 	int rc = 0;
 
-	if (!pdata->phy_dev)
+	if (!phy_dev)
 		return rc;
 
-	rc = phy_read(pdata->phy_dev, MII_LAN83C185_CTRL_STATUS);
+	rc = phy_read(phy_dev, MII_LAN83C185_CTRL_STATUS);
 
 	if (rc < 0) {
 		SMSC_WARN(pdata, drv, "Failed reading PHY control reg");
@@ -1420,7 +1425,7 @@ static int smsc911x_phy_enable_energy_detect(struct smsc911x_data *pdata)
 	/* Only enable if energy detect mode is already disabled */
 	if (!(rc & MII_LAN83C185_EDPWRDOWN)) {
 		/* Enable energy detect mode for this SMSC Transceivers */
-		rc = phy_write(pdata->phy_dev, MII_LAN83C185_CTRL_STATUS,
+		rc = phy_write(phy_dev, MII_LAN83C185_CTRL_STATUS,
 			       rc | MII_LAN83C185_EDPWRDOWN);
 
 		if (rc < 0) {
@@ -1517,7 +1522,7 @@ static int smsc911x_open(struct net_device *dev)
 	unsigned int intcfg;
 
 	/* if the phy is not yet registered, retry later*/
-	if (!pdata->phy_dev) {
+	if (!dev->phydev) {
 		SMSC_WARN(pdata, hw, "phy_dev is NULL");
 		return -EAGAIN;
 	}
@@ -1608,7 +1613,7 @@ static int smsc911x_open(struct net_device *dev)
 	pdata->last_carrier = -1;
 
 	/* Bring the PHY up */
-	phy_start(pdata->phy_dev);
+	phy_start(dev->phydev);
 
 	temp = smsc911x_reg_read(pdata, HW_CFG);
 	/* Preserve TX FIFO size and external PHY configuration */
@@ -1663,8 +1668,8 @@ static int smsc911x_stop(struct net_device *dev)
 	smsc911x_tx_update_txcounters(dev);
 
 	/* Bring the PHY down */
-	if (pdata->phy_dev)
-		phy_stop(pdata->phy_dev);
+	if (dev->phydev)
+		phy_stop(dev->phydev);
 
 	SMSC_TRACE(pdata, ifdown, "Interface stopped");
 	return 0;
@@ -1904,30 +1909,24 @@ static int smsc911x_set_mac_address(struct net_device *dev, void *p)
 /* Standard ioctls for mii-tool */
 static int smsc911x_do_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
-	struct smsc911x_data *pdata = netdev_priv(dev);
-
-	if (!netif_running(dev) || !pdata->phy_dev)
+	if (!netif_running(dev) || !dev->phydev)
 		return -EINVAL;
 
-	return phy_mii_ioctl(pdata->phy_dev, ifr, cmd);
+	return phy_mii_ioctl(dev->phydev, ifr, cmd);
 }
 
 static int
 smsc911x_ethtool_getsettings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct smsc911x_data *pdata = netdev_priv(dev);
-
 	cmd->maxtxpkt = 1;
 	cmd->maxrxpkt = 1;
-	return phy_ethtool_gset(pdata->phy_dev, cmd);
+	return phy_ethtool_gset(dev->phydev, cmd);
 }
 
 static int
 smsc911x_ethtool_setsettings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct smsc911x_data *pdata = netdev_priv(dev);
-
-	return phy_ethtool_sset(pdata->phy_dev, cmd);
+	return phy_ethtool_sset(dev->phydev, cmd);
 }
 
 static void smsc911x_ethtool_getdrvinfo(struct net_device *dev,
@@ -1941,9 +1940,7 @@ static void smsc911x_ethtool_getdrvinfo(struct net_device *dev,
 
 static int smsc911x_ethtool_nwayreset(struct net_device *dev)
 {
-	struct smsc911x_data *pdata = netdev_priv(dev);
-
-	return phy_start_aneg(pdata->phy_dev);
+	return phy_start_aneg(dev->phydev);
 }
 
 static u32 smsc911x_ethtool_getmsglevel(struct net_device *dev)
@@ -1969,7 +1966,7 @@ smsc911x_ethtool_getregs(struct net_device *dev, struct ethtool_regs *regs,
 			 void *buf)
 {
 	struct smsc911x_data *pdata = netdev_priv(dev);
-	struct phy_device *phy_dev = pdata->phy_dev;
+	struct phy_device *phy_dev = dev->phydev;
 	unsigned long flags;
 	unsigned int i;
 	unsigned int j = 0;
@@ -2308,12 +2305,11 @@ static int smsc911x_drv_remove(struct platform_device *pdev)
 	pdata = netdev_priv(dev);
 	BUG_ON(!pdata);
 	BUG_ON(!pdata->ioaddr);
-	BUG_ON(!pdata->phy_dev);
+	BUG_ON(!dev->phydev);
 
 	SMSC_TRACE(pdata, ifdown, "Stopping driver");
 
-	phy_disconnect(pdata->phy_dev);
-	pdata->phy_dev = NULL;
+	phy_disconnect(dev->phydev);
 	mdiobus_unregister(pdata->mii_bus);
 	mdiobus_free(pdata->mii_bus);
 
-- 
1.7.4.4
