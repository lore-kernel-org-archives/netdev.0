From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: [PATCH 2/7] Preparatory refactoring part 2.
Date: Sun, 29 Jul 2007 00:08:49 -0700
Message-ID: <11856929352132-git-send-email-bugfood-ml@fatooh.org>
References: <11856929352537-git-send-email-bugfood-ml@fatooh.org>
 <11856929353322-git-send-email-bugfood-ml@fatooh.org>
Cc: Corey Hickey <bugfood-ml@fatooh.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:60041 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757943AbXG2HIw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Jul 2007 03:08:52 -0400
In-Reply-To: <11856929353322-git-send-email-bugfood-ml@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Factor code out of sfq_init() and sfq_destroy(), again so that the
new functions can be used by sfq_change() later.

Actually, as the diff itself shows, most of the sfq_q_init() code
comes from the original sfq_change(), but sfq_change() is only
called by sfq_init() right now. Thus, it is safe to remove
sfq_change(); "tc qdisc change" doesn't yet work for sfq anyway.

The sfq_destroy() --> sfq_q_destroy() change looks pointless here,
but it's cleaner to split now and add code to sfq_q_destroy() in a
later patch.

Signed-off-by: Corey Hickey <bugfood-ml@fatooh.org>
---
 net/sched/sch_sfq.c |   80 +++++++++++++++++++++++++-------------------------
 1 files changed, 40 insertions(+), 40 deletions(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 8ae077f..0c46938 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -380,71 +380,71 @@ static void sfq_perturbation(unsigned long arg)
 	}
 }
 
-static int sfq_change(struct Qdisc *sch, struct rtattr *opt)
+static int sfq_q_init(struct sfq_sched_data *q, struct rtattr *opt)
 {
-	struct sfq_sched_data *q = qdisc_priv(sch);
 	struct tc_sfq_qopt *ctl = RTA_DATA(opt);
-	unsigned int qlen;
+	int i;
 
-	if (opt->rta_len < RTA_LENGTH(sizeof(*ctl)))
+	if (opt && opt->rta_len < RTA_LENGTH(sizeof(*ctl)))
 		return -EINVAL;
 
-	sch_tree_lock(sch);
-	q->quantum = ctl->quantum ? : psched_mtu(sch->dev);
-	q->perturb_period = ctl->perturb_period*HZ;
-	if (ctl->limit)
-		q->limit = min_t(u32, ctl->limit, SFQ_DEPTH);
+	q->perturbation = 0;
+	q->max_depth = 0;
+	q->tail = q->limit = SFQ_DEPTH;
+	if (opt == NULL) {
+		q->perturb_period = 0;
+	} else {
+		struct tc_sfq_qopt *ctl = RTA_DATA(opt);
+		if (ctl->quantum)
+			q->quantum = ctl->quantum;
+		q->perturb_period = ctl->perturb_period*HZ;
 
-	qlen = sch->q.qlen;
-	while (sch->q.qlen >= q->limit-1)
-		sfq_drop(sch);
-	qdisc_tree_decrease_qlen(sch, qlen - sch->q.qlen);
+		if (ctl->limit)
+			q->limit = min_t(u32, ctl->limit, SFQ_DEPTH);
+	}
 
-	del_timer(&q->perturb_timer);
-	if (q->perturb_period) {
-		q->perturb_timer.expires = jiffies + q->perturb_period;
-		add_timer(&q->perturb_timer);
+	for (i=0; i<SFQ_HASH_DIVISOR; i++)
+		q->ht[i] = SFQ_DEPTH;
+	for (i=0; i<SFQ_DEPTH; i++) {
+		skb_queue_head_init(&q->qs[i]);
+		q->dep[i+SFQ_DEPTH].next = i+SFQ_DEPTH;
+		q->dep[i+SFQ_DEPTH].prev = i+SFQ_DEPTH;
 	}
-	sch_tree_unlock(sch);
+
+	for (i=0; i<SFQ_DEPTH; i++)
+		sfq_link(q, i);
 	return 0;
 }
 
 static int sfq_init(struct Qdisc *sch, struct rtattr *opt)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
-	int i;
+	int err;
+	
+	q->quantum = psched_mtu(sch->dev); /* default */
+	if ((err = sfq_q_init(q, opt)))
+		return err;
 
 	init_timer(&q->perturb_timer);
 	q->perturb_timer.data = (unsigned long)sch;
 	q->perturb_timer.function = sfq_perturbation;
-
-	for (i=0; i<SFQ_HASH_DIVISOR; i++)
-		q->ht[i] = SFQ_DEPTH;
-	for (i=0; i<SFQ_DEPTH; i++) {
-		skb_queue_head_init(&q->qs[i]);
-		q->dep[i+SFQ_DEPTH].next = i+SFQ_DEPTH;
-		q->dep[i+SFQ_DEPTH].prev = i+SFQ_DEPTH;
-	}
-	q->limit = SFQ_DEPTH;
-	q->max_depth = 0;
-	q->tail = SFQ_DEPTH;
-	if (opt == NULL) {
-		q->quantum = psched_mtu(sch->dev);
-		q->perturb_period = 0;
-	} else {
-		int err = sfq_change(sch, opt);
-		if (err)
-			return err;
+	if (q->perturb_period) {
+		q->perturb_timer.expires = jiffies + q->perturb_period;
+		add_timer(&q->perturb_timer);
 	}
-	for (i=0; i<SFQ_DEPTH; i++)
-		sfq_link(q, i);
+
 	return 0;
 }
 
+static void sfq_q_destroy(struct sfq_sched_data *q)
+{
+	del_timer(&q->perturb_timer);
+}
+
 static void sfq_destroy(struct Qdisc *sch)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
-	del_timer(&q->perturb_timer);
+	sfq_q_destroy(q);
 }
 
 static int sfq_dump(struct Qdisc *sch, struct sk_buff *skb)
-- 
1.5.2.4

