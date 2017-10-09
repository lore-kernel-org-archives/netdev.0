From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/10] ixgbe: Clear SWFW_SYNC register during init
Date: Mon,  9 Oct 2017 11:39:51 -0700
Message-ID: <20171009184000.80053-2-jeffrey.t.kirsher@intel.com>
References: <20171009184000.80053-1-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:54649 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754162AbdJISkW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Oct 2017 14:40:22 -0400
In-Reply-To: <20171009184000.80053-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Added clearing of SW resource bits in the SW/FW synchronization
register to ixgbe_init_swfw_sync_X540().

Updated ixgbe_acquire_swfw_sync_X540 SW Manageability host interface
resource bit error case to match the error handling of the other SW
resource bits. Which is to release the SW resource bits if SW times
out while attempting to acquire the resource.

This allows the driver to load in cases where the semaphore bits
could be stuck after a reset or a crash.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c | 19 ++++++++++++-------
 1 file changed, 12 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
index 6ea0d6a5fb90..b8c5fd2a2115 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
@@ -619,12 +619,6 @@ s32 ixgbe_acquire_swfw_sync_X540(struct ixgbe_hw *hw, u32 mask)
 		usleep_range(5000, 10000);
 	}
 
-	/* Failed to get SW only semaphore */
-	if (swmask == IXGBE_GSSR_SW_MNG_SM) {
-		hw_dbg(hw, "Failed to get SW only semaphore\n");
-		return IXGBE_ERR_SWFW_SYNC;
-	}
-
 	/* If the resource is not released by the FW/HW the SW can assume that
 	 * the FW/HW malfunctions. In that case the SW should set the SW bit(s)
 	 * of the requested resource(s) while ignoring the corresponding FW/HW
@@ -647,7 +641,8 @@ s32 ixgbe_acquire_swfw_sync_X540(struct ixgbe_hw *hw, u32 mask)
 	 */
 	if (swfw_sync & swmask) {
 		u32 rmask = IXGBE_GSSR_EEP_SM | IXGBE_GSSR_PHY0_SM |
-			    IXGBE_GSSR_PHY1_SM | IXGBE_GSSR_MAC_CSR_SM;
+			    IXGBE_GSSR_PHY1_SM | IXGBE_GSSR_MAC_CSR_SM |
+			    IXGBE_GSSR_SW_MNG_SM;
 
 		if (swi2c_mask)
 			rmask |= IXGBE_GSSR_I2C_MASK;
@@ -763,6 +758,8 @@ static void ixgbe_release_swfw_sync_semaphore(struct ixgbe_hw *hw)
  **/
 void ixgbe_init_swfw_sync_X540(struct ixgbe_hw *hw)
 {
+	u32 rmask;
+
 	/* First try to grab the semaphore but we don't need to bother
 	 * looking to see whether we got the lock or not since we do
 	 * the same thing regardless of whether we got the lock or not.
@@ -771,6 +768,14 @@ void ixgbe_init_swfw_sync_X540(struct ixgbe_hw *hw)
 	 */
 	ixgbe_get_swfw_sync_semaphore(hw);
 	ixgbe_release_swfw_sync_semaphore(hw);
+
+	/* Acquire and release all software resources. */
+	rmask = IXGBE_GSSR_EEP_SM | IXGBE_GSSR_PHY0_SM |
+		IXGBE_GSSR_PHY1_SM | IXGBE_GSSR_MAC_CSR_SM |
+		IXGBE_GSSR_SW_MNG_SM | IXGBE_GSSR_I2C_MASK;
+
+	ixgbe_acquire_swfw_sync_X540(hw, rmask);
+	ixgbe_release_swfw_sync_X540(hw, rmask);
 }
 
 /**
-- 
2.14.2
