From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 05/10] batman-adv: avoid potential race condition when adding a new neighbour
Date: Mon, 17 Feb 2014 21:48:44 +0100
Message-ID: <1392670129-2498-6-git-send-email-antonio@meshcoding.com>
References: <1392670129-2498-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:13137 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752704AbaBQUxG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 15:53:06 -0500
In-Reply-To: <1392670129-2498-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

When adding a new neighbour it is important to atomically
perform the following:
- check if the neighbour already exists
- append the neighbour to the proper list

If the two operations are not performed in an atomic context
it is possible that two concurrent insertions add the same
neighbour twice.

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/bat_iv_ogm.c | 22 ++++++++++++++++------
 net/batman-adv/originator.c | 36 ++++++++++++++++++++++++++++++++++++
 net/batman-adv/originator.h |  4 ++++
 3 files changed, 56 insertions(+), 6 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 512159b..094ae7c 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -266,7 +266,7 @@ batadv_iv_ogm_neigh_new(struct batadv_hard_iface *hard_iface,
 			struct batadv_orig_node *orig_neigh)
 {
 	struct batadv_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
-	struct batadv_neigh_node *neigh_node;
+	struct batadv_neigh_node *neigh_node, *tmp_neigh_node;
 
 	neigh_node = batadv_neigh_node_new(hard_iface, neigh_addr, orig_node);
 	if (!neigh_node)
@@ -281,14 +281,24 @@ batadv_iv_ogm_neigh_new(struct batadv_hard_iface *hard_iface,
 	neigh_node->orig_node = orig_neigh;
 	neigh_node->if_incoming = hard_iface;
 
-	batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
-		   "Creating new neighbor %pM for orig_node %pM on interface %s\n",
-		   neigh_addr, orig_node->orig, hard_iface->net_dev->name);
-
 	spin_lock_bh(&orig_node->neigh_list_lock);
-	hlist_add_head_rcu(&neigh_node->list, &orig_node->neigh_list);
+	tmp_neigh_node = batadv_neigh_node_get(orig_node, hard_iface,
+					       neigh_addr);
+	if (!tmp_neigh_node) {
+		hlist_add_head_rcu(&neigh_node->list, &orig_node->neigh_list);
+	} else {
+		kfree(neigh_node);
+		batadv_hardif_free_ref(hard_iface);
+		neigh_node = tmp_neigh_node;
+	}
 	spin_unlock_bh(&orig_node->neigh_list_lock);
 
+	if (!tmp_neigh_node)
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
+			   "Creating new neighbor %pM for orig_node %pM on interface %s\n",
+			   neigh_addr, orig_node->orig,
+			   hard_iface->net_dev->name);
+
 out:
 	return neigh_node;
 }
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 6df12a2..8539416 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -458,6 +458,42 @@ out:
 }
 
 /**
+ * batadv_neigh_node_get - retrieve a neighbour from the list
+ * @orig_node: originator which the neighbour belongs to
+ * @hard_iface: the interface where this neighbour is connected to
+ * @addr: the address of the neighbour
+ *
+ * Looks for and possibly returns a neighbour belonging to this originator list
+ * which is connected through the provided hard interface.
+ * Returns NULL if the neighbour is not found.
+ */
+struct batadv_neigh_node *
+batadv_neigh_node_get(const struct batadv_orig_node *orig_node,
+		      const struct batadv_hard_iface *hard_iface,
+		      const uint8_t *addr)
+{
+	struct batadv_neigh_node *tmp_neigh_node, *res = NULL;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(tmp_neigh_node, &orig_node->neigh_list, list) {
+		if (!batadv_compare_eth(tmp_neigh_node->addr, addr))
+			continue;
+
+		if (tmp_neigh_node->if_incoming != hard_iface)
+			continue;
+
+		if (!atomic_inc_not_zero(&tmp_neigh_node->refcount))
+			continue;
+
+		res = tmp_neigh_node;
+		break;
+	}
+	rcu_read_unlock();
+
+	return res;
+}
+
+/**
  * batadv_orig_ifinfo_free_rcu - free the orig_ifinfo object
  * @rcu: rcu pointer of the orig_ifinfo object
  */
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
index 37be290..db3a9ed 100644
--- a/net/batman-adv/originator.h
+++ b/net/batman-adv/originator.h
@@ -29,6 +29,10 @@ void batadv_orig_node_free_ref_now(struct batadv_orig_node *orig_node);
 struct batadv_orig_node *batadv_orig_node_new(struct batadv_priv *bat_priv,
 					      const uint8_t *addr);
 struct batadv_neigh_node *
+batadv_neigh_node_get(const struct batadv_orig_node *orig_node,
+		      const struct batadv_hard_iface *hard_iface,
+		      const uint8_t *addr);
+struct batadv_neigh_node *
 batadv_neigh_node_new(struct batadv_hard_iface *hard_iface,
 		      const uint8_t *neigh_addr,
 		      struct batadv_orig_node *orig_node);
-- 
1.8.5.3
