From: "David S. Miller" <davem@davemloft.net>
Subject: Re: FIB reorg (3)
Date: Tue, 30 Nov 2004 22:16:34 -0800
Message-ID: <20041130221634.258cd191.davem@davemloft.net>
References: <16804.57005.843753.810704@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16804.57005.843753.810704@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 24 Nov 2004 20:19:09 +0100
Robert Olsson <Robert.Olsson@data.slu.se> wrote:

> And also fib_detect_death.

Also applied to my 2.6.11 pending tree with the
fib_lookup.h usage fixup.

Thanks Robert.

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/11/30 21:51:06-08:00 robert.olsson@data.slu.se 
#   [IPV4]: FIB cleanup, fib_detect_death()
#   
#   Remove dependancy upon fib_hash specific
#   fn_hash_select_dflt and move it over to
#   fib_semantics.c
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# net/ipv4/fib_semantics.c
#   2004/11/30 21:50:04-08:00 robert.olsson@data.slu.se +23 -0
#   [IPV4]: FIB cleanup, fib_detect_death()
# 
# net/ipv4/fib_lookup.h
#   2004/11/30 21:50:04-08:00 robert.olsson@data.slu.se +3 -0
#   [IPV4]: FIB cleanup, fib_detect_death()
# 
# net/ipv4/fib_hash.c
#   2004/11/30 21:50:04-08:00 robert.olsson@data.slu.se +2 -25
#   [IPV4]: FIB cleanup, fib_detect_death()
# 
diff -Nru a/net/ipv4/fib_hash.c b/net/ipv4/fib_hash.c
--- a/net/ipv4/fib_hash.c	2004-11-30 21:51:41 -08:00
+++ b/net/ipv4/fib_hash.c	2004-11-30 21:51:41 -08:00
@@ -274,29 +274,6 @@
 
 static int fn_hash_last_dflt=-1;
 
-static int fib_detect_death(struct fib_info *fi, int order,
-			    struct fib_info **last_resort, int *last_idx)
-{
-	struct neighbour *n;
-	int state = NUD_NONE;
-
-	n = neigh_lookup(&arp_tbl, &fi->fib_nh[0].nh_gw, fi->fib_dev);
-	if (n) {
-		state = n->nud_state;
-		neigh_release(n);
-	}
-	if (state==NUD_REACHABLE)
-		return 0;
-	if ((state&NUD_VALID) && order != fn_hash_last_dflt)
-		return 0;
-	if ((state&NUD_VALID) ||
-	    (*last_idx<0 && order > fn_hash_last_dflt)) {
-		*last_resort = fi;
-		*last_idx = order;
-	}
-	return 1;
-}
-
 static void
 fn_hash_select_default(struct fib_table *tb, const struct flowi *flp, struct fib_result *res)
 {
@@ -337,7 +314,7 @@
 				if (next_fi != res->fi)
 					break;
 			} else if (!fib_detect_death(fi, order, &last_resort,
-						     &last_idx)) {
+						     &last_idx, &fn_hash_last_dflt)) {
 				if (res->fi)
 					fib_info_put(res->fi);
 				res->fi = fi;
@@ -355,7 +332,7 @@
 		goto out;
 	}
 
-	if (!fib_detect_death(fi, order, &last_resort, &last_idx)) {
+	if (!fib_detect_death(fi, order, &last_resort, &last_idx, &fn_hash_last_dflt)) {
 		if (res->fi)
 			fib_info_put(res->fi);
 		res->fi = fi;
diff -Nru a/net/ipv4/fib_lookup.h b/net/ipv4/fib_lookup.h
--- a/net/ipv4/fib_lookup.h	2004-11-30 21:51:41 -08:00
+++ b/net/ipv4/fib_lookup.h	2004-11-30 21:51:41 -08:00
@@ -35,5 +35,8 @@
 		      struct nlmsghdr *n, struct netlink_skb_parms *req);
 extern struct fib_alias *fib_find_alias(struct list_head *fah,
 					u8 tos, u32 prio);
+extern int fib_detect_death(struct fib_info *fi, int order,
+			    struct fib_info **last_resort,
+			    int *last_idx, int *dflt);
 
 #endif /* _FIB_LOOKUP_H */
diff -Nru a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
--- a/net/ipv4/fib_semantics.c	2004-11-30 21:51:41 -08:00
+++ b/net/ipv4/fib_semantics.c	2004-11-30 21:51:41 -08:00
@@ -315,6 +315,29 @@
 	return NULL;
 }
 
+int fib_detect_death(struct fib_info *fi, int order,
+		     struct fib_info **last_resort, int *last_idx, int *dflt)
+{
+	struct neighbour *n;
+	int state = NUD_NONE;
+
+	n = neigh_lookup(&arp_tbl, &fi->fib_nh[0].nh_gw, fi->fib_dev);
+	if (n) {
+		state = n->nud_state;
+		neigh_release(n);
+	}
+	if (state==NUD_REACHABLE)
+		return 0;
+	if ((state&NUD_VALID) && order != *dflt)
+		return 0;
+	if ((state&NUD_VALID) ||
+	    (*last_idx<0 && order > *dflt)) {
+		*last_resort = fi;
+		*last_idx = order;
+	}
+	return 1;
+}
+
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 
 static u32 fib_get_attr32(struct rtattr *attr, int attrlen, int type)
