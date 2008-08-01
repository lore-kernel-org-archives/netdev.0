From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Kernel WARNING: at net/core/dev.c:1330
	__netif_schedule+0x2c/0x98()
Date: Fri, 1 Aug 2008 06:48:10 +0000
Message-ID: <20080801064810.GA4435@ff.dom.local>
References: <20080726131838.GA2873@ami.dom.local> <20080726.173434.48036095.davem@davemloft.net> <20080727203757.GA2527@ami.dom.local> <20080731.052932.110299354.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johannes@sipsolutions.net, netdev@axxeo.de, peterz@infradead.org,
	Larry.Finger@lwfinger.net, kaber@trash.net,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-wireless@vger.kernel.org, mingo@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:65247 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752450AbYHAGmy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2008 02:42:54 -0400
Received: by nf-out-0910.google.com with SMTP id d3so377095nfc.21
        for <netdev@vger.kernel.org>; Thu, 31 Jul 2008 23:42:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080731.052932.110299354.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 31, 2008 at 05:29:32AM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Sun, 27 Jul 2008 22:37:57 +0200
> 
> > Looks like enough to me. (Probably it could even share space with
> > the state.)

Alas I've some doubts here...

...
>  static inline void netif_tx_unlock(struct net_device *dev)
>  {
>  	unsigned int i;
>  
>  	for (i = 0; i < dev->num_tx_queues; i++) {
>  		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
> -		__netif_tx_unlock(txq);
> -	}
>  
> +		/* No need to grab the _xmit_lock here.  If the
> +		 * queue is not stopped for another reason, we
> +		 * force a schedule.
> +		 */
> +		clear_bit(__QUEUE_STATE_FROZEN, &txq->state);

The comments in asm-x86/bitops.h to set_bit/clear_bit are rather queer
about reordering on non x86: isn't eg. smp_mb_before_clear_bit()
useful  here?

> +		if (!test_bit(__QUEUE_STATE_XOFF, &txq->state))
> +			__netif_schedule(txq->qdisc);
> +	}
> +	spin_unlock(&dev->tx_global_lock);
>  }
...

> diff --git a/net/core/dev.c b/net/core/dev.c
> index 63d6bcd..69320a5 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4200,6 +4200,7 @@ static void netdev_init_queues(struct net_device *dev)
>  {
>  	netdev_init_one_queue(dev, &dev->rx_queue, NULL);
>  	netdev_for_each_tx_queue(dev, netdev_init_one_queue, NULL);
> +	spin_lock_init(&dev->tx_global_lock);

This will probably need some lockdep annotations similar to
_xmit_lock.

> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> index 345838a..9c9cd4d 100644
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -135,7 +135,8 @@ static inline int qdisc_restart(struct Qdisc *q)
>  	txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
>  
>  	HARD_TX_LOCK(dev, txq, smp_processor_id());
> -	if (!netif_subqueue_stopped(dev, skb))
> +	if (!netif_tx_queue_stopped(txq) &&
> +	    !netif_tx_queue_frozen(txq))
>  		ret = dev_hard_start_xmit(skb, dev, txq);
>  	HARD_TX_UNLOCK(dev, txq);

This thing is the most doubtful to me: before this patch callers would
wait on this lock. Now they take the lock without problems, check the
flags, and let to take this lock again, doing some re-queing in the
meantime.

So, it seems HARD_TX_LOCK should rather do some busy looping now with
a trylock, and re-checking the _FROZEN flag. Maybe even this should
be done in __netif_tx_lock(). On the other hand, this shouldn't block
too much the owner of tx_global_lock() with taking such a lock.

Jarek P.
