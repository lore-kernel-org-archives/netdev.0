From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC v2 17/32] dsa: mv88e6xxx: Add shared code for binding/unbinding a switch driver.
Date: Sun, 28 Feb 2016 17:41:25 +0100
Message-ID: <1456677700-23027-18-git-send-email-andrew@lunn.ch>
References: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
Cc: Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44930 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759408AbcB1QmU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Feb 2016 11:42:20 -0500
In-Reply-To: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Switch drivers are component slaves. When they are bound to a master
component, the bind function is called and resources can be reserved.
Add the shared code.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx.c | 77 ++++++++++++++++++++++++++++++++++++++-------
 drivers/net/dsa/mv88e6xxx.h |  5 +++
 2 files changed, 71 insertions(+), 11 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 7f67bf47cdb6..4a4af245b0eb 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -4,6 +4,7 @@
  *
  * Copyright (c) 2015 CMC Electronics, Inc.
  *	Added support for VLAN Table Unit operations
+ * Copyright (c) 2015 Andrew Lunn <andrew@lunn.ch>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -12,14 +13,16 @@
  */
 
 #include <linux/delay.h>
+#include <linux/device.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
+#include <linux/gpio/consumer.h>
 #include <linux/if_bridge.h>
 #include <linux/jiffies.h>
 #include <linux/list.h>
+#include <linux/mdio.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
-#include <linux/gpio/consumer.h>
 #include <linux/phy.h>
 #include <net/dsa.h>
 #include <net/switchdev.h>
@@ -2196,19 +2199,22 @@ int mv88e6xxx_setup_ports(struct dsa_switch *ds)
 
 int mv88e6xxx_setup_common(struct dsa_switch *ds, struct device *dev)
 {
-	struct mv88e6xxx_priv_state *ps;
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 
-	ps = devm_kzalloc(dev, sizeof(*ps), GFP_KERNEL);
-	if (!ps)
-		return -ENOMEM;
+	if (!ps) {
+		ps = devm_kzalloc(dev, sizeof(*ps), GFP_KERNEL);
+		if (!ps)
+			return -ENOMEM;
 
-	ds->priv = ps;
-	ps->ds = ds;
-	ps->bus = dsa_host_dev_to_mii_bus(ds->master_dev);
-	if (!ps->bus)
-		return -ENODEV;
+		ds->priv = ps;
+		ps->ds = ds;
 
-	ps->sw_addr = ds->pd->sw_addr;
+		ps->bus = dsa_host_dev_to_mii_bus(ds->master_dev);
+		if (!ps->bus)
+			return -ENODEV;
+
+		ps->sw_addr = ds->pd->sw_addr;
+	}
 
 	mutex_init(&ps->smi_mutex);
 
@@ -2654,6 +2660,55 @@ char *mv88e6xxx_lookup_name(struct mii_bus *bus, int sw_addr,
 	return NULL;
 }
 
+int mv88e6xxx_bind(struct device *dev,
+		   struct dsa_switch_tree *dst,
+		   struct dsa_switch_driver *ops,
+		   const struct mv88e6xxx_switch_id *table,
+		   unsigned int table_size)
+{
+	struct mdio_device *mdiodev = to_mdio_device(dev);
+	struct mv88e6xxx_priv_state *ps;
+	struct device_node *np = dev->of_node;
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
+	dsa_switch_register(dst, ds, np, name);
+
+	return 0;
+}
+
+void mv88e6xxx_unbind(struct device *dev, struct device *master, void *data)
+{
+	struct dsa_switch *ds = dev_get_drvdata(dev);
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+
+	dsa_switch_unregister(ds);
+	devm_kfree(dev, ds);
+
+	put_device(&ps->bus->dev);
+}
+
 static int __init mv88e6xxx_init(void)
 {
 #if IS_ENABLED(CONFIG_NET_DSA_MV88E6131)
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index dce72d1007c2..a4ae99b7cfd0 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -447,6 +447,11 @@ int mv88e6xxx_switch_reset(struct dsa_switch *ds, bool ppu_active);
 char *mv88e6xxx_lookup_name(struct mii_bus *bus, int sw_addr,
 			    const struct mv88e6xxx_switch_id *table,
 			    unsigned int num);
+int mv88e6xxx_bind(struct device *dev, struct dsa_switch_tree *dst,
+		   struct dsa_switch_driver *ops,
+		   const struct mv88e6xxx_switch_id *table,
+		   unsigned int table_size);
+void mv88e6xxx_unbind(struct device *dev, struct device *master, void *data);
 int mv88e6xxx_setup_ports(struct dsa_switch *ds);
 int mv88e6xxx_setup_common(struct dsa_switch *ds, struct device *dev);
 int mv88e6xxx_setup_global(struct dsa_switch *ds);
-- 
2.7.0
