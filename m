From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: mv643xx: convert to hw_features
Date: Sun, 17 Apr 2011 12:15:46 +0200 (CEST)
Message-ID: <20110417101546.AD95813A68@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Lennert Buytenhek <buytenh@wantstofly.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:48098 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755864Ab1DQKPs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Apr 2011 06:15:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Side effect: don't reenable RXCSUM on every ifdown/ifup.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/mv643xx_eth.c |   28 +++++++---------------------
 1 files changed, 7 insertions(+), 21 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 34425b9..29605a3 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1575,18 +1575,12 @@ mv643xx_eth_set_ringparam(struct net_device *de=
v, struct ethtool_ringparam *er)
 	return 0;
 }
=20
-static u32
-mv643xx_eth_get_rx_csum(struct net_device *dev)
-{
-	struct mv643xx_eth_private *mp =3D netdev_priv(dev);
-
-	return !!(rdlp(mp, PORT_CONFIG) & 0x02000000);
-}
=20
 static int
-mv643xx_eth_set_rx_csum(struct net_device *dev, u32 rx_csum)
+mv643xx_eth_set_features(struct net_device *dev, u32 features)
 {
 	struct mv643xx_eth_private *mp =3D netdev_priv(dev);
+	u32 rx_csum =3D features & NETIF_F_RXCSUM;
=20
 	wrlp(mp, PORT_CONFIG, rx_csum ? 0x02000000 : 0x00000000);
=20
@@ -1634,11 +1628,6 @@ static void mv643xx_eth_get_ethtool_stats(struct=
 net_device *dev,
 	}
 }
=20
-static int mv643xx_eth_set_flags(struct net_device *dev, u32 data)
-{
-	return ethtool_op_set_flags(dev, data, ETH_FLAG_LRO);
-}
-
 static int mv643xx_eth_get_sset_count(struct net_device *dev, int sset=
)
 {
 	if (sset =3D=3D ETH_SS_STATS)
@@ -1657,14 +1646,8 @@ static const struct ethtool_ops mv643xx_eth_etht=
ool_ops =3D {
 	.set_coalesce		=3D mv643xx_eth_set_coalesce,
 	.get_ringparam		=3D mv643xx_eth_get_ringparam,
 	.set_ringparam		=3D mv643xx_eth_set_ringparam,
-	.get_rx_csum		=3D mv643xx_eth_get_rx_csum,
-	.set_rx_csum		=3D mv643xx_eth_set_rx_csum,
-	.set_tx_csum		=3D ethtool_op_set_tx_csum,
-	.set_sg			=3D ethtool_op_set_sg,
 	.get_strings		=3D mv643xx_eth_get_strings,
 	.get_ethtool_stats	=3D mv643xx_eth_get_ethtool_stats,
-	.get_flags		=3D ethtool_op_get_flags,
-	.set_flags		=3D mv643xx_eth_set_flags,
 	.get_sset_count		=3D mv643xx_eth_get_sset_count,
 };
=20
@@ -2264,7 +2247,7 @@ static void port_start(struct mv643xx_eth_private=
 *mp)
 	 * frames to RX queue #0, and include the pseudo-header when
 	 * calculating receive checksums.
 	 */
-	wrlp(mp, PORT_CONFIG, 0x02000000);
+	mv643xx_eth_set_features(dev, dev->features);
=20
 	/*
 	 * Treat BPDUs as normal multicasts, and disable partition mode.
@@ -2848,6 +2831,7 @@ static const struct net_device_ops mv643xx_eth_ne=
tdev_ops =3D {
 	.ndo_validate_addr	=3D eth_validate_addr,
 	.ndo_do_ioctl		=3D mv643xx_eth_ioctl,
 	.ndo_change_mtu		=3D mv643xx_eth_change_mtu,
+	.ndo_set_features	=3D mv643xx_eth_set_features,
 	.ndo_tx_timeout		=3D mv643xx_eth_tx_timeout,
 	.ndo_get_stats		=3D mv643xx_eth_get_stats,
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -2930,7 +2914,9 @@ static int mv643xx_eth_probe(struct platform_devi=
ce *pdev)
 	dev->watchdog_timeo =3D 2 * HZ;
 	dev->base_addr =3D 0;
=20
-	dev->features =3D NETIF_F_SG | NETIF_F_IP_CSUM;
+	dev->hw_features =3D NETIF_F_SG | NETIF_F_IP_CSUM |
+		NETIF_F_RXCSUM | NETIF_F_LRO;
+	dev->features =3D NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_RXCSUM;
 	dev->vlan_features =3D NETIF_F_SG | NETIF_F_IP_CSUM;
=20
 	SET_NETDEV_DEV(dev, &pdev->dev);
--=20
1.7.2.5

