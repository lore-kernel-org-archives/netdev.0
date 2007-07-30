From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: [PATCH 6/7] Make qdisc changeable.
Date: Sun, 29 Jul 2007 17:21:15 -0700
Message-ID: <11857548783311-git-send-email-bugfood-ml@fatooh.org>
References: <11857548771998-git-send-email-bugfood-ml@fatooh.org>
Cc: Corey Hickey <bugfood-ml@fatooh.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:37095 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965441AbXG3AVX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Jul 2007 20:21:23 -0400
In-Reply-To: <11857548771998-git-send-email-bugfood-ml@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Re-implement sfq_change() and enable Qdisc_opts.change so "tc qdisc
change" will work.

Signed-off-by: Corey Hickey <bugfood-ml@fatooh.org>
---
 net/sched/sch_sfq.c |   51 ++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 50 insertions(+), 1 deletions(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index e6a6a21..e042cd0 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -485,6 +485,55 @@ static int sfq_init(struct Qdisc *sch, struct rtattr *opt)
 	return 0;
 }
 
+static int sfq_change(struct Qdisc *sch, struct rtattr *opt)
+{
+	struct sfq_sched_data *q = qdisc_priv(sch);
+	struct sfq_sched_data tmp;
+	struct sk_buff *skb;
+	int err;
+	
+	/* set up tmp queue */
+	memset(&tmp, 0, sizeof(struct sfq_sched_data));
+	tmp.quantum = psched_mtu(sch->dev); /* default */
+	if ((err = sfq_q_init(&tmp, opt)))
+		return err;
+
+	/* copy packets from the old queue to the tmp queue */
+	sch_tree_lock(sch);
+	while (sch->q.qlen >= tmp.limit - 1)
+		sfq_drop(sch);
+	while ((skb = sfq_q_dequeue(q)) != NULL)
+		sfq_q_enqueue(skb, &tmp, SFQ_TAIL);
+	
+	/* clean up the old queue */
+	sfq_q_destroy(q);
+
+	/* copy elements of the tmp queue into the old queue */
+	q->perturb_period = tmp.perturb_period;
+	q->quantum        = tmp.quantum;
+	q->limit          = tmp.limit;
+	q->depth          = tmp.depth;
+	q->hash_divisor   = tmp.hash_divisor;
+	q->tail           = tmp.tail;
+	q->max_depth      = tmp.max_depth;
+	q->ht    = tmp.ht;
+	q->dep   = tmp.dep;
+	q->next  = tmp.next;
+	q->allot = tmp.allot;
+	q->hash  = tmp.hash;
+	q->qs    = tmp.qs;
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
@@ -519,7 +568,7 @@ static struct Qdisc_ops sfq_qdisc_ops = {
 	.init		=	sfq_init,
 	.reset		=	sfq_reset,
 	.destroy	=	sfq_destroy,
-	.change		=	NULL,
+	.change		=	sfq_change,
 	.dump		=	sfq_dump,
 	.owner		=	THIS_MODULE,
 };
-- 
1.5.2.4

