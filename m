From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 17/19] i40e: factor out addition/deletion of VLAN per each MAC address
Date: Wed,  7 Dec 2016 14:19:16 -0800
Message-ID: <20161207221918.57932-18-jeffrey.t.kirsher@intel.com>
References: <20161207221918.57932-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:42627 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933472AbcLGWUT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 17:20:19 -0500
In-Reply-To: <20161207221918.57932-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

A future refactor of how the PF assigns a PVID to a VF will want to be
able to add and remove a block of filters by VLAN without worrying about
accidentally triggering the accounting for I40E_VLAN_ANY. Additionally
the PVID assignment would like to be able to batch several changes under
one use of the mac_filter_hash_lock.

Factor out the addition and deletion of a VLAN on all MACs into their
own function which i40e_vsi_(add|kill)_vlan can use. These new functions
expect the caller to take the hash lock, as well as perform any
necessary accounting for updating I40E_VLAN_ANY filters if we are now
operating under VLAN mode.

Change-ID: If79e5b60b770433275350a74b3f1880333a185d5
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 68 +++++++++++++++++++++++------
 1 file changed, 55 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index f9e9c90..8aedfb7 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2493,19 +2493,24 @@ static void i40e_vlan_rx_register(struct net_device *netdev, u32 features)
 }
 
 /**
- * i40e_vsi_add_vlan - Add vsi membership for given vlan
+ * i40e_add_vlan_all_mac - Add a MAC/VLAN filter for each existing MAC address
  * @vsi: the vsi being configured
  * @vid: vlan id to be added (0 = untagged only , -1 = any)
+ *
+ * This is a helper function for adding a new MAC/VLAN filter with the
+ * specified VLAN for each existing MAC address already in the hash table.
+ * This function does *not* perform any accounting to update filters based on
+ * VLAN mode.
+ *
+ * NOTE: this function expects to be called while under the
+ * mac_filter_hash_lock
  **/
-int i40e_vsi_add_vlan(struct i40e_vsi *vsi, s16 vid)
+static int i40e_add_vlan_all_mac(struct i40e_vsi *vsi, s16 vid)
 {
-	struct i40e_mac_filter *f, *add_f, *del_f;
+	struct i40e_mac_filter *f, *add_f;
 	struct hlist_node *h;
 	int bkt;
 
-	/* Locked once because all functions invoked below iterates list*/
-	spin_lock_bh(&vsi->mac_filter_hash_lock);
-
 	hash_for_each_safe(vsi->mac_filter_hash, bkt, h, f, hlist) {
 		if (f->state == I40E_FILTER_REMOVE)
 			continue;
@@ -2514,11 +2519,33 @@ int i40e_vsi_add_vlan(struct i40e_vsi *vsi, s16 vid)
 			dev_info(&vsi->back->pdev->dev,
 				 "Could not add vlan filter %d for %pM\n",
 				 vid, f->macaddr);
-			spin_unlock_bh(&vsi->mac_filter_hash_lock);
 			return -ENOMEM;
 		}
 	}
 
+	return 0;
+}
+
+/**
+ * i40e_vsi_add_vlan - Add VSI membership for given VLAN
+ * @vsi: the VSI being configured
+ * @vid: VLAN id to be added (0 = untagged only , -1 = any)
+ **/
+int i40e_vsi_add_vlan(struct i40e_vsi *vsi, s16 vid)
+{
+	struct i40e_mac_filter *f, *add_f, *del_f;
+	struct hlist_node *h;
+	int bkt, err;
+
+	/* Locked once because all functions invoked below iterates list*/
+	spin_lock_bh(&vsi->mac_filter_hash_lock);
+
+	err = i40e_add_vlan_all_mac(vsi, vid);
+	if (err) {
+		spin_unlock_bh(&vsi->mac_filter_hash_lock);
+		return err;
+	}
+
 	/* When we add a new VLAN filter, we need to make sure that all existing
 	 * filters which are marked as vid=-1 (I40E_VLAN_ANY) are converted to
 	 * vid=0. The simplest way is just search for all filters marked as
@@ -2557,24 +2584,39 @@ int i40e_vsi_add_vlan(struct i40e_vsi *vsi, s16 vid)
 }
 
 /**
- * i40e_vsi_kill_vlan - Remove vsi membership for given vlan
+ * i40e_rm_vlan_all_mac - Remove MAC/VLAN pair for all MAC with the given VLAN
  * @vsi: the vsi being configured
  * @vid: vlan id to be removed (0 = untagged only , -1 = any)
- **/
-void i40e_vsi_kill_vlan(struct i40e_vsi *vsi, s16 vid)
+ *
+ * This function should be used to remove all VLAN filters which match the
+ * given VID. It does not schedule the service event and does not take the
+ * mac_filter_hash_lock so it may be combined with other operations under
+ * a single invocation of the mac_filter_hash_lock.
+ *
+ * NOTE: this function expects to be called while under the
+ * mac_filter_hash_lock
+ */
+static void i40e_rm_vlan_all_mac(struct i40e_vsi *vsi, s16 vid)
 {
 	struct i40e_mac_filter *f;
 	struct hlist_node *h;
 	int bkt;
 
-	/* Locked once because all functions invoked below iterates list */
-	spin_lock_bh(&vsi->mac_filter_hash_lock);
-
 	hash_for_each_safe(vsi->mac_filter_hash, bkt, h, f, hlist) {
 		if (f->vlan == vid)
 			__i40e_del_filter(vsi, f);
 	}
+}
 
+/**
+ * i40e_vsi_kill_vlan - Remove VSI membership for given VLAN
+ * @vsi: the VSI being configured
+ * @vid: VLAN id to be removed (0 = untagged only , -1 = any)
+ **/
+void i40e_vsi_kill_vlan(struct i40e_vsi *vsi, s16 vid)
+{
+	spin_lock_bh(&vsi->mac_filter_hash_lock);
+	i40e_rm_vlan_all_mac(vsi, vid);
 	spin_unlock_bh(&vsi->mac_filter_hash_lock);
 
 	/* schedule our worker thread which will take care of
-- 
2.9.3
