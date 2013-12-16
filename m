From: Fan Du <fan.du@windriver.com>
Subject: [PATCH net-next] xfrm: Namespacify xfrm_policy_sk_bundles
Date: Mon, 16 Dec 2013 18:26:08 +0800
Message-ID: <1387189568-31769-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:35378 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753019Ab3LPK0M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 05:26:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

xfrm_policy_sk_bundles, protected by net->xfrm.xfrm_policy_sk_bundle_lock
should be put into netns xfrm structure, otherwise xfrm_policy_sk_bundles
can be corrupted from different net namespace.

And also since xfrm_policy_sk_bundles is only used in xfrm_lookup and
__xfrm_garbage_collect, both in process context, no reason we should turn
BH off. In addition we can use xchg to avoid the spinlock, inspired by
discussion in: http://marc.info/?l=linux-netdev&m=138713363113003&w=2

Signed-off-by: Fan Du <fan.du@windriver.com>
---
Please note this patch is based on commit 283bc9f35bbbcb0e9ab4e6d2427da7f9f710d52d
("xfrm: Namespacify xfrm state/policy locks"), which is still in ipsec-next tree.

---
 include/net/netns/xfrm.h |    2 +-
 net/xfrm/xfrm_policy.c   |   17 +++--------------
 2 files changed, 4 insertions(+), 15 deletions(-)

diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
index 1006a26..4a30b1b 100644
--- a/include/net/netns/xfrm.h
+++ b/include/net/netns/xfrm.h
@@ -58,9 +58,9 @@ struct netns_xfrm {
 	struct dst_ops		xfrm6_dst_ops;
 #endif
 	spinlock_t xfrm_state_lock;
-	spinlock_t xfrm_policy_sk_bundle_lock;
 	rwlock_t xfrm_policy_lock;
 	struct mutex xfrm_cfg_mutex;
+	struct dst_entry *xfrm_policy_sk_bundles;
 };
 
 #endif
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index a7487f3..26d79c0 100644
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
@@ -2108,12 +2106,8 @@ struct dst_entry *xfrm_lookup(struct net *net, struct dst_entry *dst_orig,
 			}
 
 			dst_hold(&xdst->u.dst);
-
-			spin_lock_bh(&net->xfrm.xfrm_policy_sk_bundle_lock);
-			xdst->u.dst.next = xfrm_policy_sk_bundles;
-			xfrm_policy_sk_bundles = &xdst->u.dst;
-			spin_unlock_bh(&net->xfrm.xfrm_policy_sk_bundle_lock);
-
+			xdst->u.dst.next = xchg(&net->xfrm.xfrm_policy_sk_bundles,
+						&xdst->u.dst);
 			route = xdst->route;
 		}
 	}
@@ -2551,11 +2545,7 @@ static void __xfrm_garbage_collect(struct net *net)
 {
 	struct dst_entry *head, *next;
 
-	spin_lock_bh(&net->xfrm.xfrm_policy_sk_bundle_lock);
-	head = xfrm_policy_sk_bundles;
-	xfrm_policy_sk_bundles = NULL;
-	spin_unlock_bh(&net->xfrm.xfrm_policy_sk_bundle_lock);
-
+	head = xchg(&net->xfrm.xfrm_policy_sk_bundles, NULL);
 	while (head) {
 		next = head->next;
 		dst_free(head);
@@ -2942,7 +2932,6 @@ static int __net_init xfrm_net_init(struct net *net)
 	/* Initialize the per-net locks here */
 	spin_lock_init(&net->xfrm.xfrm_state_lock);
 	rwlock_init(&net->xfrm.xfrm_policy_lock);
-	spin_lock_init(&net->xfrm.xfrm_policy_sk_bundle_lock);
 	mutex_init(&net->xfrm.xfrm_cfg_mutex);
 
 	return 0;
-- 
1.7.9.5
