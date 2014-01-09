From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [RFC Patch net-next 1/4] net_sched: switch filter list to list_head
Date: Thu,  9 Jan 2014 10:19:50 -0800
Message-ID: <1389291593-2494-2-git-send-email-xiyou.wangcong@gmail.com>
References: <1389291593-2494-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:39029 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753729AbaAISUL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 13:20:11 -0500
Received: by mail-pd0-f182.google.com with SMTP id v10so3470432pde.41
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 10:20:10 -0800 (PST)
In-Reply-To: <1389291593-2494-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So that it could be potentially traversed with RCU.

Cc: John Fastabend <john.fastabend@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/pkt_sched.h   |  4 ++--
 include/net/sch_generic.h |  9 ++++++---
 net/sched/cls_api.c       | 36 ++++++++++++++++++++++++------------
 net/sched/sch_api.c       | 35 ++++++++++++++++++++++-------------
 net/sched/sch_atm.c       | 14 +++++++-------
 net/sched/sch_cbq.c       |  9 +++++----
 net/sched/sch_choke.c     | 11 ++++++-----
 net/sched/sch_drr.c       |  7 ++++---
 net/sched/sch_dsmark.c    |  7 ++++---
 net/sched/sch_fq_codel.c  |  9 +++++----
 net/sched/sch_hfsc.c      | 15 +++++++++------
 net/sched/sch_htb.c       | 20 ++++++++++++--------
 net/sched/sch_ingress.c   | 14 +++++++++++---
 net/sched/sch_multiq.c    |  7 ++++---
 net/sched/sch_prio.c      |  9 +++++----
 net/sched/sch_qfq.c       |  7 ++++---
 net/sched/sch_sfb.c       |  9 +++++----
 net/sched/sch_sfq.c       | 11 ++++++-----
 18 files changed, 141 insertions(+), 92 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index 891d80d..27a1efa 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -109,9 +109,9 @@ static inline void qdisc_run(struct Qdisc *q)
 		__qdisc_run(q);
 }
 
-int tc_classify_compat(struct sk_buff *skb, const struct tcf_proto *tp,
+int tc_classify_compat(struct sk_buff *skb, const struct list_head *head,
 		       struct tcf_result *res);
-int tc_classify(struct sk_buff *skb, const struct tcf_proto *tp,
+int tc_classify(struct sk_buff *skb, const struct list_head *head,
 		struct tcf_result *res);
 
 /* Calculate maximal size of packet seen by hard_start_xmit
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 013d96d..97123cc 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -6,6 +6,7 @@
 #include <linux/rcupdate.h>
 #include <linux/pkt_sched.h>
 #include <linux/pkt_cls.h>
+#include <linux/list.h>
 #include <net/gen_stats.h>
 #include <net/rtnetlink.h>
 
@@ -143,7 +144,7 @@ struct Qdisc_class_ops {
 	void			(*walk)(struct Qdisc *, struct qdisc_walker * arg);
 
 	/* Filter manipulation */
-	struct tcf_proto **	(*tcf_chain)(struct Qdisc *, unsigned long);
+	struct list_head *	(*tcf_chain)(struct Qdisc *, unsigned long);
 	unsigned long		(*bind_tcf)(struct Qdisc *, unsigned long,
 					u32 classid);
 	void			(*unbind_tcf)(struct Qdisc *, unsigned long);
@@ -184,6 +185,8 @@ struct tcf_result {
 	u32		classid;
 };
 
+struct tcf_proto;
+
 struct tcf_proto_ops {
 	struct list_head	head;
 	char			kind[IFNAMSIZ];
@@ -212,7 +215,7 @@ struct tcf_proto_ops {
 
 struct tcf_proto {
 	/* Fast access part */
-	struct tcf_proto	*next;
+	struct list_head	head;
 	void			*root;
 	int			(*classify)(struct sk_buff *,
 					    const struct tcf_proto *,
@@ -376,7 +379,7 @@ struct Qdisc *qdisc_create_dflt(struct netdev_queue *dev_queue,
 void __qdisc_calculate_pkt_len(struct sk_buff *skb,
 			       const struct qdisc_size_table *stab);
 void tcf_destroy(struct tcf_proto *tp);
-void tcf_destroy_chain(struct tcf_proto **fl);
+void tcf_destroy_chain(struct list_head *fl);
 
 /* Reset all TX qdiscs greater then index of a device.  */
 static inline void qdisc_reset_all_tx_gt(struct net_device *dev, unsigned int i)
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index d8c42b1..bcc9987 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -125,8 +125,9 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
 	u32 parent;
 	struct net_device *dev;
 	struct Qdisc  *q;
-	struct tcf_proto **back, **chain;
-	struct tcf_proto *tp;
+	struct tcf_proto *back;
+	struct list_head *chain;
+	struct tcf_proto *tp, *res = NULL;
 	const struct tcf_proto_ops *tp_ops;
 	const struct Qdisc_class_ops *cops;
 	unsigned long cl;
@@ -196,21 +197,27 @@ replay:
 		goto errout;
 
 	/* Check the chain for existence of proto-tcf with this priority */
-	for (back = chain; (tp = *back) != NULL; back = &tp->next) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(tp, chain, head) {
+		back = list_next_entry(tp, head);
 		if (tp->prio >= prio) {
 			if (tp->prio == prio) {
 				if (!nprio ||
-				    (tp->protocol != protocol && protocol))
+				    (tp->protocol != protocol && protocol)) {
+					rcu_read_unlock();
 					goto errout;
+				}
+				res = tp;
 			} else
-				tp = NULL;
+				res = NULL;
 			break;
 		}
 	}
+	rcu_read_unlock();
 
 	root_lock = qdisc_root_sleeping_lock(q);
 
-	if (tp == NULL) {
+	if ((tp = res) == NULL) {
 		/* Proto-tcf does not exist, create new one */
 
 		if (tca[TCA_KIND] == NULL || !protocol)
@@ -228,6 +235,7 @@ replay:
 		tp = kzalloc(sizeof(*tp), GFP_KERNEL);
 		if (tp == NULL)
 			goto errout;
+		INIT_LIST_HEAD(&tp->head);
 		err = -ENOENT;
 		tp_ops = tcf_proto_lookup_ops(tca[TCA_KIND]);
 		if (tp_ops == NULL) {
@@ -258,7 +266,7 @@ replay:
 		}
 		tp->ops = tp_ops;
 		tp->protocol = protocol;
-		tp->prio = nprio ? : TC_H_MAJ(tcf_auto_prio(*back));
+		tp->prio = nprio ? : TC_H_MAJ(tcf_auto_prio(back));
 		tp->q = q;
 		tp->classify = tp_ops->classify;
 		tp->classid = parent;
@@ -280,7 +288,7 @@ replay:
 	if (fh == 0) {
 		if (n->nlmsg_type == RTM_DELTFILTER && t->tcm_handle == 0) {
 			spin_lock_bh(root_lock);
-			*back = tp->next;
+			list_del_rcu(&tp->head);
 			spin_unlock_bh(root_lock);
 
 			tfilter_notify(net, skb, n, tp, fh, RTM_DELTFILTER);
@@ -321,8 +329,7 @@ replay:
 	if (err == 0) {
 		if (tp_created) {
 			spin_lock_bh(root_lock);
-			tp->next = *back;
-			*back = tp;
+			list_add_rcu(&tp->head, chain);
 			spin_unlock_bh(root_lock);
 		}
 		tfilter_notify(net, skb, n, tp, fh, RTM_NEWTFILTER);
@@ -417,7 +424,8 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 	int s_t;
 	struct net_device *dev;
 	struct Qdisc *q;
-	struct tcf_proto *tp, **chain;
+	struct tcf_proto *tp;
+	struct list_head *chain;
 	struct tcmsg *tcm = nlmsg_data(cb->nlh);
 	unsigned long cl = 0;
 	const struct Qdisc_class_ops *cops;
@@ -451,7 +459,9 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 
 	s_t = cb->args[0];
 
-	for (tp = *chain, t = 0; tp; tp = tp->next, t++) {
+	t = 0;
+	rcu_read_lock();
+	list_for_each_entry_rcu(tp, chain, head) {
 		if (t < s_t)
 			continue;
 		if (TC_H_MAJ(tcm->tcm_info) &&
@@ -482,7 +492,9 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 		cb->args[1] = arg.w.count + 1;
 		if (arg.w.stop)
 			break;
+		t++;
 	}
+	rcu_read_unlock();
 
 	cb->args[0] = t;
 
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 1313145..df86686 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -29,6 +29,7 @@
 #include <linux/hrtimer.h>
 #include <linux/lockdep.h>
 #include <linux/slab.h>
+#include <linux/rculist.h>
 
 #include <net/net_namespace.h>
 #include <net/sock.h>
@@ -1772,13 +1773,15 @@ done:
  * to this qdisc, (optionally) tests for protocol and asks
  * specific classifiers.
  */
-int tc_classify_compat(struct sk_buff *skb, const struct tcf_proto *tp,
+int tc_classify_compat(struct sk_buff *skb, const struct list_head *head,
 		       struct tcf_result *res)
 {
+	struct tcf_proto *tp;
 	__be16 protocol = skb->protocol;
-	int err;
+	int err = -1;
 
-	for (; tp; tp = tp->next) {
+	WARN_ON_ONCE(!rcu_read_lock_held());
+	list_for_each_entry_rcu(tp, head, head) {
 		if (tp->protocol != protocol &&
 		    tp->protocol != htons(ETH_P_ALL))
 			continue;
@@ -1789,23 +1792,25 @@ int tc_classify_compat(struct sk_buff *skb, const struct tcf_proto *tp,
 			if (err != TC_ACT_RECLASSIFY && skb->tc_verd)
 				skb->tc_verd = SET_TC_VERD(skb->tc_verd, 0);
 #endif
-			return err;
+			break;
 		}
 	}
-	return -1;
+
+	return err;
 }
 EXPORT_SYMBOL(tc_classify_compat);
 
-int tc_classify(struct sk_buff *skb, const struct tcf_proto *tp,
+int tc_classify(struct sk_buff *skb, const struct list_head *head,
 		struct tcf_result *res)
 {
 	int err = 0;
 #ifdef CONFIG_NET_CLS_ACT
-	const struct tcf_proto *otp = tp;
+	const struct tcf_proto *tp;
+	const struct tcf_proto *otp = list_first_entry(head, struct tcf_proto, head);
 reclassify:
 #endif
 
-	err = tc_classify_compat(skb, tp, res);
+	err = tc_classify_compat(skb, head, res);
 #ifdef CONFIG_NET_CLS_ACT
 	if (err == TC_ACT_RECLASSIFY) {
 		u32 verd = G_TC_VERD(skb->tc_verd);
@@ -1830,16 +1835,20 @@ void tcf_destroy(struct tcf_proto *tp)
 {
 	tp->ops->destroy(tp);
 	module_put(tp->ops->owner);
+	synchronize_rcu();
 	kfree(tp);
 }
 
-void tcf_destroy_chain(struct tcf_proto **fl)
+void tcf_destroy_chain(struct list_head *fl)
 {
-	struct tcf_proto *tp;
+	struct tcf_proto *tp, *n;
+	LIST_HEAD(list);
+	list_splice_init_rcu(fl, &list, synchronize_rcu);
 
-	while ((tp = *fl) != NULL) {
-		*fl = tp->next;
-		tcf_destroy(tp);
+	list_for_each_entry_safe(tp, n, &list, head) {
+		tp->ops->destroy(tp);
+		module_put(tp->ops->owner);
+		kfree(tp);
 	}
 }
 EXPORT_SYMBOL(tcf_destroy_chain);
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 1f9c314..20a07c2 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -41,7 +41,7 @@
 
 struct atm_flow_data {
 	struct Qdisc		*q;	/* FIFO, TBF, etc. */
-	struct tcf_proto	*filter_list;
+	struct list_head 	filter_list;
 	struct atm_vcc		*vcc;	/* VCC; NULL if VCC is closed */
 	void			(*old_pop)(struct atm_vcc *vcc,
 					   struct sk_buff *skb); /* chaining */
@@ -273,7 +273,7 @@ static int atm_tc_change(struct Qdisc *sch, u32 classid, u32 parent,
 		error = -ENOBUFS;
 		goto err_out;
 	}
-	flow->filter_list = NULL;
+	INIT_LIST_HEAD(&flow->filter_list);
 	flow->q = qdisc_create_dflt(sch->dev_queue, &pfifo_qdisc_ops, classid);
 	if (!flow->q)
 		flow->q = &noop_qdisc;
@@ -311,7 +311,7 @@ static int atm_tc_delete(struct Qdisc *sch, unsigned long arg)
 	pr_debug("atm_tc_delete(sch %p,[qdisc %p],flow %p)\n", sch, p, flow);
 	if (list_empty(&flow->list))
 		return -EINVAL;
-	if (flow->filter_list || flow == &p->link)
+	if (!list_empty(&flow->filter_list) || flow == &p->link)
 		return -EBUSY;
 	/*
 	 * Reference count must be 2: one for "keepalive" (set at class
@@ -345,7 +345,7 @@ static void atm_tc_walk(struct Qdisc *sch, struct qdisc_walker *walker)
 	}
 }
 
-static struct tcf_proto **atm_tc_find_tcf(struct Qdisc *sch, unsigned long cl)
+static struct list_head *atm_tc_find_tcf(struct Qdisc *sch, unsigned long cl)
 {
 	struct atm_qdisc_data *p = qdisc_priv(sch);
 	struct atm_flow_data *flow = (struct atm_flow_data *)cl;
@@ -370,9 +370,9 @@ static int atm_tc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	if (TC_H_MAJ(skb->priority) != sch->handle ||
 	    !(flow = (struct atm_flow_data *)atm_tc_get(sch, skb->priority))) {
 		list_for_each_entry(flow, &p->flows, list) {
-			if (flow->filter_list) {
+			if (!list_empty(&flow->filter_list)) {
 				result = tc_classify_compat(skb,
-							    flow->filter_list,
+							    &flow->filter_list,
 							    &res);
 				if (result < 0)
 					continue;
@@ -544,7 +544,7 @@ static int atm_tc_init(struct Qdisc *sch, struct nlattr *opt)
 	if (!p->link.q)
 		p->link.q = &noop_qdisc;
 	pr_debug("atm_tc_init: link (%p) qdisc %p\n", &p->link, p->link.q);
-	p->link.filter_list = NULL;
+	INIT_LIST_HEAD(&p->link.filter_list);
 	p->link.vcc = NULL;
 	p->link.sock = NULL;
 	p->link.classid = sch->handle;
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 2f80d01..a5914ff 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -133,7 +133,7 @@ struct cbq_class {
 	struct gnet_stats_rate_est64 rate_est;
 	struct tc_cbq_xstats	xstats;
 
-	struct tcf_proto	*filter_list;
+	struct list_head	filter_list;
 
 	int			refcnt;
 	int			filters;
@@ -239,8 +239,8 @@ cbq_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 		/*
 		 * Step 2+n. Apply classifier.
 		 */
-		if (!head->filter_list ||
-		    (result = tc_classify_compat(skb, head->filter_list, &res)) < 0)
+		if (list_empty(&head->filter_list) ||
+		    (result = tc_classify_compat(skb, &head->filter_list, &res)) < 0)
 			goto fallback;
 
 		cl = (void *)res.class;
@@ -1881,6 +1881,7 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct nlattr **t
 		}
 	}
 
+	INIT_LIST_HEAD(&cl->filter_list);
 	cl->R_tab = rtab;
 	rtab = NULL;
 	cl->refcnt = 1;
@@ -1976,7 +1977,7 @@ static int cbq_delete(struct Qdisc *sch, unsigned long arg)
 	return 0;
 }
 
-static struct tcf_proto **cbq_find_tcf(struct Qdisc *sch, unsigned long arg)
+static struct list_head *cbq_find_tcf(struct Qdisc *sch, unsigned long arg)
 {
 	struct cbq_sched_data *q = qdisc_priv(sch);
 	struct cbq_class *cl = (struct cbq_class *)arg;
diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
index ddd73cb..9b36830 100644
--- a/net/sched/sch_choke.c
+++ b/net/sched/sch_choke.c
@@ -58,7 +58,7 @@ struct choke_sched_data {
 
 /* Variables */
 	struct red_vars  vars;
-	struct tcf_proto *filter_list;
+	struct list_head filter_list;
 	struct {
 		u32	prob_drop;	/* Early probability drops */
 		u32	prob_mark;	/* Early probability marks */
@@ -202,7 +202,7 @@ static bool choke_classify(struct sk_buff *skb,
 	struct tcf_result res;
 	int result;
 
-	result = tc_classify(skb, q->filter_list, &res);
+	result = tc_classify(skb, &q->filter_list, &res);
 	if (result >= 0) {
 #ifdef CONFIG_NET_CLS_ACT
 		switch (result) {
@@ -256,7 +256,7 @@ static bool choke_match_random(const struct choke_sched_data *q,
 		return false;
 
 	oskb = choke_peek_random(q, pidx);
-	if (q->filter_list)
+	if (!list_empty(&q->filter_list))
 		return choke_get_classid(nskb) == choke_get_classid(oskb);
 
 	return choke_match_flow(oskb, nskb);
@@ -268,7 +268,7 @@ static int choke_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	const struct red_parms *p = &q->parms;
 	int ret = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
 
-	if (q->filter_list) {
+	if (!list_empty(&q->filter_list)) {
 		/* If using external classifiers, get result and record it. */
 		if (!choke_classify(skb, sch, &ret))
 			goto other_drop;	/* Packet was eaten by filter */
@@ -476,6 +476,7 @@ static int choke_change(struct Qdisc *sch, struct nlattr *opt)
 
 	q->flags = ctl->flags;
 	q->limit = ctl->limit;
+	INIT_LIST_HEAD(&q->filter_list);
 
 	red_set_parms(&q->parms, ctl->qth_min, ctl->qth_max, ctl->Wlog,
 		      ctl->Plog, ctl->Scell_log,
@@ -566,7 +567,7 @@ static unsigned long choke_bind(struct Qdisc *sch, unsigned long parent,
 	return 0;
 }
 
-static struct tcf_proto **choke_find_tcf(struct Qdisc *sch, unsigned long cl)
+static struct list_head *choke_find_tcf(struct Qdisc *sch, unsigned long cl)
 {
 	struct choke_sched_data *q = qdisc_priv(sch);
 
diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
index 8302717..62f45ac 100644
--- a/net/sched/sch_drr.c
+++ b/net/sched/sch_drr.c
@@ -35,7 +35,7 @@ struct drr_class {
 
 struct drr_sched {
 	struct list_head		active;
-	struct tcf_proto		*filter_list;
+	struct list_head		filter_list;
 	struct Qdisc_class_hash		clhash;
 };
 
@@ -184,7 +184,7 @@ static void drr_put_class(struct Qdisc *sch, unsigned long arg)
 		drr_destroy_class(sch, cl);
 }
 
-static struct tcf_proto **drr_tcf_chain(struct Qdisc *sch, unsigned long cl)
+static struct list_head *drr_tcf_chain(struct Qdisc *sch, unsigned long cl)
 {
 	struct drr_sched *q = qdisc_priv(sch);
 
@@ -328,7 +328,7 @@ static struct drr_class *drr_classify(struct sk_buff *skb, struct Qdisc *sch,
 	}
 
 	*qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
-	result = tc_classify(skb, q->filter_list, &res);
+	result = tc_classify(skb, &q->filter_list, &res);
 	if (result >= 0) {
 #ifdef CONFIG_NET_CLS_ACT
 		switch (result) {
@@ -443,6 +443,7 @@ static int drr_init_qdisc(struct Qdisc *sch, struct nlattr *opt)
 	if (err < 0)
 		return err;
 	INIT_LIST_HEAD(&q->active);
+	INIT_LIST_HEAD(&q->filter_list);
 	return 0;
 }
 
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 49d6ef3..4489ffe 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -37,7 +37,7 @@
 
 struct dsmark_qdisc_data {
 	struct Qdisc		*q;
-	struct tcf_proto	*filter_list;
+	struct list_head	filter_list;
 	u8			*mask;	/* "owns" the array */
 	u8			*value;
 	u16			indices;
@@ -186,7 +186,7 @@ ignore:
 	}
 }
 
-static inline struct tcf_proto **dsmark_find_tcf(struct Qdisc *sch,
+static inline struct list_head *dsmark_find_tcf(struct Qdisc *sch,
 						 unsigned long cl)
 {
 	struct dsmark_qdisc_data *p = qdisc_priv(sch);
@@ -229,7 +229,7 @@ static int dsmark_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		skb->tc_index = TC_H_MIN(skb->priority);
 	else {
 		struct tcf_result res;
-		int result = tc_classify(skb, p->filter_list, &res);
+		int result = tc_classify(skb, &p->filter_list, &res);
 
 		pr_debug("result %d class 0x%04x\n", result, res.classid);
 
@@ -380,6 +380,7 @@ static int dsmark_init(struct Qdisc *sch, struct nlattr *opt)
 	p->indices = indices;
 	p->default_index = default_index;
 	p->set_tc_index = nla_get_flag(tb[TCA_DSMARK_SET_TC_INDEX]);
+	INIT_LIST_HEAD(&p->filter_list);
 
 	p->q = qdisc_create_dflt(sch->dev_queue, &pfifo_qdisc_ops, sch->handle);
 	if (p->q == NULL)
diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index 5578628..3c19917 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -52,7 +52,7 @@ struct fq_codel_flow {
 }; /* please try to keep this structure <= 64 bytes */
 
 struct fq_codel_sched_data {
-	struct tcf_proto *filter_list;	/* optional external classifier */
+	struct list_head filter_list;	/* optional external classifier */
 	struct fq_codel_flow *flows;	/* Flows table [flows_cnt] */
 	u32		*backlogs;	/* backlog table [flows_cnt] */
 	u32		flows_cnt;	/* number of flows */
@@ -92,11 +92,11 @@ static unsigned int fq_codel_classify(struct sk_buff *skb, struct Qdisc *sch,
 	    TC_H_MIN(skb->priority) <= q->flows_cnt)
 		return TC_H_MIN(skb->priority);
 
-	if (!q->filter_list)
+	if (list_emty(&q->filter_list))
 		return fq_codel_hash(q, skb) + 1;
 
 	*qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
-	result = tc_classify(skb, q->filter_list, &res);
+	result = tc_classify(skb, &q->filter_list, &res);
 	if (result >= 0) {
 #ifdef CONFIG_NET_CLS_ACT
 		switch (result) {
@@ -393,6 +393,7 @@ static int fq_codel_init(struct Qdisc *sch, struct nlattr *opt)
 	q->perturbation = net_random();
 	INIT_LIST_HEAD(&q->new_flows);
 	INIT_LIST_HEAD(&q->old_flows);
+	INIT_LIST_HEAD(&q->filter_list);
 	codel_params_init(&q->cparams);
 	codel_stats_init(&q->cstats);
 	q->cparams.ecn = true;
@@ -501,7 +502,7 @@ static void fq_codel_put(struct Qdisc *q, unsigned long cl)
 {
 }
 
-static struct tcf_proto **fq_codel_find_tcf(struct Qdisc *sch, unsigned long cl)
+static struct list_head *fq_codel_find_tcf(struct Qdisc *sch, unsigned long cl)
 {
 	struct fq_codel_sched_data *q = qdisc_priv(sch);
 
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index c407561..8bb4ade 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -116,7 +116,7 @@ struct hfsc_class {
 	struct gnet_stats_queue qstats;
 	struct gnet_stats_rate_est64 rate_est;
 	unsigned int	level;		/* class level in hierarchy */
-	struct tcf_proto *filter_list;	/* filter list */
+	struct list_head filter_list;	/* filter list */
 	unsigned int	filter_cnt;	/* filter count */
 
 	struct hfsc_sched *sched;	/* scheduler data */
@@ -1083,6 +1083,7 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 	cl->refcnt    = 1;
 	cl->sched     = q;
 	cl->cl_parent = parent;
+	INIT_LIST_HEAD(&cl->filter_list);
 	cl->qdisc = qdisc_create_dflt(sch->dev_queue,
 				      &pfifo_qdisc_ops, classid);
 	if (cl->qdisc == NULL)
@@ -1151,7 +1152,7 @@ hfsc_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 	struct hfsc_sched *q = qdisc_priv(sch);
 	struct hfsc_class *head, *cl;
 	struct tcf_result res;
-	struct tcf_proto *tcf;
+	struct list_head *list;
 	int result;
 
 	if (TC_H_MAJ(skb->priority ^ sch->handle) == 0 &&
@@ -1161,8 +1162,10 @@ hfsc_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 
 	*qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
 	head = &q->root;
-	tcf = q->root.filter_list;
-	while (tcf && (result = tc_classify(skb, tcf, &res)) >= 0) {
+	list = &q->root.filter_list;
+	while (list) {
+		if ((result = tc_classify(skb, list, &res)) < 0)
+			break;
 #ifdef CONFIG_NET_CLS_ACT
 		switch (result) {
 		case TC_ACT_QUEUED:
@@ -1185,7 +1188,7 @@ hfsc_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 			return cl; /* hit leaf class */
 
 		/* apply inner filter chain */
-		tcf = cl->filter_list;
+		list = &cl->filter_list;
 		head = cl;
 	}
 
@@ -1285,7 +1288,7 @@ hfsc_unbind_tcf(struct Qdisc *sch, unsigned long arg)
 	cl->filter_cnt--;
 }
 
-static struct tcf_proto **
+static struct list_head *
 hfsc_tcf_chain(struct Qdisc *sch, unsigned long arg)
 {
 	struct hfsc_sched *q = qdisc_priv(sch);
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 0db5a6e..c28e405 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -103,7 +103,7 @@ struct htb_class {
 	u32			prio;		/* these two are used only by leaves... */
 	int			quantum;	/* but stored for parent-to-leaf return */
 
-	struct tcf_proto	*filter_list;	/* class attached filters */
+	struct list_head	filter_list;	/* class attached filters */
 	int			filter_cnt;
 	int			refcnt;		/* usage count of this class */
 
@@ -153,7 +153,7 @@ struct htb_sched {
 	int			rate2quantum;	/* quant = rate / rate2quantum */
 
 	/* filters for qdisc itself */
-	struct tcf_proto	*filter_list;
+	struct list_head	filter_list;
 
 #define HTB_WARN_TOOMANYEVENTS	0x1
 	unsigned int		warned;	/* only one warning */
@@ -209,7 +209,7 @@ static struct htb_class *htb_classify(struct sk_buff *skb, struct Qdisc *sch,
 	struct htb_sched *q = qdisc_priv(sch);
 	struct htb_class *cl;
 	struct tcf_result res;
-	struct tcf_proto *tcf;
+	struct list_head *head;
 	int result;
 
 	/* allow to select class by setting skb->priority to valid classid;
@@ -223,8 +223,10 @@ static struct htb_class *htb_classify(struct sk_buff *skb, struct Qdisc *sch,
 		return cl;
 
 	*qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
-	tcf = q->filter_list;
-	while (tcf && (result = tc_classify(skb, tcf, &res)) >= 0) {
+	head = &q->filter_list;
+	while (!list_empty(head)) {
+		if ((result = tc_classify(skb, head, &res)) < 0)
+			break;
 #ifdef CONFIG_NET_CLS_ACT
 		switch (result) {
 		case TC_ACT_QUEUED:
@@ -246,7 +248,7 @@ static struct htb_class *htb_classify(struct sk_buff *skb, struct Qdisc *sch,
 			return cl;	/* we hit leaf; return it */
 
 		/* we have got inner class; apply inner filter chain */
-		tcf = cl->filter_list;
+		head = &cl->filter_list;
 	}
 	/* classification failed; try to use default class */
 	cl = htb_find(TC_H_MAKE(TC_H_MAJ(sch->handle), q->defcls), sch);
@@ -1040,6 +1042,7 @@ static int htb_init(struct Qdisc *sch, struct nlattr *opt)
 	qdisc_watchdog_init(&q->watchdog, sch);
 	INIT_WORK(&q->work, htb_work_func);
 	skb_queue_head_init(&q->direct_queue);
+	INIT_LIST_HEAD(&q->filter_list);
 
 	if (tb[TCA_HTB_DIRECT_QLEN])
 		q->direct_qlen = nla_get_u32(tb[TCA_HTB_DIRECT_QLEN]);
@@ -1413,6 +1416,7 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 		cl->refcnt = 1;
 		cl->children = 0;
 		INIT_LIST_HEAD(&cl->un.leaf.drop_list);
+		INIT_LIST_HEAD(&cl->filter_list);
 		RB_CLEAR_NODE(&cl->pq_node);
 
 		for (prio = 0; prio < TC_HTB_NUMPRIO; prio++)
@@ -1518,11 +1522,11 @@ failure:
 	return err;
 }
 
-static struct tcf_proto **htb_find_tcf(struct Qdisc *sch, unsigned long arg)
+static struct list_head *htb_find_tcf(struct Qdisc *sch, unsigned long arg)
 {
 	struct htb_sched *q = qdisc_priv(sch);
 	struct htb_class *cl = (struct htb_class *)arg;
-	struct tcf_proto **fl = cl ? &cl->filter_list : &q->filter_list;
+	struct list_head *fl = cl ? &cl->filter_list : &q->filter_list;
 
 	return fl;
 }
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index bce1665..b182e0c 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -17,7 +17,7 @@
 
 
 struct ingress_qdisc_data {
-	struct tcf_proto	*filter_list;
+	struct list_head	filter_list;
 };
 
 /* ------------------------- Class/flow operations ------------------------- */
@@ -46,7 +46,7 @@ static void ingress_walk(struct Qdisc *sch, struct qdisc_walker *walker)
 {
 }
 
-static struct tcf_proto **ingress_find_tcf(struct Qdisc *sch, unsigned long cl)
+static struct list_head *ingress_find_tcf(struct Qdisc *sch, unsigned long cl)
 {
 	struct ingress_qdisc_data *p = qdisc_priv(sch);
 
@@ -61,7 +61,7 @@ static int ingress_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	struct tcf_result res;
 	int result;
 
-	result = tc_classify(skb, p->filter_list, &res);
+	result = tc_classify(skb, &p->filter_list, &res);
 
 	qdisc_bstats_update(sch, skb);
 	switch (result) {
@@ -108,6 +108,13 @@ nla_put_failure:
 	return -1;
 }
 
+static int ingress_init(struct Qdisc *sch, struct nlattr *opt)
+{
+	struct ingress_qdisc_data *q = qdisc_priv(sch);
+	INIT_LIST_HEAD(&q->filter_list);
+	return 0;
+}
+
 static const struct Qdisc_class_ops ingress_class_ops = {
 	.leaf		=	ingress_leaf,
 	.get		=	ingress_get,
@@ -119,6 +126,7 @@ static const struct Qdisc_class_ops ingress_class_ops = {
 };
 
 static struct Qdisc_ops ingress_qdisc_ops __read_mostly = {
+	.init		=	ingress_init,
 	.cl_ops		=	&ingress_class_ops,
 	.id		=	"ingress",
 	.priv_size	=	sizeof(struct ingress_qdisc_data),
diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
index afb050a..e4be093 100644
--- a/net/sched/sch_multiq.c
+++ b/net/sched/sch_multiq.c
@@ -31,7 +31,7 @@ struct multiq_sched_data {
 	u16 bands;
 	u16 max_bands;
 	u16 curband;
-	struct tcf_proto *filter_list;
+	struct list_head filter_list;
 	struct Qdisc **queues;
 };
 
@@ -45,7 +45,7 @@ multiq_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 	int err;
 
 	*qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
-	err = tc_classify(skb, q->filter_list, &res);
+	err = tc_classify(skb, &q->filter_list, &res);
 #ifdef CONFIG_NET_CLS_ACT
 	switch (err) {
 	case TC_ACT_STOLEN:
@@ -258,6 +258,7 @@ static int multiq_init(struct Qdisc *sch, struct nlattr *opt)
 	if (opt == NULL)
 		return -EINVAL;
 
+	INIT_LIST_HEAD(&q->filter_list);
 	q->max_bands = qdisc_dev(sch)->num_tx_queues;
 
 	q->queues = kcalloc(q->max_bands, sizeof(struct Qdisc *), GFP_KERNEL);
@@ -388,7 +389,7 @@ static void multiq_walk(struct Qdisc *sch, struct qdisc_walker *arg)
 	}
 }
 
-static struct tcf_proto **multiq_find_tcf(struct Qdisc *sch, unsigned long cl)
+static struct list_head *multiq_find_tcf(struct Qdisc *sch, unsigned long cl)
 {
 	struct multiq_sched_data *q = qdisc_priv(sch);
 
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 79359b6..f4ee09f 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -24,7 +24,7 @@
 
 struct prio_sched_data {
 	int bands;
-	struct tcf_proto *filter_list;
+	struct list_head filter_list;
 	u8  prio2band[TC_PRIO_MAX+1];
 	struct Qdisc *queues[TCQ_PRIO_BANDS];
 };
@@ -40,7 +40,7 @@ prio_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 
 	*qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
 	if (TC_H_MAJ(skb->priority) != sch->handle) {
-		err = tc_classify(skb, q->filter_list, &res);
+		err = tc_classify(skb, &q->filter_list, &res);
 #ifdef CONFIG_NET_CLS_ACT
 		switch (err) {
 		case TC_ACT_STOLEN:
@@ -50,7 +50,7 @@ prio_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 			return NULL;
 		}
 #endif
-		if (!q->filter_list || err < 0) {
+		if (list_empty(&q->filter_list) || err < 0) {
 			if (TC_H_MAJ(band))
 				band = 0;
 			return q->queues[q->prio2band[band & TC_PRIO_MAX]];
@@ -235,6 +235,7 @@ static int prio_init(struct Qdisc *sch, struct nlattr *opt)
 		if ((err = prio_tune(sch, opt)) != 0)
 			return err;
 	}
+	INIT_LIST_HEAD(&q->filter_list);
 	return 0;
 }
 
@@ -351,7 +352,7 @@ static void prio_walk(struct Qdisc *sch, struct qdisc_walker *arg)
 	}
 }
 
-static struct tcf_proto **prio_find_tcf(struct Qdisc *sch, unsigned long cl)
+static struct list_head *prio_find_tcf(struct Qdisc *sch, unsigned long cl)
 {
 	struct prio_sched_data *q = qdisc_priv(sch);
 
diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index 8056fb4..c43f85a 100644
--- a/net/sched/sch_qfq.c
+++ b/net/sched/sch_qfq.c
@@ -181,7 +181,7 @@ struct qfq_group {
 };
 
 struct qfq_sched {
-	struct tcf_proto *filter_list;
+	struct list_head	filter_list;
 	struct Qdisc_class_hash clhash;
 
 	u64			oldV, V;	/* Precise virtual times. */
@@ -576,7 +576,7 @@ static void qfq_put_class(struct Qdisc *sch, unsigned long arg)
 		qfq_destroy_class(sch, cl);
 }
 
-static struct tcf_proto **qfq_tcf_chain(struct Qdisc *sch, unsigned long cl)
+static struct list_head *qfq_tcf_chain(struct Qdisc *sch, unsigned long cl)
 {
 	struct qfq_sched *q = qdisc_priv(sch);
 
@@ -714,7 +714,7 @@ static struct qfq_class *qfq_classify(struct sk_buff *skb, struct Qdisc *sch,
 	}
 
 	*qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
-	result = tc_classify(skb, q->filter_list, &res);
+	result = tc_classify(skb, &q->filter_list, &res);
 	if (result >= 0) {
 #ifdef CONFIG_NET_CLS_ACT
 		switch (result) {
@@ -1498,6 +1498,7 @@ static int qfq_init_qdisc(struct Qdisc *sch, struct nlattr *opt)
 	}
 
 	INIT_HLIST_HEAD(&q->nonfull_aggs);
+	INIT_LIST_HEAD(&q->filter_list);
 
 	return 0;
 }
diff --git a/net/sched/sch_sfb.c b/net/sched/sch_sfb.c
index 30ea467..20fcc6d 100644
--- a/net/sched/sch_sfb.c
+++ b/net/sched/sch_sfb.c
@@ -55,7 +55,7 @@ struct sfb_bins {
 
 struct sfb_sched_data {
 	struct Qdisc	*qdisc;
-	struct tcf_proto *filter_list;
+	struct list_head filter_list;
 	unsigned long	rehash_interval;
 	unsigned long	warmup_time;	/* double buffering warmup time in jiffies */
 	u32		max;
@@ -259,7 +259,7 @@ static bool sfb_classify(struct sk_buff *skb, struct sfb_sched_data *q,
 	struct tcf_result res;
 	int result;
 
-	result = tc_classify(skb, q->filter_list, &res);
+	result = tc_classify(skb, &q->filter_list, &res);
 	if (result >= 0) {
 #ifdef CONFIG_NET_CLS_ACT
 		switch (result) {
@@ -306,7 +306,7 @@ static int sfb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		}
 	}
 
-	if (q->filter_list) {
+	if (!list_empty(&q->filter_list)) {
 		/* If using external classifiers, get result and record it. */
 		if (!sfb_classify(skb, q, &ret, &salt))
 			goto other_drop;
@@ -533,6 +533,7 @@ static int sfb_change(struct Qdisc *sch, struct nlattr *opt)
 	q->tokens_avail = ctl->penalty_burst;
 	q->token_time = jiffies;
 
+	INIT_LIST_HEAD(&q->filter_list);
 	q->slot = 0;
 	q->double_buffering = false;
 	sfb_zero_all_buckets(q);
@@ -660,7 +661,7 @@ static void sfb_walk(struct Qdisc *sch, struct qdisc_walker *walker)
 	}
 }
 
-static struct tcf_proto **sfb_find_tcf(struct Qdisc *sch, unsigned long cl)
+static struct list_head *sfb_find_tcf(struct Qdisc *sch, unsigned long cl)
 {
 	struct sfb_sched_data *q = qdisc_priv(sch);
 
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 76f01e0..2a5b2a4 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -125,7 +125,7 @@ struct sfq_sched_data {
 	u8		cur_depth;	/* depth of longest slot */
 	u8		flags;
 	unsigned short  scaled_quantum; /* SFQ_ALLOT_SIZE(quantum) */
-	struct tcf_proto *filter_list;
+	struct list_head filter_list;
 	sfq_index	*ht;		/* Hash table ('divisor' slots) */
 	struct sfq_slot	*slots;		/* Flows table ('maxflows' entries) */
 
@@ -194,13 +194,13 @@ static unsigned int sfq_classify(struct sk_buff *skb, struct Qdisc *sch,
 	    TC_H_MIN(skb->priority) <= q->divisor)
 		return TC_H_MIN(skb->priority);
 
-	if (!q->filter_list) {
+	if (list_empty(&q->filter_list)) {
 		skb_flow_dissect(skb, &sfq_skb_cb(skb)->keys);
 		return sfq_hash(q, skb) + 1;
 	}
 
 	*qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
-	result = tc_classify(skb, q->filter_list, &res);
+	result = tc_classify(skb, &q->filter_list, &res);
 	if (result >= 0) {
 #ifdef CONFIG_NET_CLS_ACT
 		switch (result) {
@@ -630,7 +630,7 @@ static void sfq_perturbation(unsigned long arg)
 
 	spin_lock(root_lock);
 	q->perturbation = net_random();
-	if (!q->filter_list && q->tail)
+	if (list_empty(&q->filter_list) && q->tail)
 		sfq_rehash(sch);
 	spin_unlock(root_lock);
 
@@ -760,6 +760,7 @@ static int sfq_init(struct Qdisc *sch, struct nlattr *opt)
 	q->scaled_quantum = SFQ_ALLOT_SIZE(q->quantum);
 	q->perturb_period = 0;
 	q->perturbation = net_random();
+	INIT_LIST_HEAD(&q->filter_list);
 
 	if (opt) {
 		int err = sfq_change(sch, opt);
@@ -846,7 +847,7 @@ static void sfq_put(struct Qdisc *q, unsigned long cl)
 {
 }
 
-static struct tcf_proto **sfq_find_tcf(struct Qdisc *sch, unsigned long cl)
+static struct list_head *sfq_find_tcf(struct Qdisc *sch, unsigned long cl)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
 
-- 
1.8.3.1
