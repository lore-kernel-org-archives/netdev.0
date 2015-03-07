From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/15] i40e: Move code to enable/disable Loopback to the main file
Date: Sat,  7 Mar 2015 07:03:15 -0800
Message-ID: <1425740603-11280-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425740603-11280-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:52869 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751408AbbCGPD3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Mar 2015 10:03:29 -0500
In-Reply-To: <1425740603-11280-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>

Since changes made to enable or disable loopback for all VSIs, not only SR-IOV
or PCIOV, then it became necessary to move the associated functions to main
file - so that other non-SRIOV supported driver can take advantage of the
changes.

Change-ID: I59a49fd23a6136acda5e16f8d1e5ac7fd9c5fc05
Signed-off-by: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 68 ++++++++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 68 ----------------------
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |  2 -
 3 files changed, 68 insertions(+), 70 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 1ab5b5f..e765bb3 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5913,6 +5913,74 @@ static void i40e_verify_eeprom(struct i40e_pf *pf)
 }
 
 /**
+ * i40e_enable_pf_switch_lb
+ * @pf: pointer to the pf structure
+ *
+ * enable switch loop back or die - no point in a return value
+ **/
+static void i40e_enable_pf_switch_lb(struct i40e_pf *pf)
+{
+	struct i40e_vsi *vsi = pf->vsi[pf->lan_vsi];
+	struct i40e_vsi_context ctxt;
+	int aq_ret;
+
+	ctxt.seid = pf->main_vsi_seid;
+	ctxt.pf_num = pf->hw.pf_id;
+	ctxt.vf_num = 0;
+	aq_ret = i40e_aq_get_vsi_params(&pf->hw, &ctxt, NULL);
+	if (aq_ret) {
+		dev_info(&pf->pdev->dev,
+			 "%s couldn't get pf vsi config, err %d, aq_err %d\n",
+			 __func__, aq_ret, pf->hw.aq.asq_last_status);
+		return;
+	}
+	ctxt.flags = I40E_AQ_VSI_TYPE_PF;
+	ctxt.info.valid_sections = cpu_to_le16(I40E_AQ_VSI_PROP_SWITCH_VALID);
+	ctxt.info.switch_id |= cpu_to_le16(I40E_AQ_VSI_SW_ID_FLAG_ALLOW_LB);
+
+	aq_ret = i40e_aq_update_vsi_params(&vsi->back->hw, &ctxt, NULL);
+	if (aq_ret) {
+		dev_info(&pf->pdev->dev,
+			 "%s: update vsi switch failed, aq_err=%d\n",
+			 __func__, vsi->back->hw.aq.asq_last_status);
+	}
+}
+
+/**
+ * i40e_disable_pf_switch_lb
+ * @pf: pointer to the pf structure
+ *
+ * disable switch loop back or die - no point in a return value
+ **/
+static void i40e_disable_pf_switch_lb(struct i40e_pf *pf)
+{
+	struct i40e_vsi *vsi = pf->vsi[pf->lan_vsi];
+	struct i40e_vsi_context ctxt;
+	int aq_ret;
+
+	ctxt.seid = pf->main_vsi_seid;
+	ctxt.pf_num = pf->hw.pf_id;
+	ctxt.vf_num = 0;
+	aq_ret = i40e_aq_get_vsi_params(&pf->hw, &ctxt, NULL);
+	if (aq_ret) {
+		dev_info(&pf->pdev->dev,
+			 "%s couldn't get pf vsi config, err %d, aq_err %d\n",
+			 __func__, aq_ret, pf->hw.aq.asq_last_status);
+		return;
+	}
+	ctxt.flags = I40E_AQ_VSI_TYPE_PF;
+	ctxt.info.valid_sections = cpu_to_le16(I40E_AQ_VSI_PROP_SWITCH_VALID);
+	ctxt.info.switch_id &= ~cpu_to_le16(I40E_AQ_VSI_SW_ID_FLAG_ALLOW_LB);
+
+	aq_ret = i40e_aq_update_vsi_params(&vsi->back->hw, &ctxt, NULL);
+	if (aq_ret) {
+		dev_info(&pf->pdev->dev,
+			 "%s: update vsi switch failed, aq_err=%d\n",
+			 __func__, vsi->back->hw.aq.asq_last_status);
+	}
+}
+
+/**
  * i40e_config_bridge_mode - Configure the HW bridge mode
  * @veb: pointer to the bridge instance
  *
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 1d8b94d..7cc635e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -710,74 +710,6 @@ complete_reset:
 }
 
 /**
- * i40e_enable_pf_switch_lb
- * @pf: pointer to the pf structure
- *
- * enable switch loop back or die - no point in a return value
- **/
-void i40e_enable_pf_switch_lb(struct i40e_pf *pf)
-{
-	struct i40e_vsi *vsi = pf->vsi[pf->lan_vsi];
-	struct i40e_vsi_context ctxt;
-	int aq_ret;
-
-	ctxt.seid = pf->main_vsi_seid;
-	ctxt.pf_num = pf->hw.pf_id;
-	ctxt.vf_num = 0;
-	aq_ret = i40e_aq_get_vsi_params(&pf->hw, &ctxt, NULL);
-	if (aq_ret) {
-		dev_info(&pf->pdev->dev,
-			 "%s couldn't get pf vsi config, err %d, aq_err %d\n",
-			 __func__, aq_ret, pf->hw.aq.asq_last_status);
-		return;
-	}
-	ctxt.flags = I40E_AQ_VSI_TYPE_PF;
-	ctxt.info.valid_sections = cpu_to_le16(I40E_AQ_VSI_PROP_SWITCH_VALID);
-	ctxt.info.switch_id |= cpu_to_le16(I40E_AQ_VSI_SW_ID_FLAG_ALLOW_LB);
-
-	aq_ret = i40e_aq_update_vsi_params(&vsi->back->hw, &ctxt, NULL);
-	if (aq_ret) {
-		dev_info(&pf->pdev->dev,
-			 "%s: update vsi switch failed, aq_err=%d\n",
-			 __func__, vsi->back->hw.aq.asq_last_status);
-	}
-}
-
-/**
- * i40e_disable_pf_switch_lb
- * @pf: pointer to the pf structure
- *
- * disable switch loop back or die - no point in a return value
- **/
-void i40e_disable_pf_switch_lb(struct i40e_pf *pf)
-{
-	struct i40e_vsi *vsi = pf->vsi[pf->lan_vsi];
-	struct i40e_vsi_context ctxt;
-	int aq_ret;
-
-	ctxt.seid = pf->main_vsi_seid;
-	ctxt.pf_num = pf->hw.pf_id;
-	ctxt.vf_num = 0;
-	aq_ret = i40e_aq_get_vsi_params(&pf->hw, &ctxt, NULL);
-	if (aq_ret) {
-		dev_info(&pf->pdev->dev,
-			 "%s couldn't get pf vsi config, err %d, aq_err %d\n",
-			 __func__, aq_ret, pf->hw.aq.asq_last_status);
-		return;
-	}
-	ctxt.flags = I40E_AQ_VSI_TYPE_PF;
-	ctxt.info.valid_sections = cpu_to_le16(I40E_AQ_VSI_PROP_SWITCH_VALID);
-	ctxt.info.switch_id &= ~cpu_to_le16(I40E_AQ_VSI_SW_ID_FLAG_ALLOW_LB);
-
-	aq_ret = i40e_aq_update_vsi_params(&vsi->back->hw, &ctxt, NULL);
-	if (aq_ret) {
-		dev_info(&pf->pdev->dev,
-			 "%s: update vsi switch failed, aq_err=%d\n",
-			 __func__, vsi->back->hw.aq.asq_last_status);
-	}
-}
-
-/**
  * i40e_free_vfs
  * @pf: pointer to the pf structure
  *
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
index ef777a6..21db113 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
@@ -126,7 +126,5 @@ int i40e_ndo_set_vf_spoofchk(struct net_device *netdev, int vf_id, bool enable);
 
 void i40e_vc_notify_link_state(struct i40e_pf *pf);
 void i40e_vc_notify_reset(struct i40e_pf *pf);
-void i40e_enable_pf_switch_lb(struct i40e_pf *pf);
-void i40e_disable_pf_switch_lb(struct i40e_pf *pf);
 
 #endif /* _I40E_VIRTCHNL_PF_H_ */
-- 
1.9.3
