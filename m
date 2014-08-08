From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] xen-netback: Changes around carrier
 handling
Date: Thu, 07 Aug 2014 22:28:01 -0700 (PDT)
Message-ID: <20140807.222801.2128816957894671099.davem@davemloft.net>
References: <53E28017.9040908@citrix.com>
	<20140806.140146.1448631909293617629.davem@davemloft.net>
	<53E3A075.2090400@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wei.liu2@citrix.com, Ian.Campbell@citrix.com,
	david.vrabel@citrix.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org,
	Paul.Durrant@citrix.com
To: zoltan.kiss@citrix.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53E3A075.2090400@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zoltan Kiss <zoltan.kiss@citrix.com>
Date: Thu, 7 Aug 2014 16:51:17 +0100

> Ok, how about this:
> * ndo_start_xmit tries to set up the grant copy operations, something
> * which is done now in the thread
> * no estimation madness, just go ahead and try to do it
> * if the skb can fit, kick the thread
> * if it fails (not enough slots to complete the TX), then:
>   * call netif_tx_stop_queue on that queue (just like now)
>   * set up timer rx_stalled (just like now)
>   * save the state of the current skb (where the grant copy op setup is
>   * halted)
> * if new slots coming in, continue to create the grant copy ops for the
> * stalled skb, and if it succeeds, kick the thread plus call
> * netif_tx_start_queue. (just like now)
> * if the timer fires, drop the stalled skb, and set the carrier off, so
> * QDisc won't bother to queue packets for a stalled interface
> * the thread will only do the actual grant copy hypercall and releasing
> * the skb
> * in any case, ndo_start_xmit should return NETDEV_TX_OK, just like now

It sounds like this would work, and indeed it would abide by the intended
rules of netif_{stop,wake}_queue() and ->ndo_start_xmit()'s return
values.
