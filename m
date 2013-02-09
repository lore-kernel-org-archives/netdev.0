From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 08/11] tbf: fix value set for q->ptokens
Date: Sat,  9 Feb 2013 17:45:09 +0100
Message-ID: <1360428312-1277-9-git-send-email-jiri@resnulli.us>
References: <1360428312-1277-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, jhs@mojatatu.com,
	kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f51.google.com ([74.125.83.51]:43055 "EHLO
	mail-ee0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932453Ab3BIQpk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Feb 2013 11:45:40 -0500
Received: by mail-ee0-f51.google.com with SMTP id d17so2522800eek.10
        for <netdev@vger.kernel.org>; Sat, 09 Feb 2013 08:45:39 -0800 (PST)
In-Reply-To: <1360428312-1277-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

q->ptokens is in ns and we are assigning q->mtu directly to it. That is
wrong. psched_l2t_ns() should be used to compute correct value.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/sched/sch_tbf.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index dc562a8..6e8b670 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -165,8 +165,8 @@ static struct sk_buff *tbf_dequeue(struct Qdisc *sch)
 
 		if (q->peak_present) {
 			ptoks = toks + q->ptokens;
-			if (ptoks > (long)q->mtu)
-				ptoks = q->mtu;
+			if (ptoks > (s64) psched_l2t_ns(&q->peak, q->mtu))
+				ptoks = (s64) psched_l2t_ns(&q->peak, q->mtu);
 			ptoks -= (s64) psched_l2t_ns(&q->peak, len);
 		}
 		toks += q->tokens;
@@ -215,7 +215,8 @@ static void tbf_reset(struct Qdisc *sch)
 	sch->q.qlen = 0;
 	q->t_c = ktime_to_ns(ktime_get());
 	q->tokens = q->buffer;
-	q->ptokens = q->mtu;
+	if (q->peak_present)
+		q->ptokens = (s64) psched_l2t_ns(&q->peak, q->mtu);
 	qdisc_watchdog_cancel(&q->watchdog);
 }
 
@@ -296,11 +297,11 @@ static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
 	q->max_size = max_size;
 	q->buffer = PSCHED_TICKS2NS(qopt->buffer);
 	q->tokens = q->buffer;
-	q->ptokens = q->mtu;
 
 	psched_ratecfg_precompute(&q->rate, rtab->rate.rate);
 	if (ptab) {
 		psched_ratecfg_precompute(&q->peak, ptab->rate.rate);
+		q->ptokens = (s64) psched_l2t_ns(&q->peak, q->mtu);
 		q->peak_present = true;
 	} else {
 		q->peak_present = false;
-- 
1.8.1.2
