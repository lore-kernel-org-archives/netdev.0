From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/2 net-next] net: move qdisc ingress filtering code where it belongs
Date: Sun, 10 May 2015 18:59:30 +0200
Message-ID: <1431277170-4618-3-git-send-email-pablo@netfilter.org>
References: <1431277170-4618-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, ast@plumgrid.com, jhs@mojatatu.com,
	daniel@iogearbox.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:40246 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751442AbbEJQyv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 May 2015 12:54:51 -0400
In-Reply-To: <1431277170-4618-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The qdisc ingress filtering code is embedded into the core most likely because
at that time we had no RCU in place to define a hook. This is semantically
wrong as this violates the most basic rules of encapsulation.

On top of that, this special qdisc does not enqueue anything at all, so we can
skip the enqueue indirection from qdisc_enqueue_root() which is doing things
that we don't need.

This reduces the pollution of the super-critical ingress path, where
most users don't need this as it has been stated many times before.
e.g. 24824a09 ("net: dynamic ingress_queue allocation").

As a result, this improves performance in the super-critical ingress:

Before:

Result: OK: 4767946(c4767946+d0) usec, 100000000 (60byte,0frags)
  20973388pps 10067Mb/sec (10067226240bps) errors: 100000000

After:

Result: OK: 4747078(c4747078+d0) usec, 100000000 (60byte,0frags)
  21065587pps 10111Mb/sec (10111481760bps) errors: 100000000

This is roughly 92199pps, ~0.42% more performance on my old box.

Using pktgen rx injection, perf shows I'm profiling the right thing.

    36.12%  kpktgend_0  [kernel.kallsyms]  [k] __netif_receive_skb_core
    18.46%  kpktgend_0  [kernel.kallsyms]  [k] atomic_dec_and_test
    15.87%  kpktgend_0  [kernel.kallsyms]  [k] deliver_ptype_list_skb
     5.04%  kpktgend_0  [pktgen]           [k] pktgen_thread_worker
     4.81%  kpktgend_0  [kernel.kallsyms]  [k] netif_receive_skb_internal
     4.11%  kpktgend_0  [kernel.kallsyms]  [k] kfree_skb
     3.89%  kpktgend_0  [kernel.kallsyms]  [k] ip_rcv
     3.44%  kpktgend_0  [kernel.kallsyms]  [k] __rcu_read_unlock
     2.89%  kpktgend_0  [kernel.kallsyms]  [k] netif_receive_skb_sk
     2.14%  kpktgend_0  [kernel.kallsyms]  [k] __netif_receive_skb
     2.14%  kpktgend_0  [kernel.kallsyms]  [k] __rcu_read_lock
     0.57%  kpktgend_0  [kernel.kallsyms]  [k] __local_bh_enable_ip

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netdevice.h |    3 +++
 include/linux/rtnetlink.h |    1 +
 net/core/dev.c            |   45 ++++++++++++---------------------------------
 net/sched/sch_ingress.c   |   43 +++++++++++++++++++++++++++++++++++++++----
 4 files changed, 55 insertions(+), 37 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 1899c74..85288b5 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1299,6 +1299,9 @@ enum netdev_priv_flags {
 #define IFF_IPVLAN_MASTER		IFF_IPVLAN_MASTER
 #define IFF_IPVLAN_SLAVE		IFF_IPVLAN_SLAVE
 
+typedef struct sk_buff *qdisc_ingress_hook_t(struct sk_buff *skb);
+extern qdisc_ingress_hook_t __rcu *qdisc_ingress_hook;
+
 /**
  *	struct net_device - The DEVICE structure.
  *		Actually, this whole structure is a big mistake.  It mixes I/O
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index bd29ab4..7c204f2 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -82,6 +82,7 @@ struct netdev_queue *dev_ingress_queue_create(struct net_device *dev);
 #ifdef CONFIG_NET_CLS_ACT
 void net_inc_ingress_queue(void);
 void net_dec_ingress_queue(void);
+int net_ingress_queue_count(void);
 #endif
 
 extern void rtnetlink_init(void);
diff --git a/net/core/dev.c b/net/core/dev.c
index 862875e..14a07ec 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1644,6 +1644,12 @@ void net_dec_ingress_queue(void)
 	static_key_slow_dec(&ingress_needed);
 }
 EXPORT_SYMBOL_GPL(net_dec_ingress_queue);
+
+int net_ingress_queue_count(void)
+{
+	return static_key_count(&ingress_needed);
+}
+EXPORT_SYMBOL_GPL(net_ingress_queue_count);
 #endif
 
 static struct static_key netstamp_needed __read_mostly;
@@ -3521,37 +3527,17 @@ EXPORT_SYMBOL_GPL(br_fdb_test_addr_hook);
 #endif
 
 #ifdef CONFIG_NET_CLS_ACT
-/* TODO: Maybe we should just force sch_ingress to be compiled in
- * when CONFIG_NET_CLS_ACT is? otherwise some useless instructions
- * a compare and 2 stores extra right now if we dont have it on
- * but have CONFIG_NET_CLS_ACT
- * NOTE: This doesn't stop any functionality; if you dont have
- * the ingress scheduler, you just can't add policies on ingress.
- *
- */
-static int ing_filter(struct sk_buff *skb, struct netdev_queue *rxq)
-{
-	int result = TC_ACT_OK;
-	struct Qdisc *q;
-
-	skb->tc_verd = SET_TC_AT(skb->tc_verd, AT_INGRESS);
-
-	q = rcu_dereference(rxq->qdisc);
-	if (q != &noop_qdisc) {
-		if (likely(!test_bit(__QDISC_STATE_DEACTIVATED, &q->state)))
-			result = qdisc_enqueue_root(skb, q);
-	}
-
-	return result;
-}
+qdisc_ingress_hook_t __rcu *qdisc_ingress_hook __read_mostly;
+EXPORT_SYMBOL_GPL(qdisc_ingress_hook);
 
 static inline struct sk_buff *handle_ing(struct sk_buff *skb,
 					 struct packet_type **pt_prev,
 					 int *ret, struct net_device *orig_dev)
 {
-	struct netdev_queue *rxq = rcu_dereference(skb->dev->ingress_queue);
+	qdisc_ingress_hook_t *ingress_hook;
 
-	if (!rxq || rcu_access_pointer(rxq->qdisc) == &noop_qdisc)
+	ingress_hook = rcu_dereference(qdisc_ingress_hook);
+	if (ingress_hook == NULL)
 		return skb;
 
 	if (*pt_prev) {
@@ -3559,14 +3545,7 @@ static inline struct sk_buff *handle_ing(struct sk_buff *skb,
 		*pt_prev = NULL;
 	}
 
-	switch (ing_filter(skb, rxq)) {
-	case TC_ACT_SHOT:
-	case TC_ACT_STOLEN:
-		kfree_skb(skb);
-		return NULL;
-	}
-
-	return skb;
+	return ingress_hook(skb);
 }
 #endif
 
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index a89cc32..0c20f89 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -54,9 +54,9 @@ static struct tcf_proto __rcu **ingress_find_tcf(struct Qdisc *sch,
 	return &p->filter_list;
 }
 
-/* --------------------------- Qdisc operations ---------------------------- */
+/* ------------------------------------------------------------- */
 
-static int ingress_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+static int ingress_filter(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct ingress_qdisc_data *p = qdisc_priv(sch);
 	struct tcf_result res;
@@ -86,10 +86,42 @@ static int ingress_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	return result;
 }
 
-/* ------------------------------------------------------------- */
+static int ing_filter(struct sk_buff *skb, struct netdev_queue *rxq)
+{
+	int result = TC_ACT_OK;
+	struct Qdisc *q = rcu_dereference(rxq->qdisc);
+
+	skb->tc_verd = SET_TC_AT(skb->tc_verd, AT_INGRESS);
+
+	if (q != &noop_qdisc) {
+		if (likely(!test_bit(__QDISC_STATE_DEACTIVATED, &q->state)))
+			result = ingress_filter(skb, q);
+	}
+
+	return result;
+}
+
+static struct sk_buff *qdisc_ingress_filter(struct sk_buff *skb)
+{
+	struct netdev_queue *rxq = rcu_dereference(skb->dev->ingress_queue);
+
+	if (!rxq || rcu_access_pointer(rxq->qdisc) == &noop_qdisc)
+		return skb;
+
+	switch (ing_filter(skb, rxq)) {
+	case TC_ACT_SHOT:
+	case TC_ACT_STOLEN:
+		kfree_skb(skb);
+		return NULL;
+	}
+
+	return skb;
+}
 
 static int ingress_init(struct Qdisc *sch, struct nlattr *opt)
 {
+	if (net_ingress_queue_count() == 0)
+		rcu_assign_pointer(qdisc_ingress_hook, qdisc_ingress_filter);
 	net_inc_ingress_queue();
 	sch->flags |= TCQ_F_CPUSTATS;
 
@@ -102,6 +134,10 @@ static void ingress_destroy(struct Qdisc *sch)
 
 	tcf_destroy_chain(&p->filter_list);
 	net_dec_ingress_queue();
+	if (net_ingress_queue_count() == 0) {
+		rcu_assign_pointer(qdisc_ingress_hook, NULL);
+		synchronize_rcu();
+	}
 }
 
 static int ingress_dump(struct Qdisc *sch, struct sk_buff *skb)
@@ -132,7 +168,6 @@ static struct Qdisc_ops ingress_qdisc_ops __read_mostly = {
 	.cl_ops		=	&ingress_class_ops,
 	.id		=	"ingress",
 	.priv_size	=	sizeof(struct ingress_qdisc_data),
-	.enqueue	=	ingress_enqueue,
 	.init		=	ingress_init,
 	.destroy	=	ingress_destroy,
 	.dump		=	ingress_dump,
-- 
1.7.10.4
