From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFC] vlan: add sysfs support
Date: Mon, 1 May 2006 14:08:34 -0700
Message-ID: <20060501140834.43a006fd@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vlan@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:17795 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750945AbWEAVIk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 May 2006 17:08:40 -0400
To: Ben Greear <greearb@candelatech.com>,
	"David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add basic sysfs support for vlan device. It creates an entry in the
vlan pseudo-device to display tag.  
	/sys/class/net/eth0.5/vlan_id

It would be nice at some future to have something like:
	/sys/class/net/eth0/tags/5  -> ../../eth0.5
as well.

There is a race with udev though. The sysfs entry can't be created
until after the the class_device is registered but the registration
doesn't happen until  rtnl_unlock after register_netdevice. The class_device
registration causes the hotplug event, so the hotplug user program
might get there before vlan_id is created.


--- vlan.orig/net/8021q/Makefile	2006-05-01 12:50:58.000000000 -0700
+++ vlan/net/8021q/Makefile	2006-05-01 14:04:56.000000000 -0700
@@ -6,7 +6,5 @@
 
 8021q-objs := vlan.o vlan_dev.o
 
-ifeq ($(CONFIG_PROC_FS),y)
-8021q-objs += vlanproc.o
-endif
-
+8021q-$(CONFIG_PROC_FS) += vlanproc.o
+8021q-$(CONFIG_SYSFS) += vlan_sysfs.o
--- vlan.orig/net/8021q/vlan.c	2006-05-01 12:50:58.000000000 -0700
+++ vlan/net/8021q/vlan.c	2006-05-01 13:48:35.000000000 -0700
@@ -232,6 +232,8 @@
 			/* Remove proc entry */
 			vlan_proc_rem_dev(dev);
 
+			vlan_sysfs_remove(dev);
+
 			/* Take it out of our own structures, but be sure to
 			 * interlock with HW accelerating devices or SW vlan
 			 * input packet processing.
@@ -557,6 +559,9 @@
 
 	rtnl_unlock();
 
+	if (vlan_sysfs_add(new_dev))
+		printk(KERN_WARNING "VLAN: failed to create sysfs entry for %s\n",
+		       new_dev->name);
 
 #ifdef VLAN_DEBUG
 	printk(VLAN_DBG "Allocated new device successfully, returning.\n");
--- vlan.orig/net/8021q/vlan.h	2006-05-01 12:50:58.000000000 -0700
+++ vlan/net/8021q/vlan.h	2006-05-01 13:17:16.000000000 -0700
@@ -69,4 +69,13 @@
 int vlan_dev_get_vid(const char* dev_name, unsigned short* result);
 void vlan_dev_set_multicast_list(struct net_device *vlan_dev);
 
+#ifdef CONFIG_SYSFS
+int vlan_sysfs_add(struct net_device *dev);
+void vlan_sysfs_remove(struct net_device *dev);
+#else
+#define vlan_sysfs_add(dev)	(0)
+#define vlan_sysfs_remove(dev)  do { } while (0)
+#endif
+
+
 #endif /* !(__BEN_VLAN_802_1Q_INC__) */
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ vlan/net/8021q/vlan_sysfs.c	2006-05-01 14:04:49.000000000 -0700
@@ -0,0 +1,38 @@
+/*
+ * VLAN sysfs interface.
+ *
+ * Basic access to vlan information via sysfs.
+ * Authors:
+ * Stephen Hemminger		<shemminger@osdl.org>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/kernel.h>
+#include <linux/netdevice.h>
+#include "vlan.h"
+
+static ssize_t show_vlan_id(struct class_device *cd, char *buf)
+{
+	struct net_device *vlandev = container_of(cd, struct net_device, class_dev);
+
+	return sprintf(buf, "%d\n", VLAN_DEV_INFO(vlandev)->vlan_id);
+}
+
+static CLASS_DEVICE_ATTR(vlan_id, S_IRUGO, show_vlan_id, NULL);
+
+int vlan_sysfs_add(struct net_device *dev)
+{
+	return class_device_create_file(&dev->class_dev,
+					&class_device_attr_vlan_id);
+}
+
+void vlan_sysfs_remove(struct net_device *dev)
+{
+	return class_device_remove_file(&dev->class_dev,
+					&class_device_attr_vlan_id);
+
+}
