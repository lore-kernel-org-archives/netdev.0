From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 06/14] batman-adv: add bonding again
Date: Mon, 13 Jan 2014 23:31:30 +0100
Message-ID: <1389652298-472-7-git-send-email-antonio@meshcoding.com>
References: <1389652298-472-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:29999 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752472AbaAMWdk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 17:33:40 -0500
In-Reply-To: <1389652298-472-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <simon@open-mesh.com>

With the new interface alternating, the first hop may send packets
in a round robin fashion to it's neighbors because it has multiple
valid routes built by the multi interface optimization. This patch
enables the feature if bonding is selected. Note that unlike the
bonding implemented before, this version is much simpler and may
even enable multi path routing to a certain degree.

Signed-off-by: Simon Wunderlich <simon@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/originator.c |   4 ++
 net/batman-adv/routing.c    | 117 ++++++++++++++++++++++++++++++++++++++++++--
 net/batman-adv/routing.h    |   2 +-
 net/batman-adv/types.h      |   2 +
 4 files changed, 121 insertions(+), 4 deletions(-)

diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index b8ef416..bd88780 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -701,6 +701,10 @@ batadv_purge_orig_ifinfo(struct batadv_priv *bat_priv,
 
 		hlist_del_rcu(&orig_ifinfo->list);
 		batadv_orig_ifinfo_free_ref(orig_ifinfo);
+		if (orig_node->last_bonding_candidate == orig_ifinfo) {
+			orig_node->last_bonding_candidate = NULL;
+			batadv_orig_ifinfo_free_ref(orig_ifinfo);
+		}
 	}
 
 	spin_unlock_bh(&orig_node->neigh_list_lock);
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 55e9aeb..153065a 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -427,16 +427,127 @@ static int batadv_check_unicast_packet(struct batadv_priv *bat_priv,
 struct batadv_neigh_node *
 batadv_find_router(struct batadv_priv *bat_priv,
 		   struct batadv_orig_node *orig_node,
-		   const struct batadv_hard_iface *recv_if)
+		   struct batadv_hard_iface *recv_if)
 {
-	struct batadv_neigh_node *router;
+	struct batadv_algo_ops *bao = bat_priv->bat_algo_ops;
+	struct batadv_neigh_node *first_candidate_router = NULL;
+	struct batadv_neigh_node *next_candidate_router = NULL;
+	struct batadv_neigh_node *router, *cand_router = NULL;
+	struct batadv_neigh_node *last_cand_router = NULL;
+	struct batadv_orig_ifinfo *cand, *first_candidate = NULL;
+	struct batadv_orig_ifinfo *next_candidate = NULL;
+	struct batadv_orig_ifinfo *last_candidate;
+	bool last_candidate_found = false;
 
 	if (!orig_node)
 		return NULL;
 
 	router = batadv_orig_router_get(orig_node, recv_if);
 
-	/* TODO: fill this later with new bonding mechanism */
+	/* only consider bonding for recv_if == BATADV_IF_DEFAULT (first hop)
+	 * and if activated.
+	 */
+	if (recv_if == BATADV_IF_DEFAULT || !atomic_read(&bat_priv->bonding) ||
+	    !router)
+		return router;
+
+	/* bonding: loop through the list of possible routers found
+	 * for the various outgoing interfaces and find a candidate after
+	 * the last chosen bonding candidate (next_candidate). If no such
+	 * router is found, use the first candidate found (the previously
+	 * chosen bonding candidate might have been the last one in the list).
+	 * If this can't be found either, return the previously choosen
+	 * router - obviously there are no other candidates.
+	 */
+	rcu_read_lock();
+	last_candidate = orig_node->last_bonding_candidate;
+	if (last_candidate)
+		last_cand_router = rcu_dereference(last_candidate->router);
+
+	hlist_for_each_entry_rcu(cand, &orig_node->ifinfo_list, list) {
+		/* acquire some structures and references ... */
+		if (!atomic_inc_not_zero(&cand->refcount))
+			continue;
+
+		cand_router = rcu_dereference(cand->router);
+		if (!cand_router)
+			goto next;
+
+		if (!atomic_inc_not_zero(&cand_router->refcount)) {
+			cand_router = NULL;
+			goto next;
+		}
+
+		/* alternative candidate should be good enough to be
+		 * considered
+		 */
+		if (!bao->bat_neigh_is_equiv_or_better(cand_router,
+						       cand->if_outgoing,
+						       router, recv_if))
+			goto next;
+
+		/* don't use the same router twice */
+		if (last_cand_router == cand_router)
+			goto next;
+
+		/* mark the first possible candidate */
+		if (!first_candidate) {
+			atomic_inc(&cand_router->refcount);
+			atomic_inc(&cand->refcount);
+			first_candidate = cand;
+			first_candidate_router = cand_router;
+		}
+
+		/* check if the loop has already passed the previously selected
+		 * candidate ... this function should select the next candidate
+		 * AFTER the previously used bonding candidate.
+		 */
+		if (!last_candidate || last_candidate_found) {
+			next_candidate = cand;
+			next_candidate_router = cand_router;
+			break;
+		}
+
+		if (last_candidate == cand)
+			last_candidate_found = true;
+next:
+		/* free references */
+		if (cand_router) {
+			batadv_neigh_node_free_ref(cand_router);
+			cand_router = NULL;
+		}
+		batadv_orig_ifinfo_free_ref(cand);
+	}
+	rcu_read_unlock();
+
+	/* last_bonding_candidate is reset below, remove the old reference. */
+	if (orig_node->last_bonding_candidate)
+		batadv_orig_ifinfo_free_ref(orig_node->last_bonding_candidate);
+
+	/* After finding candidates, handle the three cases:
+	 * 1) there is a next candidate, use that
+	 * 2) there is no next candidate, use the first of the list
+	 * 3) there is no candidate at all, return the default router
+	 */
+	if (next_candidate) {
+		batadv_neigh_node_free_ref(router);
+
+		/* remove references to first candidate, we don't need it. */
+		if (first_candidate) {
+			batadv_neigh_node_free_ref(first_candidate_router);
+			batadv_orig_ifinfo_free_ref(first_candidate);
+		}
+		router = next_candidate_router;
+		orig_node->last_bonding_candidate = next_candidate;
+	} else if (first_candidate) {
+		batadv_neigh_node_free_ref(router);
+
+		/* refcounting has already been done in the loop above. */
+		router = first_candidate_router;
+		orig_node->last_bonding_candidate = first_candidate;
+	} else {
+		orig_node->last_bonding_candidate = NULL;
+	}
 
 	return router;
 }
diff --git a/net/batman-adv/routing.h b/net/batman-adv/routing.h
index 8920d0b..8fa23fc 100644
--- a/net/batman-adv/routing.h
+++ b/net/batman-adv/routing.h
@@ -44,7 +44,7 @@ int batadv_recv_unhandled_unicast_packet(struct sk_buff *skb,
 struct batadv_neigh_node *
 batadv_find_router(struct batadv_priv *bat_priv,
 		   struct batadv_orig_node *orig_node,
-		   const struct batadv_hard_iface *recv_if);
+		   struct batadv_hard_iface *recv_if);
 int batadv_window_protected(struct batadv_priv *bat_priv, int32_t seq_num_diff,
 			    unsigned long *last_reset);
 
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index c317dfc..1409279 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -198,6 +198,7 @@ struct batadv_orig_bat_iv {
  * @orig: originator ethernet address
  * @primary_addr: hosts primary interface address
  * @ifinfo_list: list for routers per outgoing interface
+ * @last_bonding_candidate: pointer to last ifinfo of last used router
  * @batadv_dat_addr_t:  address of the orig node in the distributed hash
  * @last_seen: time when last packet from this node was received
  * @bcast_seqno_reset: time when the broadcast seqno window was reset
@@ -238,6 +239,7 @@ struct batadv_orig_node {
 	uint8_t orig[ETH_ALEN];
 	uint8_t primary_addr[ETH_ALEN];
 	struct hlist_head ifinfo_list;
+	struct batadv_orig_ifinfo *last_bonding_candidate;
 #ifdef CONFIG_BATMAN_ADV_DAT
 	batadv_dat_addr_t dat_addr;
 #endif
-- 
1.8.5.2
