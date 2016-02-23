From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 11/20] batman-adv: Rename batadv_gw_node *_free_ref function to *_put
Date: Tue, 23 Feb 2016 14:08:14 +0800
Message-ID: <1456207703-903-12-git-send-email-a@unstable.cc>
References: <1456207703-903-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:10063 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932176AbcBWGWA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2016 01:22:00 -0500
In-Reply-To: <1456207703-903-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The batman-adv source code is the only place in the kernel which uses the
*_free_ref naming scheme for the *_put functions. Changing it to *_put
makes it more consistent and makes it easier to understand the connection
to the *_get functions.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/gateway_client.c | 35 +++++++++++++++++------------------
 1 file changed, 17 insertions(+), 18 deletions(-)

diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 37972dfda400..c59aff5ccac8 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -76,11 +76,10 @@ static void batadv_gw_node_release(struct kref *ref)
 }
 
 /**
- * batadv_gw_node_free_ref - decrement the gw_node refcounter and possibly
- *  release it
+ * batadv_gw_node_put - decrement the gw_node refcounter and possibly release it
  * @gw_node: gateway node to free
  */
-static void batadv_gw_node_free_ref(struct batadv_gw_node *gw_node)
+static void batadv_gw_node_put(struct batadv_gw_node *gw_node)
 {
 	kref_put(&gw_node->refcount, batadv_gw_node_release);
 }
@@ -125,7 +124,7 @@ unlock:
 	rcu_read_unlock();
 out:
 	if (gw_node)
-		batadv_gw_node_free_ref(gw_node);
+		batadv_gw_node_put(gw_node);
 	return orig_node;
 }
 
@@ -143,7 +142,7 @@ static void batadv_gw_select(struct batadv_priv *bat_priv,
 	rcu_assign_pointer(bat_priv->gw.curr_gw, new_gw_node);
 
 	if (curr_gw_node)
-		batadv_gw_node_free_ref(curr_gw_node);
+		batadv_gw_node_put(curr_gw_node);
 
 	spin_unlock_bh(&bat_priv->gw.list_lock);
 }
@@ -204,7 +203,7 @@ batadv_gw_get_best_gw_node(struct batadv_priv *bat_priv)
 			    ((tmp_gw_factor == max_gw_factor) &&
 			     (tq_avg > max_tq))) {
 				if (curr_gw)
-					batadv_gw_node_free_ref(curr_gw);
+					batadv_gw_node_put(curr_gw);
 				curr_gw = gw_node;
 				kref_get(&curr_gw->refcount);
 			}
@@ -219,7 +218,7 @@ batadv_gw_get_best_gw_node(struct batadv_priv *bat_priv)
 			  */
 			if (tq_avg > max_tq) {
 				if (curr_gw)
-					batadv_gw_node_free_ref(curr_gw);
+					batadv_gw_node_put(curr_gw);
 				curr_gw = gw_node;
 				kref_get(&curr_gw->refcount);
 			}
@@ -232,7 +231,7 @@ batadv_gw_get_best_gw_node(struct batadv_priv *bat_priv)
 		if (tmp_gw_factor > max_gw_factor)
 			max_gw_factor = tmp_gw_factor;
 
-		batadv_gw_node_free_ref(gw_node);
+		batadv_gw_node_put(gw_node);
 
 next:
 		batadv_neigh_node_put(router);
@@ -273,7 +272,7 @@ void batadv_gw_check_client_stop(struct batadv_priv *bat_priv)
 	 */
 	batadv_throw_uevent(bat_priv, BATADV_UEV_GW, BATADV_UEV_DEL, NULL);
 
-	batadv_gw_node_free_ref(curr_gw);
+	batadv_gw_node_put(curr_gw);
 }
 
 void batadv_gw_election(struct batadv_priv *bat_priv)
@@ -348,9 +347,9 @@ void batadv_gw_election(struct batadv_priv *bat_priv)
 
 out:
 	if (curr_gw)
-		batadv_gw_node_free_ref(curr_gw);
+		batadv_gw_node_put(curr_gw);
 	if (next_gw)
-		batadv_gw_node_free_ref(next_gw);
+		batadv_gw_node_put(next_gw);
 	if (router)
 		batadv_neigh_node_put(router);
 	if (router_ifinfo)
@@ -547,7 +546,7 @@ void batadv_gw_node_update(struct batadv_priv *bat_priv,
 		spin_lock_bh(&bat_priv->gw.list_lock);
 		if (!hlist_unhashed(&gw_node->list)) {
 			hlist_del_init_rcu(&gw_node->list);
-			batadv_gw_node_free_ref(gw_node);
+			batadv_gw_node_put(gw_node);
 		}
 		spin_unlock_bh(&bat_priv->gw.list_lock);
 
@@ -556,12 +555,12 @@ void batadv_gw_node_update(struct batadv_priv *bat_priv,
 			batadv_gw_reselect(bat_priv);
 
 		if (curr_gw)
-			batadv_gw_node_free_ref(curr_gw);
+			batadv_gw_node_put(curr_gw);
 	}
 
 out:
 	if (gw_node)
-		batadv_gw_node_free_ref(gw_node);
+		batadv_gw_node_put(gw_node);
 }
 
 void batadv_gw_node_delete(struct batadv_priv *bat_priv,
@@ -584,7 +583,7 @@ void batadv_gw_node_free(struct batadv_priv *bat_priv)
 	hlist_for_each_entry_safe(gw_node, node_tmp,
 				  &bat_priv->gw.list, list) {
 		hlist_del_init_rcu(&gw_node->list);
-		batadv_gw_node_free_ref(gw_node);
+		batadv_gw_node_put(gw_node);
 	}
 	spin_unlock_bh(&bat_priv->gw.list_lock);
 }
@@ -621,7 +620,7 @@ static int batadv_write_buffer_text(struct batadv_priv *bat_priv,
 	ret = seq_has_overflowed(seq) ? -1 : 0;
 
 	if (curr_gw)
-		batadv_gw_node_free_ref(curr_gw);
+		batadv_gw_node_put(curr_gw);
 out:
 	if (router_ifinfo)
 		batadv_neigh_ifinfo_put(router_ifinfo);
@@ -881,9 +880,9 @@ out:
 	if (orig_dst_node)
 		batadv_orig_node_put(orig_dst_node);
 	if (curr_gw)
-		batadv_gw_node_free_ref(curr_gw);
+		batadv_gw_node_put(curr_gw);
 	if (gw_node)
-		batadv_gw_node_free_ref(gw_node);
+		batadv_gw_node_put(gw_node);
 	if (neigh_old)
 		batadv_neigh_node_put(neigh_old);
 	if (neigh_curr)
-- 
2.7.1
