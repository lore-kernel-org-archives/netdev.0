From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv2 ipsec-next] xfrm: Namespacify xfrm_policy_sk_bundles
Date: Wed, 18 Dec 2013 11:34:18 +0800
Message-ID: <1387337658-28951-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:41091 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752574Ab3LRDeR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 22:34:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

xfrm_policy_sk_bundles, protected by net->xfrm.xfrm_policy_sk_bundle_lock
should be put into netns xfrm structure, otherwise xfrm_policy_sk_bundles
can be corrupted from different net namespace.

Moreover current xfrm_policy_sk_bundle_lock used in below two scenarios:

1. xfrm_lookup(Process context)  vs  __xfrm_garbage_collect(softirq context)
2. xfrm_lookup(Process context)  vs  __xfrm_garbage_collect(Process context
                                                when SPD change or dev down) 

we can use xchg to avoid the spinlock, at the same time cover above scenarios,
inspired by discussion in: http://marc.info/?l=linux-netdev&m=138713363113003&w=2

Signed-off-by: Fan Du <fan.du@windriver.com>
---
v2:
  Fix incorrect commit log.

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
