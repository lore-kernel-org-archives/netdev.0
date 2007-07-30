From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: [PATCH 5/7] Add divisor.
Date: Sun, 29 Jul 2007 17:21:14 -0700
Message-ID: <1185754878789-git-send-email-bugfood-ml@fatooh.org>
References: <11857548771998-git-send-email-bugfood-ml@fatooh.org>
Cc: Corey Hickey <bugfood-ml@fatooh.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:37101 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965434AbXG3AVX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Jul 2007 20:21:23 -0400
In-Reply-To: <11857548771998-git-send-email-bugfood-ml@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make hash divisor user-configurable.

Signed-off-by: Corey Hickey <bugfood-ml@fatooh.org>
---
 net/sched/sch_sfq.c |   17 ++++++++++++-----
 1 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 70124ac..e6a6a21 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -75,7 +75,7 @@
 	It is easy to increase these values, but not in flight.  */
 
 #define SFQ_DEPTH_DEFAULT	128
-#define SFQ_HASH_DIVISOR	1024
+#define SFQ_DIVISOR_DEFAULT	1024
 
 #define SFQ_HEAD 0
 #define SFQ_TAIL 1
@@ -98,6 +98,7 @@ struct sfq_sched_data
 	unsigned	quantum;	/* Allotment per round: MUST BE >= MTU */
 	int		limit;
 	unsigned	depth;
+	unsigned	hash_divisor;
 
 /* Variables */
 	struct timer_list perturb_timer;
@@ -105,7 +106,7 @@ struct sfq_sched_data
 	sfq_index	tail;		/* Index of current slot in round */
 	sfq_index	max_depth;	/* Maximal depth */
 
-	sfq_index	ht[SFQ_HASH_DIVISOR];	/* Hash table */
+	sfq_index	*ht;			/* Hash table */
 	sfq_index	*next;			/* Active slots link */
 	short		*allot;			/* Current allotment per slot */
 	unsigned short	*hash;			/* Hash value indexed by slots */
@@ -120,7 +121,7 @@ static __inline__ unsigned sfq_fold_hash(struct sfq_sched_data *q, u32 h, u32 h1
 	/* Have we any rotation primitives? If not, WHY? */
 	h ^= (h1<<pert) ^ (h1>>(0x1F - pert));
 	h ^= h>>10;
-	return h & 0x3FF;
+	return h & (q->hash_divisor-1);
 }
 
 static unsigned sfq_hash(struct sfq_sched_data *q, struct sk_buff *skb)
@@ -386,6 +387,7 @@ static void sfq_perturbation(unsigned long arg)
 static void sfq_q_destroy(struct sfq_sched_data *q)
 {
 	del_timer(&q->perturb_timer);
+	kfree(q->ht);
 	kfree(q->dep);
 	kfree(q->next);
 	kfree(q->allot);
@@ -411,12 +413,14 @@ static int sfq_q_init(struct sfq_sched_data *q, struct rtattr *opt)
 	q->max_depth = 0;
 	if (opt == NULL) {
 		q->perturb_period = 0;
+		q->hash_divisor = SFQ_DIVISOR_DEFAULT;
 		q->tail = q->limit = q->depth = SFQ_DEPTH_DEFAULT;
 	} else {
 		struct tc_sfq_qopt *ctl = RTA_DATA(opt);
 		if (ctl->quantum)
 			q->quantum = ctl->quantum;
 		q->perturb_period = ctl->perturb_period*HZ;
+		q->hash_divisor = ctl->divisor ? : SFQ_DIVISOR_DEFAULT;
 		q->tail = q->limit = q->depth = ctl->flows ? : SFQ_DEPTH_DEFAULT;
 
 		if (q->depth > SFQ_MAX_DEPTH)
@@ -426,6 +430,9 @@ static int sfq_q_init(struct sfq_sched_data *q, struct rtattr *opt)
 			q->limit = min_t(u32, ctl->limit, q->depth);
 	}
 
+	q->ht = kcalloc(q->hash_divisor, sizeof(sfq_index), GFP_KERNEL);
+	if (!q->ht)
+		goto err_case;
 	q->dep = kcalloc(1 + q->depth*2, sizeof(struct sfq_head), GFP_KERNEL);
 	if (!q->dep)
 		goto err_case;
@@ -442,7 +449,7 @@ static int sfq_q_init(struct sfq_sched_data *q, struct rtattr *opt)
 	if (!q->qs)
 		goto err_case;
 
-	for (i=0; i<SFQ_HASH_DIVISOR; i++)
+	for (i=0; i<q->hash_divisor; i++)
 		q->ht[i] = q->depth;
 	for (i=0; i < q->depth; i++) {
 		skb_queue_head_init(&q->qs[i]);
@@ -488,7 +495,7 @@ static int sfq_dump(struct Qdisc *sch, struct sk_buff *skb)
 	opt.perturb_period = q->perturb_period/HZ;
 
 	opt.limit = q->limit;
-	opt.divisor = SFQ_HASH_DIVISOR;
+	opt.divisor = q->hash_divisor;
 	opt.flows = q->depth;
 
 	RTA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
-- 
1.5.2.4

