From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 07/18] batman-adv: beautify tt_global_add() argument list
Date: Thu, 28 Jun 2012 11:34:16 +0200
Message-ID: <1340876067-28333-8-git-send-email-ordex@autistici.org>
References: <1340876067-28333-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Sven Eckelmann <sven@narfation.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:30195 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932761Ab2F1Jeb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 05:34:31 -0400
In-Reply-To: <1340876067-28333-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of adding a new bool argument each time it is needed, it is better (and
simpler) to pass an 8bit flag argument which contains all the needed flags

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
---
 net/batman-adv/routing.c           |    4 ++--
 net/batman-adv/translation-table.c |   24 +++++++++---------------
 net/batman-adv/translation-table.h |    4 ++--
 3 files changed, 13 insertions(+), 19 deletions(-)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 1b8f677..864692a 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -699,8 +699,8 @@ int batadv_recv_roam_adv(struct sk_buff *skb, struct hard_iface *recv_if)
 		   roam_adv_packet->src, roam_adv_packet->client);
 
 	batadv_tt_global_add(bat_priv, orig_node, roam_adv_packet->client,
-			     atomic_read(&orig_node->last_ttvn) + 1, true,
-			     false);
+			     TT_CLIENT_ROAM,
+			     atomic_read(&orig_node->last_ttvn) + 1);
 
 	/* Roaming phase starts: I have new information but the ttvn has not
 	 * been incremented yet. This flag will make me check all the incoming
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index d82766b..3ca2e48 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -657,8 +657,8 @@ batadv_tt_global_add_orig_entry(struct tt_global_entry *tt_global_entry,
 
 /* caller must hold orig_node refcount */
 int batadv_tt_global_add(struct bat_priv *bat_priv, struct orig_node *orig_node,
-			 const unsigned char *tt_addr, uint8_t ttvn,
-			 bool roaming, bool wifi)
+			 const unsigned char *tt_addr, uint8_t flags,
+			 uint8_t ttvn)
 {
 	struct tt_global_entry *tt_global_entry = NULL;
 	int ret = 0;
@@ -668,15 +668,14 @@ int batadv_tt_global_add(struct bat_priv *bat_priv, struct orig_node *orig_node,
 	tt_global_entry = batadv_tt_global_hash_find(bat_priv, tt_addr);
 
 	if (!tt_global_entry) {
-		tt_global_entry = kzalloc(sizeof(*tt_global_entry),
-					  GFP_ATOMIC);
+		tt_global_entry = kzalloc(sizeof(*tt_global_entry), GFP_ATOMIC);
 		if (!tt_global_entry)
 			goto out;
 
 		common = &tt_global_entry->common;
 		memcpy(common->addr, tt_addr, ETH_ALEN);
 
-		common->flags = NO_FLAGS;
+		common->flags = flags;
 		tt_global_entry->roam_at = 0;
 		atomic_set(&common->refcount, 2);
 
@@ -718,9 +717,6 @@ int batadv_tt_global_add(struct bat_priv *bat_priv, struct orig_node *orig_node,
 							orig_node, ttvn);
 	}
 
-	if (wifi)
-		tt_global_entry->common.flags |= TT_CLIENT_WIFI;
-
 	batadv_dbg(DBG_TT, bat_priv,
 		   "Creating new global tt entry: %pM (via %pM)\n",
 		   tt_global_entry->common.addr, orig_node->orig);
@@ -728,7 +724,7 @@ int batadv_tt_global_add(struct bat_priv *bat_priv, struct orig_node *orig_node,
 out_remove:
 	/* remove address from local hash if present */
 	batadv_tt_local_remove(bat_priv, tt_global_entry->common.addr,
-			       "global tt received", roaming);
+			       "global tt received", flags & TT_CLIENT_ROAM);
 	ret = 1;
 out:
 	if (tt_global_entry)
@@ -1755,7 +1751,6 @@ static void _batadv_tt_update_changes(struct bat_priv *bat_priv,
 				      uint16_t tt_num_changes, uint8_t ttvn)
 {
 	int i;
-	int is_wifi;
 	int roams;
 
 	for (i = 0; i < tt_num_changes; i++) {
@@ -1763,13 +1758,12 @@ static void _batadv_tt_update_changes(struct bat_priv *bat_priv,
 			roams = (tt_change + i)->flags & TT_CLIENT_ROAM;
 			batadv_tt_global_del(bat_priv, orig_node,
 					     (tt_change + i)->addr,
-					      "tt removed by changes",
-					      roams);
+					     "tt removed by changes",
+					     roams);
 		} else {
-			is_wifi = (tt_change + i)->flags & TT_CLIENT_WIFI;
 			if (!batadv_tt_global_add(bat_priv, orig_node,
-						  (tt_change + i)->addr, ttvn,
-						  false, is_wifi))
+						  (tt_change + i)->addr,
+						  (tt_change + i)->flags, ttvn))
 				/* In case of problem while storing a
 				 * global_entry, we stop the updating
 				 * procedure without committing the
diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/translation-table.h
index 7edc9df..46b60bd 100644
--- a/net/batman-adv/translation-table.h
+++ b/net/batman-adv/translation-table.h
@@ -32,8 +32,8 @@ void batadv_tt_global_add_orig(struct bat_priv *bat_priv,
 			       struct orig_node *orig_node,
 			       const unsigned char *tt_buff, int tt_buff_len);
 int batadv_tt_global_add(struct bat_priv *bat_priv, struct orig_node *orig_node,
-			 const unsigned char *addr, uint8_t ttvn, bool roaming,
-			 bool wifi);
+			 const unsigned char *addr, uint8_t flags,
+			 uint8_t ttvn);
 int batadv_tt_global_seq_print_text(struct seq_file *seq, void *offset);
 void batadv_tt_global_del_orig(struct bat_priv *bat_priv,
 			       struct orig_node *orig_node,
-- 
1.7.9.4
