From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/11] ixgbe: clean macvlan MAC filter table on VF reset
Date: Thu, 20 Apr 2017 18:50:23 -0700
Message-ID: <20170421015029.18994-6-jeffrey.t.kirsher@intel.com>
References: <20170421015029.18994-1-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:53037 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1034421AbdDUBu6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 21:50:58 -0400
In-Reply-To: <20170421015029.18994-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Flush the macvlan filters on VF reset to avoid conflict with other VFs that
may end up using the same MAC address.

The main change here is the call to ixgbe_set_vf_macvlan() with index 0.

Moved ixgbe_set_vf_macvlan() in front of ixgbe_vf_reset_event() to avoid
adding a prototype.

Reported-by: Sritej Kanakadandi Sritej Rama <skanakad@cisco.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 105 +++++++++++++------------
 1 file changed, 53 insertions(+), 52 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 102ca937ddb4..c45de53300aa 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -677,58 +677,6 @@ static void ixgbe_clear_vf_vlans(struct ixgbe_adapter *adapter, u32 vf)
 	}
 }
 
-static inline void ixgbe_vf_reset_event(struct ixgbe_adapter *adapter, u32 vf)
-{
-	struct ixgbe_hw *hw = &adapter->hw;
-	struct vf_data_storage *vfinfo = &adapter->vfinfo[vf];
-	u8 num_tcs = netdev_get_num_tc(adapter->netdev);
-
-	/* remove VLAN filters beloning to this VF */
-	ixgbe_clear_vf_vlans(adapter, vf);
-
-	/* add back PF assigned VLAN or VLAN 0 */
-	ixgbe_set_vf_vlan(adapter, true, vfinfo->pf_vlan, vf);
-
-	/* reset offloads to defaults */
-	ixgbe_set_vmolr(hw, vf, !vfinfo->pf_vlan);
-
-	/* set outgoing tags for VFs */
-	if (!vfinfo->pf_vlan && !vfinfo->pf_qos && !num_tcs) {
-		ixgbe_clear_vmvir(adapter, vf);
-	} else {
-		if (vfinfo->pf_qos || !num_tcs)
-			ixgbe_set_vmvir(adapter, vfinfo->pf_vlan,
-					vfinfo->pf_qos, vf);
-		else
-			ixgbe_set_vmvir(adapter, vfinfo->pf_vlan,
-					adapter->default_up, vf);
-
-		if (vfinfo->spoofchk_enabled)
-			hw->mac.ops.set_vlan_anti_spoofing(hw, true, vf);
-	}
-
-	/* reset multicast table array for vf */
-	adapter->vfinfo[vf].num_vf_mc_hashes = 0;
-
-	/* Flush and reset the mta with the new values */
-	ixgbe_set_rx_mode(adapter->netdev);
-
-	ixgbe_del_mac_filter(adapter, adapter->vfinfo[vf].vf_mac_addresses, vf);
-
-	/* reset VF api back to unknown */
-	adapter->vfinfo[vf].vf_api = ixgbe_mbox_api_10;
-}
-
-static int ixgbe_set_vf_mac(struct ixgbe_adapter *adapter,
-			    int vf, unsigned char *mac_addr)
-{
-	ixgbe_del_mac_filter(adapter, adapter->vfinfo[vf].vf_mac_addresses, vf);
-	memcpy(adapter->vfinfo[vf].vf_mac_addresses, mac_addr, ETH_ALEN);
-	ixgbe_add_mac_filter(adapter, adapter->vfinfo[vf].vf_mac_addresses, vf);
-
-	return 0;
-}
-
 static int ixgbe_set_vf_macvlan(struct ixgbe_adapter *adapter,
 				int vf, int index, unsigned char *mac_addr)
 {
@@ -784,6 +732,59 @@ static int ixgbe_set_vf_macvlan(struct ixgbe_adapter *adapter,
 	return 0;
 }
 
+static inline void ixgbe_vf_reset_event(struct ixgbe_adapter *adapter, u32 vf)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	struct vf_data_storage *vfinfo = &adapter->vfinfo[vf];
+	u8 num_tcs = netdev_get_num_tc(adapter->netdev);
+
+	/* remove VLAN filters beloning to this VF */
+	ixgbe_clear_vf_vlans(adapter, vf);
+
+	/* add back PF assigned VLAN or VLAN 0 */
+	ixgbe_set_vf_vlan(adapter, true, vfinfo->pf_vlan, vf);
+
+	/* reset offloads to defaults */
+	ixgbe_set_vmolr(hw, vf, !vfinfo->pf_vlan);
+
+	/* set outgoing tags for VFs */
+	if (!vfinfo->pf_vlan && !vfinfo->pf_qos && !num_tcs) {
+		ixgbe_clear_vmvir(adapter, vf);
+	} else {
+		if (vfinfo->pf_qos || !num_tcs)
+			ixgbe_set_vmvir(adapter, vfinfo->pf_vlan,
+					vfinfo->pf_qos, vf);
+		else
+			ixgbe_set_vmvir(adapter, vfinfo->pf_vlan,
+					adapter->default_up, vf);
+
+		if (vfinfo->spoofchk_enabled)
+			hw->mac.ops.set_vlan_anti_spoofing(hw, true, vf);
+	}
+
+	/* reset multicast table array for vf */
+	adapter->vfinfo[vf].num_vf_mc_hashes = 0;
+
+	/* Flush and reset the mta with the new values */
+	ixgbe_set_rx_mode(adapter->netdev);
+
+	ixgbe_del_mac_filter(adapter, adapter->vfinfo[vf].vf_mac_addresses, vf);
+	ixgbe_set_vf_macvlan(adapter, vf, 0, NULL);
+
+	/* reset VF api back to unknown */
+	adapter->vfinfo[vf].vf_api = ixgbe_mbox_api_10;
+}
+
+static int ixgbe_set_vf_mac(struct ixgbe_adapter *adapter,
+			    int vf, unsigned char *mac_addr)
+{
+	ixgbe_del_mac_filter(adapter, adapter->vfinfo[vf].vf_mac_addresses, vf);
+	memcpy(adapter->vfinfo[vf].vf_mac_addresses, mac_addr, ETH_ALEN);
+	ixgbe_add_mac_filter(adapter, adapter->vfinfo[vf].vf_mac_addresses, vf);
+
+	return 0;
+}
+
 int ixgbe_vf_configuration(struct pci_dev *pdev, unsigned int event_mask)
 {
 	struct ixgbe_adapter *adapter = pci_get_drvdata(pdev);
-- 
2.12.2
