From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH 4/5 v2] ifb: add multiqueue support
Date: Tue, 14 Dec 2010 23:21:38 +0800
Message-ID: <1292340098-25537-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f180.google.com ([209.85.161.180]:35639 "EHLO
	mail-gx0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758232Ab0LNPV4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Dec 2010 10:21:56 -0500
Received: by gxk19 with SMTP id 19so497563gxk.11
        for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 07:21:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Each ifb NIC has nr_cpu_ids rx queues and nr_cpu_ids queues. Packets
transmitted to ifb are enqueued to the corresponding per cpu tx queues,
and processed in the corresponding per cpu tasklet latter.

The stats are converted to the u64 ones.

tq is a stack variable now. It makes ifb_q_private smaller and tx queue
locked only once in ri_tasklet.

The tx_queue_len is multiplied by the number of online CPUs.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
---
v2: addressed the comments from Eirc. Thank him.
 drivers/net/ifb.c |  211 +++++++++++++++++++++++++++++++++++-------------------
 1 file changed, 138 insertions(+), 73 deletions(-)
diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 57c5cfb..918a38e 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -37,56 +37,60 @@
 #include <net/net_namespace.h>
 
 #define TX_Q_LIMIT    32
-struct ifb_private {
-	struct tasklet_struct   ifb_tasklet;
-	int     tasklet_pending;
-	struct sk_buff_head     rq;
-	struct sk_buff_head     tq;
+struct ifb_q_private {
+	struct net_device	*dev;
+	struct netdev_queue	*txq;
+	struct tasklet_struct	ifb_tasklet;
+	struct sk_buff_head	rq;
+	struct u64_stats_sync	syncp;
+	u64			rx_packets;
+	u64			rx_bytes;
+	u64			rx_dropped;
 };
 
+#define ifb_priv(dev) ((struct ifb_q_private __percpu *)(dev)->ml_priv)
+
 static int numifbs = 2;
 
-static void ri_tasklet(unsigned long dev)
+static void ri_tasklet(unsigned long arg)
 {
-
-	struct net_device *_dev = (struct net_device *)dev;
-	struct ifb_private *dp = netdev_priv(_dev);
-	struct net_device_stats *stats = &_dev->stats;
-	struct netdev_queue *txq;
+	struct ifb_q_private *qp = (struct ifb_q_private *)arg;
+	struct net_device *dev = qp->dev;
+	struct netdev_queue *txq = qp->txq;
 	struct sk_buff *skb;
+	struct sk_buff_head tq;
 
-	txq = netdev_get_tx_queue(_dev, 0);
-	skb = skb_peek(&dp->tq);
-	if (skb == NULL) {
-		if (__netif_tx_trylock(txq)) {
-			skb_queue_splice_tail_init(&dp->rq, &dp->tq);
-			__netif_tx_unlock(txq);
-		} else {
-			/* reschedule */
-			goto resched;
-		}
+	__skb_queue_head_init(&tq);
+	if (!__netif_tx_trylock(txq)) {
+		tasklet_schedule(&qp->ifb_tasklet);
+		return;
 	}
+	skb_queue_splice_tail_init(&qp->rq, &tq);
+	if (netif_tx_queue_stopped(txq))
+		netif_tx_wake_queue(txq);
+	__netif_tx_unlock(txq);
 
-	while ((skb = skb_dequeue(&dp->tq)) != NULL) {
+	while ((skb = __skb_dequeue(&tq)) != NULL) {
 		u32 from = G_TC_FROM(skb->tc_verd);
 
 		skb->tc_verd = 0;
 		skb->tc_verd = SET_TC_NCLS(skb->tc_verd);
-		stats->tx_packets++;
-		stats->tx_bytes += skb->len;
+		u64_stats_update_begin(&qp->syncp);
+		txq->tx_packets++;
+		txq->tx_bytes += skb->len;
 
 		rcu_read_lock();
 		skb->dev = dev_get_by_index_rcu(&init_net, skb->skb_iif);
 		if (!skb->dev) {
 			rcu_read_unlock();
+			txq->tx_dropped++;
+			u64_stats_update_end(&qp->syncp);
 			dev_kfree_skb(skb);
-			stats->tx_dropped++;
-			if (skb_queue_len(&dp->tq) != 0)
-				goto resched;
-			break;
+			continue;
 		}
 		rcu_read_unlock();
-		skb->skb_iif = _dev->ifindex;
+		u64_stats_update_end(&qp->syncp);
+		skb->skb_iif = dev->ifindex;
 
 		if (from & AT_EGRESS) {
 			dev_queue_xmit(skb);
@@ -96,82 +100,135 @@ static void ri_tasklet(unsigned long dev)
 		} else
 			BUG();
 	}
-
-	if (__netif_tx_trylock(txq)) {
-		skb = skb_peek(&dp->rq);
-		if (skb == NULL) {
-			dp->tasklet_pending = 0;
-			if (netif_queue_stopped(_dev))
-				netif_wake_queue(_dev);
-		} else {
-			__netif_tx_unlock(txq);
-			goto resched;
-		}
-		__netif_tx_unlock(txq);
-	} else {
-resched:
-		dp->tasklet_pending = 1;
-		tasklet_schedule(&dp->ifb_tasklet);
-	}
-
 }
 
 static netdev_tx_t ifb_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct ifb_private *dp = netdev_priv(dev);
-	struct net_device_stats *stats = &dev->stats;
+	int qid = skb_get_queue_mapping(skb);
+	struct ifb_q_private *qp = per_cpu_ptr(ifb_priv(dev), qid);
 	u32 from = G_TC_FROM(skb->tc_verd);
 
-	stats->rx_packets++;
-	stats->rx_bytes += skb->len;
+	WARN_ON(qid != smp_processor_id());
+
+	u64_stats_update_begin(&qp->syncp);
+	qp->rx_packets++;
+	qp->rx_bytes += skb->len;
 
 	if (!(from & (AT_INGRESS|AT_EGRESS)) || !skb->skb_iif) {
+		qp->rx_dropped++;
+		u64_stats_update_end(&qp->syncp);
 		dev_kfree_skb(skb);
-		stats->rx_dropped++;
 		return NETDEV_TX_OK;
 	}
+	u64_stats_update_end(&qp->syncp);
 
-	__skb_queue_tail(&dp->rq, skb);
-	if (!dp->tasklet_pending) {
-		dp->tasklet_pending = 1;
-		tasklet_schedule(&dp->ifb_tasklet);
-	}
+	__skb_queue_tail(&qp->rq, skb);
+	if (skb_queue_len(&qp->rq) == 1)
+		tasklet_schedule(&qp->ifb_tasklet);
 
-	if (skb_queue_len(&dp->rq) >= dev->tx_queue_len)
-		netif_stop_queue(dev);
+	if (skb_queue_len(&qp->rq) >= dev->tx_queue_len)
+		netif_tx_stop_queue(qp->txq);
 
 	return NETDEV_TX_OK;
 }
 
 static int ifb_close(struct net_device *dev)
 {
-	struct ifb_private *dp = netdev_priv(dev);
-
-	tasklet_kill(&dp->ifb_tasklet);
-	netif_stop_queue(dev);
-	__skb_queue_purge(&dp->rq);
-	__skb_queue_purge(&dp->tq);
+	struct ifb_q_private *qp;
+	int cpu;
+
+	for_each_possible_cpu(cpu) {
+		qp = per_cpu_ptr(ifb_priv(dev), cpu);
+		tasklet_kill(&qp->ifb_tasklet);
+		netif_tx_stop_queue(qp->txq);
+		__skb_queue_purge(&qp->rq);
+	}
 
 	return 0;
 }
 
 static int ifb_open(struct net_device *dev)
 {
-	struct ifb_private *dp = netdev_priv(dev);
+	int cpu;
+
+	for_each_possible_cpu(cpu)
+		netif_tx_start_queue(netdev_get_tx_queue(dev, cpu));
 
-	tasklet_init(&dp->ifb_tasklet, ri_tasklet, (unsigned long)dev);
-	__skb_queue_head_init(&dp->rq);
-	__skb_queue_head_init(&dp->tq);
-	netif_start_queue(dev);
+	return 0;
+}
+
+static int ifb_init(struct net_device *dev)
+{
+	struct ifb_q_private *q;
+	int cpu;
+
+	dev->ml_priv = alloc_percpu(struct ifb_q_private);
+	if (!ifb_priv(dev))
+		return -ENOMEM;
+	for_each_possible_cpu(cpu) {
+		q = per_cpu_ptr(ifb_priv(dev), cpu);
+		__skb_queue_head_init(&q->rq);
+		q->txq = netdev_get_tx_queue(dev, cpu);
+		q->dev = dev;
+		tasklet_init(&q->ifb_tasklet, ri_tasklet, (unsigned long)q);
+		netdev_queue_numa_node_write(q->txq, cpu_to_node(cpu));
+	}
 
 	return 0;
 }
 
+static void ifb_uninit(struct net_device *dev)
+{
+	free_percpu(ifb_priv(dev));
+}
+
+static u16 ifb_select_queue(struct net_device *dev, struct sk_buff *skb)
+{
+	return smp_processor_id();
+}
+
+static struct rtnl_link_stats64 *ifb_get_stats64(struct net_device *dev,
+		struct rtnl_link_stats64 *stats)
+{
+	struct ifb_q_private *q;
+	struct netdev_queue *txq;
+	int cpu;
+	u64 rx_packets, rx_bytes, rx_dropped;
+	u64 tx_packets, tx_bytes, tx_dropped;
+	unsigned int start;
+
+	for_each_possible_cpu(cpu) {
+		q = per_cpu_ptr(ifb_priv(dev), cpu);
+		txq = q->txq;
+		do {
+			start = u64_stats_fetch_begin_bh(&q->syncp);
+			rx_packets = q->rx_packets;
+			rx_bytes = q->rx_bytes;
+			rx_dropped = q->rx_dropped;
+			tx_packets = txq->tx_packets;
+			tx_bytes = txq->tx_bytes;
+			tx_dropped = txq->tx_dropped;
+		} while (u64_stats_fetch_retry_bh(&q->syncp, start));
+		stats->rx_packets += rx_packets;
+		stats->rx_bytes += rx_bytes;
+		stats->rx_dropped += rx_dropped;
+		stats->tx_packets += tx_packets;
+		stats->tx_bytes += tx_bytes;
+		stats->tx_dropped += tx_dropped;
+	}
+
+	return stats;
+}
+
 static const struct net_device_ops ifb_netdev_ops = {
+	.ndo_init		= ifb_init,
+	.ndo_uninit		= ifb_uninit,
 	.ndo_open		= ifb_open,
 	.ndo_stop		= ifb_close,
 	.ndo_start_xmit		= ifb_xmit,
 	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_select_queue	= ifb_select_queue,
+	.ndo_get_stats64	= ifb_get_stats64,
 };
 
 static void ifb_setup(struct net_device *dev)
@@ -202,11 +259,20 @@ static int ifb_validate(struct nlattr *tb[], struct nlattr *data[])
 	return 0;
 }
 
+static int ifb_get_tx_queues(struct net *net, struct nlattr *tb[],
+			     unsigned int *tx_queues,
+			     unsigned int *real_tx_queues)
+{
+	*real_tx_queues = *tx_queues = nr_cpu_ids;
+
+	return 0;
+}
+
 static struct rtnl_link_ops ifb_link_ops __read_mostly = {
 	.kind		= "ifb",
-	.priv_size	= sizeof(struct ifb_private),
 	.setup		= ifb_setup,
 	.validate	= ifb_validate,
+	.get_tx_queues	= ifb_get_tx_queues,
 };
 
 /* Number of ifb devices to be set up by this module. */
@@ -218,8 +284,7 @@ static int __init ifb_init_one(int index)
 	struct net_device *dev_ifb;
 	int err;
 
-	dev_ifb = alloc_netdev(sizeof(struct ifb_private), "ifb%d", ifb_setup);
-
+	dev_ifb = alloc_netdev_mq(0, "ifb%d", ifb_setup, nr_cpu_ids);
 	if (!dev_ifb)
 		return -ENOMEM;
 
