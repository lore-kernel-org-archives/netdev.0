From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH] net: fix race in the receive/select
Date: Fri, 26 Jun 2009 10:50:28 +0900
Message-ID: <4A442964.2010406@gmail.com>
References: <20090625122545.GA3625@jolsa.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	oleg@redhat.com, eric.dumazet@gmail.com
To: Jiri Olsa <jolsa@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753574AbZFZBul@vger.kernel.org>
In-Reply-To: <20090625122545.GA3625@jolsa.lab.eng.brq.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Jiri Olsa wrote:
> Adding memory barrier to the __pollwait function paired with 
> receive callbacks.  The smp_mb__after_lock define is added, 
> since {read|write|spin}_lock() on x86 are full memory barriers.
> 
> The race fires, when following code paths meet, and the tp->rcv_nxt and
> __add_wait_queue updates stay in CPU caches.
> 
> 
> CPU1                         CPU2
> 
> sys_select                   receive packet
>   ...                        ...
>   __add_wait_queue           update tp->rcv_nxt
>   ...                        ...
>   tp->rcv_nxt check          sock_def_readable
>   ...                        {
>   schedule                      ...
>                                 if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
>                                         wake_up_interruptible(sk->sk_sleep)
>                                 ...
>                              }
> 
> If there was no cache the code would work ok, since the wait_queue and
> rcv_nxt are opposit to each other.
> 
> Meaning that once tp->rcv_nxt is updated by CPU2, the CPU1 either already
> passed the tp->rcv_nxt check and sleeps, or will get the new value for
> tp->rcv_nxt and will return with new data mask.  
> In both cases the process (CPU1) is being added to the wait queue, so the
> waitqueue_active (CPU2) call cannot miss and will wake up CPU1.
> 
> The bad case is when the __add_wait_queue changes done by CPU1 stay in its
> cache, and so does the tp->rcv_nxt update on CPU2 side.  The CPU1 will then
> endup calling schedule and sleep forever if there are no more data on the
> socket.

So, the problem is the half barrier semantics of spin_lock on CPU1's
side and lack of any barrier (read for tp->rcv_nxt check can creep
above the queuelist update) in waitqueue_active() check on CPU2's side
(read for waitqueue list can creep above tcv_nxt update).  Am I
understanding it right?

This is a little bit scary.  The interface kind of suggests that they
have strong enough barrier semantics (well, I would assume that).  I
wonder whether there are more more places where this kind of race
condition exists.

> @@ -219,6 +219,10 @@ static void __pollwait(struct file *filp, wait_queue_head_t *wait_address,
>  	init_waitqueue_func_entry(&entry->wait, pollwake);
>  	entry->wait.private = pwq;
>  	add_wait_queue(wait_address, &entry->wait);
> +
> +	/* This memory barrier is paired with the smp_mb__after_lock
> +	 * in the sk_has_sleeper. */
> +	smp_mb();

I'm not entirely sure this is the correct place to do it while the mb
for the other side lives in network code.  Wouldn't it be better to
move this memory barrier to network select code?  It's strange for an
API to have only single side of a barrier pair and leave the other to
the API user.

Also, maybe we need smp_mb__after_unlock() too?  Maybe
add_wait_queue_mb() possibly paired with wait_queue_active_mb() is
better?  On x86, it wouldn't make any difference tho.

One more thing, can you please use fully winged style for multiline
comments?

Thanks.

-- 
tejun
