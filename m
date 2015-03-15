From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V2 1/3] net: Add max rate tx queue attribute
Date: Sun, 15 Mar 2015 15:03:14 +0200
Message-ID: <1426424596-3911-2-git-send-email-ogerlitz@mellanox.com>
References: <1426424596-3911-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Ido Shamay <idos@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
	John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:51866 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751848AbbCONDe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Mar 2015 09:03:34 -0400
In-Reply-To: <1426424596-3911-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

This adds a tx_maxrate attribute to the tx queue sysfs entry allowing
for max-rate limiting. Along with DCB-ETS and BQL this provides another
knob to tune queue performance. The limit units are Mbps.

By default it is disabled. To disable the rate limitation after it
has been set for a queue, it should be set to zero.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 include/linux/netdevice.h |    9 ++++++
 net/core/net-sysfs.c      |   67 +++++++++++++++++++++++++++++++++++++--------
 2 files changed, 64 insertions(+), 12 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ddab1a2..0719307 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -587,6 +587,7 @@ struct netdev_queue {
 #ifdef CONFIG_BQL
 	struct dql		dql;
 #endif
+	unsigned long		tx_maxrate;
 } ____cacheline_aligned_in_smp;
 
 static inline int netdev_queue_numa_node_read(const struct netdev_queue *q)
@@ -1025,6 +1026,11 @@ struct fib_info;
  *	the set of features that the stack has calculated and it returns
  *	those the driver believes to be appropriate.
  *
+ *	int (*ndo_set_tx_maxrate)(struct net_device *dev,
+				  int queue_index,
+				  u32 maxrate);
+ *	Called when a user wants to set a max-rate limitation of specific
+ *	TX queue.
  * int (*ndo_switch_parent_id_get)(struct net_device *dev,
  *				   struct netdev_phys_item_id *psid);
  *	Called to get an ID of the switch chip this port is part of.
@@ -1197,6 +1203,9 @@ struct net_device_ops {
 	netdev_features_t	(*ndo_features_check) (struct sk_buff *skb,
 						       struct net_device *dev,
 						       netdev_features_t features);
+	int			(*ndo_set_tx_maxrate)(struct net_device *dev,
+						      int queue_index,
+						      u32 maxrate);
 #ifdef CONFIG_NET_SWITCHDEV
 	int			(*ndo_switch_parent_id_get)(struct net_device *dev,
 							    struct netdev_phys_item_id *psid);
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index cf30620..7e58bd7 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -951,6 +951,60 @@ static ssize_t show_trans_timeout(struct netdev_queue *queue,
 	return sprintf(buf, "%lu", trans_timeout);
 }
 
+#ifdef CONFIG_XPS
+static inline unsigned int get_netdev_queue_index(struct netdev_queue *queue)
+{
+	struct net_device *dev = queue->dev;
+	int i;
+
+	for (i = 0; i < dev->num_tx_queues; i++)
+		if (queue == &dev->_tx[i])
+			break;
+
+	BUG_ON(i >= dev->num_tx_queues);
+
+	return i;
+}
+
+static ssize_t show_tx_maxrate(struct netdev_queue *queue,
+			       struct netdev_queue_attribute *attribute,
+			       char *buf)
+{
+	return sprintf(buf, "%lu\n", queue->tx_maxrate);
+}
+
+static ssize_t set_tx_maxrate(struct netdev_queue *queue,
+			      struct netdev_queue_attribute *attribute,
+			      const char *buf, size_t len)
+{
+	struct net_device *dev = queue->dev;
+	int err, index = get_netdev_queue_index(queue);
+	u32 rate = 0;
+
+	err = kstrtou32(buf, 10, &rate);
+	if (err < 0)
+		return err;
+
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	err = -EOPNOTSUPP;
+	if (dev->netdev_ops->ndo_set_tx_maxrate)
+		err = dev->netdev_ops->ndo_set_tx_maxrate(dev, index, rate);
+
+	rtnl_unlock();
+	if (!err) {
+		queue->tx_maxrate = rate;
+		return len;
+	}
+	return err;
+}
+
+static struct netdev_queue_attribute queue_tx_maxrate =
+	__ATTR(tx_maxrate, S_IRUGO | S_IWUSR,
+	       show_tx_maxrate, set_tx_maxrate);
+#endif
+
 static struct netdev_queue_attribute queue_trans_timeout =
 	__ATTR(tx_timeout, S_IRUGO, show_trans_timeout, NULL);
 
@@ -1065,18 +1119,6 @@ static struct attribute_group dql_group = {
 #endif /* CONFIG_BQL */
 
 #ifdef CONFIG_XPS
-static unsigned int get_netdev_queue_index(struct netdev_queue *queue)
-{
-	struct net_device *dev = queue->dev;
-	unsigned int i;
-
-	i = queue - dev->_tx;
-	BUG_ON(i >= dev->num_tx_queues);
-
-	return i;
-}
-
-
 static ssize_t show_xps_map(struct netdev_queue *queue,
 			    struct netdev_queue_attribute *attribute, char *buf)
 {
@@ -1153,6 +1195,7 @@ static struct attribute *netdev_queue_default_attrs[] = {
 	&queue_trans_timeout.attr,
 #ifdef CONFIG_XPS
 	&xps_cpus_attribute.attr,
+	&queue_tx_maxrate.attr,
 #endif
 	NULL
 };
-- 
1.7.1
