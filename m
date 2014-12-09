From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/13] i40e: poll on NVM semaphore only if not other error
Date: Tue,  9 Dec 2014 03:22:47 -0800
Message-ID: <1418124170-7495-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1418124170-7495-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:43353 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756701AbaLILXB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2014 06:23:01 -0500
In-Reply-To: <1418124170-7495-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Only poll on the NVM semaphore if there's time left on a previous
reservation.  Also, add a little more info to debug messages.

Change-ID: I2439bf870b95a28b810dcb5cca1c06440463cf8a
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_nvm.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_nvm.c b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
index f3d1c85..0fc62fc 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_nvm.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
@@ -93,10 +93,15 @@ i40e_status i40e_acquire_nvm(struct i40e_hw *hw,
 	/* Store the timeout */
 	hw->nvm.hw_semaphore_timeout = I40E_MS_TO_GTIME(time_left) + gtime;
 
-	if (ret_code) {
+	if (ret_code)
+		i40e_debug(hw, I40E_DEBUG_NVM,
+			   "NVM acquire type %d failed time_left=%llu ret=%d aq_err=%d\n",
+			   access, time_left, ret_code, hw->aq.asq_last_status);
+
+	if (ret_code && time_left) {
 		/* Poll until the current NVM owner timeouts */
 		timeout = I40E_MS_TO_GTIME(I40E_MAX_NVM_TIMEOUT) + gtime;
-		while (gtime < timeout) {
+		while ((gtime < timeout) && time_left) {
 			usleep_range(10000, 20000);
 			gtime = rd32(hw, I40E_GLVFGEN_TIMER);
 			ret_code = i40e_aq_request_resource(hw,
@@ -112,8 +117,8 @@ i40e_status i40e_acquire_nvm(struct i40e_hw *hw,
 		if (ret_code) {
 			hw->nvm.hw_semaphore_timeout = 0;
 			i40e_debug(hw, I40E_DEBUG_NVM,
-				   "NVM acquire timed out, wait %llu ms before trying again.\n",
-				   time_left);
+				   "NVM acquire timed out, wait %llu ms before trying again. status=%d aq_err=%d\n",
+				   time_left, ret_code, hw->aq.asq_last_status);
 		}
 	}
 
-- 
1.9.3
