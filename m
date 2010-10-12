From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [MeeGo-Dev][PATCH v3] Topcliff: Update PCH_CAN driver to 2.6.35
Date: Tue, 12 Oct 2010 09:56:18 +0200
Message-ID: <4CB414A2.8020202@pengutronix.de>
References: <002e01cb6486$2ed72cc0$66f8800a@maildom.okisemi.com>	<20101005.114506.184852374.davem@davemloft.net>	<000b01cb6503$962bc7f0$66f8800a@maildom.okisemi.com>	<20101005.200904.71120150.davem@davemloft.net>	<4CAC3D94.9010408@grandegger.com>
	<000c01cb69dc$5d2aaab0$66f8800a@maildom.okisemi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5840871339136052127=="
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	chripell-VaTbYqLCNhc@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	morinaga526-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Masayuki Ohtake <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <000c01cb69dc$5d2aaab0$66f8800a-a06+6cuVnkTSQfdrb5gaxUEOCMrvLtNR@public.gmane.org>
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
--===============5840871339136052127==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig3B87C0D0490ADE06AA096FD8"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig3B87C0D0490ADE06AA096FD8
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hello Masayuki,

On 10/12/2010 09:09 AM, Masayuki Ohtake wrote:
> We have implemented our CAN driver with FIFO mode, and
> We are testing our CAN driver with FIFO mode.
> However, we have found Our CAN hardware spec is different from our anti=
cipated.
> Our CAN HW FIFO is not common FIFO.
> Using  FIFO mode, there is possibility received packets are out-of-orde=
r.

It's called a FIFO in the Documentation, but it's not a real FIFO as we
all hoped.

> e.g.
> Recv packet-A from NW and set to FIFO.
>   |A|
>=20
> Recv packet-B from NW and set to FIFO.
>   |A|B|
>=20
> Recv packet-C is about to set to FIFO
>   |A|B|(C)|
>=20
> Userspace Copies A from Driver
> Userspace Copies B from Driver
>   |   |   |(C)|
>=20
> packet-C set to FIFO (C is not head.)
> Recv packet-D from NW(Next packet is set to head)
>   |D|   |C|
>=20
> Userspace Copies D from Driver
> Userspace Copies C from Driver
> Userspace raceived packet order is like below
> A-B-D-C

I just had a small peak at the datasheet. It seems you can implement the
same scheme for rx as on the at91, if you enough rx buffers. In the at91
driver I use 8+4 =3D 12 buffers for rx. Have a look at the driver, the rx=

path is documented.

The driver uses 8 + 4 rx buffers, the trick is that a buffer in read but
_not_ marked as free, if I understand the intel datasheet correctly this
is by not resetting the NEWDAT bit. Becasue the driver doesn't free the
buffers it knows that the next CAN frame is in the next buffer. After
reading the 8th buffer, the first 8 buffers (0-7) are marked as free.
Then the driver continues to read buffers 8-11, they might have been
filled before marking 0-7 as free. Then the driver continues from the
beginning.

> So, I think normal-mode is better than FIFO-mode.

> I will revert like the following spec.
>   Rx 1 Message Object
>   Tx 1 Message Object
>=20
> Could you agree the above ?

ahh common...the hardware doesn't seem that bad :)

cheers, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig3B87C0D0490ADE06AA096FD8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAky0FKYACgkQjTAFq1RaXHMQ6ACfRgpERnqIkP7XXRSXnDu+TAER
eIMAoI3VVKbkEHqXohLne+gutbpytZPU
=ma5k
-----END PGP SIGNATURE-----

--------------enig3B87C0D0490ADE06AA096FD8--

--===============5840871339136052127==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============5840871339136052127==--
