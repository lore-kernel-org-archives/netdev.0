From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 02/12] net: rcu-ify tcf_proto
Date: Fri, 10 Jan 2014 01:37:35 -0800
Message-ID: <20140110093733.7193.41632.stgit@nitbit.x32>
References: <20140110092041.7193.5952.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: xiyou.wangcong@gmail.com, jhs@mojatatu.com, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:37798 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753141AbaAJJh5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 04:37:57 -0500
Received: by mail-ob0-f176.google.com with SMTP id vb8so4522364obc.21
        for <netdev@vger.kernel.org>; Fri, 10 Jan 2014 01:37:56 -0800 (PST)
In-Reply-To: <20140110092041.7193.5952.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rcu'ify tcf_proto this allows calling tc_classify() without holding
any locks. Updaters are protected by RTNL.

This patch prepares the core net_sched infrastracture for running
the classifier/action chains without holding the qdisc lock however
it does nothing to ensure cls_xxx and act_xxx types also work without
locking. Additional patches are required to address the fall out.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/net/sch_generic.h |    5 +++--
 net/sched/cls_api.c       |   29 ++++++++++++++---------------
 net/sched/sch_api.c       |    6 +++---
 net/sched/sch_atm.c       |   30 +++++++++++++++++++-----------
 net/sched/sch_cbq.c       |   21 +++++++++++++++------
 net/sched/sch_choke.c     |   18 +++++++++++++-----
 net/sched/sch_drr.c       |   10 +++++++---
 net/sched/sch_dsmark.c    |    8 +++++---
 net/sched/sch_fq_codel.c  |   11 +++++++----
 net/sched/sch_hfsc.c      |   17 +++++++++++------
 net/sched/sch_htb.c       |   23 +++++++++++++++--------
 net/sched/sch_ingress.c   |    8 +++++---
 net/sched/sch_multiq.c    |    8 +++++---
 net/sched/sch_prio.c      |   11 +++++++----
 net/sched/sch_qfq.c       |    9 ++++++---
 net/sched/sch_sfb.c       |   15 +++++++++------
 net/sched/sch_sfq.c       |   11 +++++++----
 17 files changed, 151 insertions(+), 89 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 3e10a2a..11b878b 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -212,8 +212,8 @@ struct tcf_proto_ops {
 
 struct tcf_proto {
 	/* Fast access part */
-	struct tcf_proto	*next;
-	void			*root;
+	struct tcf_proto __rcu	*next;
+	void __rcu		*root;
 	int			(*classify)(struct sk_buff *,
 					    const struct tcf_proto *,
 					    struct tcf_result *);
@@ -225,6 +225,7 @@ struct tcf_proto {
 	struct Qdisc		*q;
 	void			*data;
 	const struct tcf_proto_ops	*ops;
+	struct rcu_head		rcu;
 };
 
 struct qdisc_skb_cb {
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 12e882e..86c3678 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -117,7 +117,6 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
 {
 	struct net *net = sock_net(skb->sk);
 	struct nlattr *tca[TCA_MAX + 1];
-	spinlock_t *root_lock;
 	struct tcmsg *t;
 	u32 protocol;
 	u32 prio;
@@ -125,7 +124,8 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
 	u32 parent;
 	struct net_device *dev;
 	struct Qdisc  *q;
-	struct tcf_proto **back, **chain;
+	struct tcf_proto __rcu **back;
+	struct tcf_proto __rcu **chain;
 	struct tcf_proto *tp;
 	const struct tcf_proto_ops *tp_ops;
 	const struct Qdisc_class_ops *cops;
@@ -196,7 +196,9 @@ replay:
 		goto errout;
 
 	/* Check the chain for existence of proto-tcf with this priority */
-	for (back = chain; (tp = *back) != NULL; back = &tp->next) {
+	for (back = chain;
+	     (tp = rtnl_dereference(*back)) != NULL;
+	     back = &tp->next) {
 		if (tp->prio >= prio) {
 			if (tp->prio == prio) {
 				if (!nprio ||
@@ -208,8 +210,6 @@ replay:
 		}
 	}
 
-	root_lock = qdisc_root_sleeping_lock(q);
-
 	if (tp == NULL) {
 		/* Proto-tcf does not exist, create new one */
 
@@ -258,7 +258,7 @@ replay:
 		}
 		tp->ops = tp_ops;
 		tp->protocol = protocol;
-		tp->prio = nprio ? : TC_H_MAJ(tcf_auto_prio(*back));
+		tp->prio = nprio ? : TC_H_MAJ(tcf_auto_prio(rtnl_dereference(*back)));
 		tp->q = q;
 		tp->classify = tp_ops->classify;
 		tp->classid = parent;
@@ -279,9 +279,9 @@ replay:
 
 	if (fh == 0) {
 		if (n->nlmsg_type == RTM_DELTFILTER && t->tcm_handle == 0) {
-			spin_lock_bh(root_lock);
-			*back = tp->next;
-			spin_unlock_bh(root_lock);
+			struct tcf_proto *next = rtnl_dereference(tp->next);
+
+			rcu_assign_pointer(*back, next);
 
 			tfilter_notify(net, skb, n, tp, fh, RTM_DELTFILTER);
 			tcf_destroy(tp);
@@ -320,10 +320,8 @@ replay:
 	err = tp->ops->change(net, skb, tp, cl, t->tcm_handle, tca, &fh);
 	if (err == 0) {
 		if (tp_created) {
-			spin_lock_bh(root_lock);
-			tp->next = *back;
-			*back = tp;
-			spin_unlock_bh(root_lock);
+			rcu_assign_pointer(tp->next, rtnl_dereference(*back));
+			rcu_assign_pointer(*back, tp);
 		}
 		tfilter_notify(net, skb, n, tp, fh, RTM_NEWTFILTER);
 	} else {
@@ -417,7 +415,7 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 	int s_t;
 	struct net_device *dev;
 	struct Qdisc *q;
-	struct tcf_proto *tp, **chain;
+	struct tcf_proto *tp, __rcu **chain;
 	struct tcmsg *tcm = nlmsg_data(cb->nlh);
 	unsigned long cl = 0;
 	const struct Qdisc_class_ops *cops;
@@ -451,7 +449,8 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 
 	s_t = cb->args[0];
 
-	for (tp = *chain, t = 0; tp; tp = tp->next, t++) {
+	for (tp = rtnl_dereference(*chain), t = 0;
+	     tp; tp = rtnl_dereference(tp->next), t++) {
 		if (t < s_t)
 			continue;
 		if (TC_H_MAJ(tcm->tcm_info) &&
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 1313145..774f61c 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1778,7 +1778,7 @@ int tc_classify_compat(struct sk_buff *skb, const struct tcf_proto *tp,
 	__be16 protocol = skb->protocol;
 	int err;
 
-	for (; tp; tp = tp->next) {
+	for (; tp; tp = rcu_dereference_bh(tp->next)) {
 		if (tp->protocol != protocol &&
 		    tp->protocol != htons(ETH_P_ALL))
 			continue;
@@ -1830,7 +1830,7 @@ void tcf_destroy(struct tcf_proto *tp)
 {
 	tp->ops->destroy(tp);
 	module_put(tp->ops->owner);
-	kfree(tp);
+	kfree_rcu(tp, rcu);
 }
 
 void tcf_destroy_chain(struct tcf_proto **fl)
@@ -1838,7 +1838,7 @@ void tcf_destroy_chain(struct tcf_proto **fl)
 	struct tcf_proto *tp;
 
 	while ((tp = *fl) != NULL) {
-		*fl = tp->next;
+		*fl = rtnl_dereference(tp->next);
 		tcf_destroy(tp);
 	}
 }
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 1f9c314..a4953c6 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -41,7 +41,7 @@
 
 struct atm_flow_data {
 	struct Qdisc		*q;	/* FIFO, TBF, etc. */
-	struct tcf_proto	*filter_list;
+	struct tcf_proto __rcu	*filter_list;
 	struct atm_vcc		*vcc;	/* VCC; NULL if VCC is closed */
 	void			(*old_pop)(struct atm_vcc *vcc,
 					   struct sk_buff *skb); /* chaining */
@@ -134,6 +134,7 @@ static void atm_tc_put(struct Qdisc *sch, unsigned long cl)
 {
 	struct atm_qdisc_data *p = qdisc_priv(sch);
 	struct atm_flow_data *flow = (struct atm_flow_data *)cl;
+	struct tcf_proto *fl;
 
 	pr_debug("atm_tc_put(sch %p,[qdisc %p],flow %p)\n", sch, p, flow);
 	if (--flow->ref)
@@ -142,7 +143,10 @@ static void atm_tc_put(struct Qdisc *sch, unsigned long cl)
 	list_del_init(&flow->list);
 	pr_debug("atm_tc_put: qdisc %p\n", flow->q);
 	qdisc_destroy(flow->q);
-	tcf_destroy_chain(&flow->filter_list);
+
+	fl = rtnl_dereference(flow->filter_list);
+	tcf_destroy_chain(&fl);
+
 	if (flow->sock) {
 		pr_debug("atm_tc_put: f_count %ld\n",
 			file_count(flow->sock->file));
@@ -273,7 +277,7 @@ static int atm_tc_change(struct Qdisc *sch, u32 classid, u32 parent,
 		error = -ENOBUFS;
 		goto err_out;
 	}
-	flow->filter_list = NULL;
+	rcu_assign_pointer(flow->filter_list, NULL);
 	flow->q = qdisc_create_dflt(sch->dev_queue, &pfifo_qdisc_ops, classid);
 	if (!flow->q)
 		flow->q = &noop_qdisc;
@@ -311,7 +315,7 @@ static int atm_tc_delete(struct Qdisc *sch, unsigned long arg)
 	pr_debug("atm_tc_delete(sch %p,[qdisc %p],flow %p)\n", sch, p, flow);
 	if (list_empty(&flow->list))
 		return -EINVAL;
-	if (flow->filter_list || flow == &p->link)
+	if (rtnl_dereference(flow->filter_list) || flow == &p->link)
 		return -EBUSY;
 	/*
 	 * Reference count must be 2: one for "keepalive" (set at class
@@ -369,11 +373,12 @@ static int atm_tc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	flow = NULL;
 	if (TC_H_MAJ(skb->priority) != sch->handle ||
 	    !(flow = (struct atm_flow_data *)atm_tc_get(sch, skb->priority))) {
+		struct tcf_proto *fl;
+
 		list_for_each_entry(flow, &p->flows, list) {
-			if (flow->filter_list) {
-				result = tc_classify_compat(skb,
-							    flow->filter_list,
-							    &res);
+			fl = rcu_dereference_bh(flow->filter_list);
+			if (fl) {
+				result = tc_classify_compat(skb, fl, &res);
 				if (result < 0)
 					continue;
 				flow = (struct atm_flow_data *)res.class;
@@ -544,7 +549,7 @@ static int atm_tc_init(struct Qdisc *sch, struct nlattr *opt)
 	if (!p->link.q)
 		p->link.q = &noop_qdisc;
 	pr_debug("atm_tc_init: link (%p) qdisc %p\n", &p->link, p->link.q);
-	p->link.filter_list = NULL;
+	rcu_assign_pointer(p->link.filter_list, NULL);
 	p->link.vcc = NULL;
 	p->link.sock = NULL;
 	p->link.classid = sch->handle;
@@ -568,10 +573,13 @@ static void atm_tc_destroy(struct Qdisc *sch)
 {
 	struct atm_qdisc_data *p = qdisc_priv(sch);
 	struct atm_flow_data *flow, *tmp;
+	struct tcf_proto *fl;
 
 	pr_debug("atm_tc_destroy(sch %p,[qdisc %p])\n", sch, p);
-	list_for_each_entry(flow, &p->flows, list)
-		tcf_destroy_chain(&flow->filter_list);
+	list_for_each_entry(flow, &p->flows, list) {
+		fl = rtnl_dereference(flow->filter_list);
+		tcf_destroy_chain(&fl);
+	}
 
 	list_for_each_entry_safe(flow, tmp, &p->flows, list) {
 		if (flow->ref > 1)
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 2f80d01..61a51d0 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -133,7 +133,7 @@ struct cbq_class {
 	struct gnet_stats_rate_est64 rate_est;
 	struct tc_cbq_xstats	xstats;
 
-	struct tcf_proto	*filter_list;
+	struct tcf_proto __rcu	*filter_list;
 
 	int			refcnt;
 	int			filters;
@@ -222,6 +222,7 @@ cbq_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 	struct cbq_class **defmap;
 	struct cbq_class *cl = NULL;
 	u32 prio = skb->priority;
+	struct tcf_proto *fl;
 	struct tcf_result res;
 
 	/*
@@ -234,13 +235,15 @@ cbq_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 	*qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
 	for (;;) {
 		int result = 0;
+
 		defmap = head->defaults;
 
+		fl = rcu_dereference_bh(head->filter_list);
 		/*
 		 * Step 2+n. Apply classifier.
 		 */
-		if (!head->filter_list ||
-		    (result = tc_classify_compat(skb, head->filter_list, &res)) < 0)
+		result = tc_classify_compat(skb, fl, &res);
+		if (!fl || result < 0)
 			goto fallback;
 
 		cl = (void *)res.class;
@@ -1685,10 +1688,13 @@ static unsigned long cbq_get(struct Qdisc *sch, u32 classid)
 static void cbq_destroy_class(struct Qdisc *sch, struct cbq_class *cl)
 {
 	struct cbq_sched_data *q = qdisc_priv(sch);
+	struct tcf_proto *fl;
 
 	WARN_ON(cl->filters);
 
-	tcf_destroy_chain(&cl->filter_list);
+	fl = rtnl_dereference(cl->filter_list);
+	tcf_destroy_chain(&fl);
+
 	qdisc_destroy(cl->q);
 	qdisc_put_rtab(cl->R_tab);
 	gen_kill_estimator(&cl->bstats, &cl->rate_est);
@@ -1701,6 +1707,7 @@ static void cbq_destroy(struct Qdisc *sch)
 	struct cbq_sched_data *q = qdisc_priv(sch);
 	struct hlist_node *next;
 	struct cbq_class *cl;
+	struct tcf_proto *fl;
 	unsigned int h;
 
 #ifdef CONFIG_NET_CLS_ACT
@@ -1712,8 +1719,10 @@ static void cbq_destroy(struct Qdisc *sch)
 	 * be bound to classes which have been destroyed already. --TGR '04
 	 */
 	for (h = 0; h < q->clhash.hashsize; h++) {
-		hlist_for_each_entry(cl, &q->clhash.hash[h], common.hnode)
-			tcf_destroy_chain(&cl->filter_list);
+		hlist_for_each_entry(cl, &q->clhash.hash[h], common.hnode) {
+			fl = rtnl_dereference(cl->filter_list);
+			tcf_destroy_chain(&fl);
+		}
 	}
 	for (h = 0; h < q->clhash.hashsize; h++) {
 		hlist_for_each_entry_safe(cl, next, &q->clhash.hash[h],
diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
index ddd73cb..60eb0e5 100644
--- a/net/sched/sch_choke.c
+++ b/net/sched/sch_choke.c
@@ -58,7 +58,7 @@ struct choke_sched_data {
 
 /* Variables */
 	struct red_vars  vars;
-	struct tcf_proto *filter_list;
+	struct tcf_proto __rcu *filter_list;
 	struct {
 		u32	prob_drop;	/* Early probability drops */
 		u32	prob_mark;	/* Early probability marks */
@@ -200,9 +200,11 @@ static bool choke_classify(struct sk_buff *skb,
 {
 	struct choke_sched_data *q = qdisc_priv(sch);
 	struct tcf_result res;
+	struct tcf_proto *fl;
 	int result;
 
-	result = tc_classify(skb, q->filter_list, &res);
+	fl = rcu_dereference_bh(q->filter_list);
+	result = tc_classify(skb, fl, &res);
 	if (result >= 0) {
 #ifdef CONFIG_NET_CLS_ACT
 		switch (result) {
@@ -251,12 +253,14 @@ static bool choke_match_random(const struct choke_sched_data *q,
 			       unsigned int *pidx)
 {
 	struct sk_buff *oskb;
+	struct tcf_proto *fl;
 
 	if (q->head == q->tail)
 		return false;
 
 	oskb = choke_peek_random(q, pidx);
-	if (q->filter_list)
+	fl = rcu_dereference_bh(q->filter_list);
+	if (fl)
 		return choke_get_classid(nskb) == choke_get_classid(oskb);
 
 	return choke_match_flow(oskb, nskb);
@@ -266,9 +270,11 @@ static int choke_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct choke_sched_data *q = qdisc_priv(sch);
 	const struct red_parms *p = &q->parms;
+	struct tcf_proto *fl;
 	int ret = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
 
-	if (q->filter_list) {
+	fl = rcu_dereference_bh(q->filter_list);
+	if (fl) {
 		/* If using external classifiers, get result and record it. */
 		if (!choke_classify(skb, sch, &ret))
 			goto other_drop;	/* Packet was eaten by filter */
@@ -541,8 +547,10 @@ static int choke_dump_stats(struct Qdisc *sch, struct gnet_dump *d)
 static void choke_destroy(struct Qdisc *sch)
 {
 	struct choke_sched_data *q = qdisc_priv(sch);
+	struct tcf_proto *fl;
 
-	tcf_destroy_chain(&q->filter_list);
+	fl = rtnl_dereference(q->filter_list);
+	tcf_destroy_chain(&fl);
 	choke_free(q->tab);
 }
 
diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
index 8302717..899026f 100644
--- a/net/sched/sch_drr.c
+++ b/net/sched/sch_drr.c
@@ -35,7 +35,7 @@ struct drr_class {
 
 struct drr_sched {
 	struct list_head		active;
-	struct tcf_proto		*filter_list;
+	struct tcf_proto __rcu		*filter_list;
 	struct Qdisc_class_hash		clhash;
 };
 
@@ -319,6 +319,7 @@ static struct drr_class *drr_classify(struct sk_buff *skb, struct Qdisc *sch,
 	struct drr_sched *q = qdisc_priv(sch);
 	struct drr_class *cl;
 	struct tcf_result res;
+	struct tcf_proto *fl;
 	int result;
 
 	if (TC_H_MAJ(skb->priority ^ sch->handle) == 0) {
@@ -328,7 +329,8 @@ static struct drr_class *drr_classify(struct sk_buff *skb, struct Qdisc *sch,
 	}
 
 	*qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
-	result = tc_classify(skb, q->filter_list, &res);
+	fl = rcu_dereference_bh(q->filter_list);
+	result = tc_classify(skb, fl, &res);
 	if (result >= 0) {
 #ifdef CONFIG_NET_CLS_ACT
 		switch (result) {
@@ -467,9 +469,11 @@ static void drr_destroy_qdisc(struct Qdisc *sch)
 	struct drr_sched *q = qdisc_priv(sch);
 	struct drr_class *cl;
 	struct hlist_node *next;
+	struct tcf_proto *fl;
 	unsigned int i;
 
-	tcf_destroy_chain(&q->filter_list);
+	fl = rtnl_dereference(q->filter_list);
+	tcf_destroy_chain(&fl);
 
 	for (i = 0; i < q->clhash.hashsize; i++) {
 		hlist_for_each_entry_safe(cl, next, &q->clhash.hash[i],
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 49d6ef3..6b84bd4 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -37,7 +37,7 @@
 
 struct dsmark_qdisc_data {
 	struct Qdisc		*q;
-	struct tcf_proto	*filter_list;
+	struct tcf_proto __rcu	*filter_list;
 	u8			*mask;	/* "owns" the array */
 	u8			*value;
 	u16			indices;
@@ -229,7 +229,8 @@ static int dsmark_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		skb->tc_index = TC_H_MIN(skb->priority);
 	else {
 		struct tcf_result res;
-		int result = tc_classify(skb, p->filter_list, &res);
+		struct tcf_proto *fl = rcu_dereference_bh(p->filter_list);
+		int result = tc_classify(skb, fl, &res);
 
 		pr_debug("result %d class 0x%04x\n", result, res.classid);
 
@@ -404,10 +405,11 @@ static void dsmark_reset(struct Qdisc *sch)
 static void dsmark_destroy(struct Qdisc *sch)
 {
 	struct dsmark_qdisc_data *p = qdisc_priv(sch);
+	struct tcf_proto *fl = rtnl_dereference(p->filter_list);
 
 	pr_debug("%s(sch %p,[qdisc %p])\n", __func__, sch, p);
 
-	tcf_destroy_chain(&p->filter_list);
+	tcf_destroy_chain(&fl);
 	qdisc_destroy(p->q);
 	kfree(p->mask);
 }
diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index 5578628..bc47789 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -52,7 +52,7 @@ struct fq_codel_flow {
 }; /* please try to keep this structure <= 64 bytes */
 
 struct fq_codel_sched_data {
-	struct tcf_proto *filter_list;	/* optional external classifier */
+	struct tcf_proto __rcu *filter_list; /* optional external classifier */
 	struct fq_codel_flow *flows;	/* Flows table [flows_cnt] */
 	u32		*backlogs;	/* backlog table [flows_cnt] */
 	u32		flows_cnt;	/* number of flows */
@@ -84,6 +84,7 @@ static unsigned int fq_codel_classify(struct sk_buff *skb, struct Qdisc *sch,
 				      int *qerr)
 {
 	struct fq_codel_sched_data *q = qdisc_priv(sch);
+	struct tcf_proto *filter;
 	struct tcf_result res;
 	int result;
 
@@ -92,11 +93,12 @@ static unsigned int fq_codel_classify(struct sk_buff *skb, struct Qdisc *sch,
 	    TC_H_MIN(skb->priority) <= q->flows_cnt)
 		return TC_H_MIN(skb->priority);
 
-	if (!q->filter_list)
+	filter = rcu_dereference(q->filter_list);
+	if (!filter)
 		return fq_codel_hash(q, skb) + 1;
 
 	*qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
-	result = tc_classify(skb, q->filter_list, &res);
+	result = tc_classify(skb, filter, &res);
 	if (result >= 0) {
 #ifdef CONFIG_NET_CLS_ACT
 		switch (result) {
@@ -376,8 +378,9 @@ static void fq_codel_free(void *addr)
 static void fq_codel_destroy(struct Qdisc *sch)
 {
 	struct fq_codel_sched_data *q = qdisc_priv(sch);
+	struct tcf_proto *filter = rtnl_dereference(q->filter_list);
 
-	tcf_destroy_chain(&q->filter_list);
+	tcf_destroy_chain(&filter);
 	fq_codel_free(q->backlogs);
 	fq_codel_free(q->flows);
 }
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index c407561..0a7650f 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -116,7 +116,7 @@ struct hfsc_class {
 	struct gnet_stats_queue qstats;
 	struct gnet_stats_rate_est64 rate_est;
 	unsigned int	level;		/* class level in hierarchy */
-	struct tcf_proto *filter_list;	/* filter list */
+	struct tcf_proto __rcu *filter_list; /* filter list */
 	unsigned int	filter_cnt;	/* filter count */
 
 	struct hfsc_sched *sched;	/* scheduler data */
@@ -1110,8 +1110,10 @@ static void
 hfsc_destroy_class(struct Qdisc *sch, struct hfsc_class *cl)
 {
 	struct hfsc_sched *q = qdisc_priv(sch);
+	struct tcf_proto *fl;
 
-	tcf_destroy_chain(&cl->filter_list);
+	fl = rtnl_dereference(cl->filter_list);
+	tcf_destroy_chain(&fl);
 	qdisc_destroy(cl->qdisc);
 	gen_kill_estimator(&cl->bstats, &cl->rate_est);
 	if (cl != &q->root)
@@ -1161,7 +1163,7 @@ hfsc_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 
 	*qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
 	head = &q->root;
-	tcf = q->root.filter_list;
+	tcf = rcu_dereference_bh(q->root.filter_list);
 	while (tcf && (result = tc_classify(skb, tcf, &res)) >= 0) {
 #ifdef CONFIG_NET_CLS_ACT
 		switch (result) {
@@ -1185,7 +1187,7 @@ hfsc_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 			return cl; /* hit leaf class */
 
 		/* apply inner filter chain */
-		tcf = cl->filter_list;
+		tcf = rcu_dereference_bh(cl->filter_list);
 		head = cl;
 	}
 
@@ -1540,11 +1542,14 @@ hfsc_destroy_qdisc(struct Qdisc *sch)
 	struct hfsc_sched *q = qdisc_priv(sch);
 	struct hlist_node *next;
 	struct hfsc_class *cl;
+	struct tcf_proto *fl;
 	unsigned int i;
 
 	for (i = 0; i < q->clhash.hashsize; i++) {
-		hlist_for_each_entry(cl, &q->clhash.hash[i], cl_common.hnode)
-			tcf_destroy_chain(&cl->filter_list);
+		hlist_for_each_entry(cl, &q->clhash.hash[i], cl_common.hnode) {
+			fl = rtnl_dereference(cl->filter_list);
+			tcf_destroy_chain(&fl);
+		}
 	}
 	for (i = 0; i < q->clhash.hashsize; i++) {
 		hlist_for_each_entry_safe(cl, next, &q->clhash.hash[i],
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 0db5a6e..86df75c 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -103,7 +103,7 @@ struct htb_class {
 	u32			prio;		/* these two are used only by leaves... */
 	int			quantum;	/* but stored for parent-to-leaf return */
 
-	struct tcf_proto	*filter_list;	/* class attached filters */
+	struct tcf_proto __rcu	*filter_list;	/* class attached filters */
 	int			filter_cnt;
 	int			refcnt;		/* usage count of this class */
 
@@ -153,7 +153,7 @@ struct htb_sched {
 	int			rate2quantum;	/* quant = rate / rate2quantum */
 
 	/* filters for qdisc itself */
-	struct tcf_proto	*filter_list;
+	struct tcf_proto __rcu	*filter_list;
 
 #define HTB_WARN_TOOMANYEVENTS	0x1
 	unsigned int		warned;	/* only one warning */
@@ -223,7 +223,7 @@ static struct htb_class *htb_classify(struct sk_buff *skb, struct Qdisc *sch,
 		return cl;
 
 	*qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
-	tcf = q->filter_list;
+	tcf = rcu_dereference_bh(q->filter_list);
 	while (tcf && (result = tc_classify(skb, tcf, &res)) >= 0) {
 #ifdef CONFIG_NET_CLS_ACT
 		switch (result) {
@@ -246,7 +246,7 @@ static struct htb_class *htb_classify(struct sk_buff *skb, struct Qdisc *sch,
 			return cl;	/* we hit leaf; return it */
 
 		/* we have got inner class; apply inner filter chain */
-		tcf = cl->filter_list;
+		tcf = rcu_dereference_bh(cl->filter_list);
 	}
 	/* classification failed; try to use default class */
 	cl = htb_find(TC_H_MAKE(TC_H_MAJ(sch->handle), q->defcls), sch);
@@ -1230,12 +1230,15 @@ static void htb_parent_to_leaf(struct htb_sched *q, struct htb_class *cl,
 
 static void htb_destroy_class(struct Qdisc *sch, struct htb_class *cl)
 {
+	struct tcf_proto *fl;
+
 	if (!cl->level) {
 		WARN_ON(!cl->un.leaf.q);
 		qdisc_destroy(cl->un.leaf.q);
 	}
 	gen_kill_estimator(&cl->bstats, &cl->rate_est);
-	tcf_destroy_chain(&cl->filter_list);
+	fl = rtnl_dereference(cl->filter_list);
+	tcf_destroy_chain(&fl);
 	kfree(cl);
 }
 
@@ -1244,6 +1247,7 @@ static void htb_destroy(struct Qdisc *sch)
 	struct htb_sched *q = qdisc_priv(sch);
 	struct hlist_node *next;
 	struct htb_class *cl;
+	struct tcf_proto *fl;
 	unsigned int i;
 
 	cancel_work_sync(&q->work);
@@ -1253,11 +1257,14 @@ static void htb_destroy(struct Qdisc *sch)
 	 * because filter need its target class alive to be able to call
 	 * unbind_filter on it (without Oops).
 	 */
-	tcf_destroy_chain(&q->filter_list);
+	fl = rtnl_dereference(q->filter_list);
+	tcf_destroy_chain(&fl);
 
 	for (i = 0; i < q->clhash.hashsize; i++) {
-		hlist_for_each_entry(cl, &q->clhash.hash[i], common.hnode)
-			tcf_destroy_chain(&cl->filter_list);
+		hlist_for_each_entry(cl, &q->clhash.hash[i], common.hnode) {
+			fl = rtnl_dereference(cl->filter_list);
+			tcf_destroy_chain(&fl);
+		}
 	}
 	for (i = 0; i < q->clhash.hashsize; i++) {
 		hlist_for_each_entry_safe(cl, next, &q->clhash.hash[i],
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index bce1665..f7c80d3 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -17,7 +17,7 @@
 
 
 struct ingress_qdisc_data {
-	struct tcf_proto	*filter_list;
+	struct tcf_proto __rcu	*filter_list;
 };
 
 /* ------------------------- Class/flow operations ------------------------- */
@@ -59,9 +59,10 @@ static int ingress_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct ingress_qdisc_data *p = qdisc_priv(sch);
 	struct tcf_result res;
+	struct tcf_proto *fl = rcu_dereference_bh(p->filter_list);
 	int result;
 
-	result = tc_classify(skb, p->filter_list, &res);
+	result = tc_classify(skb, fl, &res);
 
 	qdisc_bstats_update(sch, skb);
 	switch (result) {
@@ -89,8 +90,9 @@ static int ingress_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 static void ingress_destroy(struct Qdisc *sch)
 {
 	struct ingress_qdisc_data *p = qdisc_priv(sch);
+	struct tcf_proto *fl = rtnl_dereference(p->filter_list);
 
-	tcf_destroy_chain(&p->filter_list);
+	tcf_destroy_chain(&fl);
 }
 
 static int ingress_dump(struct Qdisc *sch, struct sk_buff *skb)
diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
index afb050a..169d637 100644
--- a/net/sched/sch_multiq.c
+++ b/net/sched/sch_multiq.c
@@ -31,7 +31,7 @@ struct multiq_sched_data {
 	u16 bands;
 	u16 max_bands;
 	u16 curband;
-	struct tcf_proto *filter_list;
+	struct tcf_proto __rcu *filter_list;
 	struct Qdisc **queues;
 };
 
@@ -42,10 +42,11 @@ multiq_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 	struct multiq_sched_data *q = qdisc_priv(sch);
 	u32 band;
 	struct tcf_result res;
+	struct tcf_proto *fl = rcu_dereference_bh(q->filter_list);
 	int err;
 
 	*qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
-	err = tc_classify(skb, q->filter_list, &res);
+	err = tc_classify(skb, fl, &res);
 #ifdef CONFIG_NET_CLS_ACT
 	switch (err) {
 	case TC_ACT_STOLEN:
@@ -188,8 +189,9 @@ multiq_destroy(struct Qdisc *sch)
 {
 	int band;
 	struct multiq_sched_data *q = qdisc_priv(sch);
+	struct tcf_proto *fl = rtnl_dereference(q->filter_list);
 
-	tcf_destroy_chain(&q->filter_list);
+	tcf_destroy_chain(&fl);
 	for (band = 0; band < q->bands; band++)
 		qdisc_destroy(q->queues[band]);
 
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 79359b6..43aa35d 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -24,7 +24,7 @@
 
 struct prio_sched_data {
 	int bands;
-	struct tcf_proto *filter_list;
+	struct tcf_proto __rcu *filter_list;
 	u8  prio2band[TC_PRIO_MAX+1];
 	struct Qdisc *queues[TCQ_PRIO_BANDS];
 };
@@ -36,11 +36,13 @@ prio_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 	struct prio_sched_data *q = qdisc_priv(sch);
 	u32 band = skb->priority;
 	struct tcf_result res;
+	struct tcf_proto *fl;
 	int err;
 
 	*qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
 	if (TC_H_MAJ(skb->priority) != sch->handle) {
-		err = tc_classify(skb, q->filter_list, &res);
+		fl = rcu_dereference_bh(q->filter_list);
+		err = tc_classify(skb, fl, &res);
 #ifdef CONFIG_NET_CLS_ACT
 		switch (err) {
 		case TC_ACT_STOLEN:
@@ -50,7 +52,7 @@ prio_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 			return NULL;
 		}
 #endif
-		if (!q->filter_list || err < 0) {
+		if (!fl || err < 0) {
 			if (TC_H_MAJ(band))
 				band = 0;
 			return q->queues[q->prio2band[band & TC_PRIO_MAX]];
@@ -157,8 +159,9 @@ prio_destroy(struct Qdisc *sch)
 {
 	int prio;
 	struct prio_sched_data *q = qdisc_priv(sch);
+	struct tcf_proto *fl = rtnl_dereference(q->filter_list);
 
-	tcf_destroy_chain(&q->filter_list);
+	tcf_destroy_chain(&fl);
 	for (prio = 0; prio < q->bands; prio++)
 		qdisc_destroy(q->queues[prio]);
 }
diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index 8056fb4..cee5618 100644
--- a/net/sched/sch_qfq.c
+++ b/net/sched/sch_qfq.c
@@ -181,7 +181,7 @@ struct qfq_group {
 };
 
 struct qfq_sched {
-	struct tcf_proto *filter_list;
+	struct tcf_proto __rcu *filter_list;
 	struct Qdisc_class_hash clhash;
 
 	u64			oldV, V;	/* Precise virtual times. */
@@ -704,6 +704,7 @@ static struct qfq_class *qfq_classify(struct sk_buff *skb, struct Qdisc *sch,
 	struct qfq_sched *q = qdisc_priv(sch);
 	struct qfq_class *cl;
 	struct tcf_result res;
+	struct tcf_proto *fl;
 	int result;
 
 	if (TC_H_MAJ(skb->priority ^ sch->handle) == 0) {
@@ -714,7 +715,8 @@ static struct qfq_class *qfq_classify(struct sk_buff *skb, struct Qdisc *sch,
 	}
 
 	*qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
-	result = tc_classify(skb, q->filter_list, &res);
+	fl = rcu_dereference_bh(q->filter_list);
+	result = tc_classify(skb, fl, &res);
 	if (result >= 0) {
 #ifdef CONFIG_NET_CLS_ACT
 		switch (result) {
@@ -1524,9 +1526,10 @@ static void qfq_destroy_qdisc(struct Qdisc *sch)
 	struct qfq_sched *q = qdisc_priv(sch);
 	struct qfq_class *cl;
 	struct hlist_node *next;
+	struct tcf_proto *fl = rtnl_dereference(q->filter_list);
 	unsigned int i;
 
-	tcf_destroy_chain(&q->filter_list);
+	tcf_destroy_chain(&fl);
 
 	for (i = 0; i < q->clhash.hashsize; i++) {
 		hlist_for_each_entry_safe(cl, next, &q->clhash.hash[i],
diff --git a/net/sched/sch_sfb.c b/net/sched/sch_sfb.c
index 30ea467..a4f1d6c 100644
--- a/net/sched/sch_sfb.c
+++ b/net/sched/sch_sfb.c
@@ -55,7 +55,7 @@ struct sfb_bins {
 
 struct sfb_sched_data {
 	struct Qdisc	*qdisc;
-	struct tcf_proto *filter_list;
+	struct tcf_proto __rcu *filter_list;
 	unsigned long	rehash_interval;
 	unsigned long	warmup_time;	/* double buffering warmup time in jiffies */
 	u32		max;
@@ -253,13 +253,13 @@ static bool sfb_rate_limit(struct sk_buff *skb, struct sfb_sched_data *q)
 	return false;
 }
 
-static bool sfb_classify(struct sk_buff *skb, struct sfb_sched_data *q,
+static bool sfb_classify(struct sk_buff *skb, struct tcf_proto *fl,
 			 int *qerr, u32 *salt)
 {
 	struct tcf_result res;
 	int result;
 
-	result = tc_classify(skb, q->filter_list, &res);
+	result = tc_classify(skb, fl, &res);
 	if (result >= 0) {
 #ifdef CONFIG_NET_CLS_ACT
 		switch (result) {
@@ -281,6 +281,7 @@ static int sfb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 	struct sfb_sched_data *q = qdisc_priv(sch);
 	struct Qdisc *child = q->qdisc;
+	struct tcf_proto *fl;
 	int i;
 	u32 p_min = ~0;
 	u32 minqlen = ~0;
@@ -306,9 +307,10 @@ static int sfb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		}
 	}
 
-	if (q->filter_list) {
+	fl = rcu_dereference_bh(q->filter_list);
+	if (fl) {
 		/* If using external classifiers, get result and record it. */
-		if (!sfb_classify(skb, q, &ret, &salt))
+		if (!sfb_classify(skb, fl, &ret, &salt))
 			goto other_drop;
 		keys.src = salt;
 		keys.dst = 0;
@@ -465,8 +467,9 @@ static void sfb_reset(struct Qdisc *sch)
 static void sfb_destroy(struct Qdisc *sch)
 {
 	struct sfb_sched_data *q = qdisc_priv(sch);
+	struct tcf_proto *fl = rtnl_dereference(q->filter_list);
 
-	tcf_destroy_chain(&q->filter_list);
+	tcf_destroy_chain(&fl);
 	qdisc_destroy(q->qdisc);
 }
 
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 76f01e0..da24df01 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -125,7 +125,7 @@ struct sfq_sched_data {
 	u8		cur_depth;	/* depth of longest slot */
 	u8		flags;
 	unsigned short  scaled_quantum; /* SFQ_ALLOT_SIZE(quantum) */
-	struct tcf_proto *filter_list;
+	struct tcf_proto __rcu *filter_list;
 	sfq_index	*ht;		/* Hash table ('divisor' slots) */
 	struct sfq_slot	*slots;		/* Flows table ('maxflows' entries) */
 
@@ -187,6 +187,7 @@ static unsigned int sfq_classify(struct sk_buff *skb, struct Qdisc *sch,
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
 	struct tcf_result res;
+	struct tcf_proto *fl;
 	int result;
 
 	if (TC_H_MAJ(skb->priority) == sch->handle &&
@@ -194,13 +195,14 @@ static unsigned int sfq_classify(struct sk_buff *skb, struct Qdisc *sch,
 	    TC_H_MIN(skb->priority) <= q->divisor)
 		return TC_H_MIN(skb->priority);
 
-	if (!q->filter_list) {
+	fl = rcu_dereference_bh(q->filter_list);
+	if (!fl) {
 		skb_flow_dissect(skb, &sfq_skb_cb(skb)->keys);
 		return sfq_hash(q, skb) + 1;
 	}
 
 	*qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
-	result = tc_classify(skb, q->filter_list, &res);
+	result = tc_classify(skb, fl, &res);
 	if (result >= 0) {
 #ifdef CONFIG_NET_CLS_ACT
 		switch (result) {
@@ -727,8 +729,9 @@ static void sfq_free(void *addr)
 static void sfq_destroy(struct Qdisc *sch)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
+	struct tcf_proto *fl = rtnl_dereference(q->filter_list);
 
-	tcf_destroy_chain(&q->filter_list);
+	tcf_destroy_chain(&fl);
 	q->perturb_period = 0;
 	del_timer_sync(&q->perturb_timer);
 	sfq_free(q->ht);
