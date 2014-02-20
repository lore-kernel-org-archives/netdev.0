From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 3/3] ixgbe: Check config reads for removal
Date: Wed, 19 Feb 2014 20:45:21 -0800
Message-ID: <1392871521-7731-4-git-send-email-aaron.f.brown@intel.com>
References: <1392871521-7731-1-git-send-email-aaron.f.brown@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:30893 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753549AbaBTEsM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Feb 2014 23:48:12 -0500
In-Reply-To: <1392871521-7731-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Configuration space reads should also be checked for removal. So
add some checks related to config space accesses.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c  | 10 +++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 16 +++----
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h |  6 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   | 56 +++++++++++++++++++++++--
 4 files changed, 73 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
index a26f3fe..3d2d288 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2013 Intel Corporation.
+  Copyright(c) 1999 - 2014 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -61,6 +61,9 @@ static void ixgbe_set_pcie_completion_timeout(struct ixgbe_hw *hw)
 	u32 gcr = IXGBE_READ_REG(hw, IXGBE_GCR);
 	u16 pcie_devctl2;
 
+	if (ixgbe_removed(hw->hw_addr))
+		return;
+
 	/* only take action if timeout value is defaulted to 0 */
 	if (gcr & IXGBE_GCR_CMPL_TMOUT_MASK)
 		goto out;
@@ -79,8 +82,9 @@ static void ixgbe_set_pcie_completion_timeout(struct ixgbe_hw *hw)
 	 * directly in order to set the completion timeout value for
 	 * 16ms to 55ms
 	 */
-	pci_read_config_word(adapter->pdev,
-	                     IXGBE_PCI_DEVICE_CONTROL2, &pcie_devctl2);
+	pcie_devctl2 = ixgbe_read_pci_cfg_word(hw, IXGBE_PCI_DEVICE_CONTROL2);
+	if (ixgbe_removed(hw->hw_addr))
+		return;
 	pcie_devctl2 |= IXGBE_PCI_DEVICE_CONTROL2_16ms;
 	pci_write_config_word(adapter->pdev,
 	                      IXGBE_PCI_DEVICE_CONTROL2, pcie_devctl2);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index b5c434b..fbc78eb 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2013 Intel Corporation.
+  Copyright(c) 1999 - 2014 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -2447,7 +2447,6 @@ out:
  **/
 static s32 ixgbe_disable_pcie_master(struct ixgbe_hw *hw)
 {
-	struct ixgbe_adapter *adapter = hw->back;
 	s32 status = 0;
 	u32 i;
 	u16 value;
@@ -2456,7 +2455,8 @@ static s32 ixgbe_disable_pcie_master(struct ixgbe_hw *hw)
 	IXGBE_WRITE_REG(hw, IXGBE_CTRL, IXGBE_CTRL_GIO_DIS);
 
 	/* Exit if master requests are blocked */
-	if (!(IXGBE_READ_REG(hw, IXGBE_STATUS) & IXGBE_STATUS_GIO))
+	if (!(IXGBE_READ_REG(hw, IXGBE_STATUS) & IXGBE_STATUS_GIO) ||
+		ixgbe_removed(hw->hw_addr))
 		goto out;
 
 	/* Poll for master request bit to clear */
@@ -2483,8 +2483,9 @@ static s32 ixgbe_disable_pcie_master(struct ixgbe_hw *hw)
 	 */
 	for (i = 0; i < IXGBE_PCI_MASTER_DISABLE_TIMEOUT; i++) {
 		udelay(100);
-		pci_read_config_word(adapter->pdev, IXGBE_PCI_DEVICE_STATUS,
-							 &value);
+		value = ixgbe_read_pci_cfg_word(hw, IXGBE_PCI_DEVICE_STATUS);
+		if (ixgbe_removed(hw->hw_addr))
+			goto out;
 		if (!(value & IXGBE_PCI_DEVICE_STATUS_TRANSACTION_PENDING))
 			goto out;
 	}
@@ -2817,7 +2818,6 @@ san_mac_addr_clr:
  **/
 u16 ixgbe_get_pcie_msix_count_generic(struct ixgbe_hw *hw)
 {
-	struct ixgbe_adapter *adapter = hw->back;
 	u16 msix_count = 1;
 	u16 max_msix_count;
 	u16 pcie_offset;
@@ -2836,7 +2836,9 @@ u16 ixgbe_get_pcie_msix_count_generic(struct ixgbe_hw *hw)
 		return msix_count;
 	}
 
-	pci_read_config_word(adapter->pdev, pcie_offset, &msix_count);
+	msix_count = ixgbe_read_pci_cfg_word(hw, pcie_offset);
+	if (ixgbe_removed(hw->hw_addr))
+		msix_count = 0;
 	msix_count &= IXGBE_PCIE_MSIX_TBL_SZ_MASK;
 
 	/* MSI-X count is zero-based in HW */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
index f2e3919..0777126 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2013 Intel Corporation.
+  Copyright(c) 1999 - 2014 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -125,6 +125,10 @@ s32 ixgbe_get_thermal_sensor_data_generic(struct ixgbe_hw *hw);
 s32 ixgbe_init_thermal_sensor_thresh_generic(struct ixgbe_hw *hw);
 
 #define IXGBE_FAILED_READ_REG 0xffffffffU
+#define IXGBE_FAILED_READ_CFG_DWORD 0xffffffffU
+#define IXGBE_FAILED_READ_CFG_WORD 0xffffU
+
+u16 ixgbe_read_pci_cfg_word(struct ixgbe_hw *hw, u32 reg);
 
 static inline bool ixgbe_removed(void __iomem *addr)
 {
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index b7e9f1c..8d49537 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -151,6 +151,8 @@ MODULE_DESCRIPTION("Intel(R) 10 Gigabit PCI Express Network Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 
+static bool ixgbe_check_cfg_remove(struct ixgbe_hw *hw, struct pci_dev *pdev);
+
 static int ixgbe_read_pci_cfg_word_parent(struct ixgbe_adapter *adapter,
 					  u32 reg, u16 *value)
 {
@@ -169,6 +171,9 @@ static int ixgbe_read_pci_cfg_word_parent(struct ixgbe_adapter *adapter,
 		return -1;
 
 	pcie_capability_read_word(parent_dev, reg, value);
+	if (*value == IXGBE_FAILED_READ_CFG_WORD &&
+	    ixgbe_check_cfg_remove(&adapter->hw, parent_dev))
+		return -1;
 	return 0;
 }
 
@@ -313,6 +318,46 @@ void ixgbe_check_remove(struct ixgbe_hw *hw, u32 reg)
 		ixgbe_remove_adapter(hw);
 }
 
+static bool ixgbe_check_cfg_remove(struct ixgbe_hw *hw, struct pci_dev *pdev)
+{
+	u16 value;
+
+	pci_read_config_word(pdev, PCI_VENDOR_ID, &value);
+	if (value == IXGBE_FAILED_READ_CFG_WORD) {
+		ixgbe_remove_adapter(hw);
+		return true;
+	}
+	return false;
+}
+
+u16 ixgbe_read_pci_cfg_word(struct ixgbe_hw *hw, u32 reg)
+{
+	struct ixgbe_adapter *adapter = hw->back;
+	u16 value;
+
+	if (ixgbe_removed(hw->hw_addr))
+		return IXGBE_FAILED_READ_CFG_WORD;
+	pci_read_config_word(adapter->pdev, reg, &value);
+	if (value == IXGBE_FAILED_READ_CFG_WORD &&
+	    ixgbe_check_cfg_remove(hw, adapter->pdev))
+		return IXGBE_FAILED_READ_CFG_WORD;
+	return value;
+}
+
+static u32 ixgbe_read_pci_cfg_dword(struct ixgbe_hw *hw, u32 reg)
+{
+	struct ixgbe_adapter *adapter = hw->back;
+	u32 value;
+
+	if (ixgbe_removed(hw->hw_addr))
+		return IXGBE_FAILED_READ_CFG_DWORD;
+	pci_read_config_dword(adapter->pdev, reg, &value);
+	if (value == IXGBE_FAILED_READ_CFG_DWORD &&
+	    ixgbe_check_cfg_remove(hw, adapter->pdev))
+		return IXGBE_FAILED_READ_CFG_DWORD;
+	return value;
+}
+
 static void ixgbe_service_event_complete(struct ixgbe_adapter *adapter)
 {
 	BUG_ON(!test_bit(__IXGBE_SERVICE_SCHED, &adapter->state));
@@ -8330,6 +8375,7 @@ static pci_ers_result_t ixgbe_io_error_detected(struct pci_dev *pdev,
 {
 	struct ixgbe_adapter *adapter = pci_get_drvdata(pdev);
 	struct net_device *netdev = adapter->netdev;
+	struct ixgbe_hw *hw = &adapter->hw;
 
 #ifdef CONFIG_PCI_IOV
 	struct pci_dev *bdev, *vfdev;
@@ -8352,10 +8398,12 @@ static pci_ers_result_t ixgbe_io_error_detected(struct pci_dev *pdev,
 	if (!pos)
 		goto skip_bad_vf_detection;
 
-	pci_read_config_dword(bdev, pos + PCI_ERR_HEADER_LOG, &dw0);
-	pci_read_config_dword(bdev, pos + PCI_ERR_HEADER_LOG + 4, &dw1);
-	pci_read_config_dword(bdev, pos + PCI_ERR_HEADER_LOG + 8, &dw2);
-	pci_read_config_dword(bdev, pos + PCI_ERR_HEADER_LOG + 12, &dw3);
+	dw0 = ixgbe_read_pci_cfg_dword(hw, pos + PCI_ERR_HEADER_LOG);
+	dw1 = ixgbe_read_pci_cfg_dword(hw, pos + PCI_ERR_HEADER_LOG + 4);
+	dw2 = ixgbe_read_pci_cfg_dword(hw, pos + PCI_ERR_HEADER_LOG + 8);
+	dw3 = ixgbe_read_pci_cfg_dword(hw, pos + PCI_ERR_HEADER_LOG + 12);
+	if (ixgbe_removed(hw->hw_addr))
+		goto skip_bad_vf_detection;
 
 	req_id = dw1 >> 16;
 	/* On the 82599 if bit 7 of the requestor ID is set then it's a VF */
-- 
1.8.5.GIT
