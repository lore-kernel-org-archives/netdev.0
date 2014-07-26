From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/12] ixgbe: Correct X540 semaphore error
Date: Fri, 25 Jul 2014 21:45:13 -0700
Message-ID: <1406349922-9883-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1406349922-9883-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:9197 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750967AbaGZEp0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Jul 2014 00:45:26 -0400
In-Reply-To: <1406349922-9883-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

In the function ixgbe_get_swfw_sync_semaphore, an incorrect
check was treating success as failure and vice-versa. This led
to manipulating the IXGBE_SWFW_SYNC register without holding
the software semaphore first, which is an error. In addition,
if getting the REGSMP bit in the IXGBE_SW_FW_SYNC register
timed out, no error code would be returned, making the caller
think that it had successfully acquired the lock. Fix both of
those issues and clean up the function a bit, such as make the
name in the comment match the function.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c | 34 +++++++++++++--------------
 1 file changed, 16 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
index efdb517..1e26794 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
@@ -659,46 +659,44 @@ static void ixgbe_release_swfw_sync_X540(struct ixgbe_hw *hw, u16 mask)
 }
 
 /**
- * ixgbe_get_nvm_semaphore - Get hardware semaphore
+ * ixgbe_get_swfw_sync_semaphore - Get hardware semaphore
  * @hw: pointer to hardware structure
  *
  * Sets the hardware semaphores so SW/FW can gain control of shared resources
- **/
+ */
 static s32 ixgbe_get_swfw_sync_semaphore(struct ixgbe_hw *hw)
 {
-	s32 status = IXGBE_ERR_EEPROM;
 	u32 timeout = 2000;
 	u32 i;
 	u32 swsm;
 
 	/* Get SMBI software semaphore between device drivers first */
 	for (i = 0; i < timeout; i++) {
-		/*
-		 * If the SMBI bit is 0 when we read it, then the bit will be
+		/* If the SMBI bit is 0 when we read it, then the bit will be
 		 * set and we have the semaphore
 		 */
 		swsm = IXGBE_READ_REG(hw, IXGBE_SWSM);
-		if (!(swsm & IXGBE_SWSM_SMBI)) {
-			status = 0;
+		if (!(swsm & IXGBE_SWSM_SMBI))
 			break;
-		}
 		usleep_range(50, 100);
 	}
 
+	if (i == timeout) {
+		hw_dbg(hw,
+		       "Software semaphore SMBI between device drivers not granted.\n");
+		return IXGBE_ERR_EEPROM;
+	}
+
 	/* Now get the semaphore between SW/FW through the REGSMP bit */
-	if (status) {
-		for (i = 0; i < timeout; i++) {
-			swsm = IXGBE_READ_REG(hw, IXGBE_SWFW_SYNC);
-			if (!(swsm & IXGBE_SWFW_REGSMP))
-				break;
+	for (i = 0; i < timeout; i++) {
+		swsm = IXGBE_READ_REG(hw, IXGBE_SWFW_SYNC);
+		if (!(swsm & IXGBE_SWFW_REGSMP))
+			return 0;
 
-			usleep_range(50, 100);
-		}
-	} else {
-		hw_dbg(hw, "Software semaphore SMBI between device drivers not granted.\n");
+		usleep_range(50, 100);
 	}
 
-	return status;
+	return IXGBE_ERR_EEPROM;
 }
 
 /**
-- 
1.9.3
