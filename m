From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 12/18] batman-adv: make the AP isolation attribute VLAN specific
Date: Sun, 20 Oct 2013 00:22:04 +0200
Message-ID: <1382221330-3769-13-git-send-email-antonio@meshcoding.com>
References: <1382221330-3769-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:9918 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754022Ab3JSWl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Oct 2013 18:41:27 -0400
In-Reply-To: <1382221330-3769-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

AP isolation has to be enabled on one VLAN interface only.
This patch moves the AP isolation attribute to the per-vlan
interface attribute set, enabling it to have a different
value depending on the selected vlan.

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 Documentation/ABI/testing/sysfs-class-net-mesh |  5 +++--
 net/batman-adv/soft-interface.c                |  6 ++++--
 net/batman-adv/sysfs.c                         |  5 +++--
 net/batman-adv/translation-table.c             | 27 +++++++++++++++++++-------
 net/batman-adv/translation-table.h             |  2 +-
 net/batman-adv/types.h                         |  4 ++--
 6 files changed, 33 insertions(+), 16 deletions(-)

diff --git a/Documentation/ABI/testing/sysfs-class-net-mesh b/Documentation/ABI/testing/sysfs-class-net-mesh
index dfdea2b..0baa657 100644
--- a/Documentation/ABI/testing/sysfs-class-net-mesh
+++ b/Documentation/ABI/testing/sysfs-class-net-mesh
@@ -6,13 +6,14 @@ Description:
                 Indicates whether the batman protocol messages of the
                 mesh <mesh_iface> shall be aggregated or not.
 
-What:           /sys/class/net/<mesh_iface>/mesh/ap_isolation
+What:           /sys/class/net/<mesh_iface>/mesh/<vlan_subdir>/ap_isolation
 Date:           May 2011
 Contact:        Antonio Quartulli <antonio@meshcoding.com>
 Description:
                 Indicates whether the data traffic going from a
                 wireless client to another wireless client will be
-                silently dropped.
+                silently dropped. <vlan_subdir> is empty when referring
+		to the untagged lan.
 
 What:           /sys/class/net/<mesh_iface>/mesh/bonding
 Date:           June 2010
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index f74200c..baa74b9 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -381,7 +381,8 @@ void batadv_interface_rx(struct net_device *soft_iface,
 		batadv_tt_add_temporary_global_entry(bat_priv, orig_node,
 						     ethhdr->h_source, vid);
 
-	if (batadv_is_ap_isolated(bat_priv, ethhdr->h_source, ethhdr->h_dest))
+	if (batadv_is_ap_isolated(bat_priv, ethhdr->h_source, ethhdr->h_dest,
+				  vid))
 		goto dropped;
 
 	netif_rx(skb);
@@ -458,6 +459,8 @@ int batadv_softif_create_vlan(struct batadv_priv *bat_priv, unsigned short vid)
 	vlan->vid = vid;
 	atomic_set(&vlan->refcount, 1);
 
+	atomic_set(&vlan->ap_isolation, 0);
+
 	err = batadv_sysfs_add_vlan(bat_priv->soft_iface, vlan);
 	if (err) {
 		kfree(vlan);
@@ -657,7 +660,6 @@ static int batadv_softif_init_late(struct net_device *dev)
 #ifdef CONFIG_BATMAN_ADV_DAT
 	atomic_set(&bat_priv->distributed_arp_table, 1);
 #endif
-	atomic_set(&bat_priv->ap_isolation, 0);
 	atomic_set(&bat_priv->gw_mode, BATADV_GW_MODE_OFF);
 	atomic_set(&bat_priv->gw_sel_class, 20);
 	atomic_set(&bat_priv->gw.bandwidth_down, 100);
diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index f419d21..6335433 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -453,7 +453,6 @@ BATADV_ATTR_SIF_BOOL(distributed_arp_table, S_IRUGO | S_IWUSR,
 		     batadv_dat_status_update);
 #endif
 BATADV_ATTR_SIF_BOOL(fragmentation, S_IRUGO | S_IWUSR, batadv_update_min_mtu);
-BATADV_ATTR_SIF_BOOL(ap_isolation, S_IRUGO | S_IWUSR, NULL);
 static BATADV_ATTR(routing_algo, S_IRUGO, batadv_show_bat_algo, NULL);
 static BATADV_ATTR(gw_mode, S_IRUGO | S_IWUSR, batadv_show_gw_mode,
 		   batadv_store_gw_mode);
@@ -483,7 +482,6 @@ static struct batadv_attribute *batadv_mesh_attrs[] = {
 	&batadv_attr_distributed_arp_table,
 #endif
 	&batadv_attr_fragmentation,
-	&batadv_attr_ap_isolation,
 	&batadv_attr_routing_algo,
 	&batadv_attr_gw_mode,
 	&batadv_attr_orig_interval,
@@ -499,10 +497,13 @@ static struct batadv_attribute *batadv_mesh_attrs[] = {
 	NULL,
 };
 
+BATADV_ATTR_VLAN_BOOL(ap_isolation, S_IRUGO | S_IWUSR, NULL);
+
 /**
  * batadv_vlan_attrs - array of vlan specific sysfs attributes
  */
 static struct batadv_attribute *batadv_vlan_attrs[] = {
+	&batadv_attr_vlan_ap_isolation,
 	NULL,
 };
 
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 9bf928c..58794c4 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -1482,8 +1482,19 @@ struct batadv_orig_node *batadv_transtable_search(struct batadv_priv *bat_priv,
 	struct batadv_tt_global_entry *tt_global_entry = NULL;
 	struct batadv_orig_node *orig_node = NULL;
 	struct batadv_tt_orig_list_entry *best_entry;
+	bool ap_isolation_enabled = false;
+	struct batadv_softif_vlan *vlan;
 
-	if (src && atomic_read(&bat_priv->ap_isolation)) {
+	/* if the AP isolation is requested on a VLAN, then check for its
+	 * setting in the proper VLAN private data structure
+	 */
+	vlan = batadv_softif_vlan_get(bat_priv, vid);
+	if (vlan) {
+		ap_isolation_enabled = atomic_read(&vlan->ap_isolation);
+		batadv_softif_vlan_free_ref(vlan);
+	}
+
+	if (src && ap_isolation_enabled) {
 		tt_local_entry = batadv_tt_local_hash_find(bat_priv, src, vid);
 		if (!tt_local_entry ||
 		    (tt_local_entry->common.flags & BATADV_TT_CLIENT_PENDING))
@@ -2547,22 +2558,22 @@ void batadv_tt_local_commit_changes(struct batadv_priv *bat_priv)
 }
 
 bool batadv_is_ap_isolated(struct batadv_priv *bat_priv, uint8_t *src,
-			   uint8_t *dst)
+			   uint8_t *dst, unsigned short vid)
 {
 	struct batadv_tt_local_entry *tt_local_entry = NULL;
 	struct batadv_tt_global_entry *tt_global_entry = NULL;
+	struct batadv_softif_vlan *vlan;
 	bool ret = false;
 
-	if (!atomic_read(&bat_priv->ap_isolation))
+	vlan = batadv_softif_vlan_get(bat_priv, vid);
+	if (!vlan || !atomic_read(&vlan->ap_isolation))
 		goto out;
 
-	tt_local_entry = batadv_tt_local_hash_find(bat_priv, dst,
-						   BATADV_NO_FLAGS);
+	tt_local_entry = batadv_tt_local_hash_find(bat_priv, dst, vid);
 	if (!tt_local_entry)
 		goto out;
 
-	tt_global_entry = batadv_tt_global_hash_find(bat_priv, src,
-						     BATADV_NO_FLAGS);
+	tt_global_entry = batadv_tt_global_hash_find(bat_priv, src, vid);
 	if (!tt_global_entry)
 		goto out;
 
@@ -2572,6 +2583,8 @@ bool batadv_is_ap_isolated(struct batadv_priv *bat_priv, uint8_t *src,
 	ret = true;
 
 out:
+	if (vlan)
+		batadv_softif_vlan_free_ref(vlan);
 	if (tt_global_entry)
 		batadv_tt_global_entry_free_ref(tt_global_entry);
 	if (tt_local_entry)
diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/translation-table.h
index 1d9506d..c6bf33c 100644
--- a/net/batman-adv/translation-table.h
+++ b/net/batman-adv/translation-table.h
@@ -39,7 +39,7 @@ void batadv_tt_free(struct batadv_priv *bat_priv);
 bool batadv_is_my_client(struct batadv_priv *bat_priv, const uint8_t *addr,
 			 unsigned short vid);
 bool batadv_is_ap_isolated(struct batadv_priv *bat_priv, uint8_t *src,
-			   uint8_t *dst);
+			   uint8_t *dst, unsigned short vid);
 void batadv_tt_local_commit_changes(struct batadv_priv *bat_priv);
 bool batadv_tt_global_client_is_roaming(struct batadv_priv *bat_priv,
 					uint8_t *addr, unsigned short vid);
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index e5fecd4..04a0da6 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -534,6 +534,7 @@ struct batadv_priv_nc {
  * struct batadv_softif_vlan - per VLAN attributes set
  * @vid: VLAN identifier
  * @kobj: kobject for sysfs vlan subdirectory
+ * @ap_isolation: AP isolation state
  * @list: list node for bat_priv::softif_vlan_list
  * @refcount: number of context where this object is currently in use
  * @rcu: struct used for freeing in a RCU-safe manner
@@ -541,6 +542,7 @@ struct batadv_priv_nc {
 struct batadv_softif_vlan {
 	unsigned short vid;
 	struct kobject *kobj;
+	atomic_t ap_isolation;		/* boolean */
 	struct hlist_node list;
 	atomic_t refcount;
 	struct rcu_head rcu;
@@ -556,7 +558,6 @@ struct batadv_softif_vlan {
  * @bonding: bool indicating whether traffic bonding is enabled
  * @fragmentation: bool indicating whether traffic fragmentation is enabled
  * @frag_seqno: incremental counter to identify chains of egress fragments
- * @ap_isolation: bool indicating whether ap isolation is enabled
  * @bridge_loop_avoidance: bool indicating whether bridge loop avoidance is
  *  enabled
  * @distributed_arp_table: bool indicating whether distributed ARP table is
@@ -603,7 +604,6 @@ struct batadv_priv {
 	atomic_t bonding;
 	atomic_t fragmentation;
 	atomic_t frag_seqno;
-	atomic_t ap_isolation;
 #ifdef CONFIG_BATMAN_ADV_BLA
 	atomic_t bridge_loop_avoidance;
 #endif
-- 
1.8.4
