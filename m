From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [NETPOLL] netconsole: fix soft lockup when removing module
Date: Mon, 2 Jul 2007 13:08:01 +0200
Message-ID: <20070702110801.GD1639@ff.dom.local>
References: <20070701173558.GA207@tv-sign.ru> <20070702063424.GA1639@ff.dom.local> <20070702092408.GA137@tv-sign.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S\. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Oleg Nesterov <oleg@tv-sign.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:49739 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751368AbXGBK7j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2007 06:59:39 -0400
Content-Disposition: inline
In-Reply-To: <20070702092408.GA137@tv-sign.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 02, 2007 at 01:24:08PM +0400, Oleg Nesterov wrote:
> On 07/02, Jarek Poplawski wrote:
> >
> > > > --- a/net/core/netpoll.c
> > > > +++ b/net/core/netpoll.c
> > > > @@ -72,7 +72,8 @@ static void queue_process(struct work_struct *work)
> > > >  			netif_tx_unlock(dev);
> > > >  			local_irq_restore(flags);
> > > >  
> > > > -			schedule_delayed_work(&npinfo->tx_work, HZ/10);
> > > > +			if (atomic_read(&npinfo->refcnt))
> > > > +				schedule_delayed_work(&npinfo->tx_work, HZ/10);
> > > >  			return;
> > > >  		}
> >
> > [...snip...]
> > 
> > So, 2.6.21 needs something better (maybe you've found it btw.?),
> > but they weren't too interested, anyway.
> 
> We can do a double flush trick. If queue_process() checks ->refcnt before
> schedule_delayed_work() like above, netpoll_cleanup() can do
> 
> 	flush_scheduled_work();
> 
> 	// the next invocation of queue_process()
> 	// must see ->refcnt == 0
> 	if (!cancel_delayed_work(&npinfo->tx_work)) {
> 		/* may be queued, wait for completion */
> 		flush_scheduled_work();
> 	}

I'll try to think about it later, but I don't plan to do next patch,
so feel free to send this. I didn't plan to fix netpoll at all
(I never didn't use nor studied this before...). But couldn't stand
this stupid lockup stays in 2.6.21. Now, I see it probably doesn't
annoy more than 2 or 3 people around...

> 
> Jarek, I don't understand net/, a silly question. Why do we need the #2 chunk?
> Isn't it better to move skb_queue_purge(&npinfo->txq) after cancel_..._work()
> instead?

I've thought about this too, but because I don't know netpoll/netconsole
enough I didn't want to change more than minimum needed. 

skb_queue_purge() uses heavy locking (irqsave) and I don't remember now
if I've found the reason or simply believed somebody had to have a reason
to do this there, anyway, if moved after cancel_ it could be done without
this locking, and something like while () instead of my if () should be
enough.

But there was not much interest about this patch, and I'm not currently
interested to be the main netconsole expert too, so maybe you would
like to try...

Cheers,
Jarek P.
