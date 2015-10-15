From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/17] ixgbe: Fix CS4227-related semaphore error on reset failure
Date: Thu, 15 Oct 2015 02:39:49 -0700
Message-ID: <1444902004-14433-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444902004-14433-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:12861 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751967AbbJOJm0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2015 05:42:26 -0400
In-Reply-To: <1444902004-14433-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

If the reset never completes, it is necessary to retake the
semaphore before returning, because the caller will release
the semaphore.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Darin Miller <darin.j.miller@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index ed7b289..06b15edd 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -198,6 +198,7 @@ static s32 ixgbe_write_pe(struct ixgbe_hw *hw, u8 reg, u8 value)
  * ixgbe_reset_cs4227 - Reset CS4227 using port expander
  * @hw: pointer to hardware structure
  *
+ * This function assumes that the caller has acquired the proper semaphore.
  * Returns error code
  */
 static s32 ixgbe_reset_cs4227(struct ixgbe_hw *hw)
@@ -296,6 +297,14 @@ static void ixgbe_check_cs4227(struct ixgbe_hw *hw)
 		hw->mac.ops.release_swfw_sync(hw, swfw_mask);
 		msleep(IXGBE_CS4227_CHECK_DELAY);
 	}
+	/* If still pending, assume other instance failed. */
+	if (retry == IXGBE_CS4227_RETRIES) {
+		status = hw->mac.ops.acquire_swfw_sync(hw, swfw_mask);
+		if (status) {
+			hw_err(hw, "semaphore failed with %d\n", status);
+			return;
+		}
+	}
 
 	/* Reset the CS4227. */
 	status = ixgbe_reset_cs4227(hw);
-- 
2.4.3
