From: Sebastian Frias <sf84@laposte.net>
Subject: Re: [PATCH] net: phy: at803x: don't depend on GPIOLIB
Date: Mon, 21 Mar 2016 13:48:45 +0100
Message-ID: <56EFEDAD.9030903@laposte.net>
References: <56E99727.9040702@laposte.net> <20160318125455.GN4292@pengutronix.de> <56EC2525.8000706@laposte.net> <20160318191242.GQ4292@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>, mason <slash.tmp@free.fr>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Mans Rullgard <mans@mansr.com>,
	Fabio Estevam <festevam@gmail.com>,
	Martin Blumenstingl <martin.blumenstingl@gmail.com>,
	Linus Walleij <linus.walleij@linaro.org>
To: =?windows-1252?Q?Uwe_Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>, Daniel Mack <daniel@zonque.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160318191242.GQ4292@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Uwe,

On 03/18/2016 08:12 PM, Uwe Kleine-K=F6nig wrote:
> Hello Sebastian,
>=20
> On Fri, Mar 18, 2016 at 04:56:21PM +0100, Sebastian Frias wrote:
>> On 03/18/2016 01:54 PM, Uwe Kleine-K=F6nig wrote:
>>> From a driver perspecitive, it would be nice if devm_gpiod_get_opti=
onal
>>> returned NULL iff the respective gpio isn't specified even with
>>> GPIOLIB=3Dn, but this isn't sensible either because it would result=
 in
>>> quite some gpiolib code to not being conditionally compiled on
>>> CONFIG_GPIOLIB any more.
>>
>> Let's say that was the case, what would the PHY code do?
>=20
> With reset gpios it might not be that critical, but consider an optio=
nal
> enable gpio. (Optional in the sense, that some device have it and oth=
ers
> don't, e.g. because the pin is pulled into active level by hardware.)
>=20
> Now you do:
>=20
> 	gpiod =3D gpiod_get_optional("enable");
>=20
> and if gpiod now is an error pointer, you must assume that you cannot
> operate the device. And even with GPIOLIB=3Dn (and gpiod =3D ERR_PTR(=
-ENOSYS))
> you cannot ignore the error.=20

Two things:
- I suppose that in such hypothetical case the dependency on GPIOLIB
would be required and thus be there
- We'd also need to check that 'gpiod' is not NULL

In the scenario at hand only some devices require a hack and
gpiod_reset=3DNULL is valid (ie: device will not fail probing)

>For consistency I'd recommend to do the
> same for reset even though there is a chance to get a working device.

I'm not so sure, because then information would be lost, handling both
("enable" and "reset") the same way aliases different intents and
requirements.
Indeed, only "enable" would be really mandatory, "reset" is essentially
optional (only 1 of 3 devices of the family require the hack).

Besides, if "reset" was really mandatory, we would also fail the probe
if the pointer for the reset GPIO is NULL.
Indeed, even with GPIOLIB=3Dy the pointer can be NULL if the "reset" (o=
r
"enable" in your scenario) is not present.
=46rom a functionality perspective, a NULL pointer for "reset" will res=
ult
in the same behaviour as GPIOLIB=3Dn, ie: not being able to reset the P=
HY.

So, the current code (your commit) and previous code (Daniel's commit)
clearly points to "reset" being optional.

=46urthermore, I think we should not even register the
"link_change_notify" callback when dealing with AT803x PHYs that do not
require the hack.
Another solution (considering the callback is statically registered in
the "phy_driver" structs for all AT803x PHYs) would be for the callback
to disable itself.
Once it detects that the PHY does not require the hack, it could just
perform:

    phydev->drv->link_change_notify =3D NULL;

or call a new generic function to do the same if encapsulation is requi=
red.

If everybody agrees I can make such change as well, but I really think
Daniel should give his opinion first.

>=20
>> What would you think of making at803x_link_change_notify() print a
>> message every time it should do a reset but does not has a way to do=
 it?
>=20
> Then this question is obsolete because the device doesn't probe.

I think you assume that "reset" is mandatory for all AT803x devices, bu=
t
that's not what the code says.

As such, my proposal was to:
- keep my proposed patch
- make another patch to print a warning when gpiod_reset is NULL (which
can happen, even without my patch)

What do you think?

Best regards,

Sebastian
