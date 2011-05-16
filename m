From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: Change netdev_fix_features messages loglevel
Date: Mon, 16 May 2011 15:17:57 +0200 (CEST)
Message-ID: <20110516131757.ED57E13A6A@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:35323 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753829Ab1EPNR7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 May 2011 09:17:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Those reduced to DEBUG can possibly be triggered by unprivileged proces=
ses
and are nothing exceptional. Illegal checksum combinations can only be
caused by driver bug, so promote those messages to WARN.

Since GSO without SG will now only cause DEBUG message from
netdev_fix_features(), remove the workaround from register_netdevice().

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---

This is for net tree, not net-next.

 net/core/dev.c |   22 ++++++++--------------
 1 files changed, 8 insertions(+), 14 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 9200944..b624fe4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5186,27 +5186,27 @@ u32 netdev_fix_features(struct net_device *dev,=
 u32 features)
 	/* Fix illegal checksum combinations */
 	if ((features & NETIF_F_HW_CSUM) &&
 	    (features & (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM))) {
-		netdev_info(dev, "mixed HW and IP checksum settings.\n");
+		netdev_warn(dev, "mixed HW and IP checksum settings.\n");
 		features &=3D ~(NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM);
 	}
=20
 	if ((features & NETIF_F_NO_CSUM) &&
 	    (features & (NETIF_F_HW_CSUM|NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM)))=
 {
-		netdev_info(dev, "mixed no checksumming and other settings.\n");
+		netdev_warn(dev, "mixed no checksumming and other settings.\n");
 		features &=3D ~(NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM|NETIF_F_HW_CSUM);
 	}
=20
 	/* Fix illegal SG+CSUM combinations. */
 	if ((features & NETIF_F_SG) &&
 	    !(features & NETIF_F_ALL_CSUM)) {
-		netdev_info(dev,
-			    "Dropping NETIF_F_SG since no checksum feature.\n");
+		netdev_dbg(dev,
+			"Dropping NETIF_F_SG since no checksum feature.\n");
 		features &=3D ~NETIF_F_SG;
 	}
=20
 	/* TSO requires that SG is present as well. */
 	if ((features & NETIF_F_ALL_TSO) && !(features & NETIF_F_SG)) {
-		netdev_info(dev, "Dropping TSO features since no SG feature.\n");
+		netdev_dbg(dev, "Dropping TSO features since no SG feature.\n");
 		features &=3D ~NETIF_F_ALL_TSO;
 	}
=20
@@ -5216,7 +5216,7 @@ u32 netdev_fix_features(struct net_device *dev, u=
32 features)
=20
 	/* Software GSO depends on SG. */
 	if ((features & NETIF_F_GSO) && !(features & NETIF_F_SG)) {
-		netdev_info(dev, "Dropping NETIF_F_GSO since no SG feature.\n");
+		netdev_dbg(dev, "Dropping NETIF_F_GSO since no SG feature.\n");
 		features &=3D ~NETIF_F_GSO;
 	}
=20
@@ -5226,13 +5226,13 @@ u32 netdev_fix_features(struct net_device *dev,=
 u32 features)
 		if (!((features & NETIF_F_GEN_CSUM) ||
 		    (features & (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM))
 			    =3D=3D (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM))) {
-			netdev_info(dev,
+			netdev_dbg(dev,
 				"Dropping NETIF_F_UFO since no checksum offload features.\n");
 			features &=3D ~NETIF_F_UFO;
 		}
=20
 		if (!(features & NETIF_F_SG)) {
-			netdev_info(dev,
+			netdev_dbg(dev,
 				"Dropping NETIF_F_UFO since no NETIF_F_SG feature.\n");
 			features &=3D ~NETIF_F_UFO;
 		}
@@ -5414,12 +5414,6 @@ int register_netdevice(struct net_device *dev)
 	dev->features |=3D NETIF_F_SOFT_FEATURES;
 	dev->wanted_features =3D dev->features & dev->hw_features;
=20
-	/* Avoid warning from netdev_fix_features() for GSO without SG */
-	if (!(dev->wanted_features & NETIF_F_SG)) {
-		dev->wanted_features &=3D ~NETIF_F_GSO;
-		dev->features &=3D ~NETIF_F_GSO;
-	}
-
 	/* Enable GRO and NETIF_F_HIGHDMA for vlans by default,
 	 * vlan_dev_init() will do the dev->features check, so these features
 	 * are enabled only if supported by underlying device.

