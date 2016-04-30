From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 3/4] batman-adv: Fix reference counting of vlan object for tt_local_entry
Date: Sun,  1 May 2016 01:06:02 +0800
Message-ID: <1462035963-28970-4-git-send-email-a@unstable.cc>
References: <1462035963-28970-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:13990 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751880AbcD3RGi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Apr 2016 13:06:38 -0400
In-Reply-To: <1462035963-28970-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The batadv_tt_local_entry was specific to a batadv_softif_vlan and held an
implicit reference to it. But this reference was never stored in form of a
pointer in the tt_local_entry itself. Instead batadv_tt_local_remove,
batadv_tt_local_table_free and batadv_tt_local_purge_pending_clients depend
on a consistent state of bat_priv->softif_vlan_list and that
batadv_softif_vlan_get always returns the batadv_softif_vlan object which
it has a reference for. But batadv_softif_vlan_get cannot guarantee that
because it is working only with rcu_read_lock on this list. It can
therefore happen that an vid is in this list twice or that
batadv_softif_vlan_get cannot find the batadv_softif_vlan for an vid due to
some other list operations taking place at the same time.

Instead add a batadv_softif_vlan pointer directly in batadv_tt_local_entry
which will be used for the reference counter decremented on release of
batadv_tt_local_entry.

Fixes: 35df3b298fc8 ("batman-adv: fix TT VLAN inconsistency on VLAN re-add")
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Acked-by: Antonio Quartulli <a@unstable.cc>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/translation-table.c | 42 ++++----------------------------------
 net/batman-adv/types.h             |  2 ++
 2 files changed, 6 insertions(+), 38 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 0b43e86328a5..9b4551a86535 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -215,6 +215,8 @@ static void batadv_tt_local_entry_release(struct kref *ref)
 	tt_local_entry = container_of(ref, struct batadv_tt_local_entry,
 				      common.refcount);
 
+	batadv_softif_vlan_put(tt_local_entry->vlan);
+
 	kfree_rcu(tt_local_entry, common.rcu);
 }
 
@@ -673,6 +675,7 @@ bool batadv_tt_local_add(struct net_device *soft_iface, const u8 *addr,
 	kref_get(&tt_local->common.refcount);
 	tt_local->last_seen = jiffies;
 	tt_local->common.added_at = tt_local->last_seen;
+	tt_local->vlan = vlan;
 
 	/* the batman interface mac and multicast addresses should never be
 	 * purged
@@ -991,7 +994,6 @@ int batadv_tt_local_seq_print_text(struct seq_file *seq, void *offset)
 	struct batadv_tt_common_entry *tt_common_entry;
 	struct batadv_tt_local_entry *tt_local;
 	struct batadv_hard_iface *primary_if;
-	struct batadv_softif_vlan *vlan;
 	struct hlist_head *head;
 	unsigned short vid;
 	u32 i;
@@ -1027,14 +1029,6 @@ int batadv_tt_local_seq_print_text(struct seq_file *seq, void *offset)
 			last_seen_msecs = last_seen_msecs % 1000;
 
 			no_purge = tt_common_entry->flags & np_flag;
-
-			vlan = batadv_softif_vlan_get(bat_priv, vid);
-			if (!vlan) {
-				seq_printf(seq, "Cannot retrieve VLAN %d\n",
-					   BATADV_PRINT_VID(vid));
-				continue;
-			}
-
 			seq_printf(seq,
 				   " * %pM %4i [%c%c%c%c%c%c] %3u.%03u   (%#.8x)\n",
 				   tt_common_entry->addr,
@@ -1052,9 +1046,7 @@ int batadv_tt_local_seq_print_text(struct seq_file *seq, void *offset)
 				     BATADV_TT_CLIENT_ISOLA) ? 'I' : '.'),
 				   no_purge ? 0 : last_seen_secs,
 				   no_purge ? 0 : last_seen_msecs,
-				   vlan->tt.crc);
-
-			batadv_softif_vlan_put(vlan);
+				   tt_local->vlan->tt.crc);
 		}
 		rcu_read_unlock();
 	}
@@ -1099,7 +1091,6 @@ u16 batadv_tt_local_remove(struct batadv_priv *bat_priv, const u8 *addr,
 {
 	struct batadv_tt_local_entry *tt_local_entry;
 	u16 flags, curr_flags = BATADV_NO_FLAGS;
-	struct batadv_softif_vlan *vlan;
 	void *tt_entry_exists;
 
 	tt_local_entry = batadv_tt_local_hash_find(bat_priv, addr, vid);
@@ -1139,14 +1130,6 @@ u16 batadv_tt_local_remove(struct batadv_priv *bat_priv, const u8 *addr,
 	/* extra call to free the local tt entry */
 	batadv_tt_local_entry_put(tt_local_entry);
 
-	/* decrease the reference held for this vlan */
-	vlan = batadv_softif_vlan_get(bat_priv, vid);
-	if (!vlan)
-		goto out;
-
-	batadv_softif_vlan_put(vlan);
-	batadv_softif_vlan_put(vlan);
-
 out:
 	if (tt_local_entry)
 		batadv_tt_local_entry_put(tt_local_entry);
@@ -1219,7 +1202,6 @@ static void batadv_tt_local_table_free(struct batadv_priv *bat_priv)
 	spinlock_t *list_lock; /* protects write access to the hash lists */
 	struct batadv_tt_common_entry *tt_common_entry;
 	struct batadv_tt_local_entry *tt_local;
-	struct batadv_softif_vlan *vlan;
 	struct hlist_node *node_tmp;
 	struct hlist_head *head;
 	u32 i;
@@ -1241,14 +1223,6 @@ static void batadv_tt_local_table_free(struct batadv_priv *bat_priv)
 						struct batadv_tt_local_entry,
 						common);
 
-			/* decrease the reference held for this vlan */
-			vlan = batadv_softif_vlan_get(bat_priv,
-						      tt_common_entry->vid);
-			if (vlan) {
-				batadv_softif_vlan_put(vlan);
-				batadv_softif_vlan_put(vlan);
-			}
-
 			batadv_tt_local_entry_put(tt_local);
 		}
 		spin_unlock_bh(list_lock);
@@ -3309,7 +3283,6 @@ static void batadv_tt_local_purge_pending_clients(struct batadv_priv *bat_priv)
 	struct batadv_hashtable *hash = bat_priv->tt.local_hash;
 	struct batadv_tt_common_entry *tt_common;
 	struct batadv_tt_local_entry *tt_local;
-	struct batadv_softif_vlan *vlan;
 	struct hlist_node *node_tmp;
 	struct hlist_head *head;
 	spinlock_t *list_lock; /* protects write access to the hash lists */
@@ -3339,13 +3312,6 @@ static void batadv_tt_local_purge_pending_clients(struct batadv_priv *bat_priv)
 						struct batadv_tt_local_entry,
 						common);
 
-			/* decrease the reference held for this vlan */
-			vlan = batadv_softif_vlan_get(bat_priv, tt_common->vid);
-			if (vlan) {
-				batadv_softif_vlan_put(vlan);
-				batadv_softif_vlan_put(vlan);
-			}
-
 			batadv_tt_local_entry_put(tt_local);
 		}
 		spin_unlock_bh(list_lock);
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 443e9b84e07d..65afd090ab3e 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -1073,10 +1073,12 @@ struct batadv_tt_common_entry {
  * struct batadv_tt_local_entry - translation table local entry data
  * @common: general translation table data
  * @last_seen: timestamp used for purging stale tt local entries
+ * @vlan: soft-interface vlan of the entry
  */
 struct batadv_tt_local_entry {
 	struct batadv_tt_common_entry common;
 	unsigned long last_seen;
+	struct batadv_softif_vlan *vlan;
 };
 
 /**
-- 
2.8.1
