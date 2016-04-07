From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/14] i40evf: properly handle VLAN features
Date: Wed,  6 Apr 2016 20:29:39 -0700
Message-ID: <1459999779-22254-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459999779-22254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:23097 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752024AbcDGD3p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Apr 2016 23:29:45 -0400
In-Reply-To: <1459999779-22254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Correctly set the VLAN feature flags after setting the rest of the
netdev flags. And don't set them in hw_features, because these can't be
controlled by the VF driver.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 27 +++++++++++--------------
 1 file changed, 12 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 4659ac2..9110319 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2323,29 +2323,20 @@ static int i40evf_check_reset_complete(struct i40e_hw *hw)
  **/
 int i40evf_process_config(struct i40evf_adapter *adapter)
 {
+	struct i40e_virtchnl_vf_resource *vfres = adapter->vf_res;
 	struct net_device *netdev = adapter->netdev;
 	int i;
 
 	/* got VF config message back from PF, now we can parse it */
-	for (i = 0; i < adapter->vf_res->num_vsis; i++) {
-		if (adapter->vf_res->vsi_res[i].vsi_type == I40E_VSI_SRIOV)
-			adapter->vsi_res = &adapter->vf_res->vsi_res[i];
+	for (i = 0; i < vfres->num_vsis; i++) {
+		if (vfres->vsi_res[i].vsi_type == I40E_VSI_SRIOV)
+			adapter->vsi_res = &vfres->vsi_res[i];
 	}
 	if (!adapter->vsi_res) {
 		dev_err(&adapter->pdev->dev, "No LAN VSI found\n");
 		return -ENODEV;
 	}
 
-	if (adapter->vf_res->vf_offload_flags
-	    & I40E_VIRTCHNL_VF_OFFLOAD_VLAN) {
-		netdev->vlan_features = netdev->features &
-					~(NETIF_F_HW_VLAN_CTAG_TX |
-					  NETIF_F_HW_VLAN_CTAG_RX |
-					  NETIF_F_HW_VLAN_CTAG_FILTER);
-		netdev->features |= NETIF_F_HW_VLAN_CTAG_TX |
-				    NETIF_F_HW_VLAN_CTAG_RX |
-				    NETIF_F_HW_VLAN_CTAG_FILTER;
-	}
 	netdev->features |= NETIF_F_HIGHDMA |
 			    NETIF_F_SG |
 			    NETIF_F_IP_CSUM |
@@ -2354,7 +2345,7 @@ int i40evf_process_config(struct i40evf_adapter *adapter)
 			    NETIF_F_TSO |
 			    NETIF_F_TSO6 |
 			    NETIF_F_TSO_ECN |
-			    NETIF_F_GSO_GRE	       |
+			    NETIF_F_GSO_GRE |
 			    NETIF_F_GSO_UDP_TUNNEL |
 			    NETIF_F_RXCSUM |
 			    NETIF_F_GRO;
@@ -2371,9 +2362,15 @@ int i40evf_process_config(struct i40evf_adapter *adapter)
 	if (adapter->flags & I40EVF_FLAG_OUTER_UDP_CSUM_CAPABLE)
 		netdev->features |= NETIF_F_GSO_UDP_TUNNEL_CSUM;
 
+	/* always clear VLAN features because they can change at every reset */
+	netdev->features &= ~(I40EVF_VLAN_FEATURES);
 	/* copy netdev features into list of user selectable features */
 	netdev->hw_features |= netdev->features;
-	netdev->hw_features &= ~NETIF_F_RXCSUM;
+
+	if (vfres->vf_offload_flags & I40E_VIRTCHNL_VF_OFFLOAD_VLAN) {
+		netdev->vlan_features = netdev->features;
+		netdev->features |= I40EVF_VLAN_FEATURES;
+	}
 
 	adapter->vsi.id = adapter->vsi_res->vsi_id;
 
-- 
2.5.5
