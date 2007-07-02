From: Oleg Nesterov <oleg@tv-sign.ru>
Subject: Re: [NETPOLL] netconsole: fix soft lockup when removing module
Date: Mon, 2 Jul 2007 13:24:08 +0400
Message-ID: <20070702092408.GA137@tv-sign.ru>
References: <20070701173558.GA207@tv-sign.ru> <20070702063424.GA1639@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.screens.ru ([213.234.233.54]:36893 "EHLO mail.screens.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751333AbXGBJXt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2007 05:23:49 -0400
Content-Disposition: inline
In-Reply-To: <20070702063424.GA1639@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/02, Jarek Poplawski wrote:
>
> > > --- a/net/core/netpoll.c
> > > +++ b/net/core/netpoll.c
> > > @@ -72,7 +72,8 @@ static void queue_process(struct work_struct *work)
> > >  			netif_tx_unlock(dev);
> > >  			local_irq_restore(flags);
> > >  
> > > -			schedule_delayed_work(&npinfo->tx_work, HZ/10);
> > > +			if (atomic_read(&npinfo->refcnt))
> > > +				schedule_delayed_work(&npinfo->tx_work, HZ/10);
> > >  			return;
> > >  		}
>
> [...snip...]
> 
> So, 2.6.21 needs something better (maybe you've found it btw.?),
> but they weren't too interested, anyway.

We can do a double flush trick. If queue_process() checks ->refcnt before
schedule_delayed_work() like above, netpoll_cleanup() can do

	flush_scheduled_work();

	// the next invocation of queue_process()
	// must see ->refcnt == 0
	if (!cancel_delayed_work(&npinfo->tx_work)) {
		/* may be queued, wait for completion */
		flush_scheduled_work();
	}

Jarek, I don't understand net/, a silly question. Why do we need the #2 chunk?
Isn't it better to move skb_queue_purge(&npinfo->txq) after cancel_..._work()
instead?

Oleg.	

