From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 03/10] batman-adv: move neigh_node list add into batadv_neigh_node_new()
Date: Fri, 28 Aug 2015 11:12:29 +0200
Message-ID: <1440753156-7808-4-git-send-email-antonio__26043.3422671214$1440753277$gmane$org@meshcoding.com>
References: <1440753156-7808-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:40763 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752335AbbH1JNx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Aug 2015 05:13:53 -0400
In-Reply-To: <1440753156-7808-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <mareklindner@neomailbox.ch>

All batadv_neigh_node_* functions expect the neigh_node list item to be part
of the orig_node->neigh_list, therefore the constructor of said list item
should be adding the newly created neigh_node to the respective list.

Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Acked-by: Simon Wunderlich <sw@simonwunderlich.de>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/bat_iv_ogm.c | 21 +--------------------
 net/batman-adv/originator.c | 12 ++++++++++++
 2 files changed, 13 insertions(+), 20 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index b18184e..5e93af4 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -296,8 +296,7 @@ batadv_iv_ogm_neigh_new(struct batadv_hard_iface *hard_iface,
 			struct batadv_orig_node *orig_node,
 			struct batadv_orig_node *orig_neigh)
 {
-	struct batadv_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
-	struct batadv_neigh_node *neigh_node, *tmp_neigh_node;
+	struct batadv_neigh_node *neigh_node;
 
 	neigh_node = batadv_neigh_node_new(hard_iface, neigh_addr, orig_node);
 	if (!neigh_node)
@@ -305,24 +304,6 @@ batadv_iv_ogm_neigh_new(struct batadv_hard_iface *hard_iface,
 
 	neigh_node->orig_node = orig_neigh;
 
-	spin_lock_bh(&orig_node->neigh_list_lock);
-	tmp_neigh_node = batadv_neigh_node_get(orig_node, hard_iface,
-					       neigh_addr);
-	if (!tmp_neigh_node) {
-		hlist_add_head_rcu(&neigh_node->list, &orig_node->neigh_list);
-	} else {
-		kfree(neigh_node);
-		batadv_hardif_free_ref(hard_iface);
-		neigh_node = tmp_neigh_node;
-	}
-	spin_unlock_bh(&orig_node->neigh_list_lock);
-
-	if (!tmp_neigh_node)
-		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
-			   "Creating new neighbor %pM for orig_node %pM on interface %s\n",
-			   neigh_addr, orig_node->orig,
-			   hard_iface->net_dev->name);
-
 out:
 	return neigh_node;
 }
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index f8317c1..f751775 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -457,6 +457,10 @@ batadv_neigh_node_new(struct batadv_hard_iface *hard_iface,
 {
 	struct batadv_neigh_node *neigh_node;
 
+	neigh_node = batadv_neigh_node_get(orig_node, hard_iface, neigh_addr);
+	if (neigh_node)
+		goto out;
+
 	neigh_node = kzalloc(sizeof(*neigh_node), GFP_ATOMIC);
 	if (!neigh_node)
 		goto out;
@@ -478,6 +482,14 @@ batadv_neigh_node_new(struct batadv_hard_iface *hard_iface,
 	/* extra reference for return */
 	atomic_set(&neigh_node->refcount, 2);
 
+	spin_lock_bh(&orig_node->neigh_list_lock);
+	hlist_add_head_rcu(&neigh_node->list, &orig_node->neigh_list);
+	spin_unlock_bh(&orig_node->neigh_list_lock);
+
+	batadv_dbg(BATADV_DBG_BATMAN, orig_node->bat_priv,
+		   "Creating new neighbor %pM for orig_node %pM on interface %s\n",
+		   neigh_addr, orig_node->orig, hard_iface->net_dev->name);
+
 out:
 	return neigh_node;
 }
-- 
2.5.0
