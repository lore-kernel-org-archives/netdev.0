From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/8] ixgbe: fix LED blink logic to check for link
Date: Wed, 16 Nov 2011 04:51:27 -0800
Message-ID: <1321447892-14381-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1321447892-14381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:24667 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755260Ab1KPMvh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Nov 2011 07:51:37 -0500
In-Reply-To: <1321447892-14381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Previously the driver would force link without checking whether the link was
already established. This caused some inconsistencies in the LED blink rate.

Do not force link if link is already up.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c |   18 +++++++++++-------
 1 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
index e5101e9..8cc5ecc 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
@@ -751,16 +751,20 @@ static s32 ixgbe_blink_led_start_X540(struct ixgbe_hw *hw, u32 index)
 {
 	u32 macc_reg;
 	u32 ledctl_reg;
+	ixgbe_link_speed speed;
+	bool link_up;
 
 	/*
-	 * In order for the blink bit in the LED control register
-	 * to work, link and speed must be forced in the MAC. We
-	 * will reverse this when we stop the blinking.
+	 * Link should be up in order for the blink bit in the LED control
+	 * register to work. Force link and speed in the MAC if link is down.
+	 * This will be reversed when we stop the blinking.
 	 */
-	macc_reg = IXGBE_READ_REG(hw, IXGBE_MACC);
-	macc_reg |= IXGBE_MACC_FLU | IXGBE_MACC_FSV_10G | IXGBE_MACC_FS;
-	IXGBE_WRITE_REG(hw, IXGBE_MACC, macc_reg);
-
+	hw->mac.ops.check_link(hw, &speed, &link_up, false);
+	if (link_up == false) {
+		macc_reg = IXGBE_READ_REG(hw, IXGBE_MACC);
+		macc_reg |= IXGBE_MACC_FLU | IXGBE_MACC_FSV_10G | IXGBE_MACC_FS;
+		IXGBE_WRITE_REG(hw, IXGBE_MACC, macc_reg);
+	}
 	/* Set the LED to LINK_UP + BLINK. */
 	ledctl_reg = IXGBE_READ_REG(hw, IXGBE_LEDCTL);
 	ledctl_reg &= ~IXGBE_LED_MODE_MASK(index);
-- 
1.7.6.4
