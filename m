From: Tom Herbert <therbert@google.com>
Subject: [PATCH v4 05/10] bql: Byte queue limits
Date: Mon, 28 Nov 2011 18:33:09 -0800 (PST)
Message-ID: <alpine.DEB.2.00.1111281818480.24395@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f202.google.com ([209.85.160.202]:64703 "EHLO
	mail-gy0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751662Ab1K2C5T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 21:57:19 -0500
Received: by ghrr18 with SMTP id r18so262093ghr.1
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2011 18:57:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Networking stack support for byte queue limits, uses dynamic queue
limits library.  Byte queue limits are maintained per transmit queue,
and a dql structure has been added to netdev_queue structure for this
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
 include/linux/netdevice.h |   32 ++++++++++-
 net/Kconfig               |    6 ++
 net/core/dev.c            |    3 +
 net/core/net-sysfs.c      |  140 ++++++++++++++++++++++++++++++++++++++++++---
 4 files changed, 172 insertions(+), 9 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9b24cc7..97edb32 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -43,6 +43,7 @@
 #include <linux/rculist.h>
 #include <linux/dmaengine.h>
 #include <linux/workqueue.h>
+#include <linux/dynamic_queue_limits.h>
 
 #include <linux/ethtool.h>
 #include <net/net_namespace.h>
@@ -541,7 +542,6 @@ struct netdev_queue {
  */
 	struct net_device	*dev;
 	struct Qdisc		*qdisc;
-	unsigned long		state;
 	struct Qdisc		*qdisc_sleeping;
 #ifdef CONFIG_SYSFS
 	struct kobject		kobj;
@@ -564,6 +564,12 @@ struct netdev_queue {
 	 * (/sys/class/net/DEV/Q/trans_timeout)
 	 */
 	unsigned long		trans_timeout;
+
+	unsigned long		state;
+
+#ifdef CONFIG_BQL
+	struct dql		dql;
+#endif
 } ____cacheline_aligned_in_smp;
 
 static inline int netdev_queue_numa_node_read(const struct netdev_queue *q)
@@ -1862,6 +1868,15 @@ static inline int netif_xmit_frozen_or_stopped(const struct netdev_queue *dev_qu
 static inline void netdev_tx_sent_queue(struct netdev_queue *dev_queue,
 					unsigned int bytes)
 {
+#ifdef CONFIG_BQL
+	dql_queued(&dev_queue->dql, bytes);
+	if (unlikely(dql_avail(&dev_queue->dql) < 0)) {
+		set_bit(__QUEUE_STATE_STACK_XOFF, &dev_queue->state);
+		if (unlikely(dql_avail(&dev_queue->dql) >= 0))
+			clear_bit(__QUEUE_STATE_STACK_XOFF,
+			    &dev_queue->state);
+	}
+#endif
 }
 
 static inline void netdev_sent_queue(struct net_device *dev, unsigned int bytes)
@@ -1872,6 +1887,18 @@ static inline void netdev_sent_queue(struct net_device *dev, unsigned int bytes)
 static inline void netdev_tx_completed_queue(struct netdev_queue *dev_queue,
 					     unsigned pkts, unsigned bytes)
 {
+#ifdef CONFIG_BQL
+	if (likely(bytes)) {
+		dql_completed(&dev_queue->dql, bytes);
+		if (unlikely(test_bit(__QUEUE_STATE_STACK_XOFF,
+		    &dev_queue->state) &&
+		    dql_avail(&dev_queue->dql) >= 0)) {
+			if (test_and_clear_bit(__QUEUE_STATE_STACK_XOFF,
+			     &dev_queue->state))
+				netif_schedule_queue(dev_queue);
+		}
+	}
+#endif
 }
 
 static inline void netdev_completed_queue(struct net_device *dev,
@@ -1882,6 +1909,9 @@ static inline void netdev_completed_queue(struct net_device *dev,
 
 static inline void netdev_tx_reset_queue(struct netdev_queue *q)
 {
+#ifdef CONFIG_BQL
+	dql_reset(&q->dql);
+#endif
 }
 
 static inline void netdev_reset_queue(struct net_device *dev_queue)
diff --git a/net/Kconfig b/net/Kconfig
index 63d2c5d..2d99873 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -239,6 +239,12 @@ config NETPRIO_CGROUP
 	  Cgroup subsystem for use in assigning processes to network priorities on
 	  a per-interface basis
 
+config BQL
+	boolean
+	depends on SYSFS
+	select DQL
+	default y
+
 config HAVE_BPF_JIT
 	bool
 
diff --git a/net/core/dev.c b/net/core/dev.c
index ed21a2c..25026cd 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5544,6 +5544,9 @@ static void netdev_init_one_queue(struct net_device *dev,
 	queue->xmit_lock_owner = -1;
 	netdev_queue_numa_node_write(queue, NUMA_NO_NODE);
 	queue->dev = dev;
+#ifdef CONFIG_BQL
+	dql_init(&queue->dql, HZ);
+#endif
 }
 
 static int netif_alloc_netdev_queues(struct net_device *dev)
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index b17c14a..3bf72b6 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -21,6 +21,7 @@
 #include <linux/wireless.h>
 #include <linux/vmalloc.h>
 #include <linux/export.h>
+#include <linux/jiffies.h>
 #include <net/wext.h>
 
 #include "net-sysfs.h"
@@ -845,6 +846,116 @@ static ssize_t show_trans_timeout(struct netdev_queue *queue,
 static struct netdev_queue_attribute queue_trans_timeout =
 	__ATTR(tx_timeout, S_IRUGO, show_trans_timeout, NULL);
 
+#ifdef CONFIG_BQL
+/*
+ * Byte queue limits sysfs structures and functions.
+ */
+static ssize_t bql_show(char *buf, unsigned int value)
+{
+	return sprintf(buf, "%u\n", value);
+}
+
+static ssize_t bql_set(const char *buf, const size_t count,
+		       unsigned int *pvalue)
+{
+	unsigned int value;
+	int err;
+
+	if (!strcmp(buf, "max") || !strcmp(buf, "max\n"))
+		value = DQL_MAX_LIMIT;
+	else {
+		err = kstrtouint(buf, 10, &value);
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
+
+	return sprintf(buf, "%u\n", jiffies_to_msecs(dql->slack_hold_time));
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
+
+	return sprintf(buf, "%u\n", dql->num_queued - dql->num_completed);
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
+#endif /* CONFIG_BQL */
+
 #ifdef CONFIG_XPS
 static inline unsigned int get_netdev_queue_index(struct netdev_queue *queue)
 {
@@ -1096,17 +1207,17 @@ static struct attribute *netdev_queue_default_attrs[] = {
 	NULL
 };
 
-#ifdef CONFIG_XPS
 static void netdev_queue_release(struct kobject *kobj)
 {
 	struct netdev_queue *queue = to_netdev_queue(kobj);
 
+#ifdef CONFIG_XPS
 	xps_queue_release(queue);
+#endif
 
 	memset(kobj, 0, sizeof(*kobj));
 	dev_put(queue->dev);
 }
-#endif /* CONFIG_XPS */
 
 static struct kobj_type netdev_queue_ktype = {
 	.sysfs_ops = &netdev_queue_sysfs_ops,
@@ -1125,14 +1236,21 @@ static int netdev_queue_add_kobject(struct net_device *net, int index)
 	kobj->kset = net->queues_kset;
 	error = kobject_init_and_add(kobj, &netdev_queue_ktype, NULL,
 	    "tx-%u", index);
-	if (error) {
-		kobject_put(kobj);
-		return error;
-	}
+	if (error)
+		goto exit;
+
+#ifdef CONFIG_BQL
+	error = sysfs_create_group(kobj, &dql_group);
+	if (error)
+		goto exit;
+#endif
 
 	kobject_uevent(kobj, KOBJ_ADD);
 	dev_hold(queue->dev);
 
+	return 0;
+exit:
+	kobject_put(kobj);
 	return error;
 }
 #endif /* CONFIG_SYSFS */
@@ -1152,8 +1270,14 @@ netdev_queue_update_kobjects(struct net_device *net, int old_num, int new_num)
 		}
 	}
 
-	while (--i >= new_num)
-		kobject_put(&net->_tx[i].kobj);
+	while (--i >= new_num) {
+		struct netdev_queue *queue = net->_tx + i;
+
+#ifdef CONFIG_BQL
+		sysfs_remove_group(&queue->kobj, &dql_group);
+#endif
+		kobject_put(&queue->kobj);
+	}
 
 	return error;
 #else
-- 
1.7.3.1
