From: Harald Welte <laforge@netfilter.org>
Subject: Re: NAT before IPsec with 2.6
Date: Wed, 28 Jan 2004 09:58:31 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040128085831.GM11761@sunbeam.de.gnumonks.org>
References: <20040124082252.GA19035@alpha.home.local> <Pine.LNX.4.44.0401241015470.32723-100000@filer.marasystems.com> <20040124092721.GA19140@alpha.home.local> <20040127103917.GC11761@sunbeam.de.gnumonks.org> <20040127132725.GA14685@openoffice.nl> <pan.2004.01.27.21.13.32.754125@dungeon.inka.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="w+rhPQc/K9ract27"
Cc: netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andreas Jellinghaus <aj@dungeon.inka.de>
Content-Disposition: inline
In-Reply-To: <pan.2004.01.27.21.13.32.754125@dungeon.inka.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--w+rhPQc/K9ract27
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Cc'ing netdev, since this is now a very clear proposal and not some
internal netfilter rambling.

On Tue, Jan 27, 2004 at 10:13:33PM +0100, Andreas Jellinghaus wrote:
> > This is what happens with incoming packets: they hit INPUT twice.
>=20
> yes, but once before and once after decryption. use either fwmark
> or an ipip tunnel interface to destinguish between already decrypted
> and was-never-encrypted packets.=20

yes, and this is desired.   However, the packets also hit PREROUTING
twice, which is exactly what we want (and get it for free, since
xfrm4_input.c calls netif_rx() again). =20

However, it doesn't reset the skb->nfct pointer, so connection tracking
sees both encapsulated and decapsulated packet as belonging to the same
connection.  This is wrong, and dangerous (application helpers might be
called for the encapsulated traffic, which now has a completely
different layer 4 protocol.

So with stock 2.6.x you have=20

- no working connection tracking in any kind of ipsec scenario
- conntrack and NAT helpers trying to find readable application data
  within already-encrypted packets
- no working DNAT/SNAT, mainly because of not-working connection
  tracking

> > On output, however, things are not so transparant. A packet hits OUTPUT,
> > then gets encrypted. A totally different packet hits POSTROUTING. This =
makes
> > no sense.
>=20
> use an interface, and you will see the packet twice, plus the interface
> does the route lookup on the encrypted packet. so no ugly hacks in the
> routing table are necessary.

Did anybody propose ugly hacks in the routing table?

> [symetry]
>=20
> that does not work:
> netfilter wants NAT to be the first thing for incoming packets
> and the last thing for outgoing packets. thats symetry.

yes, it is symmetric.  As is the symmetry between prerouting/postrouting
and input/output hooks. As well as the symmetry between SNAT and DNAt,
=2E..

> but you want ipsec encryption and decryption as soon as possible:
> both before looking at the routing table.

Yes, that's why what IPsec is doing for incoming ESP/AH packets the
right thing: go through PRE_ROUTING, route to LOCAL_IN, decapsulate,
and start over again.

However, for outgoing ESP/AH packets (locally-encapsulated), it doesn't
show the symmetric behaviour of what it does on the input side: go
through FORWARD, encapsulate, route, POST_ROUTING.  No starting over.

So we absolutely _need_ a symmetric-to-incoming behaviour like:

a) for locally-originated packets
LOCAL_OUT, POST_ROUTING, encapsulate, LOCAL_OUT, POST_ROUTING.

b) for forwarded, locally-encapsulated packets
PRE_ROUTING, FORWARD, POST_ROUTING, encapsulate, LOCAL_OUT, POST_ROUTING.

No, we don't achieve this by manipulating the routing code, but by
placing the respective hooks in ah{4,6}.c and esp{4,6}.c
{ah,esp}_output() function respectively. We also need to (again) reset
the skb->nfct and drop the conntrack reference again.

This way we=20
	1) make connection tracking work again
	2) do not change any routing of the current implementation
	3) enable users to
		a) filter unencapsulated, encapsulated and decapsulated
		   packeets at their 'expected' place
		b) do DNAT on the incoming decapsulated packets
		   (which doesn't work right now, but should)
		c) do SNAT on the outgoing/forwarded to-be-encapsualated
		   packets (which doesn't work right now, but should)

> mixing those two will never result in symetry. if you try it
> (routing before encapsulation), the result has problems.

I'm not proposing to route before encapsulating.  I just propose of
calling the same netfilter functions that we usually call before/after
routing at different places :)

> Andreas

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--w+rhPQc/K9ract27
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFAF3m3XaXGVTD0i/8RAqxuAJ4/Bsih+JQeaQ0TGsrVTWAnVKhmqACePVOc
M2GMr44fYlnKW5RM4SKJ5iA=
=324Q
-----END PGP SIGNATURE-----

--w+rhPQc/K9ract27--
