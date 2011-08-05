From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [RFC 2/4] [flexcan] Introduce a flexcan_clk set of functions.
Date: Fri, 05 Aug 2011 10:34:11 +0200
Message-ID: <4E3BAB03.4040803@pengutronix.de>
References: <1312509979-13226-1-git-send-email-holt@sgi.com>
	<1312509979-13226-3-git-send-email-holt@sgi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7333218060371965152=="
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1312509979-13226-3-git-send-email-holt-sJ/iWh9BUns@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--===============7333218060371965152==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig168D367EEBB627459B2B881D"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig168D367EEBB627459B2B881D
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 08/05/2011 04:06 AM, Robin Holt wrote:
> The freescale P1010RDB board does not have a
> clk_{get,put,get_rate,enable,disable} set of functions.  Wrap these wit=
h a
> flexcan_ #define for arm, and implement a more complete function for pp=
c.

Some codingstyle nitpicks inline. I hope we'll find a cleaner solution
than this patch.

Marc

> Signed-off-by: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
> To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
> To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
> Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> ---
>  drivers/net/can/flexcan.c |  114 +++++++++++++++++++++++++++++++++++++=
++++----
>  1 files changed, 105 insertions(+), 9 deletions(-)
>=20
> diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
> index 74b1706..3417d0b 100644
> --- a/drivers/net/can/flexcan.c
> +++ b/drivers/net/can/flexcan.c
> @@ -220,6 +220,102 @@ static inline void flexcan_write(u32 val, void __=
iomem *addr)
>  }
>  #endif
> =20
> +#if defined(__powerpc__)
> +struct flexcan_clk {
> +	unsigned long rate;
> +	void *data;
> +};
> +
> +static struct clk *flexcan_clk_get(struct device *dev, const char *id)=

> +{
> +	struct flexcan_clk *clock;
> +	u32 *clock_freq;
> +	u32 *clock_divider;
> +	int err;
> +
> +	clock =3D kmalloc(sizeof(struct flexcan_clk), GFP_KERNEL);
> +	if (!clock) {
> +		dev_err(dev, "Cannot allocate memory\n");
> +		err =3D -ENOMEM;
> +		goto failed_clock;
> +	}
> +	clock_freq =3D (u32 *)of_get_property(dev->of_node, "clock_freq", NUL=
L);
> +	if (!clock_freq) {
> +		dev_err(dev, "Cannot find clock_freq property\n");
> +		err =3D -EINVAL;
> +		goto failed_clock;
> +	}
> +
> +	clock_divider =3D (u32 *) of_get_property(dev->of_node,
                               ^

remove this space, please
> +					"fsl,flexcan-clock-divider", NULL);
> +	if (clock_divider =3D=3D NULL) {

!clock_divider

> +		dev_err(dev, "Cannot find fsl,flexcan-clock-divider property\n");
> +		err =3D -EINVAL;
> +		goto failed_clock;
> +	}
> +
> +	clock->rate =3D DIV_ROUND_CLOSEST(*clock_freq / *clock_divider, 1000)=
;
> +	clock->rate *=3D 1000;
> +
> +	return (struct clk *)clock;
> +
> + failed_clock:
> +	kfree(clock);
> +	return ERR_PTR(err);
> +}
> +
> +static inline void flexcan_clk_put(struct clk *_clk)
> +{
> +	struct flexcan_clk *clk =3D (struct flexcan_clk *)_clk;

that cast is not needed.

> +
> +	kfree(clk);
> +}
> +
> +static inline int flexcan_clk_enable(struct clk *clk)
> +{
> +	return 0;
> +}
> +
> +static inline void flexcan_clk_disable(struct clk *clk)
> +{
> +	return;
> +}
> +
> +static inline unsigned long flexcan_clk_get_rate(struct clk *_clk)
> +{
> +	struct flexcan_clk *clk =3D (struct flexcan_clk *)_clk;
> +
> +	return clk->rate;
> +}
> +
> +#else
> +static inline struct clk *flexcan_clk_get(struct device *dev, const ch=
ar *id)
> +{
> +	return clk_get(dev, id);
> +}
> +
> +static inline void flexcan_clk_put(struct clk *clk)
> +{
> +	clk_put(clk);
> +}
> +
> +static inline int flexcan_clk_enable(struct clk *clk)
> +{
> +	return clk_enable(clk);
> +}
> +
> +static inline void flexcan_clk_disable(struct clk *clk)
> +{
> +	clk_disable(clk);
> +}
> +
> +static inline unsigned long flexcan_clk_get_rate(struct clk *clk)
> +{
> +	return clk_get_rate(clk);
> +}
> +
> +#endif
> +
>  /*
>   * Swtich transceiver on or off
>   */
> @@ -807,7 +903,7 @@ static int flexcan_open(struct net_device *dev)
>  	struct flexcan_priv *priv =3D netdev_priv(dev);
>  	int err;
> =20
> -	clk_enable(priv->clk);
> +	flexcan_clk_enable(priv->clk);
> =20
>  	err =3D open_candev(dev);
>  	if (err)
> @@ -829,7 +925,7 @@ static int flexcan_open(struct net_device *dev)
>   out_close:
>  	close_candev(dev);
>   out:
> -	clk_disable(priv->clk);
> +	flexcan_clk_disable(priv->clk);
> =20
>  	return err;
>  }
> @@ -843,7 +939,7 @@ static int flexcan_close(struct net_device *dev)
>  	flexcan_chip_stop(dev);
> =20
>  	free_irq(dev->irq, dev);
> -	clk_disable(priv->clk);
> +	flexcan_clk_disable(priv->clk);
> =20
>  	close_candev(dev);
> =20
> @@ -882,7 +978,7 @@ static int __devinit register_flexcandev(struct net=
_device *dev)
>  	struct flexcan_regs __iomem *regs =3D priv->base;
>  	u32 reg, err;
> =20
> -	clk_enable(priv->clk);
> +	flexcan_clk_enable(priv->clk);
> =20
>  	/* select "bus clock", chip must be disabled */
>  	flexcan_chip_disable(priv);
> @@ -916,7 +1012,7 @@ static int __devinit register_flexcandev(struct ne=
t_device *dev)
>   out:
>  	/* disable core and turn off clocks */
>  	flexcan_chip_disable(priv);
> -	clk_disable(priv->clk);
> +	flexcan_clk_disable(priv->clk);
> =20
>  	return err;
>  }
> @@ -936,7 +1032,7 @@ static int __devinit flexcan_probe(struct platform=
_device *pdev)
>  	resource_size_t mem_size;
>  	int err, irq;
> =20
> -	clk =3D clk_get(&pdev->dev, NULL);
> +	clk =3D flexcan_clk_get(&pdev->dev, NULL);
>  	if (IS_ERR(clk)) {
>  		dev_err(&pdev->dev, "no clock defined\n");
>  		err =3D PTR_ERR(clk);
> @@ -973,7 +1069,7 @@ static int __devinit flexcan_probe(struct platform=
_device *pdev)
>  	dev->flags |=3D IFF_ECHO; /* we support local echo in hardware */
> =20
>  	priv =3D netdev_priv(dev);
> -	priv->can.clock.freq =3D clk_get_rate(clk);
> +	priv->can.clock.freq =3D flexcan_clk_get_rate(clk);
>  	priv->can.bittiming_const =3D &flexcan_bittiming_const;
>  	priv->can.do_set_mode =3D flexcan_set_mode;
>  	priv->can.do_get_berr_counter =3D flexcan_get_berr_counter;
> @@ -1008,7 +1104,7 @@ static int __devinit flexcan_probe(struct platfor=
m_device *pdev)
>   failed_map:
>  	release_mem_region(mem->start, mem_size);
>   failed_get:
> -	clk_put(clk);
> +	flexcan_clk_put(clk);
>   failed_clock:
>  	return err;
>  }
> @@ -1026,7 +1122,7 @@ static int __devexit flexcan_remove(struct platfo=
rm_device *pdev)
>  	mem =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
>  	release_mem_region(mem->start, resource_size(mem));
> =20
> -	clk_put(priv->clk);
> +	flexcan_clk_put(priv->clk);
> =20
>  	free_candev(dev);
> =20


--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig168D367EEBB627459B2B881D
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk47qwMACgkQjTAFq1RaXHOnswCgiygZ/fFSTmYKfq2C9RwrKteV
QYQAnRLRrrveTHdElHcN4S2M5wYonVyY
=PJDw
-----END PGP SIGNATURE-----

--------------enig168D367EEBB627459B2B881D--

--===============7333218060371965152==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============7333218060371965152==--
