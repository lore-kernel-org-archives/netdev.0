From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 04/13] xfrm: policy: remove garbage_collect callback
Date: Thu, 16 Feb 2017 13:18:38 +0100
Message-ID: <1487247527-17925-5-git-send-email-steffen.klassert@secunet.com>
References: <1487247527-17925-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:49274 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754149AbdBPMS4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Feb 2017 07:18:56 -0500
In-Reply-To: <1487247527-17925-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Just call xfrm_garbage_collect_deferred() directly.
This gets rid of a write to afinfo in register/unregister and allows to
constify afinfo later on.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h      | 2 +-
 net/ipv4/xfrm4_policy.c | 2 +-
 net/ipv6/xfrm6_policy.c | 2 +-
 net/xfrm/xfrm_policy.c  | 6 ++----
 4 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 39037b1..a22368e 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -282,7 +282,6 @@ struct xfrm_replay {
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
index 6a7ff69..77ca91d 100644
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
index e0f71c0..c273f22 100644
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
index 794148f7..80695a1 100644
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
1.9.1
