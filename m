From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 01/14] batman-adv: remove bonding and interface alternating
Date: Mon, 13 Jan 2014 23:31:25 +0100
Message-ID: <1389652298-472-2-git-send-email-antonio@meshcoding.com>
References: <1389652298-472-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:21786 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752336AbaAMWdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 17:33:13 -0500
In-Reply-To: <1389652298-472-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <simon@open-mesh.com>

Remove bonding and interface alternating code - it will be replaced
by a new, network-wide multi interface optimization which enables
both bonding and interface alternating in a better way.

Keep the sysfs and find router function though, this will be needed
later.

Signed-off-by: Simon Wunderlich <simon@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/bat_iv_ogm.c |   5 -
 net/batman-adv/originator.c |  15 +--
 net/batman-adv/routing.c    | 300 ++------------------------------------------
 net/batman-adv/routing.h    |   9 --
 net/batman-adv/types.h      |  10 +-
 5 files changed, 12 insertions(+), 327 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 278d78b..48f5d35 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -974,8 +974,6 @@ batadv_iv_ogm_orig_update(struct batadv_priv *bat_priv,
 		neigh_node->last_ttl = batadv_ogm_packet->ttl;
 	}
 
-	batadv_bonding_candidate_add(bat_priv, orig_node, neigh_node);
-
 	/* if this neighbor already is our next hop there is nothing
 	 * to change
 	 */
@@ -1424,9 +1422,6 @@ static void batadv_iv_ogm_process(const struct ethhdr *ethhdr,
 	is_bidirect = batadv_iv_ogm_calc_tq(orig_node, orig_neigh_node,
 					    batadv_ogm_packet, if_incoming);
 
-	batadv_bonding_save_primary(orig_node, orig_neigh_node,
-				    batadv_ogm_packet);
-
 	/* update ranking if it is not a duplicate or has the same
 	 * seqno and similar ttl as the non-duplicate
 	 */
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 04a6d51..03db87f 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -196,8 +196,6 @@ batadv_neigh_node_new(struct batadv_hard_iface *hard_iface,
 	neigh_node->if_incoming = hard_iface;
 	neigh_node->orig_node = orig_node;
 
-	INIT_LIST_HEAD(&neigh_node->bonding_list);
-
 	/* extra reference for return */
 	atomic_set(&neigh_node->refcount, 2);
 
@@ -208,20 +206,13 @@ out:
 static void batadv_orig_node_free_rcu(struct rcu_head *rcu)
 {
 	struct hlist_node *node_tmp;
-	struct batadv_neigh_node *neigh_node, *tmp_neigh_node;
+	struct batadv_neigh_node *neigh_node;
 	struct batadv_orig_node *orig_node;
 
 	orig_node = container_of(rcu, struct batadv_orig_node, rcu);
 
 	spin_lock_bh(&orig_node->neigh_list_lock);
 
-	/* for all bonding members ... */
-	list_for_each_entry_safe(neigh_node, tmp_neigh_node,
-				 &orig_node->bond_list, bonding_list) {
-		list_del_rcu(&neigh_node->bonding_list);
-		batadv_neigh_node_free_ref(neigh_node);
-	}
-
 	/* for all neighbors towards this originator ... */
 	hlist_for_each_entry_safe(neigh_node, node_tmp,
 				  &orig_node->neigh_list, list) {
@@ -325,7 +316,6 @@ struct batadv_orig_node *batadv_orig_node_new(struct batadv_priv *bat_priv,
 		return NULL;
 
 	INIT_HLIST_HEAD(&orig_node->neigh_list);
-	INIT_LIST_HEAD(&orig_node->bond_list);
 	INIT_LIST_HEAD(&orig_node->vlan_list);
 	spin_lock_init(&orig_node->bcast_seqno_lock);
 	spin_lock_init(&orig_node->neigh_list_lock);
@@ -350,8 +340,6 @@ struct batadv_orig_node *batadv_orig_node_new(struct batadv_priv *bat_priv,
 	orig_node->bcast_seqno_reset = reset_time;
 	orig_node->batman_seqno_reset = reset_time;
 
-	atomic_set(&orig_node->bond_candidates, 0);
-
 	/* create a vlan object for the "untagged" LAN */
 	vlan = batadv_orig_node_vlan_new(orig_node, BATADV_NO_FLAGS);
 	if (!vlan)
@@ -416,7 +404,6 @@ batadv_purge_orig_neighbors(struct batadv_priv *bat_priv,
 			neigh_purged = true;
 
 			hlist_del_rcu(&neigh_node->list);
-			batadv_bonding_candidate_del(orig_node, neigh_node);
 			batadv_neigh_node_free_ref(neigh_node);
 		} else {
 			/* store the best_neighbour if this is the first
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 7e8aa17..4fd2687 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -96,115 +96,6 @@ out:
 		batadv_neigh_node_free_ref(router);
 }
 
-/* caller must hold the neigh_list_lock */
-void batadv_bonding_candidate_del(struct batadv_orig_node *orig_node,
-				  struct batadv_neigh_node *neigh_node)
-{
-	/* this neighbor is not part of our candidate list */
-	if (list_empty(&neigh_node->bonding_list))
-		goto out;
-
-	list_del_rcu(&neigh_node->bonding_list);
-	INIT_LIST_HEAD(&neigh_node->bonding_list);
-	batadv_neigh_node_free_ref(neigh_node);
-	atomic_dec(&orig_node->bond_candidates);
-
-out:
-	return;
-}
-
-/**
- * batadv_bonding_candidate_add - consider a new link for bonding mode towards
- *  the given originator
- * @bat_priv: the bat priv with all the soft interface information
- * @orig_node: the target node
- * @neigh_node: the neighbor representing the new link to consider for bonding
- *  mode
- */
-void batadv_bonding_candidate_add(struct batadv_priv *bat_priv,
-				  struct batadv_orig_node *orig_node,
-				  struct batadv_neigh_node *neigh_node)
-{
-	struct batadv_algo_ops *bao = bat_priv->bat_algo_ops;
-	struct batadv_neigh_node *tmp_neigh_node, *router = NULL;
-	uint8_t interference_candidate = 0;
-
-	spin_lock_bh(&orig_node->neigh_list_lock);
-
-	/* only consider if it has the same primary address ...  */
-	if (!batadv_compare_eth(orig_node->orig,
-				neigh_node->orig_node->primary_addr))
-		goto candidate_del;
-
-	router = batadv_orig_node_get_router(orig_node);
-	if (!router)
-		goto candidate_del;
-
-
-	/* ... and is good enough to be considered */
-	if (bao->bat_neigh_is_equiv_or_better(neigh_node, router))
-		goto candidate_del;
-
-	/* check if we have another candidate with the same mac address or
-	 * interface. If we do, we won't select this candidate because of
-	 * possible interference.
-	 */
-	hlist_for_each_entry_rcu(tmp_neigh_node,
-				 &orig_node->neigh_list, list) {
-		if (tmp_neigh_node == neigh_node)
-			continue;
-
-		/* we only care if the other candidate is even
-		 * considered as candidate.
-		 */
-		if (list_empty(&tmp_neigh_node->bonding_list))
-			continue;
-
-		if ((neigh_node->if_incoming == tmp_neigh_node->if_incoming) ||
-		    (batadv_compare_eth(neigh_node->addr,
-					tmp_neigh_node->addr))) {
-			interference_candidate = 1;
-			break;
-		}
-	}
-
-	/* don't care further if it is an interference candidate */
-	if (interference_candidate)
-		goto candidate_del;
-
-	/* this neighbor already is part of our candidate list */
-	if (!list_empty(&neigh_node->bonding_list))
-		goto out;
-
-	if (!atomic_inc_not_zero(&neigh_node->refcount))
-		goto out;
-
-	list_add_rcu(&neigh_node->bonding_list, &orig_node->bond_list);
-	atomic_inc(&orig_node->bond_candidates);
-	goto out;
-
-candidate_del:
-	batadv_bonding_candidate_del(orig_node, neigh_node);
-
-out:
-	spin_unlock_bh(&orig_node->neigh_list_lock);
-
-	if (router)
-		batadv_neigh_node_free_ref(router);
-}
-
-/* copy primary address for bonding */
-void
-batadv_bonding_save_primary(const struct batadv_orig_node *orig_node,
-			    struct batadv_orig_node *orig_neigh_node,
-			    const struct batadv_ogm_packet *batman_ogm_packet)
-{
-	if (!(batman_ogm_packet->flags & BATADV_PRIMARIES_FIRST_HOP))
-		return;
-
-	memcpy(orig_neigh_node->primary_addr, orig_node->orig, ETH_ALEN);
-}
-
 /* checks whether the host restarted and is in the protection time.
  * returns:
  *  0 if the packet is to be accepted
@@ -459,114 +350,6 @@ out:
 	return ret;
 }
 
-/* In the bonding case, send the packets in a round
- * robin fashion over the remaining interfaces.
- *
- * This method rotates the bonding list and increases the
- * returned router's refcount.
- */
-static struct batadv_neigh_node *
-batadv_find_bond_router(struct batadv_orig_node *primary_orig,
-			const struct batadv_hard_iface *recv_if)
-{
-	struct batadv_neigh_node *tmp_neigh_node;
-	struct batadv_neigh_node *router = NULL, *first_candidate = NULL;
-
-	rcu_read_lock();
-	list_for_each_entry_rcu(tmp_neigh_node, &primary_orig->bond_list,
-				bonding_list) {
-		if (!first_candidate)
-			first_candidate = tmp_neigh_node;
-
-		/* recv_if == NULL on the first node. */
-		if (tmp_neigh_node->if_incoming == recv_if)
-			continue;
-
-		if (!atomic_inc_not_zero(&tmp_neigh_node->refcount))
-			continue;
-
-		router = tmp_neigh_node;
-		break;
-	}
-
-	/* use the first candidate if nothing was found. */
-	if (!router && first_candidate &&
-	    atomic_inc_not_zero(&first_candidate->refcount))
-		router = first_candidate;
-
-	if (!router)
-		goto out;
-
-	/* selected should point to the next element
-	 * after the current router
-	 */
-	spin_lock_bh(&primary_orig->neigh_list_lock);
-	/* this is a list_move(), which unfortunately
-	 * does not exist as rcu version
-	 */
-	list_del_rcu(&primary_orig->bond_list);
-	list_add_rcu(&primary_orig->bond_list,
-		     &router->bonding_list);
-	spin_unlock_bh(&primary_orig->neigh_list_lock);
-
-out:
-	rcu_read_unlock();
-	return router;
-}
-
-/**
- * batadv_find_ifalter_router - find the best of the remaining candidates which
- *  are not using this interface
- * @bat_priv: the bat priv with all the soft interface information
- * @primary_orig: the destination
- * @recv_if: the interface that the router returned by this function has to not
- *  use
- *
- * Returns the best candidate towards primary_orig that is not using recv_if.
- * Increases the returned neighbor's refcount
- */
-static struct batadv_neigh_node *
-batadv_find_ifalter_router(struct batadv_priv *bat_priv,
-			   struct batadv_orig_node *primary_orig,
-			   const struct batadv_hard_iface *recv_if)
-{
-	struct batadv_neigh_node *router = NULL, *first_candidate = NULL;
-	struct batadv_algo_ops *bao = bat_priv->bat_algo_ops;
-	struct batadv_neigh_node *tmp_neigh_node;
-
-	rcu_read_lock();
-	list_for_each_entry_rcu(tmp_neigh_node, &primary_orig->bond_list,
-				bonding_list) {
-		if (!first_candidate)
-			first_candidate = tmp_neigh_node;
-
-		/* recv_if == NULL on the first node. */
-		if (tmp_neigh_node->if_incoming == recv_if)
-			continue;
-
-		if (router && bao->bat_neigh_cmp(tmp_neigh_node, router))
-			continue;
-
-		if (!atomic_inc_not_zero(&tmp_neigh_node->refcount))
-			continue;
-
-		/* decrement refcount of previously selected router */
-		if (router)
-			batadv_neigh_node_free_ref(router);
-
-		/* we found a better router (or at least one valid router) */
-		router = tmp_neigh_node;
-	}
-
-	/* use the first candidate if nothing was found. */
-	if (!router && first_candidate &&
-	    atomic_inc_not_zero(&first_candidate->refcount))
-		router = first_candidate;
-
-	rcu_read_unlock();
-	return router;
-}
-
 /**
  * batadv_check_unicast_packet - Check for malformed unicast packets
  * @bat_priv: the bat priv with all the soft interface information
@@ -604,95 +387,30 @@ static int batadv_check_unicast_packet(struct batadv_priv *bat_priv,
 	return 0;
 }
 
-/* find a suitable router for this originator, and use
- * bonding if possible. increases the found neighbors
- * refcount.
+/**
+ * batadv_find_router - find a suitable router for this originator
+ * @bat_priv: the bat priv with all the soft interface information
+ * @orig_node: the destination node
+ * @recv_if: pointer to interface this packet was received on
+ *
+ * Returns the router which should be used for this orig_node on
+ * this interface, or NULL if not available.
  */
 struct batadv_neigh_node *
 batadv_find_router(struct batadv_priv *bat_priv,
 		   struct batadv_orig_node *orig_node,
 		   const struct batadv_hard_iface *recv_if)
 {
-	struct batadv_orig_node *primary_orig_node;
-	struct batadv_orig_node *router_orig;
 	struct batadv_neigh_node *router;
-	static uint8_t zero_mac[ETH_ALEN] = {0, 0, 0, 0, 0, 0};
-	int bonding_enabled;
-	uint8_t *primary_addr;
 
 	if (!orig_node)
 		return NULL;
 
 	router = batadv_orig_node_get_router(orig_node);
-	if (!router)
-		goto err;
 
-	/* without bonding, the first node should
-	 * always choose the default router.
-	 */
-	bonding_enabled = atomic_read(&bat_priv->bonding);
+	/* TODO: fill this later with new bonding mechanism */
 
-	rcu_read_lock();
-	/* select default router to output */
-	router_orig = router->orig_node;
-	if (!router_orig)
-		goto err_unlock;
-
-	if ((!recv_if) && (!bonding_enabled))
-		goto return_router;
-
-	primary_addr = router_orig->primary_addr;
-
-	/* if we have something in the primary_addr, we can search
-	 * for a potential bonding candidate.
-	 */
-	if (batadv_compare_eth(primary_addr, zero_mac))
-		goto return_router;
-
-	/* find the orig_node which has the primary interface. might
-	 * even be the same as our router_orig in many cases
-	 */
-	if (batadv_compare_eth(primary_addr, router_orig->orig)) {
-		primary_orig_node = router_orig;
-	} else {
-		primary_orig_node = batadv_orig_hash_find(bat_priv,
-							  primary_addr);
-		if (!primary_orig_node)
-			goto return_router;
-
-		batadv_orig_node_free_ref(primary_orig_node);
-	}
-
-	/* with less than 2 candidates, we can't do any
-	 * bonding and prefer the original router.
-	 */
-	if (atomic_read(&primary_orig_node->bond_candidates) < 2)
-		goto return_router;
-
-	/* all nodes between should choose a candidate which
-	 * is is not on the interface where the packet came
-	 * in.
-	 */
-	batadv_neigh_node_free_ref(router);
-
-	if (bonding_enabled)
-		router = batadv_find_bond_router(primary_orig_node, recv_if);
-	else
-		router = batadv_find_ifalter_router(bat_priv, primary_orig_node,
-						    recv_if);
-
-return_router:
-	if (router && router->if_incoming->if_status != BATADV_IF_ACTIVE)
-		goto err_unlock;
-
-	rcu_read_unlock();
 	return router;
-err_unlock:
-	rcu_read_unlock();
-err:
-	if (router)
-		batadv_neigh_node_free_ref(router);
-	return NULL;
 }
 
 static int batadv_route_unicast_packet(struct sk_buff *skb,
diff --git a/net/batman-adv/routing.h b/net/batman-adv/routing.h
index c1eadfa..192f0aa 100644
--- a/net/batman-adv/routing.h
+++ b/net/batman-adv/routing.h
@@ -44,15 +44,6 @@ struct batadv_neigh_node *
 batadv_find_router(struct batadv_priv *bat_priv,
 		   struct batadv_orig_node *orig_node,
 		   const struct batadv_hard_iface *recv_if);
-void batadv_bonding_candidate_del(struct batadv_orig_node *orig_node,
-				  struct batadv_neigh_node *neigh_node);
-void batadv_bonding_candidate_add(struct batadv_priv *bat_priv,
-				  struct batadv_orig_node *orig_node,
-				  struct batadv_neigh_node *neigh_node);
-void batadv_bonding_save_primary(const struct batadv_orig_node *orig_node,
-				 struct batadv_orig_node *orig_neigh_node,
-				 const struct batadv_ogm_packet
-				 *batman_ogm_packet);
 int batadv_window_protected(struct batadv_priv *bat_priv, int32_t seq_num_diff,
 			    unsigned long *last_reset);
 
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 0430a04..0f68845 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -199,12 +199,10 @@ struct batadv_orig_bat_iv {
  *  last_bcast_seqno)
  * @last_bcast_seqno: last broadcast sequence number received by this host
  * @neigh_list: list of potential next hop neighbor towards this orig node
- * @neigh_list_lock: lock protecting neigh_list, router and bonding_list
+ * @neigh_list_lock: lock protecting neigh_list and router
  * @hash_entry: hlist node for batadv_priv::orig_hash
  * @bat_priv: pointer to soft_iface this orig node belongs to
  * @bcast_seqno_lock: lock protecting bcast_bits & last_bcast_seqno
- * @bond_candidates: how many candidates are available
- * @bond_list: list of bonding candidates
  * @refcount: number of contexts the object is used
  * @rcu: struct used for freeing in an RCU-safe manner
  * @in_coding_list: list of nodes this orig can hear
@@ -240,14 +238,12 @@ struct batadv_orig_node {
 	DECLARE_BITMAP(bcast_bits, BATADV_TQ_LOCAL_WINDOW_SIZE);
 	uint32_t last_bcast_seqno;
 	struct hlist_head neigh_list;
-	/* neigh_list_lock protects: neigh_list, router & bonding_list */
+	/* neigh_list_lock protects: neigh_list and router */
 	spinlock_t neigh_list_lock;
 	struct hlist_node hash_entry;
 	struct batadv_priv *bat_priv;
 	/* bcast_seqno_lock protects: bcast_bits & last_bcast_seqno */
 	spinlock_t bcast_seqno_lock;
-	atomic_t bond_candidates;
-	struct list_head bond_list;
 	atomic_t refcount;
 	struct rcu_head rcu;
 #ifdef CONFIG_BATMAN_ADV_NC
@@ -320,7 +316,6 @@ struct batadv_neigh_bat_iv {
  * @if_incoming: pointer to incoming hard interface
  * @last_seen: when last packet via this neighbor was received
  * @last_ttl: last received ttl from this neigh node
- * @bonding_list: list node for batadv_orig_node::bond_list
  * @refcount: number of contexts the object is used
  * @rcu: struct used for freeing in an RCU-safe manner
  * @bat_iv: B.A.T.M.A.N. IV private structure
@@ -332,7 +327,6 @@ struct batadv_neigh_node {
 	struct batadv_hard_iface *if_incoming;
 	unsigned long last_seen;
 	uint8_t last_ttl;
-	struct list_head bonding_list;
 	atomic_t refcount;
 	struct rcu_head rcu;
 	struct batadv_neigh_bat_iv bat_iv;
-- 
1.8.5.2
