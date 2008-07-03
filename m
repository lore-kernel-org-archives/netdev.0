From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: [PATCH v3 2/2] hfsc: add link layer overhead adaption
Date: Fri, 04 Jul 2008 01:03:18 +0300
Message-ID: <20080703220317.30053.87947.stgit@fate.lan>
References: <20080703220311.30053.63477.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.dnainternet.fi ([87.94.96.108]:34709 "EHLO
	smtp1.dnainternet.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756202AbYGCWDU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 18:03:20 -0400
In-Reply-To: <20080703220311.30053.63477.stgit@fate.lan>
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

 include/linux/pkt_sched.h |    2 +
 net/sched/sch_hfsc.c      |  116 +++++++++++++++++++++++++++++++++++----------
 2 files changed, 93 insertions(+), 25 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index 5bf1444..6a2cbc4 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -326,6 +326,8 @@ enum
 	TCA_HFSC_RSC,
 	TCA_HFSC_FSC,
 	TCA_HFSC_USC,
+	TCA_HFSC_SZOPTS,
+	TCA_HFSC_STAB,
 	__TCA_HFSC_MAX,
 };
 
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index fdfaa3f..de958aa 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -128,6 +128,8 @@ struct hfsc_class
 	struct list_head siblings;	/* sibling classes */
 	struct list_head children;	/* child classes */
 	struct Qdisc	*qdisc;		/* leaf qdisc */
+	struct qdisc_size_table *stab;	/* size table used for link layer
+					   overhead adaption */
 
 	struct rb_node el_node;		/* qdisc's eligible tree member */
 	struct rb_root vt_tree;		/* active children sorted by cl_vt */
@@ -496,6 +498,14 @@ sc2isc(struct tc_service_curve *sc, struct internal_sc *isc)
 	isc->ism2 = m2ism(sc->m2);
 }
 
+/* convert packet length to link layer packet length */
+static unsigned int get_linklayer_len(struct hfsc_class *cl, unsigned int len)
+{
+	if (unlikely(!len) || likely(!cl->stab))
+		return len;
+	return qdisc_linklayer_sz(cl->stab, len);
+}
+
 /*
  * initialize the runtime service curve with the given internal
  * service curve starting at (x, y).
@@ -987,9 +997,11 @@ hfsc_change_usc(struct hfsc_class *cl, struct tc_service_curve *usc,
 }
 
 static const struct nla_policy hfsc_policy[TCA_HFSC_MAX + 1] = {
-	[TCA_HFSC_RSC]	= { .len = sizeof(struct tc_service_curve) },
-	[TCA_HFSC_FSC]	= { .len = sizeof(struct tc_service_curve) },
-	[TCA_HFSC_USC]	= { .len = sizeof(struct tc_service_curve) },
+	[TCA_HFSC_RSC]		= { .len = sizeof(struct tc_service_curve) },
+	[TCA_HFSC_FSC]		= { .len = sizeof(struct tc_service_curve) },
+	[TCA_HFSC_USC]		= { .len = sizeof(struct tc_service_curve) },
+	[TCA_HFSC_SZOPTS]	= { .len = sizeof(struct tc_sizespec) },
+	[TCA_HFSC_STAB]		= { .type = NLA_BINARY, .len = TC_STAB_SIZE },
 };
 
 static int
@@ -1000,18 +1012,21 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 	struct hfsc_class *cl = (struct hfsc_class *)*arg;
 	struct hfsc_class *parent = NULL;
 	struct nlattr *opt = tca[TCA_OPTIONS];
-	struct nlattr *tb[TCA_HFSC_MAX + 1];
+	struct nlattr *tb[TCA_HFSC_STAB + 1];
 	struct tc_service_curve *rsc = NULL, *fsc = NULL, *usc = NULL;
+	struct tc_sizespec *szopts = NULL;
+	struct qdisc_size_table *stab = NULL;
 	u64 cur_time;
 	int err;
 
 	if (opt == NULL)
 		return -EINVAL;
 
-	err = nla_parse_nested(tb, TCA_HFSC_MAX, opt, hfsc_policy);
+	err = nla_parse_nested(tb, TCA_HFSC_STAB, opt, hfsc_policy);
 	if (err < 0)
 		return err;
 
+	err = -EINVAL;
 	if (tb[TCA_HFSC_RSC]) {
 		rsc = nla_data(tb[TCA_HFSC_RSC]);
 		if (rsc->m1 == 0 && rsc->m2 == 0)
@@ -1030,12 +1045,18 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
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
 			if (cl->cl_parent && cl->cl_parent->classid != parentid)
-				return -EINVAL;
+				goto failure;
 			if (cl->cl_parent == NULL && parentid != TC_H_ROOT)
-				return -EINVAL;
+				goto failure;
 		}
 		cur_time = psched_get_time();
 
@@ -1047,9 +1068,14 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
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
@@ -1062,27 +1088,39 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
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
@@ -1109,6 +1147,9 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 		hfsc_purge_queue(sch, parent);
 	hfsc_adjust_levels(parent);
 	cl->cl_pcvtoff = parent->cl_cvtoff;
+	if (cl->stab)
+		qdisc_put_stab(cl->stab);
+	cl->stab = stab;
 	sch_tree_unlock(sch);
 
 	if (tca[TCA_RATE])
@@ -1116,6 +1157,10 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 				  &sch->dev->queue_lock, tca[TCA_RATE]);
 	*arg = (unsigned long)cl;
 	return 0;
+failure:
+	if (stab)
+		qdisc_put_stab(stab);
+	return err;
 }
 
 static void
@@ -1126,6 +1171,8 @@ hfsc_destroy_class(struct Qdisc *sch, struct hfsc_class *cl)
 	tcf_destroy_chain(cl->filter_list);
 	qdisc_destroy(cl->qdisc);
 	gen_kill_estimator(&cl->bstats, &cl->rate_est);
+	if (cl->stab)
+		qdisc_put_stab(cl->stab);
 	if (cl != &q->root)
 		kfree(cl);
 }
@@ -1338,6 +1385,21 @@ hfsc_dump_curves(struct sk_buff *skb, struct hfsc_class *cl)
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
@@ -1355,6 +1417,8 @@ hfsc_dump_class(struct Qdisc *sch, unsigned long arg, struct sk_buff *skb,
 		goto nla_put_failure;
 	if (hfsc_dump_curves(skb, cl) < 0)
 		goto nla_put_failure;
+	if (hfsc_dump_szopts(skb, cl) < 0)
+		goto nla_put_failure;
 	nla_nest_end(skb, nest);
 	return skb->len;
 
@@ -1588,7 +1652,7 @@ hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	}
 
 	if (cl->qdisc->q.qlen == 1)
-		set_active(cl, len);
+		set_active(cl, get_linklayer_len(cl, len));
 
 	cl->bstats.packets++;
 	cl->bstats.bytes += len;
@@ -1606,7 +1670,7 @@ hfsc_dequeue(struct Qdisc *sch)
 	struct hfsc_class *cl;
 	struct sk_buff *skb;
 	u64 cur_time;
-	unsigned int next_len;
+	unsigned int next_len, cur_len;
 	int realtime = 0;
 
 	if (sch->q.qlen == 0)
@@ -1643,14 +1707,16 @@ hfsc_dequeue(struct Qdisc *sch)
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

