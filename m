From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Subject: Re: [PATCH] [RFT] 2.6.4 - epic100 napi
Date: Wed, 24 Mar 2004 01:05:30 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <87brmnh7lh.fsf@devron.myhome.or.jp>
References: <20040320152109.A31118@electric-eye.fr.zoreil.com>
	<405DDDC6.7030007@pobox.com> <8765cvmyaq.fsf@devron.myhome.or.jp>
	<4060544F.2090702@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4060544F.2090702@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> writes:

> > Umm.. the above code is part of ->poll(). I think xxx_interrut() need
> > netif_running() instead. The driver must clear __LINK_STATE_RX_SCHED
> > flag...
> 
> Most interrupt routines already test this, look at
> 
> static inline int netif_rx_schedule_prep(struct net_device *dev)
> {
>          return netif_running(dev) &&
>                  !test_and_set_bit(__LINK_STATE_RX_SCHED, &dev->state);
> }
> 
> It shouldn't schedule unless the interface is running.

Yes.

> However...  I believe it was you that added this check to 8139cp.c:
>
>          /* close possible race's with dev_close */
>          if (unlikely(!netif_running(dev))) {
>                  cpw16(IntrMask, 0);
>                  goto out;
>          }

Yes, I added. And my suggestion was about this.

Because in case of 8139too, I got too many interrupts about pending RX
during the following, and the following wasn't finished.
(dev->close() wasn't called).

dev_close(),
	clear_bit(__LINK_STATE_START, &dev->state);

	smp_mb__after_clear_bit(); /* Commit netif_running(). */
	while (test_bit(__LINK_STATE_RX_SCHED, &dev->state)) {
		/* No hurry. */
		current->state = TASK_INTERRUPTIBLE;
		schedule_timeout(1);
	}


> I do wonder about the consequences, on some hardware, about receiving
> an interrupt and -not- processing the RX or TX completions associated
> with that.  For most NIC hardware, you'll get sane behavior, but not
> all, I bet...

Is this meaning should _not_ receive the interrupt about pending RX/TX?

Thanks.
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
