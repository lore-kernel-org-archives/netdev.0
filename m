From: Kedareswara rao Appana <appana.durga.rao@xilinx.com>
Subject: [PATCH 2/2] net: phy: Fix race conditions in the driver
Date: Fri, 19 Aug 2016 18:18:11 +0530
Message-ID: <1471610891-13353-2-git-send-email-appanad@xilinx.com>
References: <1471610891-13353-1-git-send-email-appanad@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-arm-kernel@lists.infradead.org>,
        <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: <michal.simek@xilinx.com>, <soren.brinkmann@xilinx.com>,
        <appanad@xilinx.com>, <f.fainelli@gmail.com>, <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0050.outbound.protection.outlook.com ([104.47.41.50]:15496
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754558AbcHSMtq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 19 Aug 2016 08:49:46 -0400
In-Reply-To: <1471610891-13353-1-git-send-email-appanad@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the below race conditions in the driver.
---> Fix Opps after unload the driver as a module
---> Use spin locks where relevant.
---> Take reference on the external phy to prevent issues
when phy driver is unloaded.

Reported-by: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>
---
 drivers/net/phy/xilinx_gmii2rgmii.c | 32 +++++++++++++++++++++++++++++++-
 1 file changed, 31 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/xilinx_gmii2rgmii.c b/drivers/net/phy/xilinx_gmii2rgmii.c
index 7336fd0..cdd9d95 100644
--- a/drivers/net/phy/xilinx_gmii2rgmii.c
+++ b/drivers/net/phy/xilinx_gmii2rgmii.c
@@ -34,6 +34,7 @@ struct gmii2rgmii {
 	struct phy_driver *phy_drv;
 	struct phy_driver conv_phy_drv;
 	int addr;
+	spinlock_t phy_lock;
 };
 
 static int xgmiitorgmii_read_status(struct phy_device *phydev)
@@ -55,7 +56,7 @@ static int xgmiitorgmii_read_status(struct phy_device *phydev)
 		val |= BMCR_SPEED1000;
 	else if (phydev->speed == SPEED_100)
 		val |= BMCR_SPEED100;
-	else
+	else if (phydev->speed == SPEED_10)
 		val |= BMCR_SPEED10;
 
 	err = mdiobus_write(phydev->mdio.bus, priv->addr, XILINX_GMII2RGMII_REG,
@@ -71,6 +72,8 @@ int xgmiitorgmii_probe(struct mdio_device *mdiodev)
 	struct device *dev = &mdiodev->dev;
 	struct device_node *np = dev->of_node, *phy_node;
 	struct gmii2rgmii *priv;
+	struct mii_bus *bus;
+	unsigned long flags;
 
 	priv = devm_kzalloc(dev, sizeof(*priv), GFP_KERNEL);
 	if (!priv)
@@ -88,17 +91,43 @@ int xgmiitorgmii_probe(struct mdio_device *mdiodev)
 		return -EPROBE_DEFER;
 	}
 
+	spin_lock_init(&priv->phy_lock);
+
+	bus = priv->phy_dev->mdio.bus;
+	if (!try_module_get(bus->owner)) {
+		dev_err(dev, "failed to get the bus module\n");
+		return -EIO;
+	}
+
+	get_device(&priv->phy_dev->mdio.dev);
+
 	priv->addr = mdiodev->addr;
 	priv->phy_drv = priv->phy_dev->drv;
 	memcpy(&priv->conv_phy_drv, priv->phy_dev->drv,
 	       sizeof(struct phy_driver));
 	priv->conv_phy_drv.read_status = xgmiitorgmii_read_status;
 	priv->phy_dev->priv = priv;
+	spin_lock_irqsave(&priv->phy_lock, flags);
 	priv->phy_dev->drv = &priv->conv_phy_drv;
+	spin_unlock_irqrestore(&priv->phy_lock, flags);
+
+	dev_set_drvdata(dev, priv);
 
 	return 0;
 }
 
+static void xgmiitorgmii_remove(struct mdio_device *mdiodev)
+{
+	struct gmii2rgmii *priv = dev_get_drvdata(&mdiodev->dev);
+	struct mii_bus *bus;
+
+	bus = priv->phy_dev->mdio.bus;
+
+	put_device(&priv->phy_dev->mdio.dev);
+	module_put(bus->owner);
+	phy_disconnect(priv->phy_dev);
+}
+
 static const struct of_device_id xgmiitorgmii_of_match[] = {
 	{ .compatible = "xlnx,gmii-to-rgmii-1.0" },
 	{},
@@ -107,6 +136,7 @@ MODULE_DEVICE_TABLE(of, xgmiitorgmii_of_match);
 
 static struct mdio_driver xgmiitorgmii_driver = {
 	.probe	= xgmiitorgmii_probe,
+	.remove	= xgmiitorgmii_remove,
 	.mdiodrv.driver = {
 		.name = "xgmiitorgmii",
 		.of_match_table = xgmiitorgmii_of_match,
-- 
2.1.2
