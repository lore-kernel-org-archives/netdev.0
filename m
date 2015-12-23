From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC 17/28] dsa: mv88e6xxx: Add shared code for binding/unbinding a switch driver.
Date: Wed, 23 Dec 2015 13:56:31 +0100
Message-ID: <1450875402-20740-18-git-send-email-andrew@lunn.ch>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>, narmstrong@baylibre.com,
	vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48808 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755877AbbLWM7B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2015 07:59:01 -0500
In-Reply-To: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Switch drivers are component slaves. When they are bound to a master
component, the bind function is called and resources can be reserved.
Add the shared code.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx.c | 72 +++++++++++++++++++++++++++++++++++++++------
 drivers/net/dsa/mv88e6xxx.h |  5 ++++
 2 files changed, 68 insertions(+), 9 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 23b0ff9f0154..36921c3a1cf0 100644
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
 #include <linux/module.h>
 #include <linux/netdevice.h>
-#include <linux/gpio/consumer.h>
+#include <linux/of_mdio.h>
 #include <linux/phy.h>
 #include <net/dsa.h>
 #include <net/switchdev.h>
@@ -2183,16 +2186,18 @@ int mv88e6xxx_setup_ports(struct dsa_switch *ds)
 
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
-	ps->sw_addr = ds->pd->sw_addr;
+		ds->priv = ps;
+		ps->ds = ds;
+		ps->bus = dsa_host_dev_to_mii_bus(ds->master_dev);
+		ps->sw_addr = ds->pd->sw_addr;
+	}
 
 	mutex_init(&ps->smi_mutex);
 
@@ -2635,6 +2640,55 @@ char *mv88e6xxx_lookup_name(struct mii_bus *bus, int sw_addr,
 	return NULL;
 }
 
+int mv88e6xxx_bind(struct device *dev,
+		   struct dsa_switch_tree *dst,
+		   struct dsa_switch_driver *ops,
+		   const struct mv88e6xxx_switch_id *table,
+		   unsigned int table_size)
+{
+	struct mv88e6xxx_priv_state *ps;
+	struct device_node *np = dev->of_node;
+	struct dsa_switch *ds;
+	const char *name;
+	int ret = 0;
+
+	ds = devm_kzalloc(dev, sizeof(*ds) + sizeof(*ps), GFP_KERNEL);
+	if (!ds)
+		return -ENOMEM;
+
+	ps = (struct mv88e6xxx_priv_state *)(ds + 1);
+	ds->priv = ps;
+	ps->ds = ds;
+
+	ret = of_mdio_parse_bus_and_addr(dev, np, &ps->bus, &ps->sw_addr);
+	if (ret)
+		return ret;
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
+	put_device(&ps->bus->dev);
+}
+
 static int __init mv88e6xxx_init(void)
 {
 #if IS_ENABLED(CONFIG_NET_DSA_MV88E6131)
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 441aec066294..376b1b78c80c 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -439,6 +439,11 @@ int mv88e6xxx_switch_reset(struct dsa_switch *ds, bool ppu_active);
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
2.6.3
