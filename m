From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/2] net: ethernet: adi: bfin_mac: use phydev from struct net_device
Date: Sun, 17 Jul 2016 01:10:14 +0200
Message-ID: <1468710615-31951-1-git-send-email-tremyfr@gmail.com>
Cc: adi-buildroot-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, andrew@lunn.ch, sudipm.mukherjee@gmail.com,
	mugunthanvnm@ti.com, felipe.balbi@linux.intel.com,
	treding@nvidia.com, fw@strlen.de, linux@roeck-us.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The private structure contain a pointer to phydev, but the structure
net_device already contain such pointer. So we can remove the pointer
phydev in the private structure, and update the driver to use the
one contained in struct net_device.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/adi/bfin_mac.c |   31 ++++++++++++-------------------
 drivers/net/ethernet/adi/bfin_mac.h |    1 -
 2 files changed, 12 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index 3d2245f..32af9d2 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -310,7 +310,7 @@ static int bfin_mdiobus_write(struct mii_bus *bus, int phy_addr, int regnum,
 static void bfin_mac_adjust_link(struct net_device *dev)
 {
 	struct bfin_mac_local *lp = netdev_priv(dev);
-	struct phy_device *phydev = lp->phydev;
+	struct phy_device *phydev = dev->phydev;
 	unsigned long flags;
 	int new_state = 0;
 
@@ -430,7 +430,6 @@ static int mii_probe(struct net_device *dev, int phy_mode)
 	lp->old_link = 0;
 	lp->old_speed = 0;
 	lp->old_duplex = -1;
-	lp->phydev = phydev;
 
 	phy_attached_print(phydev, "mdc_clk=%dHz(mdc_div=%d)@sclk=%dMHz)\n",
 			   MDC_CLK, mdc_div, sclk / 1000000);
@@ -453,10 +452,8 @@ static irqreturn_t bfin_mac_wake_interrupt(int irq, void *dev_id)
 static int
 bfin_mac_ethtool_getsettings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct bfin_mac_local *lp = netdev_priv(dev);
-
-	if (lp->phydev)
-		return phy_ethtool_gset(lp->phydev, cmd);
+	if (dev->phydev)
+		return phy_ethtool_gset(dev->phydev, cmd);
 
 	return -EINVAL;
 }
@@ -464,13 +461,11 @@ bfin_mac_ethtool_getsettings(struct net_device *dev, struct ethtool_cmd *cmd)
 static int
 bfin_mac_ethtool_setsettings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct bfin_mac_local *lp = netdev_priv(dev);
-
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
 
-	if (lp->phydev)
-		return phy_ethtool_sset(lp->phydev, cmd);
+	if (dev->phydev)
+		return phy_ethtool_sset(dev->phydev, cmd);
 
 	return -EINVAL;
 }
@@ -1427,7 +1422,7 @@ static void bfin_mac_timeout(struct net_device *dev)
 	if (netif_queue_stopped(dev))
 		netif_wake_queue(dev);
 
-	bfin_mac_enable(lp->phydev);
+	bfin_mac_enable(dev->phydev);
 
 	/* We can accept TX packets again */
 	netif_trans_update(dev); /* prevent tx timeout */
@@ -1491,8 +1486,6 @@ static void bfin_mac_set_multicast_list(struct net_device *dev)
 
 static int bfin_mac_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 {
-	struct bfin_mac_local *lp = netdev_priv(netdev);
-
 	if (!netif_running(netdev))
 		return -EINVAL;
 
@@ -1502,8 +1495,8 @@ static int bfin_mac_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 	case SIOCGHWTSTAMP:
 		return bfin_mac_hwtstamp_get(netdev, ifr);
 	default:
-		if (lp->phydev)
-			return phy_mii_ioctl(lp->phydev, ifr, cmd);
+		if (netdev->phydev)
+			return phy_mii_ioctl(netdev->phydev, ifr, cmd);
 		else
 			return -EOPNOTSUPP;
 	}
@@ -1547,12 +1540,12 @@ static int bfin_mac_open(struct net_device *dev)
 	if (ret)
 		return ret;
 
-	phy_start(lp->phydev);
+	phy_start(dev->phydev);
 	setup_system_regs(dev);
 	setup_mac_addr(dev->dev_addr);
 
 	bfin_mac_disable();
-	ret = bfin_mac_enable(lp->phydev);
+	ret = bfin_mac_enable(dev->phydev);
 	if (ret)
 		return ret;
 	pr_debug("hardware init finished\n");
@@ -1578,8 +1571,8 @@ static int bfin_mac_close(struct net_device *dev)
 	napi_disable(&lp->napi);
 	netif_carrier_off(dev);
 
-	phy_stop(lp->phydev);
-	phy_write(lp->phydev, MII_BMCR, BMCR_PDOWN);
+	phy_stop(dev->phydev);
+	phy_write(dev->phydev, MII_BMCR, BMCR_PDOWN);
 
 	/* clear everything */
 	bfin_mac_shutdown(dev);
diff --git a/drivers/net/ethernet/adi/bfin_mac.h b/drivers/net/ethernet/adi/bfin_mac.h
index d1217db..8c3b561 100644
--- a/drivers/net/ethernet/adi/bfin_mac.h
+++ b/drivers/net/ethernet/adi/bfin_mac.h
@@ -92,7 +92,6 @@ struct bfin_mac_local {
 	int old_speed;
 	int old_duplex;
 
-	struct phy_device *phydev;
 	struct mii_bus *mii_bus;
 
 #if defined(CONFIG_BFIN_MAC_USE_HWSTAMP)
-- 
1.7.4.4
