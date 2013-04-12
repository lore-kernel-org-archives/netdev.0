From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/11] ixgbe: walk pci-e bus to find minimum width
Date: Fri, 12 Apr 2013 04:24:23 -0700
Message-ID: <1365765866-15741-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1365765866-15741-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:46845 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754925Ab3DLLZG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Apr 2013 07:25:06 -0400
In-Reply-To: <1365765866-15741-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch adds a function which enables the ixgbe driver to walk up the PCI bus
for the device and query the PCI config space for the bus width at each
point. This enables the driver to determine what the minimum PCIe width is for
the device, and warn the user if it is not enough.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 50 +++++++++++++++++++++++----
 1 file changed, 44 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index e02b4e4..8793aae 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -172,6 +172,49 @@ static int ixgbe_read_pci_cfg_word_parent(struct ixgbe_adapter *adapter,
 	return 0;
 }
 
+static void ixgbe_check_minimum_bus_width(struct ixgbe_adapter *adapter)
+{
+	int pos = 0;
+	struct pci_dev *dev = adapter->pdev;
+	enum ixgbe_bus_width minimum_width = adapter->hw.bus.width;
+	enum ixgbe_bus_speed minimum_speed = adapter->hw.bus.speed;
+
+	do {
+		u16 link_status;
+		enum ixgbe_bus_width next_width;
+		enum ixgbe_bus_speed next_speed;
+		struct pci_bus *bus;
+
+		pos = pci_find_capability(dev, PCI_CAP_ID_EXP);
+		if (!pos)
+			return;
+
+		pci_read_config_word(dev, pos + 18, &link_status);
+		next_width = ixgbe_convert_bus_width(link_status);
+		next_speed = ixgbe_convert_bus_speed(link_status);
+
+		if (next_width < minimum_width)
+			minimum_width = next_width;
+		if (next_speed < minimum_speed)
+			minimum_speed = next_speed;
+
+		if ((minimum_width < ixgbe_bus_width_pcie_x4) ||
+		    ((minimum_width == ixgbe_bus_width_pcie_x4) &&
+		     (minimum_speed <= ixgbe_bus_speed_5000))) {
+			e_dev_warn("PCI-Express bandwidth available for this card is not sufficient for optimal performance.\n");
+			e_dev_warn("For optimal performance a x8 PCI-Express slot is required.\n");
+			return;
+		}
+
+		bus = dev->bus->parent;
+		if (!bus)
+			return;
+
+		dev = bus->self;
+
+	} while (dev);
+}
+
 static s32 ixgbe_get_parent_bus_info(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
@@ -7656,12 +7699,7 @@ skip_sriov:
 		e_dev_info("MAC: %d, PHY: %d, PBA No: %s\n",
 			   hw->mac.type, hw->phy.type, part_str);
 
-	if (hw->bus.width <= ixgbe_bus_width_pcie_x4) {
-		e_dev_warn("PCI-Express bandwidth available for this card is "
-			   "not sufficient for optimal performance.\n");
-		e_dev_warn("For optimal performance a x8 PCI-Express slot "
-			   "is required.\n");
-	}
+	ixgbe_check_minimum_bus_width(adapter);
 
 	/* reset the hardware with the new settings */
 	err = hw->mac.ops.start_hw(hw);
-- 
1.7.11.7
