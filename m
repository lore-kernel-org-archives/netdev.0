From: David Lamparter <equinox@diac24.net>
Subject: [PATCH 2/2] ipv6: addrconf: clean up device type handling
Date: Thu, 31 Jul 2014 22:53:54 +0200
Message-ID: <1406840034-140848-3-git-send-email-equinox@diac24.net>
References: <20140731201926.GA754314@jupiter.n2.diac24.net>
 <1406840034-140848-1-git-send-email-equinox@diac24.net>
Cc: David Miller <davem@davemloft.net>,
	David Lamparter <equinox@diac24.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:54568 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752961AbaGaUya (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jul 2014 16:54:30 -0400
In-Reply-To: <1406840034-140848-1-git-send-email-equinox@diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This realigns addrconf support for the various lower-layer device types,
and removes a little bit of duplicate code.  Behaviour should be exactly
identical before and after the patch.

(Also adds a comment to explain the weird fe80::/64 on GRE.)

Signed-off-by: David Lamparter <equinox@diac24.net>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/addrconf.c | 87 ++++++++++++++++++++++++-----------------------------
 1 file changed, 39 insertions(+), 48 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 7540a25..aa17ee6 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2756,31 +2756,6 @@ static void addrconf_addr_gen(struct inet6_dev *idev, bool prefix_route)
 	}
 }
 
-static void addrconf_dev_config(struct net_device *dev)
-{
-	struct inet6_dev *idev;
-
-	ASSERT_RTNL();
-
-	if ((dev->type != ARPHRD_ETHER) &&
-	    (dev->type != ARPHRD_FDDI) &&
-	    (dev->type != ARPHRD_ARCNET) &&
-	    (dev->type != ARPHRD_INFINIBAND) &&
-	    (dev->type != ARPHRD_IEEE802154) &&
-	    (dev->type != ARPHRD_IEEE1394) &&
-	    (dev->type != ARPHRD_TUNNEL6) &&
-	    (dev->type != ARPHRD_6LOWPAN)) {
-		/* Alas, we support only Ethernet autoconfiguration. */
-		return;
-	}
-
-	idev = addrconf_add_dev(dev);
-	if (IS_ERR(idev))
-		return;
-
-	addrconf_addr_gen(idev, false);
-}
-
 #if IS_ENABLED(CONFIG_IPV6_SIT)
 static void addrconf_sit_config(struct net_device *dev)
 {
@@ -2811,20 +2786,54 @@ static void addrconf_sit_config(struct net_device *dev)
 }
 #endif
 
-#if IS_ENABLED(CONFIG_NET_IPGRE)
-static void addrconf_gre_config(struct net_device *dev)
+static void addrconf_dev_config(struct net_device *dev)
 {
 	struct inet6_dev *idev;
+	bool prefix_route;
 
 	ASSERT_RTNL();
 
+	switch (dev->type) {
+	case ARPHRD_LOOPBACK:
+		init_loopback(dev);
+		return;
+
+	case ARPHRD_ETHER:
+	case ARPHRD_FDDI:
+	case ARPHRD_ARCNET:
+	case ARPHRD_INFINIBAND:
+	case ARPHRD_IEEE802154:
+	case ARPHRD_IEEE1394:
+	case ARPHRD_TUNNEL6:
+	case ARPHRD_6LOWPAN:
+		prefix_route = false;
+		break;
+
+#if IS_ENABLED(CONFIG_NET_IPGRE)
+	case ARPHRD_IPGRE:
+		/* XXX: This special-case behaviour is there to have a
+		 * fe80::/64 route around even if no link-local address gets
+		 * generated, which happens when gre's local == 0.0.0.0.
+		 * See commit 08b4465 for more information. */
+		prefix_route = true;
+		break;
+#endif
+#if IS_ENABLED(CONFIG_IPV6_SIT)
+	case ARPHRD_SIT:
+		addrconf_sit_config(dev);
+		return;
+#endif
+	default:
+		/* No support autoconfiguration on this type */
+		return;
+	}
+
 	idev = addrconf_add_dev(dev);
 	if (IS_ERR(idev))
 		return;
 
-	addrconf_addr_gen(idev, true);
+	addrconf_addr_gen(idev, prefix_route);
 }
-#endif
 
 static int addrconf_notify(struct notifier_block *this, unsigned long event,
 			   void *ptr)
@@ -2882,25 +2891,7 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 			run_pending = 1;
 		}
 
-		switch (dev->type) {
-#if IS_ENABLED(CONFIG_IPV6_SIT)
-		case ARPHRD_SIT:
-			addrconf_sit_config(dev);
-			break;
-#endif
-#if IS_ENABLED(CONFIG_NET_IPGRE)
-		case ARPHRD_IPGRE:
-			addrconf_gre_config(dev);
-			break;
-#endif
-		case ARPHRD_LOOPBACK:
-			init_loopback(dev);
-			break;
-
-		default:
-			addrconf_dev_config(dev);
-			break;
-		}
+		addrconf_dev_config(dev);
 
 		if (!IS_ERR_OR_NULL(idev)) {
 			if (run_pending)
-- 
1.8.5.5
