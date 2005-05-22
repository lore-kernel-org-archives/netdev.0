From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: patch tulip-natsemi-dp83840a-phy-fix.patch added to -mm tree
Date: Sat, 21 May 2005 22:56:04 -0600
Message-ID: <20050522045604.GC2733@colo.lackof.org>
References: <200505101955.j4AJtX9x032464@shell0.pdx.osdl.net> <42881C58.40001@pobox.com> <20050516050843.GA20107@colo.lackof.org> <4288CE51.1050703@pobox.com> <20050521223959.GA4337@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Grant Grundler <grundler@parisc-linux.org>, akpm@osdl.org,
	T-Bone@parisc-linux.org, varenet@parisc-linux.org,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Netdev <netdev@oss.sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261715AbVEVExH@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20050521223959.GA4337@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, May 22, 2005 at 12:39:59AM +0200, Francois Romieu wrote:
> Jeff Garzik <jgarzik@pobox.com> :
> [tulip_media_select]
> > 1) called from timer context, from the media poll timer
> > 
> > 2) called from spin_lock_irqsave() context, in the ->tx_timeout hook.
> > 
> > The first case can be fixed by moved all the timer code to a workqueue. 
> >  Then when the existing timer fires, kick the workqueue.
> > 
> > The second case can be fixed by kicking the workqueue upon tx_timeout 
> > (which is the reason why I did not suggest queue_delayed_work() use).
> 
> First try below. It only moves tulip_select_media() to process context.

Cool - thanks.

> The original patch (with s/udelay/msleep/ or such) is not included.

That's fine. I'll take care of that once Jeff is happy with this.


> Comments/suggestions ?

Basic workqueue create/destroy looks correct - but I've only played with
workqueues once before.
It wouldn't hurt if someone else double checked too.

Comments below are mostly about the other parts.


> +static inline int tulip_create_workqueue(void)
> +{
> +	ktulipd_workqueue = create_workqueue("ktulipd");
> +	return ktulipd_workqueue ? 0 : -ENOMEM;
> +}

This just obfuscates the code. It's only called in one place.
Please just directly call create_workqueue("ktulipd") from tulip_init()
and check the return value.

> +static inline void tulip_destroy_workqueue(void)
> +{
> +	destroy_workqueue(ktulipd_workqueue);
> +}

Same thing.

> @@ -526,20 +549,9 @@ static void tulip_tx_timeout(struct net_
...
> +		tp->timeout_recovery = 1;
> +		queue_work(ktulipd_workqueue, &tp->media_work);
> +		goto out_unlock;

This is the key bit.

> -	/* Stop and restart the chip's Tx processes . */
> -
> -	tulip_restart_rxtx(tp);
> -	/* Trigger an immediate transmit demand. */
> -	iowrite32(0, ioaddr + CSR1);
> -
> -	tp->stats.tx_errors++;
> +	tulip_tx_timeout_complete(tp, ioaddr);

This doesn't fix the existing issue with tulip_restart_rxtx().
Even without the patch to tulip_select_media(),
tulip_restart_rxtx() does not comply with jgarzik's linux driver
requirements becuase it can spin delay up to 1200us.


>  static void __exit tulip_cleanup (void)
>  {
>  	pci_unregister_driver (&tulip_driver);
> +	tulip_destroy_workqueue();
>  }

Only one workqueue for all instances of tulip cards, right?


...
> @@ -127,6 +128,14 @@ void tulip_timer(unsigned long data)
>  	}
>  	break;
>  	}
> +
> +	spin_lock_irqsave (&tp->lock, flags);
> +	if (tp->timeout_recovery) {
> +		tp->timeout_recovery = 0;
> +		tulip_tx_timeout_complete(tp, ioaddr);
> +	}
> +	spin_unlock_irqrestore (&tp->lock, flags);


This suffers the original issue: blocked IRQs while CPU might spin
for 1200us in tulip_tx_timeout_complete().

If tp->timeout_recovery acts as a sort of semaphore for us,
do we even need the spinlock?

I suspect "yes" because timeout_recovery is a bitfield and clearing
it is a read/modify/write operation. This is why I don't like bitfields.

ie. something like:
	if (tp->timeout_recovery) {
		tulip_tx_timeout_complete(tp, ioaddr);

		spin_lock_irqsave (&tp->lock, flags);
		tp->timeout_recovery = 0;	/* Bitfields are NOT atomic. */
		spin_unlock_irqrestore (&tp->lock, flags);
	}

thanks,
grant
