From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: Multicast packet loss
Date: Tue, 17 Mar 2009 11:11:56 +0100
Message-ID: <1237284716.5189.284.camel@laptop>
References: <49B4B909.7050002@cosmosbay.com>
	 <20090313.145152.121603300.davem@davemloft.net>
	 <49BADE87.40407@cosmosbay.com>
	 <20090313.153851.11725991.davem@davemloft.net>
	 <49BED109.3020504@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kchang@athenacr.com,
	netdev@vger.kernel.org, cl@linux-foundation.org, bmb@athenacr.com
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:58540 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752965AbZCQKMO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 06:12:14 -0400
In-Reply-To: <49BED109.3020504@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-03-16 at 23:22 +0100, Eric Dumazet wrote:

> Here is the last incantation of the patch, that of course should be
> split in two parts and better Changelog for further discussion on lkml.

I read the entire thread up to now, and I still don't really understand
the Changelog, sorry :(

> [PATCH] softirq: Introduce mechanism to defer wakeups
> 
> Some network workloads need to call scheduler too many times. For example,
> each received multicast frame can wakeup many threads. ksoftirqd is then
> not able to drain NIC RX queues in time and we get frame losses and high
> latencies.
> 
> This patch adds an infrastructure to delay work done in
> sock_def_readable() at end of do_softirq(). This needs to
> make available current->softirq_context even if !CONFIG_TRACE_IRQFLAGS

How does that solve the wakeup issue?

> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> ---

> --- a/kernel/softirq.c
> +++ b/kernel/softirq.c
> @@ -158,6 +158,42 @@ void local_bh_enable_ip(unsigned long ip)
>  }
>  EXPORT_SYMBOL(local_bh_enable_ip);
>  
> +
> +#define SOFTIRQ_DELAY_END (struct softirq_delay *)1L
> +static DEFINE_PER_CPU(struct softirq_delay *, softirq_delay_head) = {
> +	SOFTIRQ_DELAY_END
> +};

Why the magic termination value? Can't we NULL terminate the list

> +
> +/*
> + * Caller must disable preemption, and take care of appropriate
> + * locking and refcounting
> + */

Shouldn't we call it __softirq_delay_queue() if the caller needs to
disabled preemption?

Futhermore, don't we always require the caller to take care of lifetime
issues when we queue something?

> +int softirq_delay_queue(struct softirq_delay *sdel)
> +{
> +	if (!sdel->next) {
> +		sdel->next = __get_cpu_var(softirq_delay_head);
> +		__get_cpu_var(softirq_delay_head) = sdel;
> +		return 1;
> +	}
> +	return 0;
> +}
> +
> +/*
> + * Because locking is provided by subsystem, please note
> + * that sdel->func(sdel) is responsible for setting sdel->next to NULL
> + */
> +static void softirq_delay_exec(void)
> +{
> +	struct softirq_delay *sdel;
> +
> +	while ((sdel = __get_cpu_var(softirq_delay_head)) != SOFTIRQ_DELAY_END) {
> +		__get_cpu_var(softirq_delay_head) = sdel->next;
> +		sdel->func(sdel);	/*	sdel->next = NULL;*/
> +		}
> +}

Why can't we write:

  struct softirq_delay *sdel, *next;

  sdel = __get_cpu_var(softirq_delay_head);
  __get_cpu_var(softirq_delay_head) = NULL;

  while (sdel) {
    next = sdel->next;
    sdel->func(sdel);
    sdel = next;
  }

Why does it matter what happens to sdel->next? we've done the callback.

Aah, the crux is in the re-use policy.. that most certainly does deserve
a comment.

How about we make sdel->next point to itself in the init case?

Then we can write:

  while (sdel) {
    next = sdel->next;
    sdel->next = sdel;
    sdel->func(sdel);
    sdel = next;
  }

and have the enqueue bit look like:

int __softirq_delay_queue(struct softirq_delay *sdel)
{
  struct softirq_delay **head;

  if (sdel->next != sdel)
    return 0;

  head = &__get_cpu_var(softirq_delay_head);
  sdel->next = *head;
  *head = sdel;
  return 1;
}
     
> @@ -1691,6 +1694,43 @@ static void sock_def_readable(struct sock *sk, int len)
>  	read_unlock(&sk->sk_callback_lock);
>  }
>  
> +/*
> + * helper function called by softirq_delay_exec(),
> + * if inet_def_readable() queued us.
> + */
> +static void sock_readable_defer(struct softirq_delay *sdel)
> +{
> +	struct sock *sk = container_of(sdel, struct sock, sk_delay);
> +
> +	sdel->next = NULL;
> +	/*
> +	 * At this point, we dont own a lock on socket, only a reference.
> +	 * We must commit above write, or another cpu could miss a wakeup
> +	 */
> +	smp_wmb();

Where's the matching barrier?

> +	sock_def_readable(sk, 0);
> +	sock_put(sk);
> +}
> +
> +/*
> + * Custom version of sock_def_readable()
> + * We want to defer scheduler processing at the end of do_softirq()
> + * Called with socket locked.
> + */
> +void inet_def_readable(struct sock *sk, int len)
> +{
> +	if (running_from_softirq()) {
> +		if (softirq_delay_queue(&sk->sk_delay))
> +			/*
> +			 * If we queued this socket, take a reference on it
> +			 * Caller owns socket lock, so write to sk_delay.next
> +			 * will be committed before unlock.
> +			 */
> +			sock_hold(sk);
> +	} else
> +		sock_def_readable(sk, len);
> +}

OK, so the idea is to handle a bunch of packets and instead of waking N
threads for each packet, only wake them once at the end of the batch?

Sounds like a sensible idea.. 

