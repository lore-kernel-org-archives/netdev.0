From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/11] i40e: properly delete VF MAC filters
Date: Sat, 12 Dec 2015 00:33:24 -0800
Message-ID: <1449909213-33795-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449909213-33795-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:52824 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751177AbbLLIdl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Dec 2015 03:33:41 -0500
In-Reply-To: <1449909213-33795-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

The virtual channel interface was using incorrect semantics to remove
MAC addresses, which would leave incorrect filters active when using
VLANs. To correct this, add a new function that unconditionally removes
MAC addresses from all VLANs, and call this function when the VF
requests a MAC filter removal.

Change-ID: I69826908ae4f6c847f5bf9b32f11faa760189c74
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h             |  2 ++
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 36 ++++++++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  8 +++--
 3 files changed, 44 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index bd6d9c0..b7bc014 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -776,6 +776,8 @@ int i40e_vsi_add_vlan(struct i40e_vsi *vsi, s16 vid);
 int i40e_vsi_kill_vlan(struct i40e_vsi *vsi, s16 vid);
 struct i40e_mac_filter *i40e_put_mac_in_vlan(struct i40e_vsi *vsi, u8 *macaddr,
 					     bool is_vf, bool is_netdev);
+int i40e_del_mac_all_vlan(struct i40e_vsi *vsi, u8 *macaddr,
+			  bool is_vf, bool is_netdev);
 bool i40e_is_vsi_in_vlan(struct i40e_vsi *vsi);
 struct i40e_mac_filter *i40e_find_mac(struct i40e_vsi *vsi, u8 *macaddr,
 				      bool is_vf, bool is_netdev);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 3373b75..36d1c2b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1259,6 +1259,42 @@ struct i40e_mac_filter *i40e_put_mac_in_vlan(struct i40e_vsi *vsi, u8 *macaddr,
 }
 
 /**
+ * i40e_del_mac_all_vlan - Remove a MAC filter from all VLANS
+ * @vsi: the VSI to be searched
+ * @macaddr: the mac address to be removed
+ * @is_vf: true if it is a VF
+ * @is_netdev: true if it is a netdev
+ *
+ * Removes a given MAC address from a VSI, regardless of VLAN
+ *
+ * Returns 0 for success, or error
+ **/
+int i40e_del_mac_all_vlan(struct i40e_vsi *vsi, u8 *macaddr,
+			  bool is_vf, bool is_netdev)
+{
+	struct i40e_mac_filter *f = NULL;
+	int changed = 0;
+
+	WARN(!spin_is_locked(&vsi->mac_filter_list_lock),
+	     "Missing mac_filter_list_lock\n");
+	list_for_each_entry(f, &vsi->mac_filter_list, list) {
+		if ((ether_addr_equal(macaddr, f->macaddr)) &&
+		    (is_vf == f->is_vf) &&
+		    (is_netdev == f->is_netdev)) {
+			f->counter--;
+			f->changed = true;
+			changed = 1;
+		}
+	}
+	if (changed) {
+		vsi->flags |= I40E_VSI_FLAG_FILTER_CHANGED;
+		vsi->back->flags |= I40E_FLAG_FILTER_SYNC;
+		return 0;
+	}
+	return -ENOENT;
+}
+
+/**
  * i40e_rm_default_mac_filter - Remove the default MAC filter set by NVM
  * @vsi: the PF Main VSI - inappropriate for any other VSI
  * @macaddr: the MAC address
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index b3bd81c..cbbb2ef 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1683,8 +1683,12 @@ static int i40e_vc_del_mac_addr_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 	spin_lock_bh(&vsi->mac_filter_list_lock);
 	/* delete addresses from the list */
 	for (i = 0; i < al->num_elements; i++)
-		i40e_del_filter(vsi, al->list[i].addr,
-				I40E_VLAN_ANY, true, false);
+		if (i40e_del_mac_all_vlan(vsi, al->list[i].addr, true, false)) {
+			ret = I40E_ERR_INVALID_MAC_ADDR;
+			spin_unlock_bh(&vsi->mac_filter_list_lock);
+			goto error_param;
+		}
+
 	spin_unlock_bh(&vsi->mac_filter_list_lock);
 
 	/* program the updated filter list */
-- 
2.5.0
