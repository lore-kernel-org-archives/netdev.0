From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 08/16] batman-adv: tvlv - convert tt query packet to use tvlv unicast packets
Date: Wed,  9 Oct 2013 14:40:10 +0200
Message-ID: <1381322418-1349-9-git-send-email-antonio@meshcoding.com>
References: <1381322418-1349-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:25517 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753990Ab3JIMlq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 08:41:46 -0400
In-Reply-To: <1381322418-1349-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

Instead of generating TT specific packets the TVLV unicast API is used
to send translation table data.

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/main.c              |   2 -
 net/batman-adv/packet.h            |  33 ---
 net/batman-adv/routing.c           |  78 ------
 net/batman-adv/translation-table.c | 498 +++++++++++++++++++++----------------
 net/batman-adv/translation-table.h |   5 -
 5 files changed, 284 insertions(+), 332 deletions(-)

diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index cb9a446..39d9b44 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -414,8 +414,6 @@ static void batadv_recv_handler_init(void)
 	batadv_rx_handler[BATADV_BCAST] = batadv_recv_bcast_packet;
 	/* vis packet */
 	batadv_rx_handler[BATADV_VIS] = batadv_recv_vis_packet;
-	/* Translation table query (request or response) */
-	batadv_rx_handler[BATADV_TT_QUERY] = batadv_recv_tt_query;
 	/* Roaming advertisement */
 	batadv_rx_handler[BATADV_ROAM_ADV] = batadv_recv_roam_adv;
 	/* unicast tvlv packet */
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index cd59fcc..a602efc 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -31,7 +31,6 @@ enum batadv_packettype {
 	BATADV_BCAST		= 0x04,
 	BATADV_VIS		= 0x05,
 	BATADV_UNICAST_FRAG	= 0x06,
-	BATADV_TT_QUERY		= 0x07,
 	BATADV_ROAM_ADV		= 0x08,
 	BATADV_UNICAST_4ADDR	= 0x09,
 	BATADV_CODED		= 0x0a,
@@ -83,9 +82,6 @@ enum batadv_unicast_frag_flags {
 	BATADV_UNI_FRAG_LARGETAIL = BIT(1),
 };
 
-/* TT_QUERY subtypes */
-#define BATADV_TT_QUERY_TYPE_MASK 0x3
-
 /* tt data subtypes */
 #define BATADV_TT_DATA_TYPE_MASK 0x0F
 
@@ -271,30 +267,6 @@ struct batadv_vis_packet {
 	uint8_t  sender_orig[ETH_ALEN]; /* who sent or forwarded this packet */
 };
 
-struct batadv_tt_query_packet {
-	struct batadv_header header;
-	/* the flag field is a combination of:
-	 * - TT_REQUEST or TT_RESPONSE
-	 * - TT_FULL_TABLE
-	 */
-	uint8_t  flags;
-	uint8_t  dst[ETH_ALEN];
-	uint8_t  src[ETH_ALEN];
-	/* the ttvn field is:
-	 * if TT_REQUEST: ttvn that triggered the
-	 *		  request
-	 * if TT_RESPONSE: new ttvn for the src
-	 *		   orig_node
-	 */
-	uint8_t  ttvn;
-	/* tt_data field is:
-	 * if TT_REQUEST: crc associated with the
-	 *		  ttvn
-	 * if TT_RESPONSE: table_size
-	 */
-	__be16 tt_data;
-} __packed;
-
 struct batadv_roam_adv_packet {
 	struct batadv_header header;
 	uint8_t  reserved;
@@ -303,11 +275,6 @@ struct batadv_roam_adv_packet {
 	uint8_t  client[ETH_ALEN];
 } __packed;
 
-struct batadv_tt_change {
-	uint8_t flags;
-	uint8_t addr[ETH_ALEN];
-} __packed;
-
 /**
  * struct batadv_coded_packet - network coded packet
  * @header: common batman packet header and ttl of first included packet
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 9640656..d128581 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -557,84 +557,6 @@ static int batadv_check_unicast_packet(struct batadv_priv *bat_priv,
 	return 0;
 }
 
-int batadv_recv_tt_query(struct sk_buff *skb, struct batadv_hard_iface *recv_if)
-{
-	struct batadv_priv *bat_priv = netdev_priv(recv_if->soft_iface);
-	struct batadv_tt_query_packet *tt_query;
-	uint16_t tt_size;
-	int hdr_size = sizeof(*tt_query);
-	char tt_flag;
-	size_t packet_size;
-
-	if (batadv_check_unicast_packet(bat_priv, skb, hdr_size) < 0)
-		return NET_RX_DROP;
-
-	/* I could need to modify it */
-	if (skb_cow(skb, sizeof(struct batadv_tt_query_packet)) < 0)
-		goto out;
-
-	tt_query = (struct batadv_tt_query_packet *)skb->data;
-
-	switch (tt_query->flags & BATADV_TT_QUERY_TYPE_MASK) {
-	case BATADV_TT_REQUEST:
-		batadv_inc_counter(bat_priv, BATADV_CNT_TT_REQUEST_RX);
-
-		/* If we cannot provide an answer the tt_request is
-		 * forwarded
-		 */
-		if (!batadv_send_tt_response(bat_priv, tt_query)) {
-			if (tt_query->flags & BATADV_TT_FULL_TABLE)
-				tt_flag = 'F';
-			else
-				tt_flag = '.';
-
-			batadv_dbg(BATADV_DBG_TT, bat_priv,
-				   "Routing TT_REQUEST to %pM [%c]\n",
-				   tt_query->dst,
-				   tt_flag);
-			return batadv_route_unicast_packet(skb, recv_if);
-		}
-		break;
-	case BATADV_TT_RESPONSE:
-		batadv_inc_counter(bat_priv, BATADV_CNT_TT_RESPONSE_RX);
-
-		if (batadv_is_my_mac(bat_priv, tt_query->dst)) {
-			/* packet needs to be linearized to access the TT
-			 * changes
-			 */
-			if (skb_linearize(skb) < 0)
-				goto out;
-			/* skb_linearize() possibly changed skb->data */
-			tt_query = (struct batadv_tt_query_packet *)skb->data;
-
-			tt_size = batadv_tt_len(ntohs(tt_query->tt_data));
-
-			/* Ensure we have all the claimed data */
-			packet_size = sizeof(struct batadv_tt_query_packet);
-			packet_size += tt_size;
-			if (unlikely(skb_headlen(skb) < packet_size))
-				goto out;
-
-			batadv_handle_tt_response(bat_priv, tt_query);
-		} else {
-			if (tt_query->flags & BATADV_TT_FULL_TABLE)
-				tt_flag =  'F';
-			else
-				tt_flag = '.';
-			batadv_dbg(BATADV_DBG_TT, bat_priv,
-				   "Routing TT_RESPONSE to %pM [%c]\n",
-				   tt_query->dst,
-				   tt_flag);
-			return batadv_route_unicast_packet(skb, recv_if);
-		}
-		break;
-	}
-
-out:
-	/* returning NET_RX_DROP will make the caller function kfree the skb */
-	return NET_RX_DROP;
-}
-
 int batadv_recv_roam_adv(struct sk_buff *skb, struct batadv_hard_iface *recv_if)
 {
 	struct batadv_priv *bat_priv = netdev_priv(recv_if->soft_iface);
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 3fac67f..22fce8a 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -229,9 +229,15 @@ unlock:
 		atomic_inc(&bat_priv->tt.local_changes);
 }
 
-int batadv_tt_len(int changes_num)
+/**
+ * batadv_tt_len - compute length in bytes of given number of tt changes
+ * @changes_num: number of tt changes
+ *
+ * Returns computed length in bytes.
+ */
+static int batadv_tt_len(int changes_num)
 {
-	return changes_num * sizeof(struct batadv_tt_change);
+	return changes_num * sizeof(struct batadv_tvlv_tt_change);
 }
 
 static int batadv_tt_local_init(struct batadv_priv *bat_priv)
@@ -1555,9 +1561,14 @@ unlock:
 	return tt_req_node;
 }
 
-/* data_ptr is useless here, but has to be kept to respect the prototype */
-static int batadv_tt_local_valid_entry(const void *entry_ptr,
-				       const void *data_ptr)
+/**
+ * batadv_tt_local_valid - verify that given tt entry is a valid one
+ * @entry_ptr: to be checked local tt entry
+ * @data_ptr: not used but definition required to satisfy the callback prototype
+ *
+ * Returns 1 if the entry is a valid, 0 otherwise.
+ */
+static int batadv_tt_local_valid(const void *entry_ptr, const void *data_ptr)
 {
 	const struct batadv_tt_common_entry *tt_common_entry = entry_ptr;
 
@@ -1584,41 +1595,45 @@ static int batadv_tt_global_valid(const void *entry_ptr,
 	return batadv_tt_global_entry_has_orig(tt_global_entry, orig_node);
 }
 
-static struct sk_buff *
-batadv_tt_response_fill_table(uint16_t tt_len, uint8_t ttvn,
-			      struct batadv_hashtable *hash,
-			      struct batadv_priv *bat_priv,
-			      int (*valid_cb)(const void *, const void *),
-			      void *cb_data)
+/**
+ * batadv_tt_tvlv_generate - creates tvlv tt data buffer to fill it with the
+ *  tt entries from the specified tt hash
+ * @bat_priv: the bat priv with all the soft interface information
+ * @hash: hash table containing the tt entries
+ * @tt_len: expected tvlv tt data buffer length in number of bytes
+ * @valid_cb: function to filter tt change entries
+ * @cb_data: data passed to the filter function as argument
+ *
+ * Returns pointer to allocated tvlv tt data buffer if operation was
+ * successful or NULL otherwise.
+ */
+static struct batadv_tvlv_tt_data *
+batadv_tt_tvlv_generate(struct batadv_priv *bat_priv,
+			struct batadv_hashtable *hash, uint16_t tt_len,
+			int (*valid_cb)(const void *, const void *),
+			void *cb_data)
 {
 	struct batadv_tt_common_entry *tt_common_entry;
-	struct batadv_tt_query_packet *tt_response;
-	struct batadv_tt_change *tt_change;
+	struct batadv_tvlv_tt_data *tvlv_tt_data = NULL;
+	struct batadv_tvlv_tt_change *tt_change;
 	struct hlist_head *head;
-	struct sk_buff *skb = NULL;
-	uint16_t tt_tot, tt_count;
-	ssize_t tt_query_size = sizeof(struct batadv_tt_query_packet);
+	uint16_t tt_tot, tt_num_entries = 0;
+	ssize_t tvlv_tt_size = sizeof(struct batadv_tvlv_tt_data);
 	uint32_t i;
-	size_t len;
 
-	if (tt_query_size + tt_len > bat_priv->soft_iface->mtu) {
-		tt_len = bat_priv->soft_iface->mtu - tt_query_size;
-		tt_len -= tt_len % sizeof(struct batadv_tt_change);
+	if (tvlv_tt_size + tt_len > bat_priv->soft_iface->mtu) {
+		tt_len = bat_priv->soft_iface->mtu - tvlv_tt_size;
+		tt_len -= tt_len % sizeof(struct batadv_tvlv_tt_change);
 	}
-	tt_tot = tt_len / sizeof(struct batadv_tt_change);
 
-	len = tt_query_size + tt_len;
-	skb = netdev_alloc_skb_ip_align(NULL, len + ETH_HLEN);
-	if (!skb)
+	tt_tot = tt_len / sizeof(struct batadv_tvlv_tt_change);
+
+	tvlv_tt_data = kzalloc(sizeof(*tvlv_tt_data) + tt_len,
+			       GFP_ATOMIC);
+	if (!tvlv_tt_data)
 		goto out;
 
-	skb->priority = TC_PRIO_CONTROL;
-	skb_reserve(skb, ETH_HLEN);
-	tt_response = (struct batadv_tt_query_packet *)skb_put(skb, len);
-	tt_response->ttvn = ttvn;
-
-	tt_change = (struct batadv_tt_change *)(skb->data + tt_query_size);
-	tt_count = 0;
+	tt_change = (struct batadv_tvlv_tt_change *)(tvlv_tt_data + 1);
 
 	rcu_read_lock();
 	for (i = 0; i < hash->size; i++) {
@@ -1626,7 +1641,7 @@ batadv_tt_response_fill_table(uint16_t tt_len, uint8_t ttvn,
 
 		hlist_for_each_entry_rcu(tt_common_entry,
 					 head, hash_entry) {
-			if (tt_count == tt_tot)
+			if (tt_tot == tt_num_entries)
 				break;
 
 			if ((valid_cb) && (!valid_cb(tt_common_entry, cb_data)))
@@ -1635,20 +1650,16 @@ batadv_tt_response_fill_table(uint16_t tt_len, uint8_t ttvn,
 			memcpy(tt_change->addr, tt_common_entry->addr,
 			       ETH_ALEN);
 			tt_change->flags = tt_common_entry->flags;
+			tt_change->reserved = 0;
 
-			tt_count++;
+			tt_num_entries++;
 			tt_change++;
 		}
 	}
 	rcu_read_unlock();
 
-	/* store in the message the number of entries we have successfully
-	 * copied
-	 */
-	tt_response->tt_data = htons(tt_count);
-
 out:
-	return skb;
+	return tvlv_tt_data;
 }
 
 static int batadv_send_tt_request(struct batadv_priv *bat_priv,
@@ -1656,12 +1667,10 @@ static int batadv_send_tt_request(struct batadv_priv *bat_priv,
 				  uint8_t ttvn, uint16_t tt_crc,
 				  bool full_table)
 {
-	struct sk_buff *skb = NULL;
-	struct batadv_tt_query_packet *tt_request;
+	struct batadv_tvlv_tt_data *tvlv_tt_data = NULL;
 	struct batadv_hard_iface *primary_if;
 	struct batadv_tt_req_node *tt_req_node = NULL;
-	int ret = 1;
-	size_t tt_req_len;
+	bool ret = false;
 
 	primary_if = batadv_primary_if_get_selected(bat_priv);
 	if (!primary_if)
@@ -1674,157 +1683,136 @@ static int batadv_send_tt_request(struct batadv_priv *bat_priv,
 	if (!tt_req_node)
 		goto out;
 
-	skb = netdev_alloc_skb_ip_align(NULL, sizeof(*tt_request) + ETH_HLEN);
-	if (!skb)
+	tvlv_tt_data = kzalloc(sizeof(*tvlv_tt_data), GFP_ATOMIC);
+	if (!tvlv_tt_data)
 		goto out;
 
-	skb->priority = TC_PRIO_CONTROL;
-	skb_reserve(skb, ETH_HLEN);
-
-	tt_req_len = sizeof(*tt_request);
-	tt_request = (struct batadv_tt_query_packet *)skb_put(skb, tt_req_len);
-
-	tt_request->header.packet_type = BATADV_TT_QUERY;
-	tt_request->header.version = BATADV_COMPAT_VERSION;
-	memcpy(tt_request->src, primary_if->net_dev->dev_addr, ETH_ALEN);
-	memcpy(tt_request->dst, dst_orig_node->orig, ETH_ALEN);
-	tt_request->header.ttl = BATADV_TTL;
-	tt_request->ttvn = ttvn;
-	tt_request->tt_data = htons(tt_crc);
-	tt_request->flags = BATADV_TT_REQUEST;
+	tvlv_tt_data->flags = BATADV_TT_REQUEST;
+	tvlv_tt_data->ttvn = ttvn;
+	tvlv_tt_data->crc = htons(tt_crc);
 
 	if (full_table)
-		tt_request->flags |= BATADV_TT_FULL_TABLE;
+		tvlv_tt_data->flags |= BATADV_TT_FULL_TABLE;
 
 	batadv_dbg(BATADV_DBG_TT, bat_priv, "Sending TT_REQUEST to %pM [%c]\n",
-		   dst_orig_node->orig, (full_table ? 'F' : '.'));
+		   dst_orig_node->orig, full_table ? 'F' : '.');
 
 	batadv_inc_counter(bat_priv, BATADV_CNT_TT_REQUEST_TX);
-
-	if (batadv_send_skb_to_orig(skb, dst_orig_node, NULL) != NET_XMIT_DROP)
-		ret = 0;
+	batadv_tvlv_unicast_send(bat_priv, primary_if->net_dev->dev_addr,
+				 dst_orig_node->orig, BATADV_TVLV_TT, 1,
+				 tvlv_tt_data, sizeof(*tvlv_tt_data));
+	ret = true;
 
 out:
 	if (primary_if)
 		batadv_hardif_free_ref(primary_if);
-	if (ret)
-		kfree_skb(skb);
 	if (ret && tt_req_node) {
 		spin_lock_bh(&bat_priv->tt.req_list_lock);
 		list_del(&tt_req_node->list);
 		spin_unlock_bh(&bat_priv->tt.req_list_lock);
 		kfree(tt_req_node);
 	}
+	kfree(tvlv_tt_data);
 	return ret;
 }
 
-static bool
-batadv_send_other_tt_response(struct batadv_priv *bat_priv,
-			      struct batadv_tt_query_packet *tt_request)
+/**
+ * batadv_send_other_tt_response - send reply to tt request concerning another
+ *  node's translation table
+ * @bat_priv: the bat priv with all the soft interface information
+ * @tt_data: tt data containing the tt request information
+ * @req_src: mac address of tt request sender
+ * @req_dst: mac address of tt request recipient
+ *
+ * Returns true if tt request reply was sent, false otherwise.
+ */
+static bool batadv_send_other_tt_response(struct batadv_priv *bat_priv,
+					  struct batadv_tvlv_tt_data *tt_data,
+					  uint8_t *req_src, uint8_t *req_dst)
 {
 	struct batadv_orig_node *req_dst_orig_node;
 	struct batadv_orig_node *res_dst_orig_node = NULL;
-	uint8_t orig_ttvn, req_ttvn, ttvn;
-	int res, ret = false;
-	unsigned char *tt_buff;
-	bool full_table;
-	uint16_t tt_len, tt_tot;
-	struct sk_buff *skb = NULL;
-	struct batadv_tt_query_packet *tt_response;
-	uint8_t *packet_pos;
-	size_t len;
+	struct batadv_tvlv_tt_data *tvlv_tt_data = NULL;
+	uint8_t orig_ttvn, req_ttvn;
+	uint16_t tt_len;
+	bool ret = false, full_table;
 
 	batadv_dbg(BATADV_DBG_TT, bat_priv,
 		   "Received TT_REQUEST from %pM for ttvn: %u (%pM) [%c]\n",
-		   tt_request->src, tt_request->ttvn, tt_request->dst,
-		   (tt_request->flags & BATADV_TT_FULL_TABLE ? 'F' : '.'));
+		   req_src, tt_data->ttvn, req_dst,
+		   (tt_data->flags & BATADV_TT_FULL_TABLE ? 'F' : '.'));
 
 	/* Let's get the orig node of the REAL destination */
-	req_dst_orig_node = batadv_orig_hash_find(bat_priv, tt_request->dst);
+	req_dst_orig_node = batadv_orig_hash_find(bat_priv, req_dst);
 	if (!req_dst_orig_node)
 		goto out;
 
-	res_dst_orig_node = batadv_orig_hash_find(bat_priv, tt_request->src);
+	res_dst_orig_node = batadv_orig_hash_find(bat_priv, req_src);
 	if (!res_dst_orig_node)
 		goto out;
 
 	orig_ttvn = (uint8_t)atomic_read(&req_dst_orig_node->last_ttvn);
-	req_ttvn = tt_request->ttvn;
+	req_ttvn = tt_data->ttvn;
 
-	/* I don't have the requested data */
+	/* this node doesn't have the requested data */
 	if (orig_ttvn != req_ttvn ||
-	    tt_request->tt_data != htons(req_dst_orig_node->tt_crc))
+	    tt_data->crc != htons(req_dst_orig_node->tt_crc))
 		goto out;
 
 	/* If the full table has been explicitly requested */
-	if (tt_request->flags & BATADV_TT_FULL_TABLE ||
+	if (tt_data->flags & BATADV_TT_FULL_TABLE ||
 	    !req_dst_orig_node->tt_buff)
 		full_table = true;
 	else
 		full_table = false;
 
-	/* In this version, fragmentation is not implemented, then
-	 * I'll send only one packet with as much TT entries as I can
+	/* TT fragmentation hasn't been implemented yet, so send as many
+	 * TT entries fit a single packet as possible only
 	 */
 	if (!full_table) {
 		spin_lock_bh(&req_dst_orig_node->tt_buff_lock);
 		tt_len = req_dst_orig_node->tt_buff_len;
-		tt_tot = tt_len / sizeof(struct batadv_tt_change);
 
-		len = sizeof(*tt_response) + tt_len;
-		skb = netdev_alloc_skb_ip_align(NULL, len + ETH_HLEN);
-		if (!skb)
+		tvlv_tt_data = kzalloc(sizeof(*tvlv_tt_data) + tt_len,
+				       GFP_ATOMIC);
+		if (!tvlv_tt_data)
 			goto unlock;
 
-		skb->priority = TC_PRIO_CONTROL;
-		skb_reserve(skb, ETH_HLEN);
-		packet_pos = skb_put(skb, len);
-		tt_response = (struct batadv_tt_query_packet *)packet_pos;
-		tt_response->ttvn = req_ttvn;
-		tt_response->tt_data = htons(tt_tot);
-
-		tt_buff = skb->data + sizeof(*tt_response);
 		/* Copy the last orig_node's OGM buffer */
-		memcpy(tt_buff, req_dst_orig_node->tt_buff,
+		memcpy(tvlv_tt_data + 1, req_dst_orig_node->tt_buff,
 		       req_dst_orig_node->tt_buff_len);
-
 		spin_unlock_bh(&req_dst_orig_node->tt_buff_lock);
 	} else {
 		tt_len = (uint16_t)atomic_read(&req_dst_orig_node->tt_size);
-		tt_len *= sizeof(struct batadv_tt_change);
-		ttvn = (uint8_t)atomic_read(&req_dst_orig_node->last_ttvn);
+		tt_len = batadv_tt_len(tt_len);
 
-		skb = batadv_tt_response_fill_table(tt_len, ttvn,
-						    bat_priv->tt.global_hash,
-						    bat_priv,
-						    batadv_tt_global_valid,
-						    req_dst_orig_node);
-		if (!skb)
+		tvlv_tt_data = batadv_tt_tvlv_generate(bat_priv,
+						       bat_priv->tt.global_hash,
+						       tt_len,
+						       batadv_tt_global_valid,
+						       req_dst_orig_node);
+		if (!tvlv_tt_data)
 			goto out;
-
-		tt_response = (struct batadv_tt_query_packet *)skb->data;
 	}
 
-	tt_response->header.packet_type = BATADV_TT_QUERY;
-	tt_response->header.version = BATADV_COMPAT_VERSION;
-	tt_response->header.ttl = BATADV_TTL;
-	memcpy(tt_response->src, req_dst_orig_node->orig, ETH_ALEN);
-	memcpy(tt_response->dst, tt_request->src, ETH_ALEN);
-	tt_response->flags = BATADV_TT_RESPONSE;
+	tvlv_tt_data->flags = BATADV_TT_RESPONSE;
+	tvlv_tt_data->ttvn = req_ttvn;
 
 	if (full_table)
-		tt_response->flags |= BATADV_TT_FULL_TABLE;
+		tvlv_tt_data->flags |= BATADV_TT_FULL_TABLE;
 
 	batadv_dbg(BATADV_DBG_TT, bat_priv,
-		   "Sending TT_RESPONSE %pM for %pM (ttvn: %u)\n",
-		   res_dst_orig_node->orig, req_dst_orig_node->orig, req_ttvn);
+		   "Sending TT_RESPONSE %pM for %pM [%c] (ttvn: %u)\n",
+		   res_dst_orig_node->orig, req_dst_orig_node->orig,
+		   full_table ? 'F' : '.', req_ttvn);
 
 	batadv_inc_counter(bat_priv, BATADV_CNT_TT_RESPONSE_TX);
 
-	res = batadv_send_skb_to_orig(skb, res_dst_orig_node, NULL);
-	if (res != NET_XMIT_DROP)
-		ret = true;
+	batadv_tvlv_unicast_send(bat_priv, req_dst_orig_node->orig,
+				 req_src, BATADV_TVLV_TT, 1,
+				 tvlv_tt_data, sizeof(*tvlv_tt_data) + tt_len);
 
+	ret = true;
 	goto out;
 
 unlock:
@@ -1835,37 +1823,40 @@ out:
 		batadv_orig_node_free_ref(res_dst_orig_node);
 	if (req_dst_orig_node)
 		batadv_orig_node_free_ref(req_dst_orig_node);
-	if (!ret)
-		kfree_skb(skb);
+	kfree(tvlv_tt_data);
 	return ret;
 }
 
-static bool
-batadv_send_my_tt_response(struct batadv_priv *bat_priv,
-			   struct batadv_tt_query_packet *tt_request)
+/**
+ * batadv_send_my_tt_response - send reply to tt request concerning this node's
+ *  translation table
+ * @bat_priv: the bat priv with all the soft interface information
+ * @tt_data: tt data containing the tt request information
+ * @req_src: mac address of tt request sender
+ *
+ * Returns true if tt request reply was sent, false otherwise.
+ */
+static bool batadv_send_my_tt_response(struct batadv_priv *bat_priv,
+				       struct batadv_tvlv_tt_data *tt_data,
+				       uint8_t *req_src)
 {
+	struct batadv_tvlv_tt_data *tvlv_tt_data = NULL;
 	struct batadv_orig_node *orig_node;
 	struct batadv_hard_iface *primary_if = NULL;
-	uint8_t my_ttvn, req_ttvn, ttvn;
-	int ret = false;
-	unsigned char *tt_buff;
+	uint8_t my_ttvn, req_ttvn;
 	bool full_table;
-	uint16_t tt_len, tt_tot;
-	struct sk_buff *skb = NULL;
-	struct batadv_tt_query_packet *tt_response;
-	uint8_t *packet_pos;
-	size_t len;
+	uint16_t tt_len;
 
 	batadv_dbg(BATADV_DBG_TT, bat_priv,
 		   "Received TT_REQUEST from %pM for ttvn: %u (me) [%c]\n",
-		   tt_request->src, tt_request->ttvn,
-		   (tt_request->flags & BATADV_TT_FULL_TABLE ? 'F' : '.'));
+		   req_src, tt_data->ttvn,
+		   (tt_data->flags & BATADV_TT_FULL_TABLE ? 'F' : '.'));
 
 
 	my_ttvn = (uint8_t)atomic_read(&bat_priv->tt.vn);
-	req_ttvn = tt_request->ttvn;
+	req_ttvn = tt_data->ttvn;
 
-	orig_node = batadv_orig_hash_find(bat_priv, tt_request->src);
+	orig_node = batadv_orig_hash_find(bat_priv, req_src);
 	if (!orig_node)
 		goto out;
 
@@ -1876,71 +1867,58 @@ batadv_send_my_tt_response(struct batadv_priv *bat_priv,
 	/* If the full table has been explicitly requested or the gap
 	 * is too big send the whole local translation table
 	 */
-	if (tt_request->flags & BATADV_TT_FULL_TABLE || my_ttvn != req_ttvn ||
+	if (tt_data->flags & BATADV_TT_FULL_TABLE || my_ttvn != req_ttvn ||
 	    !bat_priv->tt.last_changeset)
 		full_table = true;
 	else
 		full_table = false;
 
-	/* In this version, fragmentation is not implemented, then
-	 * I'll send only one packet with as much TT entries as I can
+	/* TT fragmentation hasn't been implemented yet, so send as many
+	 * TT entries fit a single packet as possible only
 	 */
 	if (!full_table) {
 		spin_lock_bh(&bat_priv->tt.last_changeset_lock);
 		tt_len = bat_priv->tt.last_changeset_len;
-		tt_tot = tt_len / sizeof(struct batadv_tt_change);
 
-		len = sizeof(*tt_response) + tt_len;
-		skb = netdev_alloc_skb_ip_align(NULL, len + ETH_HLEN);
-		if (!skb)
+		tvlv_tt_data = kzalloc(sizeof(*tvlv_tt_data) + tt_len,
+				       GFP_ATOMIC);
+		if (!tvlv_tt_data)
 			goto unlock;
 
-		skb->priority = TC_PRIO_CONTROL;
-		skb_reserve(skb, ETH_HLEN);
-		packet_pos = skb_put(skb, len);
-		tt_response = (struct batadv_tt_query_packet *)packet_pos;
-		tt_response->ttvn = req_ttvn;
-		tt_response->tt_data = htons(tt_tot);
-
-		tt_buff = skb->data + sizeof(*tt_response);
-		memcpy(tt_buff, bat_priv->tt.last_changeset,
+		/* Copy the last orig_node's OGM buffer */
+		memcpy(tvlv_tt_data + 1, bat_priv->tt.last_changeset,
 		       bat_priv->tt.last_changeset_len);
 		spin_unlock_bh(&bat_priv->tt.last_changeset_lock);
 	} else {
 		tt_len = (uint16_t)atomic_read(&bat_priv->tt.local_entry_num);
-		tt_len *= sizeof(struct batadv_tt_change);
-		ttvn = (uint8_t)atomic_read(&bat_priv->tt.vn);
+		tt_len = batadv_tt_len(tt_len);
+		req_ttvn = (uint8_t)atomic_read(&bat_priv->tt.vn);
 
-		skb = batadv_tt_response_fill_table(tt_len, ttvn,
-						    bat_priv->tt.local_hash,
-						    bat_priv,
-						    batadv_tt_local_valid_entry,
-						    NULL);
-		if (!skb)
+		tvlv_tt_data = batadv_tt_tvlv_generate(bat_priv,
+						       bat_priv->tt.local_hash,
+						       tt_len,
+						       batadv_tt_local_valid,
+						       NULL);
+		if (!tvlv_tt_data)
 			goto out;
-
-		tt_response = (struct batadv_tt_query_packet *)skb->data;
 	}
 
-	tt_response->header.packet_type = BATADV_TT_QUERY;
-	tt_response->header.version = BATADV_COMPAT_VERSION;
-	tt_response->header.ttl = BATADV_TTL;
-	memcpy(tt_response->src, primary_if->net_dev->dev_addr, ETH_ALEN);
-	memcpy(tt_response->dst, tt_request->src, ETH_ALEN);
-	tt_response->flags = BATADV_TT_RESPONSE;
+	tvlv_tt_data->flags = BATADV_TT_RESPONSE;
+	tvlv_tt_data->ttvn = req_ttvn;
 
 	if (full_table)
-		tt_response->flags |= BATADV_TT_FULL_TABLE;
+		tvlv_tt_data->flags |= BATADV_TT_FULL_TABLE;
 
 	batadv_dbg(BATADV_DBG_TT, bat_priv,
-		   "Sending TT_RESPONSE to %pM [%c]\n",
-		   orig_node->orig,
-		   (tt_response->flags & BATADV_TT_FULL_TABLE ? 'F' : '.'));
+		   "Sending TT_RESPONSE to %pM [%c] (ttvn: %u)\n",
+		   orig_node->orig, full_table ? 'F' : '.', req_ttvn);
 
 	batadv_inc_counter(bat_priv, BATADV_CNT_TT_RESPONSE_TX);
 
-	if (batadv_send_skb_to_orig(skb, orig_node, NULL) != NET_XMIT_DROP)
-		ret = true;
+	batadv_tvlv_unicast_send(bat_priv, primary_if->net_dev->dev_addr,
+				 req_src, BATADV_TVLV_TT, 1,
+				 tvlv_tt_data, sizeof(*tvlv_tt_data) + tt_len);
+
 	goto out;
 
 unlock:
@@ -1950,29 +1928,39 @@ out:
 		batadv_orig_node_free_ref(orig_node);
 	if (primary_if)
 		batadv_hardif_free_ref(primary_if);
-	if (!ret)
-		kfree_skb(skb);
-	/* This packet was for me, so it doesn't need to be re-routed */
+	kfree(tvlv_tt_data);
+	/* The packet was for this host, so it doesn't need to be re-routed */
 	return true;
 }
 
-bool batadv_send_tt_response(struct batadv_priv *bat_priv,
-			     struct batadv_tt_query_packet *tt_request)
+/**
+ * batadv_send_tt_response - send reply to tt request
+ * @bat_priv: the bat priv with all the soft interface information
+ * @tt_data: tt data containing the tt request information
+ * @req_src: mac address of tt request sender
+ * @req_dst: mac address of tt request recipient
+ *
+ * Returns true if tt request reply was sent, false otherwise.
+ */
+static bool batadv_send_tt_response(struct batadv_priv *bat_priv,
+				    struct batadv_tvlv_tt_data *tt_data,
+				    uint8_t *req_src, uint8_t *req_dst)
 {
-	if (batadv_is_my_mac(bat_priv, tt_request->dst)) {
+	if (batadv_is_my_mac(bat_priv, req_dst)) {
 		/* don't answer backbone gws! */
-		if (batadv_bla_is_backbone_gw_orig(bat_priv, tt_request->src))
+		if (batadv_bla_is_backbone_gw_orig(bat_priv, req_src))
 			return true;
 
-		return batadv_send_my_tt_response(bat_priv, tt_request);
+		return batadv_send_my_tt_response(bat_priv, tt_data, req_src);
 	} else {
-		return batadv_send_other_tt_response(bat_priv, tt_request);
+		return batadv_send_other_tt_response(bat_priv, tt_data,
+						     req_src, req_dst);
 	}
 }
 
 static void _batadv_tt_update_changes(struct batadv_priv *bat_priv,
 				      struct batadv_orig_node *orig_node,
-				      struct batadv_tt_change *tt_change,
+				      struct batadv_tvlv_tt_change *tt_change,
 				      uint16_t tt_num_changes, uint8_t ttvn)
 {
 	int i;
@@ -2002,11 +1990,12 @@ static void _batadv_tt_update_changes(struct batadv_priv *bat_priv,
 }
 
 static void batadv_tt_fill_gtable(struct batadv_priv *bat_priv,
-				  struct batadv_tt_query_packet *tt_response)
+				  struct batadv_tvlv_tt_data *tt_data,
+				  uint8_t *resp_src, uint16_t num_entries)
 {
 	struct batadv_orig_node *orig_node;
 
-	orig_node = batadv_orig_hash_find(bat_priv, tt_response->src);
+	orig_node = batadv_orig_hash_find(bat_priv, resp_src);
 	if (!orig_node)
 		goto out;
 
@@ -2014,9 +2003,8 @@ static void batadv_tt_fill_gtable(struct batadv_priv *bat_priv,
 	batadv_tt_global_del_orig(bat_priv, orig_node, "Received full table");
 
 	_batadv_tt_update_changes(bat_priv, orig_node,
-				  (struct batadv_tt_change *)(tt_response + 1),
-				  ntohs(tt_response->tt_data),
-				  tt_response->ttvn);
+				  (struct batadv_tvlv_tt_change *)(tt_data + 1),
+				  num_entries, tt_data->ttvn);
 
 	spin_lock_bh(&orig_node->tt_buff_lock);
 	kfree(orig_node->tt_buff);
@@ -2024,7 +2012,7 @@ static void batadv_tt_fill_gtable(struct batadv_priv *bat_priv,
 	orig_node->tt_buff = NULL;
 	spin_unlock_bh(&orig_node->tt_buff_lock);
 
-	atomic_set(&orig_node->last_ttvn, tt_response->ttvn);
+	atomic_set(&orig_node->last_ttvn, tt_data->ttvn);
 
 out:
 	if (orig_node)
@@ -2034,7 +2022,7 @@ out:
 static void batadv_tt_update_changes(struct batadv_priv *bat_priv,
 				     struct batadv_orig_node *orig_node,
 				     uint16_t tt_num_changes, uint8_t ttvn,
-				     struct batadv_tt_change *tt_change)
+				     struct batadv_tvlv_tt_change *tt_change)
 {
 	_batadv_tt_update_changes(bat_priv, orig_node, tt_change,
 				  tt_num_changes, ttvn);
@@ -2065,40 +2053,46 @@ out:
 	return ret;
 }
 
-void batadv_handle_tt_response(struct batadv_priv *bat_priv,
-			       struct batadv_tt_query_packet *tt_response)
+/**
+ * batadv_handle_tt_response - process incoming tt reply
+ * @bat_priv: the bat priv with all the soft interface information
+ * @tt_data: tt data containing the tt request information
+ * @resp_src: mac address of tt reply sender
+ * @num_entries: number of tt change entries appended to the tt data
+ */
+static void batadv_handle_tt_response(struct batadv_priv *bat_priv,
+				      struct batadv_tvlv_tt_data *tt_data,
+				      uint8_t *resp_src, uint16_t num_entries)
 {
 	struct batadv_tt_req_node *node, *safe;
 	struct batadv_orig_node *orig_node = NULL;
-	struct batadv_tt_change *tt_change;
+	struct batadv_tvlv_tt_change *tt_change;
 
 	batadv_dbg(BATADV_DBG_TT, bat_priv,
 		   "Received TT_RESPONSE from %pM for ttvn %d t_size: %d [%c]\n",
-		   tt_response->src, tt_response->ttvn,
-		   ntohs(tt_response->tt_data),
-		   (tt_response->flags & BATADV_TT_FULL_TABLE ? 'F' : '.'));
+		   resp_src, tt_data->ttvn, num_entries,
+		   (tt_data->flags & BATADV_TT_FULL_TABLE ? 'F' : '.'));
 
 	/* we should have never asked a backbone gw */
-	if (batadv_bla_is_backbone_gw_orig(bat_priv, tt_response->src))
+	if (batadv_bla_is_backbone_gw_orig(bat_priv, resp_src))
 		goto out;
 
-	orig_node = batadv_orig_hash_find(bat_priv, tt_response->src);
+	orig_node = batadv_orig_hash_find(bat_priv, resp_src);
 	if (!orig_node)
 		goto out;
 
-	if (tt_response->flags & BATADV_TT_FULL_TABLE) {
-		batadv_tt_fill_gtable(bat_priv, tt_response);
+	if (tt_data->flags & BATADV_TT_FULL_TABLE) {
+		batadv_tt_fill_gtable(bat_priv, tt_data, resp_src, num_entries);
 	} else {
-		tt_change = (struct batadv_tt_change *)(tt_response + 1);
-		batadv_tt_update_changes(bat_priv, orig_node,
-					 ntohs(tt_response->tt_data),
-					 tt_response->ttvn, tt_change);
+		tt_change = (struct batadv_tvlv_tt_change *)(tt_data + 1);
+		batadv_tt_update_changes(bat_priv, orig_node, num_entries,
+					 tt_data->ttvn, tt_change);
 	}
 
 	/* Delete the tt_req_node from pending tt_requests list */
 	spin_lock_bh(&bat_priv->tt.req_list_lock);
 	list_for_each_entry_safe(node, safe, &bat_priv->tt.req_list, list) {
-		if (!batadv_compare_eth(node->addr, tt_response->src))
+		if (!batadv_compare_eth(node->addr, resp_src))
 			continue;
 		list_del(&node->list);
 		kfree(node);
@@ -2437,7 +2431,7 @@ static void batadv_tt_update_orig(struct batadv_priv *bat_priv,
 {
 	uint8_t orig_ttvn = (uint8_t)atomic_read(&orig_node->last_ttvn);
 	bool full_table = true;
-	struct batadv_tt_change *tt_change;
+	struct batadv_tvlv_tt_change *tt_change;
 
 	/* don't care about a backbone gateways updates. */
 	if (batadv_bla_is_backbone_gw_orig(bat_priv, orig_node->orig))
@@ -2458,7 +2452,7 @@ static void batadv_tt_update_orig(struct batadv_priv *bat_priv,
 			goto request_table;
 		}
 
-		tt_change = (struct batadv_tt_change *)tt_buff;
+		tt_change = (struct batadv_tvlv_tt_change *)tt_buff;
 		batadv_tt_update_changes(bat_priv, orig_node, tt_num_changes,
 					 ttvn, tt_change);
 
@@ -2599,6 +2593,81 @@ static void batadv_tt_tvlv_ogm_handler_v1(struct batadv_priv *bat_priv,
 }
 
 /**
+ * batadv_tt_tvlv_unicast_handler_v1 - process incoming (unicast) tt tvlv
+ *  container
+ * @bat_priv: the bat priv with all the soft interface information
+ * @src: mac address of tt tvlv sender
+ * @dst: mac address of tt tvlv recipient
+ * @tvlv_value: tvlv buffer containing the tt data
+ * @tvlv_value_len: tvlv buffer length
+ *
+ * Returns NET_RX_DROP if the tt tvlv is to be re-routed, NET_RX_SUCCESS
+ * otherwise.
+ */
+static int batadv_tt_tvlv_unicast_handler_v1(struct batadv_priv *bat_priv,
+					     uint8_t *src, uint8_t *dst,
+					     void *tvlv_value,
+					     uint16_t tvlv_value_len)
+{
+	struct batadv_tvlv_tt_data *tt_data;
+	uint16_t num_entries;
+	char tt_flag;
+	bool ret;
+
+	if (tvlv_value_len < sizeof(*tt_data))
+		return NET_RX_SUCCESS;
+
+	tt_data = (struct batadv_tvlv_tt_data *)tvlv_value;
+	tvlv_value_len -= sizeof(*tt_data);
+
+	num_entries = tvlv_value_len / batadv_tt_len(1);
+
+	switch (tt_data->flags & BATADV_TT_DATA_TYPE_MASK) {
+	case BATADV_TT_REQUEST:
+		batadv_inc_counter(bat_priv, BATADV_CNT_TT_REQUEST_RX);
+
+		/* If this node cannot provide a TT response the tt_request is
+		 * forwarded
+		 */
+		ret = batadv_send_tt_response(bat_priv, tt_data, src, dst);
+		if (!ret) {
+			if (tt_data->flags & BATADV_TT_FULL_TABLE)
+				tt_flag = 'F';
+			else
+				tt_flag = '.';
+
+			batadv_dbg(BATADV_DBG_TT, bat_priv,
+				   "Routing TT_REQUEST to %pM [%c]\n",
+				   dst, tt_flag);
+			/* tvlv API will re-route the packet */
+			return NET_RX_DROP;
+		}
+		break;
+	case BATADV_TT_RESPONSE:
+		batadv_inc_counter(bat_priv, BATADV_CNT_TT_RESPONSE_RX);
+
+		if (batadv_is_my_mac(bat_priv, dst)) {
+			batadv_handle_tt_response(bat_priv, tt_data,
+						  src, num_entries);
+			return NET_RX_SUCCESS;
+		}
+
+		if (tt_data->flags & BATADV_TT_FULL_TABLE)
+			tt_flag =  'F';
+		else
+			tt_flag = '.';
+
+		batadv_dbg(BATADV_DBG_TT, bat_priv,
+			   "Routing TT_RESPONSE to %pM [%c]\n", dst, tt_flag);
+
+		/* tvlv API will re-route the packet */
+		return NET_RX_DROP;
+	}
+
+	return NET_RX_SUCCESS;
+}
+
+/**
  * batadv_tt_init - initialise the translation table internals
  * @bat_priv: the bat priv with all the soft interface information
  *
@@ -2617,7 +2686,8 @@ int batadv_tt_init(struct batadv_priv *bat_priv)
 		return ret;
 
 	batadv_tvlv_handler_register(bat_priv, batadv_tt_tvlv_ogm_handler_v1,
-				     NULL, BATADV_TVLV_TT, 1, BATADV_NO_FLAGS);
+				     batadv_tt_tvlv_unicast_handler_v1,
+				     BATADV_TVLV_TT, 1, BATADV_NO_FLAGS);
 
 	INIT_DELAYED_WORK(&bat_priv->tt.work, batadv_tt_purge);
 	queue_delayed_work(batadv_event_workqueue, &bat_priv->tt.work,
diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/translation-table.h
index a709249..b4b6dea 100644
--- a/net/batman-adv/translation-table.h
+++ b/net/batman-adv/translation-table.h
@@ -20,7 +20,6 @@
 #ifndef _NET_BATMAN_ADV_TRANSLATION_TABLE_H_
 #define _NET_BATMAN_ADV_TRANSLATION_TABLE_H_
 
-int batadv_tt_len(int changes_num);
 int batadv_tt_init(struct batadv_priv *bat_priv);
 void batadv_tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 			 int ifindex);
@@ -43,11 +42,7 @@ struct batadv_orig_node *batadv_transtable_search(struct batadv_priv *bat_priv,
 						  const uint8_t *src,
 						  const uint8_t *addr);
 void batadv_tt_free(struct batadv_priv *bat_priv);
-bool batadv_send_tt_response(struct batadv_priv *bat_priv,
-			     struct batadv_tt_query_packet *tt_request);
 bool batadv_is_my_client(struct batadv_priv *bat_priv, const uint8_t *addr);
-void batadv_handle_tt_response(struct batadv_priv *bat_priv,
-			       struct batadv_tt_query_packet *tt_response);
 bool batadv_is_ap_isolated(struct batadv_priv *bat_priv, uint8_t *src,
 			   uint8_t *dst);
 void batadv_tt_local_commit_changes(struct batadv_priv *bat_priv);
-- 
1.8.3.2
