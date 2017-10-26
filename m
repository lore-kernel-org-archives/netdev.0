From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2] net: core: introduce mini_Qdisc and eliminate usage of tp->q for clsact fastpath
Date: Thu, 26 Oct 2017 11:41:03 +0200
Message-ID: <20171026094103.10164-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com, edumazet@google.com, daniel@iogearbox.net,
        alexander.h.duyck@intel.com, willemb@google.com,
        john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:50529 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751027AbdJZJlG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 05:41:06 -0400
Received: by mail-wr0-f195.google.com with SMTP id p96so2533709wrb.7
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 02:41:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

In sch_handle_egress and sch_handle_ingress tp->q is used only in order
to update stats. So stats and filter list are the only things that are
needed in clsact qdisc fastpath processing. Introduce new mini_Qdisc
struct to hold those items. This removes need for tp->q usage without
added overhead.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
v1->v2:
- Use dev instead of skb->dev in sch_handle_egress as pointed out by Daniel
- Fixed synchronize_rcu_bh() in mini_qdisc_disable and commented
---
 include/linux/netdevice.h |  9 ++++++---
 include/net/pkt_cls.h     |  1 +
 include/net/sch_generic.h | 49 +++++++++++++++++++++++++++++++++++++++++++++++
 net/core/dev.c            | 21 ++++++++++++--------
 net/sched/cls_api.c       | 23 +++++++++++++++++-----
 net/sched/sch_ingress.c   | 40 +++++++++++++++++++++++++++++---------
 6 files changed, 118 insertions(+), 25 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 6c7960c8..f0bdaf7 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1558,6 +1558,8 @@ enum netdev_priv_flags {
  *
  *	@rx_handler:		handler for received packets
  *	@rx_handler_data: 	XXX: need comments on this one
+ *	@miniq_ingress:		ingress/clsact qdisc specific data for
+ *				ingress processing
  *	@ingress_queue:		XXX: need comments on this one
  *	@broadcast:		hw bcast address
  *
@@ -1575,7 +1577,8 @@ enum netdev_priv_flags {
  *	@tx_global_lock: 	XXX: need comments on this one
  *
  *	@xps_maps:	XXX: need comments on this one
- *
+ *	@miniq_egress:		clsact qdisc specific data for
+ *				egress processing
  *	@watchdog_timeo:	Represents the timeout that is used by
  *				the watchdog (see dev_watchdog())
  *	@watchdog_timer:	List of timers
@@ -1794,7 +1797,7 @@ struct net_device {
 	void __rcu		*rx_handler_data;
 
 #ifdef CONFIG_NET_CLS_ACT
-	struct tcf_proto __rcu  *ingress_cl_list;
+	struct mini_Qdisc __rcu	*miniq_ingress;
 #endif
 	struct netdev_queue __rcu *ingress_queue;
 #ifdef CONFIG_NETFILTER_INGRESS
@@ -1825,7 +1828,7 @@ struct net_device {
 	struct xps_dev_maps __rcu *xps_maps;
 #endif
 #ifdef CONFIG_NET_CLS_ACT
-	struct tcf_proto __rcu  *egress_cl_list;
+	struct mini_Qdisc __rcu	*miniq_egress;
 #endif
 
 	/* These may be needed for future network-power-down code. */
diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 04caa24..0b2e3a7 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -25,6 +25,7 @@ enum tcf_block_binder_type {
 
 struct tcf_block_ext_info {
 	enum tcf_block_binder_type binder_type;
+	tcf_chain_change_empty_t *chain_change_empty;
 };
 
 struct tcf_block_cb;
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 031dffd..3d5a9e2 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -143,6 +143,40 @@ static inline int qdisc_avail_bulklimit(const struct netdev_queue *txq)
 #endif
 }
 
+/* Mini Qdisc serves for specific needs of ingress/clsact Qdisc.
+ * The fast path only needs to access filter list and to update stats
+ */
+struct mini_Qdisc {
+	struct tcf_proto __rcu *filter_list;
+	struct gnet_stats_basic_cpu __percpu *cpu_bstats;
+	struct gnet_stats_queue	__percpu *cpu_qstats;
+	struct mini_Qdisc __rcu **p_miniq;
+};
+
+static inline void mini_qdisc_init(struct mini_Qdisc *miniq,
+				   struct Qdisc *qdisc,
+				   struct mini_Qdisc __rcu **p_miniq)
+{
+	miniq->cpu_bstats = qdisc->cpu_bstats;
+	miniq->cpu_qstats = qdisc->cpu_qstats;
+	miniq->p_miniq = p_miniq;
+}
+
+static inline void mini_qdisc_enable(struct mini_Qdisc *miniq)
+{
+	rcu_assign_pointer(*miniq->p_miniq, miniq);
+}
+
+static inline void mini_qdisc_disable(struct mini_Qdisc *miniq)
+{
+	RCU_INIT_POINTER(*miniq->p_miniq, NULL);
+	/* We need to make sure that readers
+	 * won't see miniq->filter_list == NULL because the check
+	 * is avoided in the fast path.
+	 */
+	synchronize_rcu_bh();
+}
+
 struct Qdisc_class_ops {
 	/* Child qdisc manipulation */
 	struct netdev_queue *	(*select_queue)(struct Qdisc *, struct tcmsg *);
@@ -259,9 +293,13 @@ struct qdisc_skb_cb {
 	unsigned char		data[QDISC_CB_PRIV_LEN];
 };
 
+typedef void tcf_chain_change_empty_t(struct tcf_proto __rcu **p_filter_chain,
+				      bool empty);
+
 struct tcf_chain {
 	struct tcf_proto __rcu *filter_chain;
 	struct tcf_proto __rcu **p_filter_chain;
+	tcf_chain_change_empty_t *chain_change_empty;
 	struct list_head list;
 	struct tcf_block *block;
 	u32 index; /* chain index */
@@ -605,6 +643,12 @@ static inline void qdisc_bstats_cpu_update(struct Qdisc *sch,
 	bstats_cpu_update(this_cpu_ptr(sch->cpu_bstats), skb);
 }
 
+static inline void mini_qdisc_bstats_cpu_update(struct mini_Qdisc *miniq,
+						const struct sk_buff *skb)
+{
+	bstats_cpu_update(this_cpu_ptr(miniq->cpu_bstats), skb);
+}
+
 static inline void qdisc_bstats_update(struct Qdisc *sch,
 				       const struct sk_buff *skb)
 {
@@ -648,6 +692,11 @@ static inline void qdisc_qstats_cpu_drop(struct Qdisc *sch)
 	this_cpu_inc(sch->cpu_qstats->drops);
 }
 
+static inline void mini_qdisc_qstats_cpu_drop(struct mini_Qdisc *miniq)
+{
+	this_cpu_inc(miniq->cpu_qstats->drops);
+}
+
 static inline void qdisc_qstats_overlimit(struct Qdisc *sch)
 {
 	sch->qstats.overlimits++;
diff --git a/net/core/dev.c b/net/core/dev.c
index 24ac908..44ea1c3 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3274,14 +3274,16 @@ EXPORT_SYMBOL(dev_loopback_xmit);
 static struct sk_buff *
 sch_handle_egress(struct sk_buff *skb, int *ret, struct net_device *dev)
 {
-	struct tcf_proto *cl = rcu_dereference_bh(dev->egress_cl_list);
+	struct mini_Qdisc *miniq = rcu_dereference_bh(dev->miniq_egress);
 	struct tcf_result cl_res;
+	struct tcf_proto *cl;
 
-	if (!cl)
+	if (!miniq)
 		return skb;
+	cl = rcu_dereference_bh(miniq->filter_list);
 
 	/* qdisc_skb_cb(skb)->pkt_len was already set by the caller. */
-	qdisc_bstats_cpu_update(cl->q, skb);
+	mini_qdisc_bstats_cpu_update(miniq, skb);
 
 	switch (tcf_classify(skb, cl, &cl_res, false)) {
 	case TC_ACT_OK:
@@ -3289,7 +3291,7 @@ sch_handle_egress(struct sk_buff *skb, int *ret, struct net_device *dev)
 		skb->tc_index = TC_H_MIN(cl_res.classid);
 		break;
 	case TC_ACT_SHOT:
-		qdisc_qstats_cpu_drop(cl->q);
+		mini_qdisc_qstats_cpu_drop(miniq);
 		*ret = NET_XMIT_DROP;
 		kfree_skb(skb);
 		return NULL;
@@ -4189,16 +4191,19 @@ sch_handle_ingress(struct sk_buff *skb, struct packet_type **pt_prev, int *ret,
 		   struct net_device *orig_dev)
 {
 #ifdef CONFIG_NET_CLS_ACT
-	struct tcf_proto *cl = rcu_dereference_bh(skb->dev->ingress_cl_list);
+	struct mini_Qdisc *miniq = rcu_dereference_bh(skb->dev->miniq_ingress);
 	struct tcf_result cl_res;
+	struct tcf_proto *cl;
 
 	/* If there's at least one ingress present somewhere (so
 	 * we get here via enabled static key), remaining devices
 	 * that are not configured with an ingress qdisc will bail
 	 * out here.
 	 */
-	if (!cl)
+	if (!miniq)
 		return skb;
+	cl = rcu_dereference_bh(miniq->filter_list);
+
 	if (*pt_prev) {
 		*ret = deliver_skb(skb, *pt_prev, orig_dev);
 		*pt_prev = NULL;
@@ -4206,7 +4211,7 @@ sch_handle_ingress(struct sk_buff *skb, struct packet_type **pt_prev, int *ret,
 
 	qdisc_skb_cb(skb)->pkt_len = skb->len;
 	skb->tc_at_ingress = 1;
-	qdisc_bstats_cpu_update(cl->q, skb);
+	mini_qdisc_bstats_cpu_update(miniq, skb);
 
 	switch (tcf_classify(skb, cl, &cl_res, false)) {
 	case TC_ACT_OK:
@@ -4214,7 +4219,7 @@ sch_handle_ingress(struct sk_buff *skb, struct packet_type **pt_prev, int *ret,
 		skb->tc_index = TC_H_MIN(cl_res.classid);
 		break;
 	case TC_ACT_SHOT:
-		qdisc_qstats_cpu_drop(cl->q);
+		mini_qdisc_qstats_cpu_drop(miniq);
 		kfree_skb(skb);
 		return NULL;
 	case TC_ACT_STOLEN:
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 0e96cda..dfff12b 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -190,8 +190,11 @@ static void tcf_chain_flush(struct tcf_chain *chain)
 {
 	struct tcf_proto *tp;
 
-	if (chain->p_filter_chain)
+	if (chain->p_filter_chain) {
+		if (chain->chain_change_empty)
+			chain->chain_change_empty(chain->p_filter_chain, true);
 		RCU_INIT_POINTER(*chain->p_filter_chain, NULL);
+	}
 	while ((tp = rtnl_dereference(chain->filter_chain)) != NULL) {
 		RCU_INIT_POINTER(chain->filter_chain, tp->next);
 		tcf_chain_put(chain);
@@ -235,9 +238,11 @@ EXPORT_SYMBOL(tcf_chain_put);
 
 static void
 tcf_chain_filter_chain_ptr_set(struct tcf_chain *chain,
-			       struct tcf_proto __rcu **p_filter_chain)
+			       struct tcf_proto __rcu **p_filter_chain,
+			       struct tcf_block_ext_info *ei)
 {
 	chain->p_filter_chain = p_filter_chain;
+	chain->chain_change_empty = ei->chain_change_empty;
 }
 
 static void tcf_block_offload_cmd(struct tcf_block *block, struct Qdisc *q,
@@ -286,7 +291,7 @@ int tcf_block_get_ext(struct tcf_block **p_block,
 		err = -ENOMEM;
 		goto err_chain_create;
 	}
-	tcf_chain_filter_chain_ptr_set(chain, p_filter_chain);
+	tcf_chain_filter_chain_ptr_set(chain, p_filter_chain, ei);
 	block->net = qdisc_net(q);
 	block->q = q;
 	tcf_block_offload_bind(block, q, ei);
@@ -528,8 +533,13 @@ static void tcf_chain_tp_insert(struct tcf_chain *chain,
 				struct tcf_proto *tp)
 {
 	if (chain->p_filter_chain &&
-	    *chain_info->pprev == chain->filter_chain)
+	    *chain_info->pprev == chain->filter_chain) {
+		bool was_null = *chain->p_filter_chain == NULL;
+
 		rcu_assign_pointer(*chain->p_filter_chain, tp);
+		if (was_null && chain->chain_change_empty)
+			chain->chain_change_empty(chain->p_filter_chain, false);
+	}
 	RCU_INIT_POINTER(tp->next, tcf_chain_tp_prev(chain_info));
 	rcu_assign_pointer(*chain_info->pprev, tp);
 	tcf_chain_hold(chain);
@@ -541,8 +551,11 @@ static void tcf_chain_tp_remove(struct tcf_chain *chain,
 {
 	struct tcf_proto *next = rtnl_dereference(chain_info->next);
 
-	if (chain->p_filter_chain && tp == chain->filter_chain)
+	if (chain->p_filter_chain && tp == chain->filter_chain) {
+		if (!next && chain->chain_change_empty)
+			chain->chain_change_empty(chain->p_filter_chain, true);
 		RCU_INIT_POINTER(*chain->p_filter_chain, next);
+	}
 	RCU_INIT_POINTER(*chain_info->pprev, next);
 	tcf_chain_put(chain);
 }
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index b599db2..45f6e43 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -21,6 +21,7 @@
 struct ingress_sched_data {
 	struct tcf_block *block;
 	struct tcf_block_ext_info block_info;
+	struct mini_Qdisc miniq;
 };
 
 static struct Qdisc *ingress_leaf(struct Qdisc *sch, unsigned long arg)
@@ -54,6 +55,19 @@ static struct tcf_block *ingress_tcf_block(struct Qdisc *sch, unsigned long cl)
 	return q->block;
 }
 
+static void clsact_chain_change_empty(struct tcf_proto __rcu **p_filter_list,
+				      bool empty)
+{
+	struct mini_Qdisc *miniq = container_of(p_filter_list,
+						struct mini_Qdisc,
+						filter_list);
+
+	if (empty)
+		mini_qdisc_disable(miniq);
+	else
+		mini_qdisc_enable(miniq);
+}
+
 static int ingress_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct ingress_sched_data *q = qdisc_priv(sch);
@@ -61,8 +75,10 @@ static int ingress_init(struct Qdisc *sch, struct nlattr *opt)
 	int err;
 
 	q->block_info.binder_type = TCF_BLOCK_BINDER_TYPE_CLSACT_INGRESS;
+	q->block_info.chain_change_empty = clsact_chain_change_empty;
 
-	err = tcf_block_get_ext(&q->block, &dev->ingress_cl_list,
+	mini_qdisc_init(&q->miniq, sch, &dev->miniq_ingress);
+	err = tcf_block_get_ext(&q->block, &q->miniq.filter_list,
 				sch, &q->block_info);
 	if (err)
 		return err;
@@ -76,9 +92,8 @@ static int ingress_init(struct Qdisc *sch, struct nlattr *opt)
 static void ingress_destroy(struct Qdisc *sch)
 {
 	struct ingress_sched_data *q = qdisc_priv(sch);
-	struct net_device *dev = qdisc_dev(sch);
 
-	tcf_block_put_ext(q->block, &dev->ingress_cl_list,
+	tcf_block_put_ext(q->block, &q->miniq.filter_list,
 			  sch, &q->block_info);
 	net_dec_ingress_queue();
 }
@@ -122,6 +137,8 @@ struct clsact_sched_data {
 	struct tcf_block *egress_block;
 	struct tcf_block_ext_info ingress_block_info;
 	struct tcf_block_ext_info egress_block_info;
+	struct mini_Qdisc miniq_ingress;
+	struct mini_Qdisc miniq_egress;
 };
 
 static unsigned long clsact_find(struct Qdisc *sch, u32 classid)
@@ -162,15 +179,21 @@ static int clsact_init(struct Qdisc *sch, struct nlattr *opt)
 	int err;
 
 	q->ingress_block_info.binder_type = TCF_BLOCK_BINDER_TYPE_CLSACT_INGRESS;
+	q->ingress_block_info.chain_change_empty = clsact_chain_change_empty;
 
-	err = tcf_block_get_ext(&q->ingress_block, &dev->ingress_cl_list,
+	mini_qdisc_init(&q->miniq_ingress, sch, &dev->miniq_ingress);
+	err = tcf_block_get_ext(&q->ingress_block,
+				&q->miniq_ingress.filter_list,
 				sch, &q->ingress_block_info);
 	if (err)
 		return err;
 
 	q->egress_block_info.binder_type = TCF_BLOCK_BINDER_TYPE_CLSACT_EGRESS;
+	q->egress_block_info.chain_change_empty = clsact_chain_change_empty;
 
-	err = tcf_block_get_ext(&q->egress_block, &dev->egress_cl_list,
+	mini_qdisc_init(&q->miniq_egress, sch, &dev->miniq_egress);
+	err = tcf_block_get_ext(&q->egress_block,
+				&q->miniq_egress.filter_list,
 				sch, &q->egress_block_info);
 	if (err)
 		goto err_egress_block_get;
@@ -183,7 +206,7 @@ static int clsact_init(struct Qdisc *sch, struct nlattr *opt)
 	return 0;
 
 err_egress_block_get:
-	tcf_block_put_ext(q->ingress_block, &dev->ingress_cl_list,
+	tcf_block_put_ext(q->ingress_block, &q->miniq_ingress.filter_list,
 			  sch, &q->ingress_block_info);
 	return err;
 }
@@ -191,11 +214,10 @@ static int clsact_init(struct Qdisc *sch, struct nlattr *opt)
 static void clsact_destroy(struct Qdisc *sch)
 {
 	struct clsact_sched_data *q = qdisc_priv(sch);
-	struct net_device *dev = qdisc_dev(sch);
 
-	tcf_block_put_ext(q->egress_block, &dev->egress_cl_list,
+	tcf_block_put_ext(q->egress_block, &q->miniq_egress.filter_list,
 			  sch, &q->egress_block_info);
-	tcf_block_put_ext(q->ingress_block, &dev->ingress_cl_list,
+	tcf_block_put_ext(q->ingress_block, &q->miniq_ingress.filter_list,
 			  sch, &q->ingress_block_info);
 
 	net_dec_ingress_queue();
-- 
2.9.5
