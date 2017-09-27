From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH v4 net-next 02/12] vxlan: Call common functions to get tunnel routes
Date: Tue, 26 Sep 2017 21:57:53 -0700
Message-ID: <20170927045803.2477-3-tom@quantonium.net>
References: <20170927045803.2477-1-tom@quantonium.net>
Cc: pablo@netfilter.org, laforge@gnumonks.org, aschultz@tpip.net,
        netdev@vger.kernel.org, rohit@quantonium.net,
        Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:44255 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967161AbdI0E6o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 00:58:44 -0400
Received: by mail-pg0-f43.google.com with SMTP id j16so7136353pga.1
        for <netdev@vger.kernel.org>; Tue, 26 Sep 2017 21:58:43 -0700 (PDT)
In-Reply-To: <20170927045803.2477-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call ip_tunnel_get_route and ip6_tnl_get_route to handle getting a route
and dealing with the dst_cache.

Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 drivers/net/vxlan.c | 84 ++++-------------------------------------------------
 1 file changed, 5 insertions(+), 79 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index d7c49cf1d5e9..810caa9adf37 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1867,47 +1867,11 @@ static struct rtable *vxlan_get_route(struct vxlan_dev *vxlan, struct net_device
 				      struct dst_cache *dst_cache,
 				      const struct ip_tunnel_info *info)
 {
-	bool use_cache = ip_tunnel_dst_cache_usable(skb, info);
-	struct rtable *rt = NULL;
-	struct flowi4 fl4;
-
 	if (!sock4)
 		return ERR_PTR(-EIO);
 
-	if (tos && !info)
-		use_cache = false;
-	if (use_cache) {
-		rt = dst_cache_get_ip4(dst_cache, saddr);
-		if (rt)
-			return rt;
-	}
-
-	memset(&fl4, 0, sizeof(fl4));
-	fl4.flowi4_oif = oif;
-	fl4.flowi4_tos = RT_TOS(tos);
-	fl4.flowi4_mark = skb->mark;
-	fl4.flowi4_proto = IPPROTO_UDP;
-	fl4.daddr = daddr;
-	fl4.saddr = *saddr;
-	fl4.fl4_dport = dport;
-	fl4.fl4_sport = sport;
-
-	rt = ip_route_output_key(vxlan->net, &fl4);
-	if (likely(!IS_ERR(rt))) {
-		if (rt->dst.dev == dev) {
-			netdev_dbg(dev, "circular route to %pI4\n", &daddr);
-			ip_rt_put(rt);
-			return ERR_PTR(-ELOOP);
-		}
-
-		*saddr = fl4.saddr;
-		if (use_cache)
-			dst_cache_set_ip4(dst_cache, &rt->dst, fl4.saddr);
-	} else {
-		netdev_dbg(dev, "no route to %pI4\n", &daddr);
-		return ERR_PTR(-ENETUNREACH);
-	}
-	return rt;
+	return ip_tunnel_get_route(dev, skb, IPPROTO_UDP, oif, tos, daddr,
+				   saddr, dport, sport, dst_cache, info);
 }
 
 #if IS_ENABLED(CONFIG_IPV6)
@@ -1922,50 +1886,12 @@ static struct dst_entry *vxlan6_get_route(struct vxlan_dev *vxlan,
 					  struct dst_cache *dst_cache,
 					  const struct ip_tunnel_info *info)
 {
-	bool use_cache = ip_tunnel_dst_cache_usable(skb, info);
-	struct dst_entry *ndst;
-	struct flowi6 fl6;
-	int err;
-
 	if (!sock6)
 		return ERR_PTR(-EIO);
 
-	if (tos && !info)
-		use_cache = false;
-	if (use_cache) {
-		ndst = dst_cache_get_ip6(dst_cache, saddr);
-		if (ndst)
-			return ndst;
-	}
-
-	memset(&fl6, 0, sizeof(fl6));
-	fl6.flowi6_oif = oif;
-	fl6.daddr = *daddr;
-	fl6.saddr = *saddr;
-	fl6.flowlabel = ip6_make_flowinfo(RT_TOS(tos), label);
-	fl6.flowi6_mark = skb->mark;
-	fl6.flowi6_proto = IPPROTO_UDP;
-	fl6.fl6_dport = dport;
-	fl6.fl6_sport = sport;
-
-	err = ipv6_stub->ipv6_dst_lookup(vxlan->net,
-					 sock6->sock->sk,
-					 &ndst, &fl6);
-	if (unlikely(err < 0)) {
-		netdev_dbg(dev, "no route to %pI6\n", daddr);
-		return ERR_PTR(-ENETUNREACH);
-	}
-
-	if (unlikely(ndst->dev == dev)) {
-		netdev_dbg(dev, "circular route to %pI6\n", daddr);
-		dst_release(ndst);
-		return ERR_PTR(-ELOOP);
-	}
-
-	*saddr = fl6.saddr;
-	if (use_cache)
-		dst_cache_set_ip6(dst_cache, ndst, saddr);
-	return ndst;
+	return ip6_tnl_get_route(dev, skb, sock6->sock->sk, IPPROTO_UDP, oif,
+				   tos, label, daddr, saddr, dport, sport,
+				   dst_cache, info);
 }
 #endif
 
-- 
2.11.0
