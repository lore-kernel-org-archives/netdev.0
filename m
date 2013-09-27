From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net v2 5/6] i40e: better return values
Date: Fri, 27 Sep 2013 05:35:57 -0700
Message-ID: <1380285358-15685-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1380285358-15685-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Joe Perches <joe@perches.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:42483 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751860Ab3I0MgF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Sep 2013 08:36:05 -0400
In-Reply-To: <1380285358-15685-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

As mentioned by Joe Perches, clean up return values in some functions
making sure to have consistent return types, not mixing types.

A couple of Joe's comments suggested returning void, but since
the functions in question are ndo defined, the return values are fixed.
So make a comment in the header that notes this is a function called by
net_device_ops.

v2: fix post increment bug in return

CC: Joe Perches <joe@perches.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 37 ++++++++++++++++-------------
 1 file changed, 21 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 60c7152..221aa47 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1787,6 +1787,8 @@ int i40e_vsi_add_vlan(struct i40e_vsi *vsi, s16 vid)
  * i40e_vsi_kill_vlan - Remove vsi membership for given vlan
  * @vsi: the vsi being configured
  * @vid: vlan id to be removed (0 = untagged only , -1 = any)
+ *
+ * Return: 0 on success or negative otherwise
  **/
 int i40e_vsi_kill_vlan(struct i40e_vsi *vsi, s16 vid)
 {
@@ -1860,37 +1862,39 @@ int i40e_vsi_kill_vlan(struct i40e_vsi *vsi, s16 vid)
  * i40e_vlan_rx_add_vid - Add a vlan id filter to HW offload
  * @netdev: network interface to be adjusted
  * @vid: vlan id to be added
+ *
+ * net_device_ops implementation for adding vlan ids
  **/
 static int i40e_vlan_rx_add_vid(struct net_device *netdev,
 				__always_unused __be16 proto, u16 vid)
 {
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
-	int ret;
+	int ret = 0;
 
 	if (vid > 4095)
-		return 0;
+		return -EINVAL;
+
+	netdev_info(netdev, "adding %pM vid=%d\n", netdev->dev_addr, vid);
 
-	netdev_info(vsi->netdev, "adding %pM vid=%d\n",
-		    netdev->dev_addr, vid);
 	/* If the network stack called us with vid = 0, we should
 	 * indicate to i40e_vsi_add_vlan() that we want to receive
 	 * any traffic (i.e. with any vlan tag, or untagged)
 	 */
 	ret = i40e_vsi_add_vlan(vsi, vid ? vid : I40E_VLAN_ANY);
 
-	if (!ret) {
-		if (vid < VLAN_N_VID)
-			set_bit(vid, vsi->active_vlans);
-	}
+	if (!ret && (vid < VLAN_N_VID))
+		set_bit(vid, vsi->active_vlans);
 
-	return 0;
+	return ret;
 }
 
 /**
  * i40e_vlan_rx_kill_vid - Remove a vlan id filter from HW offload
  * @netdev: network interface to be adjusted
  * @vid: vlan id to be removed
+ *
+ * net_device_ops implementation for adding vlan ids
  **/
 static int i40e_vlan_rx_kill_vid(struct net_device *netdev,
 				 __always_unused __be16 proto, u16 vid)
@@ -1898,15 +1902,16 @@ static int i40e_vlan_rx_kill_vid(struct net_device *netdev,
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
 
-	netdev_info(vsi->netdev, "removing %pM vid=%d\n",
-		    netdev->dev_addr, vid);
+	netdev_info(netdev, "removing %pM vid=%d\n", netdev->dev_addr, vid);
+
 	/* return code is ignored as there is nothing a user
 	 * can do about failure to remove and a log message was
-	 * already printed from another function
+	 * already printed from the other function
 	 */
 	i40e_vsi_kill_vlan(vsi, vid);
 
 	clear_bit(vid, vsi->active_vlans);
+
 	return 0;
 }
 
@@ -3324,7 +3329,8 @@ static void i40e_pf_unquiesce_all_vsi(struct i40e_pf *pf)
  **/
 static u8 i40e_dcb_get_num_tc(struct i40e_dcbx_config *dcbcfg)
 {
-	int num_tc = 0, i;
+	u8 num_tc = 0;
+	int i;
 
 	/* Scan the ETS Config Priority Table to find
 	 * traffic class enabled for a given priority
@@ -3339,9 +3345,7 @@ static u8 i40e_dcb_get_num_tc(struct i40e_dcbx_config *dcbcfg)
 	/* Traffic class index starts from zero so
 	 * increment to return the actual count
 	 */
-	num_tc++;
-
-	return num_tc;
+	return num_tc + 1;
 }
 
 /**
@@ -3491,6 +3495,7 @@ static int i40e_vsi_get_bw_info(struct i40e_vsi *vsi)
 		/* 3 bits out of 4 for each TC */
 		vsi->bw_ets_max_quanta[i] = (u8)((tc_bw_max >> (i*4)) & 0x7);
 	}
+
 	return 0;
 }
 
-- 
1.8.3.1
