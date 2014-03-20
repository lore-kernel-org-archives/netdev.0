From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/15] ixgbe: use ixgbe_read_pci_cfg_word
Date: Thu, 20 Mar 2014 01:33:02 -0700
Message-ID: <1395304385-6874-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1395304385-6874-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Arun Sharma <asharma@fb.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:8080 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755915AbaCTId4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Mar 2014 04:33:56 -0400
In-Reply-To: <1395304385-6874-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch replaces some direct uses of pci_read_config_word with the
protected ixgbe_read_pci_cfg_word function, which checks for whether the
adapter is removed when LER is enabled. We shouldn't use the
pci_read_config_word calls directly because of these checks.

This patch also cleans up an unnecessary save of a pointer to the mac
object, as our standard style is to just use the hw pointer.

CC: Arun Sharma <asharma@fb.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index 7a9d874..911b711 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -646,20 +646,17 @@ enum ixgbe_bus_speed ixgbe_convert_bus_speed(u16 link_status)
  **/
 s32 ixgbe_get_bus_info_generic(struct ixgbe_hw *hw)
 {
-	struct ixgbe_adapter *adapter = hw->back;
-	struct ixgbe_mac_info *mac = &hw->mac;
 	u16 link_status;
 
 	hw->bus.type = ixgbe_bus_type_pci_express;
 
 	/* Get the negotiated link width and speed from PCI config space */
-	pci_read_config_word(adapter->pdev, IXGBE_PCI_LINK_STATUS,
-	                     &link_status);
+	link_status = ixgbe_read_pci_cfg_word(hw, IXGBE_PCI_LINK_STATUS);
 
 	hw->bus.width = ixgbe_convert_bus_width(link_status);
 	hw->bus.speed = ixgbe_convert_bus_speed(link_status);
 
-	mac->ops.set_lan_id(hw);
+	hw->mac.ops.set_lan_id(hw);
 
 	return 0;
 }
@@ -2437,12 +2434,10 @@ out:
  **/
 static u32 ixgbe_pcie_timeout_poll(struct ixgbe_hw *hw)
 {
-	struct ixgbe_adapter *adapter = hw->back;
 	s16 devctl2;
 	u32 pollcnt;
 
-	pci_read_config_word(adapter->pdev, IXGBE_PCI_DEVICE_CONTROL2,
-			     &devctl2);
+	devctl2 = ixgbe_read_pci_cfg_word(hw, IXGBE_PCI_DEVICE_CONTROL2);
 	devctl2 &= IXGBE_PCIDEVCTRL2_TIMEO_MASK;
 
 	switch (devctl2) {
-- 
1.8.3.1
