From: Marek Lindner <lindner_marek@yahoo.de>
Subject: [PATCH 8/8] batman-adv: merge update_transtable() into tt related code
Date: Wed, 24 Aug 2011 15:00:38 +0200
Message-ID: <1314190838-2273-9-git-send-email-lindner_marek@yahoo.de>
References: <1314190838-2273-1-git-send-email-lindner_marek@yahoo.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm19.bullet.mail.ukl.yahoo.com ([217.146.183.193]:29694 "HELO
	nm19.bullet.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754863Ab1HXNBS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2011 09:01:18 -0400
In-Reply-To: <1314190838-2273-1-git-send-email-lindner_marek@yahoo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/routing.c           |   66 ++--------------------------------
 net/batman-adv/translation-table.c |   69 +++++++++++++++++++++++++++++++++---
 net/batman-adv/translation-table.h |    9 ++---
 3 files changed, 70 insertions(+), 74 deletions(-)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 91a7860..1949928 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -64,65 +64,6 @@ void slide_own_bcast_window(struct hard_iface *hard_iface)
 	}
 }
 
-static void update_transtable(struct bat_priv *bat_priv,
-			      struct orig_node *orig_node,
-			      const unsigned char *tt_buff,
-			      uint8_t tt_num_changes, uint8_t ttvn,
-			      uint16_t tt_crc)
-{
-	uint8_t orig_ttvn = (uint8_t)atomic_read(&orig_node->last_ttvn);
-	bool full_table = true;
-
-	/* the ttvn increased by one -> we can apply the attached changes */
-	if (ttvn - orig_ttvn == 1) {
-		/* the OGM could not contain the changes due to their size or
-		 * because they have already been sent TT_OGM_APPEND_MAX times.
-		 * In this case send a tt request */
-		if (!tt_num_changes) {
-			full_table = false;
-			goto request_table;
-		}
-
-		tt_update_changes(bat_priv, orig_node, tt_num_changes, ttvn,
-				  (struct tt_change *)tt_buff);
-
-		/* Even if we received the precomputed crc with the OGM, we
-		 * prefer to recompute it to spot any possible inconsistency
-		 * in the global table */
-		orig_node->tt_crc = tt_global_crc(bat_priv, orig_node);
-
-		/* The ttvn alone is not enough to guarantee consistency
-		 * because a single value could represent different states
-		 * (due to the wrap around). Thus a node has to check whether
-		 * the resulting table (after applying the changes) is still
-		 * consistent or not. E.g. a node could disconnect while its
-		 * ttvn is X and reconnect on ttvn = X + TTVN_MAX: in this case
-		 * checking the CRC value is mandatory to detect the
-		 * inconsistency */
-		if (orig_node->tt_crc != tt_crc)
-			goto request_table;
-
-		/* Roaming phase is over: tables are in sync again. I can
-		 * unset the flag */
-		orig_node->tt_poss_change = false;
-	} else {
-		/* if we missed more than one change or our tables are not
-		 * in sync anymore -> request fresh tt data */
-		if (ttvn != orig_ttvn || orig_node->tt_crc != tt_crc) {
-request_table:
-			bat_dbg(DBG_TT, bat_priv, "TT inconsistency for %pM. "
-				"Need to retrieve the correct information "
-				"(ttvn: %u last_ttvn: %u crc: %u last_crc: "
-				"%u num_changes: %u)\n", orig_node->orig, ttvn,
-				orig_ttvn, tt_crc, orig_node->tt_crc,
-				tt_num_changes);
-			send_tt_request(bat_priv, orig_node, ttvn, tt_crc,
-					full_table);
-			return;
-		}
-	}
-}
-
 static void update_route(struct bat_priv *bat_priv,
 			 struct orig_node *orig_node,
 			 struct neigh_node *neigh_node)
@@ -499,10 +440,9 @@ update_tt:
 	if (((batman_packet->orig != ethhdr->h_source) &&
 				(batman_packet->ttl > 2)) ||
 				(batman_packet->flags & PRIMARIES_FIRST_HOP))
-		update_transtable(bat_priv, orig_node, tt_buff,
-				  batman_packet->tt_num_changes,
-				  batman_packet->ttvn,
-				  batman_packet->tt_crc);
+		tt_update_orig(bat_priv, orig_node, tt_buff,
+			       batman_packet->tt_num_changes,
+			       batman_packet->ttvn, batman_packet->tt_crc);
 
 	if (orig_node->gw_flags != batman_packet->gw_flags)
 		gw_node_update(bat_priv, orig_node, batman_packet->gw_flags);
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index e8f849f..cc53f78 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -1079,8 +1079,9 @@ out:
 	return skb;
 }
 
-int send_tt_request(struct bat_priv *bat_priv, struct orig_node *dst_orig_node,
-		    uint8_t ttvn, uint16_t tt_crc, bool full_table)
+static int send_tt_request(struct bat_priv *bat_priv,
+			   struct orig_node *dst_orig_node,
+			   uint8_t ttvn, uint16_t tt_crc, bool full_table)
 {
 	struct sk_buff *skb = NULL;
 	struct tt_query_packet *tt_request;
@@ -1455,9 +1456,10 @@ out:
 		orig_node_free_ref(orig_node);
 }
 
-void tt_update_changes(struct bat_priv *bat_priv, struct orig_node *orig_node,
-		       uint16_t tt_num_changes, uint8_t ttvn,
-		       struct tt_change *tt_change)
+static void tt_update_changes(struct bat_priv *bat_priv,
+			      struct orig_node *orig_node,
+			      uint16_t tt_num_changes, uint8_t ttvn,
+			      struct tt_change *tt_change)
 {
 	_tt_update_changes(bat_priv, orig_node, tt_change, tt_num_changes,
 			   ttvn);
@@ -1802,3 +1804,60 @@ out:
 		tt_local_entry_free_ref(tt_local_entry);
 	return ret;
 }
+
+void tt_update_orig(struct bat_priv *bat_priv, struct orig_node *orig_node,
+		    const unsigned char *tt_buff, uint8_t tt_num_changes,
+		    uint8_t ttvn, uint16_t tt_crc)
+{
+	uint8_t orig_ttvn = (uint8_t)atomic_read(&orig_node->last_ttvn);
+	bool full_table = true;
+
+	/* the ttvn increased by one -> we can apply the attached changes */
+	if (ttvn - orig_ttvn == 1) {
+		/* the OGM could not contain the changes due to their size or
+		 * because they have already been sent TT_OGM_APPEND_MAX times.
+		 * In this case send a tt request */
+		if (!tt_num_changes) {
+			full_table = false;
+			goto request_table;
+		}
+
+		tt_update_changes(bat_priv, orig_node, tt_num_changes, ttvn,
+				  (struct tt_change *)tt_buff);
+
+		/* Even if we received the precomputed crc with the OGM, we
+		 * prefer to recompute it to spot any possible inconsistency
+		 * in the global table */
+		orig_node->tt_crc = tt_global_crc(bat_priv, orig_node);
+
+		/* The ttvn alone is not enough to guarantee consistency
+		 * because a single value could represent different states
+		 * (due to the wrap around). Thus a node has to check whether
+		 * the resulting table (after applying the changes) is still
+		 * consistent or not. E.g. a node could disconnect while its
+		 * ttvn is X and reconnect on ttvn = X + TTVN_MAX: in this case
+		 * checking the CRC value is mandatory to detect the
+		 * inconsistency */
+		if (orig_node->tt_crc != tt_crc)
+			goto request_table;
+
+		/* Roaming phase is over: tables are in sync again. I can
+		 * unset the flag */
+		orig_node->tt_poss_change = false;
+	} else {
+		/* if we missed more than one change or our tables are not
+		 * in sync anymore -> request fresh tt data */
+		if (ttvn != orig_ttvn || orig_node->tt_crc != tt_crc) {
+request_table:
+			bat_dbg(DBG_TT, bat_priv, "TT inconsistency for %pM. "
+				"Need to retrieve the correct information "
+				"(ttvn: %u last_ttvn: %u crc: %u last_crc: "
+				"%u num_changes: %u)\n", orig_node->orig, ttvn,
+				orig_ttvn, tt_crc, orig_node->tt_crc,
+				tt_num_changes);
+			send_tt_request(bat_priv, orig_node, ttvn, tt_crc,
+					full_table);
+			return;
+		}
+	}
+}
diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/translation-table.h
index b47e876..30efd49 100644
--- a/net/batman-adv/translation-table.h
+++ b/net/batman-adv/translation-table.h
@@ -49,14 +49,8 @@ void tt_save_orig_buffer(struct bat_priv *bat_priv, struct orig_node *orig_node,
 uint16_t tt_local_crc(struct bat_priv *bat_priv);
 uint16_t tt_global_crc(struct bat_priv *bat_priv, struct orig_node *orig_node);
 void tt_free(struct bat_priv *bat_priv);
-int send_tt_request(struct bat_priv *bat_priv,
-		    struct orig_node *dst_orig_node, uint8_t ttvn,
-		    uint16_t tt_crc, bool full_table);
 bool send_tt_response(struct bat_priv *bat_priv,
 		      struct tt_query_packet *tt_request);
-void tt_update_changes(struct bat_priv *bat_priv, struct orig_node *orig_node,
-		       uint16_t tt_num_changes, uint8_t ttvn,
-		       struct tt_change *tt_change);
 bool is_my_client(struct bat_priv *bat_priv, const uint8_t *addr);
 void handle_tt_response(struct bat_priv *bat_priv,
 			struct tt_query_packet *tt_response);
@@ -64,5 +58,8 @@ void send_roam_adv(struct bat_priv *bat_priv, uint8_t *client,
 		   struct orig_node *orig_node);
 void tt_commit_changes(struct bat_priv *bat_priv);
 bool is_ap_isolated(struct bat_priv *bat_priv, uint8_t *src, uint8_t *dst);
+void tt_update_orig(struct bat_priv *bat_priv, struct orig_node *orig_node,
+		    const unsigned char *tt_buff, uint8_t tt_num_changes,
+		    uint8_t ttvn, uint16_t tt_crc);
 
 #endif /* _NET_BATMAN_ADV_TRANSLATION_TABLE_H_ */
-- 
1.7.5.3
