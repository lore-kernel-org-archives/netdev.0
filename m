From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/5] ixgbe: Use is_valid_ether_addr
Date: Thu,  6 Dec 2012 22:11:31 -0800
Message-ID: <1354860695-27039-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1354860695-27039-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:4860 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751756Ab2LGGLr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Dec 2012 01:11:47 -0500
In-Reply-To: <1354860695-27039-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

Use the normal kernel test instead of a module specific one.

Signed-off-by: Joe Perches <joe@perches.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c  |  2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 26 +------------------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h |  1 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |  2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h   |  9 ---------
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c   |  2 +-
 6 files changed, 4 insertions(+), 38 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
index e75f5a4..1073aea 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
@@ -1078,7 +1078,7 @@ mac_reset_top:
 	hw->mac.ops.get_san_mac_addr(hw, hw->mac.san_addr);
 
 	/* Add the SAN MAC address to the RAR only if it's a valid address */
-	if (ixgbe_validate_mac_addr(hw->mac.san_addr) == 0) {
+	if (is_valid_ether_addr(hw->mac.san_addr)) {
 		hw->mac.ops.set_rar(hw, hw->mac.num_rar_entries - 1,
 		                    hw->mac.san_addr, 0, IXGBE_RAH_AV);
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index 5af1eeb..5e68afd 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -1783,29 +1783,6 @@ s32 ixgbe_update_eeprom_checksum_generic(struct ixgbe_hw *hw)
 }
 
 /**
- *  ixgbe_validate_mac_addr - Validate MAC address
- *  @mac_addr: pointer to MAC address.
- *
- *  Tests a MAC address to ensure it is a valid Individual Address
- **/
-s32 ixgbe_validate_mac_addr(u8 *mac_addr)
-{
-	s32 status = 0;
-
-	/* Make sure it is not a multicast address */
-	if (IXGBE_IS_MULTICAST(mac_addr))
-		status = IXGBE_ERR_INVALID_MAC_ADDR;
-	/* Not a broadcast address */
-	else if (IXGBE_IS_BROADCAST(mac_addr))
-		status = IXGBE_ERR_INVALID_MAC_ADDR;
-	/* Reject the zero address */
-	else if (is_zero_ether_addr(mac_addr))
-		status = IXGBE_ERR_INVALID_MAC_ADDR;
-
-	return status;
-}
-
-/**
  *  ixgbe_set_rar_generic - Set Rx address register
  *  @hw: pointer to hardware structure
  *  @index: Receive address register to write
@@ -1909,8 +1886,7 @@ s32 ixgbe_init_rx_addrs_generic(struct ixgbe_hw *hw)
 	 * to the permanent address.
 	 * Otherwise, use the permanent address from the eeprom.
 	 */
-	if (ixgbe_validate_mac_addr(hw->mac.addr) ==
-	    IXGBE_ERR_INVALID_MAC_ADDR) {
+	if (!is_valid_ether_addr(hw->mac.addr)) {
 		/* Get the MAC address from the RAR0 for later reference */
 		hw->mac.ops.get_mac_addr(hw, hw->mac.addr);
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
index 1b65b6c..f7a0970 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
@@ -81,7 +81,6 @@ s32 ixgbe_fc_enable_generic(struct ixgbe_hw *hw);
 s32 ixgbe_device_supports_autoneg_fc(struct ixgbe_hw *hw);
 void ixgbe_fc_autoneg(struct ixgbe_hw *hw);
 
-s32 ixgbe_validate_mac_addr(u8 *mac_addr);
 s32 ixgbe_acquire_swfw_sync(struct ixgbe_hw *hw, u16 mask);
 void ixgbe_release_swfw_sync(struct ixgbe_hw *hw, u16 mask);
 s32 ixgbe_get_san_mac_addr_generic(struct ixgbe_hw *hw, u8 *san_mac_addr);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 2fa16de..b7bc22b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7444,7 +7444,7 @@ static int ixgbe_probe(struct pci_dev *pdev,
 	memcpy(netdev->dev_addr, hw->mac.perm_addr, netdev->addr_len);
 	memcpy(netdev->perm_addr, hw->mac.perm_addr, netdev->addr_len);
 
-	if (ixgbe_validate_mac_addr(netdev->perm_addr)) {
+	if (!is_valid_ether_addr(netdev->perm_addr)) {
 		e_dev_err("invalid MAC address\n");
 		err = -EIO;
 		goto err_sw_init;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 21915e2..cab302a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -1834,15 +1834,6 @@ enum {
 /* Number of 100 microseconds we wait for PCI Express master disable */
 #define IXGBE_PCI_MASTER_DISABLE_TIMEOUT 800
 
-/* Check whether address is multicast.  This is little-endian specific check.*/
-#define IXGBE_IS_MULTICAST(Address) \
-                (bool)(((u8 *)(Address))[0] & ((u8)0x01))
-
-/* Check whether an address is broadcast. */
-#define IXGBE_IS_BROADCAST(Address)                      \
-                ((((u8 *)(Address))[0] == ((u8)0xff)) && \
-                (((u8 *)(Address))[1] == ((u8)0xff)))
-
 /* RAH */
 #define IXGBE_RAH_VIND_MASK     0x003C0000
 #define IXGBE_RAH_VIND_SHIFT    18
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
index de4da52..c73b929 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
@@ -152,7 +152,7 @@ mac_reset_top:
 	hw->mac.ops.get_san_mac_addr(hw, hw->mac.san_addr);
 
 	/* Add the SAN MAC address to the RAR only if it's a valid address */
-	if (ixgbe_validate_mac_addr(hw->mac.san_addr) == 0) {
+	if (is_valid_ether_addr(hw->mac.san_addr)) {
 		hw->mac.ops.set_rar(hw, hw->mac.num_rar_entries - 1,
 		                    hw->mac.san_addr, 0, IXGBE_RAH_AV);
 
-- 
1.7.11.7
