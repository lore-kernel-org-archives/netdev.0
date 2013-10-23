From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 14/16] batman-adv: include the sync-flags when compute the global/local table CRC
Date: Wed, 23 Oct 2013 18:05:01 +0200
Message-ID: <1382544303-2694-15-git-send-email-antonio@meshcoding.com>
References: <1382544303-2694-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:36405 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752507Ab3JWQLu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 12:11:50 -0400
In-Reply-To: <1382544303-2694-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

Flags covered by TT_SYNC_MASK are kept in sync among the
nodes in the network and therefore they have to be
considered while computing the global/local table CRC.

In this way a generic originator is able to understand if
its table contains the correct flags or not.

Bits from 4 to 7 in the TT flags fields are now reserved for
"synchronized" flags only.

This allows future developers to add more flags of this type
without breaking compatibility.

It's important to note that not all the remote TT flags are
synchronised. This comes from the fact that some flags are
used to inject an information once only.

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/packet.h            |  5 +++--
 net/batman-adv/translation-table.c | 19 +++++++++++++++++++
 net/batman-adv/types.h             |  6 ++++++
 3 files changed, 28 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 9fbcaac..843b96a 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -110,12 +110,13 @@ enum batadv_tt_data_flags {
 
 /* BATADV_TT_CLIENT flags.
  * Flags from BIT(0) to BIT(7) are sent on the wire, while flags from BIT(8) to
- * BIT(15) are used for local computation only
+ * BIT(15) are used for local computation only.
+ * Flags from BIT(4) to BIT(7) are kept in sync with the rest of the network.
  */
 enum batadv_tt_client_flags {
 	BATADV_TT_CLIENT_DEL     = BIT(0),
 	BATADV_TT_CLIENT_ROAM    = BIT(1),
-	BATADV_TT_CLIENT_WIFI    = BIT(2),
+	BATADV_TT_CLIENT_WIFI    = BIT(4),
 	BATADV_TT_CLIENT_NOPURGE = BIT(8),
 	BATADV_TT_CLIENT_NEW     = BIT(9),
 	BATADV_TT_CLIENT_PENDING = BIT(10),
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 267780f..4add57d 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -1959,6 +1959,7 @@ static uint32_t batadv_tt_global_crc(struct batadv_priv *bat_priv,
 	struct batadv_tt_global_entry *tt_global;
 	struct hlist_head *head;
 	uint32_t i, crc_tmp, crc = 0;
+	uint8_t flags;
 
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
@@ -1997,6 +1998,13 @@ static uint32_t batadv_tt_global_crc(struct batadv_priv *bat_priv,
 
 			crc_tmp = crc32c(0, &tt_common->vid,
 					 sizeof(tt_common->vid));
+
+			/* compute the CRC on flags that have to be kept in sync
+			 * among nodes
+			 */
+			flags = tt_common->flags & BATADV_TT_SYNC_MASK;
+			crc_tmp = crc32c(crc_tmp, &flags, sizeof(flags));
+
 			crc ^= crc32c(crc_tmp, tt_common->addr, ETH_ALEN);
 		}
 		rcu_read_unlock();
@@ -2022,6 +2030,7 @@ static uint32_t batadv_tt_local_crc(struct batadv_priv *bat_priv,
 	struct batadv_tt_common_entry *tt_common;
 	struct hlist_head *head;
 	uint32_t i, crc_tmp, crc = 0;
+	uint8_t flags;
 
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
@@ -2042,6 +2051,13 @@ static uint32_t batadv_tt_local_crc(struct batadv_priv *bat_priv,
 
 			crc_tmp = crc32c(0, &tt_common->vid,
 					 sizeof(tt_common->vid));
+
+			/* compute the CRC on flags that have to be kept in sync
+			 * among nodes
+			 */
+			flags = tt_common->flags & BATADV_TT_SYNC_MASK;
+			crc_tmp = crc32c(crc_tmp, &flags, sizeof(flags));
+
 			crc ^= crc32c(crc_tmp, tt_common->addr, ETH_ALEN);
 		}
 		rcu_read_unlock();
@@ -3524,6 +3540,9 @@ int batadv_tt_init(struct batadv_priv *bat_priv)
 {
 	int ret;
 
+	/* synchronized flags must be remote */
+	BUILD_BUG_ON(!(BATADV_TT_SYNC_MASK & BATADV_TT_REMOTE_MASK));
+
 	ret = batadv_tt_local_init(bat_priv);
 	if (ret < 0)
 		return ret;
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 61297b6..3c21162 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -42,6 +42,12 @@
 #define BATADV_TT_REMOTE_MASK	0x00FF
 
 /**
+ * BATADV_TT_SYNC_MASK - bitmask of the flags that need to be kept in sync
+ *  among the nodes. These flags are used to compute the global/local CRC
+ */
+#define BATADV_TT_SYNC_MASK	0x00F0
+
+/**
  * struct batadv_hard_iface_bat_iv - per hard interface B.A.T.M.A.N. IV data
  * @ogm_buff: buffer holding the OGM packet
  * @ogm_buff_len: length of the OGM packet buffer
-- 
1.8.4
