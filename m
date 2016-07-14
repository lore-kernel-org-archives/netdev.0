From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/2] net: ethernet: tc35815: use phydev from struct net_device
Date: Thu, 14 Jul 2016 15:20:46 +0200
Message-ID: <1468502447-2254-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, andrew@lunn.ch, linux@roeck-us.net,
	colin.king@canonical.com, f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The private structure contain a pointer to phydev, but the structure
net_device already contain such pointer. So we can remove the pointer
phy in the private structure, and update the driver to use the
one contained in struct net_device.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/toshiba/tc35815.c |   45 ++++++++++++-------------------
 1 files changed, 18 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/toshiba/tc35815.c b/drivers/net/ethernet/toshiba/tc35815.c
index 74e6719..cdf8d58 100644
--- a/drivers/net/ethernet/toshiba/tc35815.c
+++ b/drivers/net/ethernet/toshiba/tc35815.c
@@ -405,7 +405,6 @@ struct tc35815_local {
 	spinlock_t rx_lock;
 
 	struct mii_bus *mii_bus;
-	struct phy_device *phy_dev;
 	int duplex;
 	int speed;
 	int link;
@@ -539,7 +538,7 @@ static int tc_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 val)
 static void tc_handle_link_change(struct net_device *dev)
 {
 	struct tc35815_local *lp = netdev_priv(dev);
-	struct phy_device *phydev = lp->phy_dev;
+	struct phy_device *phydev = dev->phydev;
 	unsigned long flags;
 	int status_change = 0;
 
@@ -645,7 +644,6 @@ static int tc_mii_probe(struct net_device *dev)
 	lp->link = 0;
 	lp->speed = 0;
 	lp->duplex = -1;
-	lp->phy_dev = phydev;
 
 	return 0;
 }
@@ -853,7 +851,7 @@ static void tc35815_remove_one(struct pci_dev *pdev)
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct tc35815_local *lp = netdev_priv(dev);
 
-	phy_disconnect(lp->phy_dev);
+	phy_disconnect(dev->phydev);
 	mdiobus_unregister(lp->mii_bus);
 	mdiobus_free(lp->mii_bus);
 	unregister_netdev(dev);
@@ -1143,8 +1141,8 @@ static void tc35815_restart(struct net_device *dev)
 	struct tc35815_local *lp = netdev_priv(dev);
 	int ret;
 
-	if (lp->phy_dev) {
-		ret = phy_init_hw(lp->phy_dev);
+	if (dev->phydev) {
+		ret = phy_init_hw(dev->phydev);
 		if (ret)
 			printk(KERN_ERR "%s: PHY init failed.\n", dev->name);
 	}
@@ -1236,7 +1234,7 @@ tc35815_open(struct net_device *dev)
 
 	netif_carrier_off(dev);
 	/* schedule a link state check */
-	phy_start(lp->phy_dev);
+	phy_start(dev->phydev);
 
 	/* We are now ready to accept transmit requeusts from
 	 * the queueing layer of the networking.
@@ -1819,8 +1817,8 @@ tc35815_close(struct net_device *dev)
 
 	netif_stop_queue(dev);
 	napi_disable(&lp->napi);
-	if (lp->phy_dev)
-		phy_stop(lp->phy_dev);
+	if (dev->phydev)
+		phy_stop(dev->phydev);
 	cancel_work_sync(&lp->restart_work);
 
 	/* Flush the Tx and disable Rx here. */
@@ -1948,20 +1946,16 @@ static void tc35815_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *
 
 static int tc35815_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct tc35815_local *lp = netdev_priv(dev);
-
-	if (!lp->phy_dev)
+	if (!dev->phydev)
 		return -ENODEV;
-	return phy_ethtool_gset(lp->phy_dev, cmd);
+	return phy_ethtool_gset(dev->phydev, cmd);
 }
 
 static int tc35815_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct tc35815_local *lp = netdev_priv(dev);
-
-	if (!lp->phy_dev)
+	if (!dev->phydev)
 		return -ENODEV;
-	return phy_ethtool_sset(lp->phy_dev, cmd);
+	return phy_ethtool_sset(dev->phydev, cmd);
 }
 
 static u32 tc35815_get_msglevel(struct net_device *dev)
@@ -2025,13 +2019,11 @@ static const struct ethtool_ops tc35815_ethtool_ops = {
 
 static int tc35815_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct tc35815_local *lp = netdev_priv(dev);
-
 	if (!netif_running(dev))
 		return -EINVAL;
-	if (!lp->phy_dev)
+	if (!dev->phydev)
 		return -ENODEV;
-	return phy_mii_ioctl(lp->phy_dev, rq, cmd);
+	return phy_mii_ioctl(dev->phydev, rq, cmd);
 }
 
 static void tc35815_chip_reset(struct net_device *dev)
@@ -2116,7 +2108,7 @@ static void tc35815_chip_init(struct net_device *dev)
 	if (lp->chiptype == TC35815_TX4939)
 		txctl &= ~Tx_EnLCarr;
 	/* WORKAROUND: ignore LostCrS in full duplex operation */
-	if (!lp->phy_dev || !lp->link || lp->duplex == DUPLEX_FULL)
+	if (!dev->phydev || !lp->link || lp->duplex == DUPLEX_FULL)
 		txctl &= ~Tx_EnLCarr;
 	tc_writel(txctl, &tr->Tx_Ctl);
 }
@@ -2132,8 +2124,8 @@ static int tc35815_suspend(struct pci_dev *pdev, pm_message_t state)
 	if (!netif_running(dev))
 		return 0;
 	netif_device_detach(dev);
-	if (lp->phy_dev)
-		phy_stop(lp->phy_dev);
+	if (dev->phydev)
+		phy_stop(dev->phydev);
 	spin_lock_irqsave(&lp->lock, flags);
 	tc35815_chip_reset(dev);
 	spin_unlock_irqrestore(&lp->lock, flags);
@@ -2144,7 +2136,6 @@ static int tc35815_suspend(struct pci_dev *pdev, pm_message_t state)
 static int tc35815_resume(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
-	struct tc35815_local *lp = netdev_priv(dev);
 
 	pci_restore_state(pdev);
 	if (!netif_running(dev))
@@ -2152,8 +2143,8 @@ static int tc35815_resume(struct pci_dev *pdev)
 	pci_set_power_state(pdev, PCI_D0);
 	tc35815_restart(dev);
 	netif_carrier_off(dev);
-	if (lp->phy_dev)
-		phy_start(lp->phy_dev);
+	if (dev->phydev)
+		phy_start(dev->phydev);
 	netif_device_attach(dev);
 	return 0;
 }
-- 
1.7.4.4
