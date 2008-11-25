From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 18/53] netns xfrm: per-netns inexact policies
Date: Tue, 25 Nov 2008 20:26:50 +0300
Message-ID: <1227634045-27534-18-git-send-email-adobriyan@gmail.com>
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
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:4839 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754424AbYKYRYQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 12:24:16 -0500
Received: by nf-out-0910.google.com with SMTP id d3so28104nfc.21
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 09:24:16 -0800 (PST)
In-Reply-To: <1227634045-27534-17-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/net/netns/xfrm.h |    2 ++
 net/xfrm/xfrm_policy.c   |   20 ++++++++++++--------
 2 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
index 42dc318..c756831 100644
--- a/include/net/netns/xfrm.h
+++ b/include/net/netns/xfrm.h
@@ -4,6 +4,7 @@
 #include <linux/list.h>
 #include <linux/wait.h>
 #include <linux/workqueue.h>
+#include <linux/xfrm.h>
 
 struct netns_xfrm {
 	struct list_head	state_all;
@@ -29,6 +30,7 @@ struct netns_xfrm {
 	struct list_head	policy_all;
 	struct hlist_head	*policy_byidx;
 	unsigned int		policy_idx_hmask;
+	struct hlist_head	policy_inexact[XFRM_POLICY_MAX * 2];
 };
 
 #endif
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 9e37a44..ba4e95b 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -327,7 +327,6 @@ struct xfrm_policy_hash {
 	unsigned int		hmask;
 };
 
-static struct hlist_head xfrm_policy_inexact[XFRM_POLICY_MAX*2];
 static struct xfrm_policy_hash xfrm_policy_bydst[XFRM_POLICY_MAX*2] __read_mostly;
 static unsigned int xfrm_policy_hashmax __read_mostly = 1 * 1024 * 1024;
 
@@ -342,7 +341,7 @@ static struct hlist_head *policy_hash_bysel(struct xfrm_selector *sel, unsigned
 	unsigned int hash = __sel_hash(sel, family, hmask);
 
 	return (hash == hmask + 1 ?
-		&xfrm_policy_inexact[dir] :
+		&init_net.xfrm.policy_inexact[dir] :
 		xfrm_policy_bydst[dir].table + hash);
 }
 
@@ -752,7 +751,7 @@ xfrm_policy_flush_secctx_check(u8 type, struct xfrm_audit *audit_info)
 		int i;
 
 		hlist_for_each_entry(pol, entry,
-				     &xfrm_policy_inexact[dir], bydst) {
+				     &init_net.xfrm.policy_inexact[dir], bydst) {
 			if (pol->type != type)
 				continue;
 			err = security_xfrm_policy_delete(pol->security);
@@ -810,7 +809,7 @@ int xfrm_policy_flush(u8 type, struct xfrm_audit *audit_info)
 		killed = 0;
 	again1:
 		hlist_for_each_entry(pol, entry,
-				     &xfrm_policy_inexact[dir], bydst) {
+				     &init_net.xfrm.policy_inexact[dir], bydst) {
 			if (pol->type != type)
 				continue;
 			hlist_del(&pol->bydst);
@@ -983,7 +982,7 @@ static struct xfrm_policy *xfrm_policy_lookup_bytype(u8 type, struct flowi *fl,
 			break;
 		}
 	}
-	chain = &xfrm_policy_inexact[dir];
+	chain = &init_net.xfrm.policy_inexact[dir];
 	hlist_for_each_entry(pol, entry, chain, bydst) {
 		err = xfrm_policy_match(pol, fl, type, family, dir);
 		if (err) {
@@ -2152,7 +2151,7 @@ static void xfrm_prune_bundles(int (*func)(struct dst_entry *))
 		int i;
 
 		hlist_for_each_entry(pol, entry,
-				     &xfrm_policy_inexact[dir], bydst)
+				     &init_net.xfrm.policy_inexact[dir], bydst)
 			prune_one_bundle(pol, func, &gc_list);
 
 		table = xfrm_policy_bydst[dir].table;
@@ -2414,7 +2413,7 @@ static int __net_init xfrm_policy_init(struct net *net)
 	for (dir = 0; dir < XFRM_POLICY_MAX * 2; dir++) {
 		struct xfrm_policy_hash *htab;
 
-		INIT_HLIST_HEAD(&xfrm_policy_inexact[dir]);
+		INIT_HLIST_HEAD(&net->xfrm.policy_inexact[dir]);
 
 		htab = &xfrm_policy_bydst[dir];
 		htab->table = xfrm_hash_alloc(sz);
@@ -2435,9 +2434,14 @@ out_byidx:
 static void xfrm_policy_fini(struct net *net)
 {
 	unsigned int sz;
+	int dir;
 
 	WARN_ON(!list_empty(&net->xfrm.policy_all));
 
+	for (dir = 0; dir < XFRM_POLICY_MAX * 2; dir++) {
+		WARN_ON(!hlist_empty(&net->xfrm.policy_inexact[dir]));
+	}
+
 	sz = (net->xfrm.policy_idx_hmask + 1) * sizeof(struct hlist_head);
 	WARN_ON(!hlist_empty(net->xfrm.policy_byidx));
 	xfrm_hash_free(net->xfrm.policy_byidx, sz);
@@ -2590,7 +2594,7 @@ static struct xfrm_policy * xfrm_migrate_policy_find(struct xfrm_selector *sel,
 			break;
 		}
 	}
-	chain = &xfrm_policy_inexact[dir];
+	chain = &init_net.xfrm.policy_inexact[dir];
 	hlist_for_each_entry(pol, entry, chain, bydst) {
 		if (xfrm_migrate_selector_match(sel, &pol->selector) &&
 		    pol->type == type &&
-- 
1.5.6.5

