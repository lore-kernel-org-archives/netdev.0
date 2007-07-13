From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Races in net_rx_action vs netpoll?
Date: Fri, 13 Jul 2007 10:55:08 +0200
Message-ID: <20070713085508.GC2009@ff.dom.local>
References: <20070712125949.GC1708@ff.dom.local> <200707121554.33915.okir@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Olaf Kirch <okir@lst.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:58712 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1761644AbXGMIqX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jul 2007 04:46:23 -0400
Content-Disposition: inline
In-Reply-To: <200707121554.33915.okir@lst.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 12, 2007 at 03:54:32PM +0200, Olaf Kirch wrote:
> Hi Jarek,
> 
> On Thursday 12 July 2007 14:59, Jarek Poplawski wrote:
> 
> > > +#ifdef CONFIG_NETPOLL
> > > +	/* Prevent race with netpoll - yes, this is a kludge.
> > > +	 * But at least it doesn't penalize the non-netpoll
> > > +	 * code path. */
> > 
> > Alas, this can penalize those who have it enabled (e.g. by distro),
> > but don't use.
> 
> Well, the test_bit is actually cheap; it's not atomic, and has no memory
> ordering requirements by all I know. The costly thing is set_bit/clear_bit
> in poll_napi; and you only ever get there when you *use* netpoll.

I've only meant "it doesn't penalize" isn't too precise here,
at least if you take it "mathematically". But, e.g. "politically"
it's 110% right, of course.

> 
> > And it looks like _netif_rx_complete should be a better place,
> > at least considering such cards as: 8139too, skge, sungem and
> > maybe more (according to 2.6.22).
> 
> Why?

It seems I miss something, but if it's to be called from dev->poll,
these drivers use __netif_rx_complete instead of netif_rx_complete.

> 
> > > +		set_bit(__LINK_STATE_POLL_LIST_FROZEN, &np->dev->state);
> > >  		npinfo->rx_flags |= NETPOLL_RX_DROP;
> > 
> > I wonder, why this flag cannot be used for this check?
> 
> I tried, but it made the patch rather icky. netpoll_info is defined
> in netpoll.h, which includes netdevice.h. So you cannot inline the
> check, and have to use an out-of-line function instead, along the
> lines of
> 
> extern int am_i_being_called_by_poll_napi(struct net_device *);
> 
> netif_rx_complete(struct net_device *dev)
> {
> #ifdef CONFIG_NETPOLL
> 	if (unlikely(dev->npinfo && am_i_being_called_by_poll_napi(dev))
> 		return;
> #endif
> 	...
> }
> 
> If you don't mind that, yes - this flag (or better, a newly introduced
> NETPOLL_RX_NAPI) may work as well.
> 
> One thing I was a little worried about was whether dev->npinfo can
> go away all of a sudden. It's really just protected by an rcu_readlock...

I didn't think about this struct netpoll_info vs. inlining,
but I'm glad you did, so adding a new flag looks more reasonably
if we don't want to mess to much with netdevice.h.
BTW, I don't think there could be any problem with rcu (if it's
all about calling dev->poll from poll_napi) because then poll_napi
should have the same problem.

> 
> > BTW, I'd be very glad if somebody could hint me what is the main
> > reason for such troublesome function as poll_napi: if it's about
> > performance isn't this enough to increase budget for netpoll in
> > net_rx_action?
> 
> I think one reason is that you want to get the kernel oops out even
> when the machine is so hosed that it doesn't even service softirqs
> anymore.

Thanks! So, I have to think about this more. Of course, such idea
is fine if it doesn't collide with normal service, which I'm not
sure is true now. I mean this problem here, and e.g. needles
servicing of not netconsole packets by different cpus, but also
some unclear to me things like calling this from find_skb when
there is a problem with alloc_skb (I wonder how a card driver
manages to get these skbs for receiving?).

Cheers,
Jarek P.
