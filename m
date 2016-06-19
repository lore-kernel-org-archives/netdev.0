From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/2] net: ethernet: bgmac: use phydev from struct net_device
Date: Sun, 19 Jun 2016 22:37:05 +0200
Message-ID: <1466368626-28985-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, f.fainelli@gmail.com, zajec5@gmail.com,
	fabio.estevam@freescale.com, jkosina@suse.cz, andrew@lunn.ch,
	nbd@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35388 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751364AbcFSUj2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2016 16:39:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The private structure contain a pointer to phydev, but the structure
net_device already contain such pointer. So we can remove the pointer
phydev in the private structure, and update the driver to use the
one contained in struct net_device.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/broadcom/bgmac.c |   17 ++++++-----------
 drivers/net/ethernet/broadcom/bgmac.h |    1 -
 2 files changed, 6 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index 0ee34cc..90ed244 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -1320,7 +1320,7 @@ static int bgmac_open(struct net_device *net_dev)
 	}
 	napi_enable(&bgmac->napi);
 
-	phy_start(bgmac->phy_dev);
+	phy_start(net_dev->phydev);
 
 	netif_carrier_on(net_dev);
 	return 0;
@@ -1332,7 +1332,7 @@ static int bgmac_stop(struct net_device *net_dev)
 
 	netif_carrier_off(net_dev);
 
-	phy_stop(bgmac->phy_dev);
+	phy_stop(net_dev->phydev);
 
 	napi_disable(&bgmac->napi);
 	bgmac_chip_intrs_off(bgmac);
@@ -1370,12 +1370,10 @@ static int bgmac_set_mac_address(struct net_device *net_dev, void *addr)
 
 static int bgmac_ioctl(struct net_device *net_dev, struct ifreq *ifr, int cmd)
 {
-	struct bgmac *bgmac = netdev_priv(net_dev);
-
 	if (!netif_running(net_dev))
 		return -EINVAL;
 
-	return phy_mii_ioctl(bgmac->phy_dev, ifr, cmd);
+	return phy_mii_ioctl(net_dev->phydev, ifr, cmd);
 }
 
 static const struct net_device_ops bgmac_netdev_ops = {
@@ -1518,7 +1516,7 @@ static int bgmac_get_settings(struct net_device *net_dev,
 {
 	struct bgmac *bgmac = netdev_priv(net_dev);
 
-	return phy_ethtool_gset(bgmac->phy_dev, cmd);
+	return phy_ethtool_gset(net_dev->phydev, cmd);
 }
 
 static int bgmac_set_settings(struct net_device *net_dev,
@@ -1526,7 +1524,7 @@ static int bgmac_set_settings(struct net_device *net_dev,
 {
 	struct bgmac *bgmac = netdev_priv(net_dev);
 
-	return phy_ethtool_sset(bgmac->phy_dev, cmd);
+	return phy_ethtool_sset(net_dev->phydev, cmd);
 }
 
 static void bgmac_get_drvinfo(struct net_device *net_dev,
@@ -1563,7 +1561,7 @@ static int bgmac_mii_write(struct mii_bus *bus, int mii_id, int regnum,
 static void bgmac_adjust_link(struct net_device *net_dev)
 {
 	struct bgmac *bgmac = netdev_priv(net_dev);
-	struct phy_device *phy_dev = bgmac->phy_dev;
+	struct phy_device *phy_dev = net_dev->phydev;
 	bool update = false;
 
 	if (phy_dev->link) {
@@ -1607,8 +1605,6 @@ static int bgmac_fixed_phy_register(struct bgmac *bgmac)
 		return err;
 	}
 
-	bgmac->phy_dev = phy_dev;
-
 	return err;
 }
 
@@ -1653,7 +1649,6 @@ static int bgmac_mii_register(struct bgmac *bgmac)
 		err = PTR_ERR(phy_dev);
 		goto err_unregister_bus;
 	}
-	bgmac->phy_dev = phy_dev;
 
 	return err;
 
diff --git a/drivers/net/ethernet/broadcom/bgmac.h b/drivers/net/ethernet/broadcom/bgmac.h
index 853d72b..99beb18 100644
--- a/drivers/net/ethernet/broadcom/bgmac.h
+++ b/drivers/net/ethernet/broadcom/bgmac.h
@@ -441,7 +441,6 @@ struct bgmac {
 	struct net_device *net_dev;
 	struct napi_struct napi;
 	struct mii_bus *mii_bus;
-	struct phy_device *phy_dev;
 
 	/* DMA */
 	struct bgmac_dma_ring tx_ring[BGMAC_MAX_TX_RINGS];
-- 
1.7.4.4
