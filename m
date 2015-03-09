From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/9] i40e: tame the nvmupdate read and write complaints
Date: Mon,  9 Mar 2015 10:55:38 -0700
Message-ID: <1425923742-4488-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425923742-4488-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:49812 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752192AbbCIRzq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Mar 2015 13:55:46 -0400
In-Reply-To: <1425923742-4488-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

The NVMUpdate tool doesn't necessarily know the ReadOnly map of the current
NVM image, and must try reading and writing words that may be protected.
This generates an error out of the Firmware request that the driver logs.
Unfortunately, this ends up spitting out hundreds of bogus read and write
error message that looks rather messy.

This patch checks the error type and under normal conditions will not print
the typical read and write errors during NVMUpdate.  This can be overridden
by enabling the NVM update debugging.  This results in a much less messy log
file, and likely many fewer customer support questions.

Change-ID: Id4ff2e9048c523b0ff503aa5ab181b025ec948ea
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 01c811c..9ff3dc1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -917,7 +917,9 @@ static int i40e_get_eeprom(struct net_device *netdev,
 
 		cmd = (struct i40e_nvm_access *)eeprom;
 		ret_val = i40e_nvmupd_command(hw, cmd, bytes, &errno);
-		if (ret_val)
+		if (ret_val &&
+		    ((hw->aq.asq_last_status != I40E_AQ_RC_EACCES) ||
+		     (hw->debug_mask & I40E_DEBUG_NVM)))
 			dev_info(&pf->pdev->dev,
 				 "NVMUpdate read failed err=%d status=0x%x errno=%d module=%d offset=0x%x size=%d\n",
 				 ret_val, hw->aq.asq_last_status, errno,
@@ -1021,7 +1023,10 @@ static int i40e_set_eeprom(struct net_device *netdev,
 
 	cmd = (struct i40e_nvm_access *)eeprom;
 	ret_val = i40e_nvmupd_command(hw, cmd, bytes, &errno);
-	if (ret_val && hw->aq.asq_last_status != I40E_AQ_RC_EBUSY)
+	if (ret_val &&
+	    ((hw->aq.asq_last_status != I40E_AQ_RC_EPERM &&
+	      hw->aq.asq_last_status != I40E_AQ_RC_EBUSY) ||
+	     (hw->debug_mask & I40E_DEBUG_NVM)))
 		dev_info(&pf->pdev->dev,
 			 "NVMUpdate write failed err=%d status=0x%x errno=%d module=%d offset=0x%x size=%d\n",
 			 ret_val, hw->aq.asq_last_status, errno,
-- 
1.9.3
