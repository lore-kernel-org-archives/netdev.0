From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [RFC PATCH 01/12] net: Move check of checksum features to netdev_fix_features()
Date: Wed, 15 Dec 2010 23:24:29 +0100 (CET)
Message-ID: <35b79fea5227b5bb1bb734b0188b7ef43cfc9dd6.1292451559.git.mirq-linux@rere.qmqm.pl>
References: <cover.1292451559.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:53548 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751834Ab0LOWYa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Dec 2010 17:24:30 -0500
In-Reply-To: <cover.1292451559.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 net/core/dev.c |   32 +++++++++++++++++---------------
 1 files changed, 17 insertions(+), 15 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index f937726..6823275 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5020,6 +5020,23 @@ static void rollback_registered(struct net_devic=
e *dev)
=20
 unsigned long netdev_fix_features(unsigned long features, const char *=
name)
 {
+	/* Fix illegal checksum combinations */
+	if ((features & NETIF_F_HW_CSUM) &&
+	    (features & (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM))) {
+		if (name)
+			printk(KERN_NOTICE "%s: mixed HW and IP checksum settings.\n",
+				name);
+		features &=3D ~(NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM);
+	}
+
+	if ((features & NETIF_F_NO_CSUM) &&
+	    (features & (NETIF_F_HW_CSUM|NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM)))=
 {
+		if (name)
+			printk(KERN_NOTICE "%s: mixed no checksumming and other settings.\n=
",
+				name);
+		features &=3D ~(NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM|NETIF_F_HW_CSUM);
+	}
+
 	/* Fix illegal SG+CSUM combinations. */
 	if ((features & NETIF_F_SG) &&
 	    !(features & NETIF_F_ALL_CSUM)) {
@@ -5195,21 +5212,6 @@ int register_netdevice(struct net_device *dev)
 	if (dev->iflink =3D=3D -1)
 		dev->iflink =3D dev->ifindex;
=20
-	/* Fix illegal checksum combinations */
-	if ((dev->features & NETIF_F_HW_CSUM) &&
-	    (dev->features & (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM))) {
-		printk(KERN_NOTICE "%s: mixed HW and IP checksum settings.\n",
-		       dev->name);
-		dev->features &=3D ~(NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM);
-	}
-
-	if ((dev->features & NETIF_F_NO_CSUM) &&
-	    (dev->features & (NETIF_F_HW_CSUM|NETIF_F_IP_CSUM|NETIF_F_IPV6_CS=
UM))) {
-		printk(KERN_NOTICE "%s: mixed no checksumming and other settings.\n"=
,
-		       dev->name);
-		dev->features &=3D ~(NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM|NETIF_F_HW_CS=
UM);
-	}
-
 	dev->features =3D netdev_fix_features(dev->features, dev->name);
=20
 	/* Enable software GSO if SG is supported. */
--=20
1.7.2.3

