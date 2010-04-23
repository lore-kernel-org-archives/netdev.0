From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH v6] net: batch skb dequeueing from softnet input_pkt_queue
Date: Fri, 23 Apr 2010 16:12:58 +0800
Message-ID: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>
Cc: jamal <hadi@cyberus.ca>, Tom Herbert <therbert@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f194.google.com ([209.85.222.194]:46687 "EHLO
	mail-pz0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876Ab0DWIac (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 04:30:32 -0400
Received: by pzk32 with SMTP id 32so6141233pzk.21
        for <netdev@vger.kernel.org>; Fri, 23 Apr 2010 01:30:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

batch skb dequeueing from softnet input_pkt_queue.

batch skb dequeueing from softnet input_pkt_queue to reduce potential lock
contention when RPS is enabled.

Note: in the worst case, the number of packets in a softnet_data may be double
of netdev_max_backlog.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 include/linux/netdevice.h |    6 +++--
 net/core/dev.c            |   50 +++++++++++++++++++++++++++++++---------------
 2 files changed, 38 insertions(+), 18 deletions(-)
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3c5ed5f..6ae9f2b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1387,6 +1387,7 @@ struct softnet_data {
 	struct Qdisc		*output_queue;
 	struct list_head	poll_list;
 	struct sk_buff		*completion_queue;
+	struct sk_buff_head	process_queue;
 
 #ifdef CONFIG_RPS
 	struct softnet_data	*rps_ipi_list;
@@ -1401,10 +1402,11 @@ struct softnet_data {
 	struct napi_struct	backlog;
 };
 
-static inline void input_queue_head_incr(struct softnet_data *sd)
+static inline void input_queue_head_add(struct softnet_data *sd,
+					unsigned int len)
 {
 #ifdef CONFIG_RPS
-	sd->input_queue_head++;
+	sd->input_queue_head += len;
 #endif
 }
 
diff --git a/net/core/dev.c b/net/core/dev.c
index a4a7c36..c1585f9 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2409,12 +2409,13 @@ static int enqueue_to_backlog(struct sk_buff *skb, int cpu,
 	__get_cpu_var(netdev_rx_stat).total++;
 
 	rps_lock(sd);
-	if (sd->input_pkt_queue.qlen <= netdev_max_backlog) {
-		if (sd->input_pkt_queue.qlen) {
+	if (skb_queue_len(&sd->input_pkt_queue) <= netdev_max_backlog) {
+		if (skb_queue_len(&sd->input_pkt_queue)) {
 enqueue:
 			__skb_queue_tail(&sd->input_pkt_queue, skb);
 #ifdef CONFIG_RPS
-			*qtail = sd->input_queue_head + sd->input_pkt_queue.qlen;
+			*qtail = sd->input_queue_head +
+					skb_queue_len(&sd->input_pkt_queue);
 #endif
 			rps_unlock(sd);
 			local_irq_restore(flags);
@@ -2934,13 +2935,21 @@ static void flush_backlog(void *arg)
 	struct sk_buff *skb, *tmp;
 
 	rps_lock(sd);
-	skb_queue_walk_safe(&sd->input_pkt_queue, skb, tmp)
+	skb_queue_walk_safe(&sd->input_pkt_queue, skb, tmp) {
 		if (skb->dev == dev) {
 			__skb_unlink(skb, &sd->input_pkt_queue);
 			kfree_skb(skb);
-			input_queue_head_incr(sd);
+			input_queue_head_add(sd, 1);
 		}
+	}
 	rps_unlock(sd);
+
+	skb_queue_walk_safe(&sd->process_queue, skb, tmp) {
+		if (skb->dev == dev) {
+			__skb_unlink(skb, &sd->process_queue);
+			kfree_skb(skb);
+		}
+	}
 }
 
 static int napi_gro_complete(struct sk_buff *skb)
@@ -3286,24 +3295,30 @@ static int process_backlog(struct napi_struct *napi, int quota)
 	}
 #endif
 	napi->weight = weight_p;
-	do {
+	local_irq_disable();
+	while (1) {
 		struct sk_buff *skb;
 
-		local_irq_disable();
+		while ((skb = __skb_dequeue(&sd->process_queue))) {
+			local_irq_enable();
+			__netif_receive_skb(skb);
+			if (++work >= quota)
+				return work;
+			local_irq_disable();
+		}
+
 		rps_lock(sd);
-		skb = __skb_dequeue(&sd->input_pkt_queue);
-		if (!skb) {
+		input_queue_head_add(sd, skb_queue_len(&sd->input_pkt_queue));
+		skb_queue_splice_tail_init(&sd->input_pkt_queue,
+					   &sd->process_queue);
+		if (skb_queue_empty(&sd->process_queue)) {
 			__napi_complete(napi);
 			rps_unlock(sd);
-			local_irq_enable();
 			break;
 		}
-		input_queue_head_incr(sd);
 		rps_unlock(sd);
-		local_irq_enable();
-
-		__netif_receive_skb(skb);
-	} while (++work < quota);
+	}
+	local_irq_enable();
 
 	return work;
 }
@@ -5631,8 +5646,10 @@ static int dev_cpu_callback(struct notifier_block *nfb,
 	/* Process offline CPU's input_pkt_queue */
 	while ((skb = __skb_dequeue(&oldsd->input_pkt_queue))) {
 		netif_rx(skb);
-		input_queue_head_incr(oldsd);
+		input_queue_head_add(oldsd, 1);
 	}
+	while ((skb = __skb_dequeue(&oldsd->process_queue)))
+		netif_rx(skb);
 
 	return NOTIFY_OK;
 }
@@ -5851,6 +5868,7 @@ static int __init net_dev_init(void)
 		struct softnet_data *sd = &per_cpu(softnet_data, i);
 
 		skb_queue_head_init(&sd->input_pkt_queue);
+		skb_queue_head_init(&sd->process_queue);
 		sd->completion_queue = NULL;
 		INIT_LIST_HEAD(&sd->poll_list);
 
