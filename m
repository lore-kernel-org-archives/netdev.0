From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/15] ixgbe: fix ixgbe_stop_mac_link_on_d3_82599 to check mng correctly
Date: Thu, 20 Mar 2014 01:32:59 -0700
Message-ID: <1395304385-6874-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1395304385-6874-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Arun Sharma <asharma@fb.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:8065 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755776AbaCTIdw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Mar 2014 04:33:52 -0400
In-Reply-To: <1395304385-6874-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Previously, we did a full check to see if MNG FW was running. Instead,
we should only check to see whether it could be enabled. Since it may
become active while down, we don't want to bring the link down.

CC: Arun Sharma <asharma@fb.com>
Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
index fcba1d9..ef808bc 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
@@ -517,12 +517,16 @@ out:
  **/
 static void ixgbe_stop_mac_link_on_d3_82599(struct ixgbe_hw *hw)
 {
-	u32 autoc2_reg;
+	u32 autoc2_reg, fwsm;
 	u16 ee_ctrl_2 = 0;
 
 	hw->eeprom.ops.read(hw, IXGBE_EEPROM_CTRL_2, &ee_ctrl_2);
 
-	if (!hw->mng_fw_enabled && !hw->wol_enabled &&
+	/* Check to see if MNG FW could be enabled */
+	fwsm = IXGBE_READ_REG(hw, IXGBE_FWSM);
+
+	if (((fwsm & IXGBE_FWSM_MODE_MASK) != IXGBE_FWSM_FW_MODE_PT) &&
+	    !hw->wol_enabled &&
 	    ee_ctrl_2 & IXGBE_EEPROM_CCD_BIT) {
 		autoc2_reg = IXGBE_READ_REG(hw, IXGBE_AUTOC2);
 		autoc2_reg |= IXGBE_AUTOC2_LINK_DISABLE_ON_D3_MASK;
-- 
1.8.3.1
