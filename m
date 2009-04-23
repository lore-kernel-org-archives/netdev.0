From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] ixgbe: Fix WoL functionality for 82599 KX4 devices
Date: Thu, 23 Apr 2009 14:15:18 -0700
Message-ID: <20090423211514.29345.14658.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.emeryville.ca.mail.comcast.net ([76.96.30.17]:39906 "EHLO
	QMTA10.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754952AbZDWVPg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 17:15:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Waskiewicz Jr, Peter P <peter.p.waskiewicz.jr@intel.com>

The current code writes the PME enabled bit in PCI config space which is
wrong.  This was needed for pre-release hardware, and was not removed from
the driver.  Also, we need to clear the WUS (wake up status) after we
resume.  Otherwise we can't wake for the same event again since it's still
asserted in the hardware.  Plus, the multicast lists were being written
improperly, causing multicast WoL to fail.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_common.c |   51 +-------------------------------------
 drivers/net/ixgbe/ixgbe_main.c   |   10 +++----
 2 files changed, 6 insertions(+), 55 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index 5567519..186a650 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -50,7 +50,6 @@ static u16 ixgbe_calc_eeprom_checksum(struct ixgbe_hw *hw);
 static void ixgbe_enable_rar(struct ixgbe_hw *hw, u32 index);
 static void ixgbe_disable_rar(struct ixgbe_hw *hw, u32 index);
 static s32 ixgbe_mta_vector(struct ixgbe_hw *hw, u8 *mc_addr);
-static void ixgbe_add_mc_addr(struct ixgbe_hw *hw, u8 *mc_addr);
 static void ixgbe_add_uc_addr(struct ixgbe_hw *hw, u8 *addr, u32 vmdq);
 
 /**
@@ -1377,8 +1376,7 @@ s32 ixgbe_update_uc_addr_list_generic(struct ixgbe_hw *hw, u8 *addr_list,
 	 * Clear accounting of old secondary address list,
 	 * don't count RAR[0]
 	 */
-	uc_addr_in_use = hw->addr_ctrl.rar_used_count -
-	                 hw->addr_ctrl.mc_addr_in_rar_count - 1;
+	uc_addr_in_use = hw->addr_ctrl.rar_used_count - 1;
 	hw->addr_ctrl.rar_used_count -= uc_addr_in_use;
 	hw->addr_ctrl.overflow_promisc = 0;
 
@@ -1493,40 +1491,6 @@ static void ixgbe_set_mta(struct ixgbe_hw *hw, u8 *mc_addr)
 }
 
 /**
- *  ixgbe_add_mc_addr - Adds a multicast address.
- *  @hw: pointer to hardware structure
- *  @mc_addr: new multicast address
- *
- *  Adds it to unused receive address register or to the multicast table.
- **/
-static void ixgbe_add_mc_addr(struct ixgbe_hw *hw, u8 *mc_addr)
-{
-	u32 rar_entries = hw->mac.num_rar_entries;
-	u32 rar;
-
-	hw_dbg(hw, " MC Addr =%.2X %.2X %.2X %.2X %.2X %.2X\n",
-	       mc_addr[0], mc_addr[1], mc_addr[2],
-	       mc_addr[3], mc_addr[4], mc_addr[5]);
-
-	/*
-	 * Place this multicast address in the RAR if there is room,
-	 * else put it in the MTA
-	 */
-	if (hw->addr_ctrl.rar_used_count < rar_entries) {
-		/* use RAR from the end up for multicast */
-		rar = rar_entries - hw->addr_ctrl.mc_addr_in_rar_count - 1;
-		hw->mac.ops.set_rar(hw, rar, mc_addr, 0, IXGBE_RAH_AV);
-		hw_dbg(hw, "Added a multicast address to RAR[%d]\n", rar);
-		hw->addr_ctrl.rar_used_count++;
-		hw->addr_ctrl.mc_addr_in_rar_count++;
-	} else {
-		ixgbe_set_mta(hw, mc_addr);
-	}
-
-	hw_dbg(hw, "ixgbe_add_mc_addr Complete\n");
-}
-
-/**
  *  ixgbe_update_mc_addr_list_generic - Updates MAC list of multicast addresses
  *  @hw: pointer to hardware structure
  *  @mc_addr_list: the list of new multicast addresses
@@ -1542,7 +1506,6 @@ s32 ixgbe_update_mc_addr_list_generic(struct ixgbe_hw *hw, u8 *mc_addr_list,
                                       u32 mc_addr_count, ixgbe_mc_addr_itr next)
 {
 	u32 i;
-	u32 rar_entries = hw->mac.num_rar_entries;
 	u32 vmdq;
 
 	/*
@@ -1550,18 +1513,8 @@ s32 ixgbe_update_mc_addr_list_generic(struct ixgbe_hw *hw, u8 *mc_addr_list,
 	 * use.
 	 */
 	hw->addr_ctrl.num_mc_addrs = mc_addr_count;
-	hw->addr_ctrl.rar_used_count -= hw->addr_ctrl.mc_addr_in_rar_count;
-	hw->addr_ctrl.mc_addr_in_rar_count = 0;
 	hw->addr_ctrl.mta_in_use = 0;
 
-	/* Zero out the other receive addresses. */
-	hw_dbg(hw, "Clearing RAR[%d-%d]\n", hw->addr_ctrl.rar_used_count,
-	          rar_entries - 1);
-	for (i = hw->addr_ctrl.rar_used_count; i < rar_entries; i++) {
-		IXGBE_WRITE_REG(hw, IXGBE_RAL(i), 0);
-		IXGBE_WRITE_REG(hw, IXGBE_RAH(i), 0);
-	}
-
 	/* Clear the MTA */
 	hw_dbg(hw, " Clearing MTA\n");
 	for (i = 0; i < hw->mac.mcft_size; i++)
@@ -1570,7 +1523,7 @@ s32 ixgbe_update_mc_addr_list_generic(struct ixgbe_hw *hw, u8 *mc_addr_list,
 	/* Add the new addresses */
 	for (i = 0; i < mc_addr_count; i++) {
 		hw_dbg(hw, " Adding the multicast addresses:\n");
-		ixgbe_add_mc_addr(hw, next(hw, &mc_addr_list, &vmdq));
+		ixgbe_set_mta(hw, next(hw, &mc_addr_list, &vmdq));
 	}
 
 	/* Enable mta */
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 0188425..07e778d 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3646,6 +3646,8 @@ static int ixgbe_resume(struct pci_dev *pdev)
 
 	ixgbe_reset(adapter);
 
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_WUS, ~0);
+
 	if (netif_running(netdev)) {
 		err = ixgbe_open(adapter->netdev);
 		if (err)
@@ -4575,7 +4577,6 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	const struct ixgbe_info *ii = ixgbe_info_tbl[ent->driver_data];
 	static int cards_found;
 	int i, err, pci_using_dac;
-	u16 pm_value = 0;
 	u32 part_num, eec;
 
 	err = pci_enable_device(pdev);
@@ -4763,11 +4764,8 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 
 	switch (pdev->device) {
 	case IXGBE_DEV_ID_82599_KX4:
-#define IXGBE_PCIE_PMCSR 0x44
-		adapter->wol = IXGBE_WUFC_MAG;
-		pci_read_config_word(pdev, IXGBE_PCIE_PMCSR, &pm_value);
-		pci_write_config_word(pdev, IXGBE_PCIE_PMCSR,
-		                      (pm_value | (1 << 8)));
+		adapter->wol = (IXGBE_WUFC_MAG | IXGBE_WUFC_EX |
+		                IXGBE_WUFC_MC | IXGBE_WUFC_BC);
 		break;
 	default:
 		adapter->wol = 0;

