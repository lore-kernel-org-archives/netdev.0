From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: [PATCH] hfsc: add link layer overhead adaption
Date: Mon, 23 Jun 2008 13:25:14 +0300
Message-ID: <20080623102514.15821.13979.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.dnainternet.fi ([87.94.96.108]:33310 "EHLO
	smtp1.dnainternet.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754128AbYFWKZR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 06:25:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CBQ and HTB have options for emulating overhead of underlying link layer
(mpu/overhead/linklayer options). This patch makes sch_hfsc use rate table
to emulate link layer overhead.

Patch uses rate table to convert packet length to emulated link layer packet
length using qdisc_l2t() in get_linklayer_len(). Converted packet length is
passed to hfsc calculations instead of real. If rate table isn't passed to
kernel, hfsc works as before.

Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
---

 include/linux/pkt_sched.h |    2 +
 net/sched/sch_hfsc.c      |  125 ++++++++++++++++++++++++++++++++++++---------
 2 files changed, 102 insertions(+), 25 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index dbb7ac3..1d2cb24 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -316,6 +316,8 @@ enum
 	TCA_HFSC_RSC,
 	TCA_HFSC_FSC,
 	TCA_HFSC_USC,
+	TCA_HFSC_RATEOPTS,
+	TCA_HFSC_RTAB,
 	__TCA_HFSC_MAX,
 };
 
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index fdfaa3f..94fd130 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -128,6 +128,8 @@ struct hfsc_class
 	struct list_head siblings;	/* sibling classes */
 	struct list_head children;	/* child classes */
 	struct Qdisc	*qdisc;		/* leaf qdisc */
+	struct qdisc_rate_table *rtab;	/* rate table used for link layer
+					   overhead adaption */
 
 	struct rb_node el_node;		/* qdisc's eligible tree member */
 	struct rb_root vt_tree;		/* active children sorted by cl_vt */
@@ -496,6 +498,20 @@ sc2isc(struct tc_service_curve *sc, struct internal_sc *isc)
 	isc->ism2 = m2ism(sc->m2);
 }
 
+/* convert packet length to link layer packet length */
+static unsigned int get_linklayer_len(struct hfsc_class *cl, unsigned int len)
+{
+	u64 ll_len;
+	if (likely(len) && unlikely(cl->rtab)) {
+		ll_len = qdisc_l2t(cl->rtab, len);
+		if (unlikely(cl->rtab->rate.rate != PSCHED_TICKS_PER_SEC))
+			ll_len = div_u64(ll_len * cl->rtab->rate.rate,
+							PSCHED_TICKS_PER_SEC);
+		return (unsigned int)ll_len;
+	}
+	return len;
+}
+
 /*
  * initialize the runtime service curve with the given internal
  * service curve starting at (x, y).
@@ -987,9 +1003,11 @@ hfsc_change_usc(struct hfsc_class *cl, struct tc_service_curve *usc,
 }
 
 static const struct nla_policy hfsc_policy[TCA_HFSC_MAX + 1] = {
-	[TCA_HFSC_RSC]	= { .len = sizeof(struct tc_service_curve) },
-	[TCA_HFSC_FSC]	= { .len = sizeof(struct tc_service_curve) },
-	[TCA_HFSC_USC]	= { .len = sizeof(struct tc_service_curve) },
+	[TCA_HFSC_RSC]		= { .len = sizeof(struct tc_service_curve) },
+	[TCA_HFSC_FSC]		= { .len = sizeof(struct tc_service_curve) },
+	[TCA_HFSC_USC]		= { .len = sizeof(struct tc_service_curve) },
+	[TCA_HFSC_RATEOPTS]	= { .len = sizeof(struct tc_ratespec) },
+	[TCA_HFSC_RTAB]		= { .type = NLA_BINARY, .len = TC_RTAB_SIZE },
 };
 
 static int
@@ -1000,18 +1018,21 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 	struct hfsc_class *cl = (struct hfsc_class *)*arg;
 	struct hfsc_class *parent = NULL;
 	struct nlattr *opt = tca[TCA_OPTIONS];
-	struct nlattr *tb[TCA_HFSC_MAX + 1];
+	struct nlattr *tb[TCA_HFSC_RTAB + 1];
 	struct tc_service_curve *rsc = NULL, *fsc = NULL, *usc = NULL;
+	struct tc_ratespec *rateopts = NULL;
+	struct qdisc_rate_table *rtab = NULL;
 	u64 cur_time;
 	int err;
 
 	if (opt == NULL)
 		return -EINVAL;
 
-	err = nla_parse_nested(tb, TCA_HFSC_MAX, opt, hfsc_policy);
+	err = nla_parse_nested(tb, TCA_HFSC_RTAB, opt, hfsc_policy);
 	if (err < 0)
 		return err;
 
+	err = -EINVAL;
 	if (tb[TCA_HFSC_RSC]) {
 		rsc = nla_data(tb[TCA_HFSC_RSC]);
 		if (rsc->m1 == 0 && rsc->m2 == 0)
@@ -1030,12 +1051,21 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 			usc = NULL;
 	}
 
+	if (tb[TCA_HFSC_RATEOPTS]) {
+		rateopts = nla_data(tb[TCA_HFSC_RATEOPTS]);
+		if (rateopts->rate == 0)
+			rateopts = NULL;
+		else
+			rtab = qdisc_get_rtab(rateopts, tb[TCA_HFSC_RTAB]);
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
 
@@ -1047,9 +1077,14 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 		if (usc != NULL)
 			hfsc_change_usc(cl, usc, cur_time);
 
+		if (cl->rtab)
+			qdisc_put_rtab(cl->rtab);
+		cl->rtab = rtab;
+
 		if (cl->qdisc->q.qlen != 0) {
 			if (cl->cl_flags & HFSC_RSC)
-				update_ed(cl, qdisc_peek_len(cl->qdisc));
+				update_ed(cl, get_linklayer_len(cl,
+						qdisc_peek_len(cl->qdisc)));
 			if (cl->cl_flags & HFSC_FSC)
 				update_vf(cl, 0, cur_time);
 		}
@@ -1062,27 +1097,39 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
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
@@ -1109,6 +1156,9 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 		hfsc_purge_queue(sch, parent);
 	hfsc_adjust_levels(parent);
 	cl->cl_pcvtoff = parent->cl_cvtoff;
+	if (cl->rtab)
+		qdisc_put_rtab(cl->rtab);
+	cl->rtab = rtab;
 	sch_tree_unlock(sch);
 
 	if (tca[TCA_RATE])
@@ -1116,6 +1166,10 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 				  &sch->dev->queue_lock, tca[TCA_RATE]);
 	*arg = (unsigned long)cl;
 	return 0;
+failure:
+	if (rtab)
+		qdisc_put_rtab(rtab);
+	return err;
 }
 
 static void
@@ -1126,6 +1180,8 @@ hfsc_destroy_class(struct Qdisc *sch, struct hfsc_class *cl)
 	tcf_destroy_chain(cl->filter_list);
 	qdisc_destroy(cl->qdisc);
 	gen_kill_estimator(&cl->bstats, &cl->rate_est);
+	if (cl->rtab)
+		qdisc_put_rtab(cl->rtab);
 	if (cl != &q->root)
 		kfree(cl);
 }
@@ -1338,6 +1394,21 @@ hfsc_dump_curves(struct sk_buff *skb, struct hfsc_class *cl)
 	return -1;
 }
 
+static inline int
+hfsc_dump_rateopts(struct sk_buff *skb, struct hfsc_class *cl)
+{
+	if (!cl->rtab)
+		return 0;
+
+	NLA_PUT(skb, TCA_HFSC_RATEOPTS, sizeof(cl->rtab->rate),
+		&cl->rtab->rate);
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
@@ -1355,6 +1426,8 @@ hfsc_dump_class(struct Qdisc *sch, unsigned long arg, struct sk_buff *skb,
 		goto nla_put_failure;
 	if (hfsc_dump_curves(skb, cl) < 0)
 		goto nla_put_failure;
+	if (hfsc_dump_rateopts(skb, cl) < 0)
+		goto nla_put_failure;
 	nla_nest_end(skb, nest);
 	return skb->len;
 
@@ -1588,7 +1661,7 @@ hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	}
 
 	if (cl->qdisc->q.qlen == 1)
-		set_active(cl, len);
+		set_active(cl, get_linklayer_len(cl, len));
 
 	cl->bstats.packets++;
 	cl->bstats.bytes += len;
@@ -1606,7 +1679,7 @@ hfsc_dequeue(struct Qdisc *sch)
 	struct hfsc_class *cl;
 	struct sk_buff *skb;
 	u64 cur_time;
-	unsigned int next_len;
+	unsigned int next_len, cur_len;
 	int realtime = 0;
 
 	if (sch->q.qlen == 0)
@@ -1643,14 +1716,16 @@ hfsc_dequeue(struct Qdisc *sch)
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

