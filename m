From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/18] i40e: Add FW check to disable DCB and wrap autoneg workaround with FW check
Date: Sat, 28 Feb 2015 03:29:41 -0800
Message-ID: <1425122989-354-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425122989-354-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:49619 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751352AbbB1L36 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Feb 2015 06:29:58 -0500
In-Reply-To: <1425122989-354-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

For FW < 4.33 DCB should be disabled.
Also Autoneg workaround to avoid Rx stall is still needed for FW < 4.33.

Change-ID: Iff36ad86be2f597e7701096014d6d094332a9a21
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 31 ++++++++++++++++++-----------
 1 file changed, 19 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 7509048..3a476956 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4577,6 +4577,11 @@ static int i40e_init_pf_dcb(struct i40e_pf *pf)
 	struct i40e_hw *hw = &pf->hw;
 	int err = 0;
 
+	/* Do not enable DCB for SW1 and SW2 images even if the FW is capable */
+	if (((pf->hw.aq.fw_maj_ver == 4) && (pf->hw.aq.fw_min_ver < 33)) ||
+	    (pf->hw.aq.fw_maj_ver < 4))
+		goto out;
+
 	/* Get the initial DCB configuration */
 	err = i40e_init_dcb(hw);
 	if (!err) {
@@ -6337,13 +6342,14 @@ static void i40e_reset_and_rebuild(struct i40e_pf *pf, bool reinit)
 		}
 	}
 
-	msleep(75);
-	ret = i40e_aq_set_link_restart_an(&pf->hw, true, NULL);
-	if (ret) {
-		dev_info(&pf->pdev->dev, "link restart failed, aq_err=%d\n",
-			 pf->hw.aq.asq_last_status);
+	if (((pf->hw.aq.fw_maj_ver == 4) && (pf->hw.aq.fw_min_ver < 33)) ||
+	    (pf->hw.aq.fw_maj_ver < 4)) {
+		msleep(75);
+		ret = i40e_aq_set_link_restart_an(&pf->hw, true, NULL);
+		if (ret)
+			dev_info(&pf->pdev->dev, "link restart failed, aq_err=%d\n",
+				 pf->hw.aq.asq_last_status);
 	}
-
 	/* reinit the misc interrupt */
 	if (pf->flags & I40E_FLAG_MSIX_ENABLED)
 		ret = i40e_setup_misc_vector(pf);
@@ -9703,13 +9709,14 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (err)
 		dev_info(&pf->pdev->dev, "set phy mask fail, aq_err %d\n", err);
 
-	msleep(75);
-	err = i40e_aq_set_link_restart_an(&pf->hw, true, NULL);
-	if (err) {
-		dev_info(&pf->pdev->dev, "link restart failed, aq_err=%d\n",
-			 pf->hw.aq.asq_last_status);
+	if (((pf->hw.aq.fw_maj_ver == 4) && (pf->hw.aq.fw_min_ver < 33)) ||
+	    (pf->hw.aq.fw_maj_ver < 4)) {
+		msleep(75);
+		err = i40e_aq_set_link_restart_an(&pf->hw, true, NULL);
+		if (err)
+			dev_info(&pf->pdev->dev, "link restart failed, aq_err=%d\n",
+				 pf->hw.aq.asq_last_status);
 	}
-
 	/* The main driver is (mostly) up and happy. We need to set this state
 	 * before setting up the misc vector or we get a race and the vector
 	 * ends up disabled forever.
-- 
1.9.3
