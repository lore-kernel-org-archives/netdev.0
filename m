From: Pavel Machek <pavel@ucw.cz>
Subject: Re: stmmac ethernet in kernel 4.9-rc6: coalescing related pauses.
Date: Fri, 2 Dec 2016 09:45:11 +0100
Message-ID: <20161202084511.GA32294@amd>
References: <20161123105125.GA26394@amd>
 <20161124085506.GA25007@amd>
 <20161124.110416.198867271899443489.davem@davemloft.net>
 <20161124212540.GA24796@amd>
 <b6ac7a3c-6774-9568-1cc0-97074eaa928f@st.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="2fHTh5uZTiUOsy+g"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        alexandre.torgue@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <b6ac7a3c-6774-9568-1cc0-97074eaa928f@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--2fHTh5uZTiUOsy+g
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> >>1 HZ, which is the lowest granularity of non-highres timers in the
> >>kernel, is variable as well as already too large of a delay for
> >>effective TX coalescing.
> >>
> >>I seriously think that the TX coalescing support should be ripped out
> >>or disabled entirely until it is implemented properly in this
> >>driver.
> >
> >Ok, I'd disable coalescing, but could not figure it out till. What is
> >generic way to do that?
> >
> >It seems only thing stmmac_tx_timer() does is calling
> >stmmac_tx_clean(), which reclaims tx_skbuff[] entries. It should be
> >possible to do that explicitely, without delay, but it stops working
> >completely if I attempt to do that.
> >
> >On a side note, stmmac_poll() does stmmac_enable_dma_irq() while
> >stmmac_dma_interrupt() disables interrupts. But I don't see any
> >protection between the two, so IMO it could race and we'd end up
> >without polling or interrupts...
>=20
>=20
> the idea behind the TX mitigation is to mix the interrupt and
> timer and this approach gave us real benefit in terms
> of performances and CPU usage (especially on SH4-200/SH4-300 platforms
> based).

Well, if you have a workload that sends and receive packets, it tends
to work ok, as you do tx_clean() in stmmac_poll(). My workload is not
like that -- it is "sending packets at 3MB/sec, receiving none". So
the stmmac_tx_timer() is rescheduled and rescheduled and rescheduled,
and then we run out of transmit descriptors, and then 40msec passes,
and then we clean them. Bad.

And that's why low-res timers do not cut it.

> In the ring, some descriptors can raise the irq (according to a
> threshold) and set the IC bit. In this path, the NAPI  poll will be
> scheduled.

Not NAPI poll but stmmac_tx_timer(), right?=20

> But there is a timer that can run (and we experimented that no high
> resolution is needed) to clear the tx resources.
> Concerning the lock protection, we had reviewed long time ago and
> IIRC, no raise condition should be present. Open to review it,
> again!

Well, I certainly like the fact that we are talking :-).

And yes, I have some questions.

There's nothing that protect stmmac_poll() from running concurently
with stmmac_dma_interrupt(), right?

Best regards,
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--2fHTh5uZTiUOsy+g
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlhBNJcACgkQMOfwapXb+vItqgCfYE0Tx53lZAEEnO5CbyvfijF6
lgcAn1JIX33pKIpTcgEutEtTrIbSfGSK
=P1hi
-----END PGP SIGNATURE-----

--2fHTh5uZTiUOsy+g--
