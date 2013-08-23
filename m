From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [RFC] b44: use phylib
Date: Sat, 24 Aug 2013 00:56:48 +0200
Message-ID: <1377298608-18016-1-git-send-email-hauke@hauke-m.de>
Cc: netdev@vger.kernel.org, Hauke Mehrtens <hauke@hauke-m.de>,
	Florian Fainelli <florian@openwrt.org>
To: zambrano@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:51363 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753610Ab3HWW5F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Aug 2013 18:57:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This splits the driver into the mac and a phy driver. On routers where
this driver is used we have a switch which implements a phy and can be
controlled by a phy driver.

I have just tested this on my router with a switch as phy and not on normal desktop PC.

This is based on a patch by Florian Fainelli <florian@openwrt.org>

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
Cc: Florian Fainelli <florian@openwrt.org>
---
 drivers/net/ethernet/broadcom/Kconfig |    1 +
 drivers/net/ethernet/broadcom/b44.c   |  217 ++++++++++++++++++---------------
 drivers/net/ethernet/broadcom/b44.h   |    5 +-
 3 files changed, 126 insertions(+), 97 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/Kconfig b/drivers/net/ethernet/broadcom/Kconfig
index 2fa5b86..3f97d9f 100644
--- a/drivers/net/ethernet/broadcom/Kconfig
+++ b/drivers/net/ethernet/broadcom/Kconfig
@@ -23,6 +23,7 @@ config B44
 	depends on SSB_POSSIBLE && HAS_DMA
 	select SSB
 	select MII
+	select PHYLIB
 	---help---
 	  If you have a network (Ethernet) controller of this type, say Y
 	  or M and read the Ethernet-HOWTO, available from
diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
index 9b017d9..4c741d7 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -29,6 +29,7 @@
 #include <linux/dma-mapping.h>
 #include <linux/ssb/ssb.h>
 #include <linux/slab.h>
+#include <linux/phy.h>
 
 #include <asm/uaccess.h>
 #include <asm/io.h>
@@ -299,21 +300,23 @@ static inline int b44_writephy(struct b44 *bp, int reg, u32 val)
 }
 
 /* miilib interface */
-static int b44_mii_read(struct net_device *dev, int phy_id, int location)
+static int b44_mii_read(struct mii_bus *bus, int phy_id, int location)
 {
 	u32 val;
-	struct b44 *bp = netdev_priv(dev);
+	struct b44 *bp = bus->priv;
 	int rc = __b44_readphy(bp, phy_id, location, &val);
 	if (rc)
 		return 0xffffffff;
 	return val;
 }
 
-static void b44_mii_write(struct net_device *dev, int phy_id, int location,
-			 int val)
+static int b44_mii_write(struct mii_bus *bus, int phy_id, int location,
+			 u16 val)
 {
-	struct b44 *bp = netdev_priv(dev);
+	struct b44 *bp = bus->priv;
 	__b44_writephy(bp, phy_id, location, val);
+
+	return 0;
 }
 
 static int b44_phy_reset(struct b44 *bp)
@@ -1795,102 +1798,24 @@ static int b44_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct b44 *bp = netdev_priv(dev);
 
-	cmd->supported = (SUPPORTED_Autoneg);
-	cmd->supported |= (SUPPORTED_100baseT_Half |
-			  SUPPORTED_100baseT_Full |
-			  SUPPORTED_10baseT_Half |
-			  SUPPORTED_10baseT_Full |
-			  SUPPORTED_MII);
-
-	cmd->advertising = 0;
-	if (bp->flags & B44_FLAG_ADV_10HALF)
-		cmd->advertising |= ADVERTISED_10baseT_Half;
-	if (bp->flags & B44_FLAG_ADV_10FULL)
-		cmd->advertising |= ADVERTISED_10baseT_Full;
-	if (bp->flags & B44_FLAG_ADV_100HALF)
-		cmd->advertising |= ADVERTISED_100baseT_Half;
-	if (bp->flags & B44_FLAG_ADV_100FULL)
-		cmd->advertising |= ADVERTISED_100baseT_Full;
-	cmd->advertising |= ADVERTISED_Pause | ADVERTISED_Asym_Pause;
-	ethtool_cmd_speed_set(cmd, ((bp->flags & B44_FLAG_100_BASE_T) ?
-				    SPEED_100 : SPEED_10));
-	cmd->duplex = (bp->flags & B44_FLAG_FULL_DUPLEX) ?
-		DUPLEX_FULL : DUPLEX_HALF;
-	cmd->port = 0;
-	cmd->phy_address = bp->phy_addr;
-	cmd->transceiver = (bp->flags & B44_FLAG_INTERNAL_PHY) ?
-		XCVR_INTERNAL : XCVR_EXTERNAL;
-	cmd->autoneg = (bp->flags & B44_FLAG_FORCE_LINK) ?
-		AUTONEG_DISABLE : AUTONEG_ENABLE;
-	if (cmd->autoneg == AUTONEG_ENABLE)
-		cmd->advertising |= ADVERTISED_Autoneg;
-	if (!netif_running(dev)){
-		ethtool_cmd_speed_set(cmd, 0);
-		cmd->duplex = 0xff;
-	}
-	cmd->maxtxpkt = 0;
-	cmd->maxrxpkt = 0;
-	return 0;
+	return phy_ethtool_gset(bp->phydev, cmd);
 }
 
 static int b44_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct b44 *bp = netdev_priv(dev);
-	u32 speed = ethtool_cmd_speed(cmd);
-
-	/* We do not support gigabit. */
-	if (cmd->autoneg == AUTONEG_ENABLE) {
-		if (cmd->advertising &
-		    (ADVERTISED_1000baseT_Half |
-		     ADVERTISED_1000baseT_Full))
-			return -EINVAL;
-	} else if ((speed != SPEED_100 &&
-		    speed != SPEED_10) ||
-		   (cmd->duplex != DUPLEX_HALF &&
-		    cmd->duplex != DUPLEX_FULL)) {
-			return -EINVAL;
-	}
+	int ret;
 
 	spin_lock_irq(&bp->lock);
 
-	if (cmd->autoneg == AUTONEG_ENABLE) {
-		bp->flags &= ~(B44_FLAG_FORCE_LINK |
-			       B44_FLAG_100_BASE_T |
-			       B44_FLAG_FULL_DUPLEX |
-			       B44_FLAG_ADV_10HALF |
-			       B44_FLAG_ADV_10FULL |
-			       B44_FLAG_ADV_100HALF |
-			       B44_FLAG_ADV_100FULL);
-		if (cmd->advertising == 0) {
-			bp->flags |= (B44_FLAG_ADV_10HALF |
-				      B44_FLAG_ADV_10FULL |
-				      B44_FLAG_ADV_100HALF |
-				      B44_FLAG_ADV_100FULL);
-		} else {
-			if (cmd->advertising & ADVERTISED_10baseT_Half)
-				bp->flags |= B44_FLAG_ADV_10HALF;
-			if (cmd->advertising & ADVERTISED_10baseT_Full)
-				bp->flags |= B44_FLAG_ADV_10FULL;
-			if (cmd->advertising & ADVERTISED_100baseT_Half)
-				bp->flags |= B44_FLAG_ADV_100HALF;
-			if (cmd->advertising & ADVERTISED_100baseT_Full)
-				bp->flags |= B44_FLAG_ADV_100FULL;
-		}
-	} else {
-		bp->flags |= B44_FLAG_FORCE_LINK;
-		bp->flags &= ~(B44_FLAG_100_BASE_T | B44_FLAG_FULL_DUPLEX);
-		if (speed == SPEED_100)
-			bp->flags |= B44_FLAG_100_BASE_T;
-		if (cmd->duplex == DUPLEX_FULL)
-			bp->flags |= B44_FLAG_FULL_DUPLEX;
-	}
-
 	if (netif_running(dev))
 		b44_setup_phy(bp);
 
+	ret = phy_ethtool_sset(bp->phydev, cmd);
+
 	spin_unlock_irq(&bp->lock);
 
-	return 0;
+	return ret;
 }
 
 static void b44_get_ringparam(struct net_device *dev,
@@ -2066,20 +1991,80 @@ static const struct ethtool_ops b44_ethtool_ops = {
 
 static int b44_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
-	struct mii_ioctl_data *data = if_mii(ifr);
 	struct b44 *bp = netdev_priv(dev);
 	int err = -EINVAL;
 
 	if (!netif_running(dev))
 		goto out;
 
+	if (!bp->phydev)
+		return -EINVAL;
+
 	spin_lock_irq(&bp->lock);
-	err = generic_mii_ioctl(&bp->mii_if, data, cmd, NULL);
+	err = phy_mii_ioctl(bp->phydev, ifr, cmd);
 	spin_unlock_irq(&bp->lock);
 out:
 	return err;
 }
 
+static void b44_adjust_link(struct net_device *dev)
+{
+	struct b44 *bp = netdev_priv(dev);
+	struct phy_device *phydev = bp->phydev;
+	int status_changed = 0;
+
+	BUG_ON(!phydev);
+
+	if (bp->old_link != phydev->link) {
+		status_changed = 1;
+		bp->old_link = phydev->link;
+	}
+
+	/* reflect duplex change */
+	if (phydev->link && (bp->old_duplex != phydev->duplex)) {
+		status_changed = 1;
+		bp->old_duplex = phydev->duplex;
+	}
+
+	if (status_changed) {
+		pr_info("%s: link %s", dev->name, phydev->link ?
+			"UP" : "DOWN");
+		if (phydev->link)
+			pr_cont(" - %d/%s", phydev->speed,
+			phydev->duplex == DUPLEX_FULL ? "full" : "half");
+		pr_cont("\n");
+	}
+}
+
+static int b44_mii_probe(struct net_device *dev)
+{
+	struct b44 *bp = netdev_priv(dev);
+	struct phy_device *phydev = NULL;
+	char phy_id[MII_BUS_ID_SIZE + 3];
+
+	/* connect to PHY */
+	snprintf(phy_id, sizeof(phy_id), PHY_ID_FMT,
+		 bp->mii_bus->id, bp->phy_addr);
+
+	phydev = phy_connect(dev, phy_id, &b44_adjust_link,
+			     PHY_INTERFACE_MODE_MII);
+	if (IS_ERR(phydev)) {
+		netdev_err(dev, "could not attach PHY: %s", phy_id);
+		bp->phy_addr = B44_PHY_ADDR_NO_PHY;
+		return PTR_ERR(phydev);
+	}
+
+	bp->phydev = phydev;
+	bp->old_link = 0;
+	bp->old_duplex = -1;
+	bp->phy_addr = phydev->addr;
+
+	netdev_info(dev, "attached PHY driver [%s] (mii_bus:phy_addr=%s)\n",
+		    phydev->drv->name, dev_name(&phydev->dev));
+
+	return 0;
+}
+
 static int b44_get_invariants(struct b44 *bp)
 {
 	struct ssb_device *sdev = bp->sdev;
@@ -2197,12 +2182,38 @@ static int b44_init_one(struct ssb_device *sdev,
 		goto err_out_powerdown;
 	}
 
-	bp->mii_if.dev = dev;
-	bp->mii_if.mdio_read = b44_mii_read;
-	bp->mii_if.mdio_write = b44_mii_write;
-	bp->mii_if.phy_id = bp->phy_addr;
-	bp->mii_if.phy_id_mask = 0x1f;
-	bp->mii_if.reg_num_mask = 0x1f;
+	bp->mii_bus = mdiobus_alloc();
+	if (!bp->mii_bus) {
+		dev_err(sdev->dev, "mdiobus_alloc() failed\n");
+		err = -ENOMEM;
+		goto err_out_powerdown;
+	}
+
+	bp->mii_bus->priv = bp;
+	bp->mii_bus->read = b44_mii_read;
+	bp->mii_bus->write = b44_mii_write;
+	bp->mii_bus->name = "b44_eth_mii";
+	snprintf(bp->mii_bus->id, MII_BUS_ID_SIZE, "%x", instance);
+	bp->mii_bus->irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
+	if (!bp->mii_bus->irq) {
+		dev_err(sdev->dev, "mii_bus irq allocation failed\n");
+		err = -ENOMEM;
+		goto err_out_mdiobus;
+	}
+
+	memset(bp->mii_bus->irq, PHY_POLL, sizeof(int) * PHY_MAX_ADDR);
+
+	err = mdiobus_register(bp->mii_bus);
+	if (err) {
+		dev_err(sdev->dev, "failed to register MII bus\n");
+		goto err_out_mdiobus_irq;
+	}
+
+	err = b44_mii_probe(dev);
+	if (err) {
+		dev_err(sdev->dev, "failed to probe MII bus\n");
+		goto err_out_mdiobus_unregister;
+	}
 
 	/* By default, advertise all speed/duplex settings. */
 	bp->flags |= (B44_FLAG_ADV_10HALF | B44_FLAG_ADV_10FULL |
@@ -2234,6 +2245,16 @@ static int b44_init_one(struct ssb_device *sdev,
 
 	return 0;
 
+
+err_out_mdiobus_unregister:
+	mdiobus_unregister(bp->mii_bus);
+
+err_out_mdiobus_irq:
+	kfree(bp->mii_bus->irq);
+
+err_out_mdiobus:
+	mdiobus_free(bp->mii_bus);
+
 err_out_powerdown:
 	ssb_bus_may_powerdown(sdev->bus);
 
@@ -2247,8 +2268,12 @@ out:
 static void b44_remove_one(struct ssb_device *sdev)
 {
 	struct net_device *dev = ssb_get_drvdata(sdev);
+	struct b44 *bp = netdev_priv(dev);
 
 	unregister_netdev(dev);
+	mdiobus_unregister(bp->mii_bus);
+	kfree(bp->mii_bus->irq);
+	mdiobus_free(bp->mii_bus);
 	ssb_device_disable(sdev, 0);
 	ssb_bus_may_powerdown(sdev->bus);
 	free_netdev(dev);
diff --git a/drivers/net/ethernet/broadcom/b44.h b/drivers/net/ethernet/broadcom/b44.h
index 8993d72..0b8db8b 100644
--- a/drivers/net/ethernet/broadcom/b44.h
+++ b/drivers/net/ethernet/broadcom/b44.h
@@ -396,7 +396,10 @@ struct b44 {
 	u32			tx_pending;
 	u8			phy_addr;
 	u8			force_copybreak;
-	struct mii_if_info	mii_if;
+	struct phy_device	*phydev;
+	struct mii_bus		*mii_bus;
+	int			old_link;
+	int			old_duplex;
 };
 
 #endif /* _B44_H */
-- 
1.7.10.4
