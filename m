From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v2] net: implement dev_disable_lro() hw_features compatibility
Date: Sat, 19 Mar 2011 03:56:34 +0100 (CET)
Message-ID: <32d98168b9b4ae553cc3647c30da85be05a28c95.1300503092.git.mirq-linux@rere.qmqm.pl>
References: <1300471986.2589.26.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:46597 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755534Ab1CSC4g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Mar 2011 22:56:36 -0400
In-Reply-To: <1300471986.2589.26.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement compatibility with new hw_features for dev_disable_lro().
This is a transition path - dev_disable_lro() should be later
integrated into netdev_fix_features() after all drivers are converted.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---

Changes from v1:
 - moved __ethtool_set_flags() prototype to ethtool.h

 include/linux/ethtool.h |    3 +++
 net/core/dev.c          |   19 +++++++++++--------
 net/core/ethtool.c      |    2 +-
 3 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index aac3e2e..c9bfe2d 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -614,6 +614,9 @@ enum ethtool_sfeatures_retval_bits {
=20
 #include <linux/rculist.h>
=20
+/* needed by dev_disable_lro() */
+extern int __ethtool_set_flags(struct net_device *dev, u32 flags);
+
 struct ethtool_rx_ntuple_flow_spec_container {
 	struct ethtool_rx_ntuple_flow_spec fs;
 	struct list_head list;
diff --git a/net/core/dev.c b/net/core/dev.c
index 0b88eba..f453370 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1353,14 +1353,17 @@ EXPORT_SYMBOL(dev_close);
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

