From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (2/4) net-sysfs - use attribute group instead of kobject
 for statistics
Date: Fri, 15 Aug 2003 15:32:43 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030815153243.3b8de683.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Net statistics were in a kobject only because there was no better way
to create a directory.  Latest 2.6.0-test3 bk tree, has merged in
Pat's change to provide "attribute groups".

This patch converts netdevice's from a statistic's kobject to attribute
group.  This is cleaner and fixes some shutdown unload issues as well.

Ps. it gets rid of of the "object has no release" warning as well.

diff -Nru a/include/linux/netdevice.h b/include/linux/netdevice.h
--- a/include/linux/netdevice.h	Fri Aug 15 15:23:44 2003
+++ b/include/linux/netdevice.h	Fri Aug 15 15:23:44 2003
@@ -463,9 +463,6 @@
 
 	/* class/net/name entry */
 	struct class_device	class_dev;
-
-	/* statistics sub-directory */
-	struct kobject		stats_kobj;
 };
 
 #define SET_MODULE_OWNER(dev) do { } while (0)
diff -Nru a/net/core/net-sysfs.c b/net/core/net-sysfs.c
--- a/net/core/net-sysfs.c	Fri Aug 15 15:23:44 2003
+++ b/net/core/net-sysfs.c	Fri Aug 15 15:23:44 2003
@@ -188,107 +188,94 @@
 	NULL
 };
 
-struct netstat_fs_entry {
-	struct attribute attr;
-	ssize_t (*show)(const struct net_device_stats *, char *);
-	ssize_t (*store)(struct net_device_stats *, const char *, size_t);
-};
-
-static ssize_t net_device_stat_show(unsigned long var, char *buf)
+/* Show a given an attribute in the statistics group */
+static ssize_t netstat_show(const struct class_device *cd, char *buf, 
+			    unsigned long offset)
 {
-	return sprintf(buf, fmt_ulong, var);
+	struct net_device *dev = to_net_dev(cd);
+	struct net_device_stats *stats;
+	ssize_t ret = -EINVAL;
+
+	if (offset > sizeof(struct net_device_stats) ||
+	    offset % sizeof(unsigned long) != 0)
+		WARN_ON(1);
+
+	read_lock(&dev_base_lock);
+	if (dev_isalive(dev) && dev->get_stats &&
+	    (stats = (*dev->get_stats)(dev))) 
+		ret = sprintf(buf, fmt_ulong,
+			      *(unsigned long *)(((u8 *) stats) + offset));
+
+	read_unlock(&dev_base_lock);
+	return ret;
 }
 
 /* generate a read-only statistics attribute */
-#define NETDEVICE_STAT(_NAME)						\
-static ssize_t show_stat_##_NAME(const struct net_device_stats *stats,	\
-				 char *buf)				\
+#define NETSTAT_ENTRY(name)						\
+static ssize_t show_##name(struct class_device *cd, char *buf) 		\
 {									\
-	return net_device_stat_show(stats->_NAME, buf);			\
+	return netstat_show(cd, buf, 					\
+			    offsetof(struct net_device_stats, name));	\
 }									\
-static struct netstat_fs_entry net_stat_##_NAME  = {		   	\
-	.attr = {.name = __stringify(_NAME), .mode = S_IRUGO },		\
-	.show = show_stat_##_NAME,					\
-}
+static CLASS_DEVICE_ATTR(name, S_IRUGO, show_##name, NULL)
 
-NETDEVICE_STAT(rx_packets);
-NETDEVICE_STAT(tx_packets);
-NETDEVICE_STAT(rx_bytes);
-NETDEVICE_STAT(tx_bytes);
-NETDEVICE_STAT(rx_errors);
-NETDEVICE_STAT(tx_errors);
-NETDEVICE_STAT(rx_dropped);
-NETDEVICE_STAT(tx_dropped);
-NETDEVICE_STAT(multicast);
-NETDEVICE_STAT(collisions);
-NETDEVICE_STAT(rx_length_errors);
-NETDEVICE_STAT(rx_over_errors);
-NETDEVICE_STAT(rx_crc_errors);
-NETDEVICE_STAT(rx_frame_errors);
-NETDEVICE_STAT(rx_fifo_errors);
-NETDEVICE_STAT(rx_missed_errors);
-NETDEVICE_STAT(tx_aborted_errors);
-NETDEVICE_STAT(tx_carrier_errors);
-NETDEVICE_STAT(tx_fifo_errors);
-NETDEVICE_STAT(tx_heartbeat_errors);
-NETDEVICE_STAT(tx_window_errors);
-NETDEVICE_STAT(rx_compressed);
-NETDEVICE_STAT(tx_compressed);
-
-static struct attribute *default_attrs[] = {
-	&net_stat_rx_packets.attr,
-	&net_stat_tx_packets.attr,
-	&net_stat_rx_bytes.attr,
-	&net_stat_tx_bytes.attr,
-	&net_stat_rx_errors.attr,
-	&net_stat_tx_errors.attr,
-	&net_stat_rx_dropped.attr,
-	&net_stat_tx_dropped.attr,
-	&net_stat_multicast.attr,
-	&net_stat_collisions.attr,
-	&net_stat_rx_length_errors.attr,
-	&net_stat_rx_over_errors.attr,
-	&net_stat_rx_crc_errors.attr,
-	&net_stat_rx_frame_errors.attr,
-	&net_stat_rx_fifo_errors.attr,
-	&net_stat_rx_missed_errors.attr,
-	&net_stat_tx_aborted_errors.attr,
-	&net_stat_tx_carrier_errors.attr,
-	&net_stat_tx_fifo_errors.attr,
-	&net_stat_tx_heartbeat_errors.attr,
-	&net_stat_tx_window_errors.attr,
-	&net_stat_rx_compressed.attr,
-	&net_stat_tx_compressed.attr,
+NETSTAT_ENTRY(rx_packets);
+NETSTAT_ENTRY(tx_packets);
+NETSTAT_ENTRY(rx_bytes);
+NETSTAT_ENTRY(tx_bytes);
+NETSTAT_ENTRY(rx_errors);
+NETSTAT_ENTRY(tx_errors);
+NETSTAT_ENTRY(rx_dropped);
+NETSTAT_ENTRY(tx_dropped);
+NETSTAT_ENTRY(multicast);
+NETSTAT_ENTRY(collisions);
+NETSTAT_ENTRY(rx_length_errors);
+NETSTAT_ENTRY(rx_over_errors);
+NETSTAT_ENTRY(rx_crc_errors);
+NETSTAT_ENTRY(rx_frame_errors);
+NETSTAT_ENTRY(rx_fifo_errors);
+NETSTAT_ENTRY(rx_missed_errors);
+NETSTAT_ENTRY(tx_aborted_errors);
+NETSTAT_ENTRY(tx_carrier_errors);
+NETSTAT_ENTRY(tx_fifo_errors);
+NETSTAT_ENTRY(tx_heartbeat_errors);
+NETSTAT_ENTRY(tx_window_errors);
+NETSTAT_ENTRY(rx_compressed);
+NETSTAT_ENTRY(tx_compressed);
+
+static struct attribute *netstat_attrs[] = {
+	&class_device_attr_rx_packets.attr,
+	&class_device_attr_tx_packets.attr,
+	&class_device_attr_rx_bytes.attr,
+	&class_device_attr_tx_bytes.attr,
+	&class_device_attr_rx_errors.attr,
+	&class_device_attr_tx_errors.attr,
+	&class_device_attr_rx_dropped.attr,
+	&class_device_attr_tx_dropped.attr,
+	&class_device_attr_multicast.attr,
+	&class_device_attr_collisions.attr,
+	&class_device_attr_rx_length_errors.attr,
+	&class_device_attr_rx_over_errors.attr,
+	&class_device_attr_rx_crc_errors.attr,
+	&class_device_attr_rx_frame_errors.attr,
+	&class_device_attr_rx_fifo_errors.attr,
+	&class_device_attr_rx_missed_errors.attr,
+	&class_device_attr_tx_aborted_errors.attr,
+	&class_device_attr_tx_carrier_errors.attr,
+	&class_device_attr_tx_fifo_errors.attr,
+	&class_device_attr_tx_heartbeat_errors.attr,
+	&class_device_attr_tx_window_errors.attr,
+	&class_device_attr_rx_compressed.attr,
+	&class_device_attr_tx_compressed.attr,
 	NULL
 };
 
 
-static ssize_t
-netstat_attr_show(struct kobject *kobj, struct attribute *attr, char *buf)
-{
-	struct netstat_fs_entry *entry
-		= container_of(attr, struct netstat_fs_entry, attr);
-	struct net_device *dev
-		= to_net_dev(to_class_dev(kobj->parent));
-	struct net_device_stats *stats;
-	ssize_t ret = -EINVAL;
-	
-	read_lock(&dev_base_lock);
-	if (dev_isalive(dev) && entry->show && dev->get_stats &&
-	    (stats = (*dev->get_stats)(dev)))
-		ret = entry->show(stats, buf);
-	read_unlock(&dev_base_lock);
-	return ret;
-}
-
-static struct sysfs_ops netstat_sysfs_ops = {
-	.show = netstat_attr_show,
+static struct attribute_group netstat_group = {
+	.name  = "statistics",
+	.attrs  = netstat_attrs,
 };
 
-static struct kobj_type netstat_ktype = {
-	.sysfs_ops	= &netstat_sysfs_ops,
-	.default_attrs  = default_attrs,
-};
 
 #ifdef CONFIG_HOTPLUG
 static int netdev_hotplug(struct class_device *cd, char **envp,
@@ -339,32 +326,23 @@
 		    goto out_unreg;
 	}
 
-	net->stats_kobj.parent = NULL;
-	if (net->get_stats) {
-		struct kobject *k = &net->stats_kobj;
-
-		k->parent = &class_dev->kobj;
-		strlcpy(k->name, "statistics", KOBJ_NAME_LEN);
-		k->ktype = &netstat_ktype;
 
-		if((ret = kobject_register(k))) 
-			 goto out_unreg; 
-	}
+	if (net->get_stats &&
+	    (ret = sysfs_create_group(&class_dev->kobj, &netstat_group)))
+		goto out_unreg; 
+
+	return 0;
 
-out:
-	return ret;
 out_unreg:
 	printk(KERN_WARNING "%s: sysfs attribute registration failed %d\n",
 	       net->name, ret);
 	class_device_unregister(class_dev);
-	goto out;
+out:
+	return ret;
 }
 
 void netdev_unregister_sysfs(struct net_device *net)
 {
-	if (net->stats_kobj.parent) 
-		kobject_unregister(&net->stats_kobj);
-
 	class_device_unregister(&net->class_dev);
 }
 
