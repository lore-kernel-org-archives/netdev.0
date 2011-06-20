From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [RFT PATCH 7/9] ethtool: prepare for larger netdev_features_t type
Date: Mon, 20 Jun 2011 21:14:55 +0200 (CEST)
Message-ID: <852a74b9068b3be7413a65023f6096f142dfd805.1308596963.git.mirq-linux@rere.qmqm.pl>
References: <cover.1308596962.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:41921 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753815Ab1FTTPA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jun 2011 15:15:00 -0400
In-Reply-To: <cover.1308596962.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 net/core/ethtool.c |   45 +++++++++++++++++++++++++++++---------------=
-
 1 files changed, 29 insertions(+), 16 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 97bbf25..3a93932 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -38,7 +38,7 @@ EXPORT_SYMBOL(ethtool_op_get_link);
=20
 /* Handlers for each ethtool command */
=20
-#define ETHTOOL_DEV_FEATURE_WORDS	1
+#define ETHTOOL_DEV_FEATURE_WORDS	((NETDEV_FEATURE_COUNT + 31) / 32)
=20
 static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GS=
TRING_LEN] =3D {
 	[NETIF_F_SG_BIT] =3D               "tx-scatter-gather",
@@ -82,16 +82,21 @@ static int ethtool_get_features(struct net_device *=
dev, void __user *useraddr)
 		.cmd =3D ETHTOOL_GFEATURES,
 		.size =3D ETHTOOL_DEV_FEATURE_WORDS,
 	};
-	struct ethtool_get_features_block features[ETHTOOL_DEV_FEATURE_WORDS]=
 =3D {
-		{
-			.available =3D dev->hw_features,
-			.requested =3D dev->wanted_features,
-			.active =3D dev->features,
-			.never_changed =3D NETIF_F_NEVER_CHANGE,
-		},
-	};
+	struct ethtool_get_features_block features[ETHTOOL_DEV_FEATURE_WORDS]=
;
 	u32 __user *sizeaddr;
 	u32 copy_size;
+	int i;
+
+	/* in case feature bits run out again */
+	BUILD_BUG_ON(ETHTOOL_DEV_FEATURE_WORDS*sizeof(u32) > sizeof(netdev_fe=
atures_t));
+
+	/* this should get loop-unrolled easily by compiler */
+	for (i =3D 0; i < ETHTOOL_DEV_FEATURE_WORDS; ++i) {
+		features[i].available =3D (u32)(dev->hw_features >> (32*i));
+		features[i].requested =3D (u32)(dev->wanted_features >> (32*i));
+		features[i].active =3D (u32)(dev->features >> (32*i));
+		features[i].never_changed =3D (u32)(NETIF_F_NEVER_CHANGE >> (32*i));
+	}
=20
 	sizeaddr =3D useraddr + offsetof(struct ethtool_gfeatures, size);
 	if (get_user(copy_size, sizeaddr))
@@ -113,7 +118,8 @@ static int ethtool_set_features(struct net_device *=
dev, void __user *useraddr)
 {
 	struct ethtool_sfeatures cmd;
 	struct ethtool_set_features_block features[ETHTOOL_DEV_FEATURE_WORDS]=
;
-	int ret =3D 0;
+	netdev_features_t wanted =3D 0, valid =3D 0;
+	int i, ret =3D 0;
=20
 	if (copy_from_user(&cmd, useraddr, sizeof(cmd)))
 		return -EFAULT;
@@ -125,19 +131,26 @@ static int ethtool_set_features(struct net_device=
 *dev, void __user *useraddr)
 	if (copy_from_user(features, useraddr, sizeof(features)))
 		return -EFAULT;
=20
-	if (features[0].valid & ~NETIF_F_ETHTOOL_BITS)
+	/* I wonder if the compiler will be smart enough to loop-unroll
+	 * and optimize this... (no worries if not) --mq */
+	for (i =3D ETHTOOL_DEV_FEATURE_WORDS; i-- > 0; ) {
+		valid =3D (valid << 32)|features[i].valid;
+		wanted =3D (wanted << 32)|features[i].requested;
+	}
+
+	if (valid & ~NETIF_F_ETHTOOL_BITS)
 		return -EINVAL;
=20
-	if (features[0].valid & ~dev->hw_features) {
-		features[0].valid &=3D dev->hw_features;
+	if (valid & ~dev->hw_features) {
+		valid &=3D dev->hw_features;
 		ret |=3D ETHTOOL_F_UNSUPPORTED;
 	}
=20
-	dev->wanted_features &=3D ~features[0].valid;
-	dev->wanted_features |=3D features[0].valid & features[0].requested;
+	dev->wanted_features &=3D ~valid;
+	dev->wanted_features |=3D wanted & valid;
 	__netdev_update_features(dev);
=20
-	if ((dev->wanted_features ^ dev->features) & features[0].valid)
+	if ((dev->wanted_features ^ dev->features) & valid)
 		ret |=3D ETHTOOL_F_WISH;
=20
 	return ret;
--=20
1.7.2.5

