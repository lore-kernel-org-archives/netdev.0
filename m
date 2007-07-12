From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Races in net_rx_action vs netpoll?
Date: Thu, 12 Jul 2007 14:59:49 +0200
Message-ID: <20070712125949.GC1708@ff.dom.local>
References: <200707101244.32753.okir@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Olaf Kirch <okir@lst.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:60568 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756581AbXGLMvG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jul 2007 08:51:06 -0400
Content-Disposition: inline
In-Reply-To: <200707101244.32753.okir@lst.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

I'm really sorry I couldn't write this sooner.
Below are a few of my doubts:


On 10-07-2007 12:44, Olaf Kirch wrote:
> On Tuesday 10 July 2007 00:27, David Miller wrote:
>> I'm happy to entertain this kind of solution, but we really
>> need to first have an interface to change multiple bits
>> at a time in one atomic operation, because by itself this
>> patch doubles the number of atomices we do when starting
>> a NAPI poll.
...
> --- iscsi-2.6.orig/include/linux/netdevice.h
> +++ iscsi-2.6/include/linux/netdevice.h
> @@ -248,6 +248,8 @@ enum netdev_state_t
>  	__LINK_STATE_LINKWATCH_PENDING,
>  	__LINK_STATE_DORMANT,
>  	__LINK_STATE_QDISC_RUNNING,
> +	/* Set by the netpoll NAPI code */
> +	__LINK_STATE_POLL_LIST_FROZEN,
>  };
>  
>  
> @@ -919,6 +921,14 @@ static inline void netif_rx_complete(str
>  {
>  	unsigned long flags;
>  
> +#ifdef CONFIG_NETPOLL
> +	/* Prevent race with netpoll - yes, this is a kludge.
> +	 * But at least it doesn't penalize the non-netpoll
> +	 * code path. */

Alas, this can penalize those who have it enabled (e.g. by distro),
but don't use.

And it looks like _netif_rx_complete should be a better place,
at least considering such cards as: 8139too, skge, sungem and
maybe more (according to 2.6.22).

> +	if (test_bit(__LINK_STATE_POLL_LIST_FROZEN, &dev->state))
> +		return;
> +#endif
> +
>  	local_irq_save(flags);
>  	BUG_ON(!test_bit(__LINK_STATE_RX_SCHED, &dev->state));
>  	list_del(&dev->poll_list);
> Index: iscsi-2.6/net/core/netpoll.c
> ===================================================================
> --- iscsi-2.6.orig/net/core/netpoll.c
> +++ iscsi-2.6/net/core/netpoll.c
> @@ -123,6 +123,13 @@ static void poll_napi(struct netpoll *np
>  	if (test_bit(__LINK_STATE_RX_SCHED, &np->dev->state) &&
>  	    npinfo->poll_owner != smp_processor_id() &&
>  	    spin_trylock(&npinfo->poll_lock)) {
> +		/* When calling dev->poll from poll_napi, we may end up in
> +		 * netif_rx_complete. However, only the CPU to which the
> +		 * device was queued is allowed to remove it from poll_list.
> +		 * Setting POLL_LIST_FROZEN tells netif_rx_complete
> +		 * to leave the NAPI state alone.
> +		 */
> +		set_bit(__LINK_STATE_POLL_LIST_FROZEN, &np->dev->state);
>  		npinfo->rx_flags |= NETPOLL_RX_DROP;

I wonder, why this flag cannot be used for this check?

>  		atomic_inc(&trapped);
>  
> @@ -130,6 +137,7 @@ static void poll_napi(struct netpoll *np
>  
>  		atomic_dec(&trapped);
>  		npinfo->rx_flags &= ~NETPOLL_RX_DROP;
> +		clear_bit(__LINK_STATE_POLL_LIST_FROZEN, &np->dev->state);
>  		spin_unlock(&npinfo->poll_lock);
>  	}
>  }
> 

BTW, I'd be very glad if somebody could hint me what is the main
reason for such troublesome function as poll_napi: if it's about
performance isn't this enough to increase budget for netpoll in
net_rx_action?

Best regards,
Jarek P.
