From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 2/3] net: dsa: move HWMON support to its own file
Date: Tue,  3 Jan 2017 13:15:37 -0500
Message-ID: <20170103181538.2593-3-vivien.didelot@savoirfairelinux.com>
References: <20170103181538.2593-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, cphealy@gmail.com,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:45688 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965476AbdACSQK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 13:16:10 -0500
In-Reply-To: <20170103181538.2593-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The HWMON support in DSA is currently embedded in the legacy DSA code.
Move it out in its own file, so that it can be reused in newer DSA code.
---
 net/dsa/Makefile   |   1 +
 net/dsa/dsa.c      | 131 +---------------------------------------------
 net/dsa/dsa_priv.h |   9 ++++
 net/dsa/hwmon.c    | 149 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 161 insertions(+), 129 deletions(-)
 create mode 100644 net/dsa/hwmon.c

diff --git a/net/dsa/Makefile b/net/dsa/Makefile
index a3380ed0e0be..560b6747c276 100644
--- a/net/dsa/Makefile
+++ b/net/dsa/Makefile
@@ -1,6 +1,7 @@
 # the core
 obj-$(CONFIG_NET_DSA) += dsa_core.o
 dsa_core-y += dsa.o slave.o dsa2.o
+dsa_core-$(CONFIG_NET_DSA_HWMON) += hwmon.o
 
 # tagging formats
 dsa_core-$(CONFIG_NET_DSA_TAG_BRCM) += tag_brcm.o
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 89e66b623d73..aa73f923e9b5 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -9,9 +9,7 @@
  * (at your option) any later version.
  */
 
-#include <linux/ctype.h>
 #include <linux/device.h>
-#include <linux/hwmon.h>
 #include <linux/list.h>
 #include <linux/platform_device.h>
 #include <linux/slab.h>
@@ -110,105 +108,6 @@ dsa_switch_probe(struct device *parent, struct device *host_dev, int sw_addr,
 	return ret;
 }
 
-/* hwmon support ************************************************************/
-
-#ifdef CONFIG_NET_DSA_HWMON
-
-static ssize_t temp1_input_show(struct device *dev,
-				struct device_attribute *attr, char *buf)
-{
-	struct dsa_switch *ds = dev_get_drvdata(dev);
-	int temp, ret;
-
-	ret = ds->ops->get_temp(ds, &temp);
-	if (ret < 0)
-		return ret;
-
-	return sprintf(buf, "%d\n", temp * 1000);
-}
-static DEVICE_ATTR_RO(temp1_input);
-
-static ssize_t temp1_max_show(struct device *dev,
-			      struct device_attribute *attr, char *buf)
-{
-	struct dsa_switch *ds = dev_get_drvdata(dev);
-	int temp, ret;
-
-	ret = ds->ops->get_temp_limit(ds, &temp);
-	if (ret < 0)
-		return ret;
-
-	return sprintf(buf, "%d\n", temp * 1000);
-}
-
-static ssize_t temp1_max_store(struct device *dev,
-			       struct device_attribute *attr, const char *buf,
-			       size_t count)
-{
-	struct dsa_switch *ds = dev_get_drvdata(dev);
-	int temp, ret;
-
-	ret = kstrtoint(buf, 0, &temp);
-	if (ret < 0)
-		return ret;
-
-	ret = ds->ops->set_temp_limit(ds, DIV_ROUND_CLOSEST(temp, 1000));
-	if (ret < 0)
-		return ret;
-
-	return count;
-}
-static DEVICE_ATTR_RW(temp1_max);
-
-static ssize_t temp1_max_alarm_show(struct device *dev,
-				    struct device_attribute *attr, char *buf)
-{
-	struct dsa_switch *ds = dev_get_drvdata(dev);
-	bool alarm;
-	int ret;
-
-	ret = ds->ops->get_temp_alarm(ds, &alarm);
-	if (ret < 0)
-		return ret;
-
-	return sprintf(buf, "%d\n", alarm);
-}
-static DEVICE_ATTR_RO(temp1_max_alarm);
-
-static struct attribute *dsa_hwmon_attrs[] = {
-	&dev_attr_temp1_input.attr,	/* 0 */
-	&dev_attr_temp1_max.attr,	/* 1 */
-	&dev_attr_temp1_max_alarm.attr,	/* 2 */
-	NULL
-};
-
-static umode_t dsa_hwmon_attrs_visible(struct kobject *kobj,
-				       struct attribute *attr, int index)
-{
-	struct device *dev = container_of(kobj, struct device, kobj);
-	struct dsa_switch *ds = dev_get_drvdata(dev);
-	struct dsa_switch_ops *ops = ds->ops;
-	umode_t mode = attr->mode;
-
-	if (index == 1) {
-		if (!ops->get_temp_limit)
-			mode = 0;
-		else if (!ops->set_temp_limit)
-			mode &= ~S_IWUSR;
-	} else if (index == 2 && !ops->get_temp_alarm) {
-		mode = 0;
-	}
-	return mode;
-}
-
-static const struct attribute_group dsa_hwmon_group = {
-	.attrs = dsa_hwmon_attrs,
-	.is_visible = dsa_hwmon_attrs_visible,
-};
-__ATTRIBUTE_GROUPS(dsa_hwmon);
-
-#endif /* CONFIG_NET_DSA_HWMON */
-
 /* basic switch operations **************************************************/
 int dsa_cpu_dsa_setup(struct dsa_switch *ds, struct device *dev,
 		      struct device_node *port_dn, int port)
@@ -417,30 +316,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 	if (ret)
 		return ret;
 
-#ifdef CONFIG_NET_DSA_HWMON
-	/* If the switch provides a temperature sensor,
-	 * register with hardware monitoring subsystem.
-	 * Treat registration error as non-fatal and ignore it.
-	 */
-	if (ops->get_temp) {
-		const char *netname = netdev_name(dst->master_netdev);
-		char hname[IFNAMSIZ + 1];
-		int i, j;
-
-		/* Create valid hwmon 'name' attribute */
-		for (i = j = 0; i < IFNAMSIZ && netname[i]; i++) {
-			if (isalnum(netname[i]))
-				hname[j++] = netname[i];
-		}
-		hname[j] = '\0';
-		scnprintf(ds->hwmon_name, sizeof(ds->hwmon_name), "%s_dsa%d",
-			  hname, index);
-		ds->hwmon_dev = hwmon_device_register_with_groups(NULL,
-					ds->hwmon_name, ds, dsa_hwmon_groups);
-		if (IS_ERR(ds->hwmon_dev))
-			ds->hwmon_dev = NULL;
-	}
-#endif /* CONFIG_NET_DSA_HWMON */
+	dsa_hwmon_register(ds);
 
 	return 0;
 }
@@ -500,10 +376,7 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
 {
 	int port;
 
-#ifdef CONFIG_NET_DSA_HWMON
-	if (ds->hwmon_dev)
-		hwmon_device_unregister(ds->hwmon_dev);
-#endif
+	dsa_hwmon_unregister(ds);
 
 	/* Destroy network devices for physical switch ports. */
 	for (port = 0; port < DSA_MAX_PORTS; port++) {
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 6cfd7388834e..8cdbc4a7b678 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -57,6 +57,15 @@ const struct dsa_device_ops *dsa_resolve_tag_protocol(int tag_protocol);
 int dsa_cpu_port_ethtool_setup(struct dsa_switch *ds);
 void dsa_cpu_port_ethtool_restore(struct dsa_switch *ds);
 
+/* hwmon.c */
+#if CONFIG_NET_DSA_HWMON
+void dsa_hwmon_register(struct dsa_switch *ds);
+void dsa_hwmon_unregister(struct dsa_switch *ds);
+#else
+static inline void dsa_hwmon_register(struct dsa_switch *ds) { }
+static inline void dsa_hwmon_unregister(struct dsa_switch *ds) { }
+#endif
+
 /* slave.c */
 extern const struct dsa_device_ops notag_netdev_ops;
 void dsa_slave_mii_bus_init(struct dsa_switch *ds);
diff --git a/net/dsa/hwmon.c b/net/dsa/hwmon.c
new file mode 100644
index 000000000000..7b3d1a9c2be2
--- /dev/null
+++ b/net/dsa/hwmon.c
@@ -0,0 +1,149 @@
+/*
+ * net/dsa/hwmon.c - HWMON subsystem support
+ * Copyright (c) 2014 Guenter Roeck <linux@roeck-us.net>
+ * Copyright (c) 2017 Vivien Didelot <vivien.didelot@savoirfairelinux.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/ctype.h>
+#include <linux/hwmon.h>
+#include <net/dsa.h>
+
+#include "dsa_priv.h"
+
+static ssize_t temp1_input_show(struct device *dev,
+				struct device_attribute *attr, char *buf)
+{
+	struct dsa_switch *ds = dev_get_drvdata(dev);
+	int temp, ret;
+
+	ret = ds->ops->get_temp(ds, &temp);
+	if (ret < 0)
+		return ret;
+
+	return sprintf(buf, "%d\n", temp * 1000);
+}
+static DEVICE_ATTR_RO(temp1_input);
+
+static ssize_t temp1_max_show(struct device *dev,
+			      struct device_attribute *attr, char *buf)
+{
+	struct dsa_switch *ds = dev_get_drvdata(dev);
+	int temp, ret;
+
+	ret = ds->ops->get_temp_limit(ds, &temp);
+	if (ret < 0)
+		return ret;
+
+	return sprintf(buf, "%d\n", temp * 1000);
+}
+
+static ssize_t temp1_max_store(struct device *dev,
+			       struct device_attribute *attr, const char *buf,
+			       size_t count)
+{
+	struct dsa_switch *ds = dev_get_drvdata(dev);
+	int temp, ret;
+
+	ret = kstrtoint(buf, 0, &temp);
+	if (ret < 0)
+		return ret;
+
+	ret = ds->ops->set_temp_limit(ds, DIV_ROUND_CLOSEST(temp, 1000));
+	if (ret < 0)
+		return ret;
+
+	return count;
+}
+static DEVICE_ATTR_RW(temp1_max);
+
+static ssize_t temp1_max_alarm_show(struct device *dev,
+				    struct device_attribute *attr, char *buf)
+{
+	struct dsa_switch *ds = dev_get_drvdata(dev);
+	bool alarm;
+	int ret;
+
+	ret = ds->ops->get_temp_alarm(ds, &alarm);
+	if (ret < 0)
+		return ret;
+
+	return sprintf(buf, "%d\n", alarm);
+}
+static DEVICE_ATTR_RO(temp1_max_alarm);
+
+static struct attribute *dsa_hwmon_attrs[] = {
+	&dev_attr_temp1_input.attr,	/* 0 */
+	&dev_attr_temp1_max.attr,	/* 1 */
+	&dev_attr_temp1_max_alarm.attr,	/* 2 */
+	NULL
+};
+
+static umode_t dsa_hwmon_attrs_visible(struct kobject *kobj,
+				       struct attribute *attr, int index)
+{
+	struct device *dev = container_of(kobj, struct device, kobj);
+	struct dsa_switch *ds = dev_get_drvdata(dev);
+	struct dsa_switch_ops *ops = ds->ops;
+	umode_t mode = attr->mode;
+
+	if (index == 1) {
+		if (!ops->get_temp_limit)
+			mode = 0;
+		else if (!ops->set_temp_limit)
+			mode &= ~S_IWUSR;
+	} else if (index == 2 && !ops->get_temp_alarm) {
+		mode = 0;
+	}
+	return mode;
+}
+
+static const struct attribute_group dsa_hwmon_group = {
+	.attrs = dsa_hwmon_attrs,
+	.is_visible = dsa_hwmon_attrs_visible,
+};
+__ATTRIBUTE_GROUPS(dsa_hwmon);
+
+void dsa_hwmon_register(struct dsa_switch *ds)
+{
+	const char *netname = netdev_name(ds->dst->master_netdev);
+	char hname[IFNAMSIZ + 1];
+	int i, j;
+
+	/* If the switch provides temperature accessors, register with hardware
+	 * monitoring subsystem. Treat registration error as non-fatal.
+	 */
+	if (!ds->ops->get_temp)
+		return;
+
+	/* Create valid hwmon 'name' attribute */
+	for (i = j = 0; i < IFNAMSIZ && netname[i]; i++) {
+		if (isalnum(netname[i]))
+			hname[j++] = netname[i];
+	}
+	hname[j] = '\0';
+	scnprintf(ds->hwmon_name, sizeof(ds->hwmon_name), "%s_dsa%d", hname,
+		  ds->index);
+	ds->hwmon_dev = hwmon_device_register_with_groups(NULL, ds->hwmon_name,
+							  ds, dsa_hwmon_groups);
+	if (IS_ERR(ds->hwmon_dev)) {
+		pr_warn("DSA: failed to register HWMON subsystem for switch %d\n",
+			ds->index);
+		ds->hwmon_dev = NULL;
+	} else {
+		pr_info("DSA: registered HWMON subsystem for switch %d\n",
+			ds->index);
+	}
+}
+
+void dsa_hwmon_unregister(struct dsa_switch *ds)
+{
+	if (ds->hwmon_dev) {
+		hwmon_device_unregister(ds->hwmon_dev);
+		ds->hwmon_dev = NULL;
+	}
+}
-- 
2.11.0
