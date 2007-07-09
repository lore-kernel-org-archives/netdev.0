From: David Miller <davem@davemloft.net>
Subject: Re: Races in net_rx_action vs netpoll?
Date: Mon, 09 Jul 2007 15:27:46 -0700 (PDT)
Message-ID: <20070709.152746.75758774.davem@davemloft.net>
References: <200707041416.33732.okir@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: okir@lst.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47205
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751003AbXGJESv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2007 00:18:51 -0400
In-Reply-To: <200707041416.33732.okir@lst.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Olaf Kirch <okir@lst.de>
Date: Wed, 4 Jul 2007 14:16:32 +0200

Another locking bug in netpoll, why am I not surprised? :-/

Thanks for reporting this Olaf.

> I think the only real fix for this is to restrict who is allowed
> to remove the interface from the poll_list. Only net_rx_action
> should be allowed to do so. A possible patch is given below
> (beware, it's untested so far)

I'm happy to entertain this kind of solution, but we really
need to first have an interface to change multiple bits
at a time in one atomic operation, because by itself this
patch doubles the number of atomices we do when starting
a NAPI poll.

>  static inline int __netif_rx_schedule_prep(struct net_device *dev)
>  {
> +	/* The driver may have decided that there's no more work
> +	 * to be done - but now another interrupt arrives, and
> +	 * we changed our mind. */
> +	smp_mb__before_clear_bit();
> +	clear_bit(__LINK_STATE_RX_COMPLETE, &dev->state);
> +
>  	return !test_and_set_bit(__LINK_STATE_RX_SCHED, &dev->state);
>  }
>  

Because of that change.
