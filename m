From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [4.4-RT PATCH RFC/RFT] drivers: net: cpsw: mark rx/tx irq as
 IRQF_NO_THREAD
Date: Fri, 9 Sep 2016 15:46:44 +0300
Message-ID: <cdfe7655-a3b3-9b38-0231-cf90c2af037b@ti.com>
References: <20160811161540.9613-1-grygorii.strashko@ti.com>
 <20160812083206.t7lvxpo44marwpf5@linutronix.de>
 <9f811252-82ff-fd24-1006-2b40cd448927@ti.com>
 <20160908160042.lci5xkd37o4rrrg5@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Steven Rostedt <rostedt@goodmis.org>, <linux-omap@vger.kernel.org>,
        Alison Chaiken <alison@peloton-tech.com>,
        <linux-rt-users@vger.kernel.org>, <netdev@vger.kernel.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:47321 "EHLO comal.ext.ti.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755325AbcIIMrJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Sep 2016 08:47:09 -0400
In-Reply-To: <20160908160042.lci5xkd37o4rrrg5@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/08/2016 07:00 PM, Sebastian Andrzej Siewior wrote:
> On 2016-08-19 17:29:16 [+0300], Grygorii Strashko wrote:
>> I've collected trace before first occurrence of  "NOHZ: local_softirq_pending 80"
>>

> 
>>  irq/354-4848400-85    [000]    90.642393: softirq_exit:         vec=3 [action=NET_RX]
>>  irq/354-4848400-85    [000]    90.642419: sched_switch:         irq/354-4848400:85 [49] S ==> rcuc/0:11 [98]
> 
> We don't serve TIMER & SCHED because those two are pushed to the
> ksoftirq thread(s). So we keep mostly doing NET_RX and now we switch to
> the next best thing which is RCU.
> 
>>           rcuc/0-11    [000]    90.642430: irq_handler_entry:    irq=354 name=48484000.ethernet
> but not for long.
> 
>>           rcuc/0-11    [000]    90.642432: irq_handler_exit:     irq=354 ret=handled
>>           rcuc/0-11    [000]    90.642435: sched_waking:         comm=irq/354-4848400 pid=85 prio=49 target_cpu=000
>>           rcuc/0-11    [000]    90.642442: sched_migrate_task:   comm=irq/354-4848400 pid=85 prio=49 orig_cpu=0 dest_cpu=1
>>           rcuc/0-11    [000]    90.642453: sched_wakeup:         irq/354-4848400:85 [49] success=1 CPU:001
>>            iperf-1284  [001]    90.642462: sched_stat_runtime:   comm=iperf pid=1284 runtime=113053 [ns] vruntime=2106997666 [ns]
>>           rcuc/0-11    [000]    90.642464: irq_handler_entry:    irq=355 name=48484000.ethernet
>>           rcuc/0-11    [000]    90.642466: irq_handler_exit:     irq=355 ret=handled
>>           rcuc/0-11    [000]    90.642469: sched_waking:         comm=irq/355-4848400 pid=86 prio=49 target_cpu=001
>>            iperf-1284  [001]    90.642473: sched_switch:         iperf:1284 [120] R ==> irq/354-4848400:85 [49]
>>  irq/354-4848400-85    [001]    90.642481: softirq_raise:        vec=3 [action=NET_RX]
>>           rcuc/0-11    [000]    90.642483: sched_wakeup:         irq/355-4848400:86 [49] success=1 CPU:001
>>  irq/354-4848400-85    [001]    90.642493: softirq_entry:        vec=3 [action=NET_RX]
>>           rcuc/0-11    [000]    90.642497: sched_migrate_task:   comm=irq/355-4848400 pid=86 prio=49 orig_cpu=1 dest_cpu=0
> ach that IRQ thread no pinned. Good. We migrate.
> 

It looks like scheduler playing ping-pong between CPUs with threaded irqs irq/354-355.
And seems this might be the case - if I pin both threaded IRQ handlers to CPU0
I can see better latency and netperf improvement
cyclictest -m -Sp98 -q  -D4m
T: 0 ( 1318) P:98 I:1000 C: 240000 Min:      9 Act:   14 Avg:   15 Max:      42
T: 1 ( 1319) P:98 I:1500 C: 159909 Min:      9 Act:   14 Avg:   16 Max:      39

if I arrange hwirqs  and pin pin both threaded IRQ handlers on CPU1 
I can observe more less similar results as with this patch. 


>>           rcuc/0-11    [000]    90.642515: irq_handler_entry:    irq=354 name=48484000.ethernet
>>           rcuc/0-11    [000]    90.642516: irq_handler_exit:     irq=354 ret=handled

> 
> As you see ksoftirqd left the CPU with a D so I would assume it is
> blocked on a lock and waits. 
> NET_RX is in progress but scheduled out due to RCUC which is also
> scheduled out.
> 
> I assume we got to softirq because nothing else can run. It will see
> that NET_RX is pending and tries it but blocks on the lock
> (lock_softirq()). It schedules out. Nothing left -> idle.
> 
> The idle code checks to see if a softirq is pending and in fact there is
> SCHED on the list and ksoftirq was about to handle it but due to
> ordering complication (NET_RX before SCHED) it can't. And we have the
> warning.
> 
> This 
> 
> --- a/kernel/softirq.c
> +++ b/kernel/softirq.c
> @@ -105,6 +105,7 @@ void softirq_check_pending_idle(void)
>  {
>  	static int rate_limit;
>  	struct softirq_runner *sr = this_cpu_ptr(&softirq_runners);
> +	struct task_struct *ksoft_tsk = __this_cpu_read(ksoftirqd);
>  	u32 warnpending;
>  	int i;
>  
> @@ -112,7 +113,7 @@ void softirq_check_pending_idle(void)
>  		return;
>  
>  	warnpending = local_softirq_pending() & SOFTIRQ_STOP_IDLE_MASK;
> -	for (i = 0; i < NR_SOFTIRQS; i++) {
> +	for (i = 0; (i < NR_SOFTIRQS) && warnpending; i++) {
>  		struct task_struct *tsk = sr->runner[i];
>  
>  		/*
> @@ -132,6 +133,15 @@ void softirq_check_pending_idle(void)
>  		}
>  	}
>  
> +	if (warnpending && ksoft_tsk) {
> +		raw_spin_lock(&ksoft_tsk->pi_lock);
> +		if (ksoft_tsk->pi_blocked_on || ksoft_tsk->state == TASK_RUNNING) {
> +			/* Clear all bits pending in that task */
> +			warnpending &= ~(ksoft_tsk->softirqs_raised);
> +		}
> +		raw_spin_unlock(&ksoft_tsk->pi_lock);
> +	}
> +
>  	if (warnpending) {
>  		printk(KERN_ERR "NOHZ: local_softirq_pending %02x\n",
>  		       warnpending);
> 
> 
> should avoid the warning if the softirq thread is blocked.


with this change i do not see  "NOHZ: local_softirq_pending 80" any more 
Tested-by: Grygorii Strashko <grygorii.strashko@ti.com> 

> 
> However:
> - RCU boosting with RT prio might help here or there.

That I'll try. current settings
CONFIG_RCU_BOOST=y
CONFIG_RCU_KTHREAD_PRIO=1
CONFIG_RCU_BOOST_DELAY=500


> - having the hard-IRQ and IRQ-thread on the same CPU might help, too. It
>   is not strictly required but saves a few cycles if you don't have to
>   perform cross CPU wake ups and migrate task forth and back. The latter
>   happens at prio 99.

I've experimented with this and it improves netperf and I also followed instructions from [1].
But seems messed ti pin threaded irqs to cpu.
[1] https://www.osadl.org/Real-time-Ethernet-UDP-worst-case-roun.qa-farm-rt-ethernet-udp-monitor.0.html

> - I am not sure NAPI works as expected. I would assume so. There is IRQ
>   354 and 355 which fire after each other. One would be enough I guess.
>   And they seem to be short living / fire often. If NAPI works then it
>   should put an end to it and push it to the softirq thread.
>   If you have IRQ-pacing support I suggest to use something like 10ms or
>   so. That means your ping response will go from <= 1ms to 10ms in the
>   worst case but since you process more packets at a time your
>   throughput should increase.
>   If I count this correct, it too you alsmost 4ms from "raise SCHED" to
>   "try process SCHED" and most of the time was spent in 35[45] hard irq,
>   raise NET_RX or cross wakeup the IRQ thread.

The question I have to dial with is why switching to RT cause so significant
netperf drop (without additional tunning) comparing to vanilla - ~120% for 256K and ~200% for 128K windows?

It's of course expected to see netperf drop, but I assume not so significant :(
And I can't find any reports or statistic related to this. Does the same happen on x86?

Thanks a lot for your comments.

-- 
regards,
-grygorii
