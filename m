From: Marek Lindner <lindner_marek@yahoo.de>
Subject: [PATCH 03/11] batman-adv: generalise tt_local_reset_flags()
Date: Mon, 12 Dec 2011 19:31:47 +0800
Message-ID: <1323689516-24427-4-git-send-email-lindner_marek@yahoo.de>
References: <1323689516-24427-1-git-send-email-lindner_marek@yahoo.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm9-vm0.bullet.mail.ukl.yahoo.com ([217.146.183.240]:25851 "HELO
	nm9-vm0.bullet.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752692Ab1LLLc1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2011 06:32:27 -0500
In-Reply-To: <1323689516-24427-1-git-send-email-lindner_marek@yahoo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>

The tt_local_reset_flags() is actually used for one use case only. It is not
generalised enough to be used indifferent situations. This patch make it general
enough in order to let other code use it whenever a flag set is requested over
the whole hash table (passed as parameter). The function is now called
tt_set_flags()

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/translation-table.c |   35 +++++++++++++++++++++++------------
 1 files changed, 23 insertions(+), 12 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 76134bc..f6bbd64 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -1695,19 +1695,19 @@ void tt_free(struct bat_priv *bat_priv)
 	kfree(bat_priv->tt_buff);
 }
 
-/* This function will reset the specified flags from all the entries in
- * the given hash table and will increment num_local_tt for each involved
- * entry */
-static void tt_local_reset_flags(struct bat_priv *bat_priv, uint16_t flags)
+/* This function will enable or disable the specified flags for all the entries
+ * in the given hash table and returns the number of modified entries */
+static uint16_t tt_set_flags(struct hashtable_t *hash, uint16_t flags,
+			     bool enable)
 {
 	uint32_t i;
-	struct hashtable_t *hash = bat_priv->tt_local_hash;
+	uint16_t changed_num = 0;
 	struct hlist_head *head;
 	struct hlist_node *node;
 	struct tt_common_entry *tt_common_entry;
 
 	if (!hash)
-		return;
+		goto out;
 
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
@@ -1715,14 +1715,21 @@ static void tt_local_reset_flags(struct bat_priv *bat_priv, uint16_t flags)
 		rcu_read_lock();
 		hlist_for_each_entry_rcu(tt_common_entry, node,
 					 head, hash_entry) {
-			if (!(tt_common_entry->flags & flags))
-				continue;
-			tt_common_entry->flags &= ~flags;
-			atomic_inc(&bat_priv->num_local_tt);
+			if (enable) {
+				if ((tt_common_entry->flags & flags) == flags)
+					continue;
+				tt_common_entry->flags |= flags;
+			} else {
+				if (!(tt_common_entry->flags & flags))
+					continue;
+				tt_common_entry->flags &= ~flags;
+			}
+			changed_num++;
 		}
 		rcu_read_unlock();
 	}
-
+out:
+	return changed_num;
 }
 
 /* Purge out all the tt local entries marked with TT_CLIENT_PENDING */
@@ -1766,7 +1773,11 @@ static void tt_local_purge_pending_clients(struct bat_priv *bat_priv)
 
 void tt_commit_changes(struct bat_priv *bat_priv)
 {
-	tt_local_reset_flags(bat_priv, TT_CLIENT_NEW);
+	uint16_t changed_num = tt_set_flags(bat_priv->tt_local_hash,
+					    TT_CLIENT_NEW, false);
+	/* all the reset entries have now to be effectively counted as local
+	 * entries */
+	atomic_add(changed_num, &bat_priv->num_local_tt);
 	tt_local_purge_pending_clients(bat_priv);
 
 	/* Increment the TTVN only once per OGM interval */
-- 
1.7.5.4
