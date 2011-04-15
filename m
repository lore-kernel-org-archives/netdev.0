From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: mlx4: convert to hw_features
Date: Fri, 15 Apr 2011 16:50:49 +0200 (CEST)
Message-ID: <20110415145049.D929D13A67@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	Eli Cohen <eli@mellanox.co.il>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:46537 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756256Ab1DOOuw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Apr 2011 10:50:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---

BTW, MAINTAINERS entry for this driver is missing.

 drivers/net/mlx4/en_ethtool.c |   42 ---------------------------------=
--------
 drivers/net/mlx4/en_netdev.c  |   26 +++++++++---------------
 drivers/net/mlx4/en_rx.c      |    2 +-
 drivers/net/mlx4/mlx4_en.h    |    1 -
 4 files changed, 11 insertions(+), 60 deletions(-)

diff --git a/drivers/net/mlx4/en_ethtool.c b/drivers/net/mlx4/en_ethtoo=
l.c
index d54b7ab..da1b64d 100644
--- a/drivers/net/mlx4/en_ethtool.c
+++ b/drivers/net/mlx4/en_ethtool.c
@@ -57,37 +57,6 @@ mlx4_en_get_drvinfo(struct net_device *dev, struct e=
thtool_drvinfo *drvinfo)
 	drvinfo->eedump_len =3D 0;
 }
=20
-static u32 mlx4_en_get_tso(struct net_device *dev)
-{
-	return (dev->features & NETIF_F_TSO) !=3D 0;
-}
-
-static int mlx4_en_set_tso(struct net_device *dev, u32 data)
-{
-	struct mlx4_en_priv *priv =3D netdev_priv(dev);
-
-	if (data) {
-		if (!priv->mdev->LSO_support)
-			return -EPERM;
-		dev->features |=3D (NETIF_F_TSO | NETIF_F_TSO6);
-	} else
-		dev->features &=3D ~(NETIF_F_TSO | NETIF_F_TSO6);
-	return 0;
-}
-
-static u32 mlx4_en_get_rx_csum(struct net_device *dev)
-{
-	struct mlx4_en_priv *priv =3D netdev_priv(dev);
-	return priv->rx_csum;
-}
-
-static int mlx4_en_set_rx_csum(struct net_device *dev, u32 data)
-{
-	struct mlx4_en_priv *priv =3D netdev_priv(dev);
-	priv->rx_csum =3D (data !=3D 0);
-	return 0;
-}
-
 static const char main_strings[][ETH_GSTRING_LEN] =3D {
 	"rx_packets", "tx_packets", "rx_bytes", "tx_bytes", "rx_errors",
 	"tx_errors", "rx_dropped", "tx_dropped", "multicast", "collisions",
@@ -483,17 +452,7 @@ const struct ethtool_ops mlx4_en_ethtool_ops =3D {
 	.get_drvinfo =3D mlx4_en_get_drvinfo,
 	.get_settings =3D mlx4_en_get_settings,
 	.set_settings =3D mlx4_en_set_settings,
-#ifdef NETIF_F_TSO
-	.get_tso =3D mlx4_en_get_tso,
-	.set_tso =3D mlx4_en_set_tso,
-#endif
-	.get_sg =3D ethtool_op_get_sg,
-	.set_sg =3D ethtool_op_set_sg,
 	.get_link =3D ethtool_op_get_link,
-	.get_rx_csum =3D mlx4_en_get_rx_csum,
-	.set_rx_csum =3D mlx4_en_set_rx_csum,
-	.get_tx_csum =3D ethtool_op_get_tx_csum,
-	.set_tx_csum =3D ethtool_op_set_tx_ipv6_csum,
 	.get_strings =3D mlx4_en_get_strings,
 	.get_sset_count =3D mlx4_en_get_sset_count,
 	.get_ethtool_stats =3D mlx4_en_get_ethtool_stats,
@@ -508,7 +467,6 @@ const struct ethtool_ops mlx4_en_ethtool_ops =3D {
 	.set_pauseparam =3D mlx4_en_set_pauseparam,
 	.get_ringparam =3D mlx4_en_get_ringparam,
 	.set_ringparam =3D mlx4_en_set_ringparam,
-	.get_flags =3D ethtool_op_get_flags,
 };
=20
=20
diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.=
c
index 77063f9..61850ad 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -1083,7 +1083,6 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev,=
 int port,
 	priv->prof =3D prof;
 	priv->port =3D port;
 	priv->port_up =3D false;
-	priv->rx_csum =3D 1;
 	priv->flags =3D prof->flags;
 	priv->tx_ring_num =3D prof->tx_ring_num;
 	priv->rx_ring_num =3D prof->rx_ring_num;
@@ -1141,21 +1140,16 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mde=
v, int port,
 	/*
 	 * Set driver features
 	 */
-	dev->features |=3D NETIF_F_SG;
-	dev->vlan_features |=3D NETIF_F_SG;
-	dev->features |=3D NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
-	dev->vlan_features |=3D NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
-	dev->features |=3D NETIF_F_HIGHDMA;
-	dev->features |=3D NETIF_F_HW_VLAN_TX |
-			 NETIF_F_HW_VLAN_RX |
-			 NETIF_F_HW_VLAN_FILTER;
-	dev->features |=3D NETIF_F_GRO;
-	if (mdev->LSO_support) {
-		dev->features |=3D NETIF_F_TSO;
-		dev->features |=3D NETIF_F_TSO6;
-		dev->vlan_features |=3D NETIF_F_TSO;
-		dev->vlan_features |=3D NETIF_F_TSO6;
-	}
+	dev->hw_features =3D NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM=
;
+	if (mdev->LSO_support)
+		dev->hw_features |=3D NETIF_F_TSO | NETIF_F_TSO6;
+
+	dev->vlan_features =3D dev->hw_features;
+
+	dev->hw_features |=3D NETIF_F_RXCSUM;
+	dev->features =3D dev->hw_features | NETIF_F_HIGHDMA |
+			NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX |
+			NETIF_F_HW_VLAN_FILTER;
=20
 	mdev->pndev[port] =3D dev;
=20
diff --git a/drivers/net/mlx4/en_rx.c b/drivers/net/mlx4/en_rx.c
index 62dd21b..277215f 100644
--- a/drivers/net/mlx4/en_rx.c
+++ b/drivers/net/mlx4/en_rx.c
@@ -584,7 +584,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, s=
truct mlx4_en_cq *cq, int bud
 		ring->bytes +=3D length;
 		ring->packets++;
=20
-		if (likely(priv->rx_csum)) {
+		if (likely(dev->features & NETIF_F_RXCSUM)) {
 			if ((cqe->status & cpu_to_be16(MLX4_CQE_STATUS_IPOK)) &&
 			    (cqe->checksum =3D=3D cpu_to_be16(0xffff))) {
 				priv->port_stats.rx_chksum_good++;
diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index e30f609..0b5150d 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -451,7 +451,6 @@ struct mlx4_en_priv {
 	int registered;
 	int allocated;
 	int stride;
-	int rx_csum;
 	u64 mac;
 	int mac_index;
 	unsigned max_mtu;
--=20
1.7.2.5

