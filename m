From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC/T] [NET] make pskb_expand_head warn when called with
	invalid state
Date: Mon, 05 May 2008 18:01:14 +0200
Message-ID: <1210003274.8245.35.camel@johannes.berg>
References: <1209924962.3655.8.camel@johannes.berg>
	 <1210002047.8245.31.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-YC4DdZFXseg6LBMjyafd"
Cc: netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:47342 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758925AbYEEQCA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 12:02:00 -0400
In-Reply-To: <1210002047.8245.31.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-YC4DdZFXseg6LBMjyafd
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2008-05-05 at 17:41 +0200, Johannes Berg wrote:
> On Sun, 2008-05-04 at 20:16 +0200, Johannes Berg wrote:
> > This makes pskb_expand_head warn when called when a socket is attached.
> =20
> > +	WARN_ON((nhead || ntail) && skb->sk);
> > +
>=20
> This is triggering now. I think it's a false positive, trace below.
>=20
> [23194.608011] Badness at net/core/skbuff.c:726


> [23194.608077] [ccf9bba0] [c02735a0] pskb_expand_head+0x58/0x1f8 (unrelia=
ble)
> [23194.608082] [ccf9bbc0] [c02737a4] __pskb_pull_tail+0x64/0x374

It's actually not really a false positive. What is happening is that
__pskb_pull_tail does (follow 'eat'):

        /* If skb has not enough free space at tail, get new one
         * plus 128 bytes for future expansions. If we have enough
         * room at tail, reallocate without expansion only if skb is cloned=
.
         */
        int i, k, eat =3D (skb->tail + delta) - skb->end;

        if (eat > 0 || skb_cloned(skb)) {
                if (pskb_expand_head(skb, 0, eat > 0 ? eat + 128 : 0,
                                     GFP_ATOMIC))
                        return NULL;
        }

which of course changes the true size of the skb without accounting it
to the socket. Now, the reason this hasn't been known before is that the
data size doesn't change because the stuff that is copied into the
header is removed from the data_len... or something like that, I think.

johannes

--=-YC4DdZFXseg6LBMjyafd
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASB8vSaVg1VMiehFYAQL7Qg/+LtcZcTQPTVSm22kYPQ4rWbXqVuRvRFjG
/wRXxQWD7LqKxVnxkmx7a9rz0cr61lDw7NTqpO9l88OyBwl4w7J+H65ropRlKdQD
2pB3k/0qFdhi2BhpjNQYQGTiez433SeGnyaAhJnZwxT5jmZPrwF1UY6IpCtR4mxE
gDA8Yj2qc6E3IkajUUGlejYaOzfjdV0TgZPonAHOuZhntouNxkWTY1GitzWNGQVm
x3ssNh+UBR3HhkA29qPhLbmkwBJ2sid3JPLqoxxQ3EOEQvwhh6Lysi6wBNKpshFB
hjbAv6xD6etsNZQwe2SvWyK50k18zGv1+9X08Q8k8HhHhVDnY7QltTai08WzqIvg
rqvoeav2b83i5USuLa6p7PikS/wTu6H50LIm1n095qkQNWsC7ax8RUitOxIYg67N
/gNJOSAeJEGrRpyqIPcNnriGVPAT4k8d1LFn7uBLEQgRJq1fJVA9qDvv0U9a0bey
iGcxtqkeCaCUQFfflCbtjo0Fedamxm7W/R+GGIVokYOFAbtFC9YxZClfSyyyiO5O
SYnGmEHPaTthqJvqQ6vqiKEKqvihvhw51Q0o7M1Zj+yMVLgVDrZMDaBaFMfMaaZ1
v01NU4/UMJm0RlMp+cfdbxM2mfQ615xTxAqPLzQvJCd+a+xcP979+6zp+xtxiVZC
WRxcJihiMUU=
=jLU9
-----END PGP SIGNATURE-----

--=-YC4DdZFXseg6LBMjyafd--

