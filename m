From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/11] i40e: refactor Rx filter handling
Date: Fri, 22 Jul 2016 00:36:34 -0700
Message-ID: <1469172999-8969-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1469172999-8969-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, guru.anbalagane@oracle.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:4223 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752607AbcGVHgt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jul 2016 03:36:49 -0400
In-Reply-To: <1469172999-8969-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Properly track filter adds and deletes so the driver doesn't lose filters
during resets and up/down cycles. Add a tracking mechanism so that the
driver knows when to enter and leave promiscuous mode.

Implement a simple state machine so the driver can track the status of
each filter throughout its lifecycle. Properly manage the overflow promiscuous
state for the each VSI, and provide a way for the driver to detect when to exit
overflow promiscuous mode.

Remove all possible default MAC filters that the firmware may have set up so
that the driver can manage these correctly, particularly when VLANs come into
play. Remove the LAA flag for filters; instead just send whatever we get through
set_mac to the firmware as the LAA for wakeup purposes.

Finally, add the state of each filter to debugfs output so we can see what's
going on inside the driver's pointy little head.

Change-ID: I97c5e366fac2254fa01eaff4f65c0af61dcf2e1f
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h         |  14 +-
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c |  16 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c    | 510 ++++++++++++-------------
 3 files changed, 261 insertions(+), 279 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index e83fc8a..2a88291 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -448,6 +448,14 @@ struct i40e_pf {
 	u16 phy_led_val;
 };
 
+enum i40e_filter_state {
+	I40E_FILTER_INVALID = 0,	/* Invalid state */
+	I40E_FILTER_NEW,		/* New, not sent to FW yet */
+	I40E_FILTER_ACTIVE,		/* Added to switch by FW */
+	I40E_FILTER_FAILED,		/* Rejected by FW */
+	I40E_FILTER_REMOVE,		/* To be removed */
+/* There is no 'removed' state; the filter struct is freed */
+};
 struct i40e_mac_filter {
 	struct list_head list;
 	u8 macaddr[ETH_ALEN];
@@ -456,8 +464,7 @@ struct i40e_mac_filter {
 	u8 counter;		/* number of instances of this filter */
 	bool is_vf;		/* filter belongs to a VF */
 	bool is_netdev;		/* filter belongs to a netdev */
-	bool changed;		/* filter needs to be sync'd to the HW */
-	bool is_laa;		/* filter is a Locally Administered Address */
+	enum i40e_filter_state state;
 };
 
 struct i40e_veb {
@@ -523,6 +530,9 @@ struct i40e_vsi {
 	struct i40e_ring **rx_rings;
 	struct i40e_ring **tx_rings;
 
+	u32  active_filters;
+	u32  promisc_threshold;
+
 	u16 work_limit;
 	u16 int_rate_limit;  /* value in usecs */
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index e6af8c8..05cf9a7 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -116,6 +116,14 @@ static ssize_t i40e_dbg_command_read(struct file *filp, char __user *buffer,
 	return len;
 }
 
+static char *i40e_filter_state_string[] = {
+	"INVALID",
+	"NEW",
+	"ACTIVE",
+	"FAILED",
+	"REMOVE",
+};
+
 /**
  * i40e_dbg_dump_vsi_seid - handles dump vsi seid write into command datum
  * @pf: the i40e_pf created in command write
@@ -160,10 +168,14 @@ static void i40e_dbg_dump_vsi_seid(struct i40e_pf *pf, int seid)
 			 pf->hw.mac.port_addr);
 	list_for_each_entry(f, &vsi->mac_filter_list, list) {
 		dev_info(&pf->pdev->dev,
-			 "    mac_filter_list: %pM vid=%d, is_netdev=%d is_vf=%d counter=%d\n",
+			 "    mac_filter_list: %pM vid=%d, is_netdev=%d is_vf=%d counter=%d, state %s\n",
 			 f->macaddr, f->vlan, f->is_netdev, f->is_vf,
-			 f->counter);
+			 f->counter, i40e_filter_state_string[f->state]);
 	}
+	dev_info(&pf->pdev->dev, "    active_filters %d, promisc_threshold %d, overflow promisc %s\n",
+		 vsi->active_filters, vsi->promisc_threshold,
+		 (test_bit(__I40E_FILTER_OVERFLOW_PROMISC, &vsi->state) ?
+		  "ON" : "OFF"));
 	nstat = i40e_get_vsi_stats_struct(vsi);
 	dev_info(&pf->pdev->dev,
 		 "    net_stats: rx_packets = %lu, rx_bytes = %lu, rx_errors = %lu, rx_dropped = %lu\n",
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 28206da..bdaebb6 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1274,8 +1274,9 @@ int i40e_del_mac_all_vlan(struct i40e_vsi *vsi, u8 *macaddr,
 		    (is_vf == f->is_vf) &&
 		    (is_netdev == f->is_netdev)) {
 			f->counter--;
-			f->changed = true;
 			changed = 1;
+			if (f->counter == 0)
+				f->state = I40E_FILTER_REMOVE;
 		}
 	}
 	if (changed) {
@@ -1291,29 +1292,32 @@ int i40e_del_mac_all_vlan(struct i40e_vsi *vsi, u8 *macaddr,
  * @vsi: the PF Main VSI - inappropriate for any other VSI
  * @macaddr: the MAC address
  *
- * Some older firmware configurations set up a default promiscuous VLAN
- * filter that needs to be removed.
+ * Remove whatever filter the firmware set up so the driver can manage
+ * its own filtering intelligently.
  **/
-static int i40e_rm_default_mac_filter(struct i40e_vsi *vsi, u8 *macaddr)
+static void i40e_rm_default_mac_filter(struct i40e_vsi *vsi, u8 *macaddr)
 {
 	struct i40e_aqc_remove_macvlan_element_data element;
 	struct i40e_pf *pf = vsi->back;
-	i40e_status ret;
 
 	/* Only appropriate for the PF main VSI */
 	if (vsi->type != I40E_VSI_MAIN)
-		return -EINVAL;
+		return;
 
 	memset(&element, 0, sizeof(element));
 	ether_addr_copy(element.mac_addr, macaddr);
 	element.vlan_tag = 0;
-	element.flags = I40E_AQC_MACVLAN_DEL_PERFECT_MATCH |
-			I40E_AQC_MACVLAN_DEL_IGNORE_VLAN;
-	ret = i40e_aq_remove_macvlan(&pf->hw, vsi->seid, &element, 1, NULL);
-	if (ret)
-		return -ENOENT;
+	/* Ignore error returns, some firmware does it this way... */
+	element.flags = I40E_AQC_MACVLAN_DEL_PERFECT_MATCH;
+	i40e_aq_remove_macvlan(&pf->hw, vsi->seid, &element, 1, NULL);
 
-	return 0;
+	memset(&element, 0, sizeof(element));
+	ether_addr_copy(element.mac_addr, macaddr);
+	element.vlan_tag = 0;
+	/* ...and some firmware does it this way. */
+	element.flags = I40E_AQC_MACVLAN_DEL_PERFECT_MATCH |
+			I40E_AQC_MACVLAN_ADD_IGNORE_VLAN;
+	i40e_aq_remove_macvlan(&pf->hw, vsi->seid, &element, 1, NULL);
 }
 
 /**
@@ -1334,6 +1338,7 @@ struct i40e_mac_filter *i40e_add_filter(struct i40e_vsi *vsi,
 					bool is_vf, bool is_netdev)
 {
 	struct i40e_mac_filter *f;
+	int changed = false;
 
 	if (!vsi || !macaddr)
 		return NULL;
@@ -1346,8 +1351,15 @@ struct i40e_mac_filter *i40e_add_filter(struct i40e_vsi *vsi,
 
 		ether_addr_copy(f->macaddr, macaddr);
 		f->vlan = vlan;
-		f->changed = true;
-
+		/* If we're in overflow promisc mode, set the state directly
+		 * to failed, so we don't bother to try sending the filter
+		 * to the hardware.
+		 */
+		if (test_bit(__I40E_FILTER_OVERFLOW_PROMISC, &vsi->state))
+			f->state = I40E_FILTER_FAILED;
+		else
+			f->state = I40E_FILTER_NEW;
+		changed = true;
 		INIT_LIST_HEAD(&f->list);
 		list_add_tail(&f->list, &vsi->mac_filter_list);
 	}
@@ -1367,10 +1379,7 @@ struct i40e_mac_filter *i40e_add_filter(struct i40e_vsi *vsi,
 		f->counter++;
 	}
 
-	/* changed tells sync_filters_subtask to
-	 * push the filter down to the firmware
-	 */
-	if (f->changed) {
+	if (changed) {
 		vsi->flags |= I40E_VSI_FLAG_FILTER_CHANGED;
 		vsi->back->flags |= I40E_FLAG_FILTER_SYNC;
 	}
@@ -1389,6 +1398,9 @@ add_filter_out:
  *
  * NOTE: This function is expected to be called with mac_filter_list_lock
  * being held.
+ * ANOTHER NOTE: This function MUST be called from within the context of
+ * the "safe" variants of any list iterators, e.g. list_for_each_entry_safe()
+ * instead of list_for_each_entry().
  **/
 void i40e_del_filter(struct i40e_vsi *vsi,
 		     u8 *macaddr, s16 vlan,
@@ -1428,9 +1440,18 @@ void i40e_del_filter(struct i40e_vsi *vsi,
 	 * remove the filter from the firmware's list
 	 */
 	if (f->counter == 0) {
-		f->changed = true;
-		vsi->flags |= I40E_VSI_FLAG_FILTER_CHANGED;
-		vsi->back->flags |= I40E_FLAG_FILTER_SYNC;
+		if ((f->state == I40E_FILTER_FAILED) ||
+		    (f->state == I40E_FILTER_NEW)) {
+			/* this one never got added by the FW. Just remove it,
+			 * no need to sync anything.
+			 */
+			list_del(&f->list);
+			kfree(f);
+		} else {
+			f->state = I40E_FILTER_REMOVE;
+			vsi->flags |= I40E_VSI_FLAG_FILTER_CHANGED;
+			vsi->back->flags |= I40E_FLAG_FILTER_SYNC;
+		}
 	}
 }
 
@@ -1452,7 +1473,6 @@ static int i40e_set_mac(struct net_device *netdev, void *p)
 	struct i40e_pf *pf = vsi->back;
 	struct i40e_hw *hw = &pf->hw;
 	struct sockaddr *addr = p;
-	struct i40e_mac_filter *f;
 
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
@@ -1473,52 +1493,23 @@ static int i40e_set_mac(struct net_device *netdev, void *p)
 	else
 		netdev_info(netdev, "set new mac address %pM\n", addr->sa_data);
 
+	spin_lock_bh(&vsi->mac_filter_list_lock);
+	i40e_del_mac_all_vlan(vsi, netdev->dev_addr, false, true);
+	i40e_put_mac_in_vlan(vsi, addr->sa_data, false, true);
+	spin_unlock_bh(&vsi->mac_filter_list_lock);
+	ether_addr_copy(netdev->dev_addr, addr->sa_data);
 	if (vsi->type == I40E_VSI_MAIN) {
 		i40e_status ret;
 
 		ret = i40e_aq_mac_address_write(&vsi->back->hw,
 						I40E_AQC_WRITE_TYPE_LAA_WOL,
 						addr->sa_data, NULL);
-		if (ret) {
-			netdev_info(netdev,
-				    "Addr change for Main VSI failed: %d\n",
-				    ret);
-			return -EADDRNOTAVAIL;
-		}
-	}
-
-	if (ether_addr_equal(netdev->dev_addr, hw->mac.addr)) {
-		struct i40e_aqc_remove_macvlan_element_data element;
-
-		memset(&element, 0, sizeof(element));
-		ether_addr_copy(element.mac_addr, netdev->dev_addr);
-		element.flags = I40E_AQC_MACVLAN_DEL_PERFECT_MATCH;
-		i40e_aq_remove_macvlan(&pf->hw, vsi->seid, &element, 1, NULL);
-	} else {
-		spin_lock_bh(&vsi->mac_filter_list_lock);
-		i40e_del_filter(vsi, netdev->dev_addr, I40E_VLAN_ANY,
-				false, false);
-		spin_unlock_bh(&vsi->mac_filter_list_lock);
-	}
-
-	if (ether_addr_equal(addr->sa_data, hw->mac.addr)) {
-		struct i40e_aqc_add_macvlan_element_data element;
-
-		memset(&element, 0, sizeof(element));
-		ether_addr_copy(element.mac_addr, hw->mac.addr);
-		element.flags = cpu_to_le16(I40E_AQC_MACVLAN_ADD_PERFECT_MATCH);
-		i40e_aq_add_macvlan(&pf->hw, vsi->seid, &element, 1, NULL);
-	} else {
-		spin_lock_bh(&vsi->mac_filter_list_lock);
-		f = i40e_add_filter(vsi, addr->sa_data, I40E_VLAN_ANY,
-				    false, false);
-		if (f)
-			f->is_laa = true;
-		spin_unlock_bh(&vsi->mac_filter_list_lock);
+		if (ret)
+			netdev_info(netdev, "Ignoring error from firmware on LAA update, status %s, AQ ret %s\n",
+				    i40e_stat_str(hw, ret),
+				    i40e_aq_str(hw, hw->aq.asq_last_status));
 	}
 
-	ether_addr_copy(netdev->dev_addr, addr->sa_data);
-
 	/* schedule our worker thread which will take care of
 	 * applying the new filter changes
 	 */
@@ -1749,28 +1740,6 @@ bottom_of_search_loop:
 }
 
 /**
- * i40e_mac_filter_entry_clone - Clones a MAC filter entry
- * @src: source MAC filter entry to be clones
- *
- * Returns the pointer to newly cloned MAC filter entry or NULL
- * in case of error
- **/
-static struct i40e_mac_filter *i40e_mac_filter_entry_clone(
-					struct i40e_mac_filter *src)
-{
-	struct i40e_mac_filter *f;
-
-	f = kzalloc(sizeof(*f), GFP_ATOMIC);
-	if (!f)
-		return NULL;
-	*f = *src;
-
-	INIT_LIST_HEAD(&f->list);
-
-	return f;
-}
-
-/**
  * i40e_undo_del_filter_entries - Undo the changes made to MAC filter entries
  * @vsi: pointer to vsi struct
  * @from: Pointer to list which contains MAC filter entries - changes to
@@ -1784,41 +1753,61 @@ static void i40e_undo_del_filter_entries(struct i40e_vsi *vsi,
 	struct i40e_mac_filter *f, *ftmp;
 
 	list_for_each_entry_safe(f, ftmp, from, list) {
-		f->changed = true;
 		/* Move the element back into MAC filter list*/
 		list_move_tail(&f->list, &vsi->mac_filter_list);
 	}
 }
 
 /**
- * i40e_undo_add_filter_entries - Undo the changes made to MAC filter entries
- * @vsi: pointer to vsi struct
+ * i40e_update_filter_state - Update filter state based on return data
+ * from firmware
+ * @count: Number of filters added
+ * @add_list: return data from fw
+ * @head: pointer to first filter in current batch
+ * @aq_err: status from fw
  *
- * MAC filter entries from list were slated to be added from device.
+ * MAC filter entries from list were slated to be added to device. Returns
+ * number of successful filters. Note that 0 does NOT mean success!
  **/
-static void i40e_undo_add_filter_entries(struct i40e_vsi *vsi)
+static int
+i40e_update_filter_state(int count,
+			 struct i40e_aqc_add_macvlan_element_data *add_list,
+			 struct i40e_mac_filter *add_head, int aq_err)
 {
-	struct i40e_mac_filter *f, *ftmp;
-
-	list_for_each_entry_safe(f, ftmp, &vsi->mac_filter_list, list) {
-		if (!f->changed && f->counter)
-			f->changed = true;
-	}
-}
+	int retval = 0;
+	int i;
 
-/**
- * i40e_cleanup_add_list - Deletes the element from add list and release
- *			memory
- * @add_list: Pointer to list which contains MAC filter entries
- **/
-static void i40e_cleanup_add_list(struct list_head *add_list)
-{
-	struct i40e_mac_filter *f, *ftmp;
 
-	list_for_each_entry_safe(f, ftmp, add_list, list) {
-		list_del(&f->list);
-		kfree(f);
+	if (!aq_err) {
+		retval = count;
+		/* Everything's good, mark all filters active. */
+		for (i = 0; i < count ; i++) {
+			add_head->state = I40E_FILTER_ACTIVE;
+			add_head = list_next_entry(add_head, list);
+		}
+	} else if (aq_err == I40E_AQ_RC_ENOSPC) {
+		/* Device ran out of filter space. Check the return value
+		 * for each filter to see which ones are active.
+		 */
+		for (i = 0; i < count ; i++) {
+			if (add_list[i].match_method ==
+			    I40E_AQC_MM_ERR_NO_RES) {
+				add_head->state = I40E_FILTER_FAILED;
+			} else {
+				add_head->state = I40E_FILTER_ACTIVE;
+				retval++;
+			}
+			add_head = list_next_entry(add_head, list);
+		}
+	} else {
+		/* Some other horrible thing happened, fail all filters */
+		retval = 0;
+		for (i = 0; i < count ; i++) {
+			add_head->state = I40E_FILTER_FAILED;
+			add_head = list_next_entry(add_head, list);
+		}
 	}
+	return retval;
 }
 
 /**
@@ -1831,22 +1820,22 @@ static void i40e_cleanup_add_list(struct list_head *add_list)
  **/
 int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 {
-	struct list_head tmp_del_list, tmp_add_list;
-	struct i40e_mac_filter *f, *ftmp, *fclone;
+	struct i40e_mac_filter *f, *ftmp, *add_head = NULL;
+	struct list_head tmp_add_list, tmp_del_list;
 	struct i40e_hw *hw = &vsi->back->hw;
-	bool promisc_forced_on = false;
-	bool add_happened = false;
+	bool promisc_changed = false;
 	char vsi_name[16] = "PF";
 	int filter_list_len = 0;
 	u32 changed_flags = 0;
 	i40e_status aq_ret = 0;
-	bool err_cond = false;
 	int retval = 0;
 	struct i40e_pf *pf;
 	int num_add = 0;
 	int num_del = 0;
 	int aq_err = 0;
 	u16 cmd_flags;
+	int list_size;
+	int fcnt;
 
 	/* empty array typed pointers, kcalloc later */
 	struct i40e_aqc_add_macvlan_element_data *add_list;
@@ -1861,8 +1850,8 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 		vsi->current_netdev_flags = vsi->netdev->flags;
 	}
 
-	INIT_LIST_HEAD(&tmp_del_list);
 	INIT_LIST_HEAD(&tmp_add_list);
+	INIT_LIST_HEAD(&tmp_del_list);
 
 	if (vsi->type == I40E_VSI_SRIOV)
 		snprintf(vsi_name, sizeof(vsi_name) - 1, "VF %d", vsi->vf_id);
@@ -1873,65 +1862,34 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 		vsi->flags &= ~I40E_VSI_FLAG_FILTER_CHANGED;
 
 		spin_lock_bh(&vsi->mac_filter_list_lock);
+		/* Create a list of filters to delete. */
 		list_for_each_entry_safe(f, ftmp, &vsi->mac_filter_list, list) {
-			if (!f->changed)
-				continue;
-
-			if (f->counter != 0)
-				continue;
-			f->changed = false;
-
-			/* Move the element into temporary del_list */
-			list_move_tail(&f->list, &tmp_del_list);
-		}
-
-		list_for_each_entry_safe(f, ftmp, &vsi->mac_filter_list, list) {
-			if (!f->changed)
-				continue;
-
-			if (f->counter == 0)
-				continue;
-			f->changed = false;
-
-			/* Clone MAC filter entry and add into temporary list */
-			fclone = i40e_mac_filter_entry_clone(f);
-			if (!fclone) {
-				err_cond = true;
-				break;
+			if (f->state == I40E_FILTER_REMOVE) {
+				WARN_ON(f->counter != 0);
+				/* Move the element into temporary del_list */
+				list_move_tail(&f->list, &tmp_del_list);
+				vsi->active_filters--;
+			}
+			if (f->state == I40E_FILTER_NEW) {
+				WARN_ON(f->counter == 0);
+				/* Move the element into temporary add_list */
+				list_move_tail(&f->list, &tmp_add_list);
 			}
-			list_add_tail(&fclone->list, &tmp_add_list);
-		}
-
-		/* if failed to clone MAC filter entry - undo */
-		if (err_cond) {
-			i40e_undo_del_filter_entries(vsi, &tmp_del_list);
-			i40e_undo_add_filter_entries(vsi);
 		}
 		spin_unlock_bh(&vsi->mac_filter_list_lock);
-
-		if (err_cond) {
-			i40e_cleanup_add_list(&tmp_add_list);
-			retval = -ENOMEM;
-			goto out;
-		}
 	}
 
 	/* Now process 'del_list' outside the lock */
 	if (!list_empty(&tmp_del_list)) {
-		int del_list_size;
-
 		filter_list_len = hw->aq.asq_buf_size /
 			    sizeof(struct i40e_aqc_remove_macvlan_element_data);
-		del_list_size = filter_list_len *
+		list_size = filter_list_len *
 			    sizeof(struct i40e_aqc_remove_macvlan_element_data);
-		del_list = kzalloc(del_list_size, GFP_ATOMIC);
+		del_list = kzalloc(list_size, GFP_ATOMIC);
 		if (!del_list) {
-			i40e_cleanup_add_list(&tmp_add_list);
-
 			/* Undo VSI's MAC filter entry element updates */
 			spin_lock_bh(&vsi->mac_filter_list_lock);
 			i40e_undo_del_filter_entries(vsi, &tmp_del_list);
-			i40e_undo_add_filter_entries(vsi);
 			spin_unlock_bh(&vsi->mac_filter_list_lock);
 			retval = -ENOMEM;
 			goto out;
@@ -1942,9 +1900,13 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 
 			/* add to delete list */
 			ether_addr_copy(del_list[num_del].mac_addr, f->macaddr);
-			del_list[num_del].vlan_tag =
-				cpu_to_le16((u16)(f->vlan ==
-					    I40E_VLAN_ANY ? 0 : f->vlan));
+			if (f->vlan == I40E_VLAN_ANY) {
+				del_list[num_del].vlan_tag = 0;
+				cmd_flags |= I40E_AQC_MACVLAN_ADD_IGNORE_VLAN;
+			} else {
+				del_list[num_del].vlan_tag =
+					cpu_to_le16((u16)(f->vlan));
+			}
 
 			cmd_flags |= I40E_AQC_MACVLAN_DEL_PERFECT_MATCH;
 			del_list[num_del].flags = cmd_flags;
@@ -1952,18 +1914,20 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 
 			/* flush a full buffer */
 			if (num_del == filter_list_len) {
-				aq_ret =
-					i40e_aq_remove_macvlan(hw, vsi->seid,
-							       del_list,
-							       num_del, NULL);
+				aq_ret = i40e_aq_remove_macvlan(hw, vsi->seid,
+								del_list,
+								num_del, NULL);
 				aq_err = hw->aq.asq_last_status;
 				num_del = 0;
-				memset(del_list, 0, del_list_size);
+				memset(del_list, 0, list_size);
 
-				if (aq_ret && aq_err != I40E_AQ_RC_ENOENT) {
+				/* Explicitly ignore and do not report when
+				 * firmware returns ENOENT.
+				 */
+				if (aq_ret && !(aq_err == I40E_AQ_RC_ENOENT)) {
 					retval = -EIO;
-					dev_err(&pf->pdev->dev,
-						 "ignoring delete macvlan error on %s, err %s, aq_err %s while flushing a full buffer\n",
+					dev_info(&pf->pdev->dev,
+						 "ignoring delete macvlan error on %s, err %s, aq_err %s\n",
 						 vsi_name,
 						 i40e_stat_str(hw, aq_ret),
 						 i40e_aq_str(hw, aq_err));
@@ -1982,12 +1946,17 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 			aq_err = hw->aq.asq_last_status;
 			num_del = 0;
 
-			if (aq_ret && aq_err != I40E_AQ_RC_ENOENT)
+			/* Explicitly ignore and do not report when firmware
+			 * returns ENOENT.
+			 */
+			if (aq_ret && !(aq_err == I40E_AQ_RC_ENOENT)) {
+				retval = -EIO;
 				dev_info(&pf->pdev->dev,
 					 "ignoring delete macvlan error on %s, err %s aq_err %s\n",
 					 vsi_name,
 					 i40e_stat_str(hw, aq_ret),
 					 i40e_aq_str(hw, aq_err));
+			}
 		}
 
 		kfree(del_list);
@@ -1995,38 +1964,36 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 	}
 
 	if (!list_empty(&tmp_add_list)) {
-		int add_list_size;
-
-		/* do all the adds now */
+		/* Do all the adds now. */
 		filter_list_len = hw->aq.asq_buf_size /
-			       sizeof(struct i40e_aqc_add_macvlan_element_data),
-		add_list_size = filter_list_len *
 			       sizeof(struct i40e_aqc_add_macvlan_element_data);
-		add_list = kzalloc(add_list_size, GFP_ATOMIC);
+		list_size = filter_list_len *
+			       sizeof(struct i40e_aqc_add_macvlan_element_data);
+		add_list = kzalloc(list_size, GFP_ATOMIC);
 		if (!add_list) {
-			/* Purge element from temporary lists */
-			i40e_cleanup_add_list(&tmp_add_list);
-
-			/* Undo add filter entries from VSI MAC filter list */
-			spin_lock_bh(&vsi->mac_filter_list_lock);
-			i40e_undo_add_filter_entries(vsi);
-			spin_unlock_bh(&vsi->mac_filter_list_lock);
 			retval = -ENOMEM;
 			goto out;
 		}
-
-		list_for_each_entry_safe(f, ftmp, &tmp_add_list, list) {
-
-			add_happened = true;
-			cmd_flags = 0;
-
+		num_add = 0;
+		list_for_each_entry(f, &tmp_add_list, list) {
+			if (test_bit(__I40E_FILTER_OVERFLOW_PROMISC,
+				     &vsi->state)) {
+				f->state = I40E_FILTER_FAILED;
+				continue;
+			}
 			/* add to add array */
+			if (num_add == 0)
+				add_head = f;
+			cmd_flags = 0;
 			ether_addr_copy(add_list[num_add].mac_addr, f->macaddr);
-			add_list[num_add].vlan_tag =
-				cpu_to_le16(
-				 (u16)(f->vlan == I40E_VLAN_ANY ? 0 : f->vlan));
+			if (f->vlan == I40E_VLAN_ANY) {
+				add_list[num_add].vlan_tag = 0;
+				cmd_flags |= I40E_AQC_MACVLAN_ADD_IGNORE_VLAN;
+			} else {
+				add_list[num_add].vlan_tag =
+					cpu_to_le16((u16)(f->vlan));
+			}
 			add_list[num_add].queue_number = 0;
-
 			cmd_flags |= I40E_AQC_MACVLAN_ADD_PERFECT_MATCH;
 			add_list[num_add].flags = cpu_to_le16(cmd_flags);
 			num_add++;
@@ -2037,44 +2004,77 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 							     add_list, num_add,
 							     NULL);
 				aq_err = hw->aq.asq_last_status;
+				fcnt = i40e_update_filter_state(num_add,
+								add_list,
+								add_head,
+								aq_ret);
+				vsi->active_filters += fcnt;
+
+				if (fcnt != num_add) {
+					promisc_changed = true;
+					set_bit(__I40E_FILTER_OVERFLOW_PROMISC,
+						&vsi->state);
+					vsi->promisc_threshold =
+						(vsi->active_filters * 3) / 4;
+					dev_warn(&pf->pdev->dev,
+						 "Error %s adding RX filters on %s, promiscuous mode forced on\n",
+						 i40e_aq_str(hw, aq_err),
+						 vsi_name);
+				}
+				memset(add_list, 0, list_size);
 				num_add = 0;
-
-				if (aq_ret)
-					break;
-				memset(add_list, 0, add_list_size);
 			}
-			/* Entries from tmp_add_list were cloned from MAC
-			 * filter list, hence clean those cloned entries
-			 */
-			list_del(&f->list);
-			kfree(f);
 		}
-
 		if (num_add) {
 			aq_ret = i40e_aq_add_macvlan(hw, vsi->seid,
 						     add_list, num_add, NULL);
 			aq_err = hw->aq.asq_last_status;
-			num_add = 0;
+			fcnt = i40e_update_filter_state(num_add, add_list,
+							add_head, aq_ret);
+			vsi->active_filters += fcnt;
+			if (fcnt != num_add) {
+				promisc_changed = true;
+				set_bit(__I40E_FILTER_OVERFLOW_PROMISC,
+					&vsi->state);
+				vsi->promisc_threshold =
+						(vsi->active_filters * 3) / 4;
+				dev_warn(&pf->pdev->dev,
+					 "Error %s adding RX filters on %s, promiscuous mode forced on\n",
+					 i40e_aq_str(hw, aq_err), vsi_name);
+			}
 		}
+		/* Now move all of the filters from the temp add list back to
+		 * the VSI's list.
+		 */
+		spin_lock_bh(&vsi->mac_filter_list_lock);
+		list_for_each_entry_safe(f, ftmp, &tmp_add_list, list) {
+			list_move_tail(&f->list, &vsi->mac_filter_list);
+		}
+		spin_unlock_bh(&vsi->mac_filter_list_lock);
 		kfree(add_list);
 		add_list = NULL;
+	}
 
-		if (add_happened && aq_ret && aq_err != I40E_AQ_RC_EINVAL) {
-			retval = i40e_aq_rc_to_posix(aq_ret, aq_err);
+	/* Check to see if we can drop out of overflow promiscuous mode. */
+	if (test_bit(__I40E_FILTER_OVERFLOW_PROMISC, &vsi->state) &&
+	    (vsi->active_filters < vsi->promisc_threshold)) {
+		int failed_count = 0;
+		/* See if we have any failed filters. We can't drop out of
+		 * promiscuous until these have all been deleted.
+		 */
+		spin_lock_bh(&vsi->mac_filter_list_lock);
+		list_for_each_entry(f, &vsi->mac_filter_list, list) {
+			if (f->state == I40E_FILTER_FAILED)
+				failed_count++;
+		}
+		spin_unlock_bh(&vsi->mac_filter_list_lock);
+		if (!failed_count) {
 			dev_info(&pf->pdev->dev,
-				 "add filter failed on %s, err %s aq_err %s\n",
-				 vsi_name,
-				 i40e_stat_str(hw, aq_ret),
-				 i40e_aq_str(hw, aq_err));
-			if ((hw->aq.asq_last_status == I40E_AQ_RC_ENOSPC) &&
-			    !test_bit(__I40E_FILTER_OVERFLOW_PROMISC,
-				      &vsi->state)) {
-				promisc_forced_on = true;
-				set_bit(__I40E_FILTER_OVERFLOW_PROMISC,
-					&vsi->state);
-				dev_info(&pf->pdev->dev, "promiscuous mode forced on %s\n",
-					 vsi_name);
-			}
+				 "filter logjam cleared on %s, leaving overflow promiscuous mode\n",
+				 vsi_name);
+			clear_bit(__I40E_FILTER_OVERFLOW_PROMISC, &vsi->state);
+			promisc_changed = true;
+			vsi->promisc_threshold = 0;
 		}
 	}
 
@@ -2103,7 +2103,9 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 				 i40e_aq_str(hw, hw->aq.asq_last_status));
 		}
 	}
-	if ((changed_flags & IFF_PROMISC) || promisc_forced_on) {
+	if ((changed_flags & IFF_PROMISC) ||
+	    (promisc_changed &&
+	     test_bit(__I40E_FILTER_OVERFLOW_PROMISC, &vsi->state))) {
 		bool cur_promisc;
 
 		cur_promisc = (!!(vsi->current_netdev_flags & IFF_PROMISC) ||
@@ -2352,7 +2354,7 @@ static void i40e_vlan_rx_register(struct net_device *netdev, u32 features)
  **/
 int i40e_vsi_add_vlan(struct i40e_vsi *vsi, s16 vid)
 {
-	struct i40e_mac_filter *f, *add_f;
+	struct i40e_mac_filter *f, *ftmp, *add_f;
 	bool is_netdev, is_vf;
 
 	is_vf = (vsi->type == I40E_VSI_SRIOV);
@@ -2373,7 +2375,7 @@ int i40e_vsi_add_vlan(struct i40e_vsi *vsi, s16 vid)
 		}
 	}
 
-	list_for_each_entry(f, &vsi->mac_filter_list, list) {
+	list_for_each_entry_safe(f, ftmp, &vsi->mac_filter_list, list) {
 		add_f = i40e_add_filter(vsi, f->macaddr, vid, is_vf, is_netdev);
 		if (!add_f) {
 			dev_info(&vsi->back->pdev->dev,
@@ -2387,7 +2389,7 @@ int i40e_vsi_add_vlan(struct i40e_vsi *vsi, s16 vid)
 	/* Now if we add a vlan tag, make sure to check if it is the first
 	 * tag (i.e. a "tag" -1 does exist) and if so replace the -1 "tag"
 	 * with 0, so we now accept untagged and specified tagged traffic
-	 * (and not any taged and untagged)
+	 * (and not all tags along with untagged)
 	 */
 	if (vid > 0) {
 		if (is_netdev && i40e_find_filter(vsi, vsi->netdev->dev_addr,
@@ -2409,7 +2411,7 @@ int i40e_vsi_add_vlan(struct i40e_vsi *vsi, s16 vid)
 
 	/* Do not assume that I40E_VLAN_ANY should be reset to VLAN 0 */
 	if (vid > 0 && !vsi->info.pvid) {
-		list_for_each_entry(f, &vsi->mac_filter_list, list) {
+		list_for_each_entry_safe(f, ftmp, &vsi->mac_filter_list, list) {
 			if (!i40e_find_filter(vsi, f->macaddr, I40E_VLAN_ANY,
 					      is_vf, is_netdev))
 				continue;
@@ -2446,7 +2448,7 @@ int i40e_vsi_add_vlan(struct i40e_vsi *vsi, s16 vid)
 int i40e_vsi_kill_vlan(struct i40e_vsi *vsi, s16 vid)
 {
 	struct net_device *netdev = vsi->netdev;
-	struct i40e_mac_filter *f, *add_f;
+	struct i40e_mac_filter *f, *ftmp, *add_f;
 	bool is_vf, is_netdev;
 	int filter_count = 0;
 
@@ -2459,7 +2461,7 @@ int i40e_vsi_kill_vlan(struct i40e_vsi *vsi, s16 vid)
 	if (is_netdev)
 		i40e_del_filter(vsi, netdev->dev_addr, vid, is_vf, is_netdev);
 
-	list_for_each_entry(f, &vsi->mac_filter_list, list)
+	list_for_each_entry_safe(f, ftmp, &vsi->mac_filter_list, list)
 		i40e_del_filter(vsi, f->macaddr, vid, is_vf, is_netdev);
 
 	/* go through all the filters for this VSI and if there is only
@@ -2492,7 +2494,7 @@ int i40e_vsi_kill_vlan(struct i40e_vsi *vsi, s16 vid)
 	}
 
 	if (!filter_count) {
-		list_for_each_entry(f, &vsi->mac_filter_list, list) {
+		list_for_each_entry_safe(f, ftmp, &vsi->mac_filter_list, list) {
 			i40e_del_filter(vsi, f->macaddr, 0, is_vf, is_netdev);
 			add_f = i40e_add_filter(vsi, f->macaddr, I40E_VLAN_ANY,
 						is_vf, is_netdev);
@@ -2537,8 +2539,6 @@ static int i40e_vlan_rx_add_vid(struct net_device *netdev,
 	if (vid > 4095)
 		return -EINVAL;
 
-	netdev_info(netdev, "adding %pM vid=%d\n", netdev->dev_addr, vid);
-
 	/* If the network stack called us with vid = 0 then
 	 * it is asking to receive priority tagged packets with
 	 * vlan id 0.  Our HW receives them by default when configured
@@ -2572,8 +2572,6 @@ static int i40e_vlan_rx_kill_vid(struct net_device *netdev,
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
 
-	netdev_info(netdev, "removing %pM vid=%d\n", netdev->dev_addr, vid);
-
 	/* return code is ignored as there is nothing a user
 	 * can do about failure to remove and a log message was
 	 * already printed from the other function
@@ -9005,7 +9003,6 @@ static const struct net_device_ops i40e_netdev_ops = {
  **/
 static int i40e_config_netdev(struct i40e_vsi *vsi)
 {
-	u8 brdcast[ETH_ALEN] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
 	struct i40e_pf *pf = vsi->back;
 	struct i40e_hw *hw = &pf->hw;
 	struct i40e_netdev_priv *np;
@@ -9069,18 +9066,10 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
 		 * default a MAC-VLAN filter that accepts any tagged packet
 		 * which must be replaced by a normal filter.
 		 */
-		if (!i40e_rm_default_mac_filter(vsi, mac_addr)) {
-			spin_lock_bh(&vsi->mac_filter_list_lock);
-			i40e_add_filter(vsi, mac_addr,
-					I40E_VLAN_ANY, false, true);
-			spin_unlock_bh(&vsi->mac_filter_list_lock);
-		}
-	} else if ((pf->hw.aq.api_maj_ver > 1) ||
-		   ((pf->hw.aq.api_maj_ver == 1) &&
-		    (pf->hw.aq.api_min_ver > 4))) {
-		/* Supported in FW API version higher than 1.4 */
-		pf->flags |= I40E_FLAG_GENEVE_OFFLOAD_CAPABLE;
-		pf->auto_disable_flags = I40E_FLAG_HW_ATR_EVICT_CAPABLE;
+		i40e_rm_default_mac_filter(vsi, mac_addr);
+		spin_lock_bh(&vsi->mac_filter_list_lock);
+		i40e_add_filter(vsi, mac_addr, I40E_VLAN_ANY, false, true);
+		spin_unlock_bh(&vsi->mac_filter_list_lock);
 	} else {
 		/* relate the VSI_VMDQ name to the VSI_MAIN name */
 		snprintf(netdev->name, IFNAMSIZ, "%sv%%d",
@@ -9092,10 +9081,6 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
 		spin_unlock_bh(&vsi->mac_filter_list_lock);
 	}
 
-	spin_lock_bh(&vsi->mac_filter_list_lock);
-	i40e_add_filter(vsi, brdcast, I40E_VLAN_ANY, false, false);
-	spin_unlock_bh(&vsi->mac_filter_list_lock);
-
 	ether_addr_copy(netdev->dev_addr, mac_addr);
 	ether_addr_copy(netdev->perm_addr, mac_addr);
 
@@ -9173,8 +9158,6 @@ int i40e_is_vsi_uplink_mode_veb(struct i40e_vsi *vsi)
 static int i40e_add_vsi(struct i40e_vsi *vsi)
 {
 	int ret = -ENODEV;
-	u8 laa_macaddr[ETH_ALEN];
-	bool found_laa_mac_filter = false;
 	struct i40e_pf *pf = vsi->back;
 	struct i40e_hw *hw = &pf->hw;
 	struct i40e_vsi_context ctxt;
@@ -9363,41 +9346,16 @@ static int i40e_add_vsi(struct i40e_vsi *vsi)
 		vsi->id = ctxt.vsi_number;
 	}
 
+	vsi->active_filters = 0;
+	clear_bit(__I40E_FILTER_OVERFLOW_PROMISC, &vsi->state);
 	spin_lock_bh(&vsi->mac_filter_list_lock);
 	/* If macvlan filters already exist, force them to get loaded */
 	list_for_each_entry_safe(f, ftmp, &vsi->mac_filter_list, list) {
-		f->changed = true;
+		f->state = I40E_FILTER_NEW;
 		f_count++;
-
-		/* Expected to have only one MAC filter entry for LAA in list */
-		if (f->is_laa && vsi->type == I40E_VSI_MAIN) {
-			ether_addr_copy(laa_macaddr, f->macaddr);
-			found_laa_mac_filter = true;
-		}
 	}
 	spin_unlock_bh(&vsi->mac_filter_list_lock);
 
-	if (found_laa_mac_filter) {
-		struct i40e_aqc_remove_macvlan_element_data element;
-
-		memset(&element, 0, sizeof(element));
-		ether_addr_copy(element.mac_addr, laa_macaddr);
-		element.flags = I40E_AQC_MACVLAN_DEL_PERFECT_MATCH;
-		ret = i40e_aq_remove_macvlan(hw, vsi->seid,
-					     &element, 1, NULL);
-		if (ret) {
-			/* some older FW has a different default */
-			element.flags |=
-				       I40E_AQC_MACVLAN_DEL_IGNORE_VLAN;
-			i40e_aq_remove_macvlan(hw, vsi->seid,
-					       &element, 1, NULL);
-		}
-
-		i40e_aq_mac_address_write(hw,
-					  I40E_AQC_WRITE_TYPE_LAA_WOL,
-					  laa_macaddr, NULL);
-	}
-
 	if (f_count) {
 		vsi->flags |= I40E_VSI_FLAG_FILTER_CHANGED;
 		pf->flags |= I40E_FLAG_FILTER_SYNC;
@@ -9608,6 +9566,8 @@ static struct i40e_vsi *i40e_vsi_reinit_setup(struct i40e_vsi *vsi)
 	pf->vsi[pf->lan_vsi]->tc_config.enabled_tc = 0;
 	pf->vsi[pf->lan_vsi]->seid = pf->main_vsi_seid;
 	i40e_vsi_config_tc(pf->vsi[pf->lan_vsi], enabled_tc);
+	if (vsi->type == I40E_VSI_MAIN)
+		i40e_rm_default_mac_filter(vsi, pf->hw.mac.perm_addr);
 
 	/* assign it some queues */
 	ret = i40e_alloc_rings(vsi);
-- 
2.5.5
