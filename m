From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 15/18] batman-adv: lock around TT operations to avoid sending inconsistent data
Date: Sun, 20 Oct 2013 00:22:07 +0200
Message-ID: <1382221330-3769-16-git-send-email-antonio@meshcoding.com>
References: <1382221330-3769-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:41431 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753045Ab3JSWjp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Oct 2013 18:39:45 -0400
In-Reply-To: <1382221330-3769-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

A TT response may be prepared and sent while the local or
global translation table is getting updated.

The worst case is when one of the tables is accessed after
its content has been recently updated but the metadata
(TTVN/CRC) has not yet. In this case the reader will get a
table content which does not match the TTVN/CRC.
This will lead to an inconsistent state and so to a TT
recovery.

To avoid entering this situation, put a lock around those TT
operations recomputing the metadata and around the TT
Response creation (the latter is the only reader that
accesses the metadata together with the table).

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/main.c              |  1 +
 net/batman-adv/originator.c        |  1 +
 net/batman-adv/translation-table.c | 37 ++++++++++++++++++++++++++-----------
 net/batman-adv/types.h             | 13 +++++++++++++
 4 files changed, 41 insertions(+), 11 deletions(-)

diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 2207551..3159a14 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -110,6 +110,7 @@ int batadv_mesh_init(struct net_device *soft_iface)
 	spin_lock_init(&bat_priv->tt.req_list_lock);
 	spin_lock_init(&bat_priv->tt.roam_list_lock);
 	spin_lock_init(&bat_priv->tt.last_changeset_lock);
+	spin_lock_init(&bat_priv->tt.commit_lock);
 	spin_lock_init(&bat_priv->gw.list_lock);
 	spin_lock_init(&bat_priv->tvlv.container_list_lock);
 	spin_lock_init(&bat_priv->tvlv.handler_list_lock);
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index a591dc5..867778e 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -239,6 +239,7 @@ struct batadv_orig_node *batadv_get_orig_node(struct batadv_priv *bat_priv,
 	spin_lock_init(&orig_node->bcast_seqno_lock);
 	spin_lock_init(&orig_node->neigh_list_lock);
 	spin_lock_init(&orig_node->tt_buff_lock);
+	spin_lock_init(&orig_node->tt_lock);
 
 	batadv_nc_init_orig(orig_node);
 
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 58794c4..00f4faa 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -2019,6 +2019,7 @@ static bool batadv_send_my_tt_response(struct batadv_priv *bat_priv,
 		   req_src, tt_data->ttvn,
 		   (tt_data->flags & BATADV_TT_FULL_TABLE ? 'F' : '.'));
 
+	spin_lock_bh(&bat_priv->tt.commit_lock);
 
 	my_ttvn = (uint8_t)atomic_read(&bat_priv->tt.vn);
 	req_ttvn = tt_data->ttvn;
@@ -2091,6 +2092,7 @@ static bool batadv_send_my_tt_response(struct batadv_priv *bat_priv,
 unlock:
 	spin_unlock_bh(&bat_priv->tt.last_changeset_lock);
 out:
+	spin_unlock_bh(&bat_priv->tt.commit_lock);
 	if (orig_node)
 		batadv_orig_node_free_ref(orig_node);
 	if (primary_if)
@@ -2259,6 +2261,8 @@ static void batadv_handle_tt_response(struct batadv_priv *bat_priv,
 	if (!orig_node)
 		goto out;
 
+	spin_lock_bh(&orig_node->tt_lock);
+
 	if (tt_data->flags & BATADV_TT_FULL_TABLE) {
 		batadv_tt_fill_gtable(bat_priv, tt_data, resp_src, num_entries);
 	} else {
@@ -2267,18 +2271,20 @@ static void batadv_handle_tt_response(struct batadv_priv *bat_priv,
 					 tt_data->ttvn, tt_change);
 	}
 
-	/* Delete the tt_req_node from pending tt_requests list */
-	spin_lock_bh(&bat_priv->tt.req_list_lock);
-	list_for_each_entry_safe(node, safe, &bat_priv->tt.req_list, list) {
-		if (!batadv_compare_eth(node->addr, resp_src))
-			continue;
-		list_del(&node->list);
-		kfree(node);
-	}
-	spin_unlock_bh(&bat_priv->tt.req_list_lock);
-
 	/* Recalculate the CRC for this orig_node and store it */
 	orig_node->tt_crc = batadv_tt_global_crc(bat_priv, orig_node);
+
+	spin_unlock_bh(&orig_node->tt_lock);
+
+	/* Delete the tt_req_node from pending tt_requests list */
+	spin_lock_bh(&bat_priv->tt.req_list_lock);
+	list_for_each_entry_safe(node, safe, &bat_priv->tt.req_list, list) {
+		if (!batadv_compare_eth(node->addr, resp_src))
+			continue;
+		list_del(&node->list);
+		kfree(node);
+	}
+	spin_unlock_bh(&bat_priv->tt.req_list_lock);
 out:
 	if (orig_node)
 		batadv_orig_node_free_ref(orig_node);
@@ -2532,10 +2538,12 @@ void batadv_tt_local_commit_changes(struct batadv_priv *bat_priv)
 {
 	uint16_t changed_num = 0;
 
+	spin_lock_bh(&bat_priv->tt.commit_lock);
+
 	if (atomic_read(&bat_priv->tt.local_changes) < 1) {
 		if (!batadv_atomic_dec_not_zero(&bat_priv->tt.ogm_append_cnt))
 			batadv_tt_tvlv_container_update(bat_priv);
-		return;
+		goto out;
 	}
 
 	changed_num = batadv_tt_set_flags(bat_priv->tt.local_hash,
@@ -2555,6 +2563,9 @@ void batadv_tt_local_commit_changes(struct batadv_priv *bat_priv)
 	/* reset the sending counter */
 	atomic_set(&bat_priv->tt.ogm_append_cnt, BATADV_TT_OGM_APPEND_MAX);
 	batadv_tt_tvlv_container_update(bat_priv);
+
+out:
+	spin_unlock_bh(&bat_priv->tt.commit_lock);
 }
 
 bool batadv_is_ap_isolated(struct batadv_priv *bat_priv, uint8_t *src,
@@ -2631,6 +2642,8 @@ static void batadv_tt_update_orig(struct batadv_priv *bat_priv,
 			goto request_table;
 		}
 
+		spin_lock_bh(&orig_node->tt_lock);
+
 		tt_change = (struct batadv_tvlv_tt_change *)tt_buff;
 		batadv_tt_update_changes(bat_priv, orig_node, tt_num_changes,
 					 ttvn, tt_change);
@@ -2641,6 +2654,8 @@ static void batadv_tt_update_orig(struct batadv_priv *bat_priv,
 		 */
 		orig_node->tt_crc = batadv_tt_global_crc(bat_priv, orig_node);
 
+		spin_unlock_bh(&orig_node->tt_lock);
+
 		/* The ttvn alone is not enough to guarantee consistency
 		 * because a single value could represent different states
 		 * (due to the wrap around). Thus a node has to check whether
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 04a0da6..bd95d61 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -128,6 +128,10 @@ struct batadv_frag_list_entry {
  * @tt_size: number of global TT entries announced by the orig node
  * @tt_initialised: bool keeping track of whether or not this node have received
  *  any translation table information from the orig node yet
+ * @tt_lock: prevents from updating the table while reading it. Table update is
+ *  made up by two operations (data structure update and metdata -CRC/TTVN-
+ *  recalculation) and they have to be executed atomically in order to avoid
+ *  another thread to read the table/metadata between those.
  * @last_real_seqno: last and best known sequence number
  * @last_ttl: ttl of last received packet
  * @bcast_bits: bitfield containing the info which payload broadcast originated
@@ -171,6 +175,8 @@ struct batadv_orig_node {
 	spinlock_t tt_buff_lock; /* protects tt_buff & tt_buff_len */
 	atomic_t tt_size;
 	bool tt_initialised;
+	/* prevents from changing the table while reading it */
+	spinlock_t tt_lock;
 	uint32_t last_real_seqno;
 	uint8_t last_ttl;
 	DECLARE_BITMAP(bcast_bits, BATADV_TQ_LOCAL_WINDOW_SIZE);
@@ -388,6 +394,11 @@ enum batadv_counters {
  * @last_changeset: last tt changeset this host has generated
  * @last_changeset_len: length of last tt changeset this host has generated
  * @last_changeset_lock: lock protecting last_changeset & last_changeset_len
+ * @commit_lock: prevents from executing a local TT commit while reading the
+ *  local table. The local TT commit is made up by two operations (data
+ *  structure update and metdata -CRC/TTVN- recalculation) and they have to be
+ *  executed atomically in order to avoid another thread to read the
+ *  table/metadata between those.
  * @work: work queue callback item for translation table purging
  */
 struct batadv_priv_tt {
@@ -408,6 +419,8 @@ struct batadv_priv_tt {
 	int16_t last_changeset_len;
 	/* protects last_changeset & last_changeset_len */
 	spinlock_t last_changeset_lock;
+	/* prevents from executing a commit while reading the table */
+	spinlock_t commit_lock;
 	struct delayed_work work;
 };
 
-- 
1.8.4
