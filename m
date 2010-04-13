From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH v2] net: batch skb dequeueing from softnet input_pkt_queue
Date: Tue, 13 Apr 2010 23:38:22 +0800
Message-ID: <1271173102-2980-1-git-send-email-xiaosuo@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:34165 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751432Ab0DMHiR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 03:38:17 -0400
Received: by vws18 with SMTP id 18so1543645vws.19
        for <netdev@vger.kernel.org>; Tue, 13 Apr 2010 00:38:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

batch skb dequeueing from softnet input_pkt_queue

batch skb dequeueing from softnet input_pkt_queue to reduce potential lock
contention and irq disabling/enabling.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 include/linux/netdevice.h |    2 ++
 net/core/dev.c            |   45 +++++++++++++++++++++++++++++++++++++++------
 2 files changed, 41 insertions(+), 6 deletions(-)
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d1a21b5..bc7a0d7 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1335,6 +1335,8 @@ struct softnet_data {
 	struct call_single_data	csd ____cacheline_aligned_in_smp;
 #endif
 	struct sk_buff_head	input_pkt_queue;
+	struct sk_buff_head	processing_queue;
+	volatile bool		flush_processing_queue;
 	struct napi_struct	backlog;
 };
 
diff --git a/net/core/dev.c b/net/core/dev.c
index a10a216..ac24293 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2324,6 +2324,11 @@ static void trigger_softirq(void *data)
 }
 #endif /* CONFIG_SMP */
 
+static inline u32 softnet_input_qlen(struct softnet_data *queue)
+{
+	return queue->input_pkt_queue.qlen + queue->processing_queue.qlen;
+}
+
 /*
  * enqueue_to_backlog is called to queue an skb to a per CPU backlog
  * queue (may be a remote CPU queue).
@@ -2339,8 +2344,8 @@ static int enqueue_to_backlog(struct sk_buff *skb, int cpu)
 	__get_cpu_var(netdev_rx_stat).total++;
 
 	rps_lock(queue);
-	if (queue->input_pkt_queue.qlen <= netdev_max_backlog) {
-		if (queue->input_pkt_queue.qlen) {
+	if (softnet_input_qlen(queue) <= netdev_max_backlog) {
+		if (softnet_input_qlen(queue)) {
 enqueue:
 			__skb_queue_tail(&queue->input_pkt_queue, skb);
 			rps_unlock(queue);
@@ -2803,6 +2808,7 @@ static void flush_backlog(void *arg)
 			__skb_unlink(skb, &queue->input_pkt_queue);
 			kfree_skb(skb);
 		}
+	queue->flush_processing_queue = true;
 	rps_unlock(queue);
 }
 
@@ -3112,14 +3118,23 @@ static int process_backlog(struct napi_struct *napi, int quota)
 	struct softnet_data *queue = &__get_cpu_var(softnet_data);
 	unsigned long start_time = jiffies;
 
+	if (queue->flush_processing_queue) {
+		struct sk_buff *skb;
+
+		queue->flush_processing_queue = false;
+		while ((skb = __skb_dequeue(&queue->processing_queue)))
+			kfree_skb(skb);
+	}
+
 	napi->weight = weight_p;
 	do {
 		struct sk_buff *skb;
 
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
@@ -3128,9 +3143,22 @@ static int process_backlog(struct napi_struct *napi, int quota)
 		rps_unlock(queue);
 		local_irq_enable();
 
-		__netif_receive_skb(skb);
-	} while (++work < quota && jiffies == start_time);
+		while ((skb = __skb_dequeue(&queue->processing_queue))) {
+			__netif_receive_skb(skb);
+			if (++work < quota && jiffies == start_time)
+				continue;
+			if (!queue->flush_processing_queue)
+				goto out;
+			queue->flush_processing_queue = false;
+			while ((skb = __skb_dequeue(&queue->processing_queue))) {
+				__netif_receive_skb(skb);
+				++work;
+			}
+			goto out;
+		}
+	} while (1);
 
+out:
 	return work;
 }
 
@@ -5487,6 +5515,9 @@ static int dev_cpu_callback(struct notifier_block *nfb,
 	raise_softirq_irqoff(NET_TX_SOFTIRQ);
 	local_irq_enable();
 
+	while ((skb = __skb_dequeue(&oldsd->processing_queue)))
+		netif_rx(skb);
+
 	/* Process offline CPU's input_pkt_queue */
 	while ((skb = __skb_dequeue(&oldsd->input_pkt_queue)))
 		netif_rx(skb);
@@ -5709,6 +5740,8 @@ static int __init net_dev_init(void)
 
 		queue = &per_cpu(softnet_data, i);
 		skb_queue_head_init(&queue->input_pkt_queue);
+		skb_queue_head_init(&queue->processing_queue);
+		queue->flush_processing_queue = false;
 		queue->completion_queue = NULL;
 		INIT_LIST_HEAD(&queue->poll_list);
 
