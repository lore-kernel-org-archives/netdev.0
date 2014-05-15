From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH v2] ipv6: update Destination Cache entries when gateway turn
 into host
Date: Thu, 15 May 2014 15:56:14 +0800
Message-ID: <5374731E.3040608@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([59.151.112.132]:53694 "EHLO
	heian.cn.fujitsu.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751882AbaEOH7p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 03:59:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


RFC 4861 states in 7.2.5:

	The IsRouter flag in the cache entry MUST be set based on the
         Router flag in the received advertisement.  In those cases
         where the IsRouter flag changes from TRUE to FALSE as a result
         of this update, the node MUST remove that router from the
         Default Router List and update the Destination Cache entries
         for all destinations using that neighbor as a router as
         specified in Section 7.3.3.  This is needed to detect when a
         node that is used as a router stops forwarding packets due to
         being configured as a host.

Currently, when dealing with NA Message which IsRouter flag changes from
TRUE to FALSE, the kernel only removes router from the Default Router List,
and don't update the Destination Cache entries.

Now in order to update those Destination Cache entries, i introduce
function rt6_clean_tohost().

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
Changes for v2:
  fix format as suggested
  delete those Destination Cache entries rather than to make them unreachable.

 include/net/ip6_route.h |  1 +
 net/ipv6/ndisc.c        |  7 ++-----
 net/ipv6/route.c        | 21 +++++++++++++++++++++
 3 files changed, 24 insertions(+), 5 deletions(-)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 6c4f5ea..216cecc 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -127,6 +127,7 @@ int rt6_dump_route(struct rt6_info *rt, void *p_arg);
 void rt6_ifdown(struct net *net, struct net_device *dev);
 void rt6_mtu_change(struct net_device *dev, unsigned int mtu);
 void rt6_remove_prefsrc(struct inet6_ifaddr *ifp);
+void rt6_clean_tohost(struct net *net, struct in6_addr *gateway);
 
 
 /*
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 09a22f4..ca8d4ea 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -851,7 +851,7 @@ out:
 static void ndisc_recv_na(struct sk_buff *skb)
 {
 	struct nd_msg *msg = (struct nd_msg *)skb_transport_header(skb);
-	const struct in6_addr *saddr = &ipv6_hdr(skb)->saddr;
+	struct in6_addr *saddr = &ipv6_hdr(skb)->saddr;
 	const struct in6_addr *daddr = &ipv6_hdr(skb)->daddr;
 	u8 *lladdr = NULL;
 	u32 ndoptlen = skb_tail_pointer(skb) - (skb_transport_header(skb) +
@@ -944,10 +944,7 @@ static void ndisc_recv_na(struct sk_buff *skb)
 			/*
 			 * Change: router to host
 			 */
-			struct rt6_info *rt;
-			rt = rt6_get_dflt_router(saddr, dev);
-			if (rt)
-				ip6_del_rt(rt);
+			rt6_clean_tohost(dev_net(dev),  saddr);
 		}
 
 out:
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 004fffb..58c449a 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2234,6 +2234,27 @@ void rt6_remove_prefsrc(struct inet6_ifaddr *ifp)
 	fib6_clean_all(net, fib6_remove_prefsrc, &adni);
 }
 
+#define RTF_RA_ROUTER		(RTF_ADDRCONF | RTF_DEFAULT | RTF_GATEWAY)
+#define RTF_CACHE_GATEWAY	(RTF_GATEWAY | RTF_CACHE)
+
+/* Remove routers and update dst entries when gateway turn into host. */
+static int fib6_clean_tohost(struct rt6_info *rt, void *arg)
+{
+	struct in6_addr *gateway = (struct in6_addr *)arg;
+
+	if ((((rt->rt6i_flags & RTF_RA_ROUTER) == RTF_RA_ROUTER) ||
+	     ((rt->rt6i_flags & RTF_CACHE_GATEWAY) == RTF_CACHE_GATEWAY)) &&
+	     ipv6_addr_equal(gateway, &rt->rt6i_gateway)) {
+		return -1;
+	}
+	return 0;
+}
+
+void rt6_clean_tohost(struct net *net, struct in6_addr *gateway)
+{
+	fib6_clean_all(net, fib6_clean_tohost, gateway);
+}
+
 struct arg_dev_net {
 	struct net_device *dev;
 	struct net *net;
-- 
1.8.3.1
