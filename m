From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [MeeGo-Dev][PATCH] Topcliff: Update PCH_CAN driver to 2.6.35
Date: Wed, 11 Aug 2010 15:04:37 +0200
Message-ID: <4C629FE5.6000204@pengutronix.de>
References: <4C61EDE5.4030505@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4667554511568606921=="
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	gregkh-l3A5Bk7waGM@public.gmane.org, yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, meego-dev-WXzIur8shnEAvxtiuMwx3w@public.gmane.org,
	arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Masayuki Ohtak <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4C61EDE5.4030505-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
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
--===============4667554511568606921==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigEA816B89CEC64391BF0E5A3B"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigEA816B89CEC64391BF0E5A3B
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

Masayuki Ohtak wrote:
> CAN driver of Topcliff PCH
>=20
> Topcliff PCH is the platform controller hub that is going to be used in=

> Intel's upcoming general embedded platform. All IO peripherals in
> Topcliff PCH are actually devices sitting on AMBA bus.=20
> Topcliff PCH has CAN I/F. This driver enables CAN function.

Thanks for your contribution. Some remarks in addition to Wolfgang's.

- Try to send patches directly with git send-email
- Rebase your tree to net-next-2.6.
- don't use global variables
- don't use that "int handle", e.g.:

> static int pch_can_msg_tx(int handle, struct pch_can_msg *msg,
> 			  struct net_device *ndev)
> {
> 	u32 id1 =3D 0;
> 	u32 id2 =3D 0;
> 	u32 data_a1 =3D 0;
> 	u32 data_a2 =3D 0;
> 	u32 data_b1 =3D 0;
> 	u32 data_b2 =3D 0;
> 	u32 tx_disable_counter =3D 0;
> 	u32 buffer_status =3D 0;
> 	u32 tx_buffer_avail =3D 0;
> 	u32 status;
> 	u32 i;
> 	u32 counter;
> 	enum pch_can_run_mode run_mode;
> 	int retval =3D 0;
> 	u32 if1_creq;
>=20
> 	if ((handle =3D=3D 0) || (msg =3D=3D NULL)) {
> 		dev_err(&ndev->dev, "%s -> Invalid Parameter.\n", __func__);
> 		retval =3D -EPERM;
> 	}
>=20
> 	else {
> 		/* Obatining the remap address for access. */
> 		struct can_hw *can =3D (struct can_hw *) handle;
>=20

use a proper struct. There are numerous drawbacks, no type safety it's
not 64 safe, bad style,...

- there are several checks for handle against 0 that make no real sense

- clean up you error paths:

if (error) {
	/* error handling */
} else {
	/* do real work */
}

This leads to a big indention level in the interesting code path, making
it very hard to read. Please rework your code this way:

if (error) {
	/* error handling */
	return error;
	/* or */
	goto out_handle_error;
}

/* do real work */

- get rid of the intermediate struct pch_can_msg:
  Your data path is:
  struct can_frame -> struct pch_can_msg -> registers
  write from struct can_frame into registers directly

- what's the purpose of "p_can_os->can_callback", call the function
  directly from the interrupt handler

- implement NAPI

- get rid of "1 << BIT_SHIFT_SIX" and friend,
  use "1 << 6" or "BIT(6)" if you like defines

- use defines to set bits in struct can_frame can_id

cheers, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigEA816B89CEC64391BF0E5A3B
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkxin+oACgkQjTAFq1RaXHN2iACfZjt9Ah8p7YSGSyiO+ESL77VR
FuYAoItW9KxeSUenEcD9MsLw370CZ/nY
=bNng
-----END PGP SIGNATURE-----

--------------enigEA816B89CEC64391BF0E5A3B--

--===============4667554511568606921==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============4667554511568606921==--
