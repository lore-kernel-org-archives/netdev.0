From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v4 4/8] net: can: c_can: Add syscon/regmap RAMINIT mechanism
Date: Thu, 13 Nov 2014 13:44:15 +0100
Message-ID: <5464A79F.1070304@pengutronix.de>
References: <1415371762-29885-1-git-send-email-rogerq@ti.com> <1415371762-29885-5-git-send-email-rogerq@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="P6h8VqiH1FAU4duNX5KNWtGX3TB41hKVj"
Cc: wsa@the-dreams.de, tony@atomide.com, tglx@linutronix.de,
	mugunthanvnm@ti.com, george.cherian@ti.com, balbi@ti.com,
	nsekhar@ti.com, nm@ti.com, sergei.shtylyov@cogentembedded.com,
	linux-omap@vger.kernel.org, linux-can@vger.kernel.org,
	netdev@vger.kernel.org
To: Roger Quadros <rogerq@ti.com>, wg@grandegger.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:51393 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932639AbaKMMoo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 07:44:44 -0500
In-Reply-To: <1415371762-29885-5-git-send-email-rogerq@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--P6h8VqiH1FAU4duNX5KNWtGX3TB41hKVj
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/07/2014 03:49 PM, Roger Quadros wrote:
> Some TI SoCs like DRA7 have a RAMINIT register specification
> different from the other AMxx SoCs and as expected by the
> existing driver.
>=20
> To add more insanity, this register is shared with other
> IPs like DSS, PCIe and PWM.
>=20
> Provides a more generic mechanism to specify the RAMINIT
> register location and START/DONE bit position and use the
> syscon/regmap framework to access the register.
>=20
> Signed-off-by: Roger Quadros <rogerq@ti.com>
> ---
>  .../devicetree/bindings/net/can/c_can.txt          |   3 +
>  drivers/net/can/c_can/c_can.h                      |  11 +-
>  drivers/net/can/c_can/c_can_platform.c             | 112 +++++++++++++=
+-------
>  3 files changed, 86 insertions(+), 40 deletions(-)
>=20
> diff --git a/Documentation/devicetree/bindings/net/can/c_can.txt b/Docu=
mentation/devicetree/bindings/net/can/c_can.txt
> index 8f1ae81..a3ca3ee 100644
> --- a/Documentation/devicetree/bindings/net/can/c_can.txt
> +++ b/Documentation/devicetree/bindings/net/can/c_can.txt
> @@ -12,6 +12,9 @@ Required properties:
>  Optional properties:
>  - ti,hwmods		: Must be "d_can<n>" or "c_can<n>", n being the
>  			  instance number
> +- syscon-raminit	: Handle to system control region that contains the
> +			  RAMINIT register, register offset to the RAMINIT
> +			  register and the CAN instance number (0 offset).
> =20
>  Note: "ti,hwmods" field is used to fetch the base address and irq
>  resources from TI, omap hwmod data base during device registration.
> diff --git a/drivers/net/can/c_can/c_can.h b/drivers/net/can/c_can/c_ca=
n.h
> index 3c305a1..0e17c7b 100644
> --- a/drivers/net/can/c_can/c_can.h
> +++ b/drivers/net/can/c_can/c_can.h
> @@ -179,6 +179,14 @@ struct c_can_driver_data {
>  	bool raminit_pulse;	/* If set, sets and clears START bit (pulse) */
>  };
> =20
> +/* Out of band RAMINIT register access via syscon regmap */
> +struct c_can_raminit {
> +	struct regmap *syscon;	/* for raminit ctrl. reg. access */
> +	unsigned int reg;	/* register index within syscon */
> +	u8 start_bit;
> +	u8 done_bit;
> +};
> +
>  /* c_can private data structure */
>  struct c_can_priv {
>  	struct can_priv can;	/* must be the first member */
> @@ -196,8 +204,7 @@ struct c_can_priv {
>  	const u16 *regs;
>  	void *priv;		/* for board-specific data */
>  	enum c_can_dev_id type;
> -	u32 __iomem *raminit_ctrlreg;
> -	int instance;
> +	struct c_can_raminit raminit_sys;	/* RAMINIT via syscon regmap */
>  	void (*raminit) (const struct c_can_priv *priv, bool enable);
>  	u32 comm_rcv_high;
>  	u32 rxmasked;
> diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c=
_can/c_can_platform.c
> index 20deb67..3776483 100644
> --- a/drivers/net/can/c_can/c_can_platform.c
> +++ b/drivers/net/can/c_can/c_can_platform.c
> @@ -32,14 +32,13 @@
>  #include <linux/clk.h>
>  #include <linux/of.h>
>  #include <linux/of_device.h>
> +#include <linux/mfd/syscon.h>
> +#include <linux/regmap.h>
> =20
>  #include <linux/can/dev.h>
> =20
>  #include "c_can.h"
> =20
> -#define CAN_RAMINIT_START_MASK(i)	(0x001 << (i))
> -#define CAN_RAMINIT_DONE_MASK(i)	(0x100 << (i))
> -#define CAN_RAMINIT_ALL_MASK(i)		(0x101 << (i))
>  #define DCAN_RAM_INIT_BIT		(1 << 3)
>  static DEFINE_SPINLOCK(raminit_lock);
>  /*
> @@ -72,47 +71,61 @@ static void c_can_plat_write_reg_aligned_to_32bit(c=
onst struct c_can_priv *priv,
>  	writew(val, priv->base + 2 * priv->regs[index]);
>  }
> =20
> -static void c_can_hw_raminit_wait_ti(const struct c_can_priv *priv, u3=
2 mask,
> -				  u32 val)
> +static void c_can_hw_raminit_wait_syscon(const struct c_can_priv *priv=
,
> +					 u32 mask, u32 val)
>  {
>  	int timeout =3D 0;
> +	const struct c_can_raminit *raminit =3D &priv->raminit_sys;
> +	u32 ctrl;
> +
>  	/* We look only at the bits of our instance. */
>  	val &=3D mask;
> -	while ((readl(priv->raminit_ctrlreg) & mask) !=3D val) {
> +	do {
>  		udelay(1);
>  		timeout++;
> =20
> +		regmap_read(raminit->syscon, raminit->reg, &ctrl);
>  		if (timeout =3D=3D 1000) {
>  			dev_err(&priv->dev->dev, "%s: time out\n", __func__);
>  			break;
>  		}
> -	}
> +	} while ((ctrl & mask) !=3D val);
>  }
> =20
> -static void c_can_hw_raminit_ti(const struct c_can_priv *priv, bool en=
able)
> +static void c_can_hw_raminit_syscon(const struct c_can_priv *priv, boo=
l enable)
>  {
> -	u32 mask =3D CAN_RAMINIT_ALL_MASK(priv->instance);
> +	u32 mask;
>  	u32 ctrl;
> +	const struct c_can_raminit *raminit =3D &priv->raminit_sys;
> +	u8 start_bit, done_bit;
> +
> +	start_bit =3D raminit->start_bit;
> +	done_bit =3D raminit->done_bit;
> =20
>  	spin_lock(&raminit_lock);
> =20
> -	ctrl =3D readl(priv->raminit_ctrlreg);
> +	mask =3D 1 << start_bit | 1 << done_bit;
> +	regmap_read(raminit->syscon, raminit->reg, &ctrl);
> +
>  	/* We clear the done and start bit first. The start bit is
>  	 * looking at the 0 -> transition, but is not self clearing;
>  	 * And we clear the init done bit as well.
> +	 * NOTE: DONE must be written with 1 to clear it.
>  	 */
> -	ctrl &=3D ~CAN_RAMINIT_START_MASK(priv->instance);
> -	ctrl |=3D CAN_RAMINIT_DONE_MASK(priv->instance);
> -	writel(ctrl, priv->raminit_ctrlreg);
> -	ctrl &=3D ~CAN_RAMINIT_DONE_MASK(priv->instance);
> -	c_can_hw_raminit_wait_ti(priv, mask, ctrl);
> +	ctrl &=3D ~(1 << start_bit);
> +	ctrl |=3D 1 << done_bit;
> +	regmap_write(raminit->syscon, raminit->reg, ctrl);
> +
> +	ctrl &=3D ~(1 << done_bit);
> +	c_can_hw_raminit_wait_syscon(priv, mask, ctrl);
> =20
>  	if (enable) {
>  		/* Set start bit and wait for the done bit. */
> -		ctrl |=3D CAN_RAMINIT_START_MASK(priv->instance);
> -		writel(ctrl, priv->raminit_ctrlreg);
> -		ctrl |=3D CAN_RAMINIT_DONE_MASK(priv->instance);
> -		c_can_hw_raminit_wait_ti(priv, mask, ctrl);
> +		ctrl |=3D 1 << start_bit;
> +		regmap_write(raminit->syscon, raminit->reg, ctrl);
> +
> +		ctrl |=3D 1 << done_bit;
> +		c_can_hw_raminit_wait_syscon(priv, mask, ctrl);
>  	}
>  	spin_unlock(&raminit_lock);
>  }
> @@ -206,10 +219,11 @@ static int c_can_plat_probe(struct platform_devic=
e *pdev)
>  	struct net_device *dev;
>  	struct c_can_priv *priv;
>  	const struct of_device_id *match;
> -	struct resource *mem, *res;
> +	struct resource *mem;
>  	int irq;
>  	struct clk *clk;
>  	const struct c_can_driver_data *drvdata;
> +	struct device_node *np =3D pdev->dev.of_node;
> =20
>  	match =3D of_match_device(c_can_of_table, &pdev->dev);
>  	if (match) {
> @@ -278,27 +292,49 @@ static int c_can_plat_probe(struct platform_devic=
e *pdev)
>  		priv->read_reg32 =3D d_can_plat_read_reg32;
>  		priv->write_reg32 =3D d_can_plat_write_reg32;
> =20
> -		if (pdev->dev.of_node)
> -			priv->instance =3D of_alias_get_id(pdev->dev.of_node, "d_can");
> -		else
> -			priv->instance =3D pdev->id;
> -
> -		res =3D platform_get_resource(pdev, IORESOURCE_MEM, 1);
> -		/* Not all D_CAN modules have a separate register for the D_CAN
> -		 * RAM initialization. Use default RAM init bit in D_CAN module
> -		 * if not specified in DT.
> +		/* Check if we need custom RAMINIT via syscon. Mostly for TI
> +		 * platforms. Only supported with DT boot.
>  		 */
> -		if (!res) {
> +		if (np && of_property_read_bool(np, "syscon-raminit")) {
> +			u32 id;
> +			struct c_can_raminit *raminit =3D &priv->raminit_sys;
> +
> +			ret =3D -EINVAL;
> +			raminit->syscon =3D syscon_regmap_lookup_by_phandle(np,
> +									  "syscon-raminit");

You should return PTR_ERR() here, as it it might be -EPROBE_DEFER

> +			if (IS_ERR(raminit->syscon)) {
> +				dev_err(&pdev->dev,
> +					"couldn't get syscon regmap for RAMINIT\n");
> +				goto exit_free_device;
> +			}

=2E..and maybe remove this error message completely.

regards,
Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--P6h8VqiH1FAU4duNX5KNWtGX3TB41hKVj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUZKefAAoJECte4hHFiupUi2MP/0OhWTPqNL8BAcDt9WEJF9f5
GPRZytsQxzdlU3Jm6U9PXJGntn8sO9njY7YxndPXwgonjNWr8wYa23CcYu5V4H8w
j8Js3qbhZZQ0DiBaFZaWB1lQnr6JKuyc3YKzwq6SZPshvwaUSWH+Ji4tBRFGH397
8IEwAAP5usA12PFDIb1z+DPgaFR9bB/YqK3+D4Rqbx1MRc5gSODmLHbkIpP8OQNw
6xndMyuNzKFiJA3buXsvfSDncKaaQcTOFGheOgZM4u8GnkVRDXqh+3VEt5PQ7R0c
1jIRiODzTExeChNdSMicbCKtnYMGy1Pdsz36ei8Zc/uuZgPzISnlRetaTypbUwun
bVREZUJbUh9Y4nP0M5MlnHodtBhhf4Qvf+7gqfAsQ3+UdDnGS9rovHPmaE7KhiX1
cgUwHIA4RGK95RWYuaUaF4PYcHIlDdCRWQ8c3hESpVB4IDeZ4bjP6JU4KHwEeXos
xnCz2xxmn7i4LDD5EdrVQNFKWegXJzwhOM6+GFRX/US8M75+mOnuwFatt5Z2lF/q
d8VjefFK8UXu+fdwl5+uL6bedZB29AztAckGyn4+EU8WuKKpVr6jIyRVbLh2KrKv
BiIaRUDjJ4Ij7znEXnRe7CkI9tE9jXF7pN5SHPUl+qZDEtbtPtuRde0VmnRr5Gw0
NNbdUQ0QwmwBVl6HGGFS
=A6aa
-----END PGP SIGNATURE-----

--P6h8VqiH1FAU4duNX5KNWtGX3TB41hKVj--
