From: Pavel Machek <pavel@ucw.cz>
Subject: Re: stmmac tx timeout
Date: Tue, 23 May 2017 15:39:46 +0200
Message-ID: <20170523133946.GA7713@amd>
References: <fc8e5141-5815-9a6d-51ed-ddd7e5c2bbc8@axis.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="0OAP2g/MAC+5xKAE"
Cc: Alexandre Torgue <alexandre.torgue@st.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Lars Persson <larper@axis.com>, netdev <netdev@vger.kernel.org>
To: Niklas Cassel <niklas.cassel@axis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:54920 "EHLO
        atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761419AbdEWNjt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 09:39:49 -0400
Content-Disposition: inline
In-Reply-To: <fc8e5141-5815-9a6d-51ed-ddd7e5c2bbc8@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--0OAP2g/MAC+5xKAE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> I'm debugging a transmit queue 0 timeout on stmmac with DWMAC4 (4.10a).
> I'm using kernel v4.9.23, which is before multi queue support was added.
> I've cherry-picked
> 98a29944774a ("net: ethernet: stmmac: remove private tx queue lock")
> 84c53b4baef8 ("stmmac: fix memory barriers")
> but I still get tx timeouts with these patches.
>=20
> I've managed to reproduce the problem several times,
> mainly by transmitting the syslog over HTTP.

How long does it take till timeout? Umm. And if you go through the
list... I believe we understood what was wrong with the timeout
handling and how to fix it...

You may want to tweak tx coalescing parameters. If you set them
"right" you should get timeouts every 5 minutes or so. That makes it
easier to debug. This should do the trick:

+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
-#define STMMAC_COAL_TX_TIMER   40000
+#define STMMAC_COAL_TX_TIMER   1000

Now that you have driver that crashes early, you might want to do some
voodoo to stop the crashing. This worked for me:

@@ -2043,7 +2063,11 @@ static netdev_tx_t stmmac_xmit(struct sk_buff
*skb, stru\
ct net_device *dev)
        } else
	                priv->tx_count_frames =3D 0;

+       dma_rmb();
+       dma_wmb();
        /* To avoid raise condition */
+       BUG_ON(first->des01.etx.own); /* This BUG_ON seems to be enough.
+                                          Replacing it with barriers is _n=
ot_enough. */
        priv->hw->desc->set_tx_owner(first);
 	wmb();

No, the BUG_ON() does not trigger. Yes, it still fixes the driver for
me. You may want to verify it has same effect for you.

At that point I ran out of time, and out of goats to sacrifice. You
may be more lucky :-).
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--0OAP2g/MAC+5xKAE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlkkO6IACgkQMOfwapXb+vKbjwCfX84F6LuU1CbN/k6aFvVYS5oX
OJcAniM5Hvbs/FYeXZN1kcovSNlCd+H3
=2yUF
-----END PGP SIGNATURE-----

--0OAP2g/MAC+5xKAE--
