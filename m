From: Sebastian Frias <sf84@laposte.net>
Subject: Re: [PATCH] net: phy: at803x: don't depend on GPIOLIB
Date: Tue, 22 Mar 2016 15:34:39 +0100
Message-ID: <56F157FF.7080804@laposte.net>
References: <56E99727.9040702@laposte.net> <20160318125455.GN4292@pengutronix.de> <56EC2525.8000706@laposte.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?windows-1252?Q?Uwe_Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>, mason <slash.tmp@free.fr>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Mans Rullgard <mans@mansr.com>,
	Fabio Estevam <festevam@gmail.com>,
	Martin Blumenstingl <martin.blumenstingl@gmail.com>,
	Linus Walleij <linus.walleij@linaro.org>
To: Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpoutz298.laposte.net ([178.22.154.198]:58798 "EHLO
	smtp.laposte.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758835AbcCVOen (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2016 10:34:43 -0400
Received: from smtp.laposte.net (localhost [127.0.0.1])
	by lpn-prd-vrout010 (Postfix) with ESMTP id 8AEED45A1BF
	for <netdev@vger.kernel.org>; Tue, 22 Mar 2016 15:34:40 +0100 (CET)
Received: from lpn-prd-vrin004 (lpn-prd-vrin004.laposte [10.128.63.5])
	by lpn-prd-vrout010 (Postfix) with ESMTP id 859DB459D1C
	for <netdev@vger.kernel.org>; Tue, 22 Mar 2016 15:34:40 +0100 (CET)
Received: from lpn-prd-vrin004 (localhost [127.0.0.1])
	by lpn-prd-vrin004 (Postfix) with ESMTP id 6FDC970E2B3
	for <netdev@vger.kernel.org>; Tue, 22 Mar 2016 15:34:40 +0100 (CET)
In-Reply-To: <56EC2525.8000706@laposte.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel,

Would you mind commenting on this thread?
Uwe and I are in a sort of deadlock because we each have a different
understanding of the intention of your commit 13a56b449325.

Basically the questions are:
- What is the intention of 13a56b449325?
- Did you mean for "reset" to be mandatory for faulty PHYs?
Mandatory meaning that you do not want the driver to work without.
- What do you think about the dependency on GPIOLIB?
You did not introduced such dependency with your change so it may point
to "reset" not being mandatory.

Best regards,

Sebastian

On 03/18/2016 04:56 PM, Sebastian Frias wrote:
> Hi Uwe, Daniel,
>=20
> On 03/18/2016 01:54 PM, Uwe Kleine-K=F6nig wrote:
>> [expand cc a bit more]
>>
>> Hello,
>>
>> On Wed, Mar 16, 2016 at 06:25:59PM +0100, Sebastian Frias wrote:
>>> Commit 687908c2b649 ("net: phy: at803x: simplify using
>>> devm_gpiod_get_optional and its 4th argument") introduced a depende=
ncy
>>> on GPIOLIB that was not there before.
>>>
>>> This commit removes such dependency by checking the return code and
>>> comparing it against ENOSYS which is returned when GPIOLIB is not
>>> selected.
>>>
>>> Fixes: 687908c2b649 ("net: phy: at803x: simplify using devm_gpiod_g=
et_optional and its 4th argument")
>>>
>>> Signed-off-by: Sebastian Frias <sf84@laposte.net>
>>> ---
>>>  drivers/net/phy/at803x.c | 4 +++-
>>>  1 file changed, 3 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
>>> index 2174ec9..88b7ff3 100644
>>> --- a/drivers/net/phy/at803x.c
>>> +++ b/drivers/net/phy/at803x.c
>>> @@ -252,7 +252,9 @@ static int at803x_probe(struct phy_device *phyd=
ev)
>>>  		return -ENOMEM;
>>>
>>>  	gpiod_reset =3D devm_gpiod_get_optional(dev, "reset", GPIOD_OUT_H=
IGH);
>>> -	if (IS_ERR(gpiod_reset))
>>> +	if (PTR_ERR(gpiod_reset) =3D=3D -ENOSYS)
>>> +		gpiod_reset =3D NULL;
>>> +	else if (IS_ERR(gpiod_reset))
>>
>> this isn't better either (IMHO it's worse, but maybe this is debatab=
le
>> and also depends on your POV).
>=20
> Well, from the code, the reset hack is only required when the PHY is
> ATH8030_PHY_ID, right?
> However, such change was introduced by Daniel Mack on commit 13a56b44=
9325.
> Hopefully he can chime in and give his opinion on this.
>=20
> Daniel, while on the subject, I have a question for you:
>=20
> Change 2b8f2a28eac1 introduced "link_status_notify" callback which is
> called systematically on the PHY state machine.
> Any reason to make the call systematic as opposed to let say:
>=20
> 	if (phydev->state !=3D old_state) {
> 		if (phydev->drv->link_change_notify)
> 			phydev->drv->link_change_notify(phydev);
> 	}
>=20
> (it does means that the callback would be called after the state mach=
ine
> processing though)
>=20
>>
>> With 687908c2b649 I made kernels without GPIOLIB fail to bind this
>> device. I admit this is not maximally nice.
>=20
> I see, that was not clear from the commit message, sorry.
>=20
>>
>> Your change makes the driver bind in this case again and then the re=
set
>> gpio isn't handled at all which might result in a later and harder t=
o
>> debug error.
>>
>> The better approach to fix your problem is: make the driver depend (=
or
>> force) on GPIOLIB.=20
>=20
> It was one of the solutions I had in mind, but:
> - since the dependency on GPIOLIB was not included on the patch
> - and given that the previous code had provision to work without GPIO
> I thought it was an overlook.
>=20
>> Or alternatively, drop reset-handling from the
>> driver.
>>
>> From a driver perspecitive, it would be nice if devm_gpiod_get_optio=
nal
>> returned NULL iff the respective gpio isn't specified even with
>> GPIOLIB=3Dn, but this isn't sensible either because it would result =
in
>> quite some gpiolib code to not being conditionally compiled on
>> CONFIG_GPIOLIB any more.
>=20
> Let's say that was the case, what would the PHY code do?
>=20
> I mean, it did not get a GPIO, whether it was because GPIOLIB=3Dn or
> because there's no 'reset' GPIO attached
> Shall it fail? Shall it continue in a sort of degraded mode? Shall it=
 warn?
> Because that's the real question here.
>=20
> What would you think of making at803x_link_change_notify() print a
> message every time it should do a reset but does not has a way to do =
it?
> I can make such change to my patch if everybody agrees on it.
> By the way, in that case, can somebody suggest a way to print such wa=
rning?
> Would printk() be ok or should I use dev_dbg() ?
>=20
> Best regards,
>=20
> Sebastian
>=20
>>
>> Best regards
>> Uwe
>>
