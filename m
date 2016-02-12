From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next v2 4/7] net: use dst_cache for vxlan device
Date: Fri, 12 Feb 2016 15:43:56 +0100
Message-ID: <5da08c2290b3d34a493ec88afd8883e528cb657c.1455287867.git.pabeni@redhat.com>
References: <cover.1455287867.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jiri Benc <jbenc@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Tom Herbert <therbert@google.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42854 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751149AbcBLOo1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Feb 2016 09:44:27 -0500
In-Reply-To: <cover.1455287867.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case of UDP traffic with datagram length
below MTU this give about 3% performance increase
when tunneling over ipv4 and about 70% when
tunneling over ipv6.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
Suggested-and-acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
v2: move the dst_cache usage into the vxlan lookup functions
---
 drivers/net/vxlan.c | 55 +++++++++++++++++++++++++++++++++++++++++++++--------
 include/net/vxlan.h |  1 +
 2 files changed, 48 insertions(+), 8 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index ebf57d9..5723b64 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -480,6 +480,8 @@ static int vxlan_fdb_replace(struct vxlan_fdb *f,
 	rd = list_first_entry_or_null(&f->remotes, struct vxlan_rdst, list);
 	if (!rd)
 		return 0;
+
+	dst_cache_reset(&rd->dst_cache);
 	rd->remote_ip = *ip;
 	rd->remote_port = port;
 	rd->remote_vni = vni;
@@ -501,6 +503,12 @@ static int vxlan_fdb_append(struct vxlan_fdb *f,
 	rd = kmalloc(sizeof(*rd), GFP_ATOMIC);
 	if (rd == NULL)
 		return -ENOBUFS;
+
+	if (dst_cache_init(&rd->dst_cache, GFP_ATOMIC)) {
+		kfree(rd);
+		return -ENOBUFS;
+	}
+
 	rd->remote_ip = *ip;
 	rd->remote_port = port;
 	rd->remote_vni = vni;
@@ -749,8 +757,10 @@ static void vxlan_fdb_free(struct rcu_head *head)
 	struct vxlan_fdb *f = container_of(head, struct vxlan_fdb, rcu);
 	struct vxlan_rdst *rd, *nd;
 
-	list_for_each_entry_safe(rd, nd, &f->remotes, list)
+	list_for_each_entry_safe(rd, nd, &f->remotes, list) {
+		dst_cache_destroy(&rd->dst_cache);
 		kfree(rd);
+	}
 	kfree(f);
 }
 
@@ -1756,11 +1766,24 @@ static int vxlan_build_skb(struct sk_buff *skb, struct dst_entry *dst,
 
 static struct rtable *vxlan_get_route(struct vxlan_dev *vxlan,
 				      struct sk_buff *skb, int oif, u8 tos,
-				      __be32 daddr, __be32 *saddr)
+				      __be32 daddr, __be32 *saddr,
+				      struct dst_cache *dst_cache,
+				      struct ip_tunnel_info *info)
 {
 	struct rtable *rt = NULL;
+	bool use_cache = false;
 	struct flowi4 fl4;
 
+	/* when the ip_tunnel_info is availble, the tos used for lookup is
+	 * packet independent, so we can use the cache
+	 */
+	if (dst_cache && !skb->mark && (!tos || info)) {
+		use_cache = true;
+		rt = dst_cache_get_ip4(dst_cache, saddr);
+		if (rt)
+			return rt;
+	}
+
 	memset(&fl4, 0, sizeof(fl4));
 	fl4.flowi4_oif = oif;
 	fl4.flowi4_tos = RT_TOS(tos);
@@ -1770,8 +1793,11 @@ static struct rtable *vxlan_get_route(struct vxlan_dev *vxlan,
 	fl4.saddr = vxlan->cfg.saddr.sin.sin_addr.s_addr;
 
 	rt = ip_route_output_key(vxlan->net, &fl4);
-	if (!IS_ERR(rt))
+	if (!IS_ERR(rt)) {
 		*saddr = fl4.saddr;
+		if (use_cache)
+			dst_cache_set_ip4(dst_cache, &rt->dst, fl4.saddr);
+	}
 	return rt;
 }
 
@@ -1779,12 +1805,21 @@ static struct rtable *vxlan_get_route(struct vxlan_dev *vxlan,
 static struct dst_entry *vxlan6_get_route(struct vxlan_dev *vxlan,
 					  struct sk_buff *skb, int oif,
 					  const struct in6_addr *daddr,
-					  struct in6_addr *saddr)
+					  struct in6_addr *saddr,
+					  struct dst_cache *dst_cache)
 {
+	bool use_cache = false;
 	struct dst_entry *ndst;
 	struct flowi6 fl6;
 	int err;
 
+	if (dst_cache && !skb->mark) {
+		use_cache = true;
+		ndst = dst_cache_get_ip6(dst_cache, saddr);
+		if (ndst)
+			return ndst;
+	}
+
 	memset(&fl6, 0, sizeof(fl6));
 	fl6.flowi6_oif = oif;
 	fl6.daddr = *daddr;
@@ -1799,6 +1834,8 @@ static struct dst_entry *vxlan6_get_route(struct vxlan_dev *vxlan,
 		return ERR_PTR(err);
 
 	*saddr = fl6.saddr;
+	if (use_cache)
+		dst_cache_set_ip6(dst_cache, ndst, saddr);
 	return ndst;
 }
 #endif
@@ -1940,7 +1977,8 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 
 		rt = vxlan_get_route(vxlan, skb,
 				     rdst ? rdst->remote_ifindex : 0, tos,
-				     dst->sin.sin_addr.s_addr, &saddr);
+				     dst->sin.sin_addr.s_addr, &saddr,
+				     rdst ? &rdst->dst_cache : NULL, info);
 		if (IS_ERR(rt)) {
 			netdev_dbg(dev, "no route to %pI4\n",
 				   &dst->sin.sin_addr.s_addr);
@@ -1992,7 +2030,8 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 
 		ndst = vxlan6_get_route(vxlan, skb,
 					rdst ? rdst->remote_ifindex : 0,
-					&dst->sin6.sin6_addr, &saddr);
+					&dst->sin6.sin6_addr, &saddr,
+					rdst ? &rdst->dst_cache : NULL);
 		if (IS_ERR(ndst)) {
 			netdev_dbg(dev, "no route to %pI6\n",
 				   &dst->sin6.sin6_addr);
@@ -2333,7 +2372,7 @@ static int vxlan_fill_metadata_dst(struct net_device *dev, struct sk_buff *skb)
 			return -EINVAL;
 		rt = vxlan_get_route(vxlan, skb, 0, info->key.tos,
 				     info->key.u.ipv4.dst,
-				     &info->key.u.ipv4.src);
+				     &info->key.u.ipv4.src, NULL, info);
 		if (IS_ERR(rt))
 			return PTR_ERR(rt);
 		ip_rt_put(rt);
@@ -2345,7 +2384,7 @@ static int vxlan_fill_metadata_dst(struct net_device *dev, struct sk_buff *skb)
 			return -EINVAL;
 		ndst = vxlan6_get_route(vxlan, skb, 0,
 					&info->key.u.ipv6.dst,
-					&info->key.u.ipv6.src);
+					&info->key.u.ipv6.src, NULL);
 		if (IS_ERR(ndst))
 			return PTR_ERR(ndst);
 		dst_release(ndst);
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 25bd919..b314e4a 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -148,6 +148,7 @@ struct vxlan_rdst {
 	u32			 remote_ifindex;
 	struct list_head	 list;
 	struct rcu_head		 rcu;
+	struct dst_cache	 dst_cache;
 };
 
 struct vxlan_config {
-- 
1.8.3.1
