From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/15] i40e: Fix an issue when PF reset fails
Date: Fri, 29 Aug 2014 02:30:12 -0700
Message-ID: <1409304620-23251-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1409304620-23251-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:53242 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751454AbaH2Ja0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Aug 2014 05:30:26 -0400
In-Reply-To: <1409304620-23251-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

We shouldn't restart Admin queue subtask if PF reset fails since we do
not have the AQ setup at that point. This patch makes sure we disable AQ
clean subtask when PF reset fails.

This will resolve an occasional kernel panic when PF reset fails for
some reason.

Change-ID: I11a747773362a8c5c0ad7a10cd34be0bda8eb9e8
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      |  1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c | 13 ++++++++++---
 2 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 4e97ba1..f1e33f8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -145,6 +145,7 @@ enum i40e_state_t {
 	__I40E_BAD_EEPROM,
 	__I40E_DOWN_REQUESTED,
 	__I40E_FD_FLUSH_REQUESTED,
+	__I40E_RESET_FAILED,
 };
 
 enum i40e_interrupt_policy {
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 55a31ab..64b8683 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5568,6 +5568,10 @@ static void i40e_clean_adminq_subtask(struct i40e_pf *pf)
 	u32 oldval;
 	u32 val;
 
+	/* Do not run clean AQ when PF reset fails */
+	if (test_bit(__I40E_RESET_FAILED, &pf->state))
+		return;
+
 	/* check for error indications */
 	val = rd32(&pf->hw, pf->hw.aq.arq.len);
 	oldval = val;
@@ -5973,19 +5977,20 @@ static void i40e_reset_and_rebuild(struct i40e_pf *pf, bool reinit)
 	ret = i40e_pf_reset(hw);
 	if (ret) {
 		dev_info(&pf->pdev->dev, "PF reset failed, %d\n", ret);
-		goto end_core_reset;
+		set_bit(__I40E_RESET_FAILED, &pf->state);
+		goto clear_recovery;
 	}
 	pf->pfr_count++;
 
 	if (test_bit(__I40E_DOWN, &pf->state))
-		goto end_core_reset;
+		goto clear_recovery;
 	dev_dbg(&pf->pdev->dev, "Rebuilding internal switch\n");
 
 	/* rebuild the basics for the AdminQ, HMC, and initial HW switch */
 	ret = i40e_init_adminq(&pf->hw);
 	if (ret) {
 		dev_info(&pf->pdev->dev, "Rebuild AdminQ failed, %d\n", ret);
-		goto end_core_reset;
+		goto clear_recovery;
 	}
 
 	/* re-verify the eeprom if we just had an EMP reset */
@@ -6103,6 +6108,8 @@ static void i40e_reset_and_rebuild(struct i40e_pf *pf, bool reinit)
 	i40e_send_version(pf);
 
 end_core_reset:
+	clear_bit(__I40E_RESET_FAILED, &pf->state);
+clear_recovery:
 	clear_bit(__I40E_RESET_RECOVERY_PENDING, &pf->state);
 }
 
-- 
1.9.3
