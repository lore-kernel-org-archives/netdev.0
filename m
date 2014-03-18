From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [patch 02/12] can: c_can: Fix hardware raminit function
Date: Tue, 18 Mar 2014 19:38:52 +0100
Message-ID: <532892BC.7080406@pengutronix.de>
References: <20140318171007.528610837@linutronix.de> <20140318171126.720944558@linutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="GbkntDp5JbJ0ok6Bc6k3j9rCP9iHGpQhq"
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Markus Pargmann <mpa@pengutronix.de>,
	Benedikt Spranger <b.spranger@linutronix.de>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org
To: Thomas Gleixner <tglx@linutronix.de>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20140318171126.720944558@linutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--GbkntDp5JbJ0ok6Bc6k3j9rCP9iHGpQhq
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 03/18/2014 06:19 PM, Thomas Gleixner wrote:
> The function is broken in several ways:
>=20
>     - The function does not wait for the init to complete.
>       That can take quite some microseconds.
>=20
>     - No protection against being called for two chips at the same
>       time. SMP is such a new thing, right?
>=20
> Clear the start and the init done bit unconditionally and wait for
> both bits to be clear.
>=20
> In the enable path set the init bit and wait
> for the init done bit.
>=20
> Add proper locking.
>=20
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> ---
>  drivers/net/can/c_can/c_can_platform.c |   48 ++++++++++++++++++++++++=
++-------
>  1 file changed, 39 insertions(+), 9 deletions(-)
>=20
> Index: linux/drivers/net/can/c_can/c_can_platform.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux.orig/drivers/net/can/c_can/c_can_platform.c
> +++ linux/drivers/net/can/c_can/c_can_platform.c
> @@ -37,8 +37,10 @@
> =20
>  #include "c_can.h"
> =20
> -#define CAN_RAMINIT_START_MASK(i)	(1 << (i))
> -
> +#define CAN_RAMINIT_START_MASK(i)	(0x001 << (i))
> +#define CAN_RAMINIT_DONE_MASK(i)	(0x100 << (i))
> +#define CAN_RAMINIT_ALL_MASK(i)		(0x101 << (i))
> +static DEFINE_SPINLOCK(raminit_lock);
>  /*
>   * 16-bit c_can registers can be arranged differently in the memory
>   * architecture of different implementations. For example: 16-bit
> @@ -69,16 +71,44 @@ static void c_can_plat_write_reg_aligned
>  	writew(val, priv->base + 2 * priv->regs[index]);
>  }
> =20
> +static void c_can_hw_raminit_wait(const struct c_can_priv *priv, u32 m=
ask,
> +				  u32 val)
> +{
> +	/* We look only at the bits of our instance. */
> +	val &=3D mask;
> +	while ((readl(priv->raminit_ctrlreg) & mask) !=3D val)
> +		udelay(1);

Do we have to add a timeout here, or is it "safe" to have a potential
endless loop here? As you have probably tortured the hardware and driver
a lot (or have been tortured by them), I assume you would have added a
timeout check if you had seen a lockup here.

> +}
> +
>  static void c_can_hw_raminit(const struct c_can_priv *priv, bool enabl=
e)
>  {
> -	u32 val;
> +	u32 mask =3D CAN_RAMINIT_ALL_MASK(priv->instance);
> +	u32 ctrl;
> +
> +	spin_lock(&raminit_lock);
> =20
> -	val =3D readl(priv->raminit_ctrlreg);
> -	if (enable)
> -		val |=3D CAN_RAMINIT_START_MASK(priv->instance);
> -	else
> -		val &=3D ~CAN_RAMINIT_START_MASK(priv->instance);
> -	writel(val, priv->raminit_ctrlreg);
> +	ctrl =3D readl(priv->raminit_ctrlreg);
> +	/*
> +	 * We clear the done and start bit first. The start bit is
> +	 * looking at the 0 -> transition, but is not self clearing;
> +	 * And we clear the init done bit as well.
> +	 */

nitpick: In the driver/net tree multi line comments look different, the
text starts right after the /*. No need to resend, I'll adjust this
while applying the patch.

> +	ctrl &=3D ~CAN_RAMINIT_START_MASK(priv->instance);
> +	ctrl |=3D CAN_RAMINIT_DONE_MASK(priv->instance);
> +	writel(ctrl, priv->raminit_ctrlreg);
> +	ctrl &=3D ~CAN_RAMINIT_DONE_MASK(priv->instance);
> +	c_can_hw_raminit_wait(priv, ctrl, mask);
> +
> +	if (enable) {
> +		/*
> +		 * Set start bit and wait for the done bit.
> +		 */
> +		ctrl |=3D CAN_RAMINIT_START_MASK(priv->instance);
> +		writel(ctrl, priv->raminit_ctrlreg);
> +		ctrl |=3D CAN_RAMINIT_DONE_MASK(priv->instance);
> +		c_can_hw_raminit_wait(priv, ctrl, mask);
> +	}
> +	spin_unlock(&raminit_lock);
>  }
> =20
>  static struct platform_device_id c_can_id_table[] =3D {

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--GbkntDp5JbJ0ok6Bc6k3j9rCP9iHGpQhq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlMokrwACgkQjTAFq1RaXHOhgwCbBVpq5SJECLG5QMT0D3quHaA7
VHkAniPbnOugdF6ZdRpCVSOaeOYp1kwA
=Mywr
-----END PGP SIGNATURE-----

--GbkntDp5JbJ0ok6Bc6k3j9rCP9iHGpQhq--
