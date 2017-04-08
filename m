From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/12] i40e: Decrease the scope of rtnl lock
Date: Sat,  8 Apr 2017 02:55:45 -0700
Message-ID: <20170408095553.78307-5-jeffrey.t.kirsher@intel.com>
References: <20170408095553.78307-1-jeffrey.t.kirsher@intel.com>
Cc: Maciej Sosin <maciej.sosin@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:26215 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751243AbdDHJ4B (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 8 Apr 2017 05:56:01 -0400
In-Reply-To: <20170408095553.78307-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maciej Sosin <maciej.sosin@intel.com>

Previously rtnl lock was held during whole reset procedure that
was stopping other PFs running their reset procedures. In the result
reset was not handled properly and host reset was the only way
to recover.

Change-ID: I23c0771c0303caaa7bd64badbf0c667e25142954
Signed-off-by: Maciej Sosin <maciej.sosin@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h         |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c |   6 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c    | 138 +++++++++++++++++--------
 3 files changed, 101 insertions(+), 45 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 421ea57128d3..686327c031fa 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -837,7 +837,7 @@ void i40e_down(struct i40e_vsi *vsi);
 extern const char i40e_driver_name[];
 extern const char i40e_driver_version_str[];
 void i40e_do_reset_safe(struct i40e_pf *pf, u32 reset_flags);
-void i40e_do_reset(struct i40e_pf *pf, u32 reset_flags);
+void i40e_do_reset(struct i40e_pf *pf, u32 reset_flags, bool lock_acquired);
 int i40e_config_rss(struct i40e_vsi *vsi, u8 *seed, u8 *lut, u16 lut_size);
 int i40e_get_rss(struct i40e_vsi *vsi, u8 *seed, u8 *lut, u16 lut_size);
 void i40e_fill_rss_lut(struct i40e_pf *pf, u8 *lut,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index c0c1a0cdaa5b..68c0f204f93e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1852,7 +1852,7 @@ static void i40e_diag_test(struct net_device *netdev,
 			 * link then the following link test would have
 			 * to be moved to before the reset
 			 */
-			i40e_do_reset(pf, BIT(__I40E_PF_RESET_REQUESTED));
+			i40e_do_reset(pf, BIT(__I40E_PF_RESET_REQUESTED), true);
 
 		if (i40e_link_test(netdev, &data[I40E_ETH_TEST_LINK]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
@@ -1868,7 +1868,7 @@ static void i40e_diag_test(struct net_device *netdev,
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
 		clear_bit(__I40E_TESTING, &pf->state);
-		i40e_do_reset(pf, BIT(__I40E_PF_RESET_REQUESTED));
+		i40e_do_reset(pf, BIT(__I40E_PF_RESET_REQUESTED), true);
 
 		if (if_running)
 			i40e_open(netdev);
@@ -4099,7 +4099,7 @@ static int i40e_set_priv_flags(struct net_device *dev, u32 flags)
 	 */
 	if ((changed_flags & I40E_FLAG_VEB_STATS_ENABLED) ||
 	    ((changed_flags & I40E_FLAG_LEGACY_RX) && netif_running(dev)))
-		i40e_do_reset(pf, BIT(__I40E_PF_RESET_REQUESTED));
+		i40e_do_reset(pf, BIT(__I40E_PF_RESET_REQUESTED), true);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 1ee2759c38f7..8181647f512e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -50,13 +50,16 @@ static const char i40e_copyright[] = "Copyright (c) 2013 - 2014 Intel Corporatio
 
 /* a bit of forward declarations */
 static void i40e_vsi_reinit_locked(struct i40e_vsi *vsi);
-static void i40e_handle_reset_warning(struct i40e_pf *pf);
+static void i40e_handle_reset_warning(struct i40e_pf *pf, bool lock_acquired);
 static int i40e_add_vsi(struct i40e_vsi *vsi);
 static int i40e_add_veb(struct i40e_veb *veb, struct i40e_vsi *vsi);
 static int i40e_setup_pf_switch(struct i40e_pf *pf, bool reinit);
 static int i40e_setup_misc_vector(struct i40e_pf *pf);
 static void i40e_determine_queue_usage(struct i40e_pf *pf);
 static int i40e_setup_pf_filter_control(struct i40e_pf *pf);
+static void i40e_prep_for_reset(struct i40e_pf *pf, bool lock_acquired);
+static int i40e_reset(struct i40e_pf *pf);
+static void i40e_rebuild(struct i40e_pf *pf, bool reinit, bool lock_acquired);
 static void i40e_fdir_sb_setup(struct i40e_pf *pf);
 static int i40e_veb_get_bw_info(struct i40e_veb *veb);
 
@@ -5537,6 +5540,8 @@ int i40e_open(struct net_device *netdev)
  * Finish initialization of the VSI.
  *
  * Returns 0 on success, negative value on failure
+ *
+ * Note: expects to be called while under rtnl_lock()
  **/
 int i40e_vsi_open(struct i40e_vsi *vsi)
 {
@@ -5600,7 +5605,7 @@ int i40e_vsi_open(struct i40e_vsi *vsi)
 err_setup_tx:
 	i40e_vsi_free_tx_resources(vsi);
 	if (vsi == pf->vsi[pf->lan_vsi])
-		i40e_do_reset(pf, BIT_ULL(__I40E_PF_RESET_REQUESTED));
+		i40e_do_reset(pf, BIT_ULL(__I40E_PF_RESET_REQUESTED), true);
 
 	return err;
 }
@@ -5686,12 +5691,14 @@ int i40e_close(struct net_device *netdev)
  * i40e_do_reset - Start a PF or Core Reset sequence
  * @pf: board private structure
  * @reset_flags: which reset is requested
+ * @lock_acquired: indicates whether or not the lock has been acquired
+ * before this function was called.
  *
  * The essential difference in resets is that the PF Reset
  * doesn't clear the packet buffers, doesn't reset the PE
  * firmware, and doesn't bother the other PFs on the chip.
  **/
-void i40e_do_reset(struct i40e_pf *pf, u32 reset_flags)
+void i40e_do_reset(struct i40e_pf *pf, u32 reset_flags, bool lock_acquired)
 {
 	u32 val;
 
@@ -5737,7 +5744,7 @@ void i40e_do_reset(struct i40e_pf *pf, u32 reset_flags)
 		 * for the Core Reset.
 		 */
 		dev_dbg(&pf->pdev->dev, "PFR requested\n");
-		i40e_handle_reset_warning(pf);
+		i40e_handle_reset_warning(pf, lock_acquired);
 
 	} else if (reset_flags & BIT_ULL(__I40E_REINIT_REQUESTED)) {
 		int v;
@@ -5946,7 +5953,7 @@ static int i40e_handle_lldp_event(struct i40e_pf *pf,
 void i40e_do_reset_safe(struct i40e_pf *pf, u32 reset_flags)
 {
 	rtnl_lock();
-	i40e_do_reset(pf, reset_flags);
+	i40e_do_reset(pf, reset_flags, true);
 	rtnl_unlock();
 }
 
@@ -6348,7 +6355,6 @@ static void i40e_reset_subtask(struct i40e_pf *pf)
 {
 	u32 reset_flags = 0;
 
-	rtnl_lock();
 	if (test_bit(__I40E_REINIT_REQUESTED, &pf->state)) {
 		reset_flags |= BIT(__I40E_REINIT_REQUESTED);
 		clear_bit(__I40E_REINIT_REQUESTED, &pf->state);
@@ -6374,18 +6380,19 @@ static void i40e_reset_subtask(struct i40e_pf *pf)
 	 * precedence before starting a new reset sequence.
 	 */
 	if (test_bit(__I40E_RESET_INTR_RECEIVED, &pf->state)) {
-		i40e_handle_reset_warning(pf);
-		goto unlock;
+		i40e_prep_for_reset(pf, false);
+		i40e_reset(pf);
+		i40e_rebuild(pf, false, false);
 	}
 
 	/* If we're already down or resetting, just bail */
 	if (reset_flags &&
 	    !test_bit(__I40E_DOWN, &pf->state) &&
-	    !test_bit(__I40E_CONFIG_BUSY, &pf->state))
-		i40e_do_reset(pf, reset_flags);
-
-unlock:
-	rtnl_unlock();
+	    !test_bit(__I40E_CONFIG_BUSY, &pf->state)) {
+		rtnl_lock();
+		i40e_do_reset(pf, reset_flags, true);
+		rtnl_unlock();
+	}
 }
 
 /**
@@ -6873,10 +6880,12 @@ static void i40e_fdir_teardown(struct i40e_pf *pf)
 /**
  * i40e_prep_for_reset - prep for the core to reset
  * @pf: board private structure
+ * @lock_acquired: indicates whether or not the lock has been acquired
+ * before this function was called.
  *
  * Close up the VFs and other things in prep for PF Reset.
   **/
-static void i40e_prep_for_reset(struct i40e_pf *pf)
+static void i40e_prep_for_reset(struct i40e_pf *pf, bool lock_acquired)
 {
 	struct i40e_hw *hw = &pf->hw;
 	i40e_status ret = 0;
@@ -6891,7 +6900,12 @@ static void i40e_prep_for_reset(struct i40e_pf *pf)
 	dev_dbg(&pf->pdev->dev, "Tearing down internal switch for reset\n");
 
 	/* quiesce the VSIs and their queues that are not already DOWN */
+	/* pf_quiesce_all_vsi modifies netdev structures -rtnl_lock needed */
+	if (!lock_acquired)
+		rtnl_lock();
 	i40e_pf_quiesce_all_vsi(pf);
+	if (!lock_acquired)
+		rtnl_unlock();
 
 	for (v = 0; v < pf->num_alloc_vsi; v++) {
 		if (pf->vsi[v])
@@ -6926,29 +6940,39 @@ static void i40e_send_version(struct i40e_pf *pf)
 }
 
 /**
- * i40e_reset_and_rebuild - reset and rebuild using a saved config
+ * i40e_reset - wait for core reset to finish reset, reset pf if corer not seen
  * @pf: board private structure
- * @reinit: if the Main VSI needs to re-initialized.
  **/
-static void i40e_reset_and_rebuild(struct i40e_pf *pf, bool reinit)
+static int i40e_reset(struct i40e_pf *pf)
 {
 	struct i40e_hw *hw = &pf->hw;
-	u8 set_fc_aq_fail = 0;
 	i40e_status ret;
-	u32 val;
-	u32 v;
 
-	/* Now we wait for GRST to settle out.
-	 * We don't have to delete the VEBs or VSIs from the hw switch
-	 * because the reset will make them disappear.
-	 */
 	ret = i40e_pf_reset(hw);
 	if (ret) {
 		dev_info(&pf->pdev->dev, "PF reset failed, %d\n", ret);
 		set_bit(__I40E_RESET_FAILED, &pf->state);
-		goto clear_recovery;
+		clear_bit(__I40E_RESET_RECOVERY_PENDING, &pf->state);
+	} else {
+		pf->pfr_count++;
 	}
-	pf->pfr_count++;
+	return ret;
+}
+
+/**
+ * i40e_rebuild - rebuild using a saved config
+ * @pf: board private structure
+ * @reinit: if the Main VSI needs to re-initialized.
+ * @lock_acquired: indicates whether or not the lock has been acquired
+ * before this function was called.
+ **/
+static void i40e_rebuild(struct i40e_pf *pf, bool reinit, bool lock_acquired)
+{
+	struct i40e_hw *hw = &pf->hw;
+	u8 set_fc_aq_fail = 0;
+	i40e_status ret;
+	u32 val;
+	int v;
 
 	if (test_bit(__I40E_DOWN, &pf->state))
 		goto clear_recovery;
@@ -6993,9 +7017,11 @@ static void i40e_reset_and_rebuild(struct i40e_pf *pf, bool reinit)
 	}
 #endif /* CONFIG_I40E_DCB */
 	/* do basic switch setup */
+	if (!lock_acquired)
+		rtnl_lock();
 	ret = i40e_setup_pf_switch(pf, reinit);
 	if (ret)
-		goto end_core_reset;
+		goto end_unlock;
 
 	/* The driver only wants link up/down and module qualification
 	 * reports from firmware.  Note the negative logic.
@@ -7066,7 +7092,7 @@ static void i40e_reset_and_rebuild(struct i40e_pf *pf, bool reinit)
 		if (ret) {
 			dev_info(&pf->pdev->dev,
 				 "rebuild of Main VSI failed: %d\n", ret);
-			goto end_core_reset;
+			goto end_unlock;
 		}
 	}
 
@@ -7117,6 +7143,9 @@ static void i40e_reset_and_rebuild(struct i40e_pf *pf, bool reinit)
 	/* tell the firmware that we're starting */
 	i40e_send_version(pf);
 
+end_unlock:
+if (!lock_acquired)
+	rtnl_unlock();
 end_core_reset:
 	clear_bit(__I40E_RESET_FAILED, &pf->state);
 clear_recovery:
@@ -7124,16 +7153,38 @@ static void i40e_reset_and_rebuild(struct i40e_pf *pf, bool reinit)
 }
 
 /**
+ * i40e_reset_and_rebuild - reset and rebuild using a saved config
+ * @pf: board private structure
+ * @reinit: if the Main VSI needs to re-initialized.
+ * @lock_acquired: indicates whether or not the lock has been acquired
+ * before this function was called.
+ **/
+static void i40e_reset_and_rebuild(struct i40e_pf *pf, bool reinit,
+				   bool lock_acquired)
+{
+	int ret;
+	/* Now we wait for GRST to settle out.
+	 * We don't have to delete the VEBs or VSIs from the hw switch
+	 * because the reset will make them disappear.
+	 */
+	ret = i40e_reset(pf);
+	if (!ret)
+		i40e_rebuild(pf, reinit, lock_acquired);
+}
+
+/**
  * i40e_handle_reset_warning - prep for the PF to reset, reset and rebuild
  * @pf: board private structure
  *
  * Close up the VFs and other things in prep for a Core Reset,
  * then get ready to rebuild the world.
+ * @lock_acquired: indicates whether or not the lock has been acquired
+ * before this function was called.
  **/
-static void i40e_handle_reset_warning(struct i40e_pf *pf)
+static void i40e_handle_reset_warning(struct i40e_pf *pf, bool lock_acquired)
 {
-	i40e_prep_for_reset(pf);
-	i40e_reset_and_rebuild(pf, false);
+	i40e_prep_for_reset(pf, lock_acquired);
+	i40e_reset_and_rebuild(pf, false, lock_acquired);
 }
 
 /**
@@ -8430,6 +8481,7 @@ static int i40e_pf_config_rss(struct i40e_pf *pf)
  *
  * returns 0 if rss is not enabled, if enabled returns the final rss queue
  * count which may be different from the requested queue count.
+ * Note: expects to be called while under rtnl_lock()
  **/
 int i40e_reconfig_rss_queues(struct i40e_pf *pf, int queue_count)
 {
@@ -8445,11 +8497,11 @@ int i40e_reconfig_rss_queues(struct i40e_pf *pf, int queue_count)
 		u16 qcount;
 
 		vsi->req_queue_pairs = queue_count;
-		i40e_prep_for_reset(pf);
+		i40e_prep_for_reset(pf, true);
 
 		pf->alloc_rss_size = new_rss_size;
 
-		i40e_reset_and_rebuild(pf, true);
+		i40e_reset_and_rebuild(pf, true, true);
 
 		/* Discard the user configured hash keys and lut, if less
 		 * queues are enabled.
@@ -8825,6 +8877,7 @@ static void i40e_clear_rss_lut(struct i40e_vsi *vsi)
  * i40e_set_features - set the netdev feature flags
  * @netdev: ptr to the netdev being adjusted
  * @features: the feature set that the stack is suggesting
+ * Note: expects to be called while under rtnl_lock()
  **/
 static int i40e_set_features(struct net_device *netdev,
 			     netdev_features_t features)
@@ -8848,7 +8901,7 @@ static int i40e_set_features(struct net_device *netdev,
 	need_reset = i40e_set_ntuple(pf, features);
 
 	if (need_reset)
-		i40e_do_reset(pf, BIT_ULL(__I40E_PF_RESET_REQUESTED));
+		i40e_do_reset(pf, BIT_ULL(__I40E_PF_RESET_REQUESTED), true);
 
 	return 0;
 }
@@ -9043,6 +9096,8 @@ static int i40e_ndo_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
  * is to change the mode then that requires a PF reset to
  * allow rebuild of the components with required hardware
  * bridge mode enabled.
+ *
+ * Note: expects to be called while under rtnl_lock()
  **/
 static int i40e_ndo_bridge_setlink(struct net_device *dev,
 				   struct nlmsghdr *nlh,
@@ -9098,7 +9153,8 @@ static int i40e_ndo_bridge_setlink(struct net_device *dev,
 				pf->flags |= I40E_FLAG_VEB_MODE_ENABLED;
 			else
 				pf->flags &= ~I40E_FLAG_VEB_MODE_ENABLED;
-			i40e_do_reset(pf, BIT_ULL(__I40E_PF_RESET_REQUESTED));
+			i40e_do_reset(pf, BIT_ULL(__I40E_PF_RESET_REQUESTED),
+				      true);
 			break;
 		}
 	}
@@ -11501,7 +11557,7 @@ static pci_ers_result_t i40e_pci_error_detected(struct pci_dev *pdev,
 	/* shutdown all operations */
 	if (!test_bit(__I40E_SUSPENDED, &pf->state)) {
 		rtnl_lock();
-		i40e_prep_for_reset(pf);
+		i40e_prep_for_reset(pf, true);
 		rtnl_unlock();
 	}
 
@@ -11570,7 +11626,7 @@ static void i40e_pci_error_resume(struct pci_dev *pdev)
 		return;
 
 	rtnl_lock();
-	i40e_handle_reset_warning(pf);
+	i40e_handle_reset_warning(pf, true);
 	rtnl_unlock();
 }
 
@@ -11633,7 +11689,7 @@ static void i40e_shutdown(struct pci_dev *pdev)
 	set_bit(__I40E_SUSPENDED, &pf->state);
 	set_bit(__I40E_DOWN, &pf->state);
 	rtnl_lock();
-	i40e_prep_for_reset(pf);
+	i40e_prep_for_reset(pf, true);
 	rtnl_unlock();
 
 	wr32(hw, I40E_PFPM_APM, (pf->wol_en ? I40E_PFPM_APM_APME_MASK : 0));
@@ -11652,7 +11708,7 @@ static void i40e_shutdown(struct pci_dev *pdev)
 		i40e_enable_mc_magic_wake(pf);
 
 	rtnl_lock();
-	i40e_prep_for_reset(pf);
+	i40e_prep_for_reset(pf, true);
 	rtnl_unlock();
 
 	wr32(hw, I40E_PFPM_APM,
@@ -11686,7 +11742,7 @@ static int i40e_suspend(struct pci_dev *pdev, pm_message_t state)
 		i40e_enable_mc_magic_wake(pf);
 
 	rtnl_lock();
-	i40e_prep_for_reset(pf);
+	i40e_prep_for_reset(pf, true);
 	rtnl_unlock();
 
 	wr32(hw, I40E_PFPM_APM, (pf->wol_en ? I40E_PFPM_APM_APME_MASK : 0));
@@ -11734,7 +11790,7 @@ static int i40e_resume(struct pci_dev *pdev)
 	if (test_and_clear_bit(__I40E_SUSPENDED, &pf->state)) {
 		clear_bit(__I40E_DOWN, &pf->state);
 		rtnl_lock();
-		i40e_reset_and_rebuild(pf, false);
+		i40e_reset_and_rebuild(pf, false, true);
 		rtnl_unlock();
 	}
 
-- 
2.12.2
