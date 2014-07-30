From: David Lamparter <equinox@diac24.net>
Subject: [RFC alternate] ipv6: addrconf: clean up device type handling
Date: Wed, 30 Jul 2014 17:58:41 +0200
Message-ID: <1406735921-122830-1-git-send-email-equinox@diac24.net>
References: <20140730153503.GJ801478@jupiter.n2.diac24.net>
Cc: David Lamparter <equinox@diac24.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Jiri Pirko <jiri@resnulli.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:59365 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754109AbaG3P7E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jul 2014 11:59:04 -0400
In-Reply-To: <20140730153503.GJ801478@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This realigns addrconf support for the various lower-layer device types,
and removes a little bit of duplicate code.

For GRE devices, this includes a semantic change in that there is now a
ff00::/8 route installed on address autogeneration.  This was previously
missing and broke any kind of IPv6 multicast - unless another address
was configured from userspace (which then added the missing ff00::/8).

Fixes: aee80b54b235 (ipv6: generate link local address for GRE tunnel)
Signed-off-by: David Lamparter <equinox@diac24.net>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: Jiri Pirko <jiri@resnulli.us>
---

This is an alternate version, yanking the switch() down and removing
dev_config/gre_config duplication.  I have no idea what rationale is behind
prefix_route - the result is a fe80::/64 route, but no address, which is not a
functioning configuration.  Jiri, you touched this just a few weeks ago, can
you comment?  (The "XXX: why is GRE special?")


 net/ipv6/addrconf.c | 87 +++++++++++++++++++++++------------------------------
 1 file changed, 37 insertions(+), 50 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 0b239fc..45746f7 100644
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
@@ -2811,21 +2786,51 @@ static void addrconf_sit_config(struct net_device *dev)
 }
 #endif
 
-#if IS_ENABLED(CONFIG_NET_IPGRE)
-static void addrconf_gre_config(struct net_device *dev)
+static void addrconf_dev_config(struct net_device *dev)
 {
 	struct inet6_dev *idev;
+	bool prefix_route;
 
 	ASSERT_RTNL();
 
-	if ((idev = ipv6_find_idev(dev)) == NULL) {
-		pr_debug("%s: add_dev failed\n", __func__);
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
+		/* XXX: why is GRE special? */
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
 		return;
 	}
 
-	addrconf_addr_gen(idev, true);
+	idev = addrconf_add_dev(dev);
+	if (IS_ERR(idev))
+		return;
+
+	addrconf_addr_gen(idev, prefix_route);
 }
-#endif
 
 static int addrconf_notify(struct notifier_block *this, unsigned long event,
 			   void *ptr)
@@ -2883,25 +2888,7 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
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
