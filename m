From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Subject: Re: [PATCH] [RFT] 2.6.4 - epic100 napi
Date: Tue, 23 Mar 2004 23:29:49 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <8765cvmyaq.fsf@devron.myhome.or.jp>
References: <20040320152109.A31118@electric-eye.fr.zoreil.com>
	<405DDDC6.7030007@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <405DDDC6.7030007@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> writes:

> > +	if (work_done < orig_budget) {
> > +		unsigned long flags;
> > +		int status;
> > +
> > +		spin_lock_irqsave(&ep->napi_lock, flags);
> > +		epic_napi_irq_on(dev, ep);
> > +		__netif_rx_complete(dev);
> > +		spin_unlock_irqrestore(&ep->napi_lock, flags);
> > +
> > +		status = inl(ioaddr + INTSTAT);
> > +		if (status & EpicNapiEvent) {
> > +			epic_napi_irq_off(dev, ep);
> > +			goto rx_action;
> > +		}
> 
> Need to add a netif_running() check to the 'if' test at the top of the
> quote.
> 
> Are you (or somebody else?) interested in reviewing all the in-tree
> NAPI drivers, and seeing if other drivers have this bug?  I think
> 8139cp.c does at least, maybe e100 too...  Such a fix would need to go
> into 2.4.x as well.

Umm.. the above code is part of ->poll(). I think xxx_interrut() need
netif_running() instead. The driver must clear __LINK_STATE_RX_SCHED
flag...

BTW, ->napi_lock is unneeded because netif_schedule() is already
atomic, it need only local_irq_enable/disable().

After __netif_rx_complete() must not do "goto rx_action", otherwise it
may become cause of twice scheduleing, it should move before spin_lock().

Thanks.
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
