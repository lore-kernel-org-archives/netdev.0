From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Mon, 18 Aug 2008 23:29:46 +0200
Message-ID: <20080818212946.GB3366@ami.dom.local>
References: <20080817.184921.08829673.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:30481 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751977AbYHRV0a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 17:26:30 -0400
Received: by ug-out-1314.google.com with SMTP id c2so294438ugf.37
        for <netdev@vger.kernel.org>; Mon, 18 Aug 2008 14:26:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080817.184921.08829673.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote, On 08/18/2008 03:49 AM:

> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Mon, 18 Aug 2008 11:36:33 +1000
> 
>> On Sun, Aug 17, 2008 at 06:35:05PM -0700, David Miller wrote:
>>> I think I see another way out of this:
>>>
>>> 1) Add __QDISC_STATE_DEACTIVATE.
>>>
>>> 2) Set it right before dev_deactivate() swaps resets the qdisc
>>>    pointer.
>>>
>>> 3) Test it in dev_queue_xmit() et al. once the qdisc root lock is
>>>    acquired, and drop lock and resample ->qdisc if
>>>    __QDISC_STATE_DEACTIVATE is set.

Two little doubts below:

> diff --git a/net/core/dev.c b/net/core/dev.c
> index 600bb23..b88f669 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1341,6 +1341,9 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
>  
>  void __netif_schedule(struct Qdisc *q)
>  {
> +	if (unlikely(test_bit(__QDISC_STATE_DEACTIVATED, &q->state)))
> +		return;
> +

Why I can't see this code in net-2.6? BTW, I guess it should be now
moved to the current __netif_reschedule()? 

>  	if (!test_and_set_bit(__QDISC_STATE_SCHED, &q->state)) {
>  		struct softnet_data *sd;
>  		unsigned long flags;
> @@ -1790,6 +1793,8 @@ gso:
>  	rcu_read_lock_bh();
>  
>  	txq = dev_pick_tx(dev, skb);
> +
> +resample_qdisc:
>  	q = rcu_dereference(txq->qdisc);
>  
>  #ifdef CONFIG_NET_CLS_ACT
> @@ -1800,6 +1805,11 @@ gso:
>  
>  		spin_lock(root_lock);
>  
> +		if (unlikely(test_bit(__QDISC_STATE_DEACTIVATED, &q->state))) {
> +			spin_unlock(root_lock);
> +			goto resample_qdisc;
> +		}
> +

OK, we now have this kfree_skb() with NET_XMIT_DROP here, but how is it
better than qdisc_enque_root() on noop_qdisc? Or how can we have here
anything else under both rcu lock and spin_lock() while this
__QDISC_STATE_DEACTIVATED bit is set?

Jarek P.

>  		rc = qdisc_enqueue_root(skb, q);
>  		qdisc_run(q);
>  
...
