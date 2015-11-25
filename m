From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: net: Generalise wq_has_sleeper helper
Date: Wed, 25 Nov 2015 10:15:33 +0100
Message-ID: <20151125091533.GX17308@twins.programming.kicks-ass.net>
References: <20151023124006.GA17308@twins.programming.kicks-ass.net>
 <20151111094829.GA23202@gondor.apana.org.au>
 <20151124055423.GA31611@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tatsu@ab.jp.nec.com, mingo@redhat.com,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Jiri Olsa <jolsa@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151124055423.GA31611@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 24, 2015 at 01:54:23PM +0800, Herbert Xu wrote:
> diff --git a/include/linux/wait.h b/include/linux/wait.h
> index 1e1bf9f..bd1157f 100644
> --- a/include/linux/wait.h
> +++ b/include/linux/wait.h
> @@ -107,6 +107,50 @@ static inline int waitqueue_active(wait_queue_head_t *q)
>  	return !list_empty(&q->task_list);
>  }
>  
> +/**
> + * wq_has_sleeper - check if there are any waiting processes
> + * @wq: wait queue head
> + *
> + * Returns true if wq has waiting processes
> + *
> + * The purpose of the wq_has_sleeper and sock_poll_wait is to wrap the memory
> + * barrier call. They were added due to the race found within the tcp code.
> + *
> + * Consider following tcp code paths:
> + *
> + * CPU1                  CPU2
> + *
> + * sys_select            receive packet
> + *   ...                 ...
> + *   __add_wait_queue    update tp->rcv_nxt
> + *   ...                 ...
> + *   tp->rcv_nxt check   sock_def_readable
> + *   ...                 {
> + *   schedule               rcu_read_lock();
> + *                          wq = rcu_dereference(sk->sk_wq);
> + *                          if (wq && waitqueue_active(&wq->wait))
> + *                              wake_up_interruptible(&wq->wait)
> + *                          ...
> + *                       }
> + *
> + * The race for tcp fires when the __add_wait_queue changes done by CPU1 stay
> + * in its cache, and so does the tp->rcv_nxt update on CPU2 side.  The CPU1
> + * could then endup calling schedule and sleep forever if there are no more
> + * data on the socket.
> + *

Would be easier to refer to the comment that now adorns
waitqueue_active().

> + */
> +static inline bool wq_has_sleeper(wait_queue_head_t *wq)
> +{
> +	/* We need to be sure we are in sync with the

broken comment style.

> +	 * add_wait_queue modifications to the wait queue.
> +	 *
> +	 * This memory barrier should be paired with one on the
> +	 * waiting side.
> +	 */
> +	smp_mb();
> +	return waitqueue_active(wq);
> +}
> +
>  extern void add_wait_queue(wait_queue_head_t *q, wait_queue_t *wait);
>  extern void add_wait_queue_exclusive(wait_queue_head_t *q, wait_queue_t *wait);
>  extern void remove_wait_queue(wait_queue_head_t *q, wait_queue_t *wait);
