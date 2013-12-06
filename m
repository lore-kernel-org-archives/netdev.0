From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/15] i40e: retry call on timeout
Date: Fri,  6 Dec 2013 00:06:21 -0800
Message-ID: <1386317188-13944-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1386317188-13944-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:42213 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752945Ab3LFIGg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 03:06:36 -0500
In-Reply-To: <1386317188-13944-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

If the admin queue times out, retry some more to make driver load and
reset more robust.

Change-Id: I45c977b3d10a62c770d6072659ec27834849ca33
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq.c | 26 ++++++++++++++++++++------
 1 file changed, 20 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.c b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
index 92c01ad..30f32f3 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
@@ -535,8 +535,9 @@ static i40e_status i40e_shutdown_arq(struct i40e_hw *hw)
  **/
 i40e_status i40e_init_adminq(struct i40e_hw *hw)
 {
-	u16 eetrack_lo, eetrack_hi;
 	i40e_status ret_code;
+	u16 eetrack_lo, eetrack_hi;
+	int retry = 0;
 
 	/* verify input for valid configuration */
 	if ((hw->aq.num_arq_entries == 0) ||
@@ -564,11 +565,24 @@ i40e_status i40e_init_adminq(struct i40e_hw *hw)
 	if (ret_code)
 		goto init_adminq_free_asq;
 
-	ret_code = i40e_aq_get_firmware_version(hw,
-				     &hw->aq.fw_maj_ver, &hw->aq.fw_min_ver,
-				     &hw->aq.api_maj_ver, &hw->aq.api_min_ver,
-				     NULL);
-	if (ret_code)
+	/* There are some cases where the firmware may not be quite ready
+	 * for AdminQ operations, so we retry the AdminQ setup a few times
+	 * if we see timeouts in this first AQ call.
+	 */
+	do {
+		ret_code = i40e_aq_get_firmware_version(hw,
+							&hw->aq.fw_maj_ver,
+							&hw->aq.fw_min_ver,
+							&hw->aq.api_maj_ver,
+							&hw->aq.api_min_ver,
+							NULL);
+		if (ret_code != I40E_ERR_ADMIN_QUEUE_TIMEOUT)
+			break;
+		retry++;
+		msleep(100);
+		i40e_resume_aq(hw);
+	} while (retry < 10);
+	if (ret_code != I40E_SUCCESS)
 		goto init_adminq_free_arq;
 
 	if (hw->aq.api_maj_ver != I40E_FW_API_VERSION_MAJOR ||
-- 
1.8.3.1
