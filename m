From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] [RFT] 2.6.4 - epic100 napi
Date: Tue, 23 Mar 2004 19:51:19 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040323195119.A14062@electric-eye.fr.zoreil.com>
References: <20040320152109.A31118@electric-eye.fr.zoreil.com> <405DDDC6.7030007@pobox.com> <8765cvmyaq.fsf@devron.myhome.or.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Content-Disposition: inline
In-Reply-To: <8765cvmyaq.fsf@devron.myhome.or.jp>; from hirofumi@mail.parknet.co.jp on Tue, Mar 23, 2004 at 11:29:49PM +0900
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

OGAWA Hirofumi <hirofumi@mail.parknet.co.jp> :
[...]
> Umm.. the above code is part of ->poll(). I think xxx_interrut() need
> netif_running() instead. The driver must clear __LINK_STATE_RX_SCHED
> flag...
> 
> BTW, ->napi_lock is unneeded because netif_schedule() is already
> atomic, it need only local_irq_enable/disable().

Color me confused. The lock is supposed to protect against:

CPU1                         CPU2
[poll]
epic_napi_irq_on(dev, ep);
                             [irq handler]
                             if (netif_rx_schedule_prep(dev)) {
                                     epic_napi_irq_off(dev, ep);
                                     __netif_rx_schedule(dev);
                             }
__netif_rx_complete(dev);

-> napi irq are disabled and device is removed from poll list. What will
   prevent it ?

> After __netif_rx_complete() must not do "goto rx_action", otherwise it
> may become cause of twice scheduleing, it should move before spin_lock().

 understand the previous statement as:

+               status = inl(ioaddr + INTSTAT);
+               if (status & EpicNapiEvent) {
+                       epic_napi_irq_off(dev, ep);
+                       goto rx_action;
+
+               spin_lock_irqsave(&ep->napi_lock, flags);
+               epic_napi_irq_on(dev, ep);
+               __netif_rx_complete(dev);
+               spin_unlock_irqrestore(&ep->napi_lock, flags);
+

Afaiu, if some data comes in just before the spin_lock, it may wait for ages.

Can you reformulate as I feel I still did not get it right.

--
Ueimor
