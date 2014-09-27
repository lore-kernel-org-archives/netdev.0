From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] ipv6: remove rt6i_genid
Date: Sun, 28 Sep 2014 00:46:06 +0200
Message-ID: <7e1b4e2dbe855fa461a4e87e0482ac16b6982c2f.1411857958.git.hannes@stressinduktion.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	YOSHIFUJI Hideaki <hideaki@yoshifuji.org>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Martin Lau <kafai@fb.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:40208 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753178AbaI0WqO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Sep 2014 18:46:14 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by gateway2.nyi.internal (Postfix) with ESMTP id 26DB5209A9
	for <netdev@vger.kernel.org>; Sat, 27 Sep 2014 18:46:14 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet noticed that all no-nonexthop or no-gateway routes which
are already marked DST_HOST (e.g. input routes routes) will always be
invalidated during sk_dst_check. Thus per-socket dst caching absolutely
had no effect and early demuxing had no effect.

Thus this patch removes rt6i_genid: fn_sernum already gets modified during
add operations, so we only must ensure we mutate fn_sernum during ipv6
address remove operations. This is a fairly cost extensive operations,
but address removal should not happen that often. Also our mtu update
functions do the same and we heard no complains so far. xfrm policy
changes also cause a call into fib6_flush_trees. Also plug a hole in
rt6_info (no cacheline changes).

I verified via tracing that this change has effect.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: YOSHIFUJI Hideaki <hideaki@yoshifuji.org>
Cc: Vlad Yasevich <vyasevich@gmail.com>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Cc: Martin Lau <kafai@fb.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/ip6_fib.h       |  5 +----
 include/net/net_namespace.h | 20 +++-----------------
 net/ipv6/addrconf.c         |  3 ++-
 net/ipv6/addrconf_core.c    |  7 +++++++
 net/ipv6/ip6_fib.c          | 20 ++++++++++++++++++++
 net/ipv6/route.c            |  4 ----
 6 files changed, 33 insertions(+), 26 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 9bcb220..cf485f9 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -114,16 +114,13 @@ struct rt6_info {
 	u32				rt6i_flags;
 	struct rt6key			rt6i_src;
 	struct rt6key			rt6i_prefsrc;
-	u32				rt6i_metric;
 
 	struct inet6_dev		*rt6i_idev;
 	unsigned long			_rt6i_peer;
 
-	u32				rt6i_genid;
-
+	u32				rt6i_metric;
 	/* more non-fragment space at head required */
 	unsigned short			rt6i_nfheader_len;
-
 	u8				rt6i_protocol;
 };
 
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 361d260..e0d6466 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -352,26 +352,12 @@ static inline void rt_genid_bump_ipv4(struct net *net)
 	atomic_inc(&net->ipv4.rt_genid);
 }
 
-#if IS_ENABLED(CONFIG_IPV6)
-static inline int rt_genid_ipv6(struct net *net)
-{
-	return atomic_read(&net->ipv6.rt_genid);
-}
-
-static inline void rt_genid_bump_ipv6(struct net *net)
-{
-	atomic_inc(&net->ipv6.rt_genid);
-}
-#else
-static inline int rt_genid_ipv6(struct net *net)
-{
-	return 0;
-}
-
+extern void (*__fib6_flush_trees)(struct net *net);
 static inline void rt_genid_bump_ipv6(struct net *net)
 {
+	if (__fib6_flush_trees)
+		__fib6_flush_trees(net);
 }
-#endif
 
 #if IS_ENABLED(CONFIG_IEEE802154_6LOWPAN)
 static inline struct netns_ieee802154_lowpan *
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 3342ee6..3e118df 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4780,10 +4780,11 @@ static void __ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
 
 		if (ip6_del_rt(ifp->rt))
 			dst_free(&ifp->rt->dst);
+
+		rt_genid_bump_ipv6(net);
 		break;
 	}
 	atomic_inc(&net->ipv6.dev_addr_genid);
-	rt_genid_bump_ipv6(net);
 }
 
 static void ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
diff --git a/net/ipv6/addrconf_core.c b/net/ipv6/addrconf_core.c
index e696045..98cc4cd 100644
--- a/net/ipv6/addrconf_core.c
+++ b/net/ipv6/addrconf_core.c
@@ -8,6 +8,13 @@
 #include <net/addrconf.h>
 #include <net/ip.h>
 
+/* if ipv6 module registers this function is used by xfrm to force all
+ * sockets to relookup their nodes - this is fairly expensive, be
+ * careful
+ */
+void (*__fib6_flush_trees)(struct net *);
+EXPORT_SYMBOL(__fib6_flush_trees);
+
 #define IPV6_ADDR_SCOPE_TYPE(scope)	((scope) << 16)
 
 static inline unsigned int ipv6_addr_scope2type(unsigned int scope)
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 76b7f5e..97b9fa8 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1605,6 +1605,24 @@ static void fib6_prune_clones(struct net *net, struct fib6_node *fn)
 	fib6_clean_tree(net, fn, fib6_prune_clone, 1, NULL);
 }
 
+static int fib6_update_sernum(struct rt6_info *rt, void *arg)
+{
+	__u32 sernum = *(__u32 *)arg;
+
+	if (rt->rt6i_node &&
+	    rt->rt6i_node->fn_sernum != sernum)
+		rt->rt6i_node->fn_sernum = sernum;
+
+	return 0;
+}
+
+static void fib6_flush_trees(struct net *net)
+{
+	__u32 new_sernum = fib6_new_sernum();
+
+	fib6_clean_all(net, fib6_update_sernum, &new_sernum);
+}
+
 /*
  *	Garbage collection
  */
@@ -1788,6 +1806,8 @@ int __init fib6_init(void)
 			      NULL);
 	if (ret)
 		goto out_unregister_subsys;
+
+	__fib6_flush_trees = fib6_flush_trees;
 out:
 	return ret;
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index f23fbd2..bafde82 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -314,7 +314,6 @@ static inline struct rt6_info *ip6_dst_alloc(struct net *net,
 
 		memset(dst + 1, 0, sizeof(*rt) - sizeof(*dst));
 		rt6_init_peer(rt, table ? &table->tb6_peers : net->ipv6.peers);
-		rt->rt6i_genid = rt_genid_ipv6(net);
 		INIT_LIST_HEAD(&rt->rt6i_siblings);
 	}
 	return rt;
@@ -1098,9 +1097,6 @@ static struct dst_entry *ip6_dst_check(struct dst_entry *dst, u32 cookie)
 	 * DST_OBSOLETE_FORCE_CHK which forces validation calls down
 	 * into this function always.
 	 */
-	if (rt->rt6i_genid != rt_genid_ipv6(dev_net(rt->dst.dev)))
-		return NULL;
-
 	if (!rt->rt6i_node || (rt->rt6i_node->fn_sernum != cookie))
 		return NULL;
 
-- 
1.9.3
