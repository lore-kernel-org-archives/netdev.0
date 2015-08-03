From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCH] net: fec: fix initial runtime PM refcount
Date: Mon, 3 Aug 2015 14:28:58 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1508031416250.1667-100000@iolanthe.rowland.org>
References: <20150803180539.GF9999@pengutronix.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Lunn <andrew@lunn.ch>, Lucas Stach <l.stach@pengutronix.de>,
	<netdev@vger.kernel.org>, <patchwork-lst@pengutronix.de>,
	"David S. Miller" <davem@davemloft.net>, <kernel@pengutronix.de>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>,
	<linux-pm@vger.kernel.org>
To: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <20150803180539.GF9999@pengutronix.de>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 3 Aug 2015, Uwe [iso-8859-1] Kleine-K=F6nig wrote:

> Hello,
>=20
> I have no clue about runtime-pm, but I added a few people to Cc: who
> should know better ...
>=20
> Best regards
> Uwe
>=20
> On Mon, Aug 03, 2015 at 06:15:54PM +0200, Andrew Lunn wrote:
> > On Mon, Aug 03, 2015 at 05:50:11PM +0200, Lucas Stach wrote:
> > > The clocks are initially active and thus the device is marked act=
ive.
> > > This still keeps the PM refcount at 0, the pm_runtime_put_autosus=
pend()
> > > call at the end of probe then leaves us with an invalid refcount =
of -1,
> > > which in turn leads to the device staying in suspended state even=
 though
> > > netdev open had been called.
> > >=20
> > > Fix this by initializing the refcount to be coherent with the ini=
tial
> > > device status.
> > >=20
> > > Fixes:
> > > 8fff755e9f8 (net: fec: Ensure clocks are enabled while using mdio=
 bus)
> > >=20
> > > Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
> > > ---
> > > Please apply this as a fix for 4.2
> > > ---
> > >  drivers/net/ethernet/freescale/fec_main.c | 1 +
> > >  1 file changed, 1 insertion(+)
> > >=20
> > > diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/=
net/ethernet/freescale/fec_main.c
> > > index 32e3807c650e..271bb5862346 100644
> > > --- a/drivers/net/ethernet/freescale/fec_main.c
> > > +++ b/drivers/net/ethernet/freescale/fec_main.c
> > > @@ -3433,6 +3433,7 @@ fec_probe(struct platform_device *pdev)
> > > =20
> > >  	pm_runtime_set_autosuspend_delay(&pdev->dev, FEC_MDIO_PM_TIMEOU=
T);
> > >  	pm_runtime_use_autosuspend(&pdev->dev);
> > > +	pm_runtime_get_noresume(&pdev->dev);
> > >  	pm_runtime_set_active(&pdev->dev);
> > >  	pm_runtime_enable(&pdev->dev);
> >=20
> > This might work, but is it the correct fix?

It looks reasonable to me.  It might also make sense to move all of
that pm_runtime_* stuff to the end of the probe routine.  Notice that
they don't get undone if register_netdev() fails.

> > Documentation/power/runtime_pm.txt says:
> >=20
> > 534 In addition to that, the initial runtime PM status of all devic=
es is
> > 535 'suspended', but it need not reflect the actual physical state =
of the device.
> > 536 Thus, if the device is initially active (i.e. it is able to pro=
cess I/O), its
> > 537 runtime PM status must be changed to 'active', with the help of
> > 538 pm_runtime_set_active(), before pm_runtime_enable() is called f=
or the device.
> >=20
> > At the point we call the pm_runtime_ functions above, all the clock=
s
> > are ticking. So according to the documentation pm_runtime_set_activ=
e()
> > is the right thing to do. But it makes no mention of have to call
> > pm_runtime_get_noresume(). I would of expected pm_runtime_set_activ=
e()
> > to set the count to the correct value.

pm_runtime_set_active() doesn't change the usage count.  All it does is=
=20
set the runtime PM status to "active".

A call to pm_runtime_get_noresume() (or something similar) is necessary
to balance the call to pm_runtime_put_autosuspend() at the end of the
probe routine.  Both the _get_ and the _put_ should be present or
neither should be.

=46or instance, an alternative way to accomplish the same result is to
replace pm_runtime_put_autosuspend() with pm_runtime_autosuspend(). =20
The only difference is that the usage counter would not be elevated
during the register_netdev() call, so in theory the device could be
suspended while that routine is running.  But if all the pm_runtime_*
calls were moved to the end of the probe function, even that couldn't
happen.

Alan Stern

