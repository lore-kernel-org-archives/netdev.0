From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: FIB reorg (2)
Date: Wed, 24 Nov 2004 20:16:01 +0100
Message-ID: <16804.56817.259589.279556@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


And a variant of fib_find_alias for fib_semantics

					--ro


--- net/ipv4/fib_hash.c.orig	Sat Nov 20 11:34:44 2004
+++ net/ipv4/fib_hash.c	Fri Nov 19 16:58:00 2004
@@ -48,6 +48,8 @@
 static kmem_cache_t *fn_hash_kmem;
 static kmem_cache_t *fn_alias_kmem;
 
+extern struct fib_alias *fib_find_alias(struct list_head *fah, u8 tos, u32 prio);
+
 struct fib_node {
 	struct hlist_node	fn_hash;
 	struct list_head	fn_alias;
@@ -404,26 +406,6 @@
 	return NULL;
 }
 
-/* Return the first fib alias matching TOS with
- * priority less than or equal to PRIO.
- */
-static struct fib_alias *fib_find_alias(struct fib_node *fn, u8 tos, u32 prio)
-{
-	if (fn) {
-		struct list_head *head = &fn->fn_alias;
-		struct fib_alias *fa;
-
-		list_for_each_entry(fa, head, fa_list) {
-			if (fa->fa_tos > tos)
-				continue;
-			if (fa->fa_info->fib_priority >= prio ||
-			    fa->fa_tos < tos)
-				return fa;
-		}
-	}
-	return NULL;
-}
-
 static int
 fn_hash_insert(struct fib_table *tb, struct rtmsg *r, struct kern_rta *rta,
 	       struct nlmsghdr *n, struct netlink_skb_parms *req)
@@ -463,7 +445,11 @@
 		fn_rehash_zone(fz);
 
 	f = fib_find_node(fz, key);
-	fa = fib_find_alias(f, tos, fi->fib_priority);
+
+	if(!f)
+	  fa = NULL;
+	else
+	  fa = fib_find_alias(&f->fn_alias, tos, fi->fib_priority);
 
 	/* Now fa, if non-NULL, points to the first fib alias
 	 * with the same keys [prefix,tos,priority], if such key already
@@ -603,7 +589,11 @@
 	}
 
 	f = fib_find_node(fz, key);
-	fa = fib_find_alias(f, tos, 0);
+
+	if(!f)
+	  fa = NULL;
+	else
+	  fa = fib_find_alias(&f->fn_alias, tos, 0);
 	if (!fa)
 		return -ESRCH;
 
--- net/ipv4/fib_semantics.c.orig	Sat Nov 20 11:35:03 2004
+++ net/ipv4/fib_semantics.c	Fri Nov 19 09:00:04 2004
@@ -268,6 +268,25 @@
 	return -1;
 }
 
+/* Return the first fib alias matching TOS with
+ * priority less than or equal to PRIO.
+ */
+struct fib_alias *fib_find_alias(struct list_head *fah, u8 tos, u32 prio)
+{
+	if (fah) {
+		struct fib_alias *fa;
+		list_for_each_entry(fa, fah, fa_list) {
+			if (fa->fa_tos > tos)
+				continue;
+			if (fa->fa_info->fib_priority >= prio ||
+			    fa->fa_tos < tos)
+				return fa;
+		}
+	}
+	return NULL;
+}
+
+
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 
 static u32 fib_get_attr32(struct rtattr *attr, int attrlen, int type)
