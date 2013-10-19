From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 07/18] batman-adv: print the VID together with the TT entries
Date: Sun, 20 Oct 2013 00:21:59 +0200
Message-ID: <1382221330-3769-8-git-send-email-antonio@meshcoding.com>
References: <1382221330-3769-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:41254 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753801Ab3JSWXD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Oct 2013 18:23:03 -0400
In-Reply-To: <1382221330-3769-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/main.h              |  2 +
 net/batman-adv/translation-table.c | 82 +++++++++++++++++++++++---------------
 2 files changed, 52 insertions(+), 32 deletions(-)

diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 2774d7f..d7dfafe 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -167,6 +167,8 @@ enum batadv_uev_type {
 #include <net/rtnetlink.h>
 #include <linux/jiffies.h>
 #include <linux/seq_file.h>
+#include <linux/if_vlan.h>
+
 #include "types.h"
 
 #define BATADV_PRINT_VID(vid) (vid & BATADV_VLAN_HAS_TAG ? \
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index c8fc303..9bf928c 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -328,8 +328,9 @@ static void batadv_tt_global_free(struct batadv_priv *bat_priv,
 				  const char *message)
 {
 	batadv_dbg(BATADV_DBG_TT, bat_priv,
-		   "Deleting global tt entry %pM: %s\n",
-		   tt_global->common.addr, message);
+		   "Deleting global tt entry %pM (vid: %d): %s\n",
+		   tt_global->common.addr,
+		   BATADV_PRINT_VID(tt_global->common.vid), message);
 
 	batadv_hash_remove(bat_priv->tt.global_hash, batadv_compare_tt,
 			   batadv_choose_tt, &tt_global->common);
@@ -363,7 +364,8 @@ void batadv_tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 		tt_local->last_seen = jiffies;
 		if (tt_local->common.flags & BATADV_TT_CLIENT_PENDING) {
 			batadv_dbg(BATADV_DBG_TT, bat_priv,
-				   "Re-adding pending client %pM\n", addr);
+				   "Re-adding pending client %pM (vid: %d)\n",
+				   addr, BATADV_PRINT_VID(vid));
 			/* whatever the reason why the PENDING flag was set,
 			 * this is a client which was enqueued to be removed in
 			 * this orig_interval. Since it popped up again, the
@@ -375,8 +377,8 @@ void batadv_tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 
 		if (tt_local->common.flags & BATADV_TT_CLIENT_ROAM) {
 			batadv_dbg(BATADV_DBG_TT, bat_priv,
-				   "Roaming client %pM came back to its original location\n",
-				   addr);
+				   "Roaming client %pM (vid: %d) came back to its original location\n",
+				   addr, BATADV_PRINT_VID(vid));
 			/* the ROAM flag is set because this client roamed away
 			 * and the node got a roaming_advertisement message. Now
 			 * that the client popped up again at its original
@@ -393,7 +395,8 @@ void batadv_tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 		goto out;
 
 	batadv_dbg(BATADV_DBG_TT, bat_priv,
-		   "Creating new local tt entry: %pM (ttvn: %d)\n", addr,
+		   "Creating new local tt entry: %pM (vid: %d, ttvn: %d)\n",
+		   addr, BATADV_PRINT_VID(vid),
 		   (uint8_t)atomic_read(&bat_priv->tt.vn));
 
 	memcpy(tt_local->common.addr, addr, ETH_ALEN);
@@ -562,8 +565,8 @@ int batadv_tt_local_seq_print_text(struct seq_file *seq, void *offset)
 		   "Locally retrieved addresses (from %s) announced via TT (TTVN: %u CRC: %#.8x):\n",
 		   net_dev->name, (uint8_t)atomic_read(&bat_priv->tt.vn),
 		   bat_priv->tt.local_crc);
-	seq_printf(seq, "       %-13s %-7s %-10s\n", "Client", "Flags",
-		   "Last seen");
+	seq_printf(seq, "       %-13s  %s %-7s %-10s\n", "Client", "VID",
+		   "Flags", "Last seen");
 
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
@@ -581,8 +584,9 @@ int batadv_tt_local_seq_print_text(struct seq_file *seq, void *offset)
 
 			no_purge = tt_common_entry->flags & np_flag;
 
-			seq_printf(seq, " * %pM [%c%c%c%c%c] %3u.%03u\n",
+			seq_printf(seq, " * %pM %4i [%c%c%c%c%c] %3u.%03u\n",
 				   tt_common_entry->addr,
+				   BATADV_PRINT_VID(tt_common_entry->vid),
 				   (tt_common_entry->flags &
 				    BATADV_TT_CLIENT_ROAM ? 'R' : '.'),
 				   no_purge ? 'P' : '.',
@@ -617,8 +621,9 @@ batadv_tt_local_set_pending(struct batadv_priv *bat_priv,
 	tt_local_entry->common.flags |= BATADV_TT_CLIENT_PENDING;
 
 	batadv_dbg(BATADV_DBG_TT, bat_priv,
-		   "Local tt entry (%pM) pending to be removed: %s\n",
-		   tt_local_entry->common.addr, message);
+		   "Local tt entry (%pM, vid: %d) pending to be removed: %s\n",
+		   tt_local_entry->common.addr,
+		   BATADV_PRINT_VID(tt_local_entry->common.vid), message);
 }
 
 /**
@@ -996,8 +1001,9 @@ add_orig_entry:
 	batadv_tt_global_orig_entry_add(tt_global_entry, orig_node, ttvn);
 
 	batadv_dbg(BATADV_DBG_TT, bat_priv,
-		   "Creating new global tt entry: %pM (via %pM)\n",
-		   common->addr, orig_node->orig);
+		   "Creating new global tt entry: %pM (vid: %d, via %pM)\n",
+		   common->addr, BATADV_PRINT_VID(common->vid),
+		   orig_node->orig);
 	ret = true;
 
 out_remove:
@@ -1077,8 +1083,9 @@ batadv_tt_global_print_entry(struct batadv_tt_global_entry *tt_global_entry,
 	if (best_entry) {
 		last_ttvn = atomic_read(&best_entry->orig_node->last_ttvn);
 		seq_printf(seq,
-			   " %c %pM  (%3u) via %pM     (%3u)   (%#.8x) [%c%c%c]\n",
+			   " %c %pM %4i   (%3u) via %pM     (%3u)   (%#.8x) [%c%c%c]\n",
 			   '*', tt_global_entry->common.addr,
+			   BATADV_PRINT_VID(tt_global_entry->common.vid),
 			   best_entry->ttvn, best_entry->orig_node->orig,
 			   last_ttvn, best_entry->orig_node->tt_crc,
 			   (flags & BATADV_TT_CLIENT_ROAM ? 'R' : '.'),
@@ -1093,8 +1100,10 @@ batadv_tt_global_print_entry(struct batadv_tt_global_entry *tt_global_entry,
 			continue;
 
 		last_ttvn = atomic_read(&orig_entry->orig_node->last_ttvn);
-		seq_printf(seq,	" %c %pM  (%3u) via %pM     (%3u)   [%c%c%c]\n",
+		seq_printf(seq,
+			   " %c %pM %4d   (%3u) via %pM     (%3u)   [%c%c%c]\n",
 			   '+', tt_global_entry->common.addr,
+			   BATADV_PRINT_VID(tt_global_entry->common.vid),
 			   orig_entry->ttvn, orig_entry->orig_node->orig,
 			   last_ttvn,
 			   (flags & BATADV_TT_CLIENT_ROAM ? 'R' : '.'),
@@ -1121,9 +1130,9 @@ int batadv_tt_global_seq_print_text(struct seq_file *seq, void *offset)
 	seq_printf(seq,
 		   "Globally announced TT entries received via the mesh %s\n",
 		   net_dev->name);
-	seq_printf(seq, "       %-13s %s       %-15s %s (%-10s) %s\n",
-		   "Client", "(TTVN)", "Originator", "(Curr TTVN)", "CRC",
-		   "Flags");
+	seq_printf(seq, "       %-13s  %s  %s       %-15s %s (%-10s) %s\n",
+		   "Client", "VID", "(TTVN)", "Originator", "(Curr TTVN)",
+		   "CRC", "Flags");
 
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
@@ -1170,15 +1179,18 @@ batadv_tt_global_del_orig_entry(struct batadv_priv *bat_priv,
 	struct hlist_head *head;
 	struct hlist_node *safe;
 	struct batadv_tt_orig_list_entry *orig_entry;
+	unsigned short vid;
 
 	spin_lock_bh(&tt_global_entry->list_lock);
 	head = &tt_global_entry->orig_list;
 	hlist_for_each_entry_safe(orig_entry, safe, head, list) {
 		if (orig_entry->orig_node == orig_node) {
+			vid = tt_global_entry->common.vid;
 			batadv_dbg(BATADV_DBG_TT, bat_priv,
-				   "Deleting %pM from global tt entry %pM: %s\n",
+				   "Deleting %pM from global tt entry %pM (vid: %d): %s\n",
 				   orig_node->orig,
-				   tt_global_entry->common.addr, message);
+				   tt_global_entry->common.addr,
+				   BATADV_PRINT_VID(vid), message);
 			hlist_del_rcu(&orig_entry->list);
 			batadv_tt_orig_list_entry_free_ref(orig_entry);
 		}
@@ -1303,6 +1315,7 @@ void batadv_tt_global_del_orig(struct batadv_priv *bat_priv,
 	struct hlist_node *safe;
 	struct hlist_head *head;
 	spinlock_t *list_lock; /* protects write access to the hash lists */
+	unsigned short vid;
 
 	if (!hash)
 		return;
@@ -1322,9 +1335,11 @@ void batadv_tt_global_del_orig(struct batadv_priv *bat_priv,
 							orig_node, message);
 
 			if (hlist_empty(&tt_global->orig_list)) {
+				vid = tt_global->common.vid;
 				batadv_dbg(BATADV_DBG_TT, bat_priv,
-					   "Deleting global tt entry %pM: %s\n",
-					   tt_global->common.addr, message);
+					   "Deleting global tt entry %pM (vid: %d): %s\n",
+					   tt_global->common.addr,
+					   BATADV_PRINT_VID(vid), message);
 				hlist_del_rcu(&tt_common_entry->hash_entry);
 				batadv_tt_global_entry_free_ref(tt_global);
 			}
@@ -1382,8 +1397,10 @@ static void batadv_tt_global_purge(struct batadv_priv *bat_priv)
 				continue;
 
 			batadv_dbg(BATADV_DBG_TT, bat_priv,
-				   "Deleting global tt entry (%pM): %s\n",
-				   tt_global->common.addr, msg);
+				   "Deleting global tt entry %pM (vid: %d): %s\n",
+				   tt_global->common.addr,
+				   BATADV_PRINT_VID(tt_global->common.vid),
+				   msg);
 
 			hlist_del_rcu(&tt_common->hash_entry);
 
@@ -2366,8 +2383,8 @@ static void batadv_send_roam_adv(struct batadv_priv *bat_priv, uint8_t *client,
 		goto out;
 
 	batadv_dbg(BATADV_DBG_TT, bat_priv,
-		   "Sending ROAMING_ADV to %pM (client %pM)\n",
-		   orig_node->orig, client);
+		   "Sending ROAMING_ADV to %pM (client %pM, vid: %d)\n",
+		   orig_node->orig, client, BATADV_PRINT_VID(vid));
 
 	batadv_inc_counter(bat_priv, BATADV_CNT_TT_ROAM_ADV_TX);
 
@@ -2480,8 +2497,9 @@ static void batadv_tt_local_purge_pending_clients(struct batadv_priv *bat_priv)
 				continue;
 
 			batadv_dbg(BATADV_DBG_TT, bat_priv,
-				   "Deleting local tt entry (%pM): pending\n",
-				   tt_common->addr);
+				   "Deleting local tt entry (%pM, vid: %d): pending\n",
+				   tt_common->addr,
+				   BATADV_PRINT_VID(tt_common->vid));
 
 			atomic_dec(&bat_priv->tt.local_entry_num);
 			hlist_del_rcu(&tt_common->hash_entry);
@@ -2694,7 +2712,7 @@ out:
 bool batadv_tt_add_temporary_global_entry(struct batadv_priv *bat_priv,
 					  struct batadv_orig_node *orig_node,
 					  const unsigned char *addr,
-					  unsigned short vlan)
+					  unsigned short vid)
 {
 	bool ret = false;
 
@@ -2705,14 +2723,14 @@ bool batadv_tt_add_temporary_global_entry(struct batadv_priv *bat_priv,
 	if (batadv_bla_is_backbone_gw_orig(bat_priv, orig_node->orig))
 		goto out;
 
-	if (!batadv_tt_global_add(bat_priv, orig_node, addr, vlan,
+	if (!batadv_tt_global_add(bat_priv, orig_node, addr, vid,
 				  BATADV_TT_CLIENT_TEMP,
 				  atomic_read(&orig_node->last_ttvn)))
 		goto out;
 
 	batadv_dbg(BATADV_DBG_TT, bat_priv,
-		   "Added temporary global client (addr: %pM orig: %pM)\n",
-		   addr, orig_node->orig);
+		   "Added temporary global client (addr: %pM, vid: %d, orig: %pM)\n",
+		   addr, BATADV_PRINT_VID(vid), orig_node->orig);
 	ret = true;
 out:
 	return ret;
-- 
1.8.4
