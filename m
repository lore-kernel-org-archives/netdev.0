From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCHv4 net-next] xfrm: Namespacify xfrm_policy_sk_bundles
Date: Thu, 9 Jan 2014 13:38:03 +0100
Message-ID: <20140109123803.GZ31491@secunet.com>
References: <1387419308.19078.343.camel@edumazet-glaptop2.roam.corp.google.com>
 <52B26553.9070103@windriver.com>
 <1387424650.19078.355.camel@edumazet-glaptop2.roam.corp.google.com>
 <52B3BAD1.30205@windriver.com>
 <20131224103521.GB29716@secunet.com>
 <52BA7DE4.9070404@windriver.com>
 <20131225101104.224f9b87@vostro>
 <52BA9AEA.7050301@windriver.com>
 <20140106103512.GR31491@secunet.com>
 <52CB69DA.7000101@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Timo Teras <timo.teras@iki.fi>,
	Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:47084 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751850AbaAIMiH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 07:38:07 -0500
Content-Disposition: inline
In-Reply-To: <52CB69DA.7000101@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 07, 2014 at 10:43:38AM +0800, Fan Du wrote:
> 
> Yes, I tested sk policy with udp, when transmit, dst will be cached into sk
> by sk_dst_set. Let's leave current implementation as it is.
> 
> Please kindly review if there is any concern about v4.

Why do you want to keep the current implementation? We don't
use the cached bundles. I'd remove this caching with the patch
below during the next development cycle if nobody has a good
reason why we should keep it.


Subject: [PATCH RFC] xfrm: Remove caching of xfrm_policy_sk_bundles

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
index 1006a26..cf65269 100644
--- a/include/net/netns/xfrm.h
+++ b/include/net/netns/xfrm.h
@@ -58,7 +58,6 @@ struct netns_xfrm {
 	struct dst_ops		xfrm6_dst_ops;
 #endif
 	spinlock_t xfrm_state_lock;
-	spinlock_t xfrm_policy_sk_bundle_lock;
 	rwlock_t xfrm_policy_lock;
 	struct mutex xfrm_cfg_mutex;
 };
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index a7487f3..1c79ca8 100644
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
@@ -2107,13 +2105,6 @@ struct dst_entry *xfrm_lookup(struct net *net, struct dst_entry *dst_orig,
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
@@ -2547,33 +2538,15 @@ static struct dst_entry *xfrm_negative_advice(struct dst_entry *dst)
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
 	flow_cache_flush();
-	__xfrm_garbage_collect(net);
 }
 EXPORT_SYMBOL(xfrm_garbage_collect);
 
 static void xfrm_garbage_collect_deferred(struct net *net)
 {
 	flow_cache_flush_deferred();
-	__xfrm_garbage_collect(net);
 }
 
 static void xfrm_init_pmtu(struct dst_entry *dst)
@@ -2942,7 +2915,6 @@ static int __net_init xfrm_net_init(struct net *net)
 	/* Initialize the per-net locks here */
 	spin_lock_init(&net->xfrm.xfrm_state_lock);
 	rwlock_init(&net->xfrm.xfrm_policy_lock);
-	spin_lock_init(&net->xfrm.xfrm_policy_sk_bundle_lock);
 	mutex_init(&net->xfrm.xfrm_cfg_mutex);
 
 	return 0;
-- 
1.7.9.5
