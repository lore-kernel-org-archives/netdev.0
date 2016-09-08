From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [4.4-RT PATCH RFC/RFT] drivers: net: cpsw: mark rx/tx irq as
 IRQF_NO_THREAD
Date: Thu, 8 Sep 2016 18:00:42 +0200
Message-ID: <20160908160042.lci5xkd37o4rrrg5@linutronix.de>
References: <20160811161540.9613-1-grygorii.strashko@ti.com>
 <20160812083206.t7lvxpo44marwpf5@linutronix.de>
 <9f811252-82ff-fd24-1006-2b40cd448927@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Steven Rostedt <rostedt@goodmis.org>, linux-omap@vger.kernel.org,
        Alison Chaiken <alison@peloton-tech.com>,
        linux-rt-users@vger.kernel.org, netdev@vger.kernel.org
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Galois.linutronix.de ([146.0.238.70]:44925 "EHLO
        Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1030335AbcIHQAw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 12:00:52 -0400
Content-Disposition: inline
In-Reply-To: <9f811252-82ff-fd24-1006-2b40cd448927@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016-08-19 17:29:16 [+0300], Grygorii Strashko wrote:
> I've collected trace before first occurrence of  "NOHZ: local_softirq_pending 80"
> 
>  irq/354-4848400-85    [000]    90.639460: irq_handler_entry:    irq=19 name=arch_timer
>            iperf-1284  [001]    90.639474: softirq_raise:        vec=1 [action=TIMER]
>            iperf-1284  [001]    90.639486: irq_handler_exit:     irq=19 ret=handled
>  irq/354-4848400-85    [000]    90.639488: softirq_raise:        vec=7 [action=SCHED]
here we raise the SCHED softirq

>            iperf-1284  [001]    90.639490: sched_waking:         comm=ksoftirqd/1 pid=21 prio=120 target_cpu=001
>  irq/354-4848400-85    [000]    90.639492: softirq_raise:        vec=1 [action=TIMER]
and a timer
>            iperf-1284  [001]    90.639499: sched_wakeup:         ksoftirqd/1:21 [120] success=1 CPU:001
>            iperf-1284  [001]    90.639504: sched_waking:         comm=ktimersoftd/1 pid=20 prio=98 target_cpu=001
>  irq/354-4848400-85    [000]    90.639505: irq_handler_exit:     irq=19 ret=handled

okay. so softirq here I come

>            iperf-1284  [001]    90.639512: sched_wakeup:         ktimersoftd/1:20 [98] success=1 CPU:001
>            iperf-1284  [001]    90.639526: sched_stat_runtime:   comm=iperf pid=1284 runtime=50752 [ns] vruntime=2105322850 [ns]
>            iperf-1284  [001]    90.639537: sched_switch:         iperf:1284 [120] R ==> irq/355-4848400:86 [49]
>  irq/355-4848400-86    [001]    90.639545: softirq_raise:        vec=3 [action=NET_RX]
>  irq/355-4848400-86    [001]    90.639556: softirq_entry:        vec=3 [action=NET_RX]
>  irq/355-4848400-86    [001]    90.639589: softirq_exit:         vec=3 [action=NET_RX]
>  irq/355-4848400-86    [001]    90.639614: sched_switch:         irq/355-4848400:86 [49] S ==> ktimersoftd/1:20 [98]
>    ktimersoftd/1-20    [001]    90.639625: softirq_entry:        vec=1 [action=TIMER]
>    ktimersoftd/1-20    [001]    90.639637: sched_waking:         comm=rcu_preempt pid=8 prio=98 target_cpu=001
>    ktimersoftd/1-20    [001]    90.639646: sched_wakeup:         rcu_preempt:8 [98] success=1 CPU:001
>    ktimersoftd/1-20    [001]    90.639663: softirq_exit:         vec=1 [action=TIMER]
>    ktimersoftd/1-20    [001]    90.639679: sched_switch:         ktimersoftd/1:20 [98] S ==> rcu_preempt:8 [98]
>      rcu_preempt-8     [001]    90.639722: sched_switch:         rcu_preempt:8 [98] S ==> ksoftirqd/1:21 [120]
>      ksoftirqd/1-21    [001]    90.639740: sched_stat_runtime:   comm=ksoftirqd/1 pid=21 runtime=25539 [ns] vruntime=29960463828 [ns]
>      ksoftirqd/1-21    [001]    90.639750: sched_switch:         ksoftirqd/1:21 [120] S ==> iperf:1284 [120]
>  irq/354-4848400-85    [000]    90.639878: irq_handler_entry:    irq=355 name=48484000.ethernet
wait, no

[ lots NET_RX wake ups ]
>  irq/354-4848400-85    [000]    90.640560: softirq_exit:         vec=3 [action=NET_RX]
ach. NET_RX

>  irq/354-4848400-85    [000]    90.640568: softirq_raise:        vec=3 [action=NET_RX]
>  irq/354-4848400-85    [000]    90.640579: softirq_entry:        vec=3 [action=NET_RX]
>  irq/354-4848400-85    [000]    90.640606: irq_handler_entry:    irq=355 name=48484000.ethernet
>  irq/354-4848400-85    [000]    90.640608: irq_handler_exit:     irq=355 ret=handled

[ more of those ]

>  irq/354-4848400-85    [000]    90.642393: softirq_exit:         vec=3 [action=NET_RX]
>  irq/354-4848400-85    [000]    90.642419: sched_switch:         irq/354-4848400:85 [49] S ==> rcuc/0:11 [98]

We don't serve TIMER & SCHED because those two are pushed to the
ksoftirq thread(s). So we keep mostly doing NET_RX and now we switch to
the next best thing which is RCU.

>           rcuc/0-11    [000]    90.642430: irq_handler_entry:    irq=354 name=48484000.ethernet
but not for long.

>           rcuc/0-11    [000]    90.642432: irq_handler_exit:     irq=354 ret=handled
>           rcuc/0-11    [000]    90.642435: sched_waking:         comm=irq/354-4848400 pid=85 prio=49 target_cpu=000
>           rcuc/0-11    [000]    90.642442: sched_migrate_task:   comm=irq/354-4848400 pid=85 prio=49 orig_cpu=0 dest_cpu=1
>           rcuc/0-11    [000]    90.642453: sched_wakeup:         irq/354-4848400:85 [49] success=1 CPU:001
>            iperf-1284  [001]    90.642462: sched_stat_runtime:   comm=iperf pid=1284 runtime=113053 [ns] vruntime=2106997666 [ns]
>           rcuc/0-11    [000]    90.642464: irq_handler_entry:    irq=355 name=48484000.ethernet
>           rcuc/0-11    [000]    90.642466: irq_handler_exit:     irq=355 ret=handled
>           rcuc/0-11    [000]    90.642469: sched_waking:         comm=irq/355-4848400 pid=86 prio=49 target_cpu=001
>            iperf-1284  [001]    90.642473: sched_switch:         iperf:1284 [120] R ==> irq/354-4848400:85 [49]
>  irq/354-4848400-85    [001]    90.642481: softirq_raise:        vec=3 [action=NET_RX]
>           rcuc/0-11    [000]    90.642483: sched_wakeup:         irq/355-4848400:86 [49] success=1 CPU:001
>  irq/354-4848400-85    [001]    90.642493: softirq_entry:        vec=3 [action=NET_RX]
>           rcuc/0-11    [000]    90.642497: sched_migrate_task:   comm=irq/355-4848400 pid=86 prio=49 orig_cpu=1 dest_cpu=0
ach that IRQ thread no pinned. Good. We migrate.

>           rcuc/0-11    [000]    90.642515: irq_handler_entry:    irq=354 name=48484000.ethernet
>           rcuc/0-11    [000]    90.642516: irq_handler_exit:     irq=354 ret=handled
>           rcuc/0-11    [000]    90.642533: sched_switch:         rcuc/0:11 [98] R ==> irq/355-4848400:86 [49]
>  irq/355-4848400-86    [000]    90.642541: softirq_raise:        vec=3 [action=NET_RX]
>  irq/355-4848400-86    [000]    90.642551: softirq_entry:        vec=3 [action=NET_RX]
>  irq/355-4848400-86    [000]    90.642562: sched_pi_setprio:     comm=iperf pid=1284 oldprio=120 newprio=49
>  irq/355-4848400-86    [000]    90.642593: sched_switch:         irq/355-4848400:86 [49] D ==> rcuc/0:11 [98]
>           rcuc/0-11    [000]    90.642621: sched_switch:         rcuc/0:11 [98] S ==> ktimersoftd/0:4 [98]
>    ktimersoftd/0-4     [000]    90.642631: softirq_entry:        vec=1 [action=TIMER]
we did wait quite some time for that one.

>    ktimersoftd/0-4     [000]    90.642647: softirq_exit:         vec=1 [action=TIMER]
>    ktimersoftd/0-4     [000]    90.642665: sched_switch:         ktimersoftd/0:4 [98] S ==> ksoftirqd/0:3 [120]
switch back ksoftirqd where SCHED softirq might run.

>      ksoftirqd/0-3     [000]    90.642692: sched_stat_runtime:   comm=ksoftirqd/0 pid=3 runtime=34486 [ns] vruntime=33313887612 [ns]
>      ksoftirqd/0-3     [000]    90.642703: sched_switch:         ksoftirqd/0:3 [120] D ==> trace-cmd:1278 [120]
but we blocked on something in softirq and go back to trace-cmd

>        trace-cmd-1278  [000]    90.642742: sched_waking:         comm=trace-cmd pid=1279 prio=120 target_cpu=001
>        trace-cmd-1278  [000]    90.642755: sched_wakeup:         trace-cmd:1279 [120] success=1 CPU:001
>  irq/354-4848400-85    [001]    90.643012: softirq_exit:         vec=3 [action=NET_RX]
>        trace-cmd-1278  [000]    90.643020: sched_stat_runtime:   comm=trace-cmd pid=1278 runtime=328098 [ns] vruntime=554552351 [ns]
>  irq/354-4848400-85    [001]    90.643021: softirq_raise:        vec=3 [action=NET_RX]
>  irq/354-4848400-85    [001]    90.643031: softirq_entry:        vec=3 [action=NET_RX]
>        trace-cmd-1278  [000]    90.643036: sched_switch:         trace-cmd:1278 [120] D ==> iperf:1282 [120]
trace-cmd is going, back to iperf.

>            iperf-1282  [000]    90.643055: sched_stat_runtime:   comm=iperf pid=1282 runtime=34811 [ns] vruntime=560242796 [ns]
>            iperf-1282  [000]    90.643068: sched_switch:         iperf:1282 [120] D ==> swapper/0:0 [120]
iperf is blocked on something, too.

>           <idle>-0     [000]    90.643079: bputs:                0xc003e7d4s: 58f67c094e488
>           <idle>-0     [000]    90.643090: bprint:               softirq_check_pending_idle: NOHZ: 80

As you see ksoftirqd left the CPU with a D so I would assume it is
blocked on a lock and waits. 
NET_RX is in progress but scheduled out due to RCUC which is also
scheduled out.

I assume we got to softirq because nothing else can run. It will see
that NET_RX is pending and tries it but blocks on the lock
(lock_softirq()). It schedules out. Nothing left -> idle.

The idle code checks to see if a softirq is pending and in fact there is
SCHED on the list and ksoftirq was about to handle it but due to
ordering complication (NET_RX before SCHED) it can't. And we have the
warning.

This 

--- a/kernel/softirq.c
+++ b/kernel/softirq.c
@@ -105,6 +105,7 @@ void softirq_check_pending_idle(void)
 {
 	static int rate_limit;
 	struct softirq_runner *sr = this_cpu_ptr(&softirq_runners);
+	struct task_struct *ksoft_tsk = __this_cpu_read(ksoftirqd);
 	u32 warnpending;
 	int i;
 
@@ -112,7 +113,7 @@ void softirq_check_pending_idle(void)
 		return;
 
 	warnpending = local_softirq_pending() & SOFTIRQ_STOP_IDLE_MASK;
-	for (i = 0; i < NR_SOFTIRQS; i++) {
+	for (i = 0; (i < NR_SOFTIRQS) && warnpending; i++) {
 		struct task_struct *tsk = sr->runner[i];
 
 		/*
@@ -132,6 +133,15 @@ void softirq_check_pending_idle(void)
 		}
 	}
 
+	if (warnpending && ksoft_tsk) {
+		raw_spin_lock(&ksoft_tsk->pi_lock);
+		if (ksoft_tsk->pi_blocked_on || ksoft_tsk->state == TASK_RUNNING) {
+			/* Clear all bits pending in that task */
+			warnpending &= ~(ksoft_tsk->softirqs_raised);
+		}
+		raw_spin_unlock(&ksoft_tsk->pi_lock);
+	}
+
 	if (warnpending) {
 		printk(KERN_ERR "NOHZ: local_softirq_pending %02x\n",
 		       warnpending);


should avoid the warning if the softirq thread is blocked.

However:
- RCU boosting with RT prio might help here or there.
- having the hard-IRQ and IRQ-thread on the same CPU might help, too. It
  is not strictly required but saves a few cycles if you don't have to
  perform cross CPU wake ups and migrate task forth and back. The latter
  happens at prio 99.
- I am not sure NAPI works as expected. I would assume so. There is IRQ
  354 and 355 which fire after each other. One would be enough I guess.
  And they seem to be short living / fire often. If NAPI works then it
  should put an end to it and push it to the softirq thread.
  If you have IRQ-pacing support I suggest to use something like 10ms or
  so. That means your ping response will go from <= 1ms to 10ms in the
  worst case but since you process more packets at a time your
  throughput should increase.
  If I count this correct, it too you alsmost 4ms from "raise SCHED" to
  "try process SCHED" and most of the time was spent in 35[45] hard irq,
  raise NET_RX or cross wakeup the IRQ thread.

Sebastian
