From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (8/11) bridge -- add sysfs support
Date: Fri, 21 May 2004 16:39:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040521163914.1bb01283@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

# This is a BitKeeper generated diff -Nru style patch.
Add sysfs attributes for bridges.  This allows for easier management, and solves
some of the 64/32bit compatibility issues.

New entries are:
sys/class/net
|-- br0
|   |-- brforward
|   |-- bridge
|   |   |-- ageing_time
|   |   |-- bridge_id
|   |   |-- forward_delay
|   |   |-- gc_timer
|   |   |-- hello_time
|   |   |-- hello_timer
|   |   |-- max_age
|   |   |-- priority
|   |   |-- root_id
|   |   |-- root_path_cost
|   |   |-- root_port
|   |   |-- stp_state
|   |   |-- tcn_timer
|   |   |-- topology_change
|   |   |-- topology_change_detected
|   |   `-- topology_change_timer
|   |-- brif
|   |   |-- dummy0 -> ../../../../class/net/dummy0/brport
|   |   `-- dummy1 -> ../../../../class/net/dummy1/brport
...
|-- dummy0
|   |-- brport
|   |   |-- bridge -> ../../../../class/net/br0
|   |   |-- change_ack
|   |   |-- config_pending
|   |   |-- designated_bridge
|   |   |-- designated_cost
|   |   |-- designated_port
|   |   |-- designated_root
|   |   |-- forward_delay_timer
|   |   |-- hold_timer
|   |   |-- message_age_timer
|   |   |-- path_cost
|   |   |-- port_id
|   |   |-- port_no
|   |   |-- priority
|   |   `-- state


diff -Nru a/include/linux/if_bridge.h b/include/linux/if_bridge.h
--- a/include/linux/if_bridge.h	2004-05-21 16:27:21 -07:00
+++ b/include/linux/if_bridge.h	2004-05-21 16:27:21 -07:00
@@ -17,6 +17,12 @@
 
 #include <linux/types.h>
 
+#define SYSFS_BRIDGE_ATTR	"bridge"
+#define SYSFS_BRIDGE_FDB	"brforward"
+#define SYSFS_BRIDGE_PORT_SUBDIR "brif"
+#define SYSFS_BRIDGE_PORT_ATTR	"brport"
+#define SYSFS_BRIDGE_PORT_LINK	"bridge"
+
 #define BRCTL_VERSION 1
 
 #define BRCTL_GET_VERSION 0
diff -Nru a/net/bridge/Makefile b/net/bridge/Makefile
--- a/net/bridge/Makefile	2004-05-21 16:27:21 -07:00
+++ b/net/bridge/Makefile	2004-05-21 16:27:21 -07:00
@@ -8,6 +8,8 @@
 			br_ioctl.o br_notify.o br_stp.o br_stp_bpdu.o \
 			br_stp_if.o br_stp_timer.o
 
+bridge-$(CONFIG_SYSFS) += br_sysfs_if.o br_sysfs_br.o
+
 bridge-$(CONFIG_BRIDGE_NETFILTER) += br_netfilter.o
 
 obj-$(CONFIG_BRIDGE_NF_EBTABLES) += netfilter/
diff -Nru a/net/bridge/br.c b/net/bridge/br.c
--- a/net/bridge/br.c	2004-05-21 16:27:21 -07:00
+++ b/net/bridge/br.c	2004-05-21 16:27:21 -07:00
@@ -33,6 +33,8 @@
 {
 	br_fdb_init();
 
+	br_sysfs_init();
+
 #ifdef CONFIG_BRIDGE_NETFILTER
 	if (br_netfilter_init())
 		return 1;
@@ -67,6 +69,7 @@
 #endif
 
 	br_handle_frame_hook = NULL;
+	br_sysfs_fini();
 	br_fdb_fini();
 }
 
diff -Nru a/net/bridge/br_if.c b/net/bridge/br_if.c
--- a/net/bridge/br_if.c	2004-05-21 16:27:21 -07:00
+++ b/net/bridge/br_if.c	2004-05-21 16:27:21 -07:00
@@ -81,8 +81,11 @@
 	struct net_device *dev = p->dev;
 
 	dev->br_port = NULL;
+	p->br = NULL;
+	p->dev = NULL;
 	dev_put(dev);
-	kfree(p);
+
+	br_sysfs_freeif(p);
 }
 
 /* called with RTNL */
@@ -111,14 +114,16 @@
 /* called with RTNL */
 static void del_br(struct net_bridge *br)
 {
-	struct list_head *p, *n;
+	struct net_bridge_port *p, *n;
 
-	list_for_each_safe(p, n, &br->port_list) {
-		del_nbp(list_entry(p, struct net_bridge_port, list));
+	list_for_each_entry_safe(p, n, &br->port_list, list) {
+		br_sysfs_removeif(p);
+		del_nbp(p);
 	}
 
 	del_timer_sync(&br->gc_timer);
 
+	br_sysfs_delbr(br->dev);
  	unregister_netdevice(br->dev);
 }
 
@@ -210,6 +215,7 @@
 	p->port_no = index;
 	br_init_port(p);
 	p->state = BR_STATE_DISABLED;
+	kobject_init(&p->kobj);
 
 	return p;
 }
@@ -223,10 +229,37 @@
 	if (!dev) 
 		return -ENOMEM;
 
-	ret = register_netdev(dev);
+	rtnl_lock();
+	if (strchr(dev->name, '%')) {
+		ret = dev_alloc_name(dev, dev->name);
+		if (ret < 0)
+			goto err1;
+	}
+
+	ret = register_netdevice(dev);
 	if (ret)
-		free_netdev(dev);
+		goto err2;
+
+	/* network device kobject is not setup until
+	 * after rtnl_unlock does it's hotplug magic.
+	 * so hold reference to avoid race.
+	 */
+	dev_hold(dev);
+	rtnl_unlock();
+
+	ret = br_sysfs_addbr(dev);
+	dev_put(dev);
+
+	if (ret) 
+		unregister_netdev(dev);
+ out:
 	return ret;
+
+ err2:
+	free_netdev(dev);
+ err1:
+	rtnl_unlock();
+	goto out;
 }
 
 int br_del_bridge(const char *name)
@@ -277,6 +310,8 @@
  	if ((err = br_fdb_insert(br, p, dev->dev_addr, 1)))
 		destroy_nbp(p);
  
+	else if ((err = br_sysfs_addif(p)))
+		del_nbp(p);
 	else {
 		dev_set_promiscuity(dev, 1);
 
@@ -300,6 +335,7 @@
 	if (!p || p->br != br) 
 		return -EINVAL;
 
+	br_sysfs_removeif(p);
 	del_nbp(p);
 
 	spin_lock_bh(&br->lock);
diff -Nru a/net/bridge/br_private.h b/net/bridge/br_private.h
--- a/net/bridge/br_private.h	2004-05-21 16:27:21 -07:00
+++ b/net/bridge/br_private.h	2004-05-21 16:27:21 -07:00
@@ -76,6 +76,7 @@
 	struct timer_list		forward_delay_timer;
 	struct timer_list		hold_timer;
 	struct timer_list		message_age_timer;
+	struct kobject			kobj;
 	struct rcu_head			rcu;
 };
 
@@ -110,6 +111,7 @@
 	struct timer_list		tcn_timer;
 	struct timer_list		topology_change_timer;
 	struct timer_list		gc_timer;
+	struct kobject			ifobj;
 };
 
 extern struct notifier_block br_device_notifier;
@@ -198,6 +200,7 @@
 				     u8 newprio);
 extern void br_stp_set_path_cost(struct net_bridge_port *p,
 				 u32 path_cost);
+extern ssize_t br_show_bridge_id(char *buf, const struct bridge_id *id);
 
 /* br_stp_bpdu.c */
 extern int br_stp_handle_bpdu(struct sk_buff *skb);
@@ -206,5 +209,29 @@
 extern void br_stp_timer_init(struct net_bridge *br);
 extern void br_stp_port_timer_init(struct net_bridge_port *p);
 extern unsigned long br_timer_value(const struct timer_list *timer);
+
+#ifdef CONFIG_SYSFS
+/* br_sysfs_if.c */
+extern int br_sysfs_addif(struct net_bridge_port *p);
+extern void br_sysfs_removeif(struct net_bridge_port *p);
+extern void br_sysfs_freeif(struct net_bridge_port *p);
+
+/* br_sysfs_br.c */
+extern struct subsystem bridge_subsys;
+extern void br_sysfs_init(void);
+extern void br_sysfs_fini(void);
+extern int br_sysfs_addbr(struct net_device *dev);
+extern void br_sysfs_delbr(struct net_device *dev);
+
+#else
+
+#define br_sysfs_addif(p)	(0)
+#define br_sysfs_removeif(p)	do { } while(0)
+#define br_sysfs_freeif(p)	kfree(p)
+#define br_sysfs_init()		do { } while(0)
+#define br_sysfs_fini()		do { } while(0)
+#define br_sysfs_addbr(dev)	(0)
+#define br_sysfs_delbr(dev)	do { } while(0)
+#endif /* CONFIG_SYSFS */
 
 #endif
diff -Nru a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
--- a/net/bridge/br_stp_if.c	2004-05-21 16:27:21 -07:00
+++ b/net/bridge/br_stp_if.c	2004-05-21 16:27:21 -07:00
@@ -212,3 +212,11 @@
 	br_configuration_update(p->br);
 	br_port_state_selection(p->br);
 }
+
+ssize_t br_show_bridge_id(char *buf, const struct bridge_id *id)
+{
+	return sprintf(buf, "%.2x%.2x.%.2x%.2x%.2x%.2x%.2x%.2x\n",
+	       id->prio[0], id->prio[1],
+	       id->addr[0], id->addr[1], id->addr[2],
+	       id->addr[3], id->addr[4], id->addr[5]);
+}
diff -Nru a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/net/bridge/br_sysfs_br.c	2004-05-21 16:27:21 -07:00
@@ -0,0 +1,383 @@
+/*
+ *	Sysfs attributes of bridge ports
+ *	Linux ethernet bridge
+ *
+ *	Authors:
+ *	Stephen Hemminger		<shemminger@osdl.org>
+ *
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License
+ *	as published by the Free Software Foundation; either version
+ *	2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/kernel.h>
+#include <linux/netdevice.h>
+#include <linux/if_bridge.h>
+#include <linux/rtnetlink.h>
+#include <linux/spinlock.h>
+#include <linux/times.h>
+
+#include "br_private.h"
+
+#define to_class_dev(obj) container_of(obj,struct class_device,kobj)
+#define to_net_dev(class) container_of(class, struct net_device, class_dev)
+#define to_bridge(cd)	((struct net_bridge *)(to_net_dev(cd)->priv))
+
+/*
+ * Common code for storing bridge parameters.
+ */
+static ssize_t store_bridge_parm(struct class_device *cd,
+				 const char *buf, size_t len,
+				 void (*set)(struct net_bridge *, unsigned long))
+{
+	struct net_bridge *br = to_bridge(cd);
+	char *endp;
+	unsigned long val;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	val = simple_strtoul(buf, &endp, 0);
+	if (endp == buf)
+		return -EINVAL;
+
+	spin_lock_bh(&br->lock);
+	(*set)(br, val);
+	spin_unlock_bh(&br->lock);
+	return len;
+}
+
+
+static ssize_t show_forward_delay(struct class_device *cd, char *buf)
+{
+	struct net_bridge *br = to_bridge(cd);
+	return sprintf(buf, "%lu\n", jiffies_to_clock_t(br->forward_delay));
+}
+
+static void set_forward_delay(struct net_bridge *br, unsigned long val)
+{
+	unsigned long delay = clock_t_to_jiffies(val);
+	br->forward_delay = delay;
+	if (br_is_root_bridge(br))
+		br->bridge_forward_delay = delay;
+}
+
+static ssize_t store_forward_delay(struct class_device *cd, const char *buf,
+				   size_t len)
+{
+	return store_bridge_parm(cd, buf, len, set_forward_delay);
+}
+static CLASS_DEVICE_ATTR(forward_delay, S_IRUGO | S_IWUSR,
+			 show_forward_delay, store_forward_delay);
+
+static ssize_t show_hello_time(struct class_device *cd, char *buf)
+{
+	return sprintf(buf, "%lu\n",
+		       jiffies_to_clock_t(to_bridge(cd)->hello_time));
+}
+
+static void set_hello_time(struct net_bridge *br, unsigned long val)
+{
+	unsigned long t = clock_t_to_jiffies(val);
+	br->hello_time = t;
+	if (br_is_root_bridge(br))
+		br->bridge_hello_time = t;
+}
+
+static ssize_t store_hello_time(struct class_device *cd, const char *buf,
+				size_t len)
+{
+	return store_bridge_parm(cd, buf, len, set_hello_time);
+}
+
+static CLASS_DEVICE_ATTR(hello_time, S_IRUGO | S_IWUSR, show_hello_time,
+			 store_hello_time);
+
+static ssize_t show_max_age(struct class_device *cd, char *buf)
+{
+	return sprintf(buf, "%lu\n",
+		       jiffies_to_clock_t(to_bridge(cd)->max_age));
+}
+
+static void set_max_age(struct net_bridge *br, unsigned long val)
+{
+	unsigned long t = clock_t_to_jiffies(val);
+	br->max_age = t;
+	if (br_is_root_bridge(br))
+		br->bridge_max_age = t;
+}
+
+static ssize_t store_max_age(struct class_device *cd, const char *buf,
+				size_t len)
+{
+	return store_bridge_parm(cd, buf, len, set_max_age);
+}
+
+static CLASS_DEVICE_ATTR(max_age, S_IRUGO | S_IWUSR, show_max_age,
+			 store_max_age);
+
+static ssize_t show_ageing_time(struct class_device *cd, char *buf)
+{
+	struct net_bridge *br = to_bridge(cd);
+	return sprintf(buf, "%lu\n", jiffies_to_clock_t(br->ageing_time));
+}
+
+static void set_ageing_time(struct net_bridge *br, unsigned long val)
+{
+	br->ageing_time = clock_t_to_jiffies(val);
+}
+
+static ssize_t store_ageing_time(struct class_device *cd, const char *buf,
+				 size_t len)
+{
+	return store_bridge_parm(cd, buf, len, set_ageing_time);
+}
+
+static CLASS_DEVICE_ATTR(ageing_time, S_IRUGO | S_IWUSR, show_ageing_time,
+			 store_ageing_time);
+static ssize_t show_stp_state(struct class_device *cd, char *buf)
+{
+	struct net_bridge *br = to_bridge(cd);
+	return sprintf(buf, "%d\n", br->stp_enabled);
+}
+
+static void set_stp_state(struct net_bridge *br, unsigned long val)
+{
+	br->stp_enabled = val;
+}
+
+static ssize_t store_stp_state(struct class_device *cd,
+			       const char *buf, size_t len)
+{
+	return store_bridge_parm(cd, buf, len, set_stp_state);
+}
+
+static CLASS_DEVICE_ATTR(stp_state, S_IRUGO | S_IWUSR, show_stp_state,
+			 store_stp_state);
+
+static ssize_t show_priority(struct class_device *cd, char *buf)
+{
+	struct net_bridge *br = to_bridge(cd);
+	return sprintf(buf, "%d\n",
+		       (br->bridge_id.prio[0] << 8) | br->bridge_id.prio[1]);
+}
+
+static void set_priority(struct net_bridge *br, unsigned long val)
+{
+	br_stp_set_bridge_priority(br, (u16) val);
+}
+
+static ssize_t store_priority(struct class_device *cd,
+			       const char *buf, size_t len)
+{
+	return store_bridge_parm(cd, buf, len, set_priority);
+}
+static CLASS_DEVICE_ATTR(priority, S_IRUGO | S_IWUSR, show_priority,
+			 store_priority);
+
+static ssize_t show_root_id(struct class_device *cd, char *buf)
+{
+	return br_show_bridge_id(buf, &to_bridge(cd)->designated_root);
+}
+static CLASS_DEVICE_ATTR(root_id, S_IRUGO, show_root_id, NULL);
+
+static ssize_t show_bridge_id(struct class_device *cd, char *buf)
+{
+	return br_show_bridge_id(buf, &to_bridge(cd)->bridge_id);
+}
+static CLASS_DEVICE_ATTR(bridge_id, S_IRUGO, show_bridge_id, NULL);
+
+static ssize_t show_root_port(struct class_device *cd, char *buf)
+{
+	return sprintf(buf, "%d\n", to_bridge(cd)->root_port);
+}
+static CLASS_DEVICE_ATTR(root_port, S_IRUGO, show_root_port, NULL);
+
+static ssize_t show_root_path_cost(struct class_device *cd, char *buf)
+{
+	return sprintf(buf, "%d\n", to_bridge(cd)->root_path_cost);
+}
+static CLASS_DEVICE_ATTR(root_path_cost, S_IRUGO, show_root_path_cost, NULL);
+
+static ssize_t show_topology_change(struct class_device *cd, char *buf)
+{
+	return sprintf(buf, "%d\n", to_bridge(cd)->topology_change);
+}
+static CLASS_DEVICE_ATTR(topology_change, S_IRUGO, show_topology_change, NULL);
+
+static ssize_t show_topology_change_detected(struct class_device *cd, char *buf)
+{
+	struct net_bridge *br = to_bridge(cd);
+	return sprintf(buf, "%d\n", br->topology_change_detected);
+}
+static CLASS_DEVICE_ATTR(topology_change_detected, S_IRUGO, show_topology_change_detected, NULL);
+
+static ssize_t show_hello_timer(struct class_device *cd, char *buf)
+{
+	struct net_bridge *br = to_bridge(cd);
+	return sprintf(buf, "%ld\n", br_timer_value(&br->hello_timer));
+}
+static CLASS_DEVICE_ATTR(hello_timer, S_IRUGO, show_hello_timer, NULL);
+
+static ssize_t show_tcn_timer(struct class_device *cd, char *buf)
+{
+	struct net_bridge *br = to_bridge(cd);
+	return sprintf(buf, "%ld\n", br_timer_value(&br->tcn_timer));
+}
+static CLASS_DEVICE_ATTR(tcn_timer, S_IRUGO, show_tcn_timer, NULL);
+
+static ssize_t show_topology_change_timer(struct class_device *cd, char *buf)
+{
+	struct net_bridge *br = to_bridge(cd);
+	return sprintf(buf, "%ld\n", br_timer_value(&br->topology_change_timer));
+}
+static CLASS_DEVICE_ATTR(topology_change_timer, S_IRUGO, show_topology_change_timer, NULL);
+
+static ssize_t show_gc_timer(struct class_device *cd, char *buf)
+{
+	struct net_bridge *br = to_bridge(cd);
+	return sprintf(buf, "%ld\n", br_timer_value(&br->gc_timer));
+}
+static CLASS_DEVICE_ATTR(gc_timer, S_IRUGO, show_gc_timer, NULL);
+
+static struct attribute *bridge_attrs[] = {
+	&class_device_attr_forward_delay.attr,
+	&class_device_attr_hello_time.attr,
+	&class_device_attr_max_age.attr,
+	&class_device_attr_ageing_time.attr,
+	&class_device_attr_stp_state.attr,
+	&class_device_attr_priority.attr,
+	&class_device_attr_bridge_id.attr,
+	&class_device_attr_root_id.attr,
+	&class_device_attr_root_path_cost.attr,
+	&class_device_attr_root_port.attr,
+	&class_device_attr_topology_change.attr,
+	&class_device_attr_topology_change_detected.attr,
+	&class_device_attr_hello_timer.attr,
+	&class_device_attr_tcn_timer.attr,
+	&class_device_attr_topology_change_timer.attr,
+	&class_device_attr_gc_timer.attr,
+	NULL
+};
+
+static struct attribute_group bridge_group = {
+	.name = SYSFS_BRIDGE_ATTR,
+	.attrs = bridge_attrs,
+};
+
+/*
+ * Export the forwarding information table as a binary file
+ * The records are struct __fdb_entry.
+ *
+ * Returns the number of bytes read.
+ */
+static ssize_t brforward_read(struct kobject *kobj, char *buf,
+			   loff_t off, size_t count)
+{
+	struct class_device *cdev = to_class_dev(kobj);
+	struct net_bridge *br = to_bridge(cdev);
+	int n;
+
+	/* must read whole records */
+	if (off % sizeof(struct __fdb_entry) != 0)
+		return -EINVAL;
+
+	n =  br_fdb_fillbuf(br, buf, 
+			    count / sizeof(struct __fdb_entry),
+			    off / sizeof(struct __fdb_entry));
+
+	if (n > 0)
+		n *= sizeof(struct __fdb_entry);
+	
+	return n;
+}
+
+static struct bin_attribute bridge_forward = {
+	.attr = { .name = SYSFS_BRIDGE_FDB,
+		  .mode = S_IRUGO, 
+		  .owner = THIS_MODULE, },
+	.read = brforward_read,
+};
+
+
+/*
+ * This is a dummy kset so bridge objects don't cause
+ * hotplug events 
+ */
+struct subsystem bridge_subsys = { 
+	.kset = { .hotplug_ops = NULL },
+};
+
+void br_sysfs_init(void)
+{
+	subsystem_register(&bridge_subsys);
+}
+
+void br_sysfs_fini(void)
+{
+	subsystem_unregister(&bridge_subsys);
+}
+
+/*
+ * Add entries in sysfs onto the existing network class device
+ * for the bridge.
+ *   Adds a attribute group "bridge" containing tuning parameters.
+ *   Binary attribute containing the forward table
+ *   Sub directory to hold links to interfaces.
+ *
+ * Note: the ifobj exists only to be a subdirectory
+ *   to hold links.  The ifobj exists in same data structure
+ *   as it's parent the bridge so reference counting works.
+ */
+int br_sysfs_addbr(struct net_device *dev)
+{
+	struct kobject *brobj = &dev->class_dev.kobj;
+	struct net_bridge *br = netdev_priv(dev);
+	int err;
+
+	err = sysfs_create_group(brobj, &bridge_group);
+	if (err) {
+		pr_info("%s: can't create group %s/%s\n",
+			__FUNCTION__, dev->name, bridge_group.name);
+		goto out1;
+	}
+
+	err = sysfs_create_bin_file(brobj, &bridge_forward);
+	if (err) {
+		pr_info("%s: can't create attribue file %s/%s\n",
+			__FUNCTION__, dev->name, bridge_forward.attr.name);
+		goto out2;
+	}
+
+	
+	kobject_set_name(&br->ifobj, SYSFS_BRIDGE_PORT_SUBDIR);
+	br->ifobj.ktype = NULL;
+	br->ifobj.kset = &bridge_subsys.kset;
+	br->ifobj.parent = brobj;
+
+	err = kobject_register(&br->ifobj);
+	if (err) {
+		pr_info("%s: can't add kobject (directory) %s/%s\n",
+			__FUNCTION__, dev->name, br->ifobj.name);
+		goto out3;
+	}
+	return 0;
+ out3:
+	sysfs_remove_bin_file(&dev->class_dev.kobj, &bridge_forward);
+ out2:
+	sysfs_remove_group(&dev->class_dev.kobj, &bridge_group);
+ out1:
+	return err;
+
+}
+
+void br_sysfs_delbr(struct net_device *dev)
+{
+	struct kobject *kobj = &dev->class_dev.kobj;
+	struct net_bridge *br = netdev_priv(dev);
+
+	kobject_unregister(&br->ifobj);
+	sysfs_remove_bin_file(kobj, &bridge_forward);
+	sysfs_remove_group(kobj, &bridge_group);
+}
diff -Nru a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/net/bridge/br_sysfs_if.c	2004-05-21 16:27:21 -07:00
@@ -0,0 +1,269 @@
+/*
+ *	Sysfs attributes of bridge ports
+ *	Linux ethernet bridge
+ *
+ *	Authors:
+ *	Stephen Hemminger		<shemminger@osdl.org>
+ *
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License
+ *	as published by the Free Software Foundation; either version
+ *	2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/kernel.h>
+#include <linux/netdevice.h>
+#include <linux/if_bridge.h>
+#include <linux/rtnetlink.h>
+#include <linux/spinlock.h>
+
+#include "br_private.h"
+
+struct brport_attribute {
+	struct attribute	attr;
+	ssize_t (*show)(struct net_bridge_port *, char *);
+	ssize_t (*store)(struct net_bridge_port *, unsigned long);
+};
+
+#define BRPORT_ATTR(_name,_mode,_show,_store)		        \
+struct brport_attribute brport_attr_##_name = { 	        \
+	.attr = {.name = __stringify(_name), 			\
+		 .mode = _mode, 				\
+		 .owner = THIS_MODULE, },			\
+	.show	= _show,					\
+	.store	= _store,					\
+};
+
+static ssize_t show_path_cost(struct net_bridge_port *p, char *buf)
+{
+	return sprintf(buf, "%d\n", p->path_cost);
+}
+static ssize_t store_path_cost(struct net_bridge_port *p, unsigned long v)
+{
+	br_stp_set_path_cost(p, v);
+	return 0;
+}
+static BRPORT_ATTR(path_cost, S_IRUGO | S_IWUSR,
+		   show_path_cost, store_path_cost);
+
+static ssize_t show_priority(struct net_bridge_port *p, char *buf)
+{
+	return sprintf(buf, "%d\n", p->priority);
+}
+static ssize_t store_priority(struct net_bridge_port *p, unsigned long v)
+{
+	if (v >= (1<<(16-BR_PORT_BITS)))
+		return -ERANGE;
+	br_stp_set_port_priority(p, v);
+	return 0;
+}
+static BRPORT_ATTR(priority, S_IRUGO | S_IWUSR,
+			 show_priority, store_priority);
+
+static ssize_t show_designated_root(struct net_bridge_port *p, char *buf)
+{
+	return br_show_bridge_id(buf, &p->designated_root);
+}
+static BRPORT_ATTR(designated_root, S_IRUGO, show_designated_root, NULL);
+
+static ssize_t show_designated_bridge(struct net_bridge_port *p, char *buf)
+{
+	return br_show_bridge_id(buf, &p->designated_bridge);
+}
+static BRPORT_ATTR(designated_bridge, S_IRUGO, show_designated_bridge, NULL);
+
+static ssize_t show_designated_port(struct net_bridge_port *p, char *buf)
+{
+	return sprintf(buf, "%d\n", p->designated_port);
+}
+static BRPORT_ATTR(designated_port, S_IRUGO, show_designated_port, NULL);
+
+static ssize_t show_designated_cost(struct net_bridge_port *p, char *buf)
+{
+	return sprintf(buf, "%d\n", p->designated_cost);
+}
+static BRPORT_ATTR(designated_cost, S_IRUGO, show_designated_cost, NULL);
+
+static ssize_t show_port_id(struct net_bridge_port *p, char *buf)
+{
+	return sprintf(buf, "0x%x\n", p->port_id);
+}
+static BRPORT_ATTR(port_id, S_IRUGO, show_port_id, NULL);
+
+static ssize_t show_port_no(struct net_bridge_port *p, char *buf)
+{
+	return sprintf(buf, "0x%x\n", p->port_no);
+}
+
+static BRPORT_ATTR(port_no, S_IRUGO, show_port_no, NULL);
+
+static ssize_t show_change_ack(struct net_bridge_port *p, char *buf)
+{
+	return sprintf(buf, "%d\n", p->topology_change_ack);
+}
+static BRPORT_ATTR(change_ack, S_IRUGO, show_change_ack, NULL);
+
+static ssize_t show_config_pending(struct net_bridge_port *p, char *buf)
+{
+	return sprintf(buf, "%d\n", p->config_pending);
+}
+static BRPORT_ATTR(config_pending, S_IRUGO, show_config_pending, NULL);
+
+static ssize_t show_port_state(struct net_bridge_port *p, char *buf)
+{
+	return sprintf(buf, "%d\n", p->state);
+}
+static BRPORT_ATTR(state, S_IRUGO, show_port_state, NULL);
+
+static ssize_t show_message_age_timer(struct net_bridge_port *p,
+					    char *buf)
+{
+	return sprintf(buf, "%ld\n", br_timer_value(&p->message_age_timer));
+}
+static BRPORT_ATTR(message_age_timer, S_IRUGO, show_message_age_timer, NULL);
+
+static ssize_t show_forward_delay_timer(struct net_bridge_port *p,
+					    char *buf)
+{
+	return sprintf(buf, "%ld\n", br_timer_value(&p->forward_delay_timer));
+}
+static BRPORT_ATTR(forward_delay_timer, S_IRUGO, show_forward_delay_timer, NULL);
+
+static ssize_t show_hold_timer(struct net_bridge_port *p,
+					    char *buf)
+{
+	return sprintf(buf, "%ld\n", br_timer_value(&p->hold_timer));
+}
+static BRPORT_ATTR(hold_timer, S_IRUGO, show_hold_timer, NULL);
+
+static struct brport_attribute *brport_attrs[] = {
+	&brport_attr_path_cost,
+	&brport_attr_priority,
+	&brport_attr_port_id,
+	&brport_attr_port_no,
+	&brport_attr_designated_root,
+	&brport_attr_designated_bridge,
+	&brport_attr_designated_port,
+	&brport_attr_designated_cost,
+	&brport_attr_state,
+	&brport_attr_change_ack,
+	&brport_attr_config_pending,
+	&brport_attr_message_age_timer,
+	&brport_attr_forward_delay_timer,
+	&brport_attr_hold_timer,
+	NULL
+};
+
+#define to_brport_attr(_at) container_of(_at, struct brport_attribute, attr)
+#define to_brport(obj)	container_of(obj, struct net_bridge_port, kobj)
+
+static ssize_t brport_show(struct kobject * kobj,
+			   struct attribute * attr, char * buf)
+{
+	struct brport_attribute * brport_attr = to_brport_attr(attr);
+	struct net_bridge_port * p = to_brport(kobj);
+
+	return brport_attr->show(p, buf);
+}
+
+static ssize_t brport_store(struct kobject * kobj,
+			    struct attribute * attr,
+			    const char * buf, size_t count)
+{
+	struct brport_attribute * brport_attr = to_brport_attr(attr);
+	struct net_bridge_port * p = to_brport(kobj);
+	ssize_t ret = -EINVAL;
+	char *endp;
+	unsigned long val;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	val = simple_strtoul(buf, &endp, 0);
+	if (endp != buf) {
+		rtnl_lock();
+		if (p->dev && p->br && brport_attr->store) {
+			spin_lock_bh(&p->br->lock);
+			ret = brport_attr->store(p, val);
+			spin_unlock_bh(&p->br->lock);
+			if (ret == 0)
+				ret = count;
+		}
+		rtnl_unlock();
+	}
+	return ret;
+}
+
+/* called from kobject_put when port ref count goes to zero. */
+static void brport_release(struct kobject *kobj)
+{
+	kfree(container_of(kobj, struct net_bridge_port, kobj));
+}
+
+static struct sysfs_ops brport_sysfs_ops = {
+	.show = brport_show,
+	.store = brport_store,
+};
+
+static struct kobj_type brport_ktype = {
+	.sysfs_ops = &brport_sysfs_ops,
+	.release = brport_release,
+};
+
+
+/*
+ * Add sysfs entries to ethernet device added to a bridge.
+ * Creates a brport subdirectory with bridge attributes.
+ * Puts symlink in bridge's brport subdirectory
+ */
+int br_sysfs_addif(struct net_bridge_port *p)
+{
+	struct net_bridge *br = p->br;
+	struct brport_attribute **a;
+	int err;
+
+	ASSERT_RTNL();
+
+	kobject_set_name(&p->kobj, SYSFS_BRIDGE_PORT_ATTR);
+	p->kobj.ktype = &brport_ktype;
+	p->kobj.parent = &(p->dev->class_dev.kobj);
+	p->kobj.kset = &bridge_subsys.kset;
+
+	err = kobject_add(&p->kobj);
+	if(err)
+		goto out1;
+
+	err = sysfs_create_link(&p->kobj, &br->dev->class_dev.kobj, 
+				SYSFS_BRIDGE_PORT_LINK);
+	if (err)
+		goto out2;
+
+	for (a = brport_attrs; *a; ++a) {
+		err = sysfs_create_file(&p->kobj, &((*a)->attr));
+		if (err)
+			goto out2;
+	}
+
+	err = sysfs_create_link(&br->ifobj, &p->kobj, p->dev->name);
+	if (err)
+		goto out2;
+
+	return 0;
+ out2:
+	kobject_del(&p->kobj);
+ out1:
+	return err;
+}
+
+void br_sysfs_removeif(struct net_bridge_port *p)
+{
+	pr_debug("br_sysfs_removeif\n");
+	sysfs_remove_link(&p->br->ifobj, p->dev->name);
+	kobject_del(&p->kobj);
+}
+
+void br_sysfs_freeif(struct net_bridge_port *p)
+{
+	pr_debug("br_sysfs_freeif\n");
+	kobject_put(&p->kobj);
+}
