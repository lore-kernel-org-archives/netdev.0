From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/4) net-sysfs misc fixes.
Date: Fri, 15 Aug 2003 15:28:28 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030815152828.626862d5.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a some minor net-sysfs code cleanup; prior to some real changes.

   - define format strings once rather than N times
   - add GNU license that I forgot in original code
   - move read_lock out from format_address to show_address so
     device is alive test is inside of lock.


diff -Nru a/net/core/net-sysfs.c b/net/core/net-sysfs.c
--- a/net/core/net-sysfs.c	Fri Aug 15 15:23:00 2003
+++ b/net/core/net-sysfs.c	Fri Aug 15 15:23:00 2003
@@ -3,6 +3,10 @@
  *
  * Copyright (c) 2003 Stephen Hemminger <shemminger@osdl.org>
  * 
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License
+ *	as published by the Free Software Foundation; either version
+ *	2 of the License, or (at your option) any later version.
  */
 
 #include <linux/config.h>
@@ -15,6 +19,10 @@
 #define to_class_dev(obj) container_of(obj,struct class_device,kobj)
 #define to_net_dev(class) container_of(class, struct net_device, class_dev)
 
+static const char *fmt_hex = "%#x\n";
+static const char *fmt_dec = "%d\n";
+static const char *fmt_ulong = "%lu\n";
+
 static inline int dev_isalive(const struct net_device *dev) 
 {
 	return dev->reg_state == NETREG_REGISTERED;
@@ -79,11 +87,11 @@
 NETDEVICE_SHOW(field, format_string)					\
 static CLASS_DEVICE_ATTR(field, S_IRUGO, show_##field, NULL)		\
 
-NETDEVICE_ATTR(addr_len, "%d\n");
-NETDEVICE_ATTR(iflink, "%d\n");
-NETDEVICE_ATTR(ifindex, "%d\n");
-NETDEVICE_ATTR(features, "%#x\n");
-NETDEVICE_ATTR(type, "%d\n");
+NETDEVICE_ATTR(addr_len, fmt_dec);
+NETDEVICE_ATTR(iflink, fmt_dec);
+NETDEVICE_ATTR(ifindex, fmt_dec);
+NETDEVICE_ATTR(features, fmt_hex);
+NETDEVICE_ATTR(type, fmt_dec);
 
 /* use same locking rules as GIFHWADDR ioctl's */
 static ssize_t format_addr(char *buf, const unsigned char *addr, int len)
@@ -91,20 +99,22 @@
 	int i;
 	char *cp = buf;
 
-	read_lock(&dev_base_lock);
 	for (i = 0; i < len; i++)
 		cp += sprintf(cp, "%02x%c", addr[i],
 			      i == (len - 1) ? '\n' : ':');
-	read_unlock(&dev_base_lock);
 	return cp - buf;
 }
 
 static ssize_t show_address(struct class_device *dev, char *buf)
 {
 	struct net_device *net = to_net_dev(dev);
+	ssize_t ret = -EINVAL;
+
+	read_lock(&dev_base_lock);
 	if (dev_isalive(net))
-	    return format_addr(buf, net->dev_addr, net->addr_len);
-	return -EINVAL;
+	    ret = format_addr(buf, net->dev_addr, net->addr_len);
+	read_unlock(&dev_base_lock);
+	return ret;
 }
 
 static ssize_t show_broadcast(struct class_device *dev, char *buf)
@@ -119,7 +129,7 @@
 static CLASS_DEVICE_ATTR(broadcast, S_IRUGO, show_broadcast, NULL);
 
 /* read-write attributes */
-NETDEVICE_SHOW(mtu, "%d\n");
+NETDEVICE_SHOW(mtu, fmt_dec);
 
 static int change_mtu(struct net_device *net, unsigned long new_mtu)
 {
@@ -133,7 +143,7 @@
 
 static CLASS_DEVICE_ATTR(mtu, S_IRUGO | S_IWUSR, show_mtu, store_mtu);
 
-NETDEVICE_SHOW(flags, "%#x\n");
+NETDEVICE_SHOW(flags, fmt_hex);
 
 static int change_flags(struct net_device *net, unsigned long new_flags)
 {
@@ -147,7 +157,7 @@
 
 static CLASS_DEVICE_ATTR(flags, S_IRUGO | S_IWUSR, show_flags, store_flags);
 
-NETDEVICE_SHOW(tx_queue_len, "%lu\n");
+NETDEVICE_SHOW(tx_queue_len, fmt_ulong);
 
 static int change_tx_queue_len(struct net_device *net, unsigned long new_len)
 {
@@ -186,7 +196,7 @@
 
 static ssize_t net_device_stat_show(unsigned long var, char *buf)
 {
-	return sprintf(buf, "%lu\n", var);
+	return sprintf(buf, fmt_ulong, var);
 }
 
 /* generate a read-only statistics attribute */
