From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/16] ixgbe: add ixgbe_write_pci_cfg_word with ixgbe_removed check
Date: Mon, 17 Mar 2014 05:45:14 -0700
Message-ID: <1395060316-16897-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1395060316-16897-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:26782 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932969AbaCQMp0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2014 08:45:26 -0400
In-Reply-To: <1395060316-16897-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Inline with the current use for ixgbe_read_pci_cfg_word, create a
similar function for writing PCI config, which checks whether the
adapter has been removed first, if Live Error Recovery has been enabled.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c  | 6 +-----
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h | 1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   | 9 +++++++++
 3 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
index f8ebe58..7fe2254 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
@@ -58,7 +58,6 @@ static s32 ixgbe_read_i2c_eeprom_82598(struct ixgbe_hw *hw, u8 byte_offset,
  **/
 static void ixgbe_set_pcie_completion_timeout(struct ixgbe_hw *hw)
 {
-	struct ixgbe_adapter *adapter = hw->back;
 	u32 gcr = IXGBE_READ_REG(hw, IXGBE_GCR);
 	u16 pcie_devctl2;
 
@@ -84,11 +83,8 @@ static void ixgbe_set_pcie_completion_timeout(struct ixgbe_hw *hw)
 	 * 16ms to 55ms
 	 */
 	pcie_devctl2 = ixgbe_read_pci_cfg_word(hw, IXGBE_PCI_DEVICE_CONTROL2);
-	if (ixgbe_removed(hw->hw_addr))
-		return;
 	pcie_devctl2 |= IXGBE_PCI_DEVICE_CONTROL2_16ms;
-	pci_write_config_word(adapter->pdev,
-	                      IXGBE_PCI_DEVICE_CONTROL2, pcie_devctl2);
+	ixgbe_write_pci_cfg_word(hw, IXGBE_PCI_DEVICE_CONTROL2, pcie_devctl2);
 out:
 	/* disable completion timeout resend */
 	gcr &= ~IXGBE_GCR_CMPL_TMOUT_RESEND;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
index d1d67ba..afa1cda 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
@@ -133,6 +133,7 @@ s32 ixgbe_init_thermal_sensor_thresh_generic(struct ixgbe_hw *hw);
 #define IXGBE_FAILED_READ_CFG_WORD 0xffffU
 
 u16 ixgbe_read_pci_cfg_word(struct ixgbe_hw *hw, u32 reg);
+void ixgbe_write_pci_cfg_word(struct ixgbe_hw *hw, u32 reg, u16 value);
 
 static inline bool ixgbe_removed(void __iomem *addr)
 {
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 18cd8ca..c773d6c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -361,6 +361,15 @@ static u32 ixgbe_read_pci_cfg_dword(struct ixgbe_hw *hw, u32 reg)
 }
 #endif /* CONFIG_PCI_IOV */
 
+void ixgbe_write_pci_cfg_word(struct ixgbe_hw *hw, u32 reg, u16 value)
+{
+	struct ixgbe_adapter *adapter = hw->back;
+
+	if (ixgbe_removed(hw->hw_addr))
+		return;
+	pci_write_config_word(adapter->pdev, reg, value);
+}
+
 static void ixgbe_service_event_complete(struct ixgbe_adapter *adapter)
 {
 	BUG_ON(!test_bit(__IXGBE_SERVICE_SCHED, &adapter->state));
-- 
1.8.3.1
