From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v2 05/16] net: ethtool: use ndo_fix_features for offload setting
Date: Sat, 22 Jan 2011 23:14:13 +0100 (CET)
Message-ID: <b21a5ae73c0c779ae4d7106b09a83c9726b14eb3.1295734271.git.mirq-linux@rere.qmqm.pl>
References: <cover.1295734270.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:43060 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752714Ab1AVWOQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Jan 2011 17:14:16 -0500
In-Reply-To: <cover.1295734270.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 net/core/ethtool.c |  262 ++++++++++++++++++++++++--------------------=
--------
 1 files changed, 119 insertions(+), 143 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 0e4ec64..621f004 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -240,6 +240,96 @@ static int ethtool_set_features(struct net_device =
*dev, void __user *useraddr)
 	return ret;
 }
=20
+static u32 ethtool_get_feature_mask(u32 eth_cmd)
+{
+	/* feature masks of legacy discrete ethtool ops */
+
+	switch (eth_cmd) {
+	case ETHTOOL_GTXCSUM:
+	case ETHTOOL_STXCSUM:
+		return NETIF_F_ALL_CSUM | NETIF_F_SCTP_CSUM;
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
+	u32 mask;
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
+	/* Driver is not converted to ndo_fix_features or does not
+	 * support changing this offload. In the latter case it won't
+	 * have corresponding ethtool_ops field set.
+	 *
+	 * Following part is to be removed after all drivers advertise
+	 * their changeable features in netdev->hw_features and stop
+	 * using discrete offload setting ops.
+	 */
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
 static const char netdev_features_strings[ETHTOOL_DEV_FEATURE_WORDS * =
32][ETH_GSTRING_LEN] =3D {
 	/* NETIF_F_SG */              "scatter-gather",
 	/* NETIF_F_IP_CSUM */         "tx-checksum-hw-ipv4",
@@ -1218,6 +1308,9 @@ static int __ethtool_set_sg(struct net_device *de=
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
@@ -1232,26 +1325,21 @@ static int __ethtool_set_sg(struct net_device *=
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
@@ -1269,108 +1357,28 @@ static int ethtool_set_rx_csum(struct net_devi=
ce *dev, char __user *useraddr)
 	return dev->ethtool_ops->set_rx_csum(dev, edata.data);
 }
=20
-static int ethtool_set_sg(struct net_device *dev, char __user *useradd=
r)
+static int __ethtool_set_tso(struct net_device *dev, u32 data)
 {
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
-{
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
@@ -1703,33 +1711,6 @@ int dev_ethtool(struct net *net, struct ifreq *i=
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
@@ -1745,21 +1726,6 @@ int dev_ethtool(struct net *net, struct ifreq *i=
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
@@ -1790,12 +1756,6 @@ int dev_ethtool(struct net *net, struct ifreq *i=
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
@@ -1823,6 +1783,22 @@ int dev_ethtool(struct net *net, struct ifreq *i=
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

