From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.5.70+] Cleanup net-sysfs show and change functions
Date: Tue, 10 Jun 2003 13:38:54 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030610133854.42713231.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This cleans up the network sysfs code to use helper functions to unify
the show/change functions, by using common code in functions rather
than template macros.

The function always checks for dead devices, so I/O will fail.

diff -Nru a/net/core/net-sysfs.c b/net/core/net-sysfs.c
--- a/net/core/net-sysfs.c	Tue Jun 10 13:32:42 2003
+++ b/net/core/net-sysfs.c	Tue Jun 10 13:32:42 2003
@@ -3,10 +3,6 @@
  *
  * Copyright (c) 2003 Stephen Hemminber <shemminger@osdl.org>
  * 
- *
- * TODO:
- * last_tx
- * last_rx
  */
 
 #include <linux/config.h>
@@ -16,33 +12,61 @@
 #include <net/sock.h>
 #include <linux/rtnetlink.h>
 
-#define to_net_dev(class) container_of((class), struct net_device, class_dev)
+#define to_class_dev(obj) container_of(obj,struct class_device,kobj)
+#define to_net_dev(class) container_of(class, struct net_device, class_dev)
 
-/* generate a show function for  simple field */
+/* use same locking rules as GIF* ioctl's */
+static ssize_t netdev_show(const struct class_device *cd, char *buf,
+			   ssize_t (*format)(const struct net_device *, char *))
+{
+	struct net_device *net = to_net_dev(cd);
+	ssize_t ret = -EINVAL;
+
+	read_lock(&dev_base_lock);
+	if (!net->deadbeaf)
+		ret = (*format)(net, buf);
+	read_unlock(&dev_base_lock);
+
+	return ret;
+}
+
+/* generate a show function for simple field */
 #define NETDEVICE_SHOW(field, format_string)				\
-static ssize_t show_##field(struct class_device *dev, char *buf)	\
+static ssize_t format_##field(const struct net_device *net, char *buf)	\
 {									\
-	return sprintf(buf, format_string, to_net_dev(dev)->field);	\
+	return sprintf(buf, format_string, net->field);			\
+}									\
+static ssize_t show_##field(struct class_device *cd, char *buf)		\
+{									\
+	return netdev_show(cd, buf, format_##field);			\
 }
 
-/* generate a store function for a field with locking */
-#define NETDEVICE_STORE(field)						\
-static ssize_t 								\
-store_##field(struct class_device *dev, const char *buf, size_t len)	\
-{									\
-	char *endp;							\
-	long new = simple_strtol(buf, &endp, 16);			\
-									\
-	if (endp == buf || new < 0)					\
-		return -EINVAL;						\
-									\
-	if (!capable(CAP_NET_ADMIN))					\
-		return -EPERM;						\
-									\
-	rtnl_lock();							\
-	to_net_dev(dev)->field = new;					\
-	rtnl_unlock();							\
-	return len;							\
+
+/* use same locking and permission rules as SIF* ioctl's */
+static ssize_t netdev_store(struct class_device *dev,
+			    const char *buf, size_t len,
+			    int (*set)(struct net_device *, unsigned long))
+{
+	struct net_device *net = to_net_dev(dev);
+	char *endp;
+	unsigned long new;
+	int ret = -EINVAL;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	new = simple_strtoul(buf, &endp, 0);
+	if (endp == buf)
+		goto err;
+
+	rtnl_lock();
+	if (!net->deadbeaf) {
+		if ((ret = (*set)(net, new)) == 0)
+			ret = len;
+	}
+	rtnl_unlock();
+ err:
+	return ret;
 }
 
 /* generate a read-only network device class attribute */
@@ -56,6 +80,7 @@
 NETDEVICE_ATTR(features, "%#x\n");
 NETDEVICE_ATTR(type, "%d\n");
 
+/* use same locking rules as GIFHWADDR ioctl's */
 static ssize_t format_addr(char *buf, const unsigned char *addr, int len)
 {
 	int i;
@@ -72,12 +97,16 @@
 static ssize_t show_address(struct class_device *dev, char *buf)
 {
 	struct net_device *net = to_net_dev(dev);
+	if (net->deadbeaf)
+		return -EINVAL;
 	return format_addr(buf, net->dev_addr, net->addr_len);
 }
 
 static ssize_t show_broadcast(struct class_device *dev, char *buf)
 {
 	struct net_device *net = to_net_dev(dev);
+	if (net->deadbeaf)
+		return -EINVAL;
 	return format_addr(buf, net->broadcast, net->addr_len);
 }
 
@@ -87,54 +116,45 @@
 /* read-write attributes */
 NETDEVICE_SHOW(mtu, "%d\n");
 
-static ssize_t store_mtu(struct class_device *dev, const char *buf, size_t len)
+static int change_mtu(struct net_device *net, unsigned long new_mtu)
 {
-	char *endp;
-	int new_mtu;
-	int err;
-
-	new_mtu = simple_strtoul(buf, &endp, 10);
-	if (endp == buf) 
-		return -EINVAL;
-
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-	
-	rtnl_lock();
-	err = dev_set_mtu(to_net_dev(dev), new_mtu);
-	rtnl_unlock();
+	return dev_set_mtu(net, (int) new_mtu);
+}
 
-	return err == 0 ? len : err;
+static ssize_t store_mtu(struct class_device *dev, const char *buf, size_t len)
+{
+	return netdev_store(dev, buf, len, change_mtu);
 }
 
 static CLASS_DEVICE_ATTR(mtu, S_IRUGO | S_IWUSR, show_mtu, store_mtu);
 
 NETDEVICE_SHOW(flags, "%#x\n");
 
+static int change_flags(struct net_device *net, unsigned long new_flags)
+{
+	return dev_change_flags(net, (unsigned) new_flags);
+}
+
 static ssize_t store_flags(struct class_device *dev, const char *buf, size_t len)
 {
-	unsigned long new_flags;
-	char *endp;
-	int err = 0;
+	return netdev_store(dev, buf, len, change_flags);
+}
 
-	new_flags = simple_strtoul(buf, &endp, 16);
-	if (endp == buf)
-		return -EINVAL;
+static CLASS_DEVICE_ATTR(flags, S_IRUGO | S_IWUSR, show_flags, store_flags);
 
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-	
-	rtnl_lock();
-	err = dev_change_flags(to_net_dev(dev), new_flags);
-	rtnl_unlock();
+NETDEVICE_SHOW(tx_queue_len, "%lu\n");
 
-	return err ? err : len;
+static int change_tx_queue_len(struct net_device *net, unsigned long new_len)
+{
+	net->tx_queue_len = new_len;
+	return 0;
 }
 
-static CLASS_DEVICE_ATTR(flags, S_IRUGO | S_IWUSR, show_flags, store_flags);
+static ssize_t store_tx_queue_len(struct class_device *dev, const char *buf, size_t len)
+{
+	return netdev_store(dev, buf,len, change_tx_queue_len);
+}
 
-NETDEVICE_SHOW(tx_queue_len, "%lu\n");
-NETDEVICE_STORE(tx_queue_len);
 static CLASS_DEVICE_ATTR(tx_queue_len, S_IRUGO | S_IWUSR, show_tx_queue_len, 
 			 store_tx_queue_len);
 
@@ -237,16 +257,17 @@
 {
 	struct netstat_fs_entry *entry
 		= container_of(attr, struct netstat_fs_entry, attr);
-	struct class_device *class_dev
-		= container_of(kobj->parent, struct class_device, kobj);
 	struct net_device *dev
-		= to_net_dev(class_dev);
-	struct net_device_stats *stats 
-		= dev->get_stats ? dev->get_stats(dev) : NULL;
-
-	if (stats && entry->show) 
-		return entry->show(stats, buf);
-	return -EINVAL;
+		= to_net_dev(to_class_dev(kobj->parent));
+	struct net_device_stats *stats;
+	ssize_t ret = -EINVAL;
+	
+	read_lock(&dev_base_lock);
+	if (!dev->deadbeaf && entry->show && dev->get_stats &&
+	    (stats = (*dev->get_stats)(dev)))
+		ret = entry->show(stats, buf);
+	read_unlock(&dev_base_lock);
+	return ret;
 }
 
 static struct sysfs_ops netstat_sysfs_ops = {
