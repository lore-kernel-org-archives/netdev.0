From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: [PATCH net-next-2.6 v4 2/2] hfsc: add link layer overhead adaption
Date: Thu, 10 Jul 2008 22:34:40 +0300
Message-ID: <20080710193440.19525.93085.stgit@fate.lan>
References: <20080710193434.19525.83454.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.dnainternet.fi ([87.94.96.108]:62613 "EHLO
	smtp1.dnainternet.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755332AbYGJTem (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 15:34:42 -0400
In-Reply-To: <20080710193434.19525.83454.stgit@fate.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CBQ and HTB have options for emulating overhead of underlying link layer
(mpu/overhead/linklayer options). This patch makes sch_hfsc use size table
to emulate link layer overhead.

Patch uses size table to convert packet length to emulated link layer packet
length. Converted packet length is passed to hfsc calculations instead of
real. If size table isn't passed to kernel, hfsc works as before.

Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
---

 include/linux/pkt_sched.h |    5 +
 net/sched/sch_hfsc.c      |  158 +++++++++++++++++++++++++++++++++++++--------
 2 files changed, 135 insertions(+), 28 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index 5bf1444..46db55d 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -303,6 +303,9 @@ struct tc_htb_xstats
 struct tc_hfsc_qopt
 {
 	__u16	defcls;		/* default class */
+	__u16	__reserved;
+	struct tc_sizespec szopts;
+	__u16	stab[512];
 };
 
 struct tc_service_curve
@@ -326,6 +329,8 @@ enum
 	TCA_HFSC_RSC,
 	TCA_HFSC_FSC,
 	TCA_HFSC_USC,
+	TCA_HFSC_SZOPTS,
+	TCA_HFSC_STAB,
 	__TCA_HFSC_MAX,
 };
 
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 997d520..1dcee08 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -68,6 +68,9 @@
 #include <net/pkt_cls.h>
 #include <asm/div64.h>
 
+#define endof(type, member) \
+	(offsetof(type, member) + sizeof(((type *)0)->member))
+
 /*
  * kernel internal service curve representation:
  *   coordinates are given by 64 bit unsigned integers.
@@ -128,6 +131,8 @@ struct hfsc_class
 	struct list_head siblings;	/* sibling classes */
 	struct list_head children;	/* child classes */
 	struct Qdisc	*qdisc;		/* leaf qdisc */
+	struct qdisc_size_table *stab;	/* size table used for link layer
+					   overhead adaption */
 
 	struct rb_node el_node;		/* qdisc's eligible tree member */
 	struct rb_root vt_tree;		/* active children sorted by cl_vt */
@@ -493,6 +498,21 @@ sc2isc(struct tc_service_curve *sc, struct internal_sc *isc)
 	isc->ism2 = m2ism(sc->m2);
 }
 
+/* convert packet length to link layer packet length */
+static unsigned int get_linklayer_len(struct hfsc_class *cl, unsigned int len)
+{
+	if (unlikely(!len))
+		return len;
+
+	while (!cl->stab) {
+		cl = cl->cl_parent;
+		if (!cl)
+			return len;
+	}
+
+	return qdisc_linklayer_sz(cl->stab, len);
+}
+
 /*
  * initialize the runtime service curve with the given internal
  * service curve starting at (x, y).
@@ -974,9 +994,11 @@ hfsc_change_usc(struct hfsc_class *cl, struct tc_service_curve *usc,
 }
 
 static const struct nla_policy hfsc_policy[TCA_HFSC_MAX + 1] = {
-	[TCA_HFSC_RSC]	= { .len = sizeof(struct tc_service_curve) },
-	[TCA_HFSC_FSC]	= { .len = sizeof(struct tc_service_curve) },
-	[TCA_HFSC_USC]	= { .len = sizeof(struct tc_service_curve) },
+	[TCA_HFSC_RSC]		= { .len = sizeof(struct tc_service_curve) },
+	[TCA_HFSC_FSC]		= { .len = sizeof(struct tc_service_curve) },
+	[TCA_HFSC_USC]		= { .len = sizeof(struct tc_service_curve) },
+	[TCA_HFSC_SZOPTS]	= { .len = sizeof(struct tc_sizespec) },
+	[TCA_HFSC_STAB]		= { .type = NLA_BINARY, .len = TC_STAB_SIZE }
 };
 
 static int
@@ -989,6 +1011,8 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 	struct nlattr *opt = tca[TCA_OPTIONS];
 	struct nlattr *tb[TCA_HFSC_MAX + 1];
 	struct tc_service_curve *rsc = NULL, *fsc = NULL, *usc = NULL;
+	struct tc_sizespec *szopts = NULL;
+	struct qdisc_size_table *stab = NULL;
 	u64 cur_time;
 	int err;
 
@@ -999,6 +1023,7 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 	if (err < 0)
 		return err;
 
+	err = -EINVAL;
 	if (tb[TCA_HFSC_RSC]) {
 		rsc = nla_data(tb[TCA_HFSC_RSC]);
 		if (rsc->m1 == 0 && rsc->m2 == 0)
@@ -1017,13 +1042,19 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 			usc = NULL;
 	}
 
+	if (tb[TCA_HFSC_SZOPTS]) {
+		szopts = nla_data(tb[TCA_HFSC_SZOPTS]);
+		stab = qdisc_get_stab(szopts, tb[TCA_HFSC_STAB]);
+	}
+
 	if (cl != NULL) {
 		if (parentid) {
+			err = -EINVAL;
 			if (cl->cl_parent &&
 			    cl->cl_parent->cl_common.classid != parentid)
-				return -EINVAL;
+				goto failure;
 			if (cl->cl_parent == NULL && parentid != TC_H_ROOT)
-				return -EINVAL;
+				goto failure;
 		}
 		cur_time = psched_get_time();
 
@@ -1035,9 +1066,14 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 		if (usc != NULL)
 			hfsc_change_usc(cl, usc, cur_time);
 
+		if (cl->stab)
+			qdisc_put_stab(cl->stab);
+		cl->stab = stab;
+
 		if (cl->qdisc->q.qlen != 0) {
 			if (cl->cl_flags & HFSC_RSC)
-				update_ed(cl, qdisc_peek_len(cl->qdisc));
+				update_ed(cl, get_linklayer_len(cl,
+						qdisc_peek_len(cl->qdisc)));
 			if (cl->cl_flags & HFSC_FSC)
 				update_vf(cl, 0, cur_time);
 		}
@@ -1050,27 +1086,39 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 		return 0;
 	}
 
-	if (parentid == TC_H_ROOT)
-		return -EEXIST;
+	if (parentid == TC_H_ROOT) {
+		err = -EEXIST;
+		goto failure;
+	}
 
 	parent = &q->root;
 	if (parentid) {
 		parent = hfsc_find_class(parentid, sch);
-		if (parent == NULL)
-			return -ENOENT;
+		if (parent == NULL) {
+			err = -ENOENT;
+			goto failure;
+		}
 	}
 
-	if (classid == 0 || TC_H_MAJ(classid ^ sch->handle) != 0)
-		return -EINVAL;
-	if (hfsc_find_class(classid, sch))
-		return -EEXIST;
+	if (classid == 0 || TC_H_MAJ(classid ^ sch->handle) != 0) {
+		err = -EINVAL;
+		goto failure;
+	}
+	if (hfsc_find_class(classid, sch)) {
+		err = -EEXIST;
+		goto failure;
+	}
 
-	if (rsc == NULL && fsc == NULL)
-		return -EINVAL;
+	if (rsc == NULL && fsc == NULL) {
+		err = -EINVAL;
+		goto failure;
+	}
 
 	cl = kzalloc(sizeof(struct hfsc_class), GFP_KERNEL);
-	if (cl == NULL)
-		return -ENOBUFS;
+	if (cl == NULL) {
+		err = -ENOBUFS;
+		goto failure;
+	}
 
 	if (rsc != NULL)
 		hfsc_change_rsc(cl, rsc, 0);
@@ -1098,6 +1146,9 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 		hfsc_purge_queue(sch, parent);
 	hfsc_adjust_levels(parent);
 	cl->cl_pcvtoff = parent->cl_cvtoff;
+	if (cl->stab)
+		qdisc_put_stab(cl->stab);
+	cl->stab = stab;
 	sch_tree_unlock(sch);
 
 	qdisc_class_hash_grow(sch, &q->clhash);
@@ -1107,6 +1158,10 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 				  &sch->dev_queue->lock, tca[TCA_RATE]);
 	*arg = (unsigned long)cl;
 	return 0;
+failure:
+	if (stab)
+		qdisc_put_stab(stab);
+	return err;
 }
 
 static void
@@ -1117,6 +1172,8 @@ hfsc_destroy_class(struct Qdisc *sch, struct hfsc_class *cl)
 	tcf_destroy_chain(&cl->filter_list);
 	qdisc_destroy(cl->qdisc);
 	gen_kill_estimator(&cl->bstats, &cl->rate_est);
+	if (cl->stab)
+		qdisc_put_stab(cl->stab);
 	if (cl != &q->root)
 		kfree(cl);
 }
@@ -1330,6 +1387,21 @@ hfsc_dump_curves(struct sk_buff *skb, struct hfsc_class *cl)
 	return -1;
 }
 
+static inline int
+hfsc_dump_szopts(struct sk_buff *skb, struct hfsc_class *cl)
+{
+	if (!cl->stab)
+		return 0;
+
+	NLA_PUT(skb, TCA_HFSC_SZOPTS, sizeof(cl->stab->szopts),
+		&cl->stab->szopts);
+
+	return skb->len;
+
+ nla_put_failure:
+	return -1;
+}
+
 static int
 hfsc_dump_class(struct Qdisc *sch, unsigned long arg, struct sk_buff *skb,
 		struct tcmsg *tcm)
@@ -1348,6 +1420,8 @@ hfsc_dump_class(struct Qdisc *sch, unsigned long arg, struct sk_buff *skb,
 		goto nla_put_failure;
 	if (hfsc_dump_curves(skb, cl) < 0)
 		goto nla_put_failure;
+	if (hfsc_dump_szopts(skb, cl) < 0)
+		goto nla_put_failure;
 	nla_nest_end(skb, nest);
 	return skb->len;
 
@@ -1427,13 +1501,18 @@ static int
 hfsc_init_qdisc(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct hfsc_sched *q = qdisc_priv(sch);
+	struct qdisc_size_table *stab = NULL;
 	struct tc_hfsc_qopt *qopt;
 	int err;
 
-	if (opt == NULL || nla_len(opt) < sizeof(*qopt))
+	if (opt == NULL || nla_len(opt) < endof(struct tc_hfsc_qopt, defcls))
 		return -EINVAL;
 	qopt = nla_data(opt);
 
+	if (nla_len(opt) >= endof(struct tc_hfsc_qopt, stab))
+		stab = __qdisc_get_stab(&qopt->szopts,
+					qopt->stab, TC_STAB_SIZE);
+
 	q->defcls = qopt->defcls;
 	err = qdisc_class_hash_init(&q->clhash);
 	if (err < 0)
@@ -1445,6 +1524,7 @@ hfsc_init_qdisc(struct Qdisc *sch, struct nlattr *opt)
 	q->root.cl_common.classid = sch->handle;
 	q->root.refcnt  = 1;
 	q->root.sched   = q;
+	q->root.stab  = stab;
 	q->root.qdisc = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
 					  &pfifo_qdisc_ops,
 					  sch->handle);
@@ -1466,14 +1546,22 @@ static int
 hfsc_change_qdisc(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct hfsc_sched *q = qdisc_priv(sch);
+	struct qdisc_size_table *stab = NULL;
 	struct tc_hfsc_qopt *qopt;
 
-	if (opt == NULL || nla_len(opt) < sizeof(*qopt))
+	if (opt == NULL || nla_len(opt) < endof(struct tc_hfsc_qopt, defcls))
 		return -EINVAL;
 	qopt = nla_data(opt);
 
+	if (nla_len(opt) >= endof(struct tc_hfsc_qopt, stab))
+		stab = __qdisc_get_stab(&qopt->szopts,
+					qopt->stab, TC_STAB_SIZE);
+
 	sch_tree_lock(sch);
 	q->defcls = qopt->defcls;
+	if (q->root.stab)
+		qdisc_put_stab(q->root.stab);
+	q->root.stab = stab;
 	sch_tree_unlock(sch);
 
 	return 0;
@@ -1559,10 +1647,22 @@ hfsc_dump_qdisc(struct Qdisc *sch, struct sk_buff *skb)
 {
 	struct hfsc_sched *q = qdisc_priv(sch);
 	unsigned char *b = skb_tail_pointer(skb);
-	struct tc_hfsc_qopt qopt;
+	u8 qopt_buf[endof(struct tc_hfsc_qopt, szopts)];
+	struct tc_hfsc_qopt *qopt = (struct tc_hfsc_qopt *)qopt_buf;
+	unsigned int qopt_len;
+
+	memset(qopt, 0, sizeof(qopt_buf));
+
+	qopt->defcls = q->defcls;
+	if (q->root.stab) {
+		qopt_len = sizeof(qopt_buf);
+		qopt->szopts = q->root.stab->szopts;
+	} else {
+		qopt_len = endof(struct tc_hfsc_qopt, defcls);
+	}
+
+	NLA_PUT(skb, TCA_OPTIONS, qopt_len, qopt);
 
-	qopt.defcls = q->defcls;
-	NLA_PUT(skb, TCA_OPTIONS, sizeof(qopt), &qopt);
 	return skb->len;
 
  nla_put_failure:
@@ -1594,7 +1694,7 @@ hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	}
 
 	if (cl->qdisc->q.qlen == 1)
-		set_active(cl, len);
+		set_active(cl, get_linklayer_len(cl, len));
 
 	cl->bstats.packets++;
 	cl->bstats.bytes += len;
@@ -1612,7 +1712,7 @@ hfsc_dequeue(struct Qdisc *sch)
 	struct hfsc_class *cl;
 	struct sk_buff *skb;
 	u64 cur_time;
-	unsigned int next_len;
+	unsigned int next_len, cur_len;
 	int realtime = 0;
 
 	if (sch->q.qlen == 0)
@@ -1649,14 +1749,16 @@ hfsc_dequeue(struct Qdisc *sch)
 		return NULL;
 	}
 
-	update_vf(cl, skb->len, cur_time);
+	cur_len = get_linklayer_len(cl, skb->len);
+	update_vf(cl, cur_len, cur_time);
 	if (realtime)
-		cl->cl_cumul += skb->len;
+		cl->cl_cumul += cur_len;
 
 	if (cl->qdisc->q.qlen != 0) {
 		if (cl->cl_flags & HFSC_RSC) {
 			/* update ed */
-			next_len = qdisc_peek_len(cl->qdisc);
+			next_len = get_linklayer_len(cl,
+						qdisc_peek_len(cl->qdisc));
 			if (realtime)
 				update_ed(cl, next_len);
 			else

