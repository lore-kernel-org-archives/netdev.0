From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2] wait: add comment before waitqueue_active noting
 memory barrier is required
Date: Wed, 11 Nov 2015 17:48:29 +0800
Message-ID: <20151111094829.GA23202@gondor.apana.org.au>
References: <20151023124006.GA17308@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tatsu@ab.jp.nec.com, mingo@redhat.com,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Jiri Olsa <jolsa@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151023124006.GA17308@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Peter Zijlstra <peterz@infradead.org> wrote:
>
>> >> Second, on the waiting thread side, the CPU can reorder the load of
>> >> CONDITION to occur during add_wait_queue active, before the entry is
>> >> added to the wait queue.
>> >>      wake_up thread                 waiting thread
>> >>                                       (reordered)
>> >> ------------------------------------------------------------------------
>> >>                                 spin_lock_irqsave(...)      <add_wait_queue>
>> >>                                 if (CONDITION)
>> >> CONDITION = 1;
>> >> if (waitqueue_active(wq))
>> >     wake_up();
>> >>                                 __add_wait_queue(...)       <add_wait_queue>
>> >>                                 spin_unlock_irqrestore(...) <add_wait_queue>
>> >>                                 wait_woken(&wait, ...);
>> >> ------------------------------------------------------------------------
>> > 
>> > This isn't actually a problem IIRC, because wait_woken() will test
>> > WQ_FLAG_WOKEN and not actually sleep.
>> 
>> In the above figure, waitqueue_active(wq) will return 0 (queue is
>> inactive) and skip the whole wake_up() call, because __add_wait_queue()
>> hasn't been called yet.  This actually does occur using a reproducer.
> 
> Duh, indeed.

BTW, the networking folks found this years ago and even added
helpers to deal with this.  See for example wq_has_sleeper in
include/net/sock.h.  It would be good if we can move some of
those helpers into wait.h instead.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
