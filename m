From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: [PATCH 08/10] Multiply perturb_period by HZ when used rather than when assigned.
Date: Sat, 25 Aug 2007 15:27:02 -0700
Message-ID: <11880808272401-git-send-email-bugfood-ml@fatooh.org>
References: <11880808243166-git-send-email-bugfood-ml@fatooh.org>
Cc: Corey Hickey <bugfood-ml@fatooh.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:35067 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759010AbXHYW1H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Aug 2007 18:27:07 -0400
In-Reply-To: <11880808243166-git-send-email-bugfood-ml@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

perturb_period is the only parameter that doesn't match 1:1 with the
value from userspace. This change makes it easy and clean to use a
small macro for setting parameters (in a subsequent patch).

Signed-off-by: Corey Hickey <bugfood-ml@fatooh.org>
---
 net/sched/sch_sfq.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 77ffce3..f9f4460 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -370,7 +370,7 @@ static void sfq_perturbation(unsigned long arg)
 	q->perturbation = net_random()&0x1F;
 
 	if (q->perturb_period) {
-		q->perturb_timer.expires = jiffies + q->perturb_period;
+		q->perturb_timer.expires = jiffies + q->perturb_period * HZ;
 		add_timer(&q->perturb_timer);
 	}
 }
@@ -432,7 +432,7 @@ sfq_q_init(struct sfq_sched_data *q, struct rtattr *opt)
 		if (ctl->quantum)
 			q->quantum = ctl->quantum;
 		if (ctl->perturb_period)
-			q->perturb_period = ctl->perturb_period * HZ;
+			q->perturb_period = ctl->perturb_period;
 		if (ctl->divisor)
 			q->hash_divisor = ctl->divisor;
 		if (ctl->flows)
@@ -495,7 +495,7 @@ static int sfq_init(struct Qdisc *sch, struct rtattr *opt)
 	q->perturb_timer.data = (unsigned long)sch;
 	q->perturb_timer.function = sfq_perturbation;
 	if (q->perturb_period) {
-		q->perturb_timer.expires = jiffies + q->perturb_period;
+		q->perturb_timer.expires = jiffies + q->perturb_period * HZ;
 		add_timer(&q->perturb_timer);
 	}
 
@@ -545,7 +545,7 @@ static int sfq_change(struct Qdisc *sch, struct rtattr *opt)
 
 	/* finish up */
 	if (q->perturb_period) {
-		q->perturb_timer.expires = jiffies + q->perturb_period;
+		q->perturb_timer.expires = jiffies + q->perturb_period * HZ;
 		add_timer(&q->perturb_timer);
 	} else {
 		q->perturbation = 0;
@@ -561,7 +561,7 @@ static int sfq_dump(struct Qdisc *sch, struct sk_buff *skb)
 	struct tc_sfq_qopt opt;
 
 	opt.quantum = q->quantum;
-	opt.perturb_period = q->perturb_period/HZ;
+	opt.perturb_period = q->perturb_period;
 
 	opt.limit = q->limit;
 	opt.divisor = q->hash_divisor;
-- 
1.5.2.4

