From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: [PATCH 1/8] Preparatory refactoring part 1.
Date: Mon, 29 Oct 2007 00:23:00 -0700
Message-ID: <1193642587-32657-2-git-send-email-bugfood-ml@fatooh.org>
References: <1193642587-32657-1-git-send-email-bugfood-ml@fatooh.org>
Cc: Corey Hickey <bugfood-ml@fatooh.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:50317 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752035AbXJ2HXL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 03:23:11 -0400
In-Reply-To: <1193642587-32657-1-git-send-email-bugfood-ml@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make a new function sfq_q_enqueue() that operates directly on the
queue data. This will be useful for implementing sfq_change() in
a later patch. A pleasant side-effect is reducing most of the
duplicate code in sfq_enqueue() and sfq_requeue().

Similarly, make a new function sfq_q_dequeue().

Signed-off-by: Corey Hickey <bugfood-ml@fatooh.org>
---
 net/sched/sch_sfq.c |  119 ++++++++++++++++++++++++++++++---------------------
 1 files changed, 70 insertions(+), 49 deletions(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index b542c87..10e2f3d 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -78,6 +78,9 @@
 #define SFQ_DEPTH		128
 #define SFQ_HASH_DIVISOR	1024
 
+#define SFQ_HEAD 0
+#define SFQ_TAIL 1
+
 /* This type should contain at least SFQ_DEPTH*2 values */
 typedef unsigned char sfq_index;
 
@@ -241,9 +244,8 @@ static unsigned int sfq_drop(struct Qdisc *sch)
 }
 
 static int
-sfq_enqueue(struct sk_buff *skb, struct Qdisc* sch)
+sfq_q_enqueue(struct sk_buff *skb, struct sfq_sched_data *q, int end)
 {
-	struct sfq_sched_data *q = qdisc_priv(sch);
 	unsigned hash = sfq_hash(q, skb);
 	sfq_index x;
 
@@ -252,15 +254,37 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 		q->ht[hash] = x = q->dep[SFQ_DEPTH].next;
 		q->hash[x] = hash;
 	}
-	/* If selected queue has length q->limit, this means that
-	 * all another queues are empty and that we do simple tail drop,
-	 * i.e. drop _this_ packet.
-	 */
-	if (q->qs[x].qlen >= q->limit)
-		return qdisc_drop(skb, sch);
 
-	sch->qstats.backlog += skb->len;
-	__skb_queue_tail(&q->qs[x], skb);
+	if (end == SFQ_TAIL) {
+		/* If selected queue has length q->limit, this means that
+		 * all other queues are empty and that we do simple tail drop,
+		 * i.e. drop _this_ packet.
+		 */
+		if (q->qs[x].qlen >= q->limit) {
+			unsigned int drop_len = skb->len;
+
+			kfree_skb(skb);
+			return drop_len;
+		}
+		__skb_queue_tail(&q->qs[x], skb);
+	} else { /* end == SFQ_HEAD */
+		__skb_queue_head(&q->qs[x], skb);
+		/* If selected queue has length q->limit+1, this means that
+		 * all other queues are empty and we do simple tail drop.
+		 * This packet is still requeued at head of queue, tail packet
+		 * is dropped.
+		 */
+		if (q->qs[x].qlen > q->limit) {
+			unsigned int drop_len;
+
+			skb = q->qs[x].prev;
+			drop_len = skb->len;
+			__skb_unlink(skb, &q->qs[x]);
+			kfree_skb(skb);
+			return drop_len;
+		}
+	}
+
 	sfq_inc(q, x);
 	if (q->qs[x].qlen == 1) {		/* The flow is new */
 		if (q->tail == SFQ_DEPTH) {	/* It is the first flow */
@@ -273,6 +297,21 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 			q->tail = x;
 		}
 	}
+
+	return 0;
+}
+
+static int
+sfq_enqueue(struct sk_buff *skb, struct Qdisc* sch)
+{
+	struct sfq_sched_data *q = qdisc_priv(sch);
+
+	if (sfq_q_enqueue(skb, q, SFQ_TAIL)) {
+		sch->qstats.drops++;
+		return NET_XMIT_DROP;
+	}
+
+	sch->qstats.backlog += skb->len;
 	if (++sch->q.qlen <= q->limit) {
 		sch->bstats.bytes += skb->len;
 		sch->bstats.packets++;
@@ -287,58 +326,27 @@ static int
 sfq_requeue(struct sk_buff *skb, struct Qdisc* sch)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
-	unsigned hash = sfq_hash(q, skb);
-	sfq_index x;
+	unsigned int drop_len;
 
-	x = q->ht[hash];
-	if (x == SFQ_DEPTH) {
-		q->ht[hash] = x = q->dep[SFQ_DEPTH].next;
-		q->hash[x] = hash;
-	}
 	sch->qstats.backlog += skb->len;
-	__skb_queue_head(&q->qs[x], skb);
-	/* If selected queue has length q->limit+1, this means that
-	 * all another queues are empty and we do simple tail drop.
-	 * This packet is still requeued at head of queue, tail packet
-	 * is dropped.
-	 */
-	if (q->qs[x].qlen > q->limit) {
-		skb = q->qs[x].prev;
-		__skb_unlink(skb, &q->qs[x]);
+	if ((drop_len = sfq_q_enqueue(skb, q, SFQ_HEAD))) {
+		sch->qstats.backlog -= drop_len;
 		sch->qstats.drops++;
-		sch->qstats.backlog -= skb->len;
-		kfree_skb(skb);
 		return NET_XMIT_CN;
 	}
-	sfq_inc(q, x);
-	if (q->qs[x].qlen == 1) {		/* The flow is new */
-		if (q->tail == SFQ_DEPTH) {	/* It is the first flow */
-			q->tail = x;
-			q->next[x] = x;
-			q->allot[x] = q->quantum;
-		} else {
-			q->next[x] = q->next[q->tail];
-			q->next[q->tail] = x;
-			q->tail = x;
-		}
-	}
+
 	if (++sch->q.qlen <= q->limit) {
 		sch->qstats.requeues++;
 		return 0;
 	}
 
-	sch->qstats.drops++;
 	sfq_drop(sch);
 	return NET_XMIT_CN;
 }
 
-
-
-
-static struct sk_buff *
-sfq_dequeue(struct Qdisc* sch)
+static struct
+sk_buff *sfq_q_dequeue(struct sfq_sched_data *q)
 {
-	struct sfq_sched_data *q = qdisc_priv(sch);
 	struct sk_buff *skb;
 	sfq_index a, old_a;
 
@@ -351,8 +359,6 @@ sfq_dequeue(struct Qdisc* sch)
 	/* Grab packet */
 	skb = __skb_dequeue(&q->qs[a]);
 	sfq_dec(q, a);
-	sch->q.qlen--;
-	sch->qstats.backlog -= skb->len;
 
 	/* Is the slot empty? */
 	if (q->qs[a].qlen == 0) {
@@ -369,6 +375,21 @@ sfq_dequeue(struct Qdisc* sch)
 		a = q->next[a];
 		q->allot[a] += q->quantum;
 	}
+
+	return skb;
+}
+
+static struct sk_buff
+*sfq_dequeue(struct Qdisc* sch)
+{
+	struct sfq_sched_data *q = qdisc_priv(sch);
+	struct sk_buff *skb;
+
+	skb = sfq_q_dequeue(q);
+	if (skb == NULL)
+		return NULL;
+	sch->q.qlen--;
+	sch->qstats.backlog -= skb->len;
 	return skb;
 }
 
-- 
1.5.3.4

