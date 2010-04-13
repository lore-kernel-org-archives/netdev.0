From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] net: batch skb dequeueing from softnet input_pkt_queue
Date: Tue, 13 Apr 2010 18:41:08 +0800
Message-ID: <1271155268-2999-1-git-send-email-xiaosuo@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f201.google.com ([209.85.221.201]:41887 "EHLO
	mail-qy0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754733Ab0DMCrS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Apr 2010 22:47:18 -0400
Received: by qyk39 with SMTP id 39so5681072qyk.24
        for <netdev@vger.kernel.org>; Mon, 12 Apr 2010 19:47:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

batch skb dequeueing from softnet input_pkt_queue

batch skb dequeueing from softnet input_pkt_queue to reduce potential lock
contention and irq disabling/enabling.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 include/linux/netdevice.h |    1 +
 net/core/dev.c            |   36 +++++++++++++++++++++++++++---------
 2 files changed, 28 insertions(+), 9 deletions(-)
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d1a21b5..f3f8cca 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1336,6 +1336,7 @@ struct softnet_data {
 #endif
 	struct sk_buff_head	input_pkt_queue;
 	struct napi_struct	backlog;
+	atomic_t		input_qlen;
 };
 
 DECLARE_PER_CPU_ALIGNED(struct softnet_data, softnet_data);
diff --git a/net/core/dev.c b/net/core/dev.c
index a10a216..8816204 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2339,10 +2339,11 @@ static int enqueue_to_backlog(struct sk_buff *skb, int cpu)
 	__get_cpu_var(netdev_rx_stat).total++;
 
 	rps_lock(queue);
-	if (queue->input_pkt_queue.qlen <= netdev_max_backlog) {
-		if (queue->input_pkt_queue.qlen) {
+	if (atomic_read(&queue->input_qlen) <= netdev_max_backlog) {
+		if (atomic_read(&queue->input_qlen)) {
 enqueue:
 			__skb_queue_tail(&queue->input_pkt_queue, skb);
+			atomic_inc(&queue->input_qlen);
 			rps_unlock(queue);
 			local_irq_restore(flags);
 			return NET_RX_SUCCESS;
@@ -2801,6 +2802,7 @@ static void flush_backlog(void *arg)
 	skb_queue_walk_safe(&queue->input_pkt_queue, skb, tmp)
 		if (skb->dev == dev) {
 			__skb_unlink(skb, &queue->input_pkt_queue);
+			atomic_dec(&queue->input_qlen);
 			kfree_skb(skb);
 		}
 	rps_unlock(queue);
@@ -3111,25 +3113,38 @@ static int process_backlog(struct napi_struct *napi, int quota)
 	int work = 0;
 	struct softnet_data *queue = &__get_cpu_var(softnet_data);
 	unsigned long start_time = jiffies;
+	struct sk_buff_head skb_queue;
 
+	__skb_queue_head_init(&skb_queue);
 	napi->weight = weight_p;
 	do {
 		struct sk_buff *skb;
 
 		local_irq_disable();
 		rps_lock(queue);
-		skb = __skb_dequeue(&queue->input_pkt_queue);
-		if (!skb) {
+		skb_queue_splice_tail_init(&queue->input_pkt_queue, &skb_queue);
+		if (skb_queue_empty(&skb_queue)) {
 			__napi_complete(napi);
-			rps_unlock(queue);
-			local_irq_enable();
 			break;
 		}
 		rps_unlock(queue);
 		local_irq_enable();
 
-		__netif_receive_skb(skb);
-	} while (++work < quota && jiffies == start_time);
+		while ((skb = __skb_dequeue(&skb_queue))) {
+			atomic_dec(&queue->input_qlen);
+			__netif_receive_skb(skb);
+			if (++work < quota && jiffies == start_time)
+				continue;
+			local_irq_disable();
+			rps_lock(queue);
+			skb_queue_splice(&skb_queue, &queue->input_pkt_queue);
+			goto out;
+		}
+	} while (1);
+
+out:
+	rps_unlock(queue);
+	local_irq_enable();
 
 	return work;
 }
@@ -5488,8 +5503,10 @@ static int dev_cpu_callback(struct notifier_block *nfb,
 	local_irq_enable();
 
 	/* Process offline CPU's input_pkt_queue */
-	while ((skb = __skb_dequeue(&oldsd->input_pkt_queue)))
+	while ((skb = __skb_dequeue(&oldsd->input_pkt_queue))) {
+		atomic_dec(&oldsd->input_qlen);
 		netif_rx(skb);
+	}
 
 	return NOTIFY_OK;
 }
@@ -5709,6 +5726,7 @@ static int __init net_dev_init(void)
 
 		queue = &per_cpu(softnet_data, i);
 		skb_queue_head_init(&queue->input_pkt_queue);
+		atomic_set(&queue->input_qlen, 0);
 		queue->completion_queue = NULL;
 		INIT_LIST_HEAD(&queue->poll_list);
 
