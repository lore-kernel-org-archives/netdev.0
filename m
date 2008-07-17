From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: [PATCH RFC 2/3] net_sched: Add accessor function for packet length
	for qdiscs
Date: Thu, 17 Jul 2008 13:09:33 +0300
Message-ID: <20080717100933.3327.20158.stgit@fate.lan>
References: <20080717100921.3327.3324.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.dnainternet.fi ([87.94.96.112]:39168 "EHLO
	smtp2.dnainternet.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755530AbYGQKJf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 06:09:35 -0400
In-Reply-To: <20080717100921.3327.3324.stgit@fate.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
---

 include/net/sch_generic.h |   17 +++++++++++------
 net/sched/sch_atm.c       |    4 ++--
 net/sched/sch_cbq.c       |   14 ++++++--------
 net/sched/sch_dsmark.c    |    2 +-
 net/sched/sch_fifo.c      |    2 +-
 net/sched/sch_gred.c      |   12 ++++++------
 net/sched/sch_hfsc.c      |   14 ++++++--------
 net/sched/sch_htb.c       |    9 +++++----
 net/sched/sch_netem.c     |    6 +++---
 net/sched/sch_prio.c      |    2 +-
 net/sched/sch_red.c       |    2 +-
 net/sched/sch_sfq.c       |   16 ++++++++--------
 net/sched/sch_tbf.c       |    9 ++++++---
 net/sched/sch_teql.c      |    6 +++---
 14 files changed, 60 insertions(+), 55 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index e3b0d71..1f1de3b 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -258,6 +258,11 @@ static inline bool qdisc_tx_is_noop(const struct net_device *dev)
 	return (txq->qdisc == &noop_qdisc);
 }
 
+static inline unsigned int qdisc_tx_len(struct sk_buff *skb)
+{
+	return skb->len;
+}
+
 static inline int qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	return sch->enqueue(skb, sch);
@@ -267,8 +272,8 @@ static inline int __qdisc_enqueue_tail(struct sk_buff *skb, struct Qdisc *sch,
 				       struct sk_buff_head *list)
 {
 	__skb_queue_tail(list, skb);
-	sch->qstats.backlog += skb->len;
-	sch->bstats.bytes += skb->len;
+	sch->qstats.backlog += qdisc_tx_len(skb);
+	sch->bstats.bytes += qdisc_tx_len(skb);
 	sch->bstats.packets++;
 
 	return NET_XMIT_SUCCESS;
@@ -285,7 +290,7 @@ static inline struct sk_buff *__qdisc_dequeue_head(struct Qdisc *sch,
 	struct sk_buff *skb = __skb_dequeue(list);
 
 	if (likely(skb != NULL))
-		sch->qstats.backlog -= skb->len;
+		sch->qstats.backlog -= qdisc_tx_len(skb);
 
 	return skb;
 }
@@ -301,7 +306,7 @@ static inline struct sk_buff *__qdisc_dequeue_tail(struct Qdisc *sch,
 	struct sk_buff *skb = __skb_dequeue_tail(list);
 
 	if (likely(skb != NULL))
-		sch->qstats.backlog -= skb->len;
+		sch->qstats.backlog -= qdisc_tx_len(skb);
 
 	return skb;
 }
@@ -315,7 +320,7 @@ static inline int __qdisc_requeue(struct sk_buff *skb, struct Qdisc *sch,
 				  struct sk_buff_head *list)
 {
 	__skb_queue_head(list, skb);
-	sch->qstats.backlog += skb->len;
+	sch->qstats.backlog += qdisc_tx_len(skb);
 	sch->qstats.requeues++;
 
 	return NET_XMIT_SUCCESS;
@@ -348,7 +353,7 @@ static inline unsigned int __qdisc_queue_drop(struct Qdisc *sch,
 	struct sk_buff *skb = __qdisc_dequeue_tail(sch, list);
 
 	if (likely(skb != NULL)) {
-		unsigned int len = skb->len;
+		unsigned int len = qdisc_tx_len(skb);
 		kfree_skb(skb);
 		return len;
 	}
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 68ed35e..fdadbf0 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -437,9 +437,9 @@ drop: __maybe_unused
 			flow->qstats.drops++;
 		return ret;
 	}
-	sch->bstats.bytes += skb->len;
+	sch->bstats.bytes += qdisc_tx_len(skb);
 	sch->bstats.packets++;
-	flow->bstats.bytes += skb->len;
+	flow->bstats.bytes += qdisc_tx_len(skb);
 	flow->bstats.packets++;
 	/*
 	 * Okay, this may seem weird. We pretend we've dropped the packet if
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 1bcb3e8..a4b7351 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -370,7 +370,6 @@ static int
 cbq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct cbq_sched_data *q = qdisc_priv(sch);
-	int len = skb->len;
 	int uninitialized_var(ret);
 	struct cbq_class *cl = cbq_classify(skb, sch, &ret);
 
@@ -391,7 +390,7 @@ cbq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	if (ret == NET_XMIT_SUCCESS) {
 		sch->q.qlen++;
 		sch->bstats.packets++;
-		sch->bstats.bytes+=len;
+		sch->bstats.bytes += qdisc_tx_len(skb);
 		cbq_mark_toplevel(q, cl);
 		if (!cl->next_alive)
 			cbq_activate_class(cl);
@@ -658,7 +657,6 @@ static enum hrtimer_restart cbq_undelay(struct hrtimer *timer)
 #ifdef CONFIG_NET_CLS_ACT
 static int cbq_reshape_fail(struct sk_buff *skb, struct Qdisc *child)
 {
-	int len = skb->len;
 	struct Qdisc *sch = child->__parent;
 	struct cbq_sched_data *q = qdisc_priv(sch);
 	struct cbq_class *cl = q->rx_class;
@@ -675,7 +673,7 @@ static int cbq_reshape_fail(struct sk_buff *skb, struct Qdisc *child)
 		if (qdisc_enqueue(skb, cl->q) == 0) {
 			sch->q.qlen++;
 			sch->bstats.packets++;
-			sch->bstats.bytes+=len;
+			sch->bstats.bytes += qdisc_tx_len(skb);
 			if (!cl->next_alive)
 				cbq_activate_class(cl);
 			return 0;
@@ -881,7 +879,7 @@ cbq_dequeue_prio(struct Qdisc *sch, int prio)
 			if (skb == NULL)
 				goto skip_class;
 
-			cl->deficit -= skb->len;
+			cl->deficit -= qdisc_tx_len(skb);
 			q->tx_class = cl;
 			q->tx_borrowed = borrow;
 			if (borrow != cl) {
@@ -889,11 +887,11 @@ cbq_dequeue_prio(struct Qdisc *sch, int prio)
 				borrow->xstats.borrows++;
 				cl->xstats.borrows++;
 #else
-				borrow->xstats.borrows += skb->len;
-				cl->xstats.borrows += skb->len;
+				borrow->xstats.borrows += qdisc_tx_len(skb);
+				cl->xstats.borrows += qdisc_tx_len(skb);
 #endif
 			}
-			q->tx_len = skb->len;
+			q->tx_len = qdisc_tx_len(skb);
 
 			if (cl->deficit <= 0) {
 				q->active[prio] = cl;
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 44d347e..4a4cd62 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -258,7 +258,7 @@ static int dsmark_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		return err;
 	}
 
-	sch->bstats.bytes += skb->len;
+	sch->bstats.bytes += qdisc_tx_len(skb);
 	sch->bstats.packets++;
 	sch->q.qlen++;
 
diff --git a/net/sched/sch_fifo.c b/net/sched/sch_fifo.c
index 1d97fa4..9f63fb4 100644
--- a/net/sched/sch_fifo.c
+++ b/net/sched/sch_fifo.c
@@ -27,7 +27,7 @@ static int bfifo_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 {
 	struct fifo_sched_data *q = qdisc_priv(sch);
 
-	if (likely(sch->qstats.backlog + skb->len <= q->limit))
+	if (likely(sch->qstats.backlog + qdisc_tx_len(skb) <= q->limit))
 		return qdisc_enqueue_tail(skb, sch);
 
 	return qdisc_reshape_fail(skb, sch);
diff --git a/net/sched/sch_gred.c b/net/sched/sch_gred.c
index 39fa285..36f4326 100644
--- a/net/sched/sch_gred.c
+++ b/net/sched/sch_gred.c
@@ -188,7 +188,7 @@ static int gred_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 	}
 
 	q->packetsin++;
-	q->bytesin += skb->len;
+	q->bytesin += qdisc_tx_len(skb);
 
 	if (gred_wred_mode(t))
 		gred_load_wred_set(t, q);
@@ -226,8 +226,8 @@ static int gred_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 			break;
 	}
 
-	if (q->backlog + skb->len <= q->limit) {
-		q->backlog += skb->len;
+	if (q->backlog + qdisc_tx_len(skb) <= q->limit) {
+		q->backlog += qdisc_tx_len(skb);
 		return qdisc_enqueue_tail(skb, sch);
 	}
 
@@ -254,7 +254,7 @@ static int gred_requeue(struct sk_buff *skb, struct Qdisc* sch)
 	} else {
 		if (red_is_idling(&q->parms))
 			red_end_of_idle_period(&q->parms);
-		q->backlog += skb->len;
+		q->backlog += qdisc_tx_len(skb);
 	}
 
 	return qdisc_requeue(skb, sch);
@@ -277,7 +277,7 @@ static struct sk_buff *gred_dequeue(struct Qdisc* sch)
 				       "VQ 0x%x after dequeue, screwing up "
 				       "backlog.\n", tc_index_to_dp(skb));
 		} else {
-			q->backlog -= skb->len;
+			q->backlog -= qdisc_tx_len(skb);
 
 			if (!q->backlog && !gred_wred_mode(t))
 				red_start_of_idle_period(&q->parms);
@@ -299,7 +299,7 @@ static unsigned int gred_drop(struct Qdisc* sch)
 
 	skb = qdisc_dequeue_tail(sch);
 	if (skb) {
-		unsigned int len = skb->len;
+		unsigned int len = qdisc_tx_len(skb);
 		struct gred_sched_data *q;
 		u16 dp = tc_index_to_dp(skb);
 
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 0ded6d0..76f8278 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -895,7 +895,7 @@ qdisc_peek_len(struct Qdisc *sch)
 			printk("qdisc_peek_len: non work-conserving qdisc ?\n");
 		return 0;
 	}
-	len = skb->len;
+	len = qdisc_tx_len(skb);
 	if (unlikely(sch->ops->requeue(skb, sch) != NET_XMIT_SUCCESS)) {
 		if (net_ratelimit())
 			printk("qdisc_peek_len: failed to requeue\n");
@@ -1574,7 +1574,6 @@ static int
 hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct hfsc_class *cl;
-	unsigned int len;
 	int err;
 
 	cl = hfsc_classify(skb, sch, &err);
@@ -1585,7 +1584,6 @@ hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		return err;
 	}
 
-	len = skb->len;
 	err = qdisc_enqueue(skb, cl->qdisc);
 	if (unlikely(err != NET_XMIT_SUCCESS)) {
 		cl->qstats.drops++;
@@ -1594,12 +1592,12 @@ hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	}
 
 	if (cl->qdisc->q.qlen == 1)
-		set_active(cl, len);
+		set_active(cl, qdisc_tx_len(skb));
 
 	cl->bstats.packets++;
-	cl->bstats.bytes += len;
+	cl->bstats.bytes += qdisc_tx_len(skb);
 	sch->bstats.packets++;
-	sch->bstats.bytes += len;
+	sch->bstats.bytes += qdisc_tx_len(skb);
 	sch->q.qlen++;
 
 	return NET_XMIT_SUCCESS;
@@ -1649,9 +1647,9 @@ hfsc_dequeue(struct Qdisc *sch)
 		return NULL;
 	}
 
-	update_vf(cl, skb->len, cur_time);
+	update_vf(cl, qdisc_tx_len(skb), cur_time);
 	if (realtime)
-		cl->cl_cumul += skb->len;
+		cl->cl_cumul += qdisc_tx_len(skb);
 
 	if (cl->qdisc->q.qlen != 0) {
 		if (cl->cl_flags & HFSC_RSC) {
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 5fc0325..5e1dcf8 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -579,13 +579,13 @@ static int htb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	} else {
 		cl->bstats.packets +=
 			skb_is_gso(skb)?skb_shinfo(skb)->gso_segs:1;
-		cl->bstats.bytes += skb->len;
+		cl->bstats.bytes += qdisc_tx_len(skb);
 		htb_activate(q, cl);
 	}
 
 	sch->q.qlen++;
 	sch->bstats.packets += skb_is_gso(skb)?skb_shinfo(skb)->gso_segs:1;
-	sch->bstats.bytes += skb->len;
+	sch->bstats.bytes += qdisc_tx_len(skb);
 	return NET_XMIT_SUCCESS;
 }
 
@@ -642,7 +642,7 @@ static int htb_requeue(struct sk_buff *skb, struct Qdisc *sch)
 static void htb_charge_class(struct htb_sched *q, struct htb_class *cl,
 			     int level, struct sk_buff *skb)
 {
-	int bytes = skb->len;
+	int bytes = qdisc_tx_len(skb);
 	long toks, diff;
 	enum htb_cmode old_mode;
 
@@ -855,7 +855,8 @@ next:
 	} while (cl != start);
 
 	if (likely(skb != NULL)) {
-		if ((cl->un.leaf.deficit[level] -= skb->len) < 0) {
+		cl->un.leaf.deficit[level] -= qdisc_tx_len(skb);
+		if (cl->un.leaf.deficit[level] < 0) {
 			cl->un.leaf.deficit[level] += cl->un.leaf.quantum;
 			htb_next_rb_node((level ? cl->parent->un.inner.ptr : q->
 					  ptr[0]) + prio);
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index cbdbc6a..bc9d6af 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -236,7 +236,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 	if (likely(ret == NET_XMIT_SUCCESS)) {
 		sch->q.qlen++;
-		sch->bstats.bytes += skb->len;
+		sch->bstats.bytes += qdisc_tx_len(skb);
 		sch->bstats.packets++;
 	} else
 		sch->qstats.drops++;
@@ -477,8 +477,8 @@ static int tfifo_enqueue(struct sk_buff *nskb, struct Qdisc *sch)
 
 		__skb_queue_after(list, skb, nskb);
 
-		sch->qstats.backlog += nskb->len;
-		sch->bstats.bytes += nskb->len;
+		sch->qstats.backlog += qdisc_tx_len(nskb);
+		sch->bstats.bytes += qdisc_tx_len(nskb);
 		sch->bstats.packets++;
 
 		return NET_XMIT_SUCCESS;
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 918d090..b5889e8 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -88,7 +88,7 @@ prio_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 	ret = qdisc_enqueue(skb, qdisc);
 	if (ret == NET_XMIT_SUCCESS) {
-		sch->bstats.bytes += skb->len;
+		sch->bstats.bytes += qdisc_tx_len(skb);
 		sch->bstats.packets++;
 		sch->q.qlen++;
 		return NET_XMIT_SUCCESS;
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index b48a391..6f34e80 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -94,7 +94,7 @@ static int red_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 
 	ret = qdisc_enqueue(skb, child);
 	if (likely(ret == NET_XMIT_SUCCESS)) {
-		sch->bstats.bytes += skb->len;
+		sch->bstats.bytes += qdisc_tx_len(skb);
 		sch->bstats.packets++;
 		sch->q.qlen++;
 	} else {
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 8458f63..ca3876b 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -245,7 +245,7 @@ static unsigned int sfq_drop(struct Qdisc *sch)
 	if (d > 1) {
 		sfq_index x = q->dep[d + SFQ_DEPTH].next;
 		skb = q->qs[x].prev;
-		len = skb->len;
+		len = qdisc_tx_len(skb);
 		__skb_unlink(skb, &q->qs[x]);
 		kfree_skb(skb);
 		sfq_dec(q, x);
@@ -261,7 +261,7 @@ static unsigned int sfq_drop(struct Qdisc *sch)
 		q->next[q->tail] = q->next[d];
 		q->allot[q->next[d]] += q->quantum;
 		skb = q->qs[d].prev;
-		len = skb->len;
+		len = qdisc_tx_len(skb);
 		__skb_unlink(skb, &q->qs[d]);
 		kfree_skb(skb);
 		sfq_dec(q, d);
@@ -305,7 +305,7 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	if (q->qs[x].qlen >= q->limit)
 		return qdisc_drop(skb, sch);
 
-	sch->qstats.backlog += skb->len;
+	sch->qstats.backlog += qdisc_tx_len(skb);
 	__skb_queue_tail(&q->qs[x], skb);
 	sfq_inc(q, x);
 	if (q->qs[x].qlen == 1) {		/* The flow is new */
@@ -320,7 +320,7 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		}
 	}
 	if (++sch->q.qlen <= q->limit) {
-		sch->bstats.bytes += skb->len;
+		sch->bstats.bytes += qdisc_tx_len(skb);
 		sch->bstats.packets++;
 		return 0;
 	}
@@ -352,7 +352,7 @@ sfq_requeue(struct sk_buff *skb, struct Qdisc *sch)
 		q->hash[x] = hash;
 	}
 
-	sch->qstats.backlog += skb->len;
+	sch->qstats.backlog += qdisc_tx_len(skb);
 	__skb_queue_head(&q->qs[x], skb);
 	/* If selected queue has length q->limit+1, this means that
 	 * all another queues are empty and we do simple tail drop.
@@ -363,7 +363,7 @@ sfq_requeue(struct sk_buff *skb, struct Qdisc *sch)
 		skb = q->qs[x].prev;
 		__skb_unlink(skb, &q->qs[x]);
 		sch->qstats.drops++;
-		sch->qstats.backlog -= skb->len;
+		sch->qstats.backlog -= qdisc_tx_len(skb);
 		kfree_skb(skb);
 		return NET_XMIT_CN;
 	}
@@ -411,7 +411,7 @@ sfq_dequeue(struct Qdisc *sch)
 	skb = __skb_dequeue(&q->qs[a]);
 	sfq_dec(q, a);
 	sch->q.qlen--;
-	sch->qstats.backlog -= skb->len;
+	sch->qstats.backlog -= qdisc_tx_len(skb);
 
 	/* Is the slot empty? */
 	if (q->qs[a].qlen == 0) {
@@ -423,7 +423,7 @@ sfq_dequeue(struct Qdisc *sch)
 		}
 		q->next[q->tail] = a;
 		q->allot[a] += q->quantum;
-	} else if ((q->allot[a] -= skb->len) <= 0) {
+	} else if ((q->allot[a] -= qdisc_tx_len(skb)) <= 0) {
 		q->tail = a;
 		a = q->next[a];
 		q->allot[a] += q->quantum;
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 7d705b8..1e3d52e 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -123,7 +123,10 @@ static int tbf_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 	struct tbf_sched_data *q = qdisc_priv(sch);
 	int ret;
 
-	if (skb->len > q->max_size) {
+	/* qdisc_tx_len() before qdisc_enqueue() wrapper, might return different
+	 * length than after wrapper. Should recalculate tx_len here if q->qdisc
+	 * has size table? */
+	if (qdisc_tx_len(skb) > q->max_size) {
 		sch->qstats.drops++;
 #ifdef CONFIG_NET_CLS_ACT
 		if (sch->reshape_fail == NULL || sch->reshape_fail(skb, sch))
@@ -140,7 +143,7 @@ static int tbf_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 	}
 
 	sch->q.qlen++;
-	sch->bstats.bytes += skb->len;
+	sch->bstats.bytes += qdisc_tx_len(skb);
 	sch->bstats.packets++;
 	return 0;
 }
@@ -181,7 +184,7 @@ static struct sk_buff *tbf_dequeue(struct Qdisc* sch)
 		psched_time_t now;
 		long toks;
 		long ptoks = 0;
-		unsigned int len = skb->len;
+		unsigned int len = qdisc_tx_len(skb);
 
 		now = psched_get_time();
 		toks = psched_tdiff_bounded(now, q->t_c, q->buffer);
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index 8ac0598..2b25275 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -83,7 +83,7 @@ teql_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 
 	if (q->q.qlen < dev->tx_queue_len) {
 		__skb_queue_tail(&q->q, skb);
-		sch->bstats.bytes += skb->len;
+		sch->bstats.bytes += qdisc_tx_len(skb);
 		sch->bstats.packets++;
 		return 0;
 	}
@@ -270,7 +270,6 @@ static int teql_master_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct Qdisc *start, *q;
 	int busy;
 	int nores;
-	int len = skb->len;
 	int subq = skb_get_queue_mapping(skb);
 	struct sk_buff *skb_res = NULL;
 
@@ -305,7 +304,8 @@ restart:
 					master->slaves = NEXT_SLAVE(q);
 					netif_wake_queue(dev);
 					master->stats.tx_packets++;
-					master->stats.tx_bytes += len;
+					master->stats.tx_bytes +=
+						qdisc_tx_len(skb);
 					return 0;
 				}
 				netif_tx_unlock(slave);

