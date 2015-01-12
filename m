From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/8] net: dsa: make module builds work
Date: Mon, 12 Jan 2015 13:57:40 -0800
Message-ID: <1421099866-3184-3-git-send-email-f.fainelli@gmail.com>
References: <1421099866-3184-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, buytenh@wantstofly.org,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:64093 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751304AbbALV54 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 16:57:56 -0500
Received: by mail-pd0-f182.google.com with SMTP id p10so32595496pdj.13
        for <netdev@vger.kernel.org>; Mon, 12 Jan 2015 13:57:55 -0800 (PST)
In-Reply-To: <1421099866-3184-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Building any DSA driver as a module will work from a compilation/linking
perspective, but the resulting modules produced are not functional.

Any DSA driver references register_switch_driver and
unregister_switch_driver which are provided by net/dsa/dsa.c, so loading
any of these modules prior to dsa_core.ko being loaded will faill.

Unfortunately, loading dsa_core.ko will make us call dsa_switch_probe()
which will find no DSA switch driver and return an error so we are stuck
there because there is no switch driver available. So this is getting us
nowhere.

This patch introduces a separate module, named dsa_lib which contains
register_switch_driver, unregister_switch_driver and dsa_switch_probe
(to avoid exposing the list and mutex used for walking switch drivers),
such that the following can be done:

- load dsa_lib
- load the dsa switch driver, e.g: mv88e6060, bcm_sf2
- load the dsa_core module

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/Makefile   |  2 ++
 net/dsa/dsa.c      | 49 ---------------------------------------
 net/dsa/dsa_lib.c  | 68 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/dsa/dsa_priv.h |  4 ++++
 4 files changed, 74 insertions(+), 49 deletions(-)
 create mode 100644 net/dsa/dsa_lib.c

diff --git a/net/dsa/Makefile b/net/dsa/Makefile
index da06ed1df620..17827194754d 100644
--- a/net/dsa/Makefile
+++ b/net/dsa/Makefile
@@ -2,6 +2,8 @@
 obj-$(CONFIG_NET_DSA) += dsa_core.o
 dsa_core-y += dsa.o slave.o
 
+obj-$(CONFIG_NET_DSA) += dsa_lib.o
+
 # tagging formats
 dsa_core-$(CONFIG_NET_DSA_TAG_BRCM) += tag_brcm.o
 dsa_core-$(CONFIG_NET_DSA_TAG_DSA) += tag_dsa.o
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 37317149f918..de77c83cfd9a 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -26,55 +26,6 @@
 char dsa_driver_version[] = "0.1";
 
 
-/* switch driver registration ***********************************************/
-static DEFINE_MUTEX(dsa_switch_drivers_mutex);
-static LIST_HEAD(dsa_switch_drivers);
-
-void register_switch_driver(struct dsa_switch_driver *drv)
-{
-	mutex_lock(&dsa_switch_drivers_mutex);
-	list_add_tail(&drv->list, &dsa_switch_drivers);
-	mutex_unlock(&dsa_switch_drivers_mutex);
-}
-EXPORT_SYMBOL_GPL(register_switch_driver);
-
-void unregister_switch_driver(struct dsa_switch_driver *drv)
-{
-	mutex_lock(&dsa_switch_drivers_mutex);
-	list_del_init(&drv->list);
-	mutex_unlock(&dsa_switch_drivers_mutex);
-}
-EXPORT_SYMBOL_GPL(unregister_switch_driver);
-
-static struct dsa_switch_driver *
-dsa_switch_probe(struct device *host_dev, int sw_addr, char **_name)
-{
-	struct dsa_switch_driver *ret;
-	struct list_head *list;
-	char *name;
-
-	ret = NULL;
-	name = NULL;
-
-	mutex_lock(&dsa_switch_drivers_mutex);
-	list_for_each(list, &dsa_switch_drivers) {
-		struct dsa_switch_driver *drv;
-
-		drv = list_entry(list, struct dsa_switch_driver, list);
-
-		name = drv->probe(host_dev, sw_addr);
-		if (name != NULL) {
-			ret = drv;
-			break;
-		}
-	}
-	mutex_unlock(&dsa_switch_drivers_mutex);
-
-	*_name = name;
-
-	return ret;
-}
-
 /* hwmon support ************************************************************/
 
 #ifdef CONFIG_NET_DSA_HWMON
diff --git a/net/dsa/dsa_lib.c b/net/dsa/dsa_lib.c
new file mode 100644
index 000000000000..2c496203c797
--- /dev/null
+++ b/net/dsa/dsa_lib.c
@@ -0,0 +1,68 @@
+/*
+ * net/dsa/dsa_lib.c - Hardware switch handling
+ * Copyright (c) 2008-2009 Marvell Semiconductor
+ * Copyright (c) 2015 Florian Fainelli <florian@openwrt.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/list.h>
+#include <linux/module.h>
+#include <linux/device.h>
+#include <net/dsa.h>
+#include "dsa_priv.h"
+
+/* switch driver registration ***********************************************/
+static DEFINE_MUTEX(dsa_switch_drivers_mutex);
+static LIST_HEAD(dsa_switch_drivers);
+
+void register_switch_driver(struct dsa_switch_driver *drv)
+{
+	mutex_lock(&dsa_switch_drivers_mutex);
+	list_add_tail(&drv->list, &dsa_switch_drivers);
+	mutex_unlock(&dsa_switch_drivers_mutex);
+}
+EXPORT_SYMBOL_GPL(register_switch_driver);
+
+void unregister_switch_driver(struct dsa_switch_driver *drv)
+{
+	mutex_lock(&dsa_switch_drivers_mutex);
+	list_del_init(&drv->list);
+	mutex_unlock(&dsa_switch_drivers_mutex);
+}
+EXPORT_SYMBOL_GPL(unregister_switch_driver);
+
+struct dsa_switch_driver *
+dsa_switch_probe(struct device *host_dev, int sw_addr, char **_name)
+{
+	struct dsa_switch_driver *ret;
+	struct list_head *list;
+	char *name;
+
+	ret = NULL;
+	name = NULL;
+
+	mutex_lock(&dsa_switch_drivers_mutex);
+	list_for_each(list, &dsa_switch_drivers) {
+		struct dsa_switch_driver *drv;
+
+		drv = list_entry(list, struct dsa_switch_driver, list);
+
+		name = drv->probe(host_dev, sw_addr);
+		if (name != NULL) {
+			ret = drv;
+			break;
+		}
+	}
+	mutex_unlock(&dsa_switch_drivers_mutex);
+
+	*_name = name;
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(dsa_switch_probe);
+
+MODULE_LICENSE("GPL");
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index e560ae53996c..1397b2894c1f 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -51,6 +51,10 @@ struct dsa_slave_priv {
 /* dsa.c */
 extern char dsa_driver_version[];
 
+/* dsa_lib.c */
+struct dsa_switch_driver *
+dsa_switch_probe(struct device *host_dev, int sw_addr, char **_name);
+
 /* slave.c */
 extern const struct dsa_device_ops notag_netdev_ops;
 void dsa_slave_mii_bus_init(struct dsa_switch *ds);
-- 
2.1.0
