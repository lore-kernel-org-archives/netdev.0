From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 2/2] net: sched: further simplify handle_ing
Date: Sat,  9 May 2015 22:51:32 +0200
Message-ID: <e0f2ed0341e05853d9ae23a804908f7c703438aa.1431203900.git.daniel@iogearbox.net>
References: <cover.1431203900.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, jhs@mojatatu.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:43961 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751778AbbEIUvi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 16:51:38 -0400
In-Reply-To: <cover.1431203900.git.daniel@iogearbox.net>
In-Reply-To: <cover.1431203900.git.daniel@iogearbox.net>
References: <cover.1431203900.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingress qdisc has no other purpose than calling into tc_classify()
that executes attached classifier(s) and action(s).

It has a 1:1 relationship to dev->ingress_queue. After having commit
087c1a601ad7 ("net: sched: run ingress qdisc without locks") removed
the central ingress lock, one major contention point is gone.

The extra indirection layers however, are not necessary for calling
into ingress qdisc. pktgen calling locally into netif_receive_skb()
with a dummy u32, single CPU result on a Supermicro X10SLM-F, Xeon
E3-1240: before ~21,1 Mpps, after patch ~22,9 Mpps.

We can redirect the private classifier list to the netdev directly,
without changing any classifier API bits (!) and execute on that from
handle_ing() side. The __QDISC_STATE_DEACTIVATE test can be removed,
ingress qdisc doesn't have a queue and thus dev_deactivate_queue()
is also not applicable, ingress_cl_list provides similar behaviour.
In other words, ingress qdisc acts like TCQ_F_BUILTIN qdisc.

One next possible step is the removal of the dev's ingress (dummy)
netdev_queue, and to only have the list member in the netdevice
itself.

Note, the filter chain is RCU protected and individual filter elements
are being kfree'd by sched subsystem after RCU grace period. RCU read
lock is being held by __netif_receive_skb_core().

Joint work with Alexei Starovoitov.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/linux/netdevice.h |  4 ++++
 net/core/dev.c            | 30 ++++++++++++++----------
 net/sched/sch_ingress.c   | 58 ++++++++---------------------------------------
 3 files changed, 31 insertions(+), 61 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 1899c74..c4e1caf 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1655,7 +1655,11 @@ struct net_device {
 	rx_handler_func_t __rcu	*rx_handler;
 	void __rcu		*rx_handler_data;
 
+#if CONFIG_NET_CLS_ACT
+	struct tcf_proto __rcu  *ingress_cl_list;
+#endif
 	struct netdev_queue __rcu *ingress_queue;
+
 	unsigned char		broadcast[MAX_ADDR_LEN];
 #ifdef CONFIG_RFS_ACCEL
 	struct cpu_rmap		*rx_cpu_rmap;
diff --git a/net/core/dev.c b/net/core/dev.c
index 8a75746..e5f77c4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3525,31 +3525,37 @@ static inline struct sk_buff *handle_ing(struct sk_buff *skb,
 					 struct packet_type **pt_prev,
 					 int *ret, struct net_device *orig_dev)
 {
-	struct netdev_queue *rxq = rcu_dereference(skb->dev->ingress_queue);
-	struct Qdisc *q;
+	struct tcf_proto *cl = rcu_dereference_bh(skb->dev->ingress_cl_list);
+	struct tcf_result cl_res;
 
 	/* If there's at least one ingress present somewhere (so
 	 * we get here via enabled static key), remaining devices
 	 * that are not configured with an ingress qdisc will bail
-	 * out w/o the rcu_dereference().
+	 * out here.
 	 */
-	if (!rxq || (q = rcu_dereference(rxq->qdisc)) == &noop_qdisc)
+	if (!cl)
 		return skb;
-
 	if (*pt_prev) {
 		*ret = deliver_skb(skb, *pt_prev, orig_dev);
 		*pt_prev = NULL;
 	}
 
+	qdisc_bstats_update_cpu(cl->q, skb);
 	skb->tc_verd = SET_TC_AT(skb->tc_verd, AT_INGRESS);
 
-	if (likely(!test_bit(__QDISC_STATE_DEACTIVATED, &q->state))) {
-		switch (qdisc_enqueue_root(skb, q)) {
-		case TC_ACT_SHOT:
-		case TC_ACT_STOLEN:
-			kfree_skb(skb);
-			return NULL;
-		}
+	switch (tc_classify(skb, cl, &cl_res)) {
+	case TC_ACT_OK:
+	case TC_ACT_RECLASSIFY:
+		skb->tc_index = TC_H_MIN(cl_res.classid);
+		break;
+	case TC_ACT_SHOT:
+		qdisc_qstats_drop_cpu(cl->q);
+	case TC_ACT_STOLEN:
+	case TC_ACT_QUEUED:
+		kfree_skb(skb);
+		return NULL;
+	default:
+		break;
 	}
 
 	return skb;
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index a89cc32..e7c648f 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -12,16 +12,10 @@
 #include <linux/list.h>
 #include <linux/skbuff.h>
 #include <linux/rtnetlink.h>
+
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
 
-
-struct ingress_qdisc_data {
-	struct tcf_proto __rcu	*filter_list;
-};
-
-/* ------------------------- Class/flow operations ------------------------- */
-
 static struct Qdisc *ingress_leaf(struct Qdisc *sch, unsigned long arg)
 {
 	return NULL;
@@ -49,45 +43,11 @@ static void ingress_walk(struct Qdisc *sch, struct qdisc_walker *walker)
 static struct tcf_proto __rcu **ingress_find_tcf(struct Qdisc *sch,
 						 unsigned long cl)
 {
-	struct ingress_qdisc_data *p = qdisc_priv(sch);
-
-	return &p->filter_list;
-}
-
-/* --------------------------- Qdisc operations ---------------------------- */
+	struct net_device *dev = qdisc_dev(sch);
 
-static int ingress_enqueue(struct sk_buff *skb, struct Qdisc *sch)
-{
-	struct ingress_qdisc_data *p = qdisc_priv(sch);
-	struct tcf_result res;
-	struct tcf_proto *fl = rcu_dereference_bh(p->filter_list);
-	int result;
-
-	result = tc_classify(skb, fl, &res);
-
-	qdisc_bstats_update_cpu(sch, skb);
-	switch (result) {
-	case TC_ACT_SHOT:
-		result = TC_ACT_SHOT;
-		qdisc_qstats_drop_cpu(sch);
-		break;
-	case TC_ACT_STOLEN:
-	case TC_ACT_QUEUED:
-		result = TC_ACT_STOLEN;
-		break;
-	case TC_ACT_RECLASSIFY:
-	case TC_ACT_OK:
-		skb->tc_index = TC_H_MIN(res.classid);
-	default:
-		result = TC_ACT_OK;
-		break;
-	}
-
-	return result;
+	return &dev->ingress_cl_list;
 }
 
-/* ------------------------------------------------------------- */
-
 static int ingress_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	net_inc_ingress_queue();
@@ -98,9 +58,9 @@ static int ingress_init(struct Qdisc *sch, struct nlattr *opt)
 
 static void ingress_destroy(struct Qdisc *sch)
 {
-	struct ingress_qdisc_data *p = qdisc_priv(sch);
+	struct net_device *dev = qdisc_dev(sch);
 
-	tcf_destroy_chain(&p->filter_list);
+	tcf_destroy_chain(&dev->ingress_cl_list);
 	net_dec_ingress_queue();
 }
 
@@ -111,6 +71,7 @@ static int ingress_dump(struct Qdisc *sch, struct sk_buff *skb)
 	nest = nla_nest_start(skb, TCA_OPTIONS);
 	if (nest == NULL)
 		goto nla_put_failure;
+
 	return nla_nest_end(skb, nest);
 
 nla_put_failure:
@@ -131,8 +92,6 @@ static const struct Qdisc_class_ops ingress_class_ops = {
 static struct Qdisc_ops ingress_qdisc_ops __read_mostly = {
 	.cl_ops		=	&ingress_class_ops,
 	.id		=	"ingress",
-	.priv_size	=	sizeof(struct ingress_qdisc_data),
-	.enqueue	=	ingress_enqueue,
 	.init		=	ingress_init,
 	.destroy	=	ingress_destroy,
 	.dump		=	ingress_dump,
@@ -149,6 +108,7 @@ static void __exit ingress_module_exit(void)
 	unregister_qdisc(&ingress_qdisc_ops);
 }
 
-module_init(ingress_module_init)
-module_exit(ingress_module_exit)
+module_init(ingress_module_init);
+module_exit(ingress_module_exit);
+
 MODULE_LICENSE("GPL");
-- 
1.9.3
