From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC,PATCH] mutex: mutex_is_owner() helper
Date: Mon, 09 Nov 2009 19:56:27 +0100
Message-ID: <1257792987.4108.364.camel@laptop>
References: <4AF19D06.3060401@gmail.com> <20091104154015.GA32567@elte.hu>
	 <4AF1B7A7.6030902@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux kernel <linux-kernel@vger.kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753127AbZKIS44@vger.kernel.org>
In-Reply-To: <4AF1B7A7.6030902@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2009-11-04 at 18:19 +0100, Eric Dumazet wrote:
> 
> BTW, I was thinking of a mutex_yield() implementation, but could not
> cook it without hard thinking, maybe you already have some nice
> implementation ?

Why? Yield sets off alarm bells, since 99.9%, and possibly more, of its
uses are wrong.

> int mutex_yield(struct mutex *lock)
> {
>         int ret = 0;
> 
>         if (mutex_needbreak(lock) || should_resched()) {
>                 mutex_unlock(lock); 
>                 __cond_resched();
>                 mutex_lock(lock);
>                 ret = 1;
>         }
>         return ret;
> } 

That reads like it should be called cond_resched_mutex(), except that
the should_resched() thing seems daft (but maybe it makes sense for
silly preemption modes like voluntary).

iirc we actually have something similar in -rt in order to implement the
lock-break for the rt-mutex based spinlocks, we set ->needbreak when a
higher priority task contends -- a policy for regular mutexes might be
'interesting' though.

As to your 'debug' helper that started this thread, doesn't
lockdep_assert_held() work for you?
