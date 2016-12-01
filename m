From: Pavel Machek <pavel@ucw.cz>
Subject: stmmac: turn coalescing / NAPI off in stmmac
Date: Thu, 1 Dec 2016 23:48:27 +0100
Message-ID: <20161201224827.GA26301@amd>
References: <20161124085506.GA25007@amd>
 <20161124.110416.198867271899443489.davem@davemloft.net>
 <20161130114431.GB14296@amd>
 <20161201.152303.425589678238707778.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="J2SCkAp4GZ/dPZZf"
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, alexandre.torgue@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161201.152303.425589678238707778.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--J2SCkAp4GZ/dPZZf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


> > @@ -2771,12 +2771,8 @@ static netdev_features_t stmmac_fix_features(str=
uct net_device *dev,
> >  		features &=3D ~NETIF_F_CSUM_MASK;
> > =20
> >  	/* Disable tso if asked by ethtool */
> > -	if ((priv->plat->tso_en) && (priv->dma_cap.tsoen)) {
> > -		if (features & NETIF_F_TSO)
> > -			priv->tso =3D true;
> > -		else
> > -			priv->tso =3D false;
> > -	}
> > +	if ((priv->plat->tso_en) && (priv->dma_cap.tsoen))
> > +		priv->tso =3D !!(features & NETIF_F_TSO);
> > =20
>=20
> Pavel, this really seems arbitrary.
>=20
> Whilst I really appreciate you're looking into this driver a bit because
> of some issues you are trying to resolve, I'd like to ask that you not
> start bombarding me with nit-pick cleanups here and there and instead
> concentrate on the real bug or issue.

Well, fixing clean code is easier than fixing strange code... Plus I
was hoping to make the mainainers to talk. The driver is listed as
supported after all.

Anyway... since you asked. I belive I have way to disable NAPI / tx
coalescing in the driver. Unfortunately, locking is missing on the rx
path, and needs to be extended to _irqsave variant on tx path.

So patch currently looks like this (hand edited, can't be
applied, got it working few hours ago). Does it look acceptable?

I'd prefer this to go after the patch that pulls common code to single
place, so that single place needs to be patched. Plus I guess I should
add ifdefs, so that more advanced NAPI / tx coalescing code can be
reactivated when it is fixed. Trivial fixes can go on top. Does that
sound like a plan?

Which tree do you want patches against?

https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/ ?

Best regards,
								Pavel


diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/ne=
t/ethernet/stmicro/stmmac/stmmac_main.c
index 0b706a7..c0016c8 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1395,9 +1397,10 @@ static void __stmmac_tx_clean(struct stmmac_priv *pr=
iv)
=20
 static void stmmac_tx_clean(struct stmmac_priv *priv)
 {
-	spin_lock(&priv->tx_lock);
+	unsigned long flags;
+	spin_lock_irqsave(&priv->tx_lock, flags);
 	__stmmac_tx_clean(priv);
-	spin_unlock(&priv->tx_lock);=09
+	spin_unlock_irqrestore(&priv->tx_lock, flags);=09
 }
=20
 static inline void stmmac_enable_dma_irq(struct stmmac_priv *priv)
@@ -1441,6 +1444,8 @@ static void stmmac_tx_err(struct stmmac_priv *priv)
 	netif_wake_queue(priv->dev);
 }
=20
+static int stmmac_rx(struct stmmac_priv *priv, int limit);
+
 /**
  * stmmac_dma_interrupt - DMA ISR
  * @priv: driver private structure
@@ -1452,10 +1457,17 @@ static void stmmac_dma_interrupt(struct stmmac_priv=
 *priv)
 {
 	int status;
 	int rxfifosz =3D priv->plat->rx_fifo_size;
+	unsigned long flags;
=20
 	status =3D priv->hw->dma->dma_interrupt(priv->ioaddr, &priv->xstats);
 	if (likely((status & handle_rx)) || (status & handle_tx)) {
+		int r;
+		spin_lock_irqsave(&priv->tx_lock, flags);
+		r =3D stmmac_rx(priv, 999);
+		spin_unlock_irqrestore(&priv->tx_lock, flags);	=09
+#if 0
 		if (likely(napi_schedule_prep(&priv->napi))) {
 			//pr_err("napi: schedule\n");
 			stmmac_disable_dma_irq(priv);
@@ -1463,7 +1475,8 @@ static void stmmac_dma_interrupt(struct stmmac_priv *=
priv)
 		} else
 			pr_err("napi: schedule failed\n");
 #endif
+		stmmac_tx_clean(priv);
 	}
 	if (unlikely(status & tx_hard_error_bump_tc)) {
 		/* Try to bump up the dma threshold on this failure */
@@ -1638,7 +1651,7 @@ static void stmmac_tx_timer(unsigned long data)
 {
 	struct stmmac_priv *priv =3D (struct stmmac_priv *)data;
=20
-	stmmac_tx_clean(priv);
+	//stmmac_tx_clean(priv);
 }
=20
 /**
@@ -1990,6 +2003,8 @@ static void stmmac_xmit_common(struct sk_buff *skb, s=
truct net_device *dev, int
 	if (likely(priv->tx_coal_frames > priv->tx_count_frames)) {
 		mod_timer(&priv->txtimer,
 			  STMMAC_COAL_TIMER(priv->tx_coal_timer));
+		priv->hw->desc->set_tx_ic(desc);
+		priv->xstats.tx_set_ic_bit++;
 	} else {
 		priv->tx_count_frames =3D 0;
 		priv->hw->desc->set_tx_ic(desc);
@@ -2038,8 +2053,9 @@ static netdev_tx_t stmmac_tso_xmit(struct sk_buff *sk=
b, struct net_device *dev)
 	struct dma_desc *desc, *first, *mss_desc =3D NULL;
 	u8 proto_hdr_len;
 	int i;
+	unsigned long flags;
=20
-	spin_lock(&priv->tx_lock);
+	spin_lock_irqsave(&priv->tx_lock, flags);
=20
 	/* Compute header lengths */
 	proto_hdr_len =3D skb_transport_offset(skb) + tcp_hdrlen(skb);
@@ -2052,7 +2068,7 @@ static netdev_tx_t stmmac_tso_xmit(struct sk_buff *sk=
b, struct net_device *dev)
 			/* This is a hard error, log it. */
 			pr_err("%s: Tx Ring full when queue awake\n", __func__);
 		}
-		spin_unlock(&priv->tx_lock);
+		spin_unlock_irqrestore(&priv->tx_lock, flags);
 		return NETDEV_TX_BUSY;
 	}
=20
@@ -2168,11 +2184,11 @@ static netdev_tx_t stmmac_tso_xmit(struct sk_buff *=
skb, struct net_device *dev)
 	priv->hw->dma->set_tx_tail_ptr(priv->ioaddr, priv->tx_tail_addr,
 				       STMMAC_CHAN0);
=20
-	spin_unlock(&priv->tx_lock);
+	spin_unlock_irqrestore(&priv->tx_lock, flags);
 	return NETDEV_TX_OK;
=20
 dma_map_err:
-	spin_unlock(&priv->tx_lock);
+	spin_unlock_irqrestore(&priv->tx_lock, flags);
 	dev_err(priv->device, "Tx dma map failed\n");
 	dev_kfree_skb(skb);
 	priv->dev->stats.tx_dropped++;
@@ -2197,6 +2213,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, s=
truct net_device *dev)
 	struct dma_desc *desc, *first;
 	unsigned int enh_desc;
 	unsigned int des;
+	unsigned int flags;
=20
 	/* Manage oversized TCP frames for GMAC4 device */
 	if (skb_is_gso(skb) && priv->tso) {
@@ -2204,7 +2221,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, s=
truct net_device *dev)
 			return stmmac_tso_xmit(skb, dev);
 	}
=20
-	spin_lock(&priv->tx_lock);
+	spin_lock_irqsave(&priv->tx_lock, flags);
=20
 	if (unlikely(stmmac_tx_avail(priv) < nfrags + 1)) {
 		if (!netif_queue_stopped(dev)) {
@@ -2212,7 +2229,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, s=
truct net_device *dev)
 			/* This is a hard error, log it. */
 			pr_err("%s: Tx Ring full when queue awake\n", __func__);
 		}
-		spin_unlock(&priv->tx_lock);
+		spin_unlock_irqrestore(&priv->tx_lock, flags);
 		return NETDEV_TX_BUSY;
 	}
=20
@@ -2347,11 +2364,11 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb,=
 struct net_device *dev)
 		priv->hw->dma->set_tx_tail_ptr(priv->ioaddr, priv->tx_tail_addr,
 					       STMMAC_CHAN0);
=20
-	spin_unlock(&priv->tx_lock);
+	spin_unlock_irqrestore(&priv->tx_lock, flags);
 	return NETDEV_TX_OK;
=20
 dma_map_err:
-	spin_unlock(&priv->tx_lock);
+	spin_unlock_irqrestore(&priv->tx_lock, flags);
 	dev_err(priv->device, "Tx dma map failed\n");
 	dev_kfree_skb(skb);
 	priv->dev->stats.tx_dropped++;
@@ -2634,7 +2651,8 @@ static int stmmac_rx(struct stmmac_priv *priv, int li=
mit)
 			else
 				skb->ip_summed =3D CHECKSUM_UNNECESSARY;
=20
-			napi_gro_receive(&priv->napi, skb);
+			//napi_gro_receive(&priv->napi, skb);
+			netif_rx(skb);
=20
 			priv->dev->stats.rx_packets++;
 			priv->dev->stats.rx_bytes +=3D frame_len;
@@ -2662,6 +2680,7 @@ static int stmmac_poll(struct napi_struct *napi, int =
budget)
 	struct stmmac_priv *priv =3D container_of(napi, struct stmmac_priv, napi);
 	int work_done;
=20
+	BUG();
 	priv->xstats.napi_poll++;
 	stmmac_tx_clean(priv);
=20



--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--J2SCkAp4GZ/dPZZf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlhAqLoACgkQMOfwapXb+vLvNwCgqnlS2VrZmfLajMNaXAjD+DPA
lm8An2ubVtYC3JdsRuRIZoMzbO/znN1q
=bEy7
-----END PGP SIGNATURE-----

--J2SCkAp4GZ/dPZZf--
