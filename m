From: David Dillow <dave@thedillows.org>
Subject: [RFC BK 6/22] xfrm offload v2: add a parameter to xfrm_prune_bundles()
Date: Mon, 10 Jan 2005 10:37:00 -0500
Message-ID: <20040110014300.15@ori.thedillows.org>
References: <20040110014300.14@ori.thedillows.org>
Cc: dave@thedillows.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/10 00:44:12-05:00 dave@thedillows.org 
#   Add a parameter to the decision function(s) used by
#   xfrm_prune_bundles(). This will allow us to have more
#   fine grained selection of bundles pruned (like, say,
#   per device.)
#   
#   Signed-off-by: David Dillow <dave@thedillows.org>
# 
# net/xfrm/xfrm_policy.c
#   2005/01/10 00:43:55-05:00 dave@thedillows.org +11 -10
#   Add a parameter to the decision function(s) used by
#   xfrm_prune_bundles(). This will allow us to have more
#   fine grained selection of bundles pruned (like, say,
#   per device.)
#   
#   Signed-off-by: David Dillow <dave@thedillows.org>
# 
diff -Nru a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
--- a/net/xfrm/xfrm_policy.c	2005-01-10 01:19:37 -05:00
+++ b/net/xfrm/xfrm_policy.c	2005-01-10 01:19:37 -05:00
@@ -724,7 +724,7 @@
 	}
 }
 
-static int stale_bundle(struct dst_entry *dst);
+static int stale_bundle(struct dst_entry *dst, void *unused);
 
 static void xfrm_accel_task(void *data)
 {
@@ -744,7 +744,7 @@
 		/* stale_bundle() validates that we have a dev, and that it
 		* is currently running.
 		*/
-		if (!stale_bundle(dst) && (dev->features & NETIF_F_IPSEC))
+		if (!stale_bundle(dst, NULL) && (dev->features & NETIF_F_IPSEC))
 			dev->xfrm_bundle_add(dev, dst);
 
 		dst_release(dst);
@@ -861,7 +861,7 @@
 		}
 
 		write_lock_bh(&policy->lock);
-		if (unlikely(policy->dead || stale_bundle(dst))) {
+		if (unlikely(policy->dead || stale_bundle(dst, NULL))) {
 			/* Wow! While we worked on resolving, this
 			 * policy has gone. Retry. It is not paranoia,
 			 * we just cannot enlist new bundle to dead object.
@@ -1042,14 +1042,14 @@
 
 static struct dst_entry *xfrm_dst_check(struct dst_entry *dst, u32 cookie)
 {
-	if (!stale_bundle(dst))
+	if (!stale_bundle(dst, NULL))
 		return dst;
 
 	dst_release(dst);
 	return NULL;
 }
 
-static int stale_bundle(struct dst_entry *dst)
+static int stale_bundle(struct dst_entry *dst, void *unused)
 {
 	struct dst_entry *child = dst;
 
@@ -1092,7 +1092,8 @@
 	return dst;
 }
 
-static void xfrm_prune_bundles(int (*func)(struct dst_entry *))
+static void xfrm_prune_bundles(int (*func)(struct dst_entry *, void *),
+					void *data)
 {
 	int i;
 	struct xfrm_policy *pol;
@@ -1104,7 +1105,7 @@
 			write_lock(&pol->lock);
 			dstp = &pol->bundles;
 			while ((dst=*dstp) != NULL) {
-				if (func(dst)) {
+				if (func(dst, data)) {
 					*dstp = dst->next;
 					dst->next = gc_list;
 					gc_list = dst;
@@ -1124,19 +1125,19 @@
 	}
 }
 
-static int unused_bundle(struct dst_entry *dst)
+static int unused_bundle(struct dst_entry *dst, void *unused)
 {
 	return !atomic_read(&dst->__refcnt);
 }
 
 static void __xfrm_garbage_collect(void)
 {
-	xfrm_prune_bundles(unused_bundle);
+	xfrm_prune_bundles(unused_bundle, NULL);
 }
 
 int xfrm_flush_bundles(void)
 {
-	xfrm_prune_bundles(stale_bundle);
+	xfrm_prune_bundles(stale_bundle, NULL);
 	return 0;
 }
 
