From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: FIB reorg (3)
Date: Wed, 24 Nov 2004 20:19:09 +0100
Message-ID: <16804.57005.843753.810704@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



And also fib_detect_death.

						--ro


--- net/ipv4/fib_hash.c.041118	Thu Nov 18 20:09:55 2004
+++ net/ipv4/fib_hash.c	Thu Nov 18 20:36:00 2004
@@ -49,6 +49,9 @@
 static kmem_cache_t *fn_alias_kmem;
 
 extern struct fib_alias *fib_find_alias(struct list_head *fah, u8 tos, u32 prio);
+extern int fib_detect_death(struct fib_info *fi, int order,
+			    struct fib_info **last_resort, int *last_idx, int *dflt);
+
 
 struct fib_node {
 	struct hlist_node	fn_hash;
@@ -276,29 +279,6 @@
 
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
@@ -339,7 +319,7 @@
 				if (next_fi != res->fi)
 					break;
 			} else if (!fib_detect_death(fi, order, &last_resort,
-						     &last_idx)) {
+						     &last_idx, &fn_hash_last_dflt)) {
 				if (res->fi)
 					fib_info_put(res->fi);
 				res->fi = fi;
@@ -357,7 +337,7 @@
 		goto out;
 	}
 
-	if (!fib_detect_death(fi, order, &last_resort, &last_idx)) {
+	if (!fib_detect_death(fi, order, &last_resort, &last_idx, &fn_hash_last_dflt)) {
 		if (res->fi)
 			fib_info_put(res->fi);
 		res->fi = fi;
--- net/ipv4/fib_semantics.c.041118	Thu Nov 18 20:26:02 2004
+++ net/ipv4/fib_semantics.c	Thu Nov 18 20:18:00 2004
@@ -317,6 +317,30 @@
 }
 
 
+int fib_detect_death(struct fib_info *fi, int order,
+			    struct fib_info **last_resort, int *last_idx, int *dflt)
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
+
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 
 static u32 fib_get_attr32(struct rtattr *attr, int attrlen, int type)
