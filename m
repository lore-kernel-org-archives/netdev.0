From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: [PATCH 4/7] Add "depth".
Date: Sun, 29 Jul 2007 17:21:13 -0700
Message-ID: <11857548783759-git-send-email-bugfood-ml@fatooh.org>
References: <11857548771998-git-send-email-bugfood-ml@fatooh.org>
Cc: Corey Hickey <bugfood-ml@fatooh.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:37095 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764939AbXG3AVX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Jul 2007 20:21:23 -0400
In-Reply-To: <11857548771998-git-send-email-bugfood-ml@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make "depth" (number of queues) user-configurable:

* replace #define with a parameter
* use old hardcoded value as a default
* kcalloc() arrays in sfq_q_init()
* free() arrays in sfq_q_destroy()

Signed-off-by: Corey Hickey <bugfood-ml@fatooh.org>
---
 net/sched/sch_sfq.c |   81 +++++++++++++++++++++++++++++++++++----------------
 1 files changed, 56 insertions(+), 25 deletions(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 583f925..70124ac 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -74,14 +74,16 @@
 
 	It is easy to increase these values, but not in flight.  */
 
-#define SFQ_DEPTH		128
+#define SFQ_DEPTH_DEFAULT	128
 #define SFQ_HASH_DIVISOR	1024
 
 #define SFQ_HEAD 0
 #define SFQ_TAIL 1
 
-/* This type should contain at least SFQ_DEPTH*2 values */
-typedef unsigned char sfq_index;
+/* This type must contain greater than depth*2 values, so depth is constrained 
+ * accordingly. */
+typedef unsigned int sfq_index;
+#define SFQ_MAX_DEPTH (UINT_MAX / 2 - 1)
 
 struct sfq_head
 {
@@ -95,6 +97,7 @@ struct sfq_sched_data
 	int		perturb_period;
 	unsigned	quantum;	/* Allotment per round: MUST BE >= MTU */
 	int		limit;
+	unsigned	depth;
 
 /* Variables */
 	struct timer_list perturb_timer;
@@ -103,11 +106,11 @@ struct sfq_sched_data
 	sfq_index	max_depth;	/* Maximal depth */
 
 	sfq_index	ht[SFQ_HASH_DIVISOR];	/* Hash table */
-	sfq_index	next[SFQ_DEPTH];	/* Active slots link */
-	short		allot[SFQ_DEPTH];	/* Current allotment per slot */
-	unsigned short	hash[SFQ_DEPTH];	/* Hash value indexed by slots */
-	struct sk_buff_head	qs[SFQ_DEPTH];		/* Slot queue */
-	struct sfq_head	dep[SFQ_DEPTH*2];	/* Linked list of slots, indexed by depth */
+	sfq_index	*next;			/* Active slots link */
+	short		*allot;			/* Current allotment per slot */
+	unsigned short	*hash;			/* Hash value indexed by slots */
+	struct sk_buff_head	*qs;		/* Slot queue */
+	struct sfq_head	*dep;			/* Linked list of slots, indexed by depth */
 };
 
 static __inline__ unsigned sfq_fold_hash(struct sfq_sched_data *q, u32 h, u32 h1)
@@ -164,7 +167,7 @@ static unsigned sfq_hash(struct sfq_sched_data *q, struct sk_buff *skb)
 static inline void sfq_link(struct sfq_sched_data *q, sfq_index x)
 {
 	sfq_index p, n;
-	int d = q->qs[x].qlen + SFQ_DEPTH;
+	int d = q->qs[x].qlen + q->depth;
 
 	p = d;
 	n = q->dep[d].next;
@@ -215,7 +218,7 @@ static unsigned int sfq_drop(struct Qdisc *sch)
 	   drop a packet from it */
 
 	if (d > 1) {
-		sfq_index x = q->dep[d+SFQ_DEPTH].next;
+		sfq_index x = q->dep[d + q->depth].next;
 		skb = q->qs[x].prev;
 		len = skb->len;
 		__skb_unlink(skb, &q->qs[x]);
@@ -238,7 +241,7 @@ static unsigned int sfq_drop(struct Qdisc *sch)
 		kfree_skb(skb);
 		sfq_dec(q, d);
 		sch->q.qlen--;
-		q->ht[q->hash[d]] = SFQ_DEPTH;
+		q->ht[q->hash[d]] = q->depth;
 		sch->qstats.drops++;
 		sch->qstats.backlog -= len;
 		return len;
@@ -253,8 +256,8 @@ static void sfq_q_enqueue(struct sk_buff *skb, struct sfq_sched_data *q, unsigne
 	sfq_index x;
 
 	x = q->ht[hash];
-	if (x == SFQ_DEPTH) {
-		q->ht[hash] = x = q->dep[SFQ_DEPTH].next;
+	if (x == q->depth) {
+		q->ht[hash] = x = q->dep[q->depth].next;
 		q->hash[x] = hash;
 	}
 
@@ -265,7 +268,7 @@ static void sfq_q_enqueue(struct sk_buff *skb, struct sfq_sched_data *q, unsigne
 
 	sfq_inc(q, x);
 	if (q->qs[x].qlen == 1) {		/* The flow is new */
-		if (q->tail == SFQ_DEPTH) {	/* It is the first flow */
+		if (q->tail == q->depth) {	/* It is the first flow */
 			q->tail = x;
 			q->next[x] = x;
 			q->allot[x] = q->quantum;
@@ -316,7 +319,7 @@ static struct sk_buff *sfq_q_dequeue(struct sfq_sched_data *q)
 	sfq_index a, old_a;
 
 	/* No active slots */
-	if (q->tail == SFQ_DEPTH)
+	if (q->tail == q->depth)
 		return NULL;
 
 	a = old_a = q->next[q->tail];
@@ -327,10 +330,10 @@ static struct sk_buff *sfq_q_dequeue(struct sfq_sched_data *q)
 
 	/* Is the slot empty? */
 	if (q->qs[a].qlen == 0) {
-		q->ht[q->hash[a]] = SFQ_DEPTH;
+		q->ht[q->hash[a]] = q->depth;
 		a = q->next[a];
 		if (a == old_a) {
-			q->tail = SFQ_DEPTH;
+			q->tail = q->depth;
 			return skb;
 		}
 		q->next[q->tail] = a;
@@ -383,6 +386,11 @@ static void sfq_perturbation(unsigned long arg)
 static void sfq_q_destroy(struct sfq_sched_data *q)
 {
 	del_timer(&q->perturb_timer);
+	kfree(q->dep);
+	kfree(q->next);
+	kfree(q->allot);
+	kfree(q->hash);
+	kfree(q->qs);
 }
 
 static void sfq_destroy(struct Qdisc *sch)
@@ -401,30 +409,53 @@ static int sfq_q_init(struct sfq_sched_data *q, struct rtattr *opt)
 
 	q->perturbation = 0;
 	q->max_depth = 0;
-	q->tail = q->limit = SFQ_DEPTH;
 	if (opt == NULL) {
 		q->perturb_period = 0;
+		q->tail = q->limit = q->depth = SFQ_DEPTH_DEFAULT;
 	} else {
 		struct tc_sfq_qopt *ctl = RTA_DATA(opt);
 		if (ctl->quantum)
 			q->quantum = ctl->quantum;
 		q->perturb_period = ctl->perturb_period*HZ;
+		q->tail = q->limit = q->depth = ctl->flows ? : SFQ_DEPTH_DEFAULT;
+
+		if (q->depth > SFQ_MAX_DEPTH)
+			return -EINVAL;
 
 		if (ctl->limit)
-			q->limit = min_t(u32, ctl->limit, SFQ_DEPTH);
+			q->limit = min_t(u32, ctl->limit, q->depth);
 	}
 
+	q->dep = kcalloc(1 + q->depth*2, sizeof(struct sfq_head), GFP_KERNEL);
+	if (!q->dep)
+		goto err_case;
+	q->next = kcalloc(q->depth, sizeof(sfq_index), GFP_KERNEL);
+	if (!q->next)
+		goto err_case;
+	q->allot = kcalloc(q->depth, sizeof(short), GFP_KERNEL);
+	if (!q->allot)
+		goto err_case;
+	q->hash = kcalloc(q->depth, sizeof(unsigned short), GFP_KERNEL);
+	if (!q->hash)
+		goto err_case;
+	q->qs = kcalloc(q->depth, sizeof(struct sk_buff_head), GFP_KERNEL);
+	if (!q->qs)
+		goto err_case;
+
 	for (i=0; i<SFQ_HASH_DIVISOR; i++)
-		q->ht[i] = SFQ_DEPTH;
-	for (i=0; i<SFQ_DEPTH; i++) {
+		q->ht[i] = q->depth;
+	for (i=0; i < q->depth; i++) {
 		skb_queue_head_init(&q->qs[i]);
-		q->dep[i+SFQ_DEPTH].next = i+SFQ_DEPTH;
-		q->dep[i+SFQ_DEPTH].prev = i+SFQ_DEPTH;
+		q->dep[i + q->depth].next = i + q->depth;
+		q->dep[i + q->depth].prev = i + q->depth;
 	}
 
-	for (i=0; i<SFQ_DEPTH; i++)
+	for (i=0; i < q->depth; i++)
 		sfq_link(q, i);
 	return 0;
+err_case:
+	sfq_q_destroy(q);
+	return -ENOBUFS;
 }
 
 static int sfq_init(struct Qdisc *sch, struct rtattr *opt)
@@ -458,7 +489,7 @@ static int sfq_dump(struct Qdisc *sch, struct sk_buff *skb)
 
 	opt.limit = q->limit;
 	opt.divisor = SFQ_HASH_DIVISOR;
-	opt.flows = q->limit;
+	opt.flows = q->depth;
 
 	RTA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
 
-- 
1.5.2.4

