From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 17/17] i40e: remove unused argument
Date: Wed,  2 Dec 2015 00:25:35 -0800
Message-ID: <1449044735-68599-18-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449044735-68599-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:56306 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757580AbbLBIZo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Dec 2015 03:25:44 -0500
In-Reply-To: <1449044735-68599-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

With the final edition of the patches to remove sleeps from
the driver's entry points, the grab_rtnl argument is no
longer needed, so partially revert the commit that added it.

Change-ID: Ib9778476242586cc9e58b670f5f48d415cb59003
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h             |  2 +-
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |  4 ++--
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 16 +++++++++++-----
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  8 ++++----
 4 files changed, 18 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index d854a46..0b9537b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -697,7 +697,7 @@ struct i40e_mac_filter *i40e_add_filter(struct i40e_vsi *vsi,
 					bool is_vf, bool is_netdev);
 void i40e_del_filter(struct i40e_vsi *vsi, u8 *macaddr, s16 vlan,
 		     bool is_vf, bool is_netdev);
-int i40e_sync_vsi_filters(struct i40e_vsi *vsi, bool grab_rtnl);
+int i40e_sync_vsi_filters(struct i40e_vsi *vsi);
 struct i40e_vsi *i40e_vsi_setup(struct i40e_pf *pf, u8 type,
 				u16 uplink, u32 param1);
 int i40e_vsi_release(struct i40e_vsi *vsi);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index d1a91c8..10744a6 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -1138,7 +1138,7 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 		spin_lock_bh(&vsi->mac_filter_list_lock);
 		f = i40e_add_filter(vsi, ma, vlan, false, false);
 		spin_unlock_bh(&vsi->mac_filter_list_lock);
-		ret = i40e_sync_vsi_filters(vsi, true);
+		ret = i40e_sync_vsi_filters(vsi);
 		if (f && !ret)
 			dev_info(&pf->pdev->dev,
 				 "add macaddr: %pM vlan=%d added to VSI %d\n",
@@ -1177,7 +1177,7 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 		spin_lock_bh(&vsi->mac_filter_list_lock);
 		i40e_del_filter(vsi, ma, vlan, false, false);
 		spin_unlock_bh(&vsi->mac_filter_list_lock);
-		ret = i40e_sync_vsi_filters(vsi, true);
+		ret = i40e_sync_vsi_filters(vsi);
 		if (!ret)
 			dev_info(&pf->pdev->dev,
 				 "del macaddr: %pM vlan=%d removed from VSI %d\n",
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 3119ee4..9e6268b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1859,13 +1859,12 @@ static void i40e_cleanup_add_list(struct list_head *add_list)
 /**
  * i40e_sync_vsi_filters - Update the VSI filter list to the HW
  * @vsi: ptr to the VSI
- * @grab_rtnl: whether RTNL needs to be grabbed
  *
  * Push any outstanding VSI filter changes through the AdminQ.
  *
  * Returns 0 or error value
  **/
-int i40e_sync_vsi_filters(struct i40e_vsi *vsi, bool grab_rtnl)
+int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 {
 	struct list_head tmp_del_list, tmp_add_list;
 	struct i40e_mac_filter *f, *ftmp, *fclone;
@@ -2169,8 +2168,15 @@ static void i40e_sync_filters_subtask(struct i40e_pf *pf)
 
 	for (v = 0; v < pf->num_alloc_vsi; v++) {
 		if (pf->vsi[v] &&
-		    (pf->vsi[v]->flags & I40E_VSI_FLAG_FILTER_CHANGED))
-			i40e_sync_vsi_filters(pf->vsi[v], true);
+		    (pf->vsi[v]->flags & I40E_VSI_FLAG_FILTER_CHANGED)) {
+			int ret = i40e_sync_vsi_filters(pf->vsi[v]);
+
+			if (ret) {
+				/* come back and try again later */
+				pf->flags |= I40E_FLAG_FILTER_SYNC;
+				break;
+			}
+		}
 	}
 }
 
@@ -9219,7 +9225,7 @@ int i40e_vsi_release(struct i40e_vsi *vsi)
 				f->is_vf, f->is_netdev);
 	spin_unlock_bh(&vsi->mac_filter_list_lock);
 
-	i40e_sync_vsi_filters(vsi, false);
+	i40e_sync_vsi_filters(vsi);
 
 	i40e_vsi_delete(vsi);
 	i40e_vsi_free_q_vectors(vsi);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 26f247d..819803c8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -565,7 +565,7 @@ static int i40e_alloc_vsi_res(struct i40e_vf *vf, enum i40e_vsi_type type)
 	}
 
 	/* program mac filter */
-	ret = i40e_sync_vsi_filters(vsi, false);
+	ret = i40e_sync_vsi_filters(vsi);
 	if (ret)
 		dev_err(&pf->pdev->dev, "Unable to program ucast filters\n");
 
@@ -1633,7 +1633,7 @@ static int i40e_vc_add_mac_addr_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 	spin_unlock_bh(&vsi->mac_filter_list_lock);
 
 	/* program the updated filter list */
-	if (i40e_sync_vsi_filters(vsi, false))
+	if (i40e_sync_vsi_filters(vsi))
 		dev_err(&pf->pdev->dev, "Unable to program VF %d MAC filters\n",
 			vf->vf_id);
 
@@ -1687,7 +1687,7 @@ static int i40e_vc_del_mac_addr_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 	spin_unlock_bh(&vsi->mac_filter_list_lock);
 
 	/* program the updated filter list */
-	if (i40e_sync_vsi_filters(vsi, false))
+	if (i40e_sync_vsi_filters(vsi))
 		dev_err(&pf->pdev->dev, "Unable to program VF %d MAC filters\n",
 			vf->vf_id);
 
@@ -2102,7 +2102,7 @@ int i40e_ndo_set_vf_mac(struct net_device *netdev, int vf_id, u8 *mac)
 
 	dev_info(&pf->pdev->dev, "Setting MAC %pM on VF %d\n", mac, vf_id);
 	/* program mac filter */
-	if (i40e_sync_vsi_filters(vsi, false)) {
+	if (i40e_sync_vsi_filters(vsi)) {
 		dev_err(&pf->pdev->dev, "Unable to program ucast filters\n");
 		ret = -EIO;
 		goto error_param;
-- 
2.5.0
