From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] sysfs support of network devices
Date: Tue, 20 May 2003 14:12:30 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030520141230.04db8dec.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, greg@kroah.com, mochel@osdl.org, jkenisto@us.ibm.com,
   lkessler@us.ibm.com, dsteklof@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is the network core infrastructure changes for network device support
of sysfs.  The changes from the earlier patch are:
	- sysfs support is not a config option.
	- updated to latest 2.5.69 including latest net device changes
	- only mtu, tx_queue_len and flags are writeable.

Please apply. Comments and extensions are always welcome.


diff -urNp -X dontdiff linux-2.5/include/linux/netdevice.h linux-2.5-sysfs/include/linux/netdevice.h
--- linux-2.5/include/linux/netdevice.h	2003-05-20 10:52:48.000000000 -0700
+++ linux-2.5-sysfs/include/linux/netdevice.h	2003-05-20 11:01:24.000000000 -0700
@@ -28,7 +28,7 @@
 #include <linux/if.h>
 #include <linux/if_ether.h>
 #include <linux/if_packet.h>
-#include <linux/kobject.h>
+#include <linux/device.h>
 
 #include <asm/atomic.h>
 #include <asm/cache.h>
@@ -441,11 +441,22 @@ struct net_device
 	struct divert_blk	*divert;
 #endif /* CONFIG_NET_DIVERT */
 
-	/* generic object representation */
-	struct kobject kobj;
+	/* generic device structure used in constructing class */
+	struct device		*dev;
+
+	/* class/net/name entry */
+	struct class_device	class_dev;
+
+	/* statistics sub-directory */
+	struct kobject		stats_kobj;
 };
 
 #define SET_MODULE_OWNER(dev) do { } while (0)
+/* Set the sysfs physical device reference for the network logical device
+ * if set prior to registration will cause a symlink during initialization.
+ */
+#define SET_NETDEV_DEV(net, pdev)	((net)->dev = (pdev))
+
 
 struct packet_type 
 {
@@ -561,12 +572,12 @@ static inline void netif_stop_queue(stru
 	set_bit(__LINK_STATE_XOFF, &dev->state);
 }
 
-static inline int netif_queue_stopped(struct net_device *dev)
+static inline int netif_queue_stopped(const struct net_device *dev)
 {
 	return test_bit(__LINK_STATE_XOFF, &dev->state);
 }
 
-static inline int netif_running(struct net_device *dev)
+static inline int netif_running(const struct net_device *dev)
 {
 	return test_bit(__LINK_STATE_START, &dev->state);
 }
@@ -606,7 +617,9 @@ extern int		netif_rx(struct sk_buff *skb
 #define HAVE_NETIF_RECEIVE_SKB 1
 extern int		netif_receive_skb(struct sk_buff *skb);
 extern int		dev_ioctl(unsigned int cmd, void *);
+extern unsigned		dev_get_flags(const struct net_device *);
 extern int		dev_change_flags(struct net_device *, unsigned);
+extern int		dev_set_mtu(struct net_device *, int);
 extern void		dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev);
 
 extern void		dev_init(void);
@@ -642,7 +655,7 @@ static inline void dev_put(struct net_de
 
 extern void linkwatch_fire_event(struct net_device *dev);
 
-static inline int netif_carrier_ok(struct net_device *dev)
+static inline int netif_carrier_ok(const struct net_device *dev)
 {
 	return !test_bit(__LINK_STATE_NOCARRIER, &dev->state);
 }
diff -urNp -X dontdiff linux-2.5/net/core/dev.c linux-2.5-sysfs/net/core/dev.c
--- linux-2.5/net/core/dev.c	2003-05-20 10:52:48.000000000 -0700
+++ linux-2.5-sysfs/net/core/dev.c	2003-05-20 13:46:33.000000000 -0700
@@ -131,16 +131,6 @@ extern int plip_init(void);
 NET_PROFILE_DEFINE(dev_queue_xmit)
 NET_PROFILE_DEFINE(softnet_process)
 
-const char *if_port_text[] = {
-  "unknown",
-  "BNC",
-  "10baseT",
-  "AUI",
-  "100baseT",
-  "100baseTX",
-  "100baseFX"
-};
-
 /*
  *	The list of packet types we will receive (as opposed to discard)
  *	and the routines to invoke.
@@ -203,7 +193,9 @@ int netdev_fastroute;
 int netdev_fastroute_obstacles;
 #endif
 
-static struct subsystem net_subsys;
+extern int netdev_sysfs_init(void);
+extern int netdev_register_sysfs(struct net_device *);
+extern void netdev_unregister_sysfs(struct net_device *);
 
 
 /*******************************************************************************
@@ -2084,6 +2076,22 @@ void dev_set_allmulti(struct net_device 
 		dev_mc_upload(dev);
 }
 
+unsigned dev_get_flags(const struct net_device *dev)
+{
+	unsigned flags;
+
+	flags = (dev->flags & ~(IFF_PROMISC |
+				IFF_ALLMULTI |
+				IFF_RUNNING)) | 
+		(dev->gflags & (IFF_PROMISC |
+				IFF_ALLMULTI));
+
+	if (netif_running(dev) && netif_carrier_ok(dev))
+		flags |= IFF_RUNNING;
+
+	return flags;
+}
+
 int dev_change_flags(struct net_device *dev, unsigned flags)
 {
 	int ret;
@@ -2146,6 +2154,32 @@ int dev_change_flags(struct net_device *
 	return ret;
 }
 
+int dev_set_mtu(struct net_device *dev, int new_mtu)
+{
+	int err;
+
+	if (new_mtu == dev->mtu)
+		return 0;
+
+	/*	MTU must be positive.	 */
+	if (new_mtu < 0)
+		return -EINVAL;
+
+	if (!netif_device_present(dev))
+		return -ENODEV;
+
+	err = 0;
+	if (dev->change_mtu)
+		err = dev->change_mtu(dev, new_mtu);
+	else
+		dev->mtu = new_mtu;
+	if (!err && dev->flags & IFF_UP)
+		notifier_call_chain(&netdev_chain,
+				    NETDEV_CHANGEMTU, dev);
+	return err;
+}
+
+
 /*
  *	Perform the SIOCxIFxxx calls.
  */
@@ -2159,13 +2193,7 @@ static int dev_ifsioc(struct ifreq *ifr,
 
 	switch (cmd) {
 		case SIOCGIFFLAGS:	/* Get interface flags */
-			ifr->ifr_flags = (dev->flags & ~(IFF_PROMISC |
-							 IFF_ALLMULTI |
-							 IFF_RUNNING)) | 
-					 (dev->gflags & (IFF_PROMISC |
-							 IFF_ALLMULTI));
-			if (netif_running(dev) && netif_carrier_ok(dev))
-				ifr->ifr_flags |= IFF_RUNNING;
+			ifr->ifr_flags = dev_get_flags(dev);
 			return 0;
 
 		case SIOCSIFFLAGS:	/* Set interface flags */
@@ -2185,27 +2213,7 @@ static int dev_ifsioc(struct ifreq *ifr,
 			return 0;
 
 		case SIOCSIFMTU:	/* Set the MTU of a device */
-			if (ifr->ifr_mtu == dev->mtu)
-				return 0;
-
-			/*
-			 *	MTU must be positive.
-			 */
-			if (ifr->ifr_mtu < 0)
-				return -EINVAL;
-
-			if (!netif_device_present(dev))
-				return -ENODEV;
-
-			err = 0;
-			if (dev->change_mtu)
-				err = dev->change_mtu(dev, ifr->ifr_mtu);
-			else
-				dev->mtu = ifr->ifr_mtu;
-			if (!err && dev->flags & IFF_UP)
-				notifier_call_chain(&netdev_chain,
-						    NETDEV_CHANGEMTU, dev);
-			return err;
+			return dev_set_mtu(dev, ifr->ifr_mtu);
 
 		case SIOCGIFHWADDR:
 			memcpy(ifr->ifr_hwaddr.sa_data, dev->dev_addr,
@@ -2293,6 +2301,7 @@ static int dev_ifsioc(struct ifreq *ifr,
 				return -EEXIST;
 			memcpy(dev->name, ifr->ifr_newname, IFNAMSIZ);
 			dev->name[IFNAMSIZ - 1] = 0;
+			snprintf(dev->class_dev.class_id, BUS_ID_SIZE, dev->name);
 			notifier_call_chain(&netdev_chain,
 					    NETDEV_CHANGENAME, dev);
 			return 0;
@@ -2591,11 +2600,10 @@ int register_netdevice(struct net_device
 		if (d == dev || !strcmp(d->name, dev->name))
 			goto out_err;
 	}
-	snprintf(dev->kobj.name,KOBJ_NAME_LEN,dev->name);
-	kobj_set_kset_s(dev,net_subsys);
-	if ((ret = kobject_register(&dev->kobj)))
-		goto out_err;
 	
+	if ((ret = netdev_register_sysfs(dev)))
+	    goto out_err;
+
 	/* Fix illegal SG+CSUM combinations. */
 	if ((dev->features & NETIF_F_SG) &&
 	    !(dev->features & (NETIF_F_IP_CSUM |
@@ -2848,8 +2856,7 @@ int unregister_netdevice(struct net_devi
 #ifdef CONFIG_NET_DIVERT
 	free_divert_blk(dev);
 #endif
-
-	kobject_unregister(&dev->kobj);
+	netdev_unregister_sysfs(dev);
 
 	spin_lock(&unregister_todo_lock);
 	dev->next = unregister_todo;
@@ -2874,8 +2881,6 @@ extern void ip_auto_config(void);
 extern void dv_init(void);
 #endif /* CONFIG_NET_DIVERT */
 
-static decl_subsys(net,NULL,NULL);
-
 
 /*
  *       This is called single threaded during boot, so no need
@@ -2891,7 +2896,8 @@ static int __init net_dev_init(void)
 	if (dev_proc_init())
 		goto out;
 
-	subsystem_register(&net_subsys);
+	if (netdev_sysfs_init())
+		goto out;
 
 	INIT_LIST_HEAD(&ptype_all);
 	for (i = 0; i < 16; i++) 
@@ -2965,7 +2971,8 @@ static int __init net_dev_init(void)
 		 */
 		netdev_boot_setup_check(dev);
 
-		if (dev->init && dev->init(dev)) {
+		if ( (dev->init && dev->init(dev)) ||
+		     netdev_register_sysfs(dev) ) {
 			/*
 			 * It failed to come up. It will be unhooked later.
 			 * dev_alloc_name can now advance to next suitable
diff -urNp -X dontdiff linux-2.5/net/core/Makefile linux-2.5-sysfs/net/core/Makefile
--- linux-2.5/net/core/Makefile	2003-05-19 11:40:20.000000000 -0700
+++ linux-2.5-sysfs/net/core/Makefile	2003-05-19 12:52:54.000000000 -0700
@@ -10,7 +10,8 @@ obj-y += sysctl_net_core.o
 endif
 endif
 
-obj-$(CONFIG_NET) += flow.o dev.o dev_mcast.o dst.o neighbour.o rtnetlink.o utils.o link_watch.o filter.o
+obj-$(CONFIG_NET) += flow.o dev.o net-sysfs.o dev_mcast.o dst.o neighbour.o \
+		     rtnetlink.o utils.o link_watch.o filter.o
 
 obj-$(CONFIG_NETFILTER) += netfilter.o
 obj-$(CONFIG_NET_DIVERT) += dv.o
diff -urNp -X dontdiff linux-2.5/net/core/net-sysfs.c linux-2.5-sysfs/net/core/net-sysfs.c
--- linux-2.5/net/core/net-sysfs.c	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.5-sysfs/net/core/net-sysfs.c	2003-05-20 10:30:01.000000000 -0700
@@ -0,0 +1,344 @@
+/*
+ * net-sysfs.c - network device class and attributes
+ *
+ * Copyright (c) 2003 Stephen Hemminber <shemminger@osdl.org>
+ * 
+ *
+ * TODO:
+ * last_tx
+ * last_rx
+ */
+
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/netdevice.h>
+#include <linux/if_arp.h>
+#include <net/sock.h>
+#include <linux/rtnetlink.h>
+
+const char *if_port_text[] = {
+   [IF_PORT_UNKNOWN] = "unknown",
+   [IF_PORT_10BASE2] = "BNC",
+   [IF_PORT_10BASET] = "10baseT",
+   [IF_PORT_AUI]     = "AUI",
+   [IF_PORT_100BASET] = "100baseT",
+   [IF_PORT_100BASETX] = "100baseTX",
+   [IF_PORT_100BASEFX] = "100baseFX"
+};
+
+#define to_net_dev(class) container_of((class), struct net_device, class_dev)
+
+/* generate a show function for  simple field */
+#define NETDEVICE_SHOW(field, format_string)				\
+static ssize_t show_##field(struct class_device *dev, char *buf)	\
+{									\
+	return sprintf(buf, format_string, to_net_dev(dev)->field);	\
+}
+
+/* generate a store function for a field with locking */
+#define NETDEVICE_STORE(field)						\
+static ssize_t 								\
+store_##field(struct class_device *dev, const char *buf, size_t len)	\
+{									\
+	char *endp;							\
+	long new = simple_strtol(buf, &endp, 16);			\
+									\
+	if (endp == buf || new < 0)					\
+		return -EINVAL;						\
+									\
+	if (!capable(CAP_NET_ADMIN))					\
+		return -EPERM;						\
+									\
+	rtnl_lock();							\
+	to_net_dev(dev)->field = new;					\
+	rtnl_unlock();							\
+	return len;							\
+}
+
+/* generate a read-only network device class attribute */
+#define NETDEVICE_ATTR(field, format_string)				\
+NETDEVICE_SHOW(field, format_string)					\
+static CLASS_DEVICE_ATTR(field, S_IRUGO, show_##field, NULL)		\
+
+NETDEVICE_ATTR(addr_len, "%d\n");
+NETDEVICE_ATTR(iflink, "%d\n");
+NETDEVICE_ATTR(ifindex, "%d\n");
+NETDEVICE_ATTR(features, "%#x\n");
+NETDEVICE_ATTR(type, "%d\n");
+
+/* TODO: only a few devices set this now should fix others. */
+static ssize_t show_port(struct class_device *dev, char *buf)
+{
+	unsigned char port = to_net_dev(dev)->if_port;
+	char *cp = buf;
+
+	cp += sprintf(cp, "%d", port);
+	if (port < ARRAY_SIZE(if_port_text))
+		cp += sprintf(cp, " (%s)", if_port_text[port]);
+	*cp++ ='\n';
+	return cp - buf;
+}
+static CLASS_DEVICE_ATTR(if_port, S_IRUGO, show_port, NULL);
+
+static ssize_t format_addr(char *buf, const unsigned char *addr, int len)
+{
+	int i;
+	char *cp = buf;
+
+	read_lock(&dev_base_lock);
+	for (i = 0; i < len; i++)
+		cp += sprintf(cp, "%02x%c", addr[i],
+			      i == (len - 1) ? '\n' : ':');
+	read_unlock(&dev_base_lock);
+	return cp - buf;
+}
+
+static ssize_t show_address(struct class_device *dev, char *buf)
+{
+	struct net_device *net = to_net_dev(dev);
+	return format_addr(buf, net->dev_addr, net->addr_len);
+}
+
+static ssize_t show_broadcast(struct class_device *dev, char *buf)
+{
+	struct net_device *net = to_net_dev(dev);
+	return format_addr(buf, net->broadcast, net->addr_len);
+}
+
+static CLASS_DEVICE_ATTR(address, S_IRUGO, show_address, NULL);
+static CLASS_DEVICE_ATTR(broadcast, S_IRUGO, show_broadcast, NULL);
+
+/* read-write attributes */
+NETDEVICE_SHOW(mtu, "%d\n");
+
+static ssize_t store_mtu(struct class_device *dev, const char *buf, size_t len)
+{
+	char *endp;
+	int new_mtu;
+	int err;
+
+	new_mtu = simple_strtoul(buf, &endp, 10);
+	if (endp == buf) 
+		return -EINVAL;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+	
+	rtnl_lock();
+	err = dev_set_mtu(to_net_dev(dev), new_mtu);
+	rtnl_unlock();
+
+	return err == 0 ? len : err;
+}
+
+static CLASS_DEVICE_ATTR(mtu, S_IRUGO | S_IWUSR, show_mtu, store_mtu);
+
+NETDEVICE_SHOW(flags, "%#x\n");
+
+static ssize_t store_flags(struct class_device *dev, const char *buf, size_t len)
+{
+	unsigned long new_flags;
+	char *endp;
+	int err = 0;
+
+	new_flags = simple_strtoul(buf, &endp, 16);
+	if (endp == buf)
+		return -EINVAL;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+	
+	rtnl_lock();
+	err = dev_change_flags(to_net_dev(dev), new_flags);
+	rtnl_unlock();
+
+	return err ? err : len;
+}
+
+static CLASS_DEVICE_ATTR(flags, S_IRUGO | S_IWUSR, show_flags, store_flags);
+
+NETDEVICE_SHOW(tx_queue_len, "%lu\n");
+NETDEVICE_STORE(tx_queue_len);
+static CLASS_DEVICE_ATTR(tx_queue_len, S_IRUGO | S_IWUSR, show_tx_queue_len, 
+			 store_tx_queue_len);
+
+static struct class net_class = {
+	.name = "net",
+};
+
+
+static struct class_device_attribute *net_class_attributes[] = {
+	&class_device_attr_ifindex,
+	&class_device_attr_iflink,
+	&class_device_attr_addr_len,
+	&class_device_attr_tx_queue_len,
+	&class_device_attr_features,
+	&class_device_attr_mtu,
+	&class_device_attr_flags,
+	&class_device_attr_if_port,
+	&class_device_attr_type,
+	&class_device_attr_address,
+	&class_device_attr_broadcast,
+	NULL
+};
+
+struct netstat_fs_entry {
+	struct attribute attr;
+	ssize_t (*show)(const struct net_device_stats *, char *);
+	ssize_t (*store)(struct net_device_stats *, const char *, size_t);
+};
+
+static ssize_t net_device_stat_show(unsigned long var, char *buf)
+{
+	return sprintf(buf, "%ld\n", var);
+}
+
+/* generate a read-only statistics attribute */
+#define NETDEVICE_STAT(_NAME)						\
+static ssize_t show_stat_##_NAME(const struct net_device_stats *stats,	\
+				 char *buf)				\
+{									\
+	return net_device_stat_show(stats->_NAME, buf);			\
+}									\
+static struct netstat_fs_entry net_stat_##_NAME  = {		   	\
+	.attr = {.name = __stringify(_NAME), .mode = S_IRUGO },		\
+	.show = show_stat_##_NAME,					\
+}
+
+NETDEVICE_STAT(rx_packets);
+NETDEVICE_STAT(tx_packets);
+NETDEVICE_STAT(rx_bytes);
+NETDEVICE_STAT(tx_bytes);
+NETDEVICE_STAT(rx_errors);
+NETDEVICE_STAT(tx_errors);
+NETDEVICE_STAT(rx_dropped);
+NETDEVICE_STAT(tx_dropped);
+NETDEVICE_STAT(multicast);
+NETDEVICE_STAT(collisions);
+NETDEVICE_STAT(rx_length_errors);
+NETDEVICE_STAT(rx_over_errors);
+NETDEVICE_STAT(rx_crc_errors);
+NETDEVICE_STAT(rx_frame_errors);
+NETDEVICE_STAT(rx_fifo_errors);
+NETDEVICE_STAT(rx_missed_errors);
+NETDEVICE_STAT(tx_aborted_errors);
+NETDEVICE_STAT(tx_carrier_errors);
+NETDEVICE_STAT(tx_fifo_errors);
+NETDEVICE_STAT(tx_heartbeat_errors);
+NETDEVICE_STAT(tx_window_errors);
+NETDEVICE_STAT(rx_compressed);
+NETDEVICE_STAT(tx_compressed);
+
+static struct attribute *default_attrs[] = {
+	&net_stat_rx_packets.attr,
+	&net_stat_tx_packets.attr,
+	&net_stat_rx_bytes.attr,
+	&net_stat_tx_bytes.attr,
+	&net_stat_rx_errors.attr,
+	&net_stat_tx_errors.attr,
+	&net_stat_rx_dropped.attr,
+	&net_stat_tx_dropped.attr,
+	&net_stat_multicast.attr,
+	&net_stat_collisions.attr,
+	&net_stat_rx_length_errors.attr,
+	&net_stat_rx_over_errors.attr,
+	&net_stat_rx_crc_errors.attr,
+	&net_stat_rx_frame_errors.attr,
+	&net_stat_rx_fifo_errors.attr,
+	&net_stat_rx_missed_errors.attr,
+	&net_stat_tx_aborted_errors.attr,
+	&net_stat_tx_carrier_errors.attr,
+	&net_stat_tx_fifo_errors.attr,
+	&net_stat_tx_heartbeat_errors.attr,
+	&net_stat_tx_window_errors.attr,
+	&net_stat_rx_compressed.attr,
+	&net_stat_tx_compressed.attr,
+	NULL
+};
+
+
+static ssize_t
+netstat_attr_show(struct kobject *kobj, struct attribute *attr, char *buf)
+{
+	struct netstat_fs_entry *entry
+		= container_of(attr, struct netstat_fs_entry, attr);
+	struct class_device *class_dev
+		= container_of(kobj->parent, struct class_device, kobj);
+	struct net_device *dev
+		= to_net_dev(class_dev);
+	struct net_device_stats *stats 
+		= dev->get_stats ? dev->get_stats(dev) : NULL;
+
+	if (stats && entry->show) 
+		return entry->show(stats, buf);
+	return -EINVAL;
+}
+
+static struct sysfs_ops netstat_sysfs_ops = {
+	.show = netstat_attr_show,
+};
+
+static struct kobj_type netstat_ktype = {
+	.sysfs_ops	= &netstat_sysfs_ops,
+	.default_attrs  = default_attrs,
+};
+
+/* Create sysfs entries for network device. */
+int netdev_register_sysfs(struct net_device *net)
+{
+	struct class_device *class_dev = &(net->class_dev);
+	int i;
+	struct class_device_attribute *attr;
+	int ret;
+
+	memset(class_dev, 0, sizeof(struct class_device)); 
+	class_dev->class = &net_class;
+	class_dev->dev = net->dev;
+	class_dev->class_data = net;
+
+	snprintf(class_dev->class_id, BUS_ID_SIZE, net->name);
+	if ((ret = class_device_register(class_dev)))
+		goto out;
+
+	for (i = 0; (attr = net_class_attributes[i]); i++) {
+		if ((ret = class_device_create_file(class_dev, attr)))
+		    goto out_unreg;
+	}
+
+	if (net->get_stats) {
+		struct kobject *k = &net->stats_kobj;
+
+		memset(k, 0, sizeof(*k));
+		k->parent = kobject_get(&class_dev->kobj);
+		if (!k->parent) {
+			ret = -EBUSY;
+			goto out_unreg;
+		}
+
+		snprintf(k->name, KOBJ_NAME_LEN, "%s", "statistics");
+		k->ktype = &netstat_ktype;
+
+		if((ret = kobject_register(k))) 
+			 goto out_unreg; 
+	}
+
+out:
+	return ret;
+out_unreg:
+	printk(KERN_WARNING "%s: sysfs attribute registration failed %d\n",
+	       net->name, ret);
+	class_device_unregister(class_dev);
+	goto out;
+}
+
+void netdev_unregister_sysfs(struct net_device *net)
+{
+	if (net->get_stats)
+		kobject_del(&net->stats_kobj);
+	class_device_unregister(&net->class_dev);
+}
+
+int netdev_sysfs_init(void)
+{
+	return class_register(&net_class);
+}
