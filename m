From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: fec: fix initial runtime PM refcount
Date: Mon, 3 Aug 2015 18:15:54 +0200
Message-ID: <20150803161554.GK3467@lunn.ch>
References: <1438617011-19073-1-git-send-email-l.stach@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>, netdev@vger.kernel.org,
	kernel@pengutronix.de, patchwork-lst@pengutronix.de
To: Lucas Stach <l.stach@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:54414 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754306AbbHCQWu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Aug 2015 12:22:50 -0400
Content-Disposition: inline
In-Reply-To: <1438617011-19073-1-git-send-email-l.stach@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 03, 2015 at 05:50:11PM +0200, Lucas Stach wrote:
> The clocks are initially active and thus the device is marked active.
> This still keeps the PM refcount at 0, the pm_runtime_put_autosuspend()
> call at the end of probe then leaves us with an invalid refcount of -1,
> which in turn leads to the device staying in suspended state even though
> netdev open had been called.
> 
> Fix this by initializing the refcount to be coherent with the initial
> device status.
> 
> Fixes:
> 8fff755e9f8 (net: fec: Ensure clocks are enabled while using mdio bus)
> 
> Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
> ---
> Please apply this as a fix for 4.2
> ---
>  drivers/net/ethernet/freescale/fec_main.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
> index 32e3807c650e..271bb5862346 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -3433,6 +3433,7 @@ fec_probe(struct platform_device *pdev)
>  
>  	pm_runtime_set_autosuspend_delay(&pdev->dev, FEC_MDIO_PM_TIMEOUT);
>  	pm_runtime_use_autosuspend(&pdev->dev);
> +	pm_runtime_get_noresume(&pdev->dev);
>  	pm_runtime_set_active(&pdev->dev);
>  	pm_runtime_enable(&pdev->dev);

This might work, but is it the correct fix?

Documentation/power/runtime_pm.txt says:

534 In addition to that, the initial runtime PM status of all devices is
535 'suspended', but it need not reflect the actual physical state of the device.
536 Thus, if the device is initially active (i.e. it is able to process I/O), its
537 runtime PM status must be changed to 'active', with the help of
538 pm_runtime_set_active(), before pm_runtime_enable() is called for the device.

At the point we call the pm_runtime_ functions above, all the clocks
are ticking. So according to the documentation pm_runtime_set_active()
is the right thing to do. But it makes no mention of have to call
pm_runtime_get_noresume(). I would of expected pm_runtime_set_active()
to set the count to the correct value.

   Andrew
