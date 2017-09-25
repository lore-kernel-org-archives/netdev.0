From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH v3 net-next 01/12] iptunnel: Add common functions to get a tunnel route
Date: Sun, 24 Sep 2017 20:29:30 -0700
Message-ID: <20170925032941.14586-2-tom@quantonium.net>
References: <20170925032941.14586-1-tom@quantonium.net>
Cc: pablo@netfilter.org, laforge@gnumonks.org, aschultz@tpip.net,
        netdev@vger.kernel.org, rohit@quantonium.net,
        Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:53823 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932698AbdIYDaC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 24 Sep 2017 23:30:02 -0400
Received: by mail-pg0-f41.google.com with SMTP id j70so3268638pgc.10
        for <netdev@vger.kernel.org>; Sun, 24 Sep 2017 20:30:02 -0700 (PDT)
In-Reply-To: <20170925032941.14586-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip_tunnel_get_route and ip6_tnl_get_route are created to return
routes for a tunnel. These functions are derived from the VXLAN
functions.

Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 include/net/ip6_tunnel.h | 35 +++++++++++++++++++++++++++++++++++
 include/net/ip_tunnels.h | 33 +++++++++++++++++++++++++++++++++
 net/ipv4/ip_tunnel.c     | 41 +++++++++++++++++++++++++++++++++++++++++
 net/ipv6/ip6_tunnel.c    | 43 +++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 152 insertions(+)

diff --git a/include/net/ip6_tunnel.h b/include/net/ip6_tunnel.h
index 08fbc7f7d8d7..5a67301b0416 100644
--- a/include/net/ip6_tunnel.h
+++ b/include/net/ip6_tunnel.h
@@ -142,6 +142,41 @@ __u32 ip6_tnl_get_cap(struct ip6_tnl *t, const struct in6_addr *laddr,
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
+				      const struct ip_tunnel_info *info,
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
+	return __ip6_tnl_get_route(dev, skb, sk, proto, oif, tos, label,
+				   daddr, saddr, dport, sport, dst_cache,
+				   info, use_cache);
+}
 
 static inline void ip6tunnel_xmit(struct sock *sk, struct sk_buff *skb,
 				  struct net_device *dev)
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index b41a1e057fce..9650efff33d7 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -285,6 +285,39 @@ int ip_tunnel_newlink(struct net_device *dev, struct nlattr *tb[],
 		      struct ip_tunnel_parm *p, __u32 fwmark);
 void ip_tunnel_setup(struct net_device *dev, unsigned int net_id);
 
+struct rtable *__ip_tunnel_get_route(struct net_device *dev,
+				     struct sk_buff *skb, u8 proto,
+				     int oif, u8 tos,
+				     __be32 daddr, __be32 *saddr,
+				     __be16 dport, __be16 sport,
+				     struct dst_cache *dst_cache,
+				     const struct ip_tunnel_info *info,
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
+				     dst_cache, info, use_cache);
+}
+
 struct ip_tunnel_encap_ops {
 	size_t (*encap_hlen)(struct ip_tunnel_encap *e);
 	int (*build_header)(struct sk_buff *skb, struct ip_tunnel_encap *e,
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index fe6fee728ce4..ea8f8bc0aaf9 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -935,6 +935,47 @@ int ip_tunnel_ioctl(struct net_device *dev, struct ip_tunnel_parm *p, int cmd)
 }
 EXPORT_SYMBOL_GPL(ip_tunnel_ioctl);
 
+struct rtable *__ip_tunnel_get_route(struct net_device *dev,
+				     struct sk_buff *skb, u8 proto,
+				    int oif, u8 tos,
+				     __be32 daddr, __be32 *saddr,
+				     __be16 dport, __be16 sport,
+				     struct dst_cache *dst_cache,
+				     const struct ip_tunnel_info *info,
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
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 3d6df489b39f..a541daea1379 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1663,6 +1663,49 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	return err;
 }
 
+struct dst_entry *__ip6_tnl_get_route(struct net_device *dev,
+				      struct sk_buff *skb, struct sock *sk,
+				      u8 proto, int oif, u8 tos, __be32 label,
+				      const struct in6_addr *daddr,
+				      struct in6_addr *saddr,
+				      __be16 dport, __be16 sport,
+				      struct dst_cache *dst_cache,
+				      const struct ip_tunnel_info *info,
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
 /**
  * ip6_tnl_change_mtu - change mtu manually for tunnel device
  *   @dev: virtual device associated with tunnel
-- 
2.11.0
