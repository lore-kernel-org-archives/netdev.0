From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: gianfar: convert to hw_features
Date: Fri, 15 Apr 2011 16:50:50 +0200 (CEST)
Message-ID: <20110415145050.39D5013A69@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alex Dubov <oakad@yahoo.com>,
	Anton Vorontsov <cbouatmailru@gmail.com>,
	Jarek Poplawski <jarkao2@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:46547 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756280Ab1DOOux (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Apr 2011 10:50:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Note: I bet that gfar_set_features() don't really need a full reset.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/gianfar.c         |   16 ++++++-----
 drivers/net/gianfar.h         |    3 +-
 drivers/net/gianfar_ethtool.c |   58 +++------------------------------=
-------
 3 files changed, 16 insertions(+), 61 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 2a0ad9a..ff60b23 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -365,7 +365,7 @@ static void gfar_init_mac(struct net_device *ndev)
 		gfar_write(&regs->rir0, DEFAULT_RIR0);
 	}
=20
-	if (priv->rx_csum_enable)
+	if (ndev->features & NETIF_F_RXCSUM)
 		rctrl |=3D RCTRL_CHECKSUMMING;
=20
 	if (priv->extended_hash) {
@@ -463,6 +463,7 @@ static const struct net_device_ops gfar_netdev_ops =
=3D {
 	.ndo_start_xmit =3D gfar_start_xmit,
 	.ndo_stop =3D gfar_close,
 	.ndo_change_mtu =3D gfar_change_mtu,
+	.ndo_set_features =3D gfar_set_features,
 	.ndo_set_multicast_list =3D gfar_set_multi,
 	.ndo_tx_timeout =3D gfar_timeout,
 	.ndo_do_ioctl =3D gfar_ioctl,
@@ -513,7 +514,7 @@ void unlock_tx_qs(struct gfar_private *priv)
 /* Returns 1 if incoming frames use an FCB */
 static inline int gfar_uses_fcb(struct gfar_private *priv)
 {
-	return priv->vlgrp || priv->rx_csum_enable ||
+	return priv->vlgrp || (priv->ndev->features & NETIF_F_RXCSUM) ||
 		(priv->device_flags & FSL_GIANFAR_DEV_HAS_TIMER);
 }
=20
@@ -1030,10 +1031,11 @@ static int gfar_probe(struct platform_device *o=
fdev)
 		netif_napi_add(dev, &priv->gfargrp[i].napi, gfar_poll, GFAR_DEV_WEIG=
HT);
=20
 	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_CSUM) {
-		priv->rx_csum_enable =3D 1;
-		dev->features |=3D NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_HIGHDMA;
-	} else
-		priv->rx_csum_enable =3D 0;
+		dev->hw_features =3D NETIF_F_IP_CSUM | NETIF_F_SG |
+			NETIF_F_RXCSUM;
+		dev->features |=3D NETIF_F_IP_CSUM | NETIF_F_SG |
+			NETIF_F_RXCSUM | NETIF_F_HIGHDMA;
+	}
=20
 	priv->vlgrp =3D NULL;
=20
@@ -2697,7 +2699,7 @@ static int gfar_process_frame(struct net_device *=
dev, struct sk_buff *skb,
 	if (priv->padding)
 		skb_pull(skb, priv->padding);
=20
-	if (priv->rx_csum_enable)
+	if (dev->features & NETIF_F_RXCSUM)
 		gfar_rx_checksum(skb, fcb);
=20
 	/* Tell the skb what kind of packet this is */
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index 0438d35..fc86f51 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -1083,7 +1083,7 @@ struct gfar_private {
 	struct device_node *phy_node;
 	struct device_node *tbi_node;
 	u32 device_flags;
-	unsigned char rx_csum_enable:1,
+	unsigned char
 		extended_hash:1,
 		bd_stash_en:1,
 		rx_filer_enable:1,
@@ -1153,6 +1153,7 @@ extern void gfar_phy_test(struct mii_bus *bus, st=
ruct phy_device *phydev,
 extern void gfar_configure_coalescing(struct gfar_private *priv,
 		unsigned long tx_mask, unsigned long rx_mask);
 void gfar_init_sysfs(struct net_device *dev);
+int gfar_set_features(struct net_device *dev, u32 features);
=20
 extern const struct ethtool_ops gfar_ethtool_ops;
=20
diff --git a/drivers/net/gianfar_ethtool.c b/drivers/net/gianfar_ethtoo=
l.c
index 0840590..493d743 100644
--- a/drivers/net/gianfar_ethtool.c
+++ b/drivers/net/gianfar_ethtool.c
@@ -517,15 +517,15 @@ static int gfar_sringparam(struct net_device *dev=
, struct ethtool_ringparam *rva
 	return err;
 }
=20
-static int gfar_set_rx_csum(struct net_device *dev, uint32_t data)
+int gfar_set_features(struct net_device *dev, u32 features)
 {
 	struct gfar_private *priv =3D netdev_priv(dev);
 	unsigned long flags;
 	int err =3D 0, i =3D 0;
+	u32 changed =3D dev->features ^ features;
=20
-	if (!(priv->device_flags & FSL_GIANFAR_DEV_HAS_CSUM))
-		return -EOPNOTSUPP;
-
+	if (!(changed & NETIF_F_RXCSUM))
+		return 0;
=20
 	if (dev->flags & IFF_UP) {
 		/* Halt TX and RX, and process the frames which
@@ -546,58 +546,15 @@ static int gfar_set_rx_csum(struct net_device *de=
v, uint32_t data)
=20
 		/* Now we take down the rings to rebuild them */
 		stop_gfar(dev);
-	}
=20
-	spin_lock_irqsave(&priv->bflock, flags);
-	priv->rx_csum_enable =3D data;
-	spin_unlock_irqrestore(&priv->bflock, flags);
+		dev->features =3D features;
=20
-	if (dev->flags & IFF_UP) {
 		err =3D startup_gfar(dev);
 		netif_tx_wake_all_queues(dev);
 	}
 	return err;
 }
=20
-static uint32_t gfar_get_rx_csum(struct net_device *dev)
-{
-	struct gfar_private *priv =3D netdev_priv(dev);
-
-	if (!(priv->device_flags & FSL_GIANFAR_DEV_HAS_CSUM))
-		return 0;
-
-	return priv->rx_csum_enable;
-}
-
-static int gfar_set_tx_csum(struct net_device *dev, uint32_t data)
-{
-	struct gfar_private *priv =3D netdev_priv(dev);
-
-	if (!(priv->device_flags & FSL_GIANFAR_DEV_HAS_CSUM))
-		return -EOPNOTSUPP;
-
-	netif_tx_lock_bh(dev);
-
-	if (data)
-		dev->features |=3D NETIF_F_IP_CSUM;
-	else
-		dev->features &=3D ~NETIF_F_IP_CSUM;
-
-	netif_tx_unlock_bh(dev);
-
-	return 0;
-}
-
-static uint32_t gfar_get_tx_csum(struct net_device *dev)
-{
-	struct gfar_private *priv =3D netdev_priv(dev);
-
-	if (!(priv->device_flags & FSL_GIANFAR_DEV_HAS_CSUM))
-		return 0;
-
-	return (dev->features & NETIF_F_IP_CSUM) !=3D 0;
-}
-
 static uint32_t gfar_get_msglevel(struct net_device *dev)
 {
 	struct gfar_private *priv =3D netdev_priv(dev);
@@ -844,11 +801,6 @@ const struct ethtool_ops gfar_ethtool_ops =3D {
 	.get_strings =3D gfar_gstrings,
 	.get_sset_count =3D gfar_sset_count,
 	.get_ethtool_stats =3D gfar_fill_stats,
-	.get_rx_csum =3D gfar_get_rx_csum,
-	.get_tx_csum =3D gfar_get_tx_csum,
-	.set_rx_csum =3D gfar_set_rx_csum,
-	.set_tx_csum =3D gfar_set_tx_csum,
-	.set_sg =3D ethtool_op_set_sg,
 	.get_msglevel =3D gfar_get_msglevel,
 	.set_msglevel =3D gfar_set_msglevel,
 #ifdef CONFIG_PM
--=20
1.7.2.5

