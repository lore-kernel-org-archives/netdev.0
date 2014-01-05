From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/15] i40e: fix mac address checking
Date: Sun,  5 Jan 2014 02:46:54 -0800
Message-ID: <1388918827-13430-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1388918827-13430-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:33338 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751112AbaAEKrL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Jan 2014 05:47:11 -0500
In-Reply-To: <1388918827-13430-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Remove custom i40e functions around ethernet addresses that are
duplicating already existing kernel functionality.

Also ends up fixing a bug with multicast addresses.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c    | 27 ------------------------
 drivers/net/ethernet/intel/i40e/i40e_main.c      |  2 +-
 drivers/net/ethernet/intel/i40e/i40e_prototype.h |  1 -
 3 files changed, 1 insertion(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index d84fca1..e5694b9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -240,33 +240,6 @@ i40e_status i40e_get_mac_addr(struct i40e_hw *hw, u8 *mac_addr)
 }
 
 /**
- * i40e_validate_mac_addr - Validate MAC address
- * @mac_addr: pointer to MAC address
- *
- * Tests a MAC address to ensure it is a valid Individual Address
- **/
-i40e_status i40e_validate_mac_addr(u8 *mac_addr)
-{
-	i40e_status status = 0;
-
-	/* Make sure it is not a multicast address */
-	if (I40E_IS_MULTICAST(mac_addr)) {
-		hw_dbg(hw, "MAC address is multicast\n");
-		status = I40E_ERR_INVALID_MAC_ADDR;
-	/* Not a broadcast address */
-	} else if (I40E_IS_BROADCAST(mac_addr)) {
-		hw_dbg(hw, "MAC address is broadcast\n");
-		status = I40E_ERR_INVALID_MAC_ADDR;
-	/* Reject the zero address */
-	} else if (mac_addr[0] == 0 && mac_addr[1] == 0 && mac_addr[2] == 0 &&
-		   mac_addr[3] == 0 && mac_addr[4] == 0 && mac_addr[5] == 0) {
-		hw_dbg(hw, "MAC address is all zeros\n");
-		status = I40E_ERR_INVALID_MAC_ADDR;
-	}
-	return status;
-}
-
-/**
  * i40e_get_media_type - Gets media type
  * @hw: pointer to the hardware structure
  **/
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index d5719bd..e48e1c8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7644,7 +7644,7 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 
 	i40e_get_mac_addr(hw, hw->mac.addr);
-	if (i40e_validate_mac_addr(hw->mac.addr)) {
+	if (!is_valid_ether_addr(hw->mac.addr)) {
 		dev_info(&pdev->dev, "invalid MAC address %pM\n", hw->mac.addr);
 		err = -EIO;
 		goto err_mac_addr;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_prototype.h b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
index 0b6e9fc..800f3c8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_prototype.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
@@ -205,7 +205,6 @@ void i40e_clear_pxe_mode(struct i40e_hw *hw);
 bool i40e_get_link_status(struct i40e_hw *hw);
 i40e_status i40e_get_mac_addr(struct i40e_hw *hw,
 						u8 *mac_addr);
-i40e_status i40e_validate_mac_addr(u8 *mac_addr);
 i40e_status i40e_read_lldp_cfg(struct i40e_hw *hw,
 					struct i40e_lldp_variables *lldp_cfg);
 /* prototype for functions used for NVM access */
-- 
1.8.3.1
