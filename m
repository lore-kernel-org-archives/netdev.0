From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v5 RESEND 6/9] net: ethtool: use ndo_fix_features for offload setting
Date: Sun, 13 Feb 2011 12:11:45 +0100 (CET)
Message-ID: <7fa77be53413ba76e26c92691bd2c7ca6f45005c.1297594674.git.mirq-linux@rere.qmqm.pl>
References: <cover.1297594674.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:50511 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754146Ab1BMLLt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Feb 2011 06:11:49 -0500
In-Reply-To: <cover.1297594674.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 net/core/ethtool.c |   45 ++++++++++++++++++++++++++++++++------------=
-
 1 files changed, 32 insertions(+), 13 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 9577396..6599997 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -357,15 +357,21 @@ static void *__ethtool_get_one_feature_actor(stru=
ct net_device *dev, u32 ethcmd)
 static int ethtool_get_one_feature(struct net_device *dev,
 	char __user *useraddr, u32 ethcmd)
 {
+	u32 mask =3D ethtool_get_feature_mask(ethcmd);
 	struct ethtool_value edata =3D {
 		.cmd =3D ethcmd,
-		.data =3D !!(dev->features & ethtool_get_feature_mask(ethcmd)),
+		.data =3D !!(dev->features & mask),
 	};
-	u32 (*actor)(struct net_device *);
=20
-	actor =3D __ethtool_get_one_feature_actor(dev, ethcmd);
-	if (actor)
-		edata.data =3D actor(dev);
+	/* compatibility with discrete get_ ops */
+	if (!(dev->hw_features & mask)) {
+		u32 (*actor)(struct net_device *);
+
+		actor =3D __ethtool_get_one_feature_actor(dev, ethcmd);
+
+		if (actor)
+			edata.data =3D actor(dev);
+	}
=20
 	if (copy_to_user(useraddr, &edata, sizeof(edata)))
 		return -EFAULT;
@@ -386,6 +392,27 @@ static int ethtool_set_one_feature(struct net_devi=
ce *dev,
 	if (copy_from_user(&edata, useraddr, sizeof(edata)))
 		return -EFAULT;
=20
+	mask =3D ethtool_get_feature_mask(ethcmd);
+	mask &=3D dev->hw_features;
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
 	switch (ethcmd) {
 	case ETHTOOL_STXCSUM:
 		return __ethtool_set_tx_csum(dev, edata.data);
@@ -395,14 +422,6 @@ static int ethtool_set_one_feature(struct net_devi=
ce *dev,
 		return __ethtool_set_tso(dev, edata.data);
 	case ETHTOOL_SUFO:
 		return __ethtool_set_ufo(dev, edata.data);
-	case ETHTOOL_SGSO:
-	case ETHTOOL_SGRO:
-		mask =3D ethtool_get_feature_mask(ethcmd);
-		if (edata.data)
-			dev->features |=3D mask;
-		else
-			dev->features &=3D ~mask;
-		return 0;
 	default:
 		return -EOPNOTSUPP;
 	}
--=20
1.7.2.3

