From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/1] via-rhine: Fix hanging with high CPU load on
 low-end broads.
Date: Wed, 28 Dec 2011 15:37:31 +0100
Message-ID: <1325083051.2327.47.camel@deadeye>
References: <1325075319-13464-1-git-send-email-gurligebis@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Roger Luethi <rl@hellgate.ch>
To: Bjarke Istrup Pedersen <gurligebis@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:43729 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753936Ab1L1Ohk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2011 09:37:40 -0500
In-Reply-To: <1325075319-13464-1-git-send-email-gurligebis@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-12-28 at 12:28 +0000, Bjarke Istrup Pedersen wrote:
> Working around problem causing high CPU load and hanging system when
> there is alot of network trafic.
> 
> It is kind of an ugly way to work around it, but it allows the Soekris
> net5501 to have trafic between two of it's NICs without hanging so much
> that the watchdog kicks in and does a hard reboot of the system.
> 
> There is more info on the problem here:
> http://http://lists.soekris.com/pipermail/soekris-tech/2010-October/016889.html
> 
> Tested with positive results on two Soekris net5501-70 boxes.

This is completely wrong.  In a UP configuration the extra spinlock
calls have no effect (except perhaps a small delay).  In an SMP
configuration they will cause rhine_tx() to deadlock when it also tries
to acquire the spinlock.

Ben.

[...]
> diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
> index f34dd99..8c77dcd 100644
> --- a/drivers/net/ethernet/via/via-rhine.c
> +++ b/drivers/net/ethernet/via/via-rhine.c
> @@ -1567,6 +1567,9 @@ static irqreturn_t rhine_interrupt(int irq, void *dev_instance)
>         int boguscnt = max_interrupt_work;
>         int handled = 0;
>  
> +       if (!spin_trylock(&rp->lock))
> +               return IRQ_RETVAL(handled);
> +
>         while ((intr_status = get_intr_status(dev))) {
>                 handled = 1;
>  
> @@ -1616,6 +1619,8 @@ static irqreturn_t rhine_interrupt(int irq, void *dev_instance)
>                 }
>         }
>  
> +       spin_unlock(&rp->lock);
> +
>         if (debug > 3)
>                 netdev_dbg(dev, "exiting interrupt, status=%08x\n",
>                            ioread16(ioaddr + IntrStatus));

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
