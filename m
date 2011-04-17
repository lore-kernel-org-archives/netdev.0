From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: [PATCH 6/8] batman-adv: concentrate all curr_gw
	related rcu operations in select/deselect functions
Date: Sun, 17 Apr 2011 21:30:16 +0200
Message-ID: <1303068618-27928-7-git-send-email-sven@narfation.org>
References: <1303068618-27928-1-git-send-email-sven@narfation.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1303068618-27928-1-git-send-email-sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>

Signed-off-by: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
---
 net/batman-adv/gateway_client.c |  176 ++++++++++++++++++++++-----------------
 net/batman-adv/gateway_client.h |    2 +-
 net/batman-adv/unicast.c        |    2 +-
 3 files changed, 103 insertions(+), 77 deletions(-)

diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 42a8a7b..2acd7a6 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -43,61 +43,75 @@ static void gw_node_free_ref(struct gw_node *gw_node)
 		call_rcu(&gw_node->rcu, gw_node_free_rcu);
 }
 
-struct orig_node *gw_get_selected(struct bat_priv *bat_priv)
+static struct gw_node *gw_get_selected_gw_node(struct bat_priv *bat_priv)
 {
-	struct gw_node *curr_gateway_tmp;
+	struct gw_node *gw_node;
+
+	rcu_read_lock();
+	gw_node = rcu_dereference(bat_priv->curr_gw);
+	if (!gw_node)
+		goto out;
+
+	if (!atomic_inc_not_zero(&gw_node->refcount))
+		gw_node = NULL;
+
+out:
+	rcu_read_unlock();
+	return gw_node;
+}
+
+struct orig_node *gw_get_selected_orig(struct bat_priv *bat_priv)
+{
+	struct gw_node *gw_node;
 	struct orig_node *orig_node = NULL;
 
-	rcu_read_lock();
-	curr_gateway_tmp = rcu_dereference(bat_priv->curr_gw);
-	if (!curr_gateway_tmp)
+	gw_node = gw_get_selected_gw_node(bat_priv);
+	if (!gw_node)
 		goto out;
 
-	orig_node = curr_gateway_tmp->orig_node;
+	rcu_read_lock();
+	orig_node = gw_node->orig_node;
 	if (!orig_node)
-		goto out;
+		goto unlock;
 
 	if (!atomic_inc_not_zero(&orig_node->refcount))
 		orig_node = NULL;
 
-out:
+unlock:
 	rcu_read_unlock();
-	return orig_node;
-}
-
-void gw_deselect(struct bat_priv *bat_priv)
-{
-	struct gw_node *gw_node;
-
-	spin_lock_bh(&bat_priv->gw_list_lock);
-	gw_node = rcu_dereference(bat_priv->curr_gw);
-	rcu_assign_pointer(bat_priv->curr_gw, NULL);
-	spin_unlock_bh(&bat_priv->gw_list_lock);
-
+out:
 	if (gw_node)
 		gw_node_free_ref(gw_node);
+	return orig_node;
 }
 
 static void gw_select(struct bat_priv *bat_priv, struct gw_node *new_gw_node)
 {
 	struct gw_node *curr_gw_node;
 
+	spin_lock_bh(&bat_priv->gw_list_lock);
+
 	if (new_gw_node && !atomic_inc_not_zero(&new_gw_node->refcount))
 		new_gw_node = NULL;
 
-	spin_lock_bh(&bat_priv->gw_list_lock);
-	curr_gw_node = rcu_dereference(bat_priv->curr_gw);
+	curr_gw_node = bat_priv->curr_gw;
 	rcu_assign_pointer(bat_priv->curr_gw, new_gw_node);
-	spin_unlock_bh(&bat_priv->gw_list_lock);
 
 	if (curr_gw_node)
 		gw_node_free_ref(curr_gw_node);
+
+	spin_unlock_bh(&bat_priv->gw_list_lock);
+}
+
+void gw_deselect(struct bat_priv *bat_priv)
+{
+	gw_select(bat_priv, NULL);
 }
 
 void gw_election(struct bat_priv *bat_priv)
 {
 	struct hlist_node *node;
-	struct gw_node *gw_node, *curr_gw, *curr_gw_tmp = NULL;
+	struct gw_node *gw_node, *curr_gw = NULL, *curr_gw_tmp = NULL;
 	struct neigh_node *router;
 	uint8_t max_tq = 0;
 	uint32_t max_gw_factor = 0, tmp_gw_factor = 0;
@@ -112,25 +126,17 @@ void gw_election(struct bat_priv *bat_priv)
 	if (atomic_read(&bat_priv->gw_mode) != GW_MODE_CLIENT)
 		return;
 
-	rcu_read_lock();
-	curr_gw = rcu_dereference(bat_priv->curr_gw);
-	if (curr_gw) {
-		rcu_read_unlock();
-		return;
-	}
+	curr_gw = gw_get_selected_gw_node(bat_priv);
+	if (!curr_gw)
+		goto out;
 
+	rcu_read_lock();
 	if (hlist_empty(&bat_priv->gw_list)) {
-
-		if (curr_gw) {
-			rcu_read_unlock();
-			bat_dbg(DBG_BATMAN, bat_priv,
-				"Removing selected gateway - "
-				"no gateway in range\n");
-			gw_deselect(bat_priv);
-		} else
-			rcu_read_unlock();
-
-		return;
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"Removing selected gateway - "
+			"no gateway in range\n");
+		gw_deselect(bat_priv);
+		goto unlock;
 	}
 
 	hlist_for_each_entry_rcu(gw_node, node, &bat_priv->gw_list, list) {
@@ -182,7 +188,7 @@ void gw_election(struct bat_priv *bat_priv)
 	if (curr_gw != curr_gw_tmp) {
 		router = orig_node_get_router(curr_gw_tmp->orig_node);
 		if (!router)
-			goto out;
+			goto unlock;
 
 		if ((curr_gw) && (!curr_gw_tmp))
 			bat_dbg(DBG_BATMAN, bat_priv,
@@ -207,8 +213,11 @@ void gw_election(struct bat_priv *bat_priv)
 		gw_select(bat_priv, curr_gw_tmp);
 	}
 
-out:
+unlock:
 	rcu_read_unlock();
+out:
+	if (curr_gw)
+		gw_node_free_ref(curr_gw);
 }
 
 void gw_check_election(struct bat_priv *bat_priv, struct orig_node *orig_node)
@@ -217,7 +226,7 @@ void gw_check_election(struct bat_priv *bat_priv, struct orig_node *orig_node)
 	struct neigh_node *router_gw = NULL, *router_orig = NULL;
 	uint8_t gw_tq_avg, orig_tq_avg;
 
-	curr_gw_orig = gw_get_selected(bat_priv);
+	curr_gw_orig = gw_get_selected_orig(bat_priv);
 	if (!curr_gw_orig)
 		goto deselect;
 
@@ -299,7 +308,11 @@ void gw_node_update(struct bat_priv *bat_priv,
 		    struct orig_node *orig_node, uint8_t new_gwflags)
 {
 	struct hlist_node *node;
-	struct gw_node *gw_node;
+	struct gw_node *gw_node, *curr_gw;
+
+	curr_gw = gw_get_selected_gw_node(bat_priv);
+	if (!curr_gw)
+		goto out;
 
 	rcu_read_lock();
 	hlist_for_each_entry_rcu(gw_node, node, &bat_priv->gw_list, list) {
@@ -320,22 +333,26 @@ void gw_node_update(struct bat_priv *bat_priv,
 				"Gateway %pM removed from gateway list\n",
 				orig_node->orig);
 
-			if (gw_node == rcu_dereference(bat_priv->curr_gw)) {
-				rcu_read_unlock();
-				gw_deselect(bat_priv);
-				return;
-			}
+			if (gw_node == curr_gw)
+				goto deselect;
 		}
 
-		rcu_read_unlock();
-		return;
+		goto unlock;
 	}
-	rcu_read_unlock();
 
 	if (new_gwflags == 0)
-		return;
+		goto unlock;
 
 	gw_node_add(bat_priv, orig_node, new_gwflags);
+	goto unlock;
+
+deselect:
+	gw_deselect(bat_priv);
+unlock:
+	rcu_read_unlock();
+out:
+	if (curr_gw)
+		gw_node_free_ref(curr_gw);
 }
 
 void gw_node_delete(struct bat_priv *bat_priv, struct orig_node *orig_node)
@@ -345,9 +362,12 @@ void gw_node_delete(struct bat_priv *bat_priv, struct orig_node *orig_node)
 
 void gw_node_purge(struct bat_priv *bat_priv)
 {
-	struct gw_node *gw_node;
+	struct gw_node *gw_node, *curr_gw;
 	struct hlist_node *node, *node_tmp;
 	unsigned long timeout = 2 * PURGE_TIMEOUT * HZ;
+	char do_deselect = 0;
+
+	curr_gw = gw_get_selected_gw_node(bat_priv);
 
 	spin_lock_bh(&bat_priv->gw_list_lock);
 
@@ -358,15 +378,21 @@ void gw_node_purge(struct bat_priv *bat_priv)
 		    atomic_read(&bat_priv->mesh_state) == MESH_ACTIVE)
 			continue;
 
-		if (rcu_dereference(bat_priv->curr_gw) == gw_node)
-			gw_deselect(bat_priv);
+		if (curr_gw == gw_node)
+			do_deselect = 1;
 
 		hlist_del_rcu(&gw_node->list);
 		gw_node_free_ref(gw_node);
 	}
 
-
 	spin_unlock_bh(&bat_priv->gw_list_lock);
+
+	/* gw_deselect() needs to acquire the gw_list_lock */
+	if (do_deselect)
+		gw_deselect(bat_priv);
+
+	if (curr_gw)
+		gw_node_free_ref(curr_gw);
 }
 
 /**
@@ -385,22 +411,22 @@ static int _write_buffer_text(struct bat_priv *bat_priv,
 	if (!router)
 		goto out;
 
-	rcu_read_lock();
-	curr_gw = rcu_dereference(bat_priv->curr_gw);
+	curr_gw = gw_get_selected_gw_node(bat_priv);
 
 	ret = seq_printf(seq, "%s %pM (%3i) %pM [%10s]: %3i - %i%s/%i%s\n",
-		       (curr_gw == gw_node ? "=>" : "  "),
-		       gw_node->orig_node->orig,
-		       router->tq_avg, router->addr,
-		       router->if_incoming->net_dev->name,
-		       gw_node->orig_node->gw_flags,
-		       (down > 2048 ? down / 1024 : down),
-		       (down > 2048 ? "MBit" : "KBit"),
-		       (up > 2048 ? up / 1024 : up),
-		       (up > 2048 ? "MBit" : "KBit"));
+			 (curr_gw == gw_node ? "=>" : "  "),
+			 gw_node->orig_node->orig,
+			 router->tq_avg, router->addr,
+			 router->if_incoming->net_dev->name,
+			 gw_node->orig_node->gw_flags,
+			 (down > 2048 ? down / 1024 : down),
+			 (down > 2048 ? "MBit" : "KBit"),
+			 (up > 2048 ? up / 1024 : up),
+			 (up > 2048 ? "MBit" : "KBit"));
 
-	rcu_read_unlock();
 	neigh_node_free_ref(router);
+	if (curr_gw)
+		gw_node_free_ref(curr_gw);
 out:
 	return ret;
 }
@@ -459,6 +485,7 @@ int gw_is_target(struct bat_priv *bat_priv, struct sk_buff *skb)
 	struct iphdr *iphdr;
 	struct ipv6hdr *ipv6hdr;
 	struct udphdr *udphdr;
+	struct gw_node *curr_gw;
 	unsigned int header_len = 0;
 
 	if (atomic_read(&bat_priv->gw_mode) == GW_MODE_OFF)
@@ -523,12 +550,11 @@ int gw_is_target(struct bat_priv *bat_priv, struct sk_buff *skb)
 	if (atomic_read(&bat_priv->gw_mode) == GW_MODE_SERVER)
 		return -1;
 
-	rcu_read_lock();
-	if (!rcu_dereference(bat_priv->curr_gw)) {
-		rcu_read_unlock();
+	curr_gw = gw_get_selected_gw_node(bat_priv);
+	if (!curr_gw)
 		return 0;
-	}
-	rcu_read_unlock();
 
+	if (curr_gw)
+		gw_node_free_ref(curr_gw);
 	return 1;
 }
diff --git a/net/batman-adv/gateway_client.h b/net/batman-adv/gateway_client.h
index 97c31d1..1ce8c60 100644
--- a/net/batman-adv/gateway_client.h
+++ b/net/batman-adv/gateway_client.h
@@ -24,7 +24,7 @@
 
 void gw_deselect(struct bat_priv *bat_priv);
 void gw_election(struct bat_priv *bat_priv);
-struct orig_node *gw_get_selected(struct bat_priv *bat_priv);
+struct orig_node *gw_get_selected_orig(struct bat_priv *bat_priv);
 void gw_check_election(struct bat_priv *bat_priv, struct orig_node *orig_node);
 void gw_node_update(struct bat_priv *bat_priv,
 		    struct orig_node *orig_node, uint8_t new_gwflags);
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index 19f84bd..d46acc8 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -289,7 +289,7 @@ int unicast_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv)
 
 	/* get routing information */
 	if (is_multicast_ether_addr(ethhdr->h_dest)) {
-		orig_node = (struct orig_node *)gw_get_selected(bat_priv);
+		orig_node = (struct orig_node *)gw_get_selected_orig(bat_priv);
 		if (orig_node)
 			goto find_router;
 	}
-- 
1.7.4.4
