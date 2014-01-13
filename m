From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 02/14] batman-adv: split tq information in neigh_node struct
Date: Mon, 13 Jan 2014 23:31:26 +0100
Message-ID: <1389652298-472-3-git-send-email-antonio@meshcoding.com>
References: <1389652298-472-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:31835 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752385AbaAMWdT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 17:33:19 -0500
In-Reply-To: <1389652298-472-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <simon@open-mesh.com>

For the network wide multi interface optimization it is required to save
metrics per outgoing interface in one neighbor. Therefore a new type is
introduced to keep interface-specific information. This also requires
some changes in access and list management.

The compare and equiv_or_better API calls are changed to take the
outgoing interface into consideration.

Signed-off-by: Simon Wunderlich <simon@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/bat_iv_ogm.c        | 267 +++++++++++++++++++++++++++++--------
 net/batman-adv/gateway_client.c    |  75 +++++++++--
 net/batman-adv/hard-interface.h    |  17 +++
 net/batman-adv/main.h              |   6 +
 net/batman-adv/network-coding.c    |  24 +++-
 net/batman-adv/originator.c        | 229 ++++++++++++++++++++++++++++---
 net/batman-adv/originator.h        |   7 +
 net/batman-adv/translation-table.c |   3 +-
 net/batman-adv/types.h             |  74 ++++++----
 9 files changed, 588 insertions(+), 114 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 48f5d35..157cc11 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -272,7 +272,14 @@ batadv_iv_ogm_neigh_new(struct batadv_hard_iface *hard_iface,
 	if (!neigh_node)
 		goto out;
 
-	spin_lock_init(&neigh_node->bat_iv.lq_update_lock);
+	if (!atomic_inc_not_zero(&hard_iface->refcount)) {
+		kfree(neigh_node);
+		neigh_node = NULL;
+		goto out;
+	}
+
+	neigh_node->orig_node = orig_neigh;
+	neigh_node->if_incoming = hard_iface;
 
 	batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 		   "Creating new neighbor %pM for orig_node %pM on interface %s\n",
@@ -895,15 +902,30 @@ static void batadv_iv_ogm_schedule(struct batadv_hard_iface *hard_iface)
 		batadv_hardif_free_ref(primary_if);
 }
 
+/**
+ * batadv_iv_ogm_orig_update - use OGM to update corresponding data in an
+ *  originator
+ * @bat_priv: the bat priv with all the soft interface information
+ * @orig_node: the orig node who originally emitted the ogm packet
+ * @ethhdr: Ethernet header of the OGM
+ * @batadv_ogm_packet: the ogm packet
+ * @if_incoming: interface where the packet was received
+ * @if_outgoing: interface for which the retransmission should be considered
+ * @tt_buff: pointer to the tt buffer
+ * @dup_status: the duplicate status of this ogm packet.
+ */
 static void
 batadv_iv_ogm_orig_update(struct batadv_priv *bat_priv,
 			  struct batadv_orig_node *orig_node,
 			  const struct ethhdr *ethhdr,
 			  const struct batadv_ogm_packet *batadv_ogm_packet,
 			  struct batadv_hard_iface *if_incoming,
+			  struct batadv_hard_iface *if_outgoing,
 			  const unsigned char *tt_buff,
 			  enum batadv_dup_status dup_status)
 {
+	struct batadv_neigh_ifinfo *neigh_ifinfo = NULL;
+	struct batadv_neigh_ifinfo *router_ifinfo = NULL;
 	struct batadv_neigh_node *neigh_node = NULL, *tmp_neigh_node = NULL;
 	struct batadv_neigh_node *router = NULL;
 	struct batadv_orig_node *orig_node_tmp;
@@ -931,12 +953,21 @@ batadv_iv_ogm_orig_update(struct batadv_priv *bat_priv,
 		if (dup_status != BATADV_NO_DUP)
 			continue;
 
-		spin_lock_bh(&tmp_neigh_node->bat_iv.lq_update_lock);
-		batadv_ring_buffer_set(tmp_neigh_node->bat_iv.tq_recv,
-				       &tmp_neigh_node->bat_iv.tq_index, 0);
-		tq_avg = batadv_ring_buffer_avg(tmp_neigh_node->bat_iv.tq_recv);
-		tmp_neigh_node->bat_iv.tq_avg = tq_avg;
-		spin_unlock_bh(&tmp_neigh_node->bat_iv.lq_update_lock);
+		/* only update the entry for this outgoing interface */
+		neigh_ifinfo = batadv_neigh_ifinfo_get(tmp_neigh_node,
+						       if_outgoing);
+		if (!neigh_ifinfo)
+			continue;
+
+		spin_lock_bh(&tmp_neigh_node->ifinfo_lock);
+		batadv_ring_buffer_set(neigh_ifinfo->bat_iv.tq_recv,
+				       &neigh_ifinfo->bat_iv.tq_index, 0);
+		tq_avg = batadv_ring_buffer_avg(neigh_ifinfo->bat_iv.tq_recv);
+		neigh_ifinfo->bat_iv.tq_avg = tq_avg;
+		spin_unlock_bh(&tmp_neigh_node->ifinfo_lock);
+
+		batadv_neigh_ifinfo_free_ref(neigh_ifinfo);
+		neigh_ifinfo = NULL;
 	}
 
 	if (!neigh_node) {
@@ -958,20 +989,23 @@ batadv_iv_ogm_orig_update(struct batadv_priv *bat_priv,
 			   "Updating existing last-hop neighbor of originator\n");
 
 	rcu_read_unlock();
+	neigh_ifinfo = batadv_neigh_ifinfo_new(neigh_node, if_outgoing);
+	if (!neigh_ifinfo)
+		goto out;
 
 	neigh_node->last_seen = jiffies;
 
-	spin_lock_bh(&neigh_node->bat_iv.lq_update_lock);
-	batadv_ring_buffer_set(neigh_node->bat_iv.tq_recv,
-			       &neigh_node->bat_iv.tq_index,
+	spin_lock_bh(&neigh_node->ifinfo_lock);
+	batadv_ring_buffer_set(neigh_ifinfo->bat_iv.tq_recv,
+			       &neigh_ifinfo->bat_iv.tq_index,
 			       batadv_ogm_packet->tq);
-	tq_avg = batadv_ring_buffer_avg(neigh_node->bat_iv.tq_recv);
-	neigh_node->bat_iv.tq_avg = tq_avg;
-	spin_unlock_bh(&neigh_node->bat_iv.lq_update_lock);
+	tq_avg = batadv_ring_buffer_avg(neigh_ifinfo->bat_iv.tq_recv);
+	neigh_ifinfo->bat_iv.tq_avg = tq_avg;
+	spin_unlock_bh(&neigh_node->ifinfo_lock);
 
 	if (dup_status == BATADV_NO_DUP) {
 		orig_node->last_ttl = batadv_ogm_packet->ttl;
-		neigh_node->last_ttl = batadv_ogm_packet->ttl;
+		neigh_ifinfo->last_ttl = batadv_ogm_packet->ttl;
 	}
 
 	/* if this neighbor already is our next hop there is nothing
@@ -981,14 +1015,23 @@ batadv_iv_ogm_orig_update(struct batadv_priv *bat_priv,
 	if (router == neigh_node)
 		goto out;
 
-	/* if this neighbor does not offer a better TQ we won't consider it */
-	if (router && (router->bat_iv.tq_avg > neigh_node->bat_iv.tq_avg))
-		goto out;
+	if (router) {
+		router_ifinfo = batadv_neigh_ifinfo_get(router, if_outgoing);
+		if (!router_ifinfo)
+			goto out;
+
+		/* if this neighbor does not offer a better TQ we won't
+		 * consider it
+		 */
+		if (router_ifinfo->bat_iv.tq_avg > neigh_ifinfo->bat_iv.tq_avg)
+			goto out;
+	}
 
 	/* if the TQ is the same and the link not more symmetric we
 	 * won't consider it either
 	 */
-	if (router && (neigh_node->bat_iv.tq_avg == router->bat_iv.tq_avg)) {
+	if (router_ifinfo &&
+	    (neigh_ifinfo->bat_iv.tq_avg == router_ifinfo->bat_iv.tq_avg)) {
 		orig_node_tmp = router->orig_node;
 		spin_lock_bh(&orig_node_tmp->bat_iv.ogm_cnt_lock);
 		if_num = router->if_incoming->if_num;
@@ -1015,15 +1058,31 @@ out:
 		batadv_neigh_node_free_ref(neigh_node);
 	if (router)
 		batadv_neigh_node_free_ref(router);
+	if (neigh_ifinfo)
+		batadv_neigh_ifinfo_free_ref(neigh_ifinfo);
+	if (router_ifinfo)
+		batadv_neigh_ifinfo_free_ref(router_ifinfo);
 }
 
+/**
+ * batadv_iv_ogm_calc_tq - calculate tq for current received ogm packet
+ * @orig_node: the orig node who originally emitted the ogm packet
+ * @orig_neigh_node: the orig node struct of the neighbor who sent the packet
+ * @batadv_ogm_packet: the ogm packet
+ * @if_incoming: interface where the packet was received
+ * @if_outgoing: interface for which the retransmission should be considered
+ *
+ * Returns 1 if the link can be considered bidirectional, 0 otherwise
+ */
 static int batadv_iv_ogm_calc_tq(struct batadv_orig_node *orig_node,
 				 struct batadv_orig_node *orig_neigh_node,
 				 struct batadv_ogm_packet *batadv_ogm_packet,
-				 struct batadv_hard_iface *if_incoming)
+				 struct batadv_hard_iface *if_incoming,
+				 struct batadv_hard_iface *if_outgoing)
 {
 	struct batadv_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
 	struct batadv_neigh_node *neigh_node = NULL, *tmp_neigh_node;
+	struct batadv_neigh_ifinfo *neigh_ifinfo;
 	uint8_t total_count;
 	uint8_t orig_eq_count, neigh_rq_count, neigh_rq_inv, tq_own;
 	unsigned int neigh_rq_inv_cube, neigh_rq_max_cube;
@@ -1068,7 +1127,13 @@ static int batadv_iv_ogm_calc_tq(struct batadv_orig_node *orig_node,
 	spin_lock_bh(&orig_node->bat_iv.ogm_cnt_lock);
 	if_num = if_incoming->if_num;
 	orig_eq_count = orig_neigh_node->bat_iv.bcast_own_sum[if_num];
-	neigh_rq_count = neigh_node->bat_iv.real_packet_count;
+	neigh_ifinfo = batadv_neigh_ifinfo_new(neigh_node, if_outgoing);
+	if (neigh_ifinfo) {
+		neigh_rq_count = neigh_ifinfo->bat_iv.real_packet_count;
+		batadv_neigh_ifinfo_free_ref(neigh_ifinfo);
+	} else {
+		neigh_rq_count = 0;
+	}
 	spin_unlock_bh(&orig_node->bat_iv.ogm_cnt_lock);
 
 	/* pay attention to not get a value bigger than 100 % */
@@ -1132,17 +1197,20 @@ out:
  * @ethhdr: ethernet header of the packet
  * @batadv_ogm_packet: OGM packet to be considered
  * @if_incoming: interface on which the OGM packet was received
+ * @if_outgoing: interface for which the retransmission should be considered
  *
  * Returns duplicate status as enum batadv_dup_status
  */
 static enum batadv_dup_status
 batadv_iv_ogm_update_seqnos(const struct ethhdr *ethhdr,
 			    const struct batadv_ogm_packet *batadv_ogm_packet,
-			    const struct batadv_hard_iface *if_incoming)
+			    const struct batadv_hard_iface *if_incoming,
+			    struct batadv_hard_iface *if_outgoing)
 {
 	struct batadv_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
 	struct batadv_orig_node *orig_node;
-	struct batadv_neigh_node *tmp_neigh_node;
+	struct batadv_neigh_node *neigh_node;
+	struct batadv_neigh_ifinfo *neigh_ifinfo;
 	int is_dup;
 	int32_t seq_diff;
 	int need_update = 0;
@@ -1169,15 +1237,19 @@ batadv_iv_ogm_update_seqnos(const struct ethhdr *ethhdr,
 	}
 
 	rcu_read_lock();
-	hlist_for_each_entry_rcu(tmp_neigh_node,
-				 &orig_node->neigh_list, list) {
-		neigh_addr = tmp_neigh_node->addr;
-		is_dup = batadv_test_bit(tmp_neigh_node->bat_iv.real_bits,
+	hlist_for_each_entry_rcu(neigh_node, &orig_node->neigh_list, list) {
+		neigh_ifinfo = batadv_neigh_ifinfo_new(neigh_node,
+						       if_outgoing);
+		if (!neigh_ifinfo)
+			continue;
+
+		neigh_addr = neigh_node->addr;
+		is_dup = batadv_test_bit(neigh_ifinfo->bat_iv.real_bits,
 					 orig_node->last_real_seqno,
 					 seqno);
 
 		if (batadv_compare_eth(neigh_addr, ethhdr->h_source) &&
-		    tmp_neigh_node->if_incoming == if_incoming) {
+		    neigh_node->if_incoming == if_incoming) {
 			set_mark = 1;
 			if (is_dup)
 				ret = BATADV_NEIGH_DUP;
@@ -1188,13 +1260,14 @@ batadv_iv_ogm_update_seqnos(const struct ethhdr *ethhdr,
 		}
 
 		/* if the window moved, set the update flag. */
-		bitmap = tmp_neigh_node->bat_iv.real_bits;
+		bitmap = neigh_ifinfo->bat_iv.real_bits;
 		need_update |= batadv_bit_get_packet(bat_priv, bitmap,
 						     seq_diff, set_mark);
 
-		packet_count = bitmap_weight(tmp_neigh_node->bat_iv.real_bits,
+		packet_count = bitmap_weight(bitmap,
 					     BATADV_TQ_LOCAL_WINDOW_SIZE);
-		tmp_neigh_node->bat_iv.real_packet_count = packet_count;
+		neigh_ifinfo->bat_iv.real_packet_count = packet_count;
+		batadv_neigh_ifinfo_free_ref(neigh_ifinfo);
 	}
 	rcu_read_unlock();
 
@@ -1221,6 +1294,7 @@ static void batadv_iv_ogm_process(const struct ethhdr *ethhdr,
 	struct batadv_orig_node *orig_neigh_node, *orig_node, *orig_node_tmp;
 	struct batadv_neigh_node *router = NULL, *router_router = NULL;
 	struct batadv_neigh_node *orig_neigh_router = NULL;
+	struct batadv_neigh_ifinfo *router_ifinfo = NULL;
 	int has_directlink_flag;
 	int is_my_addr = 0, is_my_orig = 0, is_my_oldorig = 0;
 	int is_bidirect;
@@ -1353,7 +1427,8 @@ static void batadv_iv_ogm_process(const struct ethhdr *ethhdr,
 		return;
 
 	dup_status = batadv_iv_ogm_update_seqnos(ethhdr, batadv_ogm_packet,
-						 if_incoming);
+						 if_incoming,
+						 BATADV_IF_DEFAULT);
 
 	if (dup_status == BATADV_PROTECTED) {
 		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
@@ -1372,9 +1447,11 @@ static void batadv_iv_ogm_process(const struct ethhdr *ethhdr,
 	if (router) {
 		orig_node_tmp = router->orig_node;
 		router_router = batadv_orig_node_get_router(orig_node_tmp);
+		router_ifinfo = batadv_neigh_ifinfo_get(router,
+							BATADV_IF_DEFAULT);
 	}
 
-	if ((router && router->bat_iv.tq_avg != 0) &&
+	if ((router && router_ifinfo->bat_iv.tq_avg != 0) &&
 	    (batadv_compare_eth(router->addr, ethhdr->h_source)))
 		is_from_best_next_hop = true;
 
@@ -1420,7 +1497,8 @@ static void batadv_iv_ogm_process(const struct ethhdr *ethhdr,
 	}
 
 	is_bidirect = batadv_iv_ogm_calc_tq(orig_node, orig_neigh_node,
-					    batadv_ogm_packet, if_incoming);
+					    batadv_ogm_packet, if_incoming,
+					    BATADV_IF_DEFAULT);
 
 	/* update ranking if it is not a duplicate or has the same
 	 * seqno and similar ttl as the non-duplicate
@@ -1431,7 +1509,8 @@ static void batadv_iv_ogm_process(const struct ethhdr *ethhdr,
 			    (sameseq && similar_ttl)))
 		batadv_iv_ogm_orig_update(bat_priv, orig_node, ethhdr,
 					  batadv_ogm_packet, if_incoming,
-					  tt_buff, dup_status);
+					  BATADV_IF_DEFAULT, tt_buff,
+					  dup_status);
 
 	/* is single hop (direct) neighbor */
 	if (is_single_hop_neigh) {
@@ -1527,6 +1606,34 @@ static int batadv_iv_ogm_receive(struct sk_buff *skb,
 	return NET_RX_SUCCESS;
 }
 
+/* batadv_iv_ogm_orig_print_neigh - print neighbors for the originator table
+ * @orig_node: the orig_node for which the neighbors are printed
+ * @if_outgoing: outgoing interface for these entries
+ * @seq: debugfs table seq_file struct
+ *
+ * Must be called while holding an rcu lock.
+ */
+static void
+batadv_iv_ogm_orig_print_neigh(struct batadv_orig_node *orig_node,
+			       struct batadv_hard_iface *if_outgoing,
+			       struct seq_file *seq)
+{
+	struct batadv_neigh_node *neigh_node;
+	struct batadv_neigh_ifinfo *n_ifinfo;
+
+	hlist_for_each_entry_rcu(neigh_node, &orig_node->neigh_list, list) {
+		n_ifinfo = batadv_neigh_ifinfo_get(neigh_node, if_outgoing);
+		if (!n_ifinfo)
+			continue;
+
+		seq_printf(seq, " %pM (%3i)",
+			   neigh_node->addr,
+			   n_ifinfo->bat_iv.tq_avg);
+
+		batadv_neigh_ifinfo_free_ref(n_ifinfo);
+	}
+}
+
 /**
  * batadv_iv_ogm_orig_print - print the originator table
  * @bat_priv: the bat priv with all the soft interface information
@@ -1535,10 +1642,11 @@ static int batadv_iv_ogm_receive(struct sk_buff *skb,
 static void batadv_iv_ogm_orig_print(struct batadv_priv *bat_priv,
 				     struct seq_file *seq)
 {
-	struct batadv_neigh_node *neigh_node, *neigh_node_tmp;
+	struct batadv_neigh_node *neigh_node;
 	struct batadv_hashtable *hash = bat_priv->orig_hash;
 	int last_seen_msecs, last_seen_secs;
 	struct batadv_orig_node *orig_node;
+	struct batadv_neigh_ifinfo *n_ifinfo;
 	unsigned long last_seen_jiffies;
 	struct hlist_head *head;
 	int batman_count = 0;
@@ -1557,7 +1665,12 @@ static void batadv_iv_ogm_orig_print(struct batadv_priv *bat_priv,
 			if (!neigh_node)
 				continue;
 
-			if (neigh_node->bat_iv.tq_avg == 0)
+			n_ifinfo = batadv_neigh_ifinfo_get(neigh_node,
+							   BATADV_IF_DEFAULT);
+			if (!n_ifinfo)
+				goto next;
+
+			if (n_ifinfo->bat_iv.tq_avg == 0)
 				goto next;
 
 			last_seen_jiffies = jiffies - orig_node->last_seen;
@@ -1567,22 +1680,19 @@ static void batadv_iv_ogm_orig_print(struct batadv_priv *bat_priv,
 
 			seq_printf(seq, "%pM %4i.%03is   (%3i) %pM [%10s]:",
 				   orig_node->orig, last_seen_secs,
-				   last_seen_msecs, neigh_node->bat_iv.tq_avg,
+				   last_seen_msecs, n_ifinfo->bat_iv.tq_avg,
 				   neigh_node->addr,
 				   neigh_node->if_incoming->net_dev->name);
 
-			hlist_for_each_entry_rcu(neigh_node_tmp,
-						 &orig_node->neigh_list, list) {
-				seq_printf(seq, " %pM (%3i)",
-					   neigh_node_tmp->addr,
-					   neigh_node_tmp->bat_iv.tq_avg);
-			}
-
+			batadv_iv_ogm_orig_print_neigh(orig_node,
+						       BATADV_IF_DEFAULT, seq);
 			seq_puts(seq, "\n");
 			batman_count++;
 
 next:
 			batadv_neigh_node_free_ref(neigh_node);
+			if (n_ifinfo)
+				batadv_neigh_ifinfo_free_ref(n_ifinfo);
 		}
 		rcu_read_unlock();
 	}
@@ -1594,37 +1704,84 @@ next:
 /**
  * batadv_iv_ogm_neigh_cmp - compare the metrics of two neighbors
  * @neigh1: the first neighbor object of the comparison
+ * @if_outgoing1: outgoing interface for the first neighbor
  * @neigh2: the second neighbor object of the comparison
+ * @if_outgoing2: outgoing interface for the second neighbor
  *
  * Returns a value less, equal to or greater than 0 if the metric via neigh1 is
  * lower, the same as or higher than the metric via neigh2
  */
 static int batadv_iv_ogm_neigh_cmp(struct batadv_neigh_node *neigh1,
-				   struct batadv_neigh_node *neigh2)
+				   struct batadv_hard_iface *if_outgoing1,
+				   struct batadv_neigh_node *neigh2,
+				   struct batadv_hard_iface *if_outgoing2)
 {
+	struct batadv_neigh_ifinfo *neigh1_ifinfo, *neigh2_ifinfo;
 	uint8_t tq1, tq2;
+	int diff;
 
-	tq1 = neigh1->bat_iv.tq_avg;
-	tq2 = neigh2->bat_iv.tq_avg;
+	neigh1_ifinfo = batadv_neigh_ifinfo_get(neigh1, if_outgoing1);
+	neigh2_ifinfo = batadv_neigh_ifinfo_get(neigh2, if_outgoing2);
 
-	return tq1 - tq2;
+	if (!neigh1_ifinfo || !neigh2_ifinfo) {
+		diff = 0;
+		goto out;
+	}
+
+	tq1 = neigh1_ifinfo->bat_iv.tq_avg;
+	tq2 = neigh2_ifinfo->bat_iv.tq_avg;
+	diff = tq1 - tq2;
+
+out:
+	if (neigh1_ifinfo)
+		batadv_neigh_ifinfo_free_ref(neigh1_ifinfo);
+	if (neigh2_ifinfo)
+		batadv_neigh_ifinfo_free_ref(neigh2_ifinfo);
+
+	return diff;
 }
 
 /**
  * batadv_iv_ogm_neigh_is_eob - check if neigh1 is equally good or better than
  *  neigh2 from the metric prospective
  * @neigh1: the first neighbor object of the comparison
+ * @if_outgoing: outgoing interface for the first neighbor
  * @neigh2: the second neighbor object of the comparison
- *
- * Returns true if the metric via neigh1 is equally good or better than the
- * metric via neigh2, false otherwise.
+ * @if_outgoing2: outgoing interface for the second neighbor
+
+ * Returns true if the metric via neigh1 is equally good or better than
+ * the metric via neigh2, false otherwise.
  */
-static bool batadv_iv_ogm_neigh_is_eob(struct batadv_neigh_node *neigh1,
-				       struct batadv_neigh_node *neigh2)
+static bool
+batadv_iv_ogm_neigh_is_eob(struct batadv_neigh_node *neigh1,
+			   struct batadv_hard_iface *if_outgoing1,
+			   struct batadv_neigh_node *neigh2,
+			   struct batadv_hard_iface *if_outgoing2)
 {
-	int diff = batadv_iv_ogm_neigh_cmp(neigh1, neigh2);
+	struct batadv_neigh_ifinfo *neigh1_ifinfo, *neigh2_ifinfo;
+	uint8_t tq1, tq2;
+	bool ret;
 
-	return diff > -BATADV_TQ_SIMILARITY_THRESHOLD;
+	neigh1_ifinfo = batadv_neigh_ifinfo_get(neigh1, if_outgoing1);
+	neigh2_ifinfo = batadv_neigh_ifinfo_get(neigh2, if_outgoing2);
+
+	/* we can't say that the metric is better */
+	if (!neigh1_ifinfo || !neigh2_ifinfo) {
+		ret = false;
+		goto out;
+	}
+
+	tq1 = neigh1_ifinfo->bat_iv.tq_avg;
+	tq2 = neigh2_ifinfo->bat_iv.tq_avg;
+	ret = (tq1 - tq2) > -BATADV_TQ_SIMILARITY_THRESHOLD;
+
+out:
+	if (neigh1_ifinfo)
+		batadv_neigh_ifinfo_free_ref(neigh1_ifinfo);
+	if (neigh2_ifinfo)
+		batadv_neigh_ifinfo_free_ref(neigh2_ifinfo);
+
+	return ret;
 }
 
 static struct batadv_algo_ops batadv_batman_iv __read_mostly = {
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 4150a64..4e8f5b1 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -129,6 +129,7 @@ static struct batadv_gw_node *
 batadv_gw_get_best_gw_node(struct batadv_priv *bat_priv)
 {
 	struct batadv_neigh_node *router;
+	struct batadv_neigh_ifinfo *router_ifinfo;
 	struct batadv_gw_node *gw_node, *curr_gw = NULL;
 	uint32_t max_gw_factor = 0, tmp_gw_factor = 0;
 	uint32_t gw_divisor;
@@ -149,10 +150,15 @@ batadv_gw_get_best_gw_node(struct batadv_priv *bat_priv)
 		if (!router)
 			continue;
 
+		router_ifinfo = batadv_neigh_ifinfo_get(router,
+							BATADV_IF_DEFAULT);
+		if (!router_ifinfo)
+			goto next;
+
 		if (!atomic_inc_not_zero(&gw_node->refcount))
 			goto next;
 
-		tq_avg = router->bat_iv.tq_avg;
+		tq_avg = router_ifinfo->bat_iv.tq_avg;
 
 		switch (atomic_read(&bat_priv->gw_sel_class)) {
 		case 1: /* fast connection */
@@ -197,6 +203,8 @@ batadv_gw_get_best_gw_node(struct batadv_priv *bat_priv)
 
 next:
 		batadv_neigh_node_free_ref(router);
+		if (router_ifinfo)
+			batadv_neigh_ifinfo_free_ref(router_ifinfo);
 	}
 	rcu_read_unlock();
 
@@ -239,6 +247,7 @@ void batadv_gw_election(struct batadv_priv *bat_priv)
 {
 	struct batadv_gw_node *curr_gw = NULL, *next_gw = NULL;
 	struct batadv_neigh_node *router = NULL;
+	struct batadv_neigh_ifinfo *router_ifinfo = NULL;
 	char gw_addr[18] = { '\0' };
 
 	if (atomic_read(&bat_priv->gw_mode) != BATADV_GW_MODE_CLIENT)
@@ -262,6 +271,13 @@ void batadv_gw_election(struct batadv_priv *bat_priv)
 			batadv_gw_reselect(bat_priv);
 			goto out;
 		}
+
+		router_ifinfo = batadv_neigh_ifinfo_get(router,
+							BATADV_IF_DEFAULT);
+		if (!router_ifinfo) {
+			batadv_gw_reselect(bat_priv);
+			goto out;
+		}
 	}
 
 	if ((curr_gw) && (!next_gw)) {
@@ -276,7 +292,8 @@ void batadv_gw_election(struct batadv_priv *bat_priv)
 			   next_gw->bandwidth_down / 10,
 			   next_gw->bandwidth_down % 10,
 			   next_gw->bandwidth_up / 10,
-			   next_gw->bandwidth_up % 10, router->bat_iv.tq_avg);
+			   next_gw->bandwidth_up % 10,
+			   router_ifinfo->bat_iv.tq_avg);
 		batadv_throw_uevent(bat_priv, BATADV_UEV_GW, BATADV_UEV_ADD,
 				    gw_addr);
 	} else {
@@ -286,7 +303,8 @@ void batadv_gw_election(struct batadv_priv *bat_priv)
 			   next_gw->bandwidth_down / 10,
 			   next_gw->bandwidth_down % 10,
 			   next_gw->bandwidth_up / 10,
-			   next_gw->bandwidth_up % 10, router->bat_iv.tq_avg);
+			   next_gw->bandwidth_up % 10,
+			   router_ifinfo->bat_iv.tq_avg);
 		batadv_throw_uevent(bat_priv, BATADV_UEV_GW, BATADV_UEV_CHANGE,
 				    gw_addr);
 	}
@@ -300,11 +318,15 @@ out:
 		batadv_gw_node_free_ref(next_gw);
 	if (router)
 		batadv_neigh_node_free_ref(router);
+	if (router_ifinfo)
+		batadv_neigh_ifinfo_free_ref(router_ifinfo);
 }
 
 void batadv_gw_check_election(struct batadv_priv *bat_priv,
 			      struct batadv_orig_node *orig_node)
 {
+	struct batadv_neigh_ifinfo *router_orig_tq = NULL;
+	struct batadv_neigh_ifinfo *router_gw_tq = NULL;
 	struct batadv_orig_node *curr_gw_orig;
 	struct batadv_neigh_node *router_gw = NULL, *router_orig = NULL;
 	uint8_t gw_tq_avg, orig_tq_avg;
@@ -317,6 +339,11 @@ void batadv_gw_check_election(struct batadv_priv *bat_priv,
 	if (!router_gw)
 		goto reselect;
 
+	router_gw_tq = batadv_neigh_ifinfo_get(router_gw,
+					       BATADV_IF_DEFAULT);
+	if (!router_gw_tq)
+		goto reselect;
+
 	/* this node already is the gateway */
 	if (curr_gw_orig == orig_node)
 		goto out;
@@ -325,8 +352,13 @@ void batadv_gw_check_election(struct batadv_priv *bat_priv,
 	if (!router_orig)
 		goto out;
 
-	gw_tq_avg = router_gw->bat_iv.tq_avg;
-	orig_tq_avg = router_orig->bat_iv.tq_avg;
+	router_orig_tq = batadv_neigh_ifinfo_get(router_orig,
+						 BATADV_IF_DEFAULT);
+	if (!router_orig_tq)
+		goto out;
+
+	gw_tq_avg = router_gw_tq->bat_iv.tq_avg;
+	orig_tq_avg = router_orig_tq->bat_iv.tq_avg;
 
 	/* the TQ value has to be better */
 	if (orig_tq_avg < gw_tq_avg)
@@ -352,6 +384,10 @@ out:
 		batadv_neigh_node_free_ref(router_gw);
 	if (router_orig)
 		batadv_neigh_node_free_ref(router_orig);
+	if (router_gw_tq)
+		batadv_neigh_ifinfo_free_ref(router_gw_tq);
+	if (router_orig_tq)
+		batadv_neigh_ifinfo_free_ref(router_orig_tq);
 
 	return;
 }
@@ -537,28 +573,36 @@ static int batadv_write_buffer_text(struct batadv_priv *bat_priv,
 {
 	struct batadv_gw_node *curr_gw;
 	struct batadv_neigh_node *router;
+	struct batadv_neigh_ifinfo *router_ifinfo = NULL;
 	int ret = -1;
 
 	router = batadv_orig_node_get_router(gw_node->orig_node);
 	if (!router)
 		goto out;
 
+	router_ifinfo = batadv_neigh_ifinfo_get(router, BATADV_IF_DEFAULT);
+	if (!router_ifinfo)
+		goto out;
+
 	curr_gw = batadv_gw_get_selected_gw_node(bat_priv);
 
 	ret = seq_printf(seq, "%s %pM (%3i) %pM [%10s]: %u.%u/%u.%u MBit\n",
 			 (curr_gw == gw_node ? "=>" : "  "),
 			 gw_node->orig_node->orig,
-			 router->bat_iv.tq_avg, router->addr,
+			 router_ifinfo->bat_iv.tq_avg, router->addr,
 			 router->if_incoming->net_dev->name,
 			 gw_node->bandwidth_down / 10,
 			 gw_node->bandwidth_down % 10,
 			 gw_node->bandwidth_up / 10,
 			 gw_node->bandwidth_up % 10);
 
-	batadv_neigh_node_free_ref(router);
 	if (curr_gw)
 		batadv_gw_node_free_ref(curr_gw);
 out:
+	if (router_ifinfo)
+		batadv_neigh_ifinfo_free_ref(router_ifinfo);
+	if (router)
+		batadv_neigh_node_free_ref(router);
 	return ret;
 }
 
@@ -746,6 +790,7 @@ bool batadv_gw_out_of_range(struct batadv_priv *bat_priv,
 	struct batadv_neigh_node *neigh_curr = NULL, *neigh_old = NULL;
 	struct batadv_orig_node *orig_dst_node = NULL;
 	struct batadv_gw_node *gw_node = NULL, *curr_gw = NULL;
+	struct batadv_neigh_ifinfo *curr_ifinfo, *old_ifinfo;
 	struct ethhdr *ethhdr = (struct ethhdr *)skb->data;
 	bool out_of_range = false;
 	uint8_t curr_tq_avg;
@@ -787,7 +832,14 @@ bool batadv_gw_out_of_range(struct batadv_priv *bat_priv,
 		if (!neigh_curr)
 			goto out;
 
-		curr_tq_avg = neigh_curr->bat_iv.tq_avg;
+		curr_ifinfo = batadv_neigh_ifinfo_get(neigh_curr,
+						      BATADV_IF_DEFAULT);
+		if (!curr_ifinfo)
+			goto out;
+
+		curr_tq_avg = curr_ifinfo->bat_iv.tq_avg;
+		batadv_neigh_ifinfo_free_ref(curr_ifinfo);
+
 		break;
 	case BATADV_GW_MODE_OFF:
 	default:
@@ -798,8 +850,13 @@ bool batadv_gw_out_of_range(struct batadv_priv *bat_priv,
 	if (!neigh_old)
 		goto out;
 
-	if (curr_tq_avg - neigh_old->bat_iv.tq_avg > BATADV_GW_THRESHOLD)
+	old_ifinfo = batadv_neigh_ifinfo_get(neigh_old, BATADV_IF_DEFAULT);
+	if (!old_ifinfo)
+		goto out;
+
+	if ((curr_tq_avg - old_ifinfo->bat_iv.tq_avg) > BATADV_GW_THRESHOLD)
 		out_of_range = true;
+	batadv_neigh_ifinfo_free_ref(old_ifinfo);
 
 out:
 	if (orig_dst_node)
diff --git a/net/batman-adv/hard-interface.h b/net/batman-adv/hard-interface.h
index d8ca8ac..8d4304b 100644
--- a/net/batman-adv/hard-interface.h
+++ b/net/batman-adv/hard-interface.h
@@ -51,6 +51,11 @@ int batadv_hardif_min_mtu(struct net_device *soft_iface);
 void batadv_update_min_mtu(struct net_device *soft_iface);
 void batadv_hardif_free_rcu(struct rcu_head *rcu);
 
+/**
+ * batadv_hardif_free_ref - decrement the hard interface refcounter and
+ *  possibly free it
+ * @hard_iface: the hard interface to free
+ */
 static inline void
 batadv_hardif_free_ref(struct batadv_hard_iface *hard_iface)
 {
@@ -58,6 +63,18 @@ batadv_hardif_free_ref(struct batadv_hard_iface *hard_iface)
 		call_rcu(&hard_iface->rcu, batadv_hardif_free_rcu);
 }
 
+/**
+ * batadv_hardif_free_ref_now - decrement the hard interface refcounter and
+ *  possibly free it (without rcu callback)
+ * @hard_iface: the hard interface to free
+ */
+static inline void
+batadv_hardif_free_ref_now(struct batadv_hard_iface *hard_iface)
+{
+	if (atomic_dec_and_test(&hard_iface->refcount))
+		batadv_hardif_free_rcu(&hard_iface->rcu);
+}
+
 static inline struct batadv_hard_iface *
 batadv_primary_if_get_selected(struct batadv_priv *bat_priv)
 {
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index a468760..49a2394 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -72,6 +72,12 @@
 
 #define BATADV_NO_MARK 0
 
+/* default interface for multi interface operation. The default interface is
+ * used for communication which originated locally (i.e. is not forwarded)
+ * or where special forwarding is not desired/necessary.
+ */
+#define BATADV_IF_DEFAULT	((struct batadv_hard_iface *)NULL)
+
 #define BATADV_NUM_WORDS BITS_TO_LONGS(BATADV_TQ_LOCAL_WINDOW_SIZE)
 
 #define BATADV_LOG_BUF_LEN 8192	  /* has to be a power of 2 */
diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-coding.c
index d6f0be3..aec3fa5 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -1008,6 +1008,8 @@ static bool batadv_nc_code_packets(struct batadv_priv *bat_priv,
 	struct batadv_coded_packet *coded_packet;
 	struct batadv_neigh_node *neigh_tmp, *router_neigh;
 	struct batadv_neigh_node *router_coding = NULL;
+	struct batadv_neigh_ifinfo *router_neigh_ifinfo = NULL;
+	struct batadv_neigh_ifinfo *router_coding_ifinfo = NULL;
 	uint8_t *first_source, *first_dest, *second_source, *second_dest;
 	__be32 packet_id1, packet_id2;
 	size_t count;
@@ -1021,15 +1023,25 @@ static bool batadv_nc_code_packets(struct batadv_priv *bat_priv,
 	if (!router_neigh)
 		goto out;
 
+	router_neigh_ifinfo = batadv_neigh_ifinfo_get(router_neigh,
+						      BATADV_IF_DEFAULT);
+	if (!router_neigh_ifinfo)
+		goto out;
+
 	neigh_tmp = nc_packet->neigh_node;
 	router_coding = batadv_orig_node_get_router(neigh_tmp->orig_node);
 	if (!router_coding)
 		goto out;
 
-	tq_tmp = batadv_nc_random_weight_tq(router_neigh->bat_iv.tq_avg);
-	tq_weighted_neigh = tq_tmp;
-	tq_tmp = batadv_nc_random_weight_tq(router_coding->bat_iv.tq_avg);
-	tq_weighted_coding = tq_tmp;
+	router_coding_ifinfo = batadv_neigh_ifinfo_get(router_coding,
+						       BATADV_IF_DEFAULT);
+	if (!router_coding_ifinfo)
+		goto out;
+
+	tq_tmp = router_neigh_ifinfo->bat_iv.tq_avg;
+	tq_weighted_neigh = batadv_nc_random_weight_tq(tq_tmp);
+	tq_tmp = router_coding_ifinfo->bat_iv.tq_avg;
+	tq_weighted_coding = batadv_nc_random_weight_tq(tq_tmp);
 
 	/* Select one destination for the MAC-header dst-field based on
 	 * weighted TQ-values.
@@ -1153,6 +1165,10 @@ out:
 		batadv_neigh_node_free_ref(router_neigh);
 	if (router_coding)
 		batadv_neigh_node_free_ref(router_coding);
+	if (router_neigh_ifinfo)
+		batadv_neigh_ifinfo_free_ref(router_neigh_ifinfo);
+	if (router_coding_ifinfo)
+		batadv_neigh_ifinfo_free_ref(router_coding_ifinfo);
 	return res;
 }
 
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 03db87f..1a4725f 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -148,10 +148,87 @@ err:
 	return -ENOMEM;
 }
 
+/**
+ * batadv_neigh_ifinfo_free_rcu - free the neigh_ifinfo object
+ * @rcu: rcu pointer of the neigh_ifinfo object
+ */
+static void batadv_neigh_ifinfo_free_rcu(struct rcu_head *rcu)
+{
+	struct batadv_neigh_ifinfo *neigh_ifinfo;
+
+	neigh_ifinfo = container_of(rcu, struct batadv_neigh_ifinfo, rcu);
+
+	if (neigh_ifinfo->if_outgoing != BATADV_IF_DEFAULT)
+		batadv_hardif_free_ref_now(neigh_ifinfo->if_outgoing);
+
+	kfree(neigh_ifinfo);
+}
+
+/**
+ * batadv_neigh_ifinfo_free_now - decrement the refcounter and possibly free
+ *  the neigh_ifinfo (without rcu callback)
+ * @neigh_ifinfo: the neigh_ifinfo object to release
+ */
+static void
+batadv_neigh_ifinfo_free_ref_now(struct batadv_neigh_ifinfo *neigh_ifinfo)
+{
+	if (atomic_dec_and_test(&neigh_ifinfo->refcount))
+		batadv_neigh_ifinfo_free_rcu(&neigh_ifinfo->rcu);
+}
+
+/**
+ * batadv_neigh_ifinfo_free_ref - decrement the refcounter and possibly free
+ *  the neigh_ifinfo
+ * @neigh_ifinfo: the neigh_ifinfo object to release
+ */
+void batadv_neigh_ifinfo_free_ref(struct batadv_neigh_ifinfo *neigh_ifinfo)
+{
+	if (atomic_dec_and_test(&neigh_ifinfo->refcount))
+		call_rcu(&neigh_ifinfo->rcu, batadv_neigh_ifinfo_free_rcu);
+}
+
+/**
+ * batadv_neigh_node_free_rcu - free the neigh_node
+ * @rcu: rcu pointer of the neigh_node
+ */
+static void batadv_neigh_node_free_rcu(struct rcu_head *rcu)
+{
+	struct hlist_node *node_tmp;
+	struct batadv_neigh_node *neigh_node;
+	struct batadv_neigh_ifinfo *neigh_ifinfo;
+
+	neigh_node = container_of(rcu, struct batadv_neigh_node, rcu);
+
+	hlist_for_each_entry_safe(neigh_ifinfo, node_tmp,
+				  &neigh_node->ifinfo_list, list) {
+		batadv_neigh_ifinfo_free_ref_now(neigh_ifinfo);
+	}
+	batadv_hardif_free_ref_now(neigh_node->if_incoming);
+
+	kfree(neigh_node);
+}
+
+/**
+ * batadv_neigh_node_free_ref_now - decrement the neighbors refcounter
+ *  and possibly free it (without rcu callback)
+ * @neigh_node: neigh neighbor to free
+ */
+static void
+batadv_neigh_node_free_ref_now(struct batadv_neigh_node *neigh_node)
+{
+	if (atomic_dec_and_test(&neigh_node->refcount))
+		batadv_neigh_node_free_rcu(&neigh_node->rcu);
+}
+
+/**
+ * batadv_neigh_node_free_ref - decrement the neighbors refcounter
+ *  and possibly free it
+ * @neigh_node: neigh neighbor to free
+ */
 void batadv_neigh_node_free_ref(struct batadv_neigh_node *neigh_node)
 {
 	if (atomic_dec_and_test(&neigh_node->refcount))
-		kfree_rcu(neigh_node, rcu);
+		call_rcu(&neigh_node->rcu, batadv_neigh_node_free_rcu);
 }
 
 /* increases the refcounter of a found router */
@@ -171,6 +248,84 @@ batadv_orig_node_get_router(struct batadv_orig_node *orig_node)
 }
 
 /**
+ * batadv_neigh_ifinfo_get - find the ifinfo from an neigh_node
+ * @neigh_node: the neigh node to be queried
+ * @if_outgoing: the interface for which the ifinfo should be acquired
+ *
+ * The object is returned with refcounter increased by 1.
+ *
+ * Returns the requested neigh_ifinfo or NULL if not found
+ */
+struct batadv_neigh_ifinfo *
+batadv_neigh_ifinfo_get(struct batadv_neigh_node *neigh,
+			struct batadv_hard_iface *if_outgoing)
+{
+	struct batadv_neigh_ifinfo *neigh_ifinfo = NULL,
+				   *tmp_neigh_ifinfo;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(tmp_neigh_ifinfo, &neigh->ifinfo_list,
+				 list) {
+		if (tmp_neigh_ifinfo->if_outgoing != if_outgoing)
+			continue;
+
+		if (!atomic_inc_not_zero(&tmp_neigh_ifinfo->refcount))
+			continue;
+
+		neigh_ifinfo = tmp_neigh_ifinfo;
+		break;
+	}
+	rcu_read_unlock();
+
+	return neigh_ifinfo;
+}
+
+/**
+ * batadv_neigh_ifinfo_new - search and possibly create an neigh_ifinfo object
+ * @neigh_node: the neigh node to be queried
+ * @if_outgoing: the interface for which the ifinfo should be acquired
+ *
+ * Returns NULL in case of failure or the neigh_ifinfo object for the
+ * if_outgoing interface otherwise. The object is created and added to the list
+ * if it does not exist.
+ *
+ * The object is returned with refcounter increased by 1.
+ */
+struct batadv_neigh_ifinfo *
+batadv_neigh_ifinfo_new(struct batadv_neigh_node *neigh,
+			struct batadv_hard_iface *if_outgoing)
+{
+	struct batadv_neigh_ifinfo *neigh_ifinfo;
+
+	spin_lock_bh(&neigh->ifinfo_lock);
+
+	neigh_ifinfo = batadv_neigh_ifinfo_get(neigh, if_outgoing);
+	if (neigh_ifinfo)
+		goto out;
+
+	neigh_ifinfo = kzalloc(sizeof(*neigh_ifinfo), GFP_ATOMIC);
+	if (!neigh_ifinfo)
+		goto out;
+
+	if (if_outgoing && !atomic_inc_not_zero(&if_outgoing->refcount)) {
+		kfree(neigh_ifinfo);
+		neigh_ifinfo = NULL;
+		goto out;
+	}
+
+	INIT_HLIST_NODE(&neigh_ifinfo->list);
+	atomic_set(&neigh_ifinfo->refcount, 2);
+	neigh_ifinfo->if_outgoing = if_outgoing;
+
+	hlist_add_head_rcu(&neigh_ifinfo->list, &neigh->ifinfo_list);
+
+out:
+	spin_unlock_bh(&neigh->ifinfo_lock);
+
+	return neigh_ifinfo;
+}
+
+/**
  * batadv_neigh_node_new - create and init a new neigh_node object
  * @hard_iface: the interface where the neighbour is connected to
  * @neigh_addr: the mac address of the neighbour interface
@@ -191,6 +346,8 @@ batadv_neigh_node_new(struct batadv_hard_iface *hard_iface,
 		goto out;
 
 	INIT_HLIST_NODE(&neigh_node->list);
+	INIT_HLIST_HEAD(&neigh_node->ifinfo_list);
+	spin_lock_init(&neigh_node->ifinfo_lock);
 
 	memcpy(neigh_node->addr, neigh_addr, ETH_ALEN);
 	neigh_node->if_incoming = hard_iface;
@@ -217,7 +374,7 @@ static void batadv_orig_node_free_rcu(struct rcu_head *rcu)
 	hlist_for_each_entry_safe(neigh_node, node_tmp,
 				  &orig_node->neigh_list, list) {
 		hlist_del_rcu(&neigh_node->list);
-		batadv_neigh_node_free_ref(neigh_node);
+		batadv_neigh_node_free_ref_now(neigh_node);
 	}
 
 	spin_unlock_bh(&orig_node->neigh_list_lock);
@@ -362,20 +519,23 @@ free_orig_node:
 	return NULL;
 }
 
+/**
+ * batadv_purge_orig_neighbors - purges neighbors from originator
+ * @bat_priv: the bat priv with all the soft interface information
+ * @orig_node: orig node which is to be checked
+ *
+ * Returns true if any neighbor was purged, false otherwise
+ */
 static bool
 batadv_purge_orig_neighbors(struct batadv_priv *bat_priv,
-			    struct batadv_orig_node *orig_node,
-			    struct batadv_neigh_node **best_neigh)
+			    struct batadv_orig_node *orig_node)
 {
-	struct batadv_algo_ops *bao = bat_priv->bat_algo_ops;
 	struct hlist_node *node_tmp;
 	struct batadv_neigh_node *neigh_node;
 	bool neigh_purged = false;
 	unsigned long last_seen;
 	struct batadv_hard_iface *if_incoming;
 
-	*best_neigh = NULL;
-
 	spin_lock_bh(&orig_node->neigh_list_lock);
 
 	/* for all neighbors towards this originator ... */
@@ -405,13 +565,6 @@ batadv_purge_orig_neighbors(struct batadv_priv *bat_priv,
 
 			hlist_del_rcu(&neigh_node->list);
 			batadv_neigh_node_free_ref(neigh_node);
-		} else {
-			/* store the best_neighbour if this is the first
-			 * iteration or if a better neighbor has been found
-			 */
-			if (!*best_neigh ||
-			    bao->bat_neigh_cmp(neigh_node, *best_neigh) > 0)
-				*best_neigh = neigh_node;
 		}
 	}
 
@@ -419,6 +572,41 @@ batadv_purge_orig_neighbors(struct batadv_priv *bat_priv,
 	return neigh_purged;
 }
 
+/**
+ * batadv_find_best_neighbor - finds the best neighbor after purging
+ * @bat_priv: the bat priv with all the soft interface information
+ * @orig_node: orig node which is to be checked
+ * @if_outgoing: the interface for which the metric should be compared
+ *
+ * Returns the current best neighbor, with refcount increased.
+ */
+static struct batadv_neigh_node *
+batadv_find_best_neighbor(struct batadv_priv *bat_priv,
+			  struct batadv_orig_node *orig_node,
+			  struct batadv_hard_iface *if_outgoing)
+{
+	struct batadv_neigh_node *best = NULL, *neigh;
+	struct batadv_algo_ops *bao = bat_priv->bat_algo_ops;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(neigh, &orig_node->neigh_list, list) {
+		if (best && (bao->bat_neigh_cmp(neigh, if_outgoing,
+						best, if_outgoing) <= 0))
+			continue;
+
+		if (!atomic_inc_not_zero(&neigh->refcount))
+			continue;
+
+		if (best)
+			batadv_neigh_node_free_ref(best);
+
+		best = neigh;
+	}
+	rcu_read_unlock();
+
+	return best;
+}
+
 static bool batadv_purge_orig_node(struct batadv_priv *bat_priv,
 				   struct batadv_orig_node *orig_node)
 {
@@ -431,12 +619,15 @@ static bool batadv_purge_orig_node(struct batadv_priv *bat_priv,
 			   orig_node->orig,
 			   jiffies_to_msecs(orig_node->last_seen));
 		return true;
-	} else {
-		if (batadv_purge_orig_neighbors(bat_priv, orig_node,
-						&best_neigh_node))
-			batadv_update_route(bat_priv, orig_node,
-					    best_neigh_node);
 	}
+	if (!batadv_purge_orig_neighbors(bat_priv, orig_node))
+		return false;
+
+	best_neigh_node = batadv_find_best_neighbor(bat_priv, orig_node,
+						    BATADV_IF_DEFAULT);
+	batadv_update_route(bat_priv, orig_node, best_neigh_node);
+	if (best_neigh_node)
+		batadv_neigh_node_free_ref(best_neigh_node);
 
 	return false;
 }
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
index 99ed3c6..29fa4c4 100644
--- a/net/batman-adv/originator.h
+++ b/net/batman-adv/originator.h
@@ -35,6 +35,13 @@ batadv_neigh_node_new(struct batadv_hard_iface *hard_iface,
 void batadv_neigh_node_free_ref(struct batadv_neigh_node *neigh_node);
 struct batadv_neigh_node *
 batadv_orig_node_get_router(struct batadv_orig_node *orig_node);
+struct batadv_neigh_ifinfo *
+batadv_neigh_ifinfo_new(struct batadv_neigh_node *neigh,
+			struct batadv_hard_iface *if_outgoing);
+struct batadv_neigh_ifinfo *
+batadv_neigh_ifinfo_get(struct batadv_neigh_node *neigh,
+			struct batadv_hard_iface *if_outgoing);
+void batadv_neigh_ifinfo_free_ref(struct batadv_neigh_ifinfo *neigh_ifinfo);
 int batadv_orig_seq_print_text(struct seq_file *seq, void *offset);
 int batadv_orig_hash_add_if(struct batadv_hard_iface *hard_iface,
 			    int max_if_num);
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 63d2570..22c32ae 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -1405,7 +1405,8 @@ batadv_transtable_best_orig(struct batadv_priv *bat_priv,
 			continue;
 
 		if (best_router &&
-		    bao->bat_neigh_cmp(router, best_router) <= 0) {
+		    bao->bat_neigh_cmp(router, BATADV_IF_DEFAULT,
+				       best_router, BATADV_IF_DEFAULT) <= 0) {
 			batadv_neigh_node_free_ref(router);
 			continue;
 		}
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 0f68845..8435d7c 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -289,47 +289,62 @@ struct batadv_gw_node {
 };
 
 /**
- * struct batadv_neigh_bat_iv - B.A.T.M.A.N. IV specific structure for single
- *  hop neighbors
+ * struct batadv_neigh_node - structure for single hops neighbors
+ * @list: list node for batadv_orig_node::neigh_list
+ * @orig_node: pointer to corresponding orig_node
+ * @addr: the MAC address of the neighboring interface
+ * @ifinfo_list: list for routing metrics per outgoing interface
+ * @ifinfo_lock: lock protecting private ifinfo members and list
+ * @if_incoming: pointer to incoming hard interface
+ * @last_seen: when last packet via this neighbor was received
+ * @last_ttl: last received ttl from this neigh node
+ * @rcu: struct used for freeing in an RCU-safe manner
+ * @bat_iv: B.A.T.M.A.N. IV private structure
+ */
+struct batadv_neigh_node {
+	struct hlist_node list;
+	struct batadv_orig_node *orig_node;
+	uint8_t addr[ETH_ALEN];
+	struct hlist_head ifinfo_list;
+	spinlock_t ifinfo_lock;	/* protects ifinfo_list and its members */
+	struct batadv_hard_iface *if_incoming;
+	unsigned long last_seen;
+	atomic_t refcount;
+	struct rcu_head rcu;
+};
+
+/* struct batadv_neigh_node_bat_iv - neighbor information per outgoing
+ *  interface for BATMAN IV
  * @tq_recv: ring buffer of received TQ values from this neigh node
  * @tq_index: ring buffer index
  * @tq_avg: averaged tq of all tq values in the ring buffer (tq_recv)
  * @real_bits: bitfield containing the number of OGMs received from this neigh
  *  node (relative to orig_node->last_real_seqno)
  * @real_packet_count: counted result of real_bits
- * @lq_update_lock: lock protecting tq_recv & tq_index
  */
-struct batadv_neigh_bat_iv {
+struct batadv_neigh_ifinfo_bat_iv {
 	uint8_t tq_recv[BATADV_TQ_GLOBAL_WINDOW_SIZE];
 	uint8_t tq_index;
 	uint8_t tq_avg;
 	DECLARE_BITMAP(real_bits, BATADV_TQ_LOCAL_WINDOW_SIZE);
 	uint8_t real_packet_count;
-	spinlock_t lq_update_lock; /* protects tq_recv & tq_index */
 };
 
-/**
- * struct batadv_neigh_node - structure for single hops neighbors
- * @list: list node for batadv_orig_node::neigh_list
- * @orig_node: pointer to corresponding orig_node
- * @addr: the MAC address of the neighboring interface
- * @if_incoming: pointer to incoming hard interface
- * @last_seen: when last packet via this neighbor was received
+/* struct batadv_neigh_ifinfo - neighbor information per outgoing interface
+ * @list: list node for batadv_neigh_node::ifinfo_list
+ * @if_outgoing: pointer to outgoing hard interface
+ * @bat_iv: B.A.T.M.A.N. IV private structure
  * @last_ttl: last received ttl from this neigh node
  * @refcount: number of contexts the object is used
- * @rcu: struct used for freeing in an RCU-safe manner
- * @bat_iv: B.A.T.M.A.N. IV private structure
+ * @rcu: struct used for freeing in a RCU-safe manner
  */
-struct batadv_neigh_node {
+struct batadv_neigh_ifinfo {
 	struct hlist_node list;
-	struct batadv_orig_node *orig_node;
-	uint8_t addr[ETH_ALEN];
-	struct batadv_hard_iface *if_incoming;
-	unsigned long last_seen;
+	struct batadv_hard_iface *if_outgoing;
+	struct batadv_neigh_ifinfo_bat_iv bat_iv;
 	uint8_t last_ttl;
 	atomic_t refcount;
 	struct rcu_head rcu;
-	struct batadv_neigh_bat_iv bat_iv;
 };
 
 /**
@@ -1013,9 +1028,11 @@ struct batadv_forw_packet {
  * @bat_primary_iface_set: called when primary interface is selected / changed
  * @bat_ogm_schedule: prepare a new outgoing OGM for the send queue
  * @bat_ogm_emit: send scheduled OGM
- * @bat_neigh_cmp: compare the metrics of two neighbors
- * @bat_neigh_is_equiv_or_better: check if neigh1 is equally good or
- *  better than neigh2 from the metric prospective
+ * @bat_neigh_cmp: compare the metrics of two neighbors for their respective
+ *  outgoing interfaces
+ * @bat_neigh_is_equiv_or_better: check if neigh1 is equally good or better
+ *  than neigh2 for their respective outgoing interface from the metric
+ *  prospective
  * @bat_orig_print: print the originator table (optional)
  * @bat_orig_free: free the resources allocated by the routing algorithm for an
  *  orig_node object
@@ -1034,9 +1051,14 @@ struct batadv_algo_ops {
 	void (*bat_ogm_schedule)(struct batadv_hard_iface *hard_iface);
 	void (*bat_ogm_emit)(struct batadv_forw_packet *forw_packet);
 	int (*bat_neigh_cmp)(struct batadv_neigh_node *neigh1,
-			     struct batadv_neigh_node *neigh2);
-	bool (*bat_neigh_is_equiv_or_better)(struct batadv_neigh_node *neigh1,
-					     struct batadv_neigh_node *neigh2);
+			     struct batadv_hard_iface *if_outgoing1,
+			     struct batadv_neigh_node *neigh2,
+			     struct batadv_hard_iface *if_outgoing2);
+	bool (*bat_neigh_is_equiv_or_better)
+		(struct batadv_neigh_node *neigh1,
+		 struct batadv_hard_iface *if_outgoing1,
+		 struct batadv_neigh_node *neigh2,
+		 struct batadv_hard_iface *if_outgoing2);
 	/* orig_node handling API */
 	void (*bat_orig_print)(struct batadv_priv *priv, struct seq_file *seq);
 	void (*bat_orig_free)(struct batadv_orig_node *orig_node);
-- 
1.8.5.2
