From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/11] ixgbe: enable devices with internal switch to read pci parent
Date: Fri, 12 Apr 2013 04:24:22 -0700
Message-ID: <1365765866-15741-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1365765866-15741-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:46845 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754921Ab3DLLZF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Apr 2013 07:25:05 -0400
In-Reply-To: <1365765866-15741-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch modifies the driver to enable certain devices, which have an internal
switch, to read data from the physical slot rather than reading data from the
internal switch. The internal switch will always report the same PCI width and
speed, which is not useful compared to knowing the width and speed of the slot
the physical card is plugged into.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 48 +++++++++++++++++++++++++++
 1 file changed, 48 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 35727dc..e02b4e4 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -149,6 +149,52 @@ MODULE_DESCRIPTION("Intel(R) 10 Gigabit PCI Express Network Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 
+static int ixgbe_read_pci_cfg_word_parent(struct ixgbe_adapter *adapter,
+					  u32 reg, u16 *value)
+{
+	int pos = 0;
+	struct pci_dev *parent_dev;
+	struct pci_bus *parent_bus;
+
+	parent_bus = adapter->pdev->bus->parent;
+	if (!parent_bus)
+		return -1;
+
+	parent_dev = parent_bus->self;
+	if (!parent_dev)
+		return -1;
+
+	pos = pci_find_capability(parent_dev, PCI_CAP_ID_EXP);
+	if (!pos)
+		return -1;
+
+	pci_read_config_word(parent_dev, pos + reg, value);
+	return 0;
+}
+
+static s32 ixgbe_get_parent_bus_info(struct ixgbe_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	u16 link_status = 0;
+	int err;
+
+	hw->bus.type = ixgbe_bus_type_pci_express;
+
+	/* Get the negotiated link width and speed from PCI config space of the
+	 * parent, as this device is behind a switch
+	 */
+	err = ixgbe_read_pci_cfg_word_parent(adapter, 18, &link_status);
+
+	/* assume caller will handle error case */
+	if (err)
+		return err;
+
+	hw->bus.width = ixgbe_convert_bus_width(link_status);
+	hw->bus.speed = ixgbe_convert_bus_speed(link_status);
+
+	return 0;
+}
+
 static void ixgbe_service_event_schedule(struct ixgbe_adapter *adapter)
 {
 	if (!test_bit(__IXGBE_DOWN, &adapter->state) &&
@@ -7584,6 +7630,8 @@ skip_sriov:
 
 	/* pick up the PCI bus settings for reporting later */
 	hw->mac.ops.get_bus_info(hw);
+	if (hw->device_id == IXGBE_DEV_ID_82599_SFP_SF_QP)
+		ixgbe_get_parent_bus_info(adapter);
 
 	/* print bus type/speed/width info */
 	e_dev_info("(PCI Express:%s:%s) %pM\n",
-- 
1.7.11.7
