From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: [PATCH 7/8] Rework perturb_period.
Date: Mon, 29 Oct 2007 00:23:06 -0700
Message-ID: <1193642587-32657-8-git-send-email-bugfood-ml@fatooh.org>
References: <1193642587-32657-1-git-send-email-bugfood-ml@fatooh.org>
Cc: Corey Hickey <bugfood-ml@fatooh.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:50329 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752156AbXJ2HXQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 03:23:16 -0400
In-Reply-To: <1193642587-32657-1-git-send-email-bugfood-ml@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

perturb_period is the only parameter that doesn't match 1:1 with the
value from userspace. Multiplying perturb_period by HZ when used rather
than when assigned makes it easy and clean to use a small function for
setting parameters (in a subsequent patch).

perturb_period is currently a signed integer, but I can't see any good
reason why this is so--a negative perturbation period will add a timer
that expires in the past, causing constant perturbation, which makes
hashing useless.

Strictly speaking, this will break binary compatibility with older
versions of tc, but that ought not to be a problem because (a) there's
no valid use for a negative perturb_period, and (b) negative values
will be seen as high values (> INT_MAX), which don't work anyway.

Signed-off-by: Corey Hickey <bugfood-ml@fatooh.org>
---
 include/linux/pkt_sched.h |    2 +-
 net/sched/sch_sfq.c       |   14 ++++++++------
 2 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index d754a3d..14a08ad 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -142,7 +142,7 @@ enum
 struct tc_sfq_qopt
 {
 	unsigned	quantum;	/* Bytes per round allocated to flow */
-	int		perturb_period;	/* Period of hash perturbation */
+	unsigned	perturb_period;	/* Period of hash perturbation */
 	__u32		limit;		/* Maximal packets in queue */
 	unsigned	divisor;	/* Hash divisor  */
 	unsigned	flows;		/* Maximal number of flows  */
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 7b11086..2764a54 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -70,6 +70,8 @@
 #define SFQ_HEAD 0
 #define SFQ_TAIL 1
 
+#define SFQ_PERTURB(period) (jiffies + (unsigned long)period * HZ)
+
 /* This type must contain greater than depth*2 values, so depth is constrained 
  * accordingly. */
 typedef unsigned int sfq_index;
@@ -88,7 +90,7 @@ struct sfq_head
 struct sfq_sched_data
 {
 /* Parameters */
-	int		perturb_period;
+	unsigned	perturb_period;
 	unsigned	quantum;	/* Allotment per round: MUST BE >= MTU */
 	int		limit;
 	unsigned	depth;
@@ -409,7 +411,7 @@ static void sfq_perturbation(unsigned long arg)
 	get_random_bytes(&q->perturbation, 4);
 
 	if (q->perturb_period)
-		mod_timer(&q->perturb_timer, jiffies + q->perturb_period);
+		mod_timer(&q->perturb_timer, SFQ_PERTURB(q->perturb_period));
 }
 
 static void sfq_q_destroy(struct sfq_sched_data *q)
@@ -471,7 +473,7 @@ sfq_q_init(struct sfq_sched_data *q, struct rtattr *opt)
 		if (ctl->quantum)
 			q->quantum = ctl->quantum;
 		if (ctl->perturb_period)
-			q->perturb_period = ctl->perturb_period * HZ;
+			q->perturb_period = ctl->perturb_period;
 		if (ctl->divisor)
 			q->hash_divisor = ctl->divisor;
 		if (ctl->flows)
@@ -535,7 +537,7 @@ static int sfq_init(struct Qdisc *sch, struct rtattr *opt)
 	q->perturb_timer.data = (unsigned long)sch;
 	q->perturb_timer.function = sfq_perturbation;
 	if (q->perturb_period) {
-		q->perturb_timer.expires = jiffies + q->perturb_period;
+		q->perturb_timer.expires = SFQ_PERTURB(q->perturb_period);
 		add_timer(&q->perturb_timer);
 	}
 
@@ -565,7 +567,7 @@ static int sfq_change(struct Qdisc *sch, struct rtattr *opt)
 		tmp.perturbation = 0;
 		del_timer(&q->perturb_timer);
 	} else if (tmp.perturb_period != q->perturb_period) {
-		mod_timer(&q->perturb_timer, jiffies + tmp.perturb_period);
+		mod_timer(&q->perturb_timer, SFQ_PERTURB(tmp.perturb_period));
 	}
 
 	/* move packets from the old queue to the tmp queue */
@@ -603,7 +605,7 @@ static int sfq_dump(struct Qdisc *sch, struct sk_buff *skb)
 	struct tc_sfq_qopt opt;
 
 	opt.quantum = q->quantum;
-	opt.perturb_period = q->perturb_period/HZ;
+	opt.perturb_period = q->perturb_period;
 
 	opt.limit = q->limit;
 	opt.divisor = q->hash_divisor;
-- 
1.5.3.4

