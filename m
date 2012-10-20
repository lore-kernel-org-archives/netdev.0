From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] pkt_sched: use ns_to_ktime() helper
Date: Sat, 20 Oct 2012 12:40:51 +0200
Message-ID: <1350729651.13333.570.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:37554 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754513Ab2JTKk4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Oct 2012 06:40:56 -0400
Received: by mail-ee0-f46.google.com with SMTP id b15so457183eek.19
        for <netdev@vger.kernel.org>; Sat, 20 Oct 2012 03:40:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

ns_to_ktime() seems better than ktime_set() + ktime_add_ns()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_api.c |    9 ++++-----
 net/sched/sch_cbq.c |    3 +--
 2 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index a18d975..13cc744 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -495,16 +495,15 @@ EXPORT_SYMBOL(qdisc_watchdog_init);
 
 void qdisc_watchdog_schedule(struct qdisc_watchdog *wd, psched_time_t expires)
 {
-	ktime_t time;
-
 	if (test_bit(__QDISC_STATE_DEACTIVATED,
 		     &qdisc_root_sleeping(wd->qdisc)->state))
 		return;
 
 	qdisc_throttled(wd->qdisc);
-	time = ktime_set(0, 0);
-	time = ktime_add_ns(time, PSCHED_TICKS2NS(expires));
-	hrtimer_start(&wd->timer, time, HRTIMER_MODE_ABS);
+
+	hrtimer_start(&wd->timer,
+		      ns_to_ktime(PSCHED_TICKS2NS(expires)),
+		      HRTIMER_MODE_ABS);
 }
 EXPORT_SYMBOL(qdisc_watchdog_schedule);
 
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 564b9fc..0e19948 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -509,8 +509,7 @@ static void cbq_ovl_delay(struct cbq_class *cl)
 			cl->cpriority = TC_CBQ_MAXPRIO;
 			q->pmask |= (1<<TC_CBQ_MAXPRIO);
 
-			expires = ktime_set(0, 0);
-			expires = ktime_add_ns(expires, PSCHED_TICKS2NS(sched));
+			expires = ns_to_ktime(PSCHED_TICKS2NS(sched));
 			if (hrtimer_try_to_cancel(&q->delay_timer) &&
 			    ktime_to_ns(ktime_sub(
 					hrtimer_get_expires(&q->delay_timer),
