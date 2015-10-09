From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/16] i40evf: detect reset more reliably
Date: Thu,  8 Oct 2015 18:32:49 -0700
Message-ID: <1444354374-24351-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444354374-24351-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:47722 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755545AbbJIBdA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 21:33:00 -0400
In-Reply-To: <1444354374-24351-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Using VFGEN_RSTAT to detect a VF reset is an endeavor that is fraught
with peril. It's entirely too easy to miss a reset because none of the
bits are sticky. By the time the VF driver reads the register, the reset
may have been processed and cleaned up by the PF driver, leaving the
register in the same state that it was before the reset.

Instead, detect a reset with the VF_ARQLEN register. When the VF is
reset, the enable bit in this register is cleared, and it stays cleared
until the VF driver processes the reset and re-enables the admin queue.

Because we now deal with multiple registers in the reset and watchdog
tasks, rename the rstat_val variable to reg_val.

Change-ID: Id1df17045c0992e607da0162d31807f7fc20d199
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 36 +++++++++++--------------
 1 file changed, 16 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 0d18446..664fde6 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1419,16 +1419,16 @@ static void i40evf_watchdog_task(struct work_struct *work)
 						      struct i40evf_adapter,
 						      watchdog_task);
 	struct i40e_hw *hw = &adapter->hw;
-	uint32_t rstat_val;
+	u32 reg_val;
 
 	if (test_and_set_bit(__I40EVF_IN_CRITICAL_TASK, &adapter->crit_section))
 		goto restart_watchdog;
 
 	if (adapter->flags & I40EVF_FLAG_PF_COMMS_FAILED) {
-		rstat_val = rd32(hw, I40E_VFGEN_RSTAT) &
-			    I40E_VFGEN_RSTAT_VFR_STATE_MASK;
-		if ((rstat_val == I40E_VFR_VFACTIVE) ||
-		    (rstat_val == I40E_VFR_COMPLETED)) {
+		reg_val = rd32(hw, I40E_VFGEN_RSTAT) &
+			  I40E_VFGEN_RSTAT_VFR_STATE_MASK;
+		if ((reg_val == I40E_VFR_VFACTIVE) ||
+		    (reg_val == I40E_VFR_COMPLETED)) {
 			/* A chance for redemption! */
 			dev_err(&adapter->pdev->dev, "Hardware came out of reset. Attempting reinit.\n");
 			adapter->state = __I40EVF_STARTUP;
@@ -1453,11 +1453,8 @@ static void i40evf_watchdog_task(struct work_struct *work)
 		goto watchdog_done;
 
 	/* check for reset */
-	rstat_val = rd32(hw, I40E_VFGEN_RSTAT) &
-		    I40E_VFGEN_RSTAT_VFR_STATE_MASK;
-	if (!(adapter->flags & I40EVF_FLAG_RESET_PENDING) &&
-	    (rstat_val != I40E_VFR_VFACTIVE) &&
-	    (rstat_val != I40E_VFR_COMPLETED)) {
+	reg_val = rd32(hw, I40E_VF_ARQLEN1) & I40E_VF_ARQLEN1_ARQENABLE_MASK;
+	if (!(adapter->flags & I40EVF_FLAG_RESET_PENDING) && !reg_val) {
 		adapter->state = __I40EVF_RESETTING;
 		adapter->flags |= I40EVF_FLAG_RESET_PENDING;
 		dev_err(&adapter->pdev->dev, "Hardware reset detected\n");
@@ -1572,7 +1569,7 @@ static void i40evf_reset_task(struct work_struct *work)
 	struct net_device *netdev = adapter->netdev;
 	struct i40e_hw *hw = &adapter->hw;
 	struct i40evf_mac_filter *f;
-	uint32_t rstat_val;
+	u32 reg_val;
 	int i = 0, err;
 
 	while (test_and_set_bit(__I40EVF_IN_CRITICAL_TASK,
@@ -1593,12 +1590,11 @@ static void i40evf_reset_task(struct work_struct *work)
 
 	/* poll until we see the reset actually happen */
 	for (i = 0; i < I40EVF_RESET_WAIT_COUNT; i++) {
-		rstat_val = rd32(hw, I40E_VFGEN_RSTAT) &
-			    I40E_VFGEN_RSTAT_VFR_STATE_MASK;
-		if ((rstat_val != I40E_VFR_VFACTIVE) &&
-		    (rstat_val != I40E_VFR_COMPLETED))
+		reg_val = rd32(hw, I40E_VF_ARQLEN1) &
+			  I40E_VF_ARQLEN1_ARQENABLE_MASK;
+		if (!reg_val)
 			break;
-		usleep_range(500, 1000);
+		usleep_range(5000, 10000);
 	}
 	if (i == I40EVF_RESET_WAIT_COUNT) {
 		dev_info(&adapter->pdev->dev, "Never saw reset\n");
@@ -1607,9 +1603,9 @@ static void i40evf_reset_task(struct work_struct *work)
 
 	/* wait until the reset is complete and the PF is responding to us */
 	for (i = 0; i < I40EVF_RESET_WAIT_COUNT; i++) {
-		rstat_val = rd32(hw, I40E_VFGEN_RSTAT) &
-			    I40E_VFGEN_RSTAT_VFR_STATE_MASK;
-		if (rstat_val == I40E_VFR_VFACTIVE)
+		reg_val = rd32(hw, I40E_VFGEN_RSTAT) &
+			  I40E_VFGEN_RSTAT_VFR_STATE_MASK;
+		if (reg_val == I40E_VFR_VFACTIVE)
 			break;
 		msleep(I40EVF_RESET_WAIT_MS);
 	}
@@ -1621,7 +1617,7 @@ static void i40evf_reset_task(struct work_struct *work)
 
 		/* reset never finished */
 		dev_err(&adapter->pdev->dev, "Reset never finished (%x)\n",
-			rstat_val);
+			reg_val);
 		adapter->flags |= I40EVF_FLAG_PF_COMMS_FAILED;
 
 		if (netif_running(adapter->netdev)) {
-- 
2.4.3
