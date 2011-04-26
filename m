From: Tom Herbert <therbert@google.com>
Subject: [PATCH 2/3] bql: Byte queue limits
Date: Mon, 25 Apr 2011 21:38:11 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1104252128290.5895@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:16176 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750873Ab1DZEiO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 00:38:14 -0400
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
 include/linux/netdevice.h |   46 +++++++++++++++-
 net/core/net-sysfs.c      |  137 +++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 177 insertions(+), 6 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index cb8178a..0a76b88 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -44,6 +44,7 @@
 #include <linux/rculist.h>
 #include <linux/dmaengine.h>
 #include <linux/workqueue.h>
+#include <linux/dynamic_queue_limits.h>
 
 #include <linux/ethtool.h>
 #include <net/net_namespace.h>
@@ -556,8 +557,10 @@ struct netdev_queue {
 	struct Qdisc		*qdisc;
 	unsigned long		state;
 	struct Qdisc		*qdisc_sleeping;
-#ifdef CONFIG_RPS
+#ifdef CONFIG_XPS
 	struct kobject		kobj;
+	bool			do_bql;
+	struct dql		dql;
 #endif
 #if defined(CONFIG_XPS) && defined(CONFIG_NUMA)
 	int			numa_node;
@@ -589,6 +592,47 @@ static inline void netdev_queue_numa_node_write(struct netdev_queue *q, int node
 #endif
 }
 
+/*
+ * Definitions for byte queue limits for TX queue.
+ */
+static inline void netdev_queue_bql_init(struct netdev_queue *q)
+{
+#ifdef CONFIG_XPS
+	dql_init(&q->dql, 1000);
+	q->do_bql = true;
+#endif
+}
+
+static inline void netdev_queue_bql_reset(struct netdev_queue *q)
+{
+#ifdef CONFIG_XPS
+	dql_reset(&q->dql);
+#endif
+}
+
+static inline bool netdev_queue_bytes_avail(struct netdev_queue *q)
+{
+#ifdef CONFIG_XPS
+	return dql_avail(&q->dql) >= 0;
+#endif
+}
+
+static inline void netdev_queue_bytes_sent(struct netdev_queue *q,
+					   unsigned count)
+{
+#ifdef CONFIG_XPS
+	dql_queued(&q->dql, count);
+#endif
+}
+
+static inline void netdev_queue_bytes_completed(struct netdev_queue *q,
+						unsigned count)
+{
+#ifdef CONFIG_XPS
+	dql_completed(&q->dql, count);
+#endif
+}
+
 #ifdef CONFIG_RPS
 /*
  * This structure holds an RPS map which can be of variable length.  The
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 5ceb257..5f29b8e 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -20,6 +20,7 @@
 #include <linux/rtnetlink.h>
 #include <linux/wireless.h>
 #include <linux/vmalloc.h>
+#include <linux/jiffies.h>
 #include <net/wext.h>
 
 #include "net-sysfs.h"
@@ -852,6 +853,119 @@ static inline unsigned int get_netdev_queue_index(struct netdev_queue *queue)
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
 
 static ssize_t show_xps_map(struct netdev_queue *queue,
 			    struct netdev_queue_attribute *attribute, char *buf)
@@ -1119,14 +1233,22 @@ static int netdev_queue_add_kobject(struct net_device *net, int index)
 	kobj->kset = net->queues_kset;
 	error = kobject_init_and_add(kobj, &netdev_queue_ktype, NULL,
 	    "tx-%u", index);
-	if (error) {
-		kobject_put(kobj);
-		return error;
+	if (error)
+		goto exit;
+
+	if (queue->do_bql) {
+		error = sysfs_create_group(kobj, &dql_group);
+		if (error)
+			goto kset_exit;
 	}
 
 	kobject_uevent(kobj, KOBJ_ADD);
 	dev_hold(queue->dev);
 
+	return 0;
+kset_exit:
+	kobject_put(kobj);
+exit:
 	return error;
 }
 #endif /* CONFIG_XPS */
@@ -1146,8 +1268,13 @@ netdev_queue_update_kobjects(struct net_device *net, int old_num, int new_num)
 		}
 	}
 
-	while (--i >= new_num)
-		kobject_put(&net->_tx[i].kobj);
+	while (--i >= new_num) {
+		struct netdev_queue *queue = net->_tx + i;
+
+		if (queue->do_bql)
+			sysfs_remove_group(&queue->kobj, &dql_group);
+		kobject_put(&queue->kobj);
+	}
 
 	return error;
 #else
-- 
1.7.3.1

