From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (4/4) add wireless statistics to sysfs
Date: Fri, 15 Aug 2003 15:38:04 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030815153804.58e7edc0.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Add wireless statistics to /net/class/ethXX/wireless.

diff -Nru a/net/core/net-sysfs.c b/net/core/net-sysfs.c
--- a/net/core/net-sysfs.c	Fri Aug 15 15:25:00 2003
+++ b/net/core/net-sysfs.c	Fri Aug 15 15:25:00 2003
@@ -15,6 +15,7 @@
 #include <linux/if_arp.h>
 #include <net/sock.h>
 #include <linux/rtnetlink.h>
+#include <linux/wireless.h>
 
 #define to_class_dev(obj) container_of(obj,struct class_device,kobj)
 #define to_net_dev(class) container_of(class, struct net_device, class_dev)
@@ -276,6 +277,67 @@
 	.attrs  = netstat_attrs,
 };
 
+#ifdef WIRELESS_EXT
+/* helper function that does all the locking etc for wireless stats */
+static ssize_t wireless_show(struct class_device *cd, char *buf,
+			     ssize_t (*format)(const struct iw_statistics *,
+					       char *))
+{
+	struct net_device *dev = to_net_dev(cd);
+	const struct iw_statistics *iw;
+	ssize_t ret = -EINVAL;
+	
+	read_lock(&dev_base_lock);
+	if (dev_isalive(dev) && dev->get_wireless_stats 
+	    && (iw = dev->get_wireless_stats(dev)) != NULL) 
+		ret = (*format)(iw, buf);
+	read_unlock(&dev_base_lock);
+
+	return ret;
+}
+
+/* show function template for wireless fields */
+#define WIRELESS_SHOW(name, field, format_string)			\
+static ssize_t format_iw_##name(const struct iw_statistics *iw, char *buf) \
+{									\
+	return sprintf(buf, format_string, iw->field);			\
+}									\
+static ssize_t show_iw_##name(struct class_device *cd, char *buf)	\
+{									\
+	return wireless_show(cd, buf, format_iw_##name);		\
+}									\
+static CLASS_DEVICE_ATTR(name, S_IRUGO, show_iw_##name, NULL)
+
+WIRELESS_SHOW(status, status, fmt_hex);
+WIRELESS_SHOW(link, qual.qual, fmt_dec);
+WIRELESS_SHOW(level, qual.level, fmt_dec);
+WIRELESS_SHOW(noise, qual.noise, fmt_dec);
+WIRELESS_SHOW(nwid, discard.nwid, fmt_dec);
+WIRELESS_SHOW(crypt, discard.code, fmt_dec);
+WIRELESS_SHOW(fragment, discard.fragment, fmt_dec);
+WIRELESS_SHOW(misc, discard.misc, fmt_dec);
+WIRELESS_SHOW(retries, discard.retries, fmt_dec);
+WIRELESS_SHOW(beacon, miss.beacon, fmt_dec);
+
+static struct attribute *wireless_attrs[] = {
+	&class_device_attr_status.attr,
+	&class_device_attr_link.attr,
+	&class_device_attr_level.attr,
+	&class_device_attr_noise.attr,
+	&class_device_attr_nwid.attr,
+	&class_device_attr_crypt.attr,
+	&class_device_attr_fragment.attr,
+	&class_device_attr_retries.attr,
+	&class_device_attr_misc.attr,
+	&class_device_attr_beacon.attr,
+	NULL
+};
+
+static struct attribute_group wireless_group = {
+	.name = "wireless",
+	.attrs = wireless_attrs,
+};
+#endif
 
 #ifdef CONFIG_HOTPLUG
 static int netdev_hotplug(struct class_device *cd, char **envp,
@@ -331,6 +393,11 @@
 	    (ret = sysfs_create_group(&class_dev->kobj, &netstat_group)))
 		goto out_unreg; 
 
+#ifdef WIRELESS_EXT
+	if (net->get_wireless_stats &&
+	    (ret = sysfs_create_group(&class_dev->kobj, &wireless_group)))
+		goto out_unreg; 
+#endif
 	return 0;
 
 out_unreg:
