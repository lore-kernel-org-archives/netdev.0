From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next  04/14] i40e: fixup legacy interrupt handling
Date: Fri, 18 Oct 2013 06:23:08 -0700
Message-ID: <1382102598-11343-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1382102598-11343-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: a@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:41263 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754461Ab3JRNXl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Oct 2013 09:23:41 -0400
In-Reply-To: <1382102598-11343-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

There were a number of little bugs in the error handling of irq setup, most of
which ended up panicing the kernel, and are addressed by this patch, along with
a couple formatting issues.

Legacy interrupts (including MSI) are used only in the case of failure to
allocate MSI-X interrupts.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index a8c18fa..270190a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4615,7 +4615,8 @@ static void i40e_fdir_setup(struct i40e_pf *pf)
 	bool new_vsi = false;
 	int err, i;
 
-	if (!(pf->flags & (I40E_FLAG_FDIR_ENABLED|I40E_FLAG_FDIR_ATR_ENABLED)))
+	if (!(pf->flags & (I40E_FLAG_FDIR_ENABLED |
+			   I40E_FLAG_FDIR_ATR_ENABLED)))
 		return;
 
 	pf->atr_sample_rate = I40E_DEFAULT_ATR_SAMPLE_RATE;
@@ -5435,7 +5436,8 @@ static void i40e_init_interrupt_scheme(struct i40e_pf *pf)
 	if (pf->flags & I40E_FLAG_MSIX_ENABLED) {
 		err = i40e_init_msix(pf);
 		if (err) {
-			pf->flags &= ~(I40E_FLAG_RSS_ENABLED	   |
+			pf->flags &= ~(I40E_FLAG_MSIX_ENABLED	   |
+					I40E_FLAG_RSS_ENABLED	   |
 					I40E_FLAG_MQ_ENABLED	   |
 					I40E_FLAG_DCB_ENABLED	   |
 					I40E_FLAG_SRIOV_ENABLED	   |
@@ -5450,14 +5452,17 @@ static void i40e_init_interrupt_scheme(struct i40e_pf *pf)
 
 	if (!(pf->flags & I40E_FLAG_MSIX_ENABLED) &&
 	    (pf->flags & I40E_FLAG_MSI_ENABLED)) {
+		dev_info(&pf->pdev->dev, "MSIX not available, trying MSI\n");
 		err = pci_enable_msi(pf->pdev);
 		if (err) {
-			dev_info(&pf->pdev->dev,
-				 "MSI init failed (%d), trying legacy.\n", err);
+			dev_info(&pf->pdev->dev, "MSI init failed - %d\n", err);
 			pf->flags &= ~I40E_FLAG_MSI_ENABLED;
 		}
 	}
 
+	if (!(pf->flags & (I40E_FLAG_MSIX_ENABLED | I40E_FLAG_MSI_ENABLED)))
+		dev_info(&pf->pdev->dev, "MSIX and MSI not available, falling back to Legacy IRQ\n");
+
 	/* track first vector for misc interrupts */
 	err = i40e_get_lump(pf, pf->irq_pile, 1, I40E_PILE_VALID_BIT-1);
 }
@@ -6110,8 +6115,9 @@ static int i40e_vsi_setup_vectors(struct i40e_vsi *vsi)
 		goto vector_setup_out;
 	}
 
-	vsi->base_vector = i40e_get_lump(pf, pf->irq_pile,
-					 vsi->num_q_vectors, vsi->idx);
+	if (vsi->num_q_vectors)
+		vsi->base_vector = i40e_get_lump(pf, pf->irq_pile,
+						 vsi->num_q_vectors, vsi->idx);
 	if (vsi->base_vector < 0) {
 		dev_info(&pf->pdev->dev,
 			 "failed to get q tracking for VSI %d, err=%d\n",
-- 
1.8.3.1
