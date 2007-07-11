From: David Miller <davem@davemloft.net>
Subject: Re: Races in net_rx_action vs netpoll?
Date: Tue, 10 Jul 2007 22:44:57 -0700 (PDT)
Message-ID: <20070710.224457.95896396.davem@davemloft.net>
References: <200707041416.33732.okir@lst.de>
	<20070709.152746.75758774.davem@davemloft.net>
	<200707101244.32753.okir@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: okir@lst.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42963
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755093AbXGKFof (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 01:44:35 -0400
In-Reply-To: <200707101244.32753.okir@lst.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Olaf Kirch <okir@lst.de>
Date: Tue, 10 Jul 2007 12:44:31 +0200

> On Tuesday 10 July 2007 00:27, David Miller wrote:
> > I'm happy to entertain this kind of solution, but we really
> > need to first have an interface to change multiple bits
> > at a time in one atomic operation, because by itself this
> > patch doubles the number of atomices we do when starting
> > a NAPI poll.
> 
> Understood. How about the patch below? It takes a similar
> approach, but it puts the onus on the netpoll code
> path rather than the general NAPI case.

Definitely looks more palatable.

> @@ -919,6 +921,14 @@ static inline void netif_rx_complete(str
>  {
>  	unsigned long flags;
>  
> +#ifdef CONFIG_NETPOLL
> +	/* Prevent race with netpoll - yes, this is a kludge.
> +	 * But at least it doesn't penalize the non-netpoll
> +	 * code path. */
> +	if (test_bit(__LINK_STATE_POLL_LIST_FROZEN, &dev->state))
> +		return;
> +#endif
> +
>  	local_irq_save(flags);
>  	BUG_ON(!test_bit(__LINK_STATE_RX_SCHED, &dev->state));
>  	list_del(&dev->poll_list);

That new bit can be set in interrupt context can't it?
