From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v4 3/5] net: use ndo_fix_features for ethtool_ops->set_flags
Date: Thu,  3 Feb 2011 15:21:21 +0100 (CET)
Message-ID: <bbe7e5742ffe44fb2938b7b6c2c656395fc361ac.1296741562.git.mirq-linux@rere.qmqm.pl>
References: <cover.1296741561.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:34558 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932209Ab1BCOVY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Feb 2011 09:21:24 -0500
In-Reply-To: <cover.1296741561.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 net/core/ethtool.c |   31 +++++++++++++++++++++++++++++--
 1 files changed, 29 insertions(+), 2 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 555accf..6e7c6f2 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -240,6 +240,34 @@ static int ethtool_set_features(struct net_device =
*dev, void __user *useraddr)
 	return ret;
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
+		return -EOPNOTSUPP;
+
+	dev->wanted_features =3D
+		(dev->wanted_features & ~changed) | data;
+
+	netdev_update_features(dev);
+
+	return 0;
+}
+
 static u32 ethtool_get_feature_mask(u32 eth_cmd)
 {
 	/* feature masks of legacy discrete ethtool ops */
@@ -1733,8 +1761,7 @@ int dev_ethtool(struct net *net, struct ifreq *if=
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

