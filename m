From: Pavel Machek <pavel@ucw.cz>
Subject: [PATCH] stmmac ethernet: remove cut & paste code
Date: Thu, 24 Nov 2016 12:05:48 +0100
Message-ID: <20161124110548.GB30723@amd>
References: <20161123105125.GA26394@amd>
 <20161124085506.GA25007@amd>
 <20161124102901.GA27793@amd>
 <20161124103630.GB27793@amd>
 <20161124104619.GA30723@amd>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="hHWLQfXTYDoKhP50"
To: peppe.cavallaro@st.com, netdev@vger.kernel.org,
        kernel list <linux-kernel@vger.kernel.org>,
        ezequiel@vanguardiasur.com.ar, sonic.zhang@analog.com,
        fabrice.gasnier@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161124104619.GA30723@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--hHWLQfXTYDoKhP50
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


Remove duplicate code from _tx routines.
   =20
Signed-off-by: Pavel Machek <pavel@denx.de>

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/ne=
t/ethernet/stmicro/stmmac/stmmac_main.c
index 1cff258..5cf9cef 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1960,6 +1960,38 @@ static void stmmac_tso_allocator(struct stmmac_priv =
*priv, unsigned int des,
 	}
 }
=20
+static void stmmac_xmit_common(struct sk_buff *skb, struct net_device *dev=
, int nfrags, struct dma_desc *desc)
+{
+	struct stmmac_priv *priv =3D netdev_priv(dev);
+
+	if (unlikely(stmmac_tx_avail(priv) <=3D (MAX_SKB_FRAGS + 1))) {
+		if (netif_msg_hw(priv))
+			pr_debug("%s: stop transmitted packets\n", __func__);
+		netif_stop_queue(dev);
+	}
+
+	dev->stats.tx_bytes +=3D skb->len;
+
+	/* According to the coalesce parameter the IC bit for the latest
+	 * segment is reset and the timer re-started to clean the tx status.
+	 * This approach takes care about the fragments: desc is the first
+	 * element in case of no SG.
+	 */
+	priv->tx_count_frames +=3D nfrags + 1;
+	if (likely(priv->tx_coal_frames > priv->tx_count_frames)) {
+		mod_timer(&priv->txtimer,
+			  STMMAC_COAL_TIMER(priv->tx_coal_timer));
+	} else {
+		priv->tx_count_frames =3D 0;
+		priv->hw->desc->set_tx_ic(desc);
+		priv->xstats.tx_set_ic_bit++;
+	}
+
+	if (!priv->hwts_tx_en)
+		skb_tx_timestamp(skb);
+}
+
+
 /**
  *  stmmac_tso_xmit - Tx entry point of the driver for oversized frames (T=
SO)
  *  @skb : the socket buffer
@@ -2081,30 +2113,11 @@ static netdev_tx_t stmmac_tso_xmit(struct sk_buff *=
skb, struct net_device *dev)
=20
 	priv->cur_tx =3D STMMAC_GET_ENTRY(priv->cur_tx, DMA_TX_SIZE);
=20
-	if (unlikely(stmmac_tx_avail(priv) <=3D (MAX_SKB_FRAGS + 1))) {
-		if (netif_msg_hw(priv))
-			pr_debug("%s: stop transmitted packets\n", __func__);
-		netif_stop_queue(dev);
-	}
-
-	dev->stats.tx_bytes +=3D skb->len;
+	stmmac_xmit_common(skb, dev, nfrags, desc);
+=09
 	priv->xstats.tx_tso_frames++;
 	priv->xstats.tx_tso_nfrags +=3D nfrags;
=20
-	/* Manage tx mitigation */
-	priv->tx_count_frames +=3D nfrags + 1;
-	if (likely(priv->tx_coal_frames > priv->tx_count_frames)) {
-		mod_timer(&priv->txtimer,
-			  STMMAC_COAL_TIMER(priv->tx_coal_timer));
-	} else {
-		priv->tx_count_frames =3D 0;
-		priv->hw->desc->set_tx_ic(desc);
-		priv->xstats.tx_set_ic_bit++;
-	}
-
-	if (!priv->hwts_tx_en)
-		skb_tx_timestamp(skb);
-
 	if (unlikely((skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) &&
 		     priv->hwts_tx_en)) {
 		/* declare that device is doing timestamping */
@@ -2280,31 +2293,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, =
struct net_device *dev)
 		print_pkt(skb->data, skb->len);
 	}
=20
-	if (unlikely(stmmac_tx_avail(priv) <=3D (MAX_SKB_FRAGS + 1))) {
-		if (netif_msg_hw(priv))
-			pr_debug("%s: stop transmitted packets\n", __func__);
-		netif_stop_queue(dev);
-	}
-
-	dev->stats.tx_bytes +=3D skb->len;
-
-	/* According to the coalesce parameter the IC bit for the latest
-	 * segment is reset and the timer re-started to clean the tx status.
-	 * This approach takes care about the fragments: desc is the first
-	 * element in case of no SG.
-	 */
-	priv->tx_count_frames +=3D nfrags + 1;
-	if (likely(priv->tx_coal_frames > priv->tx_count_frames)) {
-		mod_timer(&priv->txtimer,
-			  STMMAC_COAL_TIMER(priv->tx_coal_timer));
-	} else {
-		priv->tx_count_frames =3D 0;
-		priv->hw->desc->set_tx_ic(desc);
-		priv->xstats.tx_set_ic_bit++;
-	}
-
-	if (!priv->hwts_tx_en)
-		skb_tx_timestamp(skb);
+	stmmac_xmit_common(skb, dev, nfrags, desc);
=20
 	/* Ready to fill the first descriptor and set the OWN bit w/o any
 	 * problems because all the descriptors are actually ready to be


--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--hHWLQfXTYDoKhP50
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlg2yYwACgkQMOfwapXb+vKHqwCgt8cHTFoFkMFrSndNctbZRmpd
LucAnA3pTaQ2R4UoeQbkF666wgNYFCk4
=kpo8
-----END PGP SIGNATURE-----

--hHWLQfXTYDoKhP50--
