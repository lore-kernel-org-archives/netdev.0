From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: sched: use pinned timers
Date: Sat, 20 Sep 2014 18:01:30 -0700
Message-ID: <1411261290.26859.103.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:52573 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751572AbaIUBBb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 21:01:31 -0400
Received: by mail-pa0-f44.google.com with SMTP id eu11so1393109pac.31
        for <netdev@vger.kernel.org>; Sat, 20 Sep 2014 18:01:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

While using a MQ + NETEM setup, I had confirmation that the default
timer migration ( /proc/sys/kernel/timer_migration ) is killing us.

Installing this on a receiver side of a TCP_STREAM test, (NIC has 8 TX
queues) :

EST="est 1sec 4sec"
for ETH in eth1
do
 tc qd del dev $ETH root 2>/dev/null
 tc qd add dev $ETH root handle 1: mq
 tc qd add dev $ETH parent 1:1 $EST netem limit 70000 delay 6ms
 tc qd add dev $ETH parent 1:2 $EST netem limit 70000 delay 8ms
 tc qd add dev $ETH parent 1:3 $EST netem limit 70000 delay 10ms
 tc qd add dev $ETH parent 1:4 $EST netem limit 70000 delay 12ms
 tc qd add dev $ETH parent 1:5 $EST netem limit 70000 delay 14ms
 tc qd add dev $ETH parent 1:6 $EST netem limit 70000 delay 16ms
 tc qd add dev $ETH parent 1:7 $EST netem limit 80000 delay 18ms
 tc qd add dev $ETH parent 1:8 $EST netem limit 90000 delay 20ms
done

We can see that timers get migrated into a single cpu, presumably idle
at the time timers are set up.
Then all qdisc dequeues run from this cpu and huge lock contention
happens. This single cpu is stuck in softirq mode and cannot dequeue
fast enough.

    39.24%  [kernel]          [k] _raw_spin_lock
     2.65%  [kernel]          [k] netem_enqueue
     1.80%  [kernel]          [k] netem_dequeue                         
     1.63%  [kernel]          [k] copy_user_enhanced_fast_string
     1.45%  [kernel]          [k] _raw_spin_lock_bh        

By pinning qdisc timers on the cpu running the qdisc, we respect proper
XPS setting and remove this lock contention.

     5.84%  [kernel]          [k] netem_enqueue                      
     4.83%  [kernel]          [k] _raw_spin_lock
     2.92%  [kernel]          [k] copy_user_enhanced_fast_string

Current Qdiscs that benefit from this change are :

	netem, cbq, fq, hfsc, tbf, htb.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_api.c |    4 ++--
 net/sched/sch_cbq.c |    4 ++--
 net/sched/sch_htb.c |    2 +-
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index ca6248345937..15e7beee266c 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -586,7 +586,7 @@ static enum hrtimer_restart qdisc_watchdog(struct hrtimer *timer)
 
 void qdisc_watchdog_init(struct qdisc_watchdog *wd, struct Qdisc *qdisc)
 {
-	hrtimer_init(&wd->timer, CLOCK_MONOTONIC, HRTIMER_MODE_ABS);
+	hrtimer_init(&wd->timer, CLOCK_MONOTONIC, HRTIMER_MODE_ABS_PINNED);
 	wd->timer.function = qdisc_watchdog;
 	wd->qdisc = qdisc;
 }
@@ -602,7 +602,7 @@ void qdisc_watchdog_schedule_ns(struct qdisc_watchdog *wd, u64 expires)
 
 	hrtimer_start(&wd->timer,
 		      ns_to_ktime(expires),
-		      HRTIMER_MODE_ABS);
+		      HRTIMER_MODE_ABS_PINNED);
 }
 EXPORT_SYMBOL(qdisc_watchdog_schedule_ns);
 
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index a3244a800501..d2cd981ba60d 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -617,7 +617,7 @@ static enum hrtimer_restart cbq_undelay(struct hrtimer *timer)
 
 		time = ktime_set(0, 0);
 		time = ktime_add_ns(time, PSCHED_TICKS2NS(now + delay));
-		hrtimer_start(&q->delay_timer, time, HRTIMER_MODE_ABS);
+		hrtimer_start(&q->delay_timer, time, HRTIMER_MODE_ABS_PINNED);
 	}
 
 	qdisc_unthrottled(sch);
@@ -1386,7 +1386,7 @@ static int cbq_init(struct Qdisc *sch, struct nlattr *opt)
 	q->link.minidle = -0x7FFFFFFF;
 
 	qdisc_watchdog_init(&q->watchdog, sch);
-	hrtimer_init(&q->delay_timer, CLOCK_MONOTONIC, HRTIMER_MODE_ABS);
+	hrtimer_init(&q->delay_timer, CLOCK_MONOTONIC, HRTIMER_MODE_ABS_PINNED);
 	q->delay_timer.function = cbq_undelay;
 	q->toplevel = TC_CBQ_MAXLEVEL;
 	q->now = psched_get_time();
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 14408f262143..063e953d9848 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -932,7 +932,7 @@ ok:
 			ktime_t time = ns_to_ktime(next_event);
 			qdisc_throttled(q->watchdog.qdisc);
 			hrtimer_start(&q->watchdog.timer, time,
-				      HRTIMER_MODE_ABS);
+				      HRTIMER_MODE_ABS_PINNED);
 		}
 	} else {
 		schedule_work(&q->work);
