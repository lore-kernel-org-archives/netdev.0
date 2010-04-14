From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH v3] net: batch skb dequeueing from softnet input_pkt_queue
Date: Wed, 14 Apr 2010 17:52:18 +0800
Message-ID: <1271238738-8386-1-git-send-email-xiaosuo@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:34251 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754564Ab0DNJwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 05:52:08 -0400
Received: by pwj9 with SMTP id 9so6108211pwj.19
        for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 02:52:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

batch skb dequeueing from softnet input_pkt_queue

batch skb dequeueing from softnet input_pkt_queue to reduce potential lock
contention and irq disabling/enabling.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 include/linux/netdevice.h |    1 
 net/core/dev.c            |   56 ++++++++++++++++++++++++++++++++--------------
 2 files changed, 40 insertions(+), 17 deletions(-)
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d1a21b5..898bc62 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1335,6 +1335,7 @@ struct softnet_data {
 	struct call_single_data	csd ____cacheline_aligned_in_smp;
 #endif
 	struct sk_buff_head	input_pkt_queue;
+	struct sk_buff_head	processing_queue;
 	struct napi_struct	backlog;
 };
 
diff --git a/net/core/dev.c b/net/core/dev.c
index a10a216..c635a71 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -131,6 +131,7 @@
 #include <linux/random.h>
 #include <trace/events/napi.h>
 #include <linux/pci.h>
+#include <linux/stop_machine.h>
 
 #include "net-sysfs.h"
 
@@ -2332,6 +2333,7 @@ static int enqueue_to_backlog(struct sk_buff *skb, int cpu)
 {
 	struct softnet_data *queue;
 	unsigned long flags;
+	u32 qlen;
 
 	queue = &per_cpu(softnet_data, cpu);
 
@@ -2339,8 +2341,9 @@ static int enqueue_to_backlog(struct sk_buff *skb, int cpu)
 	__get_cpu_var(netdev_rx_stat).total++;
 
 	rps_lock(queue);
-	if (queue->input_pkt_queue.qlen <= netdev_max_backlog) {
-		if (queue->input_pkt_queue.qlen) {
+	qlen = queue->input_pkt_queue.qlen + queue->processing_queue.qlen;
+	if (qlen <= netdev_max_backlog) {
+		if (qlen) {
 enqueue:
 			__skb_queue_tail(&queue->input_pkt_queue, skb);
 			rps_unlock(queue);
@@ -2791,19 +2794,31 @@ int netif_receive_skb(struct sk_buff *skb)
 EXPORT_SYMBOL(netif_receive_skb);
 
 /* Network device is going away, flush any packets still pending  */
-static void flush_backlog(void *arg)
+static void __flush_backlog(struct sk_buff_head *head, struct net_device *dev)
 {
-	struct net_device *dev = arg;
-	struct softnet_data *queue = &__get_cpu_var(softnet_data);
 	struct sk_buff *skb, *tmp;
 
-	rps_lock(queue);
-	skb_queue_walk_safe(&queue->input_pkt_queue, skb, tmp)
+	skb_queue_walk_safe(head, skb, tmp) {
 		if (skb->dev == dev) {
-			__skb_unlink(skb, &queue->input_pkt_queue);
+			__skb_unlink(skb, head);
 			kfree_skb(skb);
 		}
-	rps_unlock(queue);
+	}
+}
+
+static int flush_backlog(void *arg)
+{
+	struct net_device *dev = arg;
+	struct softnet_data *queue;
+	int cpu;
+
+	for_each_online_cpu(cpu) {
+		queue = &per_cpu(softnet_data, cpu);
+		__flush_backlog(&queue->input_pkt_queue, dev);
+		__flush_backlog(&queue->processing_queue, dev);
+	}
+
+	return 0;
 }
 
 static int napi_gro_complete(struct sk_buff *skb)
@@ -3118,20 +3133,23 @@ static int process_backlog(struct napi_struct *napi, int quota)
 
 		local_irq_disable();
 		rps_lock(queue);
-		skb = __skb_dequeue(&queue->input_pkt_queue);
-		if (!skb) {
+		skb_queue_splice_tail_init(&queue->input_pkt_queue,
+					   &queue->processing_queue);
+		if (skb_queue_empty(&queue->processing_queue)) {
 			__napi_complete(napi);
 			rps_unlock(queue);
 			local_irq_enable();
-			break;
+			return work;
 		}
 		rps_unlock(queue);
 		local_irq_enable();
 
-		__netif_receive_skb(skb);
-	} while (++work < quota && jiffies == start_time);
-
-	return work;
+		while ((skb = __skb_dequeue(&queue->processing_queue))) {
+			__netif_receive_skb(skb);
+			if (++work >= quota || jiffies != start_time)
+				return work;
+		}
+	} while (1);
 }
 
 /**
@@ -5027,7 +5045,7 @@ void netdev_run_todo(void)
 
 		dev->reg_state = NETREG_UNREGISTERED;
 
-		on_each_cpu(flush_backlog, dev, 1);
+		stop_machine(flush_backlog, dev, NULL);
 
 		netdev_wait_allrefs(dev);
 
@@ -5487,6 +5505,9 @@ static int dev_cpu_callback(struct notifier_block *nfb,
 	raise_softirq_irqoff(NET_TX_SOFTIRQ);
 	local_irq_enable();
 
+	while ((skb = __skb_dequeue(&oldsd->processing_queue)))
+		netif_rx(skb);
+
 	/* Process offline CPU's input_pkt_queue */
 	while ((skb = __skb_dequeue(&oldsd->input_pkt_queue)))
 		netif_rx(skb);
@@ -5709,6 +5730,7 @@ static int __init net_dev_init(void)
 
 		queue = &per_cpu(softnet_data, i);
 		skb_queue_head_init(&queue->input_pkt_queue);
+		skb_queue_head_init(&queue->processing_queue);
 		queue->completion_queue = NULL;
 		INIT_LIST_HEAD(&queue->poll_list);
 
