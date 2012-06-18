From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 16/19] batman-adv: turn tt commit code into routing protocol agnostic API
Date: Mon, 18 Jun 2012 22:39:20 +0200
Message-ID: <1340051963-14836-17-git-send-email-ordex@autistici.org>
References: <1340051963-14836-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:41527 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753400Ab2FRUjS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2012 16:39:18 -0400
In-Reply-To: <1340051963-14836-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

Prior to this patch the translation table code made assumptions about how
the routing protocol works and where its buffers are stored (to directly
modify them).
Each protocol now calls the tt code with the relevant pointers, thereby
abstracting the code.

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Acked-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bat_iv_ogm.c        |   14 ++--
 net/batman-adv/send.c              |   74 +--------------------
 net/batman-adv/translation-table.c |  124 ++++++++++++++++++++++++++++++------
 net/batman-adv/translation-table.h |    7 +-
 net/batman-adv/types.h             |    3 +-
 5 files changed, 118 insertions(+), 104 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index ec3542c..6e0859f 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -559,22 +559,28 @@ static void bat_iv_ogm_forward(struct orig_node *orig_node,
 			     if_incoming, 0, bat_iv_ogm_fwd_send_time());
 }
 
-static void bat_iv_ogm_schedule(struct hard_iface *hard_iface,
-				int tt_num_changes)
+static void bat_iv_ogm_schedule(struct hard_iface *hard_iface)
 {
 	struct bat_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
 	struct batman_ogm_packet *batman_ogm_packet;
 	struct hard_iface *primary_if;
-	int vis_server;
+	int vis_server, tt_num_changes = 0;
 
 	vis_server = atomic_read(&bat_priv->vis_mode);
 	primary_if = primary_if_get_selected(bat_priv);
 
+	if (hard_iface == primary_if)
+		tt_num_changes = batadv_tt_append_diff(bat_priv,
+						       &hard_iface->packet_buff,
+						       &hard_iface->packet_len,
+						       BATMAN_OGM_HLEN);
+
 	batman_ogm_packet = (struct batman_ogm_packet *)hard_iface->packet_buff;
 
 	/* change sequence number to network order */
 	batman_ogm_packet->seqno =
 			htonl((uint32_t)atomic_read(&hard_iface->seqno));
+	atomic_inc(&hard_iface->seqno);
 
 	batman_ogm_packet->ttvn = atomic_read(&bat_priv->ttvn);
 	batman_ogm_packet->tt_crc = htons(bat_priv->tt_crc);
@@ -593,8 +599,6 @@ static void bat_iv_ogm_schedule(struct hard_iface *hard_iface,
 	else
 		batman_ogm_packet->gw_flags = NO_FLAGS;
 
-	atomic_inc(&hard_iface->seqno);
-
 	slide_own_bcast_window(hard_iface);
 	bat_iv_ogm_queue_add(bat_priv, hard_iface->packet_buff,
 			     hard_iface->packet_len, hard_iface, 1,
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index f5ff364..79f8973 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -77,62 +77,9 @@ send_skb_err:
 	return NET_XMIT_DROP;
 }
 
-static void realloc_packet_buffer(struct hard_iface *hard_iface,
-				  int new_len)
-{
-	unsigned char *new_buff;
-
-	new_buff = kmalloc(new_len, GFP_ATOMIC);
-
-	/* keep old buffer if kmalloc should fail */
-	if (new_buff) {
-		memcpy(new_buff, hard_iface->packet_buff,
-		       BATMAN_OGM_HLEN);
-
-		kfree(hard_iface->packet_buff);
-		hard_iface->packet_buff = new_buff;
-		hard_iface->packet_len = new_len;
-	}
-}
-
-/* when calling this function (hard_iface == primary_if) has to be true */
-static int prepare_packet_buffer(struct bat_priv *bat_priv,
-				  struct hard_iface *hard_iface)
-{
-	int new_len;
-
-	new_len = BATMAN_OGM_HLEN +
-		  tt_len((uint8_t)atomic_read(&bat_priv->tt_local_changes));
-
-	/* if we have too many changes for one packet don't send any
-	 * and wait for the tt table request which will be fragmented */
-	if (new_len > hard_iface->soft_iface->mtu)
-		new_len = BATMAN_OGM_HLEN;
-
-	realloc_packet_buffer(hard_iface, new_len);
-
-	bat_priv->tt_crc = tt_local_crc(bat_priv);
-
-	/* reset the sending counter */
-	atomic_set(&bat_priv->tt_ogm_append_cnt, TT_OGM_APPEND_MAX);
-
-	return tt_changes_fill_buffer(bat_priv,
-				      hard_iface->packet_buff + BATMAN_OGM_HLEN,
-				      hard_iface->packet_len - BATMAN_OGM_HLEN);
-}
-
-static int reset_packet_buffer(struct bat_priv *bat_priv,
-				struct hard_iface *hard_iface)
-{
-	realloc_packet_buffer(hard_iface, BATMAN_OGM_HLEN);
-	return 0;
-}
-
 void schedule_bat_ogm(struct hard_iface *hard_iface)
 {
 	struct bat_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
-	struct hard_iface *primary_if;
-	int tt_num_changes = -1;
 
 	if ((hard_iface->if_status == IF_NOT_IN_USE) ||
 	    (hard_iface->if_status == IF_TO_BE_REMOVED))
@@ -148,26 +95,7 @@ void schedule_bat_ogm(struct hard_iface *hard_iface)
 	if (hard_iface->if_status == IF_TO_BE_ACTIVATED)
 		hard_iface->if_status = IF_ACTIVE;
 
-	primary_if = primary_if_get_selected(bat_priv);
-
-	if (hard_iface == primary_if) {
-		/* if at least one change happened */
-		if (atomic_read(&bat_priv->tt_local_changes) > 0) {
-			tt_commit_changes(bat_priv);
-			tt_num_changes = prepare_packet_buffer(bat_priv,
-							       hard_iface);
-		}
-
-		/* if the changes have been sent often enough */
-		if (!atomic_dec_not_zero(&bat_priv->tt_ogm_append_cnt))
-			tt_num_changes = reset_packet_buffer(bat_priv,
-							     hard_iface);
-	}
-
-	if (primary_if)
-		hardif_free_ref(primary_if);
-
-	bat_priv->bat_algo_ops->bat_ogm_schedule(hard_iface, tt_num_changes);
+	bat_priv->bat_algo_ops->bat_ogm_schedule(hard_iface);
 }
 
 static void forw_packet_free(struct forw_packet *forw_packet)
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 88cfe2a..a1a51cc 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -275,14 +275,64 @@ out:
 		tt_global_entry_free_ref(tt_global_entry);
 }
 
-int tt_changes_fill_buffer(struct bat_priv *bat_priv,
-			   unsigned char *buff, int buff_len)
+static void tt_realloc_packet_buff(unsigned char **packet_buff,
+				   int *packet_buff_len, int min_packet_len,
+				   int new_packet_len)
+{
+	unsigned char *new_buff;
+
+	new_buff = kmalloc(new_packet_len, GFP_ATOMIC);
+
+	/* keep old buffer if kmalloc should fail */
+	if (new_buff) {
+		memcpy(new_buff, *packet_buff, min_packet_len);
+		kfree(*packet_buff);
+		*packet_buff = new_buff;
+		*packet_buff_len = new_packet_len;
+	}
+}
+
+static void tt_prepare_packet_buff(struct bat_priv *bat_priv,
+				   unsigned char **packet_buff,
+				   int *packet_buff_len, int min_packet_len)
+{
+	struct hard_iface *primary_if;
+	int req_len;
+
+	primary_if = primary_if_get_selected(bat_priv);
+
+	req_len = min_packet_len;
+	req_len += tt_len(atomic_read(&bat_priv->tt_local_changes));
+
+	/* if we have too many changes for one packet don't send any
+	 * and wait for the tt table request which will be fragmented
+	 */
+	if ((!primary_if) || (req_len > primary_if->soft_iface->mtu))
+		req_len = min_packet_len;
+
+	tt_realloc_packet_buff(packet_buff, packet_buff_len,
+			       min_packet_len, req_len);
+
+	if (primary_if)
+		hardif_free_ref(primary_if);
+}
+
+static int tt_changes_fill_buff(struct bat_priv *bat_priv,
+				unsigned char **packet_buff,
+				int *packet_buff_len, int min_packet_len)
 {
-	int count = 0, tot_changes = 0;
 	struct tt_change_node *entry, *safe;
+	int count = 0, tot_changes = 0, new_len;
+	unsigned char *tt_buff;
 
-	if (buff_len > 0)
-		tot_changes = buff_len / tt_len(1);
+	tt_prepare_packet_buff(bat_priv, packet_buff,
+			       packet_buff_len, min_packet_len);
+
+	new_len = *packet_buff_len - min_packet_len;
+	tt_buff = *packet_buff + min_packet_len;
+
+	if (new_len > 0)
+		tot_changes = new_len / tt_len(1);
 
 	spin_lock_bh(&bat_priv->tt_changes_list_lock);
 	atomic_set(&bat_priv->tt_local_changes, 0);
@@ -290,7 +340,7 @@ int tt_changes_fill_buffer(struct bat_priv *bat_priv,
 	list_for_each_entry_safe(entry, safe, &bat_priv->tt_changes_list,
 				 list) {
 		if (count < tot_changes) {
-			memcpy(buff + tt_len(count),
+			memcpy(tt_buff + tt_len(count),
 			       &entry->change, sizeof(struct tt_change));
 			count++;
 		}
@@ -304,17 +354,15 @@ int tt_changes_fill_buffer(struct bat_priv *bat_priv,
 	kfree(bat_priv->tt_buff);
 	bat_priv->tt_buff_len = 0;
 	bat_priv->tt_buff = NULL;
-	/* We check whether this new OGM has no changes due to size
-	 * problems */
-	if (buff_len > 0) {
-		/**
-		 * if kmalloc() fails we will reply with the full table
+	/* check whether this new OGM has no changes due to size problems */
+	if (new_len > 0) {
+		/* if kmalloc() fails we will reply with the full table
 		 * instead of providing the diff
 		 */
-		bat_priv->tt_buff = kmalloc(buff_len, GFP_ATOMIC);
+		bat_priv->tt_buff = kmalloc(new_len, GFP_ATOMIC);
 		if (bat_priv->tt_buff) {
-			memcpy(bat_priv->tt_buff, buff, buff_len);
-			bat_priv->tt_buff_len = buff_len;
+			memcpy(bat_priv->tt_buff, tt_buff, new_len);
+			bat_priv->tt_buff_len = new_len;
 		}
 	}
 	spin_unlock_bh(&bat_priv->tt_buff_lock);
@@ -1105,7 +1153,7 @@ static uint16_t tt_global_crc(struct bat_priv *bat_priv,
 }
 
 /* Calculates the checksum of the local table */
-uint16_t tt_local_crc(struct bat_priv *bat_priv)
+static uint16_t batadv_tt_local_crc(struct bat_priv *bat_priv)
 {
 	uint16_t total = 0, total_one;
 	struct hashtable_t *hash = bat_priv->tt_local_hash;
@@ -2025,20 +2073,56 @@ static void tt_local_purge_pending_clients(struct bat_priv *bat_priv)
 
 }
 
-void tt_commit_changes(struct bat_priv *bat_priv)
+static int tt_commit_changes(struct bat_priv *bat_priv,
+			     unsigned char **packet_buff, int *packet_buff_len,
+			     int packet_min_len)
 {
-	uint16_t changed_num = tt_set_flags(bat_priv->tt_local_hash,
-					    TT_CLIENT_NEW, false);
-	/* all the reset entries have now to be effectively counted as local
-	 * entries */
+	uint16_t changed_num = 0;
+
+	if (atomic_read(&bat_priv->tt_local_changes) < 1)
+		return -ENOENT;
+
+	changed_num = tt_set_flags(bat_priv->tt_local_hash,
+				   TT_CLIENT_NEW, false);
+
+	/* all reset entries have to be counted as local entries */
 	atomic_add(changed_num, &bat_priv->num_local_tt);
 	tt_local_purge_pending_clients(bat_priv);
+	bat_priv->tt_crc = batadv_tt_local_crc(bat_priv);
 
 	/* Increment the TTVN only once per OGM interval */
 	atomic_inc(&bat_priv->ttvn);
 	bat_dbg(DBG_TT, bat_priv, "Local changes committed, updating to ttvn %u\n",
 		(uint8_t)atomic_read(&bat_priv->ttvn));
 	bat_priv->tt_poss_change = false;
+
+	/* reset the sending counter */
+	atomic_set(&bat_priv->tt_ogm_append_cnt, TT_OGM_APPEND_MAX);
+
+	return tt_changes_fill_buff(bat_priv, packet_buff,
+				    packet_buff_len, packet_min_len);
+}
+
+/* when calling this function (hard_iface == primary_if) has to be true */
+int batadv_tt_append_diff(struct bat_priv *bat_priv,
+			  unsigned char **packet_buff, int *packet_buff_len,
+			  int packet_min_len)
+{
+	int tt_num_changes;
+
+	/* if at least one change happened */
+	tt_num_changes = tt_commit_changes(bat_priv, packet_buff,
+					   packet_buff_len, packet_min_len);
+
+	/* if the changes have been sent often enough */
+	if ((tt_num_changes < 0) &&
+	    (!atomic_dec_not_zero(&bat_priv->tt_ogm_append_cnt))) {
+		tt_realloc_packet_buff(packet_buff, packet_buff_len,
+				       packet_min_len, packet_min_len);
+		tt_num_changes = 0;
+	}
+
+	return tt_num_changes;
 }
 
 bool is_ap_isolated(struct bat_priv *bat_priv, uint8_t *src, uint8_t *dst)
diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/translation-table.h
index c43374d..d6ea30f 100644
--- a/net/batman-adv/translation-table.h
+++ b/net/batman-adv/translation-table.h
@@ -23,8 +23,6 @@
 #define _NET_BATMAN_ADV_TRANSLATION_TABLE_H_
 
 int tt_len(int changes_num);
-int tt_changes_fill_buffer(struct bat_priv *bat_priv,
-			   unsigned char *buff, int buff_len);
 int tt_init(struct bat_priv *bat_priv);
 void tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 		  int ifindex);
@@ -41,18 +39,19 @@ void tt_global_del_orig(struct bat_priv *bat_priv,
 			struct orig_node *orig_node, const char *message);
 struct orig_node *transtable_search(struct bat_priv *bat_priv,
 				    const uint8_t *src, const uint8_t *addr);
-uint16_t tt_local_crc(struct bat_priv *bat_priv);
 void tt_free(struct bat_priv *bat_priv);
 bool send_tt_response(struct bat_priv *bat_priv,
 		      struct tt_query_packet *tt_request);
 bool is_my_client(struct bat_priv *bat_priv, const uint8_t *addr);
 void handle_tt_response(struct bat_priv *bat_priv,
 			struct tt_query_packet *tt_response);
-void tt_commit_changes(struct bat_priv *bat_priv);
 bool is_ap_isolated(struct bat_priv *bat_priv, uint8_t *src, uint8_t *dst);
 void tt_update_orig(struct bat_priv *bat_priv, struct orig_node *orig_node,
 		    const unsigned char *tt_buff, uint8_t tt_num_changes,
 		    uint8_t ttvn, uint16_t tt_crc);
+int batadv_tt_append_diff(struct bat_priv *bat_priv,
+			  unsigned char **packet_buff, int *packet_buff_len,
+			  int packet_min_len);
 bool tt_global_client_is_roaming(struct bat_priv *bat_priv, uint8_t *addr);
 
 
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 6b569de..bf71d52 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -405,8 +405,7 @@ struct bat_algo_ops {
 	/* called when primary interface is selected / changed */
 	void (*bat_primary_iface_set)(struct hard_iface *hard_iface);
 	/* prepare a new outgoing OGM for the send queue */
-	void (*bat_ogm_schedule)(struct hard_iface *hard_iface,
-				 int tt_num_changes);
+	void (*bat_ogm_schedule)(struct hard_iface *hard_iface);
 	/* send scheduled OGM */
 	void (*bat_ogm_emit)(struct forw_packet *forw_packet);
 };
-- 
1.7.9.4
