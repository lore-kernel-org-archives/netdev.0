From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: [PATCH 02/10] Preparatory refactoring part 2.
Date: Sat, 25 Aug 2007 15:26:56 -0700
Message-ID: <1188080825671-git-send-email-bugfood-ml@fatooh.org>
References: <11880808243166-git-send-email-bugfood-ml@fatooh.org>
Cc: Corey Hickey <bugfood-ml@fatooh.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:35054 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757877AbXHYW1G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Aug 2007 18:27:06 -0400
In-Reply-To: <11880808243166-git-send-email-bugfood-ml@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Factor code out of sfq_init() and sfq_destroy(), again so that the
new functions can be used by sfq_change() later.

Actually, as the diff itself shows, most of the sfq_q_init() code
comes from the original sfq_change(), but sfq_change() is only
called by sfq_init() right now. Thus, it is safe to remove
sfq_change(); "tc qdisc change" doesn't yet work for sfq anyway.

Setting default parameters is moved into a separate function for
clarity.

The sfq_destroy() --> sfq_q_destroy() change looks pointless here,
but it's cleaner to split now and add code to sfq_q_destroy() in a
later patch.

Signed-off-by: Corey Hickey <bugfood-ml@fatooh.org>
---
 net/sched/sch_sfq.c |   96 +++++++++++++++++++++++++++++----------------------
 1 files changed, 55 insertions(+), 41 deletions(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 346e966..f95a0dc 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -382,43 +382,42 @@ static void sfq_perturbation(unsigned long arg)
 	}
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
-		q->limit = min_t(u32, ctl->limit, SFQ_DEPTH);
 
-	qlen = sch->q.qlen;
-	while (sch->q.qlen >= q->limit-1)
-		sfq_drop(sch);
-	qdisc_tree_decrease_qlen(sch, qlen - sch->q.qlen);
-
-	del_timer(&q->perturb_timer);
-	if (q->perturb_period) {
-		q->perturb_timer.expires = jiffies + q->perturb_period;
-		add_timer(&q->perturb_timer);
-	}
-	sch_tree_unlock(sch);
-	return 0;
+	q->quantum = psched_mtu(sch->dev);
+	q->perturbation = 0;
+	q->perturb_period = 0;
+	q->limit = SFQ_DEPTH;
 }
 
-static int sfq_init(struct Qdisc *sch, struct rtattr *opt)
+
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
+	q->limit = min_t(u32, q->limit, SFQ_DEPTH);
+	q->tail = SFQ_DEPTH;
+	q->max_depth = 0;
 
 	for (i=0; i<SFQ_HASH_DIVISOR; i++)
 		q->ht[i] = SFQ_DEPTH;
@@ -427,28 +426,43 @@ static int sfq_init(struct Qdisc *sch, struct rtattr *opt)
 		q->dep[i+SFQ_DEPTH].next = i+SFQ_DEPTH;
 		q->dep[i+SFQ_DEPTH].prev = i+SFQ_DEPTH;
 	}
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
-	}
+
 	for (i=0; i<SFQ_DEPTH; i++)
 		sfq_link(q, i);
 	return 0;
 }
 
-static void sfq_destroy(struct Qdisc *sch)
+static int sfq_init(struct Qdisc *sch, struct rtattr *opt)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
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
+static void sfq_q_destroy(struct sfq_sched_data *q)
+{
 	del_timer(&q->perturb_timer);
 }
 
+static void sfq_destroy(struct Qdisc *sch)
+{
+	struct sfq_sched_data *q = qdisc_priv(sch);
+	sfq_q_destroy(q);
+}
+
 static int sfq_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
-- 
1.5.2.4

