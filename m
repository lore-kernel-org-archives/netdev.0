From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH RFT 1/2] phylib: add device reset GPIO support
Date: Thu, 12 May 2016 20:42:33 +0200
Message-ID: <20160512184233.GJ30822@pengutronix.de>
References: <81129033.NXiOLTg1so@wasted.cogentembedded.com>
 <3641492.klKRrvS8tr@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org,
	mark.rutland-5wv7dgnIgG8@public.gmane.org, ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org,
	galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
To: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <3641492.klKRrvS8tr-gHKXc3Y1Z8zGSmamagVegGFoWSdPRAKMAL8bYrjMMd8@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello Sergei,

[we already talked about this patch in #armlinux, I'm now just
forwarding my comments on the list. Background was that I sent an easie=
r
and less complete patch with the same idea. See
http://patchwork.ozlabs.org/patch/621418/]

[added Linus Walleij to Cc, there is a question for you/him below]

On Fri, Apr 29, 2016 at 01:12:54AM +0300, Sergei Shtylyov wrote:
> --- net-next.orig/Documentation/devicetree/bindings/net/phy.txt
> +++ net-next/Documentation/devicetree/bindings/net/phy.txt
> @@ -35,6 +35,8 @@ Optional Properties:
>  - broken-turn-around: If set, indicates the PHY device does not corr=
ectly
>    release the turn around line low at the end of a MDIO transaction.
> =20
> +- reset-gpios: The GPIO phandle and specifier for the PHY reset sign=
al.
> +
>  Example:
> =20
>  ethernet-phy@0 {

This is great.

> Index: net-next/drivers/net/phy/at803x.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- net-next.orig/drivers/net/phy/at803x.c
> +++ net-next/drivers/net/phy/at803x.c
> @@ -65,7 +65,6 @@ MODULE_LICENSE("GPL");
> [...]

My patch breaks this driver. I wasn't aware of it.

> [...]
> Index: net-next/drivers/net/phy/mdio_device.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- net-next.orig/drivers/net/phy/mdio_device.c
> +++ net-next/drivers/net/phy/mdio_device.c
> [...]
> @@ -103,6 +105,13 @@ void mdio_device_remove(struct mdio_devi
>  }
>  EXPORT_SYMBOL(mdio_device_remove);
> =20
> +void mdio_device_reset(struct mdio_device *mdiodev, int value)
> +{
> +	if (mdiodev->reset)
> +		gpiod_set_value(mdiodev->reset, value);

Before v4.6-rc1~108^2~91 it was not necessary to check for the first
parameter being non-NULL before calling gpiod_set_value. Linus, did you
change this on purpose?

> +}
> +EXPORT_SYMBOL(mdio_device_reset);
> +
>  /**
>   * mdio_probe - probe an MDIO device
>   * @dev: device to probe
> @@ -117,9 +126,16 @@ static int mdio_probe(struct device *dev
>  	struct mdio_driver *mdiodrv =3D to_mdio_driver(drv);
>  	int err =3D 0;
> =20
> -	if (mdiodrv->probe)
> +	if (mdiodrv->probe) {
> +		/* Deassert the reset signal */
> +		mdio_device_reset(mdiodev, 0);
> +
>  		err =3D mdiodrv->probe(mdiodev);
> =20
> +		/* Assert the reset signal */
> +		mdio_device_reset(mdiodev, 1);

I wonder if it's safe to do this in general. What if ->probe does
something with the phy that is lost by resetting but that is relied on
later?

> +	}
> +
>  	return err;
>  }
> [...]
> Index: net-next/drivers/of/of_mdio.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- net-next.orig/drivers/of/of_mdio.c
> +++ net-next/drivers/of/of_mdio.c
> @@ -44,6 +44,7 @@ static int of_get_phy_id(struct device_n
>  static void of_mdiobus_register_phy(struct mii_bus *mdio,
>  				    struct device_node *child, u32 addr)
>  {
> +	struct gpio_desc *gpiod;
>  	struct phy_device *phy;
>  	bool is_c45;
>  	int rc;
> @@ -52,10 +53,17 @@ static void of_mdiobus_register_phy(stru
>  	is_c45 =3D of_device_is_compatible(child,
>  					 "ethernet-phy-ieee802.3-c45");
> =20
> +	gpiod =3D fwnode_get_named_gpiod(&child->fwnode, "reset-gpios");
> +	/* Deassert the reset signal */
> +	if (!IS_ERR(gpiod))
> +		gpiod_direction_output(gpiod, 0);

This is wrong I think. You must only ignore -ENODEV, all other error
codes should be passed to the caller. (I see that's not trivial because
of_mdiobus_register_phy returns void.)

In my patch I used devm_gpiod_get_array which has the nice property tha=
t
I can already pass GPIOD_OUT_LOW in flags. Also this binds the lifetime
of the gpio to the device which is nice and IMHO the right direction fo=
r
the phylib (i.e. better embracing of the device model).

This cannot be used here easily however because there is no struct
device yet and this is only created after the phy id is determined. The
phy id is either read from the device tree or must be read from the phy
which might fail if reset is not deasserted.

Principally there is no reason however that the phy_id must be known
before the struct device is created however.

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
--
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
