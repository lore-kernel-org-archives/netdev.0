From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH v2] net: reimplement softnet_data.output_queue as a FIFO queue
Date: Tue, 27 Apr 2010 17:06:24 +0800
Message-ID: <1272359184-2929-1-git-send-email-xiaosuo@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:57718 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754024Ab0D0JYE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 05:24:04 -0400
Received: by pvg2 with SMTP id 2so1066718pvg.19
        for <netdev@vger.kernel.org>; Tue, 27 Apr 2010 02:24:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

reimplement softnet_data.output_queue as a FIFO queue.

reimplement softnet_data.output_queue as a FIFO queue to keep the fairness among
the qdiscs rescheduled.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 include/linux/netdevice.h |    1 +
 net/core/dev.c            |   22 ++++++++++++----------
 2 files changed, 13 insertions(+), 10 deletions(-)
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3c5ed5f..c04ca24 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1385,6 +1385,7 @@ static inline int unregister_gifconf(unsigned int family)
  */
 struct softnet_data {
 	struct Qdisc		*output_queue;
+	struct Qdisc		**output_queue_tailp;
 	struct list_head	poll_list;
 	struct sk_buff		*completion_queue;
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 4d43f1a..3d31491 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1557,8 +1557,9 @@ static inline void __netif_reschedule(struct Qdisc *q)
 
 	local_irq_save(flags);
 	sd = &__get_cpu_var(softnet_data);
-	q->next_sched = sd->output_queue;
-	sd->output_queue = q;
+	q->next_sched = NULL;
+	*sd->output_queue_tailp = q;
+	sd->output_queue_tailp = &q->next_sched;
 	raise_softirq_irqoff(NET_TX_SOFTIRQ);
 	local_irq_restore(flags);
 }
@@ -2529,6 +2530,7 @@ static void net_tx_action(struct softirq_action *h)
 		local_irq_disable();
 		head = sd->output_queue;
 		sd->output_queue = NULL;
+		sd->output_queue_tailp = &sd->output_queue;
 		local_irq_enable();
 
 		while (head) {
@@ -5594,7 +5596,6 @@ static int dev_cpu_callback(struct notifier_block *nfb,
 			    void *ocpu)
 {
 	struct sk_buff **list_skb;
-	struct Qdisc **list_net;
 	struct sk_buff *skb;
 	unsigned int cpu, oldcpu = (unsigned long)ocpu;
 	struct softnet_data *sd, *oldsd;
@@ -5615,13 +5616,13 @@ static int dev_cpu_callback(struct notifier_block *nfb,
 	*list_skb = oldsd->completion_queue;
 	oldsd->completion_queue = NULL;
 
-	/* Find end of our output_queue. */
-	list_net = &sd->output_queue;
-	while (*list_net)
-		list_net = &(*list_net)->next_sched;
 	/* Append output queue from offline CPU. */
-	*list_net = oldsd->output_queue;
-	oldsd->output_queue = NULL;
+	if (oldsd->output_queue) {
+		*sd->output_queue_tailp = oldsd->output_queue;
+		sd->output_queue_tailp = oldsd->output_queue_tailp;
+		oldsd->output_queue = NULL;
+		oldsd->output_queue_tailp = &oldsd->output_queue;
+	}
 
 	raise_softirq_irqoff(NET_TX_SOFTIRQ);
 	local_irq_enable();
@@ -5851,7 +5852,8 @@ static int __init net_dev_init(void)
 		skb_queue_head_init(&sd->input_pkt_queue);
 		sd->completion_queue = NULL;
 		INIT_LIST_HEAD(&sd->poll_list);
-
+		sd->output_queue = NULL;
+		sd->output_queue_tailp = &sd->output_queue;
 #ifdef CONFIG_RPS
 		sd->csd.func = rps_trigger_softirq;
 		sd->csd.info = sd;
