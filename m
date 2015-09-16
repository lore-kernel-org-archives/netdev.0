From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/18] ixgbe: fix issue with SFP events with new X550 devices
Date: Tue, 15 Sep 2015 17:36:26 -0700
Message-ID: <1442363803-47237-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1442363803-47237-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:25583 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752903AbbIPAgr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Sep 2015 20:36:47 -0400
In-Reply-To: <1442363803-47237-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

Add checks for systems that don't have SFP's to avoid incorrectly
acting on interrupts that are falsely interpreted as SFP events.
This also includes a modified check generating the EICR mask to be
more forward-looking.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 63b2cfe..b9267e2 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2495,17 +2495,26 @@ static inline bool ixgbe_is_sfp(struct ixgbe_hw *hw)
 static void ixgbe_check_sfp_event(struct ixgbe_adapter *adapter, u32 eicr)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
+	u32 eicr_mask = IXGBE_EICR_GPI_SDP2(hw);
 
-	if (eicr & IXGBE_EICR_GPI_SDP2(hw)) {
+	if (!ixgbe_is_sfp(hw))
+		return;
+
+	/* Later MAC's use different SDP */
+	if (hw->mac.type >= ixgbe_mac_X540)
+		eicr_mask = IXGBE_EICR_GPI_SDP0_X540;
+
+	if (eicr & eicr_mask) {
 		/* Clear the interrupt */
-		IXGBE_WRITE_REG(hw, IXGBE_EICR, IXGBE_EICR_GPI_SDP2(hw));
+		IXGBE_WRITE_REG(hw, IXGBE_EICR, eicr_mask);
 		if (!test_bit(__IXGBE_DOWN, &adapter->state)) {
 			adapter->flags2 |= IXGBE_FLAG2_SFP_NEEDS_RESET;
 			ixgbe_service_event_schedule(adapter);
 		}
 	}
 
-	if (eicr & IXGBE_EICR_GPI_SDP1(hw)) {
+	if (adapter->hw.mac.type == ixgbe_mac_82599EB &&
+	    (eicr & IXGBE_EICR_GPI_SDP1(hw))) {
 		/* Clear the interrupt */
 		IXGBE_WRITE_REG(hw, IXGBE_EICR, IXGBE_EICR_GPI_SDP1(hw));
 		if (!test_bit(__IXGBE_DOWN, &adapter->state)) {
-- 
2.4.3
