From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: Fwd: [PATCH] bcm43xx: (hopefully) fix watchdog timeouts.
Date: Tue, 24 Oct 2006 20:37:26 -0400
Message-ID: <20061025003726.GC7340@tuxdriver.com>
References: <200610241631.18911.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <gregkh@suse.de>, stable@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:7177 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1161310AbWJYAh4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2006 20:37:56 -0400
To: Michael Buesch <mb@bu3sch.de>
Content-Disposition: inline
In-Reply-To: <200610241631.18911.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael,

It looks like you have a patch that I don't have, one that moves the
netif_tx_disable and spin_lock_irqsave outside of the "if (badness >
BADNESS_LIMIT)" conditional.

Could you pass that one along as well, or correct this patch to match
what is in Linus' tree?

Thanks,

John

On Tue, Oct 24, 2006 at 04:31:18PM +0200, Michael Buesch wrote:
> This fixes a netdev watchdog timeout problem.
> The problem is caused by a needed netif_tx_disable
> in the hardware calibration code and can be shown by the
> following timegraph.
> 
> |---5secs - ~10 jiffies time---|---|OOPS
> ^                              ^
> last real TX                   periodic work stops netif
> 
> At OOPS, the following happens:
> The watchdog timer triggers, because the timeout of 5secs
> is over. The watchdog first checks for stopped TX.
> _Usually_ TX is only stopped from the TX handler to indicate
> a full TX queue. But this is different. We need to stop TX here,
> regardless of the TX queue state. So the watchdog recognizes
> the stopped device and assumes it is stopped due to full
> TX queues (Which is a _wrong_ assumption in this case). It then
> tests how far the last TX has been in the past. If it's more than
> 5secs (which is the case for low or no traffic), it will fire
> a TX timeout.
> 
> Signed-off-by: Michael Buesch <mb@bu3sch.de>
> 
> --
> 
> John, please apply this bugfix to wireless-2.6.
> Greg, as the -stable maintainer, please consider putting this
> into 2.6.18.2
> 
> Index: linux-2.6.18/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> ===================================================================
> --- linux-2.6.18.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-10-19 21:30:42.000000000 +0200
> +++ linux-2.6.18/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-10-19 21:33:28.000000000 +0200
> @@ -3165,7 +3165,15 @@ static void bcm43xx_periodic_work_handle
>  
>  	badness = estimate_periodic_work_badness(bcm->periodic_state);
>  	mutex_lock(&bcm->mutex);
> +
> +	/* We must fake a started transmission here, as we are going to
> +	 * disable TX. If we wouldn't fake a TX, it would be possible to
> +	 * trigger the netdev watchdog, if the last real TX is already
> +	 * some time on the past (slightly less than 5secs)
> +	 */
> +	bcm->net_dev->trans_start = jiffies;
>  	netif_tx_disable(bcm->net_dev);
> +
>  	spin_lock_irqsave(&bcm->irq_lock, flags);
>  	if (badness > BADNESS_LIMIT) {
>  		/* Periodic work will take a long time, so we want it to
> 
> 
> 
> -- 
> Greetings Michael.
