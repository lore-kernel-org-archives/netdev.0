From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 18/20] i40e: use (add|rm)_vlan_all_mac helper functions when changing PVID
Date: Tue,  6 Dec 2016 23:33:52 -0800
Message-ID: <20161207073354.88568-19-jeffrey.t.kirsher@intel.com>
References: <20161207073354.88568-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:26483 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753149AbcLGHev (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 02:34:51 -0500
In-Reply-To: <20161207073354.88568-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The current flow for adding or updating the PVID for a VF uses
i40e_vsi_add_vlan and i40e_vsi_kill_vlan which each take, then release
the hash lock. In addition the two functions also must take special care
that they do not perform VLAN mode changes as this will make the code in
i40e_ndo_set_vf_port_vlan behave incorrectly.

Fix these issues by using the new helper functions i40e_add_vlan_all_mac
and i40e_rm_vlan_all_mac which expect the hash lock to already be taken.
Additionally these functions do not perform any state updates in regards
to VLAN mode, so they are safe to use in the PVID update flow.

It should be noted that we don't need the VLAN mode update code here,
because there are only a few flows here.

(a) we're adding a new PVID
  In this case, if we already had VLAN filters the VSI is knocked
  offline so we don't need to worry about pre-existing VLAN filters

(b) we're replacing an existing PVID
  In this case, we can't have any VLAN filters except those with the old
  PVID which we already take care of manually.

(c) we're removing an existing PVID
  Similarly to above, we can't have any existing VLAN filters except
  those with the old PVID which we already take care of correctly.

Because of this, we do not need (or even want) the special accounting
done in i40e_vsi_add_vlan, so use of the helpers is a saner alternative.
It also opens the door for a future patch which will refactor the flow
of i40e_vsi_add_vlan now that it is not needed in this function.

Change-ID: Ia841f63da94e12b106f41cf7d28ce8ce92f2ad99
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h             |  2 +
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  4 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 43 ++++++++++++++--------
 3 files changed, 32 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index f1d838f..ba8d309 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -852,7 +852,9 @@ int i40e_open(struct net_device *netdev);
 int i40e_close(struct net_device *netdev);
 int i40e_vsi_open(struct i40e_vsi *vsi);
 void i40e_vlan_stripping_disable(struct i40e_vsi *vsi);
+int i40e_add_vlan_all_mac(struct i40e_vsi *vsi, s16 vid);
 int i40e_vsi_add_vlan(struct i40e_vsi *vsi, s16 vid);
+void i40e_rm_vlan_all_mac(struct i40e_vsi *vsi, s16 vid);
 void i40e_vsi_kill_vlan(struct i40e_vsi *vsi, s16 vid);
 struct i40e_mac_filter *i40e_put_mac_in_vlan(struct i40e_vsi *vsi,
 					     const u8 *macaddr);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 8aedfb7..49261cc 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2505,7 +2505,7 @@ static void i40e_vlan_rx_register(struct net_device *netdev, u32 features)
  * NOTE: this function expects to be called while under the
  * mac_filter_hash_lock
  **/
-static int i40e_add_vlan_all_mac(struct i40e_vsi *vsi, s16 vid)
+int i40e_add_vlan_all_mac(struct i40e_vsi *vsi, s16 vid)
 {
 	struct i40e_mac_filter *f, *add_f;
 	struct hlist_node *h;
@@ -2596,7 +2596,7 @@ int i40e_vsi_add_vlan(struct i40e_vsi *vsi, s16 vid)
  * NOTE: this function expects to be called while under the
  * mac_filter_hash_lock
  */
-static void i40e_rm_vlan_all_mac(struct i40e_vsi *vsi, s16 vid)
+void i40e_rm_vlan_all_mac(struct i40e_vsi *vsi, s16 vid)
 {
 	struct i40e_mac_filter *f;
 	struct hlist_node *h;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index d28b684..a6198b7 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -2766,7 +2766,6 @@ int i40e_ndo_set_vf_port_vlan(struct net_device *netdev, int vf_id,
 	u16 vlanprio = vlan_id | (qos << I40E_VLAN_PRIORITY_SHIFT);
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_pf *pf = np->vsi->back;
-	bool is_vsi_in_vlan = false;
 	struct i40e_vsi *vsi;
 	struct i40e_vf *vf;
 	int ret = 0;
@@ -2803,11 +2802,10 @@ int i40e_ndo_set_vf_port_vlan(struct net_device *netdev, int vf_id,
 		/* duplicate request, so just return success */
 		goto error_pvid;
 
+	/* Locked once because multiple functions below iterate list */
 	spin_lock_bh(&vsi->mac_filter_hash_lock);
-	is_vsi_in_vlan = i40e_is_vsi_in_vlan(vsi);
-	spin_unlock_bh(&vsi->mac_filter_hash_lock);
 
-	if (le16_to_cpu(vsi->info.pvid) == 0 && is_vsi_in_vlan) {
+	if (le16_to_cpu(vsi->info.pvid) == 0 && i40e_is_vsi_in_vlan(vsi)) {
 		dev_err(&pf->pdev->dev,
 			"VF %d has already configured VLAN filters and the administrator is requesting a port VLAN override.\nPlease unload and reload the VF driver for this change to take effect.\n",
 			vf_id);
@@ -2830,14 +2828,23 @@ int i40e_ndo_set_vf_port_vlan(struct net_device *netdev, int vf_id,
 	 */
 	if ((!(vlan_id || qos) ||
 	    vlanprio != le16_to_cpu(vsi->info.pvid)) &&
-	    vsi->info.pvid)
-		ret = i40e_vsi_add_vlan(vsi, I40E_VLAN_ANY);
+	    vsi->info.pvid) {
+		ret = i40e_add_vlan_all_mac(vsi, I40E_VLAN_ANY);
+		if (ret) {
+			dev_info(&vsi->back->pdev->dev,
+				 "add VF VLAN failed, ret=%d aq_err=%d\n", ret,
+				 vsi->back->hw.aq.asq_last_status);
+			spin_unlock_bh(&vsi->mac_filter_hash_lock);
+			goto error_pvid;
+		}
+	}
 
 	if (vsi->info.pvid) {
-		/* kill old VLAN */
-		i40e_vsi_kill_vlan(vsi, (le16_to_cpu(vsi->info.pvid) &
-					 VLAN_VID_MASK));
+		/* remove all filters on the old VLAN */
+		i40e_rm_vlan_all_mac(vsi, (le16_to_cpu(vsi->info.pvid) &
+					   VLAN_VID_MASK));
 	}
+
 	if (vlan_id || qos)
 		ret = i40e_vsi_add_pvid(vsi, vlanprio);
 	else
@@ -2847,24 +2854,30 @@ int i40e_ndo_set_vf_port_vlan(struct net_device *netdev, int vf_id,
 		dev_info(&pf->pdev->dev, "Setting VLAN %d, QOS 0x%x on VF %d\n",
 			 vlan_id, qos, vf_id);
 
-		/* add new VLAN filter */
-		ret = i40e_vsi_add_vlan(vsi, vlan_id);
+		/* add new VLAN filter for each MAC */
+		ret = i40e_add_vlan_all_mac(vsi, vlan_id);
 		if (ret) {
 			dev_info(&vsi->back->pdev->dev,
 				 "add VF VLAN failed, ret=%d aq_err=%d\n", ret,
 				 vsi->back->hw.aq.asq_last_status);
+			spin_unlock_bh(&vsi->mac_filter_hash_lock);
 			goto error_pvid;
 		}
-		/* Kill non-vlan MAC filters - ignore error return since
-		 * there might not be any non-vlan MAC filters.
-		 */
-		i40e_vsi_kill_vlan(vsi, I40E_VLAN_ANY);
+
+		/* remove the previously added non-VLAN MAC filters */
+		i40e_rm_vlan_all_mac(vsi, I40E_VLAN_ANY);
 	}
 
+	spin_unlock_bh(&vsi->mac_filter_hash_lock);
+
+	/* Schedule the worker thread to take care of applying changes */
+	i40e_service_event_schedule(vsi->back);
+
 	if (ret) {
 		dev_err(&pf->pdev->dev, "Unable to update VF vsi context\n");
 		goto error_pvid;
 	}
+
 	/* The Port VLAN needs to be saved across resets the same as the
 	 * default LAN MAC address.
 	 */
-- 
2.9.3
