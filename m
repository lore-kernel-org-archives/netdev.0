From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/17] i40e: Update error messaging
Date: Wed,  2 Dec 2015 00:25:27 -0800
Message-ID: <1449044735-68599-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449044735-68599-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:5698 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757564AbbLBIZl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Dec 2015 03:25:41 -0500
In-Reply-To: <1449044735-68599-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch fixes an issue where adminq init failures always provided
a message that NVM was newer than expected.  This is not always the
case for init_adminq failures. Without this patch, if adminq init
fails for any reason, newer NVM message would be given.  This
problem is fixed by adding  a check for that specific error
condition and a different hopefully helpful message otherwise.

Change-ID: Iaeaebee4e398989eae40bb70f943ab66a3a521a5
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 491c82f..508cf9a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -10471,6 +10471,16 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	pf->hw.fc.requested_mode = I40E_FC_NONE;
 
 	err = i40e_init_adminq(hw);
+	if (err) {
+		if (err == I40E_ERR_FIRMWARE_API_VERSION)
+			dev_info(&pdev->dev,
+				 "The driver for the device stopped because the NVM image is newer than expected. You must install the most recent version of the network driver.\n");
+		else
+			dev_info(&pdev->dev,
+				 "The driver for the device stopped because the device firmware failed to init. Try updating your NVM image.\n");
+
+		goto err_pf_reset;
+	}
 
 	/* provide nvm, fw, api versions */
 	dev_info(&pdev->dev, "fw %d.%d.%05d api %d.%d nvm %s\n",
@@ -10478,12 +10488,6 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		 hw->aq.api_maj_ver, hw->aq.api_min_ver,
 		 i40e_nvm_version_str(hw));
 
-	if (err) {
-		dev_info(&pdev->dev,
-			 "The driver for the device stopped because the NVM image is newer than expected. You must install the most recent version of the network driver.\n");
-		goto err_pf_reset;
-	}
-
 	if (hw->aq.api_maj_ver == I40E_FW_API_VERSION_MAJOR &&
 	    hw->aq.api_min_ver > I40E_FW_API_VERSION_MINOR)
 		dev_info(&pdev->dev,
-- 
2.5.0
