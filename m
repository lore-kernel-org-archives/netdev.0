From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v5 4/8] net: can: c_can: Add syscon/regmap RAMINIT mechanism
Date: Fri, 14 Nov 2014 17:32:27 +0100
Message-ID: <54662E9B.9030104@pengutronix.de>
References: <1415371762-29885-1-git-send-email-rogerq@ti.com> <1415371762-29885-5-git-send-email-rogerq@ti.com> <546621C3.3010804@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="v8dGM74lRuEbqhWXi7HunCtEr6lt9i9uw"
Cc: wsa@the-dreams.de, tony@atomide.com, tglx@linutronix.de,
	mugunthanvnm@ti.com, george.cherian@ti.com, balbi@ti.com,
	nsekhar@ti.com, nm@ti.com, sergei.shtylyov@cogentembedded.com,
	linux-omap@vger.kernel.org, linux-can@vger.kernel.org,
	netdev@vger.kernel.org
To: Roger Quadros <rogerq@ti.com>, wg@grandegger.com
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <546621C3.3010804@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--v8dGM74lRuEbqhWXi7HunCtEr6lt9i9uw
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/14/2014 04:37 PM, Roger Quadros wrote:
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
>  drivers/net/can/c_can/c_can_platform.c             | 113 +++++++++++++=
+-------
>  3 files changed, 87 insertions(+), 40 deletions(-)
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
> index 1546c2b..89739a1 100644
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

My arm gcc-4.7.2 spits this warnings, I'll initialize ctrl to 0.

> drivers/net/can/c_can/c_can_platform.c: In function 'c_can_hw_raminit_w=
ait_syscon':
> drivers/net/can/c_can/c_can_platform.c:92:17: warning: 'ctrl' may be us=
ed uninitialized in this function [-Wuninitialized]
> drivers/net/can/c_can/c_can_platform.c: In function 'c_can_hw_raminit_s=
yscon':
> drivers/net/can/c_can/c_can_platform.c:115:7: warning: 'ctrl' is used u=
ninitialized in this function [-Wuninitialized]

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--v8dGM74lRuEbqhWXi7HunCtEr6lt9i9uw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUZi6bAAoJECte4hHFiupUs24P/iBfEfn/LzrMP5qTzWMSveNm
R5w96ldhfwr+/Uz3bzwAPLTwAdujXqO0S+C4jZ8BzvSKT7EzPXdg9ZJ++95P/8P9
+gxFc33fqVEe+gnLWiTEF1lJ2JIHFkfXHYhm4VJj1ZPKPjl+SF9stCnbfMINFzBk
lWAj3ryPkUO2E/rbbpENW33jQjy+57OoLV1o8PP2Ymv8XbBC44IlprbRvHkXr/bP
lXTHYpM0VbHqH85ObHmiMLgwXTznLsqYiB6mAjYoOHqIQYqcaWrrh9pYkpiVRE5+
s+YAlYuXr+CY3o+xa9B8g4YCGp+iANqSCHxI2oZcfvRuDKFxV+WRYHHicpnfUT54
9mANsHb4rhHMyHRgi7YAkGoamOZj3EpBOoh09tzpepEiyqiXLbPpw2/GKbIdG1x2
LL4Q6VHcCg11bUOKuagaSy+STqdlLsnGVhrGQehJwe4fGD7dkqoqLFDRe7KNRNVq
Ehs7tMFpeO3c7a7zlBegIuWNiSWmZu2J6Tm36ZEwJnpyy1N7twZkOlALWtvFw7vg
PBxBrAHbFoHI3qX2Es0QRjaSRS4GHK3fjOZvxW4EzGLn0zsh9n2fdQU4vwOASRwI
liD9yTkeewk4AVJYlSXQekdQz9HZAgtEa77ymIetqe5emCk20PyLXniXKvfK6hPO
ZDZAxCGXXapbCgI3VCbQ
=bVM2
-----END PGP SIGNATURE-----

--v8dGM74lRuEbqhWXi7HunCtEr6lt9i9uw--
