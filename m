From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 1/2] Sysfs net class - infrastructure
Date: Thu, 15 May 2003 16:27:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030515162717.477fb84b.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, greg@kroah.com, mochel@osdl.org, jkenisto@us.ibm.com,
   lkessler@us.ibm.com, Daniel Stekloff
 <dsteklof@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Patrick Mochel <mochel@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is the network core infrastructure changes for network device
sysfs support.  Previous /sysfs/net support is removed, it was
just an empty place holder. Places where both ioctl and sysfs need
to access the same value were put into one function.

diff -urNp -X dontdiff linux-2.5/include/linux/netdevice.h linux-2.5-sysfs/include/linux/netdevice.h
--- linux-2.5/include/linux/netdevice.h	2003-05-13 09:03:54.000000000 -0700
+++ linux-2.5-sysfs/include/linux/netdevice.h	2003-05-15 14:40:13.000000000 -0700
@@ -28,7 +28,7 @@
 #include <linux/if.h>
 #include <linux/if_ether.h>
 #include <linux/if_packet.h>
-#include <linux/kobject.h>
+#include <linux/device.h>
 
 #include <asm/atomic.h>
 #include <asm/cache.h>
@@ -229,6 +229,7 @@ struct netdev_boot_setup {
 #define NETDEV_BOOT_SETUP_MAX 8
 
 
+
 /*
  *	The DEVICE structure.
  *	Actually, this whole structure is a big mistake.  It mixes I/O
@@ -444,8 +445,16 @@ struct net_device
 	struct divert_blk	*divert;
 #endif /* CONFIG_NET_DIVERT */
 
-	/* generic object representation */
-	struct kobject kobj;
+#ifdef CONFIG_NET_SYSFS
+	/* generic device structure */
+	struct device		*dev;
+
+	/* class_device representation */
+	struct class_device	class_dev;
+
+	/* statistics object */
+	struct kobject		stats_kobj;
+#endif
 };
 
 
@@ -563,12 +572,12 @@ static inline void netif_stop_queue(stru
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
@@ -608,7 +617,9 @@ extern int		netif_rx(struct sk_buff *skb
 #define HAVE_NETIF_RECEIVE_SKB 1
 extern int		netif_receive_skb(struct sk_buff *skb);
 extern int		dev_ioctl(unsigned int cmd, void *);
+extern unsigned		dev_get_flags(const struct net_device *);
 extern int		dev_change_flags(struct net_device *, unsigned);
+extern int		dev_set_mtu(struct net_device *, int);
 extern void		dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev);
 
 extern void		dev_init(void);
@@ -644,7 +655,7 @@ static inline void dev_put(struct net_de
 
 extern void linkwatch_fire_event(struct net_device *dev);
 
-static inline int netif_carrier_ok(struct net_device *dev)
+static inline int netif_carrier_ok(const struct net_device *dev)
 {
 	return !test_bit(__LINK_STATE_NOCARRIER, &dev->state);
 }
@@ -836,6 +847,15 @@ extern int		netdev_fastroute_obstacles;
 extern void		dev_clear_fastroute(struct net_device *dev);
 #endif
 
+/* Set the sysfs physical device reference for the network logical device
+ * if set prior to registration will cause a symlink during initialization.
+ */
+#ifdef CONFIG_NET_SYSFS
+#define SET_NETDEV_DEV(net, pdev)	(net)->dev = (pdev)
+#else
+#define SET_NETDEV_DEV(net, pdev)	do { } while(0)
+#endif
+
 
 #endif /* __KERNEL__ */
 
diff -urNp -X dontdiff linux-2.5/net/core/dev.c linux-2.5-sysfs/net/core/dev.c
--- linux-2.5/net/core/dev.c	2003-05-14 10:41:43.000000000 -0700
+++ linux-2.5-sysfs/net/core/dev.c	2003-05-15 14:49:15.000000000 -0700
@@ -201,7 +201,12 @@ int netdev_fastroute;
 int netdev_fastroute_obstacles;
 #endif
 
-static struct subsystem net_subsys;
+#ifdef CONFIG_NET_SYSFS
+extern struct class net_class;
+extern int netdev_create_sysfs(struct net_device *);
+#else
+#define netdev_create_sysfs(net)	((void)(net), 0)
+#endif
 
 
 /*******************************************************************************
@@ -2101,6 +2106,22 @@ void dev_set_allmulti(struct net_device 
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
@@ -2163,6 +2184,32 @@ int dev_change_flags(struct net_device *
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
@@ -2176,13 +2223,7 @@ static int dev_ifsioc(struct ifreq *ifr,
 
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
@@ -2202,27 +2243,7 @@ static int dev_ifsioc(struct ifreq *ifr,
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
@@ -2310,6 +2331,9 @@ static int dev_ifsioc(struct ifreq *ifr,
 				return -EEXIST;
 			memcpy(dev->name, ifr->ifr_newname, IFNAMSIZ);
 			dev->name[IFNAMSIZ - 1] = 0;
+#ifdef CONFIG_NET_SYSFS
+			snprintf(dev->class_dev.class_id, BUS_ID_SIZE, dev->name);
+#endif
 			notifier_call_chain(&netdev_chain,
 					    NETDEV_CHANGENAME, dev);
 			return 0;
@@ -2556,6 +2580,7 @@ int dev_new_index(void)
 	}
 }
 
+	
 static int dev_boot_phase = 1;
 
 /**
@@ -2613,11 +2638,10 @@ int register_netdevice(struct net_device
 		if (d == dev || !strcmp(d->name, dev->name))
 			goto out_err;
 	}
-	snprintf(dev->kobj.name,KOBJ_NAME_LEN,dev->name);
-	kobj_set_kset_s(dev,net_subsys);
-	if ((ret = kobject_register(&dev->kobj)))
-		goto out_err;
 	
+	if ((ret = netdev_create_sysfs(dev)))
+	    goto out_err;
+
 	/* Fix illegal SG+CSUM combinations. */
 	if ((dev->features & NETIF_F_SG) &&
 	    !(dev->features & (NETIF_F_IP_CSUM |
@@ -2843,7 +2867,9 @@ int unregister_netdevice(struct net_devi
 		}
 	}
 out:
-	kobject_unregister(&dev->kobj);
+#ifdef CONFIG_NET_SYSFS
+	class_device_unregister(&dev->class_dev);
+#endif
 	dev_put(dev);
 	return 0;
 }
@@ -2862,8 +2888,6 @@ extern void ip_auto_config(void);
 extern void dv_init(void);
 #endif /* CONFIG_NET_DIVERT */
 
-static decl_subsys(net,NULL,NULL);
-
 
 /*
  *       This is called single threaded during boot, so no need
@@ -2879,7 +2903,10 @@ static int __init net_dev_init(void)
 	if (dev_proc_init())
 		goto out;
 
-	subsystem_register(&net_subsys);
+#ifdef CONFIG_NET_SYSFS
+	if (class_register(&net_class))
+		goto out;
+#endif
 
 	INIT_LIST_HEAD(&ptype_all);
 	for (i = 0; i < 16; i++) 
@@ -2953,7 +2980,7 @@ static int __init net_dev_init(void)
 		 */
 		netdev_boot_setup_check(dev);
 
-		if (dev->init && dev->init(dev)) {
+		if ((dev->init && dev->init(dev)) || netdev_create_sysfs(dev)) {
 			/*
 			 * It failed to come up. It will be unhooked later.
 			 * dev_alloc_name can now advance to next suitable
@@ -3042,3 +3069,4 @@ static int net_run_sbin_hotplug(struct n
 	return call_usermodehelper(argv [0], argv, envp, 0);
 }
 #endif
+
diff -urNp -X dontdiff linux-2.5/net/core/Makefile linux-2.5-sysfs/net/core/Makefile
--- linux-2.5/net/core/Makefile	2003-04-29 11:54:39.000000000 -0700
+++ linux-2.5-sysfs/net/core/Makefile	2003-05-15 15:04:20.000000000 -0700
@@ -12,6 +12,7 @@ endif
 
 obj-$(CONFIG_NET) += dev.o dev_mcast.o dst.o neighbour.o rtnetlink.o utils.o link_watch.o filter.o
 
+obj-$(CONFIG_NET_SYSFS) += net-sysfs.o 
 obj-$(CONFIG_NETFILTER) += netfilter.o
 obj-$(CONFIG_NET_DIVERT) += dv.o
 obj-$(CONFIG_NET_PROFILE) += profile.o
diff -urNp -X dontdiff linux-2.5/net/core/net-sysfs.c linux-2.5-sysfs/net/core/net-sysfs.c
--- linux-2.5/net/core/net-sysfs.c	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.5-sysfs/net/core/net-sysfs.c	2003-05-15 16:03:12.000000000 -0700
@@ -0,0 +1,327 @@
+/*
+ * net-sysfs.c - network device class and attributes
+ *
+ * Copyright (c) 2003 Stephen Hemminber <shemminger@osdl.org>
+ * 
+ *
+ * TODO:
+ * state
+ * last_tx
+ * last_rx
+ */
+
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/netdevice.h>
+#include <net/sock.h>
+#include <linux/rtnetlink.h>
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
+NETDEVICE_ATTR(type, "%d\n");
+NETDEVICE_ATTR(addr_len, "%d\n");
+NETDEVICE_ATTR(features, "%#x\n");
+
+/* TODO: only a few devices set this now should fix others. */
+static ssize_t show_port(struct class_device *dev, char *buf)
+{
+	unsigned char port = to_net_dev(dev)->if_port;
+	if (port > IF_PORT_100BASEFX)
+		return sprintf(buf, "%d\n", port);
+	else
+		return sprintf(buf, "%s\n", if_port_text[port]);
+}
+
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
+static ssize_t show_flags(struct class_device *dev, char *buf)
+{
+	return sprintf(buf, "%#x\n", dev_get_flags(to_net_dev(dev)));
+}
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
+
+NETDEVICE_SHOW(tx_queue_len, "%lu\n");
+NETDEVICE_STORE(tx_queue_len);
+
+static CLASS_DEVICE_ATTR(tx_queue_len, S_IRUGO | S_IWUSR, show_tx_queue_len, 
+			 store_tx_queue_len);
+
+NETDEVICE_SHOW(ifindex, "%d\n");
+NETDEVICE_STORE(ifindex);
+
+static CLASS_DEVICE_ATTR(ifindex, S_IRUGO | S_IWUSR, show_ifindex, 
+			 store_ifindex);
+
+struct class net_class = {
+	.name = "net",
+};
+
+
+static struct class_device_attribute *net_class_attributes[] = {
+	&class_device_attr_ifindex,
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
+int netdev_create_sysfs(struct net_device *net)
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
+	class_device_unregister(class_dev);
+	goto out;
+}
diff -urNp -X dontdiff linux-2.5/net/Kconfig linux-2.5-sysfs/net/Kconfig
--- linux-2.5/net/Kconfig	2003-05-14 10:41:43.000000000 -0700
+++ linux-2.5-sysfs/net/Kconfig	2003-05-15 14:51:59.000000000 -0700
@@ -58,6 +58,18 @@ config NETLINK_DEV
 	  the real netlink socket.
 	  This is a backward compatibility option, choose Y for now.
 
+config NET_SYSFS
+	bool "Sysfs support for network devices"
+	default y
+	---help---
+	   Show network devices in the sysfs virtual file system.
+	   This allows accessing network device information through
+	   files, for example /sys/class/net/eth0/address contains
+	   the Ethernet address.
+
+	   Some parameters (like MTU) can also be set through this
+	   interface.
+
 config NETFILTER
 	bool "Network packet filtering (replaces ipchains)"
 	---help---
