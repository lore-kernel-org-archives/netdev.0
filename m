From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 07/15] batman-adv: convert orig_node->vlan_list to hlist
Date: Tue, 25 Aug 2015 13:02:31 +0200
Message-ID: <1440500559-28368-8-git-send-email-antonio@meshcoding.com>
References: <1440500559-28368-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:33546 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755388AbbHYLEA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2015 07:04:00 -0400
In-Reply-To: <1440500559-28368-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <mareklindner@neomailbox.ch>

Since the list's tail is never accessed using a double linked list head
wastes memory.

Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/originator.c        | 7 ++++---
 net/batman-adv/translation-table.c | 8 ++++----
 net/batman-adv/types.h             | 4 ++--
 3 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 4500e3a..610620a 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -26,6 +26,7 @@
 #include <linux/list.h>
 #include <linux/lockdep.h>
 #include <linux/netdevice.h>
+#include <linux/rculist.h>
 #include <linux/seq_file.h>
 #include <linux/slab.h>
 #include <linux/spinlock.h>
@@ -70,7 +71,7 @@ batadv_orig_node_vlan_get(struct batadv_orig_node *orig_node,
 	struct batadv_orig_node_vlan *vlan = NULL, *tmp;
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(tmp, &orig_node->vlan_list, list) {
+	hlist_for_each_entry_rcu(tmp, &orig_node->vlan_list, list) {
 		if (tmp->vid != vid)
 			continue;
 
@@ -118,7 +119,7 @@ batadv_orig_node_vlan_new(struct batadv_orig_node *orig_node,
 	atomic_set(&vlan->refcount, 2);
 	vlan->vid = vid;
 
-	list_add_rcu(&vlan->list, &orig_node->vlan_list);
+	hlist_add_head_rcu(&vlan->list, &orig_node->vlan_list);
 
 out:
 	spin_unlock_bh(&orig_node->vlan_list_lock);
@@ -673,7 +674,7 @@ struct batadv_orig_node *batadv_orig_node_new(struct batadv_priv *bat_priv,
 		return NULL;
 
 	INIT_HLIST_HEAD(&orig_node->neigh_list);
-	INIT_LIST_HEAD(&orig_node->vlan_list);
+	INIT_HLIST_HEAD(&orig_node->vlan_list);
 	INIT_HLIST_HEAD(&orig_node->ifinfo_list);
 	spin_lock_init(&orig_node->bcast_seqno_lock);
 	spin_lock_init(&orig_node->neigh_list_lock);
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 3932df2..9e1f866 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -315,7 +315,7 @@ static void batadv_tt_global_size_mod(struct batadv_orig_node *orig_node,
 
 	if (atomic_add_return(v, &vlan->tt.num_entries) == 0) {
 		spin_lock_bh(&orig_node->vlan_list_lock);
-		list_del_rcu(&vlan->list);
+		hlist_del_rcu(&vlan->list);
 		spin_unlock_bh(&orig_node->vlan_list_lock);
 		batadv_orig_node_vlan_free_ref(vlan);
 	}
@@ -741,7 +741,7 @@ batadv_tt_prepare_tvlv_global_data(struct batadv_orig_node *orig_node,
 	u8 *tt_change_ptr;
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(vlan, &orig_node->vlan_list, list) {
+	hlist_for_each_entry_rcu(vlan, &orig_node->vlan_list, list) {
 		num_vlan++;
 		num_entries += atomic_read(&vlan->tt.num_entries);
 	}
@@ -767,7 +767,7 @@ batadv_tt_prepare_tvlv_global_data(struct batadv_orig_node *orig_node,
 	(*tt_data)->num_vlan = htons(num_vlan);
 
 	tt_vlan = (struct batadv_tvlv_tt_vlan_data *)(*tt_data + 1);
-	list_for_each_entry_rcu(vlan, &orig_node->vlan_list, list) {
+	hlist_for_each_entry_rcu(vlan, &orig_node->vlan_list, list) {
 		tt_vlan->vid = htons(vlan->vid);
 		tt_vlan->crc = htonl(vlan->tt.crc);
 
@@ -2466,7 +2466,7 @@ static void batadv_tt_global_update_crc(struct batadv_priv *bat_priv,
 
 	/* recompute the global CRC for each VLAN */
 	rcu_read_lock();
-	list_for_each_entry_rcu(vlan, &orig_node->vlan_list, list) {
+	hlist_for_each_entry_rcu(vlan, &orig_node->vlan_list, list) {
 		/* if orig_node is a backbone node for this VLAN, don't compute
 		 * the CRC as we ignore all the global entries over it
 		 */
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index f2ebe33..fe3695c 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -190,7 +190,7 @@ struct batadv_vlan_tt {
 struct batadv_orig_node_vlan {
 	unsigned short vid;
 	struct batadv_vlan_tt tt;
-	struct list_head list;
+	struct hlist_node list;
 	atomic_t refcount;
 	struct rcu_head rcu;
 };
@@ -302,7 +302,7 @@ struct batadv_orig_node {
 	spinlock_t out_coding_list_lock; /* Protects out_coding_list */
 #endif
 	struct batadv_frag_table_entry fragments[BATADV_FRAG_BUFFER_COUNT];
-	struct list_head vlan_list;
+	struct hlist_head vlan_list;
 	spinlock_t vlan_list_lock; /* protects vlan_list */
 	struct batadv_orig_bat_iv bat_iv;
 };
-- 
2.5.0
