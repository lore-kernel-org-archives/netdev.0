From: Mason <slash.tmp@free.fr>
Subject: Re: [PATCH] net: phy: at803x: don't depend on GPIOLIB
Date: Wed, 23 Mar 2016 11:17:11 +0100
Message-ID: <56F26D27.3020106@free.fr>
References: <56E99727.9040702@laposte.net>
 <20160318125455.GN4292@pengutronix.de> <56EC2525.8000706@laposte.net>
 <20160318191242.GQ4292@pengutronix.de> <56EFEDAD.9030903@laposte.net>
 <20160321135457.GX4292@pengutronix.de> <56F0150F.8080804@laposte.net>
 <20160321201229.GA6191@pengutronix.de> <56F157EF.5080307@laposte.net>
 <20160322194224.GF6191@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Uwe Kleine-Koenig <u.kleine-koenig@pengutronix.de>,
	Daniel Mack <daniel@zonque.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Mans Rullgard <mans@mansr.com>,
	Fabio Estevam <festevam@gmail.com>,
	Martin Blumenstingl <martin.blumenstingl@gmail.com>,
	Linus Walleij <linus.walleij@linaro.org>
To: Sebastian Frias <sf84@laposte.net>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160322194224.GF6191@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 22/03/2016 20:42, Uwe Kleine-K=F6nig wrote:

> Preconditions:
>  - Some of the devices a given driver handles have a reset line and
>    others don't.
>  - A non-empty subset (maybe all) of the devices that have a reset li=
ne
>    require that this reset line is used.
>=20
> Then the way to handle this in the driver should be done as follows:
>=20
>   unless reset_handling_not_necessary():
>     gpio =3D gpiod_get_optional("reset")
>     if IS_ERR(gpio):
>       return PTR_ERR(gpio)
>=20
> Checking for -ENOSYS or GPIOLIB=3Dn is not allowed because the device
> you're currently handling might need the GPIO, so you must not contin=
ue
> without the ability to control the line.
>=20
> So the options you have (as you have a phy that doesn't need the rese=
t
> handling):
>=20
>  - enable GPIOLIB (either in your .config or introduce a Kconfig
>    dependency)
>  - improve reset_handling_not_necessary() to return true for your cas=
e
>=20
> There is nothing else.

Here are some numbers for GPIOLIB, on an ARM build:

   text	   data	    bss	    dec	    hex	filename
   1830	      0	      0	   1830	    726	devres.o
    627	      0	      0	    627	    273	gpiolib-legacy.o
  11018	     40	      4	  11062	   2b36	gpiolib.o
   1598	      0	      0	   1598	    63e	gpiolib-of.o
--------------------------------------------------------
  15073	     40	      4	  15117	   3b0d	built-in.o

So ~15 kilobytes.


By the way, since the "reset-by-GPIO" solution is used only for
the Atheros 8030, would it be possible to make the
devm_gpiod_get_optional conditional on ATH8030_PHY_ID?

I'm thinking of something along these lines, for illustration:

diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
index 2d020a3ec0b5..576e7873e049 100644
--- a/drivers/net/phy/at803x.c
+++ b/drivers/net/phy/at803x.c
@@ -198,12 +198,16 @@ static int at803x_probe(struct phy_device *phydev=
)
        if (!priv)
                return -ENOMEM;
=20
+       if (phydev->drv->phy_id !=3D ATH8030_PHY_ID)
+               goto no_gpio;
+
        gpiod_reset =3D devm_gpiod_get_optional(dev, "reset", GPIOD_OUT=
_HIGH);
        if (IS_ERR(gpiod_reset))
                return PTR_ERR(gpiod_reset);
=20
        priv->gpiod_reset =3D gpiod_reset;
=20
+no_gpio:
        phydev->priv =3D priv;
=20
        return 0;


Regards.
