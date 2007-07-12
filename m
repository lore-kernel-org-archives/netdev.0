From: Olaf Kirch <okir@lst.de>
Subject: Re: Races in net_rx_action vs netpoll?
Date: Thu, 12 Jul 2007 15:54:32 +0200
Message-ID: <200707121554.33915.okir@lst.de>
References: <20070712125949.GC1708@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.210]:58257 "EHLO mail.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757331AbXGLNyk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jul 2007 09:54:40 -0400
In-Reply-To: <20070712125949.GC1708@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jarek,

On Thursday 12 July 2007 14:59, Jarek Poplawski wrote:

> > +#ifdef CONFIG_NETPOLL
> > +	/* Prevent race with netpoll - yes, this is a kludge.
> > +	 * But at least it doesn't penalize the non-netpoll
> > +	 * code path. */
> 
> Alas, this can penalize those who have it enabled (e.g. by distro),
> but don't use.

Well, the test_bit is actually cheap; it's not atomic, and has no memory
ordering requirements by all I know. The costly thing is set_bit/clear_bit
in poll_napi; and you only ever get there when you *use* netpoll.

> And it looks like _netif_rx_complete should be a better place,
> at least considering such cards as: 8139too, skge, sungem and
> maybe more (according to 2.6.22).

Why?

> > +		set_bit(__LINK_STATE_POLL_LIST_FROZEN, &np->dev->state);
> >  		npinfo->rx_flags |= NETPOLL_RX_DROP;
> 
> I wonder, why this flag cannot be used for this check?

I tried, but it made the patch rather icky. netpoll_info is defined
in netpoll.h, which includes netdevice.h. So you cannot inline the
check, and have to use an out-of-line function instead, along the
lines of

extern int am_i_being_called_by_poll_napi(struct net_device *);

netif_rx_complete(struct net_device *dev)
{
#ifdef CONFIG_NETPOLL
	if (unlikely(dev->npinfo && am_i_being_called_by_poll_napi(dev))
		return;
#endif
	...
}

If you don't mind that, yes - this flag (or better, a newly introduced
NETPOLL_RX_NAPI) may work as well.

One thing I was a little worried about was whether dev->npinfo can
go away all of a sudden. It's really just protected by an rcu_readlock...

> BTW, I'd be very glad if somebody could hint me what is the main
> reason for such troublesome function as poll_napi: if it's about
> performance isn't this enough to increase budget for netpoll in
> net_rx_action?

I think one reason is that you want to get the kernel oops out even
when the machine is so hosed that it doesn't even service softirqs
anymore.

Olaf
-- 
Olaf Kirch  |  --- o --- Nous sommes du soleil we love when we play
okir@lst.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax
