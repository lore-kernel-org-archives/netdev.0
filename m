From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/17] i40e: fix inconsistent statuses after a PF reset
Date: Fri, 23 Oct 2015 06:17:47 -0700
Message-ID: <1445606279-19345-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1445606279-19345-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Helin Zhang <helin.zhang@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:13278 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751923AbbJWNSS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2015 09:18:18 -0400
In-Reply-To: <1445606279-19345-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Helin Zhang <helin.zhang@intel.com>

This patch fixes a problem of possibly getting inconsistent flow control
statuses after a PF reset. Requested_mode was being set with a default
value during probing, but the initial HW state could be different from
this mode.

Change-ID: I772bf07b78616e87086418d4bd87954b66fa17cd
Signed-off-by: Helin Zhang <helin.zhang@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index f22ded5..2f117d9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -10183,6 +10183,7 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	int err;
 	u32 len;
 	u32 i;
+	u8 set_fc_aq_fail;
 
 	err = pci_enable_device_mem(pdev);
 	if (err)
@@ -10447,6 +10448,25 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		dev_info(&pdev->dev, "setup_pf_switch failed: %d\n", err);
 		goto err_vsis;
 	}
+
+	/* Make sure flow control is set according to current settings */
+	err = i40e_set_fc(hw, &set_fc_aq_fail, true);
+	if (set_fc_aq_fail & I40E_SET_FC_AQ_FAIL_GET)
+		dev_dbg(&pf->pdev->dev,
+			"Set fc with err %s aq_err %s on get_phy_cap\n",
+			i40e_stat_str(hw, err),
+			i40e_aq_str(hw, hw->aq.asq_last_status));
+	if (set_fc_aq_fail & I40E_SET_FC_AQ_FAIL_SET)
+		dev_dbg(&pf->pdev->dev,
+			"Set fc with err %s aq_err %s on set_phy_config\n",
+			i40e_stat_str(hw, err),
+			i40e_aq_str(hw, hw->aq.asq_last_status));
+	if (set_fc_aq_fail & I40E_SET_FC_AQ_FAIL_UPDATE)
+		dev_dbg(&pf->pdev->dev,
+			"Set fc with err %s aq_err %s on get_link_info\n",
+			i40e_stat_str(hw, err),
+			i40e_aq_str(hw, hw->aq.asq_last_status));
+
 	/* if FDIR VSI was set up, start it now */
 	for (i = 0; i < pf->num_alloc_vsi; i++) {
 		if (pf->vsi[i] && pf->vsi[i]->type == I40E_VSI_FDIR) {
-- 
2.4.3
