From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next-2.6 2/2] 3c59x: Use fine-grained locks for MII
 and windowed register access
Date: Thu, 24 Jun 2010 14:05:17 +0200
Message-ID: <20100624120517.GI5570@secunet.com>
References: <1277337161.26161.14.camel@localhost>
 <1277337341.26161.18.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Chase Douglas <chase.douglas@canonical.com>,
	Arne Nordmark <nordmark@mech.kth.se>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:32994 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754863Ab0FXMEc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jun 2010 08:04:32 -0400
Content-Disposition: inline
In-Reply-To: <1277337341.26161.18.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Thu, Jun 24, 2010 at 12:55:41AM +0100, Ben Hutchings wrote:
> This avoids scheduling in atomic context and also means that IRQs
> will only be deferred for relatively short periods of time.
> 
> Previously discussed in:
> http://article.gmane.org/gmane.linux.network/155024
> 
> Reported-by: Arne Nordmark <nordmark@mech.kth.se>
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> Tested-by: Arne Nordmark <nordmark@mech.kth.se> [against 2.6.32]
> ---
>  drivers/net/3c59x.c |   66 ++++++++++++++++++++++++++++++---------------------
>  1 files changed, 39 insertions(+), 27 deletions(-)
> 
> diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
> index beddef9..f4a3fb1 100644
> --- a/drivers/net/3c59x.c
> +++ b/drivers/net/3c59x.c
> @@ -644,9 +644,15 @@ struct vortex_private {
>  	u16 deferred;						/* Resend these interrupts when we
>  										 * bale from the ISR */
>  	u16 io_size;						/* Size of PCI region (for release_region) */
> -	spinlock_t lock;					/* Serialise access to device & its vortex_private */
> -	struct mii_if_info mii;				/* MII lib hooks/info */
> -	int window;					/* Register window */
> +
> +	/* Serialises access to hardware other than MII and variables below.
> +	 * The lock hierarchy is rtnl_lock > lock > mii_lock > window_lock. */
> +	spinlock_t lock;
> +
> +	spinlock_t mii_lock;		/* Serialises access to MII */
> +	struct mii_if_info mii;		/* MII lib hooks/info */
> +	spinlock_t window_lock;		/* Serialises access to windowed regs */

You should initialize the new locks properly with spin_lock_init().

> +	int window;			/* Register window */
>  };
>  
>  static void window_set(struct vortex_private *vp, int window)
> @@ -661,15 +667,23 @@ static void window_set(struct vortex_private *vp, int window)
>  static u ## size							\
>  window_read ## size(struct vortex_private *vp, int window, int addr)	\
>  {									\
> +	unsigned long flags;						\
> +	u ## size ret;							\
> +	spin_lock_irqsave(&vp->window_lock, flags);			\
>  	window_set(vp, window);						\
> -	return ioread ## size(vp->ioaddr + addr);			\
> +	ret = ioread ## size(vp->ioaddr + addr);			\
> +	spin_unlock_irqrestore(&vp->window_lock, flags);		\
> +	return ret;							\
>  }									\
>  static void								\
>  window_write ## size(struct vortex_private *vp, u ## size value,	\
>  		     int window, int addr)				\
>  {									\
> +	unsigned long flags;						\
> +	spin_lock_irqsave(&vp->window_lock, flags);			\
>  	window_set(vp, window);						\
>  	iowrite ## size(value, vp->ioaddr + addr);			\
> +	spin_unlock_irqrestore(&vp->window_lock, flags);		\
>  }

This adds a lot of calls to spin_lock_irqsave/spin_unlock_irqrestore to many
places where this is not necessary at all. For example during device probe and
device open, window_read/window_write are called multiple times, each time
disabling the interrupts. I'd suggest to have unlocked, locked and irqsave
versions of window_read/window_write and use them in appropriate places.

>  DEFINE_WINDOW_IO(8)
>  DEFINE_WINDOW_IO(16)
> @@ -1784,7 +1798,6 @@ vortex_timer(unsigned long data)
>  		pr_debug("dev->watchdog_timeo=%d\n", dev->watchdog_timeo);
>  	}
>  
> -	disable_irq_lockdep(dev->irq);
>  	media_status = window_read16(vp, 4, Wn4_Media);
>  	switch (dev->if_port) {
>  	case XCVR_10baseT:  case XCVR_100baseTx:  case XCVR_100baseFx:
> @@ -1805,10 +1818,7 @@ vortex_timer(unsigned long data)
>  	case XCVR_MII: case XCVR_NWAY:
>  		{
>  			ok = 1;
> -			/* Interrupts are already disabled */
> -			spin_lock(&vp->lock);
>  			vortex_check_media(dev, 0);
> -			spin_unlock(&vp->lock);
>  		}
>  		break;
>  	  default:					/* Other media types handled by Tx timeouts. */
> @@ -1827,6 +1837,8 @@ vortex_timer(unsigned long data)
>  	if (!ok) {
>  		unsigned int config;
>  
> +		spin_lock_irq(&vp->lock);

This can still happen every 5 seconds if the NIC has no link beat and
medialock is not set. So what about defering this locked codepath to
a workqueue, or moving the whole vortex_timer to a delayed workqueue?
In this case we don't need to disable all the interrups on the cpu, we
could still use disable_irq then.

The rest looks quite good to me.

Thanks,

Steffen
