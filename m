From: Tom Herbert <therbert@google.com>
Subject: [PATCH 2/2] net: Simplify RX queue allocation
Date: Tue, 9 Nov 2010 12:47:38 -0800 (PST)
Message-ID: <alpine.DEB.1.00.1011091243010.18818@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:38802 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752350Ab0KIUro (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 15:47:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch move RX queue allocation to alloc_netdev_mq and freeing of
the queues to free_netdev (symmetric to TX queue allocation).  Each
kobject RX queue takes a reference to the queue's device so that the
device can't be freed before all the kobjects have been released-- this
obviates the need for reference counts specific to RX queues.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/netdevice.h |    3 +--
 net/core/dev.c            |   15 ++++++++++-----
 net/core/net-sysfs.c      |    7 ++-----
 3 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d8fd2c2..da59595 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -592,8 +592,7 @@ struct netdev_rx_queue {
 	struct rps_map __rcu		*rps_map;
 	struct rps_dev_flow_table __rcu	*rps_flow_table;
 	struct kobject			kobj;
-	struct netdev_rx_queue		*first;
-	atomic_t			count;
+	struct net_device		*dev;
 } ____cacheline_aligned_in_smp;
 #endif /* CONFIG_RPS */
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 8f9c76e..87d89ba 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5034,7 +5034,7 @@ static int netif_alloc_rx_queues(struct net_device *dev)
 	 * reference count.
 	 */
 	for (i = 0; i < count; i++)
-		rx[i].first = rx;
+		rx[i].dev = dev;
 #endif
 	return 0;
 }
@@ -5110,10 +5110,6 @@ int register_netdevice(struct net_device *dev)
 
 	dev->iflink = -1;
 
-	ret = netif_alloc_rx_queues(dev);
-	if (ret)
-		goto out;
-
 	netdev_init_queues(dev);
 
 	/* Init, if this function is available */
@@ -5579,6 +5575,8 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 #ifdef CONFIG_RPS
 	dev->num_rx_queues = queue_count;
 	dev->real_num_rx_queues = queue_count;
+	if (netif_alloc_rx_queues(dev))
+		goto free_pcpu;
 #endif
 
 	dev->gso_max_size = GSO_MAX_SIZE;
@@ -5596,6 +5594,10 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 free_pcpu:
 	free_percpu(dev->pcpu_refcnt);
 	kfree(dev->_tx);
+#ifdef CONFIG_RPS
+	kfree(dev->_rx);
+#endif
+
 free_p:
 	kfree(p);
 	return NULL;
@@ -5617,6 +5619,9 @@ void free_netdev(struct net_device *dev)
 	release_net(dev_net(dev));
 
 	kfree(dev->_tx);
+#ifdef CONFIG_RPS
+	kfree(dev->_rx);
+#endif
 
 	kfree(rcu_dereference_raw(dev->ingress_queue));
 
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index a5ff5a8..3ba526b 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -706,7 +706,6 @@ static struct attribute *rx_queue_default_attrs[] = {
 static void rx_queue_release(struct kobject *kobj)
 {
 	struct netdev_rx_queue *queue = to_rx_queue(kobj);
-	struct netdev_rx_queue *first = queue->first;
 	struct rps_map *map;
 	struct rps_dev_flow_table *flow_table;
 
@@ -719,8 +718,7 @@ static void rx_queue_release(struct kobject *kobj)
 	if (flow_table)
 		call_rcu(&flow_table->rcu, rps_dev_flow_table_release);
 
-	if (atomic_dec_and_test(&first->count))
-		kfree(first);
+	dev_put(queue->dev);
 }
 
 static struct kobj_type rx_queue_ktype = {
@@ -732,7 +730,6 @@ static struct kobj_type rx_queue_ktype = {
 static int rx_queue_add_kobject(struct net_device *net, int index)
 {
 	struct netdev_rx_queue *queue = net->_rx + index;
-	struct netdev_rx_queue *first = queue->first;
 	struct kobject *kobj = &queue->kobj;
 	int error = 0;
 
@@ -745,7 +742,7 @@ static int rx_queue_add_kobject(struct net_device *net, int index)
 	}
 
 	kobject_uevent(kobj, KOBJ_ADD);
-	atomic_inc(&first->count);
+	dev_hold(queue->dev);
 
 	return error;
 }
-- 
1.7.3.1

