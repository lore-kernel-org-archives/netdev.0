From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [RFC PATCH 05/12] net: ethtool: use ndo_fix_features for ethtool_ops->set_flags
Date: Wed, 15 Dec 2010 23:24:29 +0100 (CET)
Message-ID: <2931acc52fc3ffcc188114fa9d744e1224b72718.1292451560.git.mirq-linux@rere.qmqm.pl>
References: <cover.1292451559.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:53552 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752192Ab0LOWYb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Dec 2010 17:24:31 -0500
In-Reply-To: <cover.1292451559.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 net/core/ethtool.c |   22 ++++++++++++++++++++--
 1 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 15e00b8..2f532d5 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -215,6 +215,25 @@ static int ethtool_set_features(struct net_device =
*dev, void __user *useraddr)
 	return 0;
 }
=20
+static int __ethtool_set_flags(struct net_device *dev, u32 data)
+{
+	if (data & ~flags_dup_features)
+		return -EINVAL;
+
+	if (!(dev->hw_features & flags_dup_features)) {
+		if (!dev->ethtool_ops->set_flags)
+			return -EOPNOTSUPP;
+		return dev->ethtool_ops->set_flags(dev, data);
+	}
+
+	dev->wanted_features =3D
+		(dev->wanted_features & ~flags_dup_features) | data;
+
+	netdev_update_features(dev);
+
+	return 0;
+}
+
 static unsigned long ethtool_get_feature_mask(u32 eth_cmd)
 {
 	switch (eth_cmd) {
@@ -1635,8 +1654,7 @@ int dev_ethtool(struct net *net, struct ifreq *if=
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

