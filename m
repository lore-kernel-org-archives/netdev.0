From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH] net: phy: at803x: don't depend on GPIOLIB
Date: Fri, 18 Mar 2016 13:54:55 +0100
Message-ID: <20160318125455.GN4292@pengutronix.de>
References: <56E99727.9040702@laposte.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>, mason <slash.tmp@free.fr>,
	Daniel Mack <daniel@zonque.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Mans Rullgard <mans@mansr.com>,
	Fabio Estevam <festevam@gmail.com>,
	Martin Blumenstingl <martin.blumenstingl@gmail.com>,
	Linus Walleij <linus.walleij@linaro.org>
To: Sebastian Frias <sf84@laposte.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:34869 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752439AbcCRMzF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2016 08:55:05 -0400
Content-Disposition: inline
In-Reply-To: <56E99727.9040702@laposte.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[expand cc a bit more]

Hello,

On Wed, Mar 16, 2016 at 06:25:59PM +0100, Sebastian Frias wrote:
> Commit 687908c2b649 ("net: phy: at803x: simplify using
> devm_gpiod_get_optional and its 4th argument") introduced a dependenc=
y
> on GPIOLIB that was not there before.
>=20
> This commit removes such dependency by checking the return code and
> comparing it against ENOSYS which is returned when GPIOLIB is not
> selected.
>=20
> Fixes: 687908c2b649 ("net: phy: at803x: simplify using devm_gpiod_get=
_optional and its 4th argument")
>=20
> Signed-off-by: Sebastian Frias <sf84@laposte.net>
> ---
>  drivers/net/phy/at803x.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
> index 2174ec9..88b7ff3 100644
> --- a/drivers/net/phy/at803x.c
> +++ b/drivers/net/phy/at803x.c
> @@ -252,7 +252,9 @@ static int at803x_probe(struct phy_device *phydev=
)
>  		return -ENOMEM;
>=20
>  	gpiod_reset =3D devm_gpiod_get_optional(dev, "reset", GPIOD_OUT_HIG=
H);
> -	if (IS_ERR(gpiod_reset))
> +	if (PTR_ERR(gpiod_reset) =3D=3D -ENOSYS)
> +		gpiod_reset =3D NULL;
> +	else if (IS_ERR(gpiod_reset))

this isn't better either (IMHO it's worse, but maybe this is debatable
and also depends on your POV).

With 687908c2b649 I made kernels without GPIOLIB fail to bind this
device. I admit this is not maximally nice.

Your change makes the driver bind in this case again and then the reset
gpio isn't handled at all which might result in a later and harder to
debug error.

The better approach to fix your problem is: make the driver depend (or
force) on GPIOLIB. Or alternatively, drop reset-handling from the
driver.

=46rom a driver perspecitive, it would be nice if devm_gpiod_get_option=
al
returned NULL iff the respective gpio isn't specified even with
GPIOLIB=3Dn, but this isn't sensible either because it would result in
quite some gpiolib code to not being conditionally compiled on
CONFIG_GPIOLIB any more.

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
