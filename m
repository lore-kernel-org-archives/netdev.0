From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 17/21] batman-adv: Convert batadv_neigh_node to kref
Date: Wed, 10 Feb 2016 23:57:23 +0800
Message-ID: <1455119847-5862-18-git-send-email-a@unstable.cc>
References: <1455119847-5862-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:31466 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752876AbcBJQRt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Feb 2016 11:17:49 -0500
In-Reply-To: <1455119847-5862-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

batman-adv uses a self-written reference implementation which is just based
on atomic_t. This is less obvious when reading the code than kref and
therefore increases the change that the reference counting will be missed.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/bat_iv_ogm.c |  5 +++--
 net/batman-adv/originator.c | 22 ++++++++++++----------
 net/batman-adv/routing.c    |  8 ++++----
 net/batman-adv/types.h      |  2 +-
 4 files changed, 20 insertions(+), 17 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 23ce90e21a40..affcbb571426 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -31,6 +31,7 @@
 #include <linux/init.h>
 #include <linux/jiffies.h>
 #include <linux/list.h>
+#include <linux/kref.h>
 #include <linux/netdevice.h>
 #include <linux/pkt_sched.h>
 #include <linux/printk.h>
@@ -1002,7 +1003,7 @@ batadv_iv_ogm_orig_update(struct batadv_priv *bat_priv,
 		neigh_addr = tmp_neigh_node->addr;
 		if (batadv_compare_eth(neigh_addr, ethhdr->h_source) &&
 		    tmp_neigh_node->if_incoming == if_incoming &&
-		    atomic_inc_not_zero(&tmp_neigh_node->refcount)) {
+		    kref_get_unless_zero(&tmp_neigh_node->refcount)) {
 			if (WARN(neigh_node, "too many matching neigh_nodes"))
 				batadv_neigh_node_free_ref(neigh_node);
 			neigh_node = tmp_neigh_node;
@@ -1161,7 +1162,7 @@ static int batadv_iv_ogm_calc_tq(struct batadv_orig_node *orig_node,
 		if (tmp_neigh_node->if_incoming != if_incoming)
 			continue;
 
-		if (!atomic_inc_not_zero(&tmp_neigh_node->refcount))
+		if (!kref_get_unless_zero(&tmp_neigh_node->refcount))
 			continue;
 
 		neigh_node = tmp_neigh_node;
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 428983a2036f..9e3dbd88c69e 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -229,15 +229,17 @@ void batadv_hardif_neigh_free_ref(struct batadv_hardif_neigh_node *hardif_neigh)
 /**
  * batadv_neigh_node_release - release neigh_node from lists and queue for
  *  free after rcu grace period
- * @neigh_node: neigh neighbor to free
+ * @ref: kref pointer of the neigh_node
  */
-static void batadv_neigh_node_release(struct batadv_neigh_node *neigh_node)
+static void batadv_neigh_node_release(struct kref *ref)
 {
 	struct hlist_node *node_tmp;
+	struct batadv_neigh_node *neigh_node;
 	struct batadv_hardif_neigh_node *hardif_neigh;
 	struct batadv_neigh_ifinfo *neigh_ifinfo;
 	struct batadv_algo_ops *bao;
 
+	neigh_node = container_of(ref, struct batadv_neigh_node, refcount);
 	bao = neigh_node->orig_node->bat_priv->bat_algo_ops;
 
 	hlist_for_each_entry_safe(neigh_ifinfo, node_tmp,
@@ -262,14 +264,13 @@ static void batadv_neigh_node_release(struct batadv_neigh_node *neigh_node)
 }
 
 /**
- * batadv_neigh_node_free_ref - decrement the neighbors refcounter
- *  and possibly release it
+ * batadv_neigh_node_free_ref - decrement the neighbors refcounter and possibly
+ *  release it
  * @neigh_node: neigh neighbor to free
  */
 void batadv_neigh_node_free_ref(struct batadv_neigh_node *neigh_node)
 {
-	if (atomic_dec_and_test(&neigh_node->refcount))
-		batadv_neigh_node_release(neigh_node);
+	kref_put(&neigh_node->refcount, batadv_neigh_node_release);
 }
 
 /**
@@ -298,7 +299,7 @@ batadv_orig_router_get(struct batadv_orig_node *orig_node,
 		break;
 	}
 
-	if (router && !atomic_inc_not_zero(&router->refcount))
+	if (router && !kref_get_unless_zero(&router->refcount))
 		router = NULL;
 
 	rcu_read_unlock();
@@ -491,7 +492,7 @@ batadv_neigh_node_get(const struct batadv_orig_node *orig_node,
 		if (tmp_neigh_node->if_incoming != hard_iface)
 			continue;
 
-		if (!atomic_inc_not_zero(&tmp_neigh_node->refcount))
+		if (!kref_get_unless_zero(&tmp_neigh_node->refcount))
 			continue;
 
 		res = tmp_neigh_node;
@@ -649,7 +650,8 @@ batadv_neigh_node_new(struct batadv_orig_node *orig_node,
 	neigh_node->orig_node = orig_node;
 
 	/* extra reference for return */
-	atomic_set(&neigh_node->refcount, 2);
+	kref_init(&neigh_node->refcount);
+	kref_get(&neigh_node->refcount);
 
 	spin_lock_bh(&orig_node->neigh_list_lock);
 	hlist_add_head_rcu(&neigh_node->list, &orig_node->neigh_list);
@@ -1084,7 +1086,7 @@ batadv_find_best_neighbor(struct batadv_priv *bat_priv,
 						best, if_outgoing) <= 0))
 			continue;
 
-		if (!atomic_inc_not_zero(&neigh->refcount))
+		if (!kref_get_unless_zero(&neigh->refcount))
 			continue;
 
 		if (best)
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 4a5cd8bf2661..205310b56c2b 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -73,7 +73,7 @@ static void _batadv_update_route(struct batadv_priv *bat_priv,
 
 	rcu_read_lock();
 	curr_router = rcu_dereference(orig_ifinfo->router);
-	if (curr_router && !atomic_inc_not_zero(&curr_router->refcount))
+	if (curr_router && !kref_get_unless_zero(&curr_router->refcount))
 		curr_router = NULL;
 	rcu_read_unlock();
 
@@ -101,7 +101,7 @@ static void _batadv_update_route(struct batadv_priv *bat_priv,
 		batadv_neigh_node_free_ref(curr_router);
 
 	/* increase refcount of new best neighbor */
-	if (neigh_node && !atomic_inc_not_zero(&neigh_node->refcount))
+	if (neigh_node && !kref_get_unless_zero(&neigh_node->refcount))
 		neigh_node = NULL;
 
 	spin_lock_bh(&orig_node->neigh_list_lock);
@@ -505,7 +505,7 @@ batadv_find_router(struct batadv_priv *bat_priv,
 		if (!cand_router)
 			goto next;
 
-		if (!atomic_inc_not_zero(&cand_router->refcount)) {
+		if (!kref_get_unless_zero(&cand_router->refcount)) {
 			cand_router = NULL;
 			goto next;
 		}
@@ -524,7 +524,7 @@ batadv_find_router(struct batadv_priv *bat_priv,
 
 		/* mark the first possible candidate */
 		if (!first_candidate) {
-			atomic_inc(&cand_router->refcount);
+			kref_get(&cand_router->refcount);
 			kref_get(&cand->refcount);
 			first_candidate = cand;
 			first_candidate_router = cand_router;
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 6193c01b47d2..68ca39e1713d 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -384,7 +384,7 @@ struct batadv_neigh_node {
 	spinlock_t ifinfo_lock;	/* protects ifinfo_list and its members */
 	struct batadv_hard_iface *if_incoming;
 	unsigned long last_seen;
-	atomic_t refcount;
+	struct kref refcount;
 	struct rcu_head rcu;
 };
 
-- 
2.7.1
