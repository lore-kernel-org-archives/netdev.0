From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 2/2] net: ethernet: stmmac: remove private tx queue lock
Date: Wed, 7 Dec 2016 22:37:57 +0100
Message-ID: <20161207213757.GC2250@amd>
References: <1481141138-19466-1-git-send-email-LinoSanfilippo@gmx.de>
 <1481141138-19466-3-git-send-email-LinoSanfilippo@gmx.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="GZVR6ND4mMseVXL/"
Cc: bh74.an@samsung.com, ks.giri@samsung.com, vipul.pandya@samsung.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com,
        davem@davemloft.net, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1481141138-19466-3-git-send-email-LinoSanfilippo@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--GZVR6ND4mMseVXL/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed 2016-12-07 21:05:38, Lino Sanfilippo wrote:
> The driver uses a private lock for synchronization between the xmit
> function and the xmit completion handler, but since the NETIF_F_LLTX flag
> is not set, the xmit function is also called with the xmit_lock held.
>=20
> On the other hand the xmit completion handler first takes the private lock
> and (in case that the tx queue has been stopped) the xmit_lock, leading to
> a reverse locking order and the potential danger of a deadlock.
>=20
> Fix this by removing the private lock completely and synchronizing the xm=
it
> function and completion handler solely by means of the xmit_lock. By doing
> this remove also the now unnecessary double check for a stopped tx queue.
>=20

FYI, here's modified version. I believe _bh versions are needed, and
I'm testing that version now. (Oh and I also ported it to net-next).

It survived 30 minutes of testing so far...

Best regards,
									Pavel

Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Signed-off-by: Pavel Machek <pavel@denx.de>

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/eth=
ernet/stmicro/stmmac/stmmac.h
index dbacb80..eab04ae 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -64,7 +64,6 @@ struct stmmac_priv {
 	dma_addr_t dma_tx_phy;
 	int tx_coalesce;
 	int hwts_tx_en;
-	spinlock_t tx_lock;
 	bool tx_path_in_lpi_mode;
 	struct timer_list txtimer;
 	bool tso;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/ne=
t/ethernet/stmicro/stmmac/stmmac_main.c
index 982c952..7415bc2 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1308,7 +1308,7 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 	unsigned int bytes_compl =3D 0, pkts_compl =3D 0;
 	unsigned int entry =3D priv->dirty_tx;
=20
-	spin_lock(&priv->tx_lock);
+	netif_tx_lock_bh(priv->dev);
=20
 	priv->xstats.tx_clean++;
=20
@@ -1378,23 +1378,18 @@ static void stmmac_tx_clean(struct stmmac_priv *pri=
v)
=20
 	netdev_completed_queue(priv->dev, pkts_compl, bytes_compl);
=20
-	if (unlikely(netif_queue_stopped(priv->dev) &&
-		     stmmac_tx_avail(priv) > STMMAC_TX_THRESH)) {
-		netif_tx_lock(priv->dev);
-		if (netif_queue_stopped(priv->dev) &&
-		    stmmac_tx_avail(priv) > STMMAC_TX_THRESH) {
-			netif_dbg(priv, tx_done, priv->dev,
-				  "%s: restart transmit\n", __func__);
-			netif_wake_queue(priv->dev);
-		}
-		netif_tx_unlock(priv->dev);
+	if (netif_queue_stopped(priv->dev) &&
+	    stmmac_tx_avail(priv) > STMMAC_TX_THRESH) {
+		netif_dbg(priv, tx_done, priv->dev,
+			  "%s: restart transmit\n", __func__);
+		netif_wake_queue(priv->dev);
 	}
=20
 	if ((priv->eee_enabled) && (!priv->tx_path_in_lpi_mode)) {
 		stmmac_enable_eee_mode(priv);
 		mod_timer(&priv->eee_ctrl_timer, STMMAC_LPI_T(eee_timer));
 	}
-	spin_unlock(&priv->tx_lock);
+	netif_tx_unlock_bh(priv->dev);
 }
=20
 static inline void stmmac_enable_dma_irq(struct stmmac_priv *priv)
@@ -2006,8 +2001,6 @@ static netdev_tx_t stmmac_tso_xmit(struct sk_buff *sk=
b, struct net_device *dev)
 	u8 proto_hdr_len;
 	int i;
=20
-	spin_lock(&priv->tx_lock);
-
 	/* Compute header lengths */
 	proto_hdr_len =3D skb_transport_offset(skb) + tcp_hdrlen(skb);
=20
@@ -2021,7 +2014,6 @@ static netdev_tx_t stmmac_tso_xmit(struct sk_buff *sk=
b, struct net_device *dev)
 				   "%s: Tx Ring full when queue awake\n",
 				   __func__);
 		}
-		spin_unlock(&priv->tx_lock);
 		return NETDEV_TX_BUSY;
 	}
=20
@@ -2156,11 +2148,9 @@ static netdev_tx_t stmmac_tso_xmit(struct sk_buff *s=
kb, struct net_device *dev)
 	priv->hw->dma->set_tx_tail_ptr(priv->ioaddr, priv->tx_tail_addr,
 				       STMMAC_CHAN0);
=20
-	spin_unlock(&priv->tx_lock);
 	return NETDEV_TX_OK;
=20
 dma_map_err:
-	spin_unlock(&priv->tx_lock);
 	dev_err(priv->device, "Tx dma map failed\n");
 	dev_kfree_skb(skb);
 	priv->dev->stats.tx_dropped++;
@@ -2192,10 +2182,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, =
struct net_device *dev)
 			return stmmac_tso_xmit(skb, dev);
 	}
=20
-	spin_lock(&priv->tx_lock);
-
 	if (unlikely(stmmac_tx_avail(priv) < nfrags + 1)) {
-		spin_unlock(&priv->tx_lock);
 		if (!netif_queue_stopped(dev)) {
 			netif_stop_queue(dev);
 			/* This is a hard error, log it. */
@@ -2366,11 +2353,9 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, =
struct net_device *dev)
 		priv->hw->dma->set_tx_tail_ptr(priv->ioaddr, priv->tx_tail_addr,
 					       STMMAC_CHAN0);
=20
-	spin_unlock(&priv->tx_lock);
 	return NETDEV_TX_OK;
=20
 dma_map_err:
-	spin_unlock(&priv->tx_lock);
 	netdev_err(priv->dev, "Tx DMA map failed\n");
 	dev_kfree_skb(skb);
 	priv->dev->stats.tx_dropped++;
@@ -3357,7 +3342,6 @@ int stmmac_dvr_probe(struct device *device,
 	netif_napi_add(ndev, &priv->napi, stmmac_poll, 64);
=20
 	spin_lock_init(&priv->lock);
-	spin_lock_init(&priv->tx_lock);
=20
 	ret =3D register_netdev(ndev);
 	if (ret) {




--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--GZVR6ND4mMseVXL/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlhIgTUACgkQMOfwapXb+vKlEACeKm8LLkTsdVBrgxQV5AgOsZyq
VBUAnj64P7CTGoFZx9yp/vL2DnIK7qZ0
=7X4o
-----END PGP SIGNATURE-----

--GZVR6ND4mMseVXL/--
