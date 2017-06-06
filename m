From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/2] i40e: Fix state flags for bit set and clean operations of PF
Date: Tue,  6 Jun 2017 03:00:54 -0700
Message-ID: <20170606100055.63648-2-jeffrey.t.kirsher@intel.com>
References: <20170606100055.63648-1-jeffrey.t.kirsher@intel.com>
Cc: "Mauro S. M. Rodrigues" <maurosr@linux.vnet.ibm.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:21678 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751386AbdFFKBB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Jun 2017 06:01:01 -0400
In-Reply-To: <20170606100055.63648-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Mauro S. M. Rodrigues" <maurosr@linux.vnet.ibm.com>

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

Reviewed-by: "Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>
Signed-off-by: "Mauro S. M. Rodrigues" <maurosr@linux.vnet.ibm.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 36 ++++++++++++++---------------
 1 file changed, 18 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index d5c9c9e06ff5..150caf6ca2b4 100644
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
2.12.2
