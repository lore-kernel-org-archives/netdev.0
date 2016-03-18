From: Sebastian Frias <sf84@laposte.net>
Subject: Re: [PATCH] net: phy: at803x: don't depend on GPIOLIB
Date: Fri, 18 Mar 2016 16:56:21 +0100
Message-ID: <56EC2525.8000706@laposte.net>
References: <56E99727.9040702@laposte.net> <20160318125455.GN4292@pengutronix.de>
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
Received: from smtpoutz25.laposte.net ([194.117.213.100]:46443 "EHLO
	smtp.laposte.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933569AbcCRP42 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2016 11:56:28 -0400
Received: from smtp.laposte.net (localhost [127.0.0.1])
	by lpn-prd-vrout013 (Postfix) with ESMTP id 699FF10409E
	for <netdev@vger.kernel.org>; Fri, 18 Mar 2016 16:56:23 +0100 (CET)
Received: from lpn-prd-vrin004 (lpn-prd-vrin004.prosodie [10.128.63.5])
	by lpn-prd-vrout013 (Postfix) with ESMTP id 13B7E103F5F
	for <netdev@vger.kernel.org>; Fri, 18 Mar 2016 16:56:23 +0100 (CET)
Received: from lpn-prd-vrin004 (localhost [127.0.0.1])
	by lpn-prd-vrin004 (Postfix) with ESMTP id BA19F70E268
	for <netdev@vger.kernel.org>; Fri, 18 Mar 2016 16:56:22 +0100 (CET)
In-Reply-To: <20160318125455.GN4292@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Uwe, Daniel,

On 03/18/2016 01:54 PM, Uwe Kleine-K=F6nig wrote:
> [expand cc a bit more]
>=20
> Hello,
>=20
> On Wed, Mar 16, 2016 at 06:25:59PM +0100, Sebastian Frias wrote:
>> Commit 687908c2b649 ("net: phy: at803x: simplify using
>> devm_gpiod_get_optional and its 4th argument") introduced a dependen=
cy
>> on GPIOLIB that was not there before.
>>
>> This commit removes such dependency by checking the return code and
>> comparing it against ENOSYS which is returned when GPIOLIB is not
>> selected.
>>
>> Fixes: 687908c2b649 ("net: phy: at803x: simplify using devm_gpiod_ge=
t_optional and its 4th argument")
>>
>> Signed-off-by: Sebastian Frias <sf84@laposte.net>
>> ---
>>  drivers/net/phy/at803x.c | 4 +++-
>>  1 file changed, 3 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
>> index 2174ec9..88b7ff3 100644
>> --- a/drivers/net/phy/at803x.c
>> +++ b/drivers/net/phy/at803x.c
>> @@ -252,7 +252,9 @@ static int at803x_probe(struct phy_device *phyde=
v)
>>  		return -ENOMEM;
>>
>>  	gpiod_reset =3D devm_gpiod_get_optional(dev, "reset", GPIOD_OUT_HI=
GH);
>> -	if (IS_ERR(gpiod_reset))
>> +	if (PTR_ERR(gpiod_reset) =3D=3D -ENOSYS)
>> +		gpiod_reset =3D NULL;
>> +	else if (IS_ERR(gpiod_reset))
>=20
> this isn't better either (IMHO it's worse, but maybe this is debatabl=
e
> and also depends on your POV).

Well, from the code, the reset hack is only required when the PHY is
ATH8030_PHY_ID, right?
However, such change was introduced by Daniel Mack on commit 13a56b4493=
25.
Hopefully he can chime in and give his opinion on this.

Daniel, while on the subject, I have a question for you:

Change 2b8f2a28eac1 introduced "link_status_notify" callback which is
called systematically on the PHY state machine.
Any reason to make the call systematic as opposed to let say:

	if (phydev->state !=3D old_state) {
		if (phydev->drv->link_change_notify)
			phydev->drv->link_change_notify(phydev);
	}

(it does means that the callback would be called after the state machin=
e
processing though)

>=20
> With 687908c2b649 I made kernels without GPIOLIB fail to bind this
> device. I admit this is not maximally nice.

I see, that was not clear from the commit message, sorry.

>=20
> Your change makes the driver bind in this case again and then the res=
et
> gpio isn't handled at all which might result in a later and harder to
> debug error.
>=20
> The better approach to fix your problem is: make the driver depend (o=
r
> force) on GPIOLIB.=20

It was one of the solutions I had in mind, but:
- since the dependency on GPIOLIB was not included on the patch
- and given that the previous code had provision to work without GPIO
I thought it was an overlook.

>Or alternatively, drop reset-handling from the
> driver.
>=20
> From a driver perspecitive, it would be nice if devm_gpiod_get_option=
al
> returned NULL iff the respective gpio isn't specified even with
> GPIOLIB=3Dn, but this isn't sensible either because it would result i=
n
> quite some gpiolib code to not being conditionally compiled on
> CONFIG_GPIOLIB any more.

Let's say that was the case, what would the PHY code do?

I mean, it did not get a GPIO, whether it was because GPIOLIB=3Dn or
because there's no 'reset' GPIO attached
Shall it fail? Shall it continue in a sort of degraded mode? Shall it w=
arn?
Because that's the real question here.

What would you think of making at803x_link_change_notify() print a
message every time it should do a reset but does not has a way to do it=
?
I can make such change to my patch if everybody agrees on it.
By the way, in that case, can somebody suggest a way to print such warn=
ing?
Would printk() be ok or should I use dev_dbg() ?

Best regards,

Sebastian

>=20
> Best regards
> Uwe
>=20
