From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: [PATCH 4/8] Add divisor.
Date: Mon, 29 Oct 2007 00:23:03 -0700
Message-ID: <1193642587-32657-5-git-send-email-bugfood-ml@fatooh.org>
References: <1193642587-32657-1-git-send-email-bugfood-ml@fatooh.org>
Cc: Corey Hickey <bugfood-ml@fatooh.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:50311 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751581AbXJ2HXK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 03:23:10 -0400
In-Reply-To: <1193642587-32657-1-git-send-email-bugfood-ml@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make hash divisor user-configurable.

Signed-off-by: Corey Hickey <bugfood-ml@fatooh.org>
---
 net/sched/sch_sfq.c |   27 +++++++++++++++++++++------
 1 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 1c1bf08..c74d5ce 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -76,7 +76,7 @@
 	It is easy to increase these values, but not in flight.  */
 
 #define SFQ_DEPTH_DEFAULT	128
-#define SFQ_HASH_DIVISOR	1024
+#define SFQ_DIVISOR_DEFAULT	10
 
 #define SFQ_HEAD 0
 #define SFQ_TAIL 1
@@ -86,6 +86,10 @@
 typedef unsigned int sfq_index;
 #define SFQ_MAX_DEPTH (UINT_MAX / 2 - 1)
 
+/* In practice, the actual divisor size is limited by kcalloc, but we still
+ * don't want to left shift by more than 31. */
+#define SFQ_MAX_DIVISOR 31
+
 struct sfq_head
 {
 	sfq_index	next;
@@ -99,6 +103,7 @@ struct sfq_sched_data
 	unsigned	quantum;	/* Allotment per round: MUST BE >= MTU */
 	int		limit;
 	unsigned	depth;
+	unsigned	hash_divisor;
 
 /* Variables */
 	struct timer_list perturb_timer;
@@ -106,7 +111,7 @@ struct sfq_sched_data
 	sfq_index	tail;		/* Index of current slot in round */
 	sfq_index	max_depth;	/* Maximal depth */
 
-	sfq_index	ht[SFQ_HASH_DIVISOR];	/* Hash table */
+	sfq_index	*ht;			/* Hash table */
 	sfq_index	*next;			/* Active slots link */
 	short		*allot;			/* Current allotment per slot */
 	unsigned short	*hash;			/* Hash value indexed by slots */
@@ -116,7 +121,9 @@ struct sfq_sched_data
 
 static __inline__ unsigned sfq_fold_hash(struct sfq_sched_data *q, u32 h, u32 h1)
 {
-	return jhash_2words(h, h1, q->perturbation) & (SFQ_HASH_DIVISOR - 1);
+	unsigned mask = (1<<q->hash_divisor) - 1;
+
+	return jhash_2words(h, h1, q->perturbation) & mask;
 }
 
 static unsigned sfq_hash(struct sfq_sched_data *q, struct sk_buff *skb)
@@ -418,6 +425,7 @@ static void sfq_perturbation(unsigned long arg)
 
 static void sfq_q_destroy(struct sfq_sched_data *q)
 {
+	kfree(q->ht);
 	kfree(q->dep);
 	kfree(q->next);
 	kfree(q->allot);
@@ -441,6 +449,7 @@ sfq_default_parameters(struct Qdisc *sch)
 	q->quantum        = psched_mtu(sch->dev);
 	q->perturbation   = 0;
 	q->perturb_period = 0;
+	q->hash_divisor   = SFQ_DIVISOR_DEFAULT;
 	q->depth          = SFQ_DEPTH_DEFAULT;
 	q->limit          = SFQ_DEPTH_DEFAULT - 1;
 }
@@ -463,18 +472,24 @@ sfq_q_init(struct sfq_sched_data *q, struct rtattr *opt)
 			q->quantum = ctl->quantum;
 		if (ctl->perturb_period)
 			q->perturb_period = ctl->perturb_period * HZ;
+		if (ctl->divisor)
+			q->hash_divisor = ctl->divisor;
 		if (ctl->flows)
 			q->depth = ctl->flows;
 		if (ctl->limit)
 			q->limit = ctl->limit;
 
-		if (q->depth > SFQ_MAX_DEPTH)
+		if (q->depth        > SFQ_MAX_DEPTH ||
+		    q->hash_divisor > SFQ_MAX_DIVISOR)
 			return -EINVAL;
 	}
 	q->limit = min_t(u32, q->limit, q->depth - 1);
 	q->tail = q->depth;
 	q->max_depth = 0;
 
+	q->ht = kcalloc(1<<q->hash_divisor, sizeof(sfq_index), GFP_KERNEL);
+	if (!q->ht)
+		goto err_case;
 	q->dep = kcalloc(1 + q->depth*2, sizeof(struct sfq_head), GFP_KERNEL);
 	if (!q->dep)
 		goto err_case;
@@ -491,7 +506,7 @@ sfq_q_init(struct sfq_sched_data *q, struct rtattr *opt)
 	if (!q->qs)
 		goto err_case;
 
-	for (i=0; i<SFQ_HASH_DIVISOR; i++)
+	for (i=0; i < 1<<q->hash_divisor; i++)
 		q->ht[i] = q->depth;
 	for (i=0; i < q->depth; i++) {
 		skb_queue_head_init(&q->qs[i]);
@@ -537,7 +552,7 @@ static int sfq_dump(struct Qdisc *sch, struct sk_buff *skb)
 	opt.perturb_period = q->perturb_period/HZ;
 
 	opt.limit = q->limit;
-	opt.divisor = SFQ_HASH_DIVISOR;
+	opt.divisor = q->hash_divisor;
 	opt.flows = q->depth;
 
 	RTA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
-- 
1.5.3.4

