From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 06/16] batman-adv: adapt bonding to use the new API functions
Date: Wed, 23 Oct 2013 18:04:53 +0200
Message-ID: <1382544303-2694-7-git-send-email-antonio@meshcoding.com>
References: <1382544303-2694-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:20033 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752313Ab3JWQFw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 12:05:52 -0400
In-Reply-To: <1382544303-2694-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/bat_iv_ogm.c |  2 +-
 net/batman-adv/routing.c    | 42 +++++++++++++++++++++++++++++-------------
 net/batman-adv/routing.h    |  3 ++-
 3 files changed, 32 insertions(+), 15 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 4376fe7..7cdc394 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -853,7 +853,7 @@ batadv_iv_ogm_orig_update(struct batadv_priv *bat_priv,
 		neigh_node->last_ttl = batadv_ogm_packet->header.ttl;
 	}
 
-	batadv_bonding_candidate_add(orig_node, neigh_node);
+	batadv_bonding_candidate_add(bat_priv, orig_node, neigh_node);
 
 	/* if this neighbor already is our next hop there is nothing
 	 * to change
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 5b78a71..71fba14 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -115,11 +115,21 @@ out:
 	return;
 }
 
-void batadv_bonding_candidate_add(struct batadv_orig_node *orig_node,
+/**
+ * batadv_bonding_candidate_add - consider a new link for bonding mode towards
+ *  the given originator
+ * @bat_priv: the bat priv with all the soft interface information
+ * @orig_node: the target node
+ * @neigh_node: the neighbor representing the new link to consider for bonding
+ *  mode
+ */
+void batadv_bonding_candidate_add(struct batadv_priv *bat_priv,
+				  struct batadv_orig_node *orig_node,
 				  struct batadv_neigh_node *neigh_node)
 {
+	struct batadv_algo_ops *bao = bat_priv->bat_algo_ops;
 	struct batadv_neigh_node *tmp_neigh_node, *router = NULL;
-	uint8_t interference_candidate = 0, tq;
+	uint8_t interference_candidate = 0;
 
 	spin_lock_bh(&orig_node->neigh_list_lock);
 
@@ -134,8 +144,7 @@ void batadv_bonding_candidate_add(struct batadv_orig_node *orig_node,
 
 
 	/* ... and is good enough to be considered */
-	tq = router->bat_iv.tq_avg - BATADV_BONDING_TQ_THRESHOLD;
-	if (neigh_node->bat_iv.tq_avg < tq)
+	if (bao->bat_neigh_is_equiv_or_better(neigh_node, router))
 		goto candidate_del;
 
 	/* check if we have another candidate with the same mac address or
@@ -481,18 +490,25 @@ out:
 	return router;
 }
 
-/* Interface Alternating: Use the best of the
- * remaining candidates which are not using
- * this interface.
+/**
+ * batadv_find_ifalter_router - find the best of the remaining candidates which
+ *  are not using this interface
+ * @bat_priv: the bat priv with all the soft interface information
+ * @primary_orig: the destination
+ * @recv_if: the interface that the router returned by this function has to not
+ *  use
  *
- * Increases the returned router's refcount
+ * Returns the best candidate towards primary_orig that is not using recv_if.
+ * Increases the returned neighbor's refcount
  */
 static struct batadv_neigh_node *
-batadv_find_ifalter_router(struct batadv_orig_node *primary_orig,
+batadv_find_ifalter_router(struct batadv_priv *bat_priv,
+			   struct batadv_orig_node *primary_orig,
 			   const struct batadv_hard_iface *recv_if)
 {
-	struct batadv_neigh_node *tmp_neigh_node;
 	struct batadv_neigh_node *router = NULL, *first_candidate = NULL;
+	struct batadv_algo_ops *bao = bat_priv->bat_algo_ops;
+	struct batadv_neigh_node *tmp_neigh_node;
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(tmp_neigh_node, &primary_orig->bond_list,
@@ -504,8 +520,7 @@ batadv_find_ifalter_router(struct batadv_orig_node *primary_orig,
 		if (tmp_neigh_node->if_incoming == recv_if)
 			continue;
 
-		if (router &&
-		    tmp_neigh_node->bat_iv.tq_avg <= router->bat_iv.tq_avg)
+		if (router && bao->bat_neigh_cmp(tmp_neigh_node, router))
 			continue;
 
 		if (!atomic_inc_not_zero(&tmp_neigh_node->refcount))
@@ -639,7 +654,8 @@ batadv_find_router(struct batadv_priv *bat_priv,
 	if (bonding_enabled)
 		router = batadv_find_bond_router(primary_orig_node, recv_if);
 	else
-		router = batadv_find_ifalter_router(primary_orig_node, recv_if);
+		router = batadv_find_ifalter_router(bat_priv, primary_orig_node,
+						    recv_if);
 
 return_router:
 	if (router && router->if_incoming->if_status != BATADV_IF_ACTIVE)
diff --git a/net/batman-adv/routing.h b/net/batman-adv/routing.h
index 55d637a..19544dd 100644
--- a/net/batman-adv/routing.h
+++ b/net/batman-adv/routing.h
@@ -48,7 +48,8 @@ batadv_find_router(struct batadv_priv *bat_priv,
 		   const struct batadv_hard_iface *recv_if);
 void batadv_bonding_candidate_del(struct batadv_orig_node *orig_node,
 				  struct batadv_neigh_node *neigh_node);
-void batadv_bonding_candidate_add(struct batadv_orig_node *orig_node,
+void batadv_bonding_candidate_add(struct batadv_priv *bat_priv,
+				  struct batadv_orig_node *orig_node,
 				  struct batadv_neigh_node *neigh_node);
 void batadv_bonding_save_primary(const struct batadv_orig_node *orig_node,
 				 struct batadv_orig_node *orig_neigh_node,
-- 
1.8.4
