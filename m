From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: implement dev_disable_lro() hw_features compatibility
Date: Fri, 18 Mar 2011 18:42:13 +0100 (CET)
Message-ID: <37d3c96bc52c87fcd4cdd39c9c852b1d2bbc249d.1300466356.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:52073 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757231Ab1CRRmP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Mar 2011 13:42:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement compatibility with new hw_features for dev_disable_lro().
This is a transition path - dev_disable_lro() should be later
integrated into netdev_fix_features() after all drivers are converted.

There's no point in exporting __ethtool_set_flags() as it and dev_disab=
le_lro()
are always built-in.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---

Patch is build-tested only, as I don't have any LRO-capable hardware.
It might be prettier to move dev_disable_lro() to ethtool.c.

 net/core/dev.c     |   20 ++++++++++++--------
 net/core/ethtool.c |    2 +-
 2 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 0b88eba..105e082 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1353,14 +1353,18 @@ EXPORT_SYMBOL(dev_close);
  */
 void dev_disable_lro(struct net_device *dev)
 {
-	if (dev->ethtool_ops && dev->ethtool_ops->get_flags &&
-	    dev->ethtool_ops->set_flags) {
-		u32 flags =3D dev->ethtool_ops->get_flags(dev);
-		if (flags & ETH_FLAG_LRO) {
-			flags &=3D ~ETH_FLAG_LRO;
-			dev->ethtool_ops->set_flags(dev, flags);
-		}
-	}
+	extern int __ethtool_set_flags(struct net_device *, u32);
+	u32 flags;
+
+	if (dev->ethtool_ops && dev->ethtool_ops->get_flags)
+		flags =3D dev->ethtool_ops->get_flags(dev);
+	else
+		flags =3D ethtool_op_get_flags(dev);
+
+	if (!(flags & ETH_FLAG_LRO))
+		return;
+
+	__ethtool_set_flags(dev, flags & ~ETH_FLAG_LRO);
 	WARN_ON(dev->features & NETIF_F_LRO);
 }
 EXPORT_SYMBOL(dev_disable_lro);
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index c1a71bb..7371177 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -513,7 +513,7 @@ static int ethtool_set_one_feature(struct net_devic=
e *dev,
 	}
 }
=20
-static int __ethtool_set_flags(struct net_device *dev, u32 data)
+int __ethtool_set_flags(struct net_device *dev, u32 data)
 {
 	u32 changed;
=20
--=20
1.7.2.3

