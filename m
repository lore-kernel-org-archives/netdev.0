From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 1/4] net: dsa: Pass device pointer to dsa_register_switch
Date: Tue,  5 Jul 2016 15:07:10 -0700
Message-ID: <1467756433-25062-2-git-send-email-f.fainelli@gmail.com>
References: <1467756433-25062-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:34638 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755725AbcGEWHV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 18:07:21 -0400
Received: by mail-pa0-f66.google.com with SMTP id us13so19321700pab.1
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2016 15:07:21 -0700 (PDT)
In-Reply-To: <1467756433-25062-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for allowing dsa_register_switch() to be supplied with
device/platform data, pass down a struct device pointer instead of a
struct device_node.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/b53/b53_common.c | 2 +-
 drivers/net/dsa/mv88e6xxx/chip.c | 7 +++----
 include/net/dsa.h                | 2 +-
 net/dsa/dsa2.c                   | 7 ++++---
 4 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index 444de66667b9..e5799a68cfc8 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -1778,7 +1778,7 @@ int b53_switch_register(struct b53_device *dev)
 
 	pr_info("found switch: %s, rev %i\n", dev->name, dev->core_rev);
 
-	return dsa_register_switch(dev->ds, dev->ds->dev->of_node);
+	return dsa_register_switch(dev->ds, dev->ds->dev);
 }
 EXPORT_SYMBOL(b53_switch_register);
 
diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 5cb06f7673af..11617c04cd33 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3848,8 +3848,7 @@ static struct dsa_switch_driver mv88e6xxx_switch_driver = {
 	.port_fdb_dump          = mv88e6xxx_port_fdb_dump,
 };
 
-static int mv88e6xxx_register_switch(struct mv88e6xxx_chip *chip,
-				     struct device_node *np)
+static int mv88e6xxx_register_switch(struct mv88e6xxx_chip *chip)
 {
 	struct device *dev = chip->dev;
 	struct dsa_switch *ds;
@@ -3864,7 +3863,7 @@ static int mv88e6xxx_register_switch(struct mv88e6xxx_chip *chip,
 
 	dev_set_drvdata(dev, ds);
 
-	return dsa_register_switch(ds, np);
+	return dsa_register_switch(ds, dev);
 }
 
 static void mv88e6xxx_unregister_switch(struct mv88e6xxx_chip *chip)
@@ -3911,7 +3910,7 @@ static int mv88e6xxx_probe(struct mdio_device *mdiodev)
 	if (err)
 		return err;
 
-	err = mv88e6xxx_register_switch(chip, np);
+	err = mv88e6xxx_register_switch(chip);
 	if (err) {
 		mv88e6xxx_mdio_unregister(chip);
 		return err;
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 20b3087ad193..6de162c8283e 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -381,5 +381,5 @@ static inline bool dsa_uses_tagged_protocol(struct dsa_switch_tree *dst)
 }
 
 void dsa_unregister_switch(struct dsa_switch *ds);
-int dsa_register_switch(struct dsa_switch *ds, struct device_node *np);
+int dsa_register_switch(struct dsa_switch *ds, struct device *dev);
 #endif
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 83b95fc4cede..0940a0ec83e6 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -590,8 +590,9 @@ static struct device_node *dsa_get_ports(struct dsa_switch *ds,
 	return ports;
 }
 
-static int _dsa_register_switch(struct dsa_switch *ds, struct device_node *np)
+static int _dsa_register_switch(struct dsa_switch *ds, struct device *dev)
 {
+	struct device_node *np = dev->of_node;
 	struct device_node *ports = dsa_get_ports(ds, np);
 	struct dsa_switch_tree *dst;
 	u32 tree, index;
@@ -660,12 +661,12 @@ out:
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
2.7.4
