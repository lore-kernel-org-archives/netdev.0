From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/17] fm10k: force LPORT delete when updating VLAN or MAC address
Date: Tue, 16 Jun 2015 06:47:22 -0700
Message-ID: <1434462448-140563-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1434462448-140563-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:8750 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756711AbbFPNrg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jun 2015 09:47:36 -0400
In-Reply-To: <1434462448-140563-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Currently, we don't notify the switch at all when the PF
administratively sets a new VLAN or MAC address. This causes the old
addresses to remain valid on the switch table. Since the PF is
overriding any configuration done directly by the VF, we choose to
simply re-create the LPORT for the VF. This does mean that all rules for
the VF will be dropped when we set something directly via the PF, but it
prevents some weird issues where the MAC/VLAN table retains some stale
configuration.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_iov.c | 38 +++++++++++++++++-----------
 1 file changed, 23 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_iov.c b/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
index 5b08e62..94571e6 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
@@ -400,11 +400,31 @@ int fm10k_iov_configure(struct pci_dev *pdev, int num_vfs)
 	return num_vfs;
 }
 
+static inline void fm10k_reset_vf_info(struct fm10k_intfc *interface,
+				       struct fm10k_vf_info *vf_info)
+{
+	struct fm10k_hw *hw = &interface->hw;
+
+	/* assigning the MAC address will send a mailbox message */
+	fm10k_mbx_lock(interface);
+
+	/* disable LPORT for this VF which clears switch rules */
+	hw->iov.ops.reset_lport(hw, vf_info);
+
+	/* assign new MAC+VLAN for this VF */
+	hw->iov.ops.assign_default_mac_vlan(hw, vf_info);
+
+	/* re-enable the LPORT for this VF */
+	hw->iov.ops.set_lport(hw, vf_info, vf_info->vf_idx,
+			      FM10K_VF_FLAG_MULTI_CAPABLE);
+
+	fm10k_mbx_unlock(interface);
+}
+
 int fm10k_ndo_set_vf_mac(struct net_device *netdev, int vf_idx, u8 *mac)
 {
 	struct fm10k_intfc *interface = netdev_priv(netdev);
 	struct fm10k_iov_data *iov_data = interface->iov_data;
-	struct fm10k_hw *hw = &interface->hw;
 	struct fm10k_vf_info *vf_info;
 
 	/* verify SR-IOV is active and that vf idx is valid */
@@ -419,13 +439,7 @@ int fm10k_ndo_set_vf_mac(struct net_device *netdev, int vf_idx, u8 *mac)
 	vf_info = &iov_data->vf_info[vf_idx];
 	ether_addr_copy(vf_info->mac, mac);
 
-	/* assigning the MAC will send a mailbox message so lock is needed */
-	fm10k_mbx_lock(interface);
-
-	/* assign MAC address to VF */
-	hw->iov.ops.assign_default_mac_vlan(hw, vf_info);
-
-	fm10k_mbx_unlock(interface);
+	fm10k_reset_vf_info(interface, vf_info);
 
 	return 0;
 }
@@ -455,16 +469,10 @@ int fm10k_ndo_set_vf_vlan(struct net_device *netdev, int vf_idx, u16 vid,
 	/* record default VLAN ID for VF */
 	vf_info->pf_vid = vid;
 
-	/* assigning the VLAN will send a mailbox message so lock is needed */
-	fm10k_mbx_lock(interface);
-
 	/* Clear the VLAN table for the VF */
 	hw->mac.ops.update_vlan(hw, FM10K_VLAN_ALL, vf_info->vsi, false);
 
-	/* Update VF assignment and trigger reset */
-	hw->iov.ops.assign_default_mac_vlan(hw, vf_info);
-
-	fm10k_mbx_unlock(interface);
+	fm10k_reset_vf_info(interface, vf_info);
 
 	return 0;
 }
-- 
2.4.3
