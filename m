From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v6 7/9] net: use ndo_fix_features for ethtool_ops->set_flags
Date: Wed, 16 Feb 2011 03:59:18 +0100 (CET)
Message-ID: <3f9175e399c54c6860dd2d7b7ff0b21ecf4a755b.1297824704.git.mirq-linux@rere.qmqm.pl>
References: <cover.1297824704.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:57727 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756558Ab1BPC7T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Feb 2011 21:59:19 -0500
In-Reply-To: <cover.1297824704.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 net/core/ethtool.c |   31 +++++++++++++++++++++++++++++--
 1 files changed, 29 insertions(+), 2 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 6599997..65b3d50 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -427,6 +427,34 @@ static int ethtool_set_one_feature(struct net_devi=
ce *dev,
 	}
 }
=20
+static int __ethtool_set_flags(struct net_device *dev, u32 data)
+{
+	u32 changed;
+
+	if (data & ~flags_dup_features)
+		return -EINVAL;
+
+	/* legacy set_flags() op */
+	if (dev->ethtool_ops->set_flags) {
+		if (unlikely(dev->hw_features & flags_dup_features))
+			netdev_warn(dev,
+				"driver BUG: mixed hw_features and set_flags()\n");
+		return dev->ethtool_ops->set_flags(dev, data);
+	}
+
+	/* allow changing only bits set in hw_features */
+	changed =3D (data ^ dev->wanted_features) & flags_dup_features;
+	if (changed & ~dev->hw_features)
+		return (changed & dev->hw_features) ? -EINVAL : -EOPNOTSUPP;
+
+	dev->wanted_features =3D
+		(dev->wanted_features & ~changed) | data;
+
+	netdev_update_features(dev);
+
+	return 0;
+}
+
 static int ethtool_get_settings(struct net_device *dev, void __user *u=
seraddr)
 {
 	struct ethtool_cmd cmd =3D { .cmd =3D ETHTOOL_GSET };
@@ -1768,8 +1796,7 @@ int dev_ethtool(struct net *net, struct ifreq *if=
r)
 					ethtool_op_get_flags));
 		break;
 	case ETHTOOL_SFLAGS:
-		rc =3D ethtool_set_value(dev, useraddr,
-				       dev->ethtool_ops->set_flags);
+		rc =3D ethtool_set_value(dev, useraddr, __ethtool_set_flags);
 		break;
 	case ETHTOOL_GPFLAGS:
 		rc =3D ethtool_get_value(dev, useraddr, ethcmd,
--=20
1.7.2.3

