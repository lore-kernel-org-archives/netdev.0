From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/22] i40e: remove duplicate add/delete adminq command code for filters
Date: Mon, 31 Oct 2016 15:29:42 -0700
Message-ID: <1477952992-125662-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1477952992-125662-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:46390 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1034506AbcJaW37 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 31 Oct 2016 18:29:59 -0400
In-Reply-To: <1477952992-125662-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

We duplicate some code around adding and deleting filters using the
adminq interface. This is prone to errors in case there are bugs. Use
functions which extract the logic to their own portion so that we don't
duplicate it twice in code.

Change-ID: I60d68aeb887976787dec00b23ab386a106e61465
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 156 +++++++++++++++-------------
 1 file changed, 84 insertions(+), 72 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index b4529b5..5fe54e5 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1783,6 +1783,80 @@ i40e_update_filter_state(int count,
 }
 
 /**
+ * i40e_aqc_del_filters - Request firmware to delete a set of filters
+ * @vsi: ptr to the VSI
+ * @vsi_name: name to display in messages
+ * @list: the list of filters to send to firmware
+ * @num_del: the number of filters to delete
+ * @retval: Set to -EIO on failure to delete
+ *
+ * Send a request to firmware via AdminQ to delete a set of filters. Uses
+ * *retval instead of a return value so that success does not force ret_val to
+ * be set to 0. This ensures that a sequence of calls to this function
+ * preserve the previous value of *retval on successful delete.
+ */
+static
+void i40e_aqc_del_filters(struct i40e_vsi *vsi, const char *vsi_name,
+			  struct i40e_aqc_remove_macvlan_element_data *list,
+			  int num_del, int *retval)
+{
+	struct i40e_hw *hw = &vsi->back->hw;
+	i40e_status aq_ret;
+	int aq_err;
+
+	aq_ret = i40e_aq_remove_macvlan(hw, vsi->seid, list, num_del, NULL);
+	aq_err = hw->aq.asq_last_status;
+
+	/* Explicitly ignore and do not report when firmware returns ENOENT */
+	if (aq_ret && !(aq_err == I40E_AQ_RC_ENOENT)) {
+		*retval = -EIO;
+		dev_info(&vsi->back->pdev->dev,
+			 "ignoring delete macvlan error on %s, err %s, aq_err %s\n",
+			 vsi_name, i40e_stat_str(hw, aq_ret),
+			 i40e_aq_str(hw, aq_err));
+	}
+}
+
+/**
+ * i40e_aqc_add_filters - Request firmware to add a set of filters
+ * @vsi: ptr to the VSI
+ * @vsi_name: name to display in messages
+ * @list: the list of filters to send to firmware
+ * @add_head: Position in the add hlist
+ * @num_add: the number of filters to add
+ * @promisc_change: set to true on exit if promiscuous mode was forced on
+ *
+ * Send a request to firmware via AdminQ to add a chunk of filters. Will set
+ * promisc_changed to true if the firmware has run out of space for more
+ * filters.
+ */
+static
+void i40e_aqc_add_filters(struct i40e_vsi *vsi, const char *vsi_name,
+			  struct i40e_aqc_add_macvlan_element_data *list,
+			  struct i40e_mac_filter *add_head,
+			  int num_add, bool *promisc_changed)
+{
+	struct i40e_hw *hw = &vsi->back->hw;
+	i40e_status aq_ret;
+	int aq_err, fcnt;
+
+	aq_ret = i40e_aq_add_macvlan(hw, vsi->seid, list, num_add, NULL);
+	aq_err = hw->aq.asq_last_status;
+	fcnt = i40e_update_filter_state(num_add, list, add_head, aq_ret);
+	vsi->active_filters += fcnt;
+
+	if (fcnt != num_add) {
+		*promisc_changed = true;
+		set_bit(__I40E_FILTER_OVERFLOW_PROMISC, &vsi->state);
+		vsi->promisc_threshold = (vsi->active_filters * 3) / 4;
+		dev_warn(&vsi->back->pdev->dev,
+			 "Error %s adding RX filters on %s, promiscuous mode forced on\n",
+			 i40e_aq_str(hw, aq_err),
+			 vsi_name);
+	}
+}
+
+/**
  * i40e_sync_vsi_filters - Update the VSI filter list to the HW
  * @vsi: ptr to the VSI
  *
@@ -1808,10 +1882,8 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 	int num_add = 0;
 	int num_del = 0;
 	int retval = 0;
-	int aq_err = 0;
 	u16 cmd_flags;
 	int list_size;
-	int fcnt;
 	int bkt;
 
 	/* empty array typed pointers, kcalloc later */
@@ -1948,24 +2020,10 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 
 			/* flush a full buffer */
 			if (num_del == filter_list_len) {
-				aq_ret = i40e_aq_remove_macvlan(hw, vsi->seid,
-								del_list,
-								num_del, NULL);
-				aq_err = hw->aq.asq_last_status;
-				num_del = 0;
+				i40e_aqc_del_filters(vsi, vsi_name, del_list,
+						     num_del, &retval);
 				memset(del_list, 0, list_size);
-
-				/* Explicitly ignore and do not report when
-				 * firmware returns ENOENT.
-				 */
-				if (aq_ret && !(aq_err == I40E_AQ_RC_ENOENT)) {
-					retval = -EIO;
-					dev_info(&pf->pdev->dev,
-						 "ignoring delete macvlan error on %s, err %s, aq_err %s\n",
-						 vsi_name,
-						 i40e_stat_str(hw, aq_ret),
-						 i40e_aq_str(hw, aq_err));
-				}
+				num_del = 0;
 			}
 			/* Release memory for MAC filter entries which were
 			 * synced up with HW.
@@ -1975,22 +2033,8 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 		}
 
 		if (num_del) {
-			aq_ret = i40e_aq_remove_macvlan(hw, vsi->seid, del_list,
-							num_del, NULL);
-			aq_err = hw->aq.asq_last_status;
-			num_del = 0;
-
-			/* Explicitly ignore and do not report when firmware
-			 * returns ENOENT.
-			 */
-			if (aq_ret && !(aq_err == I40E_AQ_RC_ENOENT)) {
-				retval = -EIO;
-				dev_info(&pf->pdev->dev,
-					 "ignoring delete macvlan error on %s, err %s aq_err %s\n",
-					 vsi_name,
-					 i40e_stat_str(hw, aq_ret),
-					 i40e_aq_str(hw, aq_err));
-			}
+			i40e_aqc_del_filters(vsi, vsi_name, del_list,
+					     num_del, &retval);
 		}
 
 		kfree(del_list);
@@ -2041,48 +2085,16 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 
 			/* flush a full buffer */
 			if (num_add == filter_list_len) {
-				aq_ret = i40e_aq_add_macvlan(hw, vsi->seid,
-							     add_list, num_add,
-							     NULL);
-				aq_err = hw->aq.asq_last_status;
-				fcnt = i40e_update_filter_state(num_add,
-								add_list,
-								add_head,
-								aq_ret);
-				vsi->active_filters += fcnt;
-
-				if (fcnt != num_add) {
-					promisc_changed = true;
-					set_bit(__I40E_FILTER_OVERFLOW_PROMISC,
-						&vsi->state);
-					vsi->promisc_threshold =
-						(vsi->active_filters * 3) / 4;
-					dev_warn(&pf->pdev->dev,
-						 "Error %s adding RX filters on %s, promiscuous mode forced on\n",
-						 i40e_aq_str(hw, aq_err),
-						 vsi_name);
-				}
+				i40e_aqc_add_filters(vsi, vsi_name, add_list,
+						     add_head, num_add,
+						     &promisc_changed);
 				memset(add_list, 0, list_size);
 				num_add = 0;
 			}
 		}
 		if (num_add) {
-			aq_ret = i40e_aq_add_macvlan(hw, vsi->seid,
-						     add_list, num_add, NULL);
-			aq_err = hw->aq.asq_last_status;
-			fcnt = i40e_update_filter_state(num_add, add_list,
-							add_head, aq_ret);
-			vsi->active_filters += fcnt;
-			if (fcnt != num_add) {
-				promisc_changed = true;
-				set_bit(__I40E_FILTER_OVERFLOW_PROMISC,
-					&vsi->state);
-				vsi->promisc_threshold =
-						(vsi->active_filters * 3) / 4;
-				dev_warn(&pf->pdev->dev,
-					 "Error %s adding RX filters on %s, promiscuous mode forced on\n",
-					 i40e_aq_str(hw, aq_err), vsi_name);
-			}
+			i40e_aqc_add_filters(vsi, vsi_name, add_list, add_head,
+					     num_add, &promisc_changed);
 		}
 		/* Now move all of the filters from the temp add list back to
 		 * the VSI's list.
-- 
2.7.4
