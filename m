From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 15/16] batman-adv: pass the WIFI flag from the local to global entry
Date: Sun, 28 Oct 2012 12:17:16 +0100
Message-ID: <1351423037-5292-16-git-send-email-ordex@autistici.org>
References: <1351423037-5292-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:56424 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752168Ab2J1LSy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Oct 2012 07:18:54 -0400
In-Reply-To: <1351423037-5292-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

in case of client roaming a new global entry is added while a corresponding
local one is still present. In this case the node can safely pass the WIFI flag
from the local to the global entry.

This change is required to let the AP-isolation correctly working in case of
roaming: if a generic WIFI client C roams from node A to B, A adds a global
entry for C without adding any WIFI flag. The latter will be set only later,
once A has received C's advertisement from B. In this time period the
AP-Isolation (if enabled) would not correctly work since C is not marked as
WIFI, so allowing it to communicate with other WIFI clients.

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/translation-table.c | 31 +++++++++++++++++++++++++------
 net/batman-adv/translation-table.h |  6 +++---
 2 files changed, 28 insertions(+), 9 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index c61209f..a570d95 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -489,24 +489,39 @@ batadv_tt_local_set_pending(struct batadv_priv *bat_priv,
 		   tt_local_entry->common.addr, message);
 }
 
-void batadv_tt_local_remove(struct batadv_priv *bat_priv, const uint8_t *addr,
-			    const char *message, bool roaming)
+/**
+ * batadv_tt_local_remove - logically remove an entry from the local table
+ * @bat_priv: the bat priv with all the soft interface information
+ * @addr: the MAC address of the client to remove
+ * @message: message to append to the log on deletion
+ * @roaming: true if the deletion is due to a roaming event
+ *
+ * Returns the flags assigned to the local entry before being deleted
+ */
+uint16_t batadv_tt_local_remove(struct batadv_priv *bat_priv,
+				const uint8_t *addr, const char *message,
+				bool roaming)
 {
 	struct batadv_tt_local_entry *tt_local_entry = NULL;
-	uint16_t flags;
+	uint16_t flags, curr_flags = BATADV_NO_FLAGS;
 
 	tt_local_entry = batadv_tt_local_hash_find(bat_priv, addr);
 	if (!tt_local_entry)
 		goto out;
 
+	curr_flags = tt_local_entry->common.flags;
+
 	flags = BATADV_TT_CLIENT_DEL;
 	if (roaming)
 		flags |= BATADV_TT_CLIENT_ROAM;
 
 	batadv_tt_local_set_pending(bat_priv, tt_local_entry, flags, message);
+
 out:
 	if (tt_local_entry)
 		batadv_tt_local_entry_free_ref(tt_local_entry);
+
+	return curr_flags;
 }
 
 static void batadv_tt_local_purge_list(struct batadv_priv *bat_priv,
@@ -713,6 +728,7 @@ int batadv_tt_global_add(struct batadv_priv *bat_priv,
 	int ret = 0;
 	int hash_added;
 	struct batadv_tt_common_entry *common;
+	uint16_t local_flags;
 
 	tt_global_entry = batadv_tt_global_hash_find(bat_priv, tt_addr);
 
@@ -785,10 +801,13 @@ int batadv_tt_global_add(struct batadv_priv *bat_priv,
 	ret = 1;
 
 out_remove:
+
 	/* remove address from local hash if present */
-	batadv_tt_local_remove(bat_priv, tt_global_entry->common.addr,
-			       "global tt received",
-			       flags & BATADV_TT_CLIENT_ROAM);
+	local_flags = batadv_tt_local_remove(bat_priv, tt_addr,
+					     "global tt received",
+					     flags & BATADV_TT_CLIENT_ROAM);
+	tt_global_entry->common.flags |= local_flags & BATADV_TT_CLIENT_WIFI;
+
 out:
 	if (tt_global_entry)
 		batadv_tt_global_entry_free_ref(tt_global_entry);
diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/translation-table.h
index 811fffd..9fa4fe4 100644
--- a/net/batman-adv/translation-table.h
+++ b/net/batman-adv/translation-table.h
@@ -24,9 +24,9 @@ int batadv_tt_len(int changes_num);
 int batadv_tt_init(struct batadv_priv *bat_priv);
 void batadv_tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 			 int ifindex);
-void batadv_tt_local_remove(struct batadv_priv *bat_priv,
-			    const uint8_t *addr, const char *message,
-			    bool roaming);
+uint16_t batadv_tt_local_remove(struct batadv_priv *bat_priv,
+				const uint8_t *addr, const char *message,
+				bool roaming);
 int batadv_tt_local_seq_print_text(struct seq_file *seq, void *offset);
 void batadv_tt_global_add_orig(struct batadv_priv *bat_priv,
 			       struct batadv_orig_node *orig_node,
-- 
1.7.12.4
