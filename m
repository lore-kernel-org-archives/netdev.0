From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 1/4] net: dsa: Pass device pointer to dsa_register_switch
Date: Thu, 26 Jan 2017 10:45:51 -0800
Message-ID: <20170126184554.1325-2-f.fainelli@gmail.com>
References: <20170126184554.1325-1-f.fainelli@gmail.com>
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34106 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752083AbdAZSq3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 13:46:29 -0500
Received: by mail-pg0-f66.google.com with SMTP id 3so5220115pgj.1
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 10:46:01 -0800 (PST)
In-Reply-To: <20170126184554.1325-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for allowing dsa_register_switch() to be supplied with
device/platform data, pass down a struct device pointer instead of a
struct device_node.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/b53/b53_common.c | 2 +-
 drivers/net/dsa/mv88e6xxx/chip.c | 7 +++----
 drivers/net/dsa/qca8k.c          | 2 +-
 include/net/dsa.h                | 2 +-
 net/dsa/dsa2.c                   | 7 ++++---
 5 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index 5cbb14f6a03b..bb210b12ad1b 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -1894,7 +1894,7 @@ int b53_switch_register(struct b53_device *dev)
 
 	pr_info("found switch: %s, rev %i\n", dev->name, dev->core_rev);
 
-	return dsa_register_switch(dev->ds, dev->ds->dev->of_node);
+	return dsa_register_switch(dev->ds, dev->ds->dev);
 }
 EXPORT_SYMBOL(b53_switch_register);
 
diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 5668e778ed1d..921e53351786 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -4356,8 +4356,7 @@ static struct dsa_switch_driver mv88e6xxx_switch_drv = {
 	.ops			= &mv88e6xxx_switch_ops,
 };
 
-static int mv88e6xxx_register_switch(struct mv88e6xxx_chip *chip,
-				     struct device_node *np)
+static int mv88e6xxx_register_switch(struct mv88e6xxx_chip *chip)
 {
 	struct device *dev = chip->dev;
 	struct dsa_switch *ds;
@@ -4372,7 +4371,7 @@ static int mv88e6xxx_register_switch(struct mv88e6xxx_chip *chip,
 
 	dev_set_drvdata(dev, ds);
 
-	return dsa_register_switch(ds, np);
+	return dsa_register_switch(ds, dev);
 }
 
 static void mv88e6xxx_unregister_switch(struct mv88e6xxx_chip *chip)
@@ -4456,7 +4455,7 @@ static int mv88e6xxx_probe(struct mdio_device *mdiodev)
 	if (err)
 		goto out_g2_irq;
 
-	err = mv88e6xxx_register_switch(chip, np);
+	err = mv88e6xxx_register_switch(chip);
 	if (err)
 		goto out_mdio;
 
diff --git a/drivers/net/dsa/qca8k.c b/drivers/net/dsa/qca8k.c
index 54d270d59eb0..c084aa484d2b 100644
--- a/drivers/net/dsa/qca8k.c
+++ b/drivers/net/dsa/qca8k.c
@@ -964,7 +964,7 @@ qca8k_sw_probe(struct mdio_device *mdiodev)
 	mutex_init(&priv->reg_mutex);
 	dev_set_drvdata(&mdiodev->dev, priv);
 
-	return dsa_register_switch(priv->ds, priv->ds->dev->of_node);
+	return dsa_register_switch(priv->ds, &mdiodev->dev);
 }
 
 static void
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 08b340403927..92fd795e9573 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -387,7 +387,7 @@ static inline bool dsa_uses_tagged_protocol(struct dsa_switch_tree *dst)
 }
 
 void dsa_unregister_switch(struct dsa_switch *ds);
-int dsa_register_switch(struct dsa_switch *ds, struct device_node *np);
+int dsa_register_switch(struct dsa_switch *ds, struct device *dev);
 #ifdef CONFIG_PM_SLEEP
 int dsa_switch_suspend(struct dsa_switch *ds);
 int dsa_switch_resume(struct dsa_switch *ds);
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 866222a8f9bf..2cf489c5e90f 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -578,8 +578,9 @@ static struct device_node *dsa_get_ports(struct dsa_switch *ds,
 	return ports;
 }
 
-static int _dsa_register_switch(struct dsa_switch *ds, struct device_node *np)
+static int _dsa_register_switch(struct dsa_switch *ds, struct device *dev)
 {
+	struct device_node *np = dev->of_node;
 	struct device_node *ports = dsa_get_ports(ds, np);
 	struct dsa_switch_tree *dst;
 	u32 tree, index;
@@ -659,12 +660,12 @@ static int _dsa_register_switch(struct dsa_switch *ds, struct device_node *np)
 	return err;
 }
 
-int dsa_register_switch(struct dsa_switch *ds, struct device_node *np)
+int dsa_register_switch(struct dsa_switch *ds, struct device *dev)
 {
 	int err;
 
 	mutex_lock(&dsa2_mutex);
-	err = _dsa_register_switch(ds, np);
+	err = _dsa_register_switch(ds, dev);
 	mutex_unlock(&dsa2_mutex);
 
 	return err;
-- 
2.9.3
