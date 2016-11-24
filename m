From: Pavel Machek <pavel@ucw.cz>
Subject: Re: stmmac ethernet in kernel 4.9-rc6: coalescing related pauses.
Date: Thu, 24 Nov 2016 11:29:01 +0100
Message-ID: <20161124102901.GA27793@amd>
References: <20161123105125.GA26394@amd>
 <20161124085506.GA25007@amd>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="0OAP2g/MAC+5xKAE"
To: peppe.cavallaro@st.com, netdev@vger.kernel.org,
        kernel list <linux-kernel@vger.kernel.org>,
        ezequiel@vanguardiasur.com.ar, sonic.zhang@analog.com,
        fabrice.gasnier@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161124085506.GA25007@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--0OAP2g/MAC+5xKAE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

What is going on with stmmac_tso_xmit() vs. stmmac_xmit()? One seems
to be copy of another, with subtle differences -- like calling
netif_queue_stopped() under spin_lock(&priv->tx_lock), or not.

What is going on with all these likely()s? Likely new hardware owners
will not be happy... or anyone running a lot of jumbo frames. (Perhaps
CPU's branch prediction can do better job here, without explicit hints?)

     if (unlikely(is_jumbo) && likely(priv->synopsys_id <
                                              DWMAC_CORE_4_00)) {

Are you sure this is okay?

        if (unlikely(netif_queue_stopped(priv->dev) &&
                     stmmac_tx_avail(priv) > STMMAC_TX_THRESH)) {
		netif_tx_lock(priv->dev);
                if (netif_queue_stopped(priv->dev) &&
                    stmmac_tx_avail(priv) > STMMAC_TX_THRESH) {

---

Fix english in comments.

Signed-off-by: Pavel Machek <pavel@ucw.cz>

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/ne=
t/ethernet/stmicro/stmmac/stmmac_main.c
index 1f9ec02..e5a5a05 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1747,11 +1747,11 @@ static int stmmac_hw_setup(struct net_device *dev, =
bool init_ptp)
 	if (priv->hw->pcs && priv->hw->mac->pcs_ctrl_ane)
 		priv->hw->mac->pcs_ctrl_ane(priv->hw, 1, priv->hw->ps, 0);
=20
-	/*  set TX ring length */
+	/* Set TX ring length */
 	if (priv->hw->dma->set_tx_ring_len)
 		priv->hw->dma->set_tx_ring_len(priv->ioaddr,
 					       (DMA_TX_SIZE - 1));
-	/*  set RX ring length */
+	/* Set RX ring length */
 	if (priv->hw->dma->set_rx_ring_len)
 		priv->hw->dma->set_rx_ring_len(priv->ioaddr,
 					       (DMA_RX_SIZE - 1));
@@ -2212,7 +2212,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, s=
truct net_device *dev)
 	priv->tx_skbuff[first_entry] =3D skb;
=20
 	enh_desc =3D priv->plat->enh_desc;
-	/* To program the descriptors according to the size of the frame */
+	/* Program the descriptors according to the size of the frame */
 	if (enh_desc)
 		is_jumbo =3D priv->hw->mode->is_jumbo_frm(skb->len, enh_desc);
=20
@@ -2665,7 +2665,7 @@ static int stmmac_rx(struct stmmac_priv *priv, int li=
mit)
  *  @budget : maximum number of packets that the current CPU can receive f=
rom
  *	      all interfaces.
  *  Description :
- *  To look at the incoming frames and clear the tx resources.
+ *  Look at the incoming frames and clear the tx resources.
  */
 static int stmmac_poll(struct napi_struct *napi, int budget)
 {
@@ -2828,7 +2828,7 @@ static irqreturn_t stmmac_interrupt(int irq, void *de=
v_id)
 		return IRQ_NONE;
 	}
=20
-	/* To handle GMAC own interrupts */
+	/* Handle GMAC own interrupts */
 	if ((priv->plat->has_gmac) || (priv->plat->has_gmac4)) {
 		int status =3D priv->hw->mac->host_irq_status(priv->hw,
 							    &priv->xstats);
@@ -2853,7 +2853,7 @@ static irqreturn_t stmmac_interrupt(int irq, void *de=
v_id)
 		}
 	}
=20
-	/* To handle DMA interrupts */
+	/* Handle DMA interrupts */
 	stmmac_dma_interrupt(priv);
=20
 	return IRQ_HANDLED;
@@ -3145,7 +3145,7 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
=20
 	priv->hw =3D mac;
=20
-	/* To use the chained or ring mode */
+	/* Use the chained or ring mode */
 	if (priv->synopsys_id >=3D DWMAC_CORE_4_00) {
 		priv->hw->mode =3D &dwmac4_ring_mode_ops;
 	} else {
@@ -3191,7 +3191,7 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
 	} else
 		pr_info(" No HW DMA feature register supported");
=20
-	/* To use alternate (extended), normal or GMAC4 descriptor structures */
+	/* Use alternate (extended), normal or GMAC4 descriptor structures */
 	if (priv->synopsys_id >=3D DWMAC_CORE_4_00)
 		priv->hw->desc =3D &dwmac4_desc_ops;
 	else



--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--0OAP2g/MAC+5xKAE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlg2wO0ACgkQMOfwapXb+vJ2pACgmzmmOYnVv+L7BVYTadFMjFSl
q1sAnj/VwYjfRdQ8UqNwdfugFrW5muU5
=FM88
-----END PGP SIGNATURE-----

--0OAP2g/MAC+5xKAE--
