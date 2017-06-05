From: Christian Lamparter <chunkeey@googlemail.com>
Subject: [PATCH v1 2/2] net: emac: fix and unify emac_mdio functions
Date: Mon,  5 Jun 2017 22:49:40 +0200
Message-ID: <18472d9a6bde3edaab7dcda301ccaebd437ea0dc.1496695540.git.chunkeey@googlemail.com>
References: <635dd014238af6f48c4169439b7ac161e80de1b7.1496695540.git.chunkeey@googlemail.com>
Cc: "David S . Miller" <davem@davemloft.net>,
        Ivan Mikhaylov <ivan@de.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36567 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751180AbdFEUtn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 16:49:43 -0400
Received: by mail-wm0-f65.google.com with SMTP id k15so31785178wmh.3
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 13:49:42 -0700 (PDT)
In-Reply-To: <635dd014238af6f48c4169439b7ac161e80de1b7.1496695540.git.chunkeey@googlemail.com>
In-Reply-To: <635dd014238af6f48c4169439b7ac161e80de1b7.1496695540.git.chunkeey@googlemail.com>
References: <635dd014238af6f48c4169439b7ac161e80de1b7.1496695540.git.chunkeey@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

emac_mdio_read_link() was not copying the requested phy settings
back into the emac driver's own phy api. This has caused a link
speed mismatch issue for the AR8035 as the emac driver kept
trying to connect with 10/100MBps on a 1GBit/s link.

This patch also unifies shared code between emac_setup_aneg()
and emac_mdio_setup_forced(). And furthermore it removes
a chunk of emac_mdio_init_phy(), that was copying the same
data into itself.

Signed-off-by: Christian Lamparter <chunkeey@googlemail.com>
---
 drivers/net/ethernet/ibm/emac/core.c | 41 ++++++++++++++++--------------------
 1 file changed, 18 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/ibm/emac/core.c b/drivers/net/ethernet/ibm/emac/core.c
index 18af1116fa1d..8cfb148cfdb0 100644
--- a/drivers/net/ethernet/ibm/emac/core.c
+++ b/drivers/net/ethernet/ibm/emac/core.c
@@ -2478,20 +2478,24 @@ static int emac_mii_bus_reset(struct mii_bus *bus)
 	return emac_reset(dev);
 }
 
+static int emac_mdio_phy_start_aneg(struct mii_phy *phy,
+				    struct phy_device *phy_dev)
+{
+	phy_dev->autoneg = phy->autoneg;
+	phy_dev->speed = phy->speed;
+	phy_dev->duplex = phy->duplex;
+	phy_dev->advertising = phy->advertising;
+	return phy_start_aneg(phy_dev);
+}
+
 static int emac_mdio_setup_aneg(struct mii_phy *phy, u32 advertise)
 {
 	struct net_device *ndev = phy->dev;
 	struct emac_instance *dev = netdev_priv(ndev);
 
-	dev->phy.autoneg = AUTONEG_ENABLE;
-	dev->phy.speed = SPEED_1000;
-	dev->phy.duplex = DUPLEX_FULL;
-	dev->phy.advertising = advertise;
 	phy->autoneg = AUTONEG_ENABLE;
-	phy->speed = dev->phy.speed;
-	phy->duplex = dev->phy.duplex;
 	phy->advertising = advertise;
-	return phy_start_aneg(dev->phy_dev);
+	return emac_mdio_phy_start_aneg(phy, dev->phy_dev);
 }
 
 static int emac_mdio_setup_forced(struct mii_phy *phy, int speed, int fd)
@@ -2499,13 +2503,10 @@ static int emac_mdio_setup_forced(struct mii_phy *phy, int speed, int fd)
 	struct net_device *ndev = phy->dev;
 	struct emac_instance *dev = netdev_priv(ndev);
 
-	dev->phy.autoneg =  AUTONEG_DISABLE;
-	dev->phy.speed = speed;
-	dev->phy.duplex = fd;
 	phy->autoneg = AUTONEG_DISABLE;
 	phy->speed = speed;
 	phy->duplex = fd;
-	return phy_start_aneg(dev->phy_dev);
+	return emac_mdio_phy_start_aneg(phy, dev->phy_dev);
 }
 
 static int emac_mdio_poll_link(struct mii_phy *phy)
@@ -2527,16 +2528,17 @@ static int emac_mdio_read_link(struct mii_phy *phy)
 {
 	struct net_device *ndev = phy->dev;
 	struct emac_instance *dev = netdev_priv(ndev);
+	struct phy_device *phy_dev = dev->phy_dev;
 	int res;
 
-	res = phy_read_status(dev->phy_dev);
+	res = phy_read_status(phy_dev);
 	if (res)
 		return res;
 
-	dev->phy.speed = phy->speed;
-	dev->phy.duplex = phy->duplex;
-	dev->phy.pause = phy->pause;
-	dev->phy.asym_pause = phy->asym_pause;
+	phy->speed = phy_dev->speed;
+	phy->duplex = phy_dev->duplex;
+	phy->pause = phy_dev->pause;
+	phy->asym_pause = phy_dev->asym_pause;
 	return 0;
 }
 
@@ -2546,13 +2548,6 @@ static int emac_mdio_init_phy(struct mii_phy *phy)
 	struct emac_instance *dev = netdev_priv(ndev);
 
 	phy_start(dev->phy_dev);
-	dev->phy.autoneg = phy->autoneg;
-	dev->phy.speed = phy->speed;
-	dev->phy.duplex = phy->duplex;
-	dev->phy.advertising = phy->advertising;
-	dev->phy.pause = phy->pause;
-	dev->phy.asym_pause = phy->asym_pause;
-
 	return phy_init_hw(dev->phy_dev);
 }
 
-- 
2.11.0
