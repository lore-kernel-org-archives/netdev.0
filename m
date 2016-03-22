From: Sebastian Frias <sf84@laposte.net>
Subject: Re: [PATCH] net: phy: at803x: don't depend on GPIOLIB
Date: Tue, 22 Mar 2016 15:34:23 +0100
Message-ID: <56F157EF.5080307@laposte.net>
References: <56E99727.9040702@laposte.net> <20160318125455.GN4292@pengutronix.de> <56EC2525.8000706@laposte.net> <20160318191242.GQ4292@pengutronix.de> <56EFEDAD.9030903@laposte.net> <20160321135457.GX4292@pengutronix.de> <56F0150F.8080804@laposte.net> <20160321201229.GA6191@pengutronix.de>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpoutz25.laposte.net ([194.117.213.100]:56722 "EHLO
	smtp.laposte.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751991AbcCVOe0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2016 10:34:26 -0400
Received: from smtp.laposte.net (localhost [127.0.0.1])
	by lpn-prd-vrout013 (Postfix) with ESMTP id B7D6B103C60
	for <netdev@vger.kernel.org>; Tue, 22 Mar 2016 15:34:24 +0100 (CET)
Received: from lpn-prd-vrin001 (lpn-prd-vrin001.prosodie [10.128.63.2])
	by lpn-prd-vrout013 (Postfix) with ESMTP id 96218103ED4
	for <netdev@vger.kernel.org>; Tue, 22 Mar 2016 15:34:24 +0100 (CET)
Received: from lpn-prd-vrin001 (localhost [127.0.0.1])
	by lpn-prd-vrin001 (Postfix) with ESMTP id 5D10D365438
	for <netdev@vger.kernel.org>; Tue, 22 Mar 2016 15:34:24 +0100 (CET)
In-Reply-To: <20160321201229.GA6191@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Uwe,

I think we are in a deadlock :-)
I'm going to reply inline below, but I will also send a different email
to Daniel with a small recap.
I think he should share the intent of the "reset" mechanism he
introduced, in particular if it is mandatory.


On 03/21/2016 09:12 PM, Uwe Kleine-K=F6nig wrote:
>>
>> gpiod=3DNULL (because the key is not there) or gpiod=3DERR (because
>> GPIOLIB=3Dn + my patch) will result in the same behaviour, ie: drive=
r
>> binds, but fails to reset.
>=20
> Assuming the source for the hardware description is dt (the same
> argument applies if it's ACPI or something else).
>=20
> The driver uses devm_gpiod_get_optional(..."reset"...). That means so=
me
> hardware has a reset line, some don't. If a reset gpio specification =
is
> there, that means the hardware has such a signal and it seems that me=
ans
> it must not be ignored.=20

The problem is all those "it seems" :-)
"it seems it must not be ignored" is also an hypothesis considering the
driver is not refusing to work even if it detects that the faulty PHY
has not been provided with a reset line.
Also, further down the thread you acknowledge that's a possibility.

>If there is no reset gpio specification that
> means that driver has to assume there is no reset line. (In the real
> world there might be other reasons the reset line isn't in the device
> tree, but it's not in the scope of the driver to guess why it's missi=
ng.
> If it's not there the only sensible thing to assume for the driver is=
:
> There is no reset line.)

But that is not what the current code does, the current code does not
checks if the DT presents the "reset" property directly.
It assumes that GPIOLIB works and checks GPIOLIB return codes, to
indirectly (and incorrectly) guess if a given device has a "reset" prop=
erty.
It has not been clearly explained anywhere that the "reset" property fo=
r
AT8030 is supposed to be mandatory and that the driver should fail if
not provided with one.
The code does not back up such hypothesis either, ie: GPIOLIB=3Dy +
missing "reset" will still allow the driver to work.

>=20
> So the conclusions are: If there is a reset line in dt, it must be us=
ed.
> If you don't know if there is a reset line (because GPIOLIB=3Dn) the
> driver should not bind. Everything else yields to more problems than
> good.

a) "If there is a reset line in dt, it must be used": that is an
hypothesis (I would say "it can be used");
b) if it were true, then another way of knowing if the "reset" key is
present should be used;
indeed, there should be:
c) a way to unambiguously determine if the "reset" key is in the DT
(regardless of GPIOLIB status);
that in order to know if the DT is specifying that the "reset" mechanis=
m
must be used, then:
d) iff the "reset" is absolutely necessary (ie: the faulty PHY is in us=
e
AND the original intention of the hack was for it *mandatory* for fault=
y
PHYs), some decision can be taken;

However, right now those conditions are not met.

>>> With your patch and GPIOLIB=3Dn you bind the driver even for the de=
vices
>>> that need the hack. This is broken!
>>
>> It is a degraded mode I agree and had proposed to print a warning.
>> However, I fail to see how is GPIOLIB=3Dn different from just not ha=
ving
>> "reset" present.
>=20
> GPIOLIB=3Dn means "the driver doesn't know if a reset line is
> present/necessary", not having reset means "there is no reset line".

That's the problem, that the driver is relying on GPIOLIB to know if:
- "reset" key is present
- it should fail to bind or not

and it does that based solely on GPIOLIB return codes, thus indirectly.
As opposed to checking directly the presence of the "reset" key
(regardless of GPIOLIB status) and failing immediately.

>=20
> And don't do error handling by printk assuming anyone will read it. T=
hat
> doesn't work.

I proposed a warning, not error handling.
Also if we assume people won't read the logs, why put any at all?
Some people may not read the logs, some others will, it is their choice
to bang their heads one way or another.
Currently there's no warning.
So I had to debug why the driver was not binding, and it is not obvious
that GPIOLIB must be selected, considering:
- I don't have a faulty PHY
- I don't have a "reset" key on DT
- Even if I wanted, I don't have a GPIO to connect to it

(also, even if this driver does not bind, some generic one would take o=
ver)

>=20
>> The fact that GPIOLIB=3Dy does not means that the "reset" key will b=
e there.
>=20
> Right, but with GPIOLIB=3Dy you know if it's there, and if yes, you c=
an
> control the line.

Exactly, and what I say is that knowing if "reset" is there or not
should not depend on having GPIOLIB=3Dy

To me the problem comes from the aliasing between "GPIOLIB=3Dy" and
"reset" present.
Indeed, the driver should query if the "reset" key is present
(regardless of GPIOLIB status), and then try to acquire the GPIO line.
If it cannot get the reset GPIO, then it can give up saying "you told m=
e
I need a reset line but then you did not give me one".

>=20
>> I mean, you assume that "reset" will be present for devices that nee=
d
>> the hack, yet there is no such guarantee and the code clearly assume=
s
>> that it can be missing.
>=20
> The driver must assume that the device tree is right. If it's not fix
> the device tree, don't implement clumsy work arounds in the driver.

I doubt it is like that.
I mean, it may sound easy to say "just update the DT and add the 'reset=
'
key", but the DT is describing a physical connections in this case.
Changing that may not be as easy.

IMHO it would be far better if the driver made the check on the PHY ID
(8030) at probe time and refused to bind if:
- the "reset" is absolutely necessary per design (ie: intended by Danie=
l)
and
- it did not get a reset line (for whatever reason).

That was not done.
Maybe because it is not possible because the ID may not be known at tha=
t
time (strange since it is being probed);
Maybe because Daniel meant the whole thing to be optional;
Or maybe for other reasons.

>=20
>> For all we know, the key is actually missing on systems that do use =
the
>> faulty PHY (all systems designed prior to the hack being implemented=
)
>> And that, regardless of GPIOLIB status.
>=20
> Then fix the device tree.

Changing the device tree does not automagically creates a connection
between a given GPIO (which must be available) and the PHY reset line.
GPIOs and reset lines are physical things.

But maybe I'm missing something and board designers always route GPIOs
to each and every peripheral's reset line.

>=20
>> Since the reset line can be missing, it can be missing for whatever =
reason.
>> Whether it is because the "reset" key is not present or because
>> GPIOLIB=3Dn, it does not matter, it will result on the same outcome.
>>
>> Furthermore, if "reset" is really required for certain devices that =
need
>> the hack, then both cases:
>> - GPIOLIB=3Dn
>> - "reset" not present
>> should be handled the same way (ie: not bind the driver) for such de=
vices.
>=20
> If you can detect by other means that "reset is necessary", then yes,
> the driver should ideally also fail in this case with no reset specif=
ied
> in dt.

Well, the problem is that right now we don't know what was the intentio=
n
of the person that implemented the "reset" mechanism.
Both of us are arguing about our own hypothesis.
You have yours "reset is necessary and driver should not bind without".
And I have mine "nothing in the code implies it is necessary".

>=20
>> By the way, I think not binding the driver is too strong too.
>> Having a GPIO free and being able to route it to the PHY for reset m=
ay
>> not even be possible on some systems.
>> Are they supposed to stop working?
>=20
> Sometimes no driver is better than an unreliable one.

It appears that if this driver does not binds, then a generic one (whic=
h
arguably will also lack the reset behaviour) will take over.
How can that be any better?

>>>
>>> No, if reset was mandatory you'd use gpiod_get instead of
>>> gpiod_get_optional and fail iff that call fails, too.
>>
>> Ok, but the current code for "reset" is using devm_gpiod_get_optiona=
l()
>> so "reset" is clearly optional.
>> And that call will return NULL if "reset" is not present, even with
>> GPIOLIB=3Dy
>=20
> s/even//. And returning NULL is not an error. It means: There is no
> reset line specified in dt.

Indeed, and it is totally possible that the PHY ID is a faulty one, yet
the driver will bind anyway.
You argue about a case "reset is absolutely necessary for some devices"=
,
but the code does not enforce that.

>>
>> I think somehow you try to make a difference on the reason why the
>> reset=3DINVALID (NULL or ERR), but IMHO there's none.
>=20
> NULL is not invalid. With devm_gpiod_get_optional the driver asks: "I=
s
> there a reset gpio, and if yes, which one?". The reset line is option=
al,
> that means "some devices have one, some others don't.". It does NOT m=
ean
> "You can ignore if there is a reset line or not."!

But the current code does ignore it :-)
Even for faulty devices.

Again, if you take a faulty PHY and a DT without the "reset" key, the
driver will bind.
Don't you think that goes against your hypothesis of "reset must be
present and available for some devices"?

By the way, is the "reset" key documented somewhere? How would the DT
look like?
Maybe in such documentation there's some explanation about the key bein=
g
compulsory or not.

>=20
>> If somebody using AT8030 PHY (the one that requires the hack) either
>> does not configure a "reset" key on the DT, either does not enable
>> GPIOLIB, the result will be the same.
>> There is no warning in either case and it will run on a degraded mod=
e.
>=20
> My expectation is that if the dt includes a reset property, it should=
 be
> used. So, there is a fine option for each situation:
>=20
>  - device that doesn't need the hack =3D> everything is fine;
>  - AT8030 with reset to a gpio =3D> specify the reset in dt;
>  - AT8030 without a controllable reset line =3D> don't specify a rese=
t
>    property;

You do realise that in this last case the device will work in degraded
mode, right?

>=20
> if you have a broken device with a reset line you can even drop the
> reset property from dt and not make use of the reset gpio if you thin=
k
> it's a good idea.
>=20

So you are saying that "reset" is optional, even for faulty PHYs.

>>
>> Ok, then I did not understand what you meant with "the question is
>> obsolete because the device doesn't probe".
>=20
>   if (GPIOLIB=3Dy):
>     if (device has a reset property):
>       driver runs fine with being able to reset.
>     else:
>       if (device needs reset to function properly):
>         ideally fail to probe
>       else:
>         driver runs fine without reset and without the need
> 	  to bother the user about the absense of the gpio
>   else:
>     driver fails to bind

To me it should be:

   if (device needs reset):
      if (DT has reset):
         if (GPIOLIB=3Dy):
            gpiod=3Dcallback, driver gets a reset line and can operate
properly (ie: perform the hack)
         else
            gpiod=3D-ENOSYS, driver does not get reset line: should it
fail to bind? should it continue?
      else
         gpiod=3DNULL, driver does not get a reset line: should it fail=
 to
bind? should it continue?
   else
      gpiod is not even requested, driver does not need a reset line an=
d
can operate properly.

>=20
> In no branch of these cases there is a situation where you must issue=
 a
> reset but cannot.=20

Well, the thing is that what you described does not match the code,
AFAIK current code does:

   if (GPIOLIB=3Dy):
      if (DT has reset):
         gpiod=3Dcallback
         bind driver
         if (faulty PHY):
            use gpiod
      else
         gpiod=3DNULL
         bind driver
         if (faulty PHY)
            cannot use gpiod, but continue anyway without warning
   else
      gpiod=3D-ENOSYS, fail to bind, regardless of PHY being faulty, an=
d
regardless of "reset" presence (*)


(*) the way the code is written, "reset" presence is not checked
directly, but as a side-effect of GPIOLIB

>So there is no need to ask if you should issue a
> message each time this happens. That's what I meant with "the questio=
n
> is obsolete".
>=20
>> Unless I'm missing something, the only way the driver won't bind
>> correctly with current code is if GPIOLIB=3Dn
>=20
> Right, because with GPIOLIB=3Dn you cannot control a gpio line, but y=
ou
> don't know if you must.

Well right now nobody knows if the "reset" is actually a must, even for
faulty PHYs.
The driver binds happily without, even on faulty devices.

>=20
> Consider you are an electrician (driver) and you should repair a powe=
r
> socket (control a device) but forgot your phase tester (GPIOLIB=3Dn).
> So there is no way you can determine if it's save to modify the socke=
t.
> You can choose the optimistic way and say: "If there is no voltage on=
 the
> socket, I can repair it successfully" and just try it. Or you take th=
e
> safe approach and say: "I don't know if it's safe to do, so I better
> don't.".

:-) thanks for the analogy.

>=20
> The same applies to drivers: If it might be necessary to handle a gpi=
o,
> but you cannot know if that's the case or not: Don't try it.
>=20

But that's not how the code was written.
It is not mentioned anywhere that that was the initial intention either=
=2E

>>
>> To put an example: in our case we don't use the faulty PHY.
>> So, the DT does not has the "reset" key.
>> Why should then the PHY driver be dependent on GPIOLIB?
>=20
> You want GPIOLIB to know that you don't need to handle the reset gpio=
=2E

But that's like saying "you want all possible drivers linked-in, if the=
y
are not in DT they won't load/probe, so it's fine"

We don't want GPIOLIB because it is a bunch of useless code in our case=
=2E
We know in advance that the DT will not have the "reset" key.
We know in advance that the PHY is not faulty.
Why should we link-in a bunch of useless code then?

Alternatively, if GPIOLIB is mandatory due to the way drivers are
written or the way DT works, then why make it optional?

Best regards,

Sebastian
