From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [RFT PATCH 9/9] net: move NOCACHE_COPY checks to netdev_fix_features()
Date: Mon, 20 Jun 2011 21:14:55 +0200 (CEST)
Message-ID: <55250cb000ce8cb00f01f1e3e6a8791fe9c3081e.1308596963.git.mirq-linux@rere.qmqm.pl>
References: <cover.1308596962.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:41920 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753966Ab1FTTPA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jun 2011 15:15:00 -0400
In-Reply-To: <cover.1308596962.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 include/linux/netdev_features.h |    3 ++-
 net/core/dev.c                  |   21 +++++++++++++--------
 2 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_fea=
tures.h
index 86d6193..9f24781 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -146,6 +146,7 @@ enum {
 #define NETIF_F_ALL_FOR_ALL	(NETIF_F_NOCACHE_COPY | NETIF_F_FSO)
=20
 	/* changeable features with no special hardware requirements */
-#define NETIF_F_SOFT_FEATURES	(NETIF_F_GSO | NETIF_F_GRO)
+#define NETIF_F_SOFT_FEATURES	(NETIF_F_GSO | NETIF_F_GRO | \
+				 NETIF_F_NOCACHE_COPY)
=20
 #endif	/* _LINUX_NETDEV_FEATURES_H */
diff --git a/net/core/dev.c b/net/core/dev.c
index 7e58353..30782b7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5250,6 +5250,19 @@ static netdev_features_t netdev_fix_features(str=
uct net_device *dev,
 		}
 	}
=20
+	/* No cache copy is a win only with real HW with HW checksumming */
+	if (features & NETIF_F_NOCACHE_COPY) {
+		if (!(features & NETIF_F_ALL_CSUM)) {
+			netdev_dbg(dev,
+				"Dropping NETIF_F_NOCACHE_COPY since it needs HW checksumming.\n")=
;
+			features &=3D ~NETIF_F_NOCACHE_COPY;
+		} else if (features & NETIF_F_NO_CSUM) {
+			netdev_dbg(dev,
+				"Dropping NETIF_F_NOCACHE_COPY for virtual device.\n");
+			features &=3D ~NETIF_F_NOCACHE_COPY;
+		}
+	}
+
 	return features;
 }
=20
@@ -5465,14 +5478,6 @@ int register_netdevice(struct net_device *dev)
 	dev->features |=3D NETIF_F_SOFT_FEATURES;
 	dev->wanted_features =3D dev->features & dev->hw_features;
=20
-	/* Turn on no cache copy if HW is doing checksum */
-	dev->hw_features |=3D NETIF_F_NOCACHE_COPY;
-	if ((dev->features & NETIF_F_ALL_CSUM) &&
-	    !(dev->features & NETIF_F_NO_CSUM)) {
-		dev->wanted_features |=3D NETIF_F_NOCACHE_COPY;
-		dev->features |=3D NETIF_F_NOCACHE_COPY;
-	}
-
 	/* Enable GRO and NETIF_F_HIGHDMA for vlans by default,
 	 * vlan_dev_init() will do the dev->features check, so these features
 	 * are enabled only if supported by underlying device.
--=20
1.7.2.5

