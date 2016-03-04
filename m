From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 6/7] bpf, vxlan, geneve, gre: fix usage of dst_cache on xmit
Date: Fri,  4 Mar 2016 15:15:07 +0100
Message-ID: <6968a6871ea44ba87451f5f7fc7599322c408276.1457099834.git.daniel@iogearbox.net>
References: <cover.1457099834.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:39207 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756011AbcCDOPf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 09:15:35 -0500
In-Reply-To: <cover.1457099834.git.daniel@iogearbox.net>
In-Reply-To: <cover.1457099834.git.daniel@iogearbox.net>
References: <cover.1457099834.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The assumptions from commit 0c1d70af924b ("net: use dst_cache for vxlan
device"), 468dfffcd762 ("geneve: add dst caching support") and 3c1cb4d2604c
("net/ipv4: add dst cache support for gre lwtunnels") on dst_cache usage
when ip_tunnel_info is used is unfortunately not always valid as assumed.

While it seems correct for ip_tunnel_info front-ends such as OVS, eBPF
however can fill in ip_tunnel_info for consumers like vxlan, geneve or gre
with different remote dsts, tos, etc, therefore they cannot be assumed as
packet independent.

Right now vxlan, geneve, gre would cache the dst for eBPF and every packet
would reuse the same entry that was first created on the initial route
lookup. eBPF doesn't store/cache the ip_tunnel_info, so each skb may have
a different one.

Fix it by adding a flag that checks the ip_tunnel_info. Also the !tos test
in vxlan needs to be handeled differently in this context as it is currently
inferred from ip_tunnel_info as well if present. ip_tunnel_dst_cache_usable()
helper is added for the three tunnel cases, which checks if we can use dst
cache.

Fixes: 0c1d70af924b ("net: use dst_cache for vxlan device")
Fixes: 468dfffcd762 ("geneve: add dst caching support")
Fixes: 3c1cb4d2604c ("net/ipv4: add dst cache support for gre lwtunnels")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Paolo Abeni <pabeni@redhat.com>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 [ Affected patches are in net-next only. ]

 drivers/net/geneve.c     |  6 ++----
 drivers/net/vxlan.c      | 24 ++++++++++++------------
 include/net/ip_tunnels.h | 15 +++++++++++++++
 net/core/filter.c        |  2 +-
 net/ipv4/ip_gre.c        | 10 ++++++----
 5 files changed, 36 insertions(+), 21 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 36db4cf..6a0cbbe 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -775,10 +775,10 @@ static struct rtable *geneve_get_v4_rt(struct sk_buff *skb,
 				       struct flowi4 *fl4,
 				       struct ip_tunnel_info *info)
 {
+	bool use_cache = ip_tunnel_dst_cache_usable(skb, info);
 	struct geneve_dev *geneve = netdev_priv(dev);
 	struct dst_cache *dst_cache;
 	struct rtable *rt = NULL;
-	bool use_cache = true;
 	__u8 tos;
 
 	memset(fl4, 0, sizeof(*fl4));
@@ -804,7 +804,6 @@ static struct rtable *geneve_get_v4_rt(struct sk_buff *skb,
 		dst_cache = &geneve->dst_cache;
 	}
 
-	use_cache = use_cache && !skb->mark;
 	if (use_cache) {
 		rt = dst_cache_get_ip4(dst_cache, &fl4->saddr);
 		if (rt)
@@ -832,11 +831,11 @@ static struct dst_entry *geneve_get_v6_dst(struct sk_buff *skb,
 					   struct flowi6 *fl6,
 					   struct ip_tunnel_info *info)
 {
+	bool use_cache = ip_tunnel_dst_cache_usable(skb, info);
 	struct geneve_dev *geneve = netdev_priv(dev);
 	struct geneve_sock *gs6 = geneve->sock6;
 	struct dst_entry *dst = NULL;
 	struct dst_cache *dst_cache;
-	bool use_cache = true;
 	__u8 prio;
 
 	memset(fl6, 0, sizeof(*fl6));
@@ -862,7 +861,6 @@ static struct dst_entry *geneve_get_v6_dst(struct sk_buff *skb,
 		dst_cache = &geneve->dst_cache;
 	}
 
-	use_cache = use_cache && !skb->mark;
 	if (use_cache) {
 		dst = dst_cache_get_ip6(dst_cache, &fl6->saddr);
 		if (dst)
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 5161411..366a858 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1755,17 +1755,15 @@ static struct rtable *vxlan_get_route(struct vxlan_dev *vxlan,
 				      struct sk_buff *skb, int oif, u8 tos,
 				      __be32 daddr, __be32 *saddr,
 				      struct dst_cache *dst_cache,
-				      struct ip_tunnel_info *info)
+				      const struct ip_tunnel_info *info)
 {
+	bool use_cache = ip_tunnel_dst_cache_usable(skb, info);
 	struct rtable *rt = NULL;
-	bool use_cache = false;
 	struct flowi4 fl4;
 
-	/* when the ip_tunnel_info is availble, the tos used for lookup is
-	 * packet independent, so we can use the cache
-	 */
-	if (!skb->mark && (!tos || info)) {
-		use_cache = true;
+	if (tos && !info)
+		use_cache = false;
+	if (use_cache) {
 		rt = dst_cache_get_ip4(dst_cache, saddr);
 		if (rt)
 			return rt;
@@ -1793,13 +1791,15 @@ static struct dst_entry *vxlan6_get_route(struct vxlan_dev *vxlan,
 					  struct sk_buff *skb, int oif,
 					  const struct in6_addr *daddr,
 					  struct in6_addr *saddr,
-					  struct dst_cache *dst_cache)
+					  struct dst_cache *dst_cache,
+					  const struct ip_tunnel_info *info)
 {
+	bool use_cache = ip_tunnel_dst_cache_usable(skb, info);
 	struct dst_entry *ndst;
 	struct flowi6 fl6;
 	int err;
 
-	if (!skb->mark) {
+	if (use_cache) {
 		ndst = dst_cache_get_ip6(dst_cache, saddr);
 		if (ndst)
 			return ndst;
@@ -1819,7 +1819,7 @@ static struct dst_entry *vxlan6_get_route(struct vxlan_dev *vxlan,
 		return ERR_PTR(err);
 
 	*saddr = fl6.saddr;
-	if (!skb->mark)
+	if (use_cache)
 		dst_cache_set_ip6(dst_cache, ndst, saddr);
 	return ndst;
 }
@@ -2017,7 +2017,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		ndst = vxlan6_get_route(vxlan, skb,
 					rdst ? rdst->remote_ifindex : 0,
 					&dst->sin6.sin6_addr, &saddr,
-					dst_cache);
+					dst_cache, info);
 		if (IS_ERR(ndst)) {
 			netdev_dbg(dev, "no route to %pI6\n",
 				   &dst->sin6.sin6_addr);
@@ -2386,7 +2386,7 @@ static int vxlan_fill_metadata_dst(struct net_device *dev, struct sk_buff *skb)
 			return -EINVAL;
 		ndst = vxlan6_get_route(vxlan, skb, 0,
 					&info->key.u.ipv6.dst,
-					&info->key.u.ipv6.src, NULL);
+					&info->key.u.ipv6.src, NULL, info);
 		if (IS_ERR(ndst))
 			return PTR_ERR(ndst);
 		dst_release(ndst);
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 5f28b60..e1395d7 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -140,6 +140,7 @@ struct ip_tunnel {
 #define TUNNEL_CRIT_OPT		__cpu_to_be16(0x0400)
 #define TUNNEL_GENEVE_OPT	__cpu_to_be16(0x0800)
 #define TUNNEL_VXLAN_OPT	__cpu_to_be16(0x1000)
+#define TUNNEL_NOCACHE		__cpu_to_be16(0x2000)
 
 #define TUNNEL_OPTIONS_PRESENT	(TUNNEL_GENEVE_OPT | TUNNEL_VXLAN_OPT)
 
@@ -206,6 +207,20 @@ static inline void ip_tunnel_key_init(struct ip_tunnel_key *key,
 		       0, sizeof(*key) - IP_TUNNEL_KEY_SIZE);
 }
 
+static inline bool
+ip_tunnel_dst_cache_usable(const struct sk_buff *skb,
+			   const struct ip_tunnel_info *info)
+{
+	if (skb->mark)
+		return false;
+	if (!info)
+		return true;
+	if (info->key.tun_flags & TUNNEL_NOCACHE)
+		return false;
+
+	return true;
+}
+
 static inline unsigned short ip_tunnel_info_af(const struct ip_tunnel_info
 					       *tun_info)
 {
diff --git a/net/core/filter.c b/net/core/filter.c
index 012a10c..a66dc03 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1870,7 +1870,7 @@ static u64 bpf_skb_set_tunnel_key(u64 r1, u64 r2, u64 size, u64 flags, u64 r5)
 	info = &md->u.tun_info;
 	info->mode = IP_TUNNEL_INFO_TX;
 
-	info->key.tun_flags = TUNNEL_KEY | TUNNEL_CSUM;
+	info->key.tun_flags = TUNNEL_KEY | TUNNEL_CSUM | TUNNEL_NOCACHE;
 	if (flags & BPF_F_DONT_FRAGMENT)
 		info->key.tun_flags |= TUNNEL_DONT_FRAGMENT;
 
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 202437d..31936d3 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -527,11 +527,12 @@ static void gre_fb_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ip_tunnel_info *tun_info;
 	const struct ip_tunnel_key *key;
+	struct rtable *rt = NULL;
 	struct flowi4 fl;
-	struct rtable *rt;
 	int min_headroom;
 	int tunnel_hlen;
 	__be16 df, flags;
+	bool use_cache;
 	int err;
 
 	tun_info = skb_tunnel_info(skb);
@@ -540,13 +541,14 @@ static void gre_fb_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto err_free_skb;
 
 	key = &tun_info->key;
-	rt = !skb->mark ? dst_cache_get_ip4(&tun_info->dst_cache, &fl.saddr) :
-			 NULL;
+	use_cache = ip_tunnel_dst_cache_usable(skb, tun_info);
+	if (use_cache)
+		rt = dst_cache_get_ip4(&tun_info->dst_cache, &fl.saddr);
 	if (!rt) {
 		rt = gre_get_rt(skb, dev, &fl, key);
 		if (IS_ERR(rt))
 				goto err_free_skb;
-		if (!skb->mark)
+		if (use_cache)
 			dst_cache_set_ip4(&tun_info->dst_cache, &rt->dst,
 					  fl.saddr);
 	}
-- 
1.9.3
