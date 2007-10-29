From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: [PATCH 2/8] Preparatory refactoring part 2.
Date: Mon, 29 Oct 2007 00:23:01 -0700
Message-ID: <1193642587-32657-3-git-send-email-bugfood-ml@fatooh.org>
References: <1193642587-32657-1-git-send-email-bugfood-ml@fatooh.org>
Cc: Corey Hickey <bugfood-ml@fatooh.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:50305 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750940AbXJ2HXK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 03:23:10 -0400
In-Reply-To: <1193642587-32657-1-git-send-email-bugfood-ml@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Factor code out of sfq_init() so that the new function can be used
by sfq_change() later.

Actually, as the diff itself shows, most of the sfq_q_init() code
comes from the original sfq_change(), but sfq_change() is only
called by sfq_init() right now. Thus, it is safe to remove
sfq_change(); "tc qdisc change" doesn't yet work for sfq anyway.

Setting default parameters is moved into a separate function for
clarity.

Signed-off-by: Corey Hickey <bugfood-ml@fatooh.org>
---
 net/sched/sch_sfq.c |   88 +++++++++++++++++++++++++++-----------------------
 1 files changed, 47 insertions(+), 41 deletions(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 10e2f3d..8ea816a 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -413,43 +413,41 @@ static void sfq_perturbation(unsigned long arg)
 		mod_timer(&q->perturb_timer, jiffies + q->perturb_period);
 }
 
-static int sfq_change(struct Qdisc *sch, struct rtattr *opt)
+static void
+sfq_default_parameters(struct Qdisc *sch)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
-	struct tc_sfq_qopt *ctl = RTA_DATA(opt);
-	unsigned int qlen;
-
-	if (opt->rta_len < RTA_LENGTH(sizeof(*ctl)))
-		return -EINVAL;
-
-	sch_tree_lock(sch);
-	q->quantum = ctl->quantum ? : psched_mtu(sch->dev);
-	q->perturb_period = ctl->perturb_period*HZ;
-	if (ctl->limit)
-		q->limit = min_t(u32, ctl->limit, SFQ_DEPTH - 1);
 
-	qlen = sch->q.qlen;
-	while (sch->q.qlen > q->limit)
-		sfq_drop(sch);
-	qdisc_tree_decrease_qlen(sch, qlen - sch->q.qlen);
-
-	del_timer(&q->perturb_timer);
-	if (q->perturb_period) {
-		mod_timer(&q->perturb_timer, jiffies + q->perturb_period);
-		get_random_bytes(&q->perturbation, 4);
-	}
-	sch_tree_unlock(sch);
-	return 0;
+	q->quantum        = psched_mtu(sch->dev);
+	q->perturbation   = 0;
+	q->perturb_period = 0;
+	q->limit          = SFQ_DEPTH - 1;
 }
 
-static int sfq_init(struct Qdisc *sch, struct rtattr *opt)
+static int
+sfq_q_init(struct sfq_sched_data *q, struct rtattr *opt)
 {
-	struct sfq_sched_data *q = qdisc_priv(sch);
 	int i;
 
-	init_timer(&q->perturb_timer);
-	q->perturb_timer.data = (unsigned long)sch;
-	q->perturb_timer.function = sfq_perturbation;
+	/* At this point, parameters are set to either defaults (sfq_init) or
+	 * the previous values (sfq_change). So, overwrite the parameters as
+	 * specified. */
+	if (opt) {
+		struct tc_sfq_qopt *ctl = RTA_DATA(opt);
+
+		if (opt->rta_len < RTA_LENGTH(sizeof(*ctl)))
+			return -EINVAL;
+
+		if (ctl->quantum)
+			q->quantum = ctl->quantum;
+		if (ctl->perturb_period)
+			q->perturb_period = ctl->perturb_period * HZ;
+		if (ctl->limit)
+			q->limit = ctl->limit;
+	}
+	q->limit = min_t(u32, q->limit, SFQ_DEPTH - 1);
+	q->tail = SFQ_DEPTH;
+	q->max_depth = 0;
 
 	for (i=0; i<SFQ_HASH_DIVISOR; i++)
 		q->ht[i] = SFQ_DEPTH;
@@ -458,23 +456,31 @@ static int sfq_init(struct Qdisc *sch, struct rtattr *opt)
 		q->dep[i+SFQ_DEPTH].next = i+SFQ_DEPTH;
 		q->dep[i+SFQ_DEPTH].prev = i+SFQ_DEPTH;
 	}
-	q->limit = SFQ_DEPTH - 1;
-	q->max_depth = 0;
-	q->tail = SFQ_DEPTH;
-	if (opt == NULL) {
-		q->quantum = psched_mtu(sch->dev);
-		q->perturb_period = 0;
-		get_random_bytes(&q->perturbation, 4);
-	} else {
-		int err = sfq_change(sch, opt);
-		if (err)
-			return err;
-	}
 	for (i=0; i<SFQ_DEPTH; i++)
 		sfq_link(q, i);
 	return 0;
 }
 
+static int sfq_init(struct Qdisc *sch, struct rtattr *opt)
+{
+	struct sfq_sched_data *q = qdisc_priv(sch);
+	int err;
+
+	sfq_default_parameters(sch);
+	if ((err = sfq_q_init(q, opt)))
+		return err;
+
+	init_timer(&q->perturb_timer);
+	q->perturb_timer.data = (unsigned long)sch;
+	q->perturb_timer.function = sfq_perturbation;
+	if (q->perturb_period) {
+		q->perturb_timer.expires = jiffies + q->perturb_period;
+		add_timer(&q->perturb_timer);
+	}
+
+	return 0;
+}
+
 static void sfq_destroy(struct Qdisc *sch)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
-- 
1.5.3.4

