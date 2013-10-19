From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 06/18] batman-adv: use vid when computing local and global TT CRC
Date: Sun, 20 Oct 2013 00:21:58 +0200
Message-ID: <1382221330-3769-7-git-send-email-antonio@meshcoding.com>
References: <1382221330-3769-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:13908 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753627Ab3JSWXD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Oct 2013 18:23:03 -0400
In-Reply-To: <1382221330-3769-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

now that each TT entry is characterised by a VLAN ID, the
latter has to be taken into consideration when computing the
local/global table CRC as it would be theoretically possible
to have the same client in two different VLANs

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/translation-table.c | 35 +++++++++++++++++++++++++++++++----
 1 file changed, 31 insertions(+), 4 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 63adb97..c8fc303 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -1506,6 +1506,24 @@ out:
  * batadv_tt_global_crc - calculates the checksum of the local table belonging
  *  to the given orig_node
  * @bat_priv: the bat priv with all the soft interface information
+ * @orig_node: originator for which the CRC should be computed
+ *
+ * This function computes the checksum for the global table corresponding to a
+ * specific originator. In particular, the checksum is computed as follows: For
+ * each client connected to the originator the CRC32C of the MAC address and the
+ * VID is computed and then all the CRC32Cs of the various clients are xor'ed
+ * together.
+ *
+ * The idea behind is that CRC32C should be used as much as possible in order to
+ * produce a unique hash of the table, but since the order which is used to feed
+ * the CRC32C function affects the result and since every node in the network
+ * probably sorts the clients differently, the hash function cannot be directly
+ * computed over the entire table. Hence the CRC32C is used only on
+ * the single client entry, while all the results are then xor'ed together
+ * because the XOR operation can combine them all while trying to reduce the
+ * noise as much as possible.
+ *
+ * Returns the checksum of the global table of a given originator.
  */
 static uint32_t batadv_tt_global_crc(struct batadv_priv *bat_priv,
 				     struct batadv_orig_node *orig_node)
@@ -1514,7 +1532,7 @@ static uint32_t batadv_tt_global_crc(struct batadv_priv *bat_priv,
 	struct batadv_tt_common_entry *tt_common;
 	struct batadv_tt_global_entry *tt_global;
 	struct hlist_head *head;
-	uint32_t i, crc = 0;
+	uint32_t i, crc_tmp, crc = 0;
 
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
@@ -1545,7 +1563,9 @@ static uint32_t batadv_tt_global_crc(struct batadv_priv *bat_priv,
 							     orig_node))
 				continue;
 
-			crc ^= crc32c(0, tt_common->addr, ETH_ALEN);
+			crc_tmp = crc32c(0, &tt_common->vid,
+					 sizeof(tt_common->vid));
+			crc ^= crc32c(crc_tmp, tt_common->addr, ETH_ALEN);
 		}
 		rcu_read_unlock();
 	}
@@ -1556,13 +1576,18 @@ static uint32_t batadv_tt_global_crc(struct batadv_priv *bat_priv,
 /**
  * batadv_tt_local_crc - calculates the checksum of the local table
  * @bat_priv: the bat priv with all the soft interface information
+ *
+ * For details about the computation, please refer to the documentation for
+ * batadv_tt_global_crc().
+ *
+ * Returns the checksum of the local table
  */
 static uint32_t batadv_tt_local_crc(struct batadv_priv *bat_priv)
 {
 	struct batadv_hashtable *hash = bat_priv->tt.local_hash;
 	struct batadv_tt_common_entry *tt_common;
 	struct hlist_head *head;
-	uint32_t i, crc = 0;
+	uint32_t i, crc_tmp, crc = 0;
 
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
@@ -1575,7 +1600,9 @@ static uint32_t batadv_tt_local_crc(struct batadv_priv *bat_priv)
 			if (tt_common->flags & BATADV_TT_CLIENT_NEW)
 				continue;
 
-			crc ^= crc32c(0, tt_common->addr, ETH_ALEN);
+			crc_tmp = crc32c(0, &tt_common->vid,
+					 sizeof(tt_common->vid));
+			crc ^= crc32c(crc_tmp, tt_common->addr, ETH_ALEN);
 		}
 		rcu_read_unlock();
 	}
-- 
1.8.4
