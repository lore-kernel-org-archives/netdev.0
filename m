From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v1 net-next 3/7] dsa: Add mdio device support to Marvell switches
Date: Tue, 10 May 2016 23:27:21 +0200
Message-ID: <1462915645-24674-4-git-send-email-andrew@lunn.ch>
References: <1462915645-24674-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34984 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751293AbcEJV23 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2016 17:28:29 -0400
In-Reply-To: <1462915645-24674-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow Marvell switches to be mdio devices. Currently the driver just
allocate the private structure and detects what device is on the
bus. Later patches will make them register with the DSA framework.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 .../devicetree/bindings/net/dsa/marvell.txt        | 27 +++++++
 drivers/net/dsa/mv88e6xxx.c                        | 90 +++++++++++++++++-----
 2 files changed, 99 insertions(+), 18 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/dsa/marvell.txt

diff --git a/Documentation/devicetree/bindings/net/dsa/marvell.txt b/Documentation/devicetree/bindings/net/dsa/marvell.txt
new file mode 100644
index 000000000000..cdd70cebdea7
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/dsa/marvell.txt
@@ -0,0 +1,27 @@
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
+- compatible           : Should be one of "marvell,mv88e6085",
+- reg                  : Address on the MII bus for the switch.
+
+Example:
+
+       mdio {
+               #address-cells = <1>;
+               #size-cells = <0>;
+
+               switch0: switch@0 {
+                       compatible = "marvell,mv88e6085";
+                       reg = <0>;
+               };
+       };
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 199a8628df2b..e5ba04132140 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -5,6 +5,8 @@
  * Copyright (c) 2015 CMC Electronics, Inc.
  *	Added support for VLAN Table Unit operations
  *
+ * Copyright (c) 2016 Andrew Lunn <andrew@lunn.ch>
+ *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation; either version 2 of the License, or
@@ -17,6 +19,7 @@
 #include <linux/if_bridge.h>
 #include <linux/jiffies.h>
 #include <linux/list.h>
+#include <linux/mdio.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/gpio/consumer.h>
@@ -3611,36 +3614,87 @@ struct dsa_switch_driver mv88e6xxx_switch_driver = {
 	.port_fdb_dump          = mv88e6xxx_port_fdb_dump,
 };
 
-static int __init mv88e6xxx_init(void)
+int mv88e6xxx_probe(struct mdio_device *mdiodev)
 {
-	register_switch_driver(&mv88e6xxx_switch_driver);
+	struct device *dev = &mdiodev->dev;
+	struct mv88e6xxx_priv_state *ps;
+	int id, prod_num, rev;
+	struct dsa_switch *ds;
+
+	ds = devm_kzalloc(dev, sizeof(*ds) + sizeof(*ps), GFP_KERNEL);
+	if (!ds)
+		return -ENOMEM;
+
+	ps = (struct mv88e6xxx_priv_state *)(ds + 1);
+	ds->priv = ps;
+	ps->dev = dev;
+	ps->ds = ds;
+	ps->bus = mdiodev->bus;
+	ps->sw_addr = mdiodev->addr;
+	mutex_init(&ps->smi_mutex);
+
+	get_device(&ps->bus->dev);
+
+	ds->drv = &mv88e6xxx_switch_driver;
+
+	id = mv88e6xxx_reg_read(ps, REG_PORT(0), PORT_SWITCH_ID);
+	if (id < 0)
+		return id;
+
+	prod_num = (id & 0xfff0) >> 4;
+	rev = id & 0x000f;
+
+	ps->info = mv88e6xxx_lookup_info(prod_num, mv88e6xxx_table,
+					 ARRAY_SIZE(mv88e6xxx_table));
+	if (!ps->info)
+		return -ENODEV;
+
+	dev_set_drvdata(dev, ds);
+
+	dev_info(dev, "switch 0x%x probed: %s, revision %u\n",
+		 prod_num, ps->info->name, rev);
 
 	return 0;
 }
+
+static void mv88e6xxx_remove(struct mdio_device *mdiodev)
+{
+	struct dsa_switch *ds = dev_get_drvdata(&mdiodev->dev);
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+
+	put_device(&ps->bus->dev);
+}
+
+static const struct of_device_id mv88e6xxx_of_match[] = {
+	{ .compatible = "marvell,mv88e6085" },
+	{ /* sentinel */ },
+};
+
+MODULE_DEVICE_TABLE(of, mv88e6xxx_of_match);
+
+static struct mdio_driver mv88e6xxx_driver = {
+	.probe	= mv88e6xxx_probe,
+	.remove = mv88e6xxx_remove,
+	.mdiodrv.driver = {
+		.name = "mv88e6085",
+		.of_match_table = mv88e6xxx_of_match,
+	},
+};
+
+static int __init mv88e6xxx_init(void)
+{
+	register_switch_driver(&mv88e6xxx_switch_driver);
+	return mdio_driver_register(&mv88e6xxx_driver);
+}
 module_init(mv88e6xxx_init);
 
 static void __exit mv88e6xxx_cleanup(void)
 {
+	mdio_driver_unregister(&mv88e6xxx_driver);
 	unregister_switch_driver(&mv88e6xxx_switch_driver);
 }
 module_exit(mv88e6xxx_cleanup);
 
-MODULE_ALIAS("platform:mv88e6085");
-MODULE_ALIAS("platform:mv88e6095");
-MODULE_ALIAS("platform:mv88e6095f");
-MODULE_ALIAS("platform:mv88e6123");
-MODULE_ALIAS("platform:mv88e6131");
-MODULE_ALIAS("platform:mv88e6161");
-MODULE_ALIAS("platform:mv88e6165");
-MODULE_ALIAS("platform:mv88e6171");
-MODULE_ALIAS("platform:mv88e6172");
-MODULE_ALIAS("platform:mv88e6175");
-MODULE_ALIAS("platform:mv88e6176");
-MODULE_ALIAS("platform:mv88e6320");
-MODULE_ALIAS("platform:mv88e6321");
-MODULE_ALIAS("platform:mv88e6350");
-MODULE_ALIAS("platform:mv88e6351");
-MODULE_ALIAS("platform:mv88e6352");
 MODULE_AUTHOR("Lennert Buytenhek <buytenh@wantstofly.org>");
 MODULE_DESCRIPTION("Driver for Marvell 88E6XXX ethernet switch chips");
 MODULE_LICENSE("GPL");
-- 
2.8.1
