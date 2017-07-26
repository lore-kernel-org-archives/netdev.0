From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/14] i40e: Handle admin Q timeout when releasing NVM
Date: Wed, 26 Jul 2017 03:31:13 -0700
Message-ID: <20170726103123.76743-5-jeffrey.t.kirsher@intel.com>
References: <20170726103123.76743-1-jeffrey.t.kirsher@intel.com>
Cc: Paul M Stillwell Jr <paul.m.stillwell.jr@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:8268 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751599AbdGZKdL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Jul 2017 06:33:11 -0400
In-Reply-To: <20170726103123.76743-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul M Stillwell Jr <paul.m.stillwell.jr@intel.com>

There are some rare cases where the release resource call will return an
admin Q timeout. In these cases the code needs to try to release the
resource again until it succeeds or it times out.

Signed-off-by: Paul M Stillwell Jr <paul.m.stillwell.jr@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_nvm.c | 21 +++++++++++++++++++--
 1 file changed, 19 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_nvm.c b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
index 800bd55d0159..17607a2c0a65 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_nvm.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
@@ -134,8 +134,25 @@ i40e_status i40e_acquire_nvm(struct i40e_hw *hw,
  **/
 void i40e_release_nvm(struct i40e_hw *hw)
 {
-	if (!hw->nvm.blank_nvm_mode)
-		i40e_aq_release_resource(hw, I40E_NVM_RESOURCE_ID, 0, NULL);
+	i40e_status ret_code = I40E_SUCCESS;
+	u32 total_delay = 0;
+
+	if (hw->nvm.blank_nvm_mode)
+		return;
+
+	ret_code = i40e_aq_release_resource(hw, I40E_NVM_RESOURCE_ID, 0, NULL);
+
+	/* there are some rare cases when trying to release the resource
+	 * results in an admin Q timeout, so handle them correctly
+	 */
+	while ((ret_code == I40E_ERR_ADMIN_QUEUE_TIMEOUT) &&
+	       (total_delay < hw->aq.asq_cmd_timeout)) {
+		usleep_range(1000, 2000);
+		ret_code = i40e_aq_release_resource(hw,
+						    I40E_NVM_RESOURCE_ID,
+						    0, NULL);
+		total_delay++;
+	}
 }
 
 /**
-- 
2.13.3
