From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH] net: phy: at803x: don't depend on GPIOLIB
Date: Mon, 21 Mar 2016 21:41:11 +0100
Message-ID: <20160321204111.GB6191@pengutronix.de>
References: <56E99727.9040702@laposte.net>
 <56F05651.3030706@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sebastian Frias <sf84@laposte.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>, mason <slash.tmp@free.fr>,
	Daniel Mack <zonque@gmail.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:56796 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754635AbcCUUlQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2016 16:41:16 -0400
Content-Disposition: inline
In-Reply-To: <56F05651.3030706@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Sergei,

On Mon, Mar 21, 2016 at 11:15:13PM +0300, Sergei Shtylyov wrote:
> On 03/16/2016 08:25 PM, Sebastian Frias wrote:
>=20
> >Commit 687908c2b649 ("net: phy: at803x: simplify using
> >devm_gpiod_get_optional and its 4th argument") introduced a dependen=
cy
> >on GPIOLIB that was not there before.
> >
> >This commit removes such dependency by checking the return code and
> >comparing it against ENOSYS which is returned when GPIOLIB is not
> >selected.
> >
> >Fixes: 687908c2b649 ("net: phy: at803x: simplify using
> >devm_gpiod_get_optional and its 4th argument")
> >
> >Signed-off-by: Sebastian Frias <sf84@laposte.net>
>=20
>    Do you have the PHY that requires the GPIO reset workaround?
> Askinjg because I have the patch adding the "reset-gpios" prop handli=
ng to
> phylib and your patch made me aware that I'll have to modify this dri=
ver in
> order to do that...
>=20
> >---
> >  drivers/net/phy/at803x.c | 4 +++-
> >  1 file changed, 3 insertions(+), 1 deletion(-)
> >
> >diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
> >index 2174ec9..88b7ff3 100644
> >--- a/drivers/net/phy/at803x.c
> >+++ b/drivers/net/phy/at803x.c
> >@@ -252,7 +252,9 @@ static int at803x_probe(struct phy_device *phyde=
v)
> >  		return -ENOMEM;
> >
> >  	gpiod_reset =3D devm_gpiod_get_optional(dev, "reset", GPIOD_OUT_H=
IGH);
> >-	if (IS_ERR(gpiod_reset))
> >+	if (PTR_ERR(gpiod_reset) =3D=3D -ENOSYS)
> >+		gpiod_reset =3D NULL;
> >+	else if (IS_ERR(gpiod_reset))
>    		return PTR_ERR(gpiod_reset);
>=20
>    My patch basically gets rid of all this code. The thing that worri=
es me
> is that the driver assumes that the reset singal is active low, despi=
te what
> the GPIO specifier in the device tree has for the GPIO polarity. In f=
act, it
> will only work correctly if the specified has GPIO_ACTIVE_HIGH -- whi=
ch is
> wrong because the reset signal is active low!

Note that gpio descriptors handle the polarity just fine (i.e. the pin
is set to 0 after doing gpiod_set_value(1) if the gpio is active low).

But having said that, the driver gets it wrong.

The right sequence to reset a device using a gpio is:

	gpiod_set_value(priv->gpiod_reset, 1);
	msleep(some_time);
	gpiod_set_value(priv->gpiod_reset, 0);

and if the gpio is active low, this should be specified in the device
tree. This was done wrong in 13a56b449325 (net: phy: at803x: Add suppor=
t
for hardware reset).

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
