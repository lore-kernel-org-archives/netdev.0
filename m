From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/15] i40e: Fix SR-IOV VF port VLAN
Date: Mon,  6 Jan 2014 04:30:23 -0800
Message-ID: <1389011436-18424-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1389011436-18424-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:44283 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750855AbaAFMak (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jan 2014 07:30:40 -0500
In-Reply-To: <1389011436-18424-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

This patch fixes two different problems.
1) The port VLAN configuration was not persistent across VF driver
   loads and unloads.

2) The port VLAN configuration was only correct the first time it was
   set. Switching the port VLAN on and off would cause subsequent VLAN
   configurations to be corrupted in the VSI.  Ensure that the correct
   bits are being set for the VSI port VLAN configuration.

Change-Id: I7ebf5329f77eb8d73ccd3324eb346b3abeea737d
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  8 +++++---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 16 ++++++++++++++--
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |  1 +
 3 files changed, 20 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 55fd23d..d0b2046 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2016,8 +2016,9 @@ int i40e_vsi_add_pvid(struct i40e_vsi *vsi, u16 vid)
 
 	vsi->info.valid_sections = cpu_to_le16(I40E_AQ_VSI_PROP_VLAN_VALID);
 	vsi->info.pvid = cpu_to_le16(vid);
-	vsi->info.port_vlan_flags |= I40E_AQ_VSI_PVLAN_INSERT_PVID;
-	vsi->info.port_vlan_flags |= I40E_AQ_VSI_PVLAN_MODE_UNTAGGED;
+	vsi->info.port_vlan_flags = I40E_AQ_VSI_PVLAN_MODE_TAGGED |
+				    I40E_AQ_VSI_PVLAN_INSERT_PVID |
+				    I40E_AQ_VSI_PVLAN_EMOD_STR_BOTH;
 
 	ctxt.seid = vsi->seid;
 	memcpy(&ctxt.info, &vsi->info, sizeof(vsi->info));
@@ -2040,8 +2041,9 @@ int i40e_vsi_add_pvid(struct i40e_vsi *vsi, u16 vid)
  **/
 void i40e_vsi_remove_pvid(struct i40e_vsi *vsi)
 {
+	i40e_vlan_stripping_disable(vsi);
+
 	vsi->info.pvid = 0;
-	i40e_vlan_rx_register(vsi->netdev, vsi->netdev->features);
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 685b285..2c042a26 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -388,8 +388,16 @@ static int i40e_alloc_vsi_res(struct i40e_vf *vf, enum i40e_vsi_type type)
 		dev_info(&pf->pdev->dev,
 			 "LAN VSI index %d, VSI id %d\n",
 			 vsi->idx, vsi->id);
+		/* If the port VLAN has been configured and then the
+		 * VF driver was removed then the VSI port VLAN
+		 * configuration was destroyed.  Check if there is
+		 * a port VLAN and restore the VSI configuration if
+		 * needed.
+		 */
+		if (vf->port_vlan_id)
+			i40e_vsi_add_pvid(vsi, vf->port_vlan_id);
 		f = i40e_add_filter(vsi, vf->default_lan_addr.addr,
-				    0, true, false);
+				    vf->port_vlan_id, true, false);
 	}
 
 	if (!f) {
@@ -1958,7 +1966,7 @@ int i40e_ndo_set_vf_port_vlan(struct net_device *netdev,
 		ret = i40e_vsi_add_pvid(vsi,
 				vlan_id | (qos << I40E_VLAN_PRIORITY_SHIFT));
 	else
-		i40e_vlan_stripping_disable(vsi);
+		i40e_vsi_remove_pvid(vsi);
 
 	if (vlan_id) {
 		dev_info(&pf->pdev->dev, "Setting VLAN %d, QOS 0x%x on VF %d\n",
@@ -1978,6 +1986,10 @@ int i40e_ndo_set_vf_port_vlan(struct net_device *netdev,
 		dev_err(&pf->pdev->dev, "Unable to update VF vsi context\n");
 		goto error_pvid;
 	}
+	/* The Port VLAN needs to be saved across resets the same as the
+	 * default LAN MAC address.
+	 */
+	vf->port_vlan_id = le16_to_cpu(vsi->info.pvid);
 	ret = 0;
 
 error_pvid:
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
index d0b712c..bf3384f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
@@ -82,6 +82,7 @@ struct i40e_vf {
 
 	struct i40e_virtchnl_ether_addr default_lan_addr;
 	struct i40e_virtchnl_ether_addr default_fcoe_addr;
+	u16 port_vlan_id;
 
 	/* VSI indices - actual VSI pointers are maintained in the PF structure
 	 * When assigned, these will be non-zero, because VSI 0 is always
-- 
1.8.3.1
