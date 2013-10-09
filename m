From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 07/16] batman-adv: tvlv - convert tt data sent within OGMs
Date: Wed,  9 Oct 2013 21:32:45 +0200
Message-ID: <1381347174-3629-8-git-send-email-antonio@meshcoding.com>
References: <1381347174-3629-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:12378 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755127Ab3JITds (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 15:33:48 -0400
In-Reply-To: <1381347174-3629-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

The translation table meta data (version number, crc checksum, etc)
as well as the translation table diff propgated within OGMs now uses
the newly introduced tvlv infrastructure.

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/bat_iv_ogm.c        |  44 +++----
 net/batman-adv/packet.h            |  51 ++++++--
 net/batman-adv/translation-table.c | 240 ++++++++++++++++++++-----------------
 net/batman-adv/translation-table.h |   8 +-
 net/batman-adv/types.h             |   2 +-
 5 files changed, 187 insertions(+), 158 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index f0f02d1..871ba67 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -137,8 +137,6 @@ static int batadv_iv_ogm_iface_enable(struct batadv_hard_iface *hard_iface)
 	batadv_ogm_packet->flags = BATADV_NO_FLAGS;
 	batadv_ogm_packet->reserved = 0;
 	batadv_ogm_packet->tq = BATADV_TQ_MAX_VALUE;
-	batadv_ogm_packet->tt_num_changes = 0;
-	batadv_ogm_packet->ttvn = 0;
 
 	res = 0;
 
@@ -257,14 +255,14 @@ static void batadv_iv_ogm_send_to_if(struct batadv_forw_packet *forw_packet,
 			fwd_str = "Sending own";
 
 		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
-			   "%s %spacket (originator %pM, seqno %u, TQ %d, TTL %d, IDF %s, ttvn %d) on interface %s [%pM]\n",
+			   "%s %spacket (originator %pM, seqno %u, TQ %d, TTL %d, IDF %s) on interface %s [%pM]\n",
 			   fwd_str, (packet_num > 0 ? "aggregated " : ""),
 			   batadv_ogm_packet->orig,
 			   ntohl(batadv_ogm_packet->seqno),
 			   batadv_ogm_packet->tq, batadv_ogm_packet->header.ttl,
 			   (batadv_ogm_packet->flags & BATADV_DIRECTLINK ?
 			    "on" : "off"),
-			   batadv_ogm_packet->ttvn, hard_iface->net_dev->name,
+			   hard_iface->net_dev->name,
 			   hard_iface->net_dev->dev_addr);
 
 		buff_pos += BATADV_OGM_HLEN;
@@ -689,17 +687,22 @@ static void batadv_iv_ogm_schedule(struct batadv_hard_iface *hard_iface)
 	struct batadv_ogm_packet *batadv_ogm_packet;
 	struct batadv_hard_iface *primary_if;
 	int *ogm_buff_len = &hard_iface->bat_iv.ogm_buff_len;
-	int vis_server, tt_num_changes = 0;
+	int vis_server;
 	uint32_t seqno;
 	uint16_t tvlv_len = 0;
 
 	vis_server = atomic_read(&bat_priv->vis_mode);
 	primary_if = batadv_primary_if_get_selected(bat_priv);
 
-	if (hard_iface == primary_if)
+	if (hard_iface == primary_if) {
+		/* tt changes have to be committed before the tvlv data is
+		 * appended as it may alter the tt tvlv container
+		 */
+		batadv_tt_local_commit_changes(bat_priv);
 		tvlv_len = batadv_tvlv_container_ogm_append(bat_priv, ogm_buff,
 							    ogm_buff_len,
 							    BATADV_OGM_HLEN);
+	}
 
 	batadv_ogm_packet = (struct batadv_ogm_packet *)(*ogm_buff);
 	batadv_ogm_packet->tvlv_len = htons(tvlv_len);
@@ -709,11 +712,6 @@ static void batadv_iv_ogm_schedule(struct batadv_hard_iface *hard_iface)
 	batadv_ogm_packet->seqno = htonl(seqno);
 	atomic_inc(&hard_iface->bat_iv.ogm_seqno);
 
-	batadv_ogm_packet->ttvn = atomic_read(&bat_priv->tt.vn);
-	batadv_ogm_packet->tt_crc = htons(bat_priv->tt.local_crc);
-	if (tt_num_changes >= 0)
-		batadv_ogm_packet->tt_num_changes = tt_num_changes;
-
 	if (vis_server == BATADV_VIS_TYPE_SERVER_SYNC)
 		batadv_ogm_packet->flags |= BATADV_VIS_SERVER;
 	else
@@ -814,11 +812,11 @@ batadv_iv_ogm_orig_update(struct batadv_priv *bat_priv,
 	 */
 	router = batadv_orig_node_get_router(orig_node);
 	if (router == neigh_node)
-		goto update_tt;
+		goto out;
 
 	/* if this neighbor does not offer a better TQ we won't consider it */
 	if (router && (router->tq_avg > neigh_node->tq_avg))
-		goto update_tt;
+		goto out;
 
 	/* if the TQ is the same and the link not more symmetric we
 	 * won't consider it either
@@ -837,22 +835,10 @@ batadv_iv_ogm_orig_update(struct batadv_priv *bat_priv,
 		spin_unlock_bh(&orig_node_tmp->ogm_cnt_lock);
 
 		if (sum_orig >= sum_neigh)
-			goto update_tt;
+			goto out;
 	}
 
 	batadv_update_route(bat_priv, orig_node, neigh_node);
-
-update_tt:
-	/* I have to check for transtable changes only if the OGM has been
-	 * sent through a primary interface
-	 */
-	if (((batadv_ogm_packet->orig != ethhdr->h_source) &&
-	     (batadv_ogm_packet->header.ttl > 2)) ||
-	    (batadv_ogm_packet->flags & BATADV_PRIMARIES_FIRST_HOP))
-		batadv_tt_update_orig(bat_priv, orig_node, tt_buff,
-				      batadv_ogm_packet->tt_num_changes,
-				      batadv_ogm_packet->ttvn,
-				      ntohs(batadv_ogm_packet->tt_crc));
 	goto out;
 
 unlock:
@@ -1103,13 +1089,11 @@ static void batadv_iv_ogm_process(const struct ethhdr *ethhdr,
 		is_single_hop_neigh = true;
 
 	batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
-		   "Received BATMAN packet via NB: %pM, IF: %s [%pM] (from OG: %pM, via prev OG: %pM, seqno %u, ttvn %u, crc %#.4x, changes %u, tq %d, TTL %d, V %d, IDF %d)\n",
+		   "Received BATMAN packet via NB: %pM, IF: %s [%pM] (from OG: %pM, via prev OG: %pM, seqno %u, tq %d, TTL %d, V %d, IDF %d)\n",
 		   ethhdr->h_source, if_incoming->net_dev->name,
 		   if_incoming->net_dev->dev_addr, batadv_ogm_packet->orig,
 		   batadv_ogm_packet->prev_sender,
-		   ntohl(batadv_ogm_packet->seqno), batadv_ogm_packet->ttvn,
-		   ntohs(batadv_ogm_packet->tt_crc),
-		   batadv_ogm_packet->tt_num_changes, batadv_ogm_packet->tq,
+		   ntohl(batadv_ogm_packet->seqno), batadv_ogm_packet->tq,
 		   batadv_ogm_packet->header.ttl,
 		   batadv_ogm_packet->header.version, has_directlink_flag);
 
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 55deb4d..cd59fcc 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -86,14 +86,21 @@ enum batadv_unicast_frag_flags {
 /* TT_QUERY subtypes */
 #define BATADV_TT_QUERY_TYPE_MASK 0x3
 
-enum batadv_tt_query_packettype {
-	BATADV_TT_REQUEST  = 0,
-	BATADV_TT_RESPONSE = 1,
-};
+/* tt data subtypes */
+#define BATADV_TT_DATA_TYPE_MASK 0x0F
 
-/* TT_QUERY flags */
-enum batadv_tt_query_flags {
-	BATADV_TT_FULL_TABLE = BIT(2),
+/**
+ * enum batadv_tt_data_flags - flags for tt data tvlv
+ * @BATADV_TT_OGM_DIFF: TT diff propagated through OGM
+ * @BATADV_TT_REQUEST: TT request message
+ * @BATADV_TT_RESPONSE: TT response message
+ * @BATADV_TT_FULL_TABLE: contains full table to replace existing table
+ */
+enum batadv_tt_data_flags {
+	BATADV_TT_OGM_DIFF   = BIT(0),
+	BATADV_TT_REQUEST    = BIT(1),
+	BATADV_TT_RESPONSE   = BIT(2),
+	BATADV_TT_FULL_TABLE = BIT(4),
 };
 
 /* BATADV_TT_CLIENT flags.
@@ -123,11 +130,13 @@ enum batadv_bla_claimframe {
  * @BATADV_TVLV_GW: gateway tvlv
  * @BATADV_TVLV_DAT: distributed arp table tvlv
  * @BATADV_TVLV_NC: network coding tvlv
+ * @BATADV_TVLV_TT: translation table tvlv
  */
 enum batadv_tvlv_type {
 	BATADV_TVLV_GW		= 0x01,
 	BATADV_TVLV_DAT		= 0x02,
 	BATADV_TVLV_NC		= 0x03,
+	BATADV_TVLV_TT		= 0x04,
 };
 
 /* the destination hardware field in the ARP frame is used to
@@ -161,9 +170,6 @@ struct batadv_ogm_packet {
 	uint8_t  prev_sender[ETH_ALEN];
 	uint8_t  reserved;
 	uint8_t  tq;
-	uint8_t  tt_num_changes;
-	uint8_t  ttvn; /* translation table version number */
-	__be16   tt_crc;
 	__be16   tvlv_len;
 } __packed;
 
@@ -375,4 +381,29 @@ struct batadv_tvlv_gateway_data {
 	__be32 bandwidth_up;
 };
 
+/**
+ * struct batadv_tvlv_tt_data - tt data propagated through the tt tvlv container
+ * @flags: translation table flags (see batadv_tt_data_flags)
+ * @ttvn: translation table version number
+ * @crc: crc16 checksum of the local translation table
+ */
+struct batadv_tvlv_tt_data {
+	uint8_t flags;
+	uint8_t ttvn;
+	__be16  crc;
+};
+
+/**
+ * struct batadv_tvlv_tt_change - translation table diff data
+ * @flags: status indicators concerning the non-mesh client (see
+ *  batadv_tt_client_flags)
+ * @reserved: reserved field
+ * @addr: mac address of non-mesh client that triggered this tt change
+ */
+struct batadv_tvlv_tt_change {
+	uint8_t flags;
+	uint8_t reserved;
+	uint8_t addr[ETH_ALEN];
+};
+
 #endif /* _NET_BATMAN_ADV_PACKET_H_ */
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 34510f3..3fac67f 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -180,11 +180,11 @@ static void batadv_tt_local_event(struct batadv_priv *bat_priv,
 	bool del_op_requested, del_op_entry;
 
 	tt_change_node = kmalloc(sizeof(*tt_change_node), GFP_ATOMIC);
-
 	if (!tt_change_node)
 		return;
 
 	tt_change_node->change.flags = flags;
+	tt_change_node->change.reserved = 0;
 	memcpy(tt_change_node->change.addr, common->addr, ETH_ALEN);
 
 	del_op_requested = flags & BATADV_TT_CLIENT_DEL;
@@ -376,71 +376,52 @@ out:
 		batadv_tt_global_entry_free_ref(tt_global);
 }
 
-static void batadv_tt_realloc_packet_buff(unsigned char **packet_buff,
-					  int *packet_buff_len,
-					  int min_packet_len,
-					  int new_packet_len)
+/**
+ * batadv_tt_tvlv_container_update - update the translation table tvlv container
+ *  after local tt changes have been committed
+ * @bat_priv: the bat priv with all the soft interface information
+ */
+static void batadv_tt_tvlv_container_update(struct batadv_priv *bat_priv)
 {
-	unsigned char *new_buff;
+	struct batadv_tt_change_node *entry, *safe;
+	struct batadv_tvlv_tt_data *tt_data;
+	struct batadv_tvlv_tt_change *tt_change;
+	int tt_diff_len = 0, tt_change_len = 0;
+	int tt_diff_entries_num = 0, tt_diff_entries_count = 0;
 
-	new_buff = kmalloc(new_packet_len, GFP_ATOMIC);
-
-	/* keep old buffer if kmalloc should fail */
-	if (new_buff) {
-		memcpy(new_buff, *packet_buff, min_packet_len);
-		kfree(*packet_buff);
-		*packet_buff = new_buff;
-		*packet_buff_len = new_packet_len;
-	}
-}
-
-static void batadv_tt_prepare_packet_buff(struct batadv_priv *bat_priv,
-					  unsigned char **packet_buff,
-					  int *packet_buff_len,
-					  int min_packet_len)
-{
-	int req_len;
-
-	req_len = min_packet_len;
-	req_len += batadv_tt_len(atomic_read(&bat_priv->tt.local_changes));
+	tt_diff_len += batadv_tt_len(atomic_read(&bat_priv->tt.local_changes));
 
 	/* if we have too many changes for one packet don't send any
 	 * and wait for the tt table request which will be fragmented
 	 */
-	if (req_len > bat_priv->soft_iface->mtu)
-		req_len = min_packet_len;
+	if (tt_diff_len > bat_priv->soft_iface->mtu)
+		tt_diff_len = 0;
 
-	batadv_tt_realloc_packet_buff(packet_buff, packet_buff_len,
-				      min_packet_len, req_len);
-}
+	tt_data = kzalloc(sizeof(*tt_data) + tt_diff_len, GFP_ATOMIC);
+	if (!tt_data)
+		return;
 
-static int batadv_tt_changes_fill_buff(struct batadv_priv *bat_priv,
-				       unsigned char **packet_buff,
-				       int *packet_buff_len,
-				       int min_packet_len)
-{
-	struct batadv_tt_change_node *entry, *safe;
-	int count = 0, tot_changes = 0, new_len;
-	unsigned char *tt_buff;
+	tt_data->flags = BATADV_TT_OGM_DIFF;
+	tt_data->ttvn = atomic_read(&bat_priv->tt.vn);
+	tt_data->crc = htons(bat_priv->tt.local_crc);
 
-	batadv_tt_prepare_packet_buff(bat_priv, packet_buff,
-				      packet_buff_len, min_packet_len);
+	if (tt_diff_len == 0)
+		goto container_register;
 
-	new_len = *packet_buff_len - min_packet_len;
-	tt_buff = *packet_buff + min_packet_len;
-
-	if (new_len > 0)
-		tot_changes = new_len / batadv_tt_len(1);
+	tt_diff_entries_num = tt_diff_len / batadv_tt_len(1);
 
 	spin_lock_bh(&bat_priv->tt.changes_list_lock);
 	atomic_set(&bat_priv->tt.local_changes, 0);
 
+	tt_change = (struct batadv_tvlv_tt_change *)(tt_data + 1);
+
 	list_for_each_entry_safe(entry, safe, &bat_priv->tt.changes_list,
 				 list) {
-		if (count < tot_changes) {
-			memcpy(tt_buff + batadv_tt_len(count),
-			       &entry->change, sizeof(struct batadv_tt_change));
-			count++;
+		if (tt_diff_entries_count < tt_diff_entries_num) {
+			memcpy(tt_change + tt_diff_entries_count,
+			       &entry->change,
+			       sizeof(struct batadv_tvlv_tt_change));
+			tt_diff_entries_count++;
 		}
 		list_del(&entry->list);
 		kfree(entry);
@@ -452,20 +433,25 @@ static int batadv_tt_changes_fill_buff(struct batadv_priv *bat_priv,
 	kfree(bat_priv->tt.last_changeset);
 	bat_priv->tt.last_changeset_len = 0;
 	bat_priv->tt.last_changeset = NULL;
+	tt_change_len = batadv_tt_len(tt_diff_entries_count);
 	/* check whether this new OGM has no changes due to size problems */
-	if (new_len > 0) {
+	if (tt_diff_entries_count > 0) {
 		/* if kmalloc() fails we will reply with the full table
 		 * instead of providing the diff
 		 */
-		bat_priv->tt.last_changeset = kmalloc(new_len, GFP_ATOMIC);
+		bat_priv->tt.last_changeset = kzalloc(tt_diff_len, GFP_ATOMIC);
 		if (bat_priv->tt.last_changeset) {
-			memcpy(bat_priv->tt.last_changeset, tt_buff, new_len);
-			bat_priv->tt.last_changeset_len = new_len;
+			memcpy(bat_priv->tt.last_changeset,
+			       tt_change, tt_change_len);
+			bat_priv->tt.last_changeset_len = tt_diff_len;
 		}
 	}
 	spin_unlock_bh(&bat_priv->tt.last_changeset_lock);
 
-	return count;
+container_register:
+	batadv_tvlv_container_register(bat_priv, BATADV_TVLV_TT, 1, tt_data,
+				       sizeof(*tt_data) + tt_change_len);
+	kfree(tt_data);
 }
 
 int batadv_tt_local_seq_print_text(struct seq_file *seq, void *offset)
@@ -1504,7 +1490,7 @@ static void batadv_tt_req_list_free(struct batadv_priv *bat_priv)
 static void batadv_tt_save_orig_buffer(struct batadv_priv *bat_priv,
 				       struct batadv_orig_node *orig_node,
 				       const unsigned char *tt_buff,
-				       uint8_t tt_num_changes)
+				       uint16_t tt_num_changes)
 {
 	uint16_t tt_buff_len = batadv_tt_len(tt_num_changes);
 
@@ -2126,25 +2112,6 @@ out:
 		batadv_orig_node_free_ref(orig_node);
 }
 
-int batadv_tt_init(struct batadv_priv *bat_priv)
-{
-	int ret;
-
-	ret = batadv_tt_local_init(bat_priv);
-	if (ret < 0)
-		return ret;
-
-	ret = batadv_tt_global_init(bat_priv);
-	if (ret < 0)
-		return ret;
-
-	INIT_DELAYED_WORK(&bat_priv->tt.work, batadv_tt_purge);
-	queue_delayed_work(batadv_event_workqueue, &bat_priv->tt.work,
-			   msecs_to_jiffies(BATADV_TT_WORK_PERIOD));
-
-	return 1;
-}
-
 static void batadv_tt_roam_list_free(struct batadv_priv *bat_priv)
 {
 	struct batadv_tt_roam_node *node, *safe;
@@ -2297,6 +2264,9 @@ static void batadv_tt_purge(struct work_struct *work)
 
 void batadv_tt_free(struct batadv_priv *bat_priv)
 {
+	batadv_tvlv_container_unregister(bat_priv, BATADV_TVLV_TT, 1);
+	batadv_tvlv_handler_unregister(bat_priv, BATADV_TVLV_TT, 1);
+
 	cancel_delayed_work_sync(&bat_priv->tt.work);
 
 	batadv_tt_local_table_free(bat_priv);
@@ -2384,14 +2354,20 @@ static void batadv_tt_local_purge_pending_clients(struct batadv_priv *bat_priv)
 	}
 }
 
-static int batadv_tt_commit_changes(struct batadv_priv *bat_priv,
-				    unsigned char **packet_buff,
-				    int *packet_buff_len, int packet_min_len)
+/**
+ * batadv_tt_local_commit_changes - commit all pending local tt changes which
+ *  have been queued in the time since the last commit
+ * @bat_priv: the bat priv with all the soft interface information
+ */
+void batadv_tt_local_commit_changes(struct batadv_priv *bat_priv)
 {
 	uint16_t changed_num = 0;
 
-	if (atomic_read(&bat_priv->tt.local_changes) < 1)
-		return -ENOENT;
+	if (atomic_read(&bat_priv->tt.local_changes) < 1) {
+		if (!batadv_atomic_dec_not_zero(&bat_priv->tt.ogm_append_cnt))
+			batadv_tt_tvlv_container_update(bat_priv);
+		return;
+	}
 
 	changed_num = batadv_tt_set_flags(bat_priv->tt.local_hash,
 					  BATADV_TT_CLIENT_NEW, false);
@@ -2409,32 +2385,7 @@ static int batadv_tt_commit_changes(struct batadv_priv *bat_priv,
 
 	/* reset the sending counter */
 	atomic_set(&bat_priv->tt.ogm_append_cnt, BATADV_TT_OGM_APPEND_MAX);
-
-	return batadv_tt_changes_fill_buff(bat_priv, packet_buff,
-					   packet_buff_len, packet_min_len);
-}
-
-/* when calling this function (hard_iface == primary_if) has to be true */
-int batadv_tt_append_diff(struct batadv_priv *bat_priv,
-			  unsigned char **packet_buff, int *packet_buff_len,
-			  int packet_min_len)
-{
-	int tt_num_changes;
-
-	/* if at least one change happened */
-	tt_num_changes = batadv_tt_commit_changes(bat_priv, packet_buff,
-						  packet_buff_len,
-						  packet_min_len);
-
-	/* if the changes have been sent often enough */
-	if ((tt_num_changes < 0) &&
-	    (!batadv_atomic_dec_not_zero(&bat_priv->tt.ogm_append_cnt))) {
-		batadv_tt_realloc_packet_buff(packet_buff, packet_buff_len,
-					      packet_min_len, packet_min_len);
-		tt_num_changes = 0;
-	}
-
-	return tt_num_changes;
+	batadv_tt_tvlv_container_update(bat_priv);
 }
 
 bool batadv_is_ap_isolated(struct batadv_priv *bat_priv, uint8_t *src,
@@ -2468,10 +2419,21 @@ out:
 	return ret;
 }
 
-void batadv_tt_update_orig(struct batadv_priv *bat_priv,
-			   struct batadv_orig_node *orig_node,
-			   const unsigned char *tt_buff, uint8_t tt_num_changes,
-			   uint8_t ttvn, uint16_t tt_crc)
+/**
+ * batadv_tt_update_orig - update global translation table with new tt
+ *  information received via ogms
+ * @bat_priv: the bat priv with all the soft interface information
+ * @orig: the orig_node of the ogm
+ * @tt_buff: buffer holding the tt information
+ * @tt_num_changes: number of tt changes inside the tt buffer
+ * @ttvn: translation table version number of this changeset
+ * @tt_crc: crc16 checksum of orig node's translation table
+ */
+static void batadv_tt_update_orig(struct batadv_priv *bat_priv,
+				  struct batadv_orig_node *orig_node,
+				  const unsigned char *tt_buff,
+				  uint16_t tt_num_changes, uint8_t ttvn,
+				  uint16_t tt_crc)
 {
 	uint8_t orig_ttvn = (uint8_t)atomic_read(&orig_node->last_ttvn);
 	bool full_table = true;
@@ -2605,3 +2567,61 @@ bool batadv_tt_add_temporary_global_entry(struct batadv_priv *bat_priv,
 out:
 	return ret;
 }
+
+/**
+ * batadv_tt_tvlv_ogm_handler_v1 - process incoming tt tvlv container
+ * @bat_priv: the bat priv with all the soft interface information
+ * @orig: the orig_node of the ogm
+ * @flags: flags indicating the tvlv state (see batadv_tvlv_handler_flags)
+ * @tvlv_value: tvlv buffer containing the gateway data
+ * @tvlv_value_len: tvlv buffer length
+ */
+static void batadv_tt_tvlv_ogm_handler_v1(struct batadv_priv *bat_priv,
+					  struct batadv_orig_node *orig,
+					  uint8_t flags,
+					  void *tvlv_value,
+					  uint16_t tvlv_value_len)
+{
+	struct batadv_tvlv_tt_data *tt_data;
+	uint16_t num_entries;
+
+	if (tvlv_value_len < sizeof(*tt_data))
+		return;
+
+	tt_data = (struct batadv_tvlv_tt_data *)tvlv_value;
+	tvlv_value_len -= sizeof(*tt_data);
+
+	num_entries = tvlv_value_len / batadv_tt_len(1);
+
+	batadv_tt_update_orig(bat_priv, orig,
+			      (unsigned char *)(tt_data + 1),
+			      num_entries, tt_data->ttvn, ntohs(tt_data->crc));
+}
+
+/**
+ * batadv_tt_init - initialise the translation table internals
+ * @bat_priv: the bat priv with all the soft interface information
+ *
+ * Return 0 on success or negative error number in case of failure.
+ */
+int batadv_tt_init(struct batadv_priv *bat_priv)
+{
+	int ret;
+
+	ret = batadv_tt_local_init(bat_priv);
+	if (ret < 0)
+		return ret;
+
+	ret = batadv_tt_global_init(bat_priv);
+	if (ret < 0)
+		return ret;
+
+	batadv_tvlv_handler_register(bat_priv, batadv_tt_tvlv_ogm_handler_v1,
+				     NULL, BATADV_TVLV_TT, 1, BATADV_NO_FLAGS);
+
+	INIT_DELAYED_WORK(&bat_priv->tt.work, batadv_tt_purge);
+	queue_delayed_work(batadv_event_workqueue, &bat_priv->tt.work,
+			   msecs_to_jiffies(BATADV_TT_WORK_PERIOD));
+
+	return 1;
+}
diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/translation-table.h
index 659a3bb..a709249 100644
--- a/net/batman-adv/translation-table.h
+++ b/net/batman-adv/translation-table.h
@@ -50,13 +50,7 @@ void batadv_handle_tt_response(struct batadv_priv *bat_priv,
 			       struct batadv_tt_query_packet *tt_response);
 bool batadv_is_ap_isolated(struct batadv_priv *bat_priv, uint8_t *src,
 			   uint8_t *dst);
-void batadv_tt_update_orig(struct batadv_priv *bat_priv,
-			   struct batadv_orig_node *orig_node,
-			   const unsigned char *tt_buff, uint8_t tt_num_changes,
-			   uint8_t ttvn, uint16_t tt_crc);
-int batadv_tt_append_diff(struct batadv_priv *bat_priv,
-			  unsigned char **packet_buff, int *packet_buff_len,
-			  int packet_min_len);
+void batadv_tt_local_commit_changes(struct batadv_priv *bat_priv);
 bool batadv_tt_global_client_is_roaming(struct batadv_priv *bat_priv,
 					uint8_t *addr);
 bool batadv_tt_local_client_is_roaming(struct batadv_priv *bat_priv,
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index fa5cb0d..bdabbc2 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -772,7 +772,7 @@ struct batadv_tt_orig_list_entry {
  */
 struct batadv_tt_change_node {
 	struct list_head list;
-	struct batadv_tt_change change;
+	struct batadv_tvlv_tt_change change;
 };
 
 /**
-- 
1.8.3.2
