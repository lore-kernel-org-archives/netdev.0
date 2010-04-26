From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH 1/2] net: reimplement completion_queue as a FIFO queue
Date: Mon, 26 Apr 2010 11:20:16 +0800
Message-ID: <1272252016-11755-1-git-send-email-xiaosuo@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:34349 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754430Ab0DZDUj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Apr 2010 23:20:39 -0400
Received: by pwj9 with SMTP id 9so7999210pwj.19
        for <netdev@vger.kernel.org>; Sun, 25 Apr 2010 20:20:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

reimplement completion_queue as a FIFO queue.

As slab allocator always does its best to return the latest unused objects, we'd
better release skb in order, this patch reimplement completion_queue as a FIFO
queue instead of the old LIFO queue.

At the same time, a opencoding skb queue is replaced with a sk_buff_head queue.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 include/linux/netdevice.h |    2 +-
 net/core/dev.c            |   28 ++++++++++------------------
 net/core/netpoll.c        |   12 +++++-------
 3 files changed, 16 insertions(+), 26 deletions(-)
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3c5ed5f..785e514 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1386,7 +1386,7 @@ static inline int unregister_gifconf(unsigned int family)
 struct softnet_data {
 	struct Qdisc		*output_queue;
 	struct list_head	poll_list;
-	struct sk_buff		*completion_queue;
+	struct sk_buff_head	completion_queue;
 
 #ifdef CONFIG_RPS
 	struct softnet_data	*rps_ipi_list;
diff --git a/net/core/dev.c b/net/core/dev.c
index 4d43f1a..5bbfa0f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1578,8 +1578,7 @@ void dev_kfree_skb_irq(struct sk_buff *skb)
 
 		local_irq_save(flags);
 		sd = &__get_cpu_var(softnet_data);
-		skb->next = sd->completion_queue;
-		sd->completion_queue = skb;
+		__skb_queue_tail(&sd->completion_queue, skb);
 		raise_softirq_irqoff(NET_TX_SOFTIRQ);
 		local_irq_restore(flags);
 	}
@@ -2506,18 +2505,16 @@ static void net_tx_action(struct softirq_action *h)
 {
 	struct softnet_data *sd = &__get_cpu_var(softnet_data);
 
-	if (sd->completion_queue) {
-		struct sk_buff *clist;
+	if (!skb_queue_empty(&sd->completion_queue)) {
+		struct sk_buff_head queue;
+		struct sk_buff *skb;
 
+		__skb_queue_head_init(&queue);
 		local_irq_disable();
-		clist = sd->completion_queue;
-		sd->completion_queue = NULL;
+		skb_queue_splice_tail_init(&sd->completion_queue, &queue);
 		local_irq_enable();
 
-		while (clist) {
-			struct sk_buff *skb = clist;
-			clist = clist->next;
-
+		while ((skb = __skb_dequeue(&queue))) {
 			WARN_ON(atomic_read(&skb->users));
 			__kfree_skb(skb);
 		}
@@ -5593,7 +5590,6 @@ static int dev_cpu_callback(struct notifier_block *nfb,
 			    unsigned long action,
 			    void *ocpu)
 {
-	struct sk_buff **list_skb;
 	struct Qdisc **list_net;
 	struct sk_buff *skb;
 	unsigned int cpu, oldcpu = (unsigned long)ocpu;
@@ -5607,13 +5603,9 @@ static int dev_cpu_callback(struct notifier_block *nfb,
 	sd = &per_cpu(softnet_data, cpu);
 	oldsd = &per_cpu(softnet_data, oldcpu);
 
-	/* Find end of our completion_queue. */
-	list_skb = &sd->completion_queue;
-	while (*list_skb)
-		list_skb = &(*list_skb)->next;
 	/* Append completion queue from offline CPU. */
-	*list_skb = oldsd->completion_queue;
-	oldsd->completion_queue = NULL;
+	skb_queue_splice_tail_init(&oldsd->completion_queue,
+				   &sd->completion_queue);
 
 	/* Find end of our output_queue. */
 	list_net = &sd->output_queue;
@@ -5849,7 +5841,7 @@ static int __init net_dev_init(void)
 		struct softnet_data *sd = &per_cpu(softnet_data, i);
 
 		skb_queue_head_init(&sd->input_pkt_queue);
-		sd->completion_queue = NULL;
+		__skb_queue_head_init(&sd->completion_queue);
 		INIT_LIST_HEAD(&sd->poll_list);
 
 #ifdef CONFIG_RPS
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index a58f59b..3905a14 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -222,17 +222,15 @@ static void zap_completion_queue(void)
 	unsigned long flags;
 	struct softnet_data *sd = &get_cpu_var(softnet_data);
 
-	if (sd->completion_queue) {
-		struct sk_buff *clist;
+	if (!skb_queue_empty(&sd->completion_queue)) {
+		struct sk_buff_head queue;
+		struct sk_buff *skb;
 
 		local_irq_save(flags);
-		clist = sd->completion_queue;
-		sd->completion_queue = NULL;
+		skb_queue_splice_tail_init(&sd->completion_queue, &queue);
 		local_irq_restore(flags);
 
-		while (clist != NULL) {
-			struct sk_buff *skb = clist;
-			clist = clist->next;
+		while ((skb = __skb_dequeue(&queue))) {
 			if (skb->destructor) {
 				atomic_inc(&skb->users);
 				dev_kfree_skb_any(skb); /* put this one back */
