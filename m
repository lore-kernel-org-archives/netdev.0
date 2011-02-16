From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v6 2/9] ethtool: enable GSO and GRO by default
Date: Wed, 16 Feb 2011 03:59:16 +0100 (CET)
Message-ID: <d256f661690245d75bec50f5a6acafcefcae1d8a.1297824704.git.mirq-linux@rere.qmqm.pl>
References: <cover.1297824704.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:57721 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756496Ab1BPC7S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Feb 2011 21:59:18 -0500
In-Reply-To: <cover.1297824704.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 include/linux/netdevice.h |    3 +++
 net/core/dev.c            |   18 ++++++++++++++----
 2 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d08ef65..168e3ad 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -984,6 +984,9 @@ struct net_device {
 				 NETIF_F_SG | NETIF_F_HIGHDMA |		\
 				 NETIF_F_FRAGLIST)
=20
+	/* changeable features with no special hardware requirements */
+#define NETIF_F_SOFT_FEATURES	(NETIF_F_GSO | NETIF_F_GRO)
+
 	/* Interface index. Unique device identifier	*/
 	int			ifindex;
 	int			iflink;
diff --git a/net/core/dev.c b/net/core/dev.c
index 4580460..8686f6f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5274,6 +5274,12 @@ u32 netdev_fix_features(struct net_device *dev, =
u32 features)
 		features &=3D ~NETIF_F_TSO;
 	}
=20
+	/* Software GSO depends on SG. */
+	if ((features & NETIF_F_GSO) && !(features & NETIF_F_SG)) {
+		netdev_info(dev, "Dropping NETIF_F_GSO since no SG feature.\n");
+		features &=3D ~NETIF_F_GSO;
+	}
+
 	/* UFO needs SG and checksumming */
 	if (features & NETIF_F_UFO) {
 		/* maybe split UFO into V4 and V6? */
@@ -5430,12 +5436,16 @@ int register_netdevice(struct net_device *dev)
 	if (dev->iflink =3D=3D -1)
 		dev->iflink =3D dev->ifindex;
=20
+	/* Enable software offloads by default - will be stripped in
+	 * netdev_fix_features() if not supported. */
+	dev->features |=3D NETIF_F_SOFT_FEATURES;
+
+	/* Avoid warning from netdev_fix_features() for GSO without SG */
+	if (!(dev->features & NETIF_F_SG))
+		dev->features &=3D ~NETIF_F_GSO;
+
 	dev->features =3D netdev_fix_features(dev, dev->features);
=20
-	/* Enable software GSO if SG is supported. */
-	if (dev->features & NETIF_F_SG)
-		dev->features |=3D NETIF_F_GSO;
-
 	/* Enable GRO and NETIF_F_HIGHDMA for vlans by default,
 	 * vlan_dev_init() will do the dev->features check, so these features
 	 * are enabled only if supported by underlying device.
--=20
1.7.2.3

