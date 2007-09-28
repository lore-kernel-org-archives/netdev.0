From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: [PATCH 06/10] Make qdisc changeable.
Date: Fri, 28 Sep 2007 15:52:53 -0700
Message-ID: <11910199772562-git-send-email-bugfood-ml@fatooh.org>
References: <1191019977201-git-send-email-bugfood-ml@fatooh.org>
Cc: Corey Hickey <bugfood-ml@fatooh.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:42862 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753933AbXI1WxH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Sep 2007 18:53:07 -0400
In-Reply-To: <1191019977201-git-send-email-bugfood-ml@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Re-implement sfq_change() and enable Qdisc_opts.change so "tc qdisc
change" will work.

Signed-off-by: Corey Hickey <bugfood-ml@fatooh.org>
---
 net/sched/sch_sfq.c |   61 ++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 60 insertions(+), 1 deletions(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index d72ea7c..b8e8fa5 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -416,6 +416,17 @@ sfq_default_parameters(struct Qdisc *sch)
 	q->limit          = SFQ_DEPTH_DEFAULT - 2;
 }
 
+static void
+sfq_copy_parameters(struct sfq_sched_data *dst, struct sfq_sched_data *src)
+{
+	dst->quantum        = src->quantum;
+	dst->perturbation   = src->perturbation;
+	dst->perturb_period = src->perturb_period;
+	dst->hash_divisor   = src->hash_divisor;
+	dst->limit          = src->limit;
+	dst->depth          = src->depth;
+}
+
 static int
 sfq_q_init(struct sfq_sched_data *q, struct rtattr *opt)
 {
@@ -503,6 +514,54 @@ static int sfq_init(struct Qdisc *sch, struct rtattr *opt)
 	return 0;
 }
 
+static int sfq_change(struct Qdisc *sch, struct rtattr *opt)
+{
+	struct sfq_sched_data *q = qdisc_priv(sch);
+	struct sfq_sched_data tmp;
+	struct sk_buff *skb;
+	unsigned int qlen;
+	int err;
+	
+	/* set up tmp queue */
+	memset(&tmp, 0, sizeof(struct sfq_sched_data));
+	sfq_copy_parameters(&tmp, q);
+	if ((err = sfq_q_init(&tmp, opt)))
+		return err;
+
+	/* copy packets from the old queue to the tmp queue */
+	sch_tree_lock(sch);
+	qlen = sch->q.qlen;
+	while (sch->q.qlen >= tmp.limit - 1)
+		sfq_drop(sch);
+	qdisc_tree_decrease_qlen(sch, qlen - sch->q.qlen);
+	while ((skb = sfq_q_dequeue(q)) != NULL)
+		sfq_q_enqueue(skb, &tmp, SFQ_TAIL);
+	
+	/* clean up the old queue */
+	sfq_q_destroy(q);
+
+	/* copy elements of the tmp queue into the old queue */
+	sfq_copy_parameters(q, &tmp);
+	q->tail      = tmp.tail;
+	q->max_depth = tmp.max_depth;
+	q->ht        = tmp.ht;
+	q->dep       = tmp.dep;
+	q->next      = tmp.next;
+	q->allot     = tmp.allot;
+	q->hash      = tmp.hash;
+	q->qs        = tmp.qs;
+
+	/* finish up */
+	if (q->perturb_period) {
+		q->perturb_timer.expires = jiffies + q->perturb_period;
+		add_timer(&q->perturb_timer);
+	} else {
+		q->perturbation = 0;
+	}
+	sch_tree_unlock(sch);
+	return 0;
+}
+
 static int sfq_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
@@ -537,7 +596,7 @@ static struct Qdisc_ops sfq_qdisc_ops = {
 	.init		=	sfq_init,
 	.reset		=	sfq_reset,
 	.destroy	=	sfq_destroy,
-	.change		=	NULL,
+	.change		=	sfq_change,
 	.dump		=	sfq_dump,
 	.owner		=	THIS_MODULE,
 };
-- 
1.5.3

