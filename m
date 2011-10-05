From: Wolfram Sang <w.sang@pengutronix.de>
Subject: Re: [PATCH net] mscan: zero accidentally copied register content
Date: Wed, 5 Oct 2011 17:51:27 +0200
Message-ID: <20111005155127.GB13794@pengutronix.de>
References: <4E8C78E8.3010605@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="+g7M9IMkV8truYOl"
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Andre Naujoks <nautsch@gmail.com>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:59284 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758030Ab1JEPva (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2011 11:51:30 -0400
Content-Disposition: inline
In-Reply-To: <4E8C78E8.3010605@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--+g7M9IMkV8truYOl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Oct 05, 2011 at 05:34:00PM +0200, Oliver Hartkopp wrote:
> Due to the 16 bit access to mscan registers there's too much data copied =
to
> the zero initialized CAN frame when having an odd number of bytes to copy.
> This patch clears the data byte read from the invalid register entry.
>=20
> Reported-by: Andre Naujoks <nautsch@gmail.com>
> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
>=20
> ---
>=20
> Hello Wolf[gang|ram],
>=20
> from an error report from Andre Naujoks i tracked down the problem of
> uninitialized data in (normally) initialized CAN frames to the mscan driv=
er.
>=20
> Regards,
> Oliver
>=20
>=20
> diff --git a/drivers/net/can/mscan/mscan.c b/drivers/net/can/mscan/mscan.c
> index 92feac6..1b60fbe 100644
> --- a/drivers/net/can/mscan/mscan.c
> +++ b/drivers/net/can/mscan/mscan.c
> @@ -327,20 +327,23 @@ static void mscan_get_rx_frame(struct net_device *d=
ev, struct can_frame *frame)
>  	frame->can_dlc =3D get_can_dlc(in_8(&regs->rx.dlr) & 0xf);
> =20
>  	if (!(frame->can_id & CAN_RTR_FLAG)) {
>  		void __iomem *data =3D &regs->rx.dsr1_0;
>  		u16 *payload =3D (u16 *)frame->data;
> =20
>  		for (i =3D 0; i < (frame->can_dlc + 1) / 2; i++) {
>  			*payload++ =3D in_be16(data);
>  			data +=3D 2 + _MSCAN_RESERVED_DSR_SIZE;
>  		}
> +		/* zero accidentally copied register content at odd DLCs */
> +		if (frame->can_dlc & 1)
> +			frame->data[frame->can_dlc] =3D 0;
>  	}
> =20
>  	out_8(&regs->canrflg, MSCAN_RXF);

Nice catch, but wouldn't it be more elegant to never have an invalid byte
in the first place?

if (can_dlc & 1)
	*payload =3D in_be16() & mask;

Regards,

   Wolfram

--=20
Pengutronix e.K.                           | Wolfram Sang                |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--+g7M9IMkV8truYOl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAk6MfP8ACgkQD27XaX1/VRub+wCgmX2vMwjAaTKk44PeMbd+hFO1
vmwAn3UK5AlRjHG4YnZeXrnC6B6mEsxP
=0+ve
-----END PGP SIGNATURE-----

--+g7M9IMkV8truYOl--
