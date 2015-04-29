From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 6/6] net: move qdisc ingress filtering on top of netfilter ingress hooks
Date: Wed, 29 Apr 2015 20:53:09 +0200
Message-ID: <1430333589-4940-7-git-send-email-pablo@netfilter.org>
References: <1430333589-4940-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org, jhs@mojatatu.com
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55886 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751876AbbD2Ss6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Apr 2015 14:48:58 -0400
In-Reply-To: <1430333589-4940-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Port qdisc ingress on top of the Netfilter ingress allows us to detach the
qdisc ingress filtering code from the core, so now it resides where it really
belongs.

The specific qdisc ingress static key is also gone since we now rely on the
generic netfilter hook static key infrastructure.

This only depends on the basic hook infrastructure that resides on
net/core/hooks.c, so you have enable qdisc ingress filtering without the
layer 3 netfilter hooks.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/rtnetlink.h |   13 -------
 net/core/dev.c            |   92 ++-------------------------------------------
 net/sched/Kconfig         |    1 +
 net/sched/sch_ingress.c   |   60 +++++++++++++++++++++++++++--
 4 files changed, 61 insertions(+), 105 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 2da5d10..5b2cc04 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -79,19 +79,6 @@ static inline struct netdev_queue *dev_ingress_queue(struct net_device *dev)
 
 struct netdev_queue *dev_ingress_queue_create(struct net_device *dev);
 
-#ifdef CONFIG_NET_CLS_ACT
-void net_inc_ingress_queue(void);
-void net_dec_ingress_queue(void);
-#else
-static inline void net_inc_ingress_queue(void)
-{
-}
-
-static inline void net_dec_ingress_queue(void)
-{
-}
-#endif
-
 extern void rtnetlink_init(void);
 extern void __rtnl_unlock(void);
 
diff --git a/net/core/dev.c b/net/core/dev.c
index fa8a262..af03263 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1631,22 +1631,6 @@ int call_netdevice_notifiers(unsigned long val, struct net_device *dev)
 }
 EXPORT_SYMBOL(call_netdevice_notifiers);
 
-#ifdef CONFIG_NET_CLS_ACT
-static struct static_key ingress_needed __read_mostly;
-
-void net_inc_ingress_queue(void)
-{
-	static_key_slow_inc(&ingress_needed);
-}
-EXPORT_SYMBOL_GPL(net_inc_ingress_queue);
-
-void net_dec_ingress_queue(void)
-{
-	static_key_slow_dec(&ingress_needed);
-}
-EXPORT_SYMBOL_GPL(net_dec_ingress_queue);
-#endif
-
 static struct static_key netstamp_needed __read_mostly;
 #ifdef HAVE_JUMP_LABEL
 /* We are not allowed to call static_key_slow_dec() from irq context
@@ -3521,67 +3505,6 @@ int (*br_fdb_test_addr_hook)(struct net_device *dev,
 EXPORT_SYMBOL_GPL(br_fdb_test_addr_hook);
 #endif
 
-#ifdef CONFIG_NET_CLS_ACT
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
-	struct net_device *dev = skb->dev;
-	u32 ttl = G_TC_RTTL(skb->tc_verd);
-	int result = TC_ACT_OK;
-	struct Qdisc *q;
-
-	if (unlikely(MAX_RED_LOOP < ttl++)) {
-		net_warn_ratelimited("Redir loop detected Dropping packet (%d->%d)\n",
-				     skb->skb_iif, dev->ifindex);
-		return TC_ACT_SHOT;
-	}
-
-	skb->tc_verd = SET_TC_RTTL(skb->tc_verd, ttl);
-	skb->tc_verd = SET_TC_AT(skb->tc_verd, AT_INGRESS);
-
-	q = rcu_dereference(rxq->qdisc);
-	if (q != &noop_qdisc) {
-		spin_lock(qdisc_lock(q));
-		if (likely(!test_bit(__QDISC_STATE_DEACTIVATED, &q->state)))
-			result = qdisc_enqueue_root(skb, q);
-		spin_unlock(qdisc_lock(q));
-	}
-
-	return result;
-}
-
-static inline struct sk_buff *handle_ing(struct sk_buff *skb,
-					 struct packet_type **pt_prev,
-					 int *ret, struct net_device *orig_dev)
-{
-	struct netdev_queue *rxq = rcu_dereference(skb->dev->ingress_queue);
-
-	if (!rxq || rcu_access_pointer(rxq->qdisc) == &noop_qdisc)
-		return skb;
-
-	if (*pt_prev) {
-		*ret = deliver_skb(skb, *pt_prev, orig_dev);
-		*pt_prev = NULL;
-	}
-
-	switch (ing_filter(skb, rxq)) {
-	case TC_ACT_SHOT:
-	case TC_ACT_STOLEN:
-		kfree_skb(skb);
-		return NULL;
-	}
-
-	return skb;
-}
-#endif
-
 /**
  *	netdev_rx_handler_register - register receive handler
  *	@dev: device to register a handler for
@@ -3726,16 +3649,6 @@ another_round:
 	}
 
 skip_taps:
-#ifdef CONFIG_NET_CLS_ACT
-	if (static_key_false(&ingress_needed)) {
-		skb = handle_ing(skb, &pt_prev, &ret, orig_dev);
-		if (!skb)
-			goto unlock;
-	}
-
-	skb->tc_verd = 0;
-ncls:
-#endif
 	if (nf_hook_ingress_active(skb)) {
 		ret = nf_hook_ingress(skb, &pt_prev, &ret, orig_dev);
 		if (ret < 0) {
@@ -3743,7 +3656,10 @@ ncls:
 			goto unlock;
 		}
 	}
-
+#ifdef CONFIG_NET_CLS_ACT
+	skb->tc_verd = 0;
+ncls:
+#endif
 	if (pfmemalloc && !skb_pfmemalloc_protocol(skb))
 		goto drop;
 
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 2274e72..23b57da 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -312,6 +312,7 @@ config NET_SCH_PIE
 config NET_SCH_INGRESS
 	tristate "Ingress Qdisc"
 	depends on NET_CLS_ACT
+	select NETFILTER_INGRESS
 	---help---
 	  Say Y here if you want to use classifiers for incoming packets.
 	  If unsure, say Y.
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index 4cdbfb8..996c823 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -14,10 +14,11 @@
 #include <linux/rtnetlink.h>
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
-
+#include <linux/netfilter_hooks.h>
 
 struct ingress_qdisc_data {
 	struct tcf_proto __rcu	*filter_list;
+	struct nf_hook_ops	ops;
 };
 
 /* ------------------------- Class/flow operations ------------------------- */
@@ -88,11 +89,62 @@ static int ingress_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 /* ------------------------------------------------------------- */
 
+static int ing_filter(struct sk_buff *skb, struct netdev_queue *rxq)
+{
+	struct net_device *dev = skb->dev;
+	u32 ttl = G_TC_RTTL(skb->tc_verd);
+	int result = TC_ACT_OK;
+	struct Qdisc *q;
+
+	if (unlikely(MAX_RED_LOOP < ttl++)) {
+		net_warn_ratelimited("Redir loop detected Dropping packet (%d->%d)\n",
+				     skb->skb_iif, dev->ifindex);
+		return TC_ACT_SHOT;
+	}
+
+	skb->tc_verd = SET_TC_RTTL(skb->tc_verd, ttl);
+	skb->tc_verd = SET_TC_AT(skb->tc_verd, AT_INGRESS);
+
+	q = rcu_dereference(rxq->qdisc);
+	if (q != &noop_qdisc) {
+		spin_lock(qdisc_lock(q));
+		if (likely(!test_bit(__QDISC_STATE_DEACTIVATED, &q->state)))
+			result = qdisc_enqueue_root(skb, q);
+		spin_unlock(qdisc_lock(q));
+	}
+
+	return result;
+}
+
+static unsigned int handle_ing(const struct nf_hook_ops *ops,
+			       struct sk_buff *skb,
+			       const struct nf_hook_state *state)
+{
+	struct netdev_queue *rxq = rcu_dereference(skb->dev->ingress_queue);
+
+	if (!rxq || rcu_access_pointer(rxq->qdisc) == &noop_qdisc)
+		return NF_ACCEPT;
+
+	switch (ing_filter(skb, rxq)) {
+	case TC_ACT_SHOT:
+	case TC_ACT_STOLEN:
+		return NF_DROP;
+	}
+
+	return NF_ACCEPT;
+}
+
 static int ingress_init(struct Qdisc *sch, struct nlattr *opt)
 {
-	net_inc_ingress_queue();
+	struct ingress_qdisc_data *p = qdisc_priv(sch);
+
+	p->ops.hook	= handle_ing;
+	p->ops.pf	= NFPROTO_NETDEV;
+	p->ops.hooknum	= NF_NETDEV_INGRESS;
+	p->ops.priority = 0;
+	p->ops.dev	= qdisc_dev(sch);
 
-	return 0;
+	return nf_register_hook(&p->ops);
 }
 
 static void ingress_destroy(struct Qdisc *sch)
@@ -100,7 +152,7 @@ static void ingress_destroy(struct Qdisc *sch)
 	struct ingress_qdisc_data *p = qdisc_priv(sch);
 
 	tcf_destroy_chain(&p->filter_list);
-	net_dec_ingress_queue();
+	nf_unregister_hook(&p->ops);
 }
 
 static int ingress_dump(struct Qdisc *sch, struct sk_buff *skb)
-- 
1.7.10.4
