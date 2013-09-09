From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 05/16] c_can: use 32 bit access for D_CAN
Date: Mon, 09 Sep 2013 11:37:13 +0200
Message-ID: <522D96C9.1070306@pengutronix.de>
References: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de> <1378711513-2548-6-git-send-email-b.spranger@linutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="QhnCq3TuHgIDLk3DG5G1C3F51o2qOnGfS"
Cc: netdev@vger.kernel.org,
	Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Holger Dengler <dengler@linutronix.de>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: Benedikt Spranger <b.spranger@linutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1378711513-2548-6-git-send-email-b.spranger@linutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--QhnCq3TuHgIDLk3DG5G1C3F51o2qOnGfS
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 09/09/2013 09:25 AM, Benedikt Spranger wrote:
> Other than the C_CAN 16 bit memory interface the D_CAN uses a 32bit mem=
ory
> interface. This causes some trouble while accessing the IFxCMR register=
 in
> two 16bit chunks. Use 32bit access on D_CAN.
>=20
> Signed-off-by: Benedikt Spranger <b.spranger@linutronix.de>
> ---
>  drivers/net/can/c_can/c_can.c | 56 +++++++++++++++++++++++++++--------=
--------
>  1 file changed, 35 insertions(+), 21 deletions(-)
>=20
> diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_ca=
n.c
> index 886163f..b3cfb85 100644
> --- a/drivers/net/can/c_can/c_can.c
> +++ b/drivers/net/can/c_can/c_can.c
> @@ -262,11 +262,32 @@ static inline int get_tx_echo_msg_obj(const struc=
t c_can_priv *priv)
> =20
>  static u32 c_can_read_reg32(struct c_can_priv *priv, enum reg index)

What about introducing priv->{read,write}_reg32 function pointers?

>  {
> -	u32 val =3D priv->read_reg(priv, index);
> -	val |=3D ((u32) priv->read_reg(priv, index + 1)) << 16;
> +	u32 val;
> +
> +	if (priv->type =3D=3D BOSCH_D_CAN || priv->type =3D=3D BOSCH_D_CAN_FL=
EXCARD) {
> +		val =3D readl(priv->base + priv->regs[index]);
> +	} else {
> +		val =3D priv->read_reg(priv, index);
> +		val |=3D ((u32) priv->read_reg(priv, index + 1)) << 16;
> +	}
>  	return val;
>  }
> =20
> +static void c_can_writereg32(struct c_can_priv *priv, enum reg index,
> +		u16 high, u16 low)
> +{

If we decide not to introduce read/write 32 bit function pointers,
please rename your function to c_can_write_reg32() to match the pattern
of the read_reg32() function.

As you have converted some of the potential users of write_reg32() to
work with a single 32 bit value instead of two 16 bits, I think it's
better to call this function with a single 32 bite value.

> +	u32 val;
> +
> +	if (priv->type =3D=3D BOSCH_D_CAN || priv->type =3D=3D BOSCH_D_CAN_FL=
EXCARD) {
> +		val =3D high << 16;
> +		val |=3D low;
> +		writel(val, priv->base + priv->regs[index]);
> +	} else {
> +		priv->write_reg(priv, index + 1, high);
> +		priv->write_reg(priv, index, low);
> +	}
> +}
> +
>  static void c_can_enable_all_interrupts(struct c_can_priv *priv,
>  						int enable)
>  {
> @@ -309,10 +330,8 @@ static inline void c_can_object_get(struct net_dev=
ice *dev,
>  	 * register and message RAM must be complete in 6 CAN-CLK
>  	 * period.
>  	 */
> -	priv->write_reg(priv, C_CAN_IFACE(COMMSK_REG, iface),
> -			IFX_WRITE_LOW_16BIT(mask));
> -	priv->write_reg(priv, C_CAN_IFACE(COMREQ_REG, iface),
> -			IFX_WRITE_LOW_16BIT(objno));
> +	c_can_writereg32(priv, C_CAN_IFACE(COMREQ_REG, iface),
> +			IFX_WRITE_LOW_16BIT(mask), IFX_WRITE_LOW_16BIT(objno));
> =20
>  	if (c_can_msg_obj_is_busy(priv, iface))
>  		netdev_err(dev, "timed out in object get\n");
> @@ -329,9 +348,8 @@ static inline void c_can_object_put(struct net_devi=
ce *dev,
>  	 * register and message RAM must be complete in 6 CAN-CLK
>  	 * period.
>  	 */
> -	priv->write_reg(priv, C_CAN_IFACE(COMMSK_REG, iface),
> -			(IF_COMM_WR | IFX_WRITE_LOW_16BIT(mask)));
> -	priv->write_reg(priv, C_CAN_IFACE(COMREQ_REG, iface),
> +	c_can_writereg32(priv, C_CAN_IFACE(COMREQ_REG, iface),
> +			IF_COMM_WR | IFX_WRITE_LOW_16BIT(mask),
>  			IFX_WRITE_LOW_16BIT(objno));
> =20
>  	if (c_can_msg_obj_is_busy(priv, iface))
> @@ -496,23 +514,19 @@ static void c_can_setup_receive_object(struct net=
_device *dev, int iface,
>  {
>  	struct c_can_priv *priv =3D netdev_priv(dev);
> =20
> -	priv->write_reg(priv, C_CAN_IFACE(MASK1_REG, iface),
> -			IFX_WRITE_LOW_16BIT(mask));
> -
>  	/* According to C_CAN documentation, the reserved bit
>  	 * in IFx_MASK2 register is fixed 1
>  	 */
> -	priv->write_reg(priv, C_CAN_IFACE(MASK2_REG, iface),
> -			IFX_WRITE_HIGH_16BIT(mask) | BIT(13));
> -
> +	c_can_writereg32(priv, C_CAN_IFACE(MASK1_REG, iface),
> +			IFX_WRITE_HIGH_16BIT(mask) | BIT(13),
> +			IFX_WRITE_LOW_16BIT(mask));
>  	id |=3D IF_ARB_MSGVAL;
> -	priv->write_reg(priv, C_CAN_IFACE(ARB1_REG, iface),
> -			IFX_WRITE_LOW_16BIT(id));
> -	priv->write_reg(priv, C_CAN_IFACE(ARB2_REG, iface),
> -			(IFX_WRITE_HIGH_16BIT(id)));
> +	c_can_writereg32(priv, C_CAN_IFACE(ARB1_REG, iface),
> +			IFX_WRITE_HIGH_16BIT(id), IFX_WRITE_LOW_16BIT(id));
> +	c_can_writereg32(priv, C_CAN_IFACE(MSGCTRL_REG, iface), 0, mcont);
> =20
> -	priv->write_reg(priv, C_CAN_IFACE(MSGCTRL_REG, iface), mcont);
> -	c_can_object_put(dev, iface, objno, IF_COMM_ALL & ~IF_COMM_TXRQST);
> +	c_can_object_put(dev, iface, objno, IF_COMM_WR | IF_COMM_MASK |
> +			 IF_COMM_ARB | IF_COMM_CONTROL | IF_COMM_CLR_INT_PND);

I think the last change is unrelated.

> =20
>  	netdev_dbg(dev, "obj no:%d, msgval:0x%08x\n", objno,
>  			c_can_read_reg32(priv, C_CAN_MSGVAL1_REG));
>=20

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--QhnCq3TuHgIDLk3DG5G1C3F51o2qOnGfS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlItlskACgkQjTAFq1RaXHOIYQCdFig0f2JHYydwTyAhgouZpjRX
6NoAnjVdg6rE5+7FhN+4JP4+rK9VoRjZ
=hkPy
-----END PGP SIGNATURE-----

--QhnCq3TuHgIDLk3DG5G1C3F51o2qOnGfS--
