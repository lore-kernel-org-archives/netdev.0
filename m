From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 02/10] net: sched: introduce tcf block infractructure
Date: Tue, 16 May 2017 19:27:54 +0200
Message-ID: <20170516172802.1317-3-jiri@resnulli.us>
References: <20170516172802.1317-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        dsa@cumulusnetworks.com, edumazet@google.com,
        stephen@networkplumber.org, daniel@iogearbox.net,
        alexander.h.duyck@intel.com, simon.horman@netronome.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34286 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752713AbdEPR2J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 13:28:09 -0400
Received: by mail-wm0-f67.google.com with SMTP id d127so39670637wmf.1
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 10:28:08 -0700 (PDT)
In-Reply-To: <20170516172802.1317-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Currently, the filter chains are direcly put into the private structures
of qdiscs. In order to be able to have multiple chains per qdisc and to
allow filter chains sharing among qdiscs, there is a need for common
object that would hold the chains. This introduces such object and calls
it "tcf_block".

Helpers to get and put the blocks are provided to be called from
individual qdisc code. Also, the original filter_list pointers are left
in qdisc privs to allow the entry into tcf_block processing without any
added overhead of possible multiple pointer dereference on fast path.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/pkt_cls.h     | 13 ++++++++--
 include/net/sch_generic.h |  7 +++++-
 net/sched/cls_api.c       | 48 +++++++++++++++++++++++++++++--------
 net/sched/sch_api.c       |  2 +-
 net/sched/sch_atm.c       | 27 ++++++++++++++-------
 net/sched/sch_cbq.c       | 19 ++++++++++-----
 net/sched/sch_drr.c       | 13 ++++++----
 net/sched/sch_dsmark.c    | 17 ++++++++-----
 net/sched/sch_fq_codel.c  | 15 ++++++++----
 net/sched/sch_hfsc.c      | 19 ++++++++++-----
 net/sched/sch_htb.c       | 26 +++++++++++++-------
 net/sched/sch_ingress.c   | 61 ++++++++++++++++++++++++++++++++++-------------
 net/sched/sch_multiq.c    | 14 +++++++----
 net/sched/sch_prio.c      | 17 +++++++++----
 net/sched/sch_qfq.c       | 14 +++++++----
 net/sched/sch_sfb.c       | 15 ++++++++----
 net/sched/sch_sfq.c       | 15 ++++++++----
 17 files changed, 243 insertions(+), 99 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index cb74506..e56e715 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -18,12 +18,21 @@ int register_tcf_proto_ops(struct tcf_proto_ops *ops);
 int unregister_tcf_proto_ops(struct tcf_proto_ops *ops);
 
 #ifdef CONFIG_NET_CLS
-void tcf_destroy_chain(struct tcf_proto __rcu **fl);
+int tcf_block_get(struct tcf_block **p_block,
+		  struct tcf_proto __rcu **p_filter_chain);
+void tcf_block_put(struct tcf_block *block);
 int tcf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 		 struct tcf_result *res, bool compat_mode);
 
 #else
-static inline void tcf_destroy_chain(struct tcf_proto __rcu **fl)
+static inline
+int tcf_block_get(struct tcf_block **p_block,
+		  struct tcf_proto __rcu **p_filter_chain)
+{
+	return 0;
+}
+
+static inline void tcf_block_put(struct tcf_block *block)
 {
 }
 
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 22e5209..98cf2f2 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -153,7 +153,7 @@ struct Qdisc_class_ops {
 	void			(*walk)(struct Qdisc *, struct qdisc_walker * arg);
 
 	/* Filter manipulation */
-	struct tcf_proto __rcu ** (*tcf_chain)(struct Qdisc *, unsigned long);
+	struct tcf_block *	(*tcf_block)(struct Qdisc *, unsigned long);
 	bool			(*tcf_cl_offload)(u32 classid);
 	unsigned long		(*bind_tcf)(struct Qdisc *, unsigned long,
 					u32 classid);
@@ -236,6 +236,7 @@ struct tcf_proto {
 	struct Qdisc		*q;
 	void			*data;
 	const struct tcf_proto_ops	*ops;
+	struct tcf_block	*block;
 	struct rcu_head		rcu;
 };
 
@@ -247,6 +248,10 @@ struct qdisc_skb_cb {
 	unsigned char		data[QDISC_CB_PRIV_LEN];
 };
 
+struct tcf_block {
+	struct tcf_proto __rcu **p_filter_chain;
+};
+
 static inline void qdisc_cb_private_validate(const struct sk_buff *skb, int sz)
 {
 	struct qdisc_skb_cb *qcb;
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index a97af61..42fdc8a 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -129,7 +129,8 @@ static inline u32 tcf_auto_prio(struct tcf_proto *tp)
 }
 
 static struct tcf_proto *tcf_proto_create(const char *kind, u32 protocol,
-					  u32 prio, u32 parent, struct Qdisc *q)
+					  u32 prio, u32 parent, struct Qdisc *q,
+					  struct tcf_block *block)
 {
 	struct tcf_proto *tp;
 	int err;
@@ -165,6 +166,7 @@ static struct tcf_proto *tcf_proto_create(const char *kind, u32 protocol,
 	tp->prio = prio;
 	tp->classid = parent;
 	tp->q = q;
+	tp->block = block;
 
 	err = tp->ops->init(tp);
 	if (err) {
@@ -185,7 +187,7 @@ static void tcf_proto_destroy(struct tcf_proto *tp)
 	kfree_rcu(tp, rcu);
 }
 
-void tcf_destroy_chain(struct tcf_proto __rcu **fl)
+static void tcf_destroy_chain(struct tcf_proto __rcu **fl)
 {
 	struct tcf_proto *tp;
 
@@ -194,7 +196,28 @@ void tcf_destroy_chain(struct tcf_proto __rcu **fl)
 		tcf_proto_destroy(tp);
 	}
 }
-EXPORT_SYMBOL(tcf_destroy_chain);
+
+int tcf_block_get(struct tcf_block **p_block,
+		  struct tcf_proto __rcu **p_filter_chain)
+{
+	struct tcf_block *block = kzalloc(sizeof(*block), GFP_KERNEL);
+
+	if (!block)
+		return -ENOMEM;
+	block->p_filter_chain = p_filter_chain;
+	*p_block = block;
+	return 0;
+}
+EXPORT_SYMBOL(tcf_block_get);
+
+void tcf_block_put(struct tcf_block *block)
+{
+	if (!block)
+		return;
+	tcf_destroy_chain(block->p_filter_chain);
+	kfree(block);
+}
+EXPORT_SYMBOL(tcf_block_put);
 
 /* Main classifier routine: scans classifier chain attached
  * to this qdisc, (optionally) tests for protocol and asks
@@ -254,6 +277,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
 	struct Qdisc  *q;
 	struct tcf_proto __rcu **back;
 	struct tcf_proto __rcu **chain;
+	struct tcf_block *block;
 	struct tcf_proto *next;
 	struct tcf_proto *tp;
 	const struct Qdisc_class_ops *cops;
@@ -322,7 +346,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
 	if (!cops)
 		return -EINVAL;
 
-	if (cops->tcf_chain == NULL)
+	if (!cops->tcf_block)
 		return -EOPNOTSUPP;
 
 	/* Do we search for filter, attached to class? */
@@ -333,11 +357,13 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
 	}
 
 	/* And the last stroke */
-	chain = cops->tcf_chain(q, cl);
-	if (chain == NULL) {
+	block = cops->tcf_block(q, cl);
+	if (!block) {
 		err = -EINVAL;
 		goto errout;
 	}
+	chain = block->p_filter_chain;
+
 	if (n->nlmsg_type == RTM_DELTFILTER && prio == 0) {
 		tfilter_notify_chain(net, skb, n, chain, RTM_DELTFILTER);
 		tcf_destroy_chain(chain);
@@ -381,7 +407,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
 			nprio = TC_H_MAJ(tcf_auto_prio(rtnl_dereference(*back)));
 
 		tp = tcf_proto_create(nla_data(tca[TCA_KIND]),
-				      protocol, nprio, parent, q);
+				      protocol, nprio, parent, q, block);
 		if (IS_ERR(tp)) {
 			err = PTR_ERR(tp);
 			goto errout;
@@ -550,6 +576,7 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 	int s_t;
 	struct net_device *dev;
 	struct Qdisc *q;
+	struct tcf_block *block;
 	struct tcf_proto *tp, __rcu **chain;
 	struct tcmsg *tcm = nlmsg_data(cb->nlh);
 	unsigned long cl = 0;
@@ -571,16 +598,17 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 	cops = q->ops->cl_ops;
 	if (!cops)
 		goto errout;
-	if (cops->tcf_chain == NULL)
+	if (!cops->tcf_block)
 		goto errout;
 	if (TC_H_MIN(tcm->tcm_parent)) {
 		cl = cops->get(q, tcm->tcm_parent);
 		if (cl == 0)
 			goto errout;
 	}
-	chain = cops->tcf_chain(q, cl);
-	if (chain == NULL)
+	block = cops->tcf_block(q, cl);
+	if (!block)
 		goto errout;
+	chain = block->p_filter_chain;
 
 	s_t = cb->args[0];
 
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index a3bcd97..5d95401 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -163,7 +163,7 @@ int register_qdisc(struct Qdisc_ops *qops)
 		if (!(cops->get && cops->put && cops->walk && cops->leaf))
 			goto out_einval;
 
-		if (cops->tcf_chain && !(cops->bind_tcf && cops->unbind_tcf))
+		if (cops->tcf_block && !(cops->bind_tcf && cops->unbind_tcf))
 			goto out_einval;
 	}
 
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 89d32fa..f435546 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -43,6 +43,7 @@
 struct atm_flow_data {
 	struct Qdisc		*q;	/* FIFO, TBF, etc. */
 	struct tcf_proto __rcu	*filter_list;
+	struct tcf_block	*block;
 	struct atm_vcc		*vcc;	/* VCC; NULL if VCC is closed */
 	void			(*old_pop)(struct atm_vcc *vcc,
 					   struct sk_buff *skb); /* chaining */
@@ -143,7 +144,7 @@ static void atm_tc_put(struct Qdisc *sch, unsigned long cl)
 	list_del_init(&flow->list);
 	pr_debug("atm_tc_put: qdisc %p\n", flow->q);
 	qdisc_destroy(flow->q);
-	tcf_destroy_chain(&flow->filter_list);
+	tcf_block_put(flow->block);
 	if (flow->sock) {
 		pr_debug("atm_tc_put: f_count %ld\n",
 			file_count(flow->sock->file));
@@ -274,7 +275,13 @@ static int atm_tc_change(struct Qdisc *sch, u32 classid, u32 parent,
 		error = -ENOBUFS;
 		goto err_out;
 	}
-	RCU_INIT_POINTER(flow->filter_list, NULL);
+
+	error = tcf_block_get(&flow->block, &flow->filter_list);
+	if (error) {
+		kfree(flow);
+		goto err_out;
+	}
+
 	flow->q = qdisc_create_dflt(sch->dev_queue, &pfifo_qdisc_ops, classid);
 	if (!flow->q)
 		flow->q = &noop_qdisc;
@@ -346,14 +353,13 @@ static void atm_tc_walk(struct Qdisc *sch, struct qdisc_walker *walker)
 	}
 }
 
-static struct tcf_proto __rcu **atm_tc_find_tcf(struct Qdisc *sch,
-						unsigned long cl)
+static struct tcf_block *atm_tc_tcf_block(struct Qdisc *sch, unsigned long cl)
 {
 	struct atm_qdisc_data *p = qdisc_priv(sch);
 	struct atm_flow_data *flow = (struct atm_flow_data *)cl;
 
 	pr_debug("atm_tc_find_tcf(sch %p,[qdisc %p],flow %p)\n", sch, p, flow);
-	return flow ? &flow->filter_list : &p->link.filter_list;
+	return flow ? flow->block : p->link.block;
 }
 
 /* --------------------------- Qdisc operations ---------------------------- */
@@ -524,6 +530,7 @@ static struct sk_buff *atm_tc_peek(struct Qdisc *sch)
 static int atm_tc_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct atm_qdisc_data *p = qdisc_priv(sch);
+	int err;
 
 	pr_debug("atm_tc_init(sch %p,[qdisc %p],opt %p)\n", sch, p, opt);
 	INIT_LIST_HEAD(&p->flows);
@@ -534,7 +541,11 @@ static int atm_tc_init(struct Qdisc *sch, struct nlattr *opt)
 	if (!p->link.q)
 		p->link.q = &noop_qdisc;
 	pr_debug("atm_tc_init: link (%p) qdisc %p\n", &p->link, p->link.q);
-	RCU_INIT_POINTER(p->link.filter_list, NULL);
+
+	err = tcf_block_get(&p->link.block, &p->link.filter_list);
+	if (err)
+		return err;
+
 	p->link.vcc = NULL;
 	p->link.sock = NULL;
 	p->link.classid = sch->handle;
@@ -561,7 +572,7 @@ static void atm_tc_destroy(struct Qdisc *sch)
 
 	pr_debug("atm_tc_destroy(sch %p,[qdisc %p])\n", sch, p);
 	list_for_each_entry(flow, &p->flows, list)
-		tcf_destroy_chain(&flow->filter_list);
+		tcf_block_put(flow->block);
 
 	list_for_each_entry_safe(flow, tmp, &p->flows, list) {
 		if (flow->ref > 1)
@@ -646,7 +657,7 @@ static const struct Qdisc_class_ops atm_class_ops = {
 	.change		= atm_tc_change,
 	.delete		= atm_tc_delete,
 	.walk		= atm_tc_walk,
-	.tcf_chain	= atm_tc_find_tcf,
+	.tcf_block	= atm_tc_tcf_block,
 	.bind_tcf	= atm_tc_bind_filter,
 	.unbind_tcf	= atm_tc_put,
 	.dump		= atm_tc_dump_class,
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index c543ea3..8dd6d0a 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -127,6 +127,7 @@ struct cbq_class {
 	struct tc_cbq_xstats	xstats;
 
 	struct tcf_proto __rcu	*filter_list;
+	struct tcf_block	*block;
 
 	int			refcnt;
 	int			filters;
@@ -1405,7 +1406,7 @@ static void cbq_destroy_class(struct Qdisc *sch, struct cbq_class *cl)
 
 	WARN_ON(cl->filters);
 
-	tcf_destroy_chain(&cl->filter_list);
+	tcf_block_put(cl->block);
 	qdisc_destroy(cl->q);
 	qdisc_put_rtab(cl->R_tab);
 	gen_kill_estimator(&cl->rate_est);
@@ -1430,7 +1431,7 @@ static void cbq_destroy(struct Qdisc *sch)
 	 */
 	for (h = 0; h < q->clhash.hashsize; h++) {
 		hlist_for_each_entry(cl, &q->clhash.hash[h], common.hnode)
-			tcf_destroy_chain(&cl->filter_list);
+			tcf_block_put(cl->block);
 	}
 	for (h = 0; h < q->clhash.hashsize; h++) {
 		hlist_for_each_entry_safe(cl, next, &q->clhash.hash[h],
@@ -1585,12 +1586,19 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct nlattr **t
 	if (cl == NULL)
 		goto failure;
 
+	err = tcf_block_get(&cl->block, &cl->filter_list);
+	if (err) {
+		kfree(cl);
+		return err;
+	}
+
 	if (tca[TCA_RATE]) {
 		err = gen_new_estimator(&cl->bstats, NULL, &cl->rate_est,
 					NULL,
 					qdisc_root_sleeping_running(sch),
 					tca[TCA_RATE]);
 		if (err) {
+			tcf_block_put(cl->block);
 			kfree(cl);
 			goto failure;
 		}
@@ -1688,8 +1696,7 @@ static int cbq_delete(struct Qdisc *sch, unsigned long arg)
 	return 0;
 }
 
-static struct tcf_proto __rcu **cbq_find_tcf(struct Qdisc *sch,
-					     unsigned long arg)
+static struct tcf_block *cbq_tcf_block(struct Qdisc *sch, unsigned long arg)
 {
 	struct cbq_sched_data *q = qdisc_priv(sch);
 	struct cbq_class *cl = (struct cbq_class *)arg;
@@ -1697,7 +1704,7 @@ static struct tcf_proto __rcu **cbq_find_tcf(struct Qdisc *sch,
 	if (cl == NULL)
 		cl = &q->link;
 
-	return &cl->filter_list;
+	return cl->block;
 }
 
 static unsigned long cbq_bind_filter(struct Qdisc *sch, unsigned long parent,
@@ -1756,7 +1763,7 @@ static const struct Qdisc_class_ops cbq_class_ops = {
 	.change		=	cbq_change_class,
 	.delete		=	cbq_delete,
 	.walk		=	cbq_walk,
-	.tcf_chain	=	cbq_find_tcf,
+	.tcf_block	=	cbq_tcf_block,
 	.bind_tcf	=	cbq_bind_filter,
 	.unbind_tcf	=	cbq_unbind_filter,
 	.dump		=	cbq_dump_class,
diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
index 446d79b..5db2a28 100644
--- a/net/sched/sch_drr.c
+++ b/net/sched/sch_drr.c
@@ -36,6 +36,7 @@ struct drr_class {
 struct drr_sched {
 	struct list_head		active;
 	struct tcf_proto __rcu		*filter_list;
+	struct tcf_block		*block;
 	struct Qdisc_class_hash		clhash;
 };
 
@@ -190,15 +191,14 @@ static void drr_put_class(struct Qdisc *sch, unsigned long arg)
 		drr_destroy_class(sch, cl);
 }
 
-static struct tcf_proto __rcu **drr_tcf_chain(struct Qdisc *sch,
-					      unsigned long cl)
+static struct tcf_block *drr_tcf_block(struct Qdisc *sch, unsigned long cl)
 {
 	struct drr_sched *q = qdisc_priv(sch);
 
 	if (cl)
 		return NULL;
 
-	return &q->filter_list;
+	return q->block;
 }
 
 static unsigned long drr_bind_tcf(struct Qdisc *sch, unsigned long parent,
@@ -431,6 +431,9 @@ static int drr_init_qdisc(struct Qdisc *sch, struct nlattr *opt)
 	struct drr_sched *q = qdisc_priv(sch);
 	int err;
 
+	err = tcf_block_get(&q->block, &q->filter_list);
+	if (err)
+		return err;
 	err = qdisc_class_hash_init(&q->clhash);
 	if (err < 0)
 		return err;
@@ -462,7 +465,7 @@ static void drr_destroy_qdisc(struct Qdisc *sch)
 	struct hlist_node *next;
 	unsigned int i;
 
-	tcf_destroy_chain(&q->filter_list);
+	tcf_block_put(q->block);
 
 	for (i = 0; i < q->clhash.hashsize; i++) {
 		hlist_for_each_entry_safe(cl, next, &q->clhash.hash[i],
@@ -477,7 +480,7 @@ static const struct Qdisc_class_ops drr_class_ops = {
 	.delete		= drr_delete_class,
 	.get		= drr_get_class,
 	.put		= drr_put_class,
-	.tcf_chain	= drr_tcf_chain,
+	.tcf_block	= drr_tcf_block,
 	.bind_tcf	= drr_bind_tcf,
 	.unbind_tcf	= drr_unbind_tcf,
 	.graft		= drr_graft_class,
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 7bc638d..ba45102 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -44,6 +44,7 @@ struct mask_value {
 struct dsmark_qdisc_data {
 	struct Qdisc		*q;
 	struct tcf_proto __rcu	*filter_list;
+	struct tcf_block	*block;
 	struct mask_value	*mv;
 	u16			indices;
 	u8			set_tc_index;
@@ -183,11 +184,11 @@ static void dsmark_walk(struct Qdisc *sch, struct qdisc_walker *walker)
 	}
 }
 
-static inline struct tcf_proto __rcu **dsmark_find_tcf(struct Qdisc *sch,
-						       unsigned long cl)
+static struct tcf_block *dsmark_tcf_block(struct Qdisc *sch, unsigned long cl)
 {
 	struct dsmark_qdisc_data *p = qdisc_priv(sch);
-	return &p->filter_list;
+
+	return p->block;
 }
 
 /* --------------------------- Qdisc operations ---------------------------- */
@@ -332,7 +333,7 @@ static int dsmark_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct dsmark_qdisc_data *p = qdisc_priv(sch);
 	struct nlattr *tb[TCA_DSMARK_MAX + 1];
-	int err = -EINVAL;
+	int err;
 	u32 default_index = NO_DEFAULT_INDEX;
 	u16 indices;
 	int i;
@@ -342,6 +343,10 @@ static int dsmark_init(struct Qdisc *sch, struct nlattr *opt)
 	if (!opt)
 		goto errout;
 
+	err = tcf_block_get(&p->block, &p->filter_list);
+	if (err)
+		return err;
+
 	err = nla_parse_nested(tb, TCA_DSMARK_MAX, opt, dsmark_policy, NULL);
 	if (err < 0)
 		goto errout;
@@ -400,7 +405,7 @@ static void dsmark_destroy(struct Qdisc *sch)
 
 	pr_debug("%s(sch %p,[qdisc %p])\n", __func__, sch, p);
 
-	tcf_destroy_chain(&p->filter_list);
+	tcf_block_put(p->block);
 	qdisc_destroy(p->q);
 	if (p->mv != p->embedded)
 		kfree(p->mv);
@@ -468,7 +473,7 @@ static const struct Qdisc_class_ops dsmark_class_ops = {
 	.change		=	dsmark_change,
 	.delete		=	dsmark_delete,
 	.walk		=	dsmark_walk,
-	.tcf_chain	=	dsmark_find_tcf,
+	.tcf_block	=	dsmark_tcf_block,
 	.bind_tcf	=	dsmark_bind_filter,
 	.unbind_tcf	=	dsmark_put,
 	.dump		=	dsmark_dump_class,
diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index 42ba81a..f201e73 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -55,6 +55,7 @@ struct fq_codel_flow {
 
 struct fq_codel_sched_data {
 	struct tcf_proto __rcu *filter_list; /* optional external classifier */
+	struct tcf_block *block;
 	struct fq_codel_flow *flows;	/* Flows table [flows_cnt] */
 	u32		*backlogs;	/* backlog table [flows_cnt] */
 	u32		flows_cnt;	/* number of flows */
@@ -450,7 +451,7 @@ static void fq_codel_destroy(struct Qdisc *sch)
 {
 	struct fq_codel_sched_data *q = qdisc_priv(sch);
 
-	tcf_destroy_chain(&q->filter_list);
+	tcf_block_put(q->block);
 	kvfree(q->backlogs);
 	kvfree(q->flows);
 }
@@ -459,6 +460,7 @@ static int fq_codel_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct fq_codel_sched_data *q = qdisc_priv(sch);
 	int i;
+	int err;
 
 	sch->limit = 10*1024;
 	q->flows_cnt = 1024;
@@ -478,6 +480,10 @@ static int fq_codel_init(struct Qdisc *sch, struct nlattr *opt)
 			return err;
 	}
 
+	err = tcf_block_get(&q->block, &q->filter_list);
+	if (err)
+		return err;
+
 	if (!q->flows) {
 		q->flows = kvzalloc(q->flows_cnt *
 					   sizeof(struct fq_codel_flow), GFP_KERNEL);
@@ -589,14 +595,13 @@ static void fq_codel_put(struct Qdisc *q, unsigned long cl)
 {
 }
 
-static struct tcf_proto __rcu **fq_codel_find_tcf(struct Qdisc *sch,
-						  unsigned long cl)
+static struct tcf_block *fq_codel_tcf_block(struct Qdisc *sch, unsigned long cl)
 {
 	struct fq_codel_sched_data *q = qdisc_priv(sch);
 
 	if (cl)
 		return NULL;
-	return &q->filter_list;
+	return q->block;
 }
 
 static int fq_codel_dump_class(struct Qdisc *sch, unsigned long cl,
@@ -679,7 +684,7 @@ static const struct Qdisc_class_ops fq_codel_class_ops = {
 	.leaf		=	fq_codel_leaf,
 	.get		=	fq_codel_get,
 	.put		=	fq_codel_put,
-	.tcf_chain	=	fq_codel_find_tcf,
+	.tcf_block	=	fq_codel_tcf_block,
 	.bind_tcf	=	fq_codel_bind,
 	.unbind_tcf	=	fq_codel_put,
 	.dump		=	fq_codel_dump_class,
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index b0dcab1..a324f84 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -116,6 +116,7 @@ struct hfsc_class {
 	struct gnet_stats_queue qstats;
 	struct net_rate_estimator __rcu *rate_est;
 	struct tcf_proto __rcu *filter_list; /* filter list */
+	struct tcf_block *block;
 	unsigned int	filter_cnt;	/* filter count */
 	unsigned int	level;		/* class level in hierarchy */
 
@@ -1040,12 +1041,19 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 	if (cl == NULL)
 		return -ENOBUFS;
 
+	err = tcf_block_get(&cl->block, &cl->filter_list);
+	if (err) {
+		kfree(cl);
+		return err;
+	}
+
 	if (tca[TCA_RATE]) {
 		err = gen_new_estimator(&cl->bstats, NULL, &cl->rate_est,
 					NULL,
 					qdisc_root_sleeping_running(sch),
 					tca[TCA_RATE]);
 		if (err) {
+			tcf_block_put(cl->block);
 			kfree(cl);
 			return err;
 		}
@@ -1091,7 +1099,7 @@ hfsc_destroy_class(struct Qdisc *sch, struct hfsc_class *cl)
 {
 	struct hfsc_sched *q = qdisc_priv(sch);
 
-	tcf_destroy_chain(&cl->filter_list);
+	tcf_block_put(cl->block);
 	qdisc_destroy(cl->qdisc);
 	gen_kill_estimator(&cl->rate_est);
 	if (cl != &q->root)
@@ -1261,8 +1269,7 @@ hfsc_unbind_tcf(struct Qdisc *sch, unsigned long arg)
 	cl->filter_cnt--;
 }
 
-static struct tcf_proto __rcu **
-hfsc_tcf_chain(struct Qdisc *sch, unsigned long arg)
+static struct tcf_block *hfsc_tcf_block(struct Qdisc *sch, unsigned long arg)
 {
 	struct hfsc_sched *q = qdisc_priv(sch);
 	struct hfsc_class *cl = (struct hfsc_class *)arg;
@@ -1270,7 +1277,7 @@ hfsc_tcf_chain(struct Qdisc *sch, unsigned long arg)
 	if (cl == NULL)
 		cl = &q->root;
 
-	return &cl->filter_list;
+	return cl->block;
 }
 
 static int
@@ -1515,7 +1522,7 @@ hfsc_destroy_qdisc(struct Qdisc *sch)
 
 	for (i = 0; i < q->clhash.hashsize; i++) {
 		hlist_for_each_entry(cl, &q->clhash.hash[i], cl_common.hnode)
-			tcf_destroy_chain(&cl->filter_list);
+			tcf_block_put(cl->block);
 	}
 	for (i = 0; i < q->clhash.hashsize; i++) {
 		hlist_for_each_entry_safe(cl, next, &q->clhash.hash[i],
@@ -1662,7 +1669,7 @@ static const struct Qdisc_class_ops hfsc_class_ops = {
 	.put		= hfsc_put_class,
 	.bind_tcf	= hfsc_bind_tcf,
 	.unbind_tcf	= hfsc_unbind_tcf,
-	.tcf_chain	= hfsc_tcf_chain,
+	.tcf_block	= hfsc_tcf_block,
 	.dump		= hfsc_dump_class,
 	.dump_stats	= hfsc_dump_class_stats,
 	.walk		= hfsc_walk
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 640f5f3..195bbca9 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -105,6 +105,7 @@ struct htb_class {
 	int			quantum;	/* but stored for parent-to-leaf return */
 
 	struct tcf_proto __rcu	*filter_list;	/* class attached filters */
+	struct tcf_block	*block;
 	int			filter_cnt;
 	int			refcnt;		/* usage count of this class */
 
@@ -156,6 +157,7 @@ struct htb_sched {
 
 	/* filters for qdisc itself */
 	struct tcf_proto __rcu	*filter_list;
+	struct tcf_block	*block;
 
 #define HTB_WARN_TOOMANYEVENTS	0x1
 	unsigned int		warned;	/* only one warning */
@@ -1017,6 +1019,10 @@ static int htb_init(struct Qdisc *sch, struct nlattr *opt)
 	if (!opt)
 		return -EINVAL;
 
+	err = tcf_block_get(&q->block, &q->filter_list);
+	if (err)
+		return err;
+
 	err = nla_parse_nested(tb, TCA_HTB_MAX, opt, htb_policy, NULL);
 	if (err < 0)
 		return err;
@@ -1230,7 +1236,7 @@ static void htb_destroy_class(struct Qdisc *sch, struct htb_class *cl)
 		qdisc_destroy(cl->un.leaf.q);
 	}
 	gen_kill_estimator(&cl->rate_est);
-	tcf_destroy_chain(&cl->filter_list);
+	tcf_block_put(cl->block);
 	kfree(cl);
 }
 
@@ -1248,11 +1254,11 @@ static void htb_destroy(struct Qdisc *sch)
 	 * because filter need its target class alive to be able to call
 	 * unbind_filter on it (without Oops).
 	 */
-	tcf_destroy_chain(&q->filter_list);
+	tcf_block_put(q->block);
 
 	for (i = 0; i < q->clhash.hashsize; i++) {
 		hlist_for_each_entry(cl, &q->clhash.hash[i], common.hnode)
-			tcf_destroy_chain(&cl->filter_list);
+			tcf_block_put(cl->block);
 	}
 	for (i = 0; i < q->clhash.hashsize; i++) {
 		hlist_for_each_entry_safe(cl, next, &q->clhash.hash[i],
@@ -1396,6 +1402,11 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 		if (!cl)
 			goto failure;
 
+		err = tcf_block_get(&cl->block, &cl->filter_list);
+		if (err) {
+			kfree(cl);
+			goto failure;
+		}
 		if (htb_rate_est || tca[TCA_RATE]) {
 			err = gen_new_estimator(&cl->bstats, NULL,
 						&cl->rate_est,
@@ -1403,6 +1414,7 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 						qdisc_root_sleeping_running(sch),
 						tca[TCA_RATE] ? : &est.nla);
 			if (err) {
+				tcf_block_put(cl->block);
 				kfree(cl);
 				goto failure;
 			}
@@ -1521,14 +1533,12 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 	return err;
 }
 
-static struct tcf_proto __rcu **htb_find_tcf(struct Qdisc *sch,
-					     unsigned long arg)
+static struct tcf_block *htb_tcf_block(struct Qdisc *sch, unsigned long arg)
 {
 	struct htb_sched *q = qdisc_priv(sch);
 	struct htb_class *cl = (struct htb_class *)arg;
-	struct tcf_proto __rcu **fl = cl ? &cl->filter_list : &q->filter_list;
 
-	return fl;
+	return cl ? cl->block : q->block;
 }
 
 static unsigned long htb_bind_filter(struct Qdisc *sch, unsigned long parent,
@@ -1591,7 +1601,7 @@ static const struct Qdisc_class_ops htb_class_ops = {
 	.change		=	htb_change_class,
 	.delete		=	htb_delete,
 	.walk		=	htb_walk,
-	.tcf_chain	=	htb_find_tcf,
+	.tcf_block	=	htb_tcf_block,
 	.bind_tcf	=	htb_bind_filter,
 	.unbind_tcf	=	htb_unbind_filter,
 	.dump		=	htb_dump_class,
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index 3bab5f6..d8a9beb 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -18,6 +18,10 @@
 #include <net/pkt_sched.h>
 #include <net/pkt_cls.h>
 
+struct ingress_sched_data {
+	struct tcf_block *block;
+};
+
 static struct Qdisc *ingress_leaf(struct Qdisc *sch, unsigned long arg)
 {
 	return NULL;
@@ -47,16 +51,23 @@ static void ingress_walk(struct Qdisc *sch, struct qdisc_walker *walker)
 {
 }
 
-static struct tcf_proto __rcu **ingress_find_tcf(struct Qdisc *sch,
-						 unsigned long cl)
+static struct tcf_block *ingress_tcf_block(struct Qdisc *sch, unsigned long cl)
 {
-	struct net_device *dev = qdisc_dev(sch);
+	struct ingress_sched_data *q = qdisc_priv(sch);
 
-	return &dev->ingress_cl_list;
+	return q->block;
 }
 
 static int ingress_init(struct Qdisc *sch, struct nlattr *opt)
 {
+	struct ingress_sched_data *q = qdisc_priv(sch);
+	struct net_device *dev = qdisc_dev(sch);
+	int err;
+
+	err = tcf_block_get(&q->block, &dev->ingress_cl_list);
+	if (err)
+		return err;
+
 	net_inc_ingress_queue();
 	sch->flags |= TCQ_F_CPUSTATS;
 
@@ -65,9 +76,9 @@ static int ingress_init(struct Qdisc *sch, struct nlattr *opt)
 
 static void ingress_destroy(struct Qdisc *sch)
 {
-	struct net_device *dev = qdisc_dev(sch);
+	struct ingress_sched_data *q = qdisc_priv(sch);
 
-	tcf_destroy_chain(&dev->ingress_cl_list);
+	tcf_block_put(q->block);
 	net_dec_ingress_queue();
 }
 
@@ -91,7 +102,7 @@ static const struct Qdisc_class_ops ingress_class_ops = {
 	.get		=	ingress_get,
 	.put		=	ingress_put,
 	.walk		=	ingress_walk,
-	.tcf_chain	=	ingress_find_tcf,
+	.tcf_block	=	ingress_tcf_block,
 	.tcf_cl_offload	=	ingress_cl_offload,
 	.bind_tcf	=	ingress_bind_filter,
 	.unbind_tcf	=	ingress_put,
@@ -100,12 +111,18 @@ static const struct Qdisc_class_ops ingress_class_ops = {
 static struct Qdisc_ops ingress_qdisc_ops __read_mostly = {
 	.cl_ops		=	&ingress_class_ops,
 	.id		=	"ingress",
+	.priv_size	=	sizeof(struct ingress_sched_data),
 	.init		=	ingress_init,
 	.destroy	=	ingress_destroy,
 	.dump		=	ingress_dump,
 	.owner		=	THIS_MODULE,
 };
 
+struct clsact_sched_data {
+	struct tcf_block *ingress_block;
+	struct tcf_block *egress_block;
+};
+
 static unsigned long clsact_get(struct Qdisc *sch, u32 classid)
 {
 	switch (TC_H_MIN(classid)) {
@@ -128,16 +145,15 @@ static unsigned long clsact_bind_filter(struct Qdisc *sch,
 	return clsact_get(sch, classid);
 }
 
-static struct tcf_proto __rcu **clsact_find_tcf(struct Qdisc *sch,
-						unsigned long cl)
+static struct tcf_block *clsact_tcf_block(struct Qdisc *sch, unsigned long cl)
 {
-	struct net_device *dev = qdisc_dev(sch);
+	struct clsact_sched_data *q = qdisc_priv(sch);
 
 	switch (cl) {
 	case TC_H_MIN(TC_H_MIN_INGRESS):
-		return &dev->ingress_cl_list;
+		return q->ingress_block;
 	case TC_H_MIN(TC_H_MIN_EGRESS):
-		return &dev->egress_cl_list;
+		return q->egress_block;
 	default:
 		return NULL;
 	}
@@ -145,6 +161,18 @@ static struct tcf_proto __rcu **clsact_find_tcf(struct Qdisc *sch,
 
 static int clsact_init(struct Qdisc *sch, struct nlattr *opt)
 {
+	struct clsact_sched_data *q = qdisc_priv(sch);
+	struct net_device *dev = qdisc_dev(sch);
+	int err;
+
+	err = tcf_block_get(&q->ingress_block, &dev->ingress_cl_list);
+	if (err)
+		return err;
+
+	err = tcf_block_get(&q->egress_block, &dev->egress_cl_list);
+	if (err)
+		return err;
+
 	net_inc_ingress_queue();
 	net_inc_egress_queue();
 
@@ -155,10 +183,10 @@ static int clsact_init(struct Qdisc *sch, struct nlattr *opt)
 
 static void clsact_destroy(struct Qdisc *sch)
 {
-	struct net_device *dev = qdisc_dev(sch);
+	struct clsact_sched_data *q = qdisc_priv(sch);
 
-	tcf_destroy_chain(&dev->ingress_cl_list);
-	tcf_destroy_chain(&dev->egress_cl_list);
+	tcf_block_put(q->egress_block);
+	tcf_block_put(q->ingress_block);
 
 	net_dec_ingress_queue();
 	net_dec_egress_queue();
@@ -169,7 +197,7 @@ static const struct Qdisc_class_ops clsact_class_ops = {
 	.get		=	clsact_get,
 	.put		=	ingress_put,
 	.walk		=	ingress_walk,
-	.tcf_chain	=	clsact_find_tcf,
+	.tcf_block	=	clsact_tcf_block,
 	.tcf_cl_offload	=	clsact_cl_offload,
 	.bind_tcf	=	clsact_bind_filter,
 	.unbind_tcf	=	ingress_put,
@@ -178,6 +206,7 @@ static const struct Qdisc_class_ops clsact_class_ops = {
 static struct Qdisc_ops clsact_qdisc_ops __read_mostly = {
 	.cl_ops		=	&clsact_class_ops,
 	.id		=	"clsact",
+	.priv_size	=	sizeof(struct clsact_sched_data),
 	.init		=	clsact_init,
 	.destroy	=	clsact_destroy,
 	.dump		=	ingress_dump,
diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
index 25bb9ff..6047674 100644
--- a/net/sched/sch_multiq.c
+++ b/net/sched/sch_multiq.c
@@ -32,6 +32,7 @@ struct multiq_sched_data {
 	u16 max_bands;
 	u16 curband;
 	struct tcf_proto __rcu *filter_list;
+	struct tcf_block *block;
 	struct Qdisc **queues;
 };
 
@@ -170,7 +171,7 @@ multiq_destroy(struct Qdisc *sch)
 	int band;
 	struct multiq_sched_data *q = qdisc_priv(sch);
 
-	tcf_destroy_chain(&q->filter_list);
+	tcf_block_put(q->block);
 	for (band = 0; band < q->bands; band++)
 		qdisc_destroy(q->queues[band]);
 
@@ -243,6 +244,10 @@ static int multiq_init(struct Qdisc *sch, struct nlattr *opt)
 	if (opt == NULL)
 		return -EINVAL;
 
+	err = tcf_block_get(&q->block, &q->filter_list);
+	if (err)
+		return err;
+
 	q->max_bands = qdisc_dev(sch)->num_tx_queues;
 
 	q->queues = kcalloc(q->max_bands, sizeof(struct Qdisc *), GFP_KERNEL);
@@ -367,14 +372,13 @@ static void multiq_walk(struct Qdisc *sch, struct qdisc_walker *arg)
 	}
 }
 
-static struct tcf_proto __rcu **multiq_find_tcf(struct Qdisc *sch,
-						unsigned long cl)
+static struct tcf_block *multiq_tcf_block(struct Qdisc *sch, unsigned long cl)
 {
 	struct multiq_sched_data *q = qdisc_priv(sch);
 
 	if (cl)
 		return NULL;
-	return &q->filter_list;
+	return q->block;
 }
 
 static const struct Qdisc_class_ops multiq_class_ops = {
@@ -383,7 +387,7 @@ static const struct Qdisc_class_ops multiq_class_ops = {
 	.get		=	multiq_get,
 	.put		=	multiq_put,
 	.walk		=	multiq_walk,
-	.tcf_chain	=	multiq_find_tcf,
+	.tcf_block	=	multiq_tcf_block,
 	.bind_tcf	=	multiq_bind,
 	.unbind_tcf	=	multiq_put,
 	.dump		=	multiq_dump_class,
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 7997363..a240468 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -25,6 +25,7 @@
 struct prio_sched_data {
 	int bands;
 	struct tcf_proto __rcu *filter_list;
+	struct tcf_block *block;
 	u8  prio2band[TC_PRIO_MAX+1];
 	struct Qdisc *queues[TCQ_PRIO_BANDS];
 };
@@ -145,7 +146,7 @@ prio_destroy(struct Qdisc *sch)
 	int prio;
 	struct prio_sched_data *q = qdisc_priv(sch);
 
-	tcf_destroy_chain(&q->filter_list);
+	tcf_block_put(q->block);
 	for (prio = 0; prio < q->bands; prio++)
 		qdisc_destroy(q->queues[prio]);
 }
@@ -204,9 +205,16 @@ static int prio_tune(struct Qdisc *sch, struct nlattr *opt)
 
 static int prio_init(struct Qdisc *sch, struct nlattr *opt)
 {
+	struct prio_sched_data *q = qdisc_priv(sch);
+	int err;
+
 	if (!opt)
 		return -EINVAL;
 
+	err = tcf_block_get(&q->block, &q->filter_list);
+	if (err)
+		return err;
+
 	return prio_tune(sch, opt);
 }
 
@@ -317,14 +325,13 @@ static void prio_walk(struct Qdisc *sch, struct qdisc_walker *arg)
 	}
 }
 
-static struct tcf_proto __rcu **prio_find_tcf(struct Qdisc *sch,
-					      unsigned long cl)
+static struct tcf_block *prio_tcf_block(struct Qdisc *sch, unsigned long cl)
 {
 	struct prio_sched_data *q = qdisc_priv(sch);
 
 	if (cl)
 		return NULL;
-	return &q->filter_list;
+	return q->block;
 }
 
 static const struct Qdisc_class_ops prio_class_ops = {
@@ -333,7 +340,7 @@ static const struct Qdisc_class_ops prio_class_ops = {
 	.get		=	prio_get,
 	.put		=	prio_put,
 	.walk		=	prio_walk,
-	.tcf_chain	=	prio_find_tcf,
+	.tcf_block	=	prio_tcf_block,
 	.bind_tcf	=	prio_bind,
 	.unbind_tcf	=	prio_put,
 	.dump		=	prio_dump_class,
diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index 73c7ac3..076ad03 100644
--- a/net/sched/sch_qfq.c
+++ b/net/sched/sch_qfq.c
@@ -182,6 +182,7 @@ struct qfq_group {
 
 struct qfq_sched {
 	struct tcf_proto __rcu *filter_list;
+	struct tcf_block	*block;
 	struct Qdisc_class_hash clhash;
 
 	u64			oldV, V;	/* Precise virtual times. */
@@ -582,15 +583,14 @@ static void qfq_put_class(struct Qdisc *sch, unsigned long arg)
 		qfq_destroy_class(sch, cl);
 }
 
-static struct tcf_proto __rcu **qfq_tcf_chain(struct Qdisc *sch,
-					      unsigned long cl)
+static struct tcf_block *qfq_tcf_block(struct Qdisc *sch, unsigned long cl)
 {
 	struct qfq_sched *q = qdisc_priv(sch);
 
 	if (cl)
 		return NULL;
 
-	return &q->filter_list;
+	return q->block;
 }
 
 static unsigned long qfq_bind_tcf(struct Qdisc *sch, unsigned long parent,
@@ -1438,6 +1438,10 @@ static int qfq_init_qdisc(struct Qdisc *sch, struct nlattr *opt)
 	int i, j, err;
 	u32 max_cl_shift, maxbudg_shift, max_classes;
 
+	err = tcf_block_get(&q->block, &q->filter_list);
+	if (err)
+		return err;
+
 	err = qdisc_class_hash_init(&q->clhash);
 	if (err < 0)
 		return err;
@@ -1492,7 +1496,7 @@ static void qfq_destroy_qdisc(struct Qdisc *sch)
 	struct hlist_node *next;
 	unsigned int i;
 
-	tcf_destroy_chain(&q->filter_list);
+	tcf_block_put(q->block);
 
 	for (i = 0; i < q->clhash.hashsize; i++) {
 		hlist_for_each_entry_safe(cl, next, &q->clhash.hash[i],
@@ -1508,7 +1512,7 @@ static const struct Qdisc_class_ops qfq_class_ops = {
 	.delete		= qfq_delete_class,
 	.get		= qfq_get_class,
 	.put		= qfq_put_class,
-	.tcf_chain	= qfq_tcf_chain,
+	.tcf_block	= qfq_tcf_block,
 	.bind_tcf	= qfq_bind_tcf,
 	.unbind_tcf	= qfq_unbind_tcf,
 	.graft		= qfq_graft_class,
diff --git a/net/sched/sch_sfb.c b/net/sched/sch_sfb.c
index b2878808..9756b1c 100644
--- a/net/sched/sch_sfb.c
+++ b/net/sched/sch_sfb.c
@@ -56,6 +56,7 @@ struct sfb_bins {
 struct sfb_sched_data {
 	struct Qdisc	*qdisc;
 	struct tcf_proto __rcu *filter_list;
+	struct tcf_block *block;
 	unsigned long	rehash_interval;
 	unsigned long	warmup_time;	/* double buffering warmup time in jiffies */
 	u32		max;
@@ -465,7 +466,7 @@ static void sfb_destroy(struct Qdisc *sch)
 {
 	struct sfb_sched_data *q = qdisc_priv(sch);
 
-	tcf_destroy_chain(&q->filter_list);
+	tcf_block_put(q->block);
 	qdisc_destroy(q->qdisc);
 }
 
@@ -549,6 +550,11 @@ static int sfb_change(struct Qdisc *sch, struct nlattr *opt)
 static int sfb_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct sfb_sched_data *q = qdisc_priv(sch);
+	int err;
+
+	err = tcf_block_get(&q->block, &q->filter_list);
+	if (err)
+		return err;
 
 	q->qdisc = &noop_qdisc;
 	return sfb_change(sch, opt);
@@ -657,14 +663,13 @@ static void sfb_walk(struct Qdisc *sch, struct qdisc_walker *walker)
 	}
 }
 
-static struct tcf_proto __rcu **sfb_find_tcf(struct Qdisc *sch,
-					     unsigned long cl)
+static struct tcf_block *sfb_tcf_block(struct Qdisc *sch, unsigned long cl)
 {
 	struct sfb_sched_data *q = qdisc_priv(sch);
 
 	if (cl)
 		return NULL;
-	return &q->filter_list;
+	return q->block;
 }
 
 static unsigned long sfb_bind(struct Qdisc *sch, unsigned long parent,
@@ -682,7 +687,7 @@ static const struct Qdisc_class_ops sfb_class_ops = {
 	.change		=	sfb_change_class,
 	.delete		=	sfb_delete,
 	.walk		=	sfb_walk,
-	.tcf_chain	=	sfb_find_tcf,
+	.tcf_block	=	sfb_tcf_block,
 	.bind_tcf	=	sfb_bind,
 	.unbind_tcf	=	sfb_put,
 	.dump		=	sfb_dump_class,
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 53a641f..66dfd15 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -126,6 +126,7 @@ struct sfq_sched_data {
 	u8		flags;
 	unsigned short  scaled_quantum; /* SFQ_ALLOT_SIZE(quantum) */
 	struct tcf_proto __rcu *filter_list;
+	struct tcf_block *block;
 	sfq_index	*ht;		/* Hash table ('divisor' slots) */
 	struct sfq_slot	*slots;		/* Flows table ('maxflows' entries) */
 
@@ -697,7 +698,7 @@ static void sfq_destroy(struct Qdisc *sch)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
 
-	tcf_destroy_chain(&q->filter_list);
+	tcf_block_put(q->block);
 	q->perturb_period = 0;
 	del_timer_sync(&q->perturb_timer);
 	sfq_free(q->ht);
@@ -709,6 +710,11 @@ static int sfq_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
 	int i;
+	int err;
+
+	err = tcf_block_get(&q->block, &q->filter_list);
+	if (err)
+		return err;
 
 	setup_deferrable_timer(&q->perturb_timer, sfq_perturbation,
 			       (unsigned long)sch);
@@ -815,14 +821,13 @@ static void sfq_put(struct Qdisc *q, unsigned long cl)
 {
 }
 
-static struct tcf_proto __rcu **sfq_find_tcf(struct Qdisc *sch,
-					     unsigned long cl)
+static struct tcf_block *sfq_tcf_block(struct Qdisc *sch, unsigned long cl)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
 
 	if (cl)
 		return NULL;
-	return &q->filter_list;
+	return q->block;
 }
 
 static int sfq_dump_class(struct Qdisc *sch, unsigned long cl,
@@ -878,7 +883,7 @@ static const struct Qdisc_class_ops sfq_class_ops = {
 	.leaf		=	sfq_leaf,
 	.get		=	sfq_get,
 	.put		=	sfq_put,
-	.tcf_chain	=	sfq_find_tcf,
+	.tcf_block	=	sfq_tcf_block,
 	.bind_tcf	=	sfq_bind,
 	.unbind_tcf	=	sfq_put,
 	.dump		=	sfq_dump_class,
-- 
2.9.3
