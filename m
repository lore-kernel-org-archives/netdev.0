From: "David S. Miller" <davem@davemloft.net>
Subject: Re: FIB reorg (2)
Date: Tue, 30 Nov 2004 22:10:04 -0800
Message-ID: <20041130221004.7fa2d526.davem@davemloft.net>
References: <16804.56817.259589.279556@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16804.56817.259589.279556@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 24 Nov 2004 20:16:01 +0100
Robert Olsson <Robert.Olsson@data.slu.se> wrote:

> And a variant of fib_find_alias for fib_semantics

Applied to my 2.6.11 pending tree.

I made the same fixup here as I did for the
first FIB reorg patch, namely making use of
the net/ipv4/fib_lookup.h header file.

Thanks Robert.

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/11/30 21:45:25-08:00 robert.olsson@data.slu.se 
#   [IPV4]: FIB cleanup, fib_find_alias()
#   
#   Abstract out fib_node arg usage in fib_find_alias(),
#   move to fib_semantics.c
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# net/ipv4/fib_semantics.c
#   2004/11/30 21:44:45-08:00 robert.olsson@data.slu.se +18 -0
#   [IPV4]: FIB cleanup, fib_find_alias()
# 
# net/ipv4/fib_lookup.h
#   2004/11/30 21:44:45-08:00 robert.olsson@data.slu.se +2 -0
#   [IPV4]: FIB cleanup, fib_find_alias()
# 
# net/ipv4/fib_hash.c
#   2004/11/30 21:44:45-08:00 robert.olsson@data.slu.se +10 -22
#   [IPV4]: FIB cleanup, fib_find_alias()
# 
diff -Nru a/net/ipv4/fib_hash.c b/net/ipv4/fib_hash.c
--- a/net/ipv4/fib_hash.c	2004-11-30 21:45:41 -08:00
+++ b/net/ipv4/fib_hash.c	2004-11-30 21:45:41 -08:00
@@ -399,26 +399,6 @@
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
@@ -458,7 +438,11 @@
 		fn_rehash_zone(fz);
 
 	f = fib_find_node(fz, key);
-	fa = fib_find_alias(f, tos, fi->fib_priority);
+
+	if (!f)
+		fa = NULL;
+	else
+		fa = fib_find_alias(&f->fn_alias, tos, fi->fib_priority);
 
 	/* Now fa, if non-NULL, points to the first fib alias
 	 * with the same keys [prefix,tos,priority], if such key already
@@ -598,7 +582,11 @@
 	}
 
 	f = fib_find_node(fz, key);
-	fa = fib_find_alias(f, tos, 0);
+
+	if (!f)
+		fa = NULL;
+	else
+		fa = fib_find_alias(&f->fn_alias, tos, 0);
 	if (!fa)
 		return -ESRCH;
 
diff -Nru a/net/ipv4/fib_lookup.h b/net/ipv4/fib_lookup.h
--- a/net/ipv4/fib_lookup.h	2004-11-30 21:45:41 -08:00
+++ b/net/ipv4/fib_lookup.h	2004-11-30 21:45:41 -08:00
@@ -33,5 +33,7 @@
 extern void rtmsg_fib(int event, u32 key, struct fib_alias *fa,
 		      int z, int tb_id,
 		      struct nlmsghdr *n, struct netlink_skb_parms *req);
+extern struct fib_alias *fib_find_alias(struct list_head *fah,
+					u8 tos, u32 prio);
 
 #endif /* _FIB_LOOKUP_H */
diff -Nru a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
--- a/net/ipv4/fib_semantics.c	2004-11-30 21:45:41 -08:00
+++ b/net/ipv4/fib_semantics.c	2004-11-30 21:45:41 -08:00
@@ -297,6 +297,24 @@
 		netlink_unicast(rtnl, skb, pid, MSG_DONTWAIT);
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
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 
 static u32 fib_get_attr32(struct rtattr *attr, int attrlen, int type)
