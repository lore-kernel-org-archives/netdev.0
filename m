From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Subject: [PATCH 04/11] batman-adv: check return value for
	hash_add()
Date: Mon, 12 Dec 2011 19:31:48 +0800
Message-ID: <1323689516-24427-5-git-send-email-lindner_marek@yahoo.de>
References: <1323689516-24427-1-git-send-email-lindner_marek@yahoo.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>,
	Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1323689516-24427-1-git-send-email-lindner_marek-LWAfsSFWpa4@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Simon Wunderlich <simon.wunderlich-Y4E02TeZ33kaBlGTGt4zH4SGEyLTKazZ@public.gmane.org>

if hash_add() fails, we should remove the structure to avoid memory
leaks.

Signed-off-by: Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>
Acked-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
---
 net/batman-adv/translation-table.c |   28 ++++++++++++++++++++++------
 1 files changed, 22 insertions(+), 6 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index f6bbd64..cc87acf 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -190,6 +190,7 @@ void tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 	struct bat_priv *bat_priv = netdev_priv(soft_iface);
 	struct tt_local_entry *tt_local_entry = NULL;
 	struct tt_global_entry *tt_global_entry = NULL;
+	int hash_added;
 
 	tt_local_entry = tt_local_hash_find(bat_priv, addr);
 
@@ -217,6 +218,16 @@ void tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 	if (compare_eth(addr, soft_iface->dev_addr))
 		tt_local_entry->common.flags |= TT_CLIENT_NOPURGE;
 
+	hash_added = hash_add(bat_priv->tt_local_hash, compare_tt, choose_orig,
+			 &tt_local_entry->common,
+			 &tt_local_entry->common.hash_entry);
+
+	if (unlikely(hash_added != 0)) {
+		/* remove the reference for the hash */
+		tt_local_entry_free_ref(tt_local_entry);
+		goto out;
+	}
+
 	tt_local_event(bat_priv, addr, tt_local_entry->common.flags);
 
 	/* The local entry has to be marked as NEW to avoid to send it in
@@ -224,9 +235,6 @@ void tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 	 * (consistency check) */
 	tt_local_entry->common.flags |= TT_CLIENT_NEW;
 
-	hash_add(bat_priv->tt_local_hash, compare_tt, choose_orig,
-		 &tt_local_entry->common, &tt_local_entry->common.hash_entry);
-
 	/* remove address from global hash if present */
 	tt_global_entry = tt_global_hash_find(bat_priv, addr);
 
@@ -499,6 +507,7 @@ int tt_global_add(struct bat_priv *bat_priv, struct orig_node *orig_node,
 	struct tt_global_entry *tt_global_entry;
 	struct orig_node *orig_node_tmp;
 	int ret = 0;
+	int hash_added;
 
 	tt_global_entry = tt_global_hash_find(bat_priv, tt_addr);
 
@@ -518,9 +527,15 @@ int tt_global_add(struct bat_priv *bat_priv, struct orig_node *orig_node,
 		tt_global_entry->ttvn = ttvn;
 		tt_global_entry->roam_at = 0;
 
-		hash_add(bat_priv->tt_global_hash, compare_tt,
-			 choose_orig, &tt_global_entry->common,
-			 &tt_global_entry->common.hash_entry);
+		hash_added = hash_add(bat_priv->tt_global_hash, compare_tt,
+				 choose_orig, &tt_global_entry->common,
+				 &tt_global_entry->common.hash_entry);
+
+		if (unlikely(hash_added != 0)) {
+			/* remove the reference for the hash */
+			tt_global_entry_free_ref(tt_global_entry);
+			goto out_remove;
+		}
 		atomic_inc(&orig_node->tt_size);
 	} else {
 		if (tt_global_entry->orig_node != orig_node) {
@@ -543,6 +558,7 @@ int tt_global_add(struct bat_priv *bat_priv, struct orig_node *orig_node,
 		"Creating new global tt entry: %pM (via %pM)\n",
 		tt_global_entry->common.addr, orig_node->orig);
 
+out_remove:
 	/* remove address from local hash if present */
 	tt_local_remove(bat_priv, tt_global_entry->common.addr,
 			"global tt received", roaming);
-- 
1.7.5.4
