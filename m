From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 3/3] net: mvneta: Introduce a software TSO implementation
Date: Wed, 21 May 2014 03:11:31 +0100
Message-ID: <1400638291.17377.73.camel@deadeye.wl.decadent.org.uk>
References: <1397170682-19138-1-git-send-email-ezequiel.garcia@free-electrons.com>
	 <1397170682-19138-4-git-send-email-ezequiel.garcia@free-electrons.com>
	 <20140505144702.GB12693@arch.cereza>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Y8uLO8I9aZroWUTq6nFV"
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, cmetcalf@tilera.com,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Simon Guinot <simon.guinot@sequanux.org>,
	Willy Tarreau <w@1wt.eu>, Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Simon Guinot <sguinot@lacie.com>
To: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:36900 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750735AbaEUCLn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2014 22:11:43 -0400
In-Reply-To: <20140505144702.GB12693@arch.cereza>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Y8uLO8I9aZroWUTq6nFV
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-05-05 at 11:47 -0300, Ezequiel Garcia wrote:
> Hi all,
>=20
> On 10 Apr 07:58 PM, Ezequiel Garcia wrote:
> [..]
> > +
> > +	/* Calculate expected number of TX descriptors */
> > +	desc_count =3D skb_shinfo(skb)->gso_segs * 2 + skb_shinfo(skb)->nr_fr=
ags;
> > +	if ((txq->count + desc_count) >=3D txq->size)
> > +		return 0;
> > +
>=20
> Is this calculus correct? Does it give the accurate number of needed
> descriptors or is it an approximation?
>=20
> Tilera's tilegx driver does a much stricter descriptor count (see
> tso_count_edescs). This functions loops through the skb_frag_t fragments
> as it's done later in the data egress, hence strictly counting the
> needed descriptors.
>=20
> However, as it's a much heavier routine than the one shown above,
> I'm wondering if we can get away without it.
>=20
> Willy, Any ideas here?

There are (at least) three potential bugs you need to avoid:

1. You must not underestimate the number of descriptors required here,
otherwise the ring may overflow.  Hopefully that's obvious.
2. You must ensure that the worst case number of descriptors does
actually fit in the ring, and will probably need to set
net_dev->gso_max_segs accordingly.  Eric pointed that out already.
3. If you stop the queue because an skb doesn't fit, you should not wake
it before there is enough space.

A simple way to do this is:

- Set a maximum number of segments to support (for sfc, I reckoned that
100 was enough)
- Calculate the maximum number of descriptors that could be needed for
that number of segments
- Stop the queue when the free space in the ring is less than that
maximum
- Wake the queue when the free space reaches a threshold somewhere
between that maximum and completely free

It may make more sense to work backward from the ring size to maximum
number of segments.

Ben.

--=20
Ben Hutchings
Life would be so much easier if we could look at the source code.

--=-Y8uLO8I9aZroWUTq6nFV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUAU3wLWOe/yOyVhhEJAQpECw/+JbQOrjG1npXVYQmAfQsM9fK/MrxaCQ2t
BX+ziMq6L02MgXlBBKxAcq/mWxB1g1zrvAvBpOupZ+yp3MtNBBp8tI1yF64kRQTD
c+EaP0AhHnkR059YMfAkcDeBJ2BJ5clJ3Jrr//9WX7S6CyCXZw8fJGQ7PpTFlK/F
d8yy8YDJIykJKcPg514BPs/YB0GxZPFkBWteJ7Z5vY74WIF+IdRN7zaFPyKpYTlC
1IQWVZl4e98gP+DSeBkqLbPzSh37kMmBKKRPuY6XL09iaqp8u/pvtbJm01/V1C/f
FhnpeiDW0VGaUQPn0oBygUtlfV0Fel+ohaCoRAfwr2gTqrrQLf40hs1/RmCvydTf
Lt1CQBo7NcE/Y8IDB3GqdhciCMrMLwv+AD1vge4fhMbMGvokyd+2fPaWEBCFYcVn
Dw0r7Xt8qNf5e8y+SaIUP3yaWgO69B/vJoiNtweVzAQVxE+klJFuxoaRH1Ay370P
PKG8a7IeuVjXoL5h5UCFo5G+4dW8Rj5EYiwbrJ2HN9r7ubwWq93BH+oBE2lfehYE
zlxCXKZqRiZ/5fCiTU1MGVnHDNPoqY4lkbRTwx/hoBZkb+5QKMi9kbBsfvfPMlQI
hPvXHKhUHbN+i7D0z9nYXii64fbbfxCWuzhwsbzl+6lIvg9sc3EM5f72MvoJZjqa
TGy008Luoa8=
=6JWm
-----END PGP SIGNATURE-----

--=-Y8uLO8I9aZroWUTq6nFV--
