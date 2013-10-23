From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 10/16] batman-adv: limit local translation table max size
Date: Wed, 23 Oct 2013 18:04:57 +0200
Message-ID: <1382544303-2694-11-git-send-email-antonio@meshcoding.com>
References: <1382544303-2694-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:19772 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751804Ab3JWQL6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 12:11:58 -0400
In-Reply-To: <1382544303-2694-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

The local translation table size is limited by what can be
transferred from one node to another via a full table request.

The number of entries fitting into a full table request depend
on whether the fragmentation is enabled or not. Therefore this
patch introduces a max table size check and refuses to add
more local clients when that size is reached. Moreover, if the
max full table packet size changes (MTU change or fragmentation
is disabled) the local table is downsized instantaneously.

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Acked-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/hard-interface.c    |  41 ++++++----
 net/batman-adv/soft-interface.c    |  12 ++-
 net/batman-adv/translation-table.c | 150 +++++++++++++++++++++++++++++++++----
 net/batman-adv/translation-table.h |   3 +-
 net/batman-adv/types.h             |   3 +
 5 files changed, 173 insertions(+), 36 deletions(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index c5f871f..c60d3ed 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -266,16 +266,9 @@ static void batadv_check_known_mac_addr(const struct net_device *net_dev)
 
 int batadv_hardif_min_mtu(struct net_device *soft_iface)
 {
-	const struct batadv_priv *bat_priv = netdev_priv(soft_iface);
+	struct batadv_priv *bat_priv = netdev_priv(soft_iface);
 	const struct batadv_hard_iface *hard_iface;
-	/* allow big frames if all devices are capable to do so
-	 * (have MTU > 1500 + batadv_max_header_len())
-	 */
 	int min_mtu = ETH_DATA_LEN;
-	int max_header_len = batadv_max_header_len();
-
-	if (atomic_read(&bat_priv->fragmentation))
-		goto out;
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(hard_iface, &batadv_hardif_list, list) {
@@ -286,22 +279,40 @@ int batadv_hardif_min_mtu(struct net_device *soft_iface)
 		if (hard_iface->soft_iface != soft_iface)
 			continue;
 
-		min_mtu = min_t(int, hard_iface->net_dev->mtu - max_header_len,
-				min_mtu);
+		min_mtu = min_t(int, hard_iface->net_dev->mtu, min_mtu);
 	}
 	rcu_read_unlock();
+
+	atomic_set(&bat_priv->packet_size_max, min_mtu);
+
+	if (atomic_read(&bat_priv->fragmentation) == 0)
+		goto out;
+
+	/* with fragmentation enabled the maximum size of internally generated
+	 * packets such as translation table exchanges or tvlv containers, etc
+	 * has to be calculated
+	 */
+	min_mtu = min_t(int, min_mtu, BATADV_FRAG_MAX_FRAG_SIZE);
+	min_mtu -= sizeof(struct batadv_frag_packet);
+	min_mtu *= BATADV_FRAG_MAX_FRAGMENTS;
+	atomic_set(&bat_priv->packet_size_max, min_mtu);
+
+	/* with fragmentation enabled we can fragment external packets easily */
+	min_mtu = min_t(int, min_mtu, ETH_DATA_LEN);
+
 out:
-	return min_mtu;
+	return min_mtu - batadv_max_header_len();
 }
 
 /* adjusts the MTU if a new interface with a smaller MTU appeared. */
 void batadv_update_min_mtu(struct net_device *soft_iface)
 {
-	int min_mtu;
+	soft_iface->mtu = batadv_hardif_min_mtu(soft_iface);
 
-	min_mtu = batadv_hardif_min_mtu(soft_iface);
-	if (soft_iface->mtu != min_mtu)
-		soft_iface->mtu = min_mtu;
+	/* Check if the local translate table should be cleaned up to match a
+	 * new (and smaller) MTU.
+	 */
+	batadv_tt_local_resize_to_mtu(soft_iface);
 }
 
 static void
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index e70f530..36f0508 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -166,7 +166,7 @@ static int batadv_interface_tx(struct sk_buff *skb,
 	unsigned int header_len = 0;
 	int data_len = skb->len, ret;
 	unsigned long brd_delay = 1;
-	bool do_bcast = false;
+	bool do_bcast = false, client_added;
 	unsigned short vid;
 	uint32_t seqno;
 
@@ -196,9 +196,12 @@ static int batadv_interface_tx(struct sk_buff *skb,
 	ethhdr = (struct ethhdr *)skb->data;
 
 	/* Register the client MAC in the transtable */
-	if (!is_multicast_ether_addr(ethhdr->h_source))
-		batadv_tt_local_add(soft_iface, ethhdr->h_source, vid,
-				    skb->skb_iif);
+	if (!is_multicast_ether_addr(ethhdr->h_source)) {
+		client_added = batadv_tt_local_add(soft_iface, ethhdr->h_source,
+						   vid, skb->skb_iif);
+		if (!client_added)
+			goto dropped;
+	}
 
 	/* don't accept stp packets. STP does not help in meshes.
 	 * better use the bridge loop avoidance ...
@@ -674,6 +677,7 @@ static int batadv_softif_init_late(struct net_device *dev)
 	atomic_set(&bat_priv->log_level, 0);
 #endif
 	atomic_set(&bat_priv->fragmentation, 1);
+	atomic_set(&bat_priv->packet_size_max, ETH_DATA_LEN);
 	atomic_set(&bat_priv->bcast_queue_left, BATADV_BCAST_QUEUE_LEN);
 	atomic_set(&bat_priv->batman_queue_left, BATADV_BATMAN_QUEUE_LEN);
 
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 4c28251..a3c965d 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -401,6 +401,35 @@ static uint16_t batadv_tt_entries(uint16_t tt_len)
 	return tt_len / batadv_tt_len(1);
 }
 
+/**
+ * batadv_tt_local_table_transmit_size - calculates the local translation table
+ *  size when transmitted over the air
+ * @bat_priv: the bat priv with all the soft interface information
+ *
+ * Returns local translation table size in bytes.
+ */
+static int batadv_tt_local_table_transmit_size(struct batadv_priv *bat_priv)
+{
+	uint16_t num_vlan = 0, tt_local_entries = 0;
+	struct batadv_softif_vlan *vlan;
+	int hdr_size;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(vlan, &bat_priv->softif_vlan_list, list) {
+		num_vlan++;
+		tt_local_entries += atomic_read(&vlan->tt.num_entries);
+	}
+	rcu_read_unlock();
+
+	/* header size of tvlv encapsulated tt response payload */
+	hdr_size = sizeof(struct batadv_unicast_tvlv_packet);
+	hdr_size += sizeof(struct batadv_tvlv_hdr);
+	hdr_size += sizeof(struct batadv_tvlv_tt_data);
+	hdr_size += num_vlan * sizeof(struct batadv_tvlv_tt_vlan_data);
+
+	return hdr_size + batadv_tt_len(tt_local_entries);
+}
+
 static int batadv_tt_local_init(struct batadv_priv *bat_priv)
 {
 	if (bat_priv->tt.local_hash)
@@ -439,8 +468,10 @@ static void batadv_tt_global_free(struct batadv_priv *bat_priv,
  * @vid: VLAN identifier
  * @ifindex: index of the interface where the client is connected to (useful to
  *  identify wireless clients)
+ *
+ * Returns true if the client was successfully added, false otherwise.
  */
-void batadv_tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
+bool batadv_tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 			 unsigned short vid, int ifindex)
 {
 	struct batadv_priv *bat_priv = netdev_priv(soft_iface);
@@ -448,8 +479,8 @@ void batadv_tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 	struct batadv_tt_global_entry *tt_global;
 	struct hlist_head *head;
 	struct batadv_tt_orig_list_entry *orig_entry;
-	int hash_added;
-	bool roamed_back = false;
+	int hash_added, table_size, packet_size_max;
+	bool ret = false, roamed_back = false;
 
 	tt_local = batadv_tt_local_hash_find(bat_priv, addr, vid);
 	tt_global = batadv_tt_global_hash_find(bat_priv, addr, vid);
@@ -484,6 +515,17 @@ void batadv_tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 		goto check_roaming;
 	}
 
+	/* Ignore the client if we cannot send it in a full table response. */
+	table_size = batadv_tt_local_table_transmit_size(bat_priv);
+	table_size += batadv_tt_len(1);
+	packet_size_max = atomic_read(&bat_priv->packet_size_max);
+	if (table_size > packet_size_max) {
+		net_ratelimited_function(batadv_info, soft_iface,
+					 "Local translation table size (%i) exceeds maximum packet size (%i); Ignoring new local tt entry: %pM\n",
+					 table_size, packet_size_max, addr);
+		goto out;
+	}
+
 	tt_local = kmalloc(sizeof(*tt_local), GFP_ATOMIC);
 	if (!tt_local)
 		goto out;
@@ -550,11 +592,14 @@ check_roaming:
 		}
 	}
 
+	ret = true;
+
 out:
 	if (tt_local)
 		batadv_tt_local_entry_free_ref(tt_local);
 	if (tt_global)
 		batadv_tt_global_entry_free_ref(tt_global);
+	return ret;
 }
 
 /**
@@ -926,8 +971,16 @@ out:
 	return curr_flags;
 }
 
+/**
+ * batadv_tt_local_purge_list - purge inactive tt local entries
+ * @bat_priv: the bat priv with all the soft interface information
+ * @head: pointer to the list containing the local tt entries
+ * @timeout: parameter deciding whether a given tt local entry is considered
+ *  inactive or not
+ */
 static void batadv_tt_local_purge_list(struct batadv_priv *bat_priv,
-				       struct hlist_head *head)
+				       struct hlist_head *head,
+				       int timeout)
 {
 	struct batadv_tt_local_entry *tt_local_entry;
 	struct batadv_tt_common_entry *tt_common_entry;
@@ -945,8 +998,7 @@ static void batadv_tt_local_purge_list(struct batadv_priv *bat_priv,
 		if (tt_local_entry->common.flags & BATADV_TT_CLIENT_PENDING)
 			continue;
 
-		if (!batadv_has_timed_out(tt_local_entry->last_seen,
-					  BATADV_TT_LOCAL_TIMEOUT))
+		if (!batadv_has_timed_out(tt_local_entry->last_seen, timeout))
 			continue;
 
 		batadv_tt_local_set_pending(bat_priv, tt_local_entry,
@@ -954,7 +1006,14 @@ static void batadv_tt_local_purge_list(struct batadv_priv *bat_priv,
 	}
 }
 
-static void batadv_tt_local_purge(struct batadv_priv *bat_priv)
+/**
+ * batadv_tt_local_purge - purge inactive tt local entries
+ * @bat_priv: the bat priv with all the soft interface information
+ * @timeout: parameter deciding whether a given tt local entry is considered
+ *  inactive or not
+ */
+static void batadv_tt_local_purge(struct batadv_priv *bat_priv,
+				  int timeout)
 {
 	struct batadv_hashtable *hash = bat_priv->tt.local_hash;
 	struct hlist_head *head;
@@ -966,7 +1025,7 @@ static void batadv_tt_local_purge(struct batadv_priv *bat_priv)
 		list_lock = &hash->list_locks[i];
 
 		spin_lock_bh(list_lock);
-		batadv_tt_local_purge_list(bat_priv, head);
+		batadv_tt_local_purge_list(bat_priv, head, timeout);
 		spin_unlock_bh(list_lock);
 	}
 }
@@ -2383,6 +2442,15 @@ static bool batadv_send_other_tt_response(struct batadv_priv *bat_priv,
 					req_dst_orig_node);
 	}
 
+	/* Don't send the response, if larger than fragmented packet. */
+	tt_len = sizeof(struct batadv_unicast_tvlv_packet) + tvlv_len;
+	if (tt_len > atomic_read(&bat_priv->packet_size_max)) {
+		net_ratelimited_function(batadv_info, bat_priv->soft_iface,
+					 "Ignoring TT_REQUEST from %pM; Response size exceeds max packet size.\n",
+					 res_dst_orig_node->orig);
+		goto out;
+	}
+
 	tvlv_tt_data->flags = BATADV_TT_RESPONSE;
 	tvlv_tt_data->ttvn = req_ttvn;
 
@@ -2859,7 +2927,7 @@ static void batadv_tt_purge(struct work_struct *work)
 	priv_tt = container_of(delayed_work, struct batadv_priv_tt, work);
 	bat_priv = container_of(priv_tt, struct batadv_priv, tt);
 
-	batadv_tt_local_purge(bat_priv);
+	batadv_tt_local_purge(bat_priv, BATADV_TT_LOCAL_TIMEOUT);
 	batadv_tt_global_purge(bat_priv);
 	batadv_tt_req_purge(bat_priv);
 	batadv_tt_roam_purge(bat_priv);
@@ -2972,18 +3040,18 @@ static void batadv_tt_local_purge_pending_clients(struct batadv_priv *bat_priv)
 }
 
 /**
- * batadv_tt_local_commit_changes - commit all pending local tt changes which
- *  have been queued in the time since the last commit
+ * batadv_tt_local_commit_changes_nolock - commit all pending local tt changes
+ *  which have been queued in the time since the last commit
  * @bat_priv: the bat priv with all the soft interface information
+ *
+ * Caller must hold tt->commit_lock.
  */
-void batadv_tt_local_commit_changes(struct batadv_priv *bat_priv)
+static void batadv_tt_local_commit_changes_nolock(struct batadv_priv *bat_priv)
 {
-	spin_lock_bh(&bat_priv->tt.commit_lock);
-
 	if (atomic_read(&bat_priv->tt.local_changes) < 1) {
 		if (!batadv_atomic_dec_not_zero(&bat_priv->tt.ogm_append_cnt))
 			batadv_tt_tvlv_container_update(bat_priv);
-		goto out;
+		return;
 	}
 
 	batadv_tt_local_set_flags(bat_priv, BATADV_TT_CLIENT_NEW, false, true);
@@ -3000,8 +3068,17 @@ void batadv_tt_local_commit_changes(struct batadv_priv *bat_priv)
 	/* reset the sending counter */
 	atomic_set(&bat_priv->tt.ogm_append_cnt, BATADV_TT_OGM_APPEND_MAX);
 	batadv_tt_tvlv_container_update(bat_priv);
+}
 
-out:
+/**
+ * batadv_tt_local_commit_changes - commit all pending local tt changes which
+ *  have been queued in the time since the last commit
+ * @bat_priv: the bat priv with all the soft interface information
+ */
+void batadv_tt_local_commit_changes(struct batadv_priv *bat_priv)
+{
+	spin_lock_bh(&bat_priv->tt.commit_lock);
+	batadv_tt_local_commit_changes_nolock(bat_priv);
 	spin_unlock_bh(&bat_priv->tt.commit_lock);
 }
 
@@ -3197,6 +3274,47 @@ out:
 }
 
 /**
+ * batadv_tt_local_resize_to_mtu - resize the local translation table fit the
+ *  maximum packet size that can be transported through the mesh
+ * @soft_iface: netdev struct of the mesh interface
+ *
+ * Remove entries older than 'timeout' and half timeout if more entries need
+ * to be removed.
+ */
+void batadv_tt_local_resize_to_mtu(struct net_device *soft_iface)
+{
+	struct batadv_priv *bat_priv = netdev_priv(soft_iface);
+	int packet_size_max = atomic_read(&bat_priv->packet_size_max);
+	int table_size, timeout = BATADV_TT_LOCAL_TIMEOUT / 2;
+	bool reduced = false;
+
+	spin_lock_bh(&bat_priv->tt.commit_lock);
+
+	while (true) {
+		table_size = batadv_tt_local_table_transmit_size(bat_priv);
+		if (packet_size_max >= table_size)
+			break;
+
+		batadv_tt_local_purge(bat_priv, timeout);
+		batadv_tt_local_purge_pending_clients(bat_priv);
+
+		timeout /= 2;
+		reduced = true;
+		net_ratelimited_function(batadv_info, soft_iface,
+					 "Forced to purge local tt entries to fit new maximum fragment MTU (%i)\n",
+					 packet_size_max);
+	}
+
+	/* commit these changes immediately, to avoid synchronization problem
+	 * with the TTVN
+	 */
+	if (reduced)
+		batadv_tt_local_commit_changes_nolock(bat_priv);
+
+	spin_unlock_bh(&bat_priv->tt.commit_lock);
+}
+
+/**
  * batadv_tt_tvlv_ogm_handler_v1 - process incoming tt tvlv container
  * @bat_priv: the bat priv with all the soft interface information
  * @orig: the orig_node of the ogm
diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/translation-table.h
index dc6db4e..026b1ff 100644
--- a/net/batman-adv/translation-table.h
+++ b/net/batman-adv/translation-table.h
@@ -21,7 +21,7 @@
 #define _NET_BATMAN_ADV_TRANSLATION_TABLE_H_
 
 int batadv_tt_init(struct batadv_priv *bat_priv);
-void batadv_tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
+bool batadv_tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 			 unsigned short vid, int ifindex);
 uint16_t batadv_tt_local_remove(struct batadv_priv *bat_priv,
 				const uint8_t *addr, unsigned short vid,
@@ -45,6 +45,7 @@ bool batadv_tt_global_client_is_roaming(struct batadv_priv *bat_priv,
 					uint8_t *addr, unsigned short vid);
 bool batadv_tt_local_client_is_roaming(struct batadv_priv *bat_priv,
 				       uint8_t *addr, unsigned short vid);
+void batadv_tt_local_resize_to_mtu(struct net_device *soft_iface);
 bool batadv_tt_add_temporary_global_entry(struct batadv_priv *bat_priv,
 					  struct batadv_orig_node *orig_node,
 					  const unsigned char *addr,
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 672a813..04b6b0b 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -612,6 +612,8 @@ struct batadv_softif_vlan {
  * @aggregated_ogms: bool indicating whether OGM aggregation is enabled
  * @bonding: bool indicating whether traffic bonding is enabled
  * @fragmentation: bool indicating whether traffic fragmentation is enabled
+ * @packet_size_max: max packet size that can be transmitted via
+ *  multiple fragmented skbs or a single frame if fragmentation is disabled
  * @frag_seqno: incremental counter to identify chains of egress fragments
  * @bridge_loop_avoidance: bool indicating whether bridge loop avoidance is
  *  enabled
@@ -658,6 +660,7 @@ struct batadv_priv {
 	atomic_t aggregated_ogms;
 	atomic_t bonding;
 	atomic_t fragmentation;
+	atomic_t packet_size_max;
 	atomic_t frag_seqno;
 #ifdef CONFIG_BATMAN_ADV_BLA
 	atomic_t bridge_loop_avoidance;
-- 
1.8.4
