From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v5 RESEND 8/9] net: introduce NETIF_F_RXCSUM
Date: Sun, 13 Feb 2011 12:11:46 +0100 (CET)
Message-ID: <05a256126d7400123e845e0297f20ef4ca106512.1297594674.git.mirq-linux@rere.qmqm.pl>
References: <cover.1297594674.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:50514 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754196Ab1BMLLt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Feb 2011 06:11:49 -0500
In-Reply-To: <cover.1297594674.git.mirq-linux@rere.qmqm.pl>
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
 include/linux/netdevice.h |    5 +++-
 net/core/ethtool.c        |   47 ++++++++++++++++++++++---------------=
--------
 3 files changed, 27 insertions(+), 26 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 806e716..54d776c 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -625,7 +625,6 @@ struct net_device;
=20
 /* Some generic methods drivers may use in their ethtool_ops */
 u32 ethtool_op_get_link(struct net_device *dev);
-u32 ethtool_op_get_rx_csum(struct net_device *dev);
 u32 ethtool_op_get_tx_csum(struct net_device *dev);
 int ethtool_op_set_tx_csum(struct net_device *dev, u32 data);
 int ethtool_op_set_tx_hw_csum(struct net_device *dev, u32 data);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4a3e554..45080bb 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -964,6 +964,7 @@ struct net_device {
 #define NETIF_F_FCOE_MTU	(1 << 26) /* Supports max FCoE MTU, 2158 byte=
s*/
 #define NETIF_F_NTUPLE		(1 << 27) /* N-tuple filters supported */
 #define NETIF_F_RXHASH		(1 << 28) /* Receive hashing offload */
+#define NETIF_F_RXCSUM		(1 << 29) /* Receive checksumming offload */
=20
 	/* Segmentation offload features */
 #define NETIF_F_GSO_SHIFT	16
@@ -979,7 +980,7 @@ struct net_device {
 	/* =3D all defined minus driver/device-class-related */
 #define NETIF_F_NEVER_CHANGE	(NETIF_F_HIGHDMA | NETIF_F_VLAN_CHALLENGE=
D | \
 				  NETIF_F_LLTX | NETIF_F_NETNS_LOCAL)
-#define NETIF_F_ETHTOOL_BITS	(0x1f3fffff & ~NETIF_F_NEVER_CHANGE)
+#define NETIF_F_ETHTOOL_BITS	(0x3f3fffff & ~NETIF_F_NEVER_CHANGE)
=20
 	/* List of features with software fallbacks. */
 #define NETIF_F_GSO_SOFTWARE	(NETIF_F_TSO | NETIF_F_TSO_ECN | \
@@ -2501,6 +2502,8 @@ static inline int dev_ethtool_get_settings(struct=
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
index 65b3d50..66cdc76 100644
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
@@ -274,7 +268,7 @@ static const char netdev_features_strings[ETHTOOL_D=
EV_FEATURE_WORDS * 32][ETH_GS
 	/* NETIF_F_FCOE_MTU */        "fcoe-mtu",
 	/* NETIF_F_NTUPLE */          "rx-ntuple-filter",
 	/* NETIF_F_RXHASH */          "rx-hashing",
-	"",
+	/* NETIF_F_RXCSUM */          "rx-checksum",
 	"",
 	"",
 };
@@ -313,6 +307,9 @@ static u32 ethtool_get_feature_mask(u32 eth_cmd)
 	case ETHTOOL_GTXCSUM:
 	case ETHTOOL_STXCSUM:
 		return NETIF_F_ALL_CSUM | NETIF_F_SCTP_CSUM;
+	case ETHTOOL_GRXCSUM:
+	case ETHTOOL_SRXCSUM:
+		return NETIF_F_RXCSUM;
 	case ETHTOOL_GSG:
 	case ETHTOOL_SSG:
 		return NETIF_F_SG;
@@ -343,6 +340,8 @@ static void *__ethtool_get_one_feature_actor(struct=
 net_device *dev, u32 ethcmd)
 	switch (ethcmd) {
 	case ETHTOOL_GTXCSUM:
 		return ops->get_tx_csum;
+	case ETHTOOL_GRXCSUM:
+		return ops->get_rx_csum;
 	case ETHTOOL_SSG:
 		return ops->get_sg;
 	case ETHTOOL_STSO:
@@ -354,6 +353,11 @@ static void *__ethtool_get_one_feature_actor(struc=
t net_device *dev, u32 ethcmd)
 	}
 }
=20
+static u32 __ethtool_get_rx_csum_oldbug(struct net_device *dev)
+{
+	return !!(dev->features & NETIF_F_ALL_CSUM);
+}
+
 static int ethtool_get_one_feature(struct net_device *dev,
 	char __user *useraddr, u32 ethcmd)
 {
@@ -369,6 +373,10 @@ static int ethtool_get_one_feature(struct net_devi=
ce *dev,
=20
 		actor =3D __ethtool_get_one_feature_actor(dev, ethcmd);
=20
+		/* bug compatibility with old get_rx_csum */
+		if (ethcmd =3D=3D ETHTOOL_GRXCSUM && !actor)
+			actor =3D __ethtool_get_rx_csum_oldbug;
+
 		if (actor)
 			edata.data =3D actor(dev);
 	}
@@ -379,6 +387,7 @@ static int ethtool_get_one_feature(struct net_devic=
e *dev,
 }
=20
 static int __ethtool_set_tx_csum(struct net_device *dev, u32 data);
+static int __ethtool_set_rx_csum(struct net_device *dev, u32 data);
 static int __ethtool_set_sg(struct net_device *dev, u32 data);
 static int __ethtool_set_tso(struct net_device *dev, u32 data);
 static int __ethtool_set_ufo(struct net_device *dev, u32 data);
@@ -416,6 +425,8 @@ static int ethtool_set_one_feature(struct net_devic=
e *dev,
 	switch (ethcmd) {
 	case ETHTOOL_STXCSUM:
 		return __ethtool_set_tx_csum(dev, edata.data);
+	case ETHTOOL_SRXCSUM:
+		return __ethtool_set_rx_csum(dev, edata.data);
 	case ETHTOOL_SSG:
 		return __ethtool_set_sg(dev, edata.data);
 	case ETHTOOL_STSO:
@@ -1404,20 +1415,15 @@ static int __ethtool_set_tx_csum(struct net_dev=
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
@@ -1765,15 +1771,6 @@ int dev_ethtool(struct net *net, struct ifreq *i=
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
@@ -1846,6 +1843,7 @@ int dev_ethtool(struct net *net, struct ifreq *if=
r)
 		rc =3D ethtool_set_features(dev, useraddr);
 		break;
 	case ETHTOOL_GTXCSUM:
+	case ETHTOOL_GRXCSUM:
 	case ETHTOOL_GSG:
 	case ETHTOOL_GTSO:
 	case ETHTOOL_GUFO:
@@ -1854,6 +1852,7 @@ int dev_ethtool(struct net *net, struct ifreq *if=
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

