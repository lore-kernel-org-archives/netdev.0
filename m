From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 12/24] ixgbe: correct function number for some 82598 parts
Date: Wed, 13 Apr 2011 18:02:08 -0700
Message-ID: <1302742940-22141-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1302742940-22141-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:21314 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758043Ab1DNBCe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 21:02:34 -0400
In-Reply-To: <1302742940-22141-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Some 82598 parts have LAN0 disabled and LAN1 enabled and the LAN ID bits in
Device Status register report the NIC as having only LAN1 as enabled. This
causes ixgbe_set_lan_id_multi_port_pcie() to set bus->func = 1 which is
incorrect.

Force bus->func to 0 when LAN0 is disabled in the EEPROM.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Evan Swanson <evan.swanson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_82598.c |   34 +++++++++++++++++++++++++++++++++-
 drivers/net/ixgbe/ixgbe_type.h  |    5 +++++
 2 files changed, 38 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index 845c679..c9b6574 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -1188,6 +1188,38 @@ out:
 	return physical_layer;
 }
 
+/**
+ *  ixgbe_set_lan_id_multi_port_pcie_82598 - Set LAN id for PCIe multiple
+ *  port devices.
+ *  @hw: pointer to the HW structure
+ *
+ *  Calls common function and corrects issue with some single port devices
+ *  that enable LAN1 but not LAN0.
+ **/
+static void ixgbe_set_lan_id_multi_port_pcie_82598(struct ixgbe_hw *hw)
+{
+	struct ixgbe_bus_info *bus = &hw->bus;
+	u16 pci_gen = 0;
+	u16 pci_ctrl2 = 0;
+
+	ixgbe_set_lan_id_multi_port_pcie(hw);
+
+	/* check if LAN0 is disabled */
+	hw->eeprom.ops.read(hw, IXGBE_PCIE_GENERAL_PTR, &pci_gen);
+	if ((pci_gen != 0) && (pci_gen != 0xFFFF)) {
+
+		hw->eeprom.ops.read(hw, pci_gen + IXGBE_PCIE_CTRL2, &pci_ctrl2);
+
+		/* if LAN0 is completely disabled force function to 0 */
+		if ((pci_ctrl2 & IXGBE_PCIE_CTRL2_LAN_DISABLE) &&
+		    !(pci_ctrl2 & IXGBE_PCIE_CTRL2_DISABLE_SELECT) &&
+		    !(pci_ctrl2 & IXGBE_PCIE_CTRL2_DUMMY_ENABLE)) {
+
+			bus->func = 0;
+		}
+	}
+}
+
 static struct ixgbe_mac_operations mac_ops_82598 = {
 	.init_hw		= &ixgbe_init_hw_generic,
 	.reset_hw		= &ixgbe_reset_hw_82598,
@@ -1199,7 +1231,7 @@ static struct ixgbe_mac_operations mac_ops_82598 = {
 	.get_mac_addr		= &ixgbe_get_mac_addr_generic,
 	.stop_adapter		= &ixgbe_stop_adapter_generic,
 	.get_bus_info           = &ixgbe_get_bus_info_generic,
-	.set_lan_id             = &ixgbe_set_lan_id_multi_port_pcie,
+	.set_lan_id             = &ixgbe_set_lan_id_multi_port_pcie_82598,
 	.read_analog_reg8	= &ixgbe_read_analog_reg8_82598,
 	.write_analog_reg8	= &ixgbe_write_analog_reg8_82598,
 	.setup_link		= &ixgbe_setup_mac_link_82598,
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 25c1fb7..cd1c2b6 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -1616,6 +1616,11 @@
 #define IXGBE_FLUDONE_ATTEMPTS 20000
 #endif
 
+#define IXGBE_PCIE_CTRL2                 0x5   /* PCIe Control 2 Offset */
+#define IXGBE_PCIE_CTRL2_DUMMY_ENABLE    0x8   /* Dummy Function Enable */
+#define IXGBE_PCIE_CTRL2_LAN_DISABLE     0x2   /* LAN PCI Disable */
+#define IXGBE_PCIE_CTRL2_DISABLE_SELECT  0x1   /* LAN Disable Select */
+
 #define IXGBE_SAN_MAC_ADDR_PORT0_OFFSET  0x0
 #define IXGBE_SAN_MAC_ADDR_PORT1_OFFSET  0x3
 #define IXGBE_DEVICE_CAPS_ALLOW_ANY_SFP  0x1
-- 
1.7.4.2

