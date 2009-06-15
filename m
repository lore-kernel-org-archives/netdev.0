From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 3/2] pkt_sched: Rename PSCHED_US2NS and PSCHED_NS2US
Date: Mon, 15 Jun 2009 09:15:23 +0000
Message-ID: <20090615091523.GA10411@ff.dom.local>
References: <20090609080513.GB5237@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Antonio Almeida <vexwek@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, Martin Devera <devik@cdi.cz>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Vladimir Ivashchenko <hazard@francoudi.com>,
	Badalian Vyacheslav <slavon@bigtelecom.ru>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f206.google.com ([209.85.220.206]:41179 "EHLO
	mail-fx0-f206.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750786AbZFOJP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2009 05:15:28 -0400
Received: by fxm2 with SMTP id 2so135469fxm.37
        for <netdev@vger.kernel.org>; Mon, 15 Jun 2009 02:15:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090609080513.GB5237@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 09, 2009 at 08:05:13AM +0000, Jarek Poplawski wrote:
...
> This change breaks ticks - microseconds similarity, so some minor code
> fixes might be needed. It is also planned to change naming adequately
> eg. to PSCHED_TICKS2NS() etc. in the near future.

-------------------->
pkt_sched: Rename PSCHED_US2NS and PSCHED_NS2US

Let's use TICKS instead of US, so PSCHED_TICKS2NS and PSCHED_NS2TICKS
(like in PSCHED_TICKS_PER_SEC already) to avoid misleading.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 include/net/pkt_sched.h |    8 ++++----
 net/sched/sch_api.c     |    4 ++--
 net/sched/sch_cbq.c     |    4 ++--
 3 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index 120935b..82a3191 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -43,15 +43,15 @@ typedef long	psched_tdiff_t;
 
 /* Avoid doing 64 bit divide */
 #define PSCHED_SHIFT			6
-#define PSCHED_US2NS(x)			((s64)(x) << PSCHED_SHIFT)
-#define PSCHED_NS2US(x)			((x) >> PSCHED_SHIFT)
+#define PSCHED_TICKS2NS(x)		((s64)(x) << PSCHED_SHIFT)
+#define PSCHED_NS2TICKS(x)		((x) >> PSCHED_SHIFT)
 
-#define PSCHED_TICKS_PER_SEC		PSCHED_NS2US(NSEC_PER_SEC)
+#define PSCHED_TICKS_PER_SEC		PSCHED_NS2TICKS(NSEC_PER_SEC)
 #define PSCHED_PASTPERFECT		0
 
 static inline psched_time_t psched_get_time(void)
 {
-	return PSCHED_NS2US(ktime_to_ns(ktime_get()));
+	return PSCHED_NS2TICKS(ktime_to_ns(ktime_get()));
 }
 
 static inline psched_tdiff_t
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 3200979..24d17ce 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -484,7 +484,7 @@ void qdisc_watchdog_schedule(struct qdisc_watchdog *wd, psched_time_t expires)
 
 	wd->qdisc->flags |= TCQ_F_THROTTLED;
 	time = ktime_set(0, 0);
-	time = ktime_add_ns(time, PSCHED_US2NS(expires));
+	time = ktime_add_ns(time, PSCHED_TICKS2NS(expires));
 	hrtimer_start(&wd->timer, time, HRTIMER_MODE_ABS);
 }
 EXPORT_SYMBOL(qdisc_watchdog_schedule);
@@ -1680,7 +1680,7 @@ static int psched_show(struct seq_file *seq, void *v)
 
 	hrtimer_get_res(CLOCK_MONOTONIC, &ts);
 	seq_printf(seq, "%08x %08x %08x %08x\n",
-		   (u32)NSEC_PER_USEC, (u32)PSCHED_US2NS(1),
+		   (u32)NSEC_PER_USEC, (u32)PSCHED_TICKS2NS(1),
 		   1000000,
 		   (u32)NSEC_PER_SEC/(u32)ktime_to_ns(timespec_to_ktime(ts)));
 
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index d728d81..23a1676 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -509,7 +509,7 @@ static void cbq_ovl_delay(struct cbq_class *cl)
 			q->pmask |= (1<<TC_CBQ_MAXPRIO);
 
 			expires = ktime_set(0, 0);
-			expires = ktime_add_ns(expires, PSCHED_US2NS(sched));
+			expires = ktime_add_ns(expires, PSCHED_TICKS2NS(sched));
 			if (hrtimer_try_to_cancel(&q->delay_timer) &&
 			    ktime_to_ns(ktime_sub(
 					hrtimer_get_expires(&q->delay_timer),
@@ -620,7 +620,7 @@ static enum hrtimer_restart cbq_undelay(struct hrtimer *timer)
 		ktime_t time;
 
 		time = ktime_set(0, 0);
-		time = ktime_add_ns(time, PSCHED_US2NS(now + delay));
+		time = ktime_add_ns(time, PSCHED_TICKS2NS(now + delay));
 		hrtimer_start(&q->delay_timer, time, HRTIMER_MODE_ABS);
 	}
 
