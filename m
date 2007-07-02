From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [NETPOLL] netconsole: fix soft lockup when removing module
Date: Mon, 2 Jul 2007 08:34:24 +0200
Message-ID: <20070702063424.GA1639@ff.dom.local>
References: <20070701173558.GA207@tv-sign.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S\. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Oleg Nesterov <oleg@tv-sign.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:54767 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751075AbXGBG0H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2007 02:26:07 -0400
Content-Disposition: inline
In-Reply-To: <20070701173558.GA207@tv-sign.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 01, 2007 at 09:35:58PM +0400, Oleg Nesterov wrote:
> Jarek Poplawski wrote:
> >
> >    #1
> >    Until kernel ver. 2.6.21 (including) cancel_rearming_delayed_work()
> >    required a work function should always (unconditionally) rearm with
> >    delay > 0 - otherwise it would endlessly loop. This patch replaces
> >    this function with cancel_delayed_work(). Later kernel versions don't
> >    require this, so here it's only for uniformity.
> 
> But 2.6.22 doesn't need this change, why it was merged?

One bad reason is given above. Should I look for another one?

> 
> In fact, I suspect this change adds a race,

You are right!

> 
> > --- a/net/core/netpoll.c
> > +++ b/net/core/netpoll.c
> > @@ -72,7 +72,8 @@ static void queue_process(struct work_struct *work)
> >  			netif_tx_unlock(dev);
> >  			local_irq_restore(flags);
> >  
> > -			schedule_delayed_work(&npinfo->tx_work, HZ/10);
> > +			if (atomic_read(&npinfo->refcnt))
> > +				schedule_delayed_work(&npinfo->tx_work, HZ/10);
> >  			return;
> >  		}
> >  		netif_tx_unlock(dev);
> > @@ -785,9 +786,15 @@ void netpoll_cleanup(struct netpoll *np)
> >  			if (atomic_dec_and_test(&npinfo->refcnt)) {
> >  				skb_queue_purge(&npinfo->arp_tx);
> >  				skb_queue_purge(&npinfo->txq);
> > -				cancel_rearming_delayed_work(&npinfo->tx_work);
> > +				cancel_delayed_work(&npinfo->tx_work);
> >  				flush_scheduled_work();
> 
> Suppose that ->refcnt == 1, and queue_process() was preempted just after
> atomic_read(&npinfo->refcnt).
> 
> netpoll_cleanup() comes, cancel_delayed_work() does nothing, flush_scheduled_work()
> sleeps.
> 
> queue_process() gets CPU, re-schedules ->tx_work, and returns.
> 
> flush_scheduled_work() completes, netpoll_cleanup() frees npinfo and returns
> while ->tx_work is pending.
> 
> No?

No no. (Yes!)

I had some doubts about this, and you found very good reason
for this.

I'll soon send a patch to restore cancel_rearming_delayed_work
in 2.6.22.

So, 2.6.21 needs something better (maybe you've found it btw.?),
but they weren't too interested, anyway.

Thanks very much & regards,
Jarek P.
