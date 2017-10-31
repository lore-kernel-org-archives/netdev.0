From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 2/2] net: core: introduce mini_Qdisc and eliminate usage of tp->q for clsact fastpath
Date: Tue, 31 Oct 2017 16:12:22 +0100
Message-ID: <20171031151222.5021-3-jiri@resnulli.us>
References: <20171031151222.5021-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com, edumazet@google.com, daniel@iogearbox.net,
        alexander.h.duyck@intel.com, willemb@google.com,
        john.fastabend@gmail.com, alexei.starovoitov@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:47999 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753298AbdJaPM0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 11:12:26 -0400
Received: by mail-wr0-f194.google.com with SMTP id y39so16275319wrd.4
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 08:12:25 -0700 (PDT)
In-Reply-To: <20171031151222.5021-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

In sch_handle_egress and sch_handle_ingress tp->q is used only in order
to update stats. So stats and filter list are the only things that are
needed in clsact qdisc fastpath processing. Introduce new mini_Qdisc
struct to hold those items. Also, introduce a helper to swap the
mini_Qdisc structures in case filter list head changes.

This removes need for tp->q usage without added overhead.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
v2->v3:
- Using head change callback to replace miniq pointer every time tp head
  changes. This eliminates one rcu dereference and makes the claim "without
  added overhead" valid.
v1->v2:
- Use dev instead of skb->dev in sch_handle_egress as pointed out by Daniel
- Fixed synchronize_rcu_bh() in mini_qdisc_disable and commented
---
 include/linux/netdevice.h |  9 ++++++---
 include/net/sch_generic.h | 32 ++++++++++++++++++++++++++++++++
 net/core/dev.c            | 21 +++++++++++----------
 net/sched/sch_generic.c   | 46 ++++++++++++++++++++++++++++++++++++++++++++++
 net/sched/sch_ingress.c   | 19 ++++++++++++++-----
 5 files changed, 109 insertions(+), 18 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5e02f79..7de7656 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1559,6 +1559,8 @@ enum netdev_priv_flags {
  *
  *	@rx_handler:		handler for received packets
  *	@rx_handler_data: 	XXX: need comments on this one
+ *	@miniq_ingress:		ingress/clsact qdisc specific data for
+ *				ingress processing
  *	@ingress_queue:		XXX: need comments on this one
  *	@broadcast:		hw bcast address
  *
@@ -1576,7 +1578,8 @@ enum netdev_priv_flags {
  *	@tx_global_lock: 	XXX: need comments on this one
  *
  *	@xps_maps:	XXX: need comments on this one
- *
+ *	@miniq_egress:		clsact qdisc specific data for
+ *				egress processing
  *	@watchdog_timeo:	Represents the timeout that is used by
  *				the watchdog (see dev_watchdog())
  *	@watchdog_timer:	List of timers
@@ -1795,7 +1798,7 @@ struct net_device {
 	void __rcu		*rx_handler_data;
 
 #ifdef CONFIG_NET_CLS_ACT
-	struct tcf_proto __rcu  *ingress_cl_list;
+	struct mini_Qdisc __rcu	*miniq_ingress;
 #endif
 	struct netdev_queue __rcu *ingress_queue;
 #ifdef CONFIG_NETFILTER_INGRESS
@@ -1826,7 +1829,7 @@ struct net_device {
 	struct xps_dev_maps __rcu *xps_maps;
 #endif
 #ifdef CONFIG_NET_CLS_ACT
-	struct tcf_proto __rcu  *egress_cl_list;
+	struct mini_Qdisc __rcu	*miniq_egress;
 #endif
 
 	/* These may be needed for future network-power-down code. */
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 16d0f8f..f670272 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -897,4 +897,36 @@ static inline void psched_ratecfg_getrate(struct tc_ratespec *res,
 	res->linklayer = (r->linklayer & TC_LINKLAYER_MASK);
 }
 
+/* Mini Qdisc serves for specific needs of ingress/clsact Qdisc.
+ * The fast path only needs to access filter list and to update stats
+ */
+struct mini_Qdisc {
+	struct tcf_proto *filter_list;
+	struct gnet_stats_basic_cpu __percpu *cpu_bstats;
+	struct gnet_stats_queue	__percpu *cpu_qstats;
+	struct rcu_head rcu;
+};
+
+static inline void mini_qdisc_bstats_cpu_update(struct mini_Qdisc *miniq,
+						const struct sk_buff *skb)
+{
+	bstats_cpu_update(this_cpu_ptr(miniq->cpu_bstats), skb);
+}
+
+static inline void mini_qdisc_qstats_cpu_drop(struct mini_Qdisc *miniq)
+{
+	this_cpu_inc(miniq->cpu_qstats->drops);
+}
+
+struct mini_Qdisc_pair {
+	struct mini_Qdisc miniq1;
+	struct mini_Qdisc miniq2;
+	struct mini_Qdisc __rcu **p_miniq;
+};
+
+void mini_qdisc_pair_swap(struct mini_Qdisc_pair *miniqp,
+			  struct tcf_proto *tp_head);
+void mini_qdisc_pair_init(struct mini_Qdisc_pair *miniqp, struct Qdisc *qdisc,
+			  struct mini_Qdisc __rcu **p_miniq);
+
 #endif
diff --git a/net/core/dev.c b/net/core/dev.c
index 24ac908..1423cf4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3274,22 +3274,22 @@ EXPORT_SYMBOL(dev_loopback_xmit);
 static struct sk_buff *
 sch_handle_egress(struct sk_buff *skb, int *ret, struct net_device *dev)
 {
-	struct tcf_proto *cl = rcu_dereference_bh(dev->egress_cl_list);
+	struct mini_Qdisc *miniq = rcu_dereference_bh(dev->miniq_egress);
 	struct tcf_result cl_res;
 
-	if (!cl)
+	if (!miniq)
 		return skb;
 
 	/* qdisc_skb_cb(skb)->pkt_len was already set by the caller. */
-	qdisc_bstats_cpu_update(cl->q, skb);
+	mini_qdisc_bstats_cpu_update(miniq, skb);
 
-	switch (tcf_classify(skb, cl, &cl_res, false)) {
+	switch (tcf_classify(skb, miniq->filter_list, &cl_res, false)) {
 	case TC_ACT_OK:
 	case TC_ACT_RECLASSIFY:
 		skb->tc_index = TC_H_MIN(cl_res.classid);
 		break;
 	case TC_ACT_SHOT:
-		qdisc_qstats_cpu_drop(cl->q);
+		mini_qdisc_qstats_cpu_drop(miniq);
 		*ret = NET_XMIT_DROP;
 		kfree_skb(skb);
 		return NULL;
@@ -4189,7 +4189,7 @@ sch_handle_ingress(struct sk_buff *skb, struct packet_type **pt_prev, int *ret,
 		   struct net_device *orig_dev)
 {
 #ifdef CONFIG_NET_CLS_ACT
-	struct tcf_proto *cl = rcu_dereference_bh(skb->dev->ingress_cl_list);
+	struct mini_Qdisc *miniq = rcu_dereference_bh(skb->dev->miniq_ingress);
 	struct tcf_result cl_res;
 
 	/* If there's at least one ingress present somewhere (so
@@ -4197,8 +4197,9 @@ sch_handle_ingress(struct sk_buff *skb, struct packet_type **pt_prev, int *ret,
 	 * that are not configured with an ingress qdisc will bail
 	 * out here.
 	 */
-	if (!cl)
+	if (!miniq)
 		return skb;
+
 	if (*pt_prev) {
 		*ret = deliver_skb(skb, *pt_prev, orig_dev);
 		*pt_prev = NULL;
@@ -4206,15 +4207,15 @@ sch_handle_ingress(struct sk_buff *skb, struct packet_type **pt_prev, int *ret,
 
 	qdisc_skb_cb(skb)->pkt_len = skb->len;
 	skb->tc_at_ingress = 1;
-	qdisc_bstats_cpu_update(cl->q, skb);
+	mini_qdisc_bstats_cpu_update(miniq, skb);
 
-	switch (tcf_classify(skb, cl, &cl_res, false)) {
+	switch (tcf_classify(skb, miniq->filter_list, &cl_res, false)) {
 	case TC_ACT_OK:
 	case TC_ACT_RECLASSIFY:
 		skb->tc_index = TC_H_MIN(cl_res.classid);
 		break;
 	case TC_ACT_SHOT:
-		qdisc_qstats_cpu_drop(cl->q);
+		mini_qdisc_qstats_cpu_drop(miniq);
 		kfree_skb(skb);
 		return NULL;
 	case TC_ACT_STOLEN:
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index aa74aa4..3839cbb 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -1024,3 +1024,49 @@ void psched_ratecfg_precompute(struct psched_ratecfg *r,
 	}
 }
 EXPORT_SYMBOL(psched_ratecfg_precompute);
+
+static void mini_qdisc_rcu_func(struct rcu_head *head)
+{
+}
+
+void mini_qdisc_pair_swap(struct mini_Qdisc_pair *miniqp,
+			  struct tcf_proto *tp_head)
+{
+	struct mini_Qdisc *miniq_old = rtnl_dereference(*miniqp->p_miniq);
+	struct mini_Qdisc *miniq;
+
+	if (!tp_head) {
+		RCU_INIT_POINTER(*miniqp->p_miniq, NULL);
+		return;
+	}
+
+	miniq = !miniq_old || miniq_old == &miniqp->miniq2 ?
+		&miniqp->miniq1 : &miniqp->miniq2;
+
+	/* We need to make sure that readers won't see the miniq
+	 * we are about to modify. So wait until previous call_rcu_bh callback
+	 * is done.
+	 */
+	rcu_barrier_bh();
+	miniq->filter_list = tp_head;
+	rcu_assign_pointer(*miniqp->p_miniq, miniq);
+
+	if (miniq_old)
+		/* This is counterpart of the rcu barrier above. We need to
+		 * block potential new user of miniq_old until all readers
+		 * are not seeing it.
+		 */
+		call_rcu_bh(&miniq_old->rcu, mini_qdisc_rcu_func);
+}
+EXPORT_SYMBOL(mini_qdisc_pair_swap);
+
+void mini_qdisc_pair_init(struct mini_Qdisc_pair *miniqp, struct Qdisc *qdisc,
+			  struct mini_Qdisc __rcu **p_miniq)
+{
+	miniqp->miniq1.cpu_bstats = qdisc->cpu_bstats;
+	miniqp->miniq1.cpu_qstats = qdisc->cpu_qstats;
+	miniqp->miniq2.cpu_bstats = qdisc->cpu_bstats;
+	miniqp->miniq2.cpu_qstats = qdisc->cpu_qstats;
+	miniqp->p_miniq = p_miniq;
+}
+EXPORT_SYMBOL(mini_qdisc_pair_init);
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index 8118458..5ecc38f 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -21,6 +21,7 @@
 struct ingress_sched_data {
 	struct tcf_block *block;
 	struct tcf_block_ext_info block_info;
+	struct mini_Qdisc_pair miniqp;
 };
 
 static struct Qdisc *ingress_leaf(struct Qdisc *sch, unsigned long arg)
@@ -56,9 +57,9 @@ static struct tcf_block *ingress_tcf_block(struct Qdisc *sch, unsigned long cl)
 
 static void clsact_chain_head_change(struct tcf_proto *tp_head, void *priv)
 {
-	struct tcf_proto __rcu **p_filter_chain = priv;
+	struct mini_Qdisc_pair *miniqp = priv;
 
-	rcu_assign_pointer(*p_filter_chain, tp_head);
+	mini_qdisc_pair_swap(miniqp, tp_head);
 }
 
 static int ingress_init(struct Qdisc *sch, struct nlattr *opt)
@@ -67,9 +68,11 @@ static int ingress_init(struct Qdisc *sch, struct nlattr *opt)
 	struct net_device *dev = qdisc_dev(sch);
 	int err;
 
+	mini_qdisc_pair_init(&q->miniqp, sch, &dev->miniq_ingress);
+
 	q->block_info.binder_type = TCF_BLOCK_BINDER_TYPE_CLSACT_INGRESS;
 	q->block_info.chain_head_change = clsact_chain_head_change;
-	q->block_info.chain_head_change_priv = &dev->ingress_cl_list;
+	q->block_info.chain_head_change_priv = &q->miniqp;
 
 	err = tcf_block_get_ext(&q->block, sch, &q->block_info);
 	if (err)
@@ -128,6 +131,8 @@ struct clsact_sched_data {
 	struct tcf_block *egress_block;
 	struct tcf_block_ext_info ingress_block_info;
 	struct tcf_block_ext_info egress_block_info;
+	struct mini_Qdisc_pair miniqp_ingress;
+	struct mini_Qdisc_pair miniqp_egress;
 };
 
 static unsigned long clsact_find(struct Qdisc *sch, u32 classid)
@@ -167,17 +172,21 @@ static int clsact_init(struct Qdisc *sch, struct nlattr *opt)
 	struct net_device *dev = qdisc_dev(sch);
 	int err;
 
+	mini_qdisc_pair_init(&q->miniqp_ingress, sch, &dev->miniq_ingress);
+
 	q->ingress_block_info.binder_type = TCF_BLOCK_BINDER_TYPE_CLSACT_INGRESS;
 	q->ingress_block_info.chain_head_change = clsact_chain_head_change;
-	q->ingress_block_info.chain_head_change_priv = &dev->ingress_cl_list;
+	q->ingress_block_info.chain_head_change_priv = &q->miniqp_ingress;
 
 	err = tcf_block_get_ext(&q->ingress_block, sch, &q->ingress_block_info);
 	if (err)
 		return err;
 
+	mini_qdisc_pair_init(&q->miniqp_egress, sch, &dev->miniq_egress);
+
 	q->egress_block_info.binder_type = TCF_BLOCK_BINDER_TYPE_CLSACT_EGRESS;
 	q->egress_block_info.chain_head_change = clsact_chain_head_change;
-	q->egress_block_info.chain_head_change_priv = &dev->egress_cl_list;
+	q->egress_block_info.chain_head_change_priv = &q->miniqp_egress;
 
 	err = tcf_block_get_ext(&q->egress_block, sch, &q->egress_block_info);
 	if (err)
-- 
2.9.5
