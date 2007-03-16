From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 02/10]: Add hrtimer based qdisc watchdog
Date: Fri, 16 Mar 2007 06:30:51 +0100 (MET)
Message-ID: <20070316053021.22744.96564.sendpatchset@localhost.localdomain>
References: <20070316053018.22744.76883.sendpatchset@localhost.localdomain>
Cc: devik@cdi.cz, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	shemminger@linux-foundation.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45249 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752268AbXCPFaw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2007 01:30:52 -0400
In-Reply-To: <20070316053018.22744.76883.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET_SCHED]: Add hrtimer based qdisc watchdog

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 4d0baa5c06cb04a53d8c68ecc10f38a295f08d14
tree 08da6754c9cc015a3118c452649d9fb6425dd903
parent e400fa6d9e7c13d675b96958a967e747148e9b70
author Patrick McHardy <kaber@trash.net> Fri, 16 Mar 2007 06:06:26 +0100
committer Patrick McHardy <kaber@trash.net> Fri, 16 Mar 2007 06:06:26 +0100

 include/net/pkt_sched.h |   10 ++++++++++
 net/sched/sch_api.c     |   36 ++++++++++++++++++++++++++++++++++++
 2 files changed, 46 insertions(+), 0 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index 1c12afd..b090d55 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -64,6 +64,16 @@ #define PSCHED_SET_PASTPERFECT(t)	((t) =
 #define PSCHED_IS_PASTPERFECT(t)	((t) == 0)
 #define	PSCHED_AUDIT_TDIFF(t)
 
+struct qdisc_watchdog {
+	struct hrtimer	timer;
+	struct Qdisc	*qdisc;
+};
+
+extern void qdisc_watchdog_init(struct qdisc_watchdog *wd, struct Qdisc *qdisc);
+extern void qdisc_watchdog_schedule(struct qdisc_watchdog *wd,
+				    psched_time_t expires);
+extern void qdisc_watchdog_cancel(struct qdisc_watchdog *wd);
+
 extern struct Qdisc_ops pfifo_qdisc_ops;
 extern struct Qdisc_ops bfifo_qdisc_ops;
 
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index d71bf79..6bc395c 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -34,6 +34,7 @@ #include <linux/seq_file.h>
 #include <linux/kmod.h>
 #include <linux/list.h>
 #include <linux/bitops.h>
+#include <linux/hrtimer.h>
 
 #include <net/sock.h>
 #include <net/pkt_sched.h>
@@ -291,6 +292,41 @@ void qdisc_put_rtab(struct qdisc_rate_ta
 	}
 }
 
+static enum hrtimer_restart qdisc_watchdog(struct hrtimer *timer)
+{
+	struct qdisc_watchdog *wd = container_of(timer, struct qdisc_watchdog,
+						 timer);
+
+	wd->qdisc->flags &= ~TCQ_F_THROTTLED;
+	netif_schedule(wd->qdisc->dev);
+	return HRTIMER_NORESTART;
+}
+
+void qdisc_watchdog_init(struct qdisc_watchdog *wd, struct Qdisc *qdisc)
+{
+	hrtimer_init(&wd->timer, CLOCK_MONOTONIC, HRTIMER_MODE_ABS);
+	wd->timer.function = qdisc_watchdog;
+	wd->qdisc = qdisc;
+}
+EXPORT_SYMBOL(qdisc_watchdog_init);
+
+void qdisc_watchdog_schedule(struct qdisc_watchdog *wd, psched_time_t expires)
+{
+	ktime_t time;
+
+	wd->qdisc->flags |= TCQ_F_THROTTLED;
+	time = ktime_set(0, 0);
+	time = ktime_add_ns(time, PSCHED_US2NS(expires));
+	hrtimer_start(&wd->timer, time, HRTIMER_MODE_ABS);
+}
+EXPORT_SYMBOL(qdisc_watchdog_schedule);
+
+void qdisc_watchdog_cancel(struct qdisc_watchdog *wd)
+{
+	hrtimer_cancel(&wd->timer);
+	wd->qdisc->flags &= ~TCQ_F_THROTTLED;
+}
+EXPORT_SYMBOL(qdisc_watchdog_cancel);
 
 /* Allocate an unique handle from space managed by kernel */
 
