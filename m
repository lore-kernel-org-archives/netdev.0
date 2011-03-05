From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 10/28] batman-adv: protect bonding with rcu locks
Date: Sat,  5 Mar 2011 13:28:24 +0100
Message-ID: <1299328122-21468-11-git-send-email-sven@narfation.org>
References: <1299328122-21468-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:36288 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753248Ab1CEM3p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Mar 2011 07:29:45 -0500
In-Reply-To: <1299328122-21468-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>

bonding / alternating candidates need to be secured by rcu locks
as well. This patch therefore converts the bonding list
from a plain pointer list to a rcu securable lists and references
the bonding candidates.

Signed-off-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/hard-interface.c |    2 +-
 net/batman-adv/originator.c     |   25 +++-
 net/batman-adv/originator.h     |    1 +
 net/batman-adv/routing.c        |  313 ++++++++++++++++++++-------------------
 net/batman-adv/routing.h        |    6 +-
 net/batman-adv/types.h          |    9 +-
 net/batman-adv/unicast.c        |    2 +-
 7 files changed, 195 insertions(+), 163 deletions(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index f2131f4..e2b001a 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -271,7 +271,7 @@ static void hardif_activate_interface(struct batman_if *batman_if)
 static void hardif_deactivate_interface(struct batman_if *batman_if)
 {
 	if ((batman_if->if_status != IF_ACTIVE) &&
-	   (batman_if->if_status != IF_TO_BE_ACTIVATED))
+	    (batman_if->if_status != IF_TO_BE_ACTIVATED))
 		return;
 
 	batman_if->if_status = IF_INACTIVE;
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 71dfc24..a85eadc 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -75,6 +75,14 @@ static void neigh_node_free_rcu(struct rcu_head *rcu)
 	kref_put(&neigh_node->refcount, neigh_node_free_ref);
 }
 
+void neigh_node_free_rcu_bond(struct rcu_head *rcu)
+{
+	struct neigh_node *neigh_node;
+
+	neigh_node = container_of(rcu, struct neigh_node, rcu_bond);
+	kref_put(&neigh_node->refcount, neigh_node_free_ref);
+}
+
 struct neigh_node *create_neighbor(struct orig_node *orig_node,
 				   struct orig_node *orig_neigh_node,
 				   uint8_t *neigh,
@@ -91,6 +99,7 @@ struct neigh_node *create_neighbor(struct orig_node *orig_node,
 		return NULL;
 
 	INIT_HLIST_NODE(&neigh_node->list);
+	INIT_LIST_HEAD(&neigh_node->bonding_list);
 
 	memcpy(neigh_node->addr, neigh, ETH_ALEN);
 	neigh_node->orig_node = orig_neigh_node;
@@ -106,13 +115,20 @@ struct neigh_node *create_neighbor(struct orig_node *orig_node,
 void orig_node_free_ref(struct kref *refcount)
 {
 	struct hlist_node *node, *node_tmp;
-	struct neigh_node *neigh_node;
+	struct neigh_node *neigh_node, *tmp_neigh_node;
 	struct orig_node *orig_node;
 
 	orig_node = container_of(refcount, struct orig_node, refcount);
 
 	spin_lock_bh(&orig_node->neigh_list_lock);
 
+	/* for all bonding members ... */
+	list_for_each_entry_safe(neigh_node, tmp_neigh_node,
+				 &orig_node->bond_list, bonding_list) {
+		list_del_rcu(&neigh_node->bonding_list);
+		call_rcu(&neigh_node->rcu_bond, neigh_node_free_rcu_bond);
+	}
+
 	/* for all neighbors towards this originator ... */
 	hlist_for_each_entry_safe(neigh_node, node, node_tmp,
 				  &orig_node->neigh_list, list) {
@@ -207,6 +223,7 @@ struct orig_node *get_orig_node(struct bat_priv *bat_priv, uint8_t *addr)
 		return NULL;
 
 	INIT_HLIST_HEAD(&orig_node->neigh_list);
+	INIT_LIST_HEAD(&orig_node->bond_list);
 	spin_lock_init(&orig_node->ogm_cnt_lock);
 	spin_lock_init(&orig_node->neigh_list_lock);
 	kref_init(&orig_node->refcount);
@@ -220,6 +237,8 @@ struct orig_node *get_orig_node(struct bat_priv *bat_priv, uint8_t *addr)
 	orig_node->batman_seqno_reset = jiffies - 1
 					- msecs_to_jiffies(RESET_PROTECTION_MS);
 
+	atomic_set(&orig_node->bond_candidates, 0);
+
 	size = bat_priv->num_ifaces * sizeof(unsigned long) * NUM_WORDS;
 
 	orig_node->bcast_own = kzalloc(size, GFP_ATOMIC);
@@ -295,6 +314,7 @@ static bool purge_orig_neighbors(struct bat_priv *bat_priv,
 			neigh_purged = true;
 
 			hlist_del_rcu(&neigh_node->list);
+			bonding_candidate_del(orig_node, neigh_node);
 			call_rcu(&neigh_node->rcu, neigh_node_free_rcu);
 		} else {
 			if ((!*best_neigh_node) ||
@@ -326,9 +346,6 @@ static bool purge_orig_node(struct bat_priv *bat_priv,
 				      best_neigh_node,
 				      orig_node->hna_buff,
 				      orig_node->hna_buff_len);
-			/* update bonding candidates, we could have lost
-			 * some candidates. */
-			update_bonding_candidates(orig_node);
 		}
 	}
 
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
index edc64dc..360dfd1 100644
--- a/net/batman-adv/originator.h
+++ b/net/batman-adv/originator.h
@@ -26,6 +26,7 @@ int originator_init(struct bat_priv *bat_priv);
 void originator_free(struct bat_priv *bat_priv);
 void purge_orig_ref(struct bat_priv *bat_priv);
 void orig_node_free_ref(struct kref *refcount);
+void neigh_node_free_rcu_bond(struct rcu_head *rcu);
 struct orig_node *get_orig_node(struct bat_priv *bat_priv, uint8_t *addr);
 struct neigh_node *create_neighbor(struct orig_node *orig_node,
 				   struct orig_node *orig_neigh_node,
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 7627ebe..1ad14da 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -271,6 +271,101 @@ out:
 	return ret;
 }
 
+/* caller must hold the neigh_list_lock */
+void bonding_candidate_del(struct orig_node *orig_node,
+			   struct neigh_node *neigh_node)
+{
+	/* this neighbor is not part of our candidate list */
+	if (list_empty(&neigh_node->bonding_list))
+		goto out;
+
+	list_del_rcu(&neigh_node->bonding_list);
+	call_rcu(&neigh_node->rcu_bond, neigh_node_free_rcu_bond);
+	INIT_LIST_HEAD(&neigh_node->bonding_list);
+	atomic_dec(&orig_node->bond_candidates);
+
+out:
+	return;
+}
+
+static void bonding_candidate_add(struct orig_node *orig_node,
+				  struct neigh_node *neigh_node)
+{
+	struct hlist_node *node;
+	struct neigh_node *tmp_neigh_node;
+	uint8_t best_tq, interference_candidate = 0;
+
+	spin_lock_bh(&orig_node->neigh_list_lock);
+
+	/* only consider if it has the same primary address ...  */
+	if (!compare_orig(orig_node->orig,
+			  neigh_node->orig_node->primary_addr))
+		goto candidate_del;
+
+	if (!orig_node->router)
+		goto candidate_del;
+
+	best_tq = orig_node->router->tq_avg;
+
+	/* ... and is good enough to be considered */
+	if (neigh_node->tq_avg < best_tq - BONDING_TQ_THRESHOLD)
+		goto candidate_del;
+
+	/**
+	 * check if we have another candidate with the same mac address or
+	 * interface. If we do, we won't select this candidate because of
+	 * possible interference.
+	 */
+	hlist_for_each_entry_rcu(tmp_neigh_node, node,
+				 &orig_node->neigh_list, list) {
+
+		if (tmp_neigh_node == neigh_node)
+			continue;
+
+		/* we only care if the other candidate is even
+		* considered as candidate. */
+		if (list_empty(&tmp_neigh_node->bonding_list))
+			continue;
+
+		if ((neigh_node->if_incoming == tmp_neigh_node->if_incoming) ||
+		    (compare_orig(neigh_node->addr, tmp_neigh_node->addr))) {
+			interference_candidate = 1;
+			break;
+		}
+	}
+
+	/* don't care further if it is an interference candidate */
+	if (interference_candidate)
+		goto candidate_del;
+
+	/* this neighbor already is part of our candidate list */
+	if (!list_empty(&neigh_node->bonding_list))
+		goto out;
+
+	list_add_rcu(&neigh_node->bonding_list, &orig_node->bond_list);
+	kref_get(&neigh_node->refcount);
+	atomic_inc(&orig_node->bond_candidates);
+	goto out;
+
+candidate_del:
+	bonding_candidate_del(orig_node, neigh_node);
+
+out:
+	spin_unlock_bh(&orig_node->neigh_list_lock);
+	return;
+}
+
+/* copy primary address for bonding */
+static void bonding_save_primary(struct orig_node *orig_node,
+				 struct orig_node *orig_neigh_node,
+				 struct batman_packet *batman_packet)
+{
+	if (!(batman_packet->flags & PRIMARIES_FIRST_HOP))
+		return;
+
+	memcpy(orig_neigh_node->primary_addr, orig_node->orig, ETH_ALEN);
+}
+
 static void update_orig(struct bat_priv *bat_priv,
 			struct orig_node *orig_node,
 			struct ethhdr *ethhdr,
@@ -339,6 +434,8 @@ static void update_orig(struct bat_priv *bat_priv,
 		neigh_node->last_ttl = batman_packet->ttl;
 	}
 
+	bonding_candidate_add(orig_node, neigh_node);
+
 	tmp_hna_buff_len = (hna_buff_len > batman_packet->num_hna * ETH_ALEN ?
 			    batman_packet->num_hna * ETH_ALEN : hna_buff_len);
 
@@ -497,123 +594,10 @@ err:
 	return -1;
 }
 
-/* copy primary address for bonding */
-static void mark_bonding_address(struct orig_node *orig_node,
-				 struct orig_node *orig_neigh_node,
-				 struct batman_packet *batman_packet)
-
-{
-	if (batman_packet->flags & PRIMARIES_FIRST_HOP)
-		memcpy(orig_neigh_node->primary_addr,
-		       orig_node->orig, ETH_ALEN);
-
-	return;
-}
-
-/* mark possible bond.candidates in the neighbor list */
-void update_bonding_candidates(struct orig_node *orig_node)
-{
-	int candidates;
-	int interference_candidate;
-	int best_tq;
-	struct hlist_node *node, *node2;
-	struct neigh_node *tmp_neigh_node, *tmp_neigh_node2;
-	struct neigh_node *first_candidate, *last_candidate;
-
-	/* update the candidates for this originator */
-	if (!orig_node->router) {
-		orig_node->bond.candidates = 0;
-		return;
-	}
-
-	best_tq = orig_node->router->tq_avg;
-
-	/* update bond.candidates */
-
-	candidates = 0;
-
-	/* mark other nodes which also received "PRIMARIES FIRST HOP" packets
-	 * as "bonding partner" */
-
-	/* first, zero the list */
-	rcu_read_lock();
-	hlist_for_each_entry_rcu(tmp_neigh_node, node,
-				 &orig_node->neigh_list, list) {
-		tmp_neigh_node->next_bond_candidate = NULL;
-	}
-	rcu_read_unlock();
-
-	first_candidate = NULL;
-	last_candidate = NULL;
-
-	rcu_read_lock();
-	hlist_for_each_entry_rcu(tmp_neigh_node, node,
-				 &orig_node->neigh_list, list) {
-
-		/* only consider if it has the same primary address ...  */
-		if (memcmp(orig_node->orig,
-				tmp_neigh_node->orig_node->primary_addr,
-				ETH_ALEN) != 0)
-			continue;
-
-		/* ... and is good enough to be considered */
-		if (tmp_neigh_node->tq_avg < best_tq - BONDING_TQ_THRESHOLD)
-			continue;
-
-		/* check if we have another candidate with the same
-		 * mac address or interface. If we do, we won't
-		 * select this candidate because of possible interference. */
-
-		interference_candidate = 0;
-		hlist_for_each_entry_rcu(tmp_neigh_node2, node2,
-					 &orig_node->neigh_list, list) {
-
-			if (tmp_neigh_node2 == tmp_neigh_node)
-				continue;
-
-			/* we only care if the other candidate is even
-			 * considered as candidate. */
-			if (!tmp_neigh_node2->next_bond_candidate)
-				continue;
-
-
-			if ((tmp_neigh_node->if_incoming ==
-				tmp_neigh_node2->if_incoming)
-				|| (memcmp(tmp_neigh_node->addr,
-				tmp_neigh_node2->addr, ETH_ALEN) == 0)) {
-
-				interference_candidate = 1;
-				break;
-			}
-		}
-		/* don't care further if it is an interference candidate */
-		if (interference_candidate)
-			continue;
-
-		if (!first_candidate) {
-			first_candidate = tmp_neigh_node;
-			tmp_neigh_node->next_bond_candidate = first_candidate;
-		} else
-			tmp_neigh_node->next_bond_candidate = last_candidate;
-
-		last_candidate = tmp_neigh_node;
-
-		candidates++;
-	}
-	rcu_read_unlock();
-
-	if (candidates > 0) {
-		first_candidate->next_bond_candidate = last_candidate;
-		orig_node->bond.selected = first_candidate;
-	}
-
-	orig_node->bond.candidates = candidates;
-}
-
 void receive_bat_packet(struct ethhdr *ethhdr,
-				struct batman_packet *batman_packet,
-				unsigned char *hna_buff, int hna_buff_len,
-				struct batman_if *if_incoming)
+			struct batman_packet *batman_packet,
+			unsigned char *hna_buff, int hna_buff_len,
+			struct batman_if *if_incoming)
 {
 	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
 	struct batman_if *batman_if;
@@ -795,6 +779,8 @@ void receive_bat_packet(struct ethhdr *ethhdr,
 	is_bidirectional = is_bidirectional_neigh(orig_node, orig_neigh_node,
 						batman_packet, if_incoming);
 
+	bonding_save_primary(orig_node, orig_neigh_node, batman_packet);
+
 	/* update ranking if it is not a duplicate or has the same
 	 * seqno and similar ttl as the non-duplicate */
 	if (is_bidirectional &&
@@ -804,9 +790,6 @@ void receive_bat_packet(struct ethhdr *ethhdr,
 		update_orig(bat_priv, orig_node, ethhdr, batman_packet,
 			    if_incoming, hna_buff, hna_buff_len, is_duplicate);
 
-	mark_bonding_address(orig_node, orig_neigh_node, batman_packet);
-	update_bonding_candidates(orig_node);
-
 	/* is single hop (direct) neighbor */
 	if (is_single_hop_neigh) {
 
@@ -1095,14 +1078,15 @@ int recv_icmp_packet(struct sk_buff *skb, struct batman_if *recv_if)
 }
 
 /* find a suitable router for this originator, and use
- * bonding if possible. */
+ * bonding if possible. increases the found neighbors
+ * refcount.*/
 struct neigh_node *find_router(struct bat_priv *bat_priv,
 			       struct orig_node *orig_node,
 			       struct batman_if *recv_if)
 {
 	struct orig_node *primary_orig_node;
 	struct orig_node *router_orig;
-	struct neigh_node *router, *first_candidate, *best_router;
+	struct neigh_node *router, *first_candidate, *tmp_neigh_node;
 	static uint8_t zero_mac[ETH_ALEN] = {0, 0, 0, 0, 0, 0};
 	int bonding_enabled;
 
@@ -1114,18 +1098,25 @@ struct neigh_node *find_router(struct bat_priv *bat_priv,
 
 	/* without bonding, the first node should
 	 * always choose the default router. */
-
 	bonding_enabled = atomic_read(&bat_priv->bonding);
 
-	if ((!recv_if) && (!bonding_enabled))
-		return orig_node->router;
-
+	rcu_read_lock();
+	/* select default router to output */
+	router = orig_node->router;
 	router_orig = orig_node->router->orig_node;
+	if (!router_orig) {
+		rcu_read_unlock();
+		return NULL;
+	}
+
+
+	if ((!recv_if) && (!bonding_enabled))
+		goto return_router;
 
 	/* if we have something in the primary_addr, we can search
 	 * for a potential bonding candidate. */
 	if (memcmp(router_orig->primary_addr, zero_mac, ETH_ALEN) == 0)
-		return orig_node->router;
+		goto return_router;
 
 	/* find the orig_node which has the primary interface. might
 	 * even be the same as our router_orig in many cases */
@@ -1134,60 +1125,81 @@ struct neigh_node *find_router(struct bat_priv *bat_priv,
 				router_orig->orig, ETH_ALEN) == 0) {
 		primary_orig_node = router_orig;
 	} else {
-		rcu_read_lock();
 		primary_orig_node = hash_find(bat_priv->orig_hash, compare_orig,
 					       choose_orig,
 					       router_orig->primary_addr);
-		rcu_read_unlock();
-
 		if (!primary_orig_node)
-			return orig_node->router;
+			goto return_router;
 	}
 
 	/* with less than 2 candidates, we can't do any
 	 * bonding and prefer the original router. */
-
-	if (primary_orig_node->bond.candidates < 2)
-		return orig_node->router;
+	if (atomic_read(&primary_orig_node->bond_candidates) < 2)
+		goto return_router;
 
 
 	/* all nodes between should choose a candidate which
 	 * is is not on the interface where the packet came
 	 * in. */
-	first_candidate = primary_orig_node->bond.selected;
-	router = first_candidate;
+
+	first_candidate = NULL;
+	router = NULL;
 
 	if (bonding_enabled) {
 		/* in the bonding case, send the packets in a round
 		 * robin fashion over the remaining interfaces. */
-		do {
+
+		list_for_each_entry_rcu(tmp_neigh_node,
+				&primary_orig_node->bond_list, bonding_list) {
+			if (!first_candidate)
+				first_candidate = tmp_neigh_node;
 			/* recv_if == NULL on the first node. */
-			if (router->if_incoming != recv_if)
+			if (tmp_neigh_node->if_incoming != recv_if) {
+				router = tmp_neigh_node;
 				break;
+			}
+		}
 
-			router = router->next_bond_candidate;
-		} while (router != first_candidate);
+		/* use the first candidate if nothing was found. */
+		if (!router)
+			router = first_candidate;
 
-		primary_orig_node->bond.selected = router->next_bond_candidate;
+		/* selected should point to the next element
+		 * after the current router */
+		spin_lock_bh(&primary_orig_node->neigh_list_lock);
+		/* this is a list_move(), which unfortunately
+		 * does not exist as rcu version */
+		list_del_rcu(&primary_orig_node->bond_list);
+		list_add_rcu(&primary_orig_node->bond_list,
+				&router->bonding_list);
+		spin_unlock_bh(&primary_orig_node->neigh_list_lock);
 
 	} else {
 		/* if bonding is disabled, use the best of the
 		 * remaining candidates which are not using
 		 * this interface. */
-		best_router = first_candidate;
+		list_for_each_entry_rcu(tmp_neigh_node,
+			&primary_orig_node->bond_list, bonding_list) {
+			if (!first_candidate)
+				first_candidate = tmp_neigh_node;
 
-		do {
 			/* recv_if == NULL on the first node. */
-			if ((router->if_incoming != recv_if) &&
-				(router->tq_avg > best_router->tq_avg))
-					best_router = router;
-
-			router = router->next_bond_candidate;
-		} while (router != first_candidate);
+			if (tmp_neigh_node->if_incoming != recv_if)
+				/* if we don't have a router yet
+				 * or this one is better, choose it. */
+				if ((!router) ||
+				(tmp_neigh_node->tq_avg > router->tq_avg)) {
+					router = tmp_neigh_node;
+				}
+		}
 
-		router = best_router;
+		/* use the first candidate if nothing was found. */
+		if (!router)
+			router = first_candidate;
 	}
-
+return_router:
+	kref_get(&router->refcount);
+	rcu_read_unlock();
 	return router;
 }
 
@@ -1247,6 +1259,7 @@ int route_unicast_packet(struct sk_buff *skb, struct batman_if *recv_if,
 			       unicast_packet->dest));
 	rcu_read_unlock();
 
+	/* find_router() increases neigh_nodes refcount if found. */
 	router = find_router(bat_priv, orig_node, recv_if);
 
 	if (!router) {
diff --git a/net/batman-adv/routing.h b/net/batman-adv/routing.h
index a09d16f..e2a9872 100644
--- a/net/batman-adv/routing.h
+++ b/net/batman-adv/routing.h
@@ -39,7 +39,9 @@ int recv_bcast_packet(struct sk_buff *skb, struct batman_if *recv_if);
 int recv_vis_packet(struct sk_buff *skb, struct batman_if *recv_if);
 int recv_bat_packet(struct sk_buff *skb, struct batman_if *recv_if);
 struct neigh_node *find_router(struct bat_priv *bat_priv,
-		struct orig_node *orig_node, struct batman_if *recv_if);
-void update_bonding_candidates(struct orig_node *orig_node);
+			       struct orig_node *orig_node,
+			       struct batman_if *recv_if);
+void bonding_candidate_del(struct orig_node *orig_node,
+			   struct neigh_node *neigh_node);
 
 #endif /* _NET_BATMAN_ADV_ROUTING_H_ */
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index ff70afc..1f833f0 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -90,10 +90,8 @@ struct orig_node {
 	struct bat_priv *bat_priv;
 	unsigned long last_frag_packet;
 	spinlock_t ogm_cnt_lock; /* protects ogm counter */
-	struct {
-		uint8_t candidates;
-		struct neigh_node *selected;
-	} bond;
+	atomic_t bond_candidates;
+	struct list_head bond_list;
 };
 
 struct gw_node {
@@ -116,11 +114,12 @@ struct neigh_node {
 	uint8_t tq_index;
 	uint8_t tq_avg;
 	uint8_t last_ttl;
-	struct neigh_node *next_bond_candidate;
+	struct list_head bonding_list;
 	unsigned long last_valid;
 	unsigned long real_bits[NUM_WORDS];
 	struct kref refcount;
 	struct rcu_head rcu;
+	struct rcu_head rcu_bond;
 	struct orig_node *orig_node;
 	struct batman_if *if_incoming;
 };
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index 4687027..00bfeaf 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -299,6 +299,7 @@ int unicast_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv)
 	if (!orig_node)
 		orig_node = transtable_search(bat_priv, ethhdr->h_dest);
 
+	/* find_router() increases neigh_nodes refcount if found. */
 	router = find_router(bat_priv, orig_node, NULL);
 
 	if (!router)
@@ -306,7 +307,6 @@ int unicast_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv)
 
 	/* don't lock while sending the packets ... we therefore
 		* copy the required data before sending */
-
 	batman_if = router->if_incoming;
 	memcpy(dstaddr, router->addr, ETH_ALEN);
 
-- 
1.7.2.3

