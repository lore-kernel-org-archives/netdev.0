From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH] net: phy: at803x: don't depend on GPIOLIB
Date: Mon, 21 Mar 2016 14:54:57 +0100
Message-ID: <20160321135457.GX4292@pengutronix.de>
References: <56E99727.9040702@laposte.net>
 <20160318125455.GN4292@pengutronix.de>
 <56EC2525.8000706@laposte.net>
 <20160318191242.GQ4292@pengutronix.de>
 <56EFEDAD.9030903@laposte.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Daniel Mack <daniel@zonque.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>, mason <slash.tmp@free.fr>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Mans Rullgard <mans@mansr.com>,
	Fabio Estevam <festevam@gmail.com>,
	Martin Blumenstingl <martin.blumenstingl@gmail.com>,
	Linus Walleij <linus.walleij@linaro.org>
To: Sebastian Frias <sf84@laposte.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:46593 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755215AbcCUONu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2016 10:13:50 -0400
Content-Disposition: inline
In-Reply-To: <56EFEDAD.9030903@laposte.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Sebastian,

On Mon, Mar 21, 2016 at 01:48:45PM +0100, Sebastian Frias wrote:
> On 03/18/2016 08:12 PM, Uwe Kleine-K=F6nig wrote:
> > On Fri, Mar 18, 2016 at 04:56:21PM +0100, Sebastian Frias wrote:
> >> On 03/18/2016 01:54 PM, Uwe Kleine-K=F6nig wrote:
> >>> From a driver perspecitive, it would be nice if devm_gpiod_get_op=
tional
> >>> returned NULL iff the respective gpio isn't specified even with
> >>> GPIOLIB=3Dn, but this isn't sensible either because it would resu=
lt in
> >>> quite some gpiolib code to not being conditionally compiled on
> >>> CONFIG_GPIOLIB any more.
> >>
> >> Let's say that was the case, what would the PHY code do?
> >=20
> > With reset gpios it might not be that critical, but consider an opt=
ional
> > enable gpio. (Optional in the sense, that some device have it and o=
thers
> > don't, e.g. because the pin is pulled into active level by hardware=
=2E)
> >=20
> > Now you do:
> >=20
> > 	gpiod =3D gpiod_get_optional("enable");
> >=20
> > and if gpiod now is an error pointer, you must assume that you cann=
ot
> > operate the device. And even with GPIOLIB=3Dn (and gpiod =3D ERR_PT=
R(-ENOSYS))
> > you cannot ignore the error.=20
>=20
> Two things:
> - I suppose that in such hypothetical case the dependency on GPIOLIB
>   would be required and thus be there

I don't agree. There are bugs out there, and maybe the reason is as
simple as "the implementor of the reset-gpio handling had GPIOLIB on an=
d
didn't test without GPIOLIB".

> - We'd also need to check that 'gpiod' is not NULL

That is the optional part. If gpiod is NULL, you have one of the device=
s
that don't need to handle the enable line.

> In the scenario at hand only some devices require a hack and
> gpiod_reset=3DNULL is valid (ie: device will not fail probing)

With your patch and GPIOLIB=3Dn you bind the driver even for the device=
s
that need the hack. This is broken!

> >For consistency I'd recommend to do the
> > same for reset even though there is a chance to get a working devic=
e.
>=20
> I'm not so sure, because then information would be lost, handling bot=
h
> ("enable" and "reset") the same way aliases different intents and
> requirements.
> Indeed, only "enable" would be really mandatory, "reset" is essential=
ly
> optional (only 1 of 3 devices of the family require the hack).
>=20
> Besides, if "reset" was really mandatory, we would also fail the prob=
e
> if the pointer for the reset GPIO is NULL.

No, if reset was mandatory you'd use gpiod_get instead of
gpiod_get_optional and fail iff that call fails, too.

> Indeed, even with GPIOLIB=3Dy the pointer can be NULL if the "reset" =
(or
> "enable" in your scenario) is not present.
> From a functionality perspective, a NULL pointer for "reset" will res=
ult
> in the same behaviour as GPIOLIB=3Dn, ie: not being able to reset the=
 PHY.

Right, but you only get reset=3DNULL iff the device tree (or whatever i=
s
the source of information for gpiod_get) doesn't specify a reset gpio
which then means "This device doesn't need a reset gpio.". This is
different from the GPIOLIB=3Dn case, where the return code signals "It'=
s
unknown if the device needs a reset gpio.".

> So, the current code (your commit) and previous code (Daniel's commit=
)
> clearly points to "reset" being optional.
>=20
> Furthermore, I think we should not even register the
> "link_change_notify" callback when dealing with AT803x PHYs that do n=
ot
> require the hack.
> Another solution (considering the callback is statically registered i=
n
> the "phy_driver" structs for all AT803x PHYs) would be for the callba=
ck
> to disable itself.
> Once it detects that the PHY does not require the hack, it could just
> perform:
>=20
>     phydev->drv->link_change_notify =3D NULL;
>=20
> or call a new generic function to do the same if encapsulation is req=
uired.
>=20
> If everybody agrees I can make such change as well, but I really thin=
k
> Daniel should give his opinion first.
>=20
> >=20
> >> What would you think of making at803x_link_change_notify() print a
> >> message every time it should do a reset but does not has a way to =
do it?
> >=20
> > Then this question is obsolete because the device doesn't probe.
>=20
> I think you assume that "reset" is mandatory for all AT803x devices, =
but
> that's not what the code says.

No, you're wrong here. I'm aware that the code supports devices without
reset.

> As such, my proposal was to:
> - keep my proposed patch

I don't agree.

> - make another patch to print a warning when gpiod_reset is NULL (whi=
ch
>   can happen, even without my patch)

This only happens if no reset gpio is needed and in this case the drive=
r
does the right thing. So if you ask me, there is no need to modify the
driver. Better add a dependency to GPIOLIB. This is necessary even for
devices which don't need a reset gpio to answer the question "does this
driver need a reset gpio?" correctly.

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
