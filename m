From: Jason Wang <jasowang@redhat.com>
Subject: [net-next rfc 1/3] net: avoid high order memory allocation for queues by using flex array
Date: Wed, 19 Jun 2013 13:40:50 +0800
Message-ID: <1371620452-49349-2-git-send-email-jasowang@redhat.com>
References: <1371620452-49349-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, edumazet@google.com, hkchu@google.com,
	mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371620452-49349-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently, we use kcalloc to allocate rx/tx queues for a net device which could
be easily lead to a high order memory allocation request when initializing a
multiqueue net device. We can simply avoid this by switching to use flex array
which always allocate at order zero.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 include/linux/netdevice.h |   13 ++++++----
 net/core/dev.c            |   57 ++++++++++++++++++++++++++++++++------------
 net/core/net-sysfs.c      |   15 +++++++----
 3 files changed, 58 insertions(+), 27 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 09b4188..c0b5d04 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -32,6 +32,7 @@
 #include <linux/atomic.h>
 #include <asm/cache.h>
 #include <asm/byteorder.h>
+#include <linux/flex_array.h>
 
 #include <linux/percpu.h>
 #include <linux/rculist.h>
@@ -1230,7 +1231,7 @@ struct net_device {
 
 
 #ifdef CONFIG_RPS
-	struct netdev_rx_queue	*_rx;
+	struct flex_array	*_rx;
 
 	/* Number of RX queues allocated at register_netdev() time */
 	unsigned int		num_rx_queues;
@@ -1250,7 +1251,7 @@ struct net_device {
 /*
  * Cache lines mostly used on transmit path
  */
-	struct netdev_queue	*_tx ____cacheline_aligned_in_smp;
+	struct flex_array	*_tx ____cacheline_aligned_in_smp;
 
 	/* Number of TX queues allocated at alloc_netdev_mq() time  */
 	unsigned int		num_tx_queues;
@@ -1434,7 +1435,7 @@ static inline
 struct netdev_queue *netdev_get_tx_queue(const struct net_device *dev,
 					 unsigned int index)
 {
-	return &dev->_tx[index];
+	return flex_array_get(dev->_tx, index);
 }
 
 static inline void netdev_for_each_tx_queue(struct net_device *dev,
@@ -1445,8 +1446,10 @@ static inline void netdev_for_each_tx_queue(struct net_device *dev,
 {
 	unsigned int i;
 
-	for (i = 0; i < dev->num_tx_queues; i++)
-		f(dev, &dev->_tx[i], arg);
+	for (i = 0; i < dev->num_tx_queues; i++) {
+		struct netdev_queue *txq = flex_array_get(dev->_tx, i);
+		f(dev, txq, arg);
+	}
 }
 
 extern struct netdev_queue *netdev_pick_tx(struct net_device *dev,
diff --git a/net/core/dev.c b/net/core/dev.c
index fa007db..3a4ecb1 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -130,6 +130,7 @@
 #include <linux/cpu_rmap.h>
 #include <linux/static_key.h>
 #include <linux/hashtable.h>
+#include <linux/flex_array.h>
 
 #include "net-sysfs.h"
 
@@ -2902,7 +2903,7 @@ set_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 		if (rxq_index == skb_get_rx_queue(skb))
 			goto out;
 
-		rxqueue = dev->_rx + rxq_index;
+		rxqueue = flex_array_get(dev->_rx, rxq_index);
 		flow_table = rcu_dereference(rxqueue->rps_flow_table);
 		if (!flow_table)
 			goto out;
@@ -2950,9 +2951,9 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 				  dev->name, index, dev->real_num_rx_queues);
 			goto done;
 		}
-		rxqueue = dev->_rx + index;
+		rxqueue = flex_array_get(dev->_rx, index);
 	} else
-		rxqueue = dev->_rx;
+		rxqueue = flex_array_get(dev->_rx, 0);
 
 	map = rcu_dereference(rxqueue->rps_map);
 	if (map) {
@@ -3038,7 +3039,7 @@ done:
 bool rps_may_expire_flow(struct net_device *dev, u16 rxq_index,
 			 u32 flow_id, u16 filter_id)
 {
-	struct netdev_rx_queue *rxqueue = dev->_rx + rxq_index;
+	struct netdev_rx_queue *rxqueue = flex_array_get(dev->_rx, rxq_index);
 	struct rps_dev_flow_table *flow_table;
 	struct rps_dev_flow *rflow;
 	bool expire = true;
@@ -5223,18 +5224,31 @@ EXPORT_SYMBOL(netif_stacked_transfer_operstate);
 static int netif_alloc_rx_queues(struct net_device *dev)
 {
 	unsigned int i, count = dev->num_rx_queues;
-	struct netdev_rx_queue *rx;
+	struct flex_array *rx;
+	int err;
 
 	BUG_ON(count < 1);
 
-	rx = kcalloc(count, sizeof(struct netdev_rx_queue), GFP_KERNEL);
-	if (!rx)
+	rx = flex_array_alloc(sizeof(struct netdev_rx_queue), count,
+			      GFP_KERNEL | __GFP_ZERO);
+	if (!rx) {
+		pr_err("netdev: Unable to allocate flex array for rx queues\n");
 		return -ENOMEM;
+	}
+
+	err = flex_array_prealloc(rx, 0, count, GFP_KERNEL | __GFP_ZERO);
+	if (err) {
+		pr_err("netdev, Unable to prealloc %u rx qeueus\n", count);
+		flex_array_free(rx);
+		return err;
+	}
 
 	dev->_rx = rx;
 
-	for (i = 0; i < count; i++)
-		rx[i].dev = dev;
+	for (i = 0; i < count; i++) {
+		struct netdev_rx_queue *rxq = flex_array_get(rx, i);
+		rxq->dev = dev;
+	}
 	return 0;
 }
 #endif
@@ -5256,13 +5270,24 @@ static void netdev_init_one_queue(struct net_device *dev,
 static int netif_alloc_netdev_queues(struct net_device *dev)
 {
 	unsigned int count = dev->num_tx_queues;
-	struct netdev_queue *tx;
+	struct flex_array *tx;
+	int err;
 
 	BUG_ON(count < 1);
 
-	tx = kcalloc(count, sizeof(struct netdev_queue), GFP_KERNEL);
-	if (!tx)
+	tx = flex_array_alloc(sizeof(struct netdev_queue), count,
+			      GFP_KERNEL | __GFP_ZERO);
+	if (!tx) {
+		pr_err("netdev: Unable to allocate flex array for tx queues\n");
 		return -ENOMEM;
+	}
+
+	err = flex_array_prealloc(tx, 0, count, GFP_KERNEL | __GFP_ZERO);
+	if (err) {
+		pr_err("netdev, Unable to prealloc %u tx qeueus\n", count);
+		flex_array_free(tx);
+		return err;
+	}
 
 	dev->_tx = tx;
 
@@ -5811,9 +5836,9 @@ free_all:
 
 free_pcpu:
 	free_percpu(dev->pcpu_refcnt);
-	kfree(dev->_tx);
+	flex_array_free(dev->_tx);
 #ifdef CONFIG_RPS
-	kfree(dev->_rx);
+	flex_array_free(dev->_rx);
 #endif
 
 free_p:
@@ -5836,9 +5861,9 @@ void free_netdev(struct net_device *dev)
 
 	release_net(dev_net(dev));
 
-	kfree(dev->_tx);
+	flex_array_free(dev->_tx);
 #ifdef CONFIG_RPS
-	kfree(dev->_rx);
+	flex_array_free(dev->_rx);
 #endif
 
 	kfree(rcu_dereference_protected(dev->ingress_queue, 1));
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 981fed3..4328c3a 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -22,6 +22,7 @@
 #include <linux/export.h>
 #include <linux/jiffies.h>
 #include <linux/pm_runtime.h>
+#include <linux/flex_array.h>
 
 #include "net-sysfs.h"
 
@@ -717,7 +718,7 @@ static struct kobj_type rx_queue_ktype = {
 
 static int rx_queue_add_kobject(struct net_device *net, int index)
 {
-	struct netdev_rx_queue *queue = net->_rx + index;
+	struct netdev_rx_queue *queue = flex_array_get(net->_rx, index);
 	struct kobject *kobj = &queue->kobj;
 	int error = 0;
 
@@ -751,8 +752,10 @@ net_rx_queue_update_kobjects(struct net_device *net, int old_num, int new_num)
 		}
 	}
 
-	while (--i >= new_num)
-		kobject_put(&net->_rx[i].kobj);
+	while (--i >= new_num) {
+		struct netdev_rx_queue *rxq = flex_array_get(net->_rx, i);
+		kobject_put(&rxq->kobj);
+	}
 
 	return error;
 #else
@@ -939,7 +942,7 @@ static inline unsigned int get_netdev_queue_index(struct netdev_queue *queue)
 	int i;
 
 	for (i = 0; i < dev->num_tx_queues; i++)
-		if (queue == &dev->_tx[i])
+		if (queue == (struct netdev_queue *)flex_array_get(dev->_tx, i))
 			break;
 
 	BUG_ON(i >= dev->num_tx_queues);
@@ -1051,7 +1054,7 @@ static struct kobj_type netdev_queue_ktype = {
 
 static int netdev_queue_add_kobject(struct net_device *net, int index)
 {
-	struct netdev_queue *queue = net->_tx + index;
+	struct netdev_queue *queue = flex_array_get(net->_tx, index);
 	struct kobject *kobj = &queue->kobj;
 	int error = 0;
 
@@ -1093,7 +1096,7 @@ netdev_queue_update_kobjects(struct net_device *net, int old_num, int new_num)
 	}
 
 	while (--i >= new_num) {
-		struct netdev_queue *queue = net->_tx + i;
+		struct netdev_queue *queue = flex_array_get(net->_tx, i);
 
 #ifdef CONFIG_BQL
 		sysfs_remove_group(&queue->kobj, &dql_group);
-- 
1.7.1
