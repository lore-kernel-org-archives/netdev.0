From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH][RT] netpoll: Always take poll_lock when doing polling
Date: Thu, 9 Jun 2016 14:37:33 +0200
Message-ID: <20160609123733.GB6305@linutronix.de>
References: <20160526195641.6c26e979@gandalf.local.home>
 <20160602161235.GA12971@linutronix.de>
 <20160604071131.08d449db@grimm.local.home>
 <CAOuSAjfXsLQWkrcE7Y3t-k0Bv5qieqgziu8Zf-au4SK-rLvRHQ@mail.gmail.com>
 <20160607094642.GA4089@linutronix.de>
 <CAOuSAjeUX_tvzr9K8B4T-TdXUDcYqFxbtYTa=ke-ePhMJo5NVQ@mail.gmail.com>
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
Return-path: <linux-rt-users-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAOuSAjeUX_tvzr9K8B4T-TdXUDcYqFxbtYTa=ke-ePhMJo5NVQ@mail.gmail.com>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Alison Chaiken | 2016-06-07 17:19:43 [-0700]:

>Sorry to be obscure; I had applied that patch to v4.1.6-rt5.

Using the latest is often not a bad choice compared to the random tree
you have here.

>> What I remember from testing the two patches on am335x was that before a
>> ping flood on gbit froze the serial console but with them it the ping
>> flood was not noticed.
>
>I compiled a kernel from upstream d060a36 "Merge branch
>'ti-linux-4.1.y' of git.ti.com:ti-linux-kernel/ti-linux-kernel into
>ti-rt-linux-4.1.y" which is unpatched except for using a
>board-appropriate device-tree.    The serial console is responsive
>with all our RT userspace applications running alongside a rapid
>external ping.   However, our main event loop misses frequently as
>soon as ping faster than 'ping -i 0.0002' is run.    mpstat shows that
>the sum of the hard IRQ rates in a second is equal precisely to the
>NET_RX rate, which is ~3400/s.   Does the fact that 3400 < (1/0.0002)
>already mean that some packets are dropped?   ftrace shows that

Not necessarily. The ping command reports how many packets were
received. It is possible that the sender was not able to send that many
packates _or_ the received was able to process more packets during a
single interrupt.

>cpsw_rx_poll() is called even when there is essentially no network
>traffic, so I'm not sure how to tell if NAPI is working as intended.

You should see an invocation of __raise_softirq_irqoff_ksoft() and then
cpsw's poll function should run in "ksoftirqd/" context instead in the
context of the task it runs now.

>I tried running the wakeup_rt tracer, but it loads the system too
>much.     With ftrace capturing IRQ, scheduler and net events, we're
>writing out markers into the trace buffer when the event loop makes
>its deadline and then when it misses so that we can compare the normal
>and long-latency intervals, but there doesn't appear to be a smoking
>gun in the difference between the two.

You would need to figure out what adds the latency. My understanding is
that your RT application is doing CAN traffic and is not meeting the
deadline. So you drop CAN packets in the end?

>Thanks for all your help,
>Alison

Sebastian
