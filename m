From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 14/15] net: sched: make qstats per cpu
Date: Wed, 30 Apr 2014 09:40:53 -0700
Message-ID: <20140430164051.9021.77279.stgit@nitbit.x32>
References: <20140430163250.9021.21199.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, eric.dumazet@gmail.com
To: xiyou.wangcong@gmail.com, jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f49.google.com ([209.85.219.49]:62158 "EHLO
	mail-oa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945914AbaD3QlQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2014 12:41:16 -0400
Received: by mail-oa0-f49.google.com with SMTP id o6so2255765oag.36
        for <netdev@vger.kernel.org>; Wed, 30 Apr 2014 09:41:16 -0700 (PDT)
In-Reply-To: <20140430163250.9021.21199.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that we run qdisc without locked the qstats need to handle the
case where multiple cpus are receiving or transmiting a skb. For now
the only qdisc that supports running without locks is the ingress
qdisc which increments the 32-bit drop counter.

When the stats are collected the summation of all CPUs is collected
and returned in the dump tlv.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/net/codel.h       |    4 ++--
 include/net/gen_stats.h   |    1 +
 include/net/sch_generic.h |   19 +++++++++++--------
 net/core/gen_stats.c      |   30 +++++++++++++++++++++++++++++-
 net/sched/sch_api.c       |   20 +++++++++++++++-----
 net/sched/sch_atm.c       |    2 +-
 net/sched/sch_cbq.c       |   10 +++++-----
 net/sched/sch_choke.c     |   15 ++++++++-------
 net/sched/sch_codel.c     |    2 +-
 net/sched/sch_drr.c       |    8 ++++----
 net/sched/sch_dsmark.c    |    2 +-
 net/sched/sch_fifo.c      |    6 ++++--
 net/sched/sch_fq.c        |    4 ++--
 net/sched/sch_fq_codel.c  |    8 ++++----
 net/sched/sch_generic.c   |    4 ++--
 net/sched/sch_gred.c      |   10 +++++-----
 net/sched/sch_hfsc.c      |   15 ++++++++-------
 net/sched/sch_hhf.c       |    8 ++++----
 net/sched/sch_htb.c       |    6 +++---
 net/sched/sch_ingress.c   |    4 +++-
 net/sched/sch_mq.c        |   23 ++++++++++++++---------
 net/sched/sch_mqprio.c    |   34 +++++++++++++++++++++-------------
 net/sched/sch_multiq.c    |    8 ++++----
 net/sched/sch_netem.c     |   17 +++++++++--------
 net/sched/sch_pie.c       |    8 ++++----
 net/sched/sch_plug.c      |    2 +-
 net/sched/sch_prio.c      |    8 ++++----
 net/sched/sch_qfq.c       |    8 ++++----
 net/sched/sch_red.c       |   13 +++++++------
 net/sched/sch_sfb.c       |   13 +++++++------
 net/sched/sch_sfq.c       |   19 ++++++++++---------
 net/sched/sch_tbf.c       |   11 ++++++-----
 32 files changed, 204 insertions(+), 138 deletions(-)

diff --git a/include/net/codel.h b/include/net/codel.h
index fe0eab3..6c8911c 100644
--- a/include/net/codel.h
+++ b/include/net/codel.h
@@ -228,13 +228,13 @@ static bool codel_should_drop(const struct sk_buff *skb,
 	}
 
 	vars->ldelay = now - codel_get_enqueue_time(skb);
-	sch->qstats.backlog -= qdisc_pkt_len(skb);
+	sch->qstats_qdisc.qstats.backlog -= qdisc_pkt_len(skb);
 
 	if (unlikely(qdisc_pkt_len(skb) > stats->maxpacket))
 		stats->maxpacket = qdisc_pkt_len(skb);
 
 	if (codel_time_before(vars->ldelay, params->target) ||
-	    sch->qstats.backlog <= stats->maxpacket) {
+	    sch->qstats_qdisc.qstats.backlog <= stats->maxpacket) {
 		/* went below - stay below for at least interval */
 		vars->first_above_time = 0;
 		return false;
diff --git a/include/net/gen_stats.h b/include/net/gen_stats.h
index dec4312..c9a6e38 100644
--- a/include/net/gen_stats.h
+++ b/include/net/gen_stats.h
@@ -44,6 +44,7 @@ int gnet_stats_copy_rate_est(struct gnet_dump *d,
 			     const struct gnet_stats_basic_cpu *cpu_b,
 			     struct gnet_stats_rate_est64 *r);
 int gnet_stats_copy_queue(struct gnet_dump *d, struct gnet_stats_queue *q);
+int gnet_stats_copy_queue_cpu(struct gnet_dump *d, struct gnet_stats_queue *q);
 int gnet_stats_copy_app(struct gnet_dump *d, void *st, int len);
 
 int gnet_stats_finish_copy(struct gnet_dump *d);
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 1a55e19..6d67a27 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -92,7 +92,10 @@ struct Qdisc {
 		struct gnet_stats_basic_cpu __percpu *cpu_bstats;
 	} bstats_qdisc;
 	unsigned int		__state;
-	struct gnet_stats_queue	qstats;
+	union {
+		struct gnet_stats_queue qstats;
+		struct gnet_stats_queue __percpu *cpu_qstats;
+	} qstats_qdisc;
 	struct rcu_head		rcu_head;
 	int			padded;
 	atomic_t		refcnt;
@@ -546,7 +549,7 @@ static inline int __qdisc_enqueue_tail(struct sk_buff *skb, struct Qdisc *sch,
 				       struct sk_buff_head *list)
 {
 	__skb_queue_tail(list, skb);
-	sch->qstats.backlog += qdisc_pkt_len(skb);
+	sch->qstats_qdisc.qstats.backlog += qdisc_pkt_len(skb);
 
 	return NET_XMIT_SUCCESS;
 }
@@ -562,7 +565,7 @@ static inline struct sk_buff *__qdisc_dequeue_head(struct Qdisc *sch,
 	struct sk_buff *skb = __skb_dequeue(list);
 
 	if (likely(skb != NULL)) {
-		sch->qstats.backlog -= qdisc_pkt_len(skb);
+		sch->qstats_qdisc.qstats.backlog -= qdisc_pkt_len(skb);
 		qdisc_bstats_update(sch, skb);
 	}
 
@@ -581,7 +584,7 @@ static inline unsigned int __qdisc_queue_drop_head(struct Qdisc *sch,
 
 	if (likely(skb != NULL)) {
 		unsigned int len = qdisc_pkt_len(skb);
-		sch->qstats.backlog -= len;
+		sch->qstats_qdisc.qstats.backlog -= len;
 		kfree_skb(skb);
 		return len;
 	}
@@ -600,7 +603,7 @@ static inline struct sk_buff *__qdisc_dequeue_tail(struct Qdisc *sch,
 	struct sk_buff *skb = __skb_dequeue_tail(list);
 
 	if (likely(skb != NULL))
-		sch->qstats.backlog -= qdisc_pkt_len(skb);
+		sch->qstats_qdisc.qstats.backlog -= qdisc_pkt_len(skb);
 
 	return skb;
 }
@@ -657,7 +660,7 @@ static inline void __qdisc_reset_queue(struct Qdisc *sch,
 static inline void qdisc_reset_queue(struct Qdisc *sch)
 {
 	__qdisc_reset_queue(sch, &sch->q);
-	sch->qstats.backlog = 0;
+	sch->qstats_qdisc.qstats.backlog = 0;
 }
 
 static inline unsigned int __qdisc_queue_drop(struct Qdisc *sch,
@@ -682,14 +685,14 @@ static inline unsigned int qdisc_queue_drop(struct Qdisc *sch)
 static inline int qdisc_drop(struct sk_buff *skb, struct Qdisc *sch)
 {
 	kfree_skb(skb);
-	sch->qstats.drops++;
+	sch->qstats_qdisc.qstats.drops++;
 
 	return NET_XMIT_DROP;
 }
 
 static inline int qdisc_reshape_fail(struct sk_buff *skb, struct Qdisc *sch)
 {
-	sch->qstats.drops++;
+	sch->qstats_qdisc.qstats.drops++;
 
 #ifdef CONFIG_NET_CLS_ACT
 	if (sch->reshape_fail == NULL || sch->reshape_fail(skb, sch))
diff --git a/net/core/gen_stats.c b/net/core/gen_stats.c
index b51146a..5d279de 100644
--- a/net/core/gen_stats.c
+++ b/net/core/gen_stats.c
@@ -22,7 +22,7 @@
 #include <linux/gen_stats.h>
 #include <net/netlink.h>
 #include <net/gen_stats.h>
-
+#include <uapi/linux/gen_stats.h>
 
 static inline int
 gnet_stats_copy(struct gnet_dump *d, int type, void *buf, int size)
@@ -244,6 +244,34 @@ gnet_stats_copy_queue(struct gnet_dump *d, struct gnet_stats_queue *q)
 }
 EXPORT_SYMBOL(gnet_stats_copy_queue);
 
+static void
+__gnet_stats_copy_queue_cpu(struct gnet_stats_queue *qstats,
+			    struct gnet_stats_queue *q)
+{
+	int i;
+
+	for_each_possible_cpu(i) {
+		struct gnet_stats_queue *qcpu = per_cpu_ptr(q, i);
+
+		qstats->qlen += qcpu->qlen;
+		qstats->backlog += qcpu->backlog;
+		qstats->drops += qcpu->drops;
+		qstats->requeues += qcpu->requeues;
+		qstats->overlimits += qcpu->overlimits;
+	}
+}
+
+int
+gnet_stats_copy_queue_cpu(struct gnet_dump *d, struct gnet_stats_queue *q)
+{
+	struct gnet_stats_queue qstats = {0};
+
+	__gnet_stats_copy_queue_cpu(&qstats, q);
+	return gnet_stats_copy_queue(d, &qstats);
+}
+EXPORT_SYMBOL(gnet_stats_copy_queue_cpu);
+
+
 /**
  * gnet_stats_copy_app - copy application specific statistics into statistics TLV
  * @d: dumping handle
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index bf14313..02cbbbe 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -763,7 +763,7 @@ void qdisc_tree_decrease_qlen(struct Qdisc *sch, unsigned int n)
 			cops->put(sch, cl);
 		}
 		sch->q.qlen -= n;
-		sch->qstats.drops += drops;
+		sch->qstats_qdisc.qstats.drops += drops;
 	}
 }
 EXPORT_SYMBOL(qdisc_tree_decrease_qlen);
@@ -1340,7 +1340,6 @@ static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
 		goto nla_put_failure;
 	if (q->ops->dump && q->ops->dump(q, skb) < 0)
 		goto nla_put_failure;
-	q->qstats.qlen = q->q.qlen;
 
 	stab = rtnl_dereference(q->stab);
 	if (stab && qdisc_dump_stab(skb, stab) < 0)
@@ -1360,18 +1359,29 @@ static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
 		err = gnet_stats_copy_rate_est(&d, NULL,
 					       q->bstats_qdisc.cpu_bstats,
 					       &q->rate_est);
+
+		if (err < 0)
+			goto nla_put_failure;
+
+		q->qstats_qdisc.qstats.qlen = q->q.qlen;
+		err = gnet_stats_copy_queue_cpu(&d, q->qstats_qdisc.cpu_qstats);
 	} else {
 		err = gnet_stats_copy_basic(&d, &q->bstats_qdisc.bstats);
 		if (err < 0)
 			goto nla_put_failure;
+
+		q->qstats_qdisc.qstats.qlen = q->q.qlen;
 		err = gnet_stats_copy_rate_est(&d,
 					       &q->bstats_qdisc.bstats, NULL,
 					       &q->rate_est);
+		if (err < 0)
+			goto nla_put_failure;
+
+		err = gnet_stats_copy_queue(&d, &q->qstats_qdisc.qstats);
 	}
 
-	if (err < 0 ||
-	    gnet_stats_copy_queue(&d, &q->qstats) < 0)
-			goto nla_put_failure;
+	if (err < 0)
+		goto nla_put_failure;
 
 	if (gnet_stats_finish_copy(&d) < 0)
 		goto nla_put_failure;
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 71e7e72..eab73c8 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -420,7 +420,7 @@ done:
 	if (ret != NET_XMIT_SUCCESS) {
 drop: __maybe_unused
 		if (net_xmit_drop_count(ret)) {
-			sch->qstats.drops++;
+			sch->qstats_qdisc.qstats.drops++;
 			if (flow)
 				flow->qstats.drops++;
 		}
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 9ecab38..e815ac4 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -384,7 +384,7 @@ cbq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 #endif
 	if (cl == NULL) {
 		if (ret & __NET_XMIT_BYPASS)
-			sch->qstats.drops++;
+			sch->qstats_qdisc.qstats.drops++;
 		kfree_skb(skb);
 		return ret;
 	}
@@ -402,7 +402,7 @@ cbq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	}
 
 	if (net_xmit_drop_count(ret)) {
-		sch->qstats.drops++;
+		sch->qstats_qdisc.qstats.drops++;
 		cbq_mark_toplevel(q, cl);
 		cl->qstats.drops++;
 	}
@@ -657,11 +657,11 @@ static int cbq_reshape_fail(struct sk_buff *skb, struct Qdisc *child)
 			return 0;
 		}
 		if (net_xmit_drop_count(ret))
-			sch->qstats.drops++;
+			sch->qstats_qdisc.qstats.drops++;
 		return 0;
 	}
 
-	sch->qstats.drops++;
+	sch->qstats_qdisc.qstats.drops++;
 	return -1;
 }
 #endif
@@ -1014,7 +1014,7 @@ cbq_dequeue(struct Qdisc *sch)
 	 */
 
 	if (sch->q.qlen) {
-		sch->qstats.overlimits++;
+		sch->qstats_qdisc.qstats.overlimits++;
 		if (q->wd_expires)
 			qdisc_watchdog_schedule(&q->watchdog,
 						now + q->wd_expires);
diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
index 31b2d75..7dc89d9 100644
--- a/net/sched/sch_choke.c
+++ b/net/sched/sch_choke.c
@@ -127,7 +127,7 @@ static void choke_drop_by_idx(struct Qdisc *sch, unsigned int idx)
 	if (idx == q->tail)
 		choke_zap_tail_holes(q);
 
-	sch->qstats.backlog -= qdisc_pkt_len(skb);
+	sch->qstats_qdisc.qstats.backlog -= qdisc_pkt_len(skb);
 	qdisc_drop(skb, sch);
 	qdisc_tree_decrease_qlen(sch, 1);
 	--sch->q.qlen;
@@ -296,7 +296,7 @@ static int choke_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		if (q->vars.qavg > p->qth_max) {
 			q->vars.qcount = -1;
 
-			sch->qstats.overlimits++;
+			sch->qstats_qdisc.qstats.overlimits++;
 			if (use_harddrop(q) || !use_ecn(q) ||
 			    !INET_ECN_set_ce(skb)) {
 				q->stats.forced_drop++;
@@ -309,7 +309,7 @@ static int choke_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 				q->vars.qcount = 0;
 				q->vars.qR = red_random(p);
 
-				sch->qstats.overlimits++;
+				sch->qstats_qdisc.qstats.overlimits++;
 				if (!use_ecn(q) || !INET_ECN_set_ce(skb)) {
 					q->stats.prob_drop++;
 					goto congestion_drop;
@@ -326,7 +326,7 @@ static int choke_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		q->tab[q->tail] = skb;
 		q->tail = (q->tail + 1) & q->tab_mask;
 		++sch->q.qlen;
-		sch->qstats.backlog += qdisc_pkt_len(skb);
+		sch->qstats_qdisc.qstats.backlog += qdisc_pkt_len(skb);
 		return NET_XMIT_SUCCESS;
 	}
 
@@ -339,7 +339,7 @@ congestion_drop:
 
 other_drop:
 	if (ret & __NET_XMIT_BYPASS)
-		sch->qstats.drops++;
+		sch->qstats_qdisc.qstats.drops++;
 	kfree_skb(skb);
 	return ret;
 }
@@ -359,7 +359,7 @@ static struct sk_buff *choke_dequeue(struct Qdisc *sch)
 	q->tab[q->head] = NULL;
 	choke_zap_head_holes(q);
 	--sch->q.qlen;
-	sch->qstats.backlog -= qdisc_pkt_len(skb);
+	sch->qstats_qdisc.qstats.backlog -= qdisc_pkt_len(skb);
 	qdisc_bstats_update(sch, skb);
 
 	return skb;
@@ -407,6 +407,7 @@ static void choke_free(void *addr)
 
 static int choke_change(struct Qdisc *sch, struct nlattr *opt)
 {
+	struct gnet_stats_queue *qstats = &sch->qstats_qdisc.qstats;
 	struct choke_sched_data *q = qdisc_priv(sch);
 	struct nlattr *tb[TCA_CHOKE_MAX + 1];
 	const struct tc_red_qopt *ctl;
@@ -459,7 +460,7 @@ static int choke_change(struct Qdisc *sch, struct nlattr *opt)
 					ntab[tail++] = skb;
 					continue;
 				}
-				sch->qstats.backlog -= qdisc_pkt_len(skb);
+				qstats->backlog -= qdisc_pkt_len(skb);
 				--sch->q.qlen;
 				qdisc_drop(skb, sch);
 			}
diff --git a/net/sched/sch_codel.c b/net/sched/sch_codel.c
index 2f9ab17..47a387e 100644
--- a/net/sched/sch_codel.c
+++ b/net/sched/sch_codel.c
@@ -149,7 +149,7 @@ static int codel_change(struct Qdisc *sch, struct nlattr *opt)
 	while (sch->q.qlen > sch->limit) {
 		struct sk_buff *skb = __skb_dequeue(&sch->q);
 
-		sch->qstats.backlog -= qdisc_pkt_len(skb);
+		sch->qstats_qdisc.qstats.backlog -= qdisc_pkt_len(skb);
 		qdisc_drop(skb, sch);
 	}
 	qdisc_tree_decrease_qlen(sch, qlen - sch->q.qlen);
diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
index b58971a..9547792 100644
--- a/net/sched/sch_drr.c
+++ b/net/sched/sch_drr.c
@@ -279,12 +279,12 @@ static int drr_dump_class_stats(struct Qdisc *sch, unsigned long arg,
 	memset(&xstats, 0, sizeof(xstats));
 	if (cl->qdisc->q.qlen) {
 		xstats.deficit = cl->deficit;
-		cl->qdisc->qstats.qlen = cl->qdisc->q.qlen;
+		cl->qdisc->qstats_qdisc.qstats.qlen = cl->qdisc->q.qlen;
 	}
 
 	if (gnet_stats_copy_basic(d, &cl->bstats) < 0 ||
 	    gnet_stats_copy_rate_est(d, &cl->bstats, NULL, &cl->rate_est) < 0 ||
-	    gnet_stats_copy_queue(d, &cl->qdisc->qstats) < 0)
+	    gnet_stats_copy_queue(d, &cl->qdisc->qstats_qdisc.qstats) < 0)
 		return -1;
 
 	return gnet_stats_copy_app(d, &xstats, sizeof(xstats));
@@ -359,7 +359,7 @@ static int drr_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	cl = drr_classify(skb, sch, &err);
 	if (cl == NULL) {
 		if (err & __NET_XMIT_BYPASS)
-			sch->qstats.drops++;
+			sch->qstats_qdisc.qstats.drops++;
 		kfree_skb(skb);
 		return err;
 	}
@@ -368,7 +368,7 @@ static int drr_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	if (unlikely(err != NET_XMIT_SUCCESS)) {
 		if (net_xmit_drop_count(err)) {
 			cl->qstats.drops++;
-			sch->qstats.drops++;
+			sch->qstats_qdisc.qstats.drops++;
 		}
 		return err;
 	}
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 6b84bd4..405a72d 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -258,7 +258,7 @@ static int dsmark_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	err = qdisc_enqueue(skb, p->q);
 	if (err != NET_XMIT_SUCCESS) {
 		if (net_xmit_drop_count(err))
-			sch->qstats.drops++;
+			sch->qstats_qdisc.qstats.drops++;
 		return err;
 	}
 
diff --git a/net/sched/sch_fifo.c b/net/sched/sch_fifo.c
index e15a9eb..264ae79 100644
--- a/net/sched/sch_fifo.c
+++ b/net/sched/sch_fifo.c
@@ -21,7 +21,9 @@
 
 static int bfifo_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
-	if (likely(sch->qstats.backlog + qdisc_pkt_len(skb) <= sch->limit))
+	u32 limit = sch->qstats_qdisc.qstats.backlog + qdisc_pkt_len(skb);
+
+	if (likely(limit <= sch->limit))
 		return qdisc_enqueue_tail(skb, sch);
 
 	return qdisc_reshape_fail(skb, sch);
@@ -42,7 +44,7 @@ static int pfifo_tail_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 	/* queue full, remove one skb to fulfill the limit */
 	__qdisc_queue_drop_head(sch, &sch->q);
-	sch->qstats.drops++;
+	sch->qstats_qdisc.qstats.drops++;
 	qdisc_enqueue_tail(skb, sch);
 
 	return NET_XMIT_CN;
diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index 23c682b..64f946d 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -290,7 +290,7 @@ static struct sk_buff *fq_dequeue_head(struct Qdisc *sch, struct fq_flow *flow)
 		flow->head = skb->next;
 		skb->next = NULL;
 		flow->qlen--;
-		sch->qstats.backlog -= qdisc_pkt_len(skb);
+		sch->qstats_qdisc.qstats.backlog -= qdisc_pkt_len(skb);
 		sch->q.qlen--;
 	}
 	return skb;
@@ -371,7 +371,7 @@ static int fq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	f->qlen++;
 	if (skb_is_retransmit(skb))
 		q->stat_tcp_retrans++;
-	sch->qstats.backlog += qdisc_pkt_len(skb);
+	sch->qstats_qdisc.qstats.backlog += qdisc_pkt_len(skb);
 	if (fq_flow_is_detached(f)) {
 		fq_flow_add_tail(&q->new_flows, f);
 		if (time_after(jiffies, f->age + q->flow_refill_delay))
diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index d37eb06..8f71e67 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -163,8 +163,8 @@ static unsigned int fq_codel_drop(struct Qdisc *sch)
 	q->backlogs[idx] -= len;
 	kfree_skb(skb);
 	sch->q.qlen--;
-	sch->qstats.drops++;
-	sch->qstats.backlog -= len;
+	sch->qstats_qdisc.qstats.drops++;
+	sch->qstats_qdisc.qstats.backlog -= len;
 	flow->dropped++;
 	return idx;
 }
@@ -179,7 +179,7 @@ static int fq_codel_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	idx = fq_codel_classify(skb, sch, &ret);
 	if (idx == 0) {
 		if (ret & __NET_XMIT_BYPASS)
-			sch->qstats.drops++;
+			sch->qstats_qdisc.qstats.drops++;
 		kfree_skb(skb);
 		return ret;
 	}
@@ -189,7 +189,7 @@ static int fq_codel_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	flow = &q->flows[idx];
 	flow_queue_add(flow, skb);
 	q->backlogs[idx] += qdisc_pkt_len(skb);
-	sch->qstats.backlog += qdisc_pkt_len(skb);
+	sch->qstats_qdisc.qstats.backlog += qdisc_pkt_len(skb);
 
 	if (list_empty(&flow->flowchain)) {
 		list_add_tail(&flow->flowchain, &q->new_flows);
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 27033d0..b5870a1 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -49,7 +49,7 @@ static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
 {
 	skb_dst_force(skb);
 	q->gso_skb = skb;
-	q->qstats.requeues++;
+	q->qstats_qdisc.qstats.requeues++;
 	q->q.qlen++;	/* it's still part of the queue */
 	__netif_schedule(q);
 
@@ -495,7 +495,7 @@ static void pfifo_fast_reset(struct Qdisc *qdisc)
 		__qdisc_reset_queue(qdisc, band2list(priv, prio));
 
 	priv->bitmap = 0;
-	qdisc->qstats.backlog = 0;
+	qdisc->qstats_qdisc.qstats.backlog = 0;
 	qdisc->q.qlen = 0;
 }
 
diff --git a/net/sched/sch_gred.c b/net/sched/sch_gred.c
index 12cbc09..198c44c 100644
--- a/net/sched/sch_gred.c
+++ b/net/sched/sch_gred.c
@@ -115,7 +115,7 @@ static inline unsigned int gred_backlog(struct gred_sched *table,
 					struct Qdisc *sch)
 {
 	if (gred_wred_mode(table))
-		return sch->qstats.backlog;
+		return sch->qstats_qdisc.qstats.backlog;
 	else
 		return q->backlog;
 }
@@ -209,7 +209,7 @@ static int gred_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		break;
 
 	case RED_PROB_MARK:
-		sch->qstats.overlimits++;
+		sch->qstats_qdisc.qstats.overlimits++;
 		if (!gred_use_ecn(t) || !INET_ECN_set_ce(skb)) {
 			q->stats.prob_drop++;
 			goto congestion_drop;
@@ -219,7 +219,7 @@ static int gred_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		break;
 
 	case RED_HARD_MARK:
-		sch->qstats.overlimits++;
+		sch->qstats_qdisc.qstats.overlimits++;
 		if (gred_use_harddrop(t) || !gred_use_ecn(t) ||
 		    !INET_ECN_set_ce(skb)) {
 			q->stats.forced_drop++;
@@ -261,7 +261,7 @@ static struct sk_buff *gred_dequeue(struct Qdisc *sch)
 			q->backlog -= qdisc_pkt_len(skb);
 
 			if (gred_wred_mode(t)) {
-				if (!sch->qstats.backlog)
+				if (!sch->qstats_qdisc.qstats.backlog)
 					red_start_of_idle_period(&t->wred_set);
 			} else {
 				if (!q->backlog)
@@ -294,7 +294,7 @@ static unsigned int gred_drop(struct Qdisc *sch)
 			q->stats.other++;
 
 			if (gred_wred_mode(t)) {
-				if (!sch->qstats.backlog)
+				if (!sch->qstats_qdisc.qstats.backlog)
 					red_start_of_idle_period(&t->wred_set);
 			} else {
 				if (!q->backlog)
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index d8f928c..f98c972 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1373,7 +1373,7 @@ hfsc_dump_class_stats(struct Qdisc *sch, unsigned long arg,
 	struct tc_hfsc_stats xstats;
 
 	cl->qstats.qlen = cl->qdisc->q.qlen;
-	cl->qstats.backlog = cl->qdisc->qstats.backlog;
+	cl->qstats.backlog = cl->qdisc->qstats_qdisc.qstats.backlog;
 	xstats.level   = cl->level;
 	xstats.period  = cl->cl_vtperiod;
 	xstats.work    = cl->cl_total;
@@ -1565,16 +1565,17 @@ hfsc_destroy_qdisc(struct Qdisc *sch)
 static int
 hfsc_dump_qdisc(struct Qdisc *sch, struct sk_buff *skb)
 {
+	struct gnet_stats_queue *qstats = &sch->qstats_qdisc.qstats;
 	struct hfsc_sched *q = qdisc_priv(sch);
 	unsigned char *b = skb_tail_pointer(skb);
 	struct tc_hfsc_qopt qopt;
 	struct hfsc_class *cl;
 	unsigned int i;
 
-	sch->qstats.backlog = 0;
+	qstats->backlog = 0;
 	for (i = 0; i < q->clhash.hashsize; i++) {
 		hlist_for_each_entry(cl, &q->clhash.hash[i], cl_common.hnode)
-			sch->qstats.backlog += cl->qdisc->qstats.backlog;
+			qstats->backlog += cl->qdisc->qstats_qdisc.qstats.backlog;
 	}
 
 	qopt.defcls = q->defcls;
@@ -1596,7 +1597,7 @@ hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	cl = hfsc_classify(skb, sch, &err);
 	if (cl == NULL) {
 		if (err & __NET_XMIT_BYPASS)
-			sch->qstats.drops++;
+			sch->qstats_qdisc.qstats.drops++;
 		kfree_skb(skb);
 		return err;
 	}
@@ -1605,7 +1606,7 @@ hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	if (unlikely(err != NET_XMIT_SUCCESS)) {
 		if (net_xmit_drop_count(err)) {
 			cl->qstats.drops++;
-			sch->qstats.drops++;
+			sch->qstats_qdisc.qstats.drops++;
 		}
 		return err;
 	}
@@ -1648,7 +1649,7 @@ hfsc_dequeue(struct Qdisc *sch)
 		 */
 		cl = vttree_get_minvt(&q->root, cur_time);
 		if (cl == NULL) {
-			sch->qstats.overlimits++;
+			sch->qstats_qdisc.qstats.overlimits++;
 			hfsc_schedule_watchdog(sch);
 			return NULL;
 		}
@@ -1703,7 +1704,7 @@ hfsc_drop(struct Qdisc *sch)
 				list_move_tail(&cl->dlist, &q->droplist);
 			}
 			cl->qstats.drops++;
-			sch->qstats.drops++;
+			sch->qstats_qdisc.qstats.drops++;
 			sch->q.qlen--;
 			return len;
 		}
diff --git a/net/sched/sch_hhf.c b/net/sched/sch_hhf.c
index edee03d..7cf4196 100644
--- a/net/sched/sch_hhf.c
+++ b/net/sched/sch_hhf.c
@@ -376,8 +376,8 @@ static unsigned int hhf_drop(struct Qdisc *sch)
 		struct sk_buff *skb = dequeue_head(bucket);
 
 		sch->q.qlen--;
-		sch->qstats.drops++;
-		sch->qstats.backlog -= qdisc_pkt_len(skb);
+		sch->qstats_qdisc.qstats.drops++;
+		sch->qstats_qdisc.qstats.backlog -= qdisc_pkt_len(skb);
 		kfree_skb(skb);
 	}
 
@@ -395,7 +395,7 @@ static int hhf_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 	bucket = &q->buckets[idx];
 	bucket_add(bucket, skb);
-	sch->qstats.backlog += qdisc_pkt_len(skb);
+	sch->qstats_qdisc.qstats.backlog += qdisc_pkt_len(skb);
 
 	if (list_empty(&bucket->bucketchain)) {
 		unsigned int weight;
@@ -457,7 +457,7 @@ begin:
 	if (bucket->head) {
 		skb = dequeue_head(bucket);
 		sch->q.qlen--;
-		sch->qstats.backlog -= qdisc_pkt_len(skb);
+		sch->qstats_qdisc.qstats.backlog -= qdisc_pkt_len(skb);
 	}
 
 	if (!skb) {
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 2bbed9c..2cb80e9 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -586,13 +586,13 @@ static int htb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 #ifdef CONFIG_NET_CLS_ACT
 	} else if (!cl) {
 		if (ret & __NET_XMIT_BYPASS)
-			sch->qstats.drops++;
+			sch->qstats_qdisc.qstats.drops++;
 		kfree_skb(skb);
 		return ret;
 #endif
 	} else if ((ret = qdisc_enqueue(skb, cl->un.leaf.q)) != NET_XMIT_SUCCESS) {
 		if (net_xmit_drop_count(ret)) {
-			sch->qstats.drops++;
+			sch->qstats_qdisc.qstats.drops++;
 			cl->qstats.drops++;
 		}
 		return ret;
@@ -925,7 +925,7 @@ ok:
 				goto ok;
 		}
 	}
-	sch->qstats.overlimits++;
+	sch->qstats_qdisc.qstats.overlimits++;
 	if (likely(next_event > q->now)) {
 		if (!test_bit(__QDISC_STATE_DEACTIVATED,
 			      &qdisc_root_sleeping(q->watchdog.qdisc)->state)) {
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index 5700c27..2423d7b 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -58,6 +58,7 @@ static struct tcf_proto **ingress_find_tcf(struct Qdisc *sch, unsigned long cl)
 static int ingress_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct ingress_qdisc_data *p = qdisc_priv(sch);
+	struct gnet_stats_queue *qstats;
 	struct tcf_result res;
 	struct tcf_proto *fl = rcu_dereference_bh(p->filter_list);
 	int result;
@@ -68,7 +69,8 @@ static int ingress_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	switch (result) {
 	case TC_ACT_SHOT:
 		result = TC_ACT_SHOT;
-		sch->qstats.drops++;
+		qstats = this_cpu_ptr(sch->qstats_qdisc.cpu_qstats);
+		qstats->drops++;
 		break;
 	case TC_ACT_STOLEN:
 	case TC_ACT_QUEUED:
diff --git a/net/sched/sch_mq.c b/net/sched/sch_mq.c
index e96a41f..402460d 100644
--- a/net/sched/sch_mq.c
+++ b/net/sched/sch_mq.c
@@ -98,6 +98,7 @@ static void mq_attach(struct Qdisc *sch)
 
 static int mq_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
+	struct gnet_stats_queue *qstats = &sch->qstats_qdisc.qstats;
 	struct gnet_stats_basic_packed *bstats = &sch->bstats_qdisc.bstats;
 	struct net_device *dev = qdisc_dev(sch);
 	struct Qdisc *qdisc;
@@ -105,20 +106,24 @@ static int mq_dump(struct Qdisc *sch, struct sk_buff *skb)
 
 	sch->q.qlen = 0;
 	memset(bstats, 0, sizeof(sch->bstats_qdisc));
-	memset(&sch->qstats, 0, sizeof(sch->qstats));
+	memset(qstats, 0, sizeof(sch->qstats_qdisc.qstats));
 
 	for (ntx = 0; ntx < dev->num_tx_queues; ntx++) {
+		struct gnet_stats_queue *q_qstats;
+
 		qdisc = netdev_get_tx_queue(dev, ntx)->qdisc_sleeping;
 		spin_lock_bh(qdisc_lock(qdisc));
-		sch->q.qlen		+= qdisc->q.qlen;
+		q_qstats = &qdisc->qstats_qdisc.qstats;
 
+		sch->q.qlen		+= qdisc->q.qlen;
 		bstats->bytes		+= qdisc->bstats_qdisc.bstats.bytes;
 		bstats->packets		+= qdisc->bstats_qdisc.bstats.packets;
-		sch->qstats.qlen	+= qdisc->qstats.qlen;
-		sch->qstats.backlog	+= qdisc->qstats.backlog;
-		sch->qstats.drops	+= qdisc->qstats.drops;
-		sch->qstats.requeues	+= qdisc->qstats.requeues;
-		sch->qstats.overlimits	+= qdisc->qstats.overlimits;
+		qstats->qlen		+= q_qstats->qlen;
+		qstats->backlog		+= q_qstats->backlog;
+		qstats->drops		+= q_qstats->drops;
+		qstats->requeues	+= q_qstats->requeues;
+		qstats->overlimits	+= q_qstats->overlimits;
+
 		spin_unlock_bh(qdisc_lock(qdisc));
 	}
 	return 0;
@@ -202,9 +207,9 @@ static int mq_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 	struct netdev_queue *dev_queue = mq_queue_get(sch, cl);
 
 	sch = dev_queue->qdisc_sleeping;
-	sch->qstats.qlen = sch->q.qlen;
+	sch->qstats_qdisc.qstats.qlen = sch->q.qlen;
 	if (gnet_stats_copy_basic(d, &sch->bstats_qdisc.bstats) < 0 ||
-	    gnet_stats_copy_queue(d, &sch->qstats) < 0)
+	    gnet_stats_copy_queue(d, &sch->qstats_qdisc.qstats) < 0)
 		return -1;
 	return 0;
 }
diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
index 10f5d4a..6ec84a7 100644
--- a/net/sched/sch_mqprio.c
+++ b/net/sched/sch_mqprio.c
@@ -220,6 +220,7 @@ static int mqprio_graft(struct Qdisc *sch, unsigned long cl, struct Qdisc *new,
 static int mqprio_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
 	struct gnet_stats_basic_packed *bstats = &sch->bstats_qdisc.bstats;
+	struct gnet_stats_queue *qstats = &sch->qstats_qdisc.qstats;
 	struct net_device *dev = qdisc_dev(sch);
 	struct mqprio_sched *priv = qdisc_priv(sch);
 	unsigned char *b = skb_tail_pointer(skb);
@@ -229,20 +230,25 @@ static int mqprio_dump(struct Qdisc *sch, struct sk_buff *skb)
 
 	sch->q.qlen = 0;
 	memset(bstats, 0, sizeof(sch->bstats_qdisc.bstats));
-	memset(&sch->qstats, 0, sizeof(sch->qstats));
+	memset(qstats, 0, sizeof(sch->qstats_qdisc.qstats));
 
 	for (i = 0; i < dev->num_tx_queues; i++) {
+		struct gnet_stats_queue *q_qstats;
 
 		qdisc = rtnl_dereference(netdev_get_tx_queue(dev, i)->qdisc);
 		spin_lock_bh(qdisc_lock(qdisc));
 		sch->q.qlen		+= qdisc->q.qlen;
+
 		bstats->bytes		+= qdisc->bstats_qdisc.bstats.bytes;
 		bstats->packets		+= qdisc->bstats_qdisc.bstats.packets;
-		sch->qstats.qlen	+= qdisc->qstats.qlen;
-		sch->qstats.backlog	+= qdisc->qstats.backlog;
-		sch->qstats.drops	+= qdisc->qstats.drops;
-		sch->qstats.requeues	+= qdisc->qstats.requeues;
-		sch->qstats.overlimits	+= qdisc->qstats.overlimits;
+
+		q_qstats = &qdisc->qstats_qdisc.qstats;
+
+		qstats->qlen		+= q_qstats->qlen;
+		qstats->backlog		+= q_qstats->backlog;
+		qstats->drops		+= q_qstats->drops;
+		qstats->requeues	+= q_qstats->requeues;
+		qstats->overlimits	+= q_qstats->overlimits;
 		spin_unlock_bh(qdisc_lock(qdisc));
 	}
 
@@ -342,17 +348,19 @@ static int mqprio_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 		spin_unlock_bh(d->lock);
 
 		for (i = tc.offset; i < tc.offset + tc.count; i++) {
+			struct gnet_stats_queue *stats;
 			struct netdev_queue *q = netdev_get_tx_queue(dev, i);
 
 			qdisc = rtnl_dereference(q->qdisc);
 			spin_lock_bh(qdisc_lock(qdisc));
+			stats = &qdisc->qstats_qdisc.qstats;
 			bstats.bytes      += qdisc->bstats_qdisc.bstats.bytes;
 			bstats.packets    += qdisc->bstats_qdisc.bstats.packets;
-			qstats.qlen       += qdisc->qstats.qlen;
-			qstats.backlog    += qdisc->qstats.backlog;
-			qstats.drops      += qdisc->qstats.drops;
-			qstats.requeues   += qdisc->qstats.requeues;
-			qstats.overlimits += qdisc->qstats.overlimits;
+			qstats.qlen       += stats->qlen;
+			qstats.backlog    += stats->backlog;
+			qstats.drops      += stats->drops;
+			qstats.requeues   += stats->requeues;
+			qstats.overlimits += stats->overlimits;
 			spin_unlock_bh(qdisc_lock(qdisc));
 		}
 		/* Reclaim root sleeping lock before completing stats */
@@ -364,9 +372,9 @@ static int mqprio_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 		struct netdev_queue *dev_queue = mqprio_queue_get(sch, cl);
 
 		sch = dev_queue->qdisc_sleeping;
-		sch->qstats.qlen = sch->q.qlen;
+		sch->qstats_qdisc.qstats.qlen = sch->q.qlen;
 		if (gnet_stats_copy_basic(d, &sch->bstats_qdisc.bstats) < 0 ||
-		    gnet_stats_copy_queue(d, &sch->qstats) < 0)
+		    gnet_stats_copy_queue(d, &sch->qstats_qdisc.qstats) < 0)
 			return -1;
 	}
 	return 0;
diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
index 73e8b2b..dfc9c45 100644
--- a/net/sched/sch_multiq.c
+++ b/net/sched/sch_multiq.c
@@ -75,7 +75,7 @@ multiq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	if (qdisc == NULL) {
 
 		if (ret & __NET_XMIT_BYPASS)
-			sch->qstats.drops++;
+			sch->qstats_qdisc.qstats.drops++;
 		kfree_skb(skb);
 		return ret;
 	}
@@ -87,7 +87,7 @@ multiq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		return NET_XMIT_SUCCESS;
 	}
 	if (net_xmit_drop_count(ret))
-		sch->qstats.drops++;
+		sch->qstats_qdisc.qstats.drops++;
 	return ret;
 }
 
@@ -361,9 +361,9 @@ static int multiq_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 	struct Qdisc *cl_q;
 
 	cl_q = q->queues[cl - 1];
-	cl_q->qstats.qlen = cl_q->q.qlen;
+	cl_q->qstats_qdisc.qstats.qlen = cl_q->q.qlen;
 	if (gnet_stats_copy_basic(d, &cl_q->bstats_qdisc.bstats) < 0 ||
-	    gnet_stats_copy_queue(d, &cl_q->qstats) < 0)
+	    gnet_stats_copy_queue(d, &cl_q->qstats_qdisc.qstats) < 0)
 		return -1;
 
 	return 0;
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index f1669a00..b46272f 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -429,12 +429,12 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	/* Drop packet? */
 	if (loss_event(q)) {
 		if (q->ecn && INET_ECN_set_ce(skb))
-			sch->qstats.drops++; /* mark packet */
+			sch->qstats_qdisc.qstats.drops++; /* mark packet */
 		else
 			--count;
 	}
 	if (count == 0) {
-		sch->qstats.drops++;
+		sch->qstats_qdisc.qstats.drops++;
 		kfree_skb(skb);
 		return NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
 	}
@@ -478,7 +478,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	if (unlikely(skb_queue_len(&sch->q) >= sch->limit))
 		return qdisc_reshape_fail(skb, sch);
 
-	sch->qstats.backlog += qdisc_pkt_len(skb);
+	sch->qstats_qdisc.qstats.backlog += qdisc_pkt_len(skb);
 
 	cb = netem_skb_cb(skb);
 	if (q->gap == 0 ||		/* not doing reordering */
@@ -526,7 +526,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		q->counter = 0;
 
 		__skb_queue_head(&sch->q, skb);
-		sch->qstats.requeues++;
+		sch->qstats_qdisc.qstats.requeues++;
 	}
 
 	return NET_XMIT_SUCCESS;
@@ -550,20 +550,21 @@ static unsigned int netem_drop(struct Qdisc *sch)
 			skb->next = NULL;
 			skb->prev = NULL;
 			len = qdisc_pkt_len(skb);
-			sch->qstats.backlog -= len;
+			sch->qstats_qdisc.qstats.backlog -= len;
 			kfree_skb(skb);
 		}
 	}
 	if (!len && q->qdisc && q->qdisc->ops->drop)
 	    len = q->qdisc->ops->drop(q->qdisc);
 	if (len)
-		sch->qstats.drops++;
+		sch->qstats_qdisc.qstats.drops++;
 
 	return len;
 }
 
 static struct sk_buff *netem_dequeue(struct Qdisc *sch)
 {
+	struct gnet_stats_queue *qstats = &sch->qstats_qdisc.qstats;
 	struct netem_sched_data *q = qdisc_priv(sch);
 	struct sk_buff *skb;
 	struct rb_node *p;
@@ -575,7 +576,7 @@ tfifo_dequeue:
 	skb = __skb_dequeue(&sch->q);
 	if (skb) {
 deliver:
-		sch->qstats.backlog -= qdisc_pkt_len(skb);
+		qstats->backlog -= qdisc_pkt_len(skb);
 		qdisc_unthrottled(sch);
 		qdisc_bstats_update(sch, skb);
 		return skb;
@@ -610,7 +611,7 @@ deliver:
 
 				if (unlikely(err != NET_XMIT_SUCCESS)) {
 					if (net_xmit_drop_count(err)) {
-						sch->qstats.drops++;
+						qstats->drops++;
 						qdisc_tree_decrease_qlen(sch, 1);
 					}
 				}
diff --git a/net/sched/sch_pie.c b/net/sched/sch_pie.c
index fefeeb7..f454354 100644
--- a/net/sched/sch_pie.c
+++ b/net/sched/sch_pie.c
@@ -116,7 +116,7 @@ static bool drop_early(struct Qdisc *sch, u32 packet_size)
 	/* If we have fewer than 2 mtu-sized packets, disable drop_early,
 	 * similar to min_th in RED
 	 */
-	if (sch->qstats.backlog < 2 * mtu)
+	if (sch->qstats_qdisc.qstats.backlog < 2 * mtu)
 		return false;
 
 	/* If bytemode is turned on, use packet size to compute new
@@ -232,7 +232,7 @@ static int pie_change(struct Qdisc *sch, struct nlattr *opt)
 	while (sch->q.qlen > sch->limit) {
 		struct sk_buff *skb = __skb_dequeue(&sch->q);
 
-		sch->qstats.backlog -= qdisc_pkt_len(skb);
+		sch->qstats_qdisc.qstats.backlog -= qdisc_pkt_len(skb);
 		qdisc_drop(skb, sch);
 	}
 	qdisc_tree_decrease_qlen(sch, qlen - sch->q.qlen);
@@ -245,7 +245,7 @@ static void pie_process_dequeue(struct Qdisc *sch, struct sk_buff *skb)
 {
 
 	struct pie_sched_data *q = qdisc_priv(sch);
-	int qlen = sch->qstats.backlog;	/* current queue size in bytes */
+	int qlen = sch->qstats_qdisc.qstats.backlog;
 
 	/* If current queue is about 10 packets or more and dq_count is unset
 	 * we have enough packets to calculate the drain rate. Save
@@ -310,7 +310,7 @@ static void pie_process_dequeue(struct Qdisc *sch, struct sk_buff *skb)
 static void calculate_probability(struct Qdisc *sch)
 {
 	struct pie_sched_data *q = qdisc_priv(sch);
-	u32 qlen = sch->qstats.backlog;	/* queue size in bytes */
+	u32 qlen = sch->qstats_qdisc.qstats.backlog;
 	psched_time_t qdelay = 0;	/* in pschedtime */
 	psched_time_t qdelay_old = q->vars.qdelay;	/* in pschedtime */
 	s32 delta = 0;		/* determines the change in probability */
diff --git a/net/sched/sch_plug.c b/net/sched/sch_plug.c
index 89f8fcf..df2df95 100644
--- a/net/sched/sch_plug.c
+++ b/net/sched/sch_plug.c
@@ -90,7 +90,7 @@ static int plug_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct plug_sched_data *q = qdisc_priv(sch);
 
-	if (likely(sch->qstats.backlog + skb->len <= q->limit)) {
+	if (likely(sch->qstats_qdisc.qstats.backlog + skb->len <= q->limit)) {
 		if (!q->unplug_indefinite)
 			q->pkts_current_epoch++;
 		return qdisc_enqueue_tail(skb, sch);
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 1ae5d5b..ed34ccc 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -77,7 +77,7 @@ prio_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	if (qdisc == NULL) {
 
 		if (ret & __NET_XMIT_BYPASS)
-			sch->qstats.drops++;
+			sch->qstats_qdisc.qstats.drops++;
 		kfree_skb(skb);
 		return ret;
 	}
@@ -89,7 +89,7 @@ prio_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		return NET_XMIT_SUCCESS;
 	}
 	if (net_xmit_drop_count(ret))
-		sch->qstats.drops++;
+		sch->qstats_qdisc.qstats.drops++;
 	return ret;
 }
 
@@ -325,9 +325,9 @@ static int prio_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 	struct Qdisc *cl_q;
 
 	cl_q = q->queues[cl - 1];
-	cl_q->qstats.qlen = cl_q->q.qlen;
+	cl_q->qstats_qdisc.qstats.qlen = cl_q->q.qlen;
 	if (gnet_stats_copy_basic(d, &cl_q->bstats_qdisc.bstats) < 0 ||
-	    gnet_stats_copy_queue(d, &cl_q->qstats) < 0)
+	    gnet_stats_copy_queue(d, &cl_q->qstats_qdisc.qstats) < 0)
 		return -1;
 
 	return 0;
diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index 1cc4978..f4902cf 100644
--- a/net/sched/sch_qfq.c
+++ b/net/sched/sch_qfq.c
@@ -663,14 +663,14 @@ static int qfq_dump_class_stats(struct Qdisc *sch, unsigned long arg,
 	struct tc_qfq_stats xstats;
 
 	memset(&xstats, 0, sizeof(xstats));
-	cl->qdisc->qstats.qlen = cl->qdisc->q.qlen;
+	cl->qdisc->qstats_qdisc.qstats.qlen = cl->qdisc->q.qlen;
 
 	xstats.weight = cl->agg->class_weight;
 	xstats.lmax = cl->agg->lmax;
 
 	if (gnet_stats_copy_basic(d, &cl->bstats) < 0 ||
 	    gnet_stats_copy_rate_est(d, &cl->bstats, NULL, &cl->rate_est) < 0 ||
-	    gnet_stats_copy_queue(d, &cl->qdisc->qstats) < 0)
+	    gnet_stats_copy_queue(d, &cl->qdisc->qstats_qdisc.qstats) < 0)
 		return -1;
 
 	return gnet_stats_copy_app(d, &xstats, sizeof(xstats));
@@ -1228,7 +1228,7 @@ static int qfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	cl = qfq_classify(skb, sch, &err);
 	if (cl == NULL) {
 		if (err & __NET_XMIT_BYPASS)
-			sch->qstats.drops++;
+			sch->qstats_qdisc.qstats.drops++;
 		kfree_skb(skb);
 		return err;
 	}
@@ -1248,7 +1248,7 @@ static int qfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		pr_debug("qfq_enqueue: enqueue failed %d\n", err);
 		if (net_xmit_drop_count(err)) {
 			cl->qstats.drops++;
-			sch->qstats.drops++;
+			sch->qstats_qdisc.qstats.drops++;
 		}
 		return err;
 	}
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index 633e32d..01ec26b 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -64,7 +64,7 @@ static int red_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 	q->vars.qavg = red_calc_qavg(&q->parms,
 				     &q->vars,
-				     child->qstats.backlog);
+				     child->qstats_qdisc.qstats.backlog);
 
 	if (red_is_idling(&q->vars))
 		red_end_of_idle_period(&q->vars);
@@ -74,7 +74,7 @@ static int red_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		break;
 
 	case RED_PROB_MARK:
-		sch->qstats.overlimits++;
+		sch->qstats_qdisc.qstats.overlimits++;
 		if (!red_use_ecn(q) || !INET_ECN_set_ce(skb)) {
 			q->stats.prob_drop++;
 			goto congestion_drop;
@@ -84,7 +84,7 @@ static int red_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		break;
 
 	case RED_HARD_MARK:
-		sch->qstats.overlimits++;
+		sch->qstats_qdisc.qstats.overlimits++;
 		if (red_use_harddrop(q) || !red_use_ecn(q) ||
 		    !INET_ECN_set_ce(skb)) {
 			q->stats.forced_drop++;
@@ -100,7 +100,7 @@ static int red_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		sch->q.qlen++;
 	} else if (net_xmit_drop_count(ret)) {
 		q->stats.pdrop++;
-		sch->qstats.drops++;
+		sch->qstats_qdisc.qstats.drops++;
 	}
 	return ret;
 
@@ -142,7 +142,7 @@ static unsigned int red_drop(struct Qdisc *sch)
 
 	if (child->ops->drop && (len = child->ops->drop(child)) > 0) {
 		q->stats.other++;
-		sch->qstats.drops++;
+		sch->qstats_qdisc.qstats.drops++;
 		sch->q.qlen--;
 		return len;
 	}
@@ -256,6 +256,7 @@ static int red_init(struct Qdisc *sch, struct nlattr *opt)
 
 static int red_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
+	struct gnet_stats_queue *qstats = &sch->qstats_qdisc.qstats;
 	struct red_sched_data *q = qdisc_priv(sch);
 	struct nlattr *opts = NULL;
 	struct tc_red_qopt opt = {
@@ -268,7 +269,7 @@ static int red_dump(struct Qdisc *sch, struct sk_buff *skb)
 		.Scell_log	= q->parms.Scell_log,
 	};
 
-	sch->qstats.backlog = q->qdisc->qstats.backlog;
+	qstats->backlog = q->qdisc->qstats_qdisc.qstats.backlog;
 	opts = nla_nest_start(skb, TCA_OPTIONS);
 	if (opts == NULL)
 		goto nla_put_failure;
diff --git a/net/sched/sch_sfb.c b/net/sched/sch_sfb.c
index 5938d00..3de57da 100644
--- a/net/sched/sch_sfb.c
+++ b/net/sched/sch_sfb.c
@@ -290,7 +290,7 @@ static int sfb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	struct flow_keys keys;
 
 	if (unlikely(sch->q.qlen >= q->limit)) {
-		sch->qstats.overlimits++;
+		sch->qstats_qdisc.qstats.overlimits++;
 		q->stats.queuedrop++;
 		goto drop;
 	}
@@ -348,7 +348,7 @@ static int sfb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	sfb_skb_cb(skb)->hashes[slot] = 0;
 
 	if (unlikely(minqlen >= q->max)) {
-		sch->qstats.overlimits++;
+		sch->qstats_qdisc.qstats.overlimits++;
 		q->stats.bucketdrop++;
 		goto drop;
 	}
@@ -376,7 +376,7 @@ static int sfb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 			}
 		}
 		if (sfb_rate_limit(skb, q)) {
-			sch->qstats.overlimits++;
+			sch->qstats_qdisc.qstats.overlimits++;
 			q->stats.penaltydrop++;
 			goto drop;
 		}
@@ -411,7 +411,7 @@ enqueue:
 		increment_qlen(skb, q);
 	} else if (net_xmit_drop_count(ret)) {
 		q->stats.childdrop++;
-		sch->qstats.drops++;
+		sch->qstats_qdisc.qstats.drops++;
 	}
 	return ret;
 
@@ -420,7 +420,7 @@ drop:
 	return NET_XMIT_CN;
 other_drop:
 	if (ret & __NET_XMIT_BYPASS)
-		sch->qstats.drops++;
+		sch->qstats_qdisc.qstats.drops++;
 	kfree_skb(skb);
 	return ret;
 }
@@ -557,6 +557,7 @@ static int sfb_init(struct Qdisc *sch, struct nlattr *opt)
 
 static int sfb_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
+	struct gnet_stats_queue *qstats = &sch->qstats_qdisc.qstats;
 	struct sfb_sched_data *q = qdisc_priv(sch);
 	struct nlattr *opts;
 	struct tc_sfb_qopt opt = {
@@ -571,7 +572,7 @@ static int sfb_dump(struct Qdisc *sch, struct sk_buff *skb)
 		.penalty_burst = q->penalty_burst,
 	};
 
-	sch->qstats.backlog = q->qdisc->qstats.backlog;
+	qstats->backlog = q->qdisc->qstats_qdisc.qstats.backlog;
 	opts = nla_nest_start(skb, TCA_OPTIONS);
 	if (opts == NULL)
 		goto nla_put_failure;
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 13ec4eb..fdaebc7 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -336,8 +336,8 @@ drop:
 		sfq_dec(q, x);
 		kfree_skb(skb);
 		sch->q.qlen--;
-		sch->qstats.drops++;
-		sch->qstats.backlog -= len;
+		sch->qstats_qdisc.qstats.drops++;
+		sch->qstats_qdisc.qstats.backlog -= len;
 		return len;
 	}
 
@@ -384,7 +384,7 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	hash = sfq_classify(skb, sch, &ret);
 	if (hash == 0) {
 		if (ret & __NET_XMIT_BYPASS)
-			sch->qstats.drops++;
+			sch->qstats_qdisc.qstats.drops++;
 		kfree_skb(skb);
 		return ret;
 	}
@@ -414,7 +414,7 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 			break;
 
 		case RED_PROB_MARK:
-			sch->qstats.overlimits++;
+			sch->qstats_qdisc.qstats.overlimits++;
 			if (sfq_prob_mark(q)) {
 				/* We know we have at least one packet in queue */
 				if (sfq_headdrop(q) &&
@@ -431,7 +431,7 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 			goto congestion_drop;
 
 		case RED_HARD_MARK:
-			sch->qstats.overlimits++;
+			sch->qstats_qdisc.qstats.overlimits++;
 			if (sfq_hard_mark(q)) {
 				/* We know we have at least one packet in queue */
 				if (sfq_headdrop(q) &&
@@ -457,7 +457,7 @@ congestion_drop:
 		/* We know we have at least one packet in queue */
 		head = slot_dequeue_head(slot);
 		delta = qdisc_pkt_len(head) - qdisc_pkt_len(skb);
-		sch->qstats.backlog -= delta;
+		sch->qstats_qdisc.qstats.backlog -= delta;
 		slot->backlog -= delta;
 		qdisc_drop(head, sch);
 
@@ -466,7 +466,7 @@ congestion_drop:
 	}
 
 enqueue:
-	sch->qstats.backlog += qdisc_pkt_len(skb);
+	sch->qstats_qdisc.qstats.backlog += qdisc_pkt_len(skb);
 	slot->backlog += qdisc_pkt_len(skb);
 	slot_queue_add(slot, skb);
 	sfq_inc(q, x);
@@ -525,7 +525,7 @@ next_slot:
 	sfq_dec(q, a);
 	qdisc_bstats_update(sch, skb);
 	sch->q.qlen--;
-	sch->qstats.backlog -= qdisc_pkt_len(skb);
+	sch->qstats_qdisc.qstats.backlog -= qdisc_pkt_len(skb);
 	slot->backlog -= qdisc_pkt_len(skb);
 	/* Is the slot empty? */
 	if (slot->qlen == 0) {
@@ -559,6 +559,7 @@ sfq_reset(struct Qdisc *sch)
  */
 static void sfq_rehash(struct Qdisc *sch)
 {
+	struct gnet_stats_queue *qstats = &sch->qstats_qdisc.qstats;
 	struct sfq_sched_data *q = qdisc_priv(sch);
 	struct sk_buff *skb;
 	int i;
@@ -591,7 +592,7 @@ static void sfq_rehash(struct Qdisc *sch)
 		if (x == SFQ_EMPTY_SLOT) {
 			x = q->dep[0].next; /* get a free slot */
 			if (x >= SFQ_MAX_FLOWS) {
-drop:				sch->qstats.backlog -= qdisc_pkt_len(skb);
+drop:				qstats->backlog -= qdisc_pkt_len(skb);
 				kfree_skb(skb);
 				dropped++;
 				continue;
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 18ff634..edbd14e 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -175,7 +175,7 @@ static int tbf_segment(struct sk_buff *skb, struct Qdisc *sch)
 		ret = qdisc_enqueue(segs, q->qdisc);
 		if (ret != NET_XMIT_SUCCESS) {
 			if (net_xmit_drop_count(ret))
-				sch->qstats.drops++;
+				sch->qstats_qdisc.qstats.drops++;
 		} else {
 			nb++;
 		}
@@ -201,7 +201,7 @@ static int tbf_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	ret = qdisc_enqueue(skb, q->qdisc);
 	if (ret != NET_XMIT_SUCCESS) {
 		if (net_xmit_drop_count(ret))
-			sch->qstats.drops++;
+			sch->qstats_qdisc.qstats.drops++;
 		return ret;
 	}
 
@@ -216,7 +216,7 @@ static unsigned int tbf_drop(struct Qdisc *sch)
 
 	if (q->qdisc->ops->drop && (len = q->qdisc->ops->drop(q->qdisc)) != 0) {
 		sch->q.qlen--;
-		sch->qstats.drops++;
+		sch->qstats_qdisc.qstats.drops++;
 	}
 	return len;
 }
@@ -281,7 +281,7 @@ static struct sk_buff *tbf_dequeue(struct Qdisc *sch)
 		   (cf. CSZ, HPFQ, HFSC)
 		 */
 
-		sch->qstats.overlimits++;
+		sch->qstats_qdisc.qstats.overlimits++;
 	}
 	return NULL;
 }
@@ -448,11 +448,12 @@ static void tbf_destroy(struct Qdisc *sch)
 
 static int tbf_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
+	struct gnet_stats_queue *qstats = &sch->qstats_qdisc.qstats;
 	struct tbf_sched_data *q = qdisc_priv(sch);
 	struct nlattr *nest;
 	struct tc_tbf_qopt opt;
 
-	sch->qstats.backlog = q->qdisc->qstats.backlog;
+	qstats->backlog = q->qdisc->qstats_qdisc.qstats.backlog;
 	nest = nla_nest_start(skb, TCA_OPTIONS);
 	if (nest == NULL)
 		goto nla_put_failure;
