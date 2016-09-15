From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [4.4-RT PATCH RFC/RFT] drivers: net: cpsw: mark rx/tx irq as
 IRQF_NO_THREAD
Date: Thu, 15 Sep 2016 16:39:33 +0200
Message-ID: <20160915143933.25mm53eewkmiqllm@linutronix.de>
References: <20160811161540.9613-1-grygorii.strashko@ti.com>
 <20160812083206.t7lvxpo44marwpf5@linutronix.de>
 <9f811252-82ff-fd24-1006-2b40cd448927@ti.com>
 <20160908160042.lci5xkd37o4rrrg5@linutronix.de>
 <cdfe7655-a3b3-9b38-0231-cf90c2af037b@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Steven Rostedt <rostedt@goodmis.org>, linux-omap@vger.kernel.org,
        Alison Chaiken <alison@peloton-tech.com>,
        linux-rt-users@vger.kernel.org, netdev@vger.kernel.org
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <linux-rt-users-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cdfe7655-a3b3-9b38-0231-cf90c2af037b@ti.com>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016-09-09 15:46:44 [+0300], Grygorii Strashko wrote:
> 
> It looks like scheduler playing ping-pong between CPUs with threaded irqs irq/354-355.
> And seems this might be the case - if I pin both threaded IRQ handlers to CPU0
> I can see better latency and netperf improvement
> cyclictest -m -Sp98 -q  -D4m
> T: 0 ( 1318) P:98 I:1000 C: 240000 Min:      9 Act:   14 Avg:   15 Max:      42
> T: 1 ( 1319) P:98 I:1500 C: 159909 Min:      9 Act:   14 Avg:   16 Max:      39
> 
> if I arrange hwirqs  and pin pin both threaded IRQ handlers on CPU1 
> I can observe more less similar results as with this patch. 

so no patch then.

> with this change i do not see  "NOHZ: local_softirq_pending 80" any more 
> Tested-by: Grygorii Strashko <grygorii.strashko@ti.com> 

okay. So I need to think what I do about this. Either this or trying to
run the "higher" softirq first but this could break things.
Thanks for the confirmation.

> > - having the hard-IRQ and IRQ-thread on the same CPU might help, too. It
> >   is not strictly required but saves a few cycles if you don't have to
> >   perform cross CPU wake ups and migrate task forth and back. The latter
> >   happens at prio 99.
> 
> I've experimented with this and it improves netperf and I also followed instructions from [1].
> But seems messed ti pin threaded irqs to cpu.
> [1] https://www.osadl.org/Real-time-Ethernet-UDP-worst-case-roun.qa-farm-rt-ethernet-udp-monitor.0.html

There is irq_thread() => irq_thread_check_affinity(). It might not work
as expected on ARM but it makes sense to follow the affinity mask HW irq
for the thread.

> > - I am not sure NAPI works as expected. I would assume so. There is IRQ
> >   354 and 355 which fire after each other. One would be enough I guess.
> >   And they seem to be short living / fire often. If NAPI works then it
> >   should put an end to it and push it to the softirq thread.
> >   If you have IRQ-pacing support I suggest to use something like 10ms or
> >   so. That means your ping response will go from <= 1ms to 10ms in the
> >   worst case but since you process more packets at a time your
> >   throughput should increase.
> >   If I count this correct, it too you alsmost 4ms from "raise SCHED" to
> >   "try process SCHED" and most of the time was spent in 35[45] hard irq,
> >   raise NET_RX or cross wakeup the IRQ thread.
> 
> The question I have to dial with is why switching to RT cause so significant
> netperf drop (without additional tunning) comparing to vanilla - ~120% for 256K and ~200% for 128K windows?

You have a sched / thread ping/pong. That is one thing. !RT with
threaded irqs should show similar problems. The higher latency is caused
by the migration thread.

> It's of course expected to see netperf drop, but I assume not so significant :(
> And I can't find any reports or statistic related to this. Does the same happen on x86?

It should. Maybe at a lower level if it handles migration more
effective. There is this watchdog thread (for instance) which tries to
detect lockups and runs at P99. It causes "worse" cyclictest numbers on
x86 and on ARM but on ARM this is more visible than on x86.

Sebastian
