From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH 2/2] net: reimplement softnet_data.output_queue as a FIFO queue
Date: Mon, 26 Apr 2010 11:26:01 +0800
Message-ID: <1272252361-11799-1-git-send-email-xiaosuo@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f196.google.com ([209.85.222.196]:44361 "EHLO
	mail-pz0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754293Ab0DZD0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Apr 2010 23:26:14 -0400
Received: by pzk34 with SMTP id 34so5220857pzk.33
        for <netdev@vger.kernel.org>; Sun, 25 Apr 2010 20:26:14 -0700 (PDT)
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
index 785e514..7984c15 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1385,6 +1385,7 @@ static inline int unregister_gifconf(unsigned int family)
  */
 struct softnet_data {
 	struct Qdisc		*output_queue;
+	struct Qdisc		**output_queue_tailp;
 	struct list_head	poll_list;
 	struct sk_buff_head	completion_queue;
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 5bbfa0f..b2b7869 100644
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
@@ -2526,6 +2527,7 @@ static void net_tx_action(struct softirq_action *h)
 		local_irq_disable();
 		head = sd->output_queue;
 		sd->output_queue = NULL;
+		sd->output_queue_tailp = &sd->output_queue;
 		local_irq_enable();
 
 		while (head) {
@@ -5590,7 +5592,6 @@ static int dev_cpu_callback(struct notifier_block *nfb,
 			    unsigned long action,
 			    void *ocpu)
 {
-	struct Qdisc **list_net;
 	struct sk_buff *skb;
 	unsigned int cpu, oldcpu = (unsigned long)ocpu;
 	struct softnet_data *sd, *oldsd;
@@ -5607,13 +5608,12 @@ static int dev_cpu_callback(struct notifier_block *nfb,
 	skb_queue_splice_tail_init(&oldsd->completion_queue,
 				   &sd->completion_queue);
 
-	/* Find end of our output_queue. */
-	list_net = &sd->output_queue;
-	while (*list_net)
-		list_net = &(*list_net)->next_sched;
-	/* Append output queue from offline CPU. */
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
@@ -5843,6 +5843,8 @@ static int __init net_dev_init(void)
 		skb_queue_head_init(&sd->input_pkt_queue);
 		__skb_queue_head_init(&sd->completion_queue);
 		INIT_LIST_HEAD(&sd->poll_list);
+		sd->output_queue = NULL;
+		sd->output_queue_tailp = &sd->output_queue;
 
 #ifdef CONFIG_RPS
 		sd->csd.func = rps_trigger_softirq;
