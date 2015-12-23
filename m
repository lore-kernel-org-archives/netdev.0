From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC 18/28] dsa: Add platform device support to Marvell switches
Date: Wed, 23 Dec 2015 13:56:32 +0100
Message-ID: <1450875402-20740-19-git-send-email-andrew@lunn.ch>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>, narmstrong@baylibre.com,
	vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48718 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757137AbbLWM5u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2015 07:57:50 -0500
In-Reply-To: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow Marvell switches to be platform devices, which probe and then
register with the DSA framework, as component slaves.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 .../devicetree/bindings/net/dsa/marvell.txt        |  17 ++++
 drivers/net/dsa/mv88e6060.c                        | 103 +++++++++++++++++++--
 drivers/net/dsa/mv88e6123.c                        |  51 +++++++++-
 drivers/net/dsa/mv88e6131.c                        |  52 ++++++++++-
 drivers/net/dsa/mv88e6171.c                        |  52 ++++++++++-
 drivers/net/dsa/mv88e6352.c                        |  52 ++++++++++-
 6 files changed, 309 insertions(+), 18 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/dsa/marvell.txt

diff --git a/Documentation/devicetree/bindings/net/dsa/marvell.txt b/Documentation/devicetree/bindings/net/dsa/marvell.txt
new file mode 100644
index 000000000000..9e91db9ef663
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/dsa/marvell.txt
@@ -0,0 +1,17 @@
+Marvell DSA Switch Device Tree Bindings
+---------------------------------------
+
+Required properties:
+- compatible		: Should be one of "marvell,mv88e6123",
+			  "marvell,mv88e6131", "marvell,mv88e6171",
+			  "marvell,mv88e6352" or "marvell,mv88e6060"
+- mii-bus		: phandle to MII bus the switch is on
+- addr			: Address on the MII bus for the switch
+
+Example:
+
+	switchdev0: switchdev0 {
+		compatible = "marvell,mv88e6352";
+		mii-bus = <&mdio_mux_1>;
+		addr = <0>;
+	};
diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
index 02810a50825b..41472dc409ce 100644
--- a/drivers/net/dsa/mv88e6060.c
+++ b/drivers/net/dsa/mv88e6060.c
@@ -1,6 +1,7 @@
 /*
  * net/dsa/mv88e6060.c - Driver for Marvell 88e6060 switch chips
  * Copyright (c) 2008-2009 Marvell Semiconductor
+ * Copywrite (c) 2015 Andrew Lunn <andrew@lunn.ch>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -8,12 +9,15 @@
  * (at your option) any later version.
  */
 
+#include <linux/component.h>
 #include <linux/delay.h>
 #include <linux/jiffies.h>
 #include <linux/list.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
+#include <linux/of_mdio.h>
 #include <linux/phy.h>
+#include <linux/platform_device.h>
 #include <net/dsa.h>
 #include "mv88e6060.h"
 
@@ -51,14 +55,10 @@ static int reg_write(struct dsa_switch *ds, int addr, int reg, u16 val)
 			return __ret;				\
 	})
 
-static char *mv88e6060_drv_probe(struct device *host_dev, int sw_addr)
+static char *mv88e6060_name(struct mii_bus *bus, int sw_addr)
 {
-	struct mii_bus *bus = dsa_host_dev_to_mii_bus(host_dev);
 	int ret;
 
-	if (bus == NULL)
-		return NULL;
-
 	ret = mdiobus_read(bus, sw_addr + REG_PORT(0), PORT_SWITCH_ID);
 	if (ret >= 0) {
 		if (ret == PORT_SWITCH_ID_6060)
@@ -73,6 +73,16 @@ static char *mv88e6060_drv_probe(struct device *host_dev, int sw_addr)
 	return NULL;
 }
 
+static char *mv88e6060_drv_probe(struct device *host_dev, int sw_addr)
+{
+	struct mii_bus *bus = dsa_host_dev_to_mii_bus(host_dev);
+
+	if (!bus)
+		return NULL;
+
+	return mv88e6060_name(bus, sw_addr);
+}
+
 static int mv88e6060_switch_reset(struct dsa_switch *ds)
 {
 	int i;
@@ -248,15 +258,96 @@ static struct dsa_switch_driver mv88e6060_switch_driver = {
 	.phy_write	= mv88e6060_phy_write,
 };
 
+static int mv88e6060_bind(struct device *dev,
+			  struct device *master, void *data)
+{
+	struct dsa_switch_tree *dst = data;
+	struct mv88e6060_priv *priv;
+	struct device_node *np = dev->of_node;
+	struct dsa_switch *ds;
+	const char *name;
+	int ret = 0;
+
+	ds = devm_kzalloc(dev, sizeof(*ds) + sizeof(*priv), GFP_KERNEL);
+	if (!ds)
+		return -ENOMEM;
+
+	priv = (struct mv88e6060_priv *)(ds + 1);
+	ds->priv = priv;
+
+	ret = of_mdio_parse_bus_and_addr(dev, np, &priv->bus, &priv->sw_addr);
+	if (ret)
+		return ret;
+
+	get_device(&priv->bus->dev);
+
+	ds->drv = &mv88e6060_switch_driver;
+
+	name = mv88e6060_name(priv->bus, priv->sw_addr);
+	if (!name) {
+		dev_err(dev, "Failed to find switch");
+		return -ENODEV;
+	}
+
+	dev_set_drvdata(dev, ds);
+	dsa_switch_register(dst, ds, np, name);
+
+	return 0;
+}
+
+void mv88e6060_unbind(struct device *dev, struct device *master, void *data)
+{
+	struct dsa_switch *ds = dev_get_drvdata(dev);
+	struct mv88e6060_priv *priv = ds_to_priv(ds);
+
+	dsa_switch_unregister(ds);
+	put_device(&priv->bus->dev);
+}
+
+static const struct component_ops mv88e6060_component_ops = {
+	.bind = mv88e6060_bind,
+	.unbind = mv88e6060_unbind,
+};
+
+static int mv88e6060_remove(struct platform_device *pdev)
+{
+	component_del(&pdev->dev, &mv88e6060_component_ops);
+
+	return 0;
+}
+
+static int mv88e6060_probe(struct platform_device *pdev)
+{
+	return component_add(&pdev->dev, &mv88e6060_component_ops);
+}
+
+static const struct of_device_id mv88e6060_of_match[] = {
+	{ .compatible = "marvell,mv88e6060" },
+	{ /* sentinel */ },
+};
+MODULE_DEVICE_TABLE(of, mv88e6060_of_match);
+
+static struct platform_driver mv88e6060_driver = {
+	.probe  = mv88e6060_probe,
+	.remove = mv88e6060_remove,
+	.driver = {
+		.name = "mv88e6060",
+		.of_match_table = mv88e6060_of_match,
+	},
+};
+
 static int __init mv88e6060_init(void)
 {
 	register_switch_driver(&mv88e6060_switch_driver);
-	return 0;
+
+	return platform_driver_register(&mv88e6060_driver);
 }
 module_init(mv88e6060_init);
 
 static void __exit mv88e6060_cleanup(void)
 {
+	platform_driver_unregister(&mv88e6060_driver);
+
 	unregister_switch_driver(&mv88e6060_switch_driver);
 }
 module_exit(mv88e6060_cleanup);
diff --git a/drivers/net/dsa/mv88e6123.c b/drivers/net/dsa/mv88e6123.c
index 2c23762cbed8..bb39720f3e8b 100644
--- a/drivers/net/dsa/mv88e6123.c
+++ b/drivers/net/dsa/mv88e6123.c
@@ -1,6 +1,7 @@
 /*
  * net/dsa/mv88e6123_61_65.c - Marvell 88e6123/6161/6165 switch chip support
  * Copyright (c) 2008-2009 Marvell Semiconductor
+ * Copyright (c) 2015 Andrew Lunn <andrew@lunn.ch>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -8,12 +9,14 @@
  * (at your option) any later version.
  */
 
+#include <linux/component.h>
 #include <linux/delay.h>
 #include <linux/jiffies.h>
 #include <linux/list.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/phy.h>
+#include <linux/platform_device.h>
 #include <net/dsa.h>
 #include "mv88e6xxx.h"
 
@@ -122,5 +125,49 @@ struct dsa_switch_driver mv88e6123_switch_driver = {
 };
 
 MODULE_ALIAS("platform:mv88e6123");
-MODULE_ALIAS("platform:mv88e6161");
-MODULE_ALIAS("platform:mv88e6165");
+
+static int mv88e6123_bind(struct device *dev,
+			  struct device *master, void *data)
+{
+	struct dsa_switch_tree *dst = data;
+
+	return mv88e6xxx_bind(dev, dst, &mv88e6123_switch_driver,
+			      mv88e6123_table,
+			      ARRAY_SIZE(mv88e6123_table));
+}
+
+static const struct component_ops mv88e6123_component_ops = {
+	.bind = mv88e6123_bind,
+	.unbind = mv88e6xxx_unbind,
+};
+
+static int mv88e6123_remove(struct platform_device *pdev)
+{
+	component_del(&pdev->dev, &mv88e6123_component_ops);
+
+	return 0;
+}
+
+static int mv88e6123_probe(struct platform_device *pdev)
+{
+	return component_add(&pdev->dev, &mv88e6123_component_ops);
+}
+
+static const struct of_device_id mv88e6123_of_match[] = {
+	{ .compatible = "marvell,mv88e6123" },
+	{ /* sentinel */ },
+};
+MODULE_DEVICE_TABLE(of, mv88e6123_of_match);
+
+static struct platform_driver mv88e6123_driver = {
+	.probe  = mv88e6123_probe,
+	.remove = mv88e6123_remove,
+	.driver = {
+		.name = "mv88e6123",
+		.of_match_table = mv88e6123_of_match,
+	},
+};
+module_platform_driver(mv88e6123_driver);
+
+MODULE_DESCRIPTION("Driver for Marvell 6123 family ethernet switch chips");
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index 02d2bca095af..2cd8c2155d3e 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -1,6 +1,7 @@
 /*
  * net/dsa/mv88e6131.c - Marvell 88e6095/6095f/6131 switch chip support
  * Copyright (c) 2008-2009 Marvell Semiconductor
+ * Copyright (c) 2015 Andrew Lunn <andrew@lunn.ch>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -8,11 +9,13 @@
  * (at your option) any later version.
  */
 
+#include <linux/component.h>
 #include <linux/delay.h>
 #include <linux/jiffies.h>
 #include <linux/list.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
+#include <linux/platform_device.h>
 #include <linux/phy.h>
 #include <net/dsa.h>
 #include "mv88e6xxx.h"
@@ -173,7 +176,50 @@ struct dsa_switch_driver mv88e6131_switch_driver = {
 	.adjust_link		= mv88e6xxx_adjust_link,
 };
 
-MODULE_ALIAS("platform:mv88e6085");
-MODULE_ALIAS("platform:mv88e6095");
-MODULE_ALIAS("platform:mv88e6095f");
 MODULE_ALIAS("platform:mv88e6131");
+
+static int mv88e6131_bind(struct device *dev,
+			  struct device *master, void *data)
+{
+	struct dsa_switch_tree *dst = data;
+
+	return mv88e6xxx_bind(dev, dst, &mv88e6131_switch_driver,
+			      mv88e6131_table,
+			      ARRAY_SIZE(mv88e6131_table));
+}
+
+static const struct component_ops mv88e6131_component_ops = {
+	.bind = mv88e6131_bind,
+	.unbind = mv88e6xxx_unbind,
+};
+
+static int mv88e6131_remove(struct platform_device *pdev)
+{
+	component_del(&pdev->dev, &mv88e6131_component_ops);
+
+	return 0;
+}
+
+static int mv88e6131_probe(struct platform_device *pdev)
+{
+	return component_add(&pdev->dev, &mv88e6131_component_ops);
+}
+
+static const struct of_device_id mv88e6131_of_match[] = {
+	{ .compatible = "marvell,mv88e6131" },
+	{ /* sentinel */ },
+};
+MODULE_DEVICE_TABLE(of, mv88e6131_of_match);
+
+static struct platform_driver mv88e6131_driver = {
+	.probe	= mv88e6131_probe,
+	.remove = mv88e6131_remove,
+	.driver = {
+		.name = "mv88e6131",
+		.of_match_table = mv88e6131_of_match,
+	},
+};
+module_platform_driver(mv88e6131_driver);
+
+MODULE_DESCRIPTION("Driver for Marvell 6131 family ethernet switch chips");
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index d557be12feb7..780098d0ad19 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -1,6 +1,7 @@
 /* net/dsa/mv88e6171.c - Marvell 88e6171 switch chip support
  * Copyright (c) 2008-2009 Marvell Semiconductor
  * Copyright (c) 2014 Claudio Leite <leitec@staticky.com>
+ * Copyright (c) 2015 Andrew Lunn <andrew@lunn.ch>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -8,12 +9,14 @@
  * (at your option) any later version.
  */
 
+#include <linux/component.h>
 #include <linux/delay.h>
 #include <linux/jiffies.h>
 #include <linux/list.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/phy.h>
+#include <linux/platform_device.h>
 #include <net/dsa.h>
 #include "mv88e6xxx.h"
 
@@ -120,6 +123,49 @@ struct dsa_switch_driver mv88e6171_switch_driver = {
 };
 
 MODULE_ALIAS("platform:mv88e6171");
-MODULE_ALIAS("platform:mv88e6175");
-MODULE_ALIAS("platform:mv88e6350");
-MODULE_ALIAS("platform:mv88e6351");
+
+static int mv88e6171_bind(struct device *dev,
+			  struct device *master, void *data)
+{
+	struct dsa_switch_tree *dst = data;
+
+	return mv88e6xxx_bind(dev, dst, &mv88e6171_switch_driver,
+			      mv88e6171_table,
+			      ARRAY_SIZE(mv88e6171_table));
+}
+
+static const struct component_ops mv88e6171_component_ops = {
+	.bind = mv88e6171_bind,
+	.unbind = mv88e6xxx_unbind,
+};
+
+static int mv88e6171_remove(struct platform_device *pdev)
+{
+	component_del(&pdev->dev, &mv88e6171_component_ops);
+
+	return 0;
+}
+
+static int mv88e6171_probe(struct platform_device *pdev)
+{
+	return component_add(&pdev->dev, &mv88e6171_component_ops);
+}
+
+static const struct of_device_id mv88e6171_of_match[] = {
+	{ .compatible = "marvell,mv88e6171" },
+	{ /* sentinel */ },
+};
+MODULE_DEVICE_TABLE(of, mv88e6171_of_match);
+
+static struct platform_driver mv88e6171_driver = {
+	.probe  = mv88e6171_probe,
+	.remove = mv88e6171_remove,
+	.driver = {
+		.name = "mv88e6171",
+		.of_match_table = mv88e6171_of_match,
+	},
+};
+module_platform_driver(mv88e6171_driver);
+
+MODULE_DESCRIPTION("Driver for Marvell 6171 family ethernet switch chips");
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index 959835d69af6..7e28150d44e0 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -2,6 +2,7 @@
  * net/dsa/mv88e6352.c - Marvell 88e6352 switch chip support
  *
  * Copyright (c) 2014 Guenter Roeck
+ * Copyright (c) 2015 Andrew Lunn <andrew@lunn.ch>
  *
  * Derived from mv88e6123_61_65.c
  * Copyright (c) 2008-2009 Marvell Semiconductor
@@ -12,6 +13,7 @@
  * (at your option) any later version.
  */
 
+#include <linux/component.h>
 #include <linux/delay.h>
 #include <linux/jiffies.h>
 #include <linux/list.h>
@@ -339,8 +341,50 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
 	.port_fdb_dump		= mv88e6xxx_port_fdb_dump,
 };
 
-MODULE_ALIAS("platform:mv88e6172");
-MODULE_ALIAS("platform:mv88e6176");
-MODULE_ALIAS("platform:mv88e6320");
-MODULE_ALIAS("platform:mv88e6321");
 MODULE_ALIAS("platform:mv88e6352");
+
+static int mv88e6352_bind(struct device *dev,
+			  struct device *master, void *data)
+{
+	struct dsa_switch_tree *dst = data;
+
+	return mv88e6xxx_bind(dev, dst, &mv88e6352_switch_driver,
+			      mv88e6352_table,
+			      ARRAY_SIZE(mv88e6352_table));
+}
+
+static const struct component_ops mv88e6352_component_ops = {
+	.bind = mv88e6352_bind,
+	.unbind = mv88e6xxx_unbind,
+};
+
+static int mv88e6352_remove(struct platform_device *pdev)
+{
+	component_del(&pdev->dev, &mv88e6352_component_ops);
+
+	return 0;
+}
+
+static int mv88e6352_probe(struct platform_device *pdev)
+{
+	return component_add(&pdev->dev, &mv88e6352_component_ops);
+}
+
+static const struct of_device_id mv88e6352_of_match[] = {
+	{ .compatible = "marvell,mv88e6352" },
+	{ /* sentinel */ },
+};
+MODULE_DEVICE_TABLE(of, mv88e6352_of_match);
+
+static struct platform_driver mv88e6352_driver = {
+	.probe  = mv88e6352_probe,
+	.remove = mv88e6352_remove,
+	.driver = {
+		.name = "mv88e6352",
+		.of_match_table = mv88e6352_of_match,
+	},
+};
+module_platform_driver(mv88e6352_driver);
+
+MODULE_DESCRIPTION("Driver for Marvell 6352 family ethernet switch chips");
+MODULE_LICENSE("GPL");
-- 
2.6.3
