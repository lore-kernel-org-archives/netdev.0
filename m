From: David Miller <davem@davemloft.net>
Subject: [PATCH 6/14]: pkt_sched: Make qdisc ->config() ops use
 validate/commit/cancel model.
Date: Mon, 14 Jul 2008 15:59:44 -0700 (PDT)
Message-ID: <20080714.155944.39015967.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49267
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758439AbYGNW7w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 18:59:52 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 3CBDFC8C187
	for <netdev@vger.kernel.org>; Mon, 14 Jul 2008 15:59:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Just like class grafting, qdisc configuration change requests now
separate the arg validation and memory allocation from the actual
commiting of the settings.

This allows multiqueue setups to properly unwind when the first queues
would succeed but a subsequent one would not.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/pkt_sched.h   |    3 +-
 include/net/sch_generic.h |    4 +-
 net/sched/sch_api.c       |   71 ++++++++++++++--------
 net/sched/sch_cbq.c       |    1 -
 net/sched/sch_dsmark.c    |    1 -
 net/sched/sch_fifo.c      |   85 +++++++++++++++++++-------
 net/sched/sch_gred.c      |  147 +++++++++++++++++++++++++++-----------------
 net/sched/sch_hfsc.c      |   24 +++++---
 net/sched/sch_htb.c       |    1 -
 net/sched/sch_netem.c     |  147 +++++++++++++++++++++++++++++---------------
 net/sched/sch_prio.c      |  112 ++++++++++++++++++++++++++--------
 net/sched/sch_red.c       |   72 ++++++++++++++++++----
 net/sched/sch_sfq.c       |    1 -
 net/sched/sch_tbf.c       |  125 +++++++++++++++++++++++++++++++-------
 14 files changed, 561 insertions(+), 233 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index cb95278..5d9ffe8 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -72,7 +72,8 @@ extern void qdisc_watchdog_cancel(struct qdisc_watchdog *wd);
 extern struct Qdisc_ops pfifo_qdisc_ops;
 extern struct Qdisc_ops bfifo_qdisc_ops;
 
-extern int fifo_set_limit(struct Qdisc *q, unsigned int limit);
+extern int fifo_validate_limit(struct Qdisc *q, unsigned int limit);
+extern void fifo_commit_limit(struct Qdisc *q, unsigned int limit);
 extern struct Qdisc *fifo_create_dflt(struct Qdisc *sch, struct Qdisc_ops *ops,
 				      unsigned int limit);
 
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 5318c37..4d11b29 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -102,7 +102,9 @@ struct Qdisc_ops
 	int			(*init)(struct Qdisc *, struct nlattr *arg);
 	void			(*reset)(struct Qdisc *);
 	void			(*destroy)(struct Qdisc *);
-	int			(*change)(struct Qdisc *, struct nlattr *arg);
+	int			(*validate_change)(struct Qdisc *, struct nlattr *arg);
+	void			(*commit_change)(struct Qdisc *, struct nlattr *arg);
+	void			(*cancel_change)(struct Qdisc *, struct nlattr *arg);
 
 	int			(*dump)(struct Qdisc *, struct sk_buff *);
 	int			(*dump_stats)(struct Qdisc *, struct gnet_dump *);
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index a59f99f..d190c49 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -628,26 +628,6 @@ err_out:
 	return NULL;
 }
 
-/* Change the parameters on qdisc 'sch', using the attributes described
- * in 'tca'.
- */
-static int qdisc_change(struct Qdisc *sch, struct nlattr **tca)
-{
-	if (tca[TCA_OPTIONS]) {
-		int err;
-
-		if (sch->ops->change == NULL)
-			return -EINVAL;
-		err = sch->ops->change(sch, tca[TCA_OPTIONS]);
-		if (err)
-			return err;
-	}
-	if (tca[TCA_RATE])
-		gen_replace_estimator(&sch->bstats, &sch->rate_est,
-				      &sch->dev_queue->lock, tca[TCA_RATE]);
-	return 0;
-}
-
 struct check_loop_arg
 {
 	struct qdisc_walker 	w;
@@ -708,6 +688,7 @@ struct tc_qdisc_op_info {
 #define TC_QDISC_OP_CHANGE	0x00000004
 #define TC_QDISC_OP_ALLOCATED	0x00000008
 #define TC_QDISC_OP_GRAFT_PREP	0x00000010
+#define TC_QDISC_OP_CHANGE_PREP	0x00000020
 };
 
 /* Prepare a request for a get or delete operation.  */
@@ -1133,6 +1114,24 @@ static int tc_graft_all(struct tc_qdisc_op_info *queue_arr, unsigned int num_q,
 	return 0;
 }
 
+static void tc_change_cancel(struct tc_qdisc_op_info *queue_arr, unsigned int num_q,
+			     struct nlattr **tca)
+{
+	unsigned int i;
+
+	for (i = 0; i < num_q; i++) {
+		struct tc_qdisc_op_info *qp = queue_arr + i;
+		struct Qdisc *q = qp->op_q;
+
+		if (!(qp->flags & TC_QDISC_OP_CHANGE_PREP))
+			continue;
+
+		q->ops->cancel_change(q, tca[TCA_OPTIONS]);
+
+		qp->flags &= ~TC_QDISC_OP_CHANGE_PREP;
+	}
+}
+
 /* Make qdisc parameter changes as requested in 'tca' to the qdiscs
  * recorded in 'queue_arr' and 'num_q'.
  */
@@ -1143,17 +1142,39 @@ static int tc_change_all(struct tc_qdisc_op_info *queue_arr, unsigned int num_q,
 
 	for (i = 0; i < num_q; i++) {
 		struct tc_qdisc_op_info *qp = queue_arr + i;
-		int err;
+		struct Qdisc *q = qp->op_q;
 
 		if (!(qp->flags & TC_QDISC_OP_CHANGE))
 			continue;
+		if (tca[TCA_OPTIONS]) {
+			int err = -EINVAL;
 
-		err = qdisc_change(qp->op_q, tca);
-		if (err) {
-			/* XXX In multiqueue case, need rollback... */
-			return err;
+			if (q->ops->validate_change)
+				err = q->ops->validate_change(q, tca[TCA_OPTIONS]);
+
+			if (err) {
+				tc_change_cancel(queue_arr, num_q, tca);
+				return err;
+			}
+
+			qp->flags |= TC_QDISC_OP_CHANGE_PREP;
 		}
 	}
+
+	for (i = 0; i < num_q; i++) {
+		struct tc_qdisc_op_info *qp = queue_arr + i;
+		struct Qdisc *q = qp->op_q;
+
+		if (!(qp->flags & TC_QDISC_OP_CHANGE))
+			continue;
+
+		if (tca[TCA_OPTIONS])
+			q->ops->commit_change(q, tca[TCA_OPTIONS]);
+
+		if (tca[TCA_RATE])
+			gen_replace_estimator(&q->bstats, &q->rate_est,
+					      &q->dev_queue->lock, tca[TCA_RATE]);
+	}
 	return 0;
 }
 
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 224b9c0..2c9895a 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -2076,7 +2076,6 @@ static struct Qdisc_ops cbq_qdisc_ops __read_mostly = {
 	.init		=	cbq_init,
 	.reset		=	cbq_reset,
 	.destroy	=	cbq_destroy,
-	.change		=	NULL,
 	.dump		=	cbq_dump,
 	.dump_stats	=	cbq_dump_stats,
 	.owner		=	THIS_MODULE,
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 28f4e77..85dec9b 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -515,7 +515,6 @@ static struct Qdisc_ops dsmark_qdisc_ops __read_mostly = {
 	.init		=	dsmark_init,
 	.reset		=	dsmark_reset,
 	.destroy	=	dsmark_destroy,
-	.change		=	NULL,
 	.dump		=	dsmark_dump,
 	.owner		=	THIS_MODULE,
 };
diff --git a/net/sched/sch_fifo.c b/net/sched/sch_fifo.c
index 1d97fa4..7ed1887 100644
--- a/net/sched/sch_fifo.c
+++ b/net/sched/sch_fifo.c
@@ -43,11 +43,18 @@ static int pfifo_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 	return qdisc_reshape_fail(skb, sch);
 }
 
-static int fifo_init(struct Qdisc *sch, struct nlattr *opt)
+static int fifo_validate(struct Qdisc *sch, struct nlattr *opt)
+{
+	if (opt && nla_len(opt) < sizeof (struct tc_fifo_qopt))
+		return -EINVAL;
+	return 0;
+}
+
+static void fifo_commit(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct fifo_sched_data *q = qdisc_priv(sch);
 
-	if (opt == NULL) {
+	if (!opt) {
 		u32 limit = qdisc_dev(sch)->tx_queue_len ? : 1;
 
 		if (sch->ops == &bfifo_qdisc_ops)
@@ -57,12 +64,22 @@ static int fifo_init(struct Qdisc *sch, struct nlattr *opt)
 	} else {
 		struct tc_fifo_qopt *ctl = nla_data(opt);
 
-		if (nla_len(opt) < sizeof(*ctl))
-			return -EINVAL;
-
 		q->limit = ctl->limit;
 	}
+}
+
+static void fifo_cancel(struct Qdisc *sch, struct nlattr *opt)
+{
+}
 
+static int fifo_init(struct Qdisc *sch, struct nlattr *opt)
+{
+	int err = fifo_validate(sch, opt);
+
+	if (err)
+		return err;
+
+	fifo_commit(sch, opt);
 	return 0;
 }
 
@@ -87,7 +104,9 @@ struct Qdisc_ops pfifo_qdisc_ops __read_mostly = {
 	.drop		=	qdisc_queue_drop,
 	.init		=	fifo_init,
 	.reset		=	qdisc_reset_queue,
-	.change		=	fifo_init,
+	.validate_change=	fifo_validate,
+	.commit_change	=	fifo_commit,
+	.cancel_change	=	fifo_cancel,
 	.dump		=	fifo_dump,
 	.owner		=	THIS_MODULE,
 };
@@ -102,34 +121,54 @@ struct Qdisc_ops bfifo_qdisc_ops __read_mostly = {
 	.drop		=	qdisc_queue_drop,
 	.init		=	fifo_init,
 	.reset		=	qdisc_reset_queue,
-	.change		=	fifo_init,
+	.validate_change=	fifo_validate,
+	.commit_change	=	fifo_commit,
+	.cancel_change	=	fifo_cancel,
 	.dump		=	fifo_dump,
 	.owner		=	THIS_MODULE,
 };
 EXPORT_SYMBOL(bfifo_qdisc_ops);
 
 /* Pass size change message down to embedded FIFO */
-int fifo_set_limit(struct Qdisc *q, unsigned int limit)
+int fifo_validate_limit(struct Qdisc *q, unsigned int limit)
 {
-	struct nlattr *nla;
-	int ret = -ENOMEM;
+	union {
+		struct nlattr n;
+		char buf[nla_attr_size(sizeof(struct tc_fifo_qopt))];
+	} u;
+	struct nlattr *nla = &u.n;
 
 	/* Hack to avoid sending change message to non-FIFO */
 	if (strncmp(q->ops->id + 1, "fifo", 4) != 0)
 		return 0;
 
-	nla = kmalloc(nla_attr_size(sizeof(struct tc_fifo_qopt)), GFP_KERNEL);
-	if (nla) {
-		nla->nla_type = RTM_NEWQDISC;
-		nla->nla_len = nla_attr_size(sizeof(struct tc_fifo_qopt));
-		((struct tc_fifo_qopt *)nla_data(nla))->limit = limit;
+	nla->nla_type = RTM_NEWQDISC;
+	nla->nla_len = nla_attr_size(sizeof(struct tc_fifo_qopt));
+	((struct tc_fifo_qopt *)nla_data(nla))->limit = limit;
 
-		ret = q->ops->change(q, nla);
-		kfree(nla);
-	}
-	return ret;
+	return q->ops->validate_change(q, nla);
+}
+EXPORT_SYMBOL(fifo_validate_limit);
+
+void fifo_commit_limit(struct Qdisc *q, unsigned int limit)
+{
+	union {
+		struct nlattr n;
+		char buf[nla_attr_size(sizeof(struct tc_fifo_qopt))];
+	} u;
+	struct nlattr *nla = &u.n;
+
+	/* Hack to avoid sending change message to non-FIFO */
+	if (strncmp(q->ops->id + 1, "fifo", 4) != 0)
+		return;
+
+	nla->nla_type = RTM_NEWQDISC;
+	nla->nla_len = nla_attr_size(sizeof(struct tc_fifo_qopt));
+	((struct tc_fifo_qopt *)nla_data(nla))->limit = limit;
+
+	q->ops->commit_change(q, nla);
 }
-EXPORT_SYMBOL(fifo_set_limit);
+EXPORT_SYMBOL(fifo_commit_limit);
 
 struct Qdisc *fifo_create_dflt(struct Qdisc *sch, struct Qdisc_ops *ops,
 			       unsigned int limit)
@@ -140,8 +179,10 @@ struct Qdisc *fifo_create_dflt(struct Qdisc *sch, struct Qdisc_ops *ops,
 	q = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
 			      ops, TC_H_MAKE(sch->handle, 1));
 	if (q) {
-		err = fifo_set_limit(q, limit);
-		if (err < 0) {
+		err = fifo_validate_limit(q, limit);
+		if (!err)
+			fifo_commit_limit(q, limit);
+		if (err) {
 			qdisc_destroy(q);
 			q = NULL;
 		}
diff --git a/net/sched/sch_gred.c b/net/sched/sch_gred.c
index 39fa285..c38b5d1 100644
--- a/net/sched/sch_gred.c
+++ b/net/sched/sch_gred.c
@@ -350,21 +350,16 @@ static inline void gred_destroy_vq(struct gred_sched_data *q)
 	kfree(q);
 }
 
-static inline int gred_change_table_def(struct Qdisc *sch, struct nlattr *dps)
+static void gred_change_table_def(struct Qdisc *sch, struct nlattr *dps)
 {
 	struct gred_sched *table = qdisc_priv(sch);
 	struct tc_gred_sopt *sopt;
 	int i;
 
-	if (dps == NULL)
-		return -EINVAL;
-
 	sopt = nla_data(dps);
 
-	if (sopt->DPs > MAX_DPs || sopt->DPs == 0 || sopt->def_DP >= sopt->DPs)
-		return -EINVAL;
-
 	sch_tree_lock(sch);
+
 	table->DPs = sopt->DPs;
 	table->def = sopt->def_DP;
 	table->red_flags = sopt->flags;
@@ -394,23 +389,17 @@ static inline int gred_change_table_def(struct Qdisc *sch, struct nlattr *dps)
 			table->tab[i] = NULL;
 		}
 	}
-
-	return 0;
 }
 
-static inline int gred_change_vq(struct Qdisc *sch, int dp,
-				 struct tc_gred_qopt *ctl, int prio, u8 *stab)
+static void gred_change_vq(struct Qdisc *sch, int dp, struct tc_gred_qopt *ctl,
+			   int prio, u8 *stab)
 {
 	struct gred_sched *table = qdisc_priv(sch);
 	struct gred_sched_data *q;
 
-	if (table->tab[dp] == NULL) {
-		table->tab[dp] = kzalloc(sizeof(*q), GFP_KERNEL);
-		if (table->tab[dp] == NULL)
-			return -ENOMEM;
-	}
-
 	q = table->tab[dp];
+	BUG_ON(!q);
+
 	q->DP = dp;
 	q->prio = prio;
 	q->limit = ctl->limit;
@@ -421,8 +410,6 @@ static inline int gred_change_vq(struct Qdisc *sch, int dp,
 	red_set_parms(&q->parms,
 		      ctl->qth_min, ctl->qth_max, ctl->Wlog, ctl->Plog,
 		      ctl->Scell_log, stab);
-
-	return 0;
 }
 
 static const struct nla_policy gred_policy[TCA_GRED_MAX + 1] = {
@@ -431,68 +418,106 @@ static const struct nla_policy gred_policy[TCA_GRED_MAX + 1] = {
 	[TCA_GRED_DPS]		= { .len = sizeof(struct tc_gred_sopt) },
 };
 
-static int gred_change(struct Qdisc *sch, struct nlattr *opt)
+static int gred_validate_table_def(struct tc_gred_sopt *sopt)
+{
+	if (sopt->DPs > MAX_DPs ||
+	    sopt->DPs == 0 ||
+	    sopt->def_DP >= sopt->DPs)
+		return -EINVAL;
+	return 0;
+}
+
+static int gred_validate_change(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct gred_sched *table = qdisc_priv(sch);
-	struct tc_gred_qopt *ctl;
 	struct nlattr *tb[TCA_GRED_MAX + 1];
-	int err, prio = GRED_DEF_PRIO;
+	struct tc_gred_qopt *ctl;
 	u8 *stab;
-
-	if (opt == NULL)
-		return -EINVAL;
+	int err;
 
 	err = nla_parse_nested(tb, TCA_GRED_MAX, opt, gred_policy);
 	if (err < 0)
 		return err;
 
-	if (tb[TCA_GRED_PARMS] == NULL && tb[TCA_GRED_STAB] == NULL)
-		return gred_change_table_def(sch, opt);
+	if (!tb[TCA_GRED_PARMS] && !tb[TCA_GRED_STAB]) {
+		struct tc_gred_sopt *sopt = nla_data(opt);
 
-	if (tb[TCA_GRED_PARMS] == NULL ||
-	    tb[TCA_GRED_STAB] == NULL)
+		return gred_validate_table_def(sopt);
+	}
+
+	if (!tb[TCA_GRED_PARMS] || !tb[TCA_GRED_STAB])
 		return -EINVAL;
 
-	err = -EINVAL;
 	ctl = nla_data(tb[TCA_GRED_PARMS]);
 	stab = nla_data(tb[TCA_GRED_STAB]);
 
 	if (ctl->DP >= table->DPs)
-		goto errout;
+		return -EINVAL;
 
-	if (gred_rio_mode(table)) {
-		if (ctl->prio == 0) {
-			int def_prio = GRED_DEF_PRIO;
+	sch_tree_lock(sch);
+	err = 0;
+	if (!table->tab[ctl->DP]) {
+		table->tab[ctl->DP] = kzalloc(sizeof(struct gred_sched_data),
+					      GFP_ATOMIC);
+		if (!table->tab[ctl->DP])
+			err = -ENOMEM;
+	}
+	sch_tree_unlock(sch);
 
-			if (table->tab[table->def])
-				def_prio = table->tab[table->def]->prio;
+	return err;
+}
 
-			printk(KERN_DEBUG "GRED: DP %u does not have a prio "
-			       "setting default to %d\n", ctl->DP, def_prio);
+static void gred_commit_change(struct Qdisc *sch, struct nlattr *opt)
+{
+	struct gred_sched *table = qdisc_priv(sch);
+	struct tc_gred_qopt *ctl;
+	struct nlattr *tb[TCA_GRED_MAX + 1];
+	int err, prio = GRED_DEF_PRIO;
+	u8 *stab;
 
-			prio = def_prio;
-		} else
-			prio = ctl->prio;
+	err = nla_parse_nested(tb, TCA_GRED_MAX, opt, gred_policy);
+	if (err < 0) {
+		WARN_ON(1);
+		return;
 	}
 
-	sch_tree_lock(sch);
+	if (!tb[TCA_GRED_PARMS] && !tb[TCA_GRED_STAB]) {
+		gred_change_table_def(sch, opt);
+	} else {
+		ctl = nla_data(tb[TCA_GRED_PARMS]);
+		stab = nla_data(tb[TCA_GRED_STAB]);
 
-	err = gred_change_vq(sch, ctl->DP, ctl, prio, stab);
-	if (err < 0)
-		goto errout_locked;
+		if (gred_rio_mode(table)) {
+			if (ctl->prio == 0) {
+				int def_prio = GRED_DEF_PRIO;
 
-	if (gred_rio_mode(table)) {
-		gred_disable_wred_mode(table);
-		if (gred_wred_mode_check(sch))
-			gred_enable_wred_mode(table);
-	}
+				if (table->tab[table->def])
+					def_prio = table->tab[table->def]->prio;
 
-	err = 0;
+				printk(KERN_DEBUG "GRED: DP %u does not have a prio "
+				       "setting default to %d\n", ctl->DP, def_prio);
 
-errout_locked:
-	sch_tree_unlock(sch);
-errout:
-	return err;
+				prio = def_prio;
+			} else
+				prio = ctl->prio;
+		}
+
+		sch_tree_lock(sch);
+
+		gred_change_vq(sch, ctl->DP, ctl, prio, stab);
+
+		if (gred_rio_mode(table)) {
+			gred_disable_wred_mode(table);
+			if (gred_wred_mode_check(sch))
+				gred_enable_wred_mode(table);
+		}
+
+		sch_tree_unlock(sch);
+	}
+}
+
+static void gred_cancel_change(struct Qdisc *sch, struct nlattr *opt)
+{
 }
 
 static int gred_init(struct Qdisc *sch, struct nlattr *opt)
@@ -510,7 +535,13 @@ static int gred_init(struct Qdisc *sch, struct nlattr *opt)
 	if (tb[TCA_GRED_PARMS] || tb[TCA_GRED_STAB])
 		return -EINVAL;
 
-	return gred_change_table_def(sch, tb[TCA_GRED_DPS]);
+	if (!tb[TCA_GRED_DPS])
+		return -EINVAL;
+
+	err = gred_validate_table_def(nla_data(tb[TCA_GRED_DPS]));
+	if (!err)
+		gred_change_table_def(sch, tb[TCA_GRED_DPS]);
+	return err;
 }
 
 static int gred_dump(struct Qdisc *sch, struct sk_buff *skb)
@@ -607,7 +638,9 @@ static struct Qdisc_ops gred_qdisc_ops __read_mostly = {
 	.init		=	gred_init,
 	.reset		=	gred_reset,
 	.destroy	=	gred_destroy,
-	.change		=	gred_change,
+	.validate_change=	gred_validate_change,
+	.commit_change	=	gred_commit_change,
+	.cancel_change	=	gred_cancel_change,
 	.dump		=	gred_dump,
 	.owner		=	THIS_MODULE,
 };
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 59be192..5025de6 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1479,21 +1479,25 @@ hfsc_init_qdisc(struct Qdisc *sch, struct nlattr *opt)
 	return 0;
 }
 
-static int
-hfsc_change_qdisc(struct Qdisc *sch, struct nlattr *opt)
+static int hfsc_validate_change_qdisc(struct Qdisc *sch, struct nlattr *opt)
 {
-	struct hfsc_sched *q = qdisc_priv(sch);
-	struct tc_hfsc_qopt *qopt;
-
-	if (opt == NULL || nla_len(opt) < sizeof(*qopt))
+	if (nla_len(opt) < sizeof(struct tc_hfsc_qopt))
 		return -EINVAL;
-	qopt = nla_data(opt);
+	return 0;
+}
+
+static void hfsc_commit_change_qdisc(struct Qdisc *sch, struct nlattr *opt)
+{
+	struct tc_hfsc_qopt *qopt = nla_data(opt);
+	struct hfsc_sched *q = qdisc_priv(sch);
 
 	sch_tree_lock(sch);
 	q->defcls = qopt->defcls;
 	sch_tree_unlock(sch);
+}
 
-	return 0;
+static void hfsc_cancel_change_qdisc(struct Qdisc *sch, struct nlattr *opt)
+{
 }
 
 static void
@@ -1748,7 +1752,9 @@ static const struct Qdisc_class_ops hfsc_class_ops = {
 static struct Qdisc_ops hfsc_qdisc_ops __read_mostly = {
 	.id		= "hfsc",
 	.init		= hfsc_init_qdisc,
-	.change		= hfsc_change_qdisc,
+	.validate_change= hfsc_validate_change_qdisc,
+	.commit_change	= hfsc_commit_change_qdisc,
+	.cancel_change	= hfsc_cancel_change_qdisc,
 	.reset		= hfsc_reset_qdisc,
 	.destroy	= hfsc_destroy_qdisc,
 	.dump		= hfsc_dump_qdisc,
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 292129d..186b10b 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1586,7 +1586,6 @@ static struct Qdisc_ops htb_qdisc_ops __read_mostly = {
 	.init		=	htb_init,
 	.reset		=	htb_reset,
 	.destroy	=	htb_destroy,
-	.change		=	NULL /* htb_change */,
 	.dump		=	htb_dump,
 	.owner		=	THIS_MODULE,
 };
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 180c1e4..50ec903 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -75,6 +75,8 @@ struct netem_sched_data {
 		u32  size;
 		s16 table[0];
 	} *delay_dist;
+
+	void *delay_dist_pending;
 };
 
 /* Time stamp put into socket buffer control block */
@@ -314,13 +316,12 @@ static void netem_reset(struct Qdisc *sch)
  * Distribution data is a variable size payload containing
  * signed 16 bit values.
  */
-static int get_dist_table(struct Qdisc *sch, const struct nlattr *attr)
+static int validate_dist_table(struct Qdisc *sch, const struct nlattr *attr)
 {
+	unsigned long i, n = nla_len(attr)/sizeof(__s16);
 	struct netem_sched_data *q = qdisc_priv(sch);
-	unsigned long n = nla_len(attr)/sizeof(__s16);
 	const __s16 *data = nla_data(attr);
 	struct disttable *d;
-	int i;
 
 	if (n > 65536)
 		return -EINVAL;
@@ -333,15 +334,29 @@ static int get_dist_table(struct Qdisc *sch, const struct nlattr *attr)
 	for (i = 0; i < n; i++)
 		d->table[i] = data[i];
 
+	q->delay_dist_pending = d;
+
+	return 0;
+}
+
+static void commit_dist_table(struct Qdisc *sch, const struct nlattr *attr)
+{
+	struct netem_sched_data *q = qdisc_priv(sch);
+	struct disttable *d;
+
 	spin_lock_bh(&sch->dev_queue->lock);
+
+	d = q->delay_dist_pending;
+	q->delay_dist_pending = NULL;
+
 	d = xchg(&q->delay_dist, d);
+
 	spin_unlock_bh(&sch->dev_queue->lock);
 
 	kfree(d);
-	return 0;
 }
 
-static int get_correlation(struct Qdisc *sch, const struct nlattr *attr)
+static void commit_correlation(struct Qdisc *sch, const struct nlattr *attr)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
 	const struct tc_netem_corr *c = nla_data(attr);
@@ -349,27 +364,24 @@ static int get_correlation(struct Qdisc *sch, const struct nlattr *attr)
 	init_crandom(&q->delay_cor, c->delay_corr);
 	init_crandom(&q->loss_cor, c->loss_corr);
 	init_crandom(&q->dup_cor, c->dup_corr);
-	return 0;
 }
 
-static int get_reorder(struct Qdisc *sch, const struct nlattr *attr)
+static void commit_reorder(struct Qdisc *sch, const struct nlattr *attr)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
 	const struct tc_netem_reorder *r = nla_data(attr);
 
 	q->reorder = r->probability;
 	init_crandom(&q->reorder_cor, r->correlation);
-	return 0;
 }
 
-static int get_corrupt(struct Qdisc *sch, const struct nlattr *attr)
+static void commit_corrupt(struct Qdisc *sch, const struct nlattr *attr)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
 	const struct tc_netem_corrupt *r = nla_data(attr);
 
 	q->corrupt = r->probability;
 	init_crandom(&q->corrupt_cor, r->correlation);
-	return 0;
 }
 
 static const struct nla_policy netem_policy[TCA_NETEM_MAX + 1] = {
@@ -379,27 +391,46 @@ static const struct nla_policy netem_policy[TCA_NETEM_MAX + 1] = {
 };
 
 /* Parse netlink message to set options */
-static int netem_change(struct Qdisc *sch, struct nlattr *opt)
+static int netem_validate_change(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
 	struct nlattr *tb[TCA_NETEM_MAX + 1];
 	struct tc_netem_qopt *qopt;
-	int ret;
-
-	if (opt == NULL)
-		return -EINVAL;
+	int err;
 
-	ret = nla_parse_nested_compat(tb, TCA_NETEM_MAX, opt, netem_policy,
+	err = nla_parse_nested_compat(tb, TCA_NETEM_MAX, opt, netem_policy,
 				      qopt, sizeof(*qopt));
-	if (ret < 0)
-		return ret;
+	if (err < 0)
+		return err;
 
-	ret = fifo_set_limit(q->qdisc, qopt->limit);
-	if (ret) {
-		pr_debug("netem: can't set fifo limit\n");
-		return ret;
+	err = fifo_validate_limit(q->qdisc, qopt->limit);
+	if (err)
+		return err;
+
+	if (tb[TCA_NETEM_DELAY_DIST]) {
+		err = validate_dist_table(sch, tb[TCA_NETEM_DELAY_DIST]);
+		if (err < 0)
+			return err;
+	}
+	return 0;
+}
+
+static void netem_commit_change(struct Qdisc *sch, struct nlattr *opt)
+{
+	struct netem_sched_data *q = qdisc_priv(sch);
+	struct nlattr *tb[TCA_NETEM_MAX + 1];
+	struct tc_netem_qopt *qopt;
+	int err;
+
+	err = nla_parse_nested_compat(tb, TCA_NETEM_MAX, opt, netem_policy,
+				      qopt, sizeof(*qopt));
+	if (err < 0) {
+		WARN_ON(1);
+		return;
 	}
 
+	fifo_commit_limit(q->qdisc, qopt->limit);
+
 	q->latency = qopt->latency;
 	q->jitter = qopt->jitter;
 	q->limit = qopt->limit;
@@ -414,31 +445,27 @@ static int netem_change(struct Qdisc *sch, struct nlattr *opt)
 	if (q->gap)
 		q->reorder = ~0;
 
-	if (tb[TCA_NETEM_CORR]) {
-		ret = get_correlation(sch, tb[TCA_NETEM_CORR]);
-		if (ret)
-			return ret;
-	}
+	if (tb[TCA_NETEM_CORR])
+		commit_correlation(sch, tb[TCA_NETEM_CORR]);
 
-	if (tb[TCA_NETEM_DELAY_DIST]) {
-		ret = get_dist_table(sch, tb[TCA_NETEM_DELAY_DIST]);
-		if (ret)
-			return ret;
-	}
+	if (tb[TCA_NETEM_DELAY_DIST])
+		commit_dist_table(sch, tb[TCA_NETEM_DELAY_DIST]);
 
-	if (tb[TCA_NETEM_REORDER]) {
-		ret = get_reorder(sch, tb[TCA_NETEM_REORDER]);
-		if (ret)
-			return ret;
-	}
+	if (tb[TCA_NETEM_REORDER])
+		commit_reorder(sch, tb[TCA_NETEM_REORDER]);
 
-	if (tb[TCA_NETEM_CORRUPT]) {
-		ret = get_corrupt(sch, tb[TCA_NETEM_CORRUPT]);
-		if (ret)
-			return ret;
-	}
+	if (tb[TCA_NETEM_CORRUPT])
+		commit_corrupt(sch, tb[TCA_NETEM_CORRUPT]);
+}
 
-	return 0;
+static void netem_cancel_change(struct Qdisc *sch, struct nlattr *opt)
+{
+	struct netem_sched_data *q = qdisc_priv(sch);
+
+	if (q->delay_dist_pending) {
+		kfree(q->delay_dist_pending);
+		q->delay_dist_pending = NULL;
+	}
 }
 
 /*
@@ -484,21 +511,35 @@ static int tfifo_enqueue(struct sk_buff *nskb, struct Qdisc *sch)
 	return qdisc_reshape_fail(nskb, sch);
 }
 
-static int tfifo_init(struct Qdisc *sch, struct nlattr *opt)
+static int tfifo_validate(struct Qdisc *sch, struct nlattr *opt)
+{
+	if (opt && nla_len(opt) < sizeof(struct tc_fifo_qopt))
+		return -EINVAL;
+
+	return 0;
+}
+
+static void tfifo_commit(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct fifo_sched_data *q = qdisc_priv(sch);
 
 	if (opt) {
 		struct tc_fifo_qopt *ctl = nla_data(opt);
-		if (nla_len(opt) < sizeof(*ctl))
-			return -EINVAL;
 
 		q->limit = ctl->limit;
 	} else
 		q->limit = max_t(u32, qdisc_dev(sch)->tx_queue_len, 1);
 
 	q->oldest = PSCHED_PASTPERFECT;
-	return 0;
+}
+
+static int tfifo_init(struct Qdisc *sch, struct nlattr *opt)
+{
+	int err = tfifo_validate(sch, opt);
+
+	if (!err)
+		tfifo_commit(sch, opt);
+	return err;
 }
 
 static int tfifo_dump(struct Qdisc *sch, struct sk_buff *skb)
@@ -522,7 +563,8 @@ static struct Qdisc_ops tfifo_qdisc_ops __read_mostly = {
 	.drop		=	qdisc_queue_drop,
 	.init		=	tfifo_init,
 	.reset		=	qdisc_reset_queue,
-	.change		=	tfifo_init,
+	.validate_change=	tfifo_validate,
+	.commit_change	=	tfifo_commit,
 	.dump		=	tfifo_dump,
 };
 
@@ -544,7 +586,10 @@ static int netem_init(struct Qdisc *sch, struct nlattr *opt)
 		return -ENOMEM;
 	}
 
-	ret = netem_change(sch, opt);
+	ret = netem_validate_change(sch, opt);
+	if (!ret)
+		netem_commit_change(sch, opt);
+
 	if (ret) {
 		pr_debug("netem: change failed\n");
 		qdisc_destroy(q->qdisc);
@@ -710,7 +755,9 @@ static struct Qdisc_ops netem_qdisc_ops __read_mostly = {
 	.init		=	netem_init,
 	.reset		=	netem_reset,
 	.destroy	=	netem_destroy,
-	.change		=	netem_change,
+	.validate_change=	netem_validate_change,
+	.commit_change	=	netem_commit_change,
+	.cancel_change	=	netem_cancel_change,
 	.dump		=	netem_dump,
 	.owner		=	THIS_MODULE,
 };
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index ba3b261..42f4cf9 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -27,6 +27,8 @@ struct prio_sched_data
 	struct tcf_proto *filter_list;
 	u8  prio2band[TC_PRIO_MAX+1];
 	struct Qdisc *queues[TCQ_PRIO_BANDS];
+
+	struct Qdisc *pending_queues[TCQ_PRIO_BANDS];
 };
 
 
@@ -175,57 +177,111 @@ prio_destroy(struct Qdisc* sch)
 		qdisc_destroy(q->queues[prio]);
 }
 
-static int prio_tune(struct Qdisc *sch, struct nlattr *opt)
+static int prio_validate_change(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct prio_sched_data *q = qdisc_priv(sch);
 	struct tc_prio_qopt *qopt;
-	int i;
+	int i, j;
 
 	if (nla_len(opt) < sizeof(*qopt))
 		return -EINVAL;
-	qopt = nla_data(opt);
 
+	qopt = nla_data(opt);
 	if (qopt->bands > TCQ_PRIO_BANDS || qopt->bands < 2)
 		return -EINVAL;
 
-	for (i=0; i<=TC_PRIO_MAX; i++) {
+	for (i = 0; i <= TC_PRIO_MAX; i++) {
 		if (qopt->priomap[i] >= qopt->bands)
 			return -EINVAL;
 	}
 
-	sch_tree_lock(sch);
+	for (i = 0; i < qopt->bands; i++) {
+		if (q->queues[i] == &noop_qdisc) {
+			struct Qdisc *child;
+
+			child = qdisc_create_dflt(qdisc_dev(sch),
+						  sch->dev_queue,
+						  &pfifo_qdisc_ops,
+						  TC_H_MAKE(sch->handle, i + 1));
+			if (!child)
+				goto unwind;
+
+			q->pending_queues[i] = child;
+		}
+	}
+	return 0;
+
+unwind:
+	for (j = 0; j < i; j++) {
+		struct Qdisc *child = q->pending_queues[i];
+
+		if (child) {
+			qdisc_destroy(child);
+			q->pending_queues[i] = NULL;
+		}
+	}
+	return -ENOMEM;
+}
+
+static void prio_commit_change(struct Qdisc *sch, struct nlattr *opt)
+{
+	struct prio_sched_data *q = qdisc_priv(sch);
+	struct tc_prio_qopt *qopt = nla_data(opt);
+	int i;
+
+	spin_lock_bh(&sch->dev_queue->lock);
+
 	q->bands = qopt->bands;
 	memcpy(q->prio2band, qopt->priomap, TC_PRIO_MAX+1);
 
-	for (i=q->bands; i<TCQ_PRIO_BANDS; i++) {
+	/* Relase all of the band slow qdiscs which will no longer
+	 * be in the range 0 --> q->bands.
+	 */
+	for (i = q->bands; i < TCQ_PRIO_BANDS; i++) {
 		struct Qdisc *child = xchg(&q->queues[i], &noop_qdisc);
 		if (child != &noop_qdisc) {
 			qdisc_tree_decrease_qlen(child, child->q.qlen);
 			qdisc_destroy(child);
 		}
 	}
-	sch_tree_unlock(sch);
 
-	for (i=0; i<q->bands; i++) {
+	/* Now attach the newly active band qdiscs we allocated during
+	 * validation.
+	 */
+	for (i = 0; i < q->bands; i++) {
 		if (q->queues[i] == &noop_qdisc) {
-			struct Qdisc *child;
-			child = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
-						  &pfifo_qdisc_ops,
-						  TC_H_MAKE(sch->handle, i + 1));
-			if (child) {
-				sch_tree_lock(sch);
-				child = xchg(&q->queues[i], child);
-
-				if (child != &noop_qdisc) {
-					qdisc_tree_decrease_qlen(child,
-								 child->q.qlen);
-					qdisc_destroy(child);
-				}
-				sch_tree_unlock(sch);
+			struct Qdisc *child = q->pending_queues[i];
+
+			BUG_ON(!child);
+
+			q->pending_queues[i] = NULL;
+
+			child = xchg(&q->queues[i], child);
+
+			if (child != &noop_qdisc) {
+				qdisc_tree_decrease_qlen(child,
+							 child->q.qlen);
+				qdisc_destroy(child);
 			}
 		}
 	}
-	return 0;
+
+	spin_unlock_bh(&sch->dev_queue->lock);
+}
+
+static void prio_cancel_change(struct Qdisc *sch, struct nlattr *opt)
+{
+	struct prio_sched_data *q = qdisc_priv(sch);
+	int i;
+
+	for (i = 0; i < TCQ_PRIO_BANDS; i++) {
+		struct Qdisc *child = q->pending_queues[i];
+
+		if (child) {
+			q->pending_queues[i] = NULL;
+			qdisc_destroy(child);
+		}
+	}
 }
 
 static int prio_init(struct Qdisc *sch, struct nlattr *opt)
@@ -241,8 +297,10 @@ static int prio_init(struct Qdisc *sch, struct nlattr *opt)
 	} else {
 		int err;
 
-		if ((err= prio_tune(sch, opt)) != 0)
-			return err;
+		err = prio_validate_change(sch, opt);
+		if (!err)
+			prio_commit_change(sch, opt);
+		return err;
 	}
 	return 0;
 }
@@ -441,7 +499,9 @@ static struct Qdisc_ops prio_qdisc_ops __read_mostly = {
 	.init		=	prio_init,
 	.reset		=	prio_reset,
 	.destroy	=	prio_destroy,
-	.change		=	prio_tune,
+	.validate_change=	prio_validate_change,
+	.commit_change	=	prio_commit_change,
+	.cancel_change	=	prio_cancel_change,
 	.dump		=	prio_dump,
 	.owner		=	THIS_MODULE,
 };
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index c106e0e..4844865 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -43,6 +43,7 @@ struct red_sched_data
 	struct red_parms	parms;
 	struct red_stats	stats;
 	struct Qdisc		*qdisc;
+	struct Qdisc		*pending_child;
 };
 
 static inline int red_use_ecn(struct red_sched_data *q)
@@ -179,58 +180,99 @@ static const struct nla_policy red_policy[TCA_RED_MAX + 1] = {
 	[TCA_RED_STAB]	= { .len = RED_STAB_SIZE },
 };
 
-static int red_change(struct Qdisc *sch, struct nlattr *opt)
+static int red_validate_change(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct red_sched_data *q = qdisc_priv(sch);
 	struct nlattr *tb[TCA_RED_MAX + 1];
-	struct tc_red_qopt *ctl;
 	struct Qdisc *child = NULL;
+	struct tc_red_qopt *ctl;
 	int err;
 
-	if (opt == NULL)
-		return -EINVAL;
-
 	err = nla_parse_nested(tb, TCA_RED_MAX, opt, red_policy);
 	if (err < 0)
 		return err;
 
-	if (tb[TCA_RED_PARMS] == NULL ||
-	    tb[TCA_RED_STAB] == NULL)
+	if (!tb[TCA_RED_PARMS] || !tb[TCA_RED_STAB])
 		return -EINVAL;
 
 	ctl = nla_data(tb[TCA_RED_PARMS]);
-
 	if (ctl->limit > 0) {
 		child = fifo_create_dflt(sch, &bfifo_qdisc_ops, ctl->limit);
 		if (IS_ERR(child))
 			return PTR_ERR(child);
 	}
+	q->pending_child = child;
+
+	return 0;
+}
+
+static void red_commit_change(struct Qdisc *sch, struct nlattr *opt)
+{
+	struct red_sched_data *q = qdisc_priv(sch);
+	struct nlattr *tb[TCA_RED_MAX + 1];
+	struct tc_red_qopt *ctl;
+	int err;
+
+	err = nla_parse_nested(tb, TCA_RED_MAX, opt, red_policy);
+	if (err < 0) {
+		WARN_ON(1);
+		if (q->pending_child) {
+			qdisc_destroy(q->pending_child);
+			q->pending_child = NULL;
+		}
+		return;
+	}
+
+	ctl = nla_data(tb[TCA_RED_PARMS]);
 
 	sch_tree_lock(sch);
+
 	q->flags = ctl->flags;
 	q->limit = ctl->limit;
-	if (child) {
+	if (q->pending_child) {
+		struct Qdisc *child = q->pending_child;
+
+		q->pending_child = NULL;
+
 		qdisc_tree_decrease_qlen(q->qdisc, q->qdisc->q.qlen);
 		qdisc_destroy(xchg(&q->qdisc, child));
 	}
 
 	red_set_parms(&q->parms, ctl->qth_min, ctl->qth_max, ctl->Wlog,
-				 ctl->Plog, ctl->Scell_log,
-				 nla_data(tb[TCA_RED_STAB]));
+		      ctl->Plog, ctl->Scell_log,
+		      nla_data(tb[TCA_RED_STAB]));
 
 	if (skb_queue_empty(&sch->q))
 		red_end_of_idle_period(&q->parms);
 
 	sch_tree_unlock(sch);
-	return 0;
+}
+
+static void red_cancel_change(struct Qdisc *sch, struct nlattr *opt)
+{
+	struct red_sched_data *q = qdisc_priv(sch);
+
+	if (q->pending_child) {
+		qdisc_destroy(q->pending_child);
+		q->pending_child = NULL;
+	}
 }
 
 static int red_init(struct Qdisc* sch, struct nlattr *opt)
 {
 	struct red_sched_data *q = qdisc_priv(sch);
+	int err;
 
 	q->qdisc = &noop_qdisc;
-	return red_change(sch, opt);
+
+	if (!opt)
+		return -EINVAL;
+
+	err = red_validate_change(sch, opt);
+	if (!err)
+		red_commit_change(sch, opt);
+
+	return err;
 }
 
 static int red_dump(struct Qdisc *sch, struct sk_buff *skb)
@@ -379,7 +421,9 @@ static struct Qdisc_ops red_qdisc_ops __read_mostly = {
 	.init		=	red_init,
 	.reset		=	red_reset,
 	.destroy	=	red_destroy,
-	.change		=	red_change,
+	.validate_change=	red_validate_change,
+	.commit_change	=	red_commit_change,
+	.cancel_change	=	red_cancel_change,
 	.dump		=	red_dump,
 	.dump_stats	=	red_dump_stats,
 	.owner		=	THIS_MODULE,
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 8458f63..a52ca74 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -629,7 +629,6 @@ static struct Qdisc_ops sfq_qdisc_ops __read_mostly = {
 	.init		=	sfq_init,
 	.reset		=	sfq_reset,
 	.destroy	=	sfq_destroy,
-	.change		=	NULL,
 	.dump		=	sfq_dump,
 	.owner		=	THIS_MODULE,
 };
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 1afea06..1f34488 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -113,6 +113,11 @@ struct tbf_sched_data
 	psched_time_t	t_c;		/* Time check-point */
 	struct Qdisc	*qdisc;		/* Inner qdisc, default - bfifo queue */
 	struct qdisc_watchdog watchdog;	/* Watchdog timer */
+
+	struct qdisc_rate_table *pending_rtab;
+	struct qdisc_rate_table *pending_ptab;
+	struct Qdisc *pending_child;
+	int pending_max_size;
 };
 
 #define L2T(q,L)   qdisc_l2t((q)->R_tab,L)
@@ -248,59 +253,108 @@ static const struct nla_policy tbf_policy[TCA_TBF_MAX + 1] = {
 	[TCA_TBF_PTAB]	= { .type = NLA_BINARY, .len = TC_RTAB_SIZE },
 };
 
-static int tbf_change(struct Qdisc* sch, struct nlattr *opt)
+static int tbf_validate_change(struct Qdisc *sch, struct nlattr *opt)
 {
-	int err;
 	struct tbf_sched_data *q = qdisc_priv(sch);
 	struct nlattr *tb[TCA_TBF_PTAB + 1];
-	struct tc_tbf_qopt *qopt;
 	struct qdisc_rate_table *rtab = NULL;
 	struct qdisc_rate_table *ptab = NULL;
 	struct Qdisc *child = NULL;
-	int max_size,n;
+	struct tc_tbf_qopt *qopt;
+	int err, n, max_size;
 
 	err = nla_parse_nested(tb, TCA_TBF_PTAB, opt, tbf_policy);
 	if (err < 0)
 		return err;
 
-	err = -EINVAL;
-	if (tb[TCA_TBF_PARMS] == NULL)
-		goto done;
+	if (!tb[TCA_TBF_PARMS])
+		return -EINVAL;
 
 	qopt = nla_data(tb[TCA_TBF_PARMS]);
+
+	err = -EINVAL;
 	rtab = qdisc_get_rtab(&qopt->rate, tb[TCA_TBF_RTAB]);
-	if (rtab == NULL)
-		goto done;
+	if (!rtab)
+		goto drop_rtabs;
 
 	if (qopt->peakrate.rate) {
 		if (qopt->peakrate.rate > qopt->rate.rate)
 			ptab = qdisc_get_rtab(&qopt->peakrate, tb[TCA_TBF_PTAB]);
 		if (ptab == NULL)
-			goto done;
+			goto drop_rtabs;
 	}
 
-	for (n = 0; n < 256; n++)
-		if (rtab->data[n] > qopt->buffer) break;
-	max_size = (n << qopt->rate.cell_log)-1;
+	for (n = 0; n < 256; n++) {
+		if (rtab->data[n] > qopt->buffer)
+			break;
+	}
+	max_size = (n << qopt->rate.cell_log) - 1;
 	if (ptab) {
 		int size;
 
-		for (n = 0; n < 256; n++)
-			if (ptab->data[n] > qopt->mtu) break;
-		size = (n << qopt->peakrate.cell_log)-1;
-		if (size < max_size) max_size = size;
+		for (n = 0; n < 256; n++) {
+			if (ptab->data[n] > qopt->mtu)
+				break;
+		}
+		size = (n << qopt->peakrate.cell_log) - 1;
+		if (size < max_size)
+			max_size = size;
 	}
 	if (max_size < 0)
-		goto done;
+		goto drop_rtabs;
 
 	if (qopt->limit > 0) {
 		child = fifo_create_dflt(sch, &bfifo_qdisc_ops, qopt->limit);
 		if (IS_ERR(child)) {
 			err = PTR_ERR(child);
-			goto done;
+			goto drop_rtabs;
 		}
 	}
 
+	q->pending_rtab = rtab;
+	q->pending_ptab = ptab;
+	q->pending_child = child;
+	q->pending_max_size = max_size;
+
+	return 0;
+
+drop_rtabs:
+	if (rtab)
+		qdisc_put_rtab(rtab);
+	if (ptab)
+		qdisc_put_rtab(ptab);
+	return err;
+}
+
+static void tbf_commit_change(struct Qdisc *sch, struct nlattr *opt)
+{
+	struct tbf_sched_data *q = qdisc_priv(sch);
+	struct nlattr *tb[TCA_TBF_PTAB + 1];
+	struct qdisc_rate_table *rtab;
+	struct qdisc_rate_table *ptab;
+	struct Qdisc *child;
+	struct tc_tbf_qopt *qopt;
+	int err, max_size;
+
+	err = nla_parse_nested(tb, TCA_TBF_PTAB, opt, tbf_policy);
+	if (err < 0) {
+		WARN_ON(1);
+		return;
+	}
+
+	qopt = nla_data(tb[TCA_TBF_PARMS]);
+
+	rtab = q->pending_rtab;
+	q->pending_rtab = NULL;
+
+	ptab = q->pending_ptab;
+	q->pending_ptab = NULL;
+
+	child = q->pending_child;
+	q->pending_child = NULL;
+
+	max_size = q->pending_max_size;
+
 	sch_tree_lock(sch);
 	if (child) {
 		qdisc_tree_decrease_qlen(q->qdisc, q->qdisc->q.qlen);
@@ -315,18 +369,35 @@ static int tbf_change(struct Qdisc* sch, struct nlattr *opt)
 	rtab = xchg(&q->R_tab, rtab);
 	ptab = xchg(&q->P_tab, ptab);
 	sch_tree_unlock(sch);
-	err = 0;
-done:
+
 	if (rtab)
 		qdisc_put_rtab(rtab);
 	if (ptab)
 		qdisc_put_rtab(ptab);
-	return err;
+}
+
+static void tbf_cancel_change(struct Qdisc *sch, struct nlattr *opt)
+{
+	struct tbf_sched_data *q = qdisc_priv(sch);
+
+	if (q->pending_rtab) {
+		qdisc_put_rtab(q->pending_rtab);
+		q->pending_rtab = NULL;
+	}
+	if (q->pending_ptab) {
+		qdisc_put_rtab(q->pending_ptab);
+		q->pending_ptab = NULL;
+	}
+	if (q->pending_child) {
+		qdisc_destroy(q->pending_child);
+		q->pending_child = NULL;
+	}
 }
 
 static int tbf_init(struct Qdisc* sch, struct nlattr *opt)
 {
 	struct tbf_sched_data *q = qdisc_priv(sch);
+	int err;
 
 	if (opt == NULL)
 		return -EINVAL;
@@ -335,7 +406,11 @@ static int tbf_init(struct Qdisc* sch, struct nlattr *opt)
 	qdisc_watchdog_init(&q->watchdog, sch);
 	q->qdisc = &noop_qdisc;
 
-	return tbf_change(sch, opt);
+	err = tbf_validate_change(sch, opt);
+	if (!err)
+		tbf_commit_change(sch, opt);
+
+	return err;
 }
 
 static void tbf_destroy(struct Qdisc *sch)
@@ -491,7 +566,9 @@ static struct Qdisc_ops tbf_qdisc_ops __read_mostly = {
 	.init		=	tbf_init,
 	.reset		=	tbf_reset,
 	.destroy	=	tbf_destroy,
-	.change		=	tbf_change,
+	.validate_change=	tbf_validate_change,
+	.commit_change	=	tbf_commit_change,
+	.cancel_change	=	tbf_cancel_change,
 	.dump		=	tbf_dump,
 	.owner		=	THIS_MODULE,
 };
-- 
1.5.6.2.255.gbed62

