From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 08/13] i40e: set max limit for access polling
Date: Tue,  9 Dec 2014 13:26:15 -0800
Message-ID: <1418160380-29847-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1418160380-29847-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:31176 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753113AbaLIV02 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2014 16:26:28 -0500
In-Reply-To: <1418160380-29847-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Don't bother trying to set a smaller timeout on the polling,
just simplify the code and always use the max limit.  Also,
rename a variable for clarity and fix a comment.

Change-ID: I0300c3562ccc4fd5fa3088f8ae52db0c1eb33af5
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Acked-by: Michal Kosiarz <michal.kosiarz@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_nvm.c    | 21 ++++++++-------------
 drivers/net/ethernet/intel/i40e/i40e_type.h   |  2 +-
 drivers/net/ethernet/intel/i40evf/i40e_type.h |  2 +-
 3 files changed, 10 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_nvm.c b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
index 37f0f5f..f55e52b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_nvm.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
@@ -80,45 +80,40 @@ i40e_status i40e_acquire_nvm(struct i40e_hw *hw,
 {
 	i40e_status ret_code = 0;
 	u64 gtime, timeout;
-	u64 time = 0;
+	u64 time_left = 0;
 
 	if (hw->nvm.blank_nvm_mode)
 		goto i40e_i40e_acquire_nvm_exit;
 
 	ret_code = i40e_aq_request_resource(hw, I40E_NVM_RESOURCE_ID, access,
-					    0, &time, NULL);
+					    0, &time_left, NULL);
 	/* Reading the Global Device Timer */
 	gtime = rd32(hw, I40E_GLVFGEN_TIMER);
 
 	/* Store the timeout */
-	hw->nvm.hw_semaphore_timeout = I40E_MS_TO_GTIME(time) + gtime;
+	hw->nvm.hw_semaphore_timeout = I40E_MS_TO_GTIME(time_left) + gtime;
 
 	if (ret_code) {
-		/* Set the polling timeout */
-		if (time > I40E_MAX_NVM_TIMEOUT)
-			timeout = I40E_MS_TO_GTIME(I40E_MAX_NVM_TIMEOUT)
-				  + gtime;
-		else
-			timeout = hw->nvm.hw_semaphore_timeout;
 		/* Poll until the current NVM owner timeouts */
+		timeout = I40E_MS_TO_GTIME(I40E_MAX_NVM_TIMEOUT) + gtime;
 		while (gtime < timeout) {
 			usleep_range(10000, 20000);
+			gtime = rd32(hw, I40E_GLVFGEN_TIMER);
 			ret_code = i40e_aq_request_resource(hw,
 							I40E_NVM_RESOURCE_ID,
-							access, 0, &time,
+							access, 0, &time_left,
 							NULL);
 			if (!ret_code) {
 				hw->nvm.hw_semaphore_timeout =
-						I40E_MS_TO_GTIME(time) + gtime;
+					    I40E_MS_TO_GTIME(time_left) + gtime;
 				break;
 			}
-			gtime = rd32(hw, I40E_GLVFGEN_TIMER);
 		}
 		if (ret_code) {
 			hw->nvm.hw_semaphore_timeout = 0;
 			i40e_debug(hw, I40E_DEBUG_NVM,
 				   "NVM acquire timed out, wait %llu ms before trying again.\n",
-				   time);
+				   time_left);
 		}
 	}
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index 306a23a..844421f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -261,7 +261,7 @@ enum i40e_aq_resource_access_type {
 };
 
 struct i40e_nvm_info {
-	u64 hw_semaphore_timeout; /* 2usec global time (GTIME resolution) */
+	u64 hw_semaphore_timeout; /* usec global time (GTIME resolution) */
 	u32 timeout;              /* [ms] */
 	u16 sr_size;              /* Shadow RAM size in words */
 	bool blank_nvm_mode;      /* is NVM empty (no FW present)*/
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index 9d472d6..d8175cd 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -260,7 +260,7 @@ enum i40e_aq_resource_access_type {
 };
 
 struct i40e_nvm_info {
-	u64 hw_semaphore_timeout; /* 2usec global time (GTIME resolution) */
+	u64 hw_semaphore_timeout; /* usec global time (GTIME resolution) */
 	u32 timeout;              /* [ms] */
 	u16 sr_size;              /* Shadow RAM size in words */
 	bool blank_nvm_mode;      /* is NVM empty (no FW present)*/
-- 
1.9.3
