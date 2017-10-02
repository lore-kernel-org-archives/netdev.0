From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/15] i40e: don't hold spinlock while resetting VF
Date: Mon,  2 Oct 2017 12:48:44 -0700
Message-ID: <20171002194852.71970-8-jeffrey.t.kirsher@intel.com>
References: <20171002194852.71970-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:63279 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751613AbdJBTtV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Oct 2017 15:49:21 -0400
In-Reply-To: <20171002194852.71970-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

When we refactored handling of the PVID in commit 9af52f60b2d9
("i40e: use (add|rm)_vlan_all_mac helper functions when changing PVID")
we introduced a scheduling while atomic regression.

This occurred because we now held the spinlock across a call to
i40e_reset_vf(), which results in a usleep_range() call that triggers
a scheduling while atomic bug. This was rare as it only occurred if the
user configured a VLAN on a VF and also attempted to reconfigure the VF
from the host system with a port VLAN.

We do need to hold the lock while calling i40e_is_vsi_in_vlan(), but we
should not be holding it while we reset the VF.

We'll fix this by introducing a separate helper function
i40e_vsi_has_vlans which checks whether we have a PVID and whether the
VSI has configured VLANs. This helper function will manage its own need
for the mac_filter_hash_lock.

Then, we can move the acquiring of the spinlock until after we reset the
VF, which ensures that we do not sleep while holding the lock.

Using a separate function like this makes the code more clear and is
easier to read than attempting to release and re-acquire the spinlock
when we reset the VF.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 36 +++++++++++++++++++---
 1 file changed, 32 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 9e3667fc7f6a..53ead127b293 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -2925,6 +2925,34 @@ int i40e_ndo_set_vf_mac(struct net_device *netdev, int vf_id, u8 *mac)
 	return ret;
 }
 
+/**
+ * i40e_vsi_has_vlans - True if VSI has configured VLANs
+ * @vsi: pointer to the vsi
+ *
+ * Check if a VSI has configured any VLANs. False if we have a port VLAN or if
+ * we have no configured VLANs. Do not call while holding the
+ * mac_filter_hash_lock.
+ */
+static bool i40e_vsi_has_vlans(struct i40e_vsi *vsi)
+{
+	bool have_vlans;
+
+	/* If we have a port VLAN, then the VSI cannot have any VLANs
+	 * configured, as all MAC/VLAN filters will be assigned to the PVID.
+	 */
+	if (vsi->info.pvid)
+		return false;
+
+	/* Since we don't have a PVID, we know that if the device is in VLAN
+	 * mode it must be because of a VLAN filter configured on this VSI.
+	 */
+	spin_lock_bh(&vsi->mac_filter_hash_lock);
+	have_vlans = i40e_is_vsi_in_vlan(vsi);
+	spin_unlock_bh(&vsi->mac_filter_hash_lock);
+
+	return have_vlans;
+}
+
 /**
  * i40e_ndo_set_vf_port_vlan
  * @netdev: network interface device structure
@@ -2977,10 +3005,7 @@ int i40e_ndo_set_vf_port_vlan(struct net_device *netdev, int vf_id,
 		/* duplicate request, so just return success */
 		goto error_pvid;
 
-	/* Locked once because multiple functions below iterate list */
-	spin_lock_bh(&vsi->mac_filter_hash_lock);
-
-	if (le16_to_cpu(vsi->info.pvid) == 0 && i40e_is_vsi_in_vlan(vsi)) {
+	if (i40e_vsi_has_vlans(vsi)) {
 		dev_err(&pf->pdev->dev,
 			"VF %d has already configured VLAN filters and the administrator is requesting a port VLAN override.\nPlease unload and reload the VF driver for this change to take effect.\n",
 			vf_id);
@@ -2993,6 +3018,9 @@ int i40e_ndo_set_vf_port_vlan(struct net_device *netdev, int vf_id,
 		vsi = pf->vsi[vf->lan_vsi_idx];
 	}
 
+	/* Locked once because multiple functions below iterate list */
+	spin_lock_bh(&vsi->mac_filter_hash_lock);
+
 	/* Check for condition where there was already a port VLAN ID
 	 * filter set and now it is being deleted by setting it to zero.
 	 * Additionally check for the condition where there was a port
-- 
2.14.2
