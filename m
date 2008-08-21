From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Thu, 21 Aug 2008 22:40:53 +0200
Message-ID: <20080821204052.GB2665@ami.dom.local>
References: <20080821124834.GA8794@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	denys@visp.net.lb
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:45565 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752629AbYHUUjp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 16:39:45 -0400
Received: by nf-out-0910.google.com with SMTP id d3so65551nfc.21
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 13:39:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080821124834.GA8794@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote, On 08/21/2008 02:48 PM:

> On Thu, Aug 21, 2008 at 10:35:38PM +1000, Herbert Xu wrote:
>> You're right, this doesn't work at all.  In fact it's been broken
>> even before we removed the root lock.  The problem is that we used
>> to have one big linked list for each device.  That was protected
>> by the device qdisc lock.  Now we have one list for each txq and
>> qdisc_lookup walks every single txq.  This means that no single
>> qdisc root lock can protect this anymore.

As I wrote earlier, I don't think it's like this at least with the
current implementation, an this fix seems to be temporary.

> How about going back to a single list per-device again? This list
> is only used on the slow path (well anything that tries to walk
> a potentially unbounded linked list is slow :), and qdisc_lookup
> walks through everything anyway.
> 
> We'll need to then add a new lock to protect this list, until we
> remove requeue.
> 
> Actually just doing the locking will be sufficient.  Something like
> this totally untested patch (I've abused your tx global lock):

If it's really needed, then OK with me, but tx_global_lock doesn't
look like the best choice, considering it can be used here with
qdisc root lock, and this comment from sch_generic:

" *  qdisc_lock(q) and netif_tx_lock are mutually exclusive,
  *  if one is grabbed, another must be free."

IMHO, since it's probably not for something very busy, we can even
create a global lock to avoid dependancies or maybe to use this
qdisc_stab_lock (after changing spin_locks to _bh) which is BTW
used in qdisc_destroy() already.

Thanks,
Jarek P.

> 
> diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
> index ef0efec..3f5f9b9 100644
> --- a/net/sched/sch_api.c
> +++ b/net/sched/sch_api.c
> @@ -202,16 +202,25 @@ struct Qdisc *qdisc_match_from_root(struct Qdisc *root, u32 handle)
>  struct Qdisc *qdisc_lookup(struct net_device *dev, u32 handle)
>  {
>  	unsigned int i;
> +	struct Qdisc *q;
> +
> +	spin_lock_bh(&dev->tx_global_lock);
>  
>  	for (i = 0; i < dev->num_tx_queues; i++) {
>  		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
> -		struct Qdisc *q, *txq_root = txq->qdisc_sleeping;
> +		struct Qdisc *txq_root = txq->qdisc_sleeping;
>  
>  		q = qdisc_match_from_root(txq_root, handle);
>  		if (q)
> -			return q;
> +			goto unlock;
>  	}
> -	return qdisc_match_from_root(dev->rx_queue.qdisc_sleeping, handle);
> +
> +	q = qdisc_match_from_root(dev->rx_queue.qdisc_sleeping, handle);
> +
> +unlock:
> +	spin_unlock_bh(&dev->tx_global_lock);
> +
> +	return q;
>  }
>  
>  static struct Qdisc *qdisc_leaf(struct Qdisc *p, u32 classid)
> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> index c3ed4d4..292a373 100644
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -526,8 +526,10 @@ void qdisc_destroy(struct Qdisc *qdisc)
>  	    !atomic_dec_and_test(&qdisc->refcnt))
>  		return;
>  
> +	spin_lock_bh(&dev->tx_global_lock);
>  	if (qdisc->parent)
>  		list_del(&qdisc->list);
> +	spin_unlock_bh(&dev->tx_global_lock);
>  
>  #ifdef CONFIG_NET_SCHED
>  	qdisc_put_stab(qdisc->stab);
> 
> Cheers,
