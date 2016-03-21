From: Sebastian Frias <sf84@laposte.net>
Subject: Re: [PATCH] net: phy: at803x: don't depend on GPIOLIB
Date: Mon, 21 Mar 2016 16:36:47 +0100
Message-ID: <56F0150F.8080804@laposte.net>
References: <56E99727.9040702@laposte.net> <20160318125455.GN4292@pengutronix.de> <56EC2525.8000706@laposte.net> <20160318191242.GQ4292@pengutronix.de> <56EFEDAD.9030903@laposte.net> <20160321135457.GX4292@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Daniel Mack <daniel@zonque.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>, mason <slash.tmp@free.fr>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Mans Rullgard <mans@mansr.com>,
	Fabio Estevam <festevam@gmail.com>,
	Martin Blumenstingl <martin.blumenstingl@gmail.com>,
	Linus Walleij <linus.walleij@linaro.org>
To: =?windows-1252?Q?Uwe_Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160321135457.GX4292@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Uwe,

On 03/21/2016 02:54 PM, Uwe Kleine-K=F6nig wrote:
>>
>> Two things:
>> - I suppose that in such hypothetical case the dependency on GPIOLIB
>>   would be required and thus be there
>=20
> I don't agree. There are bugs out there, and maybe the reason is as
> simple as "the implementor of the reset-gpio handling had GPIOLIB on =
and
> didn't test without GPIOLIB".

:-) fair enough, let's wait for his comments then.

>=20
>> - We'd also need to check that 'gpiod' is not NULL
>=20
> That is the optional part. If gpiod is NULL, you have one of the devi=
ces
> that don't need to handle the enable line.

gpiod=3DNULL (because the key is not there) or gpiod=3DERR (because
GPIOLIB=3Dn + my patch) will result in the same behaviour, ie: driver
binds, but fails to reset.

>=20
>> In the scenario at hand only some devices require a hack and
>> gpiod_reset=3DNULL is valid (ie: device will not fail probing)
>=20
> With your patch and GPIOLIB=3Dn you bind the driver even for the devi=
ces
> that need the hack. This is broken!

It is a degraded mode I agree and had proposed to print a warning.
However, I fail to see how is GPIOLIB=3Dn different from just not havin=
g
"reset" present.

The fact that GPIOLIB=3Dy does not means that the "reset" key will be t=
here.
I mean, you assume that "reset" will be present for devices that need
the hack, yet there is no such guarantee and the code clearly assumes
that it can be missing.
=46or all we know, the key is actually missing on systems that do use t=
he
faulty PHY (all systems designed prior to the hack being implemented)
And that, regardless of GPIOLIB status.

Since the reset line can be missing, it can be missing for whatever rea=
son.
Whether it is because the "reset" key is not present or because
GPIOLIB=3Dn, it does not matter, it will result on the same outcome.

=46urthermore, if "reset" is really required for certain devices that n=
eed
the hack, then both cases:
- GPIOLIB=3Dn
- "reset" not present
should be handled the same way (ie: not bind the driver) for such devic=
es.

By the way, I think not binding the driver is too strong too.
Having a GPIO free and being able to route it to the PHY for reset may
not even be possible on some systems.
Are they supposed to stop working?

>=20
>>> For consistency I'd recommend to do the
>>> same for reset even though there is a chance to get a working devic=
e.
>>
>> I'm not so sure, because then information would be lost, handling bo=
th
>> ("enable" and "reset") the same way aliases different intents and
>> requirements.
>> Indeed, only "enable" would be really mandatory, "reset" is essentia=
lly
>> optional (only 1 of 3 devices of the family require the hack).
>>
>> Besides, if "reset" was really mandatory, we would also fail the pro=
be
>> if the pointer for the reset GPIO is NULL.
>=20
> No, if reset was mandatory you'd use gpiod_get instead of
> gpiod_get_optional and fail iff that call fails, too.

Ok, but the current code for "reset" is using devm_gpiod_get_optional()
so "reset" is clearly optional.
And that call will return NULL if "reset" is not present, even with
GPIOLIB=3Dy

>=20
>> Indeed, even with GPIOLIB=3Dy the pointer can be NULL if the "reset"=
 (or
>> "enable" in your scenario) is not present.
>> From a functionality perspective, a NULL pointer for "reset" will re=
sult
>> in the same behaviour as GPIOLIB=3Dn, ie: not being able to reset th=
e PHY.
>=20
> Right, but you only get reset=3DNULL iff the device tree (or whatever=
 is
> the source of information for gpiod_get) doesn't specify a reset gpio
> which then means "This device doesn't need a reset gpio.". This is
> different from the GPIOLIB=3Dn case, where the return code signals "I=
t's
> unknown if the device needs a reset gpio.".

I think somehow you try to make a difference on the reason why the
reset=3DINVALID (NULL or ERR), but IMHO there's none.

If somebody using AT8030 PHY (the one that requires the hack) either
does not configure a "reset" key on the DT, either does not enable
GPIOLIB, the result will be the same.
There is no warning in either case and it will run on a degraded mode.

>=20
>> So, the current code (your commit) and previous code (Daniel's commi=
t)
>> clearly points to "reset" being optional.
>>
>> Furthermore, I think we should not even register the
>> "link_change_notify" callback when dealing with AT803x PHYs that do =
not
>> require the hack.
>> Another solution (considering the callback is statically registered =
in
>> the "phy_driver" structs for all AT803x PHYs) would be for the callb=
ack
>> to disable itself.
>> Once it detects that the PHY does not require the hack, it could jus=
t
>> perform:
>>
>>     phydev->drv->link_change_notify =3D NULL;
>>
>> or call a new generic function to do the same if encapsulation is re=
quired.
>>
>> If everybody agrees I can make such change as well, but I really thi=
nk
>> Daniel should give his opinion first.
>>
>>>
>>>> What would you think of making at803x_link_change_notify() print a
>>>> message every time it should do a reset but does not has a way to =
do it?
>>>
>>> Then this question is obsolete because the device doesn't probe.
>>
>> I think you assume that "reset" is mandatory for all AT803x devices,=
 but
>> that's not what the code says.
>=20
> No, you're wrong here. I'm aware that the code supports devices witho=
ut
> reset.

Ok, then I did not understand what you meant with "the question is
obsolete because the device doesn't probe".
Unless I'm missing something, the only way the driver won't bind
correctly with current code is if GPIOLIB=3Dn

Systems using the faulty PHY and having GPIOLIB=3Dy but with an outdate=
d
DT that does not has a "reset" key would have the PHY driver bind yet
have it fail due to missing "reset".

>=20
>> As such, my proposal was to:
>> - keep my proposed patch
>=20
> I don't agree.
>=20
>> - make another patch to print a warning when gpiod_reset is NULL (wh=
ich
>>   can happen, even without my patch)
>=20
> This only happens if no reset gpio is needed and in this case the dri=
ver
> does the right thing. So if you ask me, there is no need to modify th=
e
> driver. Better add a dependency to GPIOLIB. This is necessary even fo=
r
> devices which don't need a reset gpio to answer the question "does th=
is
> driver need a reset gpio?" correctly.

I don't see how the dependency on GPIOLIB=3Dy improves the situation in
any useful way.

To put an example: in our case we don't use the faulty PHY.
So, the DT does not has the "reset" key.
Why should then the PHY driver be dependent on GPIOLIB?

Best regards,

Sebastian
