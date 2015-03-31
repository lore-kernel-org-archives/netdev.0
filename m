From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: at803x: simplify using
 devm_gpiod_get_optional and its 4th argument
Date: Tue, 31 Mar 2015 12:57:54 -0400 (EDT)
Message-ID: <20150331.125754.1434513759096073981.davem@davemloft.net>
References: <1427484302-17075-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linus.walleij@linaro.org, acourbot@nvidia.com
To: u.kleine-koenig@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48552 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751295AbbCaQ54 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 12:57:56 -0400
In-Reply-To: <1427484302-17075-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
Date: Fri, 27 Mar 2015 20:25:02 +0100

> @@ -197,15 +197,12 @@ static int at803x_probe(struct phy_device *phyd=
ev)
>  	if (!priv)
>  		return -ENOMEM;
> =20
> -	priv->gpiod_reset =3D devm_gpiod_get(dev, "reset");
> -	if (IS_ERR(priv->gpiod_reset))
> -		priv->gpiod_reset =3D NULL;
> -	else
> -		gpiod_direction_output(priv->gpiod_reset, 1);
> +	priv->gpiod_reset =3D devm_gpiod_get_optional(dev, "reset",
> +						    GPIOD_OUT_HIGH);
> =20
>  	phydev->priv =3D priv;
> =20
> -	return 0;
> +	return IS_ERR(priv->gpiod_reset);
>  }
> =20
>  static int at803x_config_init(struct phy_device *phydev)

This isn't right.

The current code is necessary, don't change it.

Your "simplification" adds three new bugs:

1) It potentially leaves an error pointer in priv->gpiod_reset
   and I explicitly tell people to NEVER do this as it tests as
   non-NULL by cleanup code and therefore might be mistakenly
   used.

2) It returns the wrong error.  IS_ERR() is either true or
   false, but if you wanted to do this right you would
   return PTR_ERR() if IS_ERR() were true or zero.

3) Clearly this code intended to continue trying and succeed
   the probe even if getting "reset" failed, your changes
   no longer do this.

I really hate changes like this, don't try to be too cute unless
you fully understand the full repurcussions and the reasons why
someone did things one way or another.

Leaving error pointers live in datastructures is never to be done, and
if I see patches adding code doing it I will reject it on the spot.
