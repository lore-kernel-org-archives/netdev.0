From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v2 2/4] net: sched: implement qstat helper routines
Date: Fri, 26 Sep 2014 11:36:47 -0700
Message-ID: <20140926183646.2621.43672.stgit@nitbit.x32>
References: <20140926183621.2621.72538.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com, jhs@mojatatu.com, eric.dumazet@gmail.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:44747 "EHLO
	mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752861AbaIZShF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 14:37:05 -0400
Received: by mail-oi0-f46.google.com with SMTP id x69so3724323oia.33
        for <netdev@vger.kernel.org>; Fri, 26 Sep 2014 11:37:04 -0700 (PDT)
In-Reply-To: <20140926183621.2621.72538.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds helpers to manipulate qstats logic and replaces locations
that touch the counters directly. This simplifies future patches
to push qstats onto per cpu counters.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/net/sch_generic.h |   43 +++++++++++++++++++++++++++++++++++--------
 net/sched/sch_api.c       |    2 +-
 net/sched/sch_atm.c       |    2 +-
 net/sched/sch_cbq.c       |   10 +++++-----
 net/sched/sch_choke.c     |   14 +++++++-------
 net/sched/sch_codel.c     |    2 +-
 net/sched/sch_drr.c       |    4 ++--
 net/sched/sch_dsmark.c    |    2 +-
 net/sched/sch_fifo.c      |    2 +-
 net/sched/sch_fq.c        |    4 ++--
 net/sched/sch_fq_codel.c  |    8 ++++----
 net/sched/sch_gred.c      |    4 ++--
 net/sched/sch_hfsc.c      |    8 ++++----
 net/sched/sch_hhf.c       |    8 ++++----
 net/sched/sch_htb.c       |    6 +++---
 net/sched/sch_ingress.c   |    2 +-
 net/sched/sch_multiq.c    |    4 ++--
 net/sched/sch_netem.c     |   15 +++++++--------
 net/sched/sch_pie.c       |    2 +-
 net/sched/sch_prio.c      |    4 ++--
 net/sched/sch_qfq.c       |    4 ++--
 net/sched/sch_red.c       |    8 ++++----
 net/sched/sch_sfb.c       |   10 +++++-----
 net/sched/sch_sfq.c       |   17 +++++++++--------
 net/sched/sch_tbf.c       |    8 ++++----
 25 files changed, 110 insertions(+), 83 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 4b93511..5609844 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -521,11 +521,39 @@ static inline void qdisc_bstats_update(struct Qdisc *sch,
 	bstats_update(&sch->bstats, skb);
 }
 
+static inline void qdisc_qstats_backlog(struct Qdisc *sch,
+				       const struct sk_buff *skb)
+{
+	sch->qstats.backlog -= qdisc_pkt_len(skb);
+}
+
+static inline void qdisc_qstats_backlog_inc(struct Qdisc *sch,
+					    const struct sk_buff *skb)
+{
+
+	sch->qstats.backlog += qdisc_pkt_len(skb);
+}
+
+static inline void __qdisc_qstats_drop(struct Qdisc *sch, int count)
+{
+	sch->qstats.drops += count;
+}
+
+static inline void qdisc_qstats_drop(struct Qdisc *sch)
+{
+	sch->qstats.drops++;
+}
+
+static inline void qdisc_qstats_overlimit(struct Qdisc *sch)
+{
+	sch->qstats.overlimits++;
+}
+
 static inline int __qdisc_enqueue_tail(struct sk_buff *skb, struct Qdisc *sch,
 				       struct sk_buff_head *list)
 {
 	__skb_queue_tail(list, skb);
-	sch->qstats.backlog += qdisc_pkt_len(skb);
+	qdisc_qstats_backlog_inc(sch, skb);
 
 	return NET_XMIT_SUCCESS;
 }
@@ -541,7 +569,7 @@ static inline struct sk_buff *__qdisc_dequeue_head(struct Qdisc *sch,
 	struct sk_buff *skb = __skb_dequeue(list);
 
 	if (likely(skb != NULL)) {
-		sch->qstats.backlog -= qdisc_pkt_len(skb);
+		qdisc_qstats_backlog(sch, skb);
 		qdisc_bstats_update(sch, skb);
 	}
 
@@ -559,10 +587,9 @@ static inline unsigned int __qdisc_queue_drop_head(struct Qdisc *sch,
 	struct sk_buff *skb = __skb_dequeue(list);
 
 	if (likely(skb != NULL)) {
-		unsigned int len = qdisc_pkt_len(skb);
-		sch->qstats.backlog -= len;
+		qdisc_qstats_backlog(sch, skb);
 		kfree_skb(skb);
-		return len;
+		return qdisc_pkt_len(skb);
 	}
 
 	return 0;
@@ -579,7 +606,7 @@ static inline struct sk_buff *__qdisc_dequeue_tail(struct Qdisc *sch,
 	struct sk_buff *skb = __skb_dequeue_tail(list);
 
 	if (likely(skb != NULL))
-		sch->qstats.backlog -= qdisc_pkt_len(skb);
+		qdisc_qstats_backlog(sch, skb);
 
 	return skb;
 }
@@ -661,14 +688,14 @@ static inline unsigned int qdisc_queue_drop(struct Qdisc *sch)
 static inline int qdisc_drop(struct sk_buff *skb, struct Qdisc *sch)
 {
 	kfree_skb(skb);
-	sch->qstats.drops++;
+	qdisc_qstats_drop(sch);
 
 	return NET_XMIT_DROP;
 }
 
 static inline int qdisc_reshape_fail(struct sk_buff *skb, struct Qdisc *sch)
 {
-	sch->qstats.drops++;
+	qdisc_qstats_drop(sch);
 
 #ifdef CONFIG_NET_CLS_ACT
 	if (sch->reshape_fail == NULL || sch->reshape_fail(skb, sch))
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index a95e3b4..2862bc6 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -763,7 +763,7 @@ void qdisc_tree_decrease_qlen(struct Qdisc *sch, unsigned int n)
 			cops->put(sch, cl);
 		}
 		sch->q.qlen -= n;
-		sch->qstats.drops += drops;
+		__qdisc_qstats_drop(sch, drops);
 	}
 }
 EXPORT_SYMBOL(qdisc_tree_decrease_qlen);
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 0101766..040212c 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -417,7 +417,7 @@ done:
 	if (ret != NET_XMIT_SUCCESS) {
 drop: __maybe_unused
 		if (net_xmit_drop_count(ret)) {
-			sch->qstats.drops++;
+			qdisc_qstats_drop(sch);
 			if (flow)
 				flow->qstats.drops++;
 		}
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 22a3a02..60432c3 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -377,7 +377,7 @@ cbq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 #endif
 	if (cl == NULL) {
 		if (ret & __NET_XMIT_BYPASS)
-			sch->qstats.drops++;
+			qdisc_qstats_drop(sch);
 		kfree_skb(skb);
 		return ret;
 	}
@@ -395,7 +395,7 @@ cbq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	}
 
 	if (net_xmit_drop_count(ret)) {
-		sch->qstats.drops++;
+		qdisc_qstats_drop(sch);
 		cbq_mark_toplevel(q, cl);
 		cl->qstats.drops++;
 	}
@@ -650,11 +650,11 @@ static int cbq_reshape_fail(struct sk_buff *skb, struct Qdisc *child)
 			return 0;
 		}
 		if (net_xmit_drop_count(ret))
-			sch->qstats.drops++;
+			qdisc_qstats_drop(sch);
 		return 0;
 	}
 
-	sch->qstats.drops++;
+	qdisc_qstats_drop(sch);
 	return -1;
 }
 #endif
@@ -995,7 +995,7 @@ cbq_dequeue(struct Qdisc *sch)
 	 */
 
 	if (sch->q.qlen) {
-		sch->qstats.overlimits++;
+		qdisc_qstats_overlimit(sch);
 		if (q->wd_expires)
 			qdisc_watchdog_schedule(&q->watchdog,
 						now + q->wd_expires);
diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
index 8abc262..a514f42 100644
--- a/net/sched/sch_choke.c
+++ b/net/sched/sch_choke.c
@@ -127,7 +127,7 @@ static void choke_drop_by_idx(struct Qdisc *sch, unsigned int idx)
 	if (idx == q->tail)
 		choke_zap_tail_holes(q);
 
-	sch->qstats.backlog -= qdisc_pkt_len(skb);
+	qdisc_qstats_backlog(sch, skb);
 	qdisc_drop(skb, sch);
 	qdisc_tree_decrease_qlen(sch, 1);
 	--sch->q.qlen;
@@ -302,7 +302,7 @@ static int choke_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		if (q->vars.qavg > p->qth_max) {
 			q->vars.qcount = -1;
 
-			sch->qstats.overlimits++;
+			qdisc_qstats_overlimit(sch);
 			if (use_harddrop(q) || !use_ecn(q) ||
 			    !INET_ECN_set_ce(skb)) {
 				q->stats.forced_drop++;
@@ -315,7 +315,7 @@ static int choke_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 				q->vars.qcount = 0;
 				q->vars.qR = red_random(p);
 
-				sch->qstats.overlimits++;
+				qdisc_qstats_overlimit(sch);
 				if (!use_ecn(q) || !INET_ECN_set_ce(skb)) {
 					q->stats.prob_drop++;
 					goto congestion_drop;
@@ -332,7 +332,7 @@ static int choke_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		q->tab[q->tail] = skb;
 		q->tail = (q->tail + 1) & q->tab_mask;
 		++sch->q.qlen;
-		sch->qstats.backlog += qdisc_pkt_len(skb);
+		qdisc_qstats_backlog_inc(sch, skb);
 		return NET_XMIT_SUCCESS;
 	}
 
@@ -345,7 +345,7 @@ congestion_drop:
 
 other_drop:
 	if (ret & __NET_XMIT_BYPASS)
-		sch->qstats.drops++;
+		qdisc_qstats_drop(sch);
 	kfree_skb(skb);
 	return ret;
 }
@@ -365,7 +365,7 @@ static struct sk_buff *choke_dequeue(struct Qdisc *sch)
 	q->tab[q->head] = NULL;
 	choke_zap_head_holes(q);
 	--sch->q.qlen;
-	sch->qstats.backlog -= qdisc_pkt_len(skb);
+	qdisc_qstats_backlog(sch, skb);
 	qdisc_bstats_update(sch, skb);
 
 	return skb;
@@ -460,7 +460,7 @@ static int choke_change(struct Qdisc *sch, struct nlattr *opt)
 					ntab[tail++] = skb;
 					continue;
 				}
-				sch->qstats.backlog -= qdisc_pkt_len(skb);
+				qdisc_qstats_backlog(sch, skb);
 				--sch->q.qlen;
 				qdisc_drop(skb, sch);
 			}
diff --git a/net/sched/sch_codel.c b/net/sched/sch_codel.c
index 2f9ab17..c56ac44 100644
--- a/net/sched/sch_codel.c
+++ b/net/sched/sch_codel.c
@@ -149,7 +149,7 @@ static int codel_change(struct Qdisc *sch, struct nlattr *opt)
 	while (sch->q.qlen > sch->limit) {
 		struct sk_buff *skb = __skb_dequeue(&sch->q);
 
-		sch->qstats.backlog -= qdisc_pkt_len(skb);
+		qdisc_qstats_backlog(sch, skb);
 		qdisc_drop(skb, sch);
 	}
 	qdisc_tree_decrease_qlen(sch, qlen - sch->q.qlen);
diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
index 7a6243c..907b12f 100644
--- a/net/sched/sch_drr.c
+++ b/net/sched/sch_drr.c
@@ -360,7 +360,7 @@ static int drr_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	cl = drr_classify(skb, sch, &err);
 	if (cl == NULL) {
 		if (err & __NET_XMIT_BYPASS)
-			sch->qstats.drops++;
+			qdisc_qstats_drop(sch);
 		kfree_skb(skb);
 		return err;
 	}
@@ -369,7 +369,7 @@ static int drr_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	if (unlikely(err != NET_XMIT_SUCCESS)) {
 		if (net_xmit_drop_count(err)) {
 			cl->qstats.drops++;
-			sch->qstats.drops++;
+			qdisc_qstats_drop(sch);
 		}
 		return err;
 	}
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 485e456..227114f 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -258,7 +258,7 @@ static int dsmark_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	err = qdisc_enqueue(skb, p->q);
 	if (err != NET_XMIT_SUCCESS) {
 		if (net_xmit_drop_count(err))
-			sch->qstats.drops++;
+			qdisc_qstats_drop(sch);
 		return err;
 	}
 
diff --git a/net/sched/sch_fifo.c b/net/sched/sch_fifo.c
index e15a9eb..2e2398c 100644
--- a/net/sched/sch_fifo.c
+++ b/net/sched/sch_fifo.c
@@ -42,7 +42,7 @@ static int pfifo_tail_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 	/* queue full, remove one skb to fulfill the limit */
 	__qdisc_queue_drop_head(sch, &sch->q);
-	sch->qstats.drops++;
+	qdisc_qstats_drop(sch);
 	qdisc_enqueue_tail(skb, sch);
 
 	return NET_XMIT_CN;
diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index e12f997..a5a2e9f 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -290,7 +290,7 @@ static struct sk_buff *fq_dequeue_head(struct Qdisc *sch, struct fq_flow *flow)
 		flow->head = skb->next;
 		skb->next = NULL;
 		flow->qlen--;
-		sch->qstats.backlog -= qdisc_pkt_len(skb);
+		qdisc_qstats_backlog(sch, skb);
 		sch->q.qlen--;
 	}
 	return skb;
@@ -371,7 +371,7 @@ static int fq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	f->qlen++;
 	if (skb_is_retransmit(skb))
 		q->stat_tcp_retrans++;
-	sch->qstats.backlog += qdisc_pkt_len(skb);
+	qdisc_qstats_backlog_inc(sch, skb);
 	if (fq_flow_is_detached(f)) {
 		fq_flow_add_tail(&q->new_flows, f);
 		if (time_after(jiffies, f->age + q->flow_refill_delay))
diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index 105cf55..3f288ae 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -164,8 +164,8 @@ static unsigned int fq_codel_drop(struct Qdisc *sch)
 	q->backlogs[idx] -= len;
 	kfree_skb(skb);
 	sch->q.qlen--;
-	sch->qstats.drops++;
-	sch->qstats.backlog -= len;
+	qdisc_qstats_drop(sch);
+	qdisc_qstats_backlog(sch, skb);
 	flow->dropped++;
 	return idx;
 }
@@ -180,7 +180,7 @@ static int fq_codel_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	idx = fq_codel_classify(skb, sch, &ret);
 	if (idx == 0) {
 		if (ret & __NET_XMIT_BYPASS)
-			sch->qstats.drops++;
+			qdisc_qstats_drop(sch);
 		kfree_skb(skb);
 		return ret;
 	}
@@ -190,7 +190,7 @@ static int fq_codel_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	flow = &q->flows[idx];
 	flow_queue_add(flow, skb);
 	q->backlogs[idx] += qdisc_pkt_len(skb);
-	sch->qstats.backlog += qdisc_pkt_len(skb);
+	qdisc_qstats_backlog_inc(sch, skb);
 
 	if (list_empty(&flow->flowchain)) {
 		list_add_tail(&flow->flowchain, &q->new_flows);
diff --git a/net/sched/sch_gred.c b/net/sched/sch_gred.c
index 12cbc09..a4ca451 100644
--- a/net/sched/sch_gred.c
+++ b/net/sched/sch_gred.c
@@ -209,7 +209,7 @@ static int gred_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		break;
 
 	case RED_PROB_MARK:
-		sch->qstats.overlimits++;
+		qdisc_qstats_overlimit(sch);
 		if (!gred_use_ecn(t) || !INET_ECN_set_ce(skb)) {
 			q->stats.prob_drop++;
 			goto congestion_drop;
@@ -219,7 +219,7 @@ static int gred_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		break;
 
 	case RED_HARD_MARK:
-		sch->qstats.overlimits++;
+		qdisc_qstats_overlimit(sch);
 		if (gred_use_harddrop(t) || !gred_use_ecn(t) ||
 		    !INET_ECN_set_ce(skb)) {
 			q->stats.forced_drop++;
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 209b966..ad27825 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1591,7 +1591,7 @@ hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	cl = hfsc_classify(skb, sch, &err);
 	if (cl == NULL) {
 		if (err & __NET_XMIT_BYPASS)
-			sch->qstats.drops++;
+			qdisc_qstats_drop(sch);
 		kfree_skb(skb);
 		return err;
 	}
@@ -1600,7 +1600,7 @@ hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	if (unlikely(err != NET_XMIT_SUCCESS)) {
 		if (net_xmit_drop_count(err)) {
 			cl->qstats.drops++;
-			sch->qstats.drops++;
+			qdisc_qstats_drop(sch);
 		}
 		return err;
 	}
@@ -1643,7 +1643,7 @@ hfsc_dequeue(struct Qdisc *sch)
 		 */
 		cl = vttree_get_minvt(&q->root, cur_time);
 		if (cl == NULL) {
-			sch->qstats.overlimits++;
+			qdisc_qstats_overlimit(sch);
 			hfsc_schedule_watchdog(sch);
 			return NULL;
 		}
@@ -1698,7 +1698,7 @@ hfsc_drop(struct Qdisc *sch)
 				list_move_tail(&cl->dlist, &q->droplist);
 			}
 			cl->qstats.drops++;
-			sch->qstats.drops++;
+			qdisc_qstats_drop(sch);
 			sch->q.qlen--;
 			return len;
 		}
diff --git a/net/sched/sch_hhf.c b/net/sched/sch_hhf.c
index d85b681..934e9cc 100644
--- a/net/sched/sch_hhf.c
+++ b/net/sched/sch_hhf.c
@@ -376,8 +376,8 @@ static unsigned int hhf_drop(struct Qdisc *sch)
 		struct sk_buff *skb = dequeue_head(bucket);
 
 		sch->q.qlen--;
-		sch->qstats.drops++;
-		sch->qstats.backlog -= qdisc_pkt_len(skb);
+		qdisc_qstats_drop(sch);
+		qdisc_qstats_backlog(sch, skb);
 		kfree_skb(skb);
 	}
 
@@ -395,7 +395,7 @@ static int hhf_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 	bucket = &q->buckets[idx];
 	bucket_add(bucket, skb);
-	sch->qstats.backlog += qdisc_pkt_len(skb);
+	qdisc_qstats_backlog_inc(sch, skb);
 
 	if (list_empty(&bucket->bucketchain)) {
 		unsigned int weight;
@@ -457,7 +457,7 @@ begin:
 	if (bucket->head) {
 		skb = dequeue_head(bucket);
 		sch->q.qlen--;
-		sch->qstats.backlog -= qdisc_pkt_len(skb);
+		qdisc_qstats_backlog(sch, skb);
 	}
 
 	if (!skb) {
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 0256dee..c40ab7a 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -586,13 +586,13 @@ static int htb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 #ifdef CONFIG_NET_CLS_ACT
 	} else if (!cl) {
 		if (ret & __NET_XMIT_BYPASS)
-			sch->qstats.drops++;
+			qdisc_qstats_drop(sch);
 		kfree_skb(skb);
 		return ret;
 #endif
 	} else if ((ret = qdisc_enqueue(skb, cl->un.leaf.q)) != NET_XMIT_SUCCESS) {
 		if (net_xmit_drop_count(ret)) {
-			sch->qstats.drops++;
+			qdisc_qstats_drop(sch);
 			cl->qstats.drops++;
 		}
 		return ret;
@@ -925,7 +925,7 @@ ok:
 				goto ok;
 		}
 	}
-	sch->qstats.overlimits++;
+	qdisc_qstats_overlimit(sch);
 	if (likely(next_event > q->now)) {
 		if (!test_bit(__QDISC_STATE_DEACTIVATED,
 			      &qdisc_root_sleeping(q->watchdog.qdisc)->state)) {
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index b351125..eb5b844 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -69,7 +69,7 @@ static int ingress_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	switch (result) {
 	case TC_ACT_SHOT:
 		result = TC_ACT_SHOT;
-		sch->qstats.drops++;
+		qdisc_qstats_drop(sch);
 		break;
 	case TC_ACT_STOLEN:
 	case TC_ACT_QUEUED:
diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
index 4adbf7f..7f4e1d8 100644
--- a/net/sched/sch_multiq.c
+++ b/net/sched/sch_multiq.c
@@ -75,7 +75,7 @@ multiq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	if (qdisc == NULL) {
 
 		if (ret & __NET_XMIT_BYPASS)
-			sch->qstats.drops++;
+			qdisc_qstats_drop(sch);
 		kfree_skb(skb);
 		return ret;
 	}
@@ -87,7 +87,7 @@ multiq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		return NET_XMIT_SUCCESS;
 	}
 	if (net_xmit_drop_count(ret))
-		sch->qstats.drops++;
+		qdisc_qstats_drop(sch);
 	return ret;
 }
 
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 111d70f..ace7ca1 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -429,12 +429,12 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	/* Drop packet? */
 	if (loss_event(q)) {
 		if (q->ecn && INET_ECN_set_ce(skb))
-			sch->qstats.drops++; /* mark packet */
+			qdisc_qstats_drop(sch); /* mark packet */
 		else
 			--count;
 	}
 	if (count == 0) {
-		sch->qstats.drops++;
+		qdisc_qstats_drop(sch);
 		kfree_skb(skb);
 		return NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
 	}
@@ -478,7 +478,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	if (unlikely(skb_queue_len(&sch->q) >= sch->limit))
 		return qdisc_reshape_fail(skb, sch);
 
-	sch->qstats.backlog += qdisc_pkt_len(skb);
+	qdisc_qstats_backlog_inc(sch, skb);
 
 	cb = netem_skb_cb(skb);
 	if (q->gap == 0 ||		/* not doing reordering */
@@ -549,15 +549,14 @@ static unsigned int netem_drop(struct Qdisc *sch)
 			sch->q.qlen--;
 			skb->next = NULL;
 			skb->prev = NULL;
-			len = qdisc_pkt_len(skb);
-			sch->qstats.backlog -= len;
+			qdisc_qstats_backlog(sch, skb);
 			kfree_skb(skb);
 		}
 	}
 	if (!len && q->qdisc && q->qdisc->ops->drop)
 	    len = q->qdisc->ops->drop(q->qdisc);
 	if (len)
-		sch->qstats.drops++;
+		qdisc_qstats_drop(sch);
 
 	return len;
 }
@@ -575,7 +574,7 @@ tfifo_dequeue:
 	skb = __skb_dequeue(&sch->q);
 	if (skb) {
 deliver:
-		sch->qstats.backlog -= qdisc_pkt_len(skb);
+		qdisc_qstats_backlog(sch, skb);
 		qdisc_unthrottled(sch);
 		qdisc_bstats_update(sch, skb);
 		return skb;
@@ -610,7 +609,7 @@ deliver:
 
 				if (unlikely(err != NET_XMIT_SUCCESS)) {
 					if (net_xmit_drop_count(err)) {
-						sch->qstats.drops++;
+						qdisc_qstats_drop(sch);
 						qdisc_tree_decrease_qlen(sch, 1);
 					}
 				}
diff --git a/net/sched/sch_pie.c b/net/sched/sch_pie.c
index fefeeb7..32636c9 100644
--- a/net/sched/sch_pie.c
+++ b/net/sched/sch_pie.c
@@ -232,7 +232,7 @@ static int pie_change(struct Qdisc *sch, struct nlattr *opt)
 	while (sch->q.qlen > sch->limit) {
 		struct sk_buff *skb = __skb_dequeue(&sch->q);
 
-		sch->qstats.backlog -= qdisc_pkt_len(skb);
+		qdisc_qstats_backlog(sch, skb);
 		qdisc_drop(skb, sch);
 	}
 	qdisc_tree_decrease_qlen(sch, qlen - sch->q.qlen);
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 68a8f25..b411e78 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -77,7 +77,7 @@ prio_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	if (qdisc == NULL) {
 
 		if (ret & __NET_XMIT_BYPASS)
-			sch->qstats.drops++;
+			qdisc_qstats_drop(sch);
 		kfree_skb(skb);
 		return ret;
 	}
@@ -89,7 +89,7 @@ prio_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		return NET_XMIT_SUCCESS;
 	}
 	if (net_xmit_drop_count(ret))
-		sch->qstats.drops++;
+		qdisc_qstats_drop(sch);
 	return ret;
 }
 
diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index d59f857..3fb2655 100644
--- a/net/sched/sch_qfq.c
+++ b/net/sched/sch_qfq.c
@@ -1229,7 +1229,7 @@ static int qfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	cl = qfq_classify(skb, sch, &err);
 	if (cl == NULL) {
 		if (err & __NET_XMIT_BYPASS)
-			sch->qstats.drops++;
+			qdisc_qstats_drop(sch);
 		kfree_skb(skb);
 		return err;
 	}
@@ -1249,7 +1249,7 @@ static int qfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		pr_debug("qfq_enqueue: enqueue failed %d\n", err);
 		if (net_xmit_drop_count(err)) {
 			cl->qstats.drops++;
-			sch->qstats.drops++;
+			qdisc_qstats_drop(sch);
 		}
 		return err;
 	}
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index 633e32d..6c0534c 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -74,7 +74,7 @@ static int red_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		break;
 
 	case RED_PROB_MARK:
-		sch->qstats.overlimits++;
+		qdisc_qstats_overlimit(sch);
 		if (!red_use_ecn(q) || !INET_ECN_set_ce(skb)) {
 			q->stats.prob_drop++;
 			goto congestion_drop;
@@ -84,7 +84,7 @@ static int red_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		break;
 
 	case RED_HARD_MARK:
-		sch->qstats.overlimits++;
+		qdisc_qstats_overlimit(sch);
 		if (red_use_harddrop(q) || !red_use_ecn(q) ||
 		    !INET_ECN_set_ce(skb)) {
 			q->stats.forced_drop++;
@@ -100,7 +100,7 @@ static int red_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		sch->q.qlen++;
 	} else if (net_xmit_drop_count(ret)) {
 		q->stats.pdrop++;
-		sch->qstats.drops++;
+		qdisc_qstats_drop(sch);
 	}
 	return ret;
 
@@ -142,7 +142,7 @@ static unsigned int red_drop(struct Qdisc *sch)
 
 	if (child->ops->drop && (len = child->ops->drop(child)) > 0) {
 		q->stats.other++;
-		sch->qstats.drops++;
+		qdisc_qstats_drop(sch);
 		sch->q.qlen--;
 		return len;
 	}
diff --git a/net/sched/sch_sfb.c b/net/sched/sch_sfb.c
index 1562fb2..5819dd8 100644
--- a/net/sched/sch_sfb.c
+++ b/net/sched/sch_sfb.c
@@ -290,7 +290,7 @@ static int sfb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	struct flow_keys keys;
 
 	if (unlikely(sch->q.qlen >= q->limit)) {
-		sch->qstats.overlimits++;
+		qdisc_qstats_overlimit(sch);
 		q->stats.queuedrop++;
 		goto drop;
 	}
@@ -348,7 +348,7 @@ static int sfb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	sfb_skb_cb(skb)->hashes[slot] = 0;
 
 	if (unlikely(minqlen >= q->max)) {
-		sch->qstats.overlimits++;
+		qdisc_qstats_overlimit(sch);
 		q->stats.bucketdrop++;
 		goto drop;
 	}
@@ -376,7 +376,7 @@ static int sfb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 			}
 		}
 		if (sfb_rate_limit(skb, q)) {
-			sch->qstats.overlimits++;
+			qdisc_qstats_overlimit(sch);
 			q->stats.penaltydrop++;
 			goto drop;
 		}
@@ -411,7 +411,7 @@ enqueue:
 		increment_qlen(skb, q);
 	} else if (net_xmit_drop_count(ret)) {
 		q->stats.childdrop++;
-		sch->qstats.drops++;
+		qdisc_qstats_drop(sch);
 	}
 	return ret;
 
@@ -420,7 +420,7 @@ drop:
 	return NET_XMIT_CN;
 other_drop:
 	if (ret & __NET_XMIT_BYPASS)
-		sch->qstats.drops++;
+		qdisc_qstats_drop(sch);
 	kfree_skb(skb);
 	return ret;
 }
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 80c36bd..16fb3e7 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -331,8 +331,8 @@ drop:
 		sfq_dec(q, x);
 		kfree_skb(skb);
 		sch->q.qlen--;
-		sch->qstats.drops++;
-		sch->qstats.backlog -= len;
+		qdisc_qstats_drop(sch);
+		qdisc_qstats_backlog(sch, skb);
 		return len;
 	}
 
@@ -379,7 +379,7 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	hash = sfq_classify(skb, sch, &ret);
 	if (hash == 0) {
 		if (ret & __NET_XMIT_BYPASS)
-			sch->qstats.drops++;
+			qdisc_qstats_drop(sch);
 		kfree_skb(skb);
 		return ret;
 	}
@@ -409,7 +409,7 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 			break;
 
 		case RED_PROB_MARK:
-			sch->qstats.overlimits++;
+			qdisc_qstats_overlimit(sch);
 			if (sfq_prob_mark(q)) {
 				/* We know we have at least one packet in queue */
 				if (sfq_headdrop(q) &&
@@ -426,7 +426,7 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 			goto congestion_drop;
 
 		case RED_HARD_MARK:
-			sch->qstats.overlimits++;
+			qdisc_qstats_overlimit(sch);
 			if (sfq_hard_mark(q)) {
 				/* We know we have at least one packet in queue */
 				if (sfq_headdrop(q) &&
@@ -461,7 +461,7 @@ congestion_drop:
 	}
 
 enqueue:
-	sch->qstats.backlog += qdisc_pkt_len(skb);
+	qdisc_qstats_backlog_inc(sch, skb);
 	slot->backlog += qdisc_pkt_len(skb);
 	slot_queue_add(slot, skb);
 	sfq_inc(q, x);
@@ -520,7 +520,7 @@ next_slot:
 	sfq_dec(q, a);
 	qdisc_bstats_update(sch, skb);
 	sch->q.qlen--;
-	sch->qstats.backlog -= qdisc_pkt_len(skb);
+	qdisc_qstats_backlog(sch, skb);
 	slot->backlog -= qdisc_pkt_len(skb);
 	/* Is the slot empty? */
 	if (slot->qlen == 0) {
@@ -586,7 +586,8 @@ static void sfq_rehash(struct Qdisc *sch)
 		if (x == SFQ_EMPTY_SLOT) {
 			x = q->dep[0].next; /* get a free slot */
 			if (x >= SFQ_MAX_FLOWS) {
-drop:				sch->qstats.backlog -= qdisc_pkt_len(skb);
+drop:
+				qdisc_qstats_backlog(sch, skb);
 				kfree_skb(skb);
 				dropped++;
 				continue;
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 0c39b75..77edffe 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -175,7 +175,7 @@ static int tbf_segment(struct sk_buff *skb, struct Qdisc *sch)
 		ret = qdisc_enqueue(segs, q->qdisc);
 		if (ret != NET_XMIT_SUCCESS) {
 			if (net_xmit_drop_count(ret))
-				sch->qstats.drops++;
+				qdisc_qstats_drop(sch);
 		} else {
 			nb++;
 		}
@@ -201,7 +201,7 @@ static int tbf_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	ret = qdisc_enqueue(skb, q->qdisc);
 	if (ret != NET_XMIT_SUCCESS) {
 		if (net_xmit_drop_count(ret))
-			sch->qstats.drops++;
+			qdisc_qstats_drop(sch);
 		return ret;
 	}
 
@@ -216,7 +216,7 @@ static unsigned int tbf_drop(struct Qdisc *sch)
 
 	if (q->qdisc->ops->drop && (len = q->qdisc->ops->drop(q->qdisc)) != 0) {
 		sch->q.qlen--;
-		sch->qstats.drops++;
+		qdisc_qstats_drop(sch);
 	}
 	return len;
 }
@@ -281,7 +281,7 @@ static struct sk_buff *tbf_dequeue(struct Qdisc *sch)
 		   (cf. CSZ, HPFQ, HFSC)
 		 */
 
-		sch->qstats.overlimits++;
+		qdisc_qstats_overlimit(sch);
 	}
 	return NULL;
 }
