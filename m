From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [next-queu 06/19] i40e: when adding or removing MAC filters, correctly handle VLANs
Date: Thu,  2 Feb 2017 23:25:40 -0800
Message-ID: <20170203072553.168372-7-jeffrey.t.kirsher@intel.com>
References: <20170203072553.168372-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:50618 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752710AbdBCHZ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Feb 2017 02:25:57 -0500
In-Reply-To: <20170203072553.168372-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Instead of using i40e_add_filter or i40e_del_filter directly, when
adding a MAC address, we should normally be using i40e_add_mac_filter or
i40e_del_mac_filter. These functions correctly handle the various cases
of VLAN mode or PVID settings. This ensures consistency and avoids the
issues that can occur with the recent addition of a WARN_ON() in
i40e_sync_vsi_filters.

Change-ID: I7fe62db063391fdd1180b2d6a6a3c5ab4307eeee
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  6 +++---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 11 ++++-------
 2 files changed, 7 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index cabd728..2d689e0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -9341,7 +9341,7 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
 		 */
 		i40e_rm_default_mac_filter(vsi, mac_addr);
 		spin_lock_bh(&vsi->mac_filter_hash_lock);
-		i40e_add_filter(vsi, mac_addr, I40E_VLAN_ANY);
+		i40e_add_mac_filter(vsi, mac_addr);
 		spin_unlock_bh(&vsi->mac_filter_hash_lock);
 	} else {
 		/* relate the VSI_VMDQ name to the VSI_MAIN name */
@@ -9350,7 +9350,7 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
 		random_ether_addr(mac_addr);
 
 		spin_lock_bh(&vsi->mac_filter_hash_lock);
-		i40e_add_filter(vsi, mac_addr, I40E_VLAN_ANY);
+		i40e_add_mac_filter(vsi, mac_addr);
 		spin_unlock_bh(&vsi->mac_filter_hash_lock);
 	}
 
@@ -9369,7 +9369,7 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
 	 */
 	eth_broadcast_addr(broadcast);
 	spin_lock_bh(&vsi->mac_filter_hash_lock);
-	i40e_add_filter(vsi, broadcast, I40E_VLAN_ANY);
+	i40e_add_mac_filter(vsi, broadcast);
 	spin_unlock_bh(&vsi->mac_filter_hash_lock);
 
 	ether_addr_copy(netdev->dev_addr, mac_addr);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 49941dd..cbbf864 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -689,17 +689,15 @@ static int i40e_alloc_vsi_res(struct i40e_vf *vf, enum i40e_vsi_type type)
 
 		spin_lock_bh(&vsi->mac_filter_hash_lock);
 		if (is_valid_ether_addr(vf->default_lan_addr.addr)) {
-			f = i40e_add_filter(vsi, vf->default_lan_addr.addr,
-				       vf->port_vlan_id ?
-				       vf->port_vlan_id : -1);
+			f = i40e_add_mac_filter(vsi,
+						vf->default_lan_addr.addr);
 			if (!f)
 				dev_info(&pf->pdev->dev,
 					 "Could not add MAC filter %pM for VF %d\n",
 					vf->default_lan_addr.addr, vf->vf_id);
 		}
 		eth_broadcast_addr(broadcast);
-		f = i40e_add_filter(vsi, broadcast,
-				    vf->port_vlan_id ? vf->port_vlan_id : -1);
+		f = i40e_add_mac_filter(vsi, broadcast);
 		if (!f)
 			dev_info(&pf->pdev->dev,
 				 "Could not allocate VF broadcast filter\n");
@@ -2718,8 +2716,7 @@ int i40e_ndo_set_vf_mac(struct net_device *netdev, int vf_id, u8 *mac)
 
 	/* delete the temporary mac address */
 	if (!is_zero_ether_addr(vf->default_lan_addr.addr))
-		i40e_del_filter(vsi, vf->default_lan_addr.addr,
-				vf->port_vlan_id ? vf->port_vlan_id : -1);
+		i40e_del_mac_filter(vsi, vf->default_lan_addr.addr);
 
 	/* Delete all the filters for this VSI - we're going to kill it
 	 * anyway.
-- 
2.10.2
