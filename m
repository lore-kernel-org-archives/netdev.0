From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/15] ixgbe: call pcie_get_mimimum_link to check if device has enough bandwidth
Date: Mon, 29 Jul 2013 05:52:07 -0700
Message-ID: <1375102331-23905-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1375102331-23905-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:22772 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753830Ab3G2Mwc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jul 2013 08:52:32 -0400
In-Reply-To: <1375102331-23905-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch uses the new pcie_get_minimum_link function to perform a check to
ensure that the adapter is hooked into a slot which is capable of providing the
necessary bandwidth. This check supersedes the original method which only
checked the current pci device. The new method is capable of determining the
minimum speed and link of an entire PCI chain.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 130 ++++++++++++++++++++++++--
 1 file changed, 123 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 3aff87e..5ec2b74 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -195,6 +195,79 @@ static s32 ixgbe_get_parent_bus_info(struct ixgbe_adapter *adapter)
 	return 0;
 }
 
+/**
+ * ixgbe_check_from_parent - Determine whether PCIe info should come from parent
+ * @hw: hw specific details
+ *
+ * This function is used by probe to determine whether a device's PCI-Express
+ * bandwidth details should be gathered from the parent bus instead of from the
+ * device. Used to ensure that various locations all have the correct device ID
+ * checks.
+ */
+static inline bool ixgbe_pcie_from_parent(struct ixgbe_hw *hw)
+{
+	switch (hw->device_id) {
+	case IXGBE_DEV_ID_82599_SFP_SF_QP:
+		return true;
+	default:
+		return false;
+	}
+}
+
+static void ixgbe_check_minimum_link(struct ixgbe_adapter *adapter,
+				     int expected_gts)
+{
+	int max_gts = 0;
+	enum pci_bus_speed speed = PCI_SPEED_UNKNOWN;
+	enum pcie_link_width width = PCIE_LNK_WIDTH_UNKNOWN;
+	struct pci_dev *pdev;
+
+	/* determine whether to use the the parent device
+	 */
+	if (ixgbe_pcie_from_parent(&adapter->hw))
+		pdev = adapter->pdev->bus->parent->self;
+	else
+		pdev = adapter->pdev;
+
+	if (pcie_get_minimum_link(pdev, &speed, &width) ||
+	    speed == PCI_SPEED_UNKNOWN || width == PCIE_LNK_WIDTH_UNKNOWN) {
+		e_dev_warn("Unable to determine PCI-Express slot throughput.\n");
+		return;
+	}
+
+	switch (speed) {
+	case PCIE_SPEED_2_5GT:
+		/* 8b/10b encoding reduces max throughput */
+		max_gts = 2 * width;
+		break;
+	case PCIE_SPEED_5_0GT:
+		/* 8b/10b encoding reduces max throughput */
+		max_gts = 4 * width;
+		break;
+	case PCIE_SPEED_8_0GT:
+		/* 128b/130b encoding has less impact on throughput */
+		max_gts = 8 * width;
+		break;
+	default:
+		e_dev_warn("Unable to determine PCI-Express throughput.\n");
+		return;
+	}
+
+	if (max_gts < expected_gts) {
+		e_dev_warn("PCI-Express bandwidth of %dGT/s available (PCI Express:%s:Width x%d)\n",
+			   max_gts,
+			   (speed == PCIE_SPEED_8_0GT ? "8.0GT/s" :
+			    speed == PCIE_SPEED_5_0GT ? "5.0GT/s" :
+			    speed == PCIE_SPEED_2_5GT ? "2.5GT/s" :
+			    "Unknown"),
+			   width);
+		e_dev_warn("This is not sufficient for optimal performance of this card.\n");
+		e_dev_warn("For optimal performance, at least %dGT/s of bandwidth is required.\n",
+			expected_gts);
+		e_dev_warn("A slot with more lanes and/or higher speed is suggested.\n");
+	}
+}
+
 static void ixgbe_service_event_schedule(struct ixgbe_adapter *adapter)
 {
 	if (!test_bit(__IXGBE_DOWN, &adapter->state) &&
@@ -7250,6 +7323,41 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 };
 
 /**
+ * ixgbe_enumerate_functions - Get the number of ports this device has
+ * @adapter: adapter structure
+ *
+ * This function enumerates the phsyical functions co-located on a single slot,
+ * in order to determine how many ports a device has. This is most useful in
+ * determining the required GT/s of PCIe bandwidth necessary for optimal
+ * performance.
+ **/
+static inline int ixgbe_enumerate_functions(struct ixgbe_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	struct list_head *entry;
+	int physfns = 0;
+
+	/* Some cards can not use the generic count PCIe functions method, and
+	 * so must be hardcoded to the correct value.
+	 */
+	switch (hw->device_id) {
+	case IXGBE_DEV_ID_82599_SFP_SF_QP:
+		physfns = 4;
+		break;
+	default:
+		list_for_each(entry, &adapter->pdev->bus_list) {
+			struct pci_dev *pdev =
+				list_entry(entry, struct pci_dev, bus_list);
+			/* don't count virtual functions */
+			if (!pdev->is_virtfn)
+				physfns++;
+		}
+	}
+
+	return physfns;
+}
+
+/**
  * ixgbe_wol_supported - Check whether device supports WoL
  * @hw: hw specific details
  * @device_id: the device ID
@@ -7331,7 +7439,7 @@ static int ixgbe_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	struct ixgbe_hw *hw;
 	const struct ixgbe_info *ii = ixgbe_info_tbl[ent->driver_data];
 	static int cards_found;
-	int i, err, pci_using_dac;
+	int i, err, pci_using_dac, expected_gts;
 	unsigned int indices = MAX_TX_QUEUES;
 	u8 part_str[IXGBE_PBANUM_LENGTH];
 #ifdef IXGBE_FCOE
@@ -7620,7 +7728,7 @@ skip_sriov:
 
 	/* pick up the PCI bus settings for reporting later */
 	hw->mac.ops.get_bus_info(hw);
-	if (hw->device_id == IXGBE_DEV_ID_82599_SFP_SF_QP)
+	if (ixgbe_pcie_from_parent(hw))
 		ixgbe_get_parent_bus_info(adapter);
 
 	/* print bus type/speed/width info */
@@ -7646,12 +7754,20 @@ skip_sriov:
 		e_dev_info("MAC: %d, PHY: %d, PBA No: %s\n",
 			   hw->mac.type, hw->phy.type, part_str);
 
-	if (hw->bus.width <= ixgbe_bus_width_pcie_x4) {
-		e_dev_warn("PCI-Express bandwidth available for this card is "
-			   "not sufficient for optimal performance.\n");
-		e_dev_warn("For optimal performance a x8 PCI-Express slot "
-			   "is required.\n");
+	/* calculate the expected PCIe bandwidth required for optimal
+	 * performance. Note that some older parts will never have enough
+	 * bandwidth due to being older generation PCIe parts. We clamp these
+	 * parts to ensure no warning is displayed if it can't be fixed.
+	 */
+	switch (hw->mac.type) {
+	case ixgbe_mac_82598EB:
+		expected_gts = min(ixgbe_enumerate_functions(adapter) * 10, 16);
+		break;
+	default:
+		expected_gts = ixgbe_enumerate_functions(adapter) * 10;
+		break;
 	}
+	ixgbe_check_minimum_link(adapter, expected_gts);
 
 	/* reset the hardware with the new settings */
 	err = hw->mac.ops.start_hw(hw);
-- 
1.7.11.7
