From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 10/14] i40evf: future-proof vfr_stat state check
Date: Fri,  1 Aug 2014 13:27:11 -0700
Message-ID: <1406924835-31550-11-git-send-email-aaron.f.brown@intel.com>
References: <1406924835-31550-1-git-send-email-aaron.f.brown@intel.com>
Cc: Ashish Shah <ashish.n.shah@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:49261 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755270AbaHAUXa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Aug 2014 16:23:30 -0400
In-Reply-To: <1406924835-31550-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ashish Shah <ashish.n.shah@intel.com>

Previously defined state I40E_VFR_VFACTIVE uses bit 1 which is now set to
"reserved."  Update the state checks to also include I40E_VFR_COMPLETED.
This change will allow the VF to work with both existing and future PFs.

Change-ID: Ifd1d34f79f3b0ffd6d2550ee4dadc55825ff52f8
Signed-off-by: Ashish Shah <ashish.n.shah@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 23 +++++++++++++++++------
 1 file changed, 17 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 937785d..4c01079 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1298,12 +1298,16 @@ static void i40evf_watchdog_task(struct work_struct *work)
 					  struct i40evf_adapter,
 					  watchdog_task);
 	struct i40e_hw *hw = &adapter->hw;
+	uint32_t rstat_val;
 
 	if (test_and_set_bit(__I40EVF_IN_CRITICAL_TASK, &adapter->crit_section))
 		goto restart_watchdog;
 
 	if (adapter->flags & I40EVF_FLAG_PF_COMMS_FAILED) {
-		if ((rd32(hw, I40E_VFGEN_RSTAT) & 0x3) == I40E_VFR_VFACTIVE) {
+		rstat_val = rd32(hw, I40E_VFGEN_RSTAT) &
+			    I40E_VFGEN_RSTAT_VFR_STATE_MASK;
+		if ((rstat_val == I40E_VFR_VFACTIVE) ||
+		    (rstat_val == I40E_VFR_COMPLETED)) {
 			/* A chance for redemption! */
 			dev_err(&adapter->pdev->dev, "Hardware came out of reset. Attempting reinit.\n");
 			adapter->state = __I40EVF_STARTUP;
@@ -1329,8 +1333,11 @@ static void i40evf_watchdog_task(struct work_struct *work)
 		goto watchdog_done;
 
 	/* check for reset */
+	rstat_val = rd32(hw, I40E_VFGEN_RSTAT) &
+			    I40E_VFGEN_RSTAT_VFR_STATE_MASK;
 	if (!(adapter->flags & I40EVF_FLAG_RESET_PENDING) &&
-	    (rd32(hw, I40E_VFGEN_RSTAT) & 0x3) != I40E_VFR_VFACTIVE) {
+	    (rstat_val != I40E_VFR_VFACTIVE) &&
+	    (rstat_val != I40E_VFR_COMPLETED)) {
 		adapter->state = __I40EVF_RESETTING;
 		adapter->flags |= I40EVF_FLAG_RESET_PENDING;
 		dev_err(&adapter->pdev->dev, "Hardware reset detected\n");
@@ -1496,7 +1503,8 @@ static void i40evf_reset_task(struct work_struct *work)
 	for (i = 0; i < I40EVF_RESET_WAIT_COUNT; i++) {
 		rstat_val = rd32(hw, I40E_VFGEN_RSTAT) &
 			    I40E_VFGEN_RSTAT_VFR_STATE_MASK;
-		if (rstat_val != I40E_VFR_VFACTIVE)
+		if ((rstat_val != I40E_VFR_VFACTIVE) &&
+		    (rstat_val != I40E_VFR_COMPLETED))
 			break;
 		else
 			msleep(I40EVF_RESET_WAIT_MS);
@@ -1510,7 +1518,8 @@ static void i40evf_reset_task(struct work_struct *work)
 	for (i = 0; i < I40EVF_RESET_WAIT_COUNT; i++) {
 		rstat_val = rd32(hw, I40E_VFGEN_RSTAT) &
 			    I40E_VFGEN_RSTAT_VFR_STATE_MASK;
-		if (rstat_val == I40E_VFR_VFACTIVE)
+		if ((rstat_val == I40E_VFR_VFACTIVE) ||
+		    (rstat_val == I40E_VFR_COMPLETED))
 			break;
 		else
 			msleep(I40EVF_RESET_WAIT_MS);
@@ -1947,8 +1956,10 @@ static int i40evf_check_reset_complete(struct i40e_hw *hw)
 	int i;
 
 	for (i = 0; i < 100; i++) {
-		rstat = rd32(hw, I40E_VFGEN_RSTAT);
-		if (rstat == I40E_VFR_VFACTIVE)
+		rstat = rd32(hw, I40E_VFGEN_RSTAT) &
+			    I40E_VFGEN_RSTAT_VFR_STATE_MASK;
+		if ((rstat == I40E_VFR_VFACTIVE) ||
+		    (rstat == I40E_VFR_COMPLETED))
 			return 0;
 		udelay(10);
 	}
-- 
1.9.3
