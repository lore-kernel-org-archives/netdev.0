From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/2] ipv4: Inline fib_semantic_match into check_leaf
Date: Mon, 07 Mar 2011 15:13:37 -0800 (PST)
Message-ID: <20110307.151337.116381462.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35658
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756574Ab1CGXNA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 18:13:00 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id D478324C089
	for <netdev@vger.kernel.org>; Mon,  7 Mar 2011 15:13:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This elimiates a lot of pure overhead due to parameter
passing.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/fib_lookup.h    |    7 +++++
 net/ipv4/fib_semantics.c |   68 +---------------------------------------------
 net/ipv4/fib_trie.c      |   51 +++++++++++++++++++++++++++++-----
 3 files changed, 51 insertions(+), 75 deletions(-)

diff --git a/net/ipv4/fib_lookup.h b/net/ipv4/fib_lookup.h
index d5c40d8..84db2da 100644
--- a/net/ipv4/fib_lookup.h
+++ b/net/ipv4/fib_lookup.h
@@ -51,4 +51,11 @@ static inline void fib_result_assign(struct fib_result *res,
 	res->fi = fi;
 }
 
+struct fib_prop {
+	int	error;
+	u8	scope;
+};
+
+extern const struct fib_prop fib_props[RTN_MAX + 1];
+
 #endif /* _FIB_LOOKUP_H */
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index c29291b..6349a21 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -90,11 +90,7 @@ static DEFINE_SPINLOCK(fib_multipath_lock);
 #define endfor_nexthops(fi) }
 
 
-static const struct
-{
-	int	error;
-	u8	scope;
-} fib_props[RTN_MAX + 1] = {
+const struct fib_prop fib_props[RTN_MAX + 1] = {
 	[RTN_UNSPEC] = {
 		.error	= 0,
 		.scope	= RT_SCOPE_NOWHERE,
@@ -902,68 +898,6 @@ failure:
 	return ERR_PTR(err);
 }
 
-/* Note! fib_semantic_match intentionally uses  RCU list functions. */
-int fib_semantic_match(struct fib_table *tb, struct list_head *head,
-		       const struct flowi *flp, struct fib_result *res,
-		       int prefixlen, int fib_flags)
-{
-	struct fib_alias *fa;
-	int nh_sel = 0;
-
-	list_for_each_entry_rcu(fa, head, fa_list) {
-		int err;
-
-		if (fa->fa_tos &&
-		    fa->fa_tos != flp->fl4_tos)
-			continue;
-
-		if (fa->fa_scope < flp->fl4_scope)
-			continue;
-
-		fib_alias_accessed(fa);
-
-		err = fib_props[fa->fa_type].error;
-		if (err == 0) {
-			struct fib_info *fi = fa->fa_info;
-
-			if (fi->fib_flags & RTNH_F_DEAD)
-				continue;
-
-			for_nexthops(fi) {
-				if (nh->nh_flags & RTNH_F_DEAD)
-					continue;
-				if (!flp->oif || flp->oif == nh->nh_oif)
-					break;
-			}
-#ifdef CONFIG_IP_ROUTE_MULTIPATH
-			if (nhsel < fi->fib_nhs) {
-				nh_sel = nhsel;
-				goto out_fill_res;
-			}
-#else
-			if (nhsel < 1)
-				goto out_fill_res;
-#endif
-			endfor_nexthops(fi);
-			continue;
-		}
-		return err;
-	}
-	return 1;
-
-out_fill_res:
-	res->prefixlen = prefixlen;
-	res->nh_sel = nh_sel;
-	res->type = fa->fa_type;
-	res->scope = fa->fa_scope;
-	res->fi = fa->fa_info;
-	res->table = tb;
-	res->fa_head = head;
-	if (!(fib_flags & FIB_LOOKUP_NOREF))
-		atomic_inc(&res->fi->fib_clntref);
-	return 0;
-}
-
 /* Find appropriate source address to this destination */
 
 __be32 __fib_res_prefsrc(struct fib_result *res)
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index edf3b09..057062b 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1349,23 +1349,58 @@ static int check_leaf(struct fib_table *tb, struct trie *t, struct leaf *l,
 	struct hlist_node *node;
 
 	hlist_for_each_entry_rcu(li, node, hhead, hlist) {
-		int err;
+		struct fib_alias *fa;
 		int plen = li->plen;
 		__be32 mask = inet_make_mask(plen);
 
 		if (l->key != (key & ntohl(mask)))
 			continue;
 
-		err = fib_semantic_match(tb, &li->falh, flp, res, plen, fib_flags);
+		list_for_each_entry_rcu(fa, &li->falh, fa_list) {
+			struct fib_info *fi = fa->fa_info;
+			int nhsel, err;
+
+			if (fa->fa_tos && fa->fa_tos != flp->fl4_tos)
+				continue;
+			if (fa->fa_scope < flp->fl4_scope)
+				continue;
+			fib_alias_accessed(fa);
+			err = fib_props[fa->fa_type].error;
+			if (err) {
+ifdef CONFIG_IP_FIB_TRIE_STATS
+				t->stats.semantic_match_miss++;
+#endif
+				return 1;
+			}
+			if (fi->fib_flags & RTNH_F_DEAD)
+				continue;
+			for (nhsel = 0; nhsel < fi->fib_nhs; nhsel++) {
+				const struct fib_nh *nh = &fi->fib_nh[nhsel];
+
+				if (nh->nh_flags & RTNH_F_DEAD)
+					continue;
+				if (flp->oif && flp->oif != nh->nh_oif)
+					continue;
 
 #ifdef CONFIG_IP_FIB_TRIE_STATS
-		if (err <= 0)
-			t->stats.semantic_match_passed++;
-		else
-			t->stats.semantic_match_miss++;
+				t->stats.semantic_match_passed++;
+#endif
+				res->prefixlen = plen;
+				res->nh_sel = nhsel;
+				res->type = fa->fa_type;
+				res->scope = fa->fa_scope;
+				res->fi = fi;
+				res->table = tb;
+				res->fa_head = &li->falh;
+				if (!(fib_flags & FIB_LOOKUP_NOREF))
+					atomic_inc(&res->fi->fib_clntref);
+				return 0;
+			}
+		}
+
+#ifdef CONFIG_IP_FIB_TRIE_STATS
+		t->stats.semantic_match_miss++;
 #endif
-		if (err <= 0)
-			return err;
 	}
 
 	return 1;
-- 
1.7.4.1

