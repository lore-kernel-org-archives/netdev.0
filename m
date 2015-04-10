From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] net: use jump label patching for ingress qdisc in __netif_receive_skb_core
Date: Fri, 10 Apr 2015 23:07:54 +0200
Message-ID: <66b2c2faaa0f629dd9a8c0981bf51f6484bc4ee9.1428699635.git.daniel@iogearbox.net>
Cc: jhs@mojatatu.com, ast@plumgrid.com, edumazet@google.com,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44760 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756463AbbDJVH7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 17:07:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Even if we make use of classifier and actions from the egress
path, we're going into handle_ing() executing additional code
on a per-packet cost for ingress qdisc, just to realize that
nothing is attached on ingress.

Instead, this can just be blinded out as a no-op entirely with
the use of a static key. On input fast-path, we already make
use of static keys in various places, e.g. skb time stamping,
in RPS, etc. It makes sense to not waste time when we're assured
that no ingress qdisc is attached anywhere.

Enabling/disabling of that code path is being done via two
helpers, namely net_{inc,dec}_ingress_queue(), that are being
invoked under RTNL mutex when a ingress qdisc is being either
initialized or destructed.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/rtnetlink.h | 15 ++++++++++++++-
 net/core/dev.c            | 31 ++++++++++++++++++++++++-------
 net/sched/sch_ingress.c   |  9 +++++++++
 3 files changed, 47 insertions(+), 8 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 5db76a3..2da5d10 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -77,7 +77,20 @@ static inline struct netdev_queue *dev_ingress_queue(struct net_device *dev)
 	return rtnl_dereference(dev->ingress_queue);
 }
 
-extern struct netdev_queue *dev_ingress_queue_create(struct net_device *dev);
+struct netdev_queue *dev_ingress_queue_create(struct net_device *dev);
+
+#ifdef CONFIG_NET_CLS_ACT
+void net_inc_ingress_queue(void);
+void net_dec_ingress_queue(void);
+#else
+static inline void net_inc_ingress_queue(void)
+{
+}
+
+static inline void net_dec_ingress_queue(void)
+{
+}
+#endif
 
 extern void rtnetlink_init(void);
 extern void __rtnl_unlock(void);
diff --git a/net/core/dev.c b/net/core/dev.c
index 3b39652..aa958ea 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1630,6 +1630,22 @@ int call_netdevice_notifiers(unsigned long val, struct net_device *dev)
 }
 EXPORT_SYMBOL(call_netdevice_notifiers);
 
+#ifdef CONFIG_NET_CLS_ACT
+static struct static_key ingress_needed __read_mostly;
+
+void net_inc_ingress_queue(void)
+{
+	static_key_slow_inc(&ingress_needed);
+}
+EXPORT_SYMBOL_GPL(net_inc_ingress_queue);
+
+void net_dec_ingress_queue(void)
+{
+	static_key_slow_dec(&ingress_needed);
+}
+EXPORT_SYMBOL_GPL(net_dec_ingress_queue);
+#endif
+
 static struct static_key netstamp_needed __read_mostly;
 #ifdef HAVE_JUMP_LABEL
 /* We are not allowed to call static_key_slow_dec() from irq context
@@ -3547,7 +3563,7 @@ static inline struct sk_buff *handle_ing(struct sk_buff *skb,
 	struct netdev_queue *rxq = rcu_dereference(skb->dev->ingress_queue);
 
 	if (!rxq || rcu_access_pointer(rxq->qdisc) == &noop_qdisc)
-		goto out;
+		return skb;
 
 	if (*pt_prev) {
 		*ret = deliver_skb(skb, *pt_prev, orig_dev);
@@ -3561,8 +3577,6 @@ static inline struct sk_buff *handle_ing(struct sk_buff *skb,
 		return NULL;
 	}
 
-out:
-	skb->tc_verd = 0;
 	return skb;
 }
 #endif
@@ -3698,12 +3712,15 @@ another_round:
 
 skip_taps:
 #ifdef CONFIG_NET_CLS_ACT
-	skb = handle_ing(skb, &pt_prev, &ret, orig_dev);
-	if (!skb)
-		goto unlock;
+	if (static_key_false(&ingress_needed)) {
+		skb = handle_ing(skb, &pt_prev, &ret, orig_dev);
+		if (!skb)
+			goto unlock;
+	}
+
+	skb->tc_verd = 0;
 ncls:
 #endif
-
 	if (pfmemalloc && !skb_pfmemalloc_protocol(skb))
 		goto drop;
 
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index eb5b844..4cdbfb8 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -88,11 +88,19 @@ static int ingress_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 /* ------------------------------------------------------------- */
 
+static int ingress_init(struct Qdisc *sch, struct nlattr *opt)
+{
+	net_inc_ingress_queue();
+
+	return 0;
+}
+
 static void ingress_destroy(struct Qdisc *sch)
 {
 	struct ingress_qdisc_data *p = qdisc_priv(sch);
 
 	tcf_destroy_chain(&p->filter_list);
+	net_dec_ingress_queue();
 }
 
 static int ingress_dump(struct Qdisc *sch, struct sk_buff *skb)
@@ -124,6 +132,7 @@ static struct Qdisc_ops ingress_qdisc_ops __read_mostly = {
 	.id		=	"ingress",
 	.priv_size	=	sizeof(struct ingress_qdisc_data),
 	.enqueue	=	ingress_enqueue,
+	.init		=	ingress_init,
 	.destroy	=	ingress_destroy,
 	.dump		=	ingress_dump,
 	.owner		=	THIS_MODULE,
-- 
1.9.3
