From: Joe Perches <joe@perches.com>
Subject: [PATCH] neighbour: Convert NEIGH_PRINTK to neigh_dbg
Date: Mon, 15 Apr 2013 18:17:19 -0700
Message-ID: <6d196be46acd99bd65d0f0d5abb842b8b0bf0d04.1366074978.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update debugging messages to a more current style.

Emit these debugging messages at KERN_DEBUG instead
of KERN_DEFAULT.

Add and use neigh_dbg(level, fmt, ...) macro
Add dynamic_debug capability via pr_debug
Convert embedded function names to "%s: ", __func__

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/core/neighbour.c | 49 ++++++++++++++++++++-----------------------------
 1 file changed, 20 insertions(+), 29 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index c72a646..89a3a07 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -39,21 +39,13 @@
 #include <linux/string.h>
 #include <linux/log2.h>
 
+#define DEBUG
 #define NEIGH_DEBUG 1
-
-#define NEIGH_PRINTK(x...) printk(x)
-#define NEIGH_NOPRINTK(x...) do { ; } while(0)
-#define NEIGH_PRINTK1 NEIGH_NOPRINTK
-#define NEIGH_PRINTK2 NEIGH_NOPRINTK
-
-#if NEIGH_DEBUG >= 1
-#undef NEIGH_PRINTK1
-#define NEIGH_PRINTK1 NEIGH_PRINTK
-#endif
-#if NEIGH_DEBUG >= 2
-#undef NEIGH_PRINTK2
-#define NEIGH_PRINTK2 NEIGH_PRINTK
-#endif
+#define neigh_dbg(level, fmt, ...)		\
+do {						\
+	if (level <= NEIGH_DEBUG)		\
+		pr_debug(fmt, ##__VA_ARGS__);	\
+} while (0)
 
 #define PNEIGH_HASHMASK		0xF
 
@@ -246,7 +238,7 @@ static void neigh_flush_dev(struct neigh_table *tbl, struct net_device *dev)
 					n->nud_state = NUD_NOARP;
 				else
 					n->nud_state = NUD_NONE;
-				NEIGH_PRINTK2("neigh %p is stray.\n", n);
+				neigh_dbg(2, "neigh %p is stray\n", n);
 			}
 			write_unlock(&n->lock);
 			neigh_cleanup_and_release(n);
@@ -542,7 +534,7 @@ struct neighbour *__neigh_create(struct neigh_table *tbl, const void *pkey,
 						     lockdep_is_held(&tbl->lock)));
 	rcu_assign_pointer(nht->hash_buckets[hash_val], n);
 	write_unlock_bh(&tbl->lock);
-	NEIGH_PRINTK2("neigh %p is created.\n", n);
+	neigh_dbg(2, "neigh %p is created\n", n);
 	rc = n;
 out:
 	return rc;
@@ -725,7 +717,7 @@ void neigh_destroy(struct neighbour *neigh)
 	dev_put(dev);
 	neigh_parms_put(neigh->parms);
 
-	NEIGH_PRINTK2("neigh %p is destroyed.\n", neigh);
+	neigh_dbg(2, "neigh %p is destroyed\n", neigh);
 
 	atomic_dec(&neigh->tbl->entries);
 	kfree_rcu(neigh, rcu);
@@ -739,7 +731,7 @@ EXPORT_SYMBOL(neigh_destroy);
  */
 static void neigh_suspect(struct neighbour *neigh)
 {
-	NEIGH_PRINTK2("neigh %p is suspected.\n", neigh);
+	neigh_dbg(2, "neigh %p is suspected\n", neigh);
 
 	neigh->output = neigh->ops->output;
 }
@@ -751,7 +743,7 @@ static void neigh_suspect(struct neighbour *neigh)
  */
 static void neigh_connect(struct neighbour *neigh)
 {
-	NEIGH_PRINTK2("neigh %p is connected.\n", neigh);
+	neigh_dbg(2, "neigh %p is connected\n", neigh);
 
 	neigh->output = neigh->ops->connected_output;
 }
@@ -852,7 +844,7 @@ static void neigh_invalidate(struct neighbour *neigh)
 	struct sk_buff *skb;
 
 	NEIGH_CACHE_STAT_INC(neigh->tbl, res_failed);
-	NEIGH_PRINTK2("neigh %p is failed.\n", neigh);
+	neigh_dbg(2, "neigh %p is failed\n", neigh);
 	neigh->updated = jiffies;
 
 	/* It is very thin place. report_unreachable is very complicated
@@ -904,17 +896,17 @@ static void neigh_timer_handler(unsigned long arg)
 	if (state & NUD_REACHABLE) {
 		if (time_before_eq(now,
 				   neigh->confirmed + neigh->parms->reachable_time)) {
-			NEIGH_PRINTK2("neigh %p is still alive.\n", neigh);
+			neigh_dbg(2, "neigh %p is still alive\n", neigh);
 			next = neigh->confirmed + neigh->parms->reachable_time;
 		} else if (time_before_eq(now,
 					  neigh->used + neigh->parms->delay_probe_time)) {
-			NEIGH_PRINTK2("neigh %p is delayed.\n", neigh);
+			neigh_dbg(2, "neigh %p is delayed\n", neigh);
 			neigh->nud_state = NUD_DELAY;
 			neigh->updated = jiffies;
 			neigh_suspect(neigh);
 			next = now + neigh->parms->delay_probe_time;
 		} else {
-			NEIGH_PRINTK2("neigh %p is suspected.\n", neigh);
+			neigh_dbg(2, "neigh %p is suspected\n", neigh);
 			neigh->nud_state = NUD_STALE;
 			neigh->updated = jiffies;
 			neigh_suspect(neigh);
@@ -923,14 +915,14 @@ static void neigh_timer_handler(unsigned long arg)
 	} else if (state & NUD_DELAY) {
 		if (time_before_eq(now,
 				   neigh->confirmed + neigh->parms->delay_probe_time)) {
-			NEIGH_PRINTK2("neigh %p is now reachable.\n", neigh);
+			neigh_dbg(2, "neigh %p is now reachable\n", neigh);
 			neigh->nud_state = NUD_REACHABLE;
 			neigh->updated = jiffies;
 			neigh_connect(neigh);
 			notify = 1;
 			next = neigh->confirmed + neigh->parms->reachable_time;
 		} else {
-			NEIGH_PRINTK2("neigh %p is probed.\n", neigh);
+			neigh_dbg(2, "neigh %p is probed\n", neigh);
 			neigh->nud_state = NUD_PROBE;
 			neigh->updated = jiffies;
 			atomic_set(&neigh->probes, 0);
@@ -997,7 +989,7 @@ int __neigh_event_send(struct neighbour *neigh, struct sk_buff *skb)
 			return 1;
 		}
 	} else if (neigh->nud_state & NUD_STALE) {
-		NEIGH_PRINTK2("neigh %p is delayed.\n", neigh);
+		neigh_dbg(2, "neigh %p is delayed\n", neigh);
 		neigh->nud_state = NUD_DELAY;
 		neigh->updated = jiffies;
 		neigh_add_timer(neigh,
@@ -1320,8 +1312,7 @@ int neigh_resolve_output(struct neighbour *neigh, struct sk_buff *skb)
 out:
 	return rc;
 discard:
-	NEIGH_PRINTK1("neigh_resolve_output: dst=%p neigh=%p\n",
-		      dst, neigh);
+	neigh_dbg(1, "%s: dst=%p neigh=%p\n", __func__, dst, neigh);
 out_kfree_skb:
 	rc = -EINVAL;
 	kfree_skb(skb);
@@ -1498,7 +1489,7 @@ void neigh_parms_release(struct neigh_table *tbl, struct neigh_parms *parms)
 		}
 	}
 	write_unlock_bh(&tbl->lock);
-	NEIGH_PRINTK1("neigh_parms_release: not found\n");
+	neigh_dbg(1, "%s: not found\n", __func__);
 }
 EXPORT_SYMBOL(neigh_parms_release);
 
-- 
1.8.1.2.459.gbcd45b4.dirty
