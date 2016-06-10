From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH][RT] netpoll: Always take poll_lock when doing polling
Date: Fri, 10 Jun 2016 17:57:17 +0200
Message-ID: <20160610155717.GB10775@linutronix.de>
References: <20160526195641.6c26e979@gandalf.local.home>
 <20160602161235.GA12971@linutronix.de>
 <20160604071131.08d449db@grimm.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: alison@peloton-tech.com, LKML <linux-kernel@vger.kernel.org>,
	linux-rt-users <linux-rt-users@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Peter Zijlstra <peterz@infradead.org>,
	Clark Williams <williams@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:36883 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932214AbcFJP5W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 11:57:22 -0400
Content-Disposition: inline
In-Reply-To: <20160604071131.08d449db@grimm.local.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Steven Rostedt | 2016-06-04 07:11:31 [-0400]:

>From: Steven Rostedt <srostedt@redhat.com>
>Date: Tue, 5 Jan 2016 14:53:09 -0500
>Subject: [PATCH] softirq: Perform softirqs in local_bh_enable() for a limited
> amount of time
>
>To prevent starvation of tasks like ksoftirqd, if the task that is
>processing its softirqs takes more than 2 jiffies to do so, and the
>softirqs are constantly being re-added, then defer the processing to
>ksoftirqd.

I'm not sure about this. Alison didn't scream "yes it solves my problem"
and I am not sure what it is.
It is true that in RT we don't have such a limit like in !RT. You would
need to use __raise_softirq_irqoff_ksoft() instead the normal or +
wakeup() since you may have timers pending and those need to go to the
"other" ksoftirqd.
But then I don't see much change. ksoftirqd runs now at SCHED_OTHER so
it will end up on the CPU right away unless there other tasks that need
the CPU. So the scheduler will balance it the same way. The only change
will be that softirqs which are processed in context of any application
for more than two jiffies will be moved to ksoftirqd. This could be a
win.

>Signed-off-by: Steven Rostedt <rosted@goodmis.org>
>Signed-off-by: Luis Claudio R. Goncalves <lgoncalv@redhat.com>

Sebastian
