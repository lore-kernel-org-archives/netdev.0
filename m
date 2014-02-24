From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 11/13] xfrm: Remove caching of xfrm_policy_sk_bundles
Date: Mon, 24 Feb 2014 10:59:59 +0100
Message-ID: <1393236001-2445-12-git-send-email-steffen.klassert@secunet.com>
References: <1393236001-2445-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:39119 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751915AbaBXKAO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Feb 2014 05:00:14 -0500
In-Reply-To: <1393236001-2445-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We currently cache socket policy bundles at xfrm_policy_sk_bundles.
These cached bundles are never used. Instead we create and cache
a new one whenever xfrm_lookup() is called on a socket policy.

Most protocols cache the used routes to the socket, so let's
remove the unused caching of socket policy bundles in xfrm.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/netns/xfrm.h |    1 -
 net/xfrm/xfrm_policy.c   |   28 ----------------------------
 2 files changed, 29 deletions(-)

diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
index 52d0086..51f0dce 100644
--- a/include/net/netns/xfrm.h
+++ b/include/net/netns/xfrm.h
@@ -59,7 +59,6 @@ struct netns_xfrm {
 	struct dst_ops		xfrm6_dst_ops;
 #endif
 	spinlock_t xfrm_state_lock;
-	spinlock_t xfrm_policy_sk_bundle_lock;
 	rwlock_t xfrm_policy_lock;
 	struct mutex xfrm_cfg_mutex;
 
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 2232c6f..bb3669d 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -39,8 +39,6 @@
 #define XFRM_QUEUE_TMO_MAX ((unsigned)(60*HZ))
 #define XFRM_MAX_QUEUE_LEN	100
 
-static struct dst_entry *xfrm_policy_sk_bundles;
-
 static DEFINE_SPINLOCK(xfrm_policy_afinfo_lock);
 static struct xfrm_policy_afinfo __rcu *xfrm_policy_afinfo[NPROTO]
 						__read_mostly;
@@ -2109,13 +2107,6 @@ struct dst_entry *xfrm_lookup(struct net *net, struct dst_entry *dst_orig,
 				goto no_transform;
 			}
 
-			dst_hold(&xdst->u.dst);
-
-			spin_lock_bh(&net->xfrm.xfrm_policy_sk_bundle_lock);
-			xdst->u.dst.next = xfrm_policy_sk_bundles;
-			xfrm_policy_sk_bundles = &xdst->u.dst;
-			spin_unlock_bh(&net->xfrm.xfrm_policy_sk_bundle_lock);
-
 			route = xdst->route;
 		}
 	}
@@ -2549,33 +2540,15 @@ static struct dst_entry *xfrm_negative_advice(struct dst_entry *dst)
 	return dst;
 }
 
-static void __xfrm_garbage_collect(struct net *net)
-{
-	struct dst_entry *head, *next;
-
-	spin_lock_bh(&net->xfrm.xfrm_policy_sk_bundle_lock);
-	head = xfrm_policy_sk_bundles;
-	xfrm_policy_sk_bundles = NULL;
-	spin_unlock_bh(&net->xfrm.xfrm_policy_sk_bundle_lock);
-
-	while (head) {
-		next = head->next;
-		dst_free(head);
-		head = next;
-	}
-}
-
 void xfrm_garbage_collect(struct net *net)
 {
 	flow_cache_flush(net);
-	__xfrm_garbage_collect(net);
 }
 EXPORT_SYMBOL(xfrm_garbage_collect);
 
 static void xfrm_garbage_collect_deferred(struct net *net)
 {
 	flow_cache_flush_deferred(net);
-	__xfrm_garbage_collect(net);
 }
 
 static void xfrm_init_pmtu(struct dst_entry *dst)
@@ -2944,7 +2917,6 @@ static int __net_init xfrm_net_init(struct net *net)
 	/* Initialize the per-net locks here */
 	spin_lock_init(&net->xfrm.xfrm_state_lock);
 	rwlock_init(&net->xfrm.xfrm_policy_lock);
-	spin_lock_init(&net->xfrm.xfrm_policy_sk_bundle_lock);
 	mutex_init(&net->xfrm.xfrm_cfg_mutex);
 
 	flow_cache_init(net);
-- 
1.7.9.5
