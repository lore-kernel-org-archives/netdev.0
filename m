From: David Miller <davem@davemloft.net>
Subject: [PATCH 13/14]: pkt_sched: Convert Qdisc_class_ops->change to
 validate/commit/cancel.
Date: Mon, 14 Jul 2008 16:00:34 -0700 (PDT)
Message-ID: <20080714.160034.124949467.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49281
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758569AbYGNXAs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 19:00:48 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 92CA1C8C188
	for <netdev@vger.kernel.org>; Mon, 14 Jul 2008 16:00:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Now it will be possible for the qdisc change operation requests
to made fully multiqueue aware.

New versions of the generic estimator attach routines were needed
which take a pointer to the attribute structure itself rather than
the nlattr.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/gen_stats.h   |    8 +
 include/net/sch_generic.h |   10 +-
 net/core/gen_estimator.c  |   34 ++++-
 net/sched/sch_api.c       |    7 +-
 net/sched/sch_atm.c       |  119 +++++++++-------
 net/sched/sch_cbq.c       |  355 +++++++++++++++++++++++++++++----------------
 net/sched/sch_dsmark.c    |   54 ++++---
 net/sched/sch_hfsc.c      |  252 +++++++++++++++++++++-----------
 net/sched/sch_htb.c       |  249 +++++++++++++++++++++-----------
 net/sched/sch_ingress.c   |   18 ++-
 net/sched/sch_netem.c     |   23 +++-
 net/sched/sch_prio.c      |   19 ++-
 net/sched/sch_red.c       |   23 +++-
 net/sched/sch_sfq.c       |   23 +++-
 net/sched/sch_tbf.c       |   23 +++-
 15 files changed, 818 insertions(+), 399 deletions(-)

diff --git a/include/net/gen_stats.h b/include/net/gen_stats.h
index 8cd8185..bff1970 100644
--- a/include/net/gen_stats.h
+++ b/include/net/gen_stats.h
@@ -40,10 +40,18 @@ extern int gnet_stats_finish_copy(struct gnet_dump *d);
 extern int gen_new_estimator(struct gnet_stats_basic *bstats,
 			     struct gnet_stats_rate_est *rate_est,
 			     spinlock_t *stats_lock, struct nlattr *opt);
+extern int __gen_new_estimator(struct gnet_stats_basic *bstats,
+			       struct gnet_stats_rate_est *rate_est,
+			       spinlock_t *stats_lock,
+			       struct gnet_estimator *parm);
 extern void gen_kill_estimator(struct gnet_stats_basic *bstats,
 			       struct gnet_stats_rate_est *rate_est);
 extern int gen_replace_estimator(struct gnet_stats_basic *bstats,
 				 struct gnet_stats_rate_est *rate_est,
 				 spinlock_t *stats_lock, struct nlattr *opt);
+extern int __gen_replace_estimator(struct gnet_stats_basic *bstats,
+				   struct gnet_stats_rate_est *rate_est,
+				   spinlock_t *stats_lock,
+				   struct gnet_estimator *parm);
 
 #endif
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index b17dece..64d60a8 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -69,8 +69,14 @@ struct Qdisc_class_ops
 	/* Class manipulation routines */
 	unsigned long		(*get)(struct Qdisc *, u32 classid);
 	void			(*put)(struct Qdisc *, unsigned long);
-	int			(*change)(struct Qdisc *, u32, u32,
-					  struct nlattr **, unsigned long *);
+	int			(*validate_change)(struct Qdisc *, u32, u32,
+						   struct nlattr **,
+						   unsigned long *);
+	void			(*commit_change)(struct Qdisc *, u32, u32,
+					  struct nlattr **, unsigned long);
+	void			(*cancel_change)(struct Qdisc *, u32, u32,
+						 struct nlattr **,
+						 unsigned long);
 	int			(*validate_delete)(struct Qdisc *,
 						   unsigned long);
 	void			(*commit_delete)(struct Qdisc *,
diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
index 57abe82..c711471 100644
--- a/net/core/gen_estimator.c
+++ b/net/core/gen_estimator.c
@@ -156,18 +156,14 @@ skip:
  *
  * NOTE: Called under rtnl_mutex
  */
-int gen_new_estimator(struct gnet_stats_basic *bstats,
-		      struct gnet_stats_rate_est *rate_est,
-		      spinlock_t *stats_lock,
-		      struct nlattr *opt)
+int __gen_new_estimator(struct gnet_stats_basic *bstats,
+			struct gnet_stats_rate_est *rate_est,
+			spinlock_t *stats_lock,
+			struct gnet_estimator *parm)
 {
 	struct gen_estimator *est;
-	struct gnet_estimator *parm = nla_data(opt);
 	int idx;
 
-	if (nla_len(opt) < sizeof(*parm))
-		return -EINVAL;
-
 	if (parm->interval < -2 || parm->interval > 3)
 		return -EINVAL;
 
@@ -197,6 +193,19 @@ int gen_new_estimator(struct gnet_stats_basic *bstats,
 	return 0;
 }
 
+int gen_new_estimator(struct gnet_stats_basic *bstats,
+		      struct gnet_stats_rate_est *rate_est,
+		      spinlock_t *stats_lock,
+		      struct nlattr *opt)
+{
+	struct gnet_estimator *parm = nla_data(opt);
+
+	if (nla_len(opt) < sizeof(*parm))
+		return -EINVAL;
+
+	return __gen_new_estimator(bstats, rate_est, stats_lock, parm);
+}
+
 static void __gen_kill_estimator(struct rcu_head *head)
 {
 	struct gen_estimator *e = container_of(head,
@@ -260,7 +269,16 @@ int gen_replace_estimator(struct gnet_stats_basic *bstats,
 	return gen_new_estimator(bstats, rate_est, stats_lock, opt);
 }
 
+int __gen_replace_estimator(struct gnet_stats_basic *bstats,
+			    struct gnet_stats_rate_est *rate_est,
+			    spinlock_t *stats_lock, struct gnet_estimator *parm)
+{
+	gen_kill_estimator(bstats, rate_est);
+	return __gen_new_estimator(bstats, rate_est, stats_lock, parm);
+}
 
 EXPORT_SYMBOL(gen_kill_estimator);
 EXPORT_SYMBOL(gen_new_estimator);
+EXPORT_SYMBOL(__gen_new_estimator);
 EXPORT_SYMBOL(gen_replace_estimator);
+EXPORT_SYMBOL(__gen_replace_estimator);
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 5230d2d..a4020a6 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1610,9 +1610,12 @@ static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 	}
 
 	new_cl = cl;
-	err = cops->change(q, clid, pid, tca, &new_cl);
-	if (err == 0)
+
+	err = cops->validate_change(q, clid, pid, tca, &new_cl);
+	if (!err) {
+		cops->commit_change(q, clid, pid, tca, new_cl);
 		tclass_notify(skb, n, q, new_cl, RTM_NEWTCLASS);
+	}
 
 out:
 	if (cl)
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index c240275..2e32b59 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -212,27 +212,25 @@ static const struct nla_policy atm_policy[TCA_ATM_MAX + 1] = {
 	[TCA_ATM_EXCESS]	= { .type = NLA_U32 },
 };
 
-static int atm_tc_change(struct Qdisc *sch, u32 classid, u32 parent,
-			 struct nlattr **tca, unsigned long *arg)
+static int atm_tc_validate_change(struct Qdisc *sch, u32 classid, u32 parent,
+				  struct nlattr **tca, unsigned long *arg)
 {
+	struct atm_flow_data *flow = (struct atm_flow_data *) *arg;
 	struct atm_qdisc_data *p = qdisc_priv(sch);
-	struct atm_flow_data *flow = (struct atm_flow_data *)*arg;
-	struct atm_flow_data *excess = NULL;
 	struct nlattr *opt = tca[TCA_OPTIONS];
 	struct nlattr *tb[TCA_ATM_MAX + 1];
+	struct atm_flow_data *excess;
+	int err, fd, hdr_len;
 	struct socket *sock;
-	int fd, error, hdr_len;
 	void *hdr;
 
-	pr_debug("atm_tc_change(sch %p,[qdisc %p],classid %x,parent %x,"
-		"flow %p,opt %p)\n", sch, p, classid, parent, flow, opt);
-	/*
-	 * The concept of parents doesn't apply for this qdisc.
-	 */
+	if (!opt)
+		return -EINVAL;
+
+	/* The concept of parents doesn't apply for this qdisc.  */
 	if (parent && parent != TC_H_ROOT && parent != sch->handle)
 		return -EINVAL;
-	/*
-	 * ATM classes cannot be changed. In order to change properties of the
+	/* ATM classes cannot be changed. In order to change properties of the
 	 * ATM connection, that socket needs to be modified directly (via the
 	 * native ATM API. In order to send a flow to a different VC, the old
 	 * class needs to be removed and a new one added. (This may be changed
@@ -240,17 +238,15 @@ static int atm_tc_change(struct Qdisc *sch, u32 classid, u32 parent,
 	 */
 	if (flow)
 		return -EBUSY;
-	if (opt == NULL)
-		return -EINVAL;
 
-	error = nla_parse_nested(tb, TCA_ATM_MAX, opt, atm_policy);
-	if (error < 0)
-		return error;
+	err = nla_parse_nested(tb, TCA_ATM_MAX, opt, atm_policy);
+	if (err < 0)
+		return err;
 
 	if (!tb[TCA_ATM_FD])
 		return -EINVAL;
 	fd = nla_get_u32(tb[TCA_ATM_FD]);
-	pr_debug("atm_tc_change: fd %d\n", fd);
+
 	if (tb[TCA_ATM_HDR]) {
 		hdr_len = nla_len(tb[TCA_ATM_HDR]);
 		hdr = nla_data(tb[TCA_ATM_HDR]);
@@ -258,39 +254,36 @@ static int atm_tc_change(struct Qdisc *sch, u32 classid, u32 parent,
 		hdr_len = RFC1483LLC_LEN;
 		hdr = NULL;	/* default LLC/SNAP for IP */
 	}
-	if (!tb[TCA_ATM_EXCESS])
-		excess = NULL;
-	else {
+
+	excess = NULL;
+	if (tb[TCA_ATM_EXCESS]) {
 		excess = (struct atm_flow_data *)
 			atm_tc_get(sch, nla_get_u32(tb[TCA_ATM_EXCESS]));
 		if (!excess)
 			return -ENOENT;
 	}
-	pr_debug("atm_tc_change: type %d, payload %d, hdr_len %d\n",
-		 opt->nla_type, nla_len(opt), hdr_len);
-	sock = sockfd_lookup(fd, &error);
+
+	sock = sockfd_lookup(fd, &err);
 	if (!sock)
-		return error;	/* f_count++ */
-	pr_debug("atm_tc_change: f_count %d\n", file_count(sock->file));
-	if (sock->ops->family != PF_ATMSVC && sock->ops->family != PF_ATMPVC) {
-		error = -EPROTOTYPE;
-		goto err_out;
-	}
-	/* @@@ should check if the socket is really operational or we'll crash
-	   on vcc->send */
+		return err;
+
+	err = -EPROTOTYPE;
+	if (sock->ops->family != PF_ATMSVC && sock->ops->family != PF_ATMPVC)
+		goto err_sock_put;
+
 	if (classid) {
 		if (TC_H_MAJ(classid ^ sch->handle)) {
 			pr_debug("atm_tc_change: classid mismatch\n");
-			error = -EINVAL;
-			goto err_out;
+			err = -EINVAL;
+			goto err_sock_put;
 		}
 		if (find_flow(p, flow)) {
-			error = -EEXIST;
-			goto err_out;
+			err = -EEXIST;
+			goto err_sock_put;
 		}
 	} else {
-		int i;
 		unsigned long cl;
+		int i;
 
 		for (i = 1; i < 0x8000; i++) {
 			classid = TC_H_MAKE(sch->handle, 0x8000 | i);
@@ -300,23 +293,22 @@ static int atm_tc_change(struct Qdisc *sch, u32 classid, u32 parent,
 			atm_tc_put(sch, cl);
 		}
 	}
-	pr_debug("atm_tc_change: new id %x\n", classid);
+
 	flow = kzalloc(sizeof(struct atm_flow_data) + hdr_len, GFP_KERNEL);
-	pr_debug("atm_tc_change: flow %p\n", flow);
-	if (!flow) {
-		error = -ENOBUFS;
-		goto err_out;
-	}
+	err = -ENOBUFS;
+	if (!flow)
+		goto err_sock_put;
+
 	flow->filter_list = NULL;
 	flow->q = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
 				    &pfifo_qdisc_ops, classid);
+	err = -ENOMEM;
 	if (!flow->q)
-		flow->q = &noop_qdisc;
-	pr_debug("atm_tc_change: qdisc %p\n", flow->q);
+		goto err_free_flow;
+
 	flow->sock = sock;
 	flow->vcc = ATM_SD(sock);	/* speedup */
 	flow->vcc->user_back = flow;
-	pr_debug("atm_tc_change: vcc %p\n", flow->vcc);
 	flow->old_pop = flow->vcc->pop;
 	flow->parent = p;
 	flow->vcc->pop = sch_atm_pop;
@@ -324,7 +316,6 @@ static int atm_tc_change(struct Qdisc *sch, u32 classid, u32 parent,
 	flow->ref = 1;
 	flow->excess = excess;
 	flow->next = p->link.next;
-	p->link.next = flow;
 	flow->hdr_len = hdr_len;
 	if (hdr)
 		memcpy(flow->hdr, hdr, hdr_len);
@@ -332,11 +323,33 @@ static int atm_tc_change(struct Qdisc *sch, u32 classid, u32 parent,
 		memcpy(flow->hdr, llc_oui_ip, sizeof(llc_oui_ip));
 	*arg = (unsigned long)flow;
 	return 0;
-err_out:
-	if (excess)
-		atm_tc_put(sch, (unsigned long)excess);
+
+err_free_flow:
+	kfree(flow);
+
+err_sock_put:
 	sockfd_put(sock);
-	return error;
+	return err;
+}
+
+static void atm_tc_commit_change(struct Qdisc *sch, u32 classid, u32 parent,
+				 struct nlattr **tca, unsigned long arg)
+{
+	struct atm_flow_data *flow = (struct atm_flow_data *) arg;
+	struct atm_qdisc_data *p = qdisc_priv(sch);
+
+	flow->next = p->link.next;
+	p->link.next = flow;
+}
+
+static void atm_tc_cancel_change(struct Qdisc *sch, u32 classid, u32 parent,
+				  struct nlattr **tca, unsigned long arg)
+{
+	struct atm_flow_data *flow = (struct atm_flow_data *) arg;
+
+	qdisc_destroy(flow->q);
+	sockfd_put(flow->sock);
+	kfree(flow);
 }
 
 static int atm_tc_validate_delete(struct Qdisc *sch, unsigned long arg)
@@ -693,7 +706,9 @@ static const struct Qdisc_class_ops atm_class_ops = {
 	.leaf		= atm_tc_leaf,
 	.get		= atm_tc_get,
 	.put		= atm_tc_put,
-	.change		= atm_tc_change,
+	.validate_change= atm_tc_validate_change,
+	.commit_change	= atm_tc_commit_change,
+	.cancel_change	= atm_tc_cancel_change,
 	.validate_delete= atm_tc_validate_delete,
 	.commit_delete	= atm_tc_commit_delete,
 	.walk		= atm_tc_walk,
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 7138a04..a6896f8 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -171,6 +171,8 @@ struct cbq_sched_data
 	psched_tdiff_t		wd_expires;
 	int			toplevel;
 	u32			hgenerator;
+
+	void			*pending_config;
 };
 
 
@@ -1771,44 +1773,213 @@ static void cbq_put(struct Qdisc *sch, unsigned long arg)
 	}
 }
 
-static int
-cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct nlattr **tca,
-		 unsigned long *arg)
+struct cbq_pending_config {
+	struct tc_cbq_lssopt	lss;
+	struct tc_cbq_wrropt	wrr;
+	struct tc_cbq_ovl	ovl;
+	struct tc_cbq_police	police;
+	struct tc_cbq_fopt	fopt;
+	struct gnet_estimator	est;
+	struct qdisc_rate_table	*rtab;
+	struct cbq_class	*new_class;
+	unsigned int		flags;
+#define FLAG_HAVE_LSSOPT	0x00000001
+#define FLAG_HAVE_WRROPT	0x00000002
+#define FLAG_HAVE_STRATEGY	0x00000004
+#define FLAG_HAVE_POLICE	0x00000008
+#define FLAG_HAVE_FOPT		0x00000010
+#define FLAG_HAVE_RATE		0x00000020
+};
+
+static int cbq_validate_change_class(struct Qdisc *sch, u32 classid,
+				     u32 parentid, struct nlattr **tca,
+				     unsigned long *arg)
 {
-	int err;
+	struct cbq_class *cl = (struct cbq_class *) *arg;
 	struct cbq_sched_data *q = qdisc_priv(sch);
-	struct cbq_class *cl = (struct cbq_class*)*arg;
 	struct nlattr *opt = tca[TCA_OPTIONS];
 	struct nlattr *tb[TCA_CBQ_MAX + 1];
-	struct cbq_class *parent;
-	struct qdisc_rate_table *rtab = NULL;
+	struct cbq_pending_config *p;
+	int err;
 
-	if (opt == NULL)
+	if (!opt)
 		return -EINVAL;
 
 	err = nla_parse_nested(tb, TCA_CBQ_MAX, opt, cbq_policy);
 	if (err < 0)
 		return err;
 
+	p = kzalloc(sizeof(*p), GFP_KERNEL);
+	if (!p)
+		return -ENOMEM;
+
+	err = -EINVAL;
+	if (tb[TCA_CBQ_RATE]) {
+		p->rtab = qdisc_get_rtab(nla_data(tb[TCA_CBQ_RATE]),
+					 tb[TCA_CBQ_RTAB]);
+		if (!p->rtab)
+			goto err_free_config;
+	}
+
+	if (tb[TCA_CBQ_LSSOPT]) {
+		memcpy(&p->lss, nla_data(tb[TCA_CBQ_LSSOPT]), sizeof(p->lss));
+		p->flags |= FLAG_HAVE_LSSOPT;
+	}
+	if (tb[TCA_CBQ_WRROPT]) {
+		memcpy(&p->wrr, nla_data(tb[TCA_CBQ_WRROPT]), sizeof(p->wrr));
+		p->flags |= FLAG_HAVE_WRROPT;
+	}
+	if (tb[TCA_CBQ_OVL_STRATEGY]) {
+		memcpy(&p->ovl, nla_data(tb[TCA_CBQ_OVL_STRATEGY]),
+		       sizeof(p->ovl));
+		p->flags |= FLAG_HAVE_STRATEGY;
+	}
+	if (tb[TCA_CBQ_POLICE]) {
+		memcpy(&p->police, nla_data(tb[TCA_CBQ_POLICE]),
+		       sizeof(p->police));
+		p->flags |= FLAG_HAVE_POLICE;
+	}
+	if (tb[TCA_CBQ_FOPT]) {
+		memcpy(&p->fopt, nla_data(tb[TCA_CBQ_FOPT]), sizeof(p->fopt));
+		p->flags |= FLAG_HAVE_FOPT;
+	}
+	if (tb[TCA_RATE]) {
+		memcpy(&p->est, nla_data(tb[TCA_RATE]), sizeof(p->est));
+		p->flags |= FLAG_HAVE_RATE;
+	}
+
 	if (cl) {
 		/* Check parent */
 		if (parentid) {
 			if (cl->tparent &&
 			    cl->tparent->common.classid != parentid)
-				return -EINVAL;
+				goto err_release_rtab;
 			if (!cl->tparent && parentid != TC_H_ROOT)
-				return -EINVAL;
+				goto err_release_rtab;
 		}
+	} else {
+		struct cbq_class *parent;
+
+		if (parentid == TC_H_ROOT)
+			goto err_release_rtab;
+
+		if (!tb[TCA_CBQ_WRROPT] ||
+		    !tb[TCA_CBQ_RATE] ||
+		    !tb[TCA_CBQ_LSSOPT])
+			goto err_release_rtab;
 
-		if (tb[TCA_CBQ_RATE]) {
-			rtab = qdisc_get_rtab(nla_data(tb[TCA_CBQ_RATE]), tb[TCA_CBQ_RTAB]);
-			if (rtab == NULL)
-				return -EINVAL;
+		if (classid) {
+			if (TC_H_MAJ(classid^sch->handle) ||
+			    cbq_class_lookup(q, classid))
+				goto err_release_rtab;
+		} else {
+			int i;
+
+			classid = TC_H_MAKE(sch->handle, 0x8000);
+			for (i = 0; i < 0x8000; i++) {
+				if (++q->hgenerator >= 0x8000)
+					q->hgenerator = 1;
+				if (cbq_class_lookup(q, classid | q->hgenerator) == NULL)
+					break;
+			}
+			err = -ENOSR;
+			if (i >= 0x8000)
+				goto err_release_rtab;
+			classid = classid | q->hgenerator;
 		}
 
-		/* Change class parameters */
-		sch_tree_lock(sch);
+		parent = &q->link;
+		if (parentid) {
+			parent = cbq_class_lookup(q, parentid);
+			err = -EINVAL;
+			if (!parent)
+				goto err_release_rtab;
+		}
+
+		err = -ENOBUFS;
+		cl = kzalloc(sizeof(*cl), GFP_KERNEL);
+		if (!cl)
+			goto err_release_rtab;
+		cl->R_tab = p->rtab;
+		cl->refcnt = 1;
+		if (!(cl->q = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
+						&pfifo_qdisc_ops, classid)))
+			goto err_free_class;
+		cl->common.classid = classid;
+		cl->tparent = parent;
+		cl->qdisc = sch;
+		cl->allot = parent->allot;
+		cl->quantum = cl->allot;
+		cl->weight = cl->R_tab->rate.rate;
+
+		p->new_class = cl;
+	}
+
+	q->pending_config = p;
+	*arg = (unsigned long) cl;
+
+	return 0;
+
+err_free_class:
+	kfree(cl);
+
+err_release_rtab:
+	if (p->rtab)
+		qdisc_put_rtab(p->rtab);
 
+err_free_config:
+	kfree(p);
+	return err;
+}
+
+static void cbq_cancel_change_class(struct Qdisc *sch, u32 classid,
+				    u32 parentid, struct nlattr **tca,
+				    unsigned long arg)
+{
+	struct cbq_sched_data *q = qdisc_priv(sch);
+	struct cbq_pending_config *p;
+
+	BUG_ON(!q->pending_config);
+	p = q->pending_config;
+	q->pending_config = NULL;
+
+	if (p->new_class) {
+		struct cbq_class *cl = p->new_class;
+
+		p->new_class = NULL;
+
+		if (cl->q) {
+			qdisc_destroy(cl->q);
+			cl->q = NULL;
+		}
+		kfree(cl);
+	}
+
+	if (p->rtab) {
+		qdisc_put_rtab(p->rtab);
+		p->rtab = NULL;
+	}
+
+	kfree(p);
+}
+
+static void cbq_commit_change_class(struct Qdisc *sch, u32 classid,
+				    u32 parentid, struct nlattr **tca,
+				    unsigned long arg)
+{
+	struct cbq_class *cl = (struct cbq_class *) arg;
+	struct cbq_sched_data *q = qdisc_priv(sch);
+	struct qdisc_rate_table *rtab;
+	struct cbq_pending_config *p;
+
+	BUG_ON(!q->pending_config);
+	p = q->pending_config;
+	q->pending_config = NULL;
+
+	rtab = p->rtab;
+
+	if (!p->new_class) {
+		sch_tree_lock(sch);
 		if (cl->next_alive != NULL)
 			cbq_deactivate_class(cl);
 
@@ -1817,131 +1988,69 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct nlattr **t
 			qdisc_put_rtab(rtab);
 		}
 
-		if (tb[TCA_CBQ_LSSOPT])
-			cbq_set_lss(cl, nla_data(tb[TCA_CBQ_LSSOPT]));
+		if (p->flags & FLAG_HAVE_LSSOPT)
+			cbq_set_lss(cl, &p->lss);
 
-		if (tb[TCA_CBQ_WRROPT]) {
+		if (p->flags & FLAG_HAVE_WRROPT) {
 			cbq_rmprio(q, cl);
-			cbq_set_wrr(cl, nla_data(tb[TCA_CBQ_WRROPT]));
+			cbq_set_wrr(cl, &p->wrr);
 		}
 
-		if (tb[TCA_CBQ_OVL_STRATEGY])
-			cbq_set_overlimit(cl, nla_data(tb[TCA_CBQ_OVL_STRATEGY]));
+		if (p->flags & FLAG_HAVE_STRATEGY)
+			cbq_set_overlimit(cl, &p->ovl);
 
 #ifdef CONFIG_NET_CLS_ACT
-		if (tb[TCA_CBQ_POLICE])
-			cbq_set_police(cl, nla_data(tb[TCA_CBQ_POLICE]));
+		if (p->flags & FLAG_HAVE_POLICE)
+			cbq_set_police(cl, &p->police);
 #endif
 
-		if (tb[TCA_CBQ_FOPT])
-			cbq_set_fopt(cl, nla_data(tb[TCA_CBQ_FOPT]));
+		if (p->flags & FLAG_HAVE_FOPT)
+			cbq_set_fopt(cl, &p->fopt);
 
 		if (cl->q->q.qlen)
 			cbq_activate_class(cl);
 
 		sch_tree_unlock(sch);
 
-		if (tca[TCA_RATE])
-			gen_replace_estimator(&cl->bstats, &cl->rate_est,
-					      &sch->dev_queue->lock,
-					      tca[TCA_RATE]);
-		return 0;
-	}
-
-	if (parentid == TC_H_ROOT)
-		return -EINVAL;
-
-	if (tb[TCA_CBQ_WRROPT] == NULL || tb[TCA_CBQ_RATE] == NULL ||
-	    tb[TCA_CBQ_LSSOPT] == NULL)
-		return -EINVAL;
-
-	rtab = qdisc_get_rtab(nla_data(tb[TCA_CBQ_RATE]), tb[TCA_CBQ_RTAB]);
-	if (rtab == NULL)
-		return -EINVAL;
-
-	if (classid) {
-		err = -EINVAL;
-		if (TC_H_MAJ(classid^sch->handle) || cbq_class_lookup(q, classid))
-			goto failure;
+		if (p->flags & FLAG_HAVE_RATE)
+			__gen_replace_estimator(&cl->bstats, &cl->rate_est,
+						&sch->dev_queue->lock,
+						&p->est);
 	} else {
-		int i;
-		classid = TC_H_MAKE(sch->handle,0x8000);
-
-		for (i=0; i<0x8000; i++) {
-			if (++q->hgenerator >= 0x8000)
-				q->hgenerator = 1;
-			if (cbq_class_lookup(q, classid|q->hgenerator) == NULL)
-				break;
-		}
-		err = -ENOSR;
-		if (i >= 0x8000)
-			goto failure;
-		classid = classid|q->hgenerator;
-	}
-
-	parent = &q->link;
-	if (parentid) {
-		parent = cbq_class_lookup(q, parentid);
-		err = -EINVAL;
-		if (parent == NULL)
-			goto failure;
-	}
-
-	err = -ENOBUFS;
-	cl = kzalloc(sizeof(*cl), GFP_KERNEL);
-	if (cl == NULL)
-		goto failure;
-	cl->R_tab = rtab;
-	rtab = NULL;
-	cl->refcnt = 1;
-	if (!(cl->q = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
-					&pfifo_qdisc_ops, classid)))
-		cl->q = &noop_qdisc;
-	cl->common.classid = classid;
-	cl->tparent = parent;
-	cl->qdisc = sch;
-	cl->allot = parent->allot;
-	cl->quantum = cl->allot;
-	cl->weight = cl->R_tab->rate.rate;
-
-	sch_tree_lock(sch);
-	cbq_link_class(cl);
-	cl->borrow = cl->tparent;
-	if (cl->tparent != &q->link)
-		cl->share = cl->tparent;
-	cbq_adjust_levels(parent);
-	cl->minidle = -0x7FFFFFFF;
-	cbq_set_lss(cl, nla_data(tb[TCA_CBQ_LSSOPT]));
-	cbq_set_wrr(cl, nla_data(tb[TCA_CBQ_WRROPT]));
-	if (cl->ewma_log==0)
-		cl->ewma_log = q->link.ewma_log;
-	if (cl->maxidle==0)
-		cl->maxidle = q->link.maxidle;
-	if (cl->avpkt==0)
-		cl->avpkt = q->link.avpkt;
-	cl->overlimit = cbq_ovl_classic;
-	if (tb[TCA_CBQ_OVL_STRATEGY])
-		cbq_set_overlimit(cl, nla_data(tb[TCA_CBQ_OVL_STRATEGY]));
+		sch_tree_lock(sch);
+		cbq_link_class(cl);
+		cl->borrow = cl->tparent;
+		if (cl->tparent != &q->link)
+			cl->share = cl->tparent;
+		cbq_adjust_levels(cl->tparent);
+		cl->minidle = -0x7FFFFFFF;
+		cbq_set_lss(cl, &p->lss);
+		cbq_set_wrr(cl, &p->wrr);
+		if (!cl->ewma_log)
+			cl->ewma_log = q->link.ewma_log;
+		if (!cl->maxidle)
+			cl->maxidle = q->link.maxidle;
+		if (!cl->avpkt)
+			cl->avpkt = q->link.avpkt;
+		cl->overlimit = cbq_ovl_classic;
+		if (p->flags & FLAG_HAVE_STRATEGY)
+			cbq_set_overlimit(cl, &p->ovl);
 #ifdef CONFIG_NET_CLS_ACT
-	if (tb[TCA_CBQ_POLICE])
-		cbq_set_police(cl, nla_data(tb[TCA_CBQ_POLICE]));
+		if (p->flags & FLAG_HAVE_POLICE)
+			cbq_set_police(cl, &p->police);
 #endif
-	if (tb[TCA_CBQ_FOPT])
-		cbq_set_fopt(cl, nla_data(tb[TCA_CBQ_FOPT]));
-	sch_tree_unlock(sch);
-
-	qdisc_class_hash_grow(sch, &q->clhash);
+		if (p->flags & FLAG_HAVE_FOPT)
+			cbq_set_fopt(cl, &p->fopt);
+		sch_tree_unlock(sch);
 
-	if (tca[TCA_RATE])
-		gen_new_estimator(&cl->bstats, &cl->rate_est,
-				  &sch->dev_queue->lock, tca[TCA_RATE]);
+		qdisc_class_hash_grow(sch, &q->clhash);
 
-	*arg = (unsigned long)cl;
-	return 0;
+		if (p->flags & FLAG_HAVE_RATE)
+			__gen_new_estimator(&cl->bstats, &cl->rate_est,
+					    &sch->dev_queue->lock, &p->est);
+	}
 
-failure:
-	qdisc_put_rtab(rtab);
-	return err;
+	kfree(p);
 }
 
 static int cbq_validate_delete(struct Qdisc *sch, unsigned long arg)
@@ -2059,7 +2168,9 @@ static const struct Qdisc_class_ops cbq_class_ops = {
 	.qlen_notify	=	cbq_qlen_notify,
 	.get		=	cbq_get,
 	.put		=	cbq_put,
-	.change		=	cbq_change_class,
+	.validate_change=	cbq_validate_change_class,
+	.commit_change	=	cbq_commit_change_class,
+	.cancel_change	=	cbq_cancel_change_class,
 	.validate_delete=	cbq_validate_delete,
 	.commit_delete	=	cbq_commit_delete,
 	.walk		=	cbq_walk,
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 03c8bcf..10d3381 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -42,6 +42,9 @@ struct dsmark_qdisc_data {
 	u16			indices;
 	u32			default_index;	/* index range is 0...0xffff */
 	int			set_tc_index;
+
+	u8			pending_mask;
+	u8			pending_value;
 };
 
 static inline int dsmark_valid_index(struct dsmark_qdisc_data *p, u16 index)
@@ -122,43 +125,48 @@ static const struct nla_policy dsmark_policy[TCA_DSMARK_MAX + 1] = {
 	[TCA_DSMARK_VALUE]		= { .type = NLA_U8 },
 };
 
-static int dsmark_change(struct Qdisc *sch, u32 classid, u32 parent,
-			 struct nlattr **tca, unsigned long *arg)
+static int dsmark_validate_change(struct Qdisc *sch, u32 classid, u32 parent,
+				  struct nlattr **tca, unsigned long *arg)
 {
 	struct dsmark_qdisc_data *p = qdisc_priv(sch);
 	struct nlattr *opt = tca[TCA_OPTIONS];
 	struct nlattr *tb[TCA_DSMARK_MAX + 1];
 	int err = -EINVAL;
-	u8 mask = 0;
-
-	pr_debug("dsmark_change(sch %p,[qdisc %p],classid %x,parent %x),"
-		"arg 0x%lx\n", sch, p, classid, parent, *arg);
-
-	if (!dsmark_valid_index(p, *arg)) {
-		err = -ENOENT;
-		goto errout;
-	}
 
 	if (!opt)
-		goto errout;
+		return -EINVAL;
+	if (!dsmark_valid_index(p, *arg))
+		return -ENOENT;
 
 	err = nla_parse_nested(tb, TCA_DSMARK_MAX, opt, dsmark_policy);
 	if (err < 0)
-		goto errout;
-
-	if (tb[TCA_DSMARK_MASK])
-		mask = nla_get_u8(tb[TCA_DSMARK_MASK]);
+		return err;
 
 	if (tb[TCA_DSMARK_VALUE])
-		p->value[*arg-1] = nla_get_u8(tb[TCA_DSMARK_VALUE]);
+		p->pending_value = nla_get_u8(tb[TCA_DSMARK_VALUE]);
+	else
+		p->pending_value = p->value[*arg-1];
 
 	if (tb[TCA_DSMARK_MASK])
-		p->mask[*arg-1] = mask;
+		p->pending_mask = nla_get_u8(tb[TCA_DSMARK_MASK]);
+	else
+		p->pending_mask = p->mask[*arg-1];
 
-	err = 0;
+	return 0;
+}
 
-errout:
-	return err;
+static void dsmark_commit_change(struct Qdisc *sch, u32 classid, u32 parent,
+				 struct nlattr **tca, unsigned long arg)
+{
+	struct dsmark_qdisc_data *p = qdisc_priv(sch);
+
+	p->value[arg - 1] = p->pending_value;
+	p->mask[arg - 1] = p->pending_mask;
+}
+
+static void dsmark_cancel_change(struct Qdisc *sch, u32 classid, u32 parent,
+				 struct nlattr **tca, unsigned long arg)
+{
 }
 
 static int dsmark_validate_delete(struct Qdisc *sch, unsigned long arg)
@@ -498,7 +506,9 @@ static const struct Qdisc_class_ops dsmark_class_ops = {
 	.leaf		=	dsmark_leaf,
 	.get		=	dsmark_get,
 	.put		=	dsmark_put,
-	.change		=	dsmark_change,
+	.validate_change=	dsmark_validate_change,
+	.commit_change	=	dsmark_commit_change,
+	.cancel_change	=	dsmark_cancel_change,
 	.validate_delete=	dsmark_validate_delete,
 	.commit_delete	=	dsmark_commit_delete,
 	.walk		=	dsmark_walk,
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 95a497e..8e2d601 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -186,6 +186,8 @@ struct hfsc_sched
 						   dropping) */
 	struct sk_buff_head requeue;		/* requeued packet */
 	struct qdisc_watchdog watchdog;		/* watchdog timer */
+
+	void *pending_config;
 };
 
 #define	HT_INFINITY	0xffffffffffffffffULL	/* infinite time value */
@@ -979,61 +981,150 @@ static const struct nla_policy hfsc_policy[TCA_HFSC_MAX + 1] = {
 	[TCA_HFSC_USC]	= { .len = sizeof(struct tc_service_curve) },
 };
 
-static int
-hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
-		  struct nlattr **tca, unsigned long *arg)
+struct hfsc_pending_config {
+	struct tc_service_curve	*rsc;
+	struct tc_service_curve	*fsc;
+	struct tc_service_curve	*usc;
+	struct gnet_estimator	est;
+	struct hfsc_class	*new_class;
+	unsigned int		flags;
+#define FLAG_HAVE_EST		0x00000001
+};
+
+static int hfsc_validate_change_class(struct Qdisc *sch, u32 classid,
+				      u32 parentid, struct nlattr **tca,
+				      unsigned long *arg)
 {
+	struct hfsc_class *cl = (struct hfsc_class *) *arg, *parent = NULL;
 	struct hfsc_sched *q = qdisc_priv(sch);
-	struct hfsc_class *cl = (struct hfsc_class *)*arg;
-	struct hfsc_class *parent = NULL;
 	struct nlattr *opt = tca[TCA_OPTIONS];
 	struct nlattr *tb[TCA_HFSC_MAX + 1];
-	struct tc_service_curve *rsc = NULL, *fsc = NULL, *usc = NULL;
-	u64 cur_time;
+	struct hfsc_pending_config *p;
 	int err;
 
-	if (opt == NULL)
+	if (!opt)
 		return -EINVAL;
 
 	err = nla_parse_nested(tb, TCA_HFSC_MAX, opt, hfsc_policy);
 	if (err < 0)
 		return err;
 
+	if (cl) {
+		if (parentid) {
+			if (cl->cl_parent &&
+			    cl->cl_parent->cl_common.classid != parentid)
+				return -EINVAL;
+			if (cl->cl_parent == NULL && parentid != TC_H_ROOT)
+				return -EINVAL;
+		}
+	} else {
+		if (parentid == TC_H_ROOT)
+			return -EEXIST;
+		parent = &q->root;
+		if (parentid) {
+			parent = hfsc_find_class(parentid, sch);
+			if (!parent)
+				return -ENOENT;
+		}
+		if (classid == 0 || TC_H_MAJ(classid ^ sch->handle) != 0)
+			return -EINVAL;
+		if (hfsc_find_class(classid, sch))
+			return -EEXIST;
+	}
+
+	p = kzalloc(sizeof(*p), GFP_KERNEL);
+	if (p)
+		return -ENOMEM;
+
 	if (tb[TCA_HFSC_RSC]) {
-		rsc = nla_data(tb[TCA_HFSC_RSC]);
-		if (rsc->m1 == 0 && rsc->m2 == 0)
-			rsc = NULL;
+		p->rsc = nla_data(tb[TCA_HFSC_RSC]);
+		if (p->rsc->m1 == 0 && p->rsc->m2 == 0)
+			p->rsc = NULL;
 	}
 
 	if (tb[TCA_HFSC_FSC]) {
-		fsc = nla_data(tb[TCA_HFSC_FSC]);
-		if (fsc->m1 == 0 && fsc->m2 == 0)
-			fsc = NULL;
+		p->fsc = nla_data(tb[TCA_HFSC_FSC]);
+		if (p->fsc->m1 == 0 && p->fsc->m2 == 0)
+			p->fsc = NULL;
 	}
 
 	if (tb[TCA_HFSC_USC]) {
-		usc = nla_data(tb[TCA_HFSC_USC]);
-		if (usc->m1 == 0 && usc->m2 == 0)
-			usc = NULL;
+		p->usc = nla_data(tb[TCA_HFSC_USC]);
+		if (p->usc->m1 == 0 && p->usc->m2 == 0)
+			p->usc = NULL;
 	}
 
-	if (cl != NULL) {
-		if (parentid) {
-			if (cl->cl_parent &&
-			    cl->cl_parent->cl_common.classid != parentid)
-				return -EINVAL;
-			if (cl->cl_parent == NULL && parentid != TC_H_ROOT)
-				return -EINVAL;
-		}
-		cur_time = psched_get_time();
+	if (tca[TCA_RATE]) {
+		memcpy(&p->est, nla_data(tca[TCA_RATE]), sizeof(p->est));
+		p->flags |= FLAG_HAVE_EST;
+	}
+	if (!cl) {
+		err = -EINVAL;
+		if (!p->rsc && !p->fsc)
+			goto err_free_config;
+		cl = kzalloc(sizeof(struct hfsc_class), GFP_KERNEL);
+		err = -ENOBUFS;
+		if (!cl)
+			goto err_free_config;
+		if (p->rsc)
+			hfsc_change_rsc(cl, p->rsc, 0);
+		if (p->fsc)
+			hfsc_change_fsc(cl, p->fsc);
+		if (p->usc)
+			hfsc_change_usc(cl, p->usc, 0);
+
+		cl->cl_common.classid = classid;
+		cl->refcnt = 1;
+		cl->sched = q;
+		cl->cl_parent = parent;
+		cl->qdisc = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
+					      &pfifo_qdisc_ops, classid);
+		err = -ENOMEM;
+		if (!cl->qdisc)
+			goto err_free_class;
+
+		INIT_LIST_HEAD(&cl->children);
+		cl->vt_tree = RB_ROOT;
+		cl->cf_tree = RB_ROOT;
+
+		p->new_class = cl;
+	}
+
+	*arg = (unsigned long) cl;
+	q->pending_config = p;
+
+	return 0;
+
+err_free_class:
+	kfree(cl);
+
+err_free_config:
+	kfree(p);
+	return err;
+}
+
+static void hfsc_commit_change_class(struct Qdisc *sch, u32 classid,
+				     u32 parentid, struct nlattr **tca,
+				     unsigned long arg)
+{
+	struct hfsc_class *cl = (struct hfsc_class *) arg;
+	struct hfsc_sched *q = qdisc_priv(sch);
+	struct hfsc_pending_config *p;
+
+	BUG_ON(!q->pending_config);
+	p = q->pending_config;
+	q->pending_config = NULL;
+
+	if (!p->new_class) {
+		u64 cur_time = psched_get_time();
 
 		sch_tree_lock(sch);
-		if (rsc != NULL)
-			hfsc_change_rsc(cl, rsc, cur_time);
-		if (fsc != NULL)
-			hfsc_change_fsc(cl, fsc);
-		if (usc != NULL)
-			hfsc_change_usc(cl, usc, cur_time);
+		if (p->rsc)
+			hfsc_change_rsc(cl, p->rsc, cur_time);
+		if (p->fsc)
+			hfsc_change_fsc(cl, p->fsc);
+		if (p->usc)
+			hfsc_change_usc(cl, p->usc, cur_time);
 
 		if (cl->qdisc->q.qlen != 0) {
 			if (cl->cl_flags & HFSC_RSC)
@@ -1043,70 +1134,53 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 		}
 		sch_tree_unlock(sch);
 
-		if (tca[TCA_RATE])
-			gen_replace_estimator(&cl->bstats, &cl->rate_est,
-					      &sch->dev_queue->lock,
-					      tca[TCA_RATE]);
-		return 0;
-	}
+		if (p->flags & FLAG_HAVE_EST)
+			__gen_replace_estimator(&cl->bstats, &cl->rate_est,
+						&sch->dev_queue->lock,
+						&p->est);
+	} else {
+		sch_tree_lock(sch);
+		qdisc_class_hash_insert(&q->clhash, &cl->cl_common);
+		list_add_tail(&cl->siblings, &cl->cl_parent->children);
+		if (cl->cl_parent->level == 0)
+			hfsc_purge_queue(sch, cl->cl_parent);
+		hfsc_adjust_levels(cl->cl_parent);
+		cl->cl_pcvtoff = cl->cl_parent->cl_cvtoff;
+		sch_tree_unlock(sch);
 
-	if (parentid == TC_H_ROOT)
-		return -EEXIST;
+		qdisc_class_hash_grow(sch, &q->clhash);
 
-	parent = &q->root;
-	if (parentid) {
-		parent = hfsc_find_class(parentid, sch);
-		if (parent == NULL)
-			return -ENOENT;
+		if (p->flags & FLAG_HAVE_EST)
+			__gen_new_estimator(&cl->bstats, &cl->rate_est,
+					    &sch->dev_queue->lock, &p->est);
 	}
 
-	if (classid == 0 || TC_H_MAJ(classid ^ sch->handle) != 0)
-		return -EINVAL;
-	if (hfsc_find_class(classid, sch))
-		return -EEXIST;
+	kfree(p);
+}
 
-	if (rsc == NULL && fsc == NULL)
-		return -EINVAL;
+static void hfsc_cancel_change_class(struct Qdisc *sch, u32 classid,
+				     u32 parentid, struct nlattr **tca,
+				     unsigned long arg)
+{
+	struct hfsc_sched *q = qdisc_priv(sch);
+	struct hfsc_pending_config *p;
 
-	cl = kzalloc(sizeof(struct hfsc_class), GFP_KERNEL);
-	if (cl == NULL)
-		return -ENOBUFS;
-
-	if (rsc != NULL)
-		hfsc_change_rsc(cl, rsc, 0);
-	if (fsc != NULL)
-		hfsc_change_fsc(cl, fsc);
-	if (usc != NULL)
-		hfsc_change_usc(cl, usc, 0);
-
-	cl->cl_common.classid = classid;
-	cl->refcnt    = 1;
-	cl->sched     = q;
-	cl->cl_parent = parent;
-	cl->qdisc = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
-				      &pfifo_qdisc_ops, classid);
-	if (cl->qdisc == NULL)
-		cl->qdisc = &noop_qdisc;
-	INIT_LIST_HEAD(&cl->children);
-	cl->vt_tree = RB_ROOT;
-	cl->cf_tree = RB_ROOT;
+	BUG_ON(!q->pending_config);
+	p = q->pending_config;
+	q->pending_config = NULL;
 
-	sch_tree_lock(sch);
-	qdisc_class_hash_insert(&q->clhash, &cl->cl_common);
-	list_add_tail(&cl->siblings, &parent->children);
-	if (parent->level == 0)
-		hfsc_purge_queue(sch, parent);
-	hfsc_adjust_levels(parent);
-	cl->cl_pcvtoff = parent->cl_cvtoff;
-	sch_tree_unlock(sch);
+	if (p->new_class) {
+		struct hfsc_class *cl = p->new_class;
 
-	qdisc_class_hash_grow(sch, &q->clhash);
+		p->new_class = NULL;
 
-	if (tca[TCA_RATE])
-		gen_new_estimator(&cl->bstats, &cl->rate_est,
-				  &sch->dev_queue->lock, tca[TCA_RATE]);
-	*arg = (unsigned long)cl;
-	return 0;
+		if (cl->qdisc)
+			qdisc_destroy(cl->qdisc);
+
+		kfree(cl);
+	}
+
+	kfree(p);
 }
 
 static void
@@ -1737,7 +1811,9 @@ hfsc_drop(struct Qdisc *sch)
 }
 
 static const struct Qdisc_class_ops hfsc_class_ops = {
-	.change		= hfsc_change_class,
+	.validate_change= hfsc_validate_change_class,
+	.commit_change	= hfsc_commit_change_class,
+	.cancel_change	= hfsc_cancel_change_class,
 	.validate_delete= hfsc_validate_delete_class,
 	.commit_delete	= hfsc_commit_delete_class,
 	.prepare_graft	= hfsc_prepare_graft,
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index a9cf7bb..315493b 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -169,6 +169,8 @@ struct htb_sched {
 	int direct_qlen;	/* max qlen of above */
 
 	long direct_pkts;
+
+	void *pending_config;
 };
 
 /* find class in global hash table using given handle */
@@ -1326,74 +1328,73 @@ static void htb_put(struct Qdisc *sch, unsigned long arg)
 		htb_destroy_class(sch, cl);
 }
 
-static int htb_change_class(struct Qdisc *sch, u32 classid,
-			    u32 parentid, struct nlattr **tca,
-			    unsigned long *arg)
+struct htb_pending_config {
+	struct tc_htb_opt	hopt;
+	struct qdisc_rate_table	*rtab;
+	struct qdisc_rate_table	*ctab;
+	struct htb_class	*new_class;
+	struct gnet_estimator	est;
+	unsigned int		flags;
+#define FLAG_HAVE_EST		0x00000001
+};
+
+static int htb_validate_change_class(struct Qdisc *sch, u32 classid,
+				     u32 parentid, struct nlattr **tca,
+				     unsigned long *arg)
 {
-	int err = -EINVAL;
+	struct htb_class *cl = (struct htb_class *) *arg, *parent;
 	struct htb_sched *q = qdisc_priv(sch);
-	struct htb_class *cl = (struct htb_class *)*arg, *parent;
 	struct nlattr *opt = tca[TCA_OPTIONS];
-	struct qdisc_rate_table *rtab = NULL, *ctab = NULL;
+	struct qdisc_rate_table *rtab, *ctab;
 	struct nlattr *tb[TCA_HTB_RTAB + 1];
+	struct htb_pending_config *p;
 	struct tc_htb_opt *hopt;
+	int err;
 
-	/* extract all subattrs from opt attr */
 	if (!opt)
-		goto failure;
-
+		return -EINVAL;
 	err = nla_parse_nested(tb, TCA_HTB_RTAB, opt, htb_policy);
 	if (err < 0)
-		goto failure;
-
-	err = -EINVAL;
-	if (tb[TCA_HTB_PARMS] == NULL)
-		goto failure;
+		return err;
+	if (!tb[TCA_HTB_PARMS])
+		return -EINVAL;
 
 	parent = parentid == TC_H_ROOT ? NULL : htb_find(parentid, sch);
-
 	hopt = nla_data(tb[TCA_HTB_PARMS]);
 
 	rtab = qdisc_get_rtab(&hopt->rate, tb[TCA_HTB_RTAB]);
+	if (!rtab)
+		return -EINVAL;
+	err = -EINVAL;
 	ctab = qdisc_get_rtab(&hopt->ceil, tb[TCA_HTB_CTAB]);
-	if (!rtab || !ctab)
-		goto failure;
+	if (!ctab)
+		goto err_put_rtab;
+
+	p = kzalloc(sizeof(*p), GFP_KERNEL);
+	err = -ENOMEM;
+	if (!p)
+		goto err_put_ctab;
+
+	memcpy(&p->hopt, hopt, sizeof(p->hopt));
+	p->rtab = rtab;
+	p->ctab = ctab;
 
-	if (!cl) {		/* new class */
+	if (!cl) {
 		struct Qdisc *new_q;
 		int prio;
-		struct {
-			struct nlattr		nla;
-			struct gnet_estimator	opt;
-		} est = {
-			.nla = {
-				.nla_len	= nla_attr_size(sizeof(est.opt)),
-				.nla_type	= TCA_RATE,
-			},
-			.opt = {
-				/* 4s interval, 16s averaging constant */
-				.interval	= 2,
-				.ewma_log	= 2,
-			},
-		};
-
-		/* check for valid classid */
+
+		err = -EINVAL;
 		if (!classid || TC_H_MAJ(classid ^ sch->handle)
 		    || htb_find(classid, sch))
-			goto failure;
+			goto err_free_config;
+		if (parent && parent->parent && parent->parent->level < 2)
+			goto err_free_config;
 
-		/* check maximal depth */
-		if (parent && parent->parent && parent->parent->level < 2) {
-			printk(KERN_ERR "htb: tree is too deep\n");
-			goto failure;
-		}
 		err = -ENOBUFS;
-		if ((cl = kzalloc(sizeof(*cl), GFP_KERNEL)) == NULL)
-			goto failure;
+		cl = kzalloc(sizeof(*cl), GFP_KERNEL);
+		if (!cl)
+			goto err_free_config;
 
-		gen_new_estimator(&cl->bstats, &cl->rate_est,
-				  &sch->dev_queue->lock,
-				  tca[TCA_RATE] ? : &est.nla);
 		cl->refcnt = 1;
 		cl->children = 0;
 		INIT_LIST_HEAD(&cl->un.leaf.drop_list);
@@ -1402,12 +1403,81 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 		for (prio = 0; prio < TC_HTB_NUMPRIO; prio++)
 			RB_CLEAR_NODE(&cl->node[prio]);
 
-		/* create leaf qdisc early because it uses kmalloc(GFP_KERNEL)
-		   so that can't be used inside of sch_tree_lock
-		   -- thanks to Karlis Peisenieks */
 		new_q = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
 					  &pfifo_qdisc_ops, classid);
-		sch_tree_lock(sch);
+		err = -ENOMEM;
+		if (!new_q)
+			goto err_free_class;
+
+		cl->un.leaf.q = new_q;
+
+		if (tca[TCA_RATE]) {
+			memcpy(&p->est, nla_data(tca[TCA_RATE]),
+			       sizeof(p->est));
+		} else {
+			/* default: 4s interval, 16s averaging constant */
+			p->est.interval = 2;
+			p->est.ewma_log = 2;
+		}
+
+		__gen_new_estimator(&cl->bstats, &cl->rate_est,
+				    &sch->dev_queue->lock, &p->est);
+
+		cl->common.classid = classid;
+		cl->parent = parent;
+
+		/* set class to be in HTB_CAN_SEND state */
+		cl->tokens = hopt->buffer;
+		cl->ctokens = hopt->cbuffer;
+		cl->mbuffer = 60 * PSCHED_TICKS_PER_SEC;	/* 1min */
+		cl->t_c = psched_get_time();
+		cl->cmode = HTB_CAN_SEND;
+
+		p->new_class = cl;
+	} else {
+		if (tca[TCA_RATE]) {
+			memcpy(&p->est, nla_data(tca[TCA_RATE]),
+			       sizeof(p->est));
+			p->flags |= FLAG_HAVE_EST;
+		}
+	}
+
+	q->pending_config = p;
+	*arg = (unsigned long) cl;
+
+	return 0;
+
+err_free_class:
+	kfree(cl);
+
+err_free_config:
+	kfree(p);
+
+err_put_ctab:
+	qdisc_put_rtab(ctab);
+
+err_put_rtab:
+	qdisc_put_rtab(rtab);
+	return err;
+}
+
+static void htb_commit_change_class(struct Qdisc *sch, u32 classid,
+				    u32 parentid, struct nlattr **tca,
+				    unsigned long arg)
+{
+	struct htb_class *cl = (struct htb_class *) arg;
+	struct htb_sched *q = qdisc_priv(sch);
+	struct htb_pending_config *p;
+
+	BUG_ON(!q->pending_config);
+	p = q->pending_config;
+	q->pending_config = NULL;
+
+	sch_tree_lock(sch);
+	if (p->new_class) {
+		struct htb_class *parent;
+
+		parent = cl->parent;
 		if (parent && !parent->level) {
 			unsigned int qlen = parent->un.leaf.q->q.qlen;
 
@@ -1427,50 +1497,38 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 					 : TC_HTB_MAXDEPTH) - 1;
 			memset(&parent->un.inner, 0, sizeof(parent->un.inner));
 		}
-		/* leaf (we) needs elementary qdisc */
-		cl->un.leaf.q = new_q ? new_q : &noop_qdisc;
-
-		cl->common.classid = classid;
-		cl->parent = parent;
-
-		/* set class to be in HTB_CAN_SEND state */
-		cl->tokens = hopt->buffer;
-		cl->ctokens = hopt->cbuffer;
-		cl->mbuffer = 60 * PSCHED_TICKS_PER_SEC;	/* 1min */
-		cl->t_c = psched_get_time();
-		cl->cmode = HTB_CAN_SEND;
 
 		/* attach to the hash list and parent's family */
 		qdisc_class_hash_insert(&q->clhash, &cl->common);
 		if (parent)
 			parent->children++;
 	} else {
-		if (tca[TCA_RATE])
-			gen_replace_estimator(&cl->bstats, &cl->rate_est,
-					      &sch->dev_queue->lock,
-					      tca[TCA_RATE]);
-		sch_tree_lock(sch);
+		if (p->flags & FLAG_HAVE_EST)
+			__gen_replace_estimator(&cl->bstats, &cl->rate_est,
+						&sch->dev_queue->lock,
+						&p->est);
+
 	}
 
 	/* it used to be a nasty bug here, we have to check that node
 	   is really leaf before changing cl->un.leaf ! */
 	if (!cl->level) {
-		cl->un.leaf.quantum = rtab->rate.rate / q->rate2quantum;
-		if (!hopt->quantum && cl->un.leaf.quantum < 1000) {
+		cl->un.leaf.quantum = p->rtab->rate.rate / q->rate2quantum;
+		if (!p->hopt.quantum && cl->un.leaf.quantum < 1000) {
 			printk(KERN_WARNING
 			       "HTB: quantum of class %X is small. Consider r2q change.\n",
 			       cl->common.classid);
 			cl->un.leaf.quantum = 1000;
 		}
-		if (!hopt->quantum && cl->un.leaf.quantum > 200000) {
+		if (!p->hopt.quantum && cl->un.leaf.quantum > 200000) {
 			printk(KERN_WARNING
 			       "HTB: quantum of class %X is big. Consider r2q change.\n",
 			       cl->common.classid);
 			cl->un.leaf.quantum = 200000;
 		}
-		if (hopt->quantum)
-			cl->un.leaf.quantum = hopt->quantum;
-		if ((cl->un.leaf.prio = hopt->prio) >= TC_HTB_NUMPRIO)
+		if (p->hopt.quantum)
+			cl->un.leaf.quantum = p->hopt.quantum;
+		if ((cl->un.leaf.prio = p->hopt.prio) >= TC_HTB_NUMPRIO)
 			cl->un.leaf.prio = TC_HTB_NUMPRIO - 1;
 
 		/* backup for htb_parent_to_leaf */
@@ -1478,27 +1536,46 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 		cl->prio = cl->un.leaf.prio;
 	}
 
-	cl->buffer = hopt->buffer;
-	cl->cbuffer = hopt->cbuffer;
+	cl->buffer = p->hopt.buffer;
+	cl->cbuffer = p->hopt.cbuffer;
 	if (cl->rate)
 		qdisc_put_rtab(cl->rate);
-	cl->rate = rtab;
+	cl->rate = p->rtab;
 	if (cl->ceil)
 		qdisc_put_rtab(cl->ceil);
-	cl->ceil = ctab;
+	cl->ceil = p->ctab;
 	sch_tree_unlock(sch);
 
 	qdisc_class_hash_grow(sch, &q->clhash);
 
-	*arg = (unsigned long)cl;
-	return 0;
+	kfree(p);
+}
 
-failure:
-	if (rtab)
-		qdisc_put_rtab(rtab);
-	if (ctab)
-		qdisc_put_rtab(ctab);
-	return err;
+static void htb_cancel_change_class(struct Qdisc *sch, u32 classid,
+				    u32 parentid, struct nlattr **tca,
+				    unsigned long arg)
+{
+	struct htb_sched *q = qdisc_priv(sch);
+	struct htb_pending_config *p;
+
+	BUG_ON(!q->pending_config);
+	p = q->pending_config;
+	q->pending_config = NULL;
+
+	if (p->new_class) {
+		struct htb_class *cl = p->new_class;
+
+		if (cl->un.leaf.q)
+			qdisc_destroy(cl->un.leaf.q);
+
+		p->new_class = NULL;
+		kfree(p->new_class);
+	}
+
+	qdisc_put_rtab(p->ctab);
+	qdisc_put_rtab(p->rtab);
+
+	kfree(p);
 }
 
 static struct tcf_proto **htb_find_tcf(struct Qdisc *sch, unsigned long arg)
@@ -1570,7 +1647,9 @@ static const struct Qdisc_class_ops htb_class_ops = {
 	.qlen_notify	=	htb_qlen_notify,
 	.get		=	htb_get,
 	.put		=	htb_put,
-	.change		=	htb_change_class,
+	.validate_change=	htb_validate_change_class,
+	.commit_change	=	htb_commit_change_class,
+	.cancel_change	=	htb_cancel_change_class,
 	.validate_delete=	htb_validate_delete,
 	.commit_delete	=	htb_commit_delete,
 	.walk		=	htb_walk,
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index 1cfb57e..924e1d4 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -48,12 +48,22 @@ static void ingress_put(struct Qdisc *sch, unsigned long cl)
 {
 }
 
-static int ingress_change(struct Qdisc *sch, u32 classid, u32 parent,
-			  struct nlattr **tca, unsigned long *arg)
+static int ingress_validate_change(struct Qdisc *sch, u32 classid, u32 parent,
+				   struct nlattr **tca, unsigned long *arg)
 {
 	return 0;
 }
 
+static void ingress_commit_change(struct Qdisc *sch, u32 classid, u32 parent,
+				  struct nlattr **tca, unsigned long arg)
+{
+}
+
+static void ingress_cancel_change(struct Qdisc *sch, u32 classid, u32 parent,
+				  struct nlattr **tca, unsigned long arg)
+{
+}
+
 static void ingress_walk(struct Qdisc *sch, struct qdisc_walker *walker)
 {
 	return;
@@ -127,7 +137,9 @@ static const struct Qdisc_class_ops ingress_class_ops = {
 	.leaf		=	ingress_leaf,
 	.get		=	ingress_get,
 	.put		=	ingress_put,
-	.change		=	ingress_change,
+	.validate_change=	ingress_validate_change,
+	.commit_change	=	ingress_commit_change,
+	.cancel_change	=	ingress_cancel_change,
 	.walk		=	ingress_walk,
 	.tcf_chain	=	ingress_find_tcf,
 	.bind_tcf	=	ingress_bind_filter,
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index ca8bcd4..ca34c7d 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -702,12 +702,27 @@ static void netem_put(struct Qdisc *sch, unsigned long arg)
 {
 }
 
-static int netem_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
-			    struct nlattr **tca, unsigned long *arg)
+static int netem_validate_change_class(struct Qdisc *sch, u32 classid,
+				       u32 parentid, struct nlattr **tca,
+				       unsigned long *arg)
 {
 	return -ENOSYS;
 }
 
+static void netem_commit_change_class(struct Qdisc *sch, u32 classid,
+				      u32 parentid, struct nlattr **tca,
+				      unsigned long arg)
+{
+	WARN_ON(1);
+}
+
+static void netem_cancel_change_class(struct Qdisc *sch, u32 classid,
+				      u32 parentid, struct nlattr **tca,
+				      unsigned long arg)
+{
+	WARN_ON(1);
+}
+
 static int netem_validate_delete(struct Qdisc *sch, unsigned long arg)
 {
 	return -ENOSYS;
@@ -741,7 +756,9 @@ static const struct Qdisc_class_ops netem_class_ops = {
 	.leaf		=	netem_leaf,
 	.get		=	netem_get,
 	.put		=	netem_put,
-	.change		=	netem_change_class,
+	.validate_change=	netem_validate_change_class,
+	.commit_change	=	netem_commit_change_class,
+	.cancel_change	=	netem_cancel_change_class,
 	.validate_delete=	netem_validate_delete,
 	.commit_delete	=	netem_commit_delete,
 	.walk		=	netem_walk,
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 25e07db..e2bf0e2 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -394,16 +394,27 @@ static void prio_put(struct Qdisc *q, unsigned long cl)
 	return;
 }
 
-static int prio_change(struct Qdisc *sch, u32 handle, u32 parent, struct nlattr **tca, unsigned long *arg)
+static int prio_validate_tc_change(struct Qdisc *sch, u32 handle, u32 parent,
+				   struct nlattr **tca, unsigned long *arg)
 {
-	unsigned long cl = *arg;
 	struct prio_sched_data *q = qdisc_priv(sch);
+	unsigned long cl = *arg;
 
 	if (cl - 1 > q->bands)
 		return -ENOENT;
 	return 0;
 }
 
+static void prio_commit_tc_change(struct Qdisc *sch, u32 handle, u32 parent,
+				  struct nlattr **tca, unsigned long arg)
+{
+}
+
+static void prio_cancel_tc_change(struct Qdisc *sch, u32 handle, u32 parent,
+				  struct nlattr **tca, unsigned long arg)
+{
+}
+
 static int prio_validate_delete(struct Qdisc *sch, unsigned long cl)
 {
 	struct prio_sched_data *q = qdisc_priv(sch);
@@ -480,7 +491,9 @@ static const struct Qdisc_class_ops prio_class_ops = {
 	.leaf		=	prio_leaf,
 	.get		=	prio_get,
 	.put		=	prio_put,
-	.change		=	prio_change,
+	.validate_change=	prio_validate_tc_change,
+	.commit_change	=	prio_commit_tc_change,
+	.cancel_change	=	prio_cancel_tc_change,
 	.validate_delete=	prio_validate_delete,
 	.commit_delete	=	prio_commit_delete,
 	.walk		=	prio_walk,
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index 5ad4ed0..4804047 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -368,12 +368,27 @@ static void red_put(struct Qdisc *sch, unsigned long arg)
 	return;
 }
 
-static int red_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
-			    struct nlattr **tca, unsigned long *arg)
+static int red_validate_change_class(struct Qdisc *sch, u32 classid,
+				     u32 parentid, struct nlattr **tca,
+				     unsigned long *arg)
 {
 	return -ENOSYS;
 }
 
+static void red_commit_change_class(struct Qdisc *sch, u32 classid,
+				    u32 parentid, struct nlattr **tca,
+				    unsigned long arg)
+{
+	WARN_ON(1);
+}
+
+static void red_cancel_change_class(struct Qdisc *sch, u32 classid,
+				    u32 parentid, struct nlattr **tca,
+				    unsigned long arg)
+{
+	WARN_ON(1);
+}
+
 static int red_validate_delete(struct Qdisc *sch, unsigned long cl)
 {
 	return -ENOSYS;
@@ -408,7 +423,9 @@ static const struct Qdisc_class_ops red_class_ops = {
 	.leaf		=	red_leaf,
 	.get		=	red_get,
 	.put		=	red_put,
-	.change		=	red_change_class,
+	.validate_change=	red_validate_change_class,
+	.commit_change	=	red_commit_change_class,
+	.cancel_change	=	red_cancel_change_class,
 	.validate_delete=	red_validate_delete,
 	.commit_delete	=	red_commit_delete,
 	.walk		=	red_walk,
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index a52ca74..dba7ecf 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -547,12 +547,27 @@ nla_put_failure:
 	return -1;
 }
 
-static int sfq_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
-			    struct nlattr **tca, unsigned long *arg)
+static int sfq_validate_change_class(struct Qdisc *sch, u32 classid,
+				     u32 parentid, struct nlattr **tca,
+				     unsigned long *arg)
 {
 	return -EOPNOTSUPP;
 }
 
+static void sfq_commit_change_class(struct Qdisc *sch, u32 classid,
+				    u32 parentid, struct nlattr **tca,
+				    unsigned long arg)
+{
+	WARN_ON(1);
+}
+
+static void sfq_cancel_change_class(struct Qdisc *sch, u32 classid,
+				    u32 parentid, struct nlattr **tca,
+				    unsigned long arg)
+{
+	WARN_ON(1);
+}
+
 static unsigned long sfq_get(struct Qdisc *sch, u32 classid)
 {
 	return 0;
@@ -611,7 +626,9 @@ static void sfq_walk(struct Qdisc *sch, struct qdisc_walker *arg)
 
 static const struct Qdisc_class_ops sfq_class_ops = {
 	.get		=	sfq_get,
-	.change		=	sfq_change_class,
+	.validate_change=	sfq_validate_change_class,
+	.commit_change	=	sfq_commit_change_class,
+	.cancel_change	=	sfq_cancel_change_class,
 	.tcf_chain	=	sfq_find_tcf,
 	.dump		=	sfq_dump_class,
 	.dump_stats	=	sfq_dump_class_stats,
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index f9de373..5474f87 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -511,12 +511,27 @@ static void tbf_put(struct Qdisc *sch, unsigned long arg)
 {
 }
 
-static int tbf_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
-			    struct nlattr **tca, unsigned long *arg)
+static int tbf_validate_change_class(struct Qdisc *sch, u32 classid,
+				     u32 parentid, struct nlattr **tca,
+				     unsigned long *arg)
 {
 	return -ENOSYS;
 }
 
+static void tbf_commit_change_class(struct Qdisc *sch, u32 classid,
+				    u32 parentid, struct nlattr **tca,
+				    unsigned long arg)
+{
+	WARN_ON(1);
+}
+
+static void tbf_cancel_change_class(struct Qdisc *sch, u32 classid,
+				    u32 parentid, struct nlattr **tca,
+				    unsigned long arg)
+{
+	WARN_ON(1);
+}
+
 static int tbf_validate_delete(struct Qdisc *sch, unsigned long arg)
 {
 	return -ENOSYS;
@@ -552,7 +567,9 @@ static const struct Qdisc_class_ops tbf_class_ops =
 	.leaf		=	tbf_leaf,
 	.get		=	tbf_get,
 	.put		=	tbf_put,
-	.change		=	tbf_change_class,
+	.validate_change=	tbf_validate_change_class,
+	.commit_change	=	tbf_commit_change_class,
+	.cancel_change	=	tbf_cancel_change_class,
 	.validate_delete=	tbf_validate_delete,
 	.commit_delete	=	tbf_commit_delete,
 	.walk		=	tbf_walk,
-- 
1.5.6.2.255.gbed62

