From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 11/15] batman-adv: convert bat_priv->tt.req_list to hlist
Date: Tue, 25 Aug 2015 13:02:35 +0200
Message-ID: <1440500559-28368-12-git-send-email-antonio__38625.0762887814$1440502257$gmane$org@meshcoding.com>
References: <1440500559-28368-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:17835 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755393AbbHYLal (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2015 07:30:41 -0400
In-Reply-To: <1440500559-28368-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <mareklindner@neomailbox.ch>

Since the list's tail is never accessed using a double linked list head
wastes memory.

Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/main.c              |  2 +-
 net/batman-adv/translation-table.c | 29 ++++++++++++++++-------------
 net/batman-adv/types.h             |  4 ++--
 3 files changed, 19 insertions(+), 16 deletions(-)

diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 40750cb..d277ba7 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -148,7 +148,7 @@ int batadv_mesh_init(struct net_device *soft_iface)
 	INIT_HLIST_HEAD(&bat_priv->mcast.want_all_ipv6_list);
 #endif
 	INIT_LIST_HEAD(&bat_priv->tt.changes_list);
-	INIT_LIST_HEAD(&bat_priv->tt.req_list);
+	INIT_HLIST_HEAD(&bat_priv->tt.req_list);
 	INIT_LIST_HEAD(&bat_priv->tt.roam_list);
 #ifdef CONFIG_BATMAN_ADV_MCAST
 	INIT_HLIST_HEAD(&bat_priv->mcast.mla_list);
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 596e326..734b456 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -2224,12 +2224,13 @@ static u32 batadv_tt_local_crc(struct batadv_priv *bat_priv,
 
 static void batadv_tt_req_list_free(struct batadv_priv *bat_priv)
 {
-	struct batadv_tt_req_node *node, *safe;
+	struct batadv_tt_req_node *node;
+	struct hlist_node *safe;
 
 	spin_lock_bh(&bat_priv->tt.req_list_lock);
 
-	list_for_each_entry_safe(node, safe, &bat_priv->tt.req_list, list) {
-		list_del_init(&node->list);
+	hlist_for_each_entry_safe(node, safe, &bat_priv->tt.req_list, list) {
+		hlist_del_init(&node->list);
 		kfree(node);
 	}
 
@@ -2259,13 +2260,14 @@ static void batadv_tt_save_orig_buffer(struct batadv_priv *bat_priv,
 
 static void batadv_tt_req_purge(struct batadv_priv *bat_priv)
 {
-	struct batadv_tt_req_node *node, *safe;
+	struct batadv_tt_req_node *node;
+	struct hlist_node *safe;
 
 	spin_lock_bh(&bat_priv->tt.req_list_lock);
-	list_for_each_entry_safe(node, safe, &bat_priv->tt.req_list, list) {
+	hlist_for_each_entry_safe(node, safe, &bat_priv->tt.req_list, list) {
 		if (batadv_has_timed_out(node->issued_at,
 					 BATADV_TT_REQUEST_TIMEOUT)) {
-			list_del_init(&node->list);
+			hlist_del_init(&node->list);
 			kfree(node);
 		}
 	}
@@ -2287,7 +2289,7 @@ batadv_tt_req_node_new(struct batadv_priv *bat_priv,
 	struct batadv_tt_req_node *tt_req_node_tmp, *tt_req_node = NULL;
 
 	spin_lock_bh(&bat_priv->tt.req_list_lock);
-	list_for_each_entry(tt_req_node_tmp, &bat_priv->tt.req_list, list) {
+	hlist_for_each_entry(tt_req_node_tmp, &bat_priv->tt.req_list, list) {
 		if (batadv_compare_eth(tt_req_node_tmp, orig_node) &&
 		    !batadv_has_timed_out(tt_req_node_tmp->issued_at,
 					  BATADV_TT_REQUEST_TIMEOUT))
@@ -2301,7 +2303,7 @@ batadv_tt_req_node_new(struct batadv_priv *bat_priv,
 	ether_addr_copy(tt_req_node->addr, orig_node->orig);
 	tt_req_node->issued_at = jiffies;
 
-	list_add(&tt_req_node->list, &bat_priv->tt.req_list);
+	hlist_add_head(&tt_req_node->list, &bat_priv->tt.req_list);
 unlock:
 	spin_unlock_bh(&bat_priv->tt.req_list_lock);
 	return tt_req_node;
@@ -2552,8 +2554,8 @@ out:
 		batadv_hardif_free_ref(primary_if);
 	if (ret && tt_req_node) {
 		spin_lock_bh(&bat_priv->tt.req_list_lock);
-		/* list_del_init() verifies tt_req_node still is in the list */
-		list_del_init(&tt_req_node->list);
+		/* hlist_del_init() verifies tt_req_node still is in the list */
+		hlist_del_init(&tt_req_node->list);
 		spin_unlock_bh(&bat_priv->tt.req_list_lock);
 		kfree(tt_req_node);
 	}
@@ -2949,7 +2951,8 @@ static void batadv_handle_tt_response(struct batadv_priv *bat_priv,
 				      struct batadv_tvlv_tt_data *tt_data,
 				      u8 *resp_src, u16 num_entries)
 {
-	struct batadv_tt_req_node *node, *safe;
+	struct batadv_tt_req_node *node;
+	struct hlist_node *safe;
 	struct batadv_orig_node *orig_node = NULL;
 	struct batadv_tvlv_tt_change *tt_change;
 	u8 *tvlv_ptr = (u8 *)tt_data;
@@ -2987,10 +2990,10 @@ static void batadv_handle_tt_response(struct batadv_priv *bat_priv,
 
 	/* Delete the tt_req_node from pending tt_requests list */
 	spin_lock_bh(&bat_priv->tt.req_list_lock);
-	list_for_each_entry_safe(node, safe, &bat_priv->tt.req_list, list) {
+	hlist_for_each_entry_safe(node, safe, &bat_priv->tt.req_list, list) {
 		if (!batadv_compare_eth(node->addr, resp_src))
 			continue;
-		list_del_init(&node->list);
+		hlist_del_init(&node->list);
 		kfree(node);
 	}
 
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index fe3695c..2f5e6c3 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -537,7 +537,7 @@ struct batadv_priv_tt {
 	struct list_head changes_list;
 	struct batadv_hashtable *local_hash;
 	struct batadv_hashtable *global_hash;
-	struct list_head req_list;
+	struct hlist_head req_list;
 	struct list_head roam_list;
 	spinlock_t changes_list_lock; /* protects changes */
 	spinlock_t req_list_lock; /* protects req_list */
@@ -1006,7 +1006,7 @@ struct batadv_tt_change_node {
 struct batadv_tt_req_node {
 	u8 addr[ETH_ALEN];
 	unsigned long issued_at;
-	struct list_head list;
+	struct hlist_node list;
 };
 
 /**
-- 
2.5.0
