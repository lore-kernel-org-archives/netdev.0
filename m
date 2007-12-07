From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 2.6.25 2/3] ipv4: unify assignment of fi to fib_result
Date: Fri, 7 Dec 2007 19:10:14 +0300
Message-ID: <20071207161014.GA21704@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers@lists.osdl.org, devel@openvz.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:63021 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751543AbXLGQJE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Dec 2007 11:09:04 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipv4: unify assignment of fi to fib_result

Signed-off-by: Denis V. Lunev <den@openvz.org>
Acked-by: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
---
 net/ipv4/fib_hash.c   |   19 ++++---------------
 net/ipv4/fib_lookup.h |   10 ++++++++++
 net/ipv4/fib_trie.c   |   19 ++++---------------
 3 files changed, 18 insertions(+), 30 deletions(-)

diff --git a/net/ipv4/fib_hash.c b/net/ipv4/fib_hash.c
index 76bb7fd..a52b570 100644
--- a/net/ipv4/fib_hash.c
+++ b/net/ipv4/fib_hash.c
@@ -315,10 +315,7 @@ fn_hash_select_default(struct fib_table *tb, const struct flowi *flp, struct fib
 					break;
 			} else if (!fib_detect_death(fi, order, &last_resort,
 						     &last_idx, fn_hash_last_dflt)) {
-				if (res->fi)
-					fib_info_put(res->fi);
-				res->fi = fi;
-				atomic_inc(&fi->fib_clntref);
+				fib_result_assign(res, fi);
 				fn_hash_last_dflt = order;
 				goto out;
 			}
@@ -333,21 +330,13 @@ fn_hash_select_default(struct fib_table *tb, const struct flowi *flp, struct fib
 	}
 
 	if (!fib_detect_death(fi, order, &last_resort, &last_idx, fn_hash_last_dflt)) {
-		if (res->fi)
-			fib_info_put(res->fi);
-		res->fi = fi;
-		atomic_inc(&fi->fib_clntref);
+		fib_result_assign(res, fi);
 		fn_hash_last_dflt = order;
 		goto out;
 	}
 
-	if (last_idx >= 0) {
-		if (res->fi)
-			fib_info_put(res->fi);
-		res->fi = last_resort;
-		if (last_resort)
-			atomic_inc(&last_resort->fib_clntref);
-	}
+	if (last_idx >= 0)
+		fib_result_assign(res, last_resort);
 	fn_hash_last_dflt = last_idx;
 out:
 	read_unlock(&fib_hash_lock);
diff --git a/net/ipv4/fib_lookup.h b/net/ipv4/fib_lookup.h
index 6c9dd42..26ee66d 100644
--- a/net/ipv4/fib_lookup.h
+++ b/net/ipv4/fib_lookup.h
@@ -38,4 +38,14 @@ extern int fib_detect_death(struct fib_info *fi, int order,
 			    struct fib_info **last_resort,
 			    int *last_idx, int dflt);
 
+static inline void fib_result_assign(struct fib_result *res,
+				     struct fib_info *fi)
+{
+	if (res->fi != NULL)
+		fib_info_put(res->fi);
+	res->fi = fi;
+	if (fi != NULL)
+		atomic_inc(&fi->fib_clntref);
+}
+
 #endif /* _FIB_LOOKUP_H */
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 914a0d2..29a06af 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1828,10 +1828,7 @@ fn_trie_select_default(struct fib_table *tb, const struct flowi *flp, struct fib
 				break;
 		} else if (!fib_detect_death(fi, order, &last_resort,
 					     &last_idx, trie_last_dflt)) {
-			if (res->fi)
-				fib_info_put(res->fi);
-			res->fi = fi;
-			atomic_inc(&fi->fib_clntref);
+			fib_result_assign(res, fi);
 			trie_last_dflt = order;
 			goto out;
 		}
@@ -1844,20 +1841,12 @@ fn_trie_select_default(struct fib_table *tb, const struct flowi *flp, struct fib
 	}
 
 	if (!fib_detect_death(fi, order, &last_resort, &last_idx, trie_last_dflt)) {
-		if (res->fi)
-			fib_info_put(res->fi);
-		res->fi = fi;
-		atomic_inc(&fi->fib_clntref);
+		fib_result_assign(res, fi);
 		trie_last_dflt = order;
 		goto out;
 	}
-	if (last_idx >= 0) {
-		if (res->fi)
-			fib_info_put(res->fi);
-		res->fi = last_resort;
-		if (last_resort)
-			atomic_inc(&last_resort->fib_clntref);
-	}
+	if (last_idx >= 0)
+		fib_result_assign(res, last_resort);
 	trie_last_dflt = last_idx;
  out:;
 	rcu_read_unlock();
-- 
1.5.3.rc5

