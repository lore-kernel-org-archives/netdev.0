From: Felix Jia <felix.jia@alliedtelesis.co.nz>
Subject: [PATCH v3 net-next 2/2] net/ipv6: support more tunnel interfaces for EUI64 link-local generation
Date: Fri, 20 Jan 2017 11:46:58 +1300
Message-ID: <20170119224658.18723-1-felix.jia@alliedtelesis.co.nz>
Cc: Felix Jia <felix.jia@alliedtelesis.co.nz>,
        Hermin Anggawijaya <hermin.anggawijaya@alliedtelesis.co.nz>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:39863 "EHLO
        gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752263AbdASWr2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 17:47:28 -0500
Received: from mmarshal3.atlnz.lc (mmarshal3.atlnz.lc [10.32.18.43])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (Client did not present a certificate)
        by gate2.alliedtelesis.co.nz (Postfix) with ESMTPS id E40F1886BE
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 11:47:07 +1300 (NZDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Felix Jia <felix.jia@alliedtelesis.co.nz>
---
 net/ipv6/addrconf.c | 5 +++++
 net/ipv6/ip6_gre.c  | 3 +++
 net/ipv6/ip6_vti.c  | 4 ++++
 3 files changed, 12 insertions(+)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index e35259dd17ba..4c47656b9f09 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2146,12 +2146,14 @@ static int ipv6_generate_eui64(u8 *eui, struct net_device *dev)
 	case ARPHRD_SIT:
 		return addrconf_ifid_sit(eui, dev);
 	case ARPHRD_IPGRE:
+	case ARPHRD_TUNNEL:
 		return addrconf_ifid_gre(eui, dev);
 	case ARPHRD_6LOWPAN:
 		return addrconf_ifid_eui64(eui, dev);
 	case ARPHRD_IEEE1394:
 		return addrconf_ifid_ieee1394(eui, dev);
 	case ARPHRD_TUNNEL6:
+	case ARPHRD_IP6GRE:
 		return addrconf_ifid_ip6tnl(eui, dev);
 	}
 	return -1;
@@ -3195,6 +3197,9 @@ static void addrconf_dev_config(struct net_device *dev)
 	    (dev->type != ARPHRD_IEEE1394) &&
 	    (dev->type != ARPHRD_TUNNEL6) &&
 	    (dev->type != ARPHRD_6LOWPAN) &&
+	    (dev->type != ARPHRD_IP6GRE) &&
+	    (dev->type != ARPHRD_IPGRE) &&
+	    (dev->type != ARPHRD_TUNNEL) &&
 	    (dev->type != ARPHRD_NONE)) {
 		/* Alas, we support only Ethernet autoconfiguration. */
 		return;
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 75b6108234dd..7f22e1510082 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -998,6 +998,9 @@ static void ip6gre_tunnel_setup(struct net_device *dev)
 	dev->flags |= IFF_NOARP;
 	dev->addr_len = sizeof(struct in6_addr);
 	netif_keep_dst(dev);
+	/* This perm addr will be used as interface identifier by IPv6 */
+	dev->addr_assign_type = NET_ADDR_RANDOM;
+	eth_random_addr(dev->perm_addr);
 }
 
 static int ip6gre_tunnel_init_common(struct net_device *dev)
diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index d82042c8d8fd..c795fee372c4 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -49,6 +49,7 @@
 #include <net/xfrm.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
+#include <linux/etherdevice.h>
 
 #define IP6_VTI_HASH_SIZE_SHIFT  5
 #define IP6_VTI_HASH_SIZE (1 << IP6_VTI_HASH_SIZE_SHIFT)
@@ -842,6 +843,9 @@ static void vti6_dev_setup(struct net_device *dev)
 	dev->flags |= IFF_NOARP;
 	dev->addr_len = sizeof(struct in6_addr);
 	netif_keep_dst(dev);
+	/* This perm addr will be used as interface identifier by IPv6 */
+	dev->addr_assign_type = NET_ADDR_RANDOM;
+	eth_random_addr(dev->perm_addr);
 }
 
 /**
-- 
2.11.0
