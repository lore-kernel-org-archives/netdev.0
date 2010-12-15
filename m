From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [RFC PATCH 11/12] veth: convert to hw_features
Date: Wed, 15 Dec 2010 23:24:30 +0100 (CET)
Message-ID: <804076774f3e4ec1d57b63e2703fa4584a840f1c.1292451560.git.mirq-linux@rere.qmqm.pl>
References: <cover.1292451559.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:53558 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752434Ab0LOWYc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Dec 2010 17:24:32 -0500
In-Reply-To: <cover.1292451559.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This depends on 'net/veth: Fix packet checksumming' patch.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/veth.c |   45 +++++---------------------------------------=
-
 1 files changed, 5 insertions(+), 40 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index cca6a71..6e9f23c 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -36,7 +36,6 @@ struct veth_net_stats {
 struct veth_priv {
 	struct net_device *peer;
 	struct veth_net_stats __percpu *stats;
-	unsigned ip_summed;
 };
=20
 /*
@@ -99,47 +98,10 @@ static void veth_get_ethtool_stats(struct net_devic=
e *dev,
 	data[0] =3D priv->peer->ifindex;
 }
=20
-static u32 veth_get_rx_csum(struct net_device *dev)
-{
-	struct veth_priv *priv;
-
-	priv =3D netdev_priv(dev);
-	return priv->ip_summed =3D=3D CHECKSUM_UNNECESSARY;
-}
-
-static int veth_set_rx_csum(struct net_device *dev, u32 data)
-{
-	struct veth_priv *priv;
-
-	priv =3D netdev_priv(dev);
-	priv->ip_summed =3D data ? CHECKSUM_UNNECESSARY : CHECKSUM_NONE;
-	return 0;
-}
-
-static u32 veth_get_tx_csum(struct net_device *dev)
-{
-	return (dev->features & NETIF_F_NO_CSUM) !=3D 0;
-}
-
-static int veth_set_tx_csum(struct net_device *dev, u32 data)
-{
-	if (data)
-		dev->features |=3D NETIF_F_NO_CSUM;
-	else
-		dev->features &=3D ~NETIF_F_NO_CSUM;
-	return 0;
-}
-
 static const struct ethtool_ops veth_ethtool_ops =3D {
 	.get_settings		=3D veth_get_settings,
 	.get_drvinfo		=3D veth_get_drvinfo,
 	.get_link		=3D ethtool_op_get_link,
-	.get_rx_csum		=3D veth_get_rx_csum,
-	.set_rx_csum		=3D veth_set_rx_csum,
-	.get_tx_csum		=3D veth_get_tx_csum,
-	.set_tx_csum		=3D veth_set_tx_csum,
-	.get_sg			=3D ethtool_op_get_sg,
-	.set_sg			=3D ethtool_op_set_sg,
 	.get_strings		=3D veth_get_strings,
 	.get_sset_count		=3D veth_get_sset_count,
 	.get_ethtool_stats	=3D veth_get_ethtool_stats,
@@ -168,8 +130,9 @@ static netdev_tx_t veth_xmit(struct sk_buff *skb, s=
truct net_device *dev)
=20
 	/* we can't change ip_summed =3D=3D CHECKSUM_PARTIAL, as that
 	   will cause bad checksum on forwarded packets */
-	if (skb->ip_summed =3D=3D CHECKSUM_NONE)
-		skb->ip_summed =3D rcv_priv->ip_summed;
+	if (skb->ip_summed =3D=3D CHECKSUM_NONE &&
+	    rcv->features & NETIF_F_RXCSUM)
+		skb->ip_summed =3D CHECKSUM_UNNECESSARY;
=20
 	length =3D skb->len + ETH_HLEN;
 	if (dev_forward_skb(rcv, skb) !=3D NET_RX_SUCCESS)
@@ -304,6 +267,8 @@ static void veth_setup(struct net_device *dev)
 	dev->ethtool_ops =3D &veth_ethtool_ops;
 	dev->features |=3D NETIF_F_LLTX;
 	dev->destructor =3D veth_dev_free;
+
+	dev->hw_features =3D NETIF_F_NO_CSUM | NETIF_F_SG | NETIF_F_RXCSUM;
 }
=20
 /*
--=20
1.7.2.3

