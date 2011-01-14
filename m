From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net_sched: accurate bytes/packets stats/rates
Date: Fri, 14 Jan 2011 17:16:48 +0100
Message-ID: <1295021808.3937.110.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	jamal <hadi@cyberus.ca>, Jarek Poplawski <jarkao2@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:61448 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757637Ab1ANQQx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 11:16:53 -0500
Received: by wyb28 with SMTP id 28so2978762wyb.19
        for <netdev@vger.kernel.org>; Fri, 14 Jan 2011 08:16:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 44b8288308ac9d (net_sched: pfifo_head_drop problem), we fixed
a problem with pfifo_head drops that incorrectly decreased
sch->bstats.bytes and sch->bstats.packets

Several qdiscs (CHOKe, SFQ, pfifo_head, ...) are able to drop a
previously enqueued packet, and bstats cannot be changed, so
bstats/rates are not accurate (over estimated)

This patch changes the qdisc_bstats updates to be done at dequeue() time
instead of enqueue() time. bstats counters no longer account for dropped
frames, and rates are more correct, since enqueue() bursts dont have
effect on dequeue() rate.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Patrick McHardy <kaber@trash.net>
CC: Stephen Hemminger <shemminger@vyatta.com>
CC: Jarek Poplawski <jarkao2@gmail.com>
CC: jamal <hadi@cyberus.ca>
---
 include/net/sch_generic.h |   14 ++++++++------
 net/sched/sch_cbq.c       |    3 +--
 net/sched/sch_drr.c       |    2 +-
 net/sched/sch_dsmark.c    |    2 +-
 net/sched/sch_fifo.c      |    2 +-
 net/sched/sch_generic.c   |    2 +-
 net/sched/sch_hfsc.c      |    2 +-
 net/sched/sch_htb.c       |   12 +++++-------
 net/sched/sch_multiq.c    |    2 +-
 net/sched/sch_netem.c     |    3 +--
 net/sched/sch_prio.c      |    2 +-
 net/sched/sch_red.c       |   11 ++++++-----
 net/sched/sch_sfq.c       |    5 ++---
 net/sched/sch_tbf.c       |    2 +-
 net/sched/sch_teql.c      |    3 ++-
 15 files changed, 33 insertions(+), 34 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index e9eee99..8fed414 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -445,7 +445,6 @@ static inline int __qdisc_enqueue_tail(struct sk_buff *skb, struct Qdisc *sch,
 {
 	__skb_queue_tail(list, skb);
 	sch->qstats.backlog += qdisc_pkt_len(skb);
-	qdisc_bstats_update(sch, skb);
 
 	return NET_XMIT_SUCCESS;
 }
@@ -456,25 +455,28 @@ static inline int qdisc_enqueue_tail(struct sk_buff *skb, struct Qdisc *sch)
 }
 
 static inline struct sk_buff *__qdisc_dequeue_head(struct Qdisc *sch,
-						   struct sk_buff_head *list)
+						   struct sk_buff_head *list,
+						   bool stats_update)
 {
 	struct sk_buff *skb = __skb_dequeue(list);
 
-	if (likely(skb != NULL))
+	if (likely(skb != NULL)) {
+		if (stats_update)
+			qdisc_bstats_update(sch, skb);
 		sch->qstats.backlog -= qdisc_pkt_len(skb);
-
+	}
 	return skb;
 }
 
 static inline struct sk_buff *qdisc_dequeue_head(struct Qdisc *sch)
 {
-	return __qdisc_dequeue_head(sch, &sch->q);
+	return __qdisc_dequeue_head(sch, &sch->q, true);
 }
 
 static inline unsigned int __qdisc_queue_drop_head(struct Qdisc *sch,
 					      struct sk_buff_head *list)
 {
-	struct sk_buff *skb = __qdisc_dequeue_head(sch, list);
+	struct sk_buff *skb = __qdisc_dequeue_head(sch, list, false);
 
 	if (likely(skb != NULL)) {
 		unsigned int len = qdisc_pkt_len(skb);
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index c80d1c2..5f63ec5 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -390,7 +390,6 @@ cbq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	ret = qdisc_enqueue(skb, cl->q);
 	if (ret == NET_XMIT_SUCCESS) {
 		sch->q.qlen++;
-		qdisc_bstats_update(sch, skb);
 		cbq_mark_toplevel(q, cl);
 		if (!cl->next_alive)
 			cbq_activate_class(cl);
@@ -649,7 +648,6 @@ static int cbq_reshape_fail(struct sk_buff *skb, struct Qdisc *child)
 		ret = qdisc_enqueue(skb, cl->q);
 		if (ret == NET_XMIT_SUCCESS) {
 			sch->q.qlen++;
-			qdisc_bstats_update(sch, skb);
 			if (!cl->next_alive)
 				cbq_activate_class(cl);
 			return 0;
@@ -971,6 +969,7 @@ cbq_dequeue(struct Qdisc *sch)
 
 		skb = cbq_dequeue_1(sch);
 		if (skb) {
+			qdisc_bstats_update(sch, skb);
 			sch->q.qlen--;
 			sch->flags &= ~TCQ_F_THROTTLED;
 			return skb;
diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
index de55e64..6b7fe4a 100644
--- a/net/sched/sch_drr.c
+++ b/net/sched/sch_drr.c
@@ -376,7 +376,6 @@ static int drr_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	}
 
 	bstats_update(&cl->bstats, skb);
-	qdisc_bstats_update(sch, skb);
 
 	sch->q.qlen++;
 	return err;
@@ -403,6 +402,7 @@ static struct sk_buff *drr_dequeue(struct Qdisc *sch)
 			skb = qdisc_dequeue_peeked(cl->qdisc);
 			if (cl->qdisc->q.qlen == 0)
 				list_del(&cl->alist);
+			qdisc_bstats_update(sch, skb);
 			sch->q.qlen--;
 			return skb;
 		}
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 60f4bdd..0f7bf3f 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -260,7 +260,6 @@ static int dsmark_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		return err;
 	}
 
-	qdisc_bstats_update(sch, skb);
 	sch->q.qlen++;
 
 	return NET_XMIT_SUCCESS;
@@ -283,6 +282,7 @@ static struct sk_buff *dsmark_dequeue(struct Qdisc *sch)
 	if (skb == NULL)
 		return NULL;
 
+	qdisc_bstats_update(sch, skb);
 	sch->q.qlen--;
 
 	index = skb->tc_index & (p->indices - 1);
diff --git a/net/sched/sch_fifo.c b/net/sched/sch_fifo.c
index aa4d633..f2557e0 100644
--- a/net/sched/sch_fifo.c
+++ b/net/sched/sch_fifo.c
@@ -53,7 +53,7 @@ static int pfifo_tail_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 		return qdisc_enqueue_tail(skb, sch);
 
 	/* queue full, remove one skb to fulfill the limit */
-	skb_head = qdisc_dequeue_head(sch);
+	skb_head = __qdisc_dequeue_head(sch, &sch->q, false);
 	sch->qstats.drops++;
 	kfree_skb(skb_head);
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 34dc598..eeb6343 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -467,7 +467,7 @@ static struct sk_buff *pfifo_fast_dequeue(struct Qdisc* qdisc)
 
 	if (likely(band >= 0)) {
 		struct sk_buff_head *list = band2list(priv, band);
-		struct sk_buff *skb = __qdisc_dequeue_head(qdisc, list);
+		struct sk_buff *skb = __qdisc_dequeue_head(qdisc, list, true);
 
 		qdisc->q.qlen--;
 		if (skb_queue_empty(list))
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 2e45791..14a799d 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1600,7 +1600,6 @@ hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		set_active(cl, qdisc_pkt_len(skb));
 
 	bstats_update(&cl->bstats, skb);
-	qdisc_bstats_update(sch, skb);
 	sch->q.qlen++;
 
 	return NET_XMIT_SUCCESS;
@@ -1666,6 +1665,7 @@ hfsc_dequeue(struct Qdisc *sch)
 	}
 
 	sch->flags &= ~TCQ_F_THROTTLED;
+	qdisc_bstats_update(sch, skb);
 	sch->q.qlen--;
 
 	return skb;
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 984c1b0..fc12fe6 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -574,7 +574,6 @@ static int htb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	}
 
 	sch->q.qlen++;
-	qdisc_bstats_update(sch, skb);
 	return NET_XMIT_SUCCESS;
 }
 
@@ -842,7 +841,7 @@ next:
 
 static struct sk_buff *htb_dequeue(struct Qdisc *sch)
 {
-	struct sk_buff *skb = NULL;
+	struct sk_buff *skb;
 	struct htb_sched *q = qdisc_priv(sch);
 	int level;
 	psched_time_t next_event;
@@ -851,6 +850,8 @@ static struct sk_buff *htb_dequeue(struct Qdisc *sch)
 	/* try to dequeue direct packets as high prio (!) to minimize cpu work */
 	skb = __skb_dequeue(&q->direct_queue);
 	if (skb != NULL) {
+ok:
+		qdisc_bstats_update(sch, skb);
 		sch->flags &= ~TCQ_F_THROTTLED;
 		sch->q.qlen--;
 		return skb;
@@ -884,11 +885,8 @@ static struct sk_buff *htb_dequeue(struct Qdisc *sch)
 			int prio = ffz(m);
 			m |= 1 << prio;
 			skb = htb_dequeue_tree(q, prio, level);
-			if (likely(skb != NULL)) {
-				sch->q.qlen--;
-				sch->flags &= ~TCQ_F_THROTTLED;
-				goto fin;
-			}
+			if (likely(skb != NULL))
+				goto ok;
 		}
 	}
 	sch->qstats.overlimits++;
diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
index 21f13da..436a2e7 100644
--- a/net/sched/sch_multiq.c
+++ b/net/sched/sch_multiq.c
@@ -83,7 +83,6 @@ multiq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 	ret = qdisc_enqueue(skb, qdisc);
 	if (ret == NET_XMIT_SUCCESS) {
-		qdisc_bstats_update(sch, skb);
 		sch->q.qlen++;
 		return NET_XMIT_SUCCESS;
 	}
@@ -112,6 +111,7 @@ static struct sk_buff *multiq_dequeue(struct Qdisc *sch)
 			qdisc = q->queues[q->curband];
 			skb = qdisc->dequeue(qdisc);
 			if (skb) {
+				qdisc_bstats_update(sch, skb);
 				sch->q.qlen--;
 				return skb;
 			}
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 1c4bce8..6a3006b 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -240,7 +240,6 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 	if (likely(ret == NET_XMIT_SUCCESS)) {
 		sch->q.qlen++;
-		qdisc_bstats_update(sch, skb);
 	} else if (net_xmit_drop_count(ret)) {
 		sch->qstats.drops++;
 	}
@@ -289,6 +288,7 @@ static struct sk_buff *netem_dequeue(struct Qdisc *sch)
 				skb->tstamp.tv64 = 0;
 #endif
 			pr_debug("netem_dequeue: return skb=%p\n", skb);
+			qdisc_bstats_update(sch, skb);
 			sch->q.qlen--;
 			return skb;
 		}
@@ -476,7 +476,6 @@ static int tfifo_enqueue(struct sk_buff *nskb, struct Qdisc *sch)
 		__skb_queue_after(list, skb, nskb);
 
 		sch->qstats.backlog += qdisc_pkt_len(nskb);
-		qdisc_bstats_update(sch, nskb);
 
 		return NET_XMIT_SUCCESS;
 	}
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 966158d..fbd710d 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -84,7 +84,6 @@ prio_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 	ret = qdisc_enqueue(skb, qdisc);
 	if (ret == NET_XMIT_SUCCESS) {
-		qdisc_bstats_update(sch, skb);
 		sch->q.qlen++;
 		return NET_XMIT_SUCCESS;
 	}
@@ -116,6 +115,7 @@ static struct sk_buff *prio_dequeue(struct Qdisc* sch)
 		struct Qdisc *qdisc = q->queues[prio];
 		struct sk_buff *skb = qdisc->dequeue(qdisc);
 		if (skb) {
+			qdisc_bstats_update(sch, skb);
 			sch->q.qlen--;
 			return skb;
 		}
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index a6009c5..9f98dbd 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -94,7 +94,6 @@ static int red_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 
 	ret = qdisc_enqueue(skb, child);
 	if (likely(ret == NET_XMIT_SUCCESS)) {
-		qdisc_bstats_update(sch, skb);
 		sch->q.qlen++;
 	} else if (net_xmit_drop_count(ret)) {
 		q->stats.pdrop++;
@@ -114,11 +113,13 @@ static struct sk_buff * red_dequeue(struct Qdisc* sch)
 	struct Qdisc *child = q->qdisc;
 
 	skb = child->dequeue(child);
-	if (skb)
+	if (skb) {
+		qdisc_bstats_update(sch, skb);
 		sch->q.qlen--;
-	else if (!red_is_idling(&q->parms))
-		red_start_of_idle_period(&q->parms);
-
+	} else {
+		if (!red_is_idling(&q->parms))
+			red_start_of_idle_period(&q->parms);
+	}
 	return skb;
 }
 
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 239ec53..edea8ce 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -402,10 +402,8 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		q->tail = slot;
 		slot->allot = q->scaled_quantum;
 	}
-	if (++sch->q.qlen <= q->limit) {
-		qdisc_bstats_update(sch, skb);
+	if (++sch->q.qlen <= q->limit)
 		return NET_XMIT_SUCCESS;
-	}
 
 	sfq_drop(sch);
 	return NET_XMIT_CN;
@@ -445,6 +443,7 @@ next_slot:
 	}
 	skb = slot_dequeue_head(slot);
 	sfq_dec(q, a);
+	qdisc_bstats_update(sch, skb);
 	sch->q.qlen--;
 	sch->qstats.backlog -= qdisc_pkt_len(skb);
 
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 77565e7..e931658 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -134,7 +134,6 @@ static int tbf_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 	}
 
 	sch->q.qlen++;
-	qdisc_bstats_update(sch, skb);
 	return NET_XMIT_SUCCESS;
 }
 
@@ -187,6 +186,7 @@ static struct sk_buff *tbf_dequeue(struct Qdisc* sch)
 			q->ptokens = ptoks;
 			sch->q.qlen--;
 			sch->flags &= ~TCQ_F_THROTTLED;
+			qdisc_bstats_update(sch, skb);
 			return skb;
 		}
 
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index af9360d..2ecd9af 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -83,7 +83,6 @@ teql_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 
 	if (q->q.qlen < dev->tx_queue_len) {
 		__skb_queue_tail(&q->q, skb);
-		qdisc_bstats_update(sch, skb);
 		return NET_XMIT_SUCCESS;
 	}
 
@@ -107,6 +106,8 @@ teql_dequeue(struct Qdisc* sch)
 			dat->m->slaves = sch;
 			netif_wake_queue(m);
 		}
+	} else {
+		qdisc_bstats_update(sch, skb);
 	}
 	sch->q.qlen = dat->q.qlen + dat_queue->qdisc->q.qlen;
 	return skb;


