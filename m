From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/15] e1000e: Resolve issues with Management Engine (ME) briefly blocking PHY resets
Date: Sat,  8 Mar 2014 01:25:29 -0800
Message-ID: <1394270741-29926-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394270741-29926-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: David Ertman <davidx.m.ertman@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:23968 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751113AbaCHJZp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Mar 2014 04:25:45 -0500
In-Reply-To: <1394270741-29926-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ertman <davidx.m.ertman@intel.com>

On a ME enabled system with the cable out, the driver init flow would
generate an erroneous message indicating that resets were being blocked
by an active ME session.  Cause was ME clearing the semaphore bit to
block further PHY resets for up to 50 msec during power-on/cycle.  After
this interval, ME would re-set the bit and allow PHY resets.

To resolve this, change the flow of e1000e_phy_hw_reset_generic() to
utilize a delay and retry method.  Poll the FWSM register to minimize
any extra time added to the flow.  If the delay times out at 100ms
(checked in 10msec increments), then return the value E1000_BLK_PHY_RESET,
as this is the accurate state of the PHY.  Attempting to alter just the
call to e1000e_phy_hw_reset_generic() in e1000_init_phy_workarounds_pchlan()
just caused the problem to move further down the flow.

Signed-off-by: Dave Ertman <davidx.m.ertman@intel.com>
Acked-by: Bruce W. Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c | 30 +++++++++++++++++++++++++----
 1 file changed, 26 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 42f0f67..4f3da87 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -247,6 +247,7 @@ out:
  **/
 static s32 e1000_init_phy_workarounds_pchlan(struct e1000_hw *hw)
 {
+	struct e1000_adapter *adapter = hw->adapter;
 	u32 mac_reg, fwsm = er32(FWSM);
 	s32 ret_val;
 
@@ -349,12 +350,31 @@ static s32 e1000_init_phy_workarounds_pchlan(struct e1000_hw *hw)
 
 	hw->phy.ops.release(hw);
 	if (!ret_val) {
+
+		/* Check to see if able to reset PHY.  Print error if not */
+		if (hw->phy.ops.check_reset_block(hw)) {
+			e_err("Reset blocked by ME\n");
+			goto out;
+		}
+
 		/* Reset the PHY before any access to it.  Doing so, ensures
 		 * that the PHY is in a known good state before we read/write
 		 * PHY registers.  The generic reset is sufficient here,
 		 * because we haven't determined the PHY type yet.
 		 */
 		ret_val = e1000e_phy_hw_reset_generic(hw);
+		if (ret_val)
+			goto out;
+
+		/* On a successful reset, possibly need to wait for the PHY
+		 * to quiesce to an accessible state before returning control
+		 * to the calling function.  If the PHY does not quiesce, then
+		 * return E1000E_BLK_PHY_RESET, as this is the condition that
+		 *  the PHY is in.
+		 */
+		ret_val = hw->phy.ops.check_reset_block(hw);
+		if (ret_val)
+			e_err("ME blocked access to PHY after reset\n");
 	}
 
 out:
@@ -1484,11 +1504,13 @@ out:
  **/
 static s32 e1000_check_reset_block_ich8lan(struct e1000_hw *hw)
 {
-	u32 fwsm;
+	bool blocked = false;
+	int i = 0;
 
-	fwsm = er32(FWSM);
-
-	return (fwsm & E1000_ICH_FWSM_RSPCIPHY) ? 0 : E1000_BLK_PHY_RESET;
+	while ((blocked = !(er32(FWSM) & E1000_ICH_FWSM_RSPCIPHY)) &&
+	       (i++ < 10))
+		usleep_range(10000, 20000);
+	return blocked ? E1000_BLK_PHY_RESET : 0;
 }
 
 /**
-- 
1.8.3.1
