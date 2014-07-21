From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 2/2] batman-adv: fix TT VLAN inconsistency on VLAN re-add
Date: Mon, 21 Jul 2014 09:53:31 +0200
Message-ID: <1405929211-30187-3-git-send-email-antonio@meshcoding.com>
References: <1405929211-30187-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:11523 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751030AbaGUHx7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 03:53:59 -0400
In-Reply-To: <1405929211-30187-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

When a VLAN interface (on top of batX) is removed and
re-added within a short timeframe TT does not have enough
time to properly cleanup. This creates an internal TT state
mismatch as the newly created softif_vlan will be
initialized from scratch with a TT client count of zero
(even if TT entries for this VLAN still exist). The
resulting TT messages are bogus due to the counter / tt
client listing mismatch, thus creating inconsistencies on
every node in the network

To fix this issue destroy_vlan() has to not free the VLAN
object immediately but it has to be kept alive until all the
TT entries for this VLAN have been removed. destroy_vlan()
still removes the sysfs folder so that the user has the
feeling that everything went fine.

If the same VLAN is re-added before the old object is free'd,
then the latter is resurrected and re-used.

Implement such behaviour by increasing the reference counter
of a softif_vlan object every time a new local TT entry for
such VLAN is created and remove the object from the list
only when all the TT entries have been destroyed.

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/soft-interface.c    | 66 ++++++++++++++++++++++++++++----------
 net/batman-adv/translation-table.c | 26 +++++++++++++++
 net/batman-adv/types.h             |  2 ++
 3 files changed, 77 insertions(+), 17 deletions(-)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index e7ee65d..cbd677f 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -448,10 +448,15 @@ out:
  *  possibly free it
  * @softif_vlan: the vlan object to release
  */
-void batadv_softif_vlan_free_ref(struct batadv_softif_vlan *softif_vlan)
+void batadv_softif_vlan_free_ref(struct batadv_softif_vlan *vlan)
 {
-	if (atomic_dec_and_test(&softif_vlan->refcount))
-		kfree_rcu(softif_vlan, rcu);
+	if (atomic_dec_and_test(&vlan->refcount)) {
+		spin_lock_bh(&vlan->bat_priv->softif_vlan_list_lock);
+		hlist_del_rcu(&vlan->list);
+		spin_unlock_bh(&vlan->bat_priv->softif_vlan_list_lock);
+
+		kfree_rcu(vlan, rcu);
+	}
 }
 
 /**
@@ -505,6 +510,7 @@ int batadv_softif_create_vlan(struct batadv_priv *bat_priv, unsigned short vid)
 	if (!vlan)
 		return -ENOMEM;
 
+	vlan->bat_priv = bat_priv;
 	vlan->vid = vid;
 	atomic_set(&vlan->refcount, 1);
 
@@ -516,17 +522,17 @@ int batadv_softif_create_vlan(struct batadv_priv *bat_priv, unsigned short vid)
 		return err;
 	}
 
-	/* add a new TT local entry. This one will be marked with the NOPURGE
-	 * flag
-	 */
-	batadv_tt_local_add(bat_priv->soft_iface,
-			    bat_priv->soft_iface->dev_addr, vid,
-			    BATADV_NULL_IFINDEX, BATADV_NO_MARK);
-
 	spin_lock_bh(&bat_priv->softif_vlan_list_lock);
 	hlist_add_head_rcu(&vlan->list, &bat_priv->softif_vlan_list);
 	spin_unlock_bh(&bat_priv->softif_vlan_list_lock);
 
+	/* add a new TT local entry. This one will be marked with the NOPURGE
+	 * flag
+	 */
+	batadv_tt_local_add(bat_priv->soft_iface,
+			    bat_priv->soft_iface->dev_addr, vid,
+			    BATADV_NULL_IFINDEX, BATADV_NO_MARK);
+
 	return 0;
 }
 
@@ -538,18 +544,13 @@ int batadv_softif_create_vlan(struct batadv_priv *bat_priv, unsigned short vid)
 static void batadv_softif_destroy_vlan(struct batadv_priv *bat_priv,
 				       struct batadv_softif_vlan *vlan)
 {
-	spin_lock_bh(&bat_priv->softif_vlan_list_lock);
-	hlist_del_rcu(&vlan->list);
-	spin_unlock_bh(&bat_priv->softif_vlan_list_lock);
-
-	batadv_sysfs_del_vlan(bat_priv, vlan);
-
 	/* explicitly remove the associated TT local entry because it is marked
 	 * with the NOPURGE flag
 	 */
 	batadv_tt_local_remove(bat_priv, bat_priv->soft_iface->dev_addr,
 			       vlan->vid, "vlan interface destroyed", false);
 
+	batadv_sysfs_del_vlan(bat_priv, vlan);
 	batadv_softif_vlan_free_ref(vlan);
 }
 
@@ -567,6 +568,8 @@ static int batadv_interface_add_vid(struct net_device *dev, __be16 proto,
 				    unsigned short vid)
 {
 	struct batadv_priv *bat_priv = netdev_priv(dev);
+	struct batadv_softif_vlan *vlan;
+	int ret;
 
 	/* only 802.1Q vlans are supported.
 	 * batman-adv does not know how to handle other types
@@ -576,7 +579,36 @@ static int batadv_interface_add_vid(struct net_device *dev, __be16 proto,
 
 	vid |= BATADV_VLAN_HAS_TAG;
 
-	return batadv_softif_create_vlan(bat_priv, vid);
+	/* if a new vlan is getting created and it already exists, it means that
+	 * it was not deleted yet. batadv_softif_vlan_get() increases the
+	 * refcount in order to revive the object.
+	 *
+	 * if it does not exist then create it.
+	 */
+	vlan = batadv_softif_vlan_get(bat_priv, vid);
+	if (!vlan)
+		return batadv_softif_create_vlan(bat_priv, vid);
+
+	/* recreate the sysfs object if it was already destroyed (and it should
+	 * be since we received a kill_vid() for this vlan
+	 */
+	if (!vlan->kobj) {
+		ret = batadv_sysfs_add_vlan(bat_priv->soft_iface, vlan);
+		if (ret) {
+			batadv_softif_vlan_free_ref(vlan);
+			return ret;
+		}
+	}
+
+	/* add a new TT local entry. This one will be marked with the NOPURGE
+	 * flag. This must be added again, even if the vlan object already
+	 * exists, because the entry was deleted by kill_vid()
+	 */
+	batadv_tt_local_add(bat_priv->soft_iface,
+			    bat_priv->soft_iface->dev_addr, vid,
+			    BATADV_NULL_IFINDEX, BATADV_NO_MARK);
+
+	return 0;
 }
 
 /**
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index d636bde..5f59e7f 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -511,6 +511,7 @@ bool batadv_tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 	struct batadv_priv *bat_priv = netdev_priv(soft_iface);
 	struct batadv_tt_local_entry *tt_local;
 	struct batadv_tt_global_entry *tt_global = NULL;
+	struct batadv_softif_vlan *vlan;
 	struct net_device *in_dev = NULL;
 	struct hlist_head *head;
 	struct batadv_tt_orig_list_entry *orig_entry;
@@ -572,6 +573,9 @@ bool batadv_tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 	if (!tt_local)
 		goto out;
 
+	/* increase the refcounter of the related vlan */
+	vlan = batadv_softif_vlan_get(bat_priv, vid);
+
 	batadv_dbg(BATADV_DBG_TT, bat_priv,
 		   "Creating new local tt entry: %pM (vid: %d, ttvn: %d)\n",
 		   addr, BATADV_PRINT_VID(vid),
@@ -604,6 +608,7 @@ bool batadv_tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 	if (unlikely(hash_added != 0)) {
 		/* remove the reference for the hash */
 		batadv_tt_local_entry_free_ref(tt_local);
+		batadv_softif_vlan_free_ref(vlan);
 		goto out;
 	}
 
@@ -1009,6 +1014,7 @@ uint16_t batadv_tt_local_remove(struct batadv_priv *bat_priv,
 {
 	struct batadv_tt_local_entry *tt_local_entry;
 	uint16_t flags, curr_flags = BATADV_NO_FLAGS;
+	struct batadv_softif_vlan *vlan;
 
 	tt_local_entry = batadv_tt_local_hash_find(bat_priv, addr, vid);
 	if (!tt_local_entry)
@@ -1039,6 +1045,11 @@ uint16_t batadv_tt_local_remove(struct batadv_priv *bat_priv,
 	hlist_del_rcu(&tt_local_entry->common.hash_entry);
 	batadv_tt_local_entry_free_ref(tt_local_entry);
 
+	/* decrease the reference held for this vlan */
+	vlan = batadv_softif_vlan_get(bat_priv, vid);
+	batadv_softif_vlan_free_ref(vlan);
+	batadv_softif_vlan_free_ref(vlan);
+
 out:
 	if (tt_local_entry)
 		batadv_tt_local_entry_free_ref(tt_local_entry);
@@ -1111,6 +1122,7 @@ static void batadv_tt_local_table_free(struct batadv_priv *bat_priv)
 	spinlock_t *list_lock; /* protects write access to the hash lists */
 	struct batadv_tt_common_entry *tt_common_entry;
 	struct batadv_tt_local_entry *tt_local;
+	struct batadv_softif_vlan *vlan;
 	struct hlist_node *node_tmp;
 	struct hlist_head *head;
 	uint32_t i;
@@ -1131,6 +1143,13 @@ static void batadv_tt_local_table_free(struct batadv_priv *bat_priv)
 			tt_local = container_of(tt_common_entry,
 						struct batadv_tt_local_entry,
 						common);
+
+			/* decrease the reference held for this vlan */
+			vlan = batadv_softif_vlan_get(bat_priv,
+						      tt_common_entry->vid);
+			batadv_softif_vlan_free_ref(vlan);
+			batadv_softif_vlan_free_ref(vlan);
+
 			batadv_tt_local_entry_free_ref(tt_local);
 		}
 		spin_unlock_bh(list_lock);
@@ -3139,6 +3158,7 @@ static void batadv_tt_local_purge_pending_clients(struct batadv_priv *bat_priv)
 	struct batadv_hashtable *hash = bat_priv->tt.local_hash;
 	struct batadv_tt_common_entry *tt_common;
 	struct batadv_tt_local_entry *tt_local;
+	struct batadv_softif_vlan *vlan;
 	struct hlist_node *node_tmp;
 	struct hlist_head *head;
 	spinlock_t *list_lock; /* protects write access to the hash lists */
@@ -3167,6 +3187,12 @@ static void batadv_tt_local_purge_pending_clients(struct batadv_priv *bat_priv)
 			tt_local = container_of(tt_common,
 						struct batadv_tt_local_entry,
 						common);
+
+			/* decrease the reference held for this vlan */
+			vlan = batadv_softif_vlan_get(bat_priv, tt_common->vid);
+			batadv_softif_vlan_free_ref(vlan);
+			batadv_softif_vlan_free_ref(vlan);
+
 			batadv_tt_local_entry_free_ref(tt_local);
 		}
 		spin_unlock_bh(list_lock);
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 34891a5..8854c05 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -687,6 +687,7 @@ struct batadv_priv_nc {
 
 /**
  * struct batadv_softif_vlan - per VLAN attributes set
+ * @bat_priv: pointer to the mesh object
  * @vid: VLAN identifier
  * @kobj: kobject for sysfs vlan subdirectory
  * @ap_isolation: AP isolation state
@@ -696,6 +697,7 @@ struct batadv_priv_nc {
  * @rcu: struct used for freeing in a RCU-safe manner
  */
 struct batadv_softif_vlan {
+	struct batadv_priv *bat_priv;
 	unsigned short vid;
 	struct kobject *kobj;
 	atomic_t ap_isolation;		/* boolean */
-- 
1.8.5.5
