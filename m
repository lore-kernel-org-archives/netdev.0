From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] vlan: sysfs support
Date: Mon, 1 May 2006 16:28:49 -0700
Message-ID: <20060501162849.5263708b@localhost.localdomain>
References: <20060501140834.43a006fd@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	vlan@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:60841 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932320AbWEAX3G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 May 2006 19:29:06 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060501140834.43a006fd@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here is a more complete version of vlan sysfs support. Sysfs support is
good because it means scripts don't have to depend on parsing interface
names that may change.

Assuming there is a vlan 5 added to eth0 then the following links are added:

/sys/class/net/eth0/vlan_group/5 -> ../../../../class/net/eth0.5
/sys/class/net/eth0.5/vlan_device -> ../../../class/net/eth0
and one file /sys/class/net/eth0/vlan_id  that contains "5\n"

It handles the reference counts on the vlan_groups properly, but still
has a race between hotplug and creating these sysfs objects because
of the chicken/egg problem with register_netdevice interface.


Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- vlan.orig/net/8021q/Makefile	2006-05-01 12:50:58.000000000 -0700
+++ vlan/net/8021q/Makefile	2006-05-01 15:27:55.000000000 -0700
@@ -4,9 +4,7 @@
 
 obj-$(CONFIG_VLAN_8021Q) += 8021q.o
 
-8021q-objs := vlan.o vlan_dev.o
-
-ifeq ($(CONFIG_PROC_FS),y)
-8021q-objs += vlanproc.o
-endif
+8021q-y := vlan.o vlan_dev.o
 
+8021q-$(CONFIG_PROC_FS) += vlanproc.o
+8021q-$(CONFIG_SYSFS) += vlan_sysfs.o
--- vlan.orig/net/8021q/vlan.c	2006-05-01 12:50:58.000000000 -0700
+++ vlan/net/8021q/vlan.c	2006-05-01 16:17:12.000000000 -0700
@@ -193,9 +193,21 @@
 	return NULL;
 }
 
+/* Callback after last packet and any open sysfs handles are gone. */
+static void vlan_grp_release(struct kobject *kobj)
+{
+	kfree(container_of(kobj, struct vlan_group, kobj));
+}
+
+static struct kobj_type vlan_grp_ktype = {
+	.release = vlan_grp_release,
+};
+
+/* Callback after last packet in flight has passed. */
 static void vlan_rcu_free(struct rcu_head *rcu)
 {
-	kfree(container_of(rcu, struct vlan_group, rcu));
+	struct vlan_group *grp = container_of(rcu, struct vlan_group, rcu);
+	kobject_put(&grp->kobj);
 }
 
 
@@ -232,6 +244,8 @@
 			/* Remove proc entry */
 			vlan_proc_rem_dev(dev);
 
+			vlan_sysfs_remove(dev, real_dev,  grp, vlan_id);
+
 			/* Take it out of our own structures, but be sure to
 			 * interlock with HW accelerating devices or SW vlan
 			 * input packet processing.
@@ -265,6 +279,8 @@
 				hlist_del_rcu(&grp->hlist);
 
 				/* Free the group, after all cpu's are done. */
+				kobject_uevent(&grp->kobj, KOBJ_REMOVE);
+				kobject_del(&grp->kobj);
 				call_rcu(&grp->rcu, vlan_rcu_free);
 
 				grp = NULL;
@@ -531,13 +547,17 @@
 	 * so it cannot "appear" on us.
 	 */
 	if (!grp) { /* need to add a new group */
-		grp = kmalloc(sizeof(struct vlan_group), GFP_KERNEL);
+		grp = kzalloc(sizeof(struct vlan_group), GFP_KERNEL);
 		if (!grp)
 			goto out_free_unregister;
 					
 		/* printk(KERN_ALERT "VLAN REGISTER:  Allocated new group.\n"); */
-		memset(grp, 0, sizeof(struct vlan_group));
 		grp->real_dev_ifindex = real_dev->ifindex;
+		kobject_init(&grp->kobj);
+		kobject_set_name(&grp->kobj, "vlan_group");
+		grp->kobj.parent = &real_dev->class_dev.kobj;
+		grp->kobj.ktype = &vlan_grp_ktype;
+		kobject_register(&grp->kobj);
 
 		hlist_add_head_rcu(&grp->hlist, 
 				   &vlan_group_hash[vlan_grp_hashfn(real_dev->ifindex)]);
@@ -557,6 +577,9 @@
 
 	rtnl_unlock();
 
+	if (vlan_sysfs_add(new_dev, real_dev, grp, VLAN_ID))
+		printk(KERN_WARNING "VLAN: failed to create sysfs entry for %s\n",
+		       new_dev->name);
 
 #ifdef VLAN_DEBUG
 	printk(VLAN_DBG "Allocated new device successfully, returning.\n");
--- vlan.orig/net/8021q/vlan.h	2006-05-01 12:50:58.000000000 -0700
+++ vlan/net/8021q/vlan.h	2006-05-01 16:08:18.000000000 -0700
@@ -69,4 +69,15 @@
 int vlan_dev_get_vid(const char* dev_name, unsigned short* result);
 void vlan_dev_set_multicast_list(struct net_device *vlan_dev);
 
+#ifdef CONFIG_SYSFS
+int vlan_sysfs_add(struct net_device *dev, struct net_device *real_dev,
+		   struct vlan_group *grp, unsigned short tag);
+void vlan_sysfs_remove(struct net_device *dev, struct net_device *real_dev,
+		       struct vlan_group *grp, unsigned short tag);
+#else
+#define vlan_sysfs_add(dev, realdev, grp, tag)	(0)
+#define vlan_sysfs_remove(dev, realdev, grp, tag)  do { } while (0)
+#endif
+
+
 #endif /* !(__BEN_VLAN_802_1Q_INC__) */
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ vlan/net/8021q/vlan_sysfs.c	2006-05-01 16:08:18.000000000 -0700
@@ -0,0 +1,59 @@
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
+int vlan_sysfs_add(struct net_device *dev, struct net_device *real_dev,
+		   struct vlan_group *grp, unsigned short tag)
+{
+	int ret;
+	char buf[IFNAMSIZ];
+
+	ret = sysfs_create_link(&dev->class_dev.kobj,
+				&real_dev->class_dev.kobj, "vlan_device");
+	if (ret)
+		goto out;
+
+	sprintf(buf, "%d", tag);
+	ret = sysfs_create_link(&grp->kobj, &dev->class_dev.kobj, buf);
+	if (ret)
+		goto out;
+
+	ret = class_device_create_file(&dev->class_dev, &class_device_attr_vlan_id);
+ out:
+	return ret;
+}
+
+void vlan_sysfs_remove(struct net_device *dev, struct net_device *real_dev,
+		       struct vlan_group *grp, unsigned short id)
+{
+	char buf[IFNAMSIZ];
+
+	sprintf(buf, "%d", id);
+	sysfs_remove_link(&grp->kobj, buf);
+	sysfs_remove_link(&dev->class_dev.kobj, "vlan_device");
+
+	return class_device_remove_file(&dev->class_dev,
+					&class_device_attr_vlan_id);
+}
--- vlan.orig/include/linux/if_vlan.h	2006-05-01 16:07:16.000000000 -0700
+++ vlan/include/linux/if_vlan.h	2006-05-01 16:08:18.000000000 -0700
@@ -77,6 +77,7 @@
 	struct hlist_node	hlist;	/* linked list */
 	struct net_device *vlan_devices[VLAN_GROUP_ARRAY_LEN];
 	struct rcu_head		rcu;
+	struct kobject 	        kobj;
 };
 
 struct vlan_priority_tci_mapping {
