From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/14] ixgbe: Make mailbox ops initialization unconditional
Date: Wed, 23 Jan 2013 14:44:46 -0800
Message-ID: <1358981090-5794-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1358981090-5794-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Don Dutile <ddutile@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:3888 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752535Ab3AWWpT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2013 17:45:19 -0500
In-Reply-To: <1358981090-5794-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

There is no actual dependency on initialization of the mailbox ops on
whether SR-IOV is enabled or not and it doesn't hurt to go ahead and
initialize ops unconditionally.  Move the initialization into the device
probe so that the mailbox ops are initialized at the time we have the
board info necessary to do it.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
CC: Don Dutile <ddutile@redhat.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Tested-by: Sibai Li <Sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  | 9 ++++++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 9 +--------
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h | 3 +--
 3 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 7e0bb95..2472dc8 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7362,7 +7362,14 @@ static int ixgbe_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 
 #ifdef CONFIG_PCI_IOV
-	ixgbe_enable_sriov(adapter, ii);
+	/* SR-IOV not supported on the 82598 */
+	if (adapter->hw.mac.type == ixgbe_mac_82598EB)
+		goto skip_sriov;
+	/* Mailbox */
+	ixgbe_init_mbx_params_pf(hw);
+	memcpy(&hw->mbx.ops, ii->mbx_ops, sizeof(hw->mbx.ops));
+	ixgbe_enable_sriov(adapter);
+skip_sriov:
 
 #endif
 	netdev->features = NETIF_F_SG |
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 647734b..029c863 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -44,8 +44,7 @@
 #include "ixgbe_sriov.h"
 
 #ifdef CONFIG_PCI_IOV
-void ixgbe_enable_sriov(struct ixgbe_adapter *adapter,
-			 const struct ixgbe_info *ii)
+void ixgbe_enable_sriov(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
 	int num_vf_macvlans, i;
@@ -128,12 +127,6 @@ void ixgbe_enable_sriov(struct ixgbe_adapter *adapter,
 		kcalloc(adapter->num_vfs,
 			sizeof(struct vf_data_storage), GFP_KERNEL);
 	if (adapter->vfinfo) {
-		/* Now that we're sure SR-IOV is enabled
-		 * and memory allocated set up the mailbox parameters
-		 */
-		ixgbe_init_mbx_params_pf(hw);
-		memcpy(&hw->mbx.ops, ii->mbx_ops, sizeof(hw->mbx.ops));
-
 		/* limit trafffic classes based on VFs enabled */
 		if ((adapter->hw.mac.type == ixgbe_mac_82599EB) &&
 		    (adapter->num_vfs < 16)) {
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
index 21bc1dd..f693469 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
@@ -43,8 +43,7 @@ int ixgbe_ndo_get_vf_config(struct net_device *netdev,
 void ixgbe_check_vf_rate_limit(struct ixgbe_adapter *adapter);
 void ixgbe_disable_sriov(struct ixgbe_adapter *adapter);
 #ifdef CONFIG_PCI_IOV
-void ixgbe_enable_sriov(struct ixgbe_adapter *adapter,
-			const struct ixgbe_info *ii);
+void ixgbe_enable_sriov(struct ixgbe_adapter *adapter);
 #endif
 
 static inline void ixgbe_set_vmvir(struct ixgbe_adapter *adapter,
-- 
1.7.11.7
