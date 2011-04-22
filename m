From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: fix netdev_increment_features()
Date: Fri, 22 Apr 2011 18:31:16 +0200 (CEST)
Message-ID: <20110422163116.3C5C3138DD@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	bridge@lists.linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:53186 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756132Ab1DVQbR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2011 12:31:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simplify and fix netdev_increment_features() to conform to what is
stated in netdevice.h comments about NETIF_F_ONE_FOR_ALL.
Include FCoE segmentation and VLAN-challedged flags in computation.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---

I noticed this while converting bridge code to hw_features. After
adding devices to the bridge all features were always cleared regardles=
s
of features active in those devices.

 include/linux/netdevice.h |    7 ++++++-
 net/core/dev.c            |   37 ++++++++++++-------------------------
 2 files changed, 18 insertions(+), 26 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 405ce21..86140e4 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1107,7 +1107,12 @@ struct net_device {
 	 */
 #define NETIF_F_ONE_FOR_ALL	(NETIF_F_GSO_SOFTWARE | NETIF_F_GSO_ROBUST=
 | \
 				 NETIF_F_SG | NETIF_F_HIGHDMA |		\
-				 NETIF_F_FRAGLIST)
+				 NETIF_F_FRAGLIST | NETIF_F_VLAN_CHALLENGED)
+	/*
+	 * If one device doesn't support one of these features, then disable =
it
+	 * for all in netdev_increment_features.
+	 */
+#define NETIF_F_ALL_FOR_ALL	(NETIF_F_NOCACHE_COPY | NETIF_F_FSO)
=20
 	/* changeable features with no special hardware requirements */
 #define NETIF_F_SOFT_FEATURES	(NETIF_F_GSO | NETIF_F_GRO)
diff --git a/net/core/dev.c b/net/core/dev.c
index 3871bf6..1a2c91c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6184,33 +6184,20 @@ static int dev_cpu_callback(struct notifier_blo=
ck *nfb,
  */
 u32 netdev_increment_features(u32 all, u32 one, u32 mask)
 {
+	if (mask & NETIF_F_GEN_CSUM)
+		mask |=3D NETIF_F_ALL_CSUM;
+	mask |=3D NETIF_F_VLAN_CHALLENGED;
+
+	all |=3D one & (NETIF_F_ONE_FOR_ALL|NETIF_F_ALL_CSUM) & mask;
+	all &=3D one | ~NETIF_F_ALL_FOR_ALL;
+
 	/* If device needs checksumming, downgrade to it. */
-	if (all & NETIF_F_NO_CSUM && !(one & NETIF_F_NO_CSUM))
-		all ^=3D NETIF_F_NO_CSUM | (one & NETIF_F_ALL_CSUM);
-	else if (mask & NETIF_F_ALL_CSUM) {
-		/* If one device supports v4/v6 checksumming, set for all. */
-		if (one & (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM) &&
-		    !(all & NETIF_F_GEN_CSUM)) {
-			all &=3D ~NETIF_F_ALL_CSUM;
-			all |=3D one & (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);
-		}
+	if (all & (NETIF_F_ALL_CSUM & ~NETIF_F_NO_CSUM))
+		all &=3D ~NETIF_F_NO_CSUM;
=20
-		/* If one device supports hw checksumming, set for all. */
-		if (one & NETIF_F_GEN_CSUM && !(all & NETIF_F_GEN_CSUM)) {
-			all &=3D ~NETIF_F_ALL_CSUM;
-			all |=3D NETIF_F_HW_CSUM;
-		}
-	}
-
-	/* If device can't no cache copy, don't do for all */
-	if (!(one & NETIF_F_NOCACHE_COPY))
-		all &=3D ~NETIF_F_NOCACHE_COPY;
-
-	one |=3D NETIF_F_ALL_CSUM;
-
-	one |=3D all & NETIF_F_ONE_FOR_ALL;
-	all &=3D one | NETIF_F_LLTX | NETIF_F_GSO | NETIF_F_UFO;
-	all |=3D one & mask & NETIF_F_ONE_FOR_ALL;
+	/* If one device supports hw checksumming, set for all. */
+	if (all & NETIF_F_GEN_CSUM)
+		all &=3D ~(NETIF_F_ALL_CSUM & ~NETIF_F_GEN_CSUM);
=20
 	return all;
 }
--=20
1.7.2.5

