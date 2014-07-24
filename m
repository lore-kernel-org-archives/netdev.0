From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/14] i40e: Fix firmware API version errors
Date: Thu, 24 Jul 2014 06:13:22 -0700
Message-ID: <1406207604-31653-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1406207604-31653-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:36520 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759241AbaGXNOH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2014 09:14:07 -0400
In-Reply-To: <1406207604-31653-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

Reword the error messages. Also add a major version check because
We only want to warn on nvm_minor > expected_minor if
nvm_major == expected_major. Lastly, change an if to an else if
because the two statements will never evaluate to true at the same time.

Change-ID: I6ddf9986f26b35f6879cbeac4fcef04a8497a383
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 20 +++++++-------------
 1 file changed, 7 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index c34e390..821fcc1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8642,24 +8642,18 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev_info(&pdev->dev, "%s\n", i40e_fw_version_str(hw));
 	if (err) {
 		dev_info(&pdev->dev,
-			 "init_adminq failed: %d expecting API %02x.%02x\n",
-			 err,
-			 I40E_FW_API_VERSION_MAJOR, I40E_FW_API_VERSION_MINOR);
+			 "The driver for the device stopped because the NVM image is newer than expected. You must install the most recent version of the network driver.\n");
 		goto err_pf_reset;
 	}
 
-	if (hw->aq.api_min_ver > I40E_FW_API_VERSION_MINOR)
+	if (hw->aq.api_maj_ver == I40E_FW_API_VERSION_MAJOR &&
+	    hw->aq.api_min_ver > I40E_FW_API_VERSION_MINOR)
 		dev_info(&pdev->dev,
-			 "Note: FW API version %02x.%02x newer than expected %02x.%02x, recommend driver update.\n",
-			 hw->aq.api_maj_ver, hw->aq.api_min_ver,
-			 I40E_FW_API_VERSION_MAJOR, I40E_FW_API_VERSION_MINOR);
-
-	if (hw->aq.api_maj_ver < I40E_FW_API_VERSION_MAJOR ||
-	    hw->aq.api_min_ver < (I40E_FW_API_VERSION_MINOR-1))
+			 "The driver for the device detected a newer version of the NVM image than expected. Please install the most recent version of the network driver.\n");
+	else if (hw->aq.api_maj_ver < I40E_FW_API_VERSION_MAJOR ||
+		 hw->aq.api_min_ver < (I40E_FW_API_VERSION_MINOR - 1))
 		dev_info(&pdev->dev,
-			 "Note: FW API version %02x.%02x older than expected %02x.%02x, recommend nvm update.\n",
-			 hw->aq.api_maj_ver, hw->aq.api_min_ver,
-			 I40E_FW_API_VERSION_MAJOR, I40E_FW_API_VERSION_MINOR);
+			 "The driver for the device detected an older version of the NVM image than expected. Please update the NVM image.\n");
 
 
 	i40e_verify_eeprom(pf);
-- 
1.9.3
