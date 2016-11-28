From: Pavel Machek <pavel@ucw.cz>
Subject: Re: stmmac ethernet in kernel 4.9-rc6: coalescing related pauses.
Date: Mon, 28 Nov 2016 13:13:32 +0100
Message-ID: <20161128121332.GC15034@amd>
References: <20161123105125.GA26394@amd>
 <20161124085506.GA25007@amd>
 <20161124.110416.198867271899443489.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="5G06lTa6Jq83wMTw"
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, alexandre.torgue@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:57261 "EHLO
        atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753790AbcK1MNf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 07:13:35 -0500
Content-Disposition: inline
In-Reply-To: <20161124.110416.198867271899443489.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--5G06lTa6Jq83wMTw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> >> drivers/net/ethernet/stmicro/stmmac/common.h
> >> #define STMMAC_COAL_TX_TIMER    40000
> >> #define STMMAC_MAX_COAL_TX_TICK 100000
> >> #define STMMAC_TX_MAX_FRAMES    256
> >>=20
> >> If I lower the parameters, delays are gone, but I get netdev watchdog
> >> backtrace followed by broken driver.
> >>=20
> >> Any ideas what is going on there?
> >=20
> > 4.9-rc6 still has the delays. With the
> >=20
> > #define STMMAC_COAL_TX_TIMER 1000
> > #define STMMAC_TX_MAX_FRAMES 2
> >=20
> > settings, delays go away, and driver still works. (It fails fairly
> > fast in 4.4). Good news. But the question still is: what is going on
> > there?
>=20
> 256 packets looks way too large for being a trigger for aborting the
> TX coalescing timer.
>=20
> Looking more deeply into this, the driver is using non-highres timers
> to implement the TX coalescing.  This simply cannot work.
>=20
> 1 HZ, which is the lowest granularity of non-highres timers in the
> kernel, is variable as well as already too large of a delay for
> effective TX coalescing.
>=20
> I seriously think that the TX coalescing support should be ripped out
> or disabled entirely until it is implemented properly in this
> driver.

Hmm. I still don't understand how the coalescing is supposed to do any
good in this driver.

As long as transmits happen, it seems driver is not recycling used DMA
descriptors. When the transmits stops, it waits for 40msec, then
recycles them. We'll run out of DMA descriptors in 5msec at 100mbit
speeds.

Giuseppe Cavallaro, Alexandre Torgue: could you comment here? Can you
apply the cleanup patches? The driver is marked as supported, but I
see no reactions on email, and bugzilla is down :-(.

Thanks,
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--5G06lTa6Jq83wMTw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlg8H2wACgkQMOfwapXb+vIl0QCggMpg9v1CIxSD5oFwtmCWqyd3
pT0An34HilBBC5OJY/y8e1Utg4wjjQR1
=I51t
-----END PGP SIGNATURE-----

--5G06lTa6Jq83wMTw--
