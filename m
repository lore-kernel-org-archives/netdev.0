From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/14] i40e: move IRQ tracking setup into MSIX setup
Date: Thu,  5 Mar 2015 08:46:30 -0800
Message-ID: <1425573992-30955-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425573992-30955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:47536 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1945972AbbCEQql (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Mar 2015 11:46:41 -0500
In-Reply-To: <1425573992-30955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Move the IRQ tracking setup and teardown into the same routines that
do the IRQ setup and teardown.  This keeps like activities together and
allows us to track exactly the number of vectors reserved from the OS,
which may be fewer than are available from the HW.

Change-ID: I6b2b1a955c5f0ac6b94c3084304ed0b2ea6777cf
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 60 ++++++++++++++---------------
 1 file changed, 29 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index f769005..bca62c1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -3831,6 +3831,8 @@ static void i40e_reset_interrupt_capability(struct i40e_pf *pf)
 		pci_disable_msix(pf->pdev);
 		kfree(pf->msix_entries);
 		pf->msix_entries = NULL;
+		kfree(pf->irq_pile);
+		pf->irq_pile = NULL;
 	} else if (pf->flags & I40E_FLAG_MSI_ENABLED) {
 		pci_disable_msi(pf->pdev);
 	}
@@ -6933,15 +6935,14 @@ static int i40e_reserve_msix_vectors(struct i40e_pf *pf, int vectors)
  *
  * Work with the OS to set up the MSIX vectors needed.
  *
- * Returns 0 on success, negative on failure
+ * Returns the number of vectors reserved or negative on failure
  **/
 static int i40e_init_msix(struct i40e_pf *pf)
 {
-	i40e_status err = 0;
 	struct i40e_hw *hw = &pf->hw;
 	int other_vecs = 0;
 	int v_budget, i;
-	int vec;
+	int v_actual;
 
 	if (!(pf->flags & I40E_FLAG_MSIX_ENABLED))
 		return -ENODEV;
@@ -6990,9 +6991,9 @@ static int i40e_init_msix(struct i40e_pf *pf)
 
 	for (i = 0; i < v_budget; i++)
 		pf->msix_entries[i].entry = i;
-	vec = i40e_reserve_msix_vectors(pf, v_budget);
+	v_actual = i40e_reserve_msix_vectors(pf, v_budget);
 
-	if (vec != v_budget) {
+	if (v_actual != v_budget) {
 		/* If we have limited resources, we will start with no vectors
 		 * for the special features and then allocate vectors to some
 		 * of these features based on the policy and at the end disable
@@ -7005,22 +7006,24 @@ static int i40e_init_msix(struct i40e_pf *pf)
 		pf->num_vmdq_msix = 0;
 	}
 
-	if (vec < I40E_MIN_MSIX) {
+	if (v_actual < I40E_MIN_MSIX) {
 		pf->flags &= ~I40E_FLAG_MSIX_ENABLED;
 		kfree(pf->msix_entries);
 		pf->msix_entries = NULL;
 		return -ENODEV;
 
-	} else if (vec == I40E_MIN_MSIX) {
+	} else if (v_actual == I40E_MIN_MSIX) {
 		/* Adjust for minimal MSIX use */
 		pf->num_vmdq_vsis = 0;
 		pf->num_vmdq_qps = 0;
 		pf->num_lan_qps = 1;
 		pf->num_lan_msix = 1;
 
-	} else if (vec != v_budget) {
+	} else if (v_actual != v_budget) {
+		int vec;
+
 		/* reserve the misc vector */
-		vec--;
+		vec = v_actual - 1;
 
 		/* Scale vector usage down */
 		pf->num_vmdq_msix = 1;    /* force VMDqs to only one vector */
@@ -7070,7 +7073,7 @@ static int i40e_init_msix(struct i40e_pf *pf)
 		pf->flags &= ~I40E_FLAG_FCOE_ENABLED;
 	}
 #endif
-	return err;
+	return v_actual;
 }
 
 /**
@@ -7147,11 +7150,12 @@ err_out:
  **/
 static void i40e_init_interrupt_scheme(struct i40e_pf *pf)
 {
-	int err = 0;
+	int vectors = 0;
+	ssize_t size;
 
 	if (pf->flags & I40E_FLAG_MSIX_ENABLED) {
-		err = i40e_init_msix(pf);
-		if (err) {
+		vectors = i40e_init_msix(pf);
+		if (vectors < 0) {
 			pf->flags &= ~(I40E_FLAG_MSIX_ENABLED	|
 #ifdef I40E_FCOE
 				       I40E_FLAG_FCOE_ENABLED	|
@@ -7171,18 +7175,26 @@ static void i40e_init_interrupt_scheme(struct i40e_pf *pf)
 	if (!(pf->flags & I40E_FLAG_MSIX_ENABLED) &&
 	    (pf->flags & I40E_FLAG_MSI_ENABLED)) {
 		dev_info(&pf->pdev->dev, "MSI-X not available, trying MSI\n");
-		err = pci_enable_msi(pf->pdev);
-		if (err) {
-			dev_info(&pf->pdev->dev, "MSI init failed - %d\n", err);
+		vectors = pci_enable_msi(pf->pdev);
+		if (vectors < 0) {
+			dev_info(&pf->pdev->dev, "MSI init failed - %d\n",
+				 vectors);
 			pf->flags &= ~I40E_FLAG_MSI_ENABLED;
 		}
+		vectors = 1;  /* one MSI or Legacy vector */
 	}
 
 	if (!(pf->flags & (I40E_FLAG_MSIX_ENABLED | I40E_FLAG_MSI_ENABLED)))
 		dev_info(&pf->pdev->dev, "MSI-X and MSI not available, falling back to Legacy IRQ\n");
 
+	/* set up vector assignment tracking */
+	size = sizeof(struct i40e_lump_tracking) + (sizeof(u16) * vectors);
+	pf->irq_pile = kzalloc(size, GFP_KERNEL);
+	pf->irq_pile->num_entries = vectors;
+	pf->irq_pile->search_hint = 0;
+
 	/* track first vector for misc interrupts */
-	err = i40e_get_lump(pf, pf->irq_pile, 1, I40E_PILE_VALID_BIT-1);
+	(void)i40e_get_lump(pf, pf->irq_pile, 1, I40E_PILE_VALID_BIT - 1);
 }
 
 /**
@@ -7560,18 +7572,6 @@ static int i40e_sw_init(struct i40e_pf *pf)
 	pf->qp_pile->num_entries = pf->hw.func_caps.num_tx_qp;
 	pf->qp_pile->search_hint = 0;
 
-	/* set up vector assignment tracking */
-	size = sizeof(struct i40e_lump_tracking)
-		+ (sizeof(u16) * pf->hw.func_caps.num_msix_vectors);
-	pf->irq_pile = kzalloc(size, GFP_KERNEL);
-	if (!pf->irq_pile) {
-		kfree(pf->qp_pile);
-		err = -ENOMEM;
-		goto sw_init_done;
-	}
-	pf->irq_pile->num_entries = pf->hw.func_caps.num_msix_vectors;
-	pf->irq_pile->search_hint = 0;
-
 	pf->tx_timeout_recovery_level = 1;
 
 	mutex_init(&pf->switch_mutex);
@@ -9840,7 +9840,6 @@ err_configure_lan_hmc:
 	(void)i40e_shutdown_lan_hmc(hw);
 err_init_lan_hmc:
 	kfree(pf->qp_pile);
-	kfree(pf->irq_pile);
 err_sw_init:
 err_adminq_setup:
 	(void)i40e_shutdown_adminq(hw);
@@ -9940,7 +9939,6 @@ static void i40e_remove(struct pci_dev *pdev)
 	}
 
 	kfree(pf->qp_pile);
-	kfree(pf->irq_pile);
 	kfree(pf->vsi);
 
 	iounmap(pf->hw.hw_addr);
-- 
1.9.3
