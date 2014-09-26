From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v2 3/4] net: sched: restrict use of qstats qlen
Date: Fri, 26 Sep 2014 11:37:12 -0700
Message-ID: <20140926183711.2621.27896.stgit@nitbit.x32>
References: <20140926183621.2621.72538.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com, jhs@mojatatu.com, eric.dumazet@gmail.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:45650 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754412AbaIZSh3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 14:37:29 -0400
Received: by mail-oi0-f51.google.com with SMTP id e131so497723oig.24
        for <netdev@vger.kernel.org>; Fri, 26 Sep 2014 11:37:28 -0700 (PDT)
In-Reply-To: <20140926183621.2621.72538.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This removes the use of qstats->qlen variable from the classifiers
and makes it an explicit argument to gnet_stats_copy_queue().

The qlen represents the qdisc queue length and is packed into
the qstats at the last moment before passnig to user space. By
handling it explicitely we avoid, in the percpu stats case, having
to figure out which per_cpu variable to put it in.

It would probably be best to remove it from qstats completely
but qstats is a user space ABI and can't be broken. A future
patch could make an internal only qstats structure that would
avoid having to allocate an additional u32 variable on the
Qdisc struct. This would make the qstats struct 128bits instead
of 128+32.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/net/gen_stats.h  |    3 ++-
 net/core/gen_stats.c     |    6 +++++-
 net/sched/act_api.c      |    4 +++-
 net/sched/sch_api.c      |    5 +++--
 net/sched/sch_atm.c      |    4 +---
 net/sched/sch_cbq.c      |    3 +--
 net/sched/sch_drr.c      |    7 +++----
 net/sched/sch_fq_codel.c |    2 +-
 net/sched/sch_hfsc.c     |    3 +--
 net/sched/sch_htb.c      |    5 +++--
 net/sched/sch_mq.c       |    4 +---
 net/sched/sch_mqprio.c   |    9 ++++-----
 net/sched/sch_multiq.c   |    3 +--
 net/sched/sch_prio.c     |    3 +--
 net/sched/sch_qfq.c      |    3 +--
 net/sched/sch_sfq.c      |    2 +-
 16 files changed, 32 insertions(+), 34 deletions(-)

diff --git a/include/net/gen_stats.h b/include/net/gen_stats.h
index ce3c128..de9b3dd 100644
--- a/include/net/gen_stats.h
+++ b/include/net/gen_stats.h
@@ -40,7 +40,8 @@ void __gnet_stats_copy_basic(struct gnet_stats_basic_packed *bstats,
 int gnet_stats_copy_rate_est(struct gnet_dump *d,
 			     const struct gnet_stats_basic_packed *b,
 			     struct gnet_stats_rate_est64 *r);
-int gnet_stats_copy_queue(struct gnet_dump *d, struct gnet_stats_queue *q);
+int gnet_stats_copy_queue(struct gnet_dump *d,
+			  struct gnet_stats_queue *q, __u32 len);
 int gnet_stats_copy_app(struct gnet_dump *d, void *st, int len);
 
 int gnet_stats_finish_copy(struct gnet_dump *d);
diff --git a/net/core/gen_stats.c b/net/core/gen_stats.c
index 5ff8e80..ad3ecb6 100644
--- a/net/core/gen_stats.c
+++ b/net/core/gen_stats.c
@@ -219,6 +219,7 @@ EXPORT_SYMBOL(gnet_stats_copy_rate_est);
  * gnet_stats_copy_queue - copy queue statistics into statistics TLV
  * @d: dumping handle
  * @q: queue statistics
+ * @qlen: queue length statistics
  *
  * Appends the queue statistics to the top level TLV created by
  * gnet_stats_start_copy().
@@ -227,8 +228,11 @@ EXPORT_SYMBOL(gnet_stats_copy_rate_est);
  * if the room in the socket buffer was not sufficient.
  */
 int
-gnet_stats_copy_queue(struct gnet_dump *d, struct gnet_stats_queue *q)
+gnet_stats_copy_queue(struct gnet_dump *d,
+		      struct gnet_stats_queue *q, __u32 qlen)
 {
+	q->qlen = qlen;
+
 	if (d->compat_tc_stats) {
 		d->tc_stats.drops = q->drops;
 		d->tc_stats.qlen = q->qlen;
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index eca4cf9..2e13409 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -623,7 +623,9 @@ int tcf_action_copy_stats(struct sk_buff *skb, struct tc_action *a,
 	if (gnet_stats_copy_basic(&d, NULL, &p->tcfc_bstats) < 0 ||
 	    gnet_stats_copy_rate_est(&d, &p->tcfc_bstats,
 				     &p->tcfc_rate_est) < 0 ||
-	    gnet_stats_copy_queue(&d, &p->tcfc_qstats) < 0)
+	    gnet_stats_copy_queue(&d,
+				  &p->tcfc_qstats,
+				  p->tcfc_qstats.qlen) < 0)
 		goto errout;
 
 	if (gnet_stats_finish_copy(&d) < 0)
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 2862bc6..ca00ea8 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1318,6 +1318,7 @@ static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
 	unsigned char *b = skb_tail_pointer(skb);
 	struct gnet_dump d;
 	struct qdisc_size_table *stab;
+	__u32 qlen;
 
 	cond_resched();
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*tcm), flags);
@@ -1335,7 +1336,7 @@ static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
 		goto nla_put_failure;
 	if (q->ops->dump && q->ops->dump(q, skb) < 0)
 		goto nla_put_failure;
-	q->qstats.qlen = q->q.qlen;
+	qlen = q->q.qlen;
 
 	stab = rtnl_dereference(q->stab);
 	if (stab && qdisc_dump_stab(skb, stab) < 0)
@@ -1353,7 +1354,7 @@ static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
 
 	if (gnet_stats_copy_basic(&d, cpu_bstats, &q->bstats) < 0 ||
 	    gnet_stats_copy_rate_est(&d, &q->bstats, &q->rate_est) < 0 ||
-	    gnet_stats_copy_queue(&d, &q->qstats) < 0)
+	    gnet_stats_copy_queue(&d, &q->qstats, qlen) < 0)
 		goto nla_put_failure;
 
 	if (gnet_stats_finish_copy(&d) < 0)
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 040212c..c145eb6 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -637,10 +637,8 @@ atm_tc_dump_class_stats(struct Qdisc *sch, unsigned long arg,
 {
 	struct atm_flow_data *flow = (struct atm_flow_data *)arg;
 
-	flow->qstats.qlen = flow->q->q.qlen;
-
 	if (gnet_stats_copy_basic(d, NULL, &flow->bstats) < 0 ||
-	    gnet_stats_copy_queue(d, &flow->qstats) < 0)
+	    gnet_stats_copy_queue(d, &flow->qstats, flow->q->q.qlen) < 0)
 		return -1;
 
 	return 0;
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 60432c3..c610081 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -1594,7 +1594,6 @@ cbq_dump_class_stats(struct Qdisc *sch, unsigned long arg,
 	struct cbq_sched_data *q = qdisc_priv(sch);
 	struct cbq_class *cl = (struct cbq_class *)arg;
 
-	cl->qstats.qlen = cl->q->q.qlen;
 	cl->xstats.avgidle = cl->avgidle;
 	cl->xstats.undertime = 0;
 
@@ -1603,7 +1602,7 @@ cbq_dump_class_stats(struct Qdisc *sch, unsigned long arg,
 
 	if (gnet_stats_copy_basic(d, NULL, &cl->bstats) < 0 ||
 	    gnet_stats_copy_rate_est(d, &cl->bstats, &cl->rate_est) < 0 ||
-	    gnet_stats_copy_queue(d, &cl->qstats) < 0)
+	    gnet_stats_copy_queue(d, &cl->qstats, cl->q->q.qlen) < 0)
 		return -1;
 
 	return gnet_stats_copy_app(d, &cl->xstats, sizeof(cl->xstats));
diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
index 907b12f..5835a93 100644
--- a/net/sched/sch_drr.c
+++ b/net/sched/sch_drr.c
@@ -275,17 +275,16 @@ static int drr_dump_class_stats(struct Qdisc *sch, unsigned long arg,
 				struct gnet_dump *d)
 {
 	struct drr_class *cl = (struct drr_class *)arg;
+	__u32 qlen = cl->qdisc->q.qlen;
 	struct tc_drr_stats xstats;
 
 	memset(&xstats, 0, sizeof(xstats));
-	if (cl->qdisc->q.qlen) {
+	if (qlen)
 		xstats.deficit = cl->deficit;
-		cl->qdisc->qstats.qlen = cl->qdisc->q.qlen;
-	}
 
 	if (gnet_stats_copy_basic(d, NULL, &cl->bstats) < 0 ||
 	    gnet_stats_copy_rate_est(d, &cl->bstats, &cl->rate_est) < 0 ||
-	    gnet_stats_copy_queue(d, &cl->qdisc->qstats) < 0)
+	    gnet_stats_copy_queue(d, &cl->qdisc->qstats, qlen) < 0)
 		return -1;
 
 	return gnet_stats_copy_app(d, &xstats, sizeof(xstats));
diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index 3f288ae..6a42112 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -550,7 +550,7 @@ static int fq_codel_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 		qs.backlog = q->backlogs[idx];
 		qs.drops = flow->dropped;
 	}
-	if (gnet_stats_copy_queue(d, &qs) < 0)
+	if (gnet_stats_copy_queue(d, &qs, 0) < 0)
 		return -1;
 	if (idx < q->flows_cnt)
 		return gnet_stats_copy_app(d, &xstats, sizeof(xstats));
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index ad27825..d364acb 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1370,7 +1370,6 @@ hfsc_dump_class_stats(struct Qdisc *sch, unsigned long arg,
 	struct hfsc_class *cl = (struct hfsc_class *)arg;
 	struct tc_hfsc_stats xstats;
 
-	cl->qstats.qlen = cl->qdisc->q.qlen;
 	cl->qstats.backlog = cl->qdisc->qstats.backlog;
 	xstats.level   = cl->level;
 	xstats.period  = cl->cl_vtperiod;
@@ -1379,7 +1378,7 @@ hfsc_dump_class_stats(struct Qdisc *sch, unsigned long arg,
 
 	if (gnet_stats_copy_basic(d, NULL, &cl->bstats) < 0 ||
 	    gnet_stats_copy_rate_est(d, &cl->bstats, &cl->rate_est) < 0 ||
-	    gnet_stats_copy_queue(d, &cl->qstats) < 0)
+	    gnet_stats_copy_queue(d, &cl->qstats, cl->qdisc->q.qlen) < 0)
 		return -1;
 
 	return gnet_stats_copy_app(d, &xstats, sizeof(xstats));
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index c40ab7a..3a691fd 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1138,15 +1138,16 @@ static int
 htb_dump_class_stats(struct Qdisc *sch, unsigned long arg, struct gnet_dump *d)
 {
 	struct htb_class *cl = (struct htb_class *)arg;
+	__u32 qlen = 0;
 
 	if (!cl->level && cl->un.leaf.q)
-		cl->qstats.qlen = cl->un.leaf.q->q.qlen;
+		qlen = cl->un.leaf.q->q.qlen;
 	cl->xstats.tokens = PSCHED_NS2TICKS(cl->tokens);
 	cl->xstats.ctokens = PSCHED_NS2TICKS(cl->ctokens);
 
 	if (gnet_stats_copy_basic(d, NULL, &cl->bstats) < 0 ||
 	    gnet_stats_copy_rate_est(d, NULL, &cl->rate_est) < 0 ||
-	    gnet_stats_copy_queue(d, &cl->qstats) < 0)
+	    gnet_stats_copy_queue(d, &cl->qstats, qlen) < 0)
 		return -1;
 
 	return gnet_stats_copy_app(d, &cl->xstats, sizeof(cl->xstats));
diff --git a/net/sched/sch_mq.c b/net/sched/sch_mq.c
index d3a27fb..6416a69 100644
--- a/net/sched/sch_mq.c
+++ b/net/sched/sch_mq.c
@@ -112,7 +112,6 @@ static int mq_dump(struct Qdisc *sch, struct sk_buff *skb)
 		sch->q.qlen		+= qdisc->q.qlen;
 		sch->bstats.bytes	+= qdisc->bstats.bytes;
 		sch->bstats.packets	+= qdisc->bstats.packets;
-		sch->qstats.qlen	+= qdisc->qstats.qlen;
 		sch->qstats.backlog	+= qdisc->qstats.backlog;
 		sch->qstats.drops	+= qdisc->qstats.drops;
 		sch->qstats.requeues	+= qdisc->qstats.requeues;
@@ -200,9 +199,8 @@ static int mq_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 	struct netdev_queue *dev_queue = mq_queue_get(sch, cl);
 
 	sch = dev_queue->qdisc_sleeping;
-	sch->qstats.qlen = sch->q.qlen;
 	if (gnet_stats_copy_basic(d, NULL, &sch->bstats) < 0 ||
-	    gnet_stats_copy_queue(d, &sch->qstats) < 0)
+	    gnet_stats_copy_queue(d, &sch->qstats, sch->q.qlen) < 0)
 		return -1;
 	return 0;
 }
diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
index 8917372..03dbeb5 100644
--- a/net/sched/sch_mqprio.c
+++ b/net/sched/sch_mqprio.c
@@ -236,7 +236,6 @@ static int mqprio_dump(struct Qdisc *sch, struct sk_buff *skb)
 		sch->q.qlen		+= qdisc->q.qlen;
 		sch->bstats.bytes	+= qdisc->bstats.bytes;
 		sch->bstats.packets	+= qdisc->bstats.packets;
-		sch->qstats.qlen	+= qdisc->qstats.qlen;
 		sch->qstats.backlog	+= qdisc->qstats.backlog;
 		sch->qstats.drops	+= qdisc->qstats.drops;
 		sch->qstats.requeues	+= qdisc->qstats.requeues;
@@ -327,6 +326,7 @@ static int mqprio_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 
 	if (cl <= netdev_get_num_tc(dev)) {
 		int i;
+		__u32 qlen = 0;
 		struct Qdisc *qdisc;
 		struct gnet_stats_queue qstats = {0};
 		struct gnet_stats_basic_packed bstats = {0};
@@ -344,9 +344,9 @@ static int mqprio_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 
 			qdisc = rtnl_dereference(q->qdisc);
 			spin_lock_bh(qdisc_lock(qdisc));
+			qlen		  += qdisc->q.qlen;
 			bstats.bytes      += qdisc->bstats.bytes;
 			bstats.packets    += qdisc->bstats.packets;
-			qstats.qlen       += qdisc->qstats.qlen;
 			qstats.backlog    += qdisc->qstats.backlog;
 			qstats.drops      += qdisc->qstats.drops;
 			qstats.requeues   += qdisc->qstats.requeues;
@@ -356,15 +356,14 @@ static int mqprio_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 		/* Reclaim root sleeping lock before completing stats */
 		spin_lock_bh(d->lock);
 		if (gnet_stats_copy_basic(d, NULL, &bstats) < 0 ||
-		    gnet_stats_copy_queue(d, &qstats) < 0)
+		    gnet_stats_copy_queue(d, &qstats, qlen) < 0)
 			return -1;
 	} else {
 		struct netdev_queue *dev_queue = mqprio_queue_get(sch, cl);
 
 		sch = dev_queue->qdisc_sleeping;
-		sch->qstats.qlen = sch->q.qlen;
 		if (gnet_stats_copy_basic(d, NULL, &sch->bstats) < 0 ||
-		    gnet_stats_copy_queue(d, &sch->qstats) < 0)
+		    gnet_stats_copy_queue(d, &sch->qstats, sch->q.qlen) < 0)
 			return -1;
 	}
 	return 0;
diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
index 7f4e1d8..53357b3 100644
--- a/net/sched/sch_multiq.c
+++ b/net/sched/sch_multiq.c
@@ -360,9 +360,8 @@ static int multiq_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 	struct Qdisc *cl_q;
 
 	cl_q = q->queues[cl - 1];
-	cl_q->qstats.qlen = cl_q->q.qlen;
 	if (gnet_stats_copy_basic(d, NULL, &cl_q->bstats) < 0 ||
-	    gnet_stats_copy_queue(d, &cl_q->qstats) < 0)
+	    gnet_stats_copy_queue(d, &cl_q->qstats, cl_q->q.qlen) < 0)
 		return -1;
 
 	return 0;
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index b411e78..4644f55 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -324,9 +324,8 @@ static int prio_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 	struct Qdisc *cl_q;
 
 	cl_q = q->queues[cl - 1];
-	cl_q->qstats.qlen = cl_q->q.qlen;
 	if (gnet_stats_copy_basic(d, NULL, &cl_q->bstats) < 0 ||
-	    gnet_stats_copy_queue(d, &cl_q->qstats) < 0)
+	    gnet_stats_copy_queue(d, &cl_q->qstats, cl_q->q.qlen) < 0)
 		return -1;
 
 	return 0;
diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index 3fb2655..66df9d9 100644
--- a/net/sched/sch_qfq.c
+++ b/net/sched/sch_qfq.c
@@ -664,14 +664,13 @@ static int qfq_dump_class_stats(struct Qdisc *sch, unsigned long arg,
 	struct tc_qfq_stats xstats;
 
 	memset(&xstats, 0, sizeof(xstats));
-	cl->qdisc->qstats.qlen = cl->qdisc->q.qlen;
 
 	xstats.weight = cl->agg->class_weight;
 	xstats.lmax = cl->agg->lmax;
 
 	if (gnet_stats_copy_basic(d, NULL, &cl->bstats) < 0 ||
 	    gnet_stats_copy_rate_est(d, &cl->bstats, &cl->rate_est) < 0 ||
-	    gnet_stats_copy_queue(d, &cl->qdisc->qstats) < 0)
+	    gnet_stats_copy_queue(d, &cl->qdisc->qstats, cl->qdisc->q.qlen) < 0)
 		return -1;
 
 	return gnet_stats_copy_app(d, &xstats, sizeof(xstats));
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 16fb3e7..4805651 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -871,7 +871,7 @@ static int sfq_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 		qs.qlen = slot->qlen;
 		qs.backlog = slot->backlog;
 	}
-	if (gnet_stats_copy_queue(d, &qs) < 0)
+	if (gnet_stats_copy_queue(d, &qs, qs.qlen) < 0)
 		return -1;
 	return gnet_stats_copy_app(d, &xstats, sizeof(xstats));
 }
