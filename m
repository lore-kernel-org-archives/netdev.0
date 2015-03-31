From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH] net: phy: at803x: simplify using devm_gpiod_get_optional
 and its 4th argument
Date: Tue, 31 Mar 2015 19:53:47 +0200
Message-ID: <20150331175347.GL17728@pengutronix.de>
References: <1427484302-17075-1-git-send-email-u.kleine-koenig@pengutronix.de>
 <20150331.125754.1434513759096073981.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linus.walleij@linaro.org, acourbot@nvidia.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:50616 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753064AbbCaRxu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 13:53:50 -0400
Content-Disposition: inline
In-Reply-To: <20150331.125754.1434513759096073981.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 31, 2015 at 12:57:54PM -0400, David Miller wrote:
> From: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
> Date: Fri, 27 Mar 2015 20:25:02 +0100
>=20
> > @@ -197,15 +197,12 @@ static int at803x_probe(struct phy_device *ph=
ydev)
> >  	if (!priv)
> >  		return -ENOMEM;
> > =20
> > -	priv->gpiod_reset =3D devm_gpiod_get(dev, "reset");
> > -	if (IS_ERR(priv->gpiod_reset))
> > -		priv->gpiod_reset =3D NULL;
> > -	else
> > -		gpiod_direction_output(priv->gpiod_reset, 1);
> > +	priv->gpiod_reset =3D devm_gpiod_get_optional(dev, "reset",
> > +						    GPIOD_OUT_HIGH);
> > =20
> >  	phydev->priv =3D priv;
> > =20
> > -	return 0;
> > +	return IS_ERR(priv->gpiod_reset);
> >  }
> > =20
> >  static int at803x_config_init(struct phy_device *phydev)
>=20
> This isn't right.
>=20
> The current code is necessary, don't change it.
>=20
> Your "simplification" adds three new bugs:
>=20
> 1) It potentially leaves an error pointer in priv->gpiod_reset
>    and I explicitly tell people to NEVER do this as it tests as
>    non-NULL by cleanup code and therefore might be mistakenly
>    used.
If priv->gpiod_reset is an error value it makes the probe routine retur=
n
this error (after point 2 is addressed), which should end the lifetime
of the structure containing the value.

> 2) It returns the wrong error.  IS_ERR() is either true or
>    false, but if you wanted to do this right you would
>    return PTR_ERR() if IS_ERR() were true or zero.
Ah right, I should use PTR_ERR_OR_ZERO.

> 3) Clearly this code intended to continue trying and succeed
>    the probe even if getting "reset" failed, your changes
>    no longer do this.
It uses the _optional variant of devm_gpiod_get now, which returns NULL=
 if
devm_gpiod_get would return -ENOENT. For all other errors returned by
devm_gpiod_get the code that is currently in place is wrong to ignore
them.

> I really hate changes like this, don't try to be too cute unless
> you fully understand the full repurcussions and the reasons why
> someone did things one way or another.
I think I did understand the code, so I will resend with
PTR_ERR_OR_ZERO assuming it was you who didn't understood my change
regarding the other two issues you pointed out.

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
