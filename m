From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 3/8] dsa: Add mdio device support to Marvell switches
Date: Thu, 14 Apr 2016 01:59:53 +0200
Message-ID: <1460591998-20598-4-git-send-email-andrew@lunn.ch>
References: <1460591998-20598-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55193 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755174AbcDNABm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2016 20:01:42 -0400
In-Reply-To: <1460591998-20598-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow Marvell switches to be mdio devices. Currently they just probe
and allocate there private structure. Later patches will make them
register with the DSA framework.

At the same time, make them separate modules, and make mv88e6xxx a
library module.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
v2: s/Copywrite/Copyright
---
 .../devicetree/bindings/net/dsa/marvell.txt        | 29 ++++++++++
 drivers/net/dsa/Makefile                           | 19 ++----
 drivers/net/dsa/mv88e6123.c                        | 30 +++++++++-
 drivers/net/dsa/mv88e6131.c                        | 31 ++++++++--
 drivers/net/dsa/mv88e6171.c                        | 31 ++++++++--
 drivers/net/dsa/mv88e6352.c                        | 33 +++++++++--
 drivers/net/dsa/mv88e6xxx.c                        | 67 +++++++++++++---------
 drivers/net/dsa/mv88e6xxx.h                        |  5 ++
 8 files changed, 186 insertions(+), 59 deletions(-)
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
diff --git a/drivers/net/dsa/mv88e6123.c b/drivers/net/dsa/mv88e6123.c
index c34283d929c4..7ef0e3c7b703 100644
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
@@ -11,6 +12,7 @@
 #include <linux/delay.h>
 #include <linux/jiffies.h>
 #include <linux/list.h>
+#include <linux/mdio.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/phy.h>
@@ -123,6 +125,28 @@ struct dsa_switch_driver mv88e6123_switch_driver = {
 	.get_regs		= mv88e6xxx_get_regs,
 };
 
-MODULE_ALIAS("platform:mv88e6123");
-MODULE_ALIAS("platform:mv88e6161");
-MODULE_ALIAS("platform:mv88e6165");
+static int mv88e6123_probe(struct mdio_device *mdiodev)
+{
+	return mv88e6xxx_probe(mdiodev, &mv88e6123_switch_driver,
+			       mv88e6123_table, ARRAY_SIZE(mv88e6123_table));
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
+	.remove = mv88e6xxx_remove,
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
index f5d75fce1e96..25f35937787e 100644
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
@@ -11,6 +12,7 @@
 #include <linux/delay.h>
 #include <linux/jiffies.h>
 #include <linux/list.h>
+#include <linux/mdio.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/phy.h>
@@ -186,7 +188,28 @@ struct dsa_switch_driver mv88e6131_switch_driver = {
 	.port_fdb_dump          = mv88e6xxx_port_fdb_dump,
 };
 
-MODULE_ALIAS("platform:mv88e6085");
-MODULE_ALIAS("platform:mv88e6095");
-MODULE_ALIAS("platform:mv88e6095f");
-MODULE_ALIAS("platform:mv88e6131");
+static int mv88e6131_probe(struct mdio_device *mdiodev)
+{
+	return mv88e6xxx_probe(mdiodev, &mv88e6131_switch_driver,
+			       mv88e6131_table, ARRAY_SIZE(mv88e6131_table));
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
+	.remove = mv88e6xxx_remove,
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
index f5622506cdfa..abf2a9bbbec5 100644
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
@@ -11,6 +12,7 @@
 #include <linux/delay.h>
 #include <linux/jiffies.h>
 #include <linux/list.h>
+#include <linux/mdio.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/phy.h>
@@ -121,7 +123,28 @@ struct dsa_switch_driver mv88e6171_switch_driver = {
 	.port_fdb_dump		= mv88e6xxx_port_fdb_dump,
 };
 
-MODULE_ALIAS("platform:mv88e6171");
-MODULE_ALIAS("platform:mv88e6175");
-MODULE_ALIAS("platform:mv88e6350");
-MODULE_ALIAS("platform:mv88e6351");
+static int mv88e6171_probe(struct mdio_device *mdiodev)
+{
+	return mv88e6xxx_probe(mdiodev, &mv88e6171_switch_driver,
+			       mv88e6171_table, ARRAY_SIZE(mv88e6171_table));
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
+	.remove = mv88e6xxx_remove,
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
index e54ee27db129..22d42fb51991 100644
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
@@ -15,9 +16,9 @@
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
@@ -342,8 +343,28 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
 	.port_fdb_dump		= mv88e6xxx_port_fdb_dump,
 };
 
-MODULE_ALIAS("platform:mv88e6172");
-MODULE_ALIAS("platform:mv88e6176");
-MODULE_ALIAS("platform:mv88e6320");
-MODULE_ALIAS("platform:mv88e6321");
-MODULE_ALIAS("platform:mv88e6352");
+static int mv88e6352_probe(struct mdio_device *mdiodev)
+{
+	return mv88e6xxx_probe(mdiodev, &mv88e6352_switch_driver,
+			       mv88e6352_table, ARRAY_SIZE(mv88e6352_table));
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
+	.remove = mv88e6xxx_remove,
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
index 9b568f39aaf0..9e906e0459c7 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -3170,40 +3170,51 @@ char *mv88e6xxx_drv_probe(struct device *dsa_dev, struct device *host_dev,
 }
 EXPORT_SYMBOL_GPL(mv88e6xxx_drv_probe);
 
-static int __init mv88e6xxx_init(void)
+int mv88e6xxx_probe(struct mdio_device *mdiodev, struct dsa_switch_driver *ops,
+		    const struct mv88e6xxx_switch_id *table,
+		    unsigned int table_size)
 {
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
+	struct device *dev = &mdiodev->dev;
+	struct mv88e6xxx_priv_state *ps;
+	struct dsa_switch *ds;
+	const char *name;
+
+	ds = devm_kzalloc(dev, sizeof(*ds) + sizeof(*ps), GFP_KERNEL);
+	if (!ds)
+		return -ENOMEM;
+
+	ps = (struct mv88e6xxx_priv_state *)(ds + 1);
+	ds->priv = ps;
+	ps->ds = ds;
+	ps->bus = mdiodev->bus;
+	ps->sw_addr = mdiodev->addr;
+
+	get_device(&ps->bus->dev);
+
+	ds->drv = ops;
+
+	name = mv88e6xxx_lookup_name(ps->bus, ps->sw_addr, table, table_size);
+	if (!name) {
+		dev_err(dev, "Failed to find switch");
+		return -ENODEV;
+	}
+
+	dev_set_drvdata(dev, ds);
+
 	return 0;
 }
-module_init(mv88e6xxx_init);
+EXPORT_SYMBOL_GPL(mv88e6xxx_probe);
 
-static void __exit mv88e6xxx_cleanup(void)
+void mv88e6xxx_remove(struct mdio_device *mdiodev)
 {
-#if IS_ENABLED(CONFIG_NET_DSA_MV88E6171)
-	unregister_switch_driver(&mv88e6171_switch_driver);
-#endif
-#if IS_ENABLED(CONFIG_NET_DSA_MV88E6352)
-	unregister_switch_driver(&mv88e6352_switch_driver);
-#endif
-#if IS_ENABLED(CONFIG_NET_DSA_MV88E6123)
-	unregister_switch_driver(&mv88e6123_switch_driver);
-#endif
-#if IS_ENABLED(CONFIG_NET_DSA_MV88E6131)
-	unregister_switch_driver(&mv88e6131_switch_driver);
-#endif
+	struct device *dev = &mdiodev->dev;
+	struct dsa_switch *ds = dev_get_drvdata(&mdiodev->dev);
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+
+	devm_kfree(dev, ds);
+	put_device(&ps->bus->dev);
 }
-module_exit(mv88e6xxx_cleanup);
+EXPORT_SYMBOL_GPL(mv88e6xxx_remove);
 
 MODULE_AUTHOR("Lennert Buytenhek <buytenh@wantstofly.org>");
 MODULE_DESCRIPTION("Driver for Marvell 88E6XXX ethernet switch chips");
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index afb9ebdfc595..3bdc0fdf692f 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -536,6 +536,11 @@ int mv88e6xxx_port_fdb_dump(struct dsa_switch *ds, int port,
 int mv88e6xxx_phy_page_read(struct dsa_switch *ds, int port, int page, int reg);
 int mv88e6xxx_phy_page_write(struct dsa_switch *ds, int port, int page,
 			     int reg, int val);
+int mv88e6xxx_probe(struct mdio_device *mdiodev, struct dsa_switch_driver *ops,
+		    const struct mv88e6xxx_switch_id *table,
+		    unsigned int table_size);
+void mv88e6xxx_remove(struct mdio_device *mdiodev);
+
 
 extern struct dsa_switch_driver mv88e6131_switch_driver;
 extern struct dsa_switch_driver mv88e6123_switch_driver;
-- 
2.7.0
