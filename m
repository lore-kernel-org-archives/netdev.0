From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 5/6] i40e: Fix for recursive RTNL lock during PROMISC change
Date: Mon, 28 Sep 2015 17:55:33 -0700
Message-ID: <1443488134-36387-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1443488134-36387-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai <anjali.singhai@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Kiran Patil <kiran.patil@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:16566 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932203AbbI2Azi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Sep 2015 20:55:38 -0400
In-Reply-To: <1443488134-36387-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai <anjali.singhai@intel.com>

The sync_vsi_filters function can be called directly under RTNL
or through the timer subtask without one. This was causing a deadlock.

If sync_vsi_filters is called from a thread which held the lock,
and in another thread the PROMISC setting got changed we would
be executing the PROMISC change in the thread which already held
the lock alongside the other filter update. The PROMISC change
requires a reset if we are on a VEB, which requires it to be called
under RTNL.

Earlier the driver would call reset for PROMISC change without
checking if we were already under RTNL and would try to grab it
causing a deadlock. This patch changes the flow to see if we are
already under RTNL before trying to grab it.

Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Kiran Patil <kiran.patil@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h             |  2 +-
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |  4 ++--
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 19 ++++++++++++-------
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  8 ++++----
 4 files changed, 19 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 4797269..c64d18d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -666,7 +666,7 @@ struct i40e_mac_filter *i40e_add_filter(struct i40e_vsi *vsi,
 					bool is_vf, bool is_netdev);
 void i40e_del_filter(struct i40e_vsi *vsi, u8 *macaddr, s16 vlan,
 		     bool is_vf, bool is_netdev);
-int i40e_sync_vsi_filters(struct i40e_vsi *vsi);
+int i40e_sync_vsi_filters(struct i40e_vsi *vsi, bool grab_rtnl);
 struct i40e_vsi *i40e_vsi_setup(struct i40e_pf *pf, u8 type,
 				u16 uplink, u32 param1);
 int i40e_vsi_release(struct i40e_vsi *vsi);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index d7c15d1..508efb0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -1146,7 +1146,7 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 		}
 
 		f = i40e_add_filter(vsi, ma, vlan, false, false);
-		ret = i40e_sync_vsi_filters(vsi);
+		ret = i40e_sync_vsi_filters(vsi, true);
 		if (f && !ret)
 			dev_info(&pf->pdev->dev,
 				 "add macaddr: %pM vlan=%d added to VSI %d\n",
@@ -1183,7 +1183,7 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 		}
 
 		i40e_del_filter(vsi, ma, vlan, false, false);
-		ret = i40e_sync_vsi_filters(vsi);
+		ret = i40e_sync_vsi_filters(vsi, true);
 		if (!ret)
 			dev_info(&pf->pdev->dev,
 				 "del macaddr: %pM vlan=%d removed from VSI %d\n",
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index c246dca..52e58f30 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1527,7 +1527,7 @@ static int i40e_set_mac(struct net_device *netdev, void *p)
 			f->is_laa = true;
 	}
 
-	i40e_sync_vsi_filters(vsi);
+	i40e_sync_vsi_filters(vsi, false);
 	ether_addr_copy(netdev->dev_addr, addr->sa_data);
 
 	return 0;
@@ -1764,12 +1764,13 @@ static void i40e_set_rx_mode(struct net_device *netdev)
 /**
  * i40e_sync_vsi_filters - Update the VSI filter list to the HW
  * @vsi: ptr to the VSI
+ * @grab_rtnl: whether RTNL needs to be grabbed
  *
  * Push any outstanding VSI filter changes through the AdminQ.
  *
  * Returns 0 or error value
  **/
-int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
+int i40e_sync_vsi_filters(struct i40e_vsi *vsi, bool grab_rtnl)
 {
 	struct i40e_mac_filter *f, *ftmp;
 	bool promisc_forced_on = false;
@@ -1958,7 +1959,11 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 			 */
 			if (pf->cur_promisc != cur_promisc) {
 				pf->cur_promisc = cur_promisc;
-				i40e_do_reset_safe(pf,
+				if (grab_rtnl)
+					i40e_do_reset_safe(pf,
+						BIT(__I40E_PF_RESET_REQUESTED));
+				else
+					i40e_do_reset(pf,
 						BIT(__I40E_PF_RESET_REQUESTED));
 			}
 		} else {
@@ -2009,7 +2014,7 @@ static void i40e_sync_filters_subtask(struct i40e_pf *pf)
 	for (v = 0; v < pf->num_alloc_vsi; v++) {
 		if (pf->vsi[v] &&
 		    (pf->vsi[v]->flags & I40E_VSI_FLAG_FILTER_CHANGED))
-			i40e_sync_vsi_filters(pf->vsi[v]);
+			i40e_sync_vsi_filters(pf->vsi[v], true);
 	}
 }
 
@@ -2216,7 +2221,7 @@ int i40e_vsi_add_vlan(struct i40e_vsi *vsi, s16 vid)
 	    test_bit(__I40E_RESET_RECOVERY_PENDING, &vsi->back->state))
 		return 0;
 
-	return i40e_sync_vsi_filters(vsi);
+	return i40e_sync_vsi_filters(vsi, false);
 }
 
 /**
@@ -2288,7 +2293,7 @@ int i40e_vsi_kill_vlan(struct i40e_vsi *vsi, s16 vid)
 	    test_bit(__I40E_RESET_RECOVERY_PENDING, &vsi->back->state))
 		return 0;
 
-	return i40e_sync_vsi_filters(vsi);
+	return i40e_sync_vsi_filters(vsi, false);
 }
 
 /**
@@ -8821,7 +8826,7 @@ int i40e_vsi_release(struct i40e_vsi *vsi)
 	list_for_each_entry_safe(f, ftmp, &vsi->mac_filter_list, list)
 		i40e_del_filter(vsi, f->macaddr, f->vlan,
 				f->is_vf, f->is_netdev);
-	i40e_sync_vsi_filters(vsi);
+	i40e_sync_vsi_filters(vsi, false);
 
 	i40e_vsi_delete(vsi);
 	i40e_vsi_free_q_vectors(vsi);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index d99c116..eacce93 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -561,7 +561,7 @@ static int i40e_alloc_vsi_res(struct i40e_vf *vf, enum i40e_vsi_type type)
 	}
 
 	/* program mac filter */
-	ret = i40e_sync_vsi_filters(vsi);
+	ret = i40e_sync_vsi_filters(vsi, false);
 	if (ret)
 		dev_err(&pf->pdev->dev, "Unable to program ucast filters\n");
 
@@ -1605,7 +1605,7 @@ static int i40e_vc_add_mac_addr_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 	}
 
 	/* program the updated filter list */
-	if (i40e_sync_vsi_filters(vsi))
+	if (i40e_sync_vsi_filters(vsi, false))
 		dev_err(&pf->pdev->dev, "Unable to program VF MAC filters\n");
 
 error_param:
@@ -1656,7 +1656,7 @@ static int i40e_vc_del_mac_addr_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 				I40E_VLAN_ANY, true, false);
 
 	/* program the updated filter list */
-	if (i40e_sync_vsi_filters(vsi))
+	if (i40e_sync_vsi_filters(vsi, false))
 		dev_err(&pf->pdev->dev, "Unable to program VF MAC filters\n");
 
 error_param:
@@ -2062,7 +2062,7 @@ int i40e_ndo_set_vf_mac(struct net_device *netdev, int vf_id, u8 *mac)
 
 	dev_info(&pf->pdev->dev, "Setting MAC %pM on VF %d\n", mac, vf_id);
 	/* program mac filter */
-	if (i40e_sync_vsi_filters(vsi)) {
+	if (i40e_sync_vsi_filters(vsi, false)) {
 		dev_err(&pf->pdev->dev, "Unable to program ucast filters\n");
 		ret = -EIO;
 		goto error_param;
-- 
2.4.3
