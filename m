From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: Re: [RFC] endianness bugs in net/batman-adv/
Date: Sat, 14 Apr 2012 11:34:05 +0200
Message-ID: <20120414093404.GA5300@ritirata.org>
References: <20120413194629.GP6589@ZenIV.linux.org.uk>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Dxnq1zWXvFF0Q93v"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120413194629.GP6589-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org


--Dxnq1zWXvFF0Q93v
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Apr 13, 2012 at 08:46:29 +0100, Al Viro wrote:
> 	Let's start with net/batman-adv/translation-table.c:send_tt_request().=
=20
> Its tt_crc argument gets stored into skb as-is and skb goes on the wire.
> OK, so it's fixed-endian, right?

ok, it's a bug. The tt_crc field must be stored in the skb by using htons().

>=20
> 	That sucker comes straight from the (only) caller - tt_update_orig().
> There it gets compared with ->tt_crc of struct orig_node instances.  Fine,
> except that just prior to that comparison we assign to ->tt_crc the return
> value of tt_global_crc().  Which is built on crc16_byte() and clearly
> returns a host-endian value.  Additionally, orig_node ->tt_crc is getting
> compared to tt_request->tt_data in send_other_tt_response(), which ultima=
tely
> comes from recv_tt_query() where it's flipped from net-endian to host-end=
ian.
>=20

We want to do every computation using host-endian data. There is no "fixed
endian" anywhere. As I wrote above, we forgot to use htons() before sending=
 the
tt_crc over the wire.

> 	It gets even funnier - we have 3 structures with ->tt_crc in them;
> one is struct orig_node (see above), another is struct batman_ogv_packet =
and
> then there's the weirdest one - struct bat_priv.  Where ->tt_crc is
> atomic_t, of all things.  With exactly two things ever done to it:
>         batman_ogm_packet->tt_crc =3D htons((uint16_t)
>                                                 atomic_read(&bat_priv->tt=
_crc));
> in bat_iv_ogm_schedule() and
>         atomic_set(&bat_priv->tt_crc, tt_local_crc(bat_priv));
> in prepare_packet_buffer().  What the hell does that have to do with atom=
ic_t?

Thank you for spotting this. It was defined as atomic_t in the early develo=
pment
phase of this new tt framework, but, then, I'd say that we forgot to conver=
t it
to uint16_t once atomic_t was not needed anymore.

> At least that one is definitely host-endian all along (tt_local_crc() is
> the same kind of built-on-crc16_byte() thing).
>=20
> 	And then there's batman_ogv_packet, where we flip the damn field
> from net-endian to host-endian and back.  That's where the argument of
> tt_update_orig() comes from, AFAICS always in host-endian form.
>=20
> 	IOW, unless I'm misreading that code we have
> bat_priv ->tt_crc: host-endian, no need to make it atomic_t

I agree.

> orig_node ->tt_crc: host-endian

I agree. As I said before we want to use host-endian everywhere. We just wa=
nt to
convert the data to net-endian before sending it over the wire (like people
should normally do).

> tt_update_orig()/send_tt_request() tt_crc argument: host-endian

I agree.

> the value put into the packet in send_tt_request(): broken; should be
> net-endian, in reality it's host-endian.  Missing htons() at the very
> least.
>=20

Exactly. This is the bug I was talking about in my first inline response.

All the problems come from a missing htons() before sending the tt_request
packet.

Thank you very much. I'll fix it.


Best regards,


--=20
Antonio Quartulli

=2E.each of us alone is worth nothing..
Ernesto "Che" Guevara

--Dxnq1zWXvFF0Q93v
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQEcBAEBAgAGBQJPiUSMAAoJEFMQTLzJFOZFGykH/1Z06lVeOXq7WyIeZdkwKEQH
AkdNCiprzUqTdAbpM67D7Gwrhc00zDw7FgT6gCZPqf7jxZcWtD1wDvsC+PGVQ8CF
+6ghdSiJvB8mRoMCxtJIfBFDD5iMJht3fUhK1OzcWU/+OACXbo06w+xtu07ijePw
UbiS9GcBdJ/U+shcRew3kXa7XW1ck7dig9TlyoDw/aWDjIiOjPpZQIAg3WFXWEIf
khfp6sbkA5gIfW6Wt7KLHJzrtP8vfvaH3gdnQMymrZZyPQrsO7Cfd8Do3gGZhV+6
nw4U67ef3ym1+Mmk7JRfV0Om71rWujsRbVP0KB9M4WT/61OKX02EXg4x8FPpKZY=
=JVFn
-----END PGP SIGNATURE-----

--Dxnq1zWXvFF0Q93v--
