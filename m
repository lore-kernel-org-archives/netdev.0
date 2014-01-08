From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 02/15] i40e: Do not enable broadcast promiscuous by default
Date: Tue,  7 Jan 2014 22:07:23 -0800
Message-ID: <1389161256-24599-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1389161256-24599-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:23587 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755035AbaAHGIe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jan 2014 01:08:34 -0500
In-Reply-To: <1389161256-24599-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Broadcast promiscuous should only be turned on when general
promiscuous mode is turned on, otherwise VLAN tagged packets out of
the assigned VLAN domain are received.

Add a broadcast MAC filter in order to continue to receive
broadcast traffic on VLANs, MAIN or VMDQ VSI.

Change-Id: I99d8e382a082ee51201228f1226af3b46452ac55
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 16 +++++++++-------
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 19 +++++++++----------
 2 files changed, 18 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 483126c..5ddbd54 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1650,6 +1650,13 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 			dev_info(&pf->pdev->dev,
 				 "set uni promisc failed, err %d, aq_err %d\n",
 				 aq_ret, pf->hw.aq.asq_last_status);
+		aq_ret = i40e_aq_set_vsi_broadcast(&vsi->back->hw,
+						   vsi->seid,
+						   cur_promisc, NULL);
+		if (aq_ret)
+			dev_info(&pf->pdev->dev,
+				 "set brdcast promisc failed, err %d, aq_err %d\n",
+				 aq_ret, pf->hw.aq.asq_last_status);
 	}
 
 	clear_bit(__I40E_CONFIG_BUSY, &vsi->state);
@@ -3987,13 +3994,6 @@ static int i40e_open(struct net_device *netdev)
 	if (err)
 		goto err_up_complete;
 
-	if ((vsi->type == I40E_VSI_MAIN) || (vsi->type == I40E_VSI_VMDQ2)) {
-		err = i40e_aq_set_vsi_broadcast(&pf->hw, vsi->seid, true, NULL);
-		if (err)
-			netdev_info(netdev,
-				    "couldn't set broadcast err %d aq_err %d\n",
-				    err, pf->hw.aq.asq_last_status);
-	}
 #ifdef CONFIG_I40E_VXLAN
 	vxlan_get_rx_port(netdev);
 #endif
@@ -6067,6 +6067,7 @@ static const struct net_device_ops i40e_netdev_ops = {
  **/
 static int i40e_config_netdev(struct i40e_vsi *vsi)
 {
+	u8 brdcast[ETH_ALEN] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
 	struct i40e_pf *pf = vsi->back;
 	struct i40e_hw *hw = &pf->hw;
 	struct i40e_netdev_priv *np;
@@ -6116,6 +6117,7 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
 		random_ether_addr(mac_addr);
 		i40e_add_filter(vsi, mac_addr, I40E_VLAN_ANY, false, false);
 	}
+	i40e_add_filter(vsi, brdcast, I40E_VLAN_ANY, false, false);
 
 	memcpy(netdev->dev_addr, mac_addr, ETH_ALEN);
 	memcpy(netdev->perm_addr, mac_addr, ETH_ALEN);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 55ec2db..fee368a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -369,7 +369,6 @@ static int i40e_alloc_vsi_res(struct i40e_vf *vf, enum i40e_vsi_type type)
 {
 	struct i40e_mac_filter *f = NULL;
 	struct i40e_pf *pf = vf->pf;
-	struct i40e_hw *hw = &pf->hw;
 	struct i40e_vsi *vsi;
 	int ret = 0;
 
@@ -383,6 +382,7 @@ static int i40e_alloc_vsi_res(struct i40e_vf *vf, enum i40e_vsi_type type)
 		goto error_alloc_vsi_res;
 	}
 	if (type == I40E_VSI_SRIOV) {
+		u8 brdcast[ETH_ALEN] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
 		vf->lan_vsi_index = vsi->idx;
 		vf->lan_vsi_id = vsi->id;
 		dev_info(&pf->pdev->dev,
@@ -398,6 +398,14 @@ static int i40e_alloc_vsi_res(struct i40e_vf *vf, enum i40e_vsi_type type)
 			i40e_vsi_add_pvid(vsi, vf->port_vlan_id);
 		f = i40e_add_filter(vsi, vf->default_lan_addr.addr,
 				    vf->port_vlan_id, true, false);
+		if (!f)
+			dev_info(&pf->pdev->dev,
+				 "Could not allocate VF MAC addr\n");
+		f = i40e_add_filter(vsi, brdcast, vf->port_vlan_id,
+				    true, false);
+		if (!f)
+			dev_info(&pf->pdev->dev,
+				 "Could not allocate VF broadcast filter\n");
 	}
 
 	if (!f) {
@@ -413,15 +421,6 @@ static int i40e_alloc_vsi_res(struct i40e_vf *vf, enum i40e_vsi_type type)
 		goto error_alloc_vsi_res;
 	}
 
-	/* accept bcast pkts. by default */
-	ret = i40e_aq_set_vsi_broadcast(hw, vsi->seid, true, NULL);
-	if (ret) {
-		dev_err(&pf->pdev->dev,
-			"set vsi bcast failed for vf %d, vsi %d, aq_err %d\n",
-			vf->vf_id, vsi->idx, pf->hw.aq.asq_last_status);
-		ret = -EINVAL;
-	}
-
 error_alloc_vsi_res:
 	return ret;
 }
-- 
1.8.3.1
