From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 07/11] batman-adv: substitute tt_poss_change with a per-tt_entry flag
Date: Tue, 13 Nov 2012 10:15:35 +0100
Message-ID: <1352798139-19458-8-git-send-email-ordex@autistici.org>
References: <1352798139-19458-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:52714 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754546Ab2KMJQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 04:16:35 -0500
In-Reply-To: <1352798139-19458-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tt_poss_change is a node-wide flag which tells whether the node is in a roaming
state (a client recently moved to/away from it) in order to let it apply special
re-routing rules. However this flag does not give a clear idea of the current
state because it is not possible to understand *which client* is actually
involved in the roaming. For this reason a better approach has been chosen:
instead of using a node-wide variable, the roaming state is now given by a
per-tt_entry ROAM flag which, in case of packet coming through the node, tells
the node whether the real destination is in roaming state or not.

With this flag change, batadv_check_unicast_ttvn() has also been rearranged in
order to better fit the new re-routing logic and to be much more readable.

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/originator.c        |   1 -
 net/batman-adv/routing.c           | 179 ++++++++++++++++++++++++++-----------
 net/batman-adv/soft-interface.c    |   1 -
 net/batman-adv/translation-table.c |  46 +++++++---
 net/batman-adv/translation-table.h |   2 +
 net/batman-adv/types.h             |   8 --
 6 files changed, 159 insertions(+), 78 deletions(-)

diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 84930a4..8c32cf1 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -221,7 +221,6 @@ struct batadv_orig_node *batadv_get_orig_node(struct batadv_priv *bat_priv,
 	atomic_set(&orig_node->refcount, 2);
 
 	orig_node->tt_initialised = false;
-	orig_node->tt_poss_change = false;
 	orig_node->bat_priv = bat_priv;
 	memcpy(orig_node->orig, addr, ETH_ALEN);
 	batadv_dat_init_orig_node_addr(orig_node);
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 32aa4d4..78d6572 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -711,12 +711,6 @@ int batadv_recv_roam_adv(struct sk_buff *skb, struct batadv_hard_iface *recv_if)
 			     BATADV_TT_CLIENT_ROAM,
 			     atomic_read(&orig_node->last_ttvn) + 1);
 
-	/* Roaming phase starts: I have new information but the ttvn has not
-	 * been incremented yet. This flag will make me check all the incoming
-	 * packets for the correct destination.
-	 */
-	bat_priv->tt.poss_change = true;
-
 	batadv_orig_node_free_ref(orig_node);
 out:
 	/* returning NET_RX_DROP will make the caller function kfree the skb */
@@ -899,14 +893,67 @@ out:
 	return ret;
 }
 
+/**
+ * batadv_reroute_unicast_packet - update the unicast header for re-routing
+ * @bat_priv: the bat priv with all the soft interface information
+ * @unicast_packet: the unicast header to be updated
+ * @dst_addr: the payload destination
+ *
+ * Search the translation table for dst_addr and update the unicast header with
+ * the new corresponding information (originator address where the destination
+ * client currently is and its known TTVN)
+ *
+ * Returns true if the packet header has been updated, false otherwise
+ */
+static bool
+batadv_reroute_unicast_packet(struct batadv_priv *bat_priv,
+			      struct batadv_unicast_packet *unicast_packet,
+			      uint8_t *dst_addr)
+{
+	struct batadv_orig_node *orig_node = NULL;
+	struct batadv_hard_iface *primary_if = NULL;
+	bool ret = false;
+	uint8_t *orig_addr, orig_ttvn;
+
+	if (batadv_is_my_client(bat_priv, dst_addr)) {
+		primary_if = batadv_primary_if_get_selected(bat_priv);
+		if (!primary_if)
+			goto out;
+		orig_addr = primary_if->net_dev->dev_addr;
+		orig_ttvn = (uint8_t)atomic_read(&bat_priv->tt.vn);
+	} else {
+		orig_node = batadv_transtable_search(bat_priv, NULL, dst_addr);
+		if (!orig_node)
+			goto out;
+
+		if (batadv_compare_eth(orig_node->orig, unicast_packet->dest))
+			goto out;
+
+		orig_addr = orig_node->orig;
+		orig_ttvn = (uint8_t)atomic_read(&orig_node->last_ttvn);
+	}
+
+	/* update the packet header */
+	memcpy(unicast_packet->dest, orig_addr, ETH_ALEN);
+	unicast_packet->ttvn = orig_ttvn;
+
+	ret = true;
+out:
+	if (primary_if)
+		batadv_hardif_free_ref(primary_if);
+	if (orig_node)
+		batadv_orig_node_free_ref(orig_node);
+
+	return ret;
+}
+
 static int batadv_check_unicast_ttvn(struct batadv_priv *bat_priv,
 				     struct sk_buff *skb) {
-	uint8_t curr_ttvn;
+	uint8_t curr_ttvn, old_ttvn;
 	struct batadv_orig_node *orig_node;
 	struct ethhdr *ethhdr;
 	struct batadv_hard_iface *primary_if;
 	struct batadv_unicast_packet *unicast_packet;
-	bool tt_poss_change;
 	int is_old_ttvn;
 
 	/* check if there is enough data before accessing it */
@@ -918,65 +965,89 @@ static int batadv_check_unicast_ttvn(struct batadv_priv *bat_priv,
 		return 0;
 
 	unicast_packet = (struct batadv_unicast_packet *)skb->data;
+	ethhdr = (struct ethhdr *)(skb->data + sizeof(*unicast_packet));
 
-	if (batadv_is_my_mac(unicast_packet->dest)) {
-		tt_poss_change = bat_priv->tt.poss_change;
-		curr_ttvn = (uint8_t)atomic_read(&bat_priv->tt.vn);
-	} else {
+	/* check if the destination client was served by this node and it is now
+	 * roaming. In this case, it means that the node has got a ROAM_ADV
+	 * message and that it knows the new destination in the mesh to re-route
+	 * the packet to
+	 */
+	if (batadv_tt_local_client_is_roaming(bat_priv, ethhdr->h_dest)) {
+		if (batadv_reroute_unicast_packet(bat_priv, unicast_packet,
+						  ethhdr->h_dest))
+			net_ratelimited_function(batadv_dbg, BATADV_DBG_TT,
+						 bat_priv,
+						 "Rerouting unicast packet to %pM (dst=%pM): Local Roaming\n",
+						 unicast_packet->dest,
+						 ethhdr->h_dest);
+		/* at this point the mesh destination should have been
+		 * substituted with the originator address found in the global
+		 * table. If not, let the packet go untouched anyway because
+		 * there is nothing the node can do
+		 */
+		return 1;
+	}
+
+	/* retrieve the TTVN known by this node for the packet destination. This
+	 * value is used later to check if the node which sent (or re-routed
+	 * last time) the packet had an updated information or not
+	 */
+	curr_ttvn = (uint8_t)atomic_read(&bat_priv->tt.vn);
+	if (!batadv_is_my_mac(unicast_packet->dest)) {
 		orig_node = batadv_orig_hash_find(bat_priv,
 						  unicast_packet->dest);
-
+		/* if it is not possible to find the orig_node representing the
+		 * destination, the packet can immediately be dropped as it will
+		 * not be possible to deliver it
+		 */
 		if (!orig_node)
 			return 0;
 
 		curr_ttvn = (uint8_t)atomic_read(&orig_node->last_ttvn);
-		tt_poss_change = orig_node->tt_poss_change;
 		batadv_orig_node_free_ref(orig_node);
 	}
 
-	/* Check whether I have to reroute the packet */
+	/* check if the TTVN contained in the packet is fresher than what the
+	 * node knows
+	 */
 	is_old_ttvn = batadv_seq_before(unicast_packet->ttvn, curr_ttvn);
-	if (is_old_ttvn || tt_poss_change) {
-		/* check if there is enough data before accessing it */
-		if (pskb_may_pull(skb, sizeof(struct batadv_unicast_packet) +
-				  ETH_HLEN) < 0)
-			return 0;
-
-		ethhdr = (struct ethhdr *)(skb->data + sizeof(*unicast_packet));
-
-		/* we don't have an updated route for this client, so we should
-		 * not try to reroute the packet!!
-		 */
-		if (batadv_tt_global_client_is_roaming(bat_priv,
-						       ethhdr->h_dest))
-			return 1;
-
-		orig_node = batadv_transtable_search(bat_priv, NULL,
-						     ethhdr->h_dest);
-
-		if (!orig_node) {
-			if (!batadv_is_my_client(bat_priv, ethhdr->h_dest))
-				return 0;
-			primary_if = batadv_primary_if_get_selected(bat_priv);
-			if (!primary_if)
-				return 0;
-			memcpy(unicast_packet->dest,
-			       primary_if->net_dev->dev_addr, ETH_ALEN);
-			batadv_hardif_free_ref(primary_if);
-		} else {
-			memcpy(unicast_packet->dest, orig_node->orig,
-			       ETH_ALEN);
-			curr_ttvn = (uint8_t)atomic_read(&orig_node->last_ttvn);
-			batadv_orig_node_free_ref(orig_node);
-		}
-
+	if (!is_old_ttvn)
+		return 1;
+
+	old_ttvn = unicast_packet->ttvn;
+	/* the packet was forged based on outdated network information. Its
+	 * destination can possibly be updated and forwarded towards the new
+	 * target host
+	 */
+	if (batadv_reroute_unicast_packet(bat_priv, unicast_packet,
+					  ethhdr->h_dest)) {
 		net_ratelimited_function(batadv_dbg, BATADV_DBG_TT, bat_priv,
-					 "TTVN mismatch (old_ttvn %u new_ttvn %u)! Rerouting unicast packet (for %pM) to %pM\n",
-					 unicast_packet->ttvn, curr_ttvn,
-					 ethhdr->h_dest, unicast_packet->dest);
-
-		unicast_packet->ttvn = curr_ttvn;
+					 "Rerouting unicast packet to %pM (dst=%pM): TTVN mismatch old_ttvn=%u new_ttvn=%u\n",
+					 unicast_packet->dest, ethhdr->h_dest,
+					 old_ttvn, curr_ttvn);
+		return 1;
 	}
+
+	/* the packet has not been re-routed: either the destination is
+	 * currently served by this node or there is no destination at all and
+	 * it is possible to drop the packet
+	 */
+	if (!batadv_is_my_client(bat_priv, ethhdr->h_dest))
+		return 0;
+
+	/* update the header in order to let the packet be delivered to this
+	 * node's soft interface
+	 */
+	primary_if = batadv_primary_if_get_selected(bat_priv);
+	if (!primary_if)
+		return 0;
+
+	memcpy(unicast_packet->dest, primary_if->net_dev->dev_addr, ETH_ALEN);
+
+	batadv_hardif_free_ref(primary_if);
+
+	unicast_packet->ttvn = curr_ttvn;
+
 	return 1;
 }
 
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index c283d87..2d1f895 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -505,7 +505,6 @@ struct net_device *batadv_softif_create(const char *name)
 #endif
 	bat_priv->tt.last_changeset = NULL;
 	bat_priv->tt.last_changeset_len = 0;
-	bat_priv->tt.poss_change = false;
 
 	bat_priv->primary_if = NULL;
 	bat_priv->num_ifaces = 0;
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index f8b9c32..d741851 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -306,8 +306,6 @@ void batadv_tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 		head = &tt_global_entry->orig_list;
 		rcu_read_lock();
 		hlist_for_each_entry_rcu(orig_entry, node, head, list) {
-			orig_entry->orig_node->tt_poss_change = true;
-
 			batadv_send_roam_adv(bat_priv,
 					     tt_global_entry->common.addr,
 					     orig_entry->orig_node);
@@ -512,8 +510,11 @@ uint16_t batadv_tt_local_remove(struct batadv_priv *bat_priv,
 	curr_flags = tt_local_entry->common.flags;
 
 	flags = BATADV_TT_CLIENT_DEL;
-	if (roaming)
+	if (roaming) {
 		flags |= BATADV_TT_CLIENT_ROAM;
+		/* mark the local client as ROAMed */
+		tt_local_entry->common.flags |= BATADV_TT_CLIENT_ROAM;
+	}
 
 	batadv_tt_local_set_pending(bat_priv, tt_local_entry, flags, message);
 
@@ -1945,7 +1946,8 @@ bool batadv_is_my_client(struct batadv_priv *bat_priv, const uint8_t *addr)
 	/* Check if the client has been logically deleted (but is kept for
 	 * consistency purpose)
 	 */
-	if (tt_local_entry->common.flags & BATADV_TT_CLIENT_PENDING)
+	if ((tt_local_entry->common.flags & BATADV_TT_CLIENT_PENDING) ||
+	    (tt_local_entry->common.flags & BATADV_TT_CLIENT_ROAM))
 		goto out;
 	ret = true;
 out:
@@ -1996,10 +1998,6 @@ void batadv_handle_tt_response(struct batadv_priv *bat_priv,
 
 	/* Recalculate the CRC for this orig_node and store it */
 	orig_node->tt_crc = batadv_tt_global_crc(bat_priv, orig_node);
-	/* Roaming phase is over: tables are in sync again. I can
-	 * unset the flag
-	 */
-	orig_node->tt_poss_change = false;
 out:
 	if (orig_node)
 		batadv_orig_node_free_ref(orig_node);
@@ -2290,7 +2288,6 @@ static int batadv_tt_commit_changes(struct batadv_priv *bat_priv,
 	batadv_dbg(BATADV_DBG_TT, bat_priv,
 		   "Local changes committed, updating to ttvn %u\n",
 		   (uint8_t)atomic_read(&bat_priv->tt.vn));
-	bat_priv->tt.poss_change = false;
 
 	/* reset the sending counter */
 	atomic_set(&bat_priv->tt.ogm_append_cnt, BATADV_TT_OGM_APPEND_MAX);
@@ -2402,11 +2399,6 @@ void batadv_tt_update_orig(struct batadv_priv *bat_priv,
 		 */
 		if (orig_node->tt_crc != tt_crc)
 			goto request_table;
-
-		/* Roaming phase is over: tables are in sync again. I can
-		 * unset the flag
-		 */
-		orig_node->tt_poss_change = false;
 	} else {
 		/* if we missed more than one change or our tables are not
 		 * in sync anymore -> request fresh tt data
@@ -2445,6 +2437,32 @@ out:
 	return ret;
 }
 
+/**
+ * batadv_tt_local_client_is_roaming - tells whether the client is roaming
+ * @bat_priv: the bat priv with all the soft interface information
+ * @addr: the MAC address of the local client to query
+ *
+ * Returns true if the local client is known to be roaming (it is not served by
+ * this node anymore) or not. If yes, the client is still present in the table
+ * to keep the latter consistent with the node TTVN
+ */
+bool batadv_tt_local_client_is_roaming(struct batadv_priv *bat_priv,
+				       uint8_t *addr)
+{
+	struct batadv_tt_local_entry *tt_local_entry;
+	bool ret = false;
+
+	tt_local_entry = batadv_tt_local_hash_find(bat_priv, addr);
+	if (!tt_local_entry)
+		goto out;
+
+	ret = tt_local_entry->common.flags & BATADV_TT_CLIENT_ROAM;
+	batadv_tt_local_entry_free_ref(tt_local_entry);
+out:
+	return ret;
+
+}
+
 bool batadv_tt_add_temporary_global_entry(struct batadv_priv *bat_priv,
 					  struct batadv_orig_node *orig_node,
 					  const unsigned char *addr)
diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/translation-table.h
index 9fa4fe4..46d4451 100644
--- a/net/batman-adv/translation-table.h
+++ b/net/batman-adv/translation-table.h
@@ -59,6 +59,8 @@ int batadv_tt_append_diff(struct batadv_priv *bat_priv,
 			  int packet_min_len);
 bool batadv_tt_global_client_is_roaming(struct batadv_priv *bat_priv,
 					uint8_t *addr);
+bool batadv_tt_local_client_is_roaming(struct batadv_priv *bat_priv,
+				       uint8_t *addr);
 bool batadv_tt_add_temporary_global_entry(struct batadv_priv *bat_priv,
 					  struct batadv_orig_node *orig_node,
 					  const unsigned char *addr);
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index fa09961..7b3d0d7 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -101,13 +101,6 @@ struct batadv_orig_node {
 	spinlock_t tt_buff_lock; /* protects tt_buff */
 	atomic_t tt_size;
 	bool tt_initialised;
-	/* The tt_poss_change flag is used to detect an ongoing roaming phase.
-	 * If true, then I sent a Roaming_adv to this orig_node and I have to
-	 * inspect every packet directed to it to check whether it is still
-	 * the true destination or not. This flag will be reset to false as
-	 * soon as I receive a new TTVN from this orig_node
-	 */
-	bool tt_poss_change;
 	uint32_t last_real_seqno;
 	uint8_t last_ttl;
 	DECLARE_BITMAP(bcast_bits, BATADV_TQ_LOCAL_WINDOW_SIZE);
@@ -212,7 +205,6 @@ struct batadv_priv_tt {
 	atomic_t vn;
 	atomic_t ogm_append_cnt;
 	atomic_t local_changes;
-	bool poss_change;
 	struct list_head changes_list;
 	struct batadv_hashtable *local_hash;
 	struct batadv_hashtable *global_hash;
-- 
1.8.0
