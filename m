From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 10/16] c_can: add 16bit align 32bit access functions
Date: Mon, 09 Sep 2013 11:57:34 +0200
Message-ID: <522D9B8E.2040400@pengutronix.de>
References: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de> <1378711513-2548-11-git-send-email-b.spranger@linutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="d6OC3VvG9r5iglTw8BFRcCqC99bS3v7np"
Cc: netdev@vger.kernel.org,
	Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Holger Dengler <dengler@linutronix.de>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: Benedikt Spranger <b.spranger@linutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1378711513-2548-11-git-send-email-b.spranger@linutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--d6OC3VvG9r5iglTw8BFRcCqC99bS3v7np
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 09/09/2013 09:25 AM, Benedikt Spranger wrote:
> The FlexCard only allows 32bit access to DCAN registers, otherwise the
> register value can be wraped up. Add a new helper function to access
> registers 16bit aligned but 32bit access.

You are modifying code you have previously added. You should shuffle
your patches that this is not necessary.

> Signed-off-by: Benedikt Spranger <b.spranger@linutronix.de>
> ---
>  drivers/net/can/c_can/c_can.c          |  1 +
>  drivers/net/can/c_can/c_can.h          |  1 +
>  drivers/net/can/c_can/c_can_platform.c | 38 ++++++++++++++++++++++++++=
++++++--
>  3 files changed, 38 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_ca=
n.c
> index c573399..46d741d 100644
> --- a/drivers/net/can/c_can/c_can.c
> +++ b/drivers/net/can/c_can/c_can.c
> @@ -1305,6 +1305,7 @@ struct net_device *alloc_c_can_dev(void)
>  	priv->can.ctrlmode_supported =3D CAN_CTRLMODE_LOOPBACK |
>  					CAN_CTRLMODE_LISTENONLY |
>  					CAN_CTRLMODE_BERR_REPORTING;
> +	spin_lock_init(&priv->lock);
> =20
>  	return dev;
>  }
> diff --git a/drivers/net/can/c_can/c_can.h b/drivers/net/can/c_can/c_ca=
n.h
> index 9f0eda8..beea437 100644
> --- a/drivers/net/can/c_can/c_can.h
> +++ b/drivers/net/can/c_can/c_can.h
> @@ -175,6 +175,7 @@ struct c_can_priv {
>  	u32 __iomem *raminit_ctrlreg;
>  	unsigned int instance;
>  	void (*raminit) (const struct c_can_priv *priv, bool enable);
> +	spinlock_t lock;
>  };
> =20
>  struct net_device *alloc_c_can_dev(void);
> diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c=
_can/c_can_platform.c
> index 43a3e3f..c6c1eb4 100644
> --- a/drivers/net/can/c_can/c_can_platform.c
> +++ b/drivers/net/can/c_can/c_can_platform.c
> @@ -58,6 +58,40 @@ static void c_can_plat_write_reg_aligned_to_16bit(st=
ruct c_can_priv *priv,
>  	writew(val, priv->base + priv->regs[index]);
>  }
> =20
> +#define ALIGN_DOWN(p, a)	((typeof(p))round_down((unsigned long)(p), (a=
)))
> +
> +static u16 c_can_plat_read_16bit_align_32bit_access(struct c_can_priv =
*priv,
> +						    enum reg index)
> +{
> +	void *addr =3D priv->base + priv->regs[index];

Please compile with C=3D2. Should be void __iomem *.

> +	u32 reg;
> +	reg =3D readl(ALIGN_DOWN(addr, 4));
> +
> +	return IS_ALIGNED((unsigned long)addr, 4) ?
> +			reg & 0xffff :
> +			reg >> 16;
> +}
> +
> +static void c_can_plat_write_16bit_align_32bit_access(struct c_can_pri=
v *priv,
> +						      enum reg index, u16 val)
> +{
> +	unsigned long flags;
> +	void *addr =3D priv->base + priv->regs[index];

dito

> +	u32 reg;
> +
> +	spin_lock_irqsave(&priv->lock, flags);
> +	reg =3D readl(ALIGN_DOWN(addr, 4));
> +	if (IS_ALIGNED((unsigned long)addr, 4)) {
> +		reg &=3D 0xffff0000;
> +		reg |=3D val;
> +	} else {
> +		reg &=3D 0xffff;
> +		reg |=3D val << 16;
> +	}
> +	writel(reg, ALIGN_DOWN(addr, 4));
> +	spin_unlock_irqrestore(&priv->lock, flags);
> +}
> +
>  static u16 c_can_plat_read_reg_aligned_to_32bit(struct c_can_priv *pri=
v,
>  						enum reg index)
>  {
> @@ -317,8 +351,8 @@ static int c_can_plat_probe(struct platform_device =
*pdev)
>  	case BOSCH_D_CAN_FLEXCARD:
>  		priv->regs =3D reg_map_d_can;
>  		priv->can.ctrlmode_supported |=3D CAN_CTRLMODE_3_SAMPLES;
> -		priv->read_reg =3D c_can_plat_read_reg_aligned_to_16bit;
> -		priv->write_reg =3D c_can_plat_write_reg_aligned_to_16bit;
> +		priv->read_reg =3D c_can_plat_read_16bit_align_32bit_access;
> +		priv->write_reg =3D c_can_plat_write_16bit_align_32bit_access;
>  		priv->instance =3D pdev->id;
> =20
>  		res =3D platform_get_resource(pdev, IORESOURCE_MEM, 1);
>=20

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--d6OC3VvG9r5iglTw8BFRcCqC99bS3v7np
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlItm44ACgkQjTAFq1RaXHMJ/gCgkjr5UumiwWs6HIRASfpHUhRl
3GYAnRnqEmmzySlW+bJaVrIyRWkoamZL
=NU9F
-----END PGP SIGNATURE-----

--d6OC3VvG9r5iglTw8BFRcCqC99bS3v7np--
