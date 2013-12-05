From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: introduce dev_consume_skb_any()
Date: Thu, 05 Dec 2013 04:45:08 -0800
Message-ID: <1386247508.30495.180.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAJZOPZL9LxB5HdqS=+gQW-MjvW2NsZOt3NPB7v1iOFoEB7SsMQ@mail.gmail.com>
	 <1386105850.30495.38.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAJZOPZ+vnqLpdjS0TNdxDa4CNTzzfqp1=Ftjf86Fd5Lb+QdSzw@mail.gmail.com>
	 <20131203.165034.1085515763685633822.davem@davemloft.net>
	 <1386107714.30495.40.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAJZOPZ+bkvg4G6qzY6YmMui9-KmGmpHyFCJUD2xsFLOXm12rgA@mail.gmail.com>
	 <1386115199.30495.44.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:44954 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756536Ab3LEMpK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 07:45:10 -0500
Received: by mail-pd0-f175.google.com with SMTP id w10so24503574pde.20
        for <netdev@vger.kernel.org>; Thu, 05 Dec 2013 04:45:09 -0800 (PST)
In-Reply-To: <1386115199.30495.44.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Some network drivers use dev_kfree_skb_any() and dev_kfree_skb_irq()
helpers to free skbs, both for dropped packets and TX completed ones.

We need to separate the two causes to get better diagnostics
given by dropwatch or "perf record -e skb:kfree_skb"

This patch provides two new helpers, dev_consume_skb_any() and
dev_consume_skb_irq() to be used for consumed skbs.

__dev_kfree_skb_irq() is slightly optimized to remove one
atomic_dec_and_test() in fast path, and use this_cpu_{r|w} accessors.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/netdevice.h |   53 +++++++++++++++++++++++++++++-------
 net/core/dev.c            |   45 ++++++++++++++++++++----------
 2 files changed, 74 insertions(+), 24 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 7f0ed423a360..c6d64d20050c 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2368,17 +2368,52 @@ static inline int netif_copy_real_num_queues(struct net_device *to_dev,
 #define DEFAULT_MAX_NUM_RSS_QUEUES	(8)
 int netif_get_num_default_rss_queues(void);
 
-/* Use this variant when it is known for sure that it
- * is executing from hardware interrupt context or with hardware interrupts
- * disabled.
- */
-void dev_kfree_skb_irq(struct sk_buff *skb);
+enum skb_free_reason {
+	SKB_REASON_CONSUMED,
+	SKB_REASON_DROPPED,
+};
+
+void __dev_kfree_skb_irq(struct sk_buff *skb, enum skb_free_reason reason);
+void __dev_kfree_skb_any(struct sk_buff *skb, enum skb_free_reason reason);
 
-/* Use this variant in places where it could be invoked
- * from either hardware interrupt or other context, with hardware interrupts
- * either disabled or enabled.
+/*
+ * It is not allowed to call kfree_skb() or consume_skb() from hardware
+ * interrupt context or with hardware interrupts being disabled.
+ * (in_irq() || irqs_disabled())
+ *
+ * We provide four helpers that can be used in following contexts :
+ *
+ * dev_kfree_skb_irq(skb) when caller drops a packet from irq context,
+ *  replacing kfree_skb(skb)
+ *
+ * dev_consume_skb_irq(skb) when caller consumes a packet from irq context.
+ *  Typically used in place of consume_skb(skb) in TX completion path
+ *
+ * dev_kfree_skb_any(skb) when caller doesn't know its current irq context,
+ *  replacing kfree_skb(skb)
+ *
+ * dev_consume_skb_any(skb) when caller doesn't know its current irq context,
+ *  and consumed a packet. Used in place of consume_skb(skb)
  */
-void dev_kfree_skb_any(struct sk_buff *skb);
+static inline void dev_kfree_skb_irq(struct sk_buff *skb)
+{
+	__dev_kfree_skb_irq(skb, SKB_REASON_DROPPED);
+}
+
+static inline void dev_consume_skb_irq(struct sk_buff *skb)
+{
+	__dev_kfree_skb_irq(skb, SKB_REASON_CONSUMED);
+}
+
+static inline void dev_kfree_skb_any(struct sk_buff *skb)
+{
+	__dev_kfree_skb_any(skb, SKB_REASON_DROPPED);
+}
+
+static inline void dev_consume_skb_any(struct sk_buff *skb)
+{
+	__dev_kfree_skb_any(skb, SKB_REASON_CONSUMED);
+}
 
 int netif_rx(struct sk_buff *skb);
 int netif_rx_ni(struct sk_buff *skb);
diff --git a/net/core/dev.c b/net/core/dev.c
index ba3b7ea5ebb3..aa54a742f392 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2145,30 +2145,42 @@ void __netif_schedule(struct Qdisc *q)
 }
 EXPORT_SYMBOL(__netif_schedule);
 
-void dev_kfree_skb_irq(struct sk_buff *skb)
+struct dev_kfree_skb_cb {
+	enum skb_free_reason reason;
+};
+
+static struct dev_kfree_skb_cb *get_kfree_skb_cb(const struct sk_buff *skb)
+{
+	return (struct dev_kfree_skb_cb *)skb->cb;
+}
+
+void __dev_kfree_skb_irq(struct sk_buff *skb, enum skb_free_reason reason)
 {
-	if (atomic_dec_and_test(&skb->users)) {
-		struct softnet_data *sd;
-		unsigned long flags;
+	unsigned long flags;
 
-		local_irq_save(flags);
-		sd = &__get_cpu_var(softnet_data);
-		skb->next = sd->completion_queue;
-		sd->completion_queue = skb;
-		raise_softirq_irqoff(NET_TX_SOFTIRQ);
-		local_irq_restore(flags);
+	if (likely(atomic_read(&skb->users) == 1)) {
+		smp_rmb();
+		atomic_set(&skb->users, 0);
+	} else if (likely(!atomic_dec_and_test(&skb->users))) {
+		return;
 	}
+	get_kfree_skb_cb(skb)->reason = reason;
+	local_irq_save(flags);
+	skb->next = __this_cpu_read(softnet_data.completion_queue);
+	__this_cpu_write(softnet_data.completion_queue, skb);
+	raise_softirq_irqoff(NET_TX_SOFTIRQ);
+	local_irq_restore(flags);
 }
-EXPORT_SYMBOL(dev_kfree_skb_irq);
+EXPORT_SYMBOL(__dev_kfree_skb_irq);
 
-void dev_kfree_skb_any(struct sk_buff *skb)
+void __dev_kfree_skb_any(struct sk_buff *skb, enum skb_free_reason reason)
 {
 	if (in_irq() || irqs_disabled())
-		dev_kfree_skb_irq(skb);
+		__dev_kfree_skb_irq(skb, reason);
 	else
 		dev_kfree_skb(skb);
 }
-EXPORT_SYMBOL(dev_kfree_skb_any);
+EXPORT_SYMBOL(__dev_kfree_skb_any);
 
 
 /**
@@ -3306,7 +3318,10 @@ static void net_tx_action(struct softirq_action *h)
 			clist = clist->next;
 
 			WARN_ON(atomic_read(&skb->users));
-			trace_kfree_skb(skb, net_tx_action);
+			if (likely(get_kfree_skb_cb(skb)->reason == SKB_REASON_CONSUMED))
+				trace_consume_skb(skb);
+			else
+				trace_kfree_skb(skb, net_tx_action);
 			__kfree_skb(skb);
 		}
 	}
