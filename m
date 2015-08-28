From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 04/10] batman-adv: remove obsolete deleted attribute for gateway node
Date: Fri, 28 Aug 2015 11:12:30 +0200
Message-ID: <1440753156-7808-5-git-send-email-antonio@meshcoding.com>
References: <1440753156-7808-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:25567 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752343AbbH1JNy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Aug 2015 05:13:54 -0400
In-Reply-To: <1440753156-7808-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <simon@open-mesh.com>

With rcu, the gateway node deleted attribute is not needed anymore. In
fact, it may delay the free of the gateway node and its referenced
structures. Therefore remove it altogether and simplify purging as well.

Signed-off-by: Simon Wunderlich <simon@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/gateway_client.c | 48 +++++++++++------------------------------
 net/batman-adv/gateway_client.h |  2 +-
 net/batman-adv/main.c           |  2 +-
 net/batman-adv/originator.c     |  1 -
 net/batman-adv/types.h          |  2 --
 5 files changed, 14 insertions(+), 41 deletions(-)

diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index d7ca214..634c7e3 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -161,9 +161,6 @@ batadv_gw_get_best_gw_node(struct batadv_priv *bat_priv)
 
 	rcu_read_lock();
 	hlist_for_each_entry_rcu(gw_node, &bat_priv->gw.list, list) {
-		if (gw_node->deleted)
-			continue;
-
 		orig_node = gw_node->orig_node;
 		router = batadv_orig_router_get(orig_node, BATADV_IF_DEFAULT);
 		if (!router)
@@ -473,9 +470,6 @@ batadv_gw_node_get(struct batadv_priv *bat_priv,
 		if (gw_node_tmp->orig_node != orig_node)
 			continue;
 
-		if (gw_node_tmp->deleted)
-			continue;
-
 		if (!atomic_inc_not_zero(&gw_node_tmp->refcount))
 			continue;
 
@@ -525,9 +519,7 @@ void batadv_gw_node_update(struct batadv_priv *bat_priv,
 	gw_node->bandwidth_down = ntohl(gateway->bandwidth_down);
 	gw_node->bandwidth_up = ntohl(gateway->bandwidth_up);
 
-	gw_node->deleted = 0;
 	if (ntohl(gateway->bandwidth_down) == 0) {
-		gw_node->deleted = jiffies;
 		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "Gateway %pM removed from gateway list\n",
 			   orig_node->orig);
@@ -535,14 +527,21 @@ void batadv_gw_node_update(struct batadv_priv *bat_priv,
 		/* Note: We don't need a NULL check here, since curr_gw never
 		 * gets dereferenced.
 		 */
+		spin_lock_bh(&bat_priv->gw.list_lock);
+		hlist_del_init_rcu(&gw_node->list);
+		spin_unlock_bh(&bat_priv->gw.list_lock);
+
+		batadv_gw_node_free_ref(gw_node);
+
 		curr_gw = batadv_gw_get_selected_gw_node(bat_priv);
 		if (gw_node == curr_gw)
 			batadv_gw_reselect(bat_priv);
+
+		if (curr_gw)
+			batadv_gw_node_free_ref(curr_gw);
 	}
 
 out:
-	if (curr_gw)
-		batadv_gw_node_free_ref(curr_gw);
 	if (gw_node)
 		batadv_gw_node_free_ref(gw_node);
 }
@@ -558,39 +557,19 @@ void batadv_gw_node_delete(struct batadv_priv *bat_priv,
 	batadv_gw_node_update(bat_priv, orig_node, &gateway);
 }
 
-void batadv_gw_node_purge(struct batadv_priv *bat_priv)
+void batadv_gw_node_free(struct batadv_priv *bat_priv)
 {
-	struct batadv_gw_node *gw_node, *curr_gw;
+	struct batadv_gw_node *gw_node;
 	struct hlist_node *node_tmp;
-	unsigned long timeout = msecs_to_jiffies(2 * BATADV_PURGE_TIMEOUT);
-	int do_reselect = 0;
-
-	curr_gw = batadv_gw_get_selected_gw_node(bat_priv);
 
 	spin_lock_bh(&bat_priv->gw.list_lock);
-
 	hlist_for_each_entry_safe(gw_node, node_tmp,
 				  &bat_priv->gw.list, list) {
-		if (((!gw_node->deleted) ||
-		     (time_before(jiffies, gw_node->deleted + timeout))) &&
-		    atomic_read(&bat_priv->mesh_state) == BATADV_MESH_ACTIVE)
-			continue;
 
-		if (curr_gw == gw_node)
-			do_reselect = 1;
-
-		hlist_del_rcu(&gw_node->list);
+		hlist_del_init_rcu(&gw_node->list);
 		batadv_gw_node_free_ref(gw_node);
 	}
-
 	spin_unlock_bh(&bat_priv->gw.list_lock);
-
-	/* gw_reselect() needs to acquire the gw_list_lock */
-	if (do_reselect)
-		batadv_gw_reselect(bat_priv);
-
-	if (curr_gw)
-		batadv_gw_node_free_ref(curr_gw);
 }
 
 /* fails if orig_node has no router */
@@ -654,9 +633,6 @@ int batadv_gw_client_seq_print_text(struct seq_file *seq, void *offset)
 
 	rcu_read_lock();
 	hlist_for_each_entry_rcu(gw_node, &bat_priv->gw.list, list) {
-		if (gw_node->deleted)
-			continue;
-
 		/* fails if orig_node has no router */
 		if (batadv_write_buffer_text(bat_priv, seq, gw_node) < 0)
 			continue;
diff --git a/net/batman-adv/gateway_client.h b/net/batman-adv/gateway_client.h
index ef4d7e3..fa95277 100644
--- a/net/batman-adv/gateway_client.h
+++ b/net/batman-adv/gateway_client.h
@@ -38,7 +38,7 @@ void batadv_gw_node_update(struct batadv_priv *bat_priv,
 			   struct batadv_tvlv_gateway_data *gateway);
 void batadv_gw_node_delete(struct batadv_priv *bat_priv,
 			   struct batadv_orig_node *orig_node);
-void batadv_gw_node_purge(struct batadv_priv *bat_priv);
+void batadv_gw_node_free(struct batadv_priv *bat_priv);
 int batadv_gw_client_seq_print_text(struct seq_file *seq, void *offset);
 bool batadv_gw_out_of_range(struct batadv_priv *bat_priv, struct sk_buff *skb);
 enum batadv_dhcp_recipient
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index e61c5f3..d7f17c1 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -199,7 +199,7 @@ void batadv_mesh_free(struct net_device *soft_iface)
 
 	batadv_purge_outstanding_packets(bat_priv, NULL);
 
-	batadv_gw_node_purge(bat_priv);
+	batadv_gw_node_free(bat_priv);
 	batadv_nc_mesh_free(bat_priv);
 	batadv_dat_free(bat_priv);
 	batadv_bla_free(bat_priv);
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index f751775..d6d9809 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -1028,7 +1028,6 @@ static void _batadv_purge_orig(struct batadv_priv *bat_priv)
 		spin_unlock_bh(list_lock);
 	}
 
-	batadv_gw_node_purge(bat_priv);
 	batadv_gw_election(bat_priv);
 }
 
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 2f5e6c3..d260efd 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -328,7 +328,6 @@ enum batadv_orig_capabilities {
  * @orig_node: pointer to corresponding orig node
  * @bandwidth_down: advertised uplink download bandwidth
  * @bandwidth_up: advertised uplink upload bandwidth
- * @deleted: this struct is scheduled for deletion
  * @refcount: number of contexts the object is used
  * @rcu: struct used for freeing in an RCU-safe manner
  */
@@ -337,7 +336,6 @@ struct batadv_gw_node {
 	struct batadv_orig_node *orig_node;
 	u32 bandwidth_down;
 	u32 bandwidth_up;
-	unsigned long deleted;
 	atomic_t refcount;
 	struct rcu_head rcu;
 };
-- 
2.5.0
