From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net_sched: accurate bytes/packets stats/rates
Date: Fri, 14 Jan 2011 09:52:01 -0800
Message-ID: <20110114095201.4fc58a45@nehalam>
References: <1295021808.3937.110.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>,
	Jarek Poplawski <jarkao2@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52684 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757762Ab1ANRwF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 12:52:05 -0500
In-Reply-To: <1295021808.3937.110.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By using __qdisc_queue_drop_head in sch_fifo.c the stats_update parameter won't be
needed.

>From Eric Dumazet <eric.dumazet@gmail.com>

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
Acked-by: Stephen Hemminger <shemminger@vyatta.com>
CC: Patrick McHardy <kaber@trash.net>
CC: Jarek Poplawski <jarkao2@gmail.com>
CC: jamal <hadi@cyberus.ca>
---
 include/net/sch_generic.h |    8 +++++---
 net/sched/sch_cbq.c       |    3 +--
 net/sched/sch_drr.c       |    2 +-
 net/sched/sch_dsmark.c    |    2 +-
 net/sched/sch_fifo.c      |    6 +-----
 net/sched/sch_hfsc.c      |    2 +-
 net/sched/sch_htb.c       |   12 +++++-------
 net/sched/sch_multiq.c    |    2 +-
 net/sched/sch_netem.c     |    3 +--
 net/sched/sch_prio.c      |    2 +-
 net/sched/sch_red.c       |   11 ++++++-----
 net/sched/sch_sfq.c       |    5 ++---
 net/sched/sch_tbf.c       |    2 +-
 net/sched/sch_teql.c      |    3 ++-
 14 files changed, 29 insertions(+), 34 deletions(-)

--- a/include/net/sch_generic.h	2011-01-14 09:19:00.730849868 -0800
+++ b/include/net/sch_generic.h	2011-01-14 09:47:59.058551676 -0800
@@ -445,7 +445,6 @@ static inline int __qdisc_enqueue_tail(s
 {
 	__skb_queue_tail(list, skb);
 	sch->qstats.backlog += qdisc_pkt_len(skb);
-	qdisc_bstats_update(sch, skb);
 
 	return NET_XMIT_SUCCESS;
 }
@@ -460,8 +459,10 @@ static inline struct sk_buff *__qdisc_de
 {
 	struct sk_buff *skb = __skb_dequeue(list);
 
-	if (likely(skb != NULL))
+	if (likely(skb != NULL)) {
 		sch->qstats.backlog -= qdisc_pkt_len(skb);
+		qdisc_bstats_update(sch, skb);
+	}
 
 	return skb;
 }
@@ -474,10 +475,11 @@ static inline struct sk_buff *qdisc_dequ
 static inline unsigned int __qdisc_queue_drop_head(struct Qdisc *sch,
 					      struct sk_buff_head *list)
 {
-	struct sk_buff *skb = __qdisc_dequeue_head(sch, list);
+	struct sk_buff *skb = __skb_dequeue(list);
 
 	if (likely(skb != NULL)) {
 		unsigned int len = qdisc_pkt_len(skb);
+		sch->qstats.backlog -= len;
 		kfree_skb(skb);
 		return len;
 	}
--- a/net/sched/sch_cbq.c	2011-01-14 09:19:00.830857886 -0800
+++ b/net/sched/sch_cbq.c	2011-01-14 09:28:20.398631228 -0800
@@ -390,7 +390,6 @@ cbq_enqueue(struct sk_buff *skb, struct
 	ret = qdisc_enqueue(skb, cl->q);
 	if (ret == NET_XMIT_SUCCESS) {
 		sch->q.qlen++;
-		qdisc_bstats_update(sch, skb);
 		cbq_mark_toplevel(q, cl);
 		if (!cl->next_alive)
 			cbq_activate_class(cl);
@@ -649,7 +648,6 @@ static int cbq_reshape_fail(struct sk_bu
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
--- a/net/sched/sch_drr.c	2011-01-14 09:19:00.830857886 -0800
+++ b/net/sched/sch_drr.c	2011-01-14 09:28:20.398631228 -0800
@@ -376,7 +376,6 @@ static int drr_enqueue(struct sk_buff *s
 	}
 
 	bstats_update(&cl->bstats, skb);
-	qdisc_bstats_update(sch, skb);
 
 	sch->q.qlen++;
 	return err;
@@ -403,6 +402,7 @@ static struct sk_buff *drr_dequeue(struc
 			skb = qdisc_dequeue_peeked(cl->qdisc);
 			if (cl->qdisc->q.qlen == 0)
 				list_del(&cl->alist);
+			qdisc_bstats_update(sch, skb);
 			sch->q.qlen--;
 			return skb;
 		}
--- a/net/sched/sch_dsmark.c	2011-01-14 09:19:00.830857886 -0800
+++ b/net/sched/sch_dsmark.c	2011-01-14 09:28:20.398631228 -0800
@@ -260,7 +260,6 @@ static int dsmark_enqueue(struct sk_buff
 		return err;
 	}
 
-	qdisc_bstats_update(sch, skb);
 	sch->q.qlen++;
 
 	return NET_XMIT_SUCCESS;
@@ -283,6 +282,7 @@ static struct sk_buff *dsmark_dequeue(st
 	if (skb == NULL)
 		return NULL;
 
+	qdisc_bstats_update(sch, skb);
 	sch->q.qlen--;
 
 	index = skb->tc_index & (p->indices - 1);
--- a/net/sched/sch_fifo.c	2011-01-09 09:34:32.690685246 -0800
+++ b/net/sched/sch_fifo.c	2011-01-14 09:50:37.082839684 -0800
@@ -46,17 +46,13 @@ static int pfifo_enqueue(struct sk_buff
 
 static int pfifo_tail_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 {
-	struct sk_buff *skb_head;
 	struct fifo_sched_data *q = qdisc_priv(sch);
 
 	if (likely(skb_queue_len(&sch->q) < q->limit))
 		return qdisc_enqueue_tail(skb, sch);
 
 	/* queue full, remove one skb to fulfill the limit */
-	skb_head = qdisc_dequeue_head(sch);
-	sch->qstats.drops++;
-	kfree_skb(skb_head);
-
+	__qdisc_queue_drop_head(sch, &sch->q);
 	qdisc_enqueue_tail(skb, sch);
 
 	return NET_XMIT_CN;
--- a/net/sched/sch_hfsc.c	2011-01-14 09:19:00.830857886 -0800
+++ b/net/sched/sch_hfsc.c	2011-01-14 09:28:20.428633918 -0800
@@ -1600,7 +1600,6 @@ hfsc_enqueue(struct sk_buff *skb, struct
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
--- a/net/sched/sch_htb.c	2011-01-14 09:19:00.830857886 -0800
+++ b/net/sched/sch_htb.c	2011-01-14 09:28:20.438634799 -0800
@@ -574,7 +574,6 @@ static int htb_enqueue(struct sk_buff *s
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
@@ -851,6 +850,8 @@ static struct sk_buff *htb_dequeue(struc
 	/* try to dequeue direct packets as high prio (!) to minimize cpu work */
 	skb = __skb_dequeue(&q->direct_queue);
 	if (skb != NULL) {
+ok:
+		qdisc_bstats_update(sch, skb);
 		sch->flags &= ~TCQ_F_THROTTLED;
 		sch->q.qlen--;
 		return skb;
@@ -884,11 +885,8 @@ static struct sk_buff *htb_dequeue(struc
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
--- a/net/sched/sch_multiq.c	2011-01-14 09:19:00.830857886 -0800
+++ b/net/sched/sch_multiq.c	2011-01-14 09:28:20.438634799 -0800
@@ -83,7 +83,6 @@ multiq_enqueue(struct sk_buff *skb, stru
 
 	ret = qdisc_enqueue(skb, qdisc);
 	if (ret == NET_XMIT_SUCCESS) {
-		qdisc_bstats_update(sch, skb);
 		sch->q.qlen++;
 		return NET_XMIT_SUCCESS;
 	}
@@ -112,6 +111,7 @@ static struct sk_buff *multiq_dequeue(st
 			qdisc = q->queues[q->curband];
 			skb = qdisc->dequeue(qdisc);
 			if (skb) {
+				qdisc_bstats_update(sch, skb);
 				sch->q.qlen--;
 				return skb;
 			}
--- a/net/sched/sch_netem.c	2011-01-14 09:19:00.830857886 -0800
+++ b/net/sched/sch_netem.c	2011-01-14 09:28:20.438634799 -0800
@@ -240,7 +240,6 @@ static int netem_enqueue(struct sk_buff
 
 	if (likely(ret == NET_XMIT_SUCCESS)) {
 		sch->q.qlen++;
-		qdisc_bstats_update(sch, skb);
 	} else if (net_xmit_drop_count(ret)) {
 		sch->qstats.drops++;
 	}
@@ -289,6 +288,7 @@ static struct sk_buff *netem_dequeue(str
 				skb->tstamp.tv64 = 0;
 #endif
 			pr_debug("netem_dequeue: return skb=%p\n", skb);
+			qdisc_bstats_update(sch, skb);
 			sch->q.qlen--;
 			return skb;
 		}
@@ -476,7 +476,6 @@ static int tfifo_enqueue(struct sk_buff
 		__skb_queue_after(list, skb, nskb);
 
 		sch->qstats.backlog += qdisc_pkt_len(nskb);
-		qdisc_bstats_update(sch, nskb);
 
 		return NET_XMIT_SUCCESS;
 	}
--- a/net/sched/sch_prio.c	2011-01-14 09:19:00.830857886 -0800
+++ b/net/sched/sch_prio.c	2011-01-14 09:28:20.438634799 -0800
@@ -84,7 +84,6 @@ prio_enqueue(struct sk_buff *skb, struct
 
 	ret = qdisc_enqueue(skb, qdisc);
 	if (ret == NET_XMIT_SUCCESS) {
-		qdisc_bstats_update(sch, skb);
 		sch->q.qlen++;
 		return NET_XMIT_SUCCESS;
 	}
@@ -116,6 +115,7 @@ static struct sk_buff *prio_dequeue(stru
 		struct Qdisc *qdisc = q->queues[prio];
 		struct sk_buff *skb = qdisc->dequeue(qdisc);
 		if (skb) {
+			qdisc_bstats_update(sch, skb);
 			sch->q.qlen--;
 			return skb;
 		}
--- a/net/sched/sch_red.c	2011-01-14 09:19:00.830857886 -0800
+++ b/net/sched/sch_red.c	2011-01-14 09:28:20.438634799 -0800
@@ -94,7 +94,6 @@ static int red_enqueue(struct sk_buff *s
 
 	ret = qdisc_enqueue(skb, child);
 	if (likely(ret == NET_XMIT_SUCCESS)) {
-		qdisc_bstats_update(sch, skb);
 		sch->q.qlen++;
 	} else if (net_xmit_drop_count(ret)) {
 		q->stats.pdrop++;
@@ -114,11 +113,13 @@ static struct sk_buff * red_dequeue(stru
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
 
--- a/net/sched/sch_sfq.c	2011-01-14 09:19:00.830857886 -0800
+++ b/net/sched/sch_sfq.c	2011-01-14 09:28:20.438634799 -0800
@@ -402,10 +402,8 @@ sfq_enqueue(struct sk_buff *skb, struct
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
 
--- a/net/sched/sch_tbf.c	2011-01-14 09:19:00.830857886 -0800
+++ b/net/sched/sch_tbf.c	2011-01-14 09:28:20.438634799 -0800
@@ -134,7 +134,6 @@ static int tbf_enqueue(struct sk_buff *s
 	}
 
 	sch->q.qlen++;
-	qdisc_bstats_update(sch, skb);
 	return NET_XMIT_SUCCESS;
 }
 
@@ -187,6 +186,7 @@ static struct sk_buff *tbf_dequeue(struc
 			q->ptokens = ptoks;
 			sch->q.qlen--;
 			sch->flags &= ~TCQ_F_THROTTLED;
+			qdisc_bstats_update(sch, skb);
 			return skb;
 		}
 
--- a/net/sched/sch_teql.c	2011-01-14 09:19:00.830857886 -0800
+++ b/net/sched/sch_teql.c	2011-01-14 09:28:20.438634799 -0800
@@ -83,7 +83,6 @@ teql_enqueue(struct sk_buff *skb, struct
 
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
