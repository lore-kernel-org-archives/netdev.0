From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v5 06/11] sch_api: introduce qdisc_watchdog_schedule_ns()
Date: Tue, 12 Feb 2013 11:12:04 +0100
Message-ID: <1360663929-1023-7-git-send-email-jiri@resnulli.us>
References: <1360663929-1023-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, jhs@mojatatu.com,
	kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:39550 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758144Ab3BLKMe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 05:12:34 -0500
Received: by mail-ee0-f48.google.com with SMTP id t10so3891059eei.35
        for <netdev@vger.kernel.org>; Tue, 12 Feb 2013 02:12:33 -0800 (PST)
In-Reply-To: <1360663929-1023-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tbf will need to schedule watchdog in ns. No need to convert it twice.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/net/pkt_sched.h | 10 ++++++++--
 net/sched/sch_api.c     |  6 +++---
 2 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index 66f5ac3..388bf8b 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -65,8 +65,14 @@ struct qdisc_watchdog {
 };
 
 extern void qdisc_watchdog_init(struct qdisc_watchdog *wd, struct Qdisc *qdisc);
-extern void qdisc_watchdog_schedule(struct qdisc_watchdog *wd,
-				    psched_time_t expires);
+extern void qdisc_watchdog_schedule_ns(struct qdisc_watchdog *wd, u64 expires);
+
+static inline void qdisc_watchdog_schedule(struct qdisc_watchdog *wd,
+					   psched_time_t expires)
+{
+	qdisc_watchdog_schedule_ns(wd, PSCHED_TICKS2NS(expires));
+}
+
 extern void qdisc_watchdog_cancel(struct qdisc_watchdog *wd);
 
 extern struct Qdisc_ops pfifo_qdisc_ops;
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index d84f7e7..fe1ba54 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -493,7 +493,7 @@ void qdisc_watchdog_init(struct qdisc_watchdog *wd, struct Qdisc *qdisc)
 }
 EXPORT_SYMBOL(qdisc_watchdog_init);
 
-void qdisc_watchdog_schedule(struct qdisc_watchdog *wd, psched_time_t expires)
+void qdisc_watchdog_schedule_ns(struct qdisc_watchdog *wd, u64 expires)
 {
 	if (test_bit(__QDISC_STATE_DEACTIVATED,
 		     &qdisc_root_sleeping(wd->qdisc)->state))
@@ -502,10 +502,10 @@ void qdisc_watchdog_schedule(struct qdisc_watchdog *wd, psched_time_t expires)
 	qdisc_throttled(wd->qdisc);
 
 	hrtimer_start(&wd->timer,
-		      ns_to_ktime(PSCHED_TICKS2NS(expires)),
+		      ns_to_ktime(expires),
 		      HRTIMER_MODE_ABS);
 }
-EXPORT_SYMBOL(qdisc_watchdog_schedule);
+EXPORT_SYMBOL(qdisc_watchdog_schedule_ns);
 
 void qdisc_watchdog_cancel(struct qdisc_watchdog *wd)
 {
-- 
1.8.1.2
