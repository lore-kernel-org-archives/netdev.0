From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/18] i40e: Fix issue with removal of apps from DBCNL app table
Date: Sat, 28 Feb 2015 03:29:42 -0800
Message-ID: <1425122989-354-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425122989-354-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Neerav Parikh <neerav.parikh@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:50492 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751360AbbB1L37 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Feb 2015 06:29:59 -0500
In-Reply-To: <1425122989-354-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neerav Parikh <neerav.parikh@intel.com>

This patch fixes an issue where the driver is not flushing out the
DCBNL app table for applications that are not present in the local
DCBX application configuration TLVs.

Change-ID: I1f1ee04c81c145071b2ab15657546eb10b81fadb
Signed-off-by: Neerav Parikh <neerav.parikh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h        |  1 +
 drivers/net/ethernet/intel/i40e/i40e_dcb_nl.c |  9 ++++-----
 drivers/net/ethernet/intel/i40e/i40e_main.c   | 15 +++++++++------
 3 files changed, 14 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 9af4456..bc2b993 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -728,6 +728,7 @@ void i40e_fcoe_handle_status(struct i40e_ring *rx_ring,
 void i40e_vlan_stripping_enable(struct i40e_vsi *vsi);
 #ifdef CONFIG_I40E_DCB
 void i40e_dcbnl_flush_apps(struct i40e_pf *pf,
+			   struct i40e_dcbx_config *old_cfg,
 			   struct i40e_dcbx_config *new_cfg);
 void i40e_dcbnl_set_all(struct i40e_vsi *vsi);
 void i40e_dcbnl_setup(struct i40e_vsi *vsi);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_dcb_nl.c b/drivers/net/ethernet/intel/i40e/i40e_dcb_nl.c
index 183dcb6..f4070b5 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_dcb_nl.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_dcb_nl.c
@@ -269,22 +269,21 @@ static bool i40e_dcbnl_find_app(struct i40e_dcbx_config *cfg,
 /**
  * i40e_dcbnl_flush_apps - Delete all removed APPs
  * @pf: the corresponding pf
+ * @old_cfg: old DCBX configuration data
  * @new_cfg: new DCBX configuration data
  *
  * Find and delete all APPs that are not present in the passed
  * DCB configuration
  **/
 void i40e_dcbnl_flush_apps(struct i40e_pf *pf,
+			   struct i40e_dcbx_config *old_cfg,
 			   struct i40e_dcbx_config *new_cfg)
 {
 	struct i40e_dcb_app_priority_table app;
-	struct i40e_dcbx_config *dcbxcfg;
-	struct i40e_hw *hw = &pf->hw;
 	int i;
 
-	dcbxcfg = &hw->local_dcbx_config;
-	for (i = 0; i < dcbxcfg->numapps; i++) {
-		app = dcbxcfg->app[i];
+	for (i = 0; i < old_cfg->numapps; i++) {
+		app = old_cfg->app[i];
 		/* The APP is not available anymore delete it */
 		if (!i40e_dcbnl_find_app(new_cfg, &app))
 			i40e_dcbnl_del_app(pf, &app);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 3a476956..626333d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5192,7 +5192,6 @@ static int i40e_handle_lldp_event(struct i40e_pf *pf,
 	struct i40e_aqc_lldp_get_mib *mib =
 		(struct i40e_aqc_lldp_get_mib *)&e->desc.params.raw;
 	struct i40e_hw *hw = &pf->hw;
-	struct i40e_dcbx_config *dcbx_cfg = &hw->local_dcbx_config;
 	struct i40e_dcbx_config tmp_dcbx_cfg;
 	bool need_reconfig = false;
 	int ret = 0;
@@ -5225,8 +5224,10 @@ static int i40e_handle_lldp_event(struct i40e_pf *pf,
 
 	memset(&tmp_dcbx_cfg, 0, sizeof(tmp_dcbx_cfg));
 	/* Store the old configuration */
-	tmp_dcbx_cfg = *dcbx_cfg;
+	memcpy(&tmp_dcbx_cfg, &hw->local_dcbx_config, sizeof(tmp_dcbx_cfg));
 
+	/* Reset the old DCBx configuration data */
+	memset(&hw->local_dcbx_config, 0, sizeof(hw->local_dcbx_config));
 	/* Get updated DCBX data from firmware */
 	ret = i40e_get_dcb_config(&pf->hw);
 	if (ret) {
@@ -5235,20 +5236,22 @@ static int i40e_handle_lldp_event(struct i40e_pf *pf,
 	}
 
 	/* No change detected in DCBX configs */
-	if (!memcmp(&tmp_dcbx_cfg, dcbx_cfg, sizeof(tmp_dcbx_cfg))) {
+	if (!memcmp(&tmp_dcbx_cfg, &hw->local_dcbx_config,
+		    sizeof(tmp_dcbx_cfg))) {
 		dev_dbg(&pf->pdev->dev, "No change detected in DCBX configuration.\n");
 		goto exit;
 	}
 
-	need_reconfig = i40e_dcb_need_reconfig(pf, &tmp_dcbx_cfg, dcbx_cfg);
+	need_reconfig = i40e_dcb_need_reconfig(pf, &tmp_dcbx_cfg,
+					       &hw->local_dcbx_config);
 
-	i40e_dcbnl_flush_apps(pf, dcbx_cfg);
+	i40e_dcbnl_flush_apps(pf, &tmp_dcbx_cfg, &hw->local_dcbx_config);
 
 	if (!need_reconfig)
 		goto exit;
 
 	/* Enable DCB tagging only when more than one TC */
-	if (i40e_dcb_get_num_tc(dcbx_cfg) > 1)
+	if (i40e_dcb_get_num_tc(&hw->local_dcbx_config) > 1)
 		pf->flags |= I40E_FLAG_DCB_ENABLED;
 	else
 		pf->flags &= ~I40E_FLAG_DCB_ENABLED;
-- 
1.9.3
