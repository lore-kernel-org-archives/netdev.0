From: Marek Lindner <lindner_marek@yahoo.de>
Subject: [PATCH 1/8] batman-adv: convert time_after instances to has_timed_out
Date: Tue, 28 Feb 2012 19:32:21 +0800
Message-ID: <1330428748-23137-2-git-send-email-lindner_marek@yahoo.de>
References: <1330428748-23137-1-git-send-email-lindner_marek@yahoo.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm18.bullet.mail.ukl.yahoo.com ([217.146.183.192]:22863 "HELO
	nm18.bullet.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757031Ab2B1Ldj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2012 06:33:39 -0500
In-Reply-To: <1330428748-23137-1-git-send-email-lindner_marek@yahoo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To increase readability the has_timed_out() functions has been introduced.
This patch converts existing time_after() calls to use this wrapper
function (if applicable).
This patch also converts all timeouts to miliseconds to be consistent.

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
---
 net/batman-adv/gateway_client.c    |    2 +-
 net/batman-adv/main.h              |   13 +++++++------
 net/batman-adv/originator.c        |   11 ++++-------
 net/batman-adv/routing.c           |    3 +--
 net/batman-adv/soft-interface.c    |    4 ++--
 net/batman-adv/translation-table.c |   15 ++++++---------
 net/batman-adv/vis.c               |    3 +--
 net/batman-adv/vis.h               |    3 ++-
 8 files changed, 24 insertions(+), 30 deletions(-)

diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 24403a7..df5631e 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -396,7 +396,7 @@ void gw_node_purge(struct bat_priv *bat_priv)
 {
 	struct gw_node *gw_node, *curr_gw;
 	struct hlist_node *node, *node_tmp;
-	unsigned long timeout = 2 * PURGE_TIMEOUT * HZ;
+	unsigned long timeout = msecs_to_jiffies(2 * PURGE_TIMEOUT);
 	int do_deselect = 0;
 
 	curr_gw = gw_get_selected_gw_node(bat_priv);
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 586afaf..ecfed88 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -41,13 +41,14 @@
 
 /* purge originators after time in seconds if no valid packet comes in
  * -> TODO: check influence on TQ_LOCAL_WINDOW_SIZE */
-#define PURGE_TIMEOUT 200
-#define TT_LOCAL_TIMEOUT 3600 /* in seconds */
-#define TT_CLIENT_ROAM_TIMEOUT 600
+#define PURGE_TIMEOUT 200000 /* 200 seconds */
+#define TT_LOCAL_TIMEOUT 3600000 /* in miliseconds */
+#define TT_CLIENT_ROAM_TIMEOUT 600000 /* in miliseconds */
 /* sliding packet range of received originator messages in sequence numbers
  * (should be a multiple of our word size) */
 #define TQ_LOCAL_WINDOW_SIZE 64
-#define TT_REQUEST_TIMEOUT 3 /* seconds we have to keep pending tt_req */
+#define TT_REQUEST_TIMEOUT 3000 /* miliseconds we have to keep
+				 * pending tt_req */
 
 #define TQ_GLOBAL_WINDOW_SIZE 5
 #define TQ_LOCAL_BIDRECT_SEND_MINIMUM 1
@@ -56,8 +57,8 @@
 
 #define TT_OGM_APPEND_MAX 3 /* number of OGMs sent with the last tt diff */
 
-#define ROAMING_MAX_TIME 20 /* Time in which a client can roam at most
-			     * ROAMING_MAX_COUNT times */
+#define ROAMING_MAX_TIME 20000 /* Time in which a client can roam at most
+				* ROAMING_MAX_COUNT times in miliseconds*/
 #define ROAMING_MAX_COUNT 5
 
 #define NO_FLAGS 0
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 847ff7e..1161f27 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -282,8 +282,7 @@ static bool purge_orig_neighbors(struct bat_priv *bat_priv,
 	hlist_for_each_entry_safe(neigh_node, node, node_tmp,
 				  &orig_node->neigh_list, list) {
 
-		if ((time_after(jiffies,
-			neigh_node->last_valid + PURGE_TIMEOUT * HZ)) ||
+		if ((has_timed_out(neigh_node->last_valid, PURGE_TIMEOUT)) ||
 		    (neigh_node->if_incoming->if_status == IF_INACTIVE) ||
 		    (neigh_node->if_incoming->if_status == IF_NOT_IN_USE) ||
 		    (neigh_node->if_incoming->if_status == IF_TO_BE_REMOVED)) {
@@ -327,9 +326,7 @@ static bool purge_orig_node(struct bat_priv *bat_priv,
 {
 	struct neigh_node *best_neigh_node;
 
-	if (time_after(jiffies,
-		orig_node->last_valid + 2 * PURGE_TIMEOUT * HZ)) {
-
+	if (has_timed_out(orig_node->last_valid, 2 * PURGE_TIMEOUT)) {
 		bat_dbg(DBG_BATMAN, bat_priv,
 			"Originator timeout: originator %pM, last_valid %lu\n",
 			orig_node->orig, (orig_node->last_valid / HZ));
@@ -372,8 +369,8 @@ static void _purge_orig(struct bat_priv *bat_priv)
 				continue;
 			}
 
-			if (time_after(jiffies, orig_node->last_frag_packet +
-						msecs_to_jiffies(FRAG_TIMEOUT)))
+			if (has_timed_out(orig_node->last_frag_packet,
+					  FRAG_TIMEOUT))
 				frag_list_free(&orig_node->frag_list);
 		}
 		spin_unlock_bh(list_lock);
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index b72d7f3..c1e45c0 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -231,8 +231,7 @@ int window_protected(struct bat_priv *bat_priv, int32_t seq_num_diff,
 {
 	if ((seq_num_diff <= -TQ_LOCAL_WINDOW_SIZE)
 		|| (seq_num_diff >= EXPECTED_SEQNO_RANGE)) {
-		if (time_after(jiffies, *last_reset +
-			msecs_to_jiffies(RESET_PROTECTION_MS))) {
+		if (has_timed_out(*last_reset, RESET_PROTECTION_MS)) {
 
 			*last_reset = jiffies;
 			bat_dbg(DBG_BATMAN, bat_priv,
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index b5aecd5..c41dac3 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -396,8 +396,8 @@ void softif_neigh_purge(struct bat_priv *bat_priv)
 		hlist_for_each_entry_safe(softif_neigh, node_tmp, node_tmp2,
 					  &softif_neigh_vid->softif_neigh_list,
 					  list) {
-			if ((!time_after(jiffies, softif_neigh->last_seen +
-				msecs_to_jiffies(SOFTIF_NEIGH_TIMEOUT))) &&
+			if ((!has_timed_out(softif_neigh->last_seen,
+					   SOFTIF_NEIGH_TIMEOUT)) &&
 			    (atomic_read(&bat_priv->mesh_state) == MESH_ACTIVE))
 				continue;
 
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index a84e804..ff9a1b3 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -413,7 +413,7 @@ static void tt_local_purge(struct bat_priv *bat_priv)
 				continue;
 
 			if (!has_timed_out(tt_local_entry->last_seen,
-					   TT_LOCAL_TIMEOUT * 1000))
+					   TT_LOCAL_TIMEOUT))
 				continue;
 
 			tt_local_set_pending(bat_priv, tt_local_entry,
@@ -751,7 +751,7 @@ static void tt_global_roam_purge(struct bat_priv *bat_priv)
 			if (!(tt_global_entry->common.flags & TT_CLIENT_ROAM))
 				continue;
 			if (!has_timed_out(tt_global_entry->roam_at,
-					   TT_CLIENT_ROAM_TIMEOUT * 1000))
+					   TT_CLIENT_ROAM_TIMEOUT))
 				continue;
 
 			bat_dbg(DBG_TT, bat_priv, "Deleting global "
@@ -970,8 +970,7 @@ static void tt_req_purge(struct bat_priv *bat_priv)
 
 	spin_lock_bh(&bat_priv->tt_req_list_lock);
 	list_for_each_entry_safe(node, safe, &bat_priv->tt_req_list, list) {
-		if (has_timed_out(node->issued_at,
-				  TT_REQUEST_TIMEOUT * 1000)) {
+		if (has_timed_out(node->issued_at, TT_REQUEST_TIMEOUT)) {
 			list_del(&node->list);
 			kfree(node);
 		}
@@ -990,7 +989,7 @@ static struct tt_req_node *new_tt_req_node(struct bat_priv *bat_priv,
 	list_for_each_entry(tt_req_node_tmp, &bat_priv->tt_req_list, list) {
 		if (compare_eth(tt_req_node_tmp, orig_node) &&
 		    !has_timed_out(tt_req_node_tmp->issued_at,
-				   TT_REQUEST_TIMEOUT * 1000))
+				   TT_REQUEST_TIMEOUT))
 			goto unlock;
 	}
 
@@ -1583,8 +1582,7 @@ static void tt_roam_purge(struct bat_priv *bat_priv)
 
 	spin_lock_bh(&bat_priv->tt_roam_list_lock);
 	list_for_each_entry_safe(node, safe, &bat_priv->tt_roam_list, list) {
-		if (!has_timed_out(node->first_time,
-				   ROAMING_MAX_TIME * 1000))
+		if (!has_timed_out(node->first_time, ROAMING_MAX_TIME))
 			continue;
 
 		list_del(&node->list);
@@ -1611,8 +1609,7 @@ static bool tt_check_roam_count(struct bat_priv *bat_priv,
 		if (!compare_eth(tt_roam_node->addr, client))
 			continue;
 
-		if (has_timed_out(tt_roam_node->first_time,
-				  ROAMING_MAX_TIME * 1000))
+		if (has_timed_out(tt_roam_node->first_time, ROAMING_MAX_TIME))
 			continue;
 
 		if (!atomic_dec_not_zero(&tt_roam_node->counter))
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index ac7e661..4f4b2a0 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -714,8 +714,7 @@ static void purge_vis_packets(struct bat_priv *bat_priv)
 			if (info == bat_priv->my_vis_info)
 				continue;
 
-			if (time_after(jiffies,
-				       info->first_seen + VIS_TIMEOUT * HZ)) {
+			if (has_timed_out(info->first_seen, VIS_TIMEOUT)) {
 				hlist_del(node);
 				send_list_del(info);
 				kref_put(&info->refcount, free_info);
diff --git a/net/batman-adv/vis.h b/net/batman-adv/vis.h
index 31b820d..851bc4f 100644
--- a/net/batman-adv/vis.h
+++ b/net/batman-adv/vis.h
@@ -22,7 +22,8 @@
 #ifndef _NET_BATMAN_ADV_VIS_H_
 #define _NET_BATMAN_ADV_VIS_H_
 
-#define VIS_TIMEOUT		200	/* timeout of vis packets in seconds */
+#define VIS_TIMEOUT		200000	/* timeout of vis packets
+					 * in miliseconds */
 
 int vis_seq_print_text(struct seq_file *seq, void *offset);
 void receive_server_sync_packet(struct bat_priv *bat_priv,
-- 
1.7.9
