From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v8 18/20] CAN : Optimize "if" condition in
	rx/tx	processing
Date: Sun, 12 Dec 2010 16:16:45 +0100
Message-ID: <4D04E75D.10704@pengutronix.de>
References: <4CFE166D.8040805@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2851142339885380686=="
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4CFE166D.8040805-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
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
--===============2851142339885380686==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig0B4D4768880F210FDDDD36B2"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig0B4D4768880F210FDDDD36B2
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 12/07/2010 12:11 PM, Tomoya MORINAGA wrote:
> For reduce "if" condition, easy to read/understand the code,
> optimize "if" condition in rx/tx processing.
>=20
> Signed-off-by: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Acked-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
> ---
>  drivers/net/can/pch_can.c |   26 ++++++++++----------------
>  1 files changed, 10 insertions(+), 16 deletions(-)
>=20
> diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
> index 8efbe35..dcd8f00 100644
> --- a/drivers/net/can/pch_can.c
> +++ b/drivers/net/can/pch_can.c
> @@ -746,19 +746,16 @@ static int pch_can_poll(struct napi_struct *napi,=
 int quota)
> =20
>  	if (int_stat =3D=3D PCH_STATUS_INT) {
>  		reg_stat =3D ioread32(&priv->regs->stat);
> -		if (reg_stat & (PCH_BUS_OFF | PCH_LEC_ALL)) {
> -			if (reg_stat & PCH_BUS_OFF ||
> -			   (reg_stat & PCH_LEC_ALL) !=3D PCH_LEC_ALL) {
> -				pch_can_error(ndev, reg_stat);
> -				quota--;
> -			}
> -		}
> =20
> -		if (reg_stat & PCH_TX_OK)
> -			pch_can_bit_clear(&priv->regs->stat, PCH_TX_OK);
> +		if ((reg_stat & (PCH_BUS_OFF | PCH_LEC_ALL)) &&
> +		   ((reg_stat & PCH_LEC_ALL) !=3D PCH_LEC_ALL)) {
> +			pch_can_error(ndev, reg_stat);
> +			quota--;
> +		}
> =20
> -		if (reg_stat & PCH_RX_OK)
> -			pch_can_bit_clear(&priv->regs->stat, PCH_RX_OK);
> +		if (reg_stat & (PCH_TX_OK | PCH_RX_OK))
> +			pch_can_bit_clear(&priv->regs->stat,
> +					  reg_stat & (PCH_TX_OK | PCH_RX_OK));
> =20
>  		int_stat =3D pch_can_int_pending(priv);
>  	}
> @@ -900,14 +897,13 @@ static netdev_tx_t pch_xmit(struct sk_buff *skb, =
struct net_device *ndev)
>  	if (can_dropped_invalid_skb(ndev, skb))
>  		return NETDEV_TX_OK;
> =20
> +	tx_obj_no =3D priv->tx_obj;
>  	if (priv->tx_obj =3D=3D PCH_TX_OBJ_END) {
>  		if (ioread32(&priv->regs->treq2) & PCH_TREQ2_TX_MASK)
>  			netif_stop_queue(ndev);
> =20
> -		tx_obj_no =3D priv->tx_obj;
>  		priv->tx_obj =3D PCH_TX_OBJ_START;
>  	} else {
> -		tx_obj_no =3D priv->tx_obj;
>  		priv->tx_obj++;
>  	}
> =20
> @@ -926,9 +922,7 @@ static netdev_tx_t pch_xmit(struct sk_buff *skb, st=
ruct net_device *ndev)
>  	id2 |=3D PCH_ID_MSGVAL;
> =20
>  	/* If remote frame has to be transmitted.. */
> -	if (cf->can_id & CAN_RTR_FLAG)
> -		id2 &=3D ~PCH_ID2_DIR;
> -	else
> +	if (!(cf->can_id & CAN_RTR_FLAG))
>  		id2 |=3D PCH_ID2_DIR;
> =20
>  	iowrite32(id2, &priv->regs->ifregs[1].id2);


--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig0B4D4768880F210FDDDD36B2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk0E510ACgkQjTAFq1RaXHO/sgCgj2dWDPB8BiY2qtu4i+jWOdYg
GUgAoJgdMuYmkTeQm/D9AoTJr87xm8hj
=z6zT
-----END PGP SIGNATURE-----

--------------enig0B4D4768880F210FDDDD36B2--

--===============2851142339885380686==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============2851142339885380686==--
