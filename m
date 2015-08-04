From: Lucas Stach <l.stach@pengutronix.de>
Subject: Re: [PATCH] net: fec: fix initial runtime PM refcount
Date: Tue, 04 Aug 2015 09:43:36 +0200
Message-ID: <1438674216.2458.24.camel@pengutronix.de>
References: <Pine.LNX.4.44L0.1508031416250.1667-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Uwe =?ISO-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>, Andrew Lunn <andrew@lunn.ch>,
	netdev@vger.kernel.org, patchwork-lst@pengutronix.de,
	"David S. Miller" <davem@davemloft.net>, kernel@pengutronix.de,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>,
	linux-pm@vger.kernel.org
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:39203 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754651AbbHDHnm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 03:43:42 -0400
In-Reply-To: <Pine.LNX.4.44L0.1508031416250.1667-100000@iolanthe.rowland.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Montag, den 03.08.2015, 14:28 -0400 schrieb Alan Stern:
> On Mon, 3 Aug 2015, Uwe [iso-8859-1] Kleine-Knig wrote:
> 
> > Hello,
> > 
> > I have no clue about runtime-pm, but I added a few people to Cc: who
> > should know better ...
> > 
> > Best regards
> > Uwe
> > 
> > On Mon, Aug 03, 2015 at 06:15:54PM +0200, Andrew Lunn wrote:
> > > On Mon, Aug 03, 2015 at 05:50:11PM +0200, Lucas Stach wrote:
> > > > The clocks are initially active and thus the device is marked active.
> > > > This still keeps the PM refcount at 0, the pm_runtime_put_autosuspend()
> > > > call at the end of probe then leaves us with an invalid refcount of -1,
> > > > which in turn leads to the device staying in suspended state even though
> > > > netdev open had been called.
> > > > 
> > > > Fix this by initializing the refcount to be coherent with the initial
> > > > device status.
> > > > 
> > > > Fixes:
> > > > 8fff755e9f8 (net: fec: Ensure clocks are enabled while using mdio bus)
> > > > 
> > > > Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
> > > > ---
> > > > Please apply this as a fix for 4.2
> > > > ---
> > > >  drivers/net/ethernet/freescale/fec_main.c | 1 +
> > > >  1 file changed, 1 insertion(+)
> > > > 
> > > > diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
> > > > index 32e3807c650e..271bb5862346 100644
> > > > --- a/drivers/net/ethernet/freescale/fec_main.c
> > > > +++ b/drivers/net/ethernet/freescale/fec_main.c
> > > > @@ -3433,6 +3433,7 @@ fec_probe(struct platform_device *pdev)
> > > >  
> > > >  	pm_runtime_set_autosuspend_delay(&pdev->dev, FEC_MDIO_PM_TIMEOUT);
> > > >  	pm_runtime_use_autosuspend(&pdev->dev);
> > > > +	pm_runtime_get_noresume(&pdev->dev);
> > > >  	pm_runtime_set_active(&pdev->dev);
> > > >  	pm_runtime_enable(&pdev->dev);
> > > 
> > > This might work, but is it the correct fix?
> 
> It looks reasonable to me.  It might also make sense to move all of
> that pm_runtime_* stuff to the end of the probe routine.  Notice that
> they don't get undone if register_netdev() fails.
> 
Unfortunately we can not move RPM enabling to the end of probe, as the
MDIO read/write functions that rely on RPM are already called while we
are still in the middle of the probe function.

I agree that we need better error handling here, but that comment
applies to the whole FEC probe function. I think that this might be
invasive enough to justify a delay to the next merge window, not really
material for the late RCs.

Regards,
Lucas

-- 
Pengutronix e.K.             | Lucas Stach                 |
Industrial Linux Solutions   | http://www.pengutronix.de/  |
