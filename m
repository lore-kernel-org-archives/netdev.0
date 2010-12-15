From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [RFC PATCH 03/12] net: ethtool: use ndo_fix_features for offload setting
Date: Wed, 15 Dec 2010 23:24:29 +0100 (CET)
Message-ID: <b4f8764846cebb2ebaad8c5c3fb86457e11cc8a4.1292451559.git.mirq-linux@rere.qmqm.pl>
References: <cover.1292451559.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:53550 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751995Ab0LOWYa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Dec 2010 17:24:30 -0500
In-Reply-To: <cover.1292451559.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 include/linux/netdevice.h |    2 +
 net/core/dev.c            |    8 ++
 net/core/ethtool.c        |  252 +++++++++++++++++++------------------=
-------
 3 files changed, 119 insertions(+), 143 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4b20944..7634cab 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -941,6 +941,8 @@ struct net_device {
 #define NETIF_F_V6_CSUM		(NETIF_F_GEN_CSUM | NETIF_F_IPV6_CSUM)
 #define NETIF_F_ALL_CSUM	(NETIF_F_V4_CSUM | NETIF_F_V6_CSUM)
=20
+#define NETIF_F_ALL_TSO 	(NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_TSO_ECN=
)
+
 	/*
 	 * If one device supports one of these features, then enable them
 	 * for all in netdev_increment_features.
diff --git a/net/core/dev.c b/net/core/dev.c
index 1e616bb..95d0a49 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5054,6 +5054,14 @@ unsigned long netdev_fix_features(unsigned long =
features, const char *name)
 		features &=3D ~NETIF_F_TSO;
 	}
=20
+	/* Software GSO depends on SG. */
+	if ((features & NETIF_F_GSO) && !(features & NETIF_F_SG)) {
+		if (name)
+			printk(KERN_NOTICE "%s: Dropping NETIF_F_GSO since no "
+			       "SG feature.\n", name);
+		features &=3D ~NETIF_F_GSO;
+	}
+
 	if (features & NETIF_F_UFO) {
 		/* maybe split UFO into V4 and V6? */
 		if (!((features & NETIF_F_GEN_CSUM) ||
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index f08e7f1..b068738 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -55,6 +55,7 @@ int ethtool_op_set_tx_csum(struct net_device *dev, u3=
2 data)
=20
 	return 0;
 }
+EXPORT_SYMBOL(ethtool_op_set_tx_csum);
=20
 int ethtool_op_set_tx_hw_csum(struct net_device *dev, u32 data)
 {
@@ -220,6 +221,85 @@ static int ethtool_set_features(struct net_device =
*dev, void __user *useraddr)
 	return 0;
 }
=20
+static unsigned long ethtool_get_feature_mask(u32 eth_cmd)
+{
+	switch (eth_cmd) {
+	case ETHTOOL_GTXCSUM:
+	case ETHTOOL_STXCSUM:
+		return NETIF_F_ALL_CSUM|NETIF_F_SCTP_CSUM;
+	case ETHTOOL_GSG:
+	case ETHTOOL_SSG:
+		return NETIF_F_SG;
+	case ETHTOOL_GTSO:
+	case ETHTOOL_STSO:
+		return NETIF_F_ALL_TSO;
+	case ETHTOOL_GUFO:
+	case ETHTOOL_SUFO:
+		return NETIF_F_UFO;
+	case ETHTOOL_GGSO:
+	case ETHTOOL_SGSO:
+		return NETIF_F_GSO;
+	case ETHTOOL_GGRO:
+	case ETHTOOL_SGRO:
+		return NETIF_F_GRO;
+	default:
+		BUG();
+	}
+}
+
+static int ethtool_get_one_feature(struct net_device *dev, char __user=
 *useraddr,
+	u32 ethcmd)
+{
+	struct ethtool_value edata =3D {
+		.cmd =3D ethcmd,
+		.data =3D !!(dev->features & ethtool_get_feature_mask(ethcmd)),
+	};
+
+	if (copy_to_user(useraddr, &edata, sizeof(edata)))
+		return -EFAULT;
+	return 0;
+}
+
+static int __ethtool_set_tx_csum(struct net_device *dev, u32 data);
+static int __ethtool_set_sg(struct net_device *dev, u32 data);
+static int __ethtool_set_tso(struct net_device *dev, u32 data);
+static int __ethtool_set_ufo(struct net_device *dev, u32 data);
+
+static int ethtool_set_one_feature(struct net_device *dev,
+	void __user *useraddr, u32 ethcmd)
+{
+	struct ethtool_value edata;
+	unsigned long mask;
+
+	if (copy_from_user(&edata, useraddr, sizeof(edata)))
+		return -EFAULT;
+
+	mask =3D ethtool_get_feature_mask(ethcmd);
+	mask &=3D dev->hw_features | NETIF_F_SOFT_FEATURES;
+	if (mask) {
+		if (edata.data)
+			dev->wanted_features |=3D mask;
+		else
+			dev->wanted_features &=3D ~mask;
+
+		netdev_update_features(dev);
+		return 0;
+	}
+
+	switch (ethcmd) {
+	case ETHTOOL_STXCSUM:
+		return __ethtool_set_tx_csum(dev, edata.data);
+	case ETHTOOL_SSG:
+		return __ethtool_set_sg(dev, edata.data);
+	case ETHTOOL_STSO:
+		return __ethtool_set_tso(dev, edata.data);
+	case ETHTOOL_SUFO:
+		return __ethtool_set_ufo(dev, edata.data);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
 static int ethtool_get_settings(struct net_device *dev, void __user *u=
seraddr)
 {
 	struct ethtool_cmd cmd =3D { .cmd =3D ETHTOOL_GSET };
@@ -1140,6 +1220,9 @@ static int __ethtool_set_sg(struct net_device *de=
v, u32 data)
 {
 	int err;
=20
+	if (data && !(dev->features & NETIF_F_ALL_CSUM))
+		return -EINVAL;
+
 	if (!data && dev->ethtool_ops->set_tso) {
 		err =3D dev->ethtool_ops->set_tso(dev, 0);
 		if (err)
@@ -1154,26 +1237,21 @@ static int __ethtool_set_sg(struct net_device *=
dev, u32 data)
 	return dev->ethtool_ops->set_sg(dev, data);
 }
=20
-static int ethtool_set_tx_csum(struct net_device *dev, char __user *us=
eraddr)
+static int __ethtool_set_tx_csum(struct net_device *dev, u32 data)
 {
-	struct ethtool_value edata;
 	int err;
=20
 	if (!dev->ethtool_ops->set_tx_csum)
 		return -EOPNOTSUPP;
=20
-	if (copy_from_user(&edata, useraddr, sizeof(edata)))
-		return -EFAULT;
-
-	if (!edata.data && dev->ethtool_ops->set_sg) {
+	if (!data && dev->ethtool_ops->set_sg) {
 		err =3D __ethtool_set_sg(dev, 0);
 		if (err)
 			return err;
 	}
=20
-	return dev->ethtool_ops->set_tx_csum(dev, edata.data);
+	return dev->ethtool_ops->set_tx_csum(dev, data);
 }
-EXPORT_SYMBOL(ethtool_op_set_tx_csum);
=20
 static int ethtool_set_rx_csum(struct net_device *dev, char __user *us=
eraddr)
 {
@@ -1191,108 +1269,28 @@ static int ethtool_set_rx_csum(struct net_devi=
ce *dev, char __user *useraddr)
 	return dev->ethtool_ops->set_rx_csum(dev, edata.data);
 }
=20
-static int ethtool_set_sg(struct net_device *dev, char __user *useradd=
r)
-{
-	struct ethtool_value edata;
-
-	if (!dev->ethtool_ops->set_sg)
-		return -EOPNOTSUPP;
-
-	if (copy_from_user(&edata, useraddr, sizeof(edata)))
-		return -EFAULT;
-
-	if (edata.data &&
-	    !(dev->features & NETIF_F_ALL_CSUM))
-		return -EINVAL;
-
-	return __ethtool_set_sg(dev, edata.data);
-}
-
-static int ethtool_set_tso(struct net_device *dev, char __user *userad=
dr)
+static int __ethtool_set_tso(struct net_device *dev, u32 data)
 {
-	struct ethtool_value edata;
-
 	if (!dev->ethtool_ops->set_tso)
 		return -EOPNOTSUPP;
=20
-	if (copy_from_user(&edata, useraddr, sizeof(edata)))
-		return -EFAULT;
-
-	if (edata.data && !(dev->features & NETIF_F_SG))
+	if (data && !(dev->features & NETIF_F_SG))
 		return -EINVAL;
=20
-	return dev->ethtool_ops->set_tso(dev, edata.data);
+	return dev->ethtool_ops->set_tso(dev, data);
 }
=20
-static int ethtool_set_ufo(struct net_device *dev, char __user *userad=
dr)
+static int __ethtool_set_ufo(struct net_device *dev, u32 data)
 {
-	struct ethtool_value edata;
-
 	if (!dev->ethtool_ops->set_ufo)
 		return -EOPNOTSUPP;
-	if (copy_from_user(&edata, useraddr, sizeof(edata)))
-		return -EFAULT;
-	if (edata.data && !(dev->features & NETIF_F_SG))
+	if (data && !(dev->features & NETIF_F_SG))
 		return -EINVAL;
-	if (edata.data && !((dev->features & NETIF_F_GEN_CSUM) ||
+	if (data && !((dev->features & NETIF_F_GEN_CSUM) ||
 		(dev->features & (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM))
 			=3D=3D (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM)))
 		return -EINVAL;
-	return dev->ethtool_ops->set_ufo(dev, edata.data);
-}
-
-static int ethtool_get_gso(struct net_device *dev, char __user *userad=
dr)
-{
-	struct ethtool_value edata =3D { ETHTOOL_GGSO };
-
-	edata.data =3D dev->features & NETIF_F_GSO;
-	if (copy_to_user(useraddr, &edata, sizeof(edata)))
-		return -EFAULT;
-	return 0;
-}
-
-static int ethtool_set_gso(struct net_device *dev, char __user *userad=
dr)
-{
-	struct ethtool_value edata;
-
-	if (copy_from_user(&edata, useraddr, sizeof(edata)))
-		return -EFAULT;
-	if (edata.data)
-		dev->features |=3D NETIF_F_GSO;
-	else
-		dev->features &=3D ~NETIF_F_GSO;
-	return 0;
-}
-
-static int ethtool_get_gro(struct net_device *dev, char __user *userad=
dr)
-{
-	struct ethtool_value edata =3D { ETHTOOL_GGRO };
-
-	edata.data =3D dev->features & NETIF_F_GRO;
-	if (copy_to_user(useraddr, &edata, sizeof(edata)))
-		return -EFAULT;
-	return 0;
-}
-
-static int ethtool_set_gro(struct net_device *dev, char __user *userad=
dr)
-{
-	struct ethtool_value edata;
-
-	if (copy_from_user(&edata, useraddr, sizeof(edata)))
-		return -EFAULT;
-
-	if (edata.data) {
-		u32 rxcsum =3D dev->ethtool_ops->get_rx_csum ?
-				dev->ethtool_ops->get_rx_csum(dev) :
-				ethtool_op_get_rx_csum(dev);
-
-		if (!rxcsum)
-			return -EINVAL;
-		dev->features |=3D NETIF_F_GRO;
-	} else
-		dev->features &=3D ~NETIF_F_GRO;
-
-	return 0;
+	return dev->ethtool_ops->set_ufo(dev, data);
 }
=20
 static int ethtool_self_test(struct net_device *dev, char __user *user=
addr)
@@ -1629,33 +1627,6 @@ int dev_ethtool(struct net *net, struct ifreq *i=
fr)
 	case ETHTOOL_SRXCSUM:
 		rc =3D ethtool_set_rx_csum(dev, useraddr);
 		break;
-	case ETHTOOL_GTXCSUM:
-		rc =3D ethtool_get_value(dev, useraddr, ethcmd,
-				       (dev->ethtool_ops->get_tx_csum ?
-					dev->ethtool_ops->get_tx_csum :
-					ethtool_op_get_tx_csum));
-		break;
-	case ETHTOOL_STXCSUM:
-		rc =3D ethtool_set_tx_csum(dev, useraddr);
-		break;
-	case ETHTOOL_GSG:
-		rc =3D ethtool_get_value(dev, useraddr, ethcmd,
-				       (dev->ethtool_ops->get_sg ?
-					dev->ethtool_ops->get_sg :
-					ethtool_op_get_sg));
-		break;
-	case ETHTOOL_SSG:
-		rc =3D ethtool_set_sg(dev, useraddr);
-		break;
-	case ETHTOOL_GTSO:
-		rc =3D ethtool_get_value(dev, useraddr, ethcmd,
-				       (dev->ethtool_ops->get_tso ?
-					dev->ethtool_ops->get_tso :
-					ethtool_op_get_tso));
-		break;
-	case ETHTOOL_STSO:
-		rc =3D ethtool_set_tso(dev, useraddr);
-		break;
 	case ETHTOOL_TEST:
 		rc =3D ethtool_self_test(dev, useraddr);
 		break;
@@ -1671,21 +1642,6 @@ int dev_ethtool(struct net *net, struct ifreq *i=
fr)
 	case ETHTOOL_GPERMADDR:
 		rc =3D ethtool_get_perm_addr(dev, useraddr);
 		break;
-	case ETHTOOL_GUFO:
-		rc =3D ethtool_get_value(dev, useraddr, ethcmd,
-				       (dev->ethtool_ops->get_ufo ?
-					dev->ethtool_ops->get_ufo :
-					ethtool_op_get_ufo));
-		break;
-	case ETHTOOL_SUFO:
-		rc =3D ethtool_set_ufo(dev, useraddr);
-		break;
-	case ETHTOOL_GGSO:
-		rc =3D ethtool_get_gso(dev, useraddr);
-		break;
-	case ETHTOOL_SGSO:
-		rc =3D ethtool_set_gso(dev, useraddr);
-		break;
 	case ETHTOOL_GFLAGS:
 		rc =3D ethtool_get_value(dev, useraddr, ethcmd,
 				       (dev->ethtool_ops->get_flags ?
@@ -1716,12 +1672,6 @@ int dev_ethtool(struct net *net, struct ifreq *i=
fr)
 	case ETHTOOL_SRXCLSRLINS:
 		rc =3D ethtool_set_rxnfc(dev, ethcmd, useraddr);
 		break;
-	case ETHTOOL_GGRO:
-		rc =3D ethtool_get_gro(dev, useraddr);
-		break;
-	case ETHTOOL_SGRO:
-		rc =3D ethtool_set_gro(dev, useraddr);
-		break;
 	case ETHTOOL_FLASHDEV:
 		rc =3D ethtool_flash_device(dev, useraddr);
 		break;
@@ -1749,6 +1699,22 @@ int dev_ethtool(struct net *net, struct ifreq *i=
fr)
 	case ETHTOOL_SFEATURES:
 		rc =3D ethtool_set_features(dev, useraddr);
 		break;
+	case ETHTOOL_GTXCSUM:
+	case ETHTOOL_GSG:
+	case ETHTOOL_GTSO:
+	case ETHTOOL_GUFO:
+	case ETHTOOL_GGSO:
+	case ETHTOOL_GGRO:
+		rc =3D ethtool_get_one_feature(dev, useraddr, ethcmd);
+		break;
+	case ETHTOOL_STXCSUM:
+	case ETHTOOL_SSG:
+	case ETHTOOL_STSO:
+	case ETHTOOL_SUFO:
+	case ETHTOOL_SGSO:
+	case ETHTOOL_SGRO:
+		rc =3D ethtool_set_one_feature(dev, useraddr, ethcmd);
+		break;
 	default:
 		rc =3D -EOPNOTSUPP;
 	}
--=20
1.7.2.3

