From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 13/53] netns xfrm: per-netns km_waitq
Date: Tue, 25 Nov 2008 20:26:45 +0300
Message-ID: <1227634045-27534-13-git-send-email-adobriyan@gmail.com>
References: <1227634045-27534-1-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-2-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-3-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-4-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-5-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-6-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-7-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-8-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-9-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-10-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-11-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-12-git-send-email-adobriyan@gmail.com>
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.178]:32462 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753676AbYKYRYE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 12:24:04 -0500
Received: by ik-out-1112.google.com with SMTP id c29so47248ika.5
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 09:24:02 -0800 (PST)
In-Reply-To: <1227634045-27534-12-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dissalow spurious wakeups in __xfrm_lookup().

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/net/netns/xfrm.h |    3 +++
 include/net/xfrm.h       |    1 -
 net/key/af_key.c         |    2 +-
 net/xfrm/xfrm_policy.c   |    4 ++--
 net/xfrm/xfrm_state.c    |   16 +++++++---------
 5 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
index 8055535..2a383c8 100644
--- a/include/net/netns/xfrm.h
+++ b/include/net/netns/xfrm.h
@@ -2,6 +2,7 @@
 #define __NETNS_XFRM_H
 
 #include <linux/list.h>
+#include <linux/wait.h>
 #include <linux/workqueue.h>
 
 struct netns_xfrm {
@@ -22,6 +23,8 @@ struct netns_xfrm {
 	struct work_struct	state_hash_work;
 	struct hlist_head	state_gc_list;
 	struct work_struct	state_gc_work;
+
+	wait_queue_head_t	km_waitq;
 };
 
 #endif
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 9da8903..0d4353c 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1459,7 +1459,6 @@ extern int xfrm_migrate(struct xfrm_selector *sel, u8 dir, u8 type,
 			struct xfrm_kmaddress *k);
 #endif
 
-extern wait_queue_head_t km_waitq;
 extern int km_new_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr, __be16 sport);
 extern void km_policy_expired(struct xfrm_policy *pol, int dir, int hard, u32 pid);
 extern int km_report(u8 proto, struct xfrm_selector *sel, xfrm_address_t *addr);
diff --git a/net/key/af_key.c b/net/key/af_key.c
index bde8aad..f202ba6 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1411,7 +1411,7 @@ static int pfkey_acquire(struct sock *sk, struct sk_buff *skb, struct sadb_msg *
 	spin_lock_bh(&x->lock);
 	if (x->km.state == XFRM_STATE_ACQ) {
 		x->km.state = XFRM_STATE_ERROR;
-		wake_up(&km_waitq);
+		wake_up(&init_net.xfrm.km_waitq);
 	}
 	spin_unlock_bh(&x->lock);
 	xfrm_state_put(x);
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 8e7671b..cf2bf3a 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1691,11 +1691,11 @@ restart:
 			if (err == -EAGAIN && (flags & XFRM_LOOKUP_WAIT)) {
 				DECLARE_WAITQUEUE(wait, current);
 
-				add_wait_queue(&km_waitq, &wait);
+				add_wait_queue(&init_net.xfrm.km_waitq, &wait);
 				set_current_state(TASK_INTERRUPTIBLE);
 				schedule();
 				set_current_state(TASK_RUNNING);
-				remove_wait_queue(&km_waitq, &wait);
+				remove_wait_queue(&init_net.xfrm.km_waitq, &wait);
 
 				nx = xfrm_tmpl_resolve(pols, npols, fl, xfrm, family);
 
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 69c0b06..24bd89e 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -170,9 +170,6 @@ out_unlock:
 	mutex_unlock(&hash_resize_mutex);
 }
 
-DECLARE_WAIT_QUEUE_HEAD(km_waitq);
-EXPORT_SYMBOL(km_waitq);
-
 static DEFINE_RWLOCK(xfrm_state_afinfo_lock);
 static struct xfrm_state_afinfo *xfrm_state_afinfo[NPROTO];
 
@@ -399,7 +396,7 @@ static void xfrm_state_gc_task(struct work_struct *work)
 	hlist_for_each_entry_safe(x, entry, tmp, &gc_list, gclist)
 		xfrm_state_gc_destroy(x);
 
-	wake_up(&km_waitq);
+	wake_up(&net->xfrm.km_waitq);
 }
 
 static inline unsigned long make_jiffies(long secs)
@@ -470,7 +467,7 @@ resched:
 expired:
 	if (x->km.state == XFRM_STATE_ACQ && x->id.spi == 0) {
 		x->km.state = XFRM_STATE_EXPIRED;
-		wake_up(&km_waitq);
+		wake_up(&init_net.xfrm.km_waitq);
 		next = 2;
 		goto resched;
 	}
@@ -638,7 +635,7 @@ restart:
 
 out:
 	spin_unlock_bh(&xfrm_state_lock);
-	wake_up(&km_waitq);
+	wake_up(&init_net.xfrm.km_waitq);
 	return err;
 }
 EXPORT_SYMBOL(xfrm_state_flush);
@@ -929,7 +926,7 @@ static void __xfrm_state_insert(struct xfrm_state *x)
 	if (x->replay_maxage)
 		mod_timer(&x->rtimer, jiffies + x->replay_maxage);
 
-	wake_up(&km_waitq);
+	wake_up(&init_net.xfrm.km_waitq);
 
 	init_net.xfrm.state_num++;
 
@@ -1743,7 +1740,7 @@ void km_state_expired(struct xfrm_state *x, int hard, u32 pid)
 	km_state_notify(x, &c);
 
 	if (hard)
-		wake_up(&km_waitq);
+		wake_up(&init_net.xfrm.km_waitq);
 }
 
 EXPORT_SYMBOL(km_state_expired);
@@ -1794,7 +1791,7 @@ void km_policy_expired(struct xfrm_policy *pol, int dir, int hard, u32 pid)
 	km_policy_notify(pol, dir, &c);
 
 	if (hard)
-		wake_up(&km_waitq);
+		wake_up(&init_net.xfrm.km_waitq);
 }
 EXPORT_SYMBOL(km_policy_expired);
 
@@ -2089,6 +2086,7 @@ int __net_init xfrm_state_init(struct net *net)
 	INIT_WORK(&net->xfrm.state_hash_work, xfrm_hash_resize);
 	INIT_HLIST_HEAD(&net->xfrm.state_gc_list);
 	INIT_WORK(&net->xfrm.state_gc_work, xfrm_state_gc_task);
+	init_waitqueue_head(&net->xfrm.km_waitq);
 	return 0;
 
 out_byspi:
-- 
1.5.6.5

