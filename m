From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCHv3 net-next 5/7] net: add confirm_neigh method to dst_ops
Date: Tue, 31 Jan 2017 23:57:05 +0200
Message-ID: <1485899827-5212-6-git-send-email-ja@ssi.bg>
References: <1485899827-5212-1-git-send-email-ja@ssi.bg>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        Neil Horman <nhorman@tuxdriver.com>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        linux-rdma@vger.kernel.org, YueHaibing <yuehaibing@huawei.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:58181 "EHLO ja.ssi.bg"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751154AbdAaV67 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Jan 2017 16:58:59 -0500
In-Reply-To: <1485899827-5212-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add confirm_neigh method to dst_ops and use it from IPv4 and IPv6
to lookup and confirm the neighbour. Its usage via the new helper
dst_confirm_neigh() should be restricted to MSG_PROBE users for
performance reasons.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Acked-by: Eric Dumazet <edumazet@google.com>
---
 include/net/arp.h      | 16 ++++++++++++++++
 include/net/dst.h      |  7 +++++++
 include/net/dst_ops.h  |  2 ++
 include/net/ndisc.h    | 17 +++++++++++++++++
 net/ipv4/route.c       | 19 +++++++++++++++++++
 net/ipv6/route.c       | 16 ++++++++++++++++
 net/xfrm/xfrm_policy.c | 16 ++++++++++++++++
 7 files changed, 93 insertions(+)

diff --git a/include/net/arp.h b/include/net/arp.h
index 5e0f891..65619a2 100644
--- a/include/net/arp.h
+++ b/include/net/arp.h
@@ -35,6 +35,22 @@ static inline struct neighbour *__ipv4_neigh_lookup(struct net_device *dev, u32
 	return n;
 }
 
+static inline void __ipv4_confirm_neigh(struct net_device *dev, u32 key)
+{
+	struct neighbour *n;
+
+	rcu_read_lock_bh();
+	n = __ipv4_neigh_lookup_noref(dev, key);
+	if (n) {
+		unsigned long now = jiffies;
+
+		/* avoid dirtying neighbour */
+		if (n->confirmed != now)
+			n->confirmed = now;
+	}
+	rcu_read_unlock_bh();
+}
+
 void arp_init(void);
 int arp_ioctl(struct net *net, unsigned int cmd, void __user *arg);
 void arp_send(int type, int ptype, __be32 dest_ip,
diff --git a/include/net/dst.h b/include/net/dst.h
index 6835d22..3a3b34b 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -477,6 +477,13 @@ static inline struct neighbour *dst_neigh_lookup_skb(const struct dst_entry *dst
 	return IS_ERR(n) ? NULL : n;
 }
 
+static inline void dst_confirm_neigh(const struct dst_entry *dst,
+				     const void *daddr)
+{
+	if (dst->ops->confirm_neigh)
+		dst->ops->confirm_neigh(dst, daddr);
+}
+
 static inline void dst_link_failure(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
diff --git a/include/net/dst_ops.h b/include/net/dst_ops.h
index 8a2b66d..c84b328 100644
--- a/include/net/dst_ops.h
+++ b/include/net/dst_ops.h
@@ -33,6 +33,8 @@ struct dst_ops {
 	struct neighbour *	(*neigh_lookup)(const struct dst_entry *dst,
 						struct sk_buff *skb,
 						const void *daddr);
+	void			(*confirm_neigh)(const struct dst_entry *dst,
+						 const void *daddr);
 
 	struct kmem_cache	*kmem_cachep;
 
diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index d562a2f..8a02146 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -391,6 +391,23 @@ static inline struct neighbour *__ipv6_neigh_lookup(struct net_device *dev, cons
 	return n;
 }
 
+static inline void __ipv6_confirm_neigh(struct net_device *dev,
+					const void *pkey)
+{
+	struct neighbour *n;
+
+	rcu_read_lock_bh();
+	n = __ipv6_neigh_lookup_noref(dev, pkey);
+	if (n) {
+		unsigned long now = jiffies;
+
+		/* avoid dirtying neighbour */
+		if (n->confirmed != now)
+			n->confirmed = now;
+	}
+	rcu_read_unlock_bh();
+}
+
 int ndisc_init(void);
 int ndisc_late_init(void);
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 4b7c231..cb494a5 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -154,6 +154,7 @@ static u32 *ipv4_cow_metrics(struct dst_entry *dst, unsigned long old)
 static struct neighbour *ipv4_neigh_lookup(const struct dst_entry *dst,
 					   struct sk_buff *skb,
 					   const void *daddr);
+static void ipv4_confirm_neigh(const struct dst_entry *dst, const void *daddr);
 
 static struct dst_ops ipv4_dst_ops = {
 	.family =		AF_INET,
@@ -168,6 +169,7 @@ static struct neighbour *ipv4_neigh_lookup(const struct dst_entry *dst,
 	.redirect =		ip_do_redirect,
 	.local_out =		__ip_local_out,
 	.neigh_lookup =		ipv4_neigh_lookup,
+	.confirm_neigh =	ipv4_confirm_neigh,
 };
 
 #define ECN_OR_COST(class)	TC_PRIO_##class
@@ -461,6 +463,23 @@ static struct neighbour *ipv4_neigh_lookup(const struct dst_entry *dst,
 	return neigh_create(&arp_tbl, pkey, dev);
 }
 
+static void ipv4_confirm_neigh(const struct dst_entry *dst, const void *daddr)
+{
+	struct net_device *dev = dst->dev;
+	const __be32 *pkey = daddr;
+	const struct rtable *rt;
+
+	rt = (const struct rtable *)dst;
+	if (rt->rt_gateway)
+		pkey = (const __be32 *)&rt->rt_gateway;
+	else if (!daddr ||
+		 (rt->rt_flags &
+		  (RTCF_MULTICAST | RTCF_BROADCAST | RTCF_LOCAL)))
+		return;
+
+	__ipv4_confirm_neigh(dev, *(__force u32 *)pkey);
+}
+
 #define IP_IDENTS_SZ 2048u
 
 static atomic_t *ip_idents __read_mostly;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 4b1f0f9..c876940 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -217,6 +217,21 @@ static struct neighbour *ip6_neigh_lookup(const struct dst_entry *dst,
 	return neigh_create(&nd_tbl, daddr, dst->dev);
 }
 
+static void ip6_confirm_neigh(const struct dst_entry *dst, const void *daddr)
+{
+	struct net_device *dev = dst->dev;
+	struct rt6_info *rt = (struct rt6_info *)dst;
+
+	daddr = choose_neigh_daddr(rt, NULL, daddr);
+	if (!daddr)
+		return;
+	if (dev->flags & (IFF_NOARP | IFF_LOOPBACK))
+		return;
+	if (ipv6_addr_is_multicast((const struct in6_addr *)daddr))
+		return;
+	__ipv6_confirm_neigh(dev, daddr);
+}
+
 static struct dst_ops ip6_dst_ops_template = {
 	.family			=	AF_INET6,
 	.gc			=	ip6_dst_gc,
@@ -233,6 +248,7 @@ static struct neighbour *ip6_neigh_lookup(const struct dst_entry *dst,
 	.redirect		=	rt6_do_redirect,
 	.local_out		=	__ip6_local_out,
 	.neigh_lookup		=	ip6_neigh_lookup,
+	.confirm_neigh		=	ip6_confirm_neigh,
 };
 
 static unsigned int ip6_blackhole_mtu(const struct dst_entry *dst)
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 177e208..c010ee0 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2856,6 +2856,20 @@ static struct neighbour *xfrm_neigh_lookup(const struct dst_entry *dst,
 	return dst->path->ops->neigh_lookup(dst, skb, daddr);
 }
 
+static void xfrm_confirm_neigh(const struct dst_entry *dst, const void *daddr)
+{
+	const struct dst_entry *path = dst->path;
+
+	if (path == dst) {
+		dst->ops->confirm_neigh(dst, daddr);
+	} else {
+		/* daddr can be from different family and we need the
+		 * tunnel address. How to get it?
+		 */
+		path->ops->confirm_neigh(path, NULL);
+	}
+}
+
 int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo)
 {
 	int err = 0;
@@ -2882,6 +2896,8 @@ int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo)
 			dst_ops->link_failure = xfrm_link_failure;
 		if (likely(dst_ops->neigh_lookup == NULL))
 			dst_ops->neigh_lookup = xfrm_neigh_lookup;
+		if (likely(!dst_ops->confirm_neigh))
+			dst_ops->confirm_neigh = xfrm_confirm_neigh;
 		if (likely(afinfo->garbage_collect == NULL))
 			afinfo->garbage_collect = xfrm_garbage_collect_deferred;
 		rcu_assign_pointer(xfrm_policy_afinfo[afinfo->family], afinfo);
-- 
1.9.3
