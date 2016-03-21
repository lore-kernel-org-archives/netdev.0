From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH] net: phy: at803x: don't depend on GPIOLIB
Date: Mon, 21 Mar 2016 21:12:29 +0100
Message-ID: <20160321201229.GA6191@pengutronix.de>
References: <56E99727.9040702@laposte.net>
 <20160318125455.GN4292@pengutronix.de>
 <56EC2525.8000706@laposte.net>
 <20160318191242.GQ4292@pengutronix.de>
 <56EFEDAD.9030903@laposte.net>
 <20160321135457.GX4292@pengutronix.de>
 <56F0150F.8080804@laposte.net>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <56F0150F.8080804@laposte.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Sebastian,

On Mon, Mar 21, 2016 at 04:36:47PM +0100, Sebastian Frias wrote:
> On 03/21/2016 02:54 PM, Uwe Kleine-K=F6nig wrote:
> >> - We'd also need to check that 'gpiod' is not NULL
> >=20
> > That is the optional part. If gpiod is NULL, you have one of the de=
vices
> > that don't need to handle the enable line.
>=20
> gpiod=3DNULL (because the key is not there) or gpiod=3DERR (because
> GPIOLIB=3Dn + my patch) will result in the same behaviour, ie: driver
> binds, but fails to reset.

Assuming the source for the hardware description is dt (the same
argument applies if it's ACPI or something else).

The driver uses devm_gpiod_get_optional(..."reset"...). That means some
hardware has a reset line, some don't. If a reset gpio specification is
there, that means the hardware has such a signal and it seems that mean=
s
it must not be ignored. If there is no reset gpio specification that
means that driver has to assume there is no reset line. (In the real
world there might be other reasons the reset line isn't in the device
tree, but it's not in the scope of the driver to guess why it's missing=
=2E
If it's not there the only sensible thing to assume for the driver is:
There is no reset line.)

So the conclusions are: If there is a reset line in dt, it must be used=
=2E
If you don't know if there is a reset line (because GPIOLIB=3Dn) the
driver should not bind. Everything else yields to more problems than
good.

> >> In the scenario at hand only some devices require a hack and
> >> gpiod_reset=3DNULL is valid (ie: device will not fail probing)
> >=20
> > With your patch and GPIOLIB=3Dn you bind the driver even for the de=
vices
> > that need the hack. This is broken!
>=20
> It is a degraded mode I agree and had proposed to print a warning.
> However, I fail to see how is GPIOLIB=3Dn different from just not hav=
ing
> "reset" present.

GPIOLIB=3Dn means "the driver doesn't know if a reset line is
present/necessary", not having reset means "there is no reset line".

And don't do error handling by printk assuming anyone will read it. Tha=
t
doesn't work.

> The fact that GPIOLIB=3Dy does not means that the "reset" key will be=
 there.

Right, but with GPIOLIB=3Dy you know if it's there, and if yes, you can
control the line.

> I mean, you assume that "reset" will be present for devices that need
> the hack, yet there is no such guarantee and the code clearly assumes
> that it can be missing.

The driver must assume that the device tree is right. If it's not fix
the device tree, don't implement clumsy work arounds in the driver.

> For all we know, the key is actually missing on systems that do use t=
he
> faulty PHY (all systems designed prior to the hack being implemented)
> And that, regardless of GPIOLIB status.

Then fix the device tree.

> Since the reset line can be missing, it can be missing for whatever r=
eason.
> Whether it is because the "reset" key is not present or because
> GPIOLIB=3Dn, it does not matter, it will result on the same outcome.
>=20
> Furthermore, if "reset" is really required for certain devices that n=
eed
> the hack, then both cases:
> - GPIOLIB=3Dn
> - "reset" not present
> should be handled the same way (ie: not bind the driver) for such dev=
ices.

If you can detect by other means that "reset is necessary", then yes,
the driver should ideally also fail in this case with no reset specifie=
d
in dt.

> By the way, I think not binding the driver is too strong too.
> Having a GPIO free and being able to route it to the PHY for reset ma=
y
> not even be possible on some systems.
> Are they supposed to stop working?

Sometimes no driver is better than an unreliable one.

> >>> For consistency I'd recommend to do the
> >>> same for reset even though there is a chance to get a working dev=
ice.
> >>
> >> I'm not so sure, because then information would be lost, handling =
both
> >> ("enable" and "reset") the same way aliases different intents and
> >> requirements.
> >> Indeed, only "enable" would be really mandatory, "reset" is essent=
ially
> >> optional (only 1 of 3 devices of the family require the hack).
> >>
> >> Besides, if "reset" was really mandatory, we would also fail the p=
robe
> >> if the pointer for the reset GPIO is NULL.
> >=20
> > No, if reset was mandatory you'd use gpiod_get instead of
> > gpiod_get_optional and fail iff that call fails, too.
>=20
> Ok, but the current code for "reset" is using devm_gpiod_get_optional=
()
> so "reset" is clearly optional.
> And that call will return NULL if "reset" is not present, even with
> GPIOLIB=3Dy

s/even//. And returning NULL is not an error. It means: There is no
reset line specified in dt.

> >> Indeed, even with GPIOLIB=3Dy the pointer can be NULL if the "rese=
t" (or
> >> "enable" in your scenario) is not present.
> >> From a functionality perspective, a NULL pointer for "reset" will =
result
> >> in the same behaviour as GPIOLIB=3Dn, ie: not being able to reset =
the PHY.
> >=20
> > Right, but you only get reset=3DNULL iff the device tree (or whatev=
er is
> > the source of information for gpiod_get) doesn't specify a reset gp=
io
> > which then means "This device doesn't need a reset gpio.". This is
> > different from the GPIOLIB=3Dn case, where the return code signals =
"It's
> > unknown if the device needs a reset gpio.".
>=20
> I think somehow you try to make a difference on the reason why the
> reset=3DINVALID (NULL or ERR), but IMHO there's none.

NULL is not invalid. With devm_gpiod_get_optional the driver asks: "Is
there a reset gpio, and if yes, which one?". The reset line is optional=
,
that means "some devices have one, some others don't.". It does NOT mea=
n
"You can ignore if there is a reset line or not."!

> If somebody using AT8030 PHY (the one that requires the hack) either
> does not configure a "reset" key on the DT, either does not enable
> GPIOLIB, the result will be the same.
> There is no warning in either case and it will run on a degraded mode=
=2E

My expectation is that if the dt includes a reset property, it should b=
e
used. So, there is a fine option for each situation:

 - device that doesn't need the hack =3D> everything is fine;
 - AT8030 with reset to a gpio =3D> specify the reset in dt;
 - AT8030 without a controllable reset line =3D> don't specify a reset
   property;

if you have a broken device with a reset line you can even drop the
reset property from dt and not make use of the reset gpio if you think
it's a good idea.

> >>>> What would you think of making at803x_link_change_notify() print=
 a
> >>>> message every time it should do a reset but does not has a way t=
o do it?
> >>>
> >>> Then this question is obsolete because the device doesn't probe.
> >>
> >> I think you assume that "reset" is mandatory for all AT803x device=
s, but
> >> that's not what the code says.
> >=20
> > No, you're wrong here. I'm aware that the code supports devices wit=
hout
> > reset.
>=20
> Ok, then I did not understand what you meant with "the question is
> obsolete because the device doesn't probe".

  if (GPIOLIB=3Dy):
    if (device has a reset property):
      driver runs fine with being able to reset.
    else:
      if (device needs reset to function properly):
        ideally fail to probe
      else:
        driver runs fine without reset and without the need
	  to bother the user about the absense of the gpio
  else:
    driver fails to bind

In no branch of these cases there is a situation where you must issue a
reset but cannot. So there is no need to ask if you should issue a
message each time this happens. That's what I meant with "the question
is obsolete".

> Unless I'm missing something, the only way the driver won't bind
> correctly with current code is if GPIOLIB=3Dn

Right, because with GPIOLIB=3Dn you cannot control a gpio line, but you
don't know if you must.

Consider you are an electrician (driver) and you should repair a power
socket (control a device) but forgot your phase tester (GPIOLIB=3Dn).
So there is no way you can determine if it's save to modify the socket.
You can choose the optimistic way and say: "If there is no voltage on t=
he
socket, I can repair it successfully" and just try it. Or you take the
safe approach and say: "I don't know if it's safe to do, so I better
don't.".

The same applies to drivers: If it might be necessary to handle a gpio,
but you cannot know if that's the case or not: Don't try it.

> Systems using the faulty PHY and having GPIOLIB=3Dy but with an outda=
ted
> DT that does not has a "reset" key would have the PHY driver bind yet
> have it fail due to missing "reset".

dt compatibility is fine. So if you want to handle the situation
properly, change the compatible and there make sure that the presence o=
r
absence of the reset property matches reality with the new binding. And
continue to handle the old compatible the way you did before. But don't
ignore errors returned by gpiod_get et al.

> >> - make another patch to print a warning when gpiod_reset is NULL (=
which
> >>   can happen, even without my patch)
> >=20
> > This only happens if no reset gpio is needed and in this case the d=
river
> > does the right thing. So if you ask me, there is no need to modify =
the
> > driver. Better add a dependency to GPIOLIB. This is necessary even =
for
> > devices which don't need a reset gpio to answer the question "does =
this
> > driver need a reset gpio?" correctly.
>=20
> I don't see how the dependency on GPIOLIB=3Dy improves the situation =
in
> any useful way.
>=20
> To put an example: in our case we don't use the faulty PHY.
> So, the DT does not has the "reset" key.
> Why should then the PHY driver be dependent on GPIOLIB?

You want GPIOLIB to know that you don't need to handle the reset gpio.

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
