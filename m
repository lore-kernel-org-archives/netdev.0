From: Julian Anastasov <ja@ssi.bg>
Subject: [IPv4]: More fib_alias insertion fixes
Date: Sat, 25 Sep 2004 23:09:11 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0409252249150.1175@u.domain.uli>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

	some fib alias fixes:

- modify fib_find_alias to stop before the desired alias, even
if reaching different TOS. If no alias is found we have to append
at end of fn_alias.

- properly prepend/append new alias with same prefix/tos/prio

- use list_for_each_entry_continue

Signed-off-by: Julian Anastasov <ja@ssi.bg>

diff -ur v2.6.9-rc2-bk10/linux/net/ipv4/fib_hash.c linux/net/ipv4/fib_hash.c
--- v2.6.9-rc2-bk10/linux/net/ipv4/fib_hash.c	2004-09-25 22:44:31.000000000 +0300
+++ linux/net/ipv4/fib_hash.c	2004-09-25 22:45:06.580902744 +0300
@@ -431,24 +431,20 @@
 	return NULL;
 }
 
-/* Return the first fib alias matching TOS with
- * priority less than or equal to PRIO.
- */
+/* Return the first fib alias below TOS and after PRIO thresholds */
 static struct fib_alias *fib_find_alias(struct fib_node *fn, u8 tos, u32 prio)
 {
 	if (fn) {
 		struct list_head *head = &fn->fn_alias;
-		struct fib_alias *fa, *prev_fa;
+		struct fib_alias *fa;
 
-		prev_fa = NULL;
 		list_for_each_entry(fa, head, fa_list) {
-			if (fa->fa_tos != tos)
+			if (fa->fa_tos > tos)
 				continue;
-			prev_fa = fa;
-			if (prio <= fa->fa_info->fib_priority)
-				break;
+			if (fa->fa_info->fib_priority >= prio ||
+			    fa->fa_tos < tos)
+				return fa;
 		}
-		return prev_fa;
 	}
 	return NULL;
 }
@@ -461,6 +457,7 @@
 	struct fib_node *new_f, *f;
 	struct fib_alias *fa, *new_fa;
 	struct fn_zone *fz;
+	struct list_head *ins_before = NULL;
 	struct fib_info *fi;
 	int z = r->rtm_dst_len;
 	int type = r->rtm_type;
@@ -505,9 +502,12 @@
 	 * and we need to allocate a new one of those as well.
 	 */
 
-	if (fa &&
+	if (fa)
+		ins_before = &fa->fa_list;
+
+	if (fa && fa->fa_tos == tos &&
 	    fa->fa_info->fib_priority == fi->fib_priority) {
-		struct fib_alias *fa_orig;
+		struct list_head *fa_head;
 
 		err = -EEXIST;
 		if (n->nlmsg_flags & NLM_F_EXCL)
@@ -536,8 +536,9 @@
 		 * uses the same scope, type, and nexthop
 		 * information.
 		 */
-		fa_orig = fa;
-		list_for_each_entry(fa, fa_orig->fa_list.prev, fa_list) {
+		fa = list_entry(fa->fa_list.prev, struct fib_alias, fa_list);
+		fa_head = &f->fn_alias;
+		list_for_each_entry_continue(fa, fa_head, fa_list) {
 			if (fa->fa_tos != tos)
 				break;
 			if (fa->fa_info->fib_priority != fi->fib_priority)
@@ -546,9 +547,9 @@
 			    fa->fa_scope == r->rtm_scope &&
 			    fa->fa_info == fi)
 				goto out;
+			if (n->nlmsg_flags & NLM_F_APPEND)
+				ins_before = fa->fa_list.next;
 		}
-		if (!(n->nlmsg_flags & NLM_F_APPEND))
-			fa = fa_orig;
 	}
 
 	err = -ENOENT;
@@ -585,8 +586,7 @@
 	write_lock_bh(&fib_hash_lock);
 	if (new_f)
 		fib_insert_node(fz, new_f);
-	list_add(&new_fa->fa_list,
-		 (fa ? &fa->fa_list : &f->fn_alias));
+	list_add_tail(&new_fa->fa_list, ins_before? : &f->fn_alias);
 	write_unlock_bh(&fib_hash_lock);
 
 	if (new_f)
@@ -637,8 +637,9 @@
 		return -ESRCH;
 
 	fa_to_delete = NULL;
-	fa_head = fa->fa_list.prev;
-	list_for_each_entry(fa, fa_head, fa_list) {
+	fa = list_entry(fa->fa_list.prev, struct fib_alias, fa_list);
+	fa_head = &f->fn_alias;
+	list_for_each_entry_continue(fa, fa_head, fa_list) {
 		struct fib_info *fi = fa->fa_info;
 
 		if (fa->fa_tos != tos)
