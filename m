From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 4/7] net: phy: mdio-bcm-unimac: Allow specifying platform data
Date: Mon, 31 Jul 2017 12:04:25 -0700
Message-ID: <20170731190429.24204-5-f.fainelli@gmail.com>
References: <20170731190429.24204-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, opendmb@gmail.com, jaedon.shin@gmail.com,
        pgynther@google.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:36515 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751059AbdGaTEr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 15:04:47 -0400
Received: by mail-wr0-f193.google.com with SMTP id y67so31528328wrb.3
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 12:04:46 -0700 (PDT)
In-Reply-To: <20170731190429.24204-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for having the bcmgenet driver migrate over the
mdio-bcm-unimac driver, add a platform data structure which allows
passing integrating specific details like bus name, wait function to
complete MDIO operations and PHY mask.

We also define what the platform device name contract is by defining
UNIMAC_MDIO_DRV_NAME and moving it to the platform_data header.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 MAINTAINERS                                   |  1 +
 drivers/net/phy/mdio-bcm-unimac.c             | 28 +++++++++++++++++++++------
 include/linux/platform_data/mdio-bcm-unimac.h | 13 +++++++++++++
 3 files changed, 36 insertions(+), 6 deletions(-)
 create mode 100644 include/linux/platform_data/mdio-bcm-unimac.h

diff --git a/MAINTAINERS b/MAINTAINERS
index 297e610c9163..7d72fdbed6e6 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5140,6 +5140,7 @@ L:	netdev@vger.kernel.org
 S:	Maintained
 F:	include/linux/phy.h
 F:	include/linux/phy_fixed.h
+F:	include/linux/platform_data/mdio-bcm-unimac.h
 F:	drivers/net/phy/
 F:	Documentation/networking/phy.txt
 F:	drivers/of/of_mdio.c
diff --git a/drivers/net/phy/mdio-bcm-unimac.c b/drivers/net/phy/mdio-bcm-unimac.c
index 4e52692f9eea..89425ca48412 100644
--- a/drivers/net/phy/mdio-bcm-unimac.c
+++ b/drivers/net/phy/mdio-bcm-unimac.c
@@ -21,6 +21,8 @@
 #include <linux/of_platform.h>
 #include <linux/of_mdio.h>
 
+#include <linux/platform_data/mdio-bcm-unimac.h>
+
 #define MDIO_CMD		0x00
 #define  MDIO_START_BUSY	(1 << 29)
 #define  MDIO_READ_FAIL		(1 << 28)
@@ -41,6 +43,8 @@
 struct unimac_mdio_priv {
 	struct mii_bus		*mii_bus;
 	void __iomem		*base;
+	int (*wait_func)	(void *wait_func_data);
+	void			*wait_func_data;
 };
 
 static inline void unimac_mdio_start(struct unimac_mdio_priv *priv)
@@ -57,8 +61,9 @@ static inline unsigned int unimac_mdio_busy(struct unimac_mdio_priv *priv)
 	return __raw_readl(priv->base + MDIO_CMD) & MDIO_START_BUSY;
 }
 
-static int unimac_mdio_poll(struct unimac_mdio_priv *priv)
+static int unimac_mdio_poll(void *wait_func_data)
 {
+	struct unimac_mdio_priv *priv = wait_func_data;
 	unsigned int timeout = 1000;
 
 	do {
@@ -77,6 +82,7 @@ static int unimac_mdio_poll(struct unimac_mdio_priv *priv)
 static int unimac_mdio_read(struct mii_bus *bus, int phy_id, int reg)
 {
 	struct unimac_mdio_priv *priv = bus->priv;
+	int ret;
 	u32 cmd;
 
 	/* Prepare the read operation */
@@ -86,7 +92,7 @@ static int unimac_mdio_read(struct mii_bus *bus, int phy_id, int reg)
 	/* Start MDIO transaction */
 	unimac_mdio_start(priv);
 
-	ret = unimac_mdio_poll(priv);
+	ret = priv->wait_func(priv->wait_func_data);
 	if (ret)
 		return ret;
 
@@ -116,7 +122,7 @@ static int unimac_mdio_write(struct mii_bus *bus, int phy_id,
 
 	unimac_mdio_start(priv);
 
-	return unimac_mdio_poll(priv);
+	return priv->wait_func(priv->wait_func_data);
 }
 
 /* Workaround for integrated BCM7xxx Gigabit PHYs which have a problem with
@@ -165,6 +171,7 @@ static int unimac_mdio_reset(struct mii_bus *bus)
 
 static int unimac_mdio_probe(struct platform_device *pdev)
 {
+	struct unimac_mdio_pdata *pdata = pdev->dev.platform_data;
 	struct unimac_mdio_priv *priv;
 	struct device_node *np;
 	struct mii_bus *bus;
@@ -194,7 +201,16 @@ static int unimac_mdio_probe(struct platform_device *pdev)
 
 	bus = priv->mii_bus;
 	bus->priv = priv;
-	bus->name = "unimac MII bus";
+	if (pdata) {
+		bus->name = pdata->bus_name;
+		priv->wait_func = pdata->wait_func;
+		priv->wait_func_data = pdata->wait_func_data;
+		bus->phy_mask = ~pdata->phy_mask;
+	} else {
+		bus->name = "unimac MII bus";
+		priv->wait_func_data = priv;
+		priv->wait_func = unimac_mdio_poll;
+	}
 	bus->parent = &pdev->dev;
 	bus->read = unimac_mdio_read;
 	bus->write = unimac_mdio_write;
@@ -241,7 +257,7 @@ MODULE_DEVICE_TABLE(of, unimac_mdio_ids);
 
 static struct platform_driver unimac_mdio_driver = {
 	.driver = {
-		.name = "unimac-mdio",
+		.name = UNIMAC_MDIO_DRV_NAME,
 		.of_match_table = unimac_mdio_ids,
 	},
 	.probe	= unimac_mdio_probe,
@@ -252,4 +268,4 @@ module_platform_driver(unimac_mdio_driver);
 MODULE_AUTHOR("Broadcom Corporation");
 MODULE_DESCRIPTION("Broadcom UniMAC MDIO bus controller");
 MODULE_LICENSE("GPL");
-MODULE_ALIAS("platform:unimac-mdio");
+MODULE_ALIAS("platform:" UNIMAC_MDIO_DRV_NAME);
diff --git a/include/linux/platform_data/mdio-bcm-unimac.h b/include/linux/platform_data/mdio-bcm-unimac.h
new file mode 100644
index 000000000000..8a5f9f0b2c52
--- /dev/null
+++ b/include/linux/platform_data/mdio-bcm-unimac.h
@@ -0,0 +1,13 @@
+#ifndef __MDIO_BCM_UNIMAC_PDATA_H
+#define __MDIO_BCM_UNIMAC_PDATA_H
+
+struct unimac_mdio_pdata {
+	u32 phy_mask;
+	int (*wait_func)(void *data);
+	void *wait_func_data;
+	const char *bus_name;
+};
+
+#define UNIMAC_MDIO_DRV_NAME	"unimac-mdio"
+
+#endif /* __MDIO_BCM_UNIMAC_PDATA_H */
-- 
2.9.3
