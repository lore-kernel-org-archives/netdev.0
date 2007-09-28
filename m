From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: [PATCH 09/10] Change perturb_period to unsigned.
Date: Fri, 28 Sep 2007 15:52:56 -0700
Message-ID: <11910199784097-git-send-email-bugfood-ml@fatooh.org>
References: <1191019977201-git-send-email-bugfood-ml@fatooh.org>
Cc: Corey Hickey <bugfood-ml@fatooh.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:42867 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754593AbXI1WxI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Sep 2007 18:53:08 -0400
In-Reply-To: <1191019977201-git-send-email-bugfood-ml@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

perturb_period is currently a signed integer, but I can't see any good
reason why this is so--a negative perturbation period will add a timer
that expires in the past, causing constant perturbation, which makes
hashing useless.

	if (q->perturb_period) {
		q->perturb_timer.expires = jiffies + q->perturb_period;
		add_timer(&q->perturb_timer);
	}

Strictly speaking, this will break binary compatibility with older
versions of tc, but that ought not to be a problem because (a) there's
no valid use for a negative perturb_period, and (b) negative values
will be seen as high values (> INT_MAX), which don't work anyway.

If perturb_period is too large, (perturb_period * HZ) will overflow the
size of an unsigned int and wrap around. So, check for thet and reject
values that are too high.

Signed-off-by: Corey Hickey <bugfood-ml@fatooh.org>
---
 include/linux/pkt_sched.h |    2 +-
 net/sched/sch_sfq.c       |    8 ++++++--
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index 58a0ea6..8559974 100644
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
index 2d3cc38..170fd37 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -74,6 +74,9 @@
 typedef unsigned int sfq_index;
 #define SFQ_MAX_DEPTH (UINT_MAX / 2 - 1)
 
+/* We don't want perturb_period * HZ to overflow an unsigned int. */
+#define SFQ_MAX_PERTURB (UINT_MAX / HZ)
+
 struct sfq_head
 {
 	sfq_index	next;
@@ -83,7 +86,7 @@ struct sfq_head
 struct sfq_sched_data
 {
 /* Parameters */
-	int		perturb_period;
+	unsigned	perturb_period;
 	unsigned	quantum;	/* Allotment per round: MUST BE >= MTU */
 	int		limit;
 	unsigned	depth;
@@ -441,7 +444,8 @@ sfq_q_init(struct sfq_sched_data *q, struct rtattr *opt)
 		if (ctl->limit)
 			q->limit = ctl->limit;
 
-		if (q->depth > SFQ_MAX_DEPTH)
+		if (q->perturb_period > SFQ_MAX_PERTURB ||
+		    q->depth > SFQ_MAX_DEPTH)
 			return -EINVAL;
 	}
 	q->limit = min_t(u32, q->limit, q->depth - 2);
-- 
1.5.3

