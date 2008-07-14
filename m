From: David Miller <davem@davemloft.net>
Subject: [PATCH 12/14]: pkt_sched: Make Qdisc_class_ops->delete()
 validate+commit.
Date: Mon, 14 Jul 2008 16:00:29 -0700 (PDT)
Message-ID: <20080714.160029.128415599.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49279
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758561AbYGNXAb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 19:00:31 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id BDA1AC8C187
	for <netdev@vger.kernel.org>; Mon, 14 Jul 2008 16:00:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is necessary to allow delete operations to become multiqueue
aware.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/sch_generic.h |    7 +++++--
 net/sched/sch_api.c       |    6 ++++--
 net/sched/sch_atm.c       |   14 +++++++++-----
 net/sched/sch_cbq.c       |   18 ++++++++++++------
 net/sched/sch_dsmark.c    |   13 +++++++++----
 net/sched/sch_hfsc.c      |   16 +++++++++++-----
 net/sched/sch_htb.c       |   29 ++++++++++++++++++-----------
 net/sched/sch_netem.c     |    9 +++++++--
 net/sched/sch_prio.c      |    8 ++++++--
 net/sched/sch_red.c       |   10 ++++++++--
 net/sched/sch_tbf.c       |   10 ++++++++--
 11 files changed, 97 insertions(+), 43 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 150ecd0..b17dece 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -70,8 +70,11 @@ struct Qdisc_class_ops
 	unsigned long		(*get)(struct Qdisc *, u32 classid);
 	void			(*put)(struct Qdisc *, unsigned long);
 	int			(*change)(struct Qdisc *, u32, u32,
-					struct nlattr **, unsigned long *);
-	int			(*delete)(struct Qdisc *, unsigned long);
+					  struct nlattr **, unsigned long *);
+	int			(*validate_delete)(struct Qdisc *,
+						   unsigned long);
+	void			(*commit_delete)(struct Qdisc *,
+						 unsigned long);
 	void			(*walk)(struct Qdisc *, struct qdisc_walker * arg);
 
 	/* Filter manipulation */
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 8473719..5230d2d 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1594,9 +1594,11 @@ static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 				goto out;
 			break;
 		case RTM_DELTCLASS:
-			err = cops->delete(q, cl);
-			if (err == 0)
+			err = cops->validate_delete(q, cl);
+			if (!err) {
+				cops->commit_delete(q, cl);
 				tclass_notify(skb, n, q, cl, RTM_DELTCLASS);
+			}
 			goto out;
 		case RTM_GETTCLASS:
 			err = tclass_notify(skb, n, q, cl, RTM_NEWTCLASS);
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index c084050..c240275 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -339,12 +339,11 @@ err_out:
 	return error;
 }
 
-static int atm_tc_delete(struct Qdisc *sch, unsigned long arg)
+static int atm_tc_validate_delete(struct Qdisc *sch, unsigned long arg)
 {
+	struct atm_flow_data *flow = (struct atm_flow_data *) arg;
 	struct atm_qdisc_data *p = qdisc_priv(sch);
-	struct atm_flow_data *flow = (struct atm_flow_data *)arg;
 
-	pr_debug("atm_tc_delete(sch %p,[qdisc %p],flow %p)\n", sch, p, flow);
 	if (!find_flow(qdisc_priv(sch), flow))
 		return -EINVAL;
 	if (flow->filter_list || flow == &p->link)
@@ -359,10 +358,14 @@ static int atm_tc_delete(struct Qdisc *sch, unsigned long arg)
 	}
 	if (flow->ref > 2)
 		return -EBUSY;	/* catch references via excess, etc. */
-	atm_tc_put(sch, arg);
 	return 0;
 }
 
+static void atm_tc_commit_delete(struct Qdisc *sch, unsigned long arg)
+{
+	atm_tc_put(sch, arg);
+}
+
 static void atm_tc_walk(struct Qdisc *sch, struct qdisc_walker *walker)
 {
 	struct atm_qdisc_data *p = qdisc_priv(sch);
@@ -691,7 +694,8 @@ static const struct Qdisc_class_ops atm_class_ops = {
 	.get		= atm_tc_get,
 	.put		= atm_tc_put,
 	.change		= atm_tc_change,
-	.delete		= atm_tc_delete,
+	.validate_delete= atm_tc_validate_delete,
+	.commit_delete	= atm_tc_commit_delete,
 	.walk		= atm_tc_walk,
 	.tcf_chain	= atm_tc_find_tcf,
 	.bind_tcf	= atm_tc_bind_filter,
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 2c9895a..7138a04 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -1944,14 +1944,21 @@ failure:
 	return err;
 }
 
-static int cbq_delete(struct Qdisc *sch, unsigned long arg)
+static int cbq_validate_delete(struct Qdisc *sch, unsigned long arg)
 {
+	struct cbq_class *cl = (struct cbq_class*) arg;
 	struct cbq_sched_data *q = qdisc_priv(sch);
-	struct cbq_class *cl = (struct cbq_class*)arg;
-	unsigned int qlen;
 
 	if (cl->filters || cl->children || cl == &q->link)
 		return -EBUSY;
+	return 0;
+}
+
+static void cbq_commit_delete(struct Qdisc *sch, unsigned long arg)
+{
+	struct cbq_class *cl = (struct cbq_class*) arg;
+	struct cbq_sched_data *q = qdisc_priv(sch);
+	unsigned int qlen;
 
 	sch_tree_lock(sch);
 
@@ -1983,8 +1990,6 @@ static int cbq_delete(struct Qdisc *sch, unsigned long arg)
 
 	if (--cl->refcnt == 0)
 		cbq_destroy_class(sch, cl);
-
-	return 0;
 }
 
 static struct tcf_proto **cbq_find_tcf(struct Qdisc *sch, unsigned long arg)
@@ -2055,7 +2060,8 @@ static const struct Qdisc_class_ops cbq_class_ops = {
 	.get		=	cbq_get,
 	.put		=	cbq_put,
 	.change		=	cbq_change_class,
-	.delete		=	cbq_delete,
+	.validate_delete=	cbq_validate_delete,
+	.commit_delete	=	cbq_commit_delete,
 	.walk		=	cbq_walk,
 	.tcf_chain	=	cbq_find_tcf,
 	.bind_tcf	=	cbq_bind_filter,
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 85dec9b..03c8bcf 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -161,17 +161,21 @@ errout:
 	return err;
 }
 
-static int dsmark_delete(struct Qdisc *sch, unsigned long arg)
+static int dsmark_validate_delete(struct Qdisc *sch, unsigned long arg)
 {
 	struct dsmark_qdisc_data *p = qdisc_priv(sch);
 
 	if (!dsmark_valid_index(p, arg))
 		return -EINVAL;
+	return 0;
+}
+
+static void dsmark_commit_delete(struct Qdisc *sch, unsigned long arg)
+{
+	struct dsmark_qdisc_data *p = qdisc_priv(sch);
 
 	p->mask[arg-1] = 0xff;
 	p->value[arg-1] = 0;
-
-	return 0;
 }
 
 static void dsmark_walk(struct Qdisc *sch, struct qdisc_walker *walker)
@@ -495,7 +499,8 @@ static const struct Qdisc_class_ops dsmark_class_ops = {
 	.get		=	dsmark_get,
 	.put		=	dsmark_put,
 	.change		=	dsmark_change,
-	.delete		=	dsmark_delete,
+	.validate_delete=	dsmark_validate_delete,
+	.commit_delete	=	dsmark_commit_delete,
 	.walk		=	dsmark_walk,
 	.tcf_chain	=	dsmark_find_tcf,
 	.bind_tcf	=	dsmark_bind_filter,
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 5025de6..95a497e 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1121,14 +1121,20 @@ hfsc_destroy_class(struct Qdisc *sch, struct hfsc_class *cl)
 		kfree(cl);
 }
 
-static int
-hfsc_delete_class(struct Qdisc *sch, unsigned long arg)
+static int hfsc_validate_delete_class(struct Qdisc *sch, unsigned long arg)
 {
+	struct hfsc_class *cl = (struct hfsc_class *) arg;
 	struct hfsc_sched *q = qdisc_priv(sch);
-	struct hfsc_class *cl = (struct hfsc_class *)arg;
 
 	if (cl->level > 0 || cl->filter_cnt > 0 || cl == &q->root)
 		return -EBUSY;
+	return 0;
+}
+
+static void hfsc_commit_delete_class(struct Qdisc *sch, unsigned long arg)
+{
+	struct hfsc_class *cl = (struct hfsc_class *) arg;
+	struct hfsc_sched *q = qdisc_priv(sch);
 
 	sch_tree_lock(sch);
 
@@ -1142,7 +1148,6 @@ hfsc_delete_class(struct Qdisc *sch, unsigned long arg)
 		hfsc_destroy_class(sch, cl);
 
 	sch_tree_unlock(sch);
-	return 0;
 }
 
 static struct hfsc_class *
@@ -1733,7 +1738,8 @@ hfsc_drop(struct Qdisc *sch)
 
 static const struct Qdisc_class_ops hfsc_class_ops = {
 	.change		= hfsc_change_class,
-	.delete		= hfsc_delete_class,
+	.validate_delete= hfsc_validate_delete_class,
+	.commit_delete	= hfsc_commit_delete_class,
 	.prepare_graft	= hfsc_prepare_graft,
 	.commit_graft	= hfsc_commit_graft,
 	.cancel_graft	= hfsc_cancel_graft,
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 186b10b..a9cf7bb 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1263,19 +1263,26 @@ static void htb_destroy(struct Qdisc *sch)
 	__skb_queue_purge(&q->direct_queue);
 }
 
-static int htb_delete(struct Qdisc *sch, unsigned long arg)
+static int htb_validate_delete(struct Qdisc *sch, unsigned long arg)
 {
-	struct htb_sched *q = qdisc_priv(sch);
-	struct htb_class *cl = (struct htb_class *)arg;
-	unsigned int qlen;
-	struct Qdisc *new_q = NULL;
-	int last_child = 0;
+	struct htb_class *cl = (struct htb_class *) arg;
 
-	// TODO: why don't allow to delete subtree ? references ? does
-	// tc subsys quarantee us that in htb_destroy it holds no class
-	// refs so that we can remove children safely there ?
+	/* TODO: why don't allow to delete subtree? references? does
+	 * tc subsys quarantee us that in htb_destroy it holds no class
+	 * refs so that we can remove children safely there?
+	 */
 	if (cl->children || cl->filter_cnt)
 		return -EBUSY;
+	return 0;
+}
+
+static void htb_commit_delete(struct Qdisc *sch, unsigned long arg)
+{
+	struct htb_class *cl = (struct htb_class *) arg;
+	struct htb_sched *q = qdisc_priv(sch);
+	struct Qdisc *new_q = NULL;
+	int last_child = 0;
+	unsigned int qlen;
 
 	if (!cl->level && htb_parent_last_child(cl)) {
 		new_q = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
@@ -1309,7 +1316,6 @@ static int htb_delete(struct Qdisc *sch, unsigned long arg)
 		htb_destroy_class(sch, cl);
 
 	sch_tree_unlock(sch);
-	return 0;
 }
 
 static void htb_put(struct Qdisc *sch, unsigned long arg)
@@ -1565,7 +1571,8 @@ static const struct Qdisc_class_ops htb_class_ops = {
 	.get		=	htb_get,
 	.put		=	htb_put,
 	.change		=	htb_change_class,
-	.delete		=	htb_delete,
+	.validate_delete=	htb_validate_delete,
+	.commit_delete	=	htb_commit_delete,
 	.walk		=	htb_walk,
 	.tcf_chain	=	htb_find_tcf,
 	.bind_tcf	=	htb_bind_filter,
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 50ec903..ca8bcd4 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -708,11 +708,15 @@ static int netem_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 	return -ENOSYS;
 }
 
-static int netem_delete(struct Qdisc *sch, unsigned long arg)
+static int netem_validate_delete(struct Qdisc *sch, unsigned long arg)
 {
 	return -ENOSYS;
 }
 
+static void netem_commit_delete(struct Qdisc *sch, unsigned long arg)
+{
+}
+
 static void netem_walk(struct Qdisc *sch, struct qdisc_walker *walker)
 {
 	if (!walker->stop) {
@@ -738,7 +742,8 @@ static const struct Qdisc_class_ops netem_class_ops = {
 	.get		=	netem_get,
 	.put		=	netem_put,
 	.change		=	netem_change_class,
-	.delete		=	netem_delete,
+	.validate_delete=	netem_validate_delete,
+	.commit_delete	=	netem_commit_delete,
 	.walk		=	netem_walk,
 	.tcf_chain	=	netem_find_tcf,
 	.dump		=	netem_dump_class,
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 42f4cf9..25e07db 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -404,7 +404,7 @@ static int prio_change(struct Qdisc *sch, u32 handle, u32 parent, struct nlattr
 	return 0;
 }
 
-static int prio_delete(struct Qdisc *sch, unsigned long cl)
+static int prio_validate_delete(struct Qdisc *sch, unsigned long cl)
 {
 	struct prio_sched_data *q = qdisc_priv(sch);
 	if (cl - 1 > q->bands)
@@ -412,6 +412,9 @@ static int prio_delete(struct Qdisc *sch, unsigned long cl)
 	return 0;
 }
 
+static void prio_commit_delete(struct Qdisc *sch, unsigned long cl)
+{
+}
 
 static int prio_dump_class(struct Qdisc *sch, unsigned long cl, struct sk_buff *skb,
 			   struct tcmsg *tcm)
@@ -478,7 +481,8 @@ static const struct Qdisc_class_ops prio_class_ops = {
 	.get		=	prio_get,
 	.put		=	prio_put,
 	.change		=	prio_change,
-	.delete		=	prio_delete,
+	.validate_delete=	prio_validate_delete,
+	.commit_delete	=	prio_commit_delete,
 	.walk		=	prio_walk,
 	.tcf_chain	=	prio_find_tcf,
 	.bind_tcf	=	prio_bind,
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index 4844865..5ad4ed0 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -374,11 +374,16 @@ static int red_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 	return -ENOSYS;
 }
 
-static int red_delete(struct Qdisc *sch, unsigned long cl)
+static int red_validate_delete(struct Qdisc *sch, unsigned long cl)
 {
 	return -ENOSYS;
 }
 
+static void red_commit_delete(struct Qdisc *sch, unsigned long cl)
+{
+	WARN_ON(1);
+}
+
 static void red_walk(struct Qdisc *sch, struct qdisc_walker *walker)
 {
 	if (!walker->stop) {
@@ -404,7 +409,8 @@ static const struct Qdisc_class_ops red_class_ops = {
 	.get		=	red_get,
 	.put		=	red_put,
 	.change		=	red_change_class,
-	.delete		=	red_delete,
+	.validate_delete=	red_validate_delete,
+	.commit_delete	=	red_commit_delete,
 	.walk		=	red_walk,
 	.tcf_chain	=	red_find_tcf,
 	.dump		=	red_dump_class,
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 1f34488..f9de373 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -517,11 +517,16 @@ static int tbf_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 	return -ENOSYS;
 }
 
-static int tbf_delete(struct Qdisc *sch, unsigned long arg)
+static int tbf_validate_delete(struct Qdisc *sch, unsigned long arg)
 {
 	return -ENOSYS;
 }
 
+static void tbf_commit_delete(struct Qdisc *sch, unsigned long arg)
+{
+	WARN_ON(1);
+}
+
 static void tbf_walk(struct Qdisc *sch, struct qdisc_walker *walker)
 {
 	if (!walker->stop) {
@@ -548,7 +553,8 @@ static const struct Qdisc_class_ops tbf_class_ops =
 	.get		=	tbf_get,
 	.put		=	tbf_put,
 	.change		=	tbf_change_class,
-	.delete		=	tbf_delete,
+	.validate_delete=	tbf_validate_delete,
+	.commit_delete	=	tbf_commit_delete,
 	.walk		=	tbf_walk,
 	.tcf_chain	=	tbf_find_tcf,
 	.dump		=	tbf_dump_class,
-- 
1.5.6.2.255.gbed62

