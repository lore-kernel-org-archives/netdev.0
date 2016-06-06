From: Alison Chaiken <alison@peloton-tech.com>
Subject: Re: [PATCH][RT] netpoll: Always take poll_lock when doing polling
Date: Mon, 6 Jun 2016 16:25:37 -0700
Message-ID: <CAOuSAjecGSjA1hHWLApn_PL0kJ-P1zTE0wKAQwCQx0mDj63EYQ@mail.gmail.com>
References: <20160526195641.6c26e979@gandalf.local.home> <20160602161235.GA12971@linutronix.de>
 <20160604071131.08d449db@grimm.local.home> <CAOuSAjfXsLQWkrcE7Y3t-k0Bv5qieqgziu8Zf-au4SK-rLvRHQ@mail.gmail.com>
 <20160606070322.39ac701e@sluggy.hsv.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Steven Rostedt <rostedt@goodmis.org>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-rt-users <linux-rt-users@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Peter Zijlstra <peterz@infradead.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
To: Clark Williams <williams@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160606070322.39ac701e@sluggy.hsv.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Steven Rostedt suggests in reference to "[PATCH][RT] netpoll: Always
take poll_lock when doing polling"
>> >> [ Alison, can you try this patch ]
>>
 Sebastian follows up:
>> >Alison, did you try it?

I wrote:
>> I did try that patch, but it hasn't made much difference.   Let me
>> back up and restate the problem I'm trying to solve, which is that a
>> DRA7X OMAP5 SOC system running a patched 4.1.18-ti-rt kernel has a
>> main event loop in user space that misses latency deadlines under the
>> test condition where I ping-flood it from another box.   While in
>> production, the system would not be expected to support high rates of
>> network traffic, but the instability with the ping-flood makes me
>> wonder if there aren't underlying configuration problems.

Clark asked:
> What sort of tunings have you applied, regarding thread and interrupt affinity?
> Also, what scheduler policy/priority are you using for the user-space application?

We have the most critical hard IRQs (CAN, UART) pinned to one core,
scheduled with FIFO, and running at highest RT priority.  The less
critical IRQs (ethernet, MMC, DMA) are pinned to the other core and
are running at lower FIFO priority.   Next in FIFO priority we have
the ktimersoftd threads.   Then  we have our critical userspace
application running under RR with slightly lower priority and no
pinning.

When there is not much network traffic, the userspace event_loop makes
its deadlines, but when there is a lot of network traffic, the two
network hard IRQs shoot to the top of the process table, with one of
them using about 80% of one core.   This behavior persists whether the
kernel includes "net: provide a way to delegate processing a softirq
to ksoftirqd", "softirq: Perform softirqs in local_bh_enable() for a
limited amount of time", or reverts c10d73671 "softirq: reduce
latencies".

It's hard to see how a *hard* IRQ could take so much processor time.
I guess this gets back to
http://article.gmane.org/gmane.linux.kernel/2219110:
From: Rik van Riel <>
Subject: Re: [RFC PATCH 0/2] net: threadable napi poll loop
I need to get back to fixing irq & softirq time accounting,
which does not currently work correctly in all time keeping
modes...

So most likely the softirq budget is getting charged to the hard IRQ
that raises it.

>If you have not, you might try isolating one of your cores and just run the user-space application on that core, with interrupt threads running on the other core. You could use the 'tuna' application like this:
>         $ sudo tuna --cpus=1 --isolate
> This will move all the threads that *can* be moved off of cpu1 (probably to cpu0 since I believe the OMAP5 is a dual-core processor?).

Thanks, I installed tuna and gave that a try, but it actually makes
things worse.   I also tried lowering the priority of the ethernet
hard IRQ below that of the most critical userspace application, to no
avail.

Perhaps expecting an RT system to survive a ping-flood is just
unreasonable?   It would be nice to deliver a system that I didn't
know how to bring down.   At least in our real use case, the critical
system will be NAT'ed and packets will not be forwarded to it.

Thanks,
Alison
