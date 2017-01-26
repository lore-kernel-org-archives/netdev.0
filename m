From: Felix Jia <felix.jia@alliedtelesis.co.nz>
Subject: [PATCH v4 net-next 2/2] net/ipv6: support more tunnel interfaces for EUI64 link-local generation
Date: Thu, 26 Jan 2017 16:59:18 +1300
Message-ID: <20170126035918.7332-2-felix.jia@alliedtelesis.co.nz>
References: <20170126035918.7332-1-felix.jia@alliedtelesis.co.nz>
Cc: netdev@vger.kernel.org, Felix Jia <felix.jia@alliedtelesis.co.nz>
To: "David S . Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:50688 "EHLO
        gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752721AbdAZD7k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 22:59:40 -0500
In-Reply-To: <20170126035918.7332-1-felix.jia@alliedtelesis.co.nz>
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
index 65bdfd1cca80..1ba7567b4d8f 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -993,6 +993,9 @@ static void ip6gre_tunnel_setup(struct net_device *dev)
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
