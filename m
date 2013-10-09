From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 10/16] batman-adv: use CRC32C instead of CRC16 in TT code
Date: Wed,  9 Oct 2013 14:40:12 +0200
Message-ID: <1381322418-1349-11-git-send-email-antonio@meshcoding.com>
References: <1381322418-1349-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:1663 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754281Ab3JIN24 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 09:28:56 -0400
In-Reply-To: <1381322418-1349-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>

CRC32C has to be preferred to CRC16 because of its possible
HW native support and because of the reduced collision
probability. With this change the Translation Table
component now uses CRC32C to compute the local and global
table checksum.

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/packet.h            |  6 ++--
 net/batman-adv/translation-table.c | 73 ++++++++++++++++++++------------------
 net/batman-adv/types.h             |  4 +--
 3 files changed, 45 insertions(+), 38 deletions(-)

diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 5c08d26..7a337d7 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -345,12 +345,14 @@ struct batadv_tvlv_gateway_data {
  * struct batadv_tvlv_tt_data - tt data propagated through the tt tvlv container
  * @flags: translation table flags (see batadv_tt_data_flags)
  * @ttvn: translation table version number
- * @crc: crc16 checksum of the local translation table
+ * @reserved: field reserved for future use
+ * @crc: crc32 checksum of the local translation table
  */
 struct batadv_tvlv_tt_data {
 	uint8_t flags;
 	uint8_t ttvn;
-	__be16  crc;
+	uint16_t reserved;
+	__be32  crc;
 };
 
 /**
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index cb3c58e..4cdd743 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -27,7 +27,7 @@
 #include "routing.h"
 #include "bridge_loop_avoidance.h"
 
-#include <linux/crc16.h>
+#include <linux/crc32c.h>
 
 /* hash class keys */
 static struct lock_class_key batadv_tt_local_hash_lock_class_key;
@@ -409,7 +409,7 @@ static void batadv_tt_tvlv_container_update(struct batadv_priv *bat_priv)
 
 	tt_data->flags = BATADV_TT_OGM_DIFF;
 	tt_data->ttvn = atomic_read(&bat_priv->tt.vn);
-	tt_data->crc = htons(bat_priv->tt.local_crc);
+	tt_data->crc = htonl(bat_priv->tt.local_crc);
 
 	if (tt_diff_len == 0)
 		goto container_register;
@@ -481,7 +481,7 @@ int batadv_tt_local_seq_print_text(struct seq_file *seq, void *offset)
 		goto out;
 
 	seq_printf(seq,
-		   "Locally retrieved addresses (from %s) announced via TT (TTVN: %u CRC: %#.4x):\n",
+		   "Locally retrieved addresses (from %s) announced via TT (TTVN: %u CRC: %#.8x):\n",
 		   net_dev->name, (uint8_t)atomic_read(&bat_priv->tt.vn),
 		   bat_priv->tt.local_crc);
 	seq_printf(seq, "       %-13s %-7s %-10s\n", "Client", "Flags",
@@ -993,7 +993,7 @@ batadv_tt_global_print_entry(struct batadv_tt_global_entry *tt_global_entry,
 	if (best_entry) {
 		last_ttvn = atomic_read(&best_entry->orig_node->last_ttvn);
 		seq_printf(seq,
-			   " %c %pM  (%3u) via %pM     (%3u)   (%#.4x) [%c%c%c]\n",
+			   " %c %pM  (%3u) via %pM     (%3u)   (%#.8x) [%c%c%c]\n",
 			   '*', tt_global_entry->common.addr,
 			   best_entry->ttvn, best_entry->orig_node->orig,
 			   last_ttvn, best_entry->orig_node->tt_crc,
@@ -1037,7 +1037,7 @@ int batadv_tt_global_seq_print_text(struct seq_file *seq, void *offset)
 	seq_printf(seq,
 		   "Globally announced TT entries received via the mesh %s\n",
 		   net_dev->name);
-	seq_printf(seq, "       %-13s %s       %-15s %s (%-6s) %s\n",
+	seq_printf(seq, "       %-13s %s       %-15s %s (%-10s) %s\n",
 		   "Client", "(TTVN)", "Originator", "(Curr TTVN)", "CRC",
 		   "Flags");
 
@@ -1394,17 +1394,19 @@ out:
 	return orig_node;
 }
 
-/* Calculates the checksum of the local table of a given orig_node */
-static uint16_t batadv_tt_global_crc(struct batadv_priv *bat_priv,
+/**
+ * batadv_tt_global_crc - calculates the checksum of the local table belonging
+ *  to the given orig_node
+ * @bat_priv: the bat priv with all the soft interface information
+ */
+static uint32_t batadv_tt_global_crc(struct batadv_priv *bat_priv,
 				     struct batadv_orig_node *orig_node)
 {
-	uint16_t total = 0, total_one;
 	struct batadv_hashtable *hash = bat_priv->tt.global_hash;
 	struct batadv_tt_common_entry *tt_common;
 	struct batadv_tt_global_entry *tt_global;
 	struct hlist_head *head;
-	uint32_t i;
-	int j;
+	uint32_t i, crc = 0;
 
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
@@ -1435,27 +1437,24 @@ static uint16_t batadv_tt_global_crc(struct batadv_priv *bat_priv,
 							     orig_node))
 				continue;
 
-			total_one = 0;
-			for (j = 0; j < ETH_ALEN; j++)
-				total_one = crc16_byte(total_one,
-						       tt_common->addr[j]);
-			total ^= total_one;
+			crc ^= crc32c(0, tt_common->addr, ETH_ALEN);
 		}
 		rcu_read_unlock();
 	}
 
-	return total;
+	return crc;
 }
 
-/* Calculates the checksum of the local table */
-static uint16_t batadv_tt_local_crc(struct batadv_priv *bat_priv)
+/**
+ * batadv_tt_local_crc - calculates the checksum of the local table
+ * @bat_priv: the bat priv with all the soft interface information
+ */
+static uint32_t batadv_tt_local_crc(struct batadv_priv *bat_priv)
 {
-	uint16_t total = 0, total_one;
 	struct batadv_hashtable *hash = bat_priv->tt.local_hash;
 	struct batadv_tt_common_entry *tt_common;
 	struct hlist_head *head;
-	uint32_t i;
-	int j;
+	uint32_t i, crc = 0;
 
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
@@ -1467,16 +1466,13 @@ static uint16_t batadv_tt_local_crc(struct batadv_priv *bat_priv)
 			 */
 			if (tt_common->flags & BATADV_TT_CLIENT_NEW)
 				continue;
-			total_one = 0;
-			for (j = 0; j < ETH_ALEN; j++)
-				total_one = crc16_byte(total_one,
-						       tt_common->addr[j]);
-			total ^= total_one;
+
+			crc ^= crc32c(0, tt_common->addr, ETH_ALEN);
 		}
 		rcu_read_unlock();
 	}
 
-	return total;
+	return crc;
 }
 
 static void batadv_tt_req_list_free(struct batadv_priv *bat_priv)
@@ -1662,9 +1658,18 @@ out:
 	return tvlv_tt_data;
 }
 
+/**
+ * batadv_send_tt_request - send a TT Request message to a given node
+ * @bat_priv: the bat priv with all the soft interface information
+ * @dst_orig_node: the destination of the message
+ * @ttvn: the version number that the source of the message is looking for
+ * @tt_crc: the CRC associated with the version number
+ * @full_table: ask for the entire translation table if true, while only for the
+ *  last TT diff otherwise
+ */
 static int batadv_send_tt_request(struct batadv_priv *bat_priv,
 				  struct batadv_orig_node *dst_orig_node,
-				  uint8_t ttvn, uint16_t tt_crc,
+				  uint8_t ttvn, uint32_t tt_crc,
 				  bool full_table)
 {
 	struct batadv_tvlv_tt_data *tvlv_tt_data = NULL;
@@ -1689,7 +1694,7 @@ static int batadv_send_tt_request(struct batadv_priv *bat_priv,
 
 	tvlv_tt_data->flags = BATADV_TT_REQUEST;
 	tvlv_tt_data->ttvn = ttvn;
-	tvlv_tt_data->crc = htons(tt_crc);
+	tvlv_tt_data->crc = htonl(tt_crc);
 
 	if (full_table)
 		tvlv_tt_data->flags |= BATADV_TT_FULL_TABLE;
@@ -1756,7 +1761,7 @@ static bool batadv_send_other_tt_response(struct batadv_priv *bat_priv,
 
 	/* this node doesn't have the requested data */
 	if (orig_ttvn != req_ttvn ||
-	    tt_data->crc != htons(req_dst_orig_node->tt_crc))
+	    tt_data->crc != htonl(req_dst_orig_node->tt_crc))
 		goto out;
 
 	/* If the full table has been explicitly requested */
@@ -2403,13 +2408,13 @@ out:
  * @tt_buff: buffer holding the tt information
  * @tt_num_changes: number of tt changes inside the tt buffer
  * @ttvn: translation table version number of this changeset
- * @tt_crc: crc16 checksum of orig node's translation table
+ * @tt_crc: crc32 checksum of orig node's translation table
  */
 static void batadv_tt_update_orig(struct batadv_priv *bat_priv,
 				  struct batadv_orig_node *orig_node,
 				  const unsigned char *tt_buff,
 				  uint16_t tt_num_changes, uint8_t ttvn,
-				  uint16_t tt_crc)
+				  uint32_t tt_crc)
 {
 	uint8_t orig_ttvn = (uint8_t)atomic_read(&orig_node->last_ttvn);
 	bool full_table = true;
@@ -2463,7 +2468,7 @@ static void batadv_tt_update_orig(struct batadv_priv *bat_priv,
 		    orig_node->tt_crc != tt_crc) {
 request_table:
 			batadv_dbg(BATADV_DBG_TT, bat_priv,
-				   "TT inconsistency for %pM. Need to retrieve the correct information (ttvn: %u last_ttvn: %u crc: %#.4x last_crc: %#.4x num_changes: %u)\n",
+				   "TT inconsistency for %pM. Need to retrieve the correct information (ttvn: %u last_ttvn: %u crc: %#.8x last_crc: %#.8x num_changes: %u)\n",
 				   orig_node->orig, ttvn, orig_ttvn, tt_crc,
 				   orig_node->tt_crc, tt_num_changes);
 			batadv_send_tt_request(bat_priv, orig_node, ttvn,
@@ -2571,7 +2576,7 @@ static void batadv_tt_tvlv_ogm_handler_v1(struct batadv_priv *bat_priv,
 
 	batadv_tt_update_orig(bat_priv, orig,
 			      (unsigned char *)(tt_data + 1),
-			      num_entries, tt_data->ttvn, ntohs(tt_data->crc));
+			      num_entries, tt_data->ttvn, ntohl(tt_data->crc));
 }
 
 /**
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index bdabbc2..e98915a 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -150,7 +150,7 @@ struct batadv_orig_node {
 	uint8_t flags;
 	uint8_t capabilities;
 	atomic_t last_ttvn;
-	uint16_t tt_crc;
+	uint32_t tt_crc;
 	unsigned char *tt_buff;
 	int16_t tt_buff_len;
 	spinlock_t tt_buff_lock; /* protects tt_buff & tt_buff_len */
@@ -377,7 +377,7 @@ struct batadv_priv_tt {
 	spinlock_t req_list_lock; /* protects req_list */
 	spinlock_t roam_list_lock; /* protects roam_list */
 	atomic_t local_entry_num;
-	uint16_t local_crc;
+	uint32_t local_crc;
 	unsigned char *last_changeset;
 	int16_t last_changeset_len;
 	/* protects last_changeset & last_changeset_len */
-- 
1.8.3.2
