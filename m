From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH v2 06/15] net: dsa: Add support for reporting switch chip temperatures
Date: Sun, 26 Oct 2014 09:52:36 -0700
Message-ID: <1414342365-27191-7-git-send-email-linux@roeck-us.net>
References: <1414342365-27191-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, linux-kernel@vger.kernel.org,
	Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1414342365-27191-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some switches provide chip temperature data.
Add support for reporting it through the hwmon subsystem.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
v2:
- Updated headline to reflect what is reported, not how.
- Make added functionality optional with new Kconfig flag
- Register with hwmon subsystem as virtual device (no parent)
- Generate hwmon 'name' attribute from sanitized master network device
  name plus _dsaX, where X is the DSA switch index and 'sanitized'
  means to pick all characters and digits from the network device name
- Do not use devm_ function to register hwmon device, since the hwmon
  device is not associated with a device and thus can not be auto-removed.

 include/net/dsa.h |  16 +++++++
 net/dsa/Kconfig   |  11 +++++
 net/dsa/dsa.c     | 131 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 158 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index b765592..55e75e7 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -139,6 +139,14 @@ struct dsa_switch {
 	 */
 	struct device		*master_dev;
 
+#ifdef CONFIG_NET_DSA_HWMON
+	/*
+	 * Hardware monitoring information
+	 */
+	char			hwmon_name[IFNAMSIZ + 8];
+	struct device		*hwmon_dev;
+#endif
+
 	/*
 	 * Slave mii_bus and devices for the individual ports.
 	 */
@@ -242,6 +250,14 @@ struct dsa_switch_driver {
 			   struct ethtool_eee *e);
 	int	(*get_eee)(struct dsa_switch *ds, int port,
 			   struct ethtool_eee *e);
+
+#ifdef CONFIG_NET_DSA_HWMON
+	/* Hardware monitoring */
+	int	(*get_temp)(struct dsa_switch *ds, int *temp);
+	int	(*get_temp_limit)(struct dsa_switch *ds, int *temp);
+	int	(*set_temp_limit)(struct dsa_switch *ds, int temp);
+	int	(*get_temp_alarm)(struct dsa_switch *ds, bool *alarm);
+#endif
 };
 
 void register_switch_driver(struct dsa_switch_driver *type);
diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
index a585fd6..5f8ac40 100644
--- a/net/dsa/Kconfig
+++ b/net/dsa/Kconfig
@@ -11,6 +11,17 @@ config NET_DSA
 
 if NET_DSA
 
+config NET_DSA_HWMON
+	bool "Distributed Switch Architecture HWMON support"
+	default y
+	depends on HWMON && !(NET_DSA=y && HWMON=m)
+	---help---
+	  Say Y if you want to expose thermal sensor data on switches supported
+	  by the Distributed Switch Architecture.
+
+	  Some of those switches contain thermal sensors. This data is available
+	  via the hwmon sysfs interface and exposes the onboard sensors.
+
 # tagging formats
 config NET_DSA_TAG_BRCM
 	bool
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 22f34cf..5edbbca 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -9,6 +9,9 @@
  * (at your option) any later version.
  */
 
+#include <linux/ctype.h>
+#include <linux/device.h>
+#include <linux/hwmon.h>
 #include <linux/list.h>
 #include <linux/platform_device.h>
 #include <linux/slab.h>
@@ -17,6 +20,7 @@
 #include <linux/of.h>
 #include <linux/of_mdio.h>
 #include <linux/of_platform.h>
+#include <linux/sysfs.h>
 #include "dsa_priv.h"
 
 char dsa_driver_version[] = "0.1";
@@ -71,6 +75,104 @@ dsa_switch_probe(struct device *host_dev, int sw_addr, char **_name)
 	return ret;
 }
 
+/* hwmon support ************************************************************/
+
+#ifdef CONFIG_NET_DSA_HWMON
+
+static ssize_t temp1_input_show(struct device *dev,
+				struct device_attribute *attr, char *buf)
+{
+	struct dsa_switch *ds = dev_get_drvdata(dev);
+	int temp, ret;
+
+	ret = ds->drv->get_temp(ds, &temp);
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
+	ret = ds->drv->get_temp_limit(ds, &temp);
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
+	ret = ds->drv->set_temp_limit(ds, DIV_ROUND_CLOSEST(temp, 1000));
+	if (ret < 0)
+		return ret;
+
+	return count;
+}
+static DEVICE_ATTR(temp1_max, S_IRUGO, temp1_max_show, temp1_max_store);
+
+static ssize_t temp1_max_alarm_show(struct device *dev,
+				    struct device_attribute *attr, char *buf)
+{
+	struct dsa_switch *ds = dev_get_drvdata(dev);
+	bool alarm;
+	int ret;
+
+	ret = ds->drv->get_temp_alarm(ds, &alarm);
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
+	struct dsa_switch_driver *drv = ds->drv;
+	umode_t mode = attr->mode;
+
+	if (index == 1) {
+		if (!drv->get_temp_limit)
+			mode = 0;
+		else if (drv->set_temp_limit)
+			mode |= S_IWUSR;
+	} else if (index == 2 && !drv->get_temp_alarm) {
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
+#endif /* CONFIG_NET_DSA_HWMON */
 
 /* basic switch operations **************************************************/
 static struct dsa_switch *
@@ -225,6 +327,31 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 		ds->ports[i] = slave_dev;
 	}
 
+#ifdef CONFIG_NET_DSA_HWMON
+	/* If the switch provides a temperature sensor,
+	 * register with hardware monitoring subsystem.
+	 * Treat registration error as non-fatal and ignore it.
+	 */
+	if (drv->get_temp) {
+		const char *netname = netdev_name(dst->master_netdev);
+		char hname[IFNAMSIZ + 1];
+		int i, j;
+
+		/* Create valid hwmon 'name' attribute */
+		for (i = j = 0; i < IFNAMSIZ && netname[i]; i++) {
+			if (isalnum(netname[i]))
+				hname[j++] = netname[i];
+		}
+		hname[j] = '\0';
+		scnprintf(ds->hwmon_name, sizeof(ds->hwmon_name), "%s_dsa%d",
+			  hname, index);
+		ds->hwmon_dev = hwmon_device_register_with_groups(NULL,
+					ds->hwmon_name, ds, dsa_hwmon_groups);
+		if (IS_ERR(ds->hwmon_dev))
+			ds->hwmon_dev = NULL;
+	}
+#endif /* CONFIG_NET_DSA_HWMON */
+
 	return ds;
 
 out_free:
@@ -236,6 +363,10 @@ out:
 
 static void dsa_switch_destroy(struct dsa_switch *ds)
 {
+#ifdef CONFIG_NET_DSA_HWMON
+	if (ds->hwmon_dev)
+		hwmon_device_unregister(ds->hwmon_dev);
+#endif
 }
 
 #ifdef CONFIG_PM_SLEEP
-- 
1.9.1
