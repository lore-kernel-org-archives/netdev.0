From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/2]: pkt_sched: Convert qdisc_watchdog to tasklet_hrtimer
Date: Fri, 21 Aug 2009 17:03:30 -0700 (PDT)
Message-ID: <20090821.170330.217935645.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tglx@linutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46045
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932587AbZHVADS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2009 20:03:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


None of this stuff should execute in hw IRQ context, therefore
use a tasklet_hrtimer so that it runs in softirq context.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/pkt_sched.h |    4 ++--
 net/sched/sch_api.c     |    8 ++++----
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index 82a3191..7eafb8d 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -61,8 +61,8 @@ psched_tdiff_bounded(psched_time_t tv1, psched_time_t tv2, psched_time_t bound)
 }
 
 struct qdisc_watchdog {
-	struct hrtimer	timer;
-	struct Qdisc	*qdisc;
+	struct tasklet_hrtimer	timer;
+	struct Qdisc		*qdisc;
 };
 
 extern void qdisc_watchdog_init(struct qdisc_watchdog *wd, struct Qdisc *qdisc);
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 24d17ce..e1c2bf7 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -468,8 +468,8 @@ static enum hrtimer_restart qdisc_watchdog(struct hrtimer *timer)
 
 void qdisc_watchdog_init(struct qdisc_watchdog *wd, struct Qdisc *qdisc)
 {
-	hrtimer_init(&wd->timer, CLOCK_MONOTONIC, HRTIMER_MODE_ABS);
-	wd->timer.function = qdisc_watchdog;
+	tasklet_hrtimer_init(&wd->timer, qdisc_watchdog,
+			     CLOCK_MONOTONIC, HRTIMER_MODE_ABS);
 	wd->qdisc = qdisc;
 }
 EXPORT_SYMBOL(qdisc_watchdog_init);
@@ -485,13 +485,13 @@ void qdisc_watchdog_schedule(struct qdisc_watchdog *wd, psched_time_t expires)
 	wd->qdisc->flags |= TCQ_F_THROTTLED;
 	time = ktime_set(0, 0);
 	time = ktime_add_ns(time, PSCHED_TICKS2NS(expires));
-	hrtimer_start(&wd->timer, time, HRTIMER_MODE_ABS);
+	tasklet_hrtimer_start(&wd->timer, time, HRTIMER_MODE_ABS);
 }
 EXPORT_SYMBOL(qdisc_watchdog_schedule);
 
 void qdisc_watchdog_cancel(struct qdisc_watchdog *wd)
 {
-	hrtimer_cancel(&wd->timer);
+	tasklet_hrtimer_cancel(&wd->timer);
 	wd->qdisc->flags &= ~TCQ_F_THROTTLED;
 }
 EXPORT_SYMBOL(qdisc_watchdog_cancel);
-- 
1.6.3.4

