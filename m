From: Tom Herbert <therbert@google.com>
Subject: [PATCH] net: fix problem in dequeuing from input_pkt_queue
Date: Wed, 19 May 2010 14:47:37 -0700 (PDT)
Message-ID: <alpine.DEB.1.00.1005191440440.23271@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: eric.dumazet@gmail.com, xiaosuo@gmail.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:48845 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751085Ab0ESVrs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 May 2010 17:47:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix some issues introduced in batch skb dequeuing for input_pkt_queue.
The primary issue it that the queue head must be incremented only
after a packet has been processed, that is only after
__netif_receive_skb has been called.  This is needed for the mechanism
to prevent OOO packet in RFS.  Also when flushing the input_pkt_queue
and process_queue, the process queue should be done first to prevent
OOO packets.

Because the input_pkt_queue has been effectively split into two queues,
the calculation of the tail ptr is no longer correct.  The correct value
would be head+input_pkt_queue->len+process_queue->len.  To avoid
this calculation we added an explict input_queue_tail in softnet_data.
The tail value is simply incremented when queuing to input_pkt_queue.

In process_backlog the processing of the packet queue can be done
without irq's being disabled.

Made dropped in softnet_data to be "unsigned int" for consistency.

Signed-off-by: Tom Herbert <therbert@google.com>
---
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c3487a6..bc0bc85 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1403,17 +1403,25 @@ struct softnet_data {
 	struct softnet_data	*rps_ipi_next;
 	unsigned int		cpu;
 	unsigned int		input_queue_head;
+	unsigned int		input_queue_tail;
 #endif
-	unsigned		dropped;
+	unsigned int		dropped;
 	struct sk_buff_head	input_pkt_queue;
 	struct napi_struct	backlog;
 };
 
-static inline void input_queue_head_add(struct softnet_data *sd,
-					unsigned int len)
+static inline void input_queue_head_incr(struct softnet_data *sd)
 {
 #ifdef CONFIG_RPS
-	sd->input_queue_head += len;
+	sd->input_queue_head++;
+#endif
+}
+
+static inline void input_queue_tail_incr_save(struct softnet_data *sd,
+					      unsigned int *qtail)
+{
+#ifdef CONFIG_RPS
+	*qtail = ++sd->input_queue_tail;
 #endif
 }
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 6c82065..be7d475 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2426,10 +2426,7 @@ static int enqueue_to_backlog(struct sk_buff *skb, int cpu,
 		if (skb_queue_len(&sd->input_pkt_queue)) {
 enqueue:
 			__skb_queue_tail(&sd->input_pkt_queue, skb);
-#ifdef CONFIG_RPS
-			*qtail = sd->input_queue_head +
-					skb_queue_len(&sd->input_pkt_queue);
-#endif
+			input_queue_tail_incr_save(sd, qtail);
 			rps_unlock(sd);
 			local_irq_restore(flags);
 			return NET_RX_SUCCESS;
@@ -2959,22 +2956,24 @@ static void flush_backlog(void *arg)
 	struct softnet_data *sd = &__get_cpu_var(softnet_data);
 	struct sk_buff *skb, *tmp;
 
-	rps_lock(sd);
-	skb_queue_walk_safe(&sd->input_pkt_queue, skb, tmp) {
+	skb_queue_walk_safe(&sd->process_queue, skb, tmp) {
 		if (skb->dev == dev) {
-			__skb_unlink(skb, &sd->input_pkt_queue);
+			__skb_unlink(skb, &sd->process_queue);
 			kfree_skb(skb);
-			input_queue_head_add(sd, 1);
+			input_queue_head_incr(sd);
 		}
 	}
-	rps_unlock(sd);
 
-	skb_queue_walk_safe(&sd->process_queue, skb, tmp) {
+	rps_lock(sd);
+	skb_queue_walk_safe(&sd->input_pkt_queue, skb, tmp) {
 		if (skb->dev == dev) {
-			__skb_unlink(skb, &sd->process_queue);
+			__skb_unlink(skb, &sd->input_pkt_queue);
 			kfree_skb(skb);
+			input_queue_head_incr(sd);
 		}
 	}
+	rps_unlock(sd);
+
 }
 
 static int napi_gro_complete(struct sk_buff *skb)
@@ -3320,26 +3319,24 @@ static int process_backlog(struct napi_struct *napi, int quota)
 	}
 #endif
 	napi->weight = weight_p;
-	local_irq_disable();
 	while (work < quota) {
 		struct sk_buff *skb;
 		unsigned int qlen;
 
 		while ((skb = __skb_dequeue(&sd->process_queue))) {
-			local_irq_enable();
 			__netif_receive_skb(skb);
+			input_queue_head_incr(sd);
 			if (++work >= quota)
 				return work;
-			local_irq_disable();
 		}
 
+		local_irq_disable();
 		rps_lock(sd);
 		qlen = skb_queue_len(&sd->input_pkt_queue);
-		if (qlen) {
-			input_queue_head_add(sd, qlen);
+		if (qlen)
 			skb_queue_splice_tail_init(&sd->input_pkt_queue,
 						   &sd->process_queue);
-		}
+
 		if (qlen < quota - work) {
 			/*
 			 * Inline a custom version of __napi_complete().
@@ -3354,8 +3351,8 @@ static int process_backlog(struct napi_struct *napi, int quota)
 			quota = work + qlen;
 		}
 		rps_unlock(sd);
+		local_irq_enable();
 	}
-	local_irq_enable();
 
 	return work;
 }
@@ -5679,12 +5676,14 @@ static int dev_cpu_callback(struct notifier_block *nfb,
 	local_irq_enable();
 
 	/* Process offline CPU's input_pkt_queue */
-	while ((skb = __skb_dequeue(&oldsd->input_pkt_queue))) {
+	while ((skb = __skb_dequeue(&oldsd->process_queue))) {
 		netif_rx(skb);
-		input_queue_head_add(oldsd, 1);
+		input_queue_head_incr(oldsd);
 	}
-	while ((skb = __skb_dequeue(&oldsd->process_queue)))
+	while ((skb = __skb_dequeue(&oldsd->input_pkt_queue))) {
 		netif_rx(skb);
+		input_queue_head_incr(oldsd);
+	}
 
 	return NOTIFY_OK;
 }
