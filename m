From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/17] i40e: Lock for VSI's MAC filter list
Date: Fri, 16 Oct 2015 22:28:15 -0700
Message-ID: <1445059711-45992-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1445059711-45992-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Kiran Patil <kiran.patil@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:63385 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752231AbbJQF2n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Oct 2015 01:28:43 -0400
In-Reply-To: <1445059711-45992-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kiran Patil <kiran.patil@intel.com>

This patch introduces a spinlock which is to be used for synchronizing
access to VSI's MAC filter list.

This patch also synchronizes execution of other codepaths which are
accessing VSI's MAC filter list with execution of
service_task:sync_vsi_filters.

In function i40e_add_vsi, copied out LAA MAC address instead of cloning
MAC filter entry because only MAC address is needed to remove MAC VLAN
filter from FW/HW.

Change-ID: I0e10ac7c715d44aa994239642aa4d57c998573a2
Signed-off-by: Kiran Patil <kiran.patil@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h             |   2 +
 drivers/net/ethernet/intel/i40e/i40e_fcoe.c        |   2 +
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 328 +++++++++++++++++----
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  26 +-
 4 files changed, 302 insertions(+), 56 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 7a58b1f..b7818be 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -468,6 +468,8 @@ struct i40e_vsi {
 #define I40E_VSI_FLAG_VEB_OWNER		BIT(1)
 	unsigned long flags;
 
+	/* Per VSI lock to protect elements/list (MAC filter) */
+	spinlock_t mac_filter_list_lock;
 	struct list_head mac_filter_list;
 
 	/* VSI stats */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_fcoe.c b/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
index 2ec2411..fe5d9bf 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
@@ -1516,10 +1516,12 @@ void i40e_fcoe_config_netdev(struct net_device *netdev, struct i40e_vsi *vsi)
 	 * same PCI function.
 	 */
 	netdev->dev_port = 1;
+	spin_lock_bh(&vsi->mac_filter_list_lock);
 	i40e_add_filter(vsi, hw->mac.san_addr, 0, false, false);
 	i40e_add_filter(vsi, (u8[6]) FC_FCOE_FLOGI_MAC, 0, false, false);
 	i40e_add_filter(vsi, FIP_ALL_FCOE_MACS, 0, false, false);
 	i40e_add_filter(vsi, FIP_ALL_ENODE_MACS, 0, false, false);
+	spin_unlock_bh(&vsi->mac_filter_list_lock);
 
 	/* use san mac */
 	ether_addr_copy(netdev->dev_addr, hw->mac.san_addr);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 87a5d09..aa2aafd 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1223,6 +1223,9 @@ static struct i40e_mac_filter *i40e_find_filter(struct i40e_vsi *vsi,
 {
 	struct i40e_mac_filter *f;
 
+	WARN(!spin_is_locked(&vsi->mac_filter_list_lock),
+	     "Missing mac_filter_list_lock\n");
+
 	if (!vsi || !macaddr)
 		return NULL;
 
@@ -1251,6 +1254,9 @@ struct i40e_mac_filter *i40e_find_mac(struct i40e_vsi *vsi, u8 *macaddr,
 {
 	struct i40e_mac_filter *f;
 
+	WARN(!spin_is_locked(&vsi->mac_filter_list_lock),
+	     "Missing mac_filter_list_lock\n");
+
 	if (!vsi || !macaddr)
 		return NULL;
 
@@ -1273,6 +1279,9 @@ bool i40e_is_vsi_in_vlan(struct i40e_vsi *vsi)
 {
 	struct i40e_mac_filter *f;
 
+	WARN(!spin_is_locked(&vsi->mac_filter_list_lock),
+	     "Missing mac_filter_list_lock\n");
+
 	/* Only -1 for all the filters denotes not in vlan mode
 	 * so we have to go through all the list in order to make sure
 	 */
@@ -1301,6 +1310,9 @@ struct i40e_mac_filter *i40e_put_mac_in_vlan(struct i40e_vsi *vsi, u8 *macaddr,
 {
 	struct i40e_mac_filter *f;
 
+	WARN(!spin_is_locked(&vsi->mac_filter_list_lock),
+	     "Missing mac_filter_list_lock\n");
+
 	list_for_each_entry(f, &vsi->mac_filter_list, list) {
 		if (vsi->info.pvid)
 			f->vlan = le16_to_cpu(vsi->info.pvid);
@@ -1355,6 +1367,10 @@ static int i40e_rm_default_mac_filter(struct i40e_vsi *vsi, u8 *macaddr)
  * @is_netdev: make sure its a netdev filter, else doesn't matter
  *
  * Returns ptr to the filter object or NULL when no memory available.
+ *
+ * NOTE: This function is expected to be called with mac_filter_list_lock
+ * being held. If needed could add WARN/BUG_ON if lock is not held for debug
+ * purpose.
  **/
 struct i40e_mac_filter *i40e_add_filter(struct i40e_vsi *vsi,
 					u8 *macaddr, s16 vlan,
@@ -1362,6 +1378,9 @@ struct i40e_mac_filter *i40e_add_filter(struct i40e_vsi *vsi,
 {
 	struct i40e_mac_filter *f;
 
+	WARN(!spin_is_locked(&vsi->mac_filter_list_lock),
+	     "Missing mac_filter_list_lock\n");
+
 	if (!vsi || !macaddr)
 		return NULL;
 
@@ -1413,6 +1432,10 @@ add_filter_out:
  * @vlan: the vlan
  * @is_vf: make sure it's a VF filter, else doesn't matter
  * @is_netdev: make sure it's a netdev filter, else doesn't matter
+ *
+ * NOTE: This function is expected to be called with mac_filter_list_lock
+ * being held. If needed could add WARN/BUG_ON if lock is not held for debug
+ * purpose.
  **/
 void i40e_del_filter(struct i40e_vsi *vsi,
 		     u8 *macaddr, s16 vlan,
@@ -1420,6 +1443,9 @@ void i40e_del_filter(struct i40e_vsi *vsi,
 {
 	struct i40e_mac_filter *f;
 
+	WARN(!spin_is_locked(&vsi->mac_filter_list_lock),
+	     "Missing mac_filter_list_lock\n");
+
 	if (!vsi || !macaddr)
 		return;
 
@@ -1519,8 +1545,10 @@ static int i40e_set_mac(struct net_device *netdev, void *p)
 		element.flags = I40E_AQC_MACVLAN_DEL_PERFECT_MATCH;
 		i40e_aq_remove_macvlan(&pf->hw, vsi->seid, &element, 1, NULL);
 	} else {
+		spin_lock_bh(&vsi->mac_filter_list_lock);
 		i40e_del_filter(vsi, netdev->dev_addr, I40E_VLAN_ANY,
 				false, false);
+		spin_unlock_bh(&vsi->mac_filter_list_lock);
 	}
 
 	if (ether_addr_equal(addr->sa_data, hw->mac.addr)) {
@@ -1531,10 +1559,12 @@ static int i40e_set_mac(struct net_device *netdev, void *p)
 		element.flags = cpu_to_le16(I40E_AQC_MACVLAN_ADD_PERFECT_MATCH);
 		i40e_aq_add_macvlan(&pf->hw, vsi->seid, &element, 1, NULL);
 	} else {
+		spin_lock_bh(&vsi->mac_filter_list_lock);
 		f = i40e_add_filter(vsi, addr->sa_data, I40E_VLAN_ANY,
 				    false, false);
 		if (f)
 			f->is_laa = true;
+		spin_unlock_bh(&vsi->mac_filter_list_lock);
 	}
 
 	i40e_sync_vsi_filters(vsi, false);
@@ -1707,6 +1737,8 @@ static void i40e_set_rx_mode(struct net_device *netdev)
 	struct netdev_hw_addr *mca;
 	struct netdev_hw_addr *ha;
 
+	spin_lock_bh(&vsi->mac_filter_list_lock);
+
 	/* add addr if not already in the filter list */
 	netdev_for_each_uc_addr(uca, netdev) {
 		if (!i40e_find_mac(vsi, uca->addr, false, true)) {
@@ -1754,6 +1786,7 @@ static void i40e_set_rx_mode(struct net_device *netdev)
 bottom_of_search_loop:
 		continue;
 	}
+	spin_unlock_bh(&vsi->mac_filter_list_lock);
 
 	/* check for other flag changes */
 	if (vsi->current_netdev_flags != vsi->netdev->flags) {
@@ -1763,6 +1796,79 @@ bottom_of_search_loop:
 }
 
 /**
+ * i40e_mac_filter_entry_clone - Clones a MAC filter entry
+ * @src: source MAC filter entry to be clones
+ *
+ * Returns the pointer to newly cloned MAC filter entry or NULL
+ * in case of error
+ **/
+static struct i40e_mac_filter *i40e_mac_filter_entry_clone(
+					struct i40e_mac_filter *src)
+{
+	struct i40e_mac_filter *f;
+
+	f = kzalloc(sizeof(*f), GFP_ATOMIC);
+	if (!f)
+		return NULL;
+	*f = *src;
+
+	INIT_LIST_HEAD(&f->list);
+
+	return f;
+}
+
+/**
+ * i40e_undo_del_filter_entries - Undo the changes made to MAC filter entries
+ * @vsi: pointer to vsi struct
+ * @from: Pointer to list which contains MAC filter entries - changes to
+ *        those entries needs to be undone.
+ *
+ * MAC filter entries from list were slated to be removed from device.
+ **/
+static void i40e_undo_del_filter_entries(struct i40e_vsi *vsi,
+					 struct list_head *from)
+{
+	struct i40e_mac_filter *f, *ftmp;
+
+	list_for_each_entry_safe(f, ftmp, from, list) {
+		f->changed = true;
+		/* Move the element back into MAC filter list*/
+		list_move_tail(&f->list, &vsi->mac_filter_list);
+	}
+}
+
+/**
+ * i40e_undo_add_filter_entries - Undo the changes made to MAC filter entries
+ * @vsi: pointer to vsi struct
+ *
+ * MAC filter entries from list were slated to be added from device.
+ **/
+static void i40e_undo_add_filter_entries(struct i40e_vsi *vsi)
+{
+	struct i40e_mac_filter *f, *ftmp;
+
+	list_for_each_entry_safe(f, ftmp, &vsi->mac_filter_list, list) {
+		if (!f->changed && f->counter)
+			f->changed = true;
+	}
+}
+
+/**
+ * i40e_cleanup_add_list - Deletes the element from add list and release
+ *			memory
+ * @add_list: Pointer to list which contains MAC filter entries
+ **/
+static void i40e_cleanup_add_list(struct list_head *add_list)
+{
+	struct i40e_mac_filter *f, *ftmp;
+
+	list_for_each_entry_safe(f, ftmp, add_list, list) {
+		list_del(&f->list);
+		kfree(f);
+	}
+}
+
+/**
  * i40e_sync_vsi_filters - Update the VSI filter list to the HW
  * @vsi: ptr to the VSI
  * @grab_rtnl: whether RTNL needs to be grabbed
@@ -1773,11 +1879,13 @@ bottom_of_search_loop:
  **/
 int i40e_sync_vsi_filters(struct i40e_vsi *vsi, bool grab_rtnl)
 {
-	struct i40e_mac_filter *f, *ftmp;
+	struct list_head tmp_del_list, tmp_add_list;
+	struct i40e_mac_filter *f, *ftmp, *fclone;
 	bool promisc_forced_on = false;
 	bool add_happened = false;
 	int filter_list_len = 0;
 	u32 changed_flags = 0;
+	bool err_cond = false;
 	i40e_status ret = 0;
 	struct i40e_pf *pf;
 	int num_add = 0;
@@ -1798,17 +1906,13 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi, bool grab_rtnl)
 		vsi->current_netdev_flags = vsi->netdev->flags;
 	}
 
+	INIT_LIST_HEAD(&tmp_del_list);
+	INIT_LIST_HEAD(&tmp_add_list);
+
 	if (vsi->flags & I40E_VSI_FLAG_FILTER_CHANGED) {
 		vsi->flags &= ~I40E_VSI_FLAG_FILTER_CHANGED;
 
-		filter_list_len = pf->hw.aq.asq_buf_size /
-			    sizeof(struct i40e_aqc_remove_macvlan_element_data);
-		del_list = kcalloc(filter_list_len,
-			    sizeof(struct i40e_aqc_remove_macvlan_element_data),
-			    GFP_KERNEL);
-		if (!del_list)
-			return -ENOMEM;
-
+		spin_lock_bh(&vsi->mac_filter_list_lock);
 		list_for_each_entry_safe(f, ftmp, &vsi->mac_filter_list, list) {
 			if (!f->changed)
 				continue;
@@ -1816,6 +1920,58 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi, bool grab_rtnl)
 			if (f->counter != 0)
 				continue;
 			f->changed = false;
+
+			/* Move the element into temporary del_list */
+			list_move_tail(&f->list, &tmp_del_list);
+		}
+
+		list_for_each_entry_safe(f, ftmp, &vsi->mac_filter_list, list) {
+			if (!f->changed)
+				continue;
+
+			if (f->counter == 0)
+				continue;
+			f->changed = false;
+
+			/* Clone MAC filter entry and add into temporary list */
+			fclone = i40e_mac_filter_entry_clone(f);
+			if (!fclone) {
+				err_cond = true;
+				break;
+			}
+			list_add_tail(&fclone->list, &tmp_add_list);
+		}
+
+		/* if failed to clone MAC filter entry - undo */
+		if (err_cond) {
+			i40e_undo_del_filter_entries(vsi, &tmp_del_list);
+			i40e_undo_add_filter_entries(vsi);
+		}
+		spin_unlock_bh(&vsi->mac_filter_list_lock);
+
+		if (err_cond)
+			i40e_cleanup_add_list(&tmp_add_list);
+	}
+
+	/* Now process 'del_list' outside the lock */
+	if (!list_empty(&tmp_del_list)) {
+		filter_list_len = pf->hw.aq.asq_buf_size /
+			    sizeof(struct i40e_aqc_remove_macvlan_element_data);
+		del_list = kcalloc(filter_list_len,
+			    sizeof(struct i40e_aqc_remove_macvlan_element_data),
+			    GFP_KERNEL);
+		if (!del_list) {
+			i40e_cleanup_add_list(&tmp_add_list);
+
+			/* Undo VSI's MAC filter entry element updates */
+			spin_lock_bh(&vsi->mac_filter_list_lock);
+			i40e_undo_del_filter_entries(vsi, &tmp_del_list);
+			i40e_undo_add_filter_entries(vsi);
+			spin_unlock_bh(&vsi->mac_filter_list_lock);
+			return -ENOMEM;
+		}
+
+		list_for_each_entry_safe(f, ftmp, &tmp_del_list, list) {
 			cmd_flags = 0;
 
 			/* add to delete list */
@@ -1828,10 +1984,6 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi, bool grab_rtnl)
 			del_list[num_del].flags = cmd_flags;
 			num_del++;
 
-			/* unlink from filter list */
-			list_del(&f->list);
-			kfree(f);
-
 			/* flush a full buffer */
 			if (num_del == filter_list_len) {
 				ret = i40e_aq_remove_macvlan(&pf->hw,
@@ -1842,12 +1994,18 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi, bool grab_rtnl)
 				memset(del_list, 0, sizeof(*del_list));
 
 				if (ret && aq_err != I40E_AQ_RC_ENOENT)
-					dev_info(&pf->pdev->dev,
-						 "ignoring delete macvlan error, err %s, aq_err %s while flushing a full buffer\n",
-						 i40e_stat_str(&pf->hw, ret),
-						 i40e_aq_str(&pf->hw, aq_err));
+					dev_err(&pf->pdev->dev,
+						"ignoring delete macvlan error, err %s, aq_err %s while flushing a full buffer\n",
+						i40e_stat_str(&pf->hw, ret),
+						i40e_aq_str(&pf->hw, aq_err));
 			}
+			/* Release memory for MAC filter entries which were
+			 * synced up with HW.
+			 */
+			list_del(&f->list);
+			kfree(f);
 		}
+
 		if (num_del) {
 			ret = i40e_aq_remove_macvlan(&pf->hw, vsi->seid,
 						     del_list, num_del, NULL);
@@ -1863,6 +2021,9 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi, bool grab_rtnl)
 
 		kfree(del_list);
 		del_list = NULL;
+	}
+
+	if (!list_empty(&tmp_add_list)) {
 
 		/* do all the adds now */
 		filter_list_len = pf->hw.aq.asq_buf_size /
@@ -1870,16 +2031,19 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi, bool grab_rtnl)
 		add_list = kcalloc(filter_list_len,
 			       sizeof(struct i40e_aqc_add_macvlan_element_data),
 			       GFP_KERNEL);
-		if (!add_list)
+		if (!add_list) {
+			/* Purge element from temporary lists */
+			i40e_cleanup_add_list(&tmp_add_list);
+
+			/* Undo add filter entries from VSI MAC filter list */
+			spin_lock_bh(&vsi->mac_filter_list_lock);
+			i40e_undo_add_filter_entries(vsi);
+			spin_unlock_bh(&vsi->mac_filter_list_lock);
 			return -ENOMEM;
+		}
 
-		list_for_each_entry_safe(f, ftmp, &vsi->mac_filter_list, list) {
-			if (!f->changed)
-				continue;
+		list_for_each_entry_safe(f, ftmp, &tmp_add_list, list) {
 
-			if (f->counter == 0)
-				continue;
-			f->changed = false;
 			add_happened = true;
 			cmd_flags = 0;
 
@@ -1906,7 +2070,13 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi, bool grab_rtnl)
 					break;
 				memset(add_list, 0, sizeof(*add_list));
 			}
+			/* Entries from tmp_add_list were cloned from MAC
+			 * filter list, hence clean those cloned entries
+			 */
+			list_del(&f->list);
+			kfree(f);
 		}
+
 		if (num_add) {
 			ret = i40e_aq_add_macvlan(&pf->hw, vsi->seid,
 						  add_list, num_add, NULL);
@@ -2158,6 +2328,9 @@ int i40e_vsi_add_vlan(struct i40e_vsi *vsi, s16 vid)
 	is_vf = (vsi->type == I40E_VSI_SRIOV);
 	is_netdev = !!(vsi->netdev);
 
+	/* Locked once because all functions invoked below iterates list*/
+	spin_lock_bh(&vsi->mac_filter_list_lock);
+
 	if (is_netdev) {
 		add_f = i40e_add_filter(vsi, vsi->netdev->dev_addr, vid,
 					is_vf, is_netdev);
@@ -2165,6 +2338,7 @@ int i40e_vsi_add_vlan(struct i40e_vsi *vsi, s16 vid)
 			dev_info(&vsi->back->pdev->dev,
 				 "Could not add vlan filter %d for %pM\n",
 				 vid, vsi->netdev->dev_addr);
+			spin_unlock_bh(&vsi->mac_filter_list_lock);
 			return -ENOMEM;
 		}
 	}
@@ -2175,6 +2349,7 @@ int i40e_vsi_add_vlan(struct i40e_vsi *vsi, s16 vid)
 			dev_info(&vsi->back->pdev->dev,
 				 "Could not add vlan filter %d for %pM\n",
 				 vid, f->macaddr);
+			spin_unlock_bh(&vsi->mac_filter_list_lock);
 			return -ENOMEM;
 		}
 	}
@@ -2196,6 +2371,7 @@ int i40e_vsi_add_vlan(struct i40e_vsi *vsi, s16 vid)
 				dev_info(&vsi->back->pdev->dev,
 					 "Could not add filter 0 for %pM\n",
 					 vsi->netdev->dev_addr);
+				spin_unlock_bh(&vsi->mac_filter_list_lock);
 				return -ENOMEM;
 			}
 		}
@@ -2204,22 +2380,28 @@ int i40e_vsi_add_vlan(struct i40e_vsi *vsi, s16 vid)
 	/* Do not assume that I40E_VLAN_ANY should be reset to VLAN 0 */
 	if (vid > 0 && !vsi->info.pvid) {
 		list_for_each_entry(f, &vsi->mac_filter_list, list) {
-			if (i40e_find_filter(vsi, f->macaddr, I40E_VLAN_ANY,
-					     is_vf, is_netdev)) {
-				i40e_del_filter(vsi, f->macaddr, I40E_VLAN_ANY,
-						is_vf, is_netdev);
-				add_f = i40e_add_filter(vsi, f->macaddr,
-							0, is_vf, is_netdev);
-				if (!add_f) {
-					dev_info(&vsi->back->pdev->dev,
-						 "Could not add filter 0 for %pM\n",
-						 f->macaddr);
-					return -ENOMEM;
-				}
+			if (!i40e_find_filter(vsi, f->macaddr, I40E_VLAN_ANY,
+					      is_vf, is_netdev))
+				continue;
+			i40e_del_filter(vsi, f->macaddr, I40E_VLAN_ANY,
+					is_vf, is_netdev);
+			add_f = i40e_add_filter(vsi, f->macaddr,
+						0, is_vf, is_netdev);
+			if (!add_f) {
+				dev_info(&vsi->back->pdev->dev,
+					 "Could not add filter 0 for %pM\n",
+					f->macaddr);
+				spin_unlock_bh(&vsi->mac_filter_list_lock);
+				return -ENOMEM;
 			}
 		}
 	}
 
+	/* Make sure to release before sync_vsi_filter because that
+	 * function will lock/unlock as necessary
+	 */
+	spin_unlock_bh(&vsi->mac_filter_list_lock);
+
 	if (test_bit(__I40E_DOWN, &vsi->back->state) ||
 	    test_bit(__I40E_RESET_RECOVERY_PENDING, &vsi->back->state))
 		return 0;
@@ -2244,6 +2426,9 @@ int i40e_vsi_kill_vlan(struct i40e_vsi *vsi, s16 vid)
 	is_vf = (vsi->type == I40E_VSI_SRIOV);
 	is_netdev = !!(netdev);
 
+	/* Locked once because all functions invoked below iterates list */
+	spin_lock_bh(&vsi->mac_filter_list_lock);
+
 	if (is_netdev)
 		i40e_del_filter(vsi, netdev->dev_addr, vid, is_vf, is_netdev);
 
@@ -2274,6 +2459,7 @@ int i40e_vsi_kill_vlan(struct i40e_vsi *vsi, s16 vid)
 			dev_info(&vsi->back->pdev->dev,
 				 "Could not add filter %d for %pM\n",
 				 I40E_VLAN_ANY, netdev->dev_addr);
+			spin_unlock_bh(&vsi->mac_filter_list_lock);
 			return -ENOMEM;
 		}
 	}
@@ -2282,16 +2468,22 @@ int i40e_vsi_kill_vlan(struct i40e_vsi *vsi, s16 vid)
 		list_for_each_entry(f, &vsi->mac_filter_list, list) {
 			i40e_del_filter(vsi, f->macaddr, 0, is_vf, is_netdev);
 			add_f = i40e_add_filter(vsi, f->macaddr, I40E_VLAN_ANY,
-					    is_vf, is_netdev);
+						is_vf, is_netdev);
 			if (!add_f) {
 				dev_info(&vsi->back->pdev->dev,
 					 "Could not add filter %d for %pM\n",
 					 I40E_VLAN_ANY, f->macaddr);
+				spin_unlock_bh(&vsi->mac_filter_list_lock);
 				return -ENOMEM;
 			}
 		}
 	}
 
+	/* Make sure to release before sync_vsi_filter because that
+	 * function with lock/unlock as necessary
+	 */
+	spin_unlock_bh(&vsi->mac_filter_list_lock);
+
 	if (test_bit(__I40E_DOWN, &vsi->back->state) ||
 	    test_bit(__I40E_RESET_RECOVERY_PENDING, &vsi->back->state))
 		return 0;
@@ -7062,6 +7254,8 @@ static int i40e_vsi_mem_alloc(struct i40e_pf *pf, enum i40e_vsi_type type)
 	/* Setup default MSIX irq handler for VSI */
 	i40e_vsi_setup_irqhandler(vsi, i40e_msix_clean_rings);
 
+	/* Initialize VSI lock */
+	spin_lock_init(&vsi->mac_filter_list_lock);
 	pf->vsi[vsi_idx] = vsi;
 	ret = vsi_idx;
 	goto unlock_pf;
@@ -8477,17 +8671,26 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
 		 * default a MAC-VLAN filter that accepts any tagged packet
 		 * which must be replaced by a normal filter.
 		 */
-		if (!i40e_rm_default_mac_filter(vsi, mac_addr))
+		if (!i40e_rm_default_mac_filter(vsi, mac_addr)) {
+			spin_lock_bh(&vsi->mac_filter_list_lock);
 			i40e_add_filter(vsi, mac_addr,
 					I40E_VLAN_ANY, false, true);
+			spin_unlock_bh(&vsi->mac_filter_list_lock);
+		}
 	} else {
 		/* relate the VSI_VMDQ name to the VSI_MAIN name */
 		snprintf(netdev->name, IFNAMSIZ, "%sv%%d",
 			 pf->vsi[pf->lan_vsi]->netdev->name);
 		random_ether_addr(mac_addr);
+
+		spin_lock_bh(&vsi->mac_filter_list_lock);
 		i40e_add_filter(vsi, mac_addr, I40E_VLAN_ANY, false, false);
+		spin_unlock_bh(&vsi->mac_filter_list_lock);
 	}
+
+	spin_lock_bh(&vsi->mac_filter_list_lock);
 	i40e_add_filter(vsi, brdcast, I40E_VLAN_ANY, false, false);
+	spin_unlock_bh(&vsi->mac_filter_list_lock);
 
 	ether_addr_copy(netdev->dev_addr, mac_addr);
 	ether_addr_copy(netdev->perm_addr, mac_addr);
@@ -8561,10 +8764,13 @@ int i40e_is_vsi_uplink_mode_veb(struct i40e_vsi *vsi)
 static int i40e_add_vsi(struct i40e_vsi *vsi)
 {
 	int ret = -ENODEV;
-	struct i40e_mac_filter *f, *ftmp;
+	u8 laa_macaddr[ETH_ALEN];
+	bool found_laa_mac_filter = false;
 	struct i40e_pf *pf = vsi->back;
 	struct i40e_hw *hw = &pf->hw;
 	struct i40e_vsi_context ctxt;
+	struct i40e_mac_filter *f, *ftmp;
+
 	u8 enabled_tc = 0x1; /* TC0 enabled */
 	int f_count = 0;
 
@@ -8736,32 +8942,41 @@ static int i40e_add_vsi(struct i40e_vsi *vsi)
 		vsi->id = ctxt.vsi_number;
 	}
 
+	spin_lock_bh(&vsi->mac_filter_list_lock);
 	/* If macvlan filters already exist, force them to get loaded */
 	list_for_each_entry_safe(f, ftmp, &vsi->mac_filter_list, list) {
 		f->changed = true;
 		f_count++;
 
+		/* Expected to have only one MAC filter entry for LAA in list */
 		if (f->is_laa && vsi->type == I40E_VSI_MAIN) {
-			struct i40e_aqc_remove_macvlan_element_data element;
+			ether_addr_copy(laa_macaddr, f->macaddr);
+			found_laa_mac_filter = true;
+		}
+	}
+	spin_unlock_bh(&vsi->mac_filter_list_lock);
 
-			memset(&element, 0, sizeof(element));
-			ether_addr_copy(element.mac_addr, f->macaddr);
-			element.flags = I40E_AQC_MACVLAN_DEL_PERFECT_MATCH;
-			ret = i40e_aq_remove_macvlan(hw, vsi->seid,
-						     &element, 1, NULL);
-			if (ret) {
-				/* some older FW has a different default */
-				element.flags |=
-					       I40E_AQC_MACVLAN_DEL_IGNORE_VLAN;
-				i40e_aq_remove_macvlan(hw, vsi->seid,
-						       &element, 1, NULL);
-			}
+	if (found_laa_mac_filter) {
+		struct i40e_aqc_remove_macvlan_element_data element;
 
-			i40e_aq_mac_address_write(hw,
-						  I40E_AQC_WRITE_TYPE_LAA_WOL,
-						  f->macaddr, NULL);
+		memset(&element, 0, sizeof(element));
+		ether_addr_copy(element.mac_addr, laa_macaddr);
+		element.flags = I40E_AQC_MACVLAN_DEL_PERFECT_MATCH;
+		ret = i40e_aq_remove_macvlan(hw, vsi->seid,
+					     &element, 1, NULL);
+		if (ret) {
+			/* some older FW has a different default */
+			element.flags |=
+				       I40E_AQC_MACVLAN_DEL_IGNORE_VLAN;
+			i40e_aq_remove_macvlan(hw, vsi->seid,
+					       &element, 1, NULL);
 		}
+
+		i40e_aq_mac_address_write(hw,
+					  I40E_AQC_WRITE_TYPE_LAA_WOL,
+					  laa_macaddr, NULL);
 	}
+
 	if (f_count) {
 		vsi->flags |= I40E_VSI_FLAG_FILTER_CHANGED;
 		pf->flags |= I40E_FLAG_FILTER_SYNC;
@@ -8824,9 +9039,12 @@ int i40e_vsi_release(struct i40e_vsi *vsi)
 		i40e_vsi_disable_irq(vsi);
 	}
 
+	spin_lock_bh(&vsi->mac_filter_list_lock);
 	list_for_each_entry_safe(f, ftmp, &vsi->mac_filter_list, list)
 		i40e_del_filter(vsi, f->macaddr, f->vlan,
 				f->is_vf, f->is_netdev);
+	spin_unlock_bh(&vsi->mac_filter_list_lock);
+
 	i40e_sync_vsi_filters(vsi, false);
 
 	i40e_vsi_delete(vsi);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index a35a204..b2d95ee 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -547,6 +547,8 @@ static int i40e_alloc_vsi_res(struct i40e_vf *vf, enum i40e_vsi_type type)
 		 */
 		if (vf->port_vlan_id)
 			i40e_vsi_add_pvid(vsi, vf->port_vlan_id);
+
+		spin_lock_bh(&vsi->mac_filter_list_lock);
 		f = i40e_add_filter(vsi, vf->default_lan_addr.addr,
 				    vf->port_vlan_id ? vf->port_vlan_id : -1,
 				    true, false);
@@ -559,6 +561,7 @@ static int i40e_alloc_vsi_res(struct i40e_vf *vf, enum i40e_vsi_type type)
 		if (!f)
 			dev_info(&pf->pdev->dev,
 				 "Could not allocate VF broadcast filter\n");
+		spin_unlock_bh(&vsi->mac_filter_list_lock);
 	}
 
 	/* program mac filter */
@@ -1598,6 +1601,11 @@ static int i40e_vc_add_mac_addr_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 	}
 	vsi = pf->vsi[vf->lan_vsi_idx];
 
+	/* Lock once, because all function inside for loop accesses VSI's
+	 * MAC filter list which needs to be protected using same lock.
+	 */
+	spin_lock_bh(&vsi->mac_filter_list_lock);
+
 	/* add new addresses to the list */
 	for (i = 0; i < al->num_elements; i++) {
 		struct i40e_mac_filter *f;
@@ -1616,9 +1624,11 @@ static int i40e_vc_add_mac_addr_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 			dev_err(&pf->pdev->dev,
 				"Unable to add VF MAC filter\n");
 			ret = I40E_ERR_PARAM;
+			spin_unlock_bh(&vsi->mac_filter_list_lock);
 			goto error_param;
 		}
 	}
+	spin_unlock_bh(&vsi->mac_filter_list_lock);
 
 	/* program the updated filter list */
 	if (i40e_sync_vsi_filters(vsi, false))
@@ -1666,10 +1676,12 @@ static int i40e_vc_del_mac_addr_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 	}
 	vsi = pf->vsi[vf->lan_vsi_idx];
 
+	spin_lock_bh(&vsi->mac_filter_list_lock);
 	/* delete addresses from the list */
 	for (i = 0; i < al->num_elements; i++)
 		i40e_del_filter(vsi, al->list[i].addr,
 				I40E_VLAN_ANY, true, false);
+	spin_unlock_bh(&vsi->mac_filter_list_lock);
 
 	/* program the updated filter list */
 	if (i40e_sync_vsi_filters(vsi, false))
@@ -2066,6 +2078,11 @@ int i40e_ndo_set_vf_mac(struct net_device *netdev, int vf_id, u8 *mac)
 		goto error_param;
 	}
 
+	/* Lock once because below invoked function add/del_filter requires
+	 * mac_filter_list_lock to be held
+	 */
+	spin_lock_bh(&vsi->mac_filter_list_lock);
+
 	/* delete the temporary mac address */
 	i40e_del_filter(vsi, vf->default_lan_addr.addr,
 			vf->port_vlan_id ? vf->port_vlan_id : -1,
@@ -2077,6 +2094,8 @@ int i40e_ndo_set_vf_mac(struct net_device *netdev, int vf_id, u8 *mac)
 	list_for_each_entry(f, &vsi->mac_filter_list, list)
 		i40e_del_filter(vsi, f->macaddr, f->vlan, true, false);
 
+	spin_unlock_bh(&vsi->mac_filter_list_lock);
+
 	dev_info(&pf->pdev->dev, "Setting MAC %pM on VF %d\n", mac, vf_id);
 	/* program mac filter */
 	if (i40e_sync_vsi_filters(vsi, false)) {
@@ -2109,6 +2128,7 @@ int i40e_ndo_set_vf_port_vlan(struct net_device *netdev,
 	u16 vlanprio = vlan_id | (qos << I40E_VLAN_PRIORITY_SHIFT);
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_pf *pf = np->vsi->back;
+	bool is_vsi_in_vlan = false;
 	struct i40e_vsi *vsi;
 	struct i40e_vf *vf;
 	int ret = 0;
@@ -2138,7 +2158,11 @@ int i40e_ndo_set_vf_port_vlan(struct net_device *netdev,
 		/* duplicate request, so just return success */
 		goto error_pvid;
 
-	if (le16_to_cpu(vsi->info.pvid) == 0 && i40e_is_vsi_in_vlan(vsi)) {
+	spin_lock_bh(&vsi->mac_filter_list_lock);
+	is_vsi_in_vlan = i40e_is_vsi_in_vlan(vsi);
+	spin_unlock_bh(&vsi->mac_filter_list_lock);
+
+	if (le16_to_cpu(vsi->info.pvid) == 0 && is_vsi_in_vlan) {
 		dev_err(&pf->pdev->dev,
 			"VF %d has already configured VLAN filters and the administrator is requesting a port VLAN override.\nPlease unload and reload the VF driver for this change to take effect.\n",
 			vf_id);
-- 
2.4.3
