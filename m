From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 03/16] i40e: Populate and check pci bus speed and width
Date: Fri, 20 Dec 2013 08:45:52 -0800
Message-ID: <1387557965-13241-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1387557965-13241-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:43164 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754657Ab3LTQsC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Dec 2013 11:48:02 -0500
In-Reply-To: <1387557965-13241-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

Call i40e_set_pci_config_data from probe, then check that
we are in a 8GT/s x8 PCIe slot and send a warning if we are not.

Change-Id: I62815c574cee50d2787c50bbe956dde7a7a75a11
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c    | 44 ++++++++++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_main.c      | 23 +++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_prototype.h |  1 +
 drivers/net/ethernet/intel/i40e/i40e_type.h      |  9 +++++
 4 files changed, 77 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 8b6d56a..cba1eb4 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -2029,3 +2029,47 @@ i40e_status i40e_set_filter_control(struct i40e_hw *hw,
 
 	return 0;
 }
+/**
+ * i40e_set_pci_config_data - store PCI bus info
+ * @hw: pointer to hardware structure
+ * @link_status: the link status word from PCI config space
+ *
+ * Stores the PCI bus info (speed, width, type) within the i40e_hw structure
+ **/
+void i40e_set_pci_config_data(struct i40e_hw *hw, u16 link_status)
+{
+	hw->bus.type = i40e_bus_type_pci_express;
+
+	switch (link_status & PCI_EXP_LNKSTA_NLW) {
+	case I40E_PCI_LINK_WIDTH_1:
+		hw->bus.width = i40e_bus_width_pcie_x1;
+		break;
+	case I40E_PCI_LINK_WIDTH_2:
+		hw->bus.width = i40e_bus_width_pcie_x2;
+		break;
+	case I40E_PCI_LINK_WIDTH_4:
+		hw->bus.width = i40e_bus_width_pcie_x4;
+		break;
+	case I40E_PCI_LINK_WIDTH_8:
+		hw->bus.width = i40e_bus_width_pcie_x8;
+		break;
+	default:
+		hw->bus.width = i40e_bus_width_unknown;
+		break;
+	}
+
+	switch (link_status & PCI_EXP_LNKSTA_CLS) {
+	case I40E_PCI_LINK_SPEED_2500:
+		hw->bus.speed = i40e_bus_speed_2500;
+		break;
+	case I40E_PCI_LINK_SPEED_5000:
+		hw->bus.speed = i40e_bus_speed_5000;
+		break;
+	case I40E_PCI_LINK_SPEED_8000:
+		hw->bus.speed = i40e_bus_speed_8000;
+		break;
+	default:
+		hw->bus.speed = i40e_bus_speed_unknown;
+		break;
+	}
+}
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index f14b31c..22a2c0e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7369,6 +7369,7 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	struct i40e_pf *pf;
 	struct i40e_hw *hw;
 	static u16 pfs_found;
+	u16 link_status;
 	int err = 0;
 	u32 len;
 
@@ -7603,6 +7604,28 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	mod_timer(&pf->service_timer,
 		  round_jiffies(jiffies + pf->service_timer_period));
 
+	/* Get the negotiated link width and speed from PCI config space */
+	pcie_capability_read_word(pf->pdev, PCI_EXP_LNKSTA, &link_status);
+
+	i40e_set_pci_config_data(hw, link_status);
+
+	dev_info(&pdev->dev, "PCI Express: %s %s\n",
+		(hw->bus.speed == i40e_bus_speed_8000 ? "Speed 8.0GT/s" :
+		 hw->bus.speed == i40e_bus_speed_5000 ? "Speed 5.0GT/s" :
+		 hw->bus.speed == i40e_bus_speed_2500 ? "Speed 2.5GT/s" :
+		 "Unknown"),
+		(hw->bus.width == i40e_bus_width_pcie_x8 ? "Width x8" :
+		 hw->bus.width == i40e_bus_width_pcie_x4 ? "Width x4" :
+		 hw->bus.width == i40e_bus_width_pcie_x2 ? "Width x2" :
+		 hw->bus.width == i40e_bus_width_pcie_x1 ? "Width x1" :
+		 "Unknown"));
+
+	if (hw->bus.width < i40e_bus_width_pcie_x8 ||
+	    hw->bus.speed < i40e_bus_speed_8000) {
+		dev_warn(&pdev->dev, "PCI-Express bandwidth available for this device may be insufficient for optimal performance.\n");
+		dev_warn(&pdev->dev, "Please move the device to a different PCI-e link with more lanes and/or higher transfer rate.\n");
+	}
+
 	return 0;
 
 	/* Unwind what we've done if something failed in the setup */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_prototype.h b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
index 2fc9ce5..db7bf93 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_prototype.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
@@ -215,6 +215,7 @@ i40e_status i40e_read_nvm_buffer(struct i40e_hw *hw, u16 offset,
 					   u16 *words, u16 *data);
 i40e_status i40e_validate_nvm_checksum(struct i40e_hw *hw,
 						 u16 *checksum);
+void i40e_set_pci_config_data(struct i40e_hw *hw, u16 link_status);
 
 /* prototype for functions used for SW locks */
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index 72a6028..008a7a0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -116,6 +116,15 @@ enum i40e_debug_mask {
 	I40E_DEBUG_ALL			= 0xFFFFFFFF
 };
 
+/* PCI Bus Info */
+#define I40E_PCI_LINK_WIDTH_1		0x10
+#define I40E_PCI_LINK_WIDTH_2		0x20
+#define I40E_PCI_LINK_WIDTH_4		0x40
+#define I40E_PCI_LINK_WIDTH_8		0x80
+#define I40E_PCI_LINK_SPEED_2500	0x1
+#define I40E_PCI_LINK_SPEED_5000	0x2
+#define I40E_PCI_LINK_SPEED_8000	0x3
+
 /* These are structs for managing the hardware information and the operations.
  * The structures of function pointers are filled out at init time when we
  * know for sure exactly which hardware we're working with.  This gives us the
-- 
1.8.3.1
