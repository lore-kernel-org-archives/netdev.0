From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/19] ixgbe: add new bus type for intergrated I/O interface (IOSF)
Date: Tue,  1 Sep 2015 18:13:53 -0700
Message-ID: <1441156443-33381-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1441156443-33381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:59618 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754581AbbIBBOK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2015 21:14:10 -0400
In-Reply-To: <1441156443-33381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

With this patch we add support for a new bus type ixgbe_bus_type_internal.
X550em devices use IOSF and not PCIe bus so this new type is to accommodate
them.

Signed-off-by: Donald C Skidmore <donald.c.skidmore@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 11 ++++++++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c |  1 +
 3 files changed, 12 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 098c849..7e33125 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -246,11 +246,19 @@ static inline bool ixgbe_pcie_from_parent(struct ixgbe_hw *hw)
 static void ixgbe_check_minimum_link(struct ixgbe_adapter *adapter,
 				     int expected_gts)
 {
+	struct ixgbe_hw *hw = &adapter->hw;
 	int max_gts = 0;
 	enum pci_bus_speed speed = PCI_SPEED_UNKNOWN;
 	enum pcie_link_width width = PCIE_LNK_WIDTH_UNKNOWN;
 	struct pci_dev *pdev;
 
+	/* Some devices are not connected over PCIe and thus do not negotiate
+	 * speed. These devices do not have valid bus info, and thus any report
+	 * we generate may not be correct.
+	 */
+	if (hw->bus.type == ixgbe_bus_type_internal)
+		return;
+
 	/* determine whether to use the parent device */
 	if (ixgbe_pcie_from_parent(&adapter->hw))
 		pdev = adapter->pdev->bus->parent->self;
@@ -8837,9 +8845,10 @@ skip_sriov:
 	hw->eeprom.ops.read(hw, 0x2d, &adapter->eeprom_verl);
 
 	/* pick up the PCI bus settings for reporting later */
-	hw->mac.ops.get_bus_info(hw);
 	if (ixgbe_pcie_from_parent(hw))
 		ixgbe_get_parent_bus_info(adapter);
+	else
+		 hw->mac.ops.get_bus_info(hw);
 
 	/* calculate the expected PCIe bandwidth required for optimal
 	 * performance. Note that some older parts will never have enough
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 19271e5..37df15f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -3067,6 +3067,7 @@ enum ixgbe_bus_type {
 	ixgbe_bus_type_pci,
 	ixgbe_bus_type_pcix,
 	ixgbe_bus_type_pci_express,
+	ixgbe_bus_type_internal,
 	ixgbe_bus_type_reserved
 };
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index dce39be..96f603f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -620,6 +620,7 @@ static s32 ixgbe_update_flash_X550(struct ixgbe_hw *hw)
  **/
 static s32 ixgbe_get_bus_info_X550em(struct ixgbe_hw *hw)
 {
+	hw->bus.type  = ixgbe_bus_type_internal;
 	hw->bus.width = ixgbe_bus_width_unknown;
 	hw->bus.speed = ixgbe_bus_speed_unknown;
 
-- 
2.4.3
