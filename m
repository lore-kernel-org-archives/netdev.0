From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 11/53] netns xfrm: per-netns state GC list
Date: Tue, 25 Nov 2008 20:26:43 +0300
Message-ID: <1227634045-27534-11-git-send-email-adobriyan@gmail.com>
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
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:40948 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753233AbYKYRX6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 12:23:58 -0500
Received: by ey-out-2122.google.com with SMTP id 6so23228eyi.37
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 09:23:56 -0800 (PST)
In-Reply-To: <1227634045-27534-10-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

km_waitq is going to be made per-netns to disallow spurious wakeups
in __xfrm_lookup().

To not wakeup after every garbage-collected xfrm_state (which potentially
can be from different netns) make state GC list per-netns.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/net/netns/xfrm.h |    1 +
 net/xfrm/xfrm_state.c    |    6 +++---
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
index bd68802..8ceb765 100644
--- a/include/net/netns/xfrm.h
+++ b/include/net/netns/xfrm.h
@@ -20,6 +20,7 @@ struct netns_xfrm {
 	unsigned int		state_hmask;
 	unsigned int		state_num;
 	struct work_struct	state_hash_work;
+	struct hlist_head	state_gc_list;
 };
 
 #endif
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 1b2a72c..864a974 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -177,7 +177,6 @@ static DEFINE_RWLOCK(xfrm_state_afinfo_lock);
 static struct xfrm_state_afinfo *xfrm_state_afinfo[NPROTO];
 
 static struct work_struct xfrm_state_gc_work;
-static HLIST_HEAD(xfrm_state_gc_list);
 static DEFINE_SPINLOCK(xfrm_state_gc_lock);
 
 int __xfrm_state_delete(struct xfrm_state *x);
@@ -394,7 +393,7 @@ static void xfrm_state_gc_task(struct work_struct *data)
 	struct hlist_head gc_list;
 
 	spin_lock_bh(&xfrm_state_gc_lock);
-	hlist_move_list(&xfrm_state_gc_list, &gc_list);
+	hlist_move_list(&init_net.xfrm.state_gc_list, &gc_list);
 	spin_unlock_bh(&xfrm_state_gc_lock);
 
 	hlist_for_each_entry_safe(x, entry, tmp, &gc_list, gclist)
@@ -527,7 +526,7 @@ void __xfrm_state_destroy(struct xfrm_state *x)
 	WARN_ON(x->km.state != XFRM_STATE_DEAD);
 
 	spin_lock_bh(&xfrm_state_gc_lock);
-	hlist_add_head(&x->gclist, &xfrm_state_gc_list);
+	hlist_add_head(&x->gclist, &init_net.xfrm.state_gc_list);
 	spin_unlock_bh(&xfrm_state_gc_lock);
 	schedule_work(&xfrm_state_gc_work);
 }
@@ -2088,6 +2087,7 @@ int __net_init xfrm_state_init(struct net *net)
 
 	net->xfrm.state_num = 0;
 	INIT_WORK(&net->xfrm.state_hash_work, xfrm_hash_resize);
+	INIT_HLIST_HEAD(&net->xfrm.state_gc_list);
 	INIT_WORK(&xfrm_state_gc_work, xfrm_state_gc_task);
 	return 0;
 
-- 
1.5.6.5

