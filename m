From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH][RT] netpoll: Always take poll_lock when doing polling
Date: Tue, 7 Jun 2016 11:46:42 +0200
Message-ID: <20160607094642.GA4089@linutronix.de>
References: <20160526195641.6c26e979@gandalf.local.home>
 <20160602161235.GA12971@linutronix.de>
 <20160604071131.08d449db@grimm.local.home>
 <CAOuSAjfXsLQWkrcE7Y3t-k0Bv5qieqgziu8Zf-au4SK-rLvRHQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Steven Rostedt <rostedt@goodmis.org>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-rt-users <linux-rt-users@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Peter Zijlstra <peterz@infradead.org>,
	Clark Williams <williams@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
To: Alison Chaiken <alison@peloton-tech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:37832 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754438AbcFGJqr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 05:46:47 -0400
Content-Disposition: inline
In-Reply-To: <CAOuSAjfXsLQWkrcE7Y3t-k0Bv5qieqgziu8Zf-au4SK-rLvRHQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Alison Chaiken | 2016-06-05 08:16:58 [-0700]:

>I did try that patch, but it hasn't made much difference.   Let me
>back up and restate the problem I'm trying to solve, which is that a
>DRA7X OMAP5 SOC system running a patched 4.1.18-ti-rt kernel has a
>main event loop in user space that misses latency deadlines under the
>test condition where I ping-flood it from another box.   While in
>production, the system would not be expected to support high rates of
>network traffic, but the instability with the ping-flood makes me
>wonder if there aren't underlying configuration problems.
>
>We've applied Sebastian's commit "softirq: split timer softirqs out of
>ksoftirqd," which improved event loop stability substantially when we

Why did you apply that one? You have 4.1.18-ti-rt so I don't know how
that works but v4.1.15-rt18 had this patch included. Also "net: provide
a way to delegate processing a softirq to ksoftirqd" should be applied
(which is also part of v4.1.15-rt18).

>left ksoftirqd running at userspace default but elevated ktimersoftd.
> That made me think that focusing on the softirqs was pertinent.

Before that explicit "delegation" to ksoftirq within NAPI it was likely
that the NAPI callback was never interrupted and continued on the "next"
softirq.

>priority) starts having problems, I see that the hard IRQ associated
>with the ethernet device uses about 35% of one core, which seems
>awfully high if the NAPI has triggered a switch to polling.  I vaguely

Try the patch above, it is likely your NAPI was never interrupted.

>recall David Miller saying in the "threadable napi poll loop"
>discussion that accounting was broken for net IRQs, so perhaps that
>number is misleading.   mpstat shows that the NET_RX softirqs run on
>the same core where we've pinned the ethernet IRQ, so you might hope
>that userspace might be able to run happily on the other one.
>
>What I see in ftrace while watching scheduler and IRQ events is that
>the userspace application is yielding to ethernet or CAN IRQs, which
>also raise NET_RX.    In the following,  ping-flood is running, and
>irq/343 is the ethernet one:
>
> userspace_application-4767  [000] dn.h1..  4196.422318: irq_handler_entry: irq=347 name=can1
> userspace_application-4767  [000] dn.h1..  4196.422319: irq_handler_exit: irq=347 ret=handled
> userspace_application-4767  [000] dn.h2..  4196.422321: sched_waking: comm=irq/347-can1 pid=2053 prio=28 target_cpu=000
> irq/343-4848400-874   [001] ....112  4196.422323: softirq_entry: vec=3 [action=NET_RX]
> userspace_application-4767  [000] dn.h3..  4196.422325: sched_wakeup: comm=irq/347-can1 pid=2053 prio=28 target_cpu=000
> irq/343-4848400-874   [001] ....112  4196.422328: napi_poll: napi poll on napi struct edd5f560 for device eth0
> irq/343-4848400-874   [001] ....112  4196.422329: softirq_exit: vec=3 [action=NET_RX]
> userspace_application-4767  [000] dn..3..  4196.422332: sched_stat_runtime: comm=userspace_application pid=4767 runtime=22448 [ns] vruntime=338486919642 [ns]
> userspace_application-4767  [000] d...3..  4196.422336: sched_switch: prev_comm=userspace_application prev_pid=4767 prev_prio=120 prev_state=R ==> next_comm=irq/347-can1 next_pid=2053 next_prio=28
> irq/343-4848400-874   [001] d...3..  4196.422339: sched_switch: prev_comm=irq/343-4848400 prev_pid=874 prev_prio=47 prev_state=S ==> next_comm=irq/344-4848400 next_pid=875 next_prio=47

What I remember from testing the two patches on am335x was that before a
ping flood on gbit froze the serial console but with them it the ping
flood was not noticed.

>Thanks again for the patches,
>Alison Chaiken
>Peloton Technology

Sebastian
