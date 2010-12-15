From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [RFC PATCH 04/12] net: introduce NETIF_F_RXCSUM
Date: Wed, 15 Dec 2010 23:24:29 +0100 (CET)
Message-ID: <fcee74e8b71430c0e0c267ac180f5861c471dc41.1292451560.git.mirq-linux@rere.qmqm.pl>
References: <cover.1292451559.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:53551 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752071Ab0LOWYa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Dec 2010 17:24:30 -0500
In-Reply-To: <cover.1292451559.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce NETIF_F_RXCSUM to replace device-private flags for RX checksu=
m
offload. Integrate it with ndo_fix_features.

ethtool_op_get_rx_csum() is removed altogether as nothing in-tree uses =
it.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 include/linux/ethtool.h   |    1 -
 include/linux/netdevice.h |    3 +++
 net/core/ethtool.c        |   34 +++++++++++-----------------------
 3 files changed, 14 insertions(+), 24 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 0267d45..2475b41 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -568,7 +568,6 @@ struct net_device;
=20
 /* Some generic methods drivers may use in their ethtool_ops */
 u32 ethtool_op_get_link(struct net_device *dev);
-u32 ethtool_op_get_rx_csum(struct net_device *dev);
 u32 ethtool_op_get_tx_csum(struct net_device *dev);
 int ethtool_op_set_tx_csum(struct net_device *dev, u32 data);
 int ethtool_op_set_tx_hw_csum(struct net_device *dev, u32 data);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 7634cab..ce35514 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -920,6 +920,7 @@ struct net_device {
 #define NETIF_F_FCOE_MTU	(1 << 26) /* Supports max FCoE MTU, 2158 byte=
s*/
 #define NETIF_F_NTUPLE		(1 << 27) /* N-tuple filters supported */
 #define NETIF_F_RXHASH		(1 << 28) /* Receive hashing offload */
+#define NETIF_F_RXCSUM		(1 << 29) /* Receive checksumming offload */
=20
 	/* Segmentation offload features */
 #define NETIF_F_GSO_SHIFT	16
@@ -2379,6 +2380,8 @@ static inline int dev_ethtool_get_settings(struct=
 net_device *dev,
=20
 static inline u32 dev_ethtool_get_rx_csum(struct net_device *dev)
 {
+	if (dev->hw_features & NETIF_F_RXCSUM)
+		return !!(dev->features & NETIF_F_RXCSUM);
 	if (!dev->ethtool_ops || !dev->ethtool_ops->get_rx_csum)
 		return 0;
 	return dev->ethtool_ops->get_rx_csum(dev);
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index b068738..15e00b8 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -34,12 +34,6 @@ u32 ethtool_op_get_link(struct net_device *dev)
 }
 EXPORT_SYMBOL(ethtool_op_get_link);
=20
-u32 ethtool_op_get_rx_csum(struct net_device *dev)
-{
-	return (dev->features & NETIF_F_ALL_CSUM) !=3D 0;
-}
-EXPORT_SYMBOL(ethtool_op_get_rx_csum);
-
 u32 ethtool_op_get_tx_csum(struct net_device *dev)
 {
 	return (dev->features & NETIF_F_ALL_CSUM) !=3D 0;
@@ -227,6 +221,9 @@ static unsigned long ethtool_get_feature_mask(u32 e=
th_cmd)
 	case ETHTOOL_GTXCSUM:
 	case ETHTOOL_STXCSUM:
 		return NETIF_F_ALL_CSUM|NETIF_F_SCTP_CSUM;
+	case ETHTOOL_GRXCSUM:
+	case ETHTOOL_SRXCSUM:
+		return NETIF_F_RXCSUM;
 	case ETHTOOL_GSG:
 	case ETHTOOL_SSG:
 		return NETIF_F_SG;
@@ -261,6 +258,7 @@ static int ethtool_get_one_feature(struct net_devic=
e *dev, char __user *useraddr
 }
=20
 static int __ethtool_set_tx_csum(struct net_device *dev, u32 data);
+static int __ethtool_set_rx_csum(struct net_device *dev, u32 data);
 static int __ethtool_set_sg(struct net_device *dev, u32 data);
 static int __ethtool_set_tso(struct net_device *dev, u32 data);
 static int __ethtool_set_ufo(struct net_device *dev, u32 data);
@@ -289,6 +287,8 @@ static int ethtool_set_one_feature(struct net_devic=
e *dev,
 	switch (ethcmd) {
 	case ETHTOOL_STXCSUM:
 		return __ethtool_set_tx_csum(dev, edata.data);
+	case ETHTOOL_SRXCSUM:
+		return __ethtool_set_rx_csum(dev, edata.data);
 	case ETHTOOL_SSG:
 		return __ethtool_set_sg(dev, edata.data);
 	case ETHTOOL_STSO:
@@ -1253,20 +1253,15 @@ static int __ethtool_set_tx_csum(struct net_dev=
ice *dev, u32 data)
 	return dev->ethtool_ops->set_tx_csum(dev, data);
 }
=20
-static int ethtool_set_rx_csum(struct net_device *dev, char __user *us=
eraddr)
+static int __ethtool_set_rx_csum(struct net_device *dev, u32 data)
 {
-	struct ethtool_value edata;
-
 	if (!dev->ethtool_ops->set_rx_csum)
 		return -EOPNOTSUPP;
=20
-	if (copy_from_user(&edata, useraddr, sizeof(edata)))
-		return -EFAULT;
-
-	if (!edata.data && dev->ethtool_ops->set_sg)
+	if (!data)
 		dev->features &=3D ~NETIF_F_GRO;
=20
-	return dev->ethtool_ops->set_rx_csum(dev, edata.data);
+	return dev->ethtool_ops->set_rx_csum(dev, data);
 }
=20
 static int __ethtool_set_tso(struct net_device *dev, u32 data)
@@ -1618,15 +1613,6 @@ int dev_ethtool(struct net *net, struct ifreq *i=
fr)
 	case ETHTOOL_SPAUSEPARAM:
 		rc =3D ethtool_set_pauseparam(dev, useraddr);
 		break;
-	case ETHTOOL_GRXCSUM:
-		rc =3D ethtool_get_value(dev, useraddr, ethcmd,
-				       (dev->ethtool_ops->get_rx_csum ?
-					dev->ethtool_ops->get_rx_csum :
-					ethtool_op_get_rx_csum));
-		break;
-	case ETHTOOL_SRXCSUM:
-		rc =3D ethtool_set_rx_csum(dev, useraddr);
-		break;
 	case ETHTOOL_TEST:
 		rc =3D ethtool_self_test(dev, useraddr);
 		break;
@@ -1700,6 +1686,7 @@ int dev_ethtool(struct net *net, struct ifreq *if=
r)
 		rc =3D ethtool_set_features(dev, useraddr);
 		break;
 	case ETHTOOL_GTXCSUM:
+	case ETHTOOL_GRXCSUM:
 	case ETHTOOL_GSG:
 	case ETHTOOL_GTSO:
 	case ETHTOOL_GUFO:
@@ -1708,6 +1695,7 @@ int dev_ethtool(struct net *net, struct ifreq *if=
r)
 		rc =3D ethtool_get_one_feature(dev, useraddr, ethcmd);
 		break;
 	case ETHTOOL_STXCSUM:
+	case ETHTOOL_SRXCSUM:
 	case ETHTOOL_SSG:
 	case ETHTOOL_STSO:
 	case ETHTOOL_SUFO:
--=20
1.7.2.3

