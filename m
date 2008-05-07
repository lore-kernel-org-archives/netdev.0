From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC/RFT 3/4] mac80211: use GSO for fragmentation
Date: Wed, 07 May 2008 10:50:17 +0200
Message-ID: <1210150217.9305.39.camel@johannes.berg>
References: <20080430124055.091382000@sipsolutions.net>
	 <20080430130050.105344000@sipsolutions.net>
	 <20080507071026.GA24407@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-SUH3KrCrxUzNn4DwA+6j"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Ron Rindjunsky <ron.rindjunsky@intel.com>,
	Tomas Winkler <tomasw@gmail.com>,
	Ivo van Doorn <ivdoorn@gmail.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:53164 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755358AbYEGIvD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 04:51:03 -0400
In-Reply-To: <20080507071026.GA24407@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-SUH3KrCrxUzNn4DwA+6j
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2008-05-07 at 15:10 +0800, Herbert Xu wrote:
> On Wed, Apr 30, 2008 at 02:40:58PM +0200, Johannes Berg wrote:
> > This patch makes mac80211 use the GSO infrastructure for segmentation,
> > but not really all of it because we do not register a protocol handler
> > (nor can do that easily since a lot of functions need to be done before
> > segmentation and another bunch afterwards, and we need to keep rcu-
> > protected structures for both.)
>=20
> Your idea of using skb_segment to remove duplicate code is great.
>=20
> However, using skb->gso_skb for the push-back doesn't work.  For
> example, what is going to happen when I enable software GSO on a
> wireless device and then send a real GSO packet to it where each
> GSO fragment also required wireless fragmentation?

Good point. Somehow I thought this couldn't happen but of course it can
since we don't do hw GSO.

> I suggest that you just use skb_segment for the actual fragmentation
> but keep the original infrastructure for handling the fragments.

But I want to get rid of that much more than I want to get rid of the
fragmentation code :/ Also, if I need to keep that code, I will
absolutely not use skb_segment either as it's more efficient to just
trim the existing skb to make the first segment out of it (like the code
does now) rather than reallocate that too.

However, I'm sure it's buggy under certain circumstances we never
understood (as indicated by a WARN_ON triggering that shouldn't and lots
of reports about that) and I don't like the extra tasklet. I guess I
could remove it and copy the existing code into the wireless qdisc, but
that would be weird.

But you're right, it doesn't work this way. I'll have to think of
something. Maybe I can rip out all the retry logic and just store an skb
myself (like dev->gso_skb) and return NETDEV_TX_BUSY when I used that
one and the queue got full because of it. That'll requeue a lot when
non-gso skbs are coming in, but mind you this is not a common case, most
of the time fragmentation will not be enabled and even when it is device
queues should be long enough.

johannes

--=-SUH3KrCrxUzNn4DwA+6j
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASCFtSKVg1VMiehFYAQJHWg//V2LU1QUQsR/lzHCcDqfmsSv+K5ippMkh
gqWNIaMYoJvza2+k6xvk4+x7FGww4tuqfwiTXW6yblm/SFRsf1VP430J+UHZsAxg
AU5HUxuLqMkLXzWw76C9sWY8Y6IU5dViwDUp9RH81u1O1lIFD1zzO29SOmvSNWUZ
AnRb1wYjJviccvYNploQv67SCL/VOQOdz35HFwZu0jG7E0OgVm6HmZWk/nKbhObu
bUhZBQDa92FpvyYkBsbu5scT7EfS/8OUyOdJhQebKRjHWvqB/WW1Lw/JOZWpQ1KS
UcajPrh/JNZvhEqqyP++gO1nZjSlL8SHDa8WEG93AqTc9P5zpnGAouvwMFoc26oi
YdFJsgM/mxOcnZkZhshym3rqdYLY3TEvVhkAOH1ifnV9Wu6iPQtjvXQHH0h0HiMt
GHPtgvJvp9sOm4a3rKHzt+n/ddbRXr2baSbON8S0LhG52T2u/kS0hVjkS3ZMJnVn
eYfZNUq9peWO+oHYRXIFqw4qeciGrgKB0S3Tiyaxz60Ngfaq+27Unms1/kZCBYhm
3WacOtZKZuwnD+pVQyzRqcPPjXAzJpWnfwjhIfwvSYEWNl5yrhQhtHdGW3NUsvIR
jr9v5QIW8aWFZ4n/zBbA6GZV5nrEgOLCKF2TWGiEKyuLnQHyoxawrBiCpx2PuvmX
UksI02BI70Y=
=TkV2
-----END PGP SIGNATURE-----

--=-SUH3KrCrxUzNn4DwA+6j--

