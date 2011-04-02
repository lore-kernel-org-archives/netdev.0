From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: Call netdev_features_change() from netdev_update_features()
Date: Sat,  2 Apr 2011 16:41:40 +0200 (CEST)
Message-ID: <20110402144141.0192613909@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jesse Gross <jesse@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:57629 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751412Ab1DBOlm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Apr 2011 10:41:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Issue FEAT_CHANGE notification when features are changed by
netdev_update_features().  This will allow changes made by extra constr=
aints
on e.g. MTU change to be properly propagated like changes via ethtool.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 include/linux/netdevice.h |    1 +
 net/core/dev.c            |   23 +++++++++++++++++------
 net/core/ethtool.c        |    6 +++---
 3 files changed, 21 insertions(+), 9 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 0249fe7..a4664cc 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2550,6 +2550,7 @@ static inline u32 netdev_get_wanted_features(stru=
ct net_device *dev)
 }
 u32 netdev_increment_features(u32 all, u32 one, u32 mask);
 u32 netdev_fix_features(struct net_device *dev, u32 features);
+int __netdev_update_features(struct net_device *dev);
 void netdev_update_features(struct net_device *dev);
=20
 void netif_stacked_transfer_operstate(const struct net_device *rootdev=
,
diff --git a/net/core/dev.c b/net/core/dev.c
index 3da9fb0..02f5637 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5236,7 +5236,7 @@ u32 netdev_fix_features(struct net_device *dev, u=
32 features)
 }
 EXPORT_SYMBOL(netdev_fix_features);
=20
-void netdev_update_features(struct net_device *dev)
+int __netdev_update_features(struct net_device *dev)
 {
 	u32 features;
 	int err =3D 0;
@@ -5250,7 +5250,7 @@ void netdev_update_features(struct net_device *de=
v)
 	features =3D netdev_fix_features(dev, features);
=20
 	if (dev->features =3D=3D features)
-		return;
+		return 0;
=20
 	netdev_info(dev, "Features changed: 0x%08x -> 0x%08x\n",
 		dev->features, features);
@@ -5258,12 +5258,23 @@ void netdev_update_features(struct net_device *=
dev)
 	if (dev->netdev_ops->ndo_set_features)
 		err =3D dev->netdev_ops->ndo_set_features(dev, features);
=20
-	if (!err)
-		dev->features =3D features;
-	else if (err < 0)
+	if (unlikely(err < 0)) {
 		netdev_err(dev,
 			"set_features() failed (%d); wanted 0x%08x, left 0x%08x\n",
 			err, features, dev->features);
+		return -1;
+	}
+
+	if (!err)
+		dev->features =3D features;
+
+	return 1;
+}
+
+void netdev_update_features(struct net_device *dev)
+{
+	if (__netdev_update_features(dev))
+		netdev_features_change(dev);
 }
 EXPORT_SYMBOL(netdev_update_features);
=20
@@ -5430,7 +5441,7 @@ int register_netdevice(struct net_device *dev)
 		goto err_uninit;
 	dev->reg_state =3D NETREG_REGISTERED;
=20
-	netdev_update_features(dev);
+	__netdev_update_features(dev);
=20
 	/*
 	 *	Default initial state at registry is that the
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 74ead9e..439e4b0 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -317,7 +317,7 @@ static int ethtool_set_features(struct net_device *=
dev, void __user *useraddr)
=20
 	dev->wanted_features &=3D ~features[0].valid;
 	dev->wanted_features |=3D features[0].valid & features[0].requested;
-	netdev_update_features(dev);
+	__netdev_update_features(dev);
=20
 	if ((dev->wanted_features ^ dev->features) & features[0].valid)
 		ret |=3D ETHTOOL_F_WISH;
@@ -499,7 +499,7 @@ static int ethtool_set_one_feature(struct net_devic=
e *dev,
 		else
 			dev->wanted_features &=3D ~mask;
=20
-		netdev_update_features(dev);
+		__netdev_update_features(dev);
 		return 0;
 	}
=20
@@ -551,7 +551,7 @@ int __ethtool_set_flags(struct net_device *dev, u32=
 data)
 	dev->wanted_features =3D
 		(dev->wanted_features & ~changed) | data;
=20
-	netdev_update_features(dev);
+	__netdev_update_features(dev);
=20
 	return 0;
 }
--=20
1.7.2.5

