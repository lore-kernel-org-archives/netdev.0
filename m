From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH] net: fec: fix initial runtime PM refcount
Date: Mon, 3 Aug 2015 20:05:39 +0200
Message-ID: <20150803180539.GF9999@pengutronix.de>
References: <1438617011-19073-1-git-send-email-l.stach@pengutronix.de>
 <20150803161554.GK3467@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Lucas Stach <l.stach@pengutronix.de>, netdev@vger.kernel.org,
	patchwork-lst@pengutronix.de,
	"David S. Miller" <davem@davemloft.net>, kernel@pengutronix.de,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>,
	linux-pm@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:39641 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752917AbbHCSFr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 14:05:47 -0400
Content-Disposition: inline
In-Reply-To: <20150803161554.GK3467@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I have no clue about runtime-pm, but I added a few people to Cc: who
should know better ...

Best regards
Uwe

On Mon, Aug 03, 2015 at 06:15:54PM +0200, Andrew Lunn wrote:
> On Mon, Aug 03, 2015 at 05:50:11PM +0200, Lucas Stach wrote:
> > The clocks are initially active and thus the device is marked activ=
e.
> > This still keeps the PM refcount at 0, the pm_runtime_put_autosuspe=
nd()
> > call at the end of probe then leaves us with an invalid refcount of=
 -1,
> > which in turn leads to the device staying in suspended state even t=
hough
> > netdev open had been called.
> >=20
> > Fix this by initializing the refcount to be coherent with the initi=
al
> > device status.
> >=20
> > Fixes:
> > 8fff755e9f8 (net: fec: Ensure clocks are enabled while using mdio b=
us)
> >=20
> > Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
> > ---
> > Please apply this as a fix for 4.2
> > ---
> >  drivers/net/ethernet/freescale/fec_main.c | 1 +
> >  1 file changed, 1 insertion(+)
> >=20
> > diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/ne=
t/ethernet/freescale/fec_main.c
> > index 32e3807c650e..271bb5862346 100644
> > --- a/drivers/net/ethernet/freescale/fec_main.c
> > +++ b/drivers/net/ethernet/freescale/fec_main.c
> > @@ -3433,6 +3433,7 @@ fec_probe(struct platform_device *pdev)
> > =20
> >  	pm_runtime_set_autosuspend_delay(&pdev->dev, FEC_MDIO_PM_TIMEOUT)=
;
> >  	pm_runtime_use_autosuspend(&pdev->dev);
> > +	pm_runtime_get_noresume(&pdev->dev);
> >  	pm_runtime_set_active(&pdev->dev);
> >  	pm_runtime_enable(&pdev->dev);
>=20
> This might work, but is it the correct fix?
>=20
> Documentation/power/runtime_pm.txt says:
>=20
> 534 In addition to that, the initial runtime PM status of all devices=
 is
> 535 'suspended', but it need not reflect the actual physical state of=
 the device.
> 536 Thus, if the device is initially active (i.e. it is able to proce=
ss I/O), its
> 537 runtime PM status must be changed to 'active', with the help of
> 538 pm_runtime_set_active(), before pm_runtime_enable() is called for=
 the device.
>=20
> At the point we call the pm_runtime_ functions above, all the clocks
> are ticking. So according to the documentation pm_runtime_set_active(=
)
> is the right thing to do. But it makes no mention of have to call
> pm_runtime_get_noresume(). I would of expected pm_runtime_set_active(=
)
> to set the count to the correct value.

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
