From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH v4] net: batch skb dequeueing from softnet input_pkt_queue
Date: Thu, 22 Apr 2010 13:51:53 +0800
Message-ID: <1271915513-2966-1-git-send-email-xiaosuo@gmail.com>
Cc: jamal <hadi@cyberus.ca>, Tom Herbert <therbert@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f194.google.com ([209.85.222.194]:45440 "EHLO
	mail-pz0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752570Ab0DVFwU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 01:52:20 -0400
Received: by pzk32 with SMTP id 32so5149477pzk.21
        for <netdev@vger.kernel.org>; Wed, 21 Apr 2010 22:52:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

batch skb dequeueing from softnet input_pkt_queue

batch skb dequeueing from softnet input_pkt_queue to reduce potential lock
contention when RPS is enabled. input_pkt_queue is reimplemented as a single
linked list(FIFO), and input_pkt_queue_lock is moved into RPS section, so
softnet becomes smaller when RPS is disabled than before.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 include/linux/netdevice.h |   14 +++++--
 net/core/dev.c            |   92 +++++++++++++++++++++++++++++++++++-----------
 2 files changed, 82 insertions(+), 24 deletions(-)
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3c5ed5f..5ccb92b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1387,6 +1387,7 @@ struct softnet_data {
 	struct Qdisc		*output_queue;
 	struct list_head	poll_list;
 	struct sk_buff		*completion_queue;
+	struct sk_buff		*process_queue;
 
 #ifdef CONFIG_RPS
 	struct softnet_data	*rps_ipi_list;
@@ -1396,15 +1397,22 @@ struct softnet_data {
 	struct softnet_data	*rps_ipi_next;
 	unsigned int		cpu;
 	unsigned int		input_queue_head;
+	spinlock_t		input_pkt_queue_lock;
+	/* 4 bytes hole on 64bits machine */
 #endif
-	struct sk_buff_head	input_pkt_queue;
+	struct sk_buff		*input_pkt_queue_head;
+	struct sk_buff		**input_pkt_queue_tailp;
+	unsigned int		input_pkt_queue_len;
+	unsigned int		process_queue_len;
+
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
index e904c47..81c7877 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -211,14 +211,14 @@ static inline struct hlist_head *dev_index_hash(struct net *net, int ifindex)
 static inline void rps_lock(struct softnet_data *sd)
 {
 #ifdef CONFIG_RPS
-	spin_lock(&sd->input_pkt_queue.lock);
+	spin_lock(&sd->input_pkt_queue_lock);
 #endif
 }
 
 static inline void rps_unlock(struct softnet_data *sd)
 {
 #ifdef CONFIG_RPS
-	spin_unlock(&sd->input_pkt_queue.lock);
+	spin_unlock(&sd->input_pkt_queue_lock);
 #endif
 }
 
@@ -2402,6 +2402,7 @@ static int enqueue_to_backlog(struct sk_buff *skb, int cpu,
 {
 	struct softnet_data *sd;
 	unsigned long flags;
+	unsigned int qlen;
 
 	sd = &per_cpu(softnet_data, cpu);
 
@@ -2409,12 +2410,16 @@ static int enqueue_to_backlog(struct sk_buff *skb, int cpu,
 	__get_cpu_var(netdev_rx_stat).total++;
 
 	rps_lock(sd);
-	if (sd->input_pkt_queue.qlen <= netdev_max_backlog) {
-		if (sd->input_pkt_queue.qlen) {
+	qlen = sd->input_pkt_queue_len + sd->process_queue_len;
+	if (qlen <= netdev_max_backlog) {
+		if (qlen) {
 enqueue:
-			__skb_queue_tail(&sd->input_pkt_queue, skb);
+			skb->next = NULL;
+			*sd->input_pkt_queue_tailp = skb;
+			sd->input_pkt_queue_tailp = &skb->next;
+			sd->input_pkt_queue_len++;
 #ifdef CONFIG_RPS
-			*qtail = sd->input_queue_head + sd->input_pkt_queue.qlen;
+			*qtail = sd->input_queue_head + sd->input_pkt_queue_len;
 #endif
 			rps_unlock(sd);
 			local_irq_restore(flags);
@@ -2931,16 +2936,33 @@ static void flush_backlog(void *arg)
 {
 	struct net_device *dev = arg;
 	struct softnet_data *sd = &__get_cpu_var(softnet_data);
-	struct sk_buff *skb, *tmp;
+	struct sk_buff **pskb, *skb;
 
 	rps_lock(sd);
-	skb_queue_walk_safe(&sd->input_pkt_queue, skb, tmp)
+	for (pskb = &sd->input_pkt_queue_head; *pskb; ) {
+		skb = *pskb;
 		if (skb->dev == dev) {
-			__skb_unlink(skb, &sd->input_pkt_queue);
+			*pskb = skb->next;
 			kfree_skb(skb);
-			input_queue_head_incr(sd);
+			input_queue_head_add(sd, 1);
+			sd->input_pkt_queue_len--;
+		} else {
+			pskb = &skb->next;
 		}
+	}
+	sd->input_pkt_queue_tailp = pskb;
 	rps_unlock(sd);
+
+	for (pskb = &sd->process_queue; *pskb; ) {
+		skb = *pskb;
+		if (skb->dev == dev) {
+			*pskb = skb->next;
+			kfree_skb(skb);
+			sd->process_queue_len--;
+		} else {
+			pskb = &skb->next;
+		}
+	}
 }
 
 static int napi_gro_complete(struct sk_buff *skb)
@@ -3249,25 +3271,39 @@ static int process_backlog(struct napi_struct *napi, int quota)
 	struct softnet_data *sd = &__get_cpu_var(softnet_data);
 
 	napi->weight = weight_p;
+	local_irq_disable();
 	do {
 		struct sk_buff *skb;
 
-		local_irq_disable();
+		while (sd->process_queue) {
+			skb = sd->process_queue;
+			sd->process_queue = skb->next;
+			sd->process_queue_len--;
+			local_irq_enable();
+			__netif_receive_skb(skb);
+			if (++work >= quota)
+				goto out;
+			local_irq_disable();
+		}
+
 		rps_lock(sd);
-		skb = __skb_dequeue(&sd->input_pkt_queue);
-		if (!skb) {
+		if (sd->input_pkt_queue_head == NULL) {
 			__napi_complete(napi);
 			rps_unlock(sd);
 			local_irq_enable();
 			break;
 		}
-		input_queue_head_incr(sd);
-		rps_unlock(sd);
-		local_irq_enable();
 
-		__netif_receive_skb(skb);
-	} while (++work < quota);
+		sd->process_queue = sd->input_pkt_queue_head;
+		sd->process_queue_len = sd->input_pkt_queue_len;
+		input_queue_head_add(sd, sd->input_pkt_queue_len);
+		sd->input_pkt_queue_head = NULL;
+		sd->input_pkt_queue_tailp = &sd->input_pkt_queue_head;
+		sd->input_pkt_queue_len = 0;
+		rps_unlock(sd);
+	} while (1);
 
+out:
 	return work;
 }
 
@@ -5621,10 +5657,19 @@ static int dev_cpu_callback(struct notifier_block *nfb,
 	local_irq_enable();
 
 	/* Process offline CPU's input_pkt_queue */
-	while ((skb = __skb_dequeue(&oldsd->input_pkt_queue))) {
+	while ((skb = oldsd->input_pkt_queue_head)) {
+		oldsd->input_pkt_queue_head = skb->next;
+		netif_rx(skb);
+	}
+	oldsd->input_pkt_queue_tailp = &oldsd->input_pkt_queue_head;
+	input_queue_head_add(oldsd, oldsd->input_pkt_queue_len);
+	oldsd->input_pkt_queue_len = 0;
+
+	while ((skb = oldsd->process_queue)) {
+		oldsd->process_queue = skb->next;
 		netif_rx(skb);
-		input_queue_head_incr(oldsd);
 	}
+	oldsd->process_queue_len = 0;
 
 	return NOTIFY_OK;
 }
@@ -5842,11 +5887,16 @@ static int __init net_dev_init(void)
 	for_each_possible_cpu(i) {
 		struct softnet_data *sd = &per_cpu(softnet_data, i);
 
-		skb_queue_head_init(&sd->input_pkt_queue);
+		sd->input_pkt_queue_head = NULL;
+		sd->input_pkt_queue_tailp = &sd->input_pkt_queue_head;
+		sd->input_pkt_queue_len = 0;
+		sd->process_queue = NULL;
+		sd->process_queue_len = 0;
 		sd->completion_queue = NULL;
 		INIT_LIST_HEAD(&sd->poll_list);
 
 #ifdef CONFIG_RPS
+		spin_lock_init(&sd->input_pkt_queue_lock);
 		sd->csd.func = rps_trigger_softirq;
 		sd->csd.info = sd;
 		sd->csd.flags = 0;
