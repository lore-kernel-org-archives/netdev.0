From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/9] i40e: Fix a bug where Rx would stop after some time
Date: Thu, 23 Oct 2014 21:10:02 -0700
Message-ID: <1414123806-20049-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1414123806-20049-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:39968 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751437AbaJXEKR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Oct 2014 00:10:17 -0400
In-Reply-To: <1414123806-20049-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

Move the setting of flow control because this should be done at a pf level not
a vsi level. Also add a sleep and restart an to fix a bug where Rx would stop
after some stress.

Change-ID: I9a93d8c2ff27c39339eb00bc4ec1225e43900be0
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 24 ++++++++++++++++++++----
 1 file changed, 20 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index f7464e8..ff6d94d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4479,12 +4479,8 @@ static void i40e_print_link_message(struct i40e_vsi *vsi, bool isup)
 static int i40e_up_complete(struct i40e_vsi *vsi)
 {
 	struct i40e_pf *pf = vsi->back;
-	u8 set_fc_aq_fail = 0;
 	int err;
 
-	/* force flow control off */
-	i40e_set_fc(&pf->hw, &set_fc_aq_fail, true);
-
 	if (pf->flags & I40E_FLAG_MSIX_ENABLED)
 		i40e_vsi_configure_msix(vsi);
 	else
@@ -5958,6 +5954,7 @@ static void i40e_send_version(struct i40e_pf *pf)
 static void i40e_reset_and_rebuild(struct i40e_pf *pf, bool reinit)
 {
 	struct i40e_hw *hw = &pf->hw;
+	u8 set_fc_aq_fail = 0;
 	i40e_status ret;
 	u32 v;
 
@@ -6038,6 +6035,11 @@ static void i40e_reset_and_rebuild(struct i40e_pf *pf, bool reinit)
 	if (ret)
 		dev_info(&pf->pdev->dev, "set phy mask fail, aq_err %d\n", ret);
 
+	/* make sure our flow control settings are restored */
+	ret = i40e_set_fc(&pf->hw, &set_fc_aq_fail, true);
+	if (ret)
+		dev_info(&pf->pdev->dev, "set fc fail, aq_err %d\n", ret);
+
 	/* Rebuild the VSIs and VEBs that existed before reset.
 	 * They are still in our local switch element arrays, so only
 	 * need to rebuild the switch model in the HW.
@@ -6092,6 +6094,13 @@ static void i40e_reset_and_rebuild(struct i40e_pf *pf, bool reinit)
 		}
 	}
 
+	msleep(75);
+	ret = i40e_aq_set_link_restart_an(&pf->hw, true, NULL);
+	if (ret) {
+		dev_info(&pf->pdev->dev, "link restart failed, aq_err=%d\n",
+			 pf->hw.aq.asq_last_status);
+	}
+
 	/* reinit the misc interrupt */
 	if (pf->flags & I40E_FLAG_MSIX_ENABLED)
 		ret = i40e_setup_misc_vector(pf);
@@ -9169,6 +9178,13 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (err)
 		dev_info(&pf->pdev->dev, "set phy mask fail, aq_err %d\n", err);
 
+	msleep(75);
+	err = i40e_aq_set_link_restart_an(&pf->hw, true, NULL);
+	if (err) {
+		dev_info(&pf->pdev->dev, "link restart failed, aq_err=%d\n",
+			 pf->hw.aq.asq_last_status);
+	}
+
 	/* The main driver is (mostly) up and happy. We need to set this state
 	 * before setting up the misc vector or we get a race and the vector
 	 * ends up disabled forever.
-- 
1.9.3
