From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH V4 2/3] can: m_can: update to support CAN FD features
Date: Thu, 13 Nov 2014 11:10:10 +0100
Message-ID: <54648382.9080105@pengutronix.de>
References: <1415349914-9145-1-git-send-email-b29396@freescale.com> <1415349914-9145-2-git-send-email-b29396@freescale.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="ULtU4q3d12GRug08IDPtHFJ79otnoqwxR"
Cc: wg@grandegger.com, varkabhadram@gmail.com, netdev@vger.kernel.org,
	socketcan@hartkopp.net, linux-arm-kernel@lists.infradead.org
To: Dong Aisheng <b29396@freescale.com>, linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1415349914-9145-2-git-send-email-b29396@freescale.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--ULtU4q3d12GRug08IDPtHFJ79otnoqwxR
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/07/2014 09:45 AM, Dong Aisheng wrote:
> Bosch M_CAN is CAN FD capable device. This patch implements the CAN
> FD features include up to 64 bytes payload and bitrate switch function.=

> 1) Change the Rx FIFO and Tx Buffer to 64 bytes for support CAN FD
>    up to 64 bytes payload. It's backward compatible with old 8 bytes
>    normal CAN frame.
> 2) Allocate can frame or canfd frame based on EDL bit
> 3) Bitrate Switch function is disabled by default and will be enabled
>    according to CANFD_BRS bit in cf->flags.
>=20
> Acked-by: Oliver Hartkopp <socketcan@hartkopp.net>
> Signed-off-by: Dong Aisheng <b29396@freescale.com>

[...]

> -static void m_can_read_fifo(const struct net_device *dev, struct can_f=
rame *cf,
> -			    u32 rxfs)
> +static void m_can_read_fifo(struct net_device *dev, u32 rxfs)
>  {
> +	struct net_device_stats *stats =3D &dev->stats;
>  	struct m_can_priv *priv =3D netdev_priv(dev);
> -	u32 id, fgi;
> +	struct canfd_frame *cf;
> +	struct sk_buff *skb;
> +	u32 id, fgi, dlc;
> +	int i;
> =20
>  	/* calculate the fifo get index for where to read data */
>  	fgi =3D (rxfs & RXFS_FGI_MASK) >> RXFS_FGI_OFF;
> +	dlc =3D m_can_fifo_read(priv, fgi, M_CAN_FIFO_DLC);
> +	if (dlc & RX_BUF_EDL)
> +		skb =3D alloc_canfd_skb(dev, &cf);
> +	else
> +		skb =3D alloc_can_skb(dev, (struct can_frame **)&cf);
> +	if (!skb) {
> +		stats->rx_dropped++;
> +		return;
> +	}
> +
>  	id =3D m_can_fifo_read(priv, fgi, M_CAN_FIFO_ID);
>  	if (id & RX_BUF_XTD)
>  		cf->can_id =3D (id & CAN_EFF_MASK) | CAN_EFF_FLAG;
>  	else
>  		cf->can_id =3D (id >> 18) & CAN_SFF_MASK;
> =20
> -	if (id & RX_BUF_RTR) {
> +	if (id & RX_BUF_ESI) {
> +		cf->flags |=3D CANFD_ESI;
> +		netdev_dbg(dev, "ESI Error\n");
> +	}
> +
> +	if (!(dlc & RX_BUF_EDL) && (id & RX_BUF_RTR)) {
>  		cf->can_id |=3D CAN_RTR_FLAG;

I just noticed, that you don't set the cf->dlc (or cf->len) in the RTR
case. Please create a separate patch that fixes this problem.

>  	} else {
>  		id =3D m_can_fifo_read(priv, fgi, M_CAN_FIFO_DLC);
> -		cf->can_dlc =3D get_can_dlc((id >> 16) & 0x0F);
> -		*(u32 *)(cf->data + 0) =3D m_can_fifo_read(priv, fgi,
> -							 M_CAN_FIFO_DATA(0));
> -		*(u32 *)(cf->data + 4) =3D m_can_fifo_read(priv, fgi,
> -							 M_CAN_FIFO_DATA(1));
> +		if (dlc & RX_BUF_EDL)
> +			cf->len =3D can_dlc2len((id >> 16) & 0x0F);
> +		else
> +			cf->len =3D get_can_dlc((id >> 16) & 0x0F);
> +
> +		if (id & RX_BUF_BRS)
> +			cf->flags |=3D CANFD_BRS;
> +
> +		for (i =3D 0; i < cf->len; i +=3D 4)
> +			*(u32 *)(cf->data + i) =3D
> +				m_can_fifo_read(priv, fgi,
> +						M_CAN_FIFO_DATA(i / 4));
>  	}
> =20
>  	/* acknowledge rx fifo 0 */
>  	m_can_write(priv, M_CAN_RXF0A, fgi);
> +
> +	stats->rx_packets++;
> +	stats->rx_bytes +=3D cf->len;
> +
> +	netif_receive_skb(skb);
>  }

Regards,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--ULtU4q3d12GRug08IDPtHFJ79otnoqwxR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUZIOCAAoJECte4hHFiupU2fAP+wR+RDkSe6THhucHvpa/EQQe
WMgZ858tnE5OH/G7Mzntza1jeo0v4lasTfyGZqRJt8RLhcIKS2ZOXKdJKWZT1JpH
lw7fgkZiUb4zQXFwrUpOz0PlMxR5CENMoJiUCKowxra9ik6nxuderRYkRcTALStP
9TlgTimFGiZopfLJAMFyx4afyYe6LSINUUig3riUMBNNuHZZBZX/xdOgPGtzy7Qw
7l8WTlQvYdlO3TaSc9cEm97zgYKnEkb8vJ+p38VzJLU1vOHrCWr4S16gvKcTwTnZ
M8ycmBQdgQYc990obwMqhpoojybd7DFbPmQ5YuIRMU/acCV4Z/Fc1o75dePUXTMj
kOy9Y89Tv0g5EvSyCXQZ/U8Fz0zWCJvptYBKkkh1D5OEhQ0oUlg/k1Gj0HgUM1DA
jia9RUyp/LEyac7a4zrI6JpA8sIJZGTj/hEKmO04w0selJsufHF753RoDyZ6b1EN
Kx7pcHjsr9SR0XhQG6vOO9PZ+1YhU554IxhQZWxhYG90Aytm/mEy/cMfAzB1nheg
cjw2DbdYih/QtSbHxrwc+PfKiqI/GOzpwfS3LiZerMkXs/LvffuQl2snjWeAvfVk
S+pVyy41+0H16Z00wLqDB9GIMbexsr7rMCxAlj4Fb3+tYhQGWze2Vvag4wOQHHwV
j708Sv+FAHIkUrcMhXkl
=qlhI
-----END PGP SIGNATURE-----

--ULtU4q3d12GRug08IDPtHFJ79otnoqwxR--
