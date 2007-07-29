From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: [PATCH 1/7] Preparatory refactoring part 1.
Date: Sun, 29 Jul 2007 00:08:48 -0700
Message-ID: <11856929353322-git-send-email-bugfood-ml@fatooh.org>
References: <11856929352537-git-send-email-bugfood-ml@fatooh.org>
Cc: Corey Hickey <bugfood-ml@fatooh.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:60036 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757598AbXG2HIw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Jul 2007 03:08:52 -0400
In-Reply-To: <11856929352537-git-send-email-bugfood-ml@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make a new function sfq_q_enqueue() that operates directly on the
queue data. This will be useful for implementing sfq_change() in
a later patch. A pleasant side-effect is reducing most of the
duplicate code in sfq_enqueue() and sfq_requeue().

Similarly, make a new function sfq_q_dequeue().

Signed-off-by: Corey Hickey <bugfood-ml@fatooh.org>
---
 net/sched/sch_sfq.c |   70 ++++++++++++++++++++++++++------------------------
 1 files changed, 36 insertions(+), 34 deletions(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 9579573..8ae077f 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -77,6 +77,9 @@
 #define SFQ_DEPTH		128
 #define SFQ_HASH_DIVISOR	1024
 
+#define SFQ_HEAD 0
+#define SFQ_TAIL 1
+
 /* This type should contain at least SFQ_DEPTH*2 values */
 typedef unsigned char sfq_index;
 
@@ -244,10 +247,8 @@ static unsigned int sfq_drop(struct Qdisc *sch)
 	return 0;
 }
 
-static int
-sfq_enqueue(struct sk_buff *skb, struct Qdisc* sch)
+static void sfq_q_enqueue(struct sk_buff *skb, struct sfq_sched_data *q, unsigned int end)
 {
-	struct sfq_sched_data *q = qdisc_priv(sch);
 	unsigned hash = sfq_hash(q, skb);
 	sfq_index x;
 
@@ -256,8 +257,12 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 		q->ht[hash] = x = q->dep[SFQ_DEPTH].next;
 		q->hash[x] = hash;
 	}
-	sch->qstats.backlog += skb->len;
-	__skb_queue_tail(&q->qs[x], skb);
+
+	if (end == SFQ_TAIL)
+		__skb_queue_tail(&q->qs[x], skb);
+	else
+		__skb_queue_head(&q->qs[x], skb);
+
 	sfq_inc(q, x);
 	if (q->qs[x].qlen == 1) {		/* The flow is new */
 		if (q->tail == SFQ_DEPTH) {	/* It is the first flow */
@@ -270,12 +275,21 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 			q->tail = x;
 		}
 	}
+}
+
+static int
+sfq_enqueue(struct sk_buff *skb, struct Qdisc* sch)
+{
+	struct sfq_sched_data *q = qdisc_priv(sch);
+	sfq_q_enqueue(skb, q, SFQ_TAIL);
+	sch->qstats.backlog += skb->len;
 	if (++sch->q.qlen < q->limit-1) {
 		sch->bstats.bytes += skb->len;
 		sch->bstats.packets++;
 		return 0;
 	}
 
+	sch->qstats.drops++;
 	sfq_drop(sch);
 	return NET_XMIT_CN;
 }
@@ -284,28 +298,8 @@ static int
 sfq_requeue(struct sk_buff *skb, struct Qdisc* sch)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
-	unsigned hash = sfq_hash(q, skb);
-	sfq_index x;
-
-	x = q->ht[hash];
-	if (x == SFQ_DEPTH) {
-		q->ht[hash] = x = q->dep[SFQ_DEPTH].next;
-		q->hash[x] = hash;
-	}
+	sfq_q_enqueue(skb, q, SFQ_HEAD);
 	sch->qstats.backlog += skb->len;
-	__skb_queue_head(&q->qs[x], skb);
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
 	if (++sch->q.qlen < q->limit - 1) {
 		sch->qstats.requeues++;
 		return 0;
@@ -316,13 +310,8 @@ sfq_requeue(struct sk_buff *skb, struct Qdisc* sch)
 	return NET_XMIT_CN;
 }
 
-
-
-
-static struct sk_buff *
-sfq_dequeue(struct Qdisc* sch)
+static struct sk_buff *sfq_q_dequeue(struct sfq_sched_data *q)
 {
-	struct sfq_sched_data *q = qdisc_priv(sch);
 	struct sk_buff *skb;
 	sfq_index a, old_a;
 
@@ -335,8 +324,6 @@ sfq_dequeue(struct Qdisc* sch)
 	/* Grab packet */
 	skb = __skb_dequeue(&q->qs[a]);
 	sfq_dec(q, a);
-	sch->q.qlen--;
-	sch->qstats.backlog -= skb->len;
 
 	/* Is the slot empty? */
 	if (q->qs[a].qlen == 0) {
@@ -353,6 +340,21 @@ sfq_dequeue(struct Qdisc* sch)
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
1.5.2.4

