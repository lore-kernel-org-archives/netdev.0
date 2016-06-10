From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH][RT] netpoll: Always take poll_lock when doing polling
Date: Fri, 10 Jun 2016 09:28:53 -0700
Message-ID: <1465576133.7945.65.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160526195641.6c26e979@gandalf.local.home>
	 <20160610153051.GA10775@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Steven Rostedt <rostedt@goodmis.org>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-rt-users <linux-rt-users@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Peter Zijlstra <peterz@infradead.org>,
	Clark Williams <williams@redhat.com>,
	David Miller <davem@davemloft.net>, alison@peloton-tech.com
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160610153051.GA10775@linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-06-10 at 17:30 +0200, Sebastian Andrzej Siewior wrote:
> * Steven Rostedt | 2016-05-26 19:56:41 [-0400]:
> 
> >For example:
> >
> >   <interrupt thread (as all interrupts on RT are threaded>
> >
> >   napi_schedule_prep()
> >        test_and_set_bit(NAPI_STATE_SCHED, &n->state)
> >
> >   <preempted by higher prio task that runs softirqs in its context>
> >
> >   sk_busy_loop()
> >
> >      do {
> >           rc = busy_poll()
> >               ret = napi_schedule_prep()
> >                    return !test_and_set_bit(NAPI_STATE_SCHED, &n->state)
> >                     <returns zero because NAPI_STATE_SCHED is set>
> >               if (!ret) return 0
> >           <rc is zero>
> >      } while (...) /* for ever */
> >
> 
> No, I don't see the busyloop. while() is here:
> |    while (!nonblock && skb_queue_empty(&sk->sk_receive_queue) &&
> |                  !need_resched() && !busy_loop_timeout(end_time));
> 
> and this seems to be the case since v3.11 where it was introduced (but
> now it moved to dev.c). So even if there is no busy_poll() and
> napi_schedule_prep() returns 0 our cycles here are limited by
> busy_loop_timeout().

Well, before linux-4.5 and commit 2a028ecb76497d ("net: allow BH
servicing in sk_busy_loop()") , sk_busy_loop() was completely blocking
BH.

Not sure it matters in your case.
