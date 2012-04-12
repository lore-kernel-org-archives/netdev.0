From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ks8851: Fix missing mutex_lock/unlock
Date: Thu, 12 Apr 2012 23:03:00 +0100
Message-ID: <1334268180.2497.39.camel@bwh-desktop.uk.solarflarecom.com>
References: <1334266100-9875-1-git-send-email-mjr@cs.wisc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <fbl@redhat.com>, <davem@davemloft.net>, <sboyd@codeaurora.org>,
	<ben@simtec.co.uk>, <netdev@vger.kernel.org>
To: <mjr@cs.wisc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:40048 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S965022Ab2DLWDF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 18:03:05 -0400
In-Reply-To: <1334266100-9875-1-git-send-email-mjr@cs.wisc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-04-12 at 16:28 -0500, mjr@cs.wisc.edu wrote:
> From: Matt Renzelmann <mjr@cs.wisc.edu>
> 
> All calls to ks8851_rdreg* and ks8851_wrreg* should be protected with
> the driver's lock mutex.  A spurious interrupt may otherwise cause a
> crash.  Thanks to Stephen Boyd and Flavio Leitner for feedback.
> 
> Signed-off-by: Matt Renzelmann <mjr@cs.wisc.edu>
> ---
> 
> Here's the next revision.  This is basically Flavio Leitner's latest
> version without the mutex.  Please let me know if I'm missing
> anything and I can re-submit it.
> 
>  drivers/net/ethernet/micrel/ks8851.c |    8 ++++----
>  1 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/ethernet/micrel/ks8851.c b/drivers/net/ethernet/micrel/ks8851.c
> index c722aa6..6528d66 100644
> --- a/drivers/net/ethernet/micrel/ks8851.c
> +++ b/drivers/net/ethernet/micrel/ks8851.c
> @@ -1418,6 +1418,7 @@ static int __devinit ks8851_probe(struct spi_device *spi)
>  	struct net_device *ndev;
>  	struct ks8851_net *ks;
>  	int ret;
> +	unsigned cider;
>  
>  	ndev = alloc_etherdev(sizeof(struct ks8851_net));
>  	if (!ndev)
> @@ -1484,8 +1485,8 @@ static int __devinit ks8851_probe(struct spi_device *spi)
>  	ks8851_soft_reset(ks, GRR_GSR);
>  
>  	/* simple check for a valid chip being connected to the bus */
> -
> -	if ((ks8851_rdreg16(ks, KS_CIDER) & ~CIDER_REV_MASK) != CIDER_ID) {
> +	cider = CIDER_REV_GET(ks8851_rdreg16(ks, KS_CIDER));

So now 'cider' holds the revision bits.

> +	if ((cider & ~CIDER_REV_MASK) != CIDER_ID) {

But this is trying to check everything *but* the revision bits.

>  		dev_err(&spi->dev, "failed to read device ID\n");
>  		ret = -ENODEV;
>  		goto err_id;
> @@ -1516,8 +1517,7 @@ static int __devinit ks8851_probe(struct spi_device *spi)
>  	}
>  
>  	netdev_info(ndev, "revision %d, MAC %pM, IRQ %d, %s EEPROM\n",
> -		    CIDER_REV_GET(ks8851_rdreg16(ks, KS_CIDER)),
> -		    ndev->dev_addr, ndev->irq,
> +		    CIDER_REV_GET(cider), ndev->dev_addr, ndev->irq,

And this is trying to extract the revision bits, as if 'cider' holds the
full register value.

I think you need to remove the first CIDER_REV_GET().

Ben.

>  		    ks->rc_ccr & CCR_EEPROM ? "has" : "no");
>  
>  	return 0;

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
