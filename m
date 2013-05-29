From: Tom Parkin <tparkin@katalix.com>
Subject: Re: [RFC] l2tp: avoid checksum offload for fragmented packets
Date: Wed, 29 May 2013 18:15:32 +0100
Message-ID: <20130529171531.GB3179@raven>
References: <1368723860-22749-1-git-send-email-tparkin@katalix.com>
 <1368723860-22749-2-git-send-email-tparkin@katalix.com>
 <20130527185829.GO1942@kvack.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="z6Eq5LdranGa6ru8"
Cc: netdev@vger.kernel.org, jchapman@katalix.com
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:40960 "EHLO bert.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756816Ab3E2RPe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 May 2013 13:15:34 -0400
Content-Disposition: inline
In-Reply-To: <20130527185829.GO1942@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--z6Eq5LdranGa6ru8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Thanks, Ben.

On Mon, May 27, 2013 at 02:58:29PM -0400, Benjamin LaHaise wrote:
> > This change modifies the L2TP xmit path to fallback to software checksum
> > calculation if the L2TP packet + IP header exceeds the tunnel device MT=
U.
> > Since we don't know what the IP header length will be a priori, we assu=
me the
> > worst-case of 60b.  This will likely result in unnecessary software
> > checksumming when packet sizes approach the MTU since it's probably not=
 common
> > to be using the full IP header.
>=20
> Using the worst case value of 60 is a poor choice for many users of L2TP =
--
> plenty of the wholesale ISP services in the world using PPPoE transport=
=20
> sessions to ISPs using frame with headers of ethernet(14) + IP(20) + UDP(=
8) +=20
> L2TP(6) =3D 48 (this setup is used by a number of large telcos here in Ca=
nada). =20
> This will results in spurious use of software checksumming over links tha=
t=20
> are provisioned with the minimum usable MTU (which is common with this ki=
nd=20
> of link).  Please make the code calculate the correct size of the added=
=20
> headers to avoid uexpected CPU overhead.

Yes, I agree.  I wasn't sure whether direct calculation of the IP
header length would be acceptable, or whether there was another
mechanism available that I should be making use of.

I'll respin this patch with direct calculations rather than the worse-case
guess.

> > An alternative approach is to mimic UDP and use socket corking to allow=
 us to
> > pass the skb to the IP layer prior to finally pushing the button on xmi=
t.
> > This lets IP do his fragmentation before we authorise the packet send,
> > allowing us to check whether the packet was actually fragmented by IP o=
r not.
>=20
> That is probably undesirable from a CPU usage point of view.  Ideally, th=
e=20
> kernel's L2TP stack should generate ICMP frag needed messages for such=20
> frames to avoid the fragmentation overhead (ipip is one such tunnelling=
=20
> protocol that does this; there are others).

I agree.  That sounds like a better overall approach.  Perhaps we
could look at fixing up the immediate issue with a patch similar to
this (with your review comments resolved), and then add support for
ICMP frag needed messages as a further piece of work?

> > @@ -1197,30 +1224,14 @@ int l2tp_xmit_skb(struct l2tp_session *session,=
 struct sk_buff *skb, int hdr_len
> >  		uh->check =3D 0;
> > =20
> >  		/* Calculate UDP checksum if configured to do so */
> > +		if (sk->sk_no_check =3D=3D UDP_CSUM_NOXMIT)
> > +			skb->ip_summed =3D CHECKSUM_NONE;
> >  #if IS_ENABLED(CONFIG_IPV6)
> > -		if (sk->sk_family =3D=3D PF_INET6)
> > +		else if (sk->sk_family =3D=3D PF_INET6)
> >  			l2tp_xmit_ipv6_csum(sk, skb, udp_len);
> > -		else
> ...
>=20
> The last time I checked, for IPv6 UDP packets, the checksum MUST always b=
e=20
> calculated (RFC 2460).  If this has changed, you'll also need to update t=
he=20
> IPv6 UDP receive path to allow rx packets with a zero checksum, as I beli=
eve=20
> they are noisily dropped at present.

Good catch, I'll fix that by reverting this chunk.

--=20
Tom Parkin
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

--z6Eq5LdranGa6ru8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJRpjezAAoJEJSMBmUKuovQJS4IAKCJZAW27FhmFGRcEjAW73TO
59xUaSbyidpsxmP11erlQ8GiGeQ0A27XCGosDXep/XSpeF/qh1vEUv1ZE4F+JjLT
mfZkUlGKByGJA1kiuUj6L1bGb7BeQ8tVNuLdG9OwA/fMkl46JtXyVfM7o3WPW35V
3qfB1Gy13t6atFfvln1JB8tFiHwodBzC0KLSUuQlwRxaxMVfquVcFbC3ARvNaF3x
PLGuFxr2J2VJ1FljnaJ1zZeNW3R62OJcVs+128iSlbh6rh79qewiZJ+53fASiVe9
FljoiBhbZoP3c2f7IrrNzn2y3q4Bw5FmAgO86Y9ElWanJiURodROl6Gpc9Ki9/Y=
=qGDN
-----END PGP SIGNATURE-----

--z6Eq5LdranGa6ru8--
