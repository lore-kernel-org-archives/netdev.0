From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 19/53] netns xfrm: per-netns xfrm_policy_bydst hash
Date: Tue, 25 Nov 2008 20:26:51 +0300
Message-ID: <1227634045-27534-19-git-send-email-adobriyan@gmail.com>
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
 <1227634045-27534-13-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-14-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-15-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-16-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-17-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-18-git-send-email-adobriyan@gmail.com>
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.176]:41399 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751287AbYKYS5P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 13:57:15 -0500
Received: by ik-out-1112.google.com with SMTP id c29so81529ika.5
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 10:57:13 -0800 (PST)
In-Reply-To: <1227634045-27534-18-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/net/netns/xfrm.h |    6 +++++
 net/xfrm/xfrm_policy.c   |   57 ++++++++++++++++++++++++++-------------------
 2 files changed, 39 insertions(+), 24 deletions(-)

diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
index c756831..39cfa79 100644
--- a/include/net/netns/xfrm.h
+++ b/include/net/netns/xfrm.h
@@ -6,6 +6,11 @@
 #include <linux/workqueue.h>
 #include <linux/xfrm.h>
 
+struct xfrm_policy_hash {
+	struct hlist_head	*table;
+	unsigned int		hmask;
+};
+
 struct netns_xfrm {
 	struct list_head	state_all;
 	/*
@@ -31,6 +36,7 @@ struct netns_xfrm {
 	struct hlist_head	*policy_byidx;
 	unsigned int		policy_idx_hmask;
 	struct hlist_head	policy_inexact[XFRM_POLICY_MAX * 2];
+	struct xfrm_policy_hash	policy_bydst[XFRM_POLICY_MAX * 2];
 };
 
 #endif
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index ba4e95b..929b2fd 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -322,12 +322,6 @@ static void xfrm_policy_kill(struct xfrm_policy *policy)
 	schedule_work(&xfrm_policy_gc_work);
 }
 
-struct xfrm_policy_hash {
-	struct hlist_head	*table;
-	unsigned int		hmask;
-};
-
-static struct xfrm_policy_hash xfrm_policy_bydst[XFRM_POLICY_MAX*2] __read_mostly;
 static unsigned int xfrm_policy_hashmax __read_mostly = 1 * 1024 * 1024;
 
 static inline unsigned int idx_hash(u32 index)
@@ -337,20 +331,20 @@ static inline unsigned int idx_hash(u32 index)
 
 static struct hlist_head *policy_hash_bysel(struct xfrm_selector *sel, unsigned short family, int dir)
 {
-	unsigned int hmask = xfrm_policy_bydst[dir].hmask;
+	unsigned int hmask = init_net.xfrm.policy_bydst[dir].hmask;
 	unsigned int hash = __sel_hash(sel, family, hmask);
 
 	return (hash == hmask + 1 ?
 		&init_net.xfrm.policy_inexact[dir] :
-		xfrm_policy_bydst[dir].table + hash);
+		init_net.xfrm.policy_bydst[dir].table + hash);
 }
 
 static struct hlist_head *policy_hash_direct(xfrm_address_t *daddr, xfrm_address_t *saddr, unsigned short family, int dir)
 {
-	unsigned int hmask = xfrm_policy_bydst[dir].hmask;
+	unsigned int hmask = init_net.xfrm.policy_bydst[dir].hmask;
 	unsigned int hash = __addr_hash(daddr, saddr, family, hmask);
 
-	return xfrm_policy_bydst[dir].table + hash;
+	return init_net.xfrm.policy_bydst[dir].table + hash;
 }
 
 static void xfrm_dst_hash_transfer(struct hlist_head *list,
@@ -407,10 +401,10 @@ static unsigned long xfrm_new_hash_mask(unsigned int old_hmask)
 
 static void xfrm_bydst_resize(int dir)
 {
-	unsigned int hmask = xfrm_policy_bydst[dir].hmask;
+	unsigned int hmask = init_net.xfrm.policy_bydst[dir].hmask;
 	unsigned int nhashmask = xfrm_new_hash_mask(hmask);
 	unsigned int nsize = (nhashmask + 1) * sizeof(struct hlist_head);
-	struct hlist_head *odst = xfrm_policy_bydst[dir].table;
+	struct hlist_head *odst = init_net.xfrm.policy_bydst[dir].table;
 	struct hlist_head *ndst = xfrm_hash_alloc(nsize);
 	int i;
 
@@ -422,8 +416,8 @@ static void xfrm_bydst_resize(int dir)
 	for (i = hmask; i >= 0; i--)
 		xfrm_dst_hash_transfer(odst + i, ndst, nhashmask);
 
-	xfrm_policy_bydst[dir].table = ndst;
-	xfrm_policy_bydst[dir].hmask = nhashmask;
+	init_net.xfrm.policy_bydst[dir].table = ndst;
+	init_net.xfrm.policy_bydst[dir].hmask = nhashmask;
 
 	write_unlock_bh(&xfrm_policy_lock);
 
@@ -458,7 +452,7 @@ static void xfrm_byidx_resize(int total)
 static inline int xfrm_bydst_should_resize(int dir, int *total)
 {
 	unsigned int cnt = xfrm_policy_count[dir];
-	unsigned int hmask = xfrm_policy_bydst[dir].hmask;
+	unsigned int hmask = init_net.xfrm.policy_bydst[dir].hmask;
 
 	if (total)
 		*total += cnt;
@@ -763,9 +757,9 @@ xfrm_policy_flush_secctx_check(u8 type, struct xfrm_audit *audit_info)
 				return err;
 			}
 		}
-		for (i = xfrm_policy_bydst[dir].hmask; i >= 0; i--) {
+		for (i = init_net.xfrm.policy_bydst[dir].hmask; i >= 0; i--) {
 			hlist_for_each_entry(pol, entry,
-					     xfrm_policy_bydst[dir].table + i,
+					     init_net.xfrm.policy_bydst[dir].table + i,
 					     bydst) {
 				if (pol->type != type)
 					continue;
@@ -827,10 +821,10 @@ int xfrm_policy_flush(u8 type, struct xfrm_audit *audit_info)
 			goto again1;
 		}
 
-		for (i = xfrm_policy_bydst[dir].hmask; i >= 0; i--) {
+		for (i = init_net.xfrm.policy_bydst[dir].hmask; i >= 0; i--) {
 	again2:
 			hlist_for_each_entry(pol, entry,
-					     xfrm_policy_bydst[dir].table + i,
+					     init_net.xfrm.policy_bydst[dir].table + i,
 					     bydst) {
 				if (pol->type != type)
 					continue;
@@ -2154,8 +2148,8 @@ static void xfrm_prune_bundles(int (*func)(struct dst_entry *))
 				     &init_net.xfrm.policy_inexact[dir], bydst)
 			prune_one_bundle(pol, func, &gc_list);
 
-		table = xfrm_policy_bydst[dir].table;
-		for (i = xfrm_policy_bydst[dir].hmask; i >= 0; i--) {
+		table = init_net.xfrm.policy_bydst[dir].table;
+		for (i = init_net.xfrm.policy_bydst[dir].hmask; i >= 0; i--) {
 			hlist_for_each_entry(pol, entry, table + i, bydst)
 				prune_one_bundle(pol, func, &gc_list);
 		}
@@ -2415,11 +2409,11 @@ static int __net_init xfrm_policy_init(struct net *net)
 
 		INIT_HLIST_HEAD(&net->xfrm.policy_inexact[dir]);
 
-		htab = &xfrm_policy_bydst[dir];
+		htab = &net->xfrm.policy_bydst[dir];
 		htab->table = xfrm_hash_alloc(sz);
-		htab->hmask = hmask;
 		if (!htab->table)
-			panic("XFRM: failed to allocate bydst hash\n");
+			goto out_bydst;
+		htab->hmask = hmask;
 	}
 
 	INIT_LIST_HEAD(&net->xfrm.policy_all);
@@ -2427,6 +2421,14 @@ static int __net_init xfrm_policy_init(struct net *net)
 		register_netdevice_notifier(&xfrm_dev_notifier);
 	return 0;
 
+out_bydst:
+	for (dir--; dir >= 0; dir--) {
+		struct xfrm_policy_hash *htab;
+
+		htab = &net->xfrm.policy_bydst[dir];
+		xfrm_hash_free(htab->table, sz);
+	}
+	xfrm_hash_free(net->xfrm.policy_byidx, sz);
 out_byidx:
 	return -ENOMEM;
 }
@@ -2439,7 +2441,14 @@ static void xfrm_policy_fini(struct net *net)
 	WARN_ON(!list_empty(&net->xfrm.policy_all));
 
 	for (dir = 0; dir < XFRM_POLICY_MAX * 2; dir++) {
+		struct xfrm_policy_hash *htab;
+
 		WARN_ON(!hlist_empty(&net->xfrm.policy_inexact[dir]));
+
+		htab = &net->xfrm.policy_bydst[dir];
+		sz = (htab->hmask + 1);
+		WARN_ON(!hlist_empty(htab->table));
+		xfrm_hash_free(htab->table, sz);
 	}
 
 	sz = (net->xfrm.policy_idx_hmask + 1) * sizeof(struct hlist_head);
-- 
1.5.6.5

