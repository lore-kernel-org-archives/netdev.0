From: Alison Chaiken <alison@peloton-tech.com>
Subject: Re: [PATCH][RT] netpoll: Always take poll_lock when doing polling
Date: Sun, 5 Jun 2016 08:16:58 -0700
Message-ID: <CAOuSAjfXsLQWkrcE7Y3t-k0Bv5qieqgziu8Zf-au4SK-rLvRHQ@mail.gmail.com>
References: <20160526195641.6c26e979@gandalf.local.home> <20160602161235.GA12971@linutronix.de>
 <20160604071131.08d449db@grimm.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-rt-users <linux-rt-users@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Peter Zijlstra <peterz@infradead.org>,
	Clark Williams <williams@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160604071131.08d449db@grimm.local.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Steven Rostedt suggests in reference to "[PATCH][RT] netpoll: Always
take poll_lock when doing polling"
>> [ Alison, can you try this patch ]

Sebastian follows up:
>Alison, did you try it?

Sorry for not responding sooner.   I was hoping to come to a complete
understanding of the system before replying . . .

I did try that patch, but it hasn't made much difference.   Let me
back up and restate the problem I'm trying to solve, which is that a
DRA7X OMAP5 SOC system running a patched 4.1.18-ti-rt kernel has a
main event loop in user space that misses latency deadlines under the
test condition where I ping-flood it from another box.   While in
production, the system would not be expected to support high rates of
network traffic, but the instability with the ping-flood makes me
wonder if there aren't underlying configuration problems.

We've applied Sebastian's commit "softirq: split timer softirqs out of
ksoftirqd," which improved event loop stability substantially when we
left ksoftirqd running at userspace default but elevated ktimersoftd.
 That made me think that focusing on the softirqs was pertinent.

Subsequently, I've tried "[PATCH][RT] netpoll: Always take poll_lock
when doing polling" (which seems like a good idea in any event).
After reading the "net: threadable napi poll loop discussion"
(https://lkml.org/lkml/2016/5/10/472), and
https://lkml.org/lkml/2016/2/27/152, I tried reverting

commit c10d73671ad30f54692f7f69f0e09e75d3a8926a
   Author: Eric Dumazet <edumazet@google.com>
   Date:   Thu Jan 10 15:26:34 2013 -0800
       softirq: reduce latencies

but that didn't help.   When the userspace application (running at -3
priority) starts having problems, I see that the hard IRQ associated
with the ethernet device uses about 35% of one core, which seems
awfully high if the NAPI has triggered a switch to polling.  I vaguely
recall David Miller saying in the "threadable napi poll loop"
discussion that accounting was broken for net IRQs, so perhaps that
number is misleading.   mpstat shows that the NET_RX softirqs run on
the same core where we've pinned the ethernet IRQ, so you might hope
that userspace might be able to run happily on the other one.

What I see in ftrace while watching scheduler and IRQ events is that
the userspace application is yielding to ethernet or CAN IRQs, which
also raise NET_RX.    In the following,  ping-flood is running, and
irq/343 is the ethernet one:

 userspace_application-4767  [000] dn.h1..  4196.422318:
irq_handler_entry: irq=347 name=can1
 userspace_application-4767  [000] dn.h1..  4196.422319:
irq_handler_exit: irq=347 ret=handled
 userspace_application-4767  [000] dn.h2..  4196.422321: sched_waking:
comm=irq/347-can1 pid=2053 prio=28 target_cpu=000
 irq/343-4848400-874   [001] ....112  4196.422323: softirq_entry:
vec=3 [action=NET_RX]
 userspace_application-4767  [000] dn.h3..  4196.422325: sched_wakeup:
comm=irq/347-can1 pid=2053 prio=28 target_cpu=000
 irq/343-4848400-874   [001] ....112  4196.422328: napi_poll: napi
poll on napi struct edd5f560 for device eth0
 irq/343-4848400-874   [001] ....112  4196.422329: softirq_exit: vec=3
[action=NET_RX]
 userspace_application-4767  [000] dn..3..  4196.422332:
sched_stat_runtime: comm=userspace_application pid=4767 runtime=22448
[ns] vruntime=338486919642 [ns]
 userspace_application-4767  [000] d...3..  4196.422336: sched_switch:
prev_comm=userspace_application prev_pid=4767 prev_prio=120
prev_state=R ==> next_comm=irq/347-can1 next_pid=2053 next_prio=28
 irq/343-4848400-874   [001] d...3..  4196.422339: sched_switch:
prev_comm=irq/343-4848400 prev_pid=874 prev_prio=47 prev_state=S ==>
next_comm=irq/344-4848400 next_pid=875 next_prio=47

You can see why the application is having problems: it is constantly
interrupted by eth and CAN IRQs.   Given that CAN traffic is critical
for our application, perhaps we will simply have to reduce the eth
hard IRQ priority in order to make the system more robust?     It
would be great to offload the network traffic-handling to the Cortex-M
processor on the DRA7, but I fear that the development schedule will
not allow for that option.

I still am not sure how to tell if the NAPI switch from
interrupt-driven to polling is properly taking place.      Any
suggestion on how best to monitor that behavior with overly loading
the system would be appreciated.

Thanks again for the patches,
Alison Chaiken
Peloton Technology
