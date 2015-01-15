From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/17] i40e: don't give up on DCB error after reset
Date: Thu, 15 Jan 2015 04:19:15 -0800
Message-ID: <1421324368-6860-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1421324368-6860-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:64854 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753000AbbAOMTd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2015 07:19:33 -0500
In-Reply-To: <1421324368-6860-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

We don't need to give up in the reset/rebuild process if the DCB setup failed,
so handle it here the same as in the probe setup.  Also adjust the log strings
a little to look less scary.

Change-ID: I57308d703047e61d3f1a5e471ea77be232444ca0
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index cd34d9b..fd6411e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4533,7 +4533,8 @@ static int i40e_init_pf_dcb(struct i40e_pf *pf)
 				"DCBX offload is supported for this PF.\n");
 		}
 	} else {
-		dev_info(&pf->pdev->dev, "AQ Querying DCB configuration failed: %d\n",
+		dev_info(&pf->pdev->dev,
+			 "AQ Querying DCB configuration failed: aq_err %d\n",
 			 pf->hw.aq.asq_last_status);
 	}
 
@@ -6188,8 +6189,9 @@ static void i40e_reset_and_rebuild(struct i40e_pf *pf, bool reinit)
 #ifdef CONFIG_I40E_DCB
 	ret = i40e_init_pf_dcb(pf);
 	if (ret) {
-		dev_info(&pf->pdev->dev, "init_pf_dcb failed: %d\n", ret);
-		goto end_core_reset;
+		dev_info(&pf->pdev->dev, "DCB init failed %d, disabled\n", ret);
+		pf->flags &= ~I40E_FLAG_DCB_CAPABLE;
+		/* Continue without DCB enabled */
 	}
 #endif /* CONFIG_I40E_DCB */
 #ifdef I40E_FCOE
@@ -9269,7 +9271,7 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 #ifdef CONFIG_I40E_DCB
 	err = i40e_init_pf_dcb(pf);
 	if (err) {
-		dev_info(&pdev->dev, "init_pf_dcb failed: %d\n", err);
+		dev_info(&pdev->dev, "DCB init failed %d, disabled\n", err);
 		pf->flags &= ~I40E_FLAG_DCB_CAPABLE;
 		/* Continue without DCB enabled */
 	}
-- 
1.9.3
