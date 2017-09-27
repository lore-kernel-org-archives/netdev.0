From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH v4 net-next 01/12] iptunnel: Add common functions to get a tunnel route
Date: Tue, 26 Sep 2017 21:57:52 -0700
Message-ID: <20170927045803.2477-2-tom@quantonium.net>
References: <20170927045803.2477-1-tom@quantonium.net>
Cc: pablo@netfilter.org, laforge@gnumonks.org, aschultz@tpip.net,
        netdev@vger.kernel.org, rohit@quantonium.net,
        Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:45093 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967161AbdI0E6j (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 00:58:39 -0400
Received: by mail-pf0-f180.google.com with SMTP id z84so6672264pfi.2
        for <netdev@vger.kernel.org>; Tue, 26 Sep 2017 21:58:38 -0700 (PDT)
In-Reply-To: <20170927045803.2477-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip_tunnel_get_route and ip6_tnl_get_route are created to return
routes for a tunnel. These functions are derived from the VXLAN
functions.

Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 include/net/ip6_tunnel.h | 33 +++++++++++++++++++++++++++++++++
 include/net/ip_tunnels.h | 32 ++++++++++++++++++++++++++++++++
 net/ipv4/ip_tunnel.c     | 40 ++++++++++++++++++++++++++++++++++++++++
 net/ipv6/route.c         | 42 ++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 147 insertions(+)

diff --git a/include/net/ip6_tunnel.h b/include/net/ip6_tunnel.h
index 08fbc7f7d8d7..f84325aacdaf 100644
--- a/include/net/ip6_tunnel.h
+++ b/include/net/ip6_tunnel.h
@@ -142,6 +142,39 @@ __u32 ip6_tnl_get_cap(struct ip6_tnl *t, const struct in6_addr *laddr,
 struct net *ip6_tnl_get_link_net(const struct net_device *dev);
 int ip6_tnl_get_iflink(const struct net_device *dev);
 int ip6_tnl_change_mtu(struct net_device *dev, int new_mtu);
+struct dst_entry *__ip6_tnl_get_route(struct net_device *dev,
+				      struct sk_buff *skb, struct sock *sk,
+				      u8 proto, int oif, u8 tos, __be32 label,
+				      const struct in6_addr *daddr,
+				      struct in6_addr *saddr,
+				      __be16 dport, __be16 sport,
+				      struct dst_cache *dst_cache,
+				      bool use_cache);
+
+static inline struct dst_entry *ip6_tnl_get_route(struct net_device *dev,
+			struct sk_buff *skb, struct sock *sk, u8 proto,
+			int oif, u8 tos, __be32 label,
+			const struct in6_addr *daddr,
+			struct in6_addr *saddr,
+			__be16 dport, __be16 sport,
+			struct dst_cache *dst_cache,
+			const struct ip_tunnel_info *info)
+{
+	 bool use_cache = (ip_tunnel_dst_cache_usable(skb, info) &&
+		(!tos || info));
+
+#if IS_ENABLED(CONFIG_IPV6)
+	if (use_cache) {
+		struct dst_entry *ndst = dst_cache_get_ip6(dst_cache, saddr);
+
+		if (ndst)
+			return ndst;
+	}
+#endif
+
+	return __ip6_tnl_get_route(dev, skb, sk, proto, oif, tos, label, daddr,
+				   saddr, dport, sport, dst_cache, use_cache);
+}
 
 static inline void ip6tunnel_xmit(struct sock *sk, struct sk_buff *skb,
 				  struct net_device *dev)
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index b41a1e057fce..2b05ae24f4f6 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -285,6 +285,38 @@ int ip_tunnel_newlink(struct net_device *dev, struct nlattr *tb[],
 		      struct ip_tunnel_parm *p, __u32 fwmark);
 void ip_tunnel_setup(struct net_device *dev, unsigned int net_id);
 
+struct rtable *__ip_tunnel_get_route(struct net_device *dev,
+				     struct sk_buff *skb, u8 proto,
+				     int oif, u8 tos,
+				     __be32 daddr, __be32 *saddr,
+				     __be16 dport, __be16 sport,
+				     struct dst_cache *dst_cache,
+				     bool use_cache);
+
+static inline struct rtable *ip_tunnel_get_route(struct net_device *dev,
+				     struct sk_buff *skb, u8 proto,
+				     int oif, u8 tos,
+				     __be32 daddr, __be32 *saddr,
+				     __be16 dport, __be16 sport,
+				     struct dst_cache *dst_cache,
+				     const struct ip_tunnel_info *info)
+{
+	bool use_cache = (ip_tunnel_dst_cache_usable(skb, info) &&
+		(!tos || info));
+
+	if (use_cache) {
+		struct rtable *rt;
+
+		rt = dst_cache_get_ip4(dst_cache, saddr);
+		if (rt)
+			return rt;
+	}
+
+	return __ip_tunnel_get_route(dev, skb, proto, oif, tos,
+				     daddr, saddr, dport, sport,
+				     dst_cache, use_cache);
+}
+
 struct ip_tunnel_encap_ops {
 	size_t (*encap_hlen)(struct ip_tunnel_encap *e);
 	int (*build_header)(struct sk_buff *skb, struct ip_tunnel_encap *e,
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index fe6fee728ce4..c97525d8dff9 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -935,6 +935,46 @@ int ip_tunnel_ioctl(struct net_device *dev, struct ip_tunnel_parm *p, int cmd)
 }
 EXPORT_SYMBOL_GPL(ip_tunnel_ioctl);
 
+struct rtable *__ip_tunnel_get_route(struct net_device *dev,
+				     struct sk_buff *skb, u8 proto,
+				    int oif, u8 tos,
+				     __be32 daddr, __be32 *saddr,
+				     __be16 dport, __be16 sport,
+				     struct dst_cache *dst_cache,
+				     bool use_cache)
+{
+	struct rtable *rt = NULL;
+	struct flowi4 fl4;
+
+	memset(&fl4, 0, sizeof(fl4));
+	fl4.flowi4_oif = oif;
+	fl4.flowi4_tos = RT_TOS(tos);
+	fl4.flowi4_mark = skb->mark;
+	fl4.flowi4_proto = proto;
+	fl4.daddr = daddr;
+	fl4.saddr = *saddr;
+	fl4.fl4_dport = dport;
+	fl4.fl4_sport = sport;
+
+	rt = ip_route_output_key(dev_net(dev), &fl4);
+	if (likely(!IS_ERR(rt))) {
+		if (rt->dst.dev == dev) {
+			netdev_dbg(dev, "circular route to %pI4\n", &daddr);
+			ip_rt_put(rt);
+			return ERR_PTR(-ELOOP);
+		}
+
+		*saddr = fl4.saddr;
+		if (use_cache)
+			dst_cache_set_ip4(dst_cache, &rt->dst, fl4.saddr);
+	} else {
+		netdev_dbg(dev, "no route to %pI4\n", &daddr);
+		return ERR_PTR(-ENETUNREACH);
+	}
+	return rt;
+}
+EXPORT_SYMBOL_GPL(__ip_tunnel_get_route);
+
 int __ip_tunnel_change_mtu(struct net_device *dev, int new_mtu, bool strict)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 26cc9f483b6d..57cb8649b4eb 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1884,6 +1884,48 @@ static struct rt6_info *ip6_nh_lookup_table(struct net *net,
 	return rt;
 }
 
+struct dst_entry *__ip6_tnl_get_route(struct net_device *dev,
+				      struct sk_buff *skb, struct sock *sk,
+				      u8 proto, int oif, u8 tos, __be32 label,
+				      const struct in6_addr *daddr,
+				      struct in6_addr *saddr,
+				      __be16 dport, __be16 sport,
+				      struct dst_cache *dst_cache,
+				      bool use_cache)
+{
+	struct dst_entry *ndst;
+	struct flowi6 fl6;
+	int err;
+
+	memset(&fl6, 0, sizeof(fl6));
+	fl6.flowi6_oif = oif;
+	fl6.daddr = *daddr;
+	fl6.saddr = *saddr;
+	fl6.flowlabel = ip6_make_flowinfo(RT_TOS(tos), label);
+	fl6.flowi6_mark = skb->mark;
+	fl6.flowi6_proto = proto;
+	fl6.fl6_dport = dport;
+	fl6.fl6_sport = sport;
+
+	err = ipv6_stub->ipv6_dst_lookup(dev_net(dev), sk, &ndst, &fl6);
+	if (unlikely(err < 0)) {
+		netdev_dbg(dev, "no route to %pI6\n", daddr);
+		return ERR_PTR(-ENETUNREACH);
+	}
+
+	if (unlikely(ndst->dev == dev)) {
+		netdev_dbg(dev, "circular route to %pI6\n", daddr);
+		dst_release(ndst);
+		return ERR_PTR(-ELOOP);
+	}
+
+	*saddr = fl6.saddr;
+	if (use_cache)
+		dst_cache_set_ip6(dst_cache, ndst, saddr);
+	return ndst;
+}
+EXPORT_SYMBOL_GPL(__ip6_tnl_get_route);
+
 static struct rt6_info *ip6_route_info_create(struct fib6_config *cfg,
 					      struct netlink_ext_ack *extack)
 {
-- 
2.11.0
