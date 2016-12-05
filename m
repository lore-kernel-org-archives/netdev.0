From: Pavel Machek <pavel@ucw.cz>
Subject: [PATCH] stmmac: disable tx coalescing
Date: Mon, 5 Dec 2016 13:27:11 +0100
Message-ID: <20161205122711.GA30774@amd>
References: <20161123105125.GA26394@amd>
 <20161124085506.GA25007@amd>
 <20161124.110416.198867271899443489.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="qDbXVdCdHGoSgWSk"
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, alexandre.torgue@st.com,
        LinoSanfilippo@gmx.de
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161124.110416.198867271899443489.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--qDbXVdCdHGoSgWSk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


Tx coalescing in stmmac is broken in more than one way, so disable it
for now.
   =20
First, low-res timers have resolution down to one per second. It is
not acceptable to delay transmits for 40msec, and certainly not
acceptable to delay them for 1000msec.
   =20
Second, the logic is wrong:
   =20
    if (likely(priv->tx_coal_frames > priv->tx_count_frames))
     	mod_timer(&priv->txtimer,
     	          STMMAC_COAL_TIMER(priv->tx_coal_timer));
    ...
   =20
doing tx_clean() after set number of packets, or set time after the
first packet is transmitted would make sense. But that's not what the
code does. As long as packets are being transmitted, you move the
timer into the future.. so that finally you run out of the place, then
wait for timer (!) and only then you do the cleaning.

Third, tx_cleanup is not safe to call from interrupt (tx_lock is not
irqsave), but that's exactly what coalescing code does.

Signed-off-by: Pavel Machek <pavel@denx.de>

---

This is stable candidate, afaict. It is broken in 4.4, too.

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/eth=
ernet/stmicro/stmmac/common.h
index 3ced2e1..32ce148 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -244,11 +244,11 @@ struct stmmac_extra_stats {
 /* Max/Min RI Watchdog Timer count value */
 #define MAX_DMA_RIWT		0xff
 #define MIN_DMA_RIWT		0x20
-/* Tx coalesce parameters */
+/* Tx coalesce parameters. Set STMMAC_TX_FRAMES to 0 to disable coalescing=
=2E */
 #define STMMAC_COAL_TX_TIMER	40000
 #define STMMAC_MAX_COAL_TX_TICK	100000
 #define STMMAC_TX_MAX_FRAMES	256
-#define STMMAC_TX_FRAMES	64
+#define STMMAC_TX_FRAMES	0
=20
 /* Rx IPC status */
 enum rx_frame_status {

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--qDbXVdCdHGoSgWSk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlhFXR8ACgkQMOfwapXb+vLI1gCcDZkfphBdX0wf+e8sp16yk704
7wQAn1AADoz3/vppMUpJ54AZeFcE4HvD
=ZCaQ
-----END PGP SIGNATURE-----

--qDbXVdCdHGoSgWSk--
