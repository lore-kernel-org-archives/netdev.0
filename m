From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: [PATCH 04/10] Make "depth" (number of queues) user-configurable:
Date: Sat, 25 Aug 2007 15:26:58 -0700
Message-ID: <11880808262256-git-send-email-bugfood-ml@fatooh.org>
References: <11880808243166-git-send-email-bugfood-ml@fatooh.org>
Cc: Corey Hickey <bugfood-ml@fatooh.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:35054 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757977AbXHYW1H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Aug 2007 18:27:07 -0400
In-Reply-To: <11880808243166-git-send-email-bugfood-ml@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* replace #define with a parameter
* use old hardcoded value as a default
* kcalloc() arrays in sfq_q_init()
* free() arrays in sfq_q_destroy()

Signed-off-by: Corey Hickey <bugfood-ml@fatooh.org>
---
 net/sched/sch_sfq.c |   84 +++++++++++++++++++++++++++++++++++----------------
 1 files changed, 58 insertions(+), 26 deletions(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 676195d..2e6d607 100644
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
@@ -254,8 +257,8 @@ sfq_q_enqueue(struct sk_buff *skb, struct sfq_sched_data *q, unsigned int end)
 	sfq_index x;
 
 	x = q->ht[hash];
-	if (x == SFQ_DEPTH) {
-		q->ht[hash] = x = q->dep[SFQ_DEPTH].next;
+	if (x == q->depth) {
+		q->ht[hash] = x = q->dep[q->depth].next;
 		q->hash[x] = hash;
 	}
 
@@ -266,7 +269,7 @@ sfq_q_enqueue(struct sk_buff *skb, struct sfq_sched_data *q, unsigned int end)
 
 	sfq_inc(q, x);
 	if (q->qs[x].qlen == 1) {		/* The flow is new */
-		if (q->tail == SFQ_DEPTH) {	/* It is the first flow */
+		if (q->tail == q->depth) {	/* It is the first flow */
 			q->tail = x;
 			q->next[x] = x;
 			q->allot[x] = q->quantum;
@@ -318,7 +321,7 @@ sk_buff *sfq_q_dequeue(struct sfq_sched_data *q)
 	sfq_index a, old_a;
 
 	/* No active slots */
-	if (q->tail == SFQ_DEPTH)
+	if (q->tail == q->depth)
 		return NULL;
 
 	a = old_a = q->next[q->tail];
@@ -329,10 +332,10 @@ sk_buff *sfq_q_dequeue(struct sfq_sched_data *q)
 
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
@@ -385,6 +388,11 @@ static void sfq_perturbation(unsigned long arg)
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
@@ -401,7 +409,7 @@ sfq_default_parameters(struct Qdisc *sch)
 	q->quantum = psched_mtu(sch->dev);
 	q->perturbation = 0;
 	q->perturb_period = 0;
-	q->limit = SFQ_DEPTH;
+	q->limit = q->depth = SFQ_DEPTH_DEFAULT;
 }
 
 
@@ -423,24 +431,48 @@ sfq_q_init(struct sfq_sched_data *q, struct rtattr *opt)
 			q->quantum = ctl->quantum;
 		if (ctl->perturb_period)
 			q->perturb_period = ctl->perturb_period * HZ;
+		if (ctl->flows)
+			q->depth = ctl->flows;
 		if (ctl->limit)
 			q->limit = ctl->limit;
+
+		if (q->depth > SFQ_MAX_DEPTH)
+			return -EINVAL;
 	}
-	q->limit = min_t(u32, q->limit, SFQ_DEPTH);
-	q->tail = SFQ_DEPTH;
+	q->limit = min_t(u32, q->limit, q->depth);
+	q->tail = q->depth;
 	q->max_depth = 0;
 
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
@@ -474,7 +506,7 @@ static int sfq_dump(struct Qdisc *sch, struct sk_buff *skb)
 
 	opt.limit = q->limit;
 	opt.divisor = SFQ_HASH_DIVISOR;
-	opt.flows = q->limit;
+	opt.flows = q->depth;
 
 	RTA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
 
-- 
1.5.2.4

