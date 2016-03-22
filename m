From: Sebastian Frias <sf84@laposte.net>
Subject: Re: [PATCH] net: phy: at803x: don't depend on GPIOLIB
Date: Tue, 22 Mar 2016 15:53:51 +0100
Message-ID: <56F15C7F.9060404@laposte.net>
References: <56E99727.9040702@laposte.net> <56F05651.3030706@cogentembedded.com> <20160321204111.GB6191@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>, mason <slash.tmp@free.fr>,
	Daniel Mack <zonque@gmail.com>
To: =?windows-1252?Q?Uwe_Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpoutz27.laposte.net ([194.117.213.102]:56131 "EHLO
	smtp.laposte.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751003AbcCVOxz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2016 10:53:55 -0400
Received: from smtp.laposte.net (localhost [127.0.0.1])
	by lpn-prd-vrout015 (Postfix) with ESMTP id 83BAC1C7C03
	for <netdev@vger.kernel.org>; Tue, 22 Mar 2016 15:53:52 +0100 (CET)
Received: from lpn-prd-vrin001 (lpn-prd-vrin001.laposte [10.128.63.2])
	by lpn-prd-vrout015 (Postfix) with ESMTP id 789E81C7B89
	for <netdev@vger.kernel.org>; Tue, 22 Mar 2016 15:53:52 +0100 (CET)
Received: from lpn-prd-vrin001 (localhost [127.0.0.1])
	by lpn-prd-vrin001 (Postfix) with ESMTP id 57D4E36542D
	for <netdev@vger.kernel.org>; Tue, 22 Mar 2016 15:53:52 +0100 (CET)
In-Reply-To: <20160321204111.GB6191@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 03/21/2016 09:41 PM, Uwe Kleine-K=F6nig wrote:
>>    My patch basically gets rid of all this code. The thing that worr=
ies me
>> is that the driver assumes that the reset singal is active low, desp=
ite what
>> the GPIO specifier in the device tree has for the GPIO polarity. In =
fact, it
>> will only work correctly if the specified has GPIO_ACTIVE_HIGH -- wh=
ich is
>> wrong because the reset signal is active low!
>=20
> Note that gpio descriptors handle the polarity just fine (i.e. the pi=
n
> is set to 0 after doing gpiod_set_value(1) if the gpio is active low)=
=2E
>=20

Isn't that source of bugs?
What about using some #define (or probably better, an enum)?, something
like:

    gpiod_set_value(gpiod, GPIO_SET_VALUE_ACTIVE)
    gpiod_set_value(gpiod, GPIO_SET_VALUE_INACTIVE)
    gpiod_set_value(gpiod, GPIO_SET_VALUE_TRISTATE)

then, somebody reading the code would have to stop and think what do
these mean.
IIUC, currently the "0" or "1" can easily be confused with the actual
logical value of the GPIO.

gpiod_set_value() could also return an int with the actual value it
applied to the GPIO.
=46or example: if gpiod is active low, gpiod_set_value(gpiod,
GPIO_SET_VALUE_ACTIVE) would return 0;
Conversely, if gpiod is active high, gpiod_set_value(gpiod,
GPIO_SET_VALUE_ACTIVE) would return 1;

Best regards,

Sebastian

> But having said that, the driver gets it wrong.
>=20
> The right sequence to reset a device using a gpio is:
>=20
> 	gpiod_set_value(priv->gpiod_reset, 1);
> 	msleep(some_time);
> 	gpiod_set_value(priv->gpiod_reset, 0);
>=20
> and if the gpio is active low, this should be specified in the device
> tree. This was done wrong in 13a56b449325 (net: phy: at803x: Add supp=
ort
> for hardware reset).
>=20
> Best regards
> Uwe
>=20
