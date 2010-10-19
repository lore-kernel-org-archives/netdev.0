From: Tom Herbert <therbert@google.com>
Subject: [PATCH 3/3 v2] net: allocate tx queues in register_netdevice
Date: Mon, 18 Oct 2010 21:04:39 -0700 (PDT)
Message-ID: <alpine.DEB.1.00.1010182100180.6676@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: bhutchings@solarflare.com, eric.dumazet@gmail.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:2247 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932393Ab0JSEEq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Oct 2010 00:04:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces netif_alloc_netdev_queues which is called from
register_device instead of alloc_netdev_mq.  This makes TX queue
allocation symmetric with RX allocation.  Also, queue locks allocation
is done in netdev_init_one_queue.  Change set_real_num_tx_queues to
fail if requested number < 1 or greater than number of allocated
queues.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/netdevice.h |    4 +-
 net/core/dev.c            |  106 ++++++++++++++++++++++----------------------
 2 files changed, 55 insertions(+), 55 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 14fbb04..880d565 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1696,8 +1696,8 @@ static inline int netif_is_multiqueue(const struct net_device *dev)
 	return dev->num_tx_queues > 1;
 }
 
-extern void netif_set_real_num_tx_queues(struct net_device *dev,
-					 unsigned int txq);
+extern int netif_set_real_num_tx_queues(struct net_device *dev,
+					unsigned int txq);
 
 #ifdef CONFIG_RPS
 extern int netif_set_real_num_rx_queues(struct net_device *dev,
diff --git a/net/core/dev.c b/net/core/dev.c
index d33adec..7ae5c7e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1553,18 +1553,20 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
  * Routine to help set real_num_tx_queues. To avoid skbs mapped to queues
  * greater then real_num_tx_queues stale skbs on the qdisc must be flushed.
  */
-void netif_set_real_num_tx_queues(struct net_device *dev, unsigned int txq)
+int netif_set_real_num_tx_queues(struct net_device *dev, unsigned int txq)
 {
-	unsigned int real_num = dev->real_num_tx_queues;
+	if (txq < 1 || txq > dev->num_tx_queues)
+		return -EINVAL;
 
-	if (unlikely(txq > dev->num_tx_queues))
-		;
-	else if (txq > real_num)
-		dev->real_num_tx_queues = txq;
-	else if (txq < real_num) {
-		dev->real_num_tx_queues = txq;
-		qdisc_reset_all_tx_gt(dev, txq);
+	if (dev->reg_state == NETREG_REGISTERED) {
+		ASSERT_RTNL();
+
+		if (txq < dev->real_num_tx_queues)
+			qdisc_reset_all_tx_gt(dev, txq);
 	}
+
+	dev->real_num_tx_queues = txq;
+	return 0;
 }
 EXPORT_SYMBOL(netif_set_real_num_tx_queues);
 
@@ -4928,20 +4930,6 @@ static void rollback_registered(struct net_device *dev)
 	rollback_registered_many(&single);
 }
 
-static void __netdev_init_queue_locks_one(struct net_device *dev,
-					  struct netdev_queue *dev_queue,
-					  void *_unused)
-{
-	spin_lock_init(&dev_queue->_xmit_lock);
-	netdev_set_xmit_lockdep_class(&dev_queue->_xmit_lock, dev->type);
-	dev_queue->xmit_lock_owner = -1;
-}
-
-static void netdev_init_queue_locks(struct net_device *dev)
-{
-	netdev_for_each_tx_queue(dev, __netdev_init_queue_locks_one, NULL);
-}
-
 unsigned long netdev_fix_features(unsigned long features, const char *name)
 {
 	/* Fix illegal SG+CSUM combinations. */
@@ -5034,6 +5022,41 @@ static int netif_alloc_rx_queues(struct net_device *dev)
 	return 0;
 }
 
+static int netif_alloc_netdev_queues(struct net_device *dev)
+{
+	unsigned int count = dev->num_tx_queues;
+	struct netdev_queue *tx;
+
+	BUG_ON(count < 1);
+
+	tx = kcalloc(count, sizeof(struct netdev_queue), GFP_KERNEL);
+	if (!tx) {
+		pr_err("netdev: Unable to allocate %u tx queues.\n",
+		       count);
+			return -ENOMEM;
+	}
+	dev->_tx = tx;
+	return 0;
+}
+
+static void netdev_init_one_queue(struct net_device *dev,
+				  struct netdev_queue *queue,
+				  void *_unused)
+{
+	queue->dev = dev;
+
+	/* Initialize queue lock */
+	spin_lock_init(&queue->_xmit_lock);
+	netdev_set_xmit_lockdep_class(&queue->_xmit_lock, dev->type);
+	queue->xmit_lock_owner = -1;
+}
+
+static void netdev_init_queues(struct net_device *dev)
+{
+	netdev_for_each_tx_queue(dev, netdev_init_one_queue, NULL);
+	spin_lock_init(&dev->tx_global_lock);
+}
+
 /**
  *	register_netdevice	- register a network device
  *	@dev: device to register
@@ -5067,7 +5090,6 @@ int register_netdevice(struct net_device *dev)
 
 	spin_lock_init(&dev->addr_list_lock);
 	netdev_set_addr_lockdep_class(dev);
-	netdev_init_queue_locks(dev);
 
 	dev->iflink = -1;
 
@@ -5075,6 +5097,12 @@ int register_netdevice(struct net_device *dev)
 	if (ret)
 		goto out;
 
+	ret = netif_alloc_netdev_queues(dev);
+	if (ret)
+		goto out;
+
+	netdev_init_queues(dev);
+
 	/* Init, if this function is available */
 	if (dev->netdev_ops->ndo_init) {
 		ret = dev->netdev_ops->ndo_init(dev);
@@ -5456,19 +5484,6 @@ struct rtnl_link_stats64 *dev_get_stats(struct net_device *dev,
 }
 EXPORT_SYMBOL(dev_get_stats);
 
-static void netdev_init_one_queue(struct net_device *dev,
-				  struct netdev_queue *queue,
-				  void *_unused)
-{
-	queue->dev = dev;
-}
-
-static void netdev_init_queues(struct net_device *dev)
-{
-	netdev_for_each_tx_queue(dev, netdev_init_one_queue, NULL);
-	spin_lock_init(&dev->tx_global_lock);
-}
-
 struct netdev_queue *dev_ingress_queue_create(struct net_device *dev)
 {
 	struct netdev_queue *queue = dev_ingress_queue(dev);
@@ -5480,7 +5495,6 @@ struct netdev_queue *dev_ingress_queue_create(struct net_device *dev)
 	if (!queue)
 		return NULL;
 	netdev_init_one_queue(dev, queue, NULL);
-	__netdev_init_queue_locks_one(dev, queue, NULL);
 	queue->qdisc = &noop_qdisc;
 	queue->qdisc_sleeping = &noop_qdisc;
 	rcu_assign_pointer(dev->ingress_queue, queue);
@@ -5502,7 +5516,6 @@ struct netdev_queue *dev_ingress_queue_create(struct net_device *dev)
 struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 		void (*setup)(struct net_device *), unsigned int queue_count)
 {
-	struct netdev_queue *tx;
 	struct net_device *dev;
 	size_t alloc_size;
 	struct net_device *p;
@@ -5530,20 +5543,12 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 		return NULL;
 	}
 
-	tx = kcalloc(queue_count, sizeof(struct netdev_queue), GFP_KERNEL);
-	if (!tx) {
-		printk(KERN_ERR "alloc_netdev: Unable to allocate "
-		       "tx qdiscs.\n");
-		goto free_p;
-	}
-
-
 	dev = PTR_ALIGN(p, NETDEV_ALIGN);
 	dev->padded = (char *)dev - (char *)p;
 
 	dev->pcpu_refcnt = alloc_percpu(int);
 	if (!dev->pcpu_refcnt)
-		goto free_tx;
+		goto free_p;
 
 	if (dev_addr_init(dev))
 		goto free_pcpu;
@@ -5553,7 +5558,6 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 
 	dev_net_set(dev, &init_net);
 
-	dev->_tx = tx;
 	dev->num_tx_queues = queue_count;
 	dev->real_num_tx_queues = queue_count;
 
@@ -5564,8 +5568,6 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 
 	dev->gso_max_size = GSO_MAX_SIZE;
 
-	netdev_init_queues(dev);
-
 	INIT_LIST_HEAD(&dev->ethtool_ntuple_list.list);
 	dev->ethtool_ntuple_list.count = 0;
 	INIT_LIST_HEAD(&dev->napi_list);
@@ -5576,8 +5578,6 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 	strcpy(dev->name, name);
 	return dev;
 
-free_tx:
-	kfree(tx);
 free_pcpu:
 	free_percpu(dev->pcpu_refcnt);
 free_p:
-- 
1.7.1

