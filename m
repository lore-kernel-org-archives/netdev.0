From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 10/12] batman-adv: gateway election code refactoring
Date: Mon, 20 Jun 2011 12:17:03 +0200
Message-ID: <1308565025-21293-11-git-send-email-sven@narfation.org>
References: <1308565025-21293-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Sven Eckelmann <sven@narfation.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:57196 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753910Ab1FTKRg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jun 2011 06:17:36 -0400
In-Reply-To: <1308565025-21293-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>

The gateway election mechanism has been a little revised. Now the
gw_election is trigered by an atomic_t flag (gw_reselect) which is set
to 1 in case of election needed, avoding to set curr_gw to NULL.

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
---
 net/batman-adv/gateway_client.c |  142 +++++++++++++++++++++++----------------
 net/batman-adv/main.c           |    1 +
 net/batman-adv/types.h          |    1 +
 3 files changed, 85 insertions(+), 59 deletions(-)

diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 7248de2..0350c0c 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -20,6 +20,7 @@
  */
 
 #include "main.h"
+#include "bat_sysfs.h"
 #include "gateway_client.h"
 #include "gateway_common.h"
 #include "hard-interface.h"
@@ -97,40 +98,19 @@ static void gw_select(struct bat_priv *bat_priv, struct gw_node *new_gw_node)
 
 void gw_deselect(struct bat_priv *bat_priv)
 {
-	gw_select(bat_priv, NULL);
+	atomic_set(&bat_priv->gw_reselect, 1);
 }
 
-void gw_election(struct bat_priv *bat_priv)
+static struct gw_node *gw_get_best_gw_node(struct bat_priv *bat_priv)
 {
-	struct hlist_node *node;
-	struct gw_node *gw_node, *curr_gw = NULL, *curr_gw_tmp = NULL;
 	struct neigh_node *router;
-	uint8_t max_tq = 0;
+	struct hlist_node *node;
+	struct gw_node *gw_node, *curr_gw = NULL;
 	uint32_t max_gw_factor = 0, tmp_gw_factor = 0;
+	uint8_t max_tq = 0;
 	int down, up;
 
-	/**
-	 * The batman daemon checks here if we already passed a full originator
-	 * cycle in order to make sure we don't choose the first gateway we
-	 * hear about. This check is based on the daemon's uptime which we
-	 * don't have.
-	 **/
-	if (atomic_read(&bat_priv->gw_mode) != GW_MODE_CLIENT)
-		return;
-
-	curr_gw = gw_get_selected_gw_node(bat_priv);
-	if (curr_gw)
-		goto out;
-
 	rcu_read_lock();
-	if (hlist_empty(&bat_priv->gw_list)) {
-		bat_dbg(DBG_BATMAN, bat_priv,
-			"Removing selected gateway - "
-			"no gateway in range\n");
-		gw_deselect(bat_priv);
-		goto unlock;
-	}
-
 	hlist_for_each_entry_rcu(gw_node, node, &bat_priv->gw_list, list) {
 		if (gw_node->deleted)
 			continue;
@@ -139,6 +119,9 @@ void gw_election(struct bat_priv *bat_priv)
 		if (!router)
 			continue;
 
+		if (!atomic_inc_not_zero(&gw_node->refcount))
+			goto next;
+
 		switch (atomic_read(&bat_priv->gw_sel_class)) {
 		case 1: /* fast connection */
 			gw_bandwidth_to_kbit(gw_node->orig_node->gw_flags,
@@ -151,8 +134,12 @@ void gw_election(struct bat_priv *bat_priv)
 
 			if ((tmp_gw_factor > max_gw_factor) ||
 			    ((tmp_gw_factor == max_gw_factor) &&
-			     (router->tq_avg > max_tq)))
-				curr_gw_tmp = gw_node;
+			     (router->tq_avg > max_tq))) {
+				if (curr_gw)
+					gw_node_free_ref(curr_gw);
+				curr_gw = gw_node;
+				atomic_inc(&curr_gw->refcount);
+			}
 			break;
 
 		default: /**
@@ -163,8 +150,12 @@ void gw_election(struct bat_priv *bat_priv)
 			  *     soon as a better gateway appears which has
 			  *     $routing_class more tq points)
 			  **/
-			if (router->tq_avg > max_tq)
-				curr_gw_tmp = gw_node;
+			if (router->tq_avg > max_tq) {
+				if (curr_gw)
+					gw_node_free_ref(curr_gw);
+				curr_gw = gw_node;
+				atomic_inc(&curr_gw->refcount);
+			}
 			break;
 		}
 
@@ -174,42 +165,75 @@ void gw_election(struct bat_priv *bat_priv)
 		if (tmp_gw_factor > max_gw_factor)
 			max_gw_factor = tmp_gw_factor;
 
-		neigh_node_free_ref(router);
-	}
-
-	if (curr_gw != curr_gw_tmp) {
-		router = orig_node_get_router(curr_gw_tmp->orig_node);
-		if (!router)
-			goto unlock;
-
-		if ((curr_gw) && (!curr_gw_tmp))
-			bat_dbg(DBG_BATMAN, bat_priv,
-				"Removing selected gateway - "
-				"no gateway in range\n");
-		else if ((!curr_gw) && (curr_gw_tmp))
-			bat_dbg(DBG_BATMAN, bat_priv,
-				"Adding route to gateway %pM "
-				"(gw_flags: %i, tq: %i)\n",
-				curr_gw_tmp->orig_node->orig,
-				curr_gw_tmp->orig_node->gw_flags,
-				router->tq_avg);
-		else
-			bat_dbg(DBG_BATMAN, bat_priv,
-				"Changing route to gateway %pM "
-				"(gw_flags: %i, tq: %i)\n",
-				curr_gw_tmp->orig_node->orig,
-				curr_gw_tmp->orig_node->gw_flags,
-				router->tq_avg);
+		gw_node_free_ref(gw_node);
 
+next:
 		neigh_node_free_ref(router);
-		gw_select(bat_priv, curr_gw_tmp);
 	}
-
-unlock:
 	rcu_read_unlock();
+
+	return curr_gw;
+}
+
+void gw_election(struct bat_priv *bat_priv)
+{
+	struct gw_node *curr_gw = NULL, *next_gw = NULL;
+	struct neigh_node *router = NULL;
+
+	/**
+	 * The batman daemon checks here if we already passed a full originator
+	 * cycle in order to make sure we don't choose the first gateway we
+	 * hear about. This check is based on the daemon's uptime which we
+	 * don't have.
+	 **/
+	if (atomic_read(&bat_priv->gw_mode) != GW_MODE_CLIENT)
+		goto out;
+
+	if (!atomic_dec_not_zero(&bat_priv->gw_reselect))
+		goto out;
+
+	curr_gw = gw_get_selected_gw_node(bat_priv);
+
+	next_gw = gw_get_best_gw_node(bat_priv);
+
+	if (curr_gw == next_gw)
+		goto out;
+
+	if (next_gw) {
+		router = orig_node_get_router(next_gw->orig_node);
+		if (!router) {
+			gw_deselect(bat_priv);
+			goto out;
+		}
+	}
+
+	if ((curr_gw) && (!next_gw)) {
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"Removing selected gateway - no gateway in range\n");
+	} else if ((!curr_gw) && (next_gw)) {
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"Adding route to gateway %pM (gw_flags: %i, tq: %i)\n",
+			next_gw->orig_node->orig,
+			next_gw->orig_node->gw_flags,
+			router->tq_avg);
+	} else {
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"Changing route to gateway %pM "
+			"(gw_flags: %i, tq: %i)\n",
+			next_gw->orig_node->orig,
+			next_gw->orig_node->gw_flags,
+			router->tq_avg);
+	}
+
+	gw_select(bat_priv, next_gw);
+
 out:
 	if (curr_gw)
 		gw_node_free_ref(curr_gw);
+	if (next_gw)
+		gw_node_free_ref(next_gw);
+	if (router)
+		neigh_node_free_ref(router);
 }
 
 void gw_check_election(struct bat_priv *bat_priv, struct orig_node *orig_node)
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index c2b06b7..e367e69 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -113,6 +113,7 @@ int mesh_init(struct net_device *soft_iface)
 	if (vis_init(bat_priv) < 1)
 		goto err;
 
+	atomic_set(&bat_priv->gw_reselect, 0);
 	atomic_set(&bat_priv->mesh_state, MESH_ACTIVE);
 	goto end;
 
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 11e8569..85cf122 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -201,6 +201,7 @@ struct bat_priv {
 	struct delayed_work orig_work;
 	struct delayed_work vis_work;
 	struct gw_node __rcu *curr_gw;  /* rcu protected pointer */
+	atomic_t gw_reselect;
 	struct hard_iface __rcu *primary_if;  /* rcu protected pointer */
 	struct vis_info *my_vis_info;
 };
-- 
1.7.5.3

