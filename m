From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v3] can: Topcliff: PCH_CAN driver: Add Flow
	control,
Date: Wed, 24 Nov 2010 13:34:24 +0100
Message-ID: <4CED0650.7030004@pengutronix.de>
References: <4CE2434B.5050701@dsn.okisemi.com>	<4CE27796.2000206@pengutronix.de>	<007401cb87b1$a773b3d0$66f8800a@maildom.okisemi.com>	<4CE64167.2030405@pengutronix.de>
	<003201cb8a02$f05b15e0$66f8800a@maildom.okisemi.com>
	<4CEA2986.4080607@pengutronix.de>
	<000b01cb8b6b$d7542a90$66f8800a@maildom.okisemi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0830353262254892152=="
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <000b01cb8b6b$d7542a90$66f8800a-a06+6cuVnkTSQfdrb5gaxUEOCMrvLtNR@public.gmane.org>
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
--===============0830353262254892152==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigD7C6F9C39BB5CE0F44C31FBA"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigD7C6F9C39BB5CE0F44C31FBA
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 11/24/2010 01:09 AM, Tomoya MORINAGA wrote:
> On Monday, November 22, 2010 5:27 PM, Marc Kleine-Budde wrote:
>>>>>> Still we have the busy waiting in the TX path. Maybe you can move =
the
>>>>>> waiting before accessing the if[1] and remove the busy waiting her=
e.
>>>>> I can't understand your saying.
>>>>> For transmitting data, calling pch_can_rw_msg_obj is mandatory.
>>>> Yes, but the busy wait is not needed. It should be enough to do the
>>>> busy-waiting _before_ accessing the if[1].
>>>
>>> Do you mean we should create other pch_can_rw_msg_obj which doesn't h=
ave busy wait ?
>> ACK, and this non busy waiting is use in the TX path. But you add a bu=
sy
>> wait only function before accessing the if[1] in the TX path.
>=20
> The "busy waiting" of pch_can_rw_msg_obj is for next processing accesse=
s to Message object.
> If deleting this busy waiting, next processing can access to Message ob=
ject, regardless previous transfer doesn't
> complete yet.
> Thus, I think, the "busy waiting" is necessary.

Yes, it's necessary, but not where it is done currently.
Let me outline how I think the TX path should look like:

pch_xmit() {
	take_care_about_flow_control();
	prepare_can_frame_to_be_copied_to_tx_if();

	/* most likely we don't have to wait here */
	wait_until_tx_if_is_ready();

	copy_can_frame_to_tx_if();

	/* trigger tx in hardware */
	send_tx_if_but_dont_do_busywait();

	/* tx_if is busy now, but before we access it, we'll check tx_if is read=
y */
}

cheers, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigD7C6F9C39BB5CE0F44C31FBA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkztBlQACgkQjTAFq1RaXHPr7ACeJkeg1kQ9oEK5RJh6XWb/xN0s
DykAnAlk9+t5/r5/GKblZq00KthubUtC
=M+Vn
-----END PGP SIGNATURE-----

--------------enigD7C6F9C39BB5CE0F44C31FBA--

--===============0830353262254892152==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============0830353262254892152==--
