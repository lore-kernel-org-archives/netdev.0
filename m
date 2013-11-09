From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/2] ixgbe: add warning when max_vfs is out of range.
Date: Sat,  9 Nov 2013 04:52:32 -0800
Message-ID: <1384001552-18754-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:29193 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751544Ab3KIMwi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Nov 2013 07:52:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The max_vfs parameter has a limit of 63 and silently fails (adding 0 vfs) when
it is out of range. This patch adds a warning so that the user knows something
went wrong. Also, this patch moves the warning in ixgbe_enable_sriov() to where
max_vfs is checked, so that even an out of range value will show the deprecated
warning. Previously, an out of range parameter didn't even warn the user to use
the new sysfs interface instead.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  | 17 +++++++++++++----
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |  4 ----
 2 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 0ade0cd..2767cf2 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -132,7 +132,7 @@ static struct notifier_block dca_notifier = {
 static unsigned int max_vfs;
 module_param(max_vfs, uint, 0);
 MODULE_PARM_DESC(max_vfs,
-		 "Maximum number of virtual functions to allocate per physical function - default is zero and maximum value is 63");
+		 "Maximum number of virtual functions to allocate per physical function - default is zero and maximum value is 63. (Deprecated)");
 #endif /* CONFIG_PCI_IOV */
 
 static unsigned int allow_unsupported_sfp;
@@ -4816,11 +4816,20 @@ static int ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	hw->fc.disable_fc_autoneg = ixgbe_device_supports_autoneg_fc(hw);
 
 #ifdef CONFIG_PCI_IOV
+	if (max_vfs > 0)
+		e_dev_warn("Enabling SR-IOV VFs using the max_vfs module parameter is deprecated - please use the pci sysfs interface instead.\n");
+
 	/* assign number of SR-IOV VFs */
-	if (hw->mac.type != ixgbe_mac_82598EB)
-		adapter->num_vfs = (max_vfs > 63) ? 0 : max_vfs;
+	if (hw->mac.type != ixgbe_mac_82598EB) {
+		if (max_vfs > 63) {
+			adapter->num_vfs = 0;
+			e_dev_warn("max_vfs parameter out of range. Not assigning any SR-IOV VFs\n");
+		} else {
+			adapter->num_vfs = max_vfs;
+		}
+	}
+#endif /* CONFIG_PCI_IOV */
 
-#endif
 	/* enable itr by default in dynamic mode */
 	adapter->rx_itr_setting = 1;
 	adapter->tx_itr_setting = 1;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 276d7b1..9e0c9c7 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -129,10 +129,6 @@ void ixgbe_enable_sriov(struct ixgbe_adapter *adapter)
 	if (!pre_existing_vfs && !adapter->num_vfs)
 		return;
 
-	if (!pre_existing_vfs)
-		dev_warn(&adapter->pdev->dev,
-			 "Enabling SR-IOV VFs using the module parameter is deprecated - please use the pci sysfs interface.\n");
-
 	/* If there are pre-existing VFs then we have to force
 	 * use of that many - over ride any module parameter value.
 	 * This may result from the user unloading the PF driver
-- 
1.8.3.1
