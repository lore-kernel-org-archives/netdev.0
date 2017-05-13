From: "Mauro S. M. Rodrigues" <maurosr@linux.vnet.ibm.com>
Subject: [PATCH net] i40e: Fix state flags for bit set and clean operations of PF
Date: Fri, 12 May 2017 23:26:56 -0300
Message-ID: <1494642416-21796-1-git-send-email-maurosr@linux.vnet.ibm.com>
Cc: jeffrey.t.kirsher@intel.com, gpiccoli@linux.vnet.ibm.com,
        "Mauro S. M. Rodrigues" <maurosr@linux.vnet.ibm.com>
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:33400 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751407AbdEMC12 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 12 May 2017 22:27:28 -0400
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4D2OQ7x016914
        for <netdev@vger.kernel.org>; Fri, 12 May 2017 22:27:20 -0400
Received: from e24smtp05.br.ibm.com (e24smtp05.br.ibm.com [32.104.18.26])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2adg80km8t-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 12 May 2017 22:27:19 -0400
Received: from localhost
        by e24smtp05.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <maurosr@linux.vnet.ibm.com>;
        Fri, 12 May 2017 23:27:18 -0300
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
        by d24relay04.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v4D2RFvw40894496
        for <netdev@vger.kernel.org>; Fri, 12 May 2017 23:27:15 -0300
Received: from d24av01.br.ibm.com (localhost [127.0.0.1])
        by d24av01.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v4D2REnZ029063
        for <netdev@vger.kernel.org>; Fri, 12 May 2017 23:27:15 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 0da36b9774cc ("i40e: use DECLARE_BITMAP for state fields")
introduced changes in the way i40e works with state flags converting
them to bitmaps using kernel bitmap API. This change introduced a
regression due to a mistaken substitution using __I40E_VSI_DOWN instead
of __I40E_DOWN when testing state of a PF at i40e_reset_subtask()
function. This caused a flood in the kernel log with the follow message:

[49.013] i40e 0002:01:00.0: bad reset request 0x00000020

Commit d19cb64b9222 ("i40e: separate PF and VSI state flags")
also introduced some misuse of the VSI and PF flags, so both could be
considered as the offenders.

This patch simply fixes the flags where it makes sense by changing
__I40E_VSI_DOWN to __I40E_DOWN.

Fixes: 0da36b9774cc ("i40e: use DECLARE_BITMAP for state fields")
Fixes: d19cb64b9222 ("i40e: separate PF and VSI state flags")

Reviewed-by: Guilherme G. Piccoli <gpiccoli@linux.vnet.ibm.com>
Signed-off-by: Mauro S. M. Rodrigues <maurosr@linux.vnet.ibm.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 36 ++++++++++++++---------------
 1 file changed, 18 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index d5c9c9e..150caf6 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -295,7 +295,7 @@ struct i40e_vsi *i40e_find_vsi_from_id(struct i40e_pf *pf, u16 id)
  **/
 void i40e_service_event_schedule(struct i40e_pf *pf)
 {
-	if (!test_bit(__I40E_VSI_DOWN, pf->state) &&
+	if (!test_bit(__I40E_DOWN, pf->state) &&
 	    !test_bit(__I40E_RESET_RECOVERY_PENDING, pf->state))
 		queue_work(i40e_wq, &pf->service_task);
 }
@@ -3611,7 +3611,7 @@ static irqreturn_t i40e_intr(int irq, void *data)
 		 * this is not a performance path and napi_schedule()
 		 * can deal with rescheduling.
 		 */
-		if (!test_bit(__I40E_VSI_DOWN, pf->state))
+		if (!test_bit(__I40E_DOWN, pf->state))
 			napi_schedule_irqoff(&q_vector->napi);
 	}
 
@@ -3687,7 +3687,7 @@ static irqreturn_t i40e_intr(int irq, void *data)
 enable_intr:
 	/* re-enable interrupt causes */
 	wr32(hw, I40E_PFINT_ICR0_ENA, ena_mask);
-	if (!test_bit(__I40E_VSI_DOWN, pf->state)) {
+	if (!test_bit(__I40E_DOWN, pf->state)) {
 		i40e_service_event_schedule(pf);
 		i40e_irq_dynamic_enable_icr0(pf, false);
 	}
@@ -6203,7 +6203,7 @@ static void i40e_fdir_reinit_subtask(struct i40e_pf *pf)
 {
 
 	/* if interface is down do nothing */
-	if (test_bit(__I40E_VSI_DOWN, pf->state))
+	if (test_bit(__I40E_DOWN, pf->state))
 		return;
 
 	if (test_bit(__I40E_FD_FLUSH_REQUESTED, pf->state))
@@ -6344,7 +6344,7 @@ static void i40e_watchdog_subtask(struct i40e_pf *pf)
 	int i;
 
 	/* if interface is down do nothing */
-	if (test_bit(__I40E_VSI_DOWN, pf->state) ||
+	if (test_bit(__I40E_DOWN, pf->state) ||
 	    test_bit(__I40E_CONFIG_BUSY, pf->state))
 		return;
 
@@ -6399,9 +6399,9 @@ static void i40e_reset_subtask(struct i40e_pf *pf)
 		reset_flags |= BIT(__I40E_GLOBAL_RESET_REQUESTED);
 		clear_bit(__I40E_GLOBAL_RESET_REQUESTED, pf->state);
 	}
-	if (test_bit(__I40E_VSI_DOWN_REQUESTED, pf->state)) {
-		reset_flags |= BIT(__I40E_VSI_DOWN_REQUESTED);
-		clear_bit(__I40E_VSI_DOWN_REQUESTED, pf->state);
+	if (test_bit(__I40E_DOWN_REQUESTED, pf->state)) {
+		reset_flags |= BIT(__I40E_DOWN_REQUESTED);
+		clear_bit(__I40E_DOWN_REQUESTED, pf->state);
 	}
 
 	/* If there's a recovery already waiting, it takes
@@ -6415,7 +6415,7 @@ static void i40e_reset_subtask(struct i40e_pf *pf)
 
 	/* If we're already down or resetting, just bail */
 	if (reset_flags &&
-	    !test_bit(__I40E_VSI_DOWN, pf->state) &&
+	    !test_bit(__I40E_DOWN, pf->state) &&
 	    !test_bit(__I40E_CONFIG_BUSY, pf->state)) {
 		rtnl_lock();
 		i40e_do_reset(pf, reset_flags, true);
@@ -7002,7 +7002,7 @@ static void i40e_rebuild(struct i40e_pf *pf, bool reinit, bool lock_acquired)
 	u32 val;
 	int v;
 
-	if (test_bit(__I40E_VSI_DOWN, pf->state))
+	if (test_bit(__I40E_DOWN, pf->state))
 		goto clear_recovery;
 	dev_dbg(&pf->pdev->dev, "Rebuilding internal switch\n");
 
@@ -9767,7 +9767,7 @@ int i40e_vsi_release(struct i40e_vsi *vsi)
 		return -ENODEV;
 	}
 	if (vsi == pf->vsi[pf->lan_vsi] &&
-	    !test_bit(__I40E_VSI_DOWN, pf->state)) {
+	    !test_bit(__I40E_DOWN, pf->state)) {
 		dev_info(&pf->pdev->dev, "Can't remove PF VSI\n");
 		return -ENODEV;
 	}
@@ -11003,7 +11003,7 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 	pf->next_vsi = 0;
 	pf->pdev = pdev;
-	set_bit(__I40E_VSI_DOWN, pf->state);
+	set_bit(__I40E_DOWN, pf->state);
 
 	hw = &pf->hw;
 	hw->back = pf;
@@ -11293,7 +11293,7 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	 * before setting up the misc vector or we get a race and the vector
 	 * ends up disabled forever.
 	 */
-	clear_bit(__I40E_VSI_DOWN, pf->state);
+	clear_bit(__I40E_DOWN, pf->state);
 
 	/* In case of MSIX we are going to setup the misc vector right here
 	 * to handle admin queue events etc. In case of legacy and MSI
@@ -11448,7 +11448,7 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	/* Unwind what we've done if something failed in the setup */
 err_vsis:
-	set_bit(__I40E_VSI_DOWN, pf->state);
+	set_bit(__I40E_DOWN, pf->state);
 	i40e_clear_interrupt_scheme(pf);
 	kfree(pf->vsi);
 err_switch_setup:
@@ -11500,7 +11500,7 @@ static void i40e_remove(struct pci_dev *pdev)
 
 	/* no more scheduling of any task */
 	set_bit(__I40E_SUSPENDED, pf->state);
-	set_bit(__I40E_VSI_DOWN, pf->state);
+	set_bit(__I40E_DOWN, pf->state);
 	if (pf->service_timer.data)
 		del_timer_sync(&pf->service_timer);
 	if (pf->service_task.func)
@@ -11740,7 +11740,7 @@ static void i40e_shutdown(struct pci_dev *pdev)
 	struct i40e_hw *hw = &pf->hw;
 
 	set_bit(__I40E_SUSPENDED, pf->state);
-	set_bit(__I40E_VSI_DOWN, pf->state);
+	set_bit(__I40E_DOWN, pf->state);
 	rtnl_lock();
 	i40e_prep_for_reset(pf, true);
 	rtnl_unlock();
@@ -11789,7 +11789,7 @@ static int i40e_suspend(struct pci_dev *pdev, pm_message_t state)
 	int retval = 0;
 
 	set_bit(__I40E_SUSPENDED, pf->state);
-	set_bit(__I40E_VSI_DOWN, pf->state);
+	set_bit(__I40E_DOWN, pf->state);
 
 	if (pf->wol_en && (pf->flags & I40E_FLAG_WOL_MC_MAGIC_PKT_WAKE))
 		i40e_enable_mc_magic_wake(pf);
@@ -11841,7 +11841,7 @@ static int i40e_resume(struct pci_dev *pdev)
 
 	/* handling the reset will rebuild the device state */
 	if (test_and_clear_bit(__I40E_SUSPENDED, pf->state)) {
-		clear_bit(__I40E_VSI_DOWN, pf->state);
+		clear_bit(__I40E_DOWN, pf->state);
 		rtnl_lock();
 		i40e_reset_and_rebuild(pf, false, true);
 		rtnl_unlock();
-- 
2.7.4
