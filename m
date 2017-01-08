From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/4] net: dsa: Encapsulate legacy switch drivers into dsa_switch_driver
Date: Sun,  8 Jan 2017 14:52:07 -0800
Message-ID: <20170108225208.15431-4-f.fainelli@gmail.com>
References: <20170108225208.15431-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36092 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757265AbdAHW5d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Jan 2017 17:57:33 -0500
Received: by mail-pg0-f67.google.com with SMTP id 75so11595662pgf.3
        for <netdev@vger.kernel.org>; Sun, 08 Jan 2017 14:57:33 -0800 (PST)
In-Reply-To: <20170108225208.15431-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for making struct dsa_switch_ops const, encapsulate it
within a dsa_switch_driver which has a list pointer and a pointer to
dsa_switch_ops. This allows us to take the list_head pointer out of
dsa_switch_ops, which is written to by {un,}register_switch_driver.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/mv88e6060.c      |  8 ++++++--
 drivers/net/dsa/mv88e6xxx/chip.c |  8 ++++++--
 include/net/dsa.h                | 11 +++++++----
 net/dsa/dsa.c                    | 12 +++++++-----
 4 files changed, 26 insertions(+), 13 deletions(-)

diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
index 7ce36dbd9b62..bcbd6dcbd8e8 100644
--- a/drivers/net/dsa/mv88e6060.c
+++ b/drivers/net/dsa/mv88e6060.c
@@ -261,16 +261,20 @@ static struct dsa_switch_ops mv88e6060_switch_ops = {
 	.phy_write	= mv88e6060_phy_write,
 };
 
+static struct dsa_switch_driver mv88e6060_switch_drv = {
+	.ops		= &mv88e6060_switch_ops,
+};
+
 static int __init mv88e6060_init(void)
 {
-	register_switch_driver(&mv88e6060_switch_ops);
+	register_switch_driver(&mv88e6060_switch_drv);
 	return 0;
 }
 module_init(mv88e6060_init);
 
 static void __exit mv88e6060_cleanup(void)
 {
-	unregister_switch_driver(&mv88e6060_switch_ops);
+	unregister_switch_driver(&mv88e6060_switch_drv);
 }
 module_exit(mv88e6060_cleanup);
 
diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 676b0e2ad221..d43d12c281b3 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -4403,6 +4403,10 @@ static struct dsa_switch_ops mv88e6xxx_switch_ops = {
 	.port_mdb_dump          = mv88e6xxx_port_mdb_dump,
 };
 
+static struct dsa_switch_driver mv88e6xxx_switch_drv = {
+	.ops			= &mv88e6xxx_switch_ops,
+};
+
 static int mv88e6xxx_register_switch(struct mv88e6xxx_chip *chip,
 				     struct device_node *np)
 {
@@ -4565,7 +4569,7 @@ static struct mdio_driver mv88e6xxx_driver = {
 
 static int __init mv88e6xxx_init(void)
 {
-	register_switch_driver(&mv88e6xxx_switch_ops);
+	register_switch_driver(&mv88e6xxx_switch_drv);
 	return mdio_driver_register(&mv88e6xxx_driver);
 }
 module_init(mv88e6xxx_init);
@@ -4573,7 +4577,7 @@ module_init(mv88e6xxx_init);
 static void __exit mv88e6xxx_cleanup(void)
 {
 	mdio_driver_unregister(&mv88e6xxx_driver);
-	unregister_switch_driver(&mv88e6xxx_switch_ops);
+	unregister_switch_driver(&mv88e6xxx_switch_drv);
 }
 module_exit(mv88e6xxx_cleanup);
 
diff --git a/include/net/dsa.h b/include/net/dsa.h
index b122196d5a1f..edfa9b130953 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -240,8 +240,6 @@ struct switchdev_obj_port_mdb;
 struct switchdev_obj_port_vlan;
 
 struct dsa_switch_ops {
-	struct list_head	list;
-
 	/*
 	 * Probing and setup.
 	 */
@@ -390,8 +388,13 @@ struct dsa_switch_ops {
 				 int (*cb)(struct switchdev_obj *obj));
 };
 
-void register_switch_driver(struct dsa_switch_ops *type);
-void unregister_switch_driver(struct dsa_switch_ops *type);
+struct dsa_switch_driver {
+	struct list_head	list;
+	struct dsa_switch_ops	*ops;
+};
+
+void register_switch_driver(struct dsa_switch_driver *type);
+void unregister_switch_driver(struct dsa_switch_driver *type);
 struct mii_bus *dsa_host_dev_to_mii_bus(struct device *dev);
 
 static inline bool dsa_uses_tagged_protocol(struct dsa_switch_tree *dst)
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index cda787ebad15..4e7bc57cdae5 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -60,18 +60,18 @@ const struct dsa_device_ops *dsa_device_ops[DSA_TAG_LAST] = {
 static DEFINE_MUTEX(dsa_switch_drivers_mutex);
 static LIST_HEAD(dsa_switch_drivers);
 
-void register_switch_driver(struct dsa_switch_ops *ops)
+void register_switch_driver(struct dsa_switch_driver *drv)
 {
 	mutex_lock(&dsa_switch_drivers_mutex);
-	list_add_tail(&ops->list, &dsa_switch_drivers);
+	list_add_tail(&drv->list, &dsa_switch_drivers);
 	mutex_unlock(&dsa_switch_drivers_mutex);
 }
 EXPORT_SYMBOL_GPL(register_switch_driver);
 
-void unregister_switch_driver(struct dsa_switch_ops *ops)
+void unregister_switch_driver(struct dsa_switch_driver *drv)
 {
 	mutex_lock(&dsa_switch_drivers_mutex);
-	list_del_init(&ops->list);
+	list_del_init(&drv->list);
 	mutex_unlock(&dsa_switch_drivers_mutex);
 }
 EXPORT_SYMBOL_GPL(unregister_switch_driver);
@@ -90,8 +90,10 @@ dsa_switch_probe(struct device *parent, struct device *host_dev, int sw_addr,
 	mutex_lock(&dsa_switch_drivers_mutex);
 	list_for_each(list, &dsa_switch_drivers) {
 		struct dsa_switch_ops *ops;
+		struct dsa_switch_driver *drv;
 
-		ops = list_entry(list, struct dsa_switch_ops, list);
+		drv = list_entry(list, struct dsa_switch_driver, list);
+		ops = drv->ops;
 
 		name = ops->probe(parent, host_dev, sw_addr, priv);
 		if (name != NULL) {
-- 
2.9.3
