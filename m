From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v4 08/11] tbf: fix value set for q->ptokens
Date: Sun, 10 Feb 2013 11:52:16 +0100
Message-ID: <1360493539-14868-9-git-send-email-jiri@resnulli.us>
References: <1360493539-14868-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, jhs@mojatatu.com,
	kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f177.google.com ([209.85.215.177]:33281 "EHLO
	mail-ea0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754762Ab3BJKxB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 05:53:01 -0500
Received: by mail-ea0-f177.google.com with SMTP id n13so2205246eaa.22
        for <netdev@vger.kernel.org>; Sun, 10 Feb 2013 02:52:59 -0800 (PST)
In-Reply-To: <1360493539-14868-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

q->ptokens is in ns and we are assigning q->mtu directly to it. That is
wrong. psched_l2t_ns() should be used to compute correct value.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/sched/sch_tbf.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index dc562a8..0ac6224 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -111,6 +111,7 @@ struct tbf_sched_data {
 /* Variables */
 	s64	tokens;			/* Current number of B tokens */
 	s64	ptokens;		/* Current number of P tokens */
+	s64	mtu_ptokens;
 	psched_time_t	t_c;		/* Time check-point */
 	struct Qdisc	*qdisc;		/* Inner qdisc, default - bfifo queue */
 	struct qdisc_watchdog watchdog;	/* Watchdog timer */
@@ -165,8 +166,8 @@ static struct sk_buff *tbf_dequeue(struct Qdisc *sch)
 
 		if (q->peak_present) {
 			ptoks = toks + q->ptokens;
-			if (ptoks > (long)q->mtu)
-				ptoks = q->mtu;
+			if (ptoks > q->mtu_ptokens)
+				ptoks = q->mtu_ptokens;
 			ptoks -= (s64) psched_l2t_ns(&q->peak, len);
 		}
 		toks += q->tokens;
@@ -215,7 +216,8 @@ static void tbf_reset(struct Qdisc *sch)
 	sch->q.qlen = 0;
 	q->t_c = ktime_to_ns(ktime_get());
 	q->tokens = q->buffer;
-	q->ptokens = q->mtu;
+	if (q->peak_present)
+		q->ptokens = q->mtu_ptokens;
 	qdisc_watchdog_cancel(&q->watchdog);
 }
 
@@ -296,11 +298,12 @@ static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
 	q->max_size = max_size;
 	q->buffer = PSCHED_TICKS2NS(qopt->buffer);
 	q->tokens = q->buffer;
-	q->ptokens = q->mtu;
 
 	psched_ratecfg_precompute(&q->rate, rtab->rate.rate);
 	if (ptab) {
 		psched_ratecfg_precompute(&q->peak, ptab->rate.rate);
+		q->mtu_ptokens = (s64) psched_l2t_ns(&q->peak, q->mtu);
+		q->ptokens = q->mtu_ptokens;
 		q->peak_present = true;
 	} else {
 		q->peak_present = false;
-- 
1.8.1.2
