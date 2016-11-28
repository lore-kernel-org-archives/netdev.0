From: Pavel Machek <pavel@ucw.cz>
Subject: [PATCH] stmmac: reduce code duplication getting basic descriptors
Date: Mon, 28 Nov 2016 13:17:36 +0100
Message-ID: <20161128121736.GD15034@amd>
References: <20161123105125.GA26394@amd>
 <20161124085506.GA25007@amd>
 <20161124.110416.198867271899443489.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="ZJcv+A0YCCLh2VIg"
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, Andrew Morton <akpm@osdl.org>,
        alexandre.torgue@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:57343 "EHLO
        atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754353AbcK1MRn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 07:17:43 -0500
Content-Disposition: inline
In-Reply-To: <20161124.110416.198867271899443489.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--ZJcv+A0YCCLh2VIg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


Remove code duplication getting basic descriptors.
   =20
Signed-off-by: Pavel Machek <pavel@denx.de>

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/ne=
t/ethernet/stmicro/stmmac/stmmac_main.c
index f7133d0..ed20668 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -929,6 +929,17 @@ static int stmmac_set_bfsize(int mtu, int bufsize)
 	return ret;
 }
=20
+static inline struct dma_desc *stmmac_tx_desc(struct stmmac_priv *priv, in=
t i)
+{
+	struct dma_desc *p;
+	if (priv->extend_desc)
+		p =3D &((priv->dma_etx + i)->basic);
+	else
+		p =3D priv->dma_tx + i;
+	return p;
+}
+
+
 /**
  * stmmac_clear_descriptors - clear descriptors
  * @priv: driver private structure
@@ -1078,11 +1089,7 @@ static int init_dma_desc_rings(struct net_device *de=
v, gfp_t flags)
=20
 	/* TX INITIALIZATION */
 	for (i =3D 0; i < DMA_TX_SIZE; i++) {
-		struct dma_desc *p;
-		if (priv->extend_desc)
-			p =3D &((priv->dma_etx + i)->basic);
-		else
-			p =3D priv->dma_tx + i;
+		struct dma_desc *p =3D stmmac_tx_desc(priv, i);
=20
 		if (priv->synopsys_id >=3D DWMAC_CORE_4_00) {
 			p->des0 =3D 0;
@@ -1129,12 +1136,7 @@ static void dma_free_tx_skbufs(struct stmmac_priv *p=
riv)
 	int i;
=20
 	for (i =3D 0; i < DMA_TX_SIZE; i++) {
-		struct dma_desc *p;
-
-		if (priv->extend_desc)
-			p =3D &((priv->dma_etx + i)->basic);
-		else
-			p =3D priv->dma_tx + i;
+		struct dma_desc *p =3D stmmac_tx_desc(priv, i);
=20
 		if (priv->tx_skbuff_dma[i].buf) {
 			if (priv->tx_skbuff_dma[i].map_as_page)
@@ -1314,14 +1316,9 @@ static void __stmmac_tx_clean(struct stmmac_priv *pr=
iv)
=20
 	while (entry !=3D priv->cur_tx) {
 		struct sk_buff *skb =3D priv->tx_skbuff[entry];
-		struct dma_desc *p;
+		struct dma_desc *p =3D stmmac_tx_desc(priv, entry);
 		int status;
=20
-		if (priv->extend_desc)
-			p =3D (struct dma_desc *)(priv->dma_etx + entry);
-		else
-			p =3D priv->dma_tx + entry;
-
 		status =3D priv->hw->desc->tx_status(&priv->dev->stats,
 						      &priv->xstats, p,
 						      priv->ioaddr);
@@ -2227,11 +2224,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, =
struct net_device *dev)
=20
 	csum_insertion =3D (skb->ip_summed =3D=3D CHECKSUM_PARTIAL);
=20
-	if (likely(priv->extend_desc))
-		desc =3D (struct dma_desc *)(priv->dma_etx + entry);
-	else
-		desc =3D priv->dma_tx + entry;
-
+	desc =3D stmmac_tx_desc(priv, entry);
 	first =3D desc;
=20
 	priv->tx_skbuff[first_entry] =3D skb;
@@ -2254,10 +2247,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, =
struct net_device *dev)
=20
 		entry =3D STMMAC_GET_ENTRY(entry, DMA_TX_SIZE);
=20
-		if (likely(priv->extend_desc))
-			desc =3D (struct dma_desc *)(priv->dma_etx + entry);
-		else
-			desc =3D priv->dma_tx + entry;
+		desc =3D stmmac_tx_desc(priv, entry);
=20
 		des =3D skb_frag_dma_map(priv->device, frag, 0, len,
 				       DMA_TO_DEVICE);

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--ZJcv+A0YCCLh2VIg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlg8IGAACgkQMOfwapXb+vIiVgCgvKCNUbdG/SMIHE6ue+rshbKF
PL8An03G8Gxc6NoKhRIFLgHyjTXYSRWm
=eEy/
-----END PGP SIGNATURE-----

--ZJcv+A0YCCLh2VIg--
