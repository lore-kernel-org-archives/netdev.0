From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v8 01/20] CAN : Add flow control processing.
Date: Sun, 12 Dec 2010 16:26:06 +0100
Message-ID: <4D04E98E.5090800@pengutronix.de>
References: <4CFE13E4.2020707@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6957107330546993352=="
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4CFE13E4.2020707-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
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
--===============6957107330546993352==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig779C94C24F67452167BA05DC"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig779C94C24F67452167BA05DC
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 12/07/2010 12:00 PM, Tomoya MORINAGA wrote:
> Currently, there is no flow control processing.
> Thus, Add flow control processing as
> when there is no empty of tx buffer,
> netif_stop_queue is called.
> When there is empty buffer, netif_wake_queue is called.

See comment inline.

> Signed-off-by: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
> ---
>  drivers/net/can/pch_can.c |   31 ++++++++++++-------------------
>  1 files changed, 12 insertions(+), 19 deletions(-)
>=20
> diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
> index a9b6a65..f0f1404 100644
> --- a/drivers/net/can/pch_can.c
> +++ b/drivers/net/can/pch_can.c
> @@ -102,6 +102,10 @@
> =20
>  #define PCH_FIFO_THRESH		16
> =20
> +/* TxRqst2 show status of MsgObjNo.17~32 */
> +#define PCH_TREQ2_TX_MASK	(((1 << PCH_TX_OBJ_NUM) - 1) <<\
> +							(PCH_RX_OBJ_END - 16))
> +
>  enum pch_ifreg {
>  	PCH_RX_IFREG,
>  	PCH_TX_IFREG,
> @@ -871,6 +875,8 @@ MSG_OBJ:
>  			dlc =3D 8;
>  		stats->tx_bytes +=3D dlc;
>  		stats->tx_packets++;
> +		if (int_stat =3D=3D PCH_TX_OBJ_END)
> +			netif_wake_queue(ndev);
>  	}
> =20
>  	int_stat =3D pch_can_int_pending(priv);
> @@ -1009,18 +1015,6 @@ static int pch_close(struct net_device *ndev)
>  	return 0;
>  }
> =20
> -static int pch_get_msg_obj_sts(struct net_device *ndev, u32 obj_id)
> -{
> -	u32 buffer_status =3D 0;
> -	struct pch_can_priv *priv =3D netdev_priv(ndev);
> -
> -	/* Getting the message object status. */
> -	buffer_status =3D (u32) pch_can_get_buffer_status(priv);
> -
> -	return buffer_status & obj_id;
> -}
> -
> -
>  static netdev_tx_t pch_xmit(struct sk_buff *skb, struct net_device *nd=
ev)
>  {
>  	int i, j;
> @@ -1031,17 +1025,16 @@ static netdev_tx_t pch_xmit(struct sk_buff *skb=
, struct net_device *ndev)
>  	if (can_dropped_invalid_skb(ndev, skb))
>  		return NETDEV_TX_OK;
> =20
> -	if (priv->tx_obj =3D=3D PCH_TX_OBJ_END) { /* Point tail Obj */
> -		while (pch_get_msg_obj_sts(ndev, (((1 << PCH_TX_OBJ_NUM)-1) <<
> -					   PCH_RX_OBJ_NUM)))
> -			udelay(500);
> +	if (priv->tx_obj =3D=3D PCH_TX_OBJ_END) {
> +		if (ioread32(&priv->regs->treq2) & PCH_TREQ2_TX_MASK)
> +			netif_stop_queue(ndev);

David asked you in his previous review to implement a pure software
solution without relying on the hardware because it tends to be racy.

> =20
> -		priv->tx_obj =3D PCH_TX_OBJ_START; /* Point head of Tx Obj ID */
> -		tx_buffer_avail =3D priv->tx_obj; /* Point Tail of Tx Obj */
> +		tx_buffer_avail =3D priv->tx_obj;
> +		priv->tx_obj =3D PCH_TX_OBJ_START;
>  	} else {
>  		tx_buffer_avail =3D priv->tx_obj;
> +		priv->tx_obj++;
>  	}
> -	priv->tx_obj++;
> =20
>  	/* Reading the Msg Obj from the Msg RAM to the Interface register. */=

>  	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[1].cmask);

cheers, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig779C94C24F67452167BA05DC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk0E6ZEACgkQjTAFq1RaXHOkfQCfYOcWycuoEAr7Uw0+WHk9gMl1
H3gAnjbrhyelv3OHgGbx/4+tRRgejrVL
=viGG
-----END PGP SIGNATURE-----

--------------enig779C94C24F67452167BA05DC--

--===============6957107330546993352==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============6957107330546993352==--
