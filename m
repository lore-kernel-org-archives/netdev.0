From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 10/18] batman-adv: add per VLAN interface attribute framework
Date: Sun, 20 Oct 2013 00:22:02 +0200
Message-ID: <1382221330-3769-11-git-send-email-antonio@meshcoding.com>
References: <1382221330-3769-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:38252 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753737Ab3JSWli (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Oct 2013 18:41:38 -0400
In-Reply-To: <1382221330-3769-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

Since batman-adv is now fully VLAN-aware, a proper framework
able to handle per-vlan-interface attributes is needed.

Those attributes will affect the associated VLAN interface
only, rather than the real soft_iface (which would result
in every vlan interface having the same attribute
configuration).

To make the code simpler and easier to extend, attributes
associated to the standalone soft_iface are now treated
like belonging to yet another vlan having a special vid.
This vid is different from the others because it is made up
by all zeros and the VLAN_HAS_TAG bit is not set.

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/hard-interface.c |   2 +
 net/batman-adv/main.c           |   5 +-
 net/batman-adv/soft-interface.c | 171 ++++++++++++++++++++++++++++++++++++++++
 net/batman-adv/soft-interface.h |   1 +
 net/batman-adv/types.h          |  21 +++++
 5 files changed, 197 insertions(+), 3 deletions(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index d564af2..c5f871f 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -643,6 +643,8 @@ static int batadv_hard_if_event(struct notifier_block *this,
 
 	if (batadv_softif_is_valid(net_dev) && event == NETDEV_REGISTER) {
 		batadv_sysfs_add_meshif(net_dev);
+		bat_priv = netdev_priv(net_dev);
+		batadv_softif_create_vlan(bat_priv, BATADV_NO_FLAGS);
 		return NOTIFY_DONE;
 	}
 
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 80f60d1..2207551 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -113,6 +113,7 @@ int batadv_mesh_init(struct net_device *soft_iface)
 	spin_lock_init(&bat_priv->gw.list_lock);
 	spin_lock_init(&bat_priv->tvlv.container_list_lock);
 	spin_lock_init(&bat_priv->tvlv.handler_list_lock);
+	spin_lock_init(&bat_priv->softif_vlan_list_lock);
 
 	INIT_HLIST_HEAD(&bat_priv->forw_bat_list);
 	INIT_HLIST_HEAD(&bat_priv->forw_bcast_list);
@@ -122,6 +123,7 @@ int batadv_mesh_init(struct net_device *soft_iface)
 	INIT_LIST_HEAD(&bat_priv->tt.roam_list);
 	INIT_HLIST_HEAD(&bat_priv->tvlv.container_list);
 	INIT_HLIST_HEAD(&bat_priv->tvlv.handler_list);
+	INIT_HLIST_HEAD(&bat_priv->softif_vlan_list);
 
 	ret = batadv_originator_init(bat_priv);
 	if (ret < 0)
@@ -131,9 +133,6 @@ int batadv_mesh_init(struct net_device *soft_iface)
 	if (ret < 0)
 		goto err;
 
-	batadv_tt_local_add(soft_iface, soft_iface->dev_addr,
-			    BATADV_NO_FLAGS, BATADV_NULL_IFINDEX);
-
 	ret = batadv_bla_init(bat_priv);
 	if (ret < 0)
 		goto err;
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 279e91d..936b83b 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -393,6 +393,166 @@ out:
 	return;
 }
 
+/**
+ * batadv_softif_vlan_free_ref - decrease the vlan object refcounter and
+ *  possibly free it
+ * @softif_vlan: the vlan object to release
+ */
+static void batadv_softif_vlan_free_ref(struct batadv_softif_vlan *softif_vlan)
+{
+	if (atomic_dec_and_test(&softif_vlan->refcount))
+		kfree_rcu(softif_vlan, rcu);
+}
+
+/**
+ * batadv_softif_vlan_get - get the vlan object for a specific vid
+ * @bat_priv: the bat priv with all the soft interface information
+ * @vid: the identifier of the vlan object to retrieve
+ *
+ * Returns the private data of the vlan matching the vid passed as argument or
+ * NULL otherwise. The refcounter of the returned object is incremented by 1.
+ */
+static struct batadv_softif_vlan *
+batadv_softif_vlan_get(struct batadv_priv *bat_priv, unsigned short vid)
+{
+	struct batadv_softif_vlan *vlan_tmp, *vlan = NULL;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(vlan_tmp, &bat_priv->softif_vlan_list, list) {
+		if (vlan_tmp->vid != vid)
+			continue;
+
+		if (!atomic_inc_not_zero(&vlan_tmp->refcount))
+			continue;
+
+		vlan = vlan_tmp;
+		break;
+	}
+	rcu_read_unlock();
+
+	return vlan;
+}
+
+/**
+ * batadv_create_vlan - allocate the needed resources for a new vlan
+ * @bat_priv: the bat priv with all the soft interface information
+ * @vid: the VLAN identifier
+ *
+ * Returns 0 on success, a negative error otherwise.
+ */
+int batadv_softif_create_vlan(struct batadv_priv *bat_priv, unsigned short vid)
+{
+	struct batadv_softif_vlan *vlan;
+
+	vlan = batadv_softif_vlan_get(bat_priv, vid);
+	if (vlan) {
+		batadv_softif_vlan_free_ref(vlan);
+		return -EEXIST;
+	}
+
+	vlan = kzalloc(sizeof(*vlan), GFP_ATOMIC);
+	if (!vlan)
+		return -ENOMEM;
+
+	vlan->vid = vid;
+	atomic_set(&vlan->refcount, 1);
+
+	/* add a new TT local entry. This one will be marked with the NOPURGE
+	 * flag
+	 */
+	batadv_tt_local_add(bat_priv->soft_iface,
+			    bat_priv->soft_iface->dev_addr, vid,
+			    BATADV_NULL_IFINDEX);
+
+	spin_lock_bh(&bat_priv->softif_vlan_list_lock);
+	hlist_add_head_rcu(&vlan->list, &bat_priv->softif_vlan_list);
+	spin_unlock_bh(&bat_priv->softif_vlan_list_lock);
+
+	return 0;
+}
+
+/**
+ * batadv_softif_destroy_vlan - remove and destroy a softif_vlan object
+ * @bat_priv: the bat priv with all the soft interface information
+ * @vlan: the object to remove
+ */
+static void batadv_softif_destroy_vlan(struct batadv_priv *bat_priv,
+				       struct batadv_softif_vlan *vlan)
+{
+	spin_lock_bh(&bat_priv->softif_vlan_list_lock);
+	hlist_del_rcu(&vlan->list);
+	spin_unlock_bh(&bat_priv->softif_vlan_list_lock);
+
+	/* explicitly remove the associated TT local entry because it is marked
+	 * with the NOPURGE flag
+	 */
+	batadv_tt_local_remove(bat_priv, bat_priv->soft_iface->dev_addr,
+			       vlan->vid, "vlan interface destroyed", false);
+
+	batadv_softif_vlan_free_ref(vlan);
+}
+
+/**
+ * batadv_interface_add_vid - ndo_add_vid API implementation
+ * @dev: the netdev of the mesh interface
+ * @vid: identifier of the new vlan
+ *
+ * Set up all the internal structures for handling the new vlan on top of the
+ * mesh interface
+ *
+ * Returns 0 on success or a negative error code in case of failure.
+ */
+static int batadv_interface_add_vid(struct net_device *dev, __be16 proto,
+				    unsigned short vid)
+{
+	struct batadv_priv *bat_priv = netdev_priv(dev);
+
+	/* only 802.1Q vlans are supported.
+	 * batman-adv does not know how to handle other types
+	 */
+	if (proto != htons(ETH_P_8021Q))
+		return -EINVAL;
+
+	vid |= BATADV_VLAN_HAS_TAG;
+
+	return batadv_softif_create_vlan(bat_priv, vid);
+}
+
+/**
+ * batadv_interface_kill_vid - ndo_kill_vid API implementation
+ * @dev: the netdev of the mesh interface
+ * @vid: identifier of the deleted vlan
+ *
+ * Destroy all the internal structures used to handle the vlan identified by vid
+ * on top of the mesh interface
+ *
+ * Returns 0 on success, -EINVAL if the specified prototype is not ETH_P_8021Q
+ * or -ENOENT if the specified vlan id wasn't registered.
+ */
+static int batadv_interface_kill_vid(struct net_device *dev, __be16 proto,
+				     unsigned short vid)
+{
+	struct batadv_priv *bat_priv = netdev_priv(dev);
+	struct batadv_softif_vlan *vlan;
+
+	/* only 802.1Q vlans are supported. batman-adv does not know how to
+	 * handle other types
+	 */
+	if (proto != htons(ETH_P_8021Q))
+		return -EINVAL;
+
+	vlan = batadv_softif_vlan_get(bat_priv, vid | BATADV_VLAN_HAS_TAG);
+	if (!vlan)
+		return -ENOENT;
+
+	batadv_softif_destroy_vlan(bat_priv, vlan);
+
+	/* finally free the vlan object */
+	batadv_softif_vlan_free_ref(vlan);
+
+	return 0;
+}
+
 /* batman-adv network devices have devices nesting below it and are a special
  * "super class" of normal network devices; split their locks off into a
  * separate class since they always nest.
@@ -432,6 +592,7 @@ static void batadv_set_lockdep_class(struct net_device *dev)
  */
 static void batadv_softif_destroy_finish(struct work_struct *work)
 {
+	struct batadv_softif_vlan *vlan;
 	struct batadv_priv *bat_priv;
 	struct net_device *soft_iface;
 
@@ -439,6 +600,13 @@ static void batadv_softif_destroy_finish(struct work_struct *work)
 				cleanup_work);
 	soft_iface = bat_priv->soft_iface;
 
+	/* destroy the "untagged" VLAN */
+	vlan = batadv_softif_vlan_get(bat_priv, BATADV_NO_FLAGS);
+	if (vlan) {
+		batadv_softif_destroy_vlan(bat_priv, vlan);
+		batadv_softif_vlan_free_ref(vlan);
+	}
+
 	batadv_sysfs_del_meshif(soft_iface);
 
 	rtnl_lock();
@@ -594,6 +762,8 @@ static const struct net_device_ops batadv_netdev_ops = {
 	.ndo_open = batadv_interface_open,
 	.ndo_stop = batadv_interface_release,
 	.ndo_get_stats = batadv_interface_stats,
+	.ndo_vlan_rx_add_vid = batadv_interface_add_vid,
+	.ndo_vlan_rx_kill_vid = batadv_interface_kill_vid,
 	.ndo_set_mac_address = batadv_interface_set_mac_addr,
 	.ndo_change_mtu = batadv_interface_change_mtu,
 	.ndo_set_rx_mode = batadv_interface_set_rx_mode,
@@ -633,6 +803,7 @@ static void batadv_softif_init_early(struct net_device *dev)
 
 	dev->netdev_ops = &batadv_netdev_ops;
 	dev->destructor = batadv_softif_free;
+	dev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
 	dev->tx_queue_len = 0;
 
 	/* can't call min_mtu, because the needed variables
diff --git a/net/batman-adv/soft-interface.h b/net/batman-adv/soft-interface.h
index 2f2472c..16d9be6 100644
--- a/net/batman-adv/soft-interface.h
+++ b/net/batman-adv/soft-interface.h
@@ -28,5 +28,6 @@ struct net_device *batadv_softif_create(const char *name);
 void batadv_softif_destroy_sysfs(struct net_device *soft_iface);
 int batadv_softif_is_valid(const struct net_device *net_dev);
 extern struct rtnl_link_ops batadv_link_ops;
+int batadv_softif_create_vlan(struct batadv_priv *bat_priv, unsigned short vid);
 
 #endif /* _NET_BATMAN_ADV_SOFT_INTERFACE_H_ */
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 6954a5d..e5fecd4 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -531,6 +531,22 @@ struct batadv_priv_nc {
 };
 
 /**
+ * struct batadv_softif_vlan - per VLAN attributes set
+ * @vid: VLAN identifier
+ * @kobj: kobject for sysfs vlan subdirectory
+ * @list: list node for bat_priv::softif_vlan_list
+ * @refcount: number of context where this object is currently in use
+ * @rcu: struct used for freeing in a RCU-safe manner
+ */
+struct batadv_softif_vlan {
+	unsigned short vid;
+	struct kobject *kobj;
+	struct hlist_node list;
+	atomic_t refcount;
+	struct rcu_head rcu;
+};
+
+/**
  * struct batadv_priv - per mesh interface data
  * @mesh_state: current status of the mesh (inactive/active/deactivating)
  * @soft_iface: net device which holds this struct as private data
@@ -566,6 +582,9 @@ struct batadv_priv_nc {
  * @primary_if: one of the hard interfaces assigned to this mesh interface
  *  becomes the primary interface
  * @bat_algo_ops: routing algorithm used by this mesh interface
+ * @softif_vlan_list: a list of softif_vlan structs, one per VLAN created on top
+ *  of the mesh interface represented by this object
+ * @softif_vlan_list_lock: lock protecting softif_vlan_list
  * @bla: bridge loope avoidance data
  * @debug_log: holding debug logging relevant data
  * @gw: gateway data
@@ -613,6 +632,8 @@ struct batadv_priv {
 	struct work_struct cleanup_work;
 	struct batadv_hard_iface __rcu *primary_if;  /* rcu protected pointer */
 	struct batadv_algo_ops *bat_algo_ops;
+	struct hlist_head softif_vlan_list;
+	spinlock_t softif_vlan_list_lock; /* protects softif_vlan_list */
 #ifdef CONFIG_BATMAN_ADV_BLA
 	struct batadv_priv_bla bla;
 #endif
-- 
1.8.4
