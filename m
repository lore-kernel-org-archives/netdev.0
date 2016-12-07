From: Pavel Machek <pavel@ucw.cz>
Subject: [RFC] Re: Re: stmmac ethernet in kernel 4.9-rc6: coalescing related
 pauses.
Date: Wed, 7 Dec 2016 13:31:40 +0100
Message-ID: <20161207123140.GA8785@amd>
References: <20161123105125.GA26394@amd>
 <20161124085506.GA25007@amd>
 <20161124.110416.198867271899443489.davem@davemloft.net>
 <20161124212540.GA24796@amd>
 <b6ac7a3c-6774-9568-1cc0-97074eaa928f@st.com>
 <20161202084511.GA32294@amd>
 <trinity-11729d3e-ae5e-4850-a1bf-b83a1d0a864c-1480687521037@3capp-gmx-bs55>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="PEIAKu/WMn1b1Hv9"
Cc: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        alexandre.torgue@st.com, David Miller <davem@davemloft.net>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <trinity-11729d3e-ae5e-4850-a1bf-b83a1d0a864c-1480687521037@3capp-gmx-bs55>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--PEIAKu/WMn1b1Hv9
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri 2016-12-02 15:05:21, Lino Sanfilippo wrote:
> Hi,
>=20
>=20
> >=20
> > There's nothing that protect stmmac_poll() from running concurently
> > with stmmac_dma_interrupt(), right?
> >=20
>=20
> could it be that there is also another issue concerned locking?:
> The tx completion handler takes the xmit_lock in case that the
> netif_queue is stopped. This is AFAICS unnecessary, since both
> xmit and completion handler are already synchronized by the private
> tx lock. But it is IMHO also dangerous:
>=20
> In the xmit handler we have the locking order
> 1. xmit_lock
> 2. private tx lock
>=20
> while in the completion handler its the reverse:
>=20
> 1. private tx lock
> 2. xmit lock.
>=20
> Do I miss something?

No, it seems you are right. Something like this?

Hmm. And can priv->tx_lock be removed, as we already rely on
netif_tx_lock?

(I copied the "lock already held" annotations from forcedeth. I hope
they are right....)

Best regards,
								Pavel


commit a6f21255dfc11fcadc5062dfd0c5f3d77ca4f634
Author: Pavel <pavel@ucw.cz>
Date:   Wed Dec 7 13:29:15 2016 +0100

    Reported-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
   =20
    The tx completion handler takes the xmit_lock in case that the
    netif_queue is stopped. This is AFAICS unnecessary, since both
    xmit and completion handler are already synchronized by the private
    tx lock. But it is IMHO also dangerous:
   =20
    In the xmit handler we have the locking order
    1. xmit_lock
    2. private tx lock
   =20
    while in the completion handler its the reverse:
   =20
    1. private tx lock
    2. xmit lock.
   =20
    Signed-off-by: Pavel Machek <pavel@denx.de>

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/ne=
t/ethernet/stmicro/stmmac/stmmac_main.c
index 982c952..5df9bb3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1380,14 +1380,9 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
=20
 	if (unlikely(netif_queue_stopped(priv->dev) &&
 		     stmmac_tx_avail(priv) > STMMAC_TX_THRESH)) {
-		netif_tx_lock(priv->dev);
-		if (netif_queue_stopped(priv->dev) &&
-		    stmmac_tx_avail(priv) > STMMAC_TX_THRESH) {
-			netif_dbg(priv, tx_done, priv->dev,
-				  "%s: restart transmit\n", __func__);
-			netif_wake_queue(priv->dev);
-		}
-		netif_tx_unlock(priv->dev);
+		netif_dbg(priv, tx_done, priv->dev,
+			  "%s: restart transmit\n", __func__);
+		netif_wake_queue(priv->dev);
 	}
=20
 	if ((priv->eee_enabled) && (!priv->tx_path_in_lpi_mode)) {
@@ -1630,7 +1625,9 @@ static void stmmac_tx_timer(unsigned long data)
 {
 	struct stmmac_priv *priv =3D (struct stmmac_priv *)data;
=20
+	netif_tx_lock_bh(priv->dev);
 	stmmac_tx_clean(priv);
+	netif_tx_unlock_bh(priv->dev);
 }
=20
 /**
@@ -1994,7 +1991,8 @@ static void stmmac_tso_allocator(struct stmmac_priv *=
priv, unsigned int des,
  *   --------
  *
  * mss is fixed when enable tso, so w/o programming the TDES3 ctx field.
- */
+ *
+ *  Called with netif_tx_lock held.                                       =
                          */
 static netdev_tx_t stmmac_tso_xmit(struct sk_buff *skb, struct net_device =
*dev)
 {
 	u32 pay_len, mss;
@@ -2174,6 +2172,7 @@ static netdev_tx_t stmmac_tso_xmit(struct sk_buff *sk=
b, struct net_device *dev)
  *  Description : this is the tx entry point of the driver.
  *  It programs the chain or the ring and supports oversized frames
  *  and SG feature.
+ *  Called with netif_tx_lock held.=20
  */
 static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 {
@@ -2684,7 +2683,9 @@ static int stmmac_poll(struct napi_struct *napi, int =
budget)
 	int work_done =3D 0;
=20
 	priv->xstats.napi_poll++;
+	netif_tx_lock_bh(priv->dev);
 	stmmac_tx_clean(priv);
+	netif_tx_unlock_bh(priv->dev);
=20
 	work_done =3D stmmac_rx(priv, budget);
 	if (work_done < budget) {
@@ -2701,6 +2702,7 @@ static int stmmac_poll(struct napi_struct *napi, int =
budget)
  *   complete within a reasonable time. The driver will mark the error in =
the
  *   netdev structure and arrange for the device to be reset to a sane sta=
te
  *   in order to transmit a new packet.
+ * Called with netif_tx_lock held.
  */
 static void stmmac_tx_timeout(struct net_device *dev)
 {


--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--PEIAKu/WMn1b1Hv9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlhIASwACgkQMOfwapXb+vLB/gCgkLA1yrUoaU8Ff60+xtiZBLZw
8c0AnjZqLROhrNx9aZfNGb0VVXiDr8pl
=Vw/x
-----END PGP SIGNATURE-----

--PEIAKu/WMn1b1Hv9--
