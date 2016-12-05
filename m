From: Pavel Machek <pavel@ucw.cz>
Subject: Re: stmmac ethernet in kernel 4.9-rc6: coalescing related pauses.
Date: Mon, 5 Dec 2016 12:56:53 +0100
Message-ID: <20161205115653.GB16126@amd>
References: <20161123105125.GA26394@amd>
 <20161124085506.GA25007@amd>
 <20161124.110416.198867271899443489.davem@davemloft.net>
 <20161124212540.GA24796@amd>
 <b6ac7a3c-6774-9568-1cc0-97074eaa928f@st.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="rJwd6BRFiFCcLxzm"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <b6ac7a3c-6774-9568-1cc0-97074eaa928f@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--rJwd6BRFiFCcLxzm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> the idea behind the TX mitigation is to mix the interrupt and
> timer and this approach gave us real benefit in terms
> of performances and CPU usage (especially on SH4-200/SH4-300 platforms
> based).
> In the ring, some descriptors can raise the irq (according to a
> threshold) and set the IC bit. In this path, the NAPI  poll will be
> scheduled.
> But there is a timer that can run (and we experimented that no high
> resolution is needed) to clear the tx resources.

I'm sorry, but it is just broken. It could have never worked. If it
appered it did, you did not test it right.

First, low-res timers have resolution down to one per second (see
David's email). It is not acceptable to delay transmits for 40msec,
and certainly not acceptable to delay them for 1000msec.

Second, the logic is wrong:

        if (likely(priv->tx_coal_frames > priv->tx_count_frames))
	                mod_timer(&priv->txtimer,
 				STMMAC_COAL_TIMER(priv->tx_coal_timer));
	                else {
 				priv->tx_count_frames =3D 0;
 				priv->hw->desc->set_tx_ic(desc);
 				priv->xstats.tx_set_ic_bit++;
			}
								=09

doing tx_clean() after set number of packets, or set time after the
first packet is transmitted would make sense. But that's not what the
code does. As long as packets are being transmitted, you move the
timer into the future.. so that finally you run out of the place, then
wait for timer (!) and only then you do the cleaning.

Third, times are wrong by order of magnitude. AFAICT cleaning should
be at around 5msec at 100mbit speeds, and at around .5msec at
gigabit. You have 40msec there. (Perhaps that is not too important if
the logic is fixed, as described above).

Best regards,
								Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--rJwd6BRFiFCcLxzm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlhFVgUACgkQMOfwapXb+vJKZgCdECNN7YJBvAXv1wznGamW4big
S8MAn3zN6E3SmiqupnSbGwj4tcKVXbnH
=68Ny
-----END PGP SIGNATURE-----

--rJwd6BRFiFCcLxzm--
