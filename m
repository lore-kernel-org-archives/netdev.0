From: =?utf-8?q?Micha=C5=82?= =?utf-8?b?TWlyb3PFgmF3?=
	<mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: Move check of checksum features to netdev_fix_features()
Date: Tue, 30 Nov 2010 15:23:52 +0100
Message-ID: <20101130142352.3936.9503.stgit@rechot.qmqm.pl>
References: <fddashfjkasdhklfjashlkjfs@rechot.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Jesse Gross <jesse@nicira.com>
To: netdev@vget.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:59712 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752174Ab0K3OxX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Nov 2010 09:53:23 -0500
In-Reply-To: <fddashfjkasdhklfjashlkjfs@rechot.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>

diff --git a/net/core/dev.c b/net/core/dev.c
index 622f85a..c64a848 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5023,6 +5023,23 @@ static void rollback_registered(struct net_devic=
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
@@ -5206,21 +5223,6 @@ int register_netdevice(struct net_device *dev)
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
