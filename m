From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 03/12] batman-adv: add list of unique single hop neighbors per hard-interface
Date: Wed, 16 Dec 2015 15:49:24 +0800
Message-ID: <1450252173-20949-4-git-send-email-antonio@meshcoding.com>
References: <1450252173-20949-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:23667 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933692AbbLPHvP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Dec 2015 02:51:15 -0500
In-Reply-To: <1450252173-20949-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <mareklindner@neomailbox.ch>

Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/hard-interface.c |   4 +
 net/batman-adv/originator.c     | 157 ++++++++++++++++++++++++++++++++++++++++
 net/batman-adv/originator.h     |   5 ++
 net/batman-adv/types.h          |  22 ++++++
 4 files changed, 188 insertions(+)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index a58184f..01acccc 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -32,6 +32,7 @@
 #include <linux/rculist.h>
 #include <linux/rtnetlink.h>
 #include <linux/slab.h>
+#include <linux/spinlock.h>
 #include <linux/workqueue.h>
 #include <net/net_namespace.h>
 
@@ -639,9 +640,12 @@ batadv_hardif_add_interface(struct net_device *net_dev)
 		goto free_sysfs;
 
 	INIT_LIST_HEAD(&hard_iface->list);
+	INIT_HLIST_HEAD(&hard_iface->neigh_list);
 	INIT_WORK(&hard_iface->cleanup_work,
 		  batadv_hardif_remove_interface_finish);
 
+	spin_lock_init(&hard_iface->neigh_list_lock);
+
 	hard_iface->num_bcasts = BATADV_NUM_BCASTS_DEFAULT;
 	if (batadv_is_wifi_netdev(net_dev))
 		hard_iface->num_bcasts = BATADV_NUM_BCASTS_WIRELESS;
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 7486df9..a8671c6 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -202,6 +202,47 @@ void batadv_neigh_ifinfo_free_ref(struct batadv_neigh_ifinfo *neigh_ifinfo)
 }
 
 /**
+ * batadv_hardif_neigh_free_rcu - free the hardif neigh_node
+ * @rcu: rcu pointer of the neigh_node
+ */
+static void batadv_hardif_neigh_free_rcu(struct rcu_head *rcu)
+{
+	struct batadv_hardif_neigh_node *hardif_neigh;
+
+	hardif_neigh = container_of(rcu, struct batadv_hardif_neigh_node, rcu);
+
+	spin_lock_bh(&hardif_neigh->if_incoming->neigh_list_lock);
+	hlist_del_init_rcu(&hardif_neigh->list);
+	spin_unlock_bh(&hardif_neigh->if_incoming->neigh_list_lock);
+
+	batadv_hardif_free_ref_now(hardif_neigh->if_incoming);
+	kfree(hardif_neigh);
+}
+
+/**
+ * batadv_hardif_neigh_free_now - decrement the hardif neighbors refcounter
+ *  and possibly free it (without rcu callback)
+ * @hardif_neigh: hardif neigh neighbor to free
+ */
+static void
+batadv_hardif_neigh_free_now(struct batadv_hardif_neigh_node *hardif_neigh)
+{
+	if (atomic_dec_and_test(&hardif_neigh->refcount))
+		batadv_hardif_neigh_free_rcu(&hardif_neigh->rcu);
+}
+
+/**
+ * batadv_hardif_neigh_free_ref - decrement the hardif neighbors refcounter
+ *  and possibly free it
+ * @hardif_neigh: hardif neigh neighbor to free
+ */
+void batadv_hardif_neigh_free_ref(struct batadv_hardif_neigh_node *hardif_neigh)
+{
+	if (atomic_dec_and_test(&hardif_neigh->refcount))
+		call_rcu(&hardif_neigh->rcu, batadv_hardif_neigh_free_rcu);
+}
+
+/**
  * batadv_neigh_node_free_rcu - free the neigh_node
  * @rcu: rcu pointer of the neigh_node
  */
@@ -209,6 +250,7 @@ static void batadv_neigh_node_free_rcu(struct rcu_head *rcu)
 {
 	struct hlist_node *node_tmp;
 	struct batadv_neigh_node *neigh_node;
+	struct batadv_hardif_neigh_node *hardif_neigh;
 	struct batadv_neigh_ifinfo *neigh_ifinfo;
 	struct batadv_algo_ops *bao;
 
@@ -220,6 +262,14 @@ static void batadv_neigh_node_free_rcu(struct rcu_head *rcu)
 		batadv_neigh_ifinfo_free_ref_now(neigh_ifinfo);
 	}
 
+	hardif_neigh = batadv_hardif_neigh_get(neigh_node->if_incoming,
+					       neigh_node->addr);
+	if (hardif_neigh) {
+		/* batadv_hardif_neigh_get() increases refcount too */
+		batadv_hardif_neigh_free_now(hardif_neigh);
+		batadv_hardif_neigh_free_now(hardif_neigh);
+	}
+
 	if (bao->bat_neigh_free)
 		bao->bat_neigh_free(neigh_node);
 
@@ -479,6 +529,102 @@ batadv_neigh_node_get(const struct batadv_orig_node *orig_node,
 }
 
 /**
+ * batadv_hardif_neigh_create - create a hardif neighbour node
+ * @hard_iface: the interface this neighbour is connected to
+ * @neigh_addr: the interface address of the neighbour to retrieve
+ *
+ * Returns the hardif neighbour node if found or created or NULL otherwise.
+ */
+static struct batadv_hardif_neigh_node *
+batadv_hardif_neigh_create(struct batadv_hard_iface *hard_iface,
+			   const u8 *neigh_addr)
+{
+	struct batadv_hardif_neigh_node *hardif_neigh = NULL;
+
+	spin_lock_bh(&hard_iface->neigh_list_lock);
+
+	/* check if neighbor hasn't been added in the meantime */
+	hardif_neigh = batadv_hardif_neigh_get(hard_iface, neigh_addr);
+	if (hardif_neigh)
+		goto out;
+
+	if (!atomic_inc_not_zero(&hard_iface->refcount))
+		goto out;
+
+	hardif_neigh = kzalloc(sizeof(*hardif_neigh), GFP_ATOMIC);
+	if (!hardif_neigh) {
+		batadv_hardif_free_ref(hard_iface);
+		goto out;
+	}
+
+	INIT_HLIST_NODE(&hardif_neigh->list);
+	ether_addr_copy(hardif_neigh->addr, neigh_addr);
+	hardif_neigh->if_incoming = hard_iface;
+	hardif_neigh->last_seen = jiffies;
+
+	atomic_set(&hardif_neigh->refcount, 1);
+
+	hlist_add_head(&hardif_neigh->list, &hard_iface->neigh_list);
+
+out:
+	spin_unlock_bh(&hard_iface->neigh_list_lock);
+	return hardif_neigh;
+}
+
+/**
+ * batadv_hardif_neigh_get_or_create - retrieve or create a hardif neighbour
+ *  node
+ * @hard_iface: the interface this neighbour is connected to
+ * @neigh_addr: the interface address of the neighbour to retrieve
+ *
+ * Returns the hardif neighbour node if found or created or NULL otherwise.
+ */
+static struct batadv_hardif_neigh_node *
+batadv_hardif_neigh_get_or_create(struct batadv_hard_iface *hard_iface,
+				  const u8 *neigh_addr)
+{
+	struct batadv_hardif_neigh_node *hardif_neigh = NULL;
+
+	/* first check without locking to avoid the overhead */
+	hardif_neigh = batadv_hardif_neigh_get(hard_iface, neigh_addr);
+	if (hardif_neigh)
+		return hardif_neigh;
+
+	return batadv_hardif_neigh_create(hard_iface, neigh_addr);
+}
+
+/**
+ * batadv_hardif_neigh_get - retrieve a hardif neighbour from the list
+ * @hard_iface: the interface where this neighbour is connected to
+ * @neigh_addr: the address of the neighbour
+ *
+ * Looks for and possibly returns a neighbour belonging to this hard interface.
+ * Returns NULL if the neighbour is not found.
+ */
+struct batadv_hardif_neigh_node *
+batadv_hardif_neigh_get(const struct batadv_hard_iface *hard_iface,
+			const u8 *neigh_addr)
+{
+	struct batadv_hardif_neigh_node *tmp_hardif_neigh, *hardif_neigh = NULL;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(tmp_hardif_neigh,
+				 &hard_iface->neigh_list, list) {
+		if (!batadv_compare_eth(tmp_hardif_neigh->addr, neigh_addr))
+			continue;
+
+		if (!atomic_inc_not_zero(&tmp_hardif_neigh->refcount))
+			continue;
+
+		hardif_neigh = tmp_hardif_neigh;
+		break;
+	}
+	rcu_read_unlock();
+
+	return hardif_neigh;
+}
+
+/**
  * batadv_neigh_node_new - create and init a new neigh_node object
  * @orig_node: originator object representing the neighbour
  * @hard_iface: the interface where the neighbour is connected to
@@ -493,11 +639,17 @@ batadv_neigh_node_new(struct batadv_orig_node *orig_node,
 		      const u8 *neigh_addr)
 {
 	struct batadv_neigh_node *neigh_node;
+	struct batadv_hardif_neigh_node *hardif_neigh = NULL;
 
 	neigh_node = batadv_neigh_node_get(orig_node, hard_iface, neigh_addr);
 	if (neigh_node)
 		goto out;
 
+	hardif_neigh = batadv_hardif_neigh_get_or_create(hard_iface,
+							 neigh_addr);
+	if (!hardif_neigh)
+		goto out;
+
 	neigh_node = kzalloc(sizeof(*neigh_node), GFP_ATOMIC);
 	if (!neigh_node)
 		goto out;
@@ -523,11 +675,16 @@ batadv_neigh_node_new(struct batadv_orig_node *orig_node,
 	hlist_add_head_rcu(&neigh_node->list, &orig_node->neigh_list);
 	spin_unlock_bh(&orig_node->neigh_list_lock);
 
+	/* increment unique neighbor refcount */
+	atomic_inc(&hardif_neigh->refcount);
+
 	batadv_dbg(BATADV_DBG_BATMAN, orig_node->bat_priv,
 		   "Creating new neighbor %pM for orig_node %pM on interface %s\n",
 		   neigh_addr, orig_node->orig, hard_iface->net_dev->name);
 
 out:
+	if (hardif_neigh)
+		batadv_hardif_neigh_free_ref(hardif_neigh);
 	return neigh_node;
 }
 
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
index fa18f9b..eae0557 100644
--- a/net/batman-adv/originator.h
+++ b/net/batman-adv/originator.h
@@ -41,6 +41,11 @@ void batadv_orig_node_free_ref(struct batadv_orig_node *orig_node);
 void batadv_orig_node_free_ref_now(struct batadv_orig_node *orig_node);
 struct batadv_orig_node *batadv_orig_node_new(struct batadv_priv *bat_priv,
 					      const u8 *addr);
+struct batadv_hardif_neigh_node *
+batadv_hardif_neigh_get(const struct batadv_hard_iface *hard_iface,
+			const u8 *neigh_addr);
+void
+batadv_hardif_neigh_free_ref(struct batadv_hardif_neigh_node *hardif_neigh);
 struct batadv_neigh_node *
 batadv_neigh_node_new(struct batadv_orig_node *orig_node,
 		      struct batadv_hard_iface *hard_iface,
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index d260efd..71c7d9f 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -100,6 +100,8 @@ struct batadv_hard_iface_bat_iv {
  * @bat_iv: BATMAN IV specific per hard interface data
  * @cleanup_work: work queue callback item for hard interface deinit
  * @debug_dir: dentry for nc subdir in batman-adv directory in debugfs
+ * @neigh_list: list of unique single hop neighbors via this interface
+ * @neigh_list_lock: lock protecting neigh_list
  */
 struct batadv_hard_iface {
 	struct list_head list;
@@ -115,6 +117,9 @@ struct batadv_hard_iface {
 	struct batadv_hard_iface_bat_iv bat_iv;
 	struct work_struct cleanup_work;
 	struct dentry *debug_dir;
+	struct hlist_head neigh_list;
+	/* neigh_list_lock protects: neigh_list */
+	spinlock_t neigh_list_lock;
 };
 
 /**
@@ -341,6 +346,23 @@ struct batadv_gw_node {
 };
 
 /**
+ * batadv_hardif_neigh_node - unique neighbor per hard interface
+ * @list: list node for batadv_hard_iface::neigh_list
+ * @addr: the MAC address of the neighboring interface
+ * @if_incoming: pointer to incoming hard interface
+ * @refcount: number of contexts the object is used
+ * @rcu: struct used for freeing in a RCU-safe manner
+ */
+struct batadv_hardif_neigh_node {
+	struct hlist_node list;
+	u8 addr[ETH_ALEN];
+	struct batadv_hard_iface *if_incoming;
+	unsigned long last_seen;
+	atomic_t refcount;
+	struct rcu_head rcu;
+};
+
+/**
  * struct batadv_neigh_node - structure for single hops neighbors
  * @list: list node for batadv_orig_node::neigh_list
  * @orig_node: pointer to corresponding orig_node
-- 
2.6.4
