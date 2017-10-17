From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: [RFC PATCH next 1/2] i40e: add ToQueue specific handling for mac filters
Date: Tue, 17 Oct 2017 14:18:08 -0700
Message-ID: <1508275089-430113-2-git-send-email-shannon.nelson@oracle.com>
References: <1508275089-430113-1-git-send-email-shannon.nelson@oracle.com>
Cc: netdev@vger.kernel.org
To: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:38759 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S937659AbdJQVVX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 17:21:23 -0400
In-Reply-To: <1508275089-430113-1-git-send-email-shannon.nelson@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the concept of queue-specific filters to the filter handling.  This
will be used in the near future for macvlan offload filters.  In
general, filters for standard use will use a queue of 0, which we'll
take to mean the filter applies to the whole VSI.  Only the filters for
macvlan offload will use a non-zero queue.

Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h             |   17 +++--
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |    4 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        |   72 ++++++++++++-------
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |   10 ++--
 4 files changed, 63 insertions(+), 40 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 18c453a..a187f53 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -539,14 +539,17 @@ struct i40e_pf {
 /**
  * i40e_mac_to_hkey - Convert a 6-byte MAC Address to a u64 hash key
  * @macaddr: the MAC Address as the base key
+ * @queue: if non-zero, the queue to receive packets with this mac address
  *
  * Simply copies the address and returns it as a u64 for hashing
  **/
-static inline u64 i40e_addr_to_hkey(const u8 *macaddr)
+static inline u64 i40e_addr_to_hkey(const u8 *macaddr, u16 queue)
 {
 	u64 key = 0;
+	u16 *k = (u16 *)&key;
 
 	ether_addr_copy((u8 *)&key, macaddr);
+	k[3] = queue;
 	return key;
 }
 
@@ -563,6 +566,7 @@ struct i40e_mac_filter {
 	u8 macaddr[ETH_ALEN];
 #define I40E_VLAN_ANY -1
 	s16 vlan;
+	u16 queue;
 	enum i40e_filter_state state;
 };
 
@@ -892,10 +896,11 @@ int i40e_add_del_fdir(struct i40e_vsi *vsi,
 u32 i40e_get_global_fd_count(struct i40e_pf *pf);
 bool i40e_set_ntuple(struct i40e_pf *pf, netdev_features_t features);
 void i40e_set_ethtool_ops(struct net_device *netdev);
-struct i40e_mac_filter *i40e_add_filter(struct i40e_vsi *vsi,
-					const u8 *macaddr, s16 vlan);
+struct i40e_mac_filter *i40e_add_filter(struct i40e_vsi *vsi, const u8 *macaddr,
+					s16 vlan, u16 queue);
 void __i40e_del_filter(struct i40e_vsi *vsi, struct i40e_mac_filter *f);
-void i40e_del_filter(struct i40e_vsi *vsi, const u8 *macaddr, s16 vlan);
+void i40e_del_filter(struct i40e_vsi *vsi, const u8 *macaddr,
+		     s16 vlan, u16 queue);
 int i40e_sync_vsi_filters(struct i40e_vsi *vsi);
 struct i40e_vsi *i40e_vsi_setup(struct i40e_pf *pf, u8 type,
 				u16 uplink, u32 param1);
@@ -971,8 +976,8 @@ static inline void i40e_irq_dynamic_enable(struct i40e_vsi *vsi, int vector)
 void i40e_rm_vlan_all_mac(struct i40e_vsi *vsi, s16 vid);
 void i40e_vsi_kill_vlan(struct i40e_vsi *vsi, u16 vid);
 struct i40e_mac_filter *i40e_add_mac_filter(struct i40e_vsi *vsi,
-					    const u8 *macaddr);
-int i40e_del_mac_filter(struct i40e_vsi *vsi, const u8 *macaddr);
+					    const u8 *macaddr, u16 queue);
+int i40e_del_mac_filter(struct i40e_vsi *vsi, const u8 *macaddr, u16 queue);
 bool i40e_is_vsi_in_vlan(struct i40e_vsi *vsi);
 struct i40e_mac_filter *i40e_find_mac(struct i40e_vsi *vsi, const u8 *macaddr);
 void i40e_vlan_stripping_enable(struct i40e_vsi *vsi);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index 6f2725f..cf173e1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -171,8 +171,8 @@ static void i40e_dbg_dump_vsi_seid(struct i40e_pf *pf, int seid)
 			 pf->hw.mac.port_addr);
 	hash_for_each(vsi->mac_filter_hash, bkt, f, hlist) {
 		dev_info(&pf->pdev->dev,
-			 "    mac_filter_hash: %pM vid=%d, state %s\n",
-			 f->macaddr, f->vlan,
+			 "    mac_filter_hash: %pM vid=%d q=%d, state %s\n",
+			 f->macaddr, f->vlan, f->queue,
 			 i40e_filter_state_string[f->state]);
 	}
 	dev_info(&pf->pdev->dev, "    active_filters %u, promisc_threshold %u, overflow promisc %s\n",
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 84c5087..e4b8a4b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1114,11 +1114,13 @@ void i40e_update_stats(struct i40e_vsi *vsi)
  * @vsi: the VSI to be searched
  * @macaddr: the MAC address
  * @vlan: the vlan
+ * @queue: the queue
  *
  * Returns ptr to the filter object or NULL
  **/
 static struct i40e_mac_filter *i40e_find_filter(struct i40e_vsi *vsi,
-						const u8 *macaddr, s16 vlan)
+						const u8 *macaddr, s16 vlan,
+						u16 queue)
 {
 	struct i40e_mac_filter *f;
 	u64 key;
@@ -1126,10 +1128,10 @@ void i40e_update_stats(struct i40e_vsi *vsi)
 	if (!vsi || !macaddr)
 		return NULL;
 
-	key = i40e_addr_to_hkey(macaddr);
+	key = i40e_addr_to_hkey(macaddr, queue);
 	hash_for_each_possible(vsi->mac_filter_hash, f, hlist, key) {
 		if ((ether_addr_equal(macaddr, f->macaddr)) &&
-		    (vlan == f->vlan))
+		    (vlan == f->vlan) && (queue == f->queue))
 			return f;
 	}
 	return NULL;
@@ -1151,7 +1153,7 @@ struct i40e_mac_filter *i40e_find_mac(struct i40e_vsi *vsi, const u8 *macaddr)
 	if (!vsi || !macaddr)
 		return NULL;
 
-	key = i40e_addr_to_hkey(macaddr);
+	key = i40e_addr_to_hkey(macaddr, 0);
 	hash_for_each_possible(vsi->mac_filter_hash, f, hlist, key) {
 		if ((ether_addr_equal(macaddr, f->macaddr)))
 			return f;
@@ -1277,7 +1279,8 @@ static int i40e_correct_mac_vlan_filters(struct i40e_vsi *vsi,
 				new_vlan = I40E_VLAN_ANY;
 
 			/* Create the new filter */
-			add_head = i40e_add_filter(vsi, f->macaddr, new_vlan);
+			add_head = i40e_add_filter(vsi, f->macaddr,
+						   new_vlan, f->queue);
 			if (!add_head)
 				return -ENOMEM;
 
@@ -1342,14 +1345,15 @@ static void i40e_rm_default_mac_filter(struct i40e_vsi *vsi, u8 *macaddr)
  * @vsi: the VSI to be searched
  * @macaddr: the MAC address
  * @vlan: the vlan
+ * @queue: if non-zero, the specific queue to receive for this mac address
  *
  * Returns ptr to the filter object or NULL when no memory available.
  *
  * NOTE: This function is expected to be called with mac_filter_hash_lock
  * being held.
  **/
-struct i40e_mac_filter *i40e_add_filter(struct i40e_vsi *vsi,
-					const u8 *macaddr, s16 vlan)
+struct i40e_mac_filter *i40e_add_filter(struct i40e_vsi *vsi, const u8 *macaddr,
+					s16 vlan, u16 queue)
 {
 	struct i40e_mac_filter *f;
 	u64 key;
@@ -1357,7 +1361,7 @@ struct i40e_mac_filter *i40e_add_filter(struct i40e_vsi *vsi,
 	if (!vsi || !macaddr)
 		return NULL;
 
-	f = i40e_find_filter(vsi, macaddr, vlan);
+	f = i40e_find_filter(vsi, macaddr, vlan, queue);
 	if (!f) {
 		f = kzalloc(sizeof(*f), GFP_ATOMIC);
 		if (!f)
@@ -1371,6 +1375,7 @@ struct i40e_mac_filter *i40e_add_filter(struct i40e_vsi *vsi,
 
 		ether_addr_copy(f->macaddr, macaddr);
 		f->vlan = vlan;
+		f->queue = queue;
 		/* If we're in overflow promisc mode, set the state directly
 		 * to failed, so we don't bother to try sending the filter
 		 * to the hardware.
@@ -1381,7 +1386,7 @@ struct i40e_mac_filter *i40e_add_filter(struct i40e_vsi *vsi,
 			f->state = I40E_FILTER_NEW;
 		INIT_HLIST_NODE(&f->hlist);
 
-		key = i40e_addr_to_hkey(macaddr);
+		key = i40e_addr_to_hkey(macaddr, queue);
 		hash_add(vsi->mac_filter_hash, &f->hlist, key);
 
 		vsi->flags |= I40E_VSI_FLAG_FILTER_CHANGED;
@@ -1443,6 +1448,7 @@ void __i40e_del_filter(struct i40e_vsi *vsi, struct i40e_mac_filter *f)
  * @vsi: the VSI to be searched
  * @macaddr: the MAC address
  * @vlan: the VLAN
+ * @queue: if non-zero, the specific queue to receive for this mac address
  *
  * NOTE: This function is expected to be called with mac_filter_hash_lock
  * being held.
@@ -1450,14 +1456,15 @@ void __i40e_del_filter(struct i40e_vsi *vsi, struct i40e_mac_filter *f)
  * the "safe" variants of any list iterators, e.g. list_for_each_entry_safe()
  * instead of list_for_each_entry().
  **/
-void i40e_del_filter(struct i40e_vsi *vsi, const u8 *macaddr, s16 vlan)
+void i40e_del_filter(struct i40e_vsi *vsi, const u8 *macaddr,
+		     s16 vlan, u16 queue)
 {
 	struct i40e_mac_filter *f;
 
 	if (!vsi || !macaddr)
 		return;
 
-	f = i40e_find_filter(vsi, macaddr, vlan);
+	f = i40e_find_filter(vsi, macaddr, vlan, queue);
 	__i40e_del_filter(vsi, f);
 }
 
@@ -1465,6 +1472,7 @@ void i40e_del_filter(struct i40e_vsi *vsi, const u8 *macaddr, s16 vlan)
  * i40e_add_mac_filter - Add a MAC filter for all active VLANs
  * @vsi: the VSI to be searched
  * @macaddr: the mac address to be filtered
+ * @queue: if non-zero, the target ToQueue
  *
  * If we're not in VLAN mode, just add the filter to I40E_VLAN_ANY. Otherwise,
  * go through all the macvlan filters and add a macvlan filter for each
@@ -1474,7 +1482,7 @@ void i40e_del_filter(struct i40e_vsi *vsi, const u8 *macaddr, s16 vlan)
  * Returns last filter added on success, else NULL
  **/
 struct i40e_mac_filter *i40e_add_mac_filter(struct i40e_vsi *vsi,
-					    const u8 *macaddr)
+					    const u8 *macaddr, u16 queue)
 {
 	struct i40e_mac_filter *f, *add = NULL;
 	struct hlist_node *h;
@@ -1482,15 +1490,15 @@ struct i40e_mac_filter *i40e_add_mac_filter(struct i40e_vsi *vsi,
 
 	if (vsi->info.pvid)
 		return i40e_add_filter(vsi, macaddr,
-				       le16_to_cpu(vsi->info.pvid));
+				       le16_to_cpu(vsi->info.pvid), queue);
 
 	if (!i40e_is_vsi_in_vlan(vsi))
-		return i40e_add_filter(vsi, macaddr, I40E_VLAN_ANY);
+		return i40e_add_filter(vsi, macaddr, I40E_VLAN_ANY, queue);
 
 	hash_for_each_safe(vsi->mac_filter_hash, bkt, h, f, hlist) {
 		if (f->state == I40E_FILTER_REMOVE)
 			continue;
-		add = i40e_add_filter(vsi, macaddr, f->vlan);
+		add = i40e_add_filter(vsi, macaddr, f->vlan, queue);
 		if (!add)
 			return NULL;
 	}
@@ -1502,13 +1510,14 @@ struct i40e_mac_filter *i40e_add_mac_filter(struct i40e_vsi *vsi,
  * i40e_del_mac_filter - Remove a MAC filter from all VLANs
  * @vsi: the VSI to be searched
  * @macaddr: the mac address to be removed
+ * @queue: if non-zero, the target ToQueue
  *
  * Removes a given MAC address from a VSI regardless of what VLAN it has been
  * associated with.
  *
  * Returns 0 for success, or error
  **/
-int i40e_del_mac_filter(struct i40e_vsi *vsi, const u8 *macaddr)
+int i40e_del_mac_filter(struct i40e_vsi *vsi, const u8 *macaddr, u16 queue)
 {
 	struct i40e_mac_filter *f;
 	struct hlist_node *h;
@@ -1518,7 +1527,8 @@ int i40e_del_mac_filter(struct i40e_vsi *vsi, const u8 *macaddr)
 	WARN(!spin_is_locked(&vsi->mac_filter_hash_lock),
 	     "Missing mac_filter_hash_lock\n");
 	hash_for_each_safe(vsi->mac_filter_hash, bkt, h, f, hlist) {
-		if (ether_addr_equal(macaddr, f->macaddr)) {
+		if (ether_addr_equal(macaddr, f->macaddr) &&
+		    queue == f->queue) {
 			__i40e_del_filter(vsi, f);
 			found = true;
 		}
@@ -1565,8 +1575,8 @@ static int i40e_set_mac(struct net_device *netdev, void *p)
 		netdev_info(netdev, "set new mac address %pM\n", addr->sa_data);
 
 	spin_lock_bh(&vsi->mac_filter_hash_lock);
-	i40e_del_mac_filter(vsi, netdev->dev_addr);
-	i40e_add_mac_filter(vsi, addr->sa_data);
+	i40e_del_mac_filter(vsi, netdev->dev_addr, 0);
+	i40e_add_mac_filter(vsi, addr->sa_data, 0);
 	spin_unlock_bh(&vsi->mac_filter_hash_lock);
 	ether_addr_copy(netdev->dev_addr, addr->sa_data);
 	if (vsi->type == I40E_VSI_MAIN) {
@@ -1731,7 +1741,7 @@ static int i40e_addr_sync(struct net_device *netdev, const u8 *addr)
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
 
-	if (i40e_add_mac_filter(vsi, addr))
+	if (i40e_add_mac_filter(vsi, addr, 0))
 		return 0;
 	else
 		return -ENOMEM;
@@ -1750,7 +1760,7 @@ static int i40e_addr_unsync(struct net_device *netdev, const u8 *addr)
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
 
-	i40e_del_mac_filter(vsi, addr);
+	i40e_del_mac_filter(vsi, addr, 0);
 
 	return 0;
 }
@@ -1793,7 +1803,7 @@ static void i40e_undo_del_filter_entries(struct i40e_vsi *vsi,
 	struct hlist_node *h;
 
 	hlist_for_each_entry_safe(f, h, from, hlist) {
-		u64 key = i40e_addr_to_hkey(f->macaddr);
+		u64 key = i40e_addr_to_hkey(f->macaddr, f->queue);
 
 		/* Move the element back into MAC filter list*/
 		hlist_del(&f->hlist);
@@ -2194,7 +2204,15 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 				add_list[num_add].vlan_tag =
 					cpu_to_le16((u16)(new->f->vlan));
 			}
-			add_list[num_add].queue_number = 0;
+
+			if (new->f->queue) {
+				add_list[num_add].queue_number =
+					cpu_to_le16(new->f->queue);
+				cmd_flags |= I40E_AQC_MACVLAN_ADD_TO_QUEUE;
+			} else {
+				add_list[num_add].queue_number = 0;
+			}
+
 			/* set invalid match method for later detection */
 			add_list[num_add].match_method = I40E_AQC_MM_ERR_NO_RES;
 			cmd_flags |= I40E_AQC_MACVLAN_ADD_PERFECT_MATCH;
@@ -2580,7 +2598,7 @@ int i40e_add_vlan_all_mac(struct i40e_vsi *vsi, s16 vid)
 	hash_for_each_safe(vsi->mac_filter_hash, bkt, h, f, hlist) {
 		if (f->state == I40E_FILTER_REMOVE)
 			continue;
-		add_f = i40e_add_filter(vsi, f->macaddr, vid);
+		add_f = i40e_add_filter(vsi, f->macaddr, vid, 0);
 		if (!add_f) {
 			dev_info(&vsi->back->pdev->dev,
 				 "Could not add vlan filter %d for %pM\n",
@@ -9772,7 +9790,7 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
 		 */
 		i40e_rm_default_mac_filter(vsi, mac_addr);
 		spin_lock_bh(&vsi->mac_filter_hash_lock);
-		i40e_add_mac_filter(vsi, mac_addr);
+		i40e_add_mac_filter(vsi, mac_addr, 0);
 		spin_unlock_bh(&vsi->mac_filter_hash_lock);
 	} else {
 		/* Relate the VSI_VMDQ name to the VSI_MAIN name. Note that we
@@ -9786,7 +9804,7 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
 		random_ether_addr(mac_addr);
 
 		spin_lock_bh(&vsi->mac_filter_hash_lock);
-		i40e_add_mac_filter(vsi, mac_addr);
+		i40e_add_mac_filter(vsi, mac_addr, 0);
 		spin_unlock_bh(&vsi->mac_filter_hash_lock);
 	}
 
@@ -9805,7 +9823,7 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
 	 */
 	eth_broadcast_addr(broadcast);
 	spin_lock_bh(&vsi->mac_filter_hash_lock);
-	i40e_add_mac_filter(vsi, broadcast);
+	i40e_add_mac_filter(vsi, broadcast, 0);
 	spin_unlock_bh(&vsi->mac_filter_hash_lock);
 
 	ether_addr_copy(netdev->dev_addr, mac_addr);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 0456813..d2ed218 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -709,14 +709,14 @@ static int i40e_alloc_vsi_res(struct i40e_vf *vf, enum i40e_vsi_type type)
 		spin_lock_bh(&vsi->mac_filter_hash_lock);
 		if (is_valid_ether_addr(vf->default_lan_addr.addr)) {
 			f = i40e_add_mac_filter(vsi,
-						vf->default_lan_addr.addr);
+						vf->default_lan_addr.addr, 0);
 			if (!f)
 				dev_info(&pf->pdev->dev,
 					 "Could not add MAC filter %pM for VF %d\n",
 					vf->default_lan_addr.addr, vf->vf_id);
 		}
 		eth_broadcast_addr(broadcast);
-		f = i40e_add_mac_filter(vsi, broadcast);
+		f = i40e_add_mac_filter(vsi, broadcast, 0);
 		if (!f)
 			dev_info(&pf->pdev->dev,
 				 "Could not allocate VF broadcast filter\n");
@@ -2217,7 +2217,7 @@ static int i40e_vc_add_mac_addr_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 
 		f = i40e_find_mac(vsi, al->list[i].addr);
 		if (!f)
-			f = i40e_add_mac_filter(vsi, al->list[i].addr);
+			f = i40e_add_mac_filter(vsi, al->list[i].addr, 0);
 
 		if (!f) {
 			dev_err(&pf->pdev->dev,
@@ -2282,7 +2282,7 @@ static int i40e_vc_del_mac_addr_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 	spin_lock_bh(&vsi->mac_filter_hash_lock);
 	/* delete addresses from the list */
 	for (i = 0; i < al->num_elements; i++)
-		if (i40e_del_mac_filter(vsi, al->list[i].addr)) {
+		if (i40e_del_mac_filter(vsi, al->list[i].addr, 0)) {
 			ret = I40E_ERR_INVALID_MAC_ADDR;
 			spin_unlock_bh(&vsi->mac_filter_hash_lock);
 			goto error_param;
@@ -2916,7 +2916,7 @@ int i40e_ndo_set_vf_mac(struct net_device *netdev, int vf_id, u8 *mac)
 
 	/* delete the temporary mac address */
 	if (!is_zero_ether_addr(vf->default_lan_addr.addr))
-		i40e_del_mac_filter(vsi, vf->default_lan_addr.addr);
+		i40e_del_mac_filter(vsi, vf->default_lan_addr.addr, 0);
 
 	/* Delete all the filters for this VSI - we're going to kill it
 	 * anyway.
-- 
1.7.1
