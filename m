From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 1/4] net_sched: drop packets after root qdisc lock is released
Date: Tue, 21 Jun 2016 23:16:49 -0700
Message-ID: <1466576212-15012-2-git-send-email-edumazet@google.com>
References: <1466576212-15012-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35733 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750897AbcFVGWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 02:22:51 -0400
Received: by mail-pa0-f43.google.com with SMTP id hl6so13789770pac.2
        for <netdev@vger.kernel.org>; Tue, 21 Jun 2016 23:22:51 -0700 (PDT)
In-Reply-To: <1466576212-15012-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Qdisc performance suffers when packets are dropped at enqueue()
time because drops (kfree_skb()) are done while qdisc lock is held,
delaying a dequeue() draining the queue.

Nominal throughput can be reduced by 50 % when this happens,
at a time we would like the dequeue() to proceed as fast as possible.

Even FQ is vulnerable to this problem, while one of FQ goals was
to provide some flow isolation.

This patch adds a 'struct sk_buff **to_free' parameter to all
qdisc->enqueue(), and in qdisc_drop() helper.

I measured a performance increase of up to 12 %, but this patch
is a prereq so that future batches in enqueue() can fly.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/sch_generic.h | 41 ++++++++++++++++++++++++++++++-----------
 net/core/dev.c            |  7 +++++--
 net/sched/sch_atm.c       |  9 +++++----
 net/sched/sch_blackhole.c |  5 +++--
 net/sched/sch_cbq.c       |  7 ++++---
 net/sched/sch_choke.c     | 16 +++++++++-------
 net/sched/sch_codel.c     |  8 +++++---
 net/sched/sch_drr.c       |  7 ++++---
 net/sched/sch_dsmark.c    |  9 +++++----
 net/sched/sch_fifo.c      | 15 +++++++++------
 net/sched/sch_fq.c        |  7 ++++---
 net/sched/sch_fq_codel.c  | 15 +++++++++------
 net/sched/sch_generic.c   | 10 ++++++----
 net/sched/sch_gred.c      |  7 ++++---
 net/sched/sch_hfsc.c      |  6 +++---
 net/sched/sch_hhf.c       | 10 +++++-----
 net/sched/sch_htb.c       | 10 ++++++----
 net/sched/sch_multiq.c    |  7 ++++---
 net/sched/sch_netem.c     | 25 +++++++++++++++----------
 net/sched/sch_pie.c       |  5 +++--
 net/sched/sch_plug.c      |  5 +++--
 net/sched/sch_prio.c      |  4 ++--
 net/sched/sch_qfq.c       |  7 ++++---
 net/sched/sch_red.c       |  7 ++++---
 net/sched/sch_sfb.c       |  7 ++++---
 net/sched/sch_sfq.c       |  8 ++++----
 net/sched/sch_tbf.c       | 16 +++++++++-------
 net/sched/sch_teql.c      |  4 ++--
 28 files changed, 170 insertions(+), 114 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 4f7cee8344c4..04e84c07c94f 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -37,8 +37,10 @@ struct qdisc_size_table {
 };
 
 struct Qdisc {
-	int 			(*enqueue)(struct sk_buff *skb, struct Qdisc *dev);
-	struct sk_buff *	(*dequeue)(struct Qdisc *dev);
+	int 			(*enqueue)(struct sk_buff *skb,
+					   struct Qdisc *sch,
+					   struct sk_buff **to_free);
+	struct sk_buff *	(*dequeue)(struct Qdisc *sch);
 	unsigned int		flags;
 #define TCQ_F_BUILTIN		1
 #define TCQ_F_INGRESS		2
@@ -160,7 +162,9 @@ struct Qdisc_ops {
 	char			id[IFNAMSIZ];
 	int			priv_size;
 
-	int 			(*enqueue)(struct sk_buff *, struct Qdisc *);
+	int 			(*enqueue)(struct sk_buff *skb,
+					   struct Qdisc *sch,
+					   struct sk_buff **to_free);
 	struct sk_buff *	(*dequeue)(struct Qdisc *);
 	struct sk_buff *	(*peek)(struct Qdisc *);
 
@@ -498,10 +502,11 @@ static inline void qdisc_calculate_pkt_len(struct sk_buff *skb,
 #endif
 }
 
-static inline int qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+static inline int qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch,
+				struct sk_buff **to_free)
 {
 	qdisc_calculate_pkt_len(skb, sch);
-	return sch->enqueue(skb, sch);
+	return sch->enqueue(skb, sch, to_free);
 }
 
 static inline bool qdisc_is_percpu_stats(const struct Qdisc *q)
@@ -626,24 +631,36 @@ static inline struct sk_buff *qdisc_dequeue_head(struct Qdisc *sch)
 	return __qdisc_dequeue_head(sch, &sch->q);
 }
 
+/* Instead of calling kfree_skb() while root qdisc lock is held,
+ * queue the skb for future freeing at end of __dev_xmit_skb()
+ */
+static inline void __qdisc_drop(struct sk_buff *skb, struct sk_buff **to_free)
+{
+	skb->next = *to_free;
+	*to_free = skb;
+}
+
 static inline unsigned int __qdisc_queue_drop_head(struct Qdisc *sch,
-					      struct sk_buff_head *list)
+						   struct sk_buff_head *list,
+						   struct sk_buff **to_free)
 {
 	struct sk_buff *skb = __skb_dequeue(list);
 
 	if (likely(skb != NULL)) {
 		unsigned int len = qdisc_pkt_len(skb);
+
 		qdisc_qstats_backlog_dec(sch, skb);
-		kfree_skb(skb);
+		__qdisc_drop(skb, to_free);
 		return len;
 	}
 
 	return 0;
 }
 
-static inline unsigned int qdisc_queue_drop_head(struct Qdisc *sch)
+static inline unsigned int qdisc_queue_drop_head(struct Qdisc *sch,
+						 struct sk_buff **to_free)
 {
-	return __qdisc_queue_drop_head(sch, &sch->q);
+	return __qdisc_queue_drop_head(sch, &sch->q, to_free);
 }
 
 static inline struct sk_buff *qdisc_peek_head(struct Qdisc *sch)
@@ -724,9 +741,11 @@ static inline void rtnl_qdisc_drop(struct sk_buff *skb, struct Qdisc *sch)
 	qdisc_qstats_drop(sch);
 }
 
-static inline int qdisc_drop(struct sk_buff *skb, struct Qdisc *sch)
+
+static inline int qdisc_drop(struct sk_buff *skb, struct Qdisc *sch,
+			     struct sk_buff **to_free)
 {
-	kfree_skb(skb);
+	__qdisc_drop(skb, to_free);
 	qdisc_qstats_drop(sch);
 
 	return NET_XMIT_DROP;
diff --git a/net/core/dev.c b/net/core/dev.c
index d40593b3b9fb..aba10d2a8bc3 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3070,6 +3070,7 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 				 struct netdev_queue *txq)
 {
 	spinlock_t *root_lock = qdisc_lock(q);
+	struct sk_buff *to_free = NULL;
 	bool contended;
 	int rc;
 
@@ -3086,7 +3087,7 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 
 	spin_lock(root_lock);
 	if (unlikely(test_bit(__QDISC_STATE_DEACTIVATED, &q->state))) {
-		kfree_skb(skb);
+		__qdisc_drop(skb, &to_free);
 		rc = NET_XMIT_DROP;
 	} else if ((q->flags & TCQ_F_CAN_BYPASS) && !qdisc_qlen(q) &&
 		   qdisc_run_begin(q)) {
@@ -3109,7 +3110,7 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 
 		rc = NET_XMIT_SUCCESS;
 	} else {
-		rc = q->enqueue(skb, q) & NET_XMIT_MASK;
+		rc = q->enqueue(skb, q, &to_free) & NET_XMIT_MASK;
 		if (qdisc_run_begin(q)) {
 			if (unlikely(contended)) {
 				spin_unlock(&q->busylock);
@@ -3119,6 +3120,8 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 		}
 	}
 	spin_unlock(root_lock);
+	if (unlikely(to_free))
+		kfree_skb_list(to_free);
 	if (unlikely(contended))
 		spin_unlock(&q->busylock);
 	return rc;
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index e04ea6994d1c..481e4f12aeb4 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -357,7 +357,8 @@ static struct tcf_proto __rcu **atm_tc_find_tcf(struct Qdisc *sch,
 
 /* --------------------------- Qdisc operations ---------------------------- */
 
-static int atm_tc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+static int atm_tc_enqueue(struct sk_buff *skb, struct Qdisc *sch,
+			  struct sk_buff **to_free)
 {
 	struct atm_qdisc_data *p = qdisc_priv(sch);
 	struct atm_flow_data *flow;
@@ -398,10 +399,10 @@ done:
 		switch (result) {
 		case TC_ACT_QUEUED:
 		case TC_ACT_STOLEN:
-			kfree_skb(skb);
+			__qdisc_drop(skb, to_free);
 			return NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
 		case TC_ACT_SHOT:
-			kfree_skb(skb);
+			__qdisc_drop(skb, to_free);
 			goto drop;
 		case TC_ACT_RECLASSIFY:
 			if (flow->excess)
@@ -413,7 +414,7 @@ done:
 #endif
 	}
 
-	ret = qdisc_enqueue(skb, flow->q);
+	ret = qdisc_enqueue(skb, flow->q, to_free);
 	if (ret != NET_XMIT_SUCCESS) {
 drop: __maybe_unused
 		if (net_xmit_drop_count(ret)) {
diff --git a/net/sched/sch_blackhole.c b/net/sched/sch_blackhole.c
index 3fee70d9814f..c98a61e980ba 100644
--- a/net/sched/sch_blackhole.c
+++ b/net/sched/sch_blackhole.c
@@ -17,9 +17,10 @@
 #include <linux/skbuff.h>
 #include <net/pkt_sched.h>
 
-static int blackhole_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+static int blackhole_enqueue(struct sk_buff *skb, struct Qdisc *sch,
+			     struct sk_buff **to_free)
 {
-	qdisc_drop(skb, sch);
+	qdisc_drop(skb, sch, to_free);
 	return NET_XMIT_SUCCESS;
 }
 
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index a29fd811d7b9..beb554aa8cfb 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -358,7 +358,8 @@ cbq_mark_toplevel(struct cbq_sched_data *q, struct cbq_class *cl)
 }
 
 static int
-cbq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+cbq_enqueue(struct sk_buff *skb, struct Qdisc *sch,
+	    struct sk_buff **to_free)
 {
 	struct cbq_sched_data *q = qdisc_priv(sch);
 	int uninitialized_var(ret);
@@ -370,11 +371,11 @@ cbq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	if (cl == NULL) {
 		if (ret & __NET_XMIT_BYPASS)
 			qdisc_qstats_drop(sch);
-		kfree_skb(skb);
+		__qdisc_drop(skb, to_free);
 		return ret;
 	}
 
-	ret = qdisc_enqueue(skb, cl->q);
+	ret = qdisc_enqueue(skb, cl->q, to_free);
 	if (ret == NET_XMIT_SUCCESS) {
 		sch->q.qlen++;
 		cbq_mark_toplevel(q, cl);
diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
index 789b69ee9e51..3b6d5bd69101 100644
--- a/net/sched/sch_choke.c
+++ b/net/sched/sch_choke.c
@@ -115,7 +115,8 @@ static void choke_zap_tail_holes(struct choke_sched_data *q)
 }
 
 /* Drop packet from queue array by creating a "hole" */
-static void choke_drop_by_idx(struct Qdisc *sch, unsigned int idx)
+static void choke_drop_by_idx(struct Qdisc *sch, unsigned int idx,
+			      struct sk_buff **to_free)
 {
 	struct choke_sched_data *q = qdisc_priv(sch);
 	struct sk_buff *skb = q->tab[idx];
@@ -129,7 +130,7 @@ static void choke_drop_by_idx(struct Qdisc *sch, unsigned int idx)
 
 	qdisc_qstats_backlog_dec(sch, skb);
 	qdisc_tree_reduce_backlog(sch, 1, qdisc_pkt_len(skb));
-	qdisc_drop(skb, sch);
+	qdisc_drop(skb, sch, to_free);
 	--sch->q.qlen;
 }
 
@@ -261,7 +262,8 @@ static bool choke_match_random(const struct choke_sched_data *q,
 	return choke_match_flow(oskb, nskb);
 }
 
-static int choke_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+static int choke_enqueue(struct sk_buff *skb, struct Qdisc *sch,
+			 struct sk_buff **to_free)
 {
 	int ret = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
 	struct choke_sched_data *q = qdisc_priv(sch);
@@ -288,7 +290,7 @@ static int choke_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		/* Draw a packet at random from queue and compare flow */
 		if (choke_match_random(q, skb, &idx)) {
 			q->stats.matched++;
-			choke_drop_by_idx(sch, idx);
+			choke_drop_by_idx(sch, idx, to_free);
 			goto congestion_drop;
 		}
 
@@ -331,16 +333,16 @@ static int choke_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	}
 
 	q->stats.pdrop++;
-	return qdisc_drop(skb, sch);
+	return qdisc_drop(skb, sch, to_free);
 
 congestion_drop:
-	qdisc_drop(skb, sch);
+	qdisc_drop(skb, sch, to_free);
 	return NET_XMIT_CN;
 
 other_drop:
 	if (ret & __NET_XMIT_BYPASS)
 		qdisc_qstats_drop(sch);
-	kfree_skb(skb);
+	__qdisc_drop(skb, to_free);
 	return ret;
 }
 
diff --git a/net/sched/sch_codel.c b/net/sched/sch_codel.c
index c5bc424e3b3c..4002df3c7d9f 100644
--- a/net/sched/sch_codel.c
+++ b/net/sched/sch_codel.c
@@ -82,7 +82,8 @@ static void drop_func(struct sk_buff *skb, void *ctx)
 {
 	struct Qdisc *sch = ctx;
 
-	qdisc_drop(skb, sch);
+	kfree_skb(skb);
+	qdisc_qstats_drop(sch);
 }
 
 static struct sk_buff *codel_qdisc_dequeue(struct Qdisc *sch)
@@ -107,7 +108,8 @@ static struct sk_buff *codel_qdisc_dequeue(struct Qdisc *sch)
 	return skb;
 }
 
-static int codel_qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+static int codel_qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch,
+			       struct sk_buff **to_free)
 {
 	struct codel_sched_data *q;
 
@@ -117,7 +119,7 @@ static int codel_qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	}
 	q = qdisc_priv(sch);
 	q->drop_overlimit++;
-	return qdisc_drop(skb, sch);
+	return qdisc_drop(skb, sch, to_free);
 }
 
 static const struct nla_policy codel_policy[TCA_CODEL_MAX + 1] = {
diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
index 22609e4e845f..8af5c59eef84 100644
--- a/net/sched/sch_drr.c
+++ b/net/sched/sch_drr.c
@@ -350,7 +350,8 @@ static struct drr_class *drr_classify(struct sk_buff *skb, struct Qdisc *sch,
 	return NULL;
 }
 
-static int drr_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+static int drr_enqueue(struct sk_buff *skb, struct Qdisc *sch,
+		       struct sk_buff **to_free)
 {
 	struct drr_sched *q = qdisc_priv(sch);
 	struct drr_class *cl;
@@ -360,11 +361,11 @@ static int drr_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	if (cl == NULL) {
 		if (err & __NET_XMIT_BYPASS)
 			qdisc_qstats_drop(sch);
-		kfree_skb(skb);
+		__qdisc_drop(skb, to_free);
 		return err;
 	}
 
-	err = qdisc_enqueue(skb, cl->qdisc);
+	err = qdisc_enqueue(skb, cl->qdisc, to_free);
 	if (unlikely(err != NET_XMIT_SUCCESS)) {
 		if (net_xmit_drop_count(err)) {
 			cl->qstats.drops++;
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index b9ba5f658528..1308bbf460f7 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -191,7 +191,8 @@ static inline struct tcf_proto __rcu **dsmark_find_tcf(struct Qdisc *sch,
 
 /* --------------------------- Qdisc operations ---------------------------- */
 
-static int dsmark_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+static int dsmark_enqueue(struct sk_buff *skb, struct Qdisc *sch,
+			  struct sk_buff **to_free)
 {
 	struct dsmark_qdisc_data *p = qdisc_priv(sch);
 	int err;
@@ -234,7 +235,7 @@ static int dsmark_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 #ifdef CONFIG_NET_CLS_ACT
 		case TC_ACT_QUEUED:
 		case TC_ACT_STOLEN:
-			kfree_skb(skb);
+			__qdisc_drop(skb, to_free);
 			return NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
 
 		case TC_ACT_SHOT:
@@ -251,7 +252,7 @@ static int dsmark_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		}
 	}
 
-	err = qdisc_enqueue(skb, p->q);
+	err = qdisc_enqueue(skb, p->q, to_free);
 	if (err != NET_XMIT_SUCCESS) {
 		if (net_xmit_drop_count(err))
 			qdisc_qstats_drop(sch);
@@ -264,7 +265,7 @@ static int dsmark_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	return NET_XMIT_SUCCESS;
 
 drop:
-	qdisc_drop(skb, sch);
+	qdisc_drop(skb, sch, to_free);
 	return NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
 }
 
diff --git a/net/sched/sch_fifo.c b/net/sched/sch_fifo.c
index dea70e3ef0ba..6ea0db427f91 100644
--- a/net/sched/sch_fifo.c
+++ b/net/sched/sch_fifo.c
@@ -19,29 +19,32 @@
 
 /* 1 band FIFO pseudo-"scheduler" */
 
-static int bfifo_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+static int bfifo_enqueue(struct sk_buff *skb, struct Qdisc *sch,
+			 struct sk_buff **to_free)
 {
 	if (likely(sch->qstats.backlog + qdisc_pkt_len(skb) <= sch->limit))
 		return qdisc_enqueue_tail(skb, sch);
 
-	return qdisc_drop(skb, sch);
+	return qdisc_drop(skb, sch, to_free);
 }
 
-static int pfifo_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+static int pfifo_enqueue(struct sk_buff *skb, struct Qdisc *sch,
+			 struct sk_buff **to_free)
 {
 	if (likely(skb_queue_len(&sch->q) < sch->limit))
 		return qdisc_enqueue_tail(skb, sch);
 
-	return qdisc_drop(skb, sch);
+	return qdisc_drop(skb, sch, to_free);
 }
 
-static int pfifo_tail_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+static int pfifo_tail_enqueue(struct sk_buff *skb, struct Qdisc *sch,
+			      struct sk_buff **to_free)
 {
 	if (likely(skb_queue_len(&sch->q) < sch->limit))
 		return qdisc_enqueue_tail(skb, sch);
 
 	/* queue full, remove one skb to fulfill the limit */
-	__qdisc_queue_drop_head(sch, &sch->q);
+	__qdisc_queue_drop_head(sch, &sch->q, to_free);
 	qdisc_qstats_drop(sch);
 	qdisc_enqueue_tail(skb, sch);
 
diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index 6eb06674f778..e5458b99e09c 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -368,18 +368,19 @@ static void flow_queue_add(struct fq_flow *flow, struct sk_buff *skb)
 	}
 }
 
-static int fq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+static int fq_enqueue(struct sk_buff *skb, struct Qdisc *sch,
+		      struct sk_buff **to_free)
 {
 	struct fq_sched_data *q = qdisc_priv(sch);
 	struct fq_flow *f;
 
 	if (unlikely(sch->q.qlen >= sch->limit))
-		return qdisc_drop(skb, sch);
+		return qdisc_drop(skb, sch, to_free);
 
 	f = fq_classify(skb, q);
 	if (unlikely(f->qlen >= q->flow_plimit && f != &q->internal)) {
 		q->stat_flows_plimit++;
-		return qdisc_drop(skb, sch);
+		return qdisc_drop(skb, sch, to_free);
 	}
 
 	f->qlen++;
diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index 2dc0a849515a..f715195459c9 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -139,7 +139,8 @@ static inline void flow_queue_add(struct fq_codel_flow *flow,
 	skb->next = NULL;
 }
 
-static unsigned int fq_codel_drop(struct Qdisc *sch, unsigned int max_packets)
+static unsigned int fq_codel_drop(struct Qdisc *sch, unsigned int max_packets,
+				  struct sk_buff **to_free)
 {
 	struct fq_codel_sched_data *q = qdisc_priv(sch);
 	struct sk_buff *skb;
@@ -172,7 +173,7 @@ static unsigned int fq_codel_drop(struct Qdisc *sch, unsigned int max_packets)
 		skb = dequeue_head(flow);
 		len += qdisc_pkt_len(skb);
 		mem += skb->truesize;
-		kfree_skb(skb);
+		__qdisc_drop(skb, to_free);
 	} while (++i < max_packets && len < threshold);
 
 	flow->dropped += i;
@@ -184,7 +185,8 @@ static unsigned int fq_codel_drop(struct Qdisc *sch, unsigned int max_packets)
 	return idx;
 }
 
-static int fq_codel_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+static int fq_codel_enqueue(struct sk_buff *skb, struct Qdisc *sch,
+			    struct sk_buff **to_free)
 {
 	struct fq_codel_sched_data *q = qdisc_priv(sch);
 	unsigned int idx, prev_backlog, prev_qlen;
@@ -197,7 +199,7 @@ static int fq_codel_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	if (idx == 0) {
 		if (ret & __NET_XMIT_BYPASS)
 			qdisc_qstats_drop(sch);
-		kfree_skb(skb);
+		__qdisc_drop(skb, to_free);
 		return ret;
 	}
 	idx--;
@@ -229,7 +231,7 @@ static int fq_codel_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	 * So instead of dropping a single packet, drop half of its backlog
 	 * with a 64 packets limit to not add a too big cpu spike here.
 	 */
-	ret = fq_codel_drop(sch, q->drop_batch_size);
+	ret = fq_codel_drop(sch, q->drop_batch_size, to_free);
 
 	prev_qlen -= sch->q.qlen;
 	prev_backlog -= sch->qstats.backlog;
@@ -276,7 +278,8 @@ static void drop_func(struct sk_buff *skb, void *ctx)
 {
 	struct Qdisc *sch = ctx;
 
-	qdisc_drop(skb, sch);
+	kfree_skb(skb);
+	qdisc_qstats_drop(sch);
 }
 
 static struct sk_buff *fq_codel_dequeue(struct Qdisc *sch)
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 773b632e1e33..ff86606954f2 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -348,9 +348,10 @@ EXPORT_SYMBOL(netif_carrier_off);
    cheaper.
  */
 
-static int noop_enqueue(struct sk_buff *skb, struct Qdisc *qdisc)
+static int noop_enqueue(struct sk_buff *skb, struct Qdisc *qdisc,
+			struct sk_buff **to_free)
 {
-	kfree_skb(skb);
+	__qdisc_drop(skb, to_free);
 	return NET_XMIT_CN;
 }
 
@@ -439,7 +440,8 @@ static inline struct sk_buff_head *band2list(struct pfifo_fast_priv *priv,
 	return priv->q + band;
 }
 
-static int pfifo_fast_enqueue(struct sk_buff *skb, struct Qdisc *qdisc)
+static int pfifo_fast_enqueue(struct sk_buff *skb, struct Qdisc *qdisc,
+			      struct sk_buff **to_free)
 {
 	if (skb_queue_len(&qdisc->q) < qdisc_dev(qdisc)->tx_queue_len) {
 		int band = prio2band[skb->priority & TC_PRIO_MAX];
@@ -451,7 +453,7 @@ static int pfifo_fast_enqueue(struct sk_buff *skb, struct Qdisc *qdisc)
 		return __qdisc_enqueue_tail(skb, qdisc, list);
 	}
 
-	return qdisc_drop(skb, qdisc);
+	return qdisc_drop(skb, qdisc, to_free);
 }
 
 static struct sk_buff *pfifo_fast_dequeue(struct Qdisc *qdisc)
diff --git a/net/sched/sch_gred.c b/net/sched/sch_gred.c
index b5fb63c7be02..c78a093c551a 100644
--- a/net/sched/sch_gred.c
+++ b/net/sched/sch_gred.c
@@ -149,7 +149,8 @@ static inline int gred_use_harddrop(struct gred_sched *t)
 	return t->red_flags & TC_RED_HARDDROP;
 }
 
-static int gred_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+static int gred_enqueue(struct sk_buff *skb, struct Qdisc *sch,
+			struct sk_buff **to_free)
 {
 	struct gred_sched_data *q = NULL;
 	struct gred_sched *t = qdisc_priv(sch);
@@ -237,10 +238,10 @@ static int gred_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 	q->stats.pdrop++;
 drop:
-	return qdisc_drop(skb, sch);
+	return qdisc_drop(skb, sch, to_free);
 
 congestion_drop:
-	qdisc_drop(skb, sch);
+	qdisc_drop(skb, sch, to_free);
 	return NET_XMIT_CN;
 }
 
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index bd08c363a26d..8cb5eff7b79c 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1572,7 +1572,7 @@ hfsc_dump_qdisc(struct Qdisc *sch, struct sk_buff *skb)
 }
 
 static int
-hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch, struct sk_buff **to_free)
 {
 	struct hfsc_class *cl;
 	int uninitialized_var(err);
@@ -1581,11 +1581,11 @@ hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	if (cl == NULL) {
 		if (err & __NET_XMIT_BYPASS)
 			qdisc_qstats_drop(sch);
-		kfree_skb(skb);
+		__qdisc_drop(skb, to_free);
 		return err;
 	}
 
-	err = qdisc_enqueue(skb, cl->qdisc);
+	err = qdisc_enqueue(skb, cl->qdisc, to_free);
 	if (unlikely(err != NET_XMIT_SUCCESS)) {
 		if (net_xmit_drop_count(err)) {
 			cl->qstats.drops++;
diff --git a/net/sched/sch_hhf.c b/net/sched/sch_hhf.c
index c44593b8e65a..e3d0458af17b 100644
--- a/net/sched/sch_hhf.c
+++ b/net/sched/sch_hhf.c
@@ -345,7 +345,7 @@ static void bucket_add(struct wdrr_bucket *bucket, struct sk_buff *skb)
 	skb->next = NULL;
 }
 
-static unsigned int hhf_drop(struct Qdisc *sch)
+static unsigned int hhf_drop(struct Qdisc *sch, struct sk_buff **to_free)
 {
 	struct hhf_sched_data *q = qdisc_priv(sch);
 	struct wdrr_bucket *bucket;
@@ -359,16 +359,16 @@ static unsigned int hhf_drop(struct Qdisc *sch)
 		struct sk_buff *skb = dequeue_head(bucket);
 
 		sch->q.qlen--;
-		qdisc_qstats_drop(sch);
 		qdisc_qstats_backlog_dec(sch, skb);
-		kfree_skb(skb);
+		qdisc_drop(skb, sch, to_free);
 	}
 
 	/* Return id of the bucket from which the packet was dropped. */
 	return bucket - q->buckets;
 }
 
-static int hhf_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+static int hhf_enqueue(struct sk_buff *skb, struct Qdisc *sch,
+		       struct sk_buff **to_free)
 {
 	struct hhf_sched_data *q = qdisc_priv(sch);
 	enum wdrr_bucket_idx idx;
@@ -406,7 +406,7 @@ static int hhf_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	/* Return Congestion Notification only if we dropped a packet from this
 	 * bucket.
 	 */
-	if (hhf_drop(sch) == idx)
+	if (hhf_drop(sch, to_free) == idx)
 		return NET_XMIT_CN;
 
 	/* As we dropped a packet, better let upper stack know this. */
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index a454605ab5cb..f3882259c385 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -569,7 +569,8 @@ static inline void htb_deactivate(struct htb_sched *q, struct htb_class *cl)
 	list_del_init(&cl->un.leaf.drop_list);
 }
 
-static int htb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+static int htb_enqueue(struct sk_buff *skb, struct Qdisc *sch,
+		       struct sk_buff **to_free)
 {
 	int uninitialized_var(ret);
 	struct htb_sched *q = qdisc_priv(sch);
@@ -581,16 +582,17 @@ static int htb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 			__skb_queue_tail(&q->direct_queue, skb);
 			q->direct_pkts++;
 		} else {
-			return qdisc_drop(skb, sch);
+			return qdisc_drop(skb, sch, to_free);
 		}
 #ifdef CONFIG_NET_CLS_ACT
 	} else if (!cl) {
 		if (ret & __NET_XMIT_BYPASS)
 			qdisc_qstats_drop(sch);
-		kfree_skb(skb);
+		__qdisc_drop(skb, to_free);
 		return ret;
 #endif
-	} else if ((ret = qdisc_enqueue(skb, cl->un.leaf.q)) != NET_XMIT_SUCCESS) {
+	} else if ((ret = qdisc_enqueue(skb, cl->un.leaf.q,
+					to_free)) != NET_XMIT_SUCCESS) {
 		if (net_xmit_drop_count(ret)) {
 			qdisc_qstats_drop(sch);
 			cl->qstats.drops++;
diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
index 5ea93305d705..9ffbb025b37e 100644
--- a/net/sched/sch_multiq.c
+++ b/net/sched/sch_multiq.c
@@ -65,7 +65,8 @@ multiq_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 }
 
 static int
-multiq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+multiq_enqueue(struct sk_buff *skb, struct Qdisc *sch,
+	       struct sk_buff **to_free)
 {
 	struct Qdisc *qdisc;
 	int ret;
@@ -76,12 +77,12 @@ multiq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 		if (ret & __NET_XMIT_BYPASS)
 			qdisc_qstats_drop(sch);
-		kfree_skb(skb);
+		__qdisc_drop(skb, to_free);
 		return ret;
 	}
 #endif
 
-	ret = qdisc_enqueue(skb, qdisc);
+	ret = qdisc_enqueue(skb, qdisc, to_free);
 	if (ret == NET_XMIT_SUCCESS) {
 		sch->q.qlen++;
 		return NET_XMIT_SUCCESS;
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index e271967439bf..ccca8ca4c722 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -397,7 +397,8 @@ static void tfifo_enqueue(struct sk_buff *nskb, struct Qdisc *sch)
  * when we statistically choose to corrupt one, we instead segment it, returning
  * the first packet to be corrupted, and re-enqueue the remaining frames
  */
-static struct sk_buff *netem_segment(struct sk_buff *skb, struct Qdisc *sch)
+static struct sk_buff *netem_segment(struct sk_buff *skb, struct Qdisc *sch,
+				     struct sk_buff **to_free)
 {
 	struct sk_buff *segs;
 	netdev_features_t features = netif_skb_features(skb);
@@ -405,7 +406,7 @@ static struct sk_buff *netem_segment(struct sk_buff *skb, struct Qdisc *sch)
 	segs = skb_gso_segment(skb, features & ~NETIF_F_GSO_MASK);
 
 	if (IS_ERR_OR_NULL(segs)) {
-		qdisc_drop(skb, sch);
+		qdisc_drop(skb, sch, to_free);
 		return NULL;
 	}
 	consume_skb(skb);
@@ -418,7 +419,8 @@ static struct sk_buff *netem_segment(struct sk_buff *skb, struct Qdisc *sch)
  * 	NET_XMIT_DROP: queue length didn't change.
  *      NET_XMIT_SUCCESS: one skb was queued.
  */
-static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch,
+			 struct sk_buff **to_free)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
 	/* We don't fill cb now as skb_unshare() may invalidate it */
@@ -443,7 +445,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	}
 	if (count == 0) {
 		qdisc_qstats_drop(sch);
-		kfree_skb(skb);
+		__qdisc_drop(skb, to_free);
 		return NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
 	}
 
@@ -463,7 +465,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		u32 dupsave = q->duplicate; /* prevent duplicating a dup... */
 
 		q->duplicate = 0;
-		rootq->enqueue(skb2, rootq);
+		rootq->enqueue(skb2, rootq, to_free);
 		q->duplicate = dupsave;
 	}
 
@@ -475,7 +477,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	 */
 	if (q->corrupt && q->corrupt >= get_crandom(&q->corrupt_cor)) {
 		if (skb_is_gso(skb)) {
-			segs = netem_segment(skb, sch);
+			segs = netem_segment(skb, sch, to_free);
 			if (!segs)
 				return NET_XMIT_DROP;
 		} else {
@@ -488,7 +490,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		if (!(skb = skb_unshare(skb, GFP_ATOMIC)) ||
 		    (skb->ip_summed == CHECKSUM_PARTIAL &&
 		     skb_checksum_help(skb))) {
-			rc = qdisc_drop(skb, sch);
+			rc = qdisc_drop(skb, sch, to_free);
 			goto finish_segs;
 		}
 
@@ -497,7 +499,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	}
 
 	if (unlikely(skb_queue_len(&sch->q) >= sch->limit))
-		return qdisc_drop(skb, sch);
+		return qdisc_drop(skb, sch, to_free);
 
 	qdisc_qstats_backlog_inc(sch, skb);
 
@@ -557,7 +559,7 @@ finish_segs:
 			segs->next = NULL;
 			qdisc_skb_cb(segs)->pkt_len = segs->len;
 			last_len = segs->len;
-			rc = qdisc_enqueue(segs, sch);
+			rc = qdisc_enqueue(segs, sch, to_free);
 			if (rc != NET_XMIT_SUCCESS) {
 				if (net_xmit_drop_count(rc))
 					qdisc_qstats_drop(sch);
@@ -615,8 +617,11 @@ deliver:
 #endif
 
 			if (q->qdisc) {
-				int err = qdisc_enqueue(skb, q->qdisc);
+				struct sk_buff *to_free = NULL;
+				int err;
 
+				err = qdisc_enqueue(skb, q->qdisc, &to_free);
+				kfree_skb_list(to_free);
 				if (unlikely(err != NET_XMIT_SUCCESS)) {
 					if (net_xmit_drop_count(err)) {
 						qdisc_qstats_drop(sch);
diff --git a/net/sched/sch_pie.c b/net/sched/sch_pie.c
index 912a46a5d02e..a570b0bb254c 100644
--- a/net/sched/sch_pie.c
+++ b/net/sched/sch_pie.c
@@ -134,7 +134,8 @@ static bool drop_early(struct Qdisc *sch, u32 packet_size)
 	return false;
 }
 
-static int pie_qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+static int pie_qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch,
+			     struct sk_buff **to_free)
 {
 	struct pie_sched_data *q = qdisc_priv(sch);
 	bool enqueue = false;
@@ -166,7 +167,7 @@ static int pie_qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 out:
 	q->stats.dropped++;
-	return qdisc_drop(skb, sch);
+	return qdisc_drop(skb, sch, to_free);
 }
 
 static const struct nla_policy pie_policy[TCA_PIE_MAX + 1] = {
diff --git a/net/sched/sch_plug.c b/net/sched/sch_plug.c
index a12cd37680f8..1c6cbab3e7b9 100644
--- a/net/sched/sch_plug.c
+++ b/net/sched/sch_plug.c
@@ -88,7 +88,8 @@ struct plug_sched_data {
 	u32 pkts_to_release;
 };
 
-static int plug_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+static int plug_enqueue(struct sk_buff *skb, struct Qdisc *sch,
+			struct sk_buff **to_free)
 {
 	struct plug_sched_data *q = qdisc_priv(sch);
 
@@ -98,7 +99,7 @@ static int plug_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		return qdisc_enqueue_tail(skb, sch);
 	}
 
-	return qdisc_drop(skb, sch);
+	return qdisc_drop(skb, sch, to_free);
 }
 
 static struct sk_buff *plug_dequeue(struct Qdisc *sch)
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index de492682caee..f4d443aeae54 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -67,7 +67,7 @@ prio_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 }
 
 static int
-prio_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+prio_enqueue(struct sk_buff *skb, struct Qdisc *sch, struct sk_buff **to_free)
 {
 	struct Qdisc *qdisc;
 	int ret;
@@ -83,7 +83,7 @@ prio_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	}
 #endif
 
-	ret = qdisc_enqueue(skb, qdisc);
+	ret = qdisc_enqueue(skb, qdisc, to_free);
 	if (ret == NET_XMIT_SUCCESS) {
 		qdisc_qstats_backlog_inc(sch, skb);
 		sch->q.qlen++;
diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index 0427fa8b23f2..f27ffee106f6 100644
--- a/net/sched/sch_qfq.c
+++ b/net/sched/sch_qfq.c
@@ -1217,7 +1217,8 @@ static struct qfq_aggregate *qfq_choose_next_agg(struct qfq_sched *q)
 	return agg;
 }
 
-static int qfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+static int qfq_enqueue(struct sk_buff *skb, struct Qdisc *sch,
+		       struct sk_buff **to_free)
 {
 	struct qfq_sched *q = qdisc_priv(sch);
 	struct qfq_class *cl;
@@ -1240,11 +1241,11 @@ static int qfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 				     qdisc_pkt_len(skb));
 		if (err) {
 			cl->qstats.drops++;
-			return qdisc_drop(skb, sch);
+			return qdisc_drop(skb, sch, to_free);
 		}
 	}
 
-	err = qdisc_enqueue(skb, cl->qdisc);
+	err = qdisc_enqueue(skb, cl->qdisc, to_free);
 	if (unlikely(err != NET_XMIT_SUCCESS)) {
 		pr_debug("qfq_enqueue: enqueue failed %d\n", err);
 		if (net_xmit_drop_count(err)) {
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index a0d57530335e..249b2a18acbd 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -56,7 +56,8 @@ static inline int red_use_harddrop(struct red_sched_data *q)
 	return q->flags & TC_RED_HARDDROP;
 }
 
-static int red_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+static int red_enqueue(struct sk_buff *skb, struct Qdisc *sch,
+		       struct sk_buff **to_free)
 {
 	struct red_sched_data *q = qdisc_priv(sch);
 	struct Qdisc *child = q->qdisc;
@@ -95,7 +96,7 @@ static int red_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		break;
 	}
 
-	ret = qdisc_enqueue(skb, child);
+	ret = qdisc_enqueue(skb, child, to_free);
 	if (likely(ret == NET_XMIT_SUCCESS)) {
 		qdisc_qstats_backlog_inc(sch, skb);
 		sch->q.qlen++;
@@ -106,7 +107,7 @@ static int red_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	return ret;
 
 congestion_drop:
-	qdisc_drop(skb, sch);
+	qdisc_drop(skb, sch, to_free);
 	return NET_XMIT_CN;
 }
 
diff --git a/net/sched/sch_sfb.c b/net/sched/sch_sfb.c
index c69611640fa5..add3cc7d37ec 100644
--- a/net/sched/sch_sfb.c
+++ b/net/sched/sch_sfb.c
@@ -275,7 +275,8 @@ static bool sfb_classify(struct sk_buff *skb, struct tcf_proto *fl,
 	return false;
 }
 
-static int sfb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+static int sfb_enqueue(struct sk_buff *skb, struct Qdisc *sch,
+		       struct sk_buff **to_free)
 {
 
 	struct sfb_sched_data *q = qdisc_priv(sch);
@@ -397,7 +398,7 @@ static int sfb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	}
 
 enqueue:
-	ret = qdisc_enqueue(skb, child);
+	ret = qdisc_enqueue(skb, child, to_free);
 	if (likely(ret == NET_XMIT_SUCCESS)) {
 		sch->q.qlen++;
 		increment_qlen(skb, q);
@@ -408,7 +409,7 @@ enqueue:
 	return ret;
 
 drop:
-	qdisc_drop(skb, sch);
+	qdisc_drop(skb, sch, to_free);
 	return NET_XMIT_CN;
 other_drop:
 	if (ret & __NET_XMIT_BYPASS)
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 57d118b41cad..7f195ed4d568 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -343,7 +343,7 @@ static int sfq_headdrop(const struct sfq_sched_data *q)
 }
 
 static int
-sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch, struct sk_buff **to_free)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
 	unsigned int hash, dropped;
@@ -367,7 +367,7 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	if (x == SFQ_EMPTY_SLOT) {
 		x = q->dep[0].next; /* get a free slot */
 		if (x >= SFQ_MAX_FLOWS)
-			return qdisc_drop(skb, sch);
+			return qdisc_drop(skb, sch, to_free);
 		q->ht[hash] = x;
 		slot = &q->slots[x];
 		slot->hash = hash;
@@ -424,14 +424,14 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	if (slot->qlen >= q->maxdepth) {
 congestion_drop:
 		if (!sfq_headdrop(q))
-			return qdisc_drop(skb, sch);
+			return qdisc_drop(skb, sch, to_free);
 
 		/* We know we have at least one packet in queue */
 		head = slot_dequeue_head(slot);
 		delta = qdisc_pkt_len(head) - qdisc_pkt_len(skb);
 		sch->qstats.backlog -= delta;
 		slot->backlog -= delta;
-		qdisc_drop(head, sch);
+		qdisc_drop(head, sch, to_free);
 
 		slot_queue_add(slot, skb);
 		return NET_XMIT_CN;
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index c12df84d1078..303355c449ab 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -155,7 +155,8 @@ static unsigned int skb_gso_mac_seglen(const struct sk_buff *skb)
 /* GSO packet is too big, segment it so that tbf can transmit
  * each segment in time
  */
-static int tbf_segment(struct sk_buff *skb, struct Qdisc *sch)
+static int tbf_segment(struct sk_buff *skb, struct Qdisc *sch,
+		       struct sk_buff **to_free)
 {
 	struct tbf_sched_data *q = qdisc_priv(sch);
 	struct sk_buff *segs, *nskb;
@@ -166,7 +167,7 @@ static int tbf_segment(struct sk_buff *skb, struct Qdisc *sch)
 	segs = skb_gso_segment(skb, features & ~NETIF_F_GSO_MASK);
 
 	if (IS_ERR_OR_NULL(segs))
-		return qdisc_drop(skb, sch);
+		return qdisc_drop(skb, sch, to_free);
 
 	nb = 0;
 	while (segs) {
@@ -174,7 +175,7 @@ static int tbf_segment(struct sk_buff *skb, struct Qdisc *sch)
 		segs->next = NULL;
 		qdisc_skb_cb(segs)->pkt_len = segs->len;
 		len += segs->len;
-		ret = qdisc_enqueue(segs, q->qdisc);
+		ret = qdisc_enqueue(segs, q->qdisc, to_free);
 		if (ret != NET_XMIT_SUCCESS) {
 			if (net_xmit_drop_count(ret))
 				qdisc_qstats_drop(sch);
@@ -190,17 +191,18 @@ static int tbf_segment(struct sk_buff *skb, struct Qdisc *sch)
 	return nb > 0 ? NET_XMIT_SUCCESS : NET_XMIT_DROP;
 }
 
-static int tbf_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+static int tbf_enqueue(struct sk_buff *skb, struct Qdisc *sch,
+		       struct sk_buff **to_free)
 {
 	struct tbf_sched_data *q = qdisc_priv(sch);
 	int ret;
 
 	if (qdisc_pkt_len(skb) > q->max_size) {
 		if (skb_is_gso(skb) && skb_gso_mac_seglen(skb) <= q->max_size)
-			return tbf_segment(skb, sch);
-		return qdisc_drop(skb, sch);
+			return tbf_segment(skb, sch, to_free);
+		return qdisc_drop(skb, sch, to_free);
 	}
-	ret = qdisc_enqueue(skb, q->qdisc);
+	ret = qdisc_enqueue(skb, q->qdisc, to_free);
 	if (ret != NET_XMIT_SUCCESS) {
 		if (net_xmit_drop_count(ret))
 			qdisc_qstats_drop(sch);
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index e02687185a59..2cd9b4478b92 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -77,7 +77,7 @@ struct teql_sched_data {
 /* "teql*" qdisc routines */
 
 static int
-teql_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+teql_enqueue(struct sk_buff *skb, struct Qdisc *sch, struct sk_buff **to_free)
 {
 	struct net_device *dev = qdisc_dev(sch);
 	struct teql_sched_data *q = qdisc_priv(sch);
@@ -87,7 +87,7 @@ teql_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		return NET_XMIT_SUCCESS;
 	}
 
-	return qdisc_drop(skb, sch);
+	return qdisc_drop(skb, sch, to_free);
 }
 
 static struct sk_buff *
-- 
2.8.0.rc3.226.g39d4020
