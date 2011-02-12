From: Tom Herbert <therbert@google.com>
Subject: [PATCH 1/2] net: Add RX queue weights
Date: Fri, 11 Feb 2011 16:00:50 -0800 (PST)
Message-ID: <alpine.DEB.2.00.1102111552090.2793@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:48957 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756887Ab1BLAA4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 19:00:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a weight attribute to the netdev RX queues.  This allows
control over the relative receive packet load for each queue.  These
values are set in sysfs variable 'weight' in the rxq directory for
a device.  When a weight is set, a new netdev operation is called to
inform the driver of the changed weight.  The driver is expected to
apply the queue weights in a logical manner to the RSS indirection table
of the device to achieve the desired weighting.  The driver
implementation for this is unspecified.

If a weight for a queue is zero, this effectively disables that queue
for RSS (but possibly still usable by accelerated RFS, etc.), except
in the case that all queue weights are zero, then all queues are
considered equally weighted (the default).

Example configuration:
echo 1 > /sys/class/net/eth4/queues/rx-0/weight
echo 1 > /sys/class/net/eth4/queues/rx-1/weight
echo 5 > /sys/class/net/eth4/queues/rx-2/weight
echo 0 > /sys/class/net/eth4/queues/rx-3/weight

So rx queue 0 and 1 have equal weight, queue 2 is 5X in weight and
queue 3 is disabled for RSS.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/netdevice.h |   29 +++++++++++++++++++++++++++++
 net/core/net-sysfs.c      |   36 ++++++++++++++++++++++++++++++++++++
 2 files changed, 65 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c7d7074..9b02bd3 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -624,6 +624,7 @@ struct netdev_rx_queue {
 	struct rps_dev_flow_table __rcu	*rps_flow_table;
 	struct kobject			kobj;
 	struct net_device		*dev;
+	u32				weight;
 } ____cacheline_aligned_in_smp;
 #endif /* CONFIG_RPS */
 
@@ -783,6 +784,11 @@ struct netdev_tc_txq {
  *	Set hardware filter for RFS.  rxq_index is the target queue index;
  *	flow_id is a flow ID to be passed to rps_may_expire_flow() later.
  *	Return the filter ID on success, or a negative error code.
+ *
+ * void (*ndo_set_rxq_weight)(struct net_device *dev, u16 rxq, u32 weight);
+ *	An rx queue weight has been modified.  rxq is the queue index whose
+ *	weight has changed, weight is the new weight.  This is called after
+ *	the weight has been updated in the netdev_rx_queue structure.
  */
 #define HAVE_NET_DEVICE_OPS
 struct net_device_ops {
@@ -862,6 +868,10 @@ struct net_device_ops {
 						     u16 rxq_index,
 						     u32 flow_id);
 #endif
+#ifdef CONFIG_RPS
+	void			(*ndo_set_rxq_weight)(struct net_device *dev,
+						      u16 rxq, u32 weight);
+#endif
 };
 
 /*
@@ -1279,6 +1289,25 @@ static inline void netdev_for_each_tx_queue(struct net_device *dev,
 		f(dev, &dev->_tx[i], arg);
 }
 
+#ifdef CONFIG_RPS
+static inline u16 netdev_rx_queue_to_index(struct netdev_rx_queue *queue)
+{
+	return (u16)(queue - queue->dev->_rx);
+}
+#endif /* CONFIG_RPS */
+
+static inline u32 netdev_rxq_weight(struct net_device *dev, u16 index)
+{
+#ifdef CONFIG_RPS
+	if (index >= dev->real_num_rx_queues)
+		return 0;
+
+	return (dev->_rx + index)->weight;
+#else
+	return 0;
+#endif
+}
+
 /*
  * Net namespace inlines
  */
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 5ceb257..e1fe54a 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -625,6 +625,41 @@ static ssize_t store_rps_map(struct netdev_rx_queue *queue,
 	return len;
 }
 
+static ssize_t show_rxq_weight(struct netdev_rx_queue *queue,
+			       struct rx_queue_attribute *attribute, char *buf)
+{
+	return sprintf(buf, fmt_dec, queue->weight);
+}
+
+static ssize_t store_rxq_weight(struct netdev_rx_queue *queue,
+				struct rx_queue_attribute *attribute, char *buf)
+{
+	char *endp;
+	u32 new;
+	static DEFINE_MUTEX(weight_mutex);
+	const struct net_device_ops *ops = queue->dev->netdev_ops;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	new = simple_strtoul(buf, &endp, 0);
+	if (endp == buf)
+		return -EINVAL;
+
+	if (!ops->ndo_set_rxq_weight)
+		return -ENOENT;
+
+	mutex_lock(&weight_mutex);
+	queue->weight = new;
+	ops->ndo_set_rxq_weight(queue->dev,
+	    netdev_rx_queue_to_index(queue), new);
+	mutex_unlock(&weight_mutex);
+}
+
+static struct rx_queue_attribute rxq_weight_attribute =
+	__ATTR(weight, S_IRUGO | S_IWUSR,
+	    show_rxq_weight, store_rxq_weight);
+
 static ssize_t show_rps_dev_flow_table_cnt(struct netdev_rx_queue *queue,
 					   struct rx_queue_attribute *attr,
 					   char *buf)
@@ -715,6 +750,7 @@ static struct rx_queue_attribute rps_dev_flow_table_cnt_attribute =
 static struct attribute *rx_queue_default_attrs[] = {
 	&rps_cpus_attribute.attr,
 	&rps_dev_flow_table_cnt_attribute.attr,
+	&rxq_weight_attribute.attr,
 	NULL
 };
 
-- 
1.7.3.1

