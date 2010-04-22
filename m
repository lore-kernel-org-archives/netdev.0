From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH v5] net: batch skb dequeueing from softnet input_pkt_queue
Date: Thu, 22 Apr 2010 17:09:17 +0800
Message-ID: <1271927357-2973-1-git-send-email-xiaosuo@gmail.com>
Cc: jamal <hadi@cyberus.ca>, Tom Herbert <therbert@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:35589 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752972Ab0DVJ0n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 05:26:43 -0400
Received: by pvh1 with SMTP id 1so201524pvh.19
        for <netdev@vger.kernel.org>; Thu, 22 Apr 2010 02:26:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

batch skb dequeueing from softnet input_pkt_queue

batch skb dequeueing from softnet input_pkt_queue to reduce potential lock
contention when RPS is enabled. input_pkt_queue is reimplemented as a single
linked list (FIFO) to keep enqueueing and dequeueing as fast as posible, and
input_pkt_queue_lock is moved into RPS section to reduce 4 bytes on 32bits
machine.

Note: input_pkt_queue_len doesn't been decreased until process_backlog()
returns.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 include/linux/netdevice.h |   12 ++++-
 net/core/dev.c            |   99 +++++++++++++++++++++++++++++++++-------------
 2 files changed, 82 insertions(+), 29 deletions(-)
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3c5ed5f..58abdd5 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1387,6 +1387,7 @@ struct softnet_data {
 	struct Qdisc		*output_queue;
 	struct list_head	poll_list;
 	struct sk_buff		*completion_queue;
+	struct sk_buff		*process_queue;
 
 #ifdef CONFIG_RPS
 	struct softnet_data	*rps_ipi_list;
@@ -1396,15 +1397,20 @@ struct softnet_data {
 	struct softnet_data	*rps_ipi_next;
 	unsigned int		cpu;
 	unsigned int		input_queue_head;
+	spinlock_t		input_pkt_queue_lock;
 #endif
-	struct sk_buff_head	input_pkt_queue;
+	unsigned int		input_pkt_queue_len;
+	struct sk_buff		*input_pkt_queue_head;
+	struct sk_buff		**input_pkt_queue_tailp;
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
index e904c47..f37c223 100644
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
 
@@ -2409,12 +2409,15 @@ static int enqueue_to_backlog(struct sk_buff *skb, int cpu,
 	__get_cpu_var(netdev_rx_stat).total++;
 
 	rps_lock(sd);
-	if (sd->input_pkt_queue.qlen <= netdev_max_backlog) {
-		if (sd->input_pkt_queue.qlen) {
+	if (sd->input_pkt_queue_len <= netdev_max_backlog) {
+		if (sd->input_pkt_queue_len) {
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
@@ -2927,19 +2930,37 @@ EXPORT_SYMBOL(netif_receive_skb);
 /* Network device is going away, flush any packets still pending
  * Called with irqs disabled.
  */
-static void flush_backlog(void *arg)
+
+static struct sk_buff **__flush_backlog(struct softnet_data *sd,
+					struct sk_buff **pskb,
+					struct net_device *dev)
 {
-	struct net_device *dev = arg;
-	struct softnet_data *sd = &__get_cpu_var(softnet_data);
-	struct sk_buff *skb, *tmp;
+	struct sk_buff *skb;
 
-	rps_lock(sd);
-	skb_queue_walk_safe(&sd->input_pkt_queue, skb, tmp)
+	while (*pskb) {
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
+
+	return pskb;
+}
+
+static void flush_backlog(void *arg)
+{
+	struct softnet_data *sd = &__get_cpu_var(softnet_data);
+	struct sk_buff **tailp;
+
+	rps_lock(sd);
+	tailp = __flush_backlog(sd, &sd->input_pkt_queue_head, arg);
+	sd->input_pkt_queue_tailp = tailp;
+	__flush_backlog(sd, &sd->process_queue, arg);
 	rps_unlock(sd);
 }
 
@@ -3249,24 +3270,39 @@ static int process_backlog(struct napi_struct *napi, int quota)
 	struct softnet_data *sd = &__get_cpu_var(softnet_data);
 
 	napi->weight = weight_p;
+	local_irq_disable();
 	do {
 		struct sk_buff *skb;
 
-		local_irq_disable();
+		while (sd->process_queue) {
+			skb = sd->process_queue;
+			sd->process_queue = skb->next;
+			local_irq_enable();
+			__netif_receive_skb(skb);
+			if (++work >= quota) {
+				local_irq_disable();
+				rps_lock(sd);
+				goto out;
+			}
+			local_irq_disable();
+		}
+
 		rps_lock(sd);
-		skb = __skb_dequeue(&sd->input_pkt_queue);
-		if (!skb) {
+		if (sd->input_pkt_queue_head == NULL) {
 			__napi_complete(napi);
-			rps_unlock(sd);
-			local_irq_enable();
 			break;
 		}
-		input_queue_head_incr(sd);
+		sd->process_queue = sd->input_pkt_queue_head;
+		sd->input_pkt_queue_head = NULL;
+		sd->input_pkt_queue_tailp = &sd->input_pkt_queue_head;
 		rps_unlock(sd);
-		local_irq_enable();
+	} while (1);
 
-		__netif_receive_skb(skb);
-	} while (++work < quota);
+out:
+	sd->input_pkt_queue_len -= work;
+	input_queue_head_add(sd, work);
+	rps_unlock(sd);
+	local_irq_enable();
 
 	return work;
 }
@@ -5621,10 +5657,17 @@ static int dev_cpu_callback(struct notifier_block *nfb,
 	local_irq_enable();
 
 	/* Process offline CPU's input_pkt_queue */
-	while ((skb = __skb_dequeue(&oldsd->input_pkt_queue))) {
+	while ((skb = oldsd->input_pkt_queue_head)) {
+		oldsd->input_pkt_queue_head = skb->next;
+		netif_rx(skb);
+	}
+	while ((skb = oldsd->process_queue)) {
+		oldsd->process_queue = skb->next;
 		netif_rx(skb);
-		input_queue_head_incr(oldsd);
 	}
+	oldsd->input_pkt_queue_tailp = &oldsd->input_pkt_queue_head;
+	input_queue_head_add(oldsd, oldsd->input_pkt_queue_len);
+	oldsd->input_pkt_queue_len = 0;
 
 	return NOTIFY_OK;
 }
@@ -5842,11 +5885,15 @@ static int __init net_dev_init(void)
 	for_each_possible_cpu(i) {
 		struct softnet_data *sd = &per_cpu(softnet_data, i);
 
-		skb_queue_head_init(&sd->input_pkt_queue);
+		sd->input_pkt_queue_head = NULL;
+		sd->input_pkt_queue_tailp = &sd->input_pkt_queue_head;
+		sd->input_pkt_queue_len = 0;
+		sd->process_queue = NULL;
 		sd->completion_queue = NULL;
 		INIT_LIST_HEAD(&sd->poll_list);
 
 #ifdef CONFIG_RPS
+		spin_lock_init(&sd->input_pkt_queue_lock);
 		sd->csd.func = rps_trigger_softirq;
 		sd->csd.info = sd;
 		sd->csd.flags = 0;
