From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: stmmac: convert to hw_features
Date: Sat,  9 Apr 2011 14:46:55 +0200 (CEST)
Message-ID: <20110409124655.A015B13909@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:32897 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754479Ab1DIMq5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Apr 2011 08:46:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This also removes TSO as it's made fully in software --- better to leav=
e this
to networking core.

If the MAC features can be detected at probe time and not at open, then
stmmac_fix_features could be simplified by limiting hw_features. That's
also better for users as they don't see offloads being togglable but
never turned on.

Redundant fallbacks for TX csum are removed as it's already handled
by network core.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/stmmac/stmmac_ethtool.c |   14 ------
 drivers/net/stmmac/stmmac_main.c    |   83 ++++++++++-----------------=
--------
 2 files changed, 23 insertions(+), 74 deletions(-)

diff --git a/drivers/net/stmmac/stmmac_ethtool.c b/drivers/net/stmmac/s=
tmmac_ethtool.c
index fd719ed..156a805 100644
--- a/drivers/net/stmmac/stmmac_ethtool.c
+++ b/drivers/net/stmmac/stmmac_ethtool.c
@@ -197,13 +197,6 @@ static void stmmac_ethtool_gregs(struct net_device=
 *dev,
 	}
 }
=20
-static u32 stmmac_ethtool_get_rx_csum(struct net_device *dev)
-{
-	struct stmmac_priv *priv =3D netdev_priv(dev);
-
-	return priv->rx_coe;
-}
-
 static void
 stmmac_get_pauseparam(struct net_device *netdev,
 		      struct ethtool_pauseparam *pause)
@@ -358,11 +351,6 @@ static struct ethtool_ops stmmac_ethtool_ops =3D {
 	.get_regs =3D stmmac_ethtool_gregs,
 	.get_regs_len =3D stmmac_ethtool_get_regs_len,
 	.get_link =3D ethtool_op_get_link,
-	.get_rx_csum =3D stmmac_ethtool_get_rx_csum,
-	.get_tx_csum =3D ethtool_op_get_tx_csum,
-	.set_tx_csum =3D ethtool_op_set_tx_ipv6_csum,
-	.get_sg =3D ethtool_op_get_sg,
-	.set_sg =3D ethtool_op_set_sg,
 	.get_pauseparam =3D stmmac_get_pauseparam,
 	.set_pauseparam =3D stmmac_set_pauseparam,
 	.get_ethtool_stats =3D stmmac_get_ethtool_stats,
@@ -370,8 +358,6 @@ static struct ethtool_ops stmmac_ethtool_ops =3D {
 	.get_wol =3D stmmac_get_wol,
 	.set_wol =3D stmmac_set_wol,
 	.get_sset_count	=3D stmmac_get_sset_count,
-	.get_tso =3D ethtool_op_get_tso,
-	.set_tso =3D ethtool_op_set_tso,
 };
=20
 void stmmac_set_ethtool_ops(struct net_device *netdev)
diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmm=
ac_main.c
index 0e5f031..62fa51e 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -139,7 +139,6 @@ static const u32 default_msg_level =3D (NETIF_MSG_D=
RV | NETIF_MSG_PROBE |
 				      NETIF_MSG_IFDOWN | NETIF_MSG_TIMER);
=20
 static irqreturn_t stmmac_interrupt(int irq, void *dev_id);
-static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device =
*dev);
=20
 /**
  * stmmac_verify_args - verify the driver parameters.
@@ -843,6 +842,7 @@ static int stmmac_open(struct net_device *dev)
 		pr_info("stmmac: Rx Checksum Offload Engine supported\n");
 	if (priv->plat->tx_coe)
 		pr_info("\tTX Checksum insertion supported\n");
+	netdev_update_features(dev);
=20
 	/* Initialise the MMC (if present) to disable all interrupts. */
 	writel(0xffffffff, priv->ioaddr + MMC_HIGH_INTR_MASK);
@@ -927,46 +927,6 @@ static int stmmac_release(struct net_device *dev)
 	return 0;
 }
=20
-/*
- * To perform emulated hardware segmentation on skb.
- */
-static int stmmac_sw_tso(struct stmmac_priv *priv, struct sk_buff *skb=
)
-{
-	struct sk_buff *segs, *curr_skb;
-	int gso_segs =3D skb_shinfo(skb)->gso_segs;
-
-	/* Estimate the number of fragments in the worst case */
-	if (unlikely(stmmac_tx_avail(priv) < gso_segs)) {
-		netif_stop_queue(priv->dev);
-		TX_DBG(KERN_ERR "%s: TSO BUG! Tx Ring full when queue awake\n",
-		       __func__);
-		if (stmmac_tx_avail(priv) < gso_segs)
-			return NETDEV_TX_BUSY;
-
-		netif_wake_queue(priv->dev);
-	}
-	TX_DBG("\tstmmac_sw_tso: segmenting: skb %p (len %d)\n",
-	       skb, skb->len);
-
-	segs =3D skb_gso_segment(skb, priv->dev->features & ~NETIF_F_TSO);
-	if (IS_ERR(segs))
-		goto sw_tso_end;
-
-	do {
-		curr_skb =3D segs;
-		segs =3D segs->next;
-		TX_DBG("\t\tcurrent skb->len: %d, *curr %p,"
-		       "*next %p\n", curr_skb->len, curr_skb, segs);
-		curr_skb->next =3D NULL;
-		stmmac_xmit(curr_skb, priv->dev);
-	} while (segs);
-
-sw_tso_end:
-	dev_kfree_skb(skb);
-
-	return NETDEV_TX_OK;
-}
-
 static unsigned int stmmac_handle_jumbo_frames(struct sk_buff *skb,
 					       struct net_device *dev,
 					       int csum_insertion)
@@ -1044,16 +1004,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *s=
kb, struct net_device *dev)
 		       !skb_is_gso(skb) ? "isn't" : "is");
 #endif
=20
-	if (unlikely(skb_is_gso(skb)))
-		return stmmac_sw_tso(priv, skb);
-
-	if (likely((skb->ip_summed =3D=3D CHECKSUM_PARTIAL))) {
-		if (unlikely((!priv->plat->tx_coe) ||
-			     (priv->no_csum_insertion)))
-			skb_checksum_help(skb);
-		else
-			csum_insertion =3D 1;
-	}
+	csum_insertion =3D (skb->ip_summed =3D=3D CHECKSUM_PARTIAL);
=20
 	desc =3D priv->dma_tx + entry;
 	first =3D desc;
@@ -1373,18 +1324,29 @@ static int stmmac_change_mtu(struct net_device =
*dev, int new_mtu)
 		return -EINVAL;
 	}
=20
+	dev->mtu =3D new_mtu;
+	netdev_update_features(dev);
+
+	return 0;
+}
+
+static u32 stmmac_fix_features(struct net_device *dev, u32 features)
+{
+	struct stmmac_priv *priv =3D netdev_priv(dev);
+
+	if (!priv->rx_coe)
+		features &=3D ~NETIF_F_RXCSUM;
+	if (!priv->plat->tx_coe)
+		features &=3D ~NETIF_F_ALL_CSUM;
+
 	/* Some GMAC devices have a bugged Jumbo frame support that
 	 * needs to have the Tx COE disabled for oversized frames
 	 * (due to limited buffer sizes). In this case we disable
 	 * the TX csum insertionin the TDES and not use SF. */
-	if ((priv->plat->bugged_jumbo) && (priv->dev->mtu > ETH_DATA_LEN))
-		priv->no_csum_insertion =3D 1;
-	else
-		priv->no_csum_insertion =3D 0;
+	if (priv->plat->bugged_jumbo && (dev->mtu > ETH_DATA_LEN))
+		features &=3D ~NETIF_F_ALL_CSUM;
=20
-	dev->mtu =3D new_mtu;
-
-	return 0;
+	return features;
 }
=20
 static irqreturn_t stmmac_interrupt(int irq, void *dev_id)
@@ -1464,6 +1426,7 @@ static const struct net_device_ops stmmac_netdev_=
ops =3D {
 	.ndo_start_xmit =3D stmmac_xmit,
 	.ndo_stop =3D stmmac_release,
 	.ndo_change_mtu =3D stmmac_change_mtu,
+	.ndo_fix_features =3D stmmac_fix_features,
 	.ndo_set_multicast_list =3D stmmac_multicast_list,
 	.ndo_tx_timeout =3D stmmac_tx_timeout,
 	.ndo_do_ioctl =3D stmmac_ioctl,
@@ -1494,8 +1457,8 @@ static int stmmac_probe(struct net_device *dev)
 	dev->netdev_ops =3D &stmmac_netdev_ops;
 	stmmac_set_ethtool_ops(dev);
=20
-	dev->features |=3D NETIF_F_SG | NETIF_F_HIGHDMA |
-		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
+	dev->hw_features =3D NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM=
;
+	dev->features |=3D dev->hw_features | NETIF_F_HIGHDMA;
 	dev->watchdog_timeo =3D msecs_to_jiffies(watchdog);
 #ifdef STMMAC_VLAN_TAG_USED
 	/* Both mac100 and gmac support receive VLAN tag detection */
--=20
1.7.2.5

