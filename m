From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 12/53] netns xfrm: per-netns state GC work
Date: Tue, 25 Nov 2008 20:26:44 +0300
Message-ID: <1227634045-27534-12-git-send-email-adobriyan@gmail.com>
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
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.26]:41337 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752821AbYKYRYB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 12:24:01 -0500
Received: by ey-out-2122.google.com with SMTP id 6so23232eyi.37
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 09:23:59 -0800 (PST)
In-Reply-To: <1227634045-27534-11-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

State GC is per-netns, and this is part of it.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/net/netns/xfrm.h |    1 +
 net/xfrm/xfrm_state.c    |   10 +++++-----
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
index 8ceb765..8055535 100644
--- a/include/net/netns/xfrm.h
+++ b/include/net/netns/xfrm.h
@@ -21,6 +21,7 @@ struct netns_xfrm {
 	unsigned int		state_num;
 	struct work_struct	state_hash_work;
 	struct hlist_head	state_gc_list;
+	struct work_struct	state_gc_work;
 };
 
 #endif
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 864a974..69c0b06 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -176,7 +176,6 @@ EXPORT_SYMBOL(km_waitq);
 static DEFINE_RWLOCK(xfrm_state_afinfo_lock);
 static struct xfrm_state_afinfo *xfrm_state_afinfo[NPROTO];
 
-static struct work_struct xfrm_state_gc_work;
 static DEFINE_SPINLOCK(xfrm_state_gc_lock);
 
 int __xfrm_state_delete(struct xfrm_state *x);
@@ -386,14 +385,15 @@ static void xfrm_state_gc_destroy(struct xfrm_state *x)
 	kfree(x);
 }
 
-static void xfrm_state_gc_task(struct work_struct *data)
+static void xfrm_state_gc_task(struct work_struct *work)
 {
+	struct net *net = container_of(work, struct net, xfrm.state_gc_work);
 	struct xfrm_state *x;
 	struct hlist_node *entry, *tmp;
 	struct hlist_head gc_list;
 
 	spin_lock_bh(&xfrm_state_gc_lock);
-	hlist_move_list(&init_net.xfrm.state_gc_list, &gc_list);
+	hlist_move_list(&net->xfrm.state_gc_list, &gc_list);
 	spin_unlock_bh(&xfrm_state_gc_lock);
 
 	hlist_for_each_entry_safe(x, entry, tmp, &gc_list, gclist)
@@ -528,7 +528,7 @@ void __xfrm_state_destroy(struct xfrm_state *x)
 	spin_lock_bh(&xfrm_state_gc_lock);
 	hlist_add_head(&x->gclist, &init_net.xfrm.state_gc_list);
 	spin_unlock_bh(&xfrm_state_gc_lock);
-	schedule_work(&xfrm_state_gc_work);
+	schedule_work(&init_net.xfrm.state_gc_work);
 }
 EXPORT_SYMBOL(__xfrm_state_destroy);
 
@@ -2088,7 +2088,7 @@ int __net_init xfrm_state_init(struct net *net)
 	net->xfrm.state_num = 0;
 	INIT_WORK(&net->xfrm.state_hash_work, xfrm_hash_resize);
 	INIT_HLIST_HEAD(&net->xfrm.state_gc_list);
-	INIT_WORK(&xfrm_state_gc_work, xfrm_state_gc_task);
+	INIT_WORK(&net->xfrm.state_gc_work, xfrm_state_gc_task);
 	return 0;
 
 out_byspi:
-- 
1.5.6.5

