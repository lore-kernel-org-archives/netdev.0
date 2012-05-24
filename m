From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 02/21] datapath: Use tun_key on transmit
Date: Thu, 24 May 2012 18:08:55 +0900
Message-ID: <1337850554-10339-3-git-send-email-horms@verge.net.au>
References: <1337850554-10339-1-git-send-email-horms@verge.net.au>
Cc: netdev@vger.kernel.org, Kyle Mestery <kmestery@cisco.com>,
	Simon Horman <horms@verge.net.au>
To: dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:46650 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753537Ab2EXJJV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2012 05:09:21 -0400
In-Reply-To: <1337850554-10339-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the tun_key, which is the basis of flow-based tunnelling, on transmit.

Cc: Kyle Mestery <kmestery@cisco.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 datapath/tunnel.c | 45 ++++++++++++++++++++++++++++++++-------------
 1 file changed, 32 insertions(+), 13 deletions(-)

diff --git a/datapath/tunnel.c b/datapath/tunnel.c
index 010e513..61add96 100644
--- a/datapath/tunnel.c
+++ b/datapath/tunnel.c
@@ -1002,15 +1002,16 @@ unlock:
 }
 
 static struct rtable *__find_route(const struct tnl_mutable_config *mutable,
-				   u8 ipproto, u8 tos)
+				   u8 ipproto, __be32 daddr, __be32 saddr,
+				   u8 tos)
 {
 	/* Tunnel configuration keeps DSCP part of TOS bits, But Linux
 	 * router expect RT_TOS bits only. */
 
 #if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,39)
 	struct flowi fl = { .nl_u = { .ip4_u = {
-					.daddr = mutable->key.daddr,
-					.saddr = mutable->key.saddr,
+					.daddr = daddr,
+					.saddr = saddr,
 					.tos   = RT_TOS(tos) } },
 					.proto = ipproto };
 	struct rtable *rt;
@@ -1020,8 +1021,8 @@ static struct rtable *__find_route(const struct tnl_mutable_config *mutable,
 
 	return rt;
 #else
-	struct flowi4 fl = { .daddr = mutable->key.daddr,
-			     .saddr = mutable->key.saddr,
+	struct flowi4 fl = { .daddr = daddr,
+			     .saddr = saddr,
 			     .flowi4_tos = RT_TOS(tos),
 			     .flowi4_proto = ipproto };
 
@@ -1031,7 +1032,8 @@ static struct rtable *__find_route(const struct tnl_mutable_config *mutable,
 
 static struct rtable *find_route(struct vport *vport,
 				 const struct tnl_mutable_config *mutable,
-				 u8 tos, struct tnl_cache **cache)
+				 u8 tos, __be32 daddr, __be32 saddr,
+				 struct tnl_cache **cache)
 {
 	struct tnl_vport *tnl_vport = tnl_vport_priv(vport);
 	struct tnl_cache *cur_cache = rcu_dereference(tnl_vport->cache);
@@ -1039,14 +1041,16 @@ static struct rtable *find_route(struct vport *vport,
 	*cache = NULL;
 	tos = RT_TOS(tos);
 
-	if (likely(tos == RT_TOS(mutable->tos) &&
-	    check_cache_valid(cur_cache, mutable))) {
+	if (daddr == mutable->key.daddr && saddr == mutable->key.saddr &&
+	    tos == RT_TOS(mutable->tos) &&
+	    check_cache_valid(cur_cache, mutable)) {
 		*cache = cur_cache;
 		return cur_cache->rt;
 	} else {
 		struct rtable *rt;
 
-		rt = __find_route(mutable, tnl_vport->tnl_ops->ipproto, tos);
+		rt = __find_route(mutable, tnl_vport->tnl_ops->ipproto,
+				  daddr, saddr, tos);
 		if (IS_ERR(rt))
 			return NULL;
 
@@ -1182,6 +1186,8 @@ int ovs_tnl_send(struct vport *vport, struct sk_buff *skb)
 	struct tnl_cache *cache;
 	int sent_len = 0;
 	__be16 frag_off = 0;
+	__be32 daddr;
+	__be32 saddr;
 	u8 ttl;
 	u8 inner_tos;
 	u8 tos;
@@ -1221,11 +1227,21 @@ int ovs_tnl_send(struct vport *vport, struct sk_buff *skb)
 
 	if (mutable->flags & TNL_F_TOS_INHERIT)
 		tos = inner_tos;
+	else if (OVS_CB(skb)->tun_key)
+		tos = OVS_CB(skb)->tun_key->ipv4_tos;
 	else
 		tos = mutable->tos;
 
+	if (OVS_CB(skb)->tun_key) {
+		daddr = OVS_CB(skb)->tun_key->ipv4_dst;
+		saddr = OVS_CB(skb)->tun_key->ipv4_src;
+	} else {
+		daddr = mutable->key.daddr;
+		saddr = mutable->key.saddr;
+	}
+
 	/* Route lookup */
-	rt = find_route(vport, mutable, tos, &cache);
+	rt = find_route(vport, mutable, tos, daddr, saddr, &cache);
 	if (unlikely(!rt))
 		goto error_free;
 	if (unlikely(!cache))
@@ -1262,10 +1278,12 @@ int ovs_tnl_send(struct vport *vport, struct sk_buff *skb)
 	}
 
 	/* TTL */
-	ttl = mutable->ttl;
+	if (OVS_CB(skb)->tun_key)
+		ttl = OVS_CB(skb)->tun_key->ipv4_ttl;
+	else
+		ttl = mutable->ttl;
 	if (!ttl)
 		ttl = ip4_dst_hoplimit(&rt_dst(rt));
-
 	if (mutable->flags & TNL_F_TTL_INHERIT) {
 		if (skb->protocol == htons(ETH_P_IP))
 			ttl = ip_hdr(skb)->ttl;
@@ -1444,7 +1462,8 @@ static int tnl_set_config(struct net *net, struct nlattr *options,
 		struct net_device *dev;
 		struct rtable *rt;
 
-		rt = __find_route(mutable, tnl_ops->ipproto, mutable->tos);
+		rt = __find_route(mutable, tnl_ops->ipproto, mutable->tos,
+				  mutable->key.daddr, mutable->key.saddr);
 		if (IS_ERR(rt))
 			return -EADDRNOTAVAIL;
 		dev = rt_dst(rt).dev;
-- 
1.7.10.2.484.gcd07cc5
