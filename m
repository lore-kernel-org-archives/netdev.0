From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH v2 net-next 9/9] ipv6: rename rt_genid_bump_ipv6 to rt6_inval_dst_caches
Date: Sun, 21 Sep 2014 16:11:53 +0200
Message-ID: <6756ccda4f3a3cb9e7e70b2051c53a19d8792aff.1411308211.git.hannes@stressinduktion.org>
References: <cover.1411308211.git.hannes@stressinduktion.org>
Cc: eric.dumazet@gmail.com, hideaki@yoshifuji.org, vyasevich@gmail.com,
	nicolas.dichtel@6wind.com, kafai@fb.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:36210 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751421AbaIUOMO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Sep 2014 10:12:14 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by gateway2.nyi.internal (Postfix) with ESMTP id 64914207ED
	for <netdev@vger.kernel.org>; Sun, 21 Sep 2014 10:12:14 -0400 (EDT)
In-Reply-To: <cover.1411308211.git.hannes@stressinduktion.org>
In-Reply-To: <cover.1411308211.git.hannes@stressinduktion.org>
References: <cover.1411308211.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also rename ipv4 and ipv6 agnostic rt_genid_bump_all to
rt_inval_dst_caches as we don't care how the flushing is implemented in
the protocols.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: YOSHIFUJI Hideaki <hideaki@yoshifuji.org>
Cc: Vlad Yasevich <vyasevich@gmail.com>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Cc: Martin Lau <kafai@fb.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/net_namespace.h     | 8 ++++----
 net/ipv6/addrconf.c             | 2 +-
 net/xfrm/xfrm_policy.c          | 2 +-
 security/selinux/include/xfrm.h | 2 +-
 4 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 61aad36..e73b80f 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -354,13 +354,13 @@ static inline void rt_genid_bump_ipv4(struct net *net)
 
 #if IS_ENABLED(CONFIG_IPV6)
 extern void (*__fib6_flush_trees)(struct net *);
-static inline void rt_genid_bump_ipv6(struct net *net)
+static inline void rt6_dst_inval_caches(struct net *net)
 {
 	if (__fib6_flush_trees)
 		__fib6_flush_trees(net);
 }
 #else
-static inline void rt_genid_bump_ipv6(struct net *net)
+static inline void rt6_dst_inval_caches(struct net *net)
 {
 }
 #endif
@@ -374,10 +374,10 @@ net_ieee802154_lowpan(struct net *net)
 #endif
 
 /* For callers who don't really care about whether it's IPv4 or IPv6 */
-static inline void rt_genid_bump_all(struct net *net)
+static inline void dst_inval_caches(struct net *net)
 {
 	rt_genid_bump_ipv4(net);
-	rt_genid_bump_ipv6(net);
+	rt6_dst_inval_caches(net);
 }
 
 static inline int fnhe_genid(struct net *net)
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index a2d2626..0c2aade 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4782,7 +4782,7 @@ static void __ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
 		if (ip6_del_rt(ifp->rt))
 			dst_free(&ifp->rt->dst);
 
-		rt_genid_bump_ipv6(net);
+		rt6_dst_inval_caches(net);
 		break;
 	}
 	atomic_inc(&net->ipv6.dev_addr_genid);
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index beeed60..6d09195 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -665,7 +665,7 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 	if (policy->family == AF_INET)
 		rt_genid_bump_ipv4(net);
 	else
-		rt_genid_bump_ipv6(net);
+		rt6_dst_inval_caches(net);
 
 	if (delpol) {
 		xfrm_policy_requeue(delpol, policy);
diff --git a/security/selinux/include/xfrm.h b/security/selinux/include/xfrm.h
index 1450f85..a1c5f97 100644
--- a/security/selinux/include/xfrm.h
+++ b/security/selinux/include/xfrm.h
@@ -49,7 +49,7 @@ static inline void selinux_xfrm_notify_policyload(void)
 	rtnl_lock();
 	for_each_net(net) {
 		atomic_inc(&net->xfrm.flow_cache_genid);
-		rt_genid_bump_all(net);
+		dst_inval_caches(net);
 	}
 	rtnl_unlock();
 }
-- 
1.9.3
