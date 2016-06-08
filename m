From: Alison Chaiken <alison@peloton-tech.com>
Subject: Re: [PATCH][RT] netpoll: Always take poll_lock when doing polling
Date: Tue, 7 Jun 2016 17:19:43 -0700
Message-ID: <CAOuSAjeUX_tvzr9K8B4T-TdXUDcYqFxbtYTa=ke-ePhMJo5NVQ@mail.gmail.com>
References: <20160526195641.6c26e979@gandalf.local.home> <20160602161235.GA12971@linutronix.de>
 <20160604071131.08d449db@grimm.local.home> <CAOuSAjfXsLQWkrcE7Y3t-k0Bv5qieqgziu8Zf-au4SK-rLvRHQ@mail.gmail.com>
 <20160607094642.GA4089@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Steven Rostedt <rostedt@goodmis.org>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-rt-users <linux-rt-users@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Peter Zijlstra <peterz@infradead.org>,
	Clark Williams <williams@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:37665 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751399AbcFHATq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 20:19:46 -0400
Received: by mail-wm0-f44.google.com with SMTP id k204so90035667wmk.0
        for <netdev@vger.kernel.org>; Tue, 07 Jun 2016 17:19:45 -0700 (PDT)
In-Reply-To: <20160607094642.GA4089@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I wrote:
>>We've applied Sebastian's commit "softirq: split timer softirqs out of
>>ksoftirqd," which improved event loop stability substantially when we

Sebastian Andrzej Siewior <bigeasy@linutronix.de>replied:
>Why did you apply that one? You have 4.1.18-ti-rt so I don't know how
>that works but v4.1.15-rt18 had this patch included. Also "net: provide
>a way to delegate processing a softirq to ksoftirqd" should be applied
>(which is also part of v4.1.15-rt18).

Sorry to be obscure; I had applied that patch to v4.1.6-rt5.

> What I remember from testing the two patches on am335x was that before a
> ping flood on gbit froze the serial console but with them it the ping
> flood was not noticed.

I compiled a kernel from upstream d060a36 "Merge branch
'ti-linux-4.1.y' of git.ti.com:ti-linux-kernel/ti-linux-kernel into
ti-rt-linux-4.1.y" which is unpatched except for using a
board-appropriate device-tree.    The serial console is responsive
with all our RT userspace applications running alongside a rapid
external ping.   However, our main event loop misses frequently as
soon as ping faster than 'ping -i 0.0002' is run.    mpstat shows that
the sum of the hard IRQ rates in a second is equal precisely to the
NET_RX rate, which is ~3400/s.   Does the fact that 3400 < (1/0.0002)
already mean that some packets are dropped?   ftrace shows that
cpsw_rx_poll() is called even when there is essentially no network
traffic, so I'm not sure how to tell if NAPI is working as intended.

I tried running the wakeup_rt tracer, but it loads the system too
much.     With ftrace capturing IRQ, scheduler and net events, we're
writing out markers into the trace buffer when the event loop makes
its deadline and then when it misses so that we can compare the normal
and long-latency intervals, but there doesn't appear to be a smoking
gun in the difference between the two.

Thanks for all your help,
Alison
