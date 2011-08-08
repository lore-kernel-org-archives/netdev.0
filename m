From: Tom Herbert <therbert@google.com>
Subject: [RFC PATCH v2 4/9] bql: Byte queue limits
Date: Sun, 7 Aug 2011 21:48:24 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1108072144010.13721@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:12849 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899Ab1HHEs3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 00:48:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Networking stack support for byte queue limits, uses dynamic queue
limits library.  Byte queue limits are maintained per transmit queue,
and a bql structure has been added to netdev_queue structure for this
purpose.

Configuration of bql is in the tx-<n> sysfs directory for the queue
under the byte_queue_limits directory.  Configuration includes:
limit_min, bql minimum limit
limit_max, bql maximum limit
hold_time, bql slack hold time

Also under the directory are:
limit, current byte limit
inflight, current number of bytes on the queue

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/netdevice.h |   16 +++
 net/core/dev.c            |    1 +
 net/core/net-sysfs.c      |  230 ++++++++++++++++++++++++++++++++++-----------
 3 files changed, 192 insertions(+), 55 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 74e8862..d49265b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -43,6 +43,7 @@
 #include <linux/rculist.h>
 #include <linux/dmaengine.h>
 #include <linux/workqueue.h>
+#include <linux/dynamic_queue_limits.h>
 
 #include <linux/ethtool.h>
 #include <net/net_namespace.h>
@@ -536,6 +537,7 @@ struct netdev_queue {
 #if defined(CONFIG_RPS) || defined(CONFIG_XPS)
 	struct kobject		kobj;
 #endif
+	struct dql		dql;
 #if defined(CONFIG_XPS) && defined(CONFIG_NUMA)
 	int			numa_node;
 #endif
@@ -1913,29 +1915,43 @@ static inline int netif_xmit_frozen_or_stopped(const struct netdev_queue *dev_qu
 static inline void netdev_tx_sent_queue(struct netdev_queue *dev_queue,
 					unsigned int pkts, unsigned int bytes)
 {
+	dql_queued(&dev_queue->dql, bytes);
+	if (dql_avail(&dev_queue->dql) < 0)
+		set_bit(__QUEUE_STATE_STACK_XOFF, &dev_queue->state);
 }
 
 static inline void netdev_sent_queue(struct net_device *dev,
 				     unsigned int pkts, unsigned int bytes)
 {
+	netdev_tx_sent_queue(netdev_get_tx_queue(dev, 0), pkts, bytes);
 }
 
 static inline void netdev_tx_completed_queue(struct netdev_queue *dev_queue,
 					     unsigned pkts, unsigned bytes)
 {
+	if (bytes) {
+		dql_completed(&dev_queue->dql, bytes);
+		if (dql_avail(&dev_queue->dql) >= 0 &&
+		    test_and_clear_bit(__QUEUE_STATE_STACK_XOFF,
+		     &dev_queue->state))
+			netif_schedule_queue(dev_queue);
+	}
 }
 
 static inline void netdev_completed_queue(struct net_device *dev,
 					  unsigned pkts, unsigned bytes)
 {
+	netdev_tx_completed_queue(netdev_get_tx_queue(dev, 0), pkts, bytes);
 }
 
 static inline void netdev_tx_reset_queue(struct netdev_queue *q)
 {
+	dql_reset(&q->dql);
 }
 
 static inline void netdev_reset_queue(struct net_device *dev_queue)
 {
+	netdev_tx_reset_queue(netdev_get_tx_queue(dev_queue, 0));
 }
 
 /**
diff --git a/net/core/dev.c b/net/core/dev.c
index a7f8c38..bd5cd15 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5395,6 +5395,7 @@ static void netdev_init_one_queue(struct net_device *dev,
 	queue->xmit_lock_owner = -1;
 	netdev_queue_numa_node_write(queue, NUMA_NO_NODE);
 	queue->dev = dev;
+	dql_init(&queue->dql, 1000);
 }
 
 static int netif_alloc_netdev_queues(struct net_device *dev)
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 1683e5d..eca8684 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -20,6 +20,7 @@
 #include <linux/rtnetlink.h>
 #include <linux/wireless.h>
 #include <linux/vmalloc.h>
+#include <linux/jiffies.h>
 #include <net/wext.h>
 
 #include "net-sysfs.h"
@@ -779,7 +780,6 @@ net_rx_queue_update_kobjects(struct net_device *net, int old_num, int new_num)
 #endif
 }
 
-#ifdef CONFIG_XPS
 /*
  * netdev_queue sysfs structures and functions.
  */
@@ -839,7 +839,121 @@ static inline unsigned int get_netdev_queue_index(struct netdev_queue *queue)
 	return i;
 }
 
+static ssize_t bql_show(char *buf, unsigned long value)
+{
+	int p = 0;
+
+	p = sprintf(buf, "%lu\n", value);
+	return p;
+}
+
+static ssize_t bql_set(const char *buf, const size_t count,
+		       unsigned long *pvalue)
+{
+	unsigned long value;
+	int err;
+
+	if (!strcmp(buf, "max") || !strcmp(buf, "max\n"))
+		value = DQL_MAX_LIMIT;
+	else {
+		err = kstrtoul(buf, 10, &value);
+		if (err < 0)
+			return err;
+		if (value > DQL_MAX_LIMIT)
+			return -EINVAL;
+	}
+
+	*pvalue = value;
+
+	return count;
+}
+
+static ssize_t bql_show_hold_time(struct netdev_queue *queue,
+				  struct netdev_queue_attribute *attr,
+				  char *buf)
+{
+	struct dql *dql = &queue->dql;
+	int p = 0;
+
+	p = sprintf(buf, "%u\n", jiffies_to_msecs(dql->slack_hold_time));
+
+	return p;
+}
+
+static ssize_t bql_set_hold_time(struct netdev_queue *queue,
+				 struct netdev_queue_attribute *attribute,
+				 const char *buf, size_t len)
+{
+	struct dql *dql = &queue->dql;
+	unsigned value;
+	int err;
+
+	err = kstrtouint(buf, 10, &value);
+	if (err < 0)
+		return err;
+
+	dql->slack_hold_time = msecs_to_jiffies(value);
+
+	return len;
+}
+
+static struct netdev_queue_attribute bql_hold_time_attribute =
+	__ATTR(hold_time, S_IRUGO | S_IWUSR, bql_show_hold_time,
+	    bql_set_hold_time);
+
+static ssize_t bql_show_inflight(struct netdev_queue *queue,
+				 struct netdev_queue_attribute *attr,
+				 char *buf)
+{
+	struct dql *dql = &queue->dql;
+	int p = 0;
+
+	p = sprintf(buf, "%lu\n", dql->num_queued - dql->num_completed);
+
+	return p;
+}
+
+static struct netdev_queue_attribute bql_inflight_attribute =
+	__ATTR(inflight, S_IRUGO | S_IWUSR, bql_show_inflight, NULL);
+
+#define BQL_ATTR(NAME, FIELD)						\
+static ssize_t bql_show_ ## NAME(struct netdev_queue *queue,		\
+				 struct netdev_queue_attribute *attr,	\
+				 char *buf)				\
+{									\
+	return bql_show(buf, queue->dql.FIELD);				\
+}									\
+									\
+static ssize_t bql_set_ ## NAME(struct netdev_queue *queue,		\
+				struct netdev_queue_attribute *attr,	\
+				const char *buf, size_t len)		\
+{									\
+	return bql_set(buf, len, &queue->dql.FIELD);			\
+}									\
+									\
+static struct netdev_queue_attribute bql_ ## NAME ## _attribute =	\
+	__ATTR(NAME, S_IRUGO | S_IWUSR, bql_show_ ## NAME,		\
+	    bql_set_ ## NAME);
+
+BQL_ATTR(limit, limit)
+BQL_ATTR(limit_max, max_limit)
+BQL_ATTR(limit_min, min_limit)
+
+static struct attribute *dql_attrs[] = {
+	&bql_limit_attribute.attr,
+	&bql_limit_max_attribute.attr,
+	&bql_limit_min_attribute.attr,
+	&bql_hold_time_attribute.attr,
+	&bql_inflight_attribute.attr,
+	NULL
+};
+
+static struct attribute_group dql_group = {
+	.name  = "byte_queue_limits",
+	.attrs  = dql_attrs,
+};
 
+#ifdef CONFIG_XPS
 static ssize_t show_xps_map(struct netdev_queue *queue,
 			    struct netdev_queue_attribute *attribute, char *buf)
 {
@@ -889,6 +1003,51 @@ static DEFINE_MUTEX(xps_map_mutex);
 #define xmap_dereference(P)		\
 	rcu_dereference_protected((P), lockdep_is_held(&xps_map_mutex))
 
+static void xps_queue_release(struct netdev_queue *queue)
+{
+	struct net_device *dev = queue->dev;
+	struct xps_dev_maps *dev_maps;
+	struct xps_map *map;
+	unsigned long index;
+	int i, pos, nonempty = 0;
+
+	index = get_netdev_queue_index(queue);
+
+	mutex_lock(&xps_map_mutex);
+	dev_maps = xmap_dereference(dev->xps_maps);
+
+	if (dev_maps) {
+		for_each_possible_cpu(i) {
+			map = xmap_dereference(dev_maps->cpu_map[i]);
+			if (!map)
+				continue;
+
+			for (pos = 0; pos < map->len; pos++)
+				if (map->queues[pos] == index)
+					break;
+
+			if (pos < map->len) {
+				if (map->len > 1)
+					map->queues[pos] =
+					    map->queues[--map->len];
+				else {
+					RCU_INIT_POINTER(dev_maps->cpu_map[i],
+					    NULL);
+					kfree_rcu(map, rcu);
+					map = NULL;
+				}
+			}
+			if (map)
+				nonempty = 1;
+		}
+
+		if (!nonempty) {
+			RCU_INIT_POINTER(dev->xps_maps, NULL);
+			kfree_rcu(dev_maps, rcu);
+		}
+	}
+}
+
 static ssize_t store_xps_map(struct netdev_queue *queue,
 		      struct netdev_queue_attribute *attribute,
 		      const char *buf, size_t len)
@@ -1024,53 +1183,13 @@ static struct attribute *netdev_queue_default_attrs[] = {
 	&xps_cpus_attribute.attr,
 	NULL
 };
+#endif
 
 static void netdev_queue_release(struct kobject *kobj)
 {
 	struct netdev_queue *queue = to_netdev_queue(kobj);
-	struct net_device *dev = queue->dev;
-	struct xps_dev_maps *dev_maps;
-	struct xps_map *map;
-	unsigned long index;
-	int i, pos, nonempty = 0;
-
-	index = get_netdev_queue_index(queue);
-
-	mutex_lock(&xps_map_mutex);
-	dev_maps = xmap_dereference(dev->xps_maps);
-
-	if (dev_maps) {
-		for_each_possible_cpu(i) {
-			map = xmap_dereference(dev_maps->cpu_map[i]);
-			if (!map)
-				continue;
 
-			for (pos = 0; pos < map->len; pos++)
-				if (map->queues[pos] == index)
-					break;
-
-			if (pos < map->len) {
-				if (map->len > 1)
-					map->queues[pos] =
-					    map->queues[--map->len];
-				else {
-					RCU_INIT_POINTER(dev_maps->cpu_map[i],
-					    NULL);
-					kfree_rcu(map, rcu);
-					map = NULL;
-				}
-			}
-			if (map)
-				nonempty = 1;
-		}
-
-		if (!nonempty) {
-			RCU_INIT_POINTER(dev->xps_maps, NULL);
-			kfree_rcu(dev_maps, rcu);
-		}
-	}
-
-	mutex_unlock(&xps_map_mutex);
+	xps_queue_release(queue);
 
 	memset(kobj, 0, sizeof(*kobj));
 	dev_put(queue->dev);
@@ -1091,22 +1210,26 @@ static int netdev_queue_add_kobject(struct net_device *net, int index)
 	kobj->kset = net->queues_kset;
 	error = kobject_init_and_add(kobj, &netdev_queue_ktype, NULL,
 	    "tx-%u", index);
+	if (error)
+		goto exit;
+
+	error = sysfs_create_group(kobj, &dql_group);
 	if (error) {
 		kobject_put(kobj);
-		return error;
+		goto exit;
 	}
 
 	kobject_uevent(kobj, KOBJ_ADD);
 	dev_hold(queue->dev);
 
+	return 0;
+exit:
 	return error;
 }
-#endif /* CONFIG_XPS */
 
 int
 netdev_queue_update_kobjects(struct net_device *net, int old_num, int new_num)
 {
-#ifdef CONFIG_XPS
 	int i;
 	int error = 0;
 
@@ -1118,25 +1241,24 @@ netdev_queue_update_kobjects(struct net_device *net, int old_num, int new_num)
 		}
 	}
 
-	while (--i >= new_num)
-		kobject_put(&net->_tx[i].kobj);
+	while (--i >= new_num) {
+		struct netdev_queue *queue = net->_tx + i;
+
+		sysfs_remove_group(&queue->kobj, &dql_group);
+		kobject_put(&queue->kobj);
+	}
 
 	return error;
-#else
-	return 0;
-#endif
 }
 
 static int register_queue_kobjects(struct net_device *net)
 {
 	int error = 0, txq = 0, rxq = 0, real_rx = 0, real_tx = 0;
 
-#if defined(CONFIG_RPS) || defined(CONFIG_XPS)
 	net->queues_kset = kset_create_and_add("queues",
 	    NULL, &net->dev.kobj);
 	if (!net->queues_kset)
 		return -ENOMEM;
-#endif
 
 #ifdef CONFIG_RPS
 	real_rx = net->real_num_rx_queues;
@@ -1172,9 +1294,7 @@ static void remove_queue_kobjects(struct net_device *net)
 
 	net_rx_queue_update_kobjects(net, real_rx, 0);
 	netdev_queue_update_kobjects(net, real_tx, 0);
-#if defined(CONFIG_RPS) || defined(CONFIG_XPS)
 	kset_unregister(net->queues_kset);
-#endif
 }
 
 static void *net_grab_current_ns(void)
-- 
1.7.3.1

