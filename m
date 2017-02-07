From: Florian Westphal <fw@strlen.de>
Subject: [PATCH ipsec-next 3/6] xfrm: policy: remove garbage_collect callback
Date: Tue,  7 Feb 2017 15:00:16 +0100
Message-ID: <20170207140019.20269-4-fw@strlen.de>
References: <20170207140019.20269-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:56642 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754499AbdBGOCM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 09:02:12 -0500
In-Reply-To: <20170207140019.20269-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just call xfrm_garbage_collect_deferred() directly.
This gets rid of a write to afinfo in register/unregister and allows to
constify afinfo later on.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/xfrm.h      | 2 +-
 net/ipv4/xfrm4_policy.c | 2 +-
 net/ipv6/xfrm6_policy.c | 2 +-
 net/xfrm/xfrm_policy.c  | 6 ++----
 4 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 39037b1cce7a..a22368edd105 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -282,7 +282,6 @@ struct xfrm_dst;
 struct xfrm_policy_afinfo {
 	unsigned short		family;
 	struct dst_ops		*dst_ops;
-	void			(*garbage_collect)(struct net *net);
 	struct dst_entry	*(*dst_lookup)(struct net *net,
 					       int tos, int oif,
 					       const xfrm_address_t *saddr,
@@ -1169,6 +1168,7 @@ static inline void xfrm_sk_free_policy(struct sock *sk)
 }
 
 void xfrm_garbage_collect(struct net *net);
+void xfrm_garbage_collect_deferred(struct net *net);
 
 #else
 
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 6a7ff6957535..77ca91d7b79c 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -219,7 +219,7 @@ static inline int xfrm4_garbage_collect(struct dst_ops *ops)
 {
 	struct net *net = container_of(ops, struct net, xfrm.xfrm4_dst_ops);
 
-	xfrm4_policy_afinfo.garbage_collect(net);
+	xfrm_garbage_collect_deferred(net);
 	return (dst_entries_get_slow(ops) > ops->gc_thresh * 2);
 }
 
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index e0f71c01d728..c273f22b12af 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -220,7 +220,7 @@ static inline int xfrm6_garbage_collect(struct dst_ops *ops)
 {
 	struct net *net = container_of(ops, struct net, xfrm.xfrm6_dst_ops);
 
-	xfrm6_policy_afinfo.garbage_collect(net);
+	xfrm_garbage_collect_deferred(net);
 	return dst_entries_get_fast(ops) > ops->gc_thresh * 2;
 }
 
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 794148f76ae2..80695a157b6e 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2733,10 +2733,11 @@ void xfrm_garbage_collect(struct net *net)
 }
 EXPORT_SYMBOL(xfrm_garbage_collect);
 
-static void xfrm_garbage_collect_deferred(struct net *net)
+void xfrm_garbage_collect_deferred(struct net *net)
 {
 	flow_cache_flush_deferred(net);
 }
+EXPORT_SYMBOL(xfrm_garbage_collect_deferred);
 
 static void xfrm_init_pmtu(struct dst_entry *dst)
 {
@@ -2873,8 +2874,6 @@ int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo)
 			dst_ops->link_failure = xfrm_link_failure;
 		if (likely(dst_ops->neigh_lookup == NULL))
 			dst_ops->neigh_lookup = xfrm_neigh_lookup;
-		if (likely(afinfo->garbage_collect == NULL))
-			afinfo->garbage_collect = xfrm_garbage_collect_deferred;
 		rcu_assign_pointer(xfrm_policy_afinfo[afinfo->family], afinfo);
 	}
 	spin_unlock(&xfrm_policy_afinfo_lock);
@@ -2901,7 +2900,6 @@ void xfrm_policy_unregister_afinfo(struct xfrm_policy_afinfo *afinfo)
 	dst_ops->check = NULL;
 	dst_ops->negative_advice = NULL;
 	dst_ops->link_failure = NULL;
-	afinfo->garbage_collect = NULL;
 }
 EXPORT_SYMBOL(xfrm_policy_unregister_afinfo);
 
-- 
2.10.2
