From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH][RT] netpoll: Always take poll_lock when doing polling
Date: Fri, 10 Jun 2016 17:30:51 +0200
Message-ID: <20160610153051.GA10775@linutronix.de>
References: <20160526195641.6c26e979@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: LKML <linux-kernel@vger.kernel.org>,
	linux-rt-users <linux-rt-users@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Peter Zijlstra <peterz@infradead.org>,
	Clark Williams <williams@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, alison@peloton-tech.com
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160526195641.6c26e979@gandalf.local.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Steven Rostedt | 2016-05-26 19:56:41 [-0400]:

>For example:
>
>   <interrupt thread (as all interrupts on RT are threaded>
>
>   napi_schedule_prep()
>        test_and_set_bit(NAPI_STATE_SCHED, &n->state)
>
>   <preempted by higher prio task that runs softirqs in its context>
>
>   sk_busy_loop()
>
>      do {
>           rc = busy_poll()
>               ret = napi_schedule_prep()
>                    return !test_and_set_bit(NAPI_STATE_SCHED, &n->state)
>                     <returns zero because NAPI_STATE_SCHED is set>
>               if (!ret) return 0
>           <rc is zero>
>      } while (...) /* for ever */
>

No, I don't see the busyloop. while() is here:
|    while (!nonblock && skb_queue_empty(&sk->sk_receive_queue) &&
|                  !need_resched() && !busy_loop_timeout(end_time));

and this seems to be the case since v3.11 where it was introduced (but
now it moved to dev.c). So even if there is no busy_poll() and
napi_schedule_prep() returns 0 our cycles here are limited by
busy_loop_timeout().

Sebastian
