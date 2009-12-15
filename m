From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] wireless: wext: allocate space for NULL-termination
 for 32byte SSIDs
Date: Tue, 15 Dec 2009 11:03:31 +0100
Message-ID: <1260871411.3692.4.camel@johannes.local>
References: <1260650850-16163-1-git-send-email-daniel@caiaq.de>
	 <20091215.014308.77044043.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-Q0rfAH3PVOalrltMCQSk"
Cc: daniel@caiaq.de, linux-kernel@vger.kernel.org, dcbw@redhat.com,
	m.hirsch@raumfeld.com, netdev@vger.kernel.org,
	libertas-dev@lists.infradead.org, stable@kernel.org,
	linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755862AbZLOKEC@vger.kernel.org>
In-Reply-To: <20091215.014308.77044043.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-Q0rfAH3PVOalrltMCQSk
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2009-12-15 at 01:43 -0800, David Miller wrote:

> > The effect is that after a number of mode transistions (sometimes as fe=
w
> > as two sufficed), the kernel will oops at very strange locations, mostl=
y
> > in something like __kmem_alloc().
> >=20
> > While the root cause turned out to be an issue with the wpa-supplicant
> > which feeds the kernel driver with garbage, this occasion pointed out a
> > bug in the wireless wext core when SSIDs with 32 byte lengths are passe=
d
> > from userspace. In this case, the string is not properly NULL-terminate=
d
> > which causes some other part to corrupt memory.
> >=20
> > (In the particular case I observed, an SIOCSIWESSID was issued with
> >  bogus data in iwp->pointer but iwp->length=3D32).
> >=20
> > I admitedly couldn't find where the actual corruption itself happens,
> > but with this trivial fix, I can't reproduce the bug anymore.

Well you should try harder :)

> > -	/* kzalloc() ensures NULL-termination for essid_compat. */
> > -	extra =3D kzalloc(extra_size, GFP_KERNEL);
> > +	/* kzalloc() +1 ensures NULL-termination for essid_compat. */
> > +	extra =3D kzalloc(extra_size + 1, GFP_KERNEL);

That doesn't seem correct.

If this is used in a SET, then it is purely an in-kernel thing and
everything in the kernel is passed the length + data, and the kernel
MUST NEVER treat the SSID as a NUL-terminated string.

If this is used in a GET, then it will be filled up to 32 bytes by the
get handler, and the trailing \0 your patch reserves will never be
copied into userspace.

Since you indicate the kernel crashed, it is likely that libertas is
treating the buffer as a string, instead of an SSID.

That doesn't, however, make your fix and more valid. Whatever code uses
it as a string is clearly at fault, since this is a valid four-byte
SSID: "\x00\x01\x02\x03"

johannes

--=-Q0rfAH3PVOalrltMCQSk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJLJ17uAAoJEODzc/N7+QmakpQQAIIrYHyJcdJDdRtRLMroqt1c
zT+e+NIdWHxFT5XRxnzLVyDuJOrmE4/xNgWmHo/gZ60PZtQhaGQO+ekJTQTNSFYK
Il3pb5TKHR7WBGsJWj1ME14S6hswruCFCjDVgDMozXlFLYc1+QWoWkqHdanh2XaK
mdwxi1c13cHHWPTgZT5pYtaPELjDktqHJO79NQ7JUQ8JZCPCcxvPNg97l7yZ5kKl
AyBXbbvTuoG2KY94Lk0qgo1Mwf7Dm4fQNmIrwwFAaIpRZBidDQROTAtMaZcivSoL
tuvIiJTtpJzxHITx5+iZuHm8HZQHQgDj/lsPeBoodPy2aGNrp/VcPwulyYzY5FU/
JkeFTMMQEXNpFaa482EM1gyY8MKkyxUQojxU7/KDgpRrBxK1T9D1jp2ALDQfGxyA
SKE5uVsXrfag+7kM59Q/Dw1LJjcRVSZ0rc0D47Tn/lR98E/gJjxTknUBspyYUA6R
F0NIcZpgfoi4PdBC+b1/F2FcWN6Riy1aQ9paQcxkRSdpOVi4Mad+e+G4RrXJw6bT
5aC4BP9337aRAMmLjjl2yZXTSqZ4mbzLS6gVkxX5v39zMeKMgIMPnz/TqlMUZpFo
PcNjGuM7teS7s96rV4FzHgE2VuR1UKJBK8xxSWQUlD/inreh7xLYlH5CRHXf8Hwp
V8tFvhpOwnTxU4MIy+4O
=UhFJ
-----END PGP SIGNATURE-----

--=-Q0rfAH3PVOalrltMCQSk--
