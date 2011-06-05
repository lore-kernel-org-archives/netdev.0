From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH] ep93xx-eth: convert to phylib
Date: Sun, 5 Jun 2011 19:57:36 +0200
Message-ID: <201106051957.36492.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Lennert Buytenhek <kernel@wantstofly.org>,
	Mika Westerberg <mika.westerberg@iki.fi>,
	hsweeten@visionengravers.com, ryan@bluewatersys.com,
	linux-arm-kernel@list
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:65190 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754404Ab1FER5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2011 13:57:40 -0400
Received: by wwa36 with SMTP id 36so3117758wwa.1
        for <netdev@vger.kernel.org>; Sun, 05 Jun 2011 10:57:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ep93xx-eth lacked support for monitoring link status changes, with this
patch, link changes are now watched and reported correctly.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/arm/Kconfig b/drivers/net/arm/Kconfig
index 39e1c0d..53d075e 100644
--- a/drivers/net/arm/Kconfig
+++ b/drivers/net/arm/Kconfig
@@ -51,7 +51,7 @@ config ARM_KS8695_ETHER
 config EP93XX_ETH
 	tristate "EP93xx Ethernet support"
 	depends on ARM && ARCH_EP93XX
-	select MII
+	select PHYLIB
 	help
 	  This is a driver for the ethernet hardware included in EP93xx CPUs.
 	  Say Y if you are building a kernel for EP93xx based devices.
diff --git a/drivers/net/arm/ep93xx_eth.c b/drivers/net/arm/ep93xx_eth.c
index 5a77001..4669b6c 100644
--- a/drivers/net/arm/ep93xx_eth.c
+++ b/drivers/net/arm/ep93xx_eth.c
@@ -24,6 +24,7 @@
 #include <linux/delay.h>
 #include <linux/io.h>
 #include <linux/slab.h>
+#include <linux/phy.h>
 
 #include <mach/hardware.h>
 
@@ -175,7 +176,11 @@ struct ep93xx_priv
 	struct net_device	*dev;
 	struct napi_struct	napi;
 
-	struct mii_if_info	mii;
+	struct mii_bus		*mii_bus;
+	struct phy_device	*phydev;
+	int			old_link;
+	int			old_duplex;
+	unsigned int		phy_addr;
 	u8			mdc_divisor;
 };
 
@@ -186,8 +191,9 @@ struct ep93xx_priv
 #define wrw(ep, off, val)	__raw_writew((val), (ep)->base_addr + (off))
 #define wrl(ep, off, val)	__raw_writel((val), (ep)->base_addr + (off))
 
-static int ep93xx_mdio_read(struct net_device *dev, int phy_id, int reg)
+static int ep93xx_mdiobus_read(struct mii_bus *bus, int phy_id, int reg)
 {
+	struct net_device *dev = bus->priv;
 	struct ep93xx_priv *ep = netdev_priv(dev);
 	int data;
 	int i;
@@ -210,8 +216,9 @@ static int ep93xx_mdio_read(struct net_device *dev, int phy_id, int reg)
 	return data;
 }
 
-static void ep93xx_mdio_write(struct net_device *dev, int phy_id, int reg, int data)
+static int ep93xx_mdiobus_write(struct mii_bus *bus, int phy_id, int reg, u16 data)
 {
+	struct net_device *dev = bus->priv;
 	struct ep93xx_priv *ep = netdev_priv(dev);
 	int i;
 
@@ -224,8 +231,84 @@ static void ep93xx_mdio_write(struct net_device *dev, int phy_id, int reg, int d
 		msleep(1);
 	}
 
-	if (i == 10)
+	if (i == 10) {
 		pr_info("mdio write timed out\n");
+		return -ETIMEDOUT;
+	}
+
+	return 0;
+}
+
+static int ep93xx_mdiobus_reset(struct mii_bus *bus)
+{
+	return 0;
+}
+
+static void ep93xx_adjust_link(struct net_device *dev)
+{
+	struct ep93xx_priv * ep = netdev_priv(dev);
+	struct phy_device *phydev = ep->phydev;
+	int status_changed = 0;
+
+	BUG_ON(!phydev);
+
+	if (ep->old_link != phydev->link) {
+		status_changed = 1;
+		ep->old_link = phydev->link;
+	}
+
+	if (phydev->link && (ep->old_duplex != phydev->duplex)) {
+		status_changed = 1;
+		ep->old_duplex = phydev->duplex;
+	}
+
+	if (status_changed) {
+		pr_info("%s: link %s", dev->name, phydev->link ?
+			"UP" : "DOWN");
+		if (phydev->link)
+			pr_cont(" - %d/%s", phydev->speed,
+			DUPLEX_FULL == phydev->duplex ? "full" : "half");
+		pr_cont("\n");
+	}
+}
+
+static int ep93xx_mii_probe(struct net_device *dev)
+{
+	struct ep93xx_priv * ep = netdev_priv(dev);
+	struct phy_device *phydev = NULL;
+
+	/* use platform supplied PHY address if valid */
+	if (ep->phy_addr)
+		phydev = ep->mii_bus->phy_map[ep->phy_addr];
+	else
+		phydev = phy_find_first(ep->mii_bus);
+
+	if (!phydev) {
+		pr_err("no PHY found\n");
+		return -ENODEV;
+	}
+
+	phydev = phy_connect(dev, dev_name(&phydev->dev), &ep93xx_adjust_link,
+					0, PHY_INTERFACE_MODE_MII);
+	if (IS_ERR(phydev)) {
+		pr_err("could not attach to PHY\n");
+		return PTR_ERR(phydev);
+	}
+
+	/* mask with MAC supported features */
+	phydev->supported &= PHY_BASIC_FEATURES;
+	phydev->advertising = phydev->supported;
+	ep->phydev = phydev;
+	ep->old_link = 0;
+	ep->old_duplex = -1;
+
+	pr_info("attached PHY driver [%s] "
+		"(mii_bus:phy_addr=%s)\n",
+		phydev->drv->name, dev_name(&phydev->dev));
+
+	phy_start(phydev);
+
+	return 0;
 }
 
 static int ep93xx_rx(struct net_device *dev, int processed, int budget)
@@ -570,7 +653,7 @@ static int ep93xx_start_hw(struct net_device *dev)
 	wrl(ep, REG_SELFCTL, ((ep->mdc_divisor - 1) << 9));
 
 	/* Does the PHY support preamble suppress?  */
-	if ((ep93xx_mdio_read(dev, ep->mii.phy_id, MII_BMSR) & 0x0040) != 0)
+	if ((ep93xx_mdiobus_read(ep->mii_bus, ep->phy_addr, MII_BMSR) & 0x0040) != 0)
 		wrl(ep, REG_SELFCTL, ((ep->mdc_divisor - 1) << 9) | (1 << 8));
 
 	/* Receive descriptor ring.  */
@@ -703,9 +786,11 @@ static int ep93xx_close(struct net_device *dev)
 static int ep93xx_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	struct ep93xx_priv *ep = netdev_priv(dev);
-	struct mii_ioctl_data *data = if_mii(ifr);
 
-	return generic_mii_ioctl(&ep->mii, data, cmd, NULL);
+	if (!ep->phydev)
+		return -ENODEV;
+
+	return phy_mii_ioctl(ep->phydev, ifr, cmd);
 }
 
 static void ep93xx_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
@@ -717,25 +802,19 @@ static void ep93xx_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *i
 static int ep93xx_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct ep93xx_priv *ep = netdev_priv(dev);
-	return mii_ethtool_gset(&ep->mii, cmd);
+	return phy_ethtool_gset(ep->phydev, cmd);
 }
 
 static int ep93xx_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct ep93xx_priv *ep = netdev_priv(dev);
-	return mii_ethtool_sset(&ep->mii, cmd);
+	return phy_ethtool_sset(ep->phydev, cmd);
 }
 
 static int ep93xx_nway_reset(struct net_device *dev)
 {
 	struct ep93xx_priv *ep = netdev_priv(dev);
-	return mii_nway_restart(&ep->mii);
-}
-
-static u32 ep93xx_get_link(struct net_device *dev)
-{
-	struct ep93xx_priv *ep = netdev_priv(dev);
-	return mii_link_ok(&ep->mii);
+	return phy_start_aneg(ep->phydev);
 }
 
 static const struct ethtool_ops ep93xx_ethtool_ops = {
@@ -743,7 +822,7 @@ static const struct ethtool_ops ep93xx_ethtool_ops = {
 	.get_settings		= ep93xx_get_settings,
 	.set_settings		= ep93xx_set_settings,
 	.nway_reset		= ep93xx_nway_reset,
-	.get_link		= ep93xx_get_link,
+	.get_link		= ethtool_op_get_link,
 };
 
 static const struct net_device_ops ep93xx_netdev_ops = {
@@ -789,6 +868,11 @@ static int ep93xx_eth_remove(struct platform_device *pdev)
 
 	/* @@@ Force down.  */
 	unregister_netdev(dev);
+
+	mdiobus_unregister(ep->mii_bus);
+	kfree(ep->mii_bus->irq);
+	mdiobus_free(ep->mii_bus);
+
 	ep93xx_free_buffers(ep);
 
 	if (ep->base_addr != NULL)
@@ -811,7 +895,8 @@ static int ep93xx_eth_probe(struct platform_device *pdev)
 	struct ep93xx_priv *ep;
 	struct resource *mem;
 	int irq;
-	int err;
+	int err = 0;
+	int i;
 
 	if (pdev == NULL)
 		return -ENODEV;
@@ -849,13 +934,41 @@ static int ep93xx_eth_probe(struct platform_device *pdev)
 	}
 	ep->irq = irq;
 
-	ep->mii.phy_id = data->phy_id;
-	ep->mii.phy_id_mask = 0x1f;
-	ep->mii.reg_num_mask = 0x1f;
-	ep->mii.dev = dev;
-	ep->mii.mdio_read = ep93xx_mdio_read;
-	ep->mii.mdio_write = ep93xx_mdio_write;
+	ep->mii_bus = mdiobus_alloc();
+	if (!ep->mii_bus) {
+		dev_err(&pdev->dev, "Failed to allocate mdiobus\n");
+		goto err_out;
+	}
+
+	ep->phy_addr = data->phy_id;
+	ep->mii_bus->priv = dev;
+	ep->mii_bus->read = ep93xx_mdiobus_read;
+	ep->mii_bus->write = ep93xx_mdiobus_write;
+	ep->mii_bus->reset = ep93xx_mdiobus_reset;
+	ep->mii_bus->name = "ep93xx_eth_mii";
 	ep->mdc_divisor = 40;	/* Max HCLK 100 MHz, min MDIO clk 2.5 MHz.  */
+	snprintf(ep->mii_bus->id, MII_BUS_ID_SIZE, "%x",
+				(pdev->id != -1) ? pdev->id : 0);
+	ep->mii_bus->irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
+	if (!ep->mii_bus->irq) {
+		dev_err(&pdev->dev, "mii_bus irq allocation failed\n");
+		goto err_out;
+	}
+
+	for (i = 0; i < PHY_MAX_ADDR; i++)
+		ep->mii_bus->irq[i] = PHY_POLL;
+
+	err = mdiobus_register(ep->mii_bus);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to register MII bus\n");
+		goto err_out;
+	}
+
+	err = ep93xx_mii_probe(dev);
+	if (err) {
+		dev_err(&pdev->dev, "failed to probe MII bus\n");
+		goto err_out;
+	}
 
 	if (is_zero_ether_addr(dev->dev_addr))
 		random_ether_addr(dev->dev_addr);
-- 
1.7.4.1

