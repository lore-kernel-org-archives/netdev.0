From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Subject: Re: [PATCH] [RFT] 2.6.4 - epic100 napi
Date: Wed, 24 Mar 2004 04:59:19 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <871xnjgwrs.fsf@devron.myhome.or.jp>
References: <20040320152109.A31118@electric-eye.fr.zoreil.com>
	<405DDDC6.7030007@pobox.com> <8765cvmyaq.fsf@devron.myhome.or.jp>
	<20040323195119.A14062@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040323195119.A14062@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Francois Romieu <romieu@fr.zoreil.com> writes:

> OGAWA Hirofumi <hirofumi@mail.parknet.co.jp> :
> [...]
> > Umm.. the above code is part of ->poll(). I think xxx_interrut() need
> > netif_running() instead. The driver must clear __LINK_STATE_RX_SCHED
> > flag...
> > 
> > BTW, ->napi_lock is unneeded because netif_schedule() is already
> > atomic, it need only local_irq_enable/disable().
> 
> Color me confused. The lock is supposed to protect against:
> 
> CPU1                         CPU2
> [poll]
> epic_napi_irq_on(dev, ep);
>                              [irq handler]
>                              if (netif_rx_schedule_prep(dev)) {
>                                      epic_napi_irq_off(dev, ep);
>                                      __netif_rx_schedule(dev);
>                              }
> __netif_rx_complete(dev);
> 
> -> napi irq are disabled and device is removed from poll list. What will
>    prevent it ?

__LINK_STATE_RX_SCHED flag is setting until __netif_rx_complete() is called.
So netif_rx_schedule_prep() returns 0.

> > After __netif_rx_complete() must not do "goto rx_action", otherwise it
> > may become cause of twice scheduleing, it should move before spin_lock().
> 
>  understand the previous statement as:
> 
> +               status = inl(ioaddr + INTSTAT);
> +               if (status & EpicNapiEvent) {
> +                       epic_napi_irq_off(dev, ep);
> +                       goto rx_action;
> +
> +               spin_lock_irqsave(&ep->napi_lock, flags);
> +               epic_napi_irq_on(dev, ep);
> +               __netif_rx_complete(dev);
> +               spin_unlock_irqrestore(&ep->napi_lock, flags);
> +
> 
> Afaiu, if some data comes in just before the spin_lock, it may wait for ages.

Yes, maybe. But, if after spin_lock, it loop may call the twice
__netif_rx_schedule(). And netif_rx_complete() doesn't call dev_put().
It will leaks the dev->refcnt, I think.

> +               __netif_rx_complete(dev);
> +               spin_unlock_irqrestore(&ep->napi_lock, flags);
           -- interrupt and call __netif_rx_schedule() --
> +               status = inl(ioaddr + INTSTAT);
> +               if (status & EpicNapiEvent) {
> +                       epic_napi_irq_off(dev, ep);
> +                       goto rx_action;

Thanks.
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
