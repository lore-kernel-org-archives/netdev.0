From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: Xmit Packet Steering (XPS)
Date: Fri, 20 Nov 2009 00:46:36 +0100
Message-ID: <4B05D8DC.7020907@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:32941 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757873AbZKSXqj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 18:46:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is first version of XPS.

Goal of XPS is to free TX completed skbs by the cpu that submitted the transmit.

Because I chose to union skb->iif with skb->sending_cpu, I chose
to introduce a new xps_consume_skb(skb), and not generalize consume_skb() itself.

This means that selected drivers must use new function to benefit from XPS

Preliminary tests are quite good, especially on NUMA machines.

Only NAPI drivers can use this new infrastructure (xps_consume_skb() cannot
be called from hardirq context, only from softirq)

I converted tg3 and pktgen for my tests

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/tg3.c      |    2
 include/linux/skbuff.h |   14 +++
 net/core/Makefile      |    1
 net/core/dev.c         |    8 +-
 net/core/pktgen.c      |    1
 net/core/xps.c         |  145 +++++++++++++++++++++++++++++++++++++++
 6 files changed, 165 insertions(+), 6 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 6e6db95..bc756e6 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4379,7 +4379,7 @@ static void tg3_tx(struct tg3_napi *tnapi)
 			sw_idx = NEXT_TX(sw_idx);
 		}
 
-		dev_kfree_skb(skb);
+		xps_consume_skb(skb);
 
 		if (unlikely(tx_bug)) {
 			tg3_tx_recover(tp);
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 63f4742..e8e4795 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -366,7 +366,10 @@ struct sk_buff {
 	struct nf_bridge_info	*nf_bridge;
 #endif
 
-	int			iif;
+	union {
+		int		iif;
+		int		sending_cpu;
+	};
 #ifdef CONFIG_NET_SCHED
 	__u16			tc_index;	/* traffic control index */
 #ifdef CONFIG_NET_CLS_ACT
@@ -441,6 +444,15 @@ static inline struct rtable *skb_rtable(const struct sk_buff *skb)
 
 extern void kfree_skb(struct sk_buff *skb);
 extern void consume_skb(struct sk_buff *skb);
+#if defined(CONFIG_SMP)
+extern void xps_consume_skb(struct sk_buff *skb);
+extern void xps_flush(void);
+extern void xps_init(void);
+#else
+#define xps_consume_skb(skb) consume_skb(skb)
+static inline void xps_flush(void) {}
+static inline void xps_init(void) {}
+#endif
 extern void	       __kfree_skb(struct sk_buff *skb);
 extern struct sk_buff *__alloc_skb(unsigned int size,
 				   gfp_t priority, int fclone, int node);
diff --git a/net/core/Makefile b/net/core/Makefile
index 796f46e..eacd3d8 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -19,4 +19,5 @@ obj-$(CONFIG_NET_DMA) += user_dma.o
 obj-$(CONFIG_FIB_RULES) += fib_rules.o
 obj-$(CONFIG_TRACEPOINTS) += net-traces.o
 obj-$(CONFIG_NET_DROP_MONITOR) += drop_monitor.o
+obj-$(CONFIG_SMP) += xps.o
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 9977288..9e134f6 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1965,6 +1965,7 @@ int dev_queue_xmit(struct sk_buff *skb)
 	struct netdev_queue *txq;
 	struct Qdisc *q;
 	int rc = -ENOMEM;
+	int cpu;
 
 	/* GSO will handle the following emulations directly. */
 	if (netif_needs_gso(dev, skb))
@@ -2000,6 +2001,7 @@ gso:
 	 */
 	rcu_read_lock_bh();
 
+	skb->sending_cpu = cpu = smp_processor_id();
 	txq = dev_pick_tx(dev, skb);
 	q = rcu_dereference(txq->qdisc);
 
@@ -2024,8 +2026,6 @@ gso:
 	   Either shot noqueue qdisc, it is even simpler 8)
 	 */
 	if (dev->flags & IFF_UP) {
-		int cpu = smp_processor_id(); /* ok because BHs are off */
-
 		if (txq->xmit_lock_owner != cpu) {
 
 			HARD_TX_LOCK(dev, txq, cpu);
@@ -2967,7 +2967,7 @@ static void net_rx_action(struct softirq_action *h)
 	}
 out:
 	local_irq_enable();
-
+	xps_flush();
 #ifdef CONFIG_NET_DMA
 	/*
 	 * There may not be any more sk_buffs coming right now, so push
@@ -5798,7 +5798,7 @@ static int __init net_dev_init(void)
 		queue->backlog.gro_list = NULL;
 		queue->backlog.gro_count = 0;
 	}
-
+	xps_init();
 	dev_boot_phase = 0;
 
 	/* The loopback device is special if any other network devices
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index d38470a..b41b794 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3435,6 +3435,7 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 			pkt_dev->clone_count--;	/* back out increment, OOM */
 			return;
 		}
+		pkt_dev->skb->sending_cpu = smp_processor_id();
 		pkt_dev->last_pkt_size = pkt_dev->skb->len;
 		pkt_dev->allocated_skbs++;
 		pkt_dev->clone_count = 0;	/* reset counter */
diff --git a/net/core/xps.c b/net/core/xps.c
index e69de29..e580159 100644
--- a/net/core/xps.c
+++ b/net/core/xps.c
@@ -0,0 +1,145 @@
+/*
+ * XPS : Xmit Packet Steering
+ *
+ * TX completion packet freeing is performed on cpu that sent packet.
+ */
+#if defined(CONFIG_SMP)
+
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/kmemcheck.h>
+#include <linux/mm.h>
+#include <linux/interrupt.h>
+#include <linux/in.h>
+#include <linux/inet.h>
+#include <linux/slab.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+
+
+struct xps_pcpu_queue {
+	struct call_single_data csd;
+	struct sk_buff_head	list;
+};
+
+static DEFINE_PER_CPU(cpumask_t, xps_cpus);
+
+static DEFINE_PER_CPU(struct xps_pcpu_queue, xps_pcpu_queue);
+
+static struct sk_buff_head *xps_array; /* nr_cpu_ids elems */
+
+
+
+/* called from softirq context only */
+void xps_consume_skb(struct sk_buff *skb)
+{
+	unsigned int remote;
+	int thiscpu;
+	struct sk_buff_head *head;
+	/*
+	 * Might be stupid to dirty this cache line, but might
+	 * also be stupid to send an IPI if skb is not to be freed :(
+	 * One solution to this problem would be to move ->users in first cache line
+	 * (shared with ->next & ->sending_cpu fields ), so that this cpu dirties
+	 * only one cache line per queued skb.
+	 */
+	if (!atomic_dec_and_test(&skb->users))
+		return;
+
+	remote = skb->sending_cpu;
+	thiscpu = smp_processor_id();
+	if (remote >= nr_cpu_ids || remote == thiscpu) {
+		__kfree_skb(skb);
+		return;
+	}
+	head = &per_cpu_ptr(xps_array, thiscpu)[remote];
+
+	__skb_queue_head(head, skb);
+
+	/* IPI to remote processor will be sent later by xps_flush(),
+	 * to coalesce as much as possible skbs
+	 */
+	cpu_set(remote, __get_cpu_var(xps_cpus));
+}
+EXPORT_SYMBOL(xps_consume_skb);
+
+/*
+ * called at end of net_rx_action()
+ * preemption (and cpu migration/offline/online) disabled
+ */
+void xps_flush(void)
+{
+	int cpu, prevlen;
+	struct sk_buff_head *head = per_cpu_ptr(xps_array, smp_processor_id());
+	struct xps_pcpu_queue *q;
+	struct sk_buff *skb;
+
+	for_each_cpu_mask_nr(cpu, __get_cpu_var(xps_cpus)) {
+		q = &per_cpu(xps_pcpu_queue, cpu);
+		if (cpu_online(cpu)) {
+			spin_lock(&q->list.lock);
+			prevlen = skb_queue_len(&q->list);
+			skb_queue_splice_init(&head[cpu], &q->list);
+			spin_unlock(&q->list.lock);
+			/*
+			 * We hope remote cpu will be fast enough to transfert
+			 * this list to its completion queue before our
+			 * next xps_flush() call
+			 */
+			if (!prevlen)
+				__smp_call_function_single(cpu, &q->csd, 0);
+			continue;
+		}
+		/*
+		 * ok, we must free these skbs, even if we tried to avoid it :)
+		 */
+		while ((skb = __skb_dequeue(&head[cpu])) != NULL)
+			__kfree_skb(skb);
+	}
+	cpus_clear(__get_cpu_var(xps_cpus));
+}
+
+/*
+ * called from hardirq (IPI) context
+ */
+static void remote_free_skb_list(void *arg)
+{
+	struct sk_buff *last;
+	struct softnet_data *sd;
+	struct xps_pcpu_queue *q = arg; /* &__get_cpu_var(xps_pcpu_queue); */
+
+	spin_lock(&q->list.lock);
+
+	last = q->list.prev;
+	sd = &__get_cpu_var(softnet_data);
+	last->next = sd->completion_queue;
+	sd->completion_queue = q->list.next;
+	__skb_queue_head_init(&q->list);
+
+	spin_unlock(&q->list.lock);
+
+	raise_softirq_irqoff(NET_TX_SOFTIRQ);
+}
+
+void __init xps_init(void)
+{
+	int cpu, remote;
+	struct sk_buff_head *head;
+
+	xps_array = __alloc_percpu(nr_cpu_ids * sizeof(struct sk_buff_head),
+				   __alignof__(struct sk_buff_head));
+	if (!xps_array)
+		panic("XPS: Could not allocate xps_array\n");
+
+	for_each_possible_cpu(cpu) {
+		skb_queue_head_init(&per_cpu(xps_pcpu_queue, cpu).list);
+		per_cpu(xps_pcpu_queue, cpu).csd.func = remote_free_skb_list;
+		per_cpu(xps_pcpu_queue, cpu).csd.info = &per_cpu(xps_pcpu_queue, cpu);
+		head = per_cpu_ptr(xps_array, cpu);
+		for (remote = 0; remote < nr_cpu_ids; remote++)
+			__skb_queue_head_init(head + remote);
+	}
+}
+
+#endif /* CONFIG_SMP */
