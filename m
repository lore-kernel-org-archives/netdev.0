From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 1/5] ixgbe: modify behavior on receiving a HW ECC error.
Date: Thu, 13 Feb 2014 00:00:46 -0800
Message-ID: <1392278450-27062-2-git-send-email-aaron.f.brown@intel.com>
References: <1392278450-27062-1-git-send-email-aaron.f.brown@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:61219 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752491AbaBMIDL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Feb 2014 03:03:11 -0500
In-Reply-To: <1392278450-27062-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

Currently when we noticed a HW ECC error we would  request the use reload
the driver to force a reset of the part.  This was done due to the mistaken
believe that a normal reset would not be sufficient.  Well it turns out it
would be so now we just schedule a reset upon seeing the ECC.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 6d4ada7..7824559 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2630,9 +2630,12 @@ static irqreturn_t ixgbe_msix_other(int irq, void *data)
 	switch (hw->mac.type) {
 	case ixgbe_mac_82599EB:
 	case ixgbe_mac_X540:
-		if (eicr & IXGBE_EICR_ECC)
-			e_info(link, "Received unrecoverable ECC Err, please "
-			       "reboot\n");
+		if (eicr & IXGBE_EICR_ECC) {
+			e_info(link, "Received ECC Err, initiating reset\n");
+			adapter->flags2 |= IXGBE_FLAG2_RESET_REQUESTED;
+			ixgbe_service_event_schedule(adapter);
+			IXGBE_WRITE_REG(hw, IXGBE_EICR, IXGBE_EICR_ECC);
+		}
 		/* Handle Flow Director Full threshold interrupt */
 		if (eicr & IXGBE_EICR_FLOW_DIR) {
 			int reinit_count = 0;
@@ -2846,9 +2849,12 @@ static irqreturn_t ixgbe_intr(int irq, void *data)
 		ixgbe_check_sfp_event(adapter, eicr);
 		/* Fall through */
 	case ixgbe_mac_X540:
-		if (eicr & IXGBE_EICR_ECC)
-			e_info(link, "Received unrecoverable ECC err, please "
-				     "reboot\n");
+		if (eicr & IXGBE_EICR_ECC) {
+			e_info(link, "Received ECC Err, initiating reset\n");
+			adapter->flags2 |= IXGBE_FLAG2_RESET_REQUESTED;
+			ixgbe_service_event_schedule(adapter);
+			IXGBE_WRITE_REG(hw, IXGBE_EICR, IXGBE_EICR_ECC);
+		}
 		ixgbe_check_overtemp_event(adapter, eicr);
 		break;
 	default:
-- 
1.8.5.GIT
