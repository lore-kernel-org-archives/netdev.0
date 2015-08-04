From: Lucas Stach <l.stach@pengutronix.de>
Subject: Re: [PATCH] net: fec: fix initial runtime PM refcount
Date: Tue, 04 Aug 2015 09:34:22 +0200
Message-ID: <1438673662.2458.19.camel@pengutronix.de>
References: <1438617011-19073-1-git-send-email-l.stach@pengutronix.de>
	 <20150803161554.GK3467@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, patchwork-lst@pengutronix.de,
	"David S. Miller" <davem@davemloft.net>, kernel@pengutronix.de,
	Uwe =?ISO-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:57329 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752878AbbHDHeY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 03:34:24 -0400
In-Reply-To: <20150803161554.GK3467@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Montag, den 03.08.2015, 18:15 +0200 schrieb Andrew Lunn:
> On Mon, Aug 03, 2015 at 05:50:11PM +0200, Lucas Stach wrote:
> > The clocks are initially active and thus the device is marked active.
> > This still keeps the PM refcount at 0, the pm_runtime_put_autosuspend()
> > call at the end of probe then leaves us with an invalid refcount of -1,
> > which in turn leads to the device staying in suspended state even though
> > netdev open had been called.
> > 
> > Fix this by initializing the refcount to be coherent with the initial
> > device status.
> > 
> > Fixes:
> > 8fff755e9f8 (net: fec: Ensure clocks are enabled while using mdio bus)
> > 
> > Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
> > ---
> > Please apply this as a fix for 4.2
> > ---
> >  drivers/net/ethernet/freescale/fec_main.c | 1 +
> >  1 file changed, 1 insertion(+)
> > 
> > diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
> > index 32e3807c650e..271bb5862346 100644
> > --- a/drivers/net/ethernet/freescale/fec_main.c
> > +++ b/drivers/net/ethernet/freescale/fec_main.c
> > @@ -3433,6 +3433,7 @@ fec_probe(struct platform_device *pdev)
> >  
> >  	pm_runtime_set_autosuspend_delay(&pdev->dev, FEC_MDIO_PM_TIMEOUT);
> >  	pm_runtime_use_autosuspend(&pdev->dev);
> > +	pm_runtime_get_noresume(&pdev->dev);
> >  	pm_runtime_set_active(&pdev->dev);
> >  	pm_runtime_enable(&pdev->dev);
> 
> This might work, but is it the correct fix?
> 
> Documentation/power/runtime_pm.txt says:
> 
> 534 In addition to that, the initial runtime PM status of all devices is
> 535 'suspended', but it need not reflect the actual physical state of the device.
> 536 Thus, if the device is initially active (i.e. it is able to process I/O), its
> 537 runtime PM status must be changed to 'active', with the help of
> 538 pm_runtime_set_active(), before pm_runtime_enable() is called for the device.
> 
> At the point we call the pm_runtime_ functions above, all the clocks
> are ticking. So according to the documentation pm_runtime_set_active()
> is the right thing to do. But it makes no mention of have to call
> pm_runtime_get_noresume(). I would of expected pm_runtime_set_active()
> to set the count to the correct value.
> 
It is the correct fix.

pm_runtime_enable() is the transition point between whatever state the
device was in and the runtime PM managed state. pm_runtime_set_active()
informs the RPM framework about the current device state.
pm_runtime_get_noresume() tells the RPM framework what state we want the
device to be in after the transition to RPM managed state.

We expect the device to stay on while we go through the probe() routine,
so we need to get the runtime PM refcount, otherwise it would be fine
for RPM to turn the device off immediately after calling
pm_runtime_enable(). We drop the refcount when leaving the probe
routine.

Regards,
Lucas
-- 
Pengutronix e.K.             | Lucas Stach                 |
Industrial Linux Solutions   | http://www.pengutronix.de/  |
