From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] ioc3: fix incorrect use of htons/ntohs
Date: Mon, 15 Dec 2014 21:09:25 +0000
Message-ID: <1418677765.30883.23.camel@decadent.org.uk>
References: <1417344054-4374-1-git-send-email-LinoSanfilippo@gmx.de>
	 <1417406976.7215.126.camel@decadent.org.uk>
	 <20141215181444.GD26674@linux-mips.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Zix5fHZKM620G0OqlTYM"
Cc: Lino Sanfilippo <LinoSanfilippo@gmx.de>, linux-mips@linux-mips.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141215181444.GD26674@linux-mips.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-Zix5fHZKM620G0OqlTYM
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-12-15 at 19:14 +0100, Ralf Baechle wrote:
> On Mon, Dec 01, 2014 at 04:09:36AM +0000, Ben Hutchings wrote:
>=20
> > >  	/* Same as tx - compute csum of pseudo header  */
> > >  	csum =3D hwsum +
> > > -	       (ih->tot_len - (ih->ihl << 2)) +
> > > -	       htons((uint16_t)ih->protocol) +
> > > +	       (ih->tot_len - (ih->ihl << 2)) + ih->protocol +
> > >  	       (ih->saddr >> 16) + (ih->saddr & 0xffff) +
> > >  	       (ih->daddr >> 16) + (ih->daddr & 0xffff);
> > >
> >=20
> > The pseudo-header is specified as:
> >=20
> >                      +--------+--------+--------+--------+
> >                      |           Source Address          |
> >                      +--------+--------+--------+--------+
> >                      |         Destination Address       |
> >                      +--------+--------+--------+--------+
> >                      |  zero  |  PTCL  |    TCP Length   |
> >                      +--------+--------+--------+--------+
> >=20
> > The current code zero-extends the protocol number to produce the 5th
> > 16-bit word of the pseudo-header, then uses htons() to put it in
> > big-endian order, consistent with the other fields.  (Yes, it's doing
> > addition on big-endian words; this works even on little-endian machines
> > due to the way the checksum is specified.)
> >=20
> > The driver should not be doing this at all, though.  It should set
> > skb->csum =3D hwsum; skb->ip_summed =3D CHECKSUM_COMPLETE; and let the
> > network stack adjust the hardware checksum.
>=20
> Really?  The IOC3 isn't the exactly the smartest NIC around; it does add =
up
> everything and the kitchen sink, that is ethernet headers, IP headers and
> on RX the frame's trailing CRC.

That is almost exactly what CHECKSUM_COMPLETE means on receive; only the
CRC would need to be subtracted.  Then the driver can validate
{TCP,UDP}/IPv{4,6} checksums without any header parsing.

> All that needs to be subtracted in software
> which is what this does.  I think others NICs are all smarted and don't
> need this particular piece of magic.

It may not be smart, but that allows it to cover more cases than most
smart network controllers!

On transmit, the driver should:
- Calculate the partial checksum of data up to offset csum_start
- Subtract this from the checksum at offset (csum_start + csum_offset)
It should set the NETIF_F_GEN_CSUM feature flag rather than
NETIF_F_IP_CSUM.  Then it will be able to generate {TCP,UDP}/IPv{4,6}
checksums.

Ben.

> I agree with your other comment wrt. to htons().


--=20
Ben Hutchings
The two most common things in the universe are hydrogen and stupidity.

--=-Zix5fHZKM620G0OqlTYM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVI9OCue/yOyVhhEJAQqxHhAAtq+Ozd3aCYDzZ4brcMbPbnbxoruJY70N
tJvXWYPHqDc9y9XDtHtWLGCKpkByqX3a38N6sulCDJ8pN1mFBF9ws9oDF8nd6M0b
h+RwlFqIm25oiwPblrKf1yxNSeGFHoTGyId3UpKG8uvnwV6OD4T1HNF+Xb6BfYZv
EyNaLwpl8Q11HLINSO8GNv78gqpCqeeUXDRw4aucmxsAJOHVUpOcHmh2PUbDNezf
pEbHN6ydpGmaOYSMwYwxXw9q//TjBNuE8nZsLsb7ifc7SB9JUKLLz7mAhWDHubyg
GsWJrbnVwBPsSYz64d76hxfmj0Klnj1FxfKUNCUQv0gv0HvhhxwiH1XFTWRGqr73
RXhnRhCuKmF6VS1P2AaKttidO2cxMXAjLpcO+WsyiuzRHcF71Q/w8VqMrH5sDW9W
SpyIstDV1L2ypErS450ej+rUR5EnPzIATDfo7RlOsRoXeohNW4olbGlYzMuMQXkR
yWNrbiWC9+rjlumxoZcZlq0y7t1nuPc2DzbXfmjAFbUathjIGiz18XEVT0LvvTiv
vqeHLAbHbuk+zYiHHb2oskm4q6rIbzR4segMOi1CJdONB6yIUu+uqd7BMQGlgqk7
9fcDn1/Cb5bUizH33lIU+C15Nq22n4nYqNw5xbExQrdKad7v89/iRqOUIZWSOR91
C2jWo0Lu2Sc=
=TgJb
-----END PGP SIGNATURE-----

--=-Zix5fHZKM620G0OqlTYM--
