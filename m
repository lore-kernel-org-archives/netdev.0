From: Pavel Machek <pavel@ucw.cz>
Subject: [PATCH] stmmac: fix memory barriers
Date: Sun, 18 Dec 2016 21:38:12 +0100
Message-ID: <20161218203812.GA1012@amd>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="5mCyUwZo2JvN/JJP"
To: LinoSanfilippo@gmx.de, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, davem@davemloft.net,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        niklas.cassel@axis.com, Joao.Pinto@synopsys.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--5mCyUwZo2JvN/JJP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


Fix up memory barriers in stmmac driver. They are meant to protect
against DMA engine, so smp_ variants are certainly wrong, and dma_
variants are preferable.
   =20
Signed-off-by: Pavel Machek <pavel@denx.de>

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c b/drivers/n=
et/ethernet/stmicro/stmmac/dwmac4_descs.c
index a340fc8..8816515 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
@@ -334,7 +334,7 @@ static void dwmac4_rd_prepare_tx_desc(struct dma_desc *=
p, int is_fs, int len,
 		 * descriptors for the same frame has to be set before, to
 		 * avoid race condition.
 		 */
-		wmb();
+		dma_wmb();
=20
 	p->des3 =3D cpu_to_le32(tdes3);
 }
@@ -377,7 +377,7 @@ static void dwmac4_rd_prepare_tso_tx_desc(struct dma_de=
sc *p, int is_fs,
 		 * descriptors for the same frame has to be set before, to
 		 * avoid race condition.
 		 */
-		wmb();
+		dma_wmb();
=20
 	p->des3 =3D cpu_to_le32(tdes3);
 }
diff --git a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c b/drivers/net/e=
thernet/stmicro/stmmac/enh_desc.c
index ce97e52..f0d8632 100644
--- a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
@@ -350,7 +350,7 @@ static void enh_desc_prepare_tx_desc(struct dma_desc *p=
, int is_fs, int len,
 		 * descriptors for the same frame has to be set before, to
 		 * avoid race condition.
 		 */
-		wmb();
+		dma_wmb();
=20
 	p->des0 =3D cpu_to_le32(tdes0);
 }
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/ne=
t/ethernet/stmicro/stmmac/stmmac_main.c
index 3e40578..bb40382 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2125,7 +2125,7 @@ static netdev_tx_t stmmac_tso_xmit(struct sk_buff *sk=
b, struct net_device *dev)
 	 * descriptor and then barrier is needed to make sure that
 	 * all is coherent before granting the DMA engine.
 	 */
-	smp_wmb();
+	dma_wmb();
=20
 	if (netif_msg_pktdata(priv)) {
 		pr_info("%s: curr=3D%d dirty=3D%d f=3D%d, e=3D%d, f_p=3D%p, nfrags %d\n",
@@ -2338,7 +2338,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, s=
truct net_device *dev)
 		 * descriptor and then barrier is needed to make sure that
 		 * all is coherent before granting the DMA engine.
 		 */
-		smp_wmb();
+		dma_wmb();
 	}
=20
 	netdev_sent_queue(dev, skb->len);
@@ -2443,14 +2443,14 @@ static inline void stmmac_rx_refill(struct stmmac_p=
riv *priv)
 			netif_dbg(priv, rx_status, priv->dev,
 				  "refill entry #%d\n", entry);
 		}
-		wmb();
+		dma_wmb();
=20
 		if (unlikely(priv->synopsys_id >=3D DWMAC_CORE_4_00))
 			priv->hw->desc->init_rx_desc(p, priv->use_riwt, 0, 0);
 		else
 			priv->hw->desc->set_rx_owner(p);
=20
-		wmb();
+		dma_wmb();
=20
 		entry =3D STMMAC_GET_ENTRY(entry, DMA_RX_SIZE);
 	}

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--5mCyUwZo2JvN/JJP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlhW87QACgkQMOfwapXb+vLIZgCbBt3xZ30pWvof3ChSgxWal46w
96wAn2T2nbuwqMovjX/lIlqnm+D1y5ci
=IvAO
-----END PGP SIGNATURE-----

--5mCyUwZo2JvN/JJP--
