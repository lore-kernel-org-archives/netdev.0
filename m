From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Subject: [PATCH 1/6] batman-adv: unify flags for
	tt_change/tt_local_entry/tt_global_entry
Date: Tue,  5 Jul 2011 15:43:55 +0200
Message-ID: <1309873440-11704-2-git-send-email-lindner_marek@yahoo.de>
References: <1309873440-11704-1-git-send-email-lindner_marek@yahoo.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1309873440-11704-1-git-send-email-lindner_marek-LWAfsSFWpa4@public.gmane.org>
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

From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>

The tt_local_entry structure now has a 'flags' field. This helps to
unify the flags format to all the client related structures (tt_global_entry
and tt_change). The 'never_purge' field is now encoded in the 'flags' one.
To optimise the usage of this field, its length has been increased to 16bit
in order to use the eight leading bits (from 0 to 7) to store flags that have
to be sent on the wire, while the eight ending ones are used for local
computation only.

Moreover 'enum tt_change_flags' is now called 'enum tt_client_flags' and the
defined values apply to the tt_local_entry, tt_global_entry and the tt_change
'flags' field.

Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Signed-off-by: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
---
 net/batman-adv/packet.h            |   11 +++++++----
 net/batman-adv/translation-table.c |   13 ++++++-------
 net/batman-adv/translation-table.h |    3 +--
 net/batman-adv/types.h             |    4 ++--
 4 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index c5f081d..590e4a6 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -78,10 +78,13 @@ enum tt_query_flags {
 	TT_FULL_TABLE = 1 << 2
 };
 
-/* TT_CHANGE flags */
-enum tt_change_flags {
-	TT_CHANGE_DEL  = 0x01,
-	TT_CLIENT_ROAM = 0x02
+/* TT_CLIENT flags.
+ * Flags from 1 to 1 << 7 are sent on the wire, while flags from 1 << 8 to
+ * 1 << 15 are used for local computation only */
+enum tt_client_flags {
+	TT_CLIENT_DEL     = 1 << 0,
+	TT_CLIENT_ROAM    = 1 << 1,
+	TT_CLIENT_NOPURGE = 1 << 8
 };
 
 struct batman_packet {
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 5f1fcd5..4208dc7 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -211,13 +211,12 @@ void tt_local_add(struct net_device *soft_iface, const uint8_t *addr)
 
 	memcpy(tt_local_entry->addr, addr, ETH_ALEN);
 	tt_local_entry->last_seen = jiffies;
+	tt_local_entry->flags = NO_FLAGS;
 	atomic_set(&tt_local_entry->refcount, 2);
 
 	/* the batman interface mac address should never be purged */
 	if (compare_eth(addr, soft_iface->dev_addr))
-		tt_local_entry->never_purge = 1;
-	else
-		tt_local_entry->never_purge = 0;
+		tt_local_entry->flags |= TT_CLIENT_NOPURGE;
 
 	hash_add(bat_priv->tt_local_hash, compare_ltt, choose_orig,
 		 tt_local_entry, &tt_local_entry->hash_entry);
@@ -387,7 +386,7 @@ void tt_local_remove(struct bat_priv *bat_priv, const uint8_t *addr,
 	if (!tt_local_entry)
 		goto out;
 
-	tt_local_event(bat_priv, TT_CHANGE_DEL, tt_local_entry->addr, roaming);
+	tt_local_event(bat_priv, TT_CLIENT_DEL, tt_local_entry->addr, roaming);
 	tt_local_del(bat_priv, tt_local_entry, message);
 out:
 	if (tt_local_entry)
@@ -410,14 +409,14 @@ static void tt_local_purge(struct bat_priv *bat_priv)
 		spin_lock_bh(list_lock);
 		hlist_for_each_entry_safe(tt_local_entry, node, node_tmp,
 					  head, hash_entry) {
-			if (tt_local_entry->never_purge)
+			if (tt_local_entry->flags & TT_CLIENT_NOPURGE)
 				continue;
 
 			if (!is_out_of_time(tt_local_entry->last_seen,
 					    TT_LOCAL_TIMEOUT * 1000))
 				continue;
 
-			tt_local_event(bat_priv, TT_CHANGE_DEL,
+			tt_local_event(bat_priv, TT_CLIENT_DEL,
 				       tt_local_entry->addr, false);
 			atomic_dec(&bat_priv->num_local_tt);
 			bat_dbg(DBG_TT, bat_priv, "Deleting local "
@@ -1335,7 +1334,7 @@ static void _tt_update_changes(struct bat_priv *bat_priv,
 	int i;
 
 	for (i = 0; i < tt_num_changes; i++) {
-		if ((tt_change + i)->flags & TT_CHANGE_DEL)
+		if ((tt_change + i)->flags & TT_CLIENT_DEL)
 			tt_global_del(bat_priv, orig_node,
 				      (tt_change + i)->addr,
 				      "tt removed by changes",
diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/translation-table.h
index 1cd2d39..460e583 100644
--- a/net/batman-adv/translation-table.h
+++ b/net/batman-adv/translation-table.h
@@ -30,8 +30,7 @@ void tt_local_add(struct net_device *soft_iface, const uint8_t *addr);
 void tt_local_remove(struct bat_priv *bat_priv,
 		     const uint8_t *addr, const char *message, bool roaming);
 int tt_local_seq_print_text(struct seq_file *seq, void *offset);
-void tt_global_add_orig(struct bat_priv *bat_priv,
-			struct orig_node *orig_node,
+void tt_global_add_orig(struct bat_priv *bat_priv, struct orig_node *orig_node,
 			const unsigned char *tt_buff, int tt_buff_len);
 int tt_global_add(struct bat_priv *bat_priv,
 		  struct orig_node *orig_node, const unsigned char *addr,
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 85cf122..25bd1db 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -224,7 +224,7 @@ struct socket_packet {
 struct tt_local_entry {
 	uint8_t addr[ETH_ALEN];
 	unsigned long last_seen;
-	char never_purge;
+	uint16_t flags;
 	atomic_t refcount;
 	struct rcu_head rcu;
 	struct hlist_node hash_entry;
@@ -234,7 +234,7 @@ struct tt_global_entry {
 	uint8_t addr[ETH_ALEN];
 	struct orig_node *orig_node;
 	uint8_t ttvn;
-	uint8_t flags; /* only TT_GLOBAL_ROAM is used */
+	uint16_t flags; /* only TT_GLOBAL_ROAM is used */
 	unsigned long roam_at; /* time at which TT_GLOBAL_ROAM was set */
 	atomic_t refcount;
 	struct rcu_head rcu;
-- 
1.7.5.3
