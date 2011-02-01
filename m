From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/2] ipv4: Remember FIB alias list head and table in lookup
 results.
Date: Mon, 31 Jan 2011 16:25:48 -0800 (PST)
Message-ID: <20110131.162548.35037920.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43028
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754297Ab1BAAZN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jan 2011 19:25:13 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id D930024C087
	for <netdev@vger.kernel.org>; Mon, 31 Jan 2011 16:25:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This will be used later to implement fib_select_default() in a
completely generic manner, instead of the current situation where the
default route is re-looked up in the TRIE/HASH table and then the
available aliases are analyzed.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip_fib.h     |    3 +++
 net/ipv4/fib_hash.c      |    2 +-
 net/ipv4/fib_lookup.h    |    2 +-
 net/ipv4/fib_semantics.c |    7 +++++--
 net/ipv4/fib_trie.c      |    8 ++++----
 5 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 2c0508a..f5199b0 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -96,12 +96,15 @@ struct fib_info {
 struct fib_rule;
 #endif
 
+struct fib_table;
 struct fib_result {
 	unsigned char	prefixlen;
 	unsigned char	nh_sel;
 	unsigned char	type;
 	unsigned char	scope;
 	struct fib_info *fi;
+	struct fib_table *table;
+	struct list_head *fa_head;
 #ifdef CONFIG_IP_MULTIPLE_TABLES
 	struct fib_rule	*r;
 #endif
diff --git a/net/ipv4/fib_hash.c b/net/ipv4/fib_hash.c
index b3acb04..0a88866 100644
--- a/net/ipv4/fib_hash.c
+++ b/net/ipv4/fib_hash.c
@@ -288,7 +288,7 @@ int fib_table_lookup(struct fib_table *tb,
 				if (f->fn_key != k)
 					continue;
 
-				err = fib_semantic_match(&f->fn_alias,
+				err = fib_semantic_match(tb, &f->fn_alias,
 						 flp, res,
 						 fz->fz_order, fib_flags);
 				if (err <= 0)
diff --git a/net/ipv4/fib_lookup.h b/net/ipv4/fib_lookup.h
index c079cc0..d5c40d8 100644
--- a/net/ipv4/fib_lookup.h
+++ b/net/ipv4/fib_lookup.h
@@ -25,7 +25,7 @@ static inline void fib_alias_accessed(struct fib_alias *fa)
 }
 
 /* Exported by fib_semantics.c */
-extern int fib_semantic_match(struct list_head *head,
+extern int fib_semantic_match(struct fib_table *tb, struct list_head *head,
 			      const struct flowi *flp,
 			      struct fib_result *res, int prefixlen, int fib_flags);
 extern void fib_release_info(struct fib_info *);
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 48e93a5..1bf6fb9 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -889,8 +889,9 @@ failure:
 }
 
 /* Note! fib_semantic_match intentionally uses  RCU list functions. */
-int fib_semantic_match(struct list_head *head, const struct flowi *flp,
-		       struct fib_result *res, int prefixlen, int fib_flags)
+int fib_semantic_match(struct fib_table *tb, struct list_head *head,
+		       const struct flowi *flp, struct fib_result *res,
+		       int prefixlen, int fib_flags)
 {
 	struct fib_alias *fa;
 	int nh_sel = 0;
@@ -954,6 +955,8 @@ out_fill_res:
 	res->type = fa->fa_type;
 	res->scope = fa->fa_scope;
 	res->fi = fa->fa_info;
+	res->table = tb;
+	res->fa_head = head;
 	if (!(fib_flags & FIB_LOOKUP_NOREF))
 		atomic_inc(&res->fi->fib_clntref);
 	return 0;
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 0f28034..8cee5c8 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1340,7 +1340,7 @@ err:
 }
 
 /* should be called with rcu_read_lock */
-static int check_leaf(struct trie *t, struct leaf *l,
+static int check_leaf(struct fib_table *tb, struct trie *t, struct leaf *l,
 		      t_key key,  const struct flowi *flp,
 		      struct fib_result *res, int fib_flags)
 {
@@ -1356,7 +1356,7 @@ static int check_leaf(struct trie *t, struct leaf *l,
 		if (l->key != (key & ntohl(mask)))
 			continue;
 
-		err = fib_semantic_match(&li->falh, flp, res, plen, fib_flags);
+		err = fib_semantic_match(tb, &li->falh, flp, res, plen, fib_flags);
 
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 		if (err <= 0)
@@ -1398,7 +1398,7 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi *flp,
 
 	/* Just a leaf? */
 	if (IS_LEAF(n)) {
-		ret = check_leaf(t, (struct leaf *)n, key, flp, res, fib_flags);
+		ret = check_leaf(tb, t, (struct leaf *)n, key, flp, res, fib_flags);
 		goto found;
 	}
 
@@ -1423,7 +1423,7 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi *flp,
 		}
 
 		if (IS_LEAF(n)) {
-			ret = check_leaf(t, (struct leaf *)n, key, flp, res, fib_flags);
+			ret = check_leaf(tb, t, (struct leaf *)n, key, flp, res, fib_flags);
 			if (ret > 0)
 				goto backtrace;
 			goto found;
-- 
1.7.4

