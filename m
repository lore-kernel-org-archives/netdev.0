From: Yury Polyanskiy <ypolyans@princeton.edu>
Subject: Re: [PATCH] xfrm: SAD entries do not expire correctly after
 suspend-resume
Date: Mon, 9 Nov 2009 13:31:53 -0500
Message-ID: <20091109133153.668bb296@penta.localdomain>
References: <20091108211249.2ecdfd38@penta.localdomain>
	<20091109153910.GA8039@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/iv4duz1M7tmAbIncNh9WFo/"; protocol="application/pgp-signature"
Cc: netdev@vger.kernel.org, davem@davemloft.net, peterz@infradead.org,
	yoshfuji@linux-ipv6.org, tglx@linutronix.de, mingo@elte.hu
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ppa02.Princeton.EDU ([128.112.128.216]:52030 "EHLO
	ppa02.Princeton.EDU" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751016AbZKISec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 13:34:32 -0500
In-Reply-To: <20091109153910.GA8039@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/iv4duz1M7tmAbIncNh9WFo/
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 9 Nov 2009 10:39:10 -0500
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> However, I have some reservations as to whether this is the ideal
> situation.  Unless I'm mistaken, this patch may cause IPsec SAs
> to expire if the system clock was out of sync prior to IPsec startup
> and is subsequently resynced by ntpdate or similar.
>=20
> For example, it's quite common for clocks to be out-of-sync by
> 10 hours in Australia due to time zone issues with BIOS clocks.
> So potentially ntpdate could move the clock forward by 10 hours
> or more on bootup thus causing IPsec SAs to expire prematurely
> with this patch.
>=20
> This shouldn't really be a problem in itself except that there
> are some dodgy IPsec gateways out there that refuse to reestablish
> IPsec SAs if the interval between two successive connections is
> too small.  This could render the SA inoperable for hours.

But why would it be inoperable for hours?=20

I think that the following will happen:
* racoon will recreate SAD entry in the larval state, wait 30s and drop
  it (since dodgy-gw filtered out all keyexchange packets)
* The next time there is a connect() with a match in the SPD, racoon
  will again try to recreate the SAD entry. If there dodgy-gw still
  filters out, the larval SAD entry dies after 30s.

So the inoperability will only last as long as dodgy-gw filters
keyexchanges.=20

In any case, running ntpdate before racoon fixes the problem.

>=20
> So the upshot of all this is that we definitely want the effect
> of this patch for suspend/resume, but it would be great if we can
> avoid it for settimeofday(2).

I think the natural solution is to have CLOCK_BOOTBASED hrtimers. I.e.
something in the spirit of monotonic_to_bootbased() and getboottime().
I understand that doing +=3Dtotal_sleep_time is against the core idea of
hires timers, but perhaps there is a nicer way.

Best,
Y

--Sig_/iv4duz1M7tmAbIncNh9WFo/
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkr4YBkACgkQemuRe3zuqOTJCwCgkPeESqnm0+blOu4GiRU8vB3S
lQ0An3recE9OReLwuVPR//W+v6fmlTZ0
=9tpH
-----END PGP SIGNATURE-----

--Sig_/iv4duz1M7tmAbIncNh9WFo/--
