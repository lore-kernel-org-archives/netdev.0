From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC v2 20/32] dsa: Add mdio device support to Marvell switches
Date: Sun, 28 Feb 2016 17:41:28 +0100
Message-ID: <1456677700-23027-21-git-send-email-andrew@lunn.ch>
References: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
Cc: Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44954 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758371AbcB1Qmn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Feb 2016 11:42:43 -0500
In-Reply-To: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow Marvell switches to be mdio devices, which probe and then
register with the DSA framework, as component slaves.

At the same time, make them separate modules, and make mv88e6xxx a
library module.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
v2: s/Copywrite/Copyright
---
 .../devicetree/bindings/net/dsa/marvell.txt        |  29 +++++
 drivers/net/dsa/Makefile                           |  19 +---
 drivers/net/dsa/mv88e6060.c                        | 122 ++++++++++++++++++---
 drivers/net/dsa/mv88e6123.c                        |  50 ++++++++-
 drivers/net/dsa/mv88e6131.c                        |  51 ++++++++-
 drivers/net/dsa/mv88e6171.c                        |  51 ++++++++-
 drivers/net/dsa/mv88e6352.c                        |  53 ++++++++-
 drivers/net/dsa/mv88e6xxx.c                        |  35 ------
 8 files changed, 329 insertions(+), 81 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/dsa/marvell.txt

diff --git a/Documentation/devicetree/bindings/net/dsa/marvell.txt b/Documentation/devicetree/bindings/net/dsa/marvell.txt
new file mode 100644
index 000000000000..51b7cd9408f2
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/dsa/marvell.txt
@@ -0,0 +1,29 @@
+Marvell DSA Switch Device Tree Bindings
+---------------------------------------
+
+WARNING: This binding is currently unstable. Do not program it into a
+FLASH never to be changed again. Once this binding is stable, this
+warning will be removed.
+
+If you need a stable binding, use the old dsa.txt binding.
+
+Marvell Switches are MDIO devices. The following properties should be
+placed as a child node of an mdio device.
+
+Required properties:
+- compatible		: Should be one of "marvell,mv88e6123",
+			  "marvell,mv88e6131", "marvell,mv88e6171",
+			  "marvell,mv88e6352" or "marvell,mv88e6060"
+- reg			: Address on the MII bus for the switch.
+
+Example:
+
+	mdio {
+		#address-cells = <1>;
+		#size-cells = <0>;
+
+		switch0: switch@1 {
+			reg = <0>;
+			compatible = "marvell,mv88e6131";
+		};
+	};
diff --git a/drivers/net/dsa/Makefile b/drivers/net/dsa/Makefile
index a6e09939be65..3e1f36120e02 100644
--- a/drivers/net/dsa/Makefile
+++ b/drivers/net/dsa/Makefile
@@ -1,16 +1,7 @@
 obj-$(CONFIG_NET_DSA_MV88E6060) += mv88e6060.o
-obj-$(CONFIG_NET_DSA_MV88E6XXX) += mv88e6xxx_drv.o
-mv88e6xxx_drv-y += mv88e6xxx.o
-ifdef CONFIG_NET_DSA_MV88E6123
-mv88e6xxx_drv-y += mv88e6123.o
-endif
-ifdef CONFIG_NET_DSA_MV88E6131
-mv88e6xxx_drv-y += mv88e6131.o
-endif
-ifdef CONFIG_NET_DSA_MV88E6352
-mv88e6xxx_drv-y += mv88e6352.o
-endif
-ifdef CONFIG_NET_DSA_MV88E6171
-mv88e6xxx_drv-y += mv88e6171.o
-endif
+obj-$(CONFIG_NET_DSA_MV88E6XXX) += mv88e6xxx.o
+obj-$(CONFIG_NET_DSA_MV88E6131) += mv88e6123.o
+obj-$(CONFIG_NET_DSA_MV88E6131) += mv88e6131.o
+obj-$(CONFIG_NET_DSA_MV88E6352) += mv88e6352.o
+obj-$(CONFIG_NET_DSA_MV88E6171) += mv88e6171.o
 obj-$(CONFIG_NET_DSA_BCM_SF2)	+= bcm_sf2.o
diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
index 59e8b0fb8431..723273c8ff32 100644
--- a/drivers/net/dsa/mv88e6060.c
+++ b/drivers/net/dsa/mv88e6060.c
@@ -1,6 +1,7 @@
 /*
  * net/dsa/mv88e6060.c - Driver for Marvell 88e6060 switch chips
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
 #include "mv88e6060.h"
 
@@ -51,14 +54,10 @@ static int reg_write(struct dsa_switch *ds, int addr, int reg, u16 val)
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
@@ -73,6 +72,16 @@ static char *mv88e6060_drv_probe(struct device *host_dev, int sw_addr)
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
@@ -170,19 +179,22 @@ static int mv88e6060_setup(struct dsa_switch *ds, struct device *dev)
 {
 	int i;
 	int ret;
-	struct mv88e6060_priv *priv;
+	struct mv88e6060_priv *priv = ds_to_priv(ds);
 
-	priv = devm_kzalloc(dev, sizeof(*priv), GFP_KERNEL);
-	if (!priv)
-		return -ENOMEM;
+	if (!priv) {
+		/* Old method when dsa creates the switch */
+		priv = devm_kzalloc(dev, sizeof(*priv), GFP_KERNEL);
+		if (!priv)
+			return -ENOMEM;
 
-	ds->priv = priv;
+		ds->priv = priv;
 
-	priv->bus = dsa_host_dev_to_mii_bus(ds->master_dev);
-	if (!priv->bus)
-		return -ENODEV;
+		priv->bus = dsa_host_dev_to_mii_bus(ds->master_dev);
+		if (!priv->bus)
+			return -ENODEV;
 
-	priv->sw_addr = ds->pd->sw_addr;
+		priv->sw_addr = ds->pd->sw_addr;
+	}
 
 	ret = mv88e6060_switch_reset(ds);
 	if (ret < 0)
@@ -252,15 +264,95 @@ static struct dsa_switch_driver mv88e6060_switch_driver = {
 	.phy_write	= mv88e6060_phy_write,
 };
 
+static int mv88e6060_bind(struct device *dev,
+			  struct device *master, void *data)
+{
+	struct mdio_device *mdiodev = to_mdio_device(dev);
+	struct dsa_switch_tree *dst = data;
+	struct mv88e6060_priv *priv;
+	struct device_node *np = dev->of_node;
+	struct dsa_switch *ds;
+	const char *name;
+
+	ds = devm_kzalloc(dev, sizeof(*ds) + sizeof(*priv), GFP_KERNEL);
+	if (!ds)
+		return -ENOMEM;
+
+	priv = (struct mv88e6060_priv *)(ds + 1);
+	ds->priv = priv;
+	priv->bus = mdiodev->bus;
+	priv->sw_addr = mdiodev->addr;
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
+static void mv88e6060_unbind(struct device *dev, struct device *master,
+			     void *data)
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
index 2c23762cbed8..4c488f9f2a34 100644
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
@@ -8,9 +9,11 @@
  * (at your option) any later version.
  */
 
+#include <linux/component.h>
 #include <linux/delay.h>
 #include <linux/jiffies.h>
 #include <linux/list.h>
+#include <linux/mdio.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/phy.h>
@@ -121,6 +124,47 @@ struct dsa_switch_driver mv88e6123_switch_driver = {
 	.get_regs		= mv88e6xxx_get_regs,
 };
 
-MODULE_ALIAS("platform:mv88e6123");
-MODULE_ALIAS("platform:mv88e6161");
-MODULE_ALIAS("platform:mv88e6165");
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
+static void mv88e6123_remove(struct mdio_device *mdiodev)
+{
+	component_del(&mdiodev->dev, &mv88e6123_component_ops);
+}
+
+static int mv88e6123_probe(struct mdio_device *mdiodev)
+{
+	return component_add(&mdiodev->dev, &mv88e6123_component_ops);
+}
+
+static const struct of_device_id mv88e6123_of_match[] = {
+	{ .compatible = "marvell,mv88e6123" },
+	{ /* sentinel */ },
+};
+MODULE_DEVICE_TABLE(of, mv88e6123_of_match);
+
+static struct mdio_driver mv88e6123_driver = {
+	.probe  = mv88e6123_probe,
+	.remove = mv88e6123_remove,
+	.mdiodrv.driver = {
+		.name = "mv88e6123",
+		.of_match_table = mv88e6123_of_match,
+	},
+};
+
+mv88e6xxx_module_driver(mv88e6123_driver, mv88e6123_switch_driver);
+
+MODULE_DESCRIPTION("Driver for Marvell 6123 family ethernet switch chips");
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index 02d2bca095af..e5a4e2b11322 100644
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
@@ -8,9 +9,11 @@
  * (at your option) any later version.
  */
 
+#include <linux/component.h>
 #include <linux/delay.h>
 #include <linux/jiffies.h>
 #include <linux/list.h>
+#include <linux/mdio.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/phy.h>
@@ -173,7 +176,47 @@ struct dsa_switch_driver mv88e6131_switch_driver = {
 	.adjust_link		= mv88e6xxx_adjust_link,
 };
 
-MODULE_ALIAS("platform:mv88e6085");
-MODULE_ALIAS("platform:mv88e6095");
-MODULE_ALIAS("platform:mv88e6095f");
-MODULE_ALIAS("platform:mv88e6131");
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
+static void mv88e6131_remove(struct mdio_device *mdiodev)
+{
+	component_del(&mdiodev->dev, &mv88e6131_component_ops);
+}
+
+static int mv88e6131_probe(struct mdio_device *mdiodev)
+{
+	return component_add(&mdiodev->dev, &mv88e6131_component_ops);
+}
+
+static const struct of_device_id mv88e6131_of_match[] = {
+	{ .compatible = "marvell,mv88e6131" },
+	{ /* sentinel */ },
+};
+MODULE_DEVICE_TABLE(of, mv88e6131_of_match);
+
+static struct mdio_driver mv88e6131_driver = {
+	.probe	= mv88e6131_probe,
+	.remove = mv88e6131_remove,
+	.mdiodrv.driver = {
+		.name = "mv88e6131",
+		.of_match_table = mv88e6131_of_match,
+	},
+};
+
+mv88e6xxx_module_driver(mv88e6131_driver, mv88e6131_switch_driver);
+
+MODULE_DESCRIPTION("Driver for Marvell 6131 family ethernet switch chips");
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index d557be12feb7..249c2c075a2d 100644
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
@@ -8,9 +9,11 @@
  * (at your option) any later version.
  */
 
+#include <linux/component.h>
 #include <linux/delay.h>
 #include <linux/jiffies.h>
 #include <linux/list.h>
+#include <linux/mdio.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/phy.h>
@@ -119,7 +122,47 @@ struct dsa_switch_driver mv88e6171_switch_driver = {
 	.port_fdb_dump		= mv88e6xxx_port_fdb_dump,
 };
 
-MODULE_ALIAS("platform:mv88e6171");
-MODULE_ALIAS("platform:mv88e6175");
-MODULE_ALIAS("platform:mv88e6350");
-MODULE_ALIAS("platform:mv88e6351");
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
+static void mv88e6171_remove(struct mdio_device *mdiodev)
+{
+	component_del(&mdiodev->dev, &mv88e6171_component_ops);
+}
+
+static int mv88e6171_probe(struct mdio_device *mdiodev)
+{
+	return component_add(&mdiodev->dev, &mv88e6171_component_ops);
+}
+
+static const struct of_device_id mv88e6171_of_match[] = {
+	{ .compatible = "marvell,mv88e6171" },
+	{ /* sentinel */ },
+};
+MODULE_DEVICE_TABLE(of, mv88e6171_of_match);
+
+static struct mdio_driver mv88e6171_driver = {
+	.probe  = mv88e6171_probe,
+	.remove = mv88e6171_remove,
+	.mdiodrv.driver = {
+		.name = "mv88e6171",
+		.of_match_table = mv88e6171_of_match,
+	},
+};
+
+mv88e6xxx_module_driver(mv88e6171_driver, mv88e6171_switch_driver);
+
+MODULE_DESCRIPTION("Driver for Marvell 6171 family ethernet switch chips");
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index 959835d69af6..0d245f76e557 100644
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
@@ -12,12 +13,13 @@
  * (at your option) any later version.
  */
 
+#include <linux/component.h>
 #include <linux/delay.h>
 #include <linux/jiffies.h>
 #include <linux/list.h>
+#include <linux/mdio.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
-#include <linux/platform_device.h>
 #include <linux/phy.h>
 #include <net/dsa.h>
 #include "mv88e6xxx.h"
@@ -339,8 +341,47 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
 	.port_fdb_dump		= mv88e6xxx_port_fdb_dump,
 };
 
-MODULE_ALIAS("platform:mv88e6172");
-MODULE_ALIAS("platform:mv88e6176");
-MODULE_ALIAS("platform:mv88e6320");
-MODULE_ALIAS("platform:mv88e6321");
-MODULE_ALIAS("platform:mv88e6352");
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
+static void mv88e6352_remove(struct mdio_device *mdiodev)
+{
+	component_del(&mdiodev->dev, &mv88e6352_component_ops);
+}
+
+static int mv88e6352_probe(struct mdio_device *mdiodev)
+{
+	return component_add(&mdiodev->dev, &mv88e6352_component_ops);
+}
+
+static const struct of_device_id mv88e6352_of_match[] = {
+	{ .compatible = "marvell,mv88e6352" },
+	{ /* sentinel */ },
+};
+MODULE_DEVICE_TABLE(of, mv88e6352_of_match);
+
+static struct mdio_driver mv88e6352_driver = {
+	.probe  = mv88e6352_probe,
+	.remove = mv88e6352_remove,
+	.mdiodrv.driver = {
+		.name = "mv88e6352",
+		.of_match_table = mv88e6352_of_match,
+	},
+};
+
+mv88e6xxx_module_driver(mv88e6352_driver, mv88e6352_switch_driver);
+
+MODULE_DESCRIPTION("Driver for Marvell 6352 family ethernet switch chips");
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index b0838bf77fd9..3dca92b8d592 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2755,41 +2755,6 @@ void mv88e6xxx_unbind(struct device *dev, struct device *master, void *data)
 }
 EXPORT_SYMBOL_GPL(mv88e6xxx_unbind);
 
-static int __init mv88e6xxx_init(void)
-{
-#if IS_ENABLED(CONFIG_NET_DSA_MV88E6131)
-	register_switch_driver(&mv88e6131_switch_driver);
-#endif
-#if IS_ENABLED(CONFIG_NET_DSA_MV88E6123)
-	register_switch_driver(&mv88e6123_switch_driver);
-#endif
-#if IS_ENABLED(CONFIG_NET_DSA_MV88E6352)
-	register_switch_driver(&mv88e6352_switch_driver);
-#endif
-#if IS_ENABLED(CONFIG_NET_DSA_MV88E6171)
-	register_switch_driver(&mv88e6171_switch_driver);
-#endif
-	return 0;
-}
-module_init(mv88e6xxx_init);
-
-static void __exit mv88e6xxx_cleanup(void)
-{
-#if IS_ENABLED(CONFIG_NET_DSA_MV88E6171)
-	unregister_switch_driver(&mv88e6171_switch_driver);
-#endif
-#if IS_ENABLED(CONFIG_NET_DSA_MV88E6352)
-	unregister_switch_driver(&mv88e6352_switch_driver);
-#endif
-#if IS_ENABLED(CONFIG_NET_DSA_MV88E6123_61_65)
-	unregister_switch_driver(&mv88e6123_61_65_switch_driver);
-#endif
-#if IS_ENABLED(CONFIG_NET_DSA_MV88E6131)
-	unregister_switch_driver(&mv88e6131_switch_driver);
-#endif
-}
-module_exit(mv88e6xxx_cleanup);
-
 MODULE_AUTHOR("Lennert Buytenhek <buytenh@wantstofly.org>");
 MODULE_DESCRIPTION("Driver for Marvell 88E6XXX ethernet switch chips");
 MODULE_LICENSE("GPL");
-- 
2.7.0
