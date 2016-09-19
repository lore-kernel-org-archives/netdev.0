From: Stefan Assmann <sassmann@kpanic.de>
Subject: [PATCH net-next 2/3] i40e: fix MSI-X vector redistribution if hw limit is reached
Date: Mon, 19 Sep 2016 13:37:50 +0200
Message-ID: <1474285071-28218-3-git-send-email-sassmann@kpanic.de>
References: <1474285071-28218-1-git-send-email-sassmann@kpanic.de>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        jeffrey.t.kirsher@intel.com, sassmann@kpanic.de
To: intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38048 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753895AbcISLiW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Sep 2016 07:38:22 -0400
In-Reply-To: <1474285071-28218-1-git-send-email-sassmann@kpanic.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver allocates 1 vector per CPU thread and the current hardware
limit for vectors is 129 per PF. On systems with 128 or more threads
this currently means all vectors are used by the PF leaving no room for
additional features like VMDq, iWARP, etc...
The code that should redistribute the vectors in this case is broken and
never triggers. Fixed the code so that it actually triggers if the
hardware limit is reached and adjust the number of queue pairs
accordingly.
Also the number of initially requested iWARP vectors was not properly
saved when the vector limit was reached, and therefore always zero.

Comparison with debug statement.
Before:
i40e 0000:2d:00.0: VMDq disabled, not enough MSI-X vectors
i40e 0000:2d:00.0: IWARP disabled, not enough MSI-X vectors
i40e 00.0 MSI-X vector distribution: PF 128, VMDq 0, FDSB 0, iWARP 0
After:
i40e 0000:2d:00.0: MSI-X vector limit reached, attempting to redistribute vectors
i40e 00.0 MSI-X vector distribution: PF 78, VMDq 8, FDSB 0, iWARP 42

Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 38 +++++++++++++++++------------
 1 file changed, 22 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 5f3f1c8..4727c02 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7665,6 +7665,8 @@ static int i40e_init_msix(struct i40e_pf *pf)
 #endif
 	/* can we reserve enough for iWARP? */
 	if (pf->flags & I40E_FLAG_IWARP_ENABLED) {
+		iwarp_requested = pf->num_iwarp_msix;
+
 		if (!vectors_left)
 			pf->num_iwarp_msix = 0;
 		else if (vectors_left < pf->num_iwarp_msix)
@@ -7706,21 +7708,6 @@ static int i40e_init_msix(struct i40e_pf *pf)
 		pf->msix_entries[i].entry = i;
 	v_actual = i40e_reserve_msix_vectors(pf, v_budget);
 
-	if (v_actual != v_budget) {
-		/* If we have limited resources, we will start with no vectors
-		 * for the special features and then allocate vectors to some
-		 * of these features based on the policy and at the end disable
-		 * the features that did not get any vectors.
-		 */
-		iwarp_requested = pf->num_iwarp_msix;
-		pf->num_iwarp_msix = 0;
-#ifdef I40E_FCOE
-		pf->num_fcoe_qps = 0;
-		pf->num_fcoe_msix = 0;
-#endif
-		pf->num_vmdq_msix = 0;
-	}
-
 	if (v_actual < I40E_MIN_MSIX) {
 		pf->flags &= ~I40E_FLAG_MSIX_ENABLED;
 		kfree(pf->msix_entries);
@@ -7734,9 +7721,16 @@ static int i40e_init_msix(struct i40e_pf *pf)
 		pf->num_lan_qps = 1;
 		pf->num_lan_msix = 1;
 
-	} else if (v_actual != v_budget) {
+	} else if (!vectors_left) {
+		/* If we have limited resources, we will start with no vectors
+		 * for the special features and then allocate vectors to some
+		 * of these features based on the policy and at the end disable
+		 * the features that did not get any vectors.
+		 */
 		int vec;
 
+		dev_info(&pf->pdev->dev,
+			 "MSI-X vector limit reached, attempting to redistribute vectors\n");
 		/* reserve the misc vector */
 		vec = v_actual - 1;
 
@@ -7744,6 +7738,10 @@ static int i40e_init_msix(struct i40e_pf *pf)
 		pf->num_vmdq_msix = 1;    /* force VMDqs to only one vector */
 		pf->num_vmdq_vsis = 1;
 		pf->num_vmdq_qps = 1;
+#ifdef I40E_FCOE
+		pf->num_fcoe_qps = 0;
+		pf->num_fcoe_msix = 0;
+#endif
 		pf->flags &= ~I40E_FLAG_FD_SB_ENABLED;
 
 		/* partition out the remaining vectors */
@@ -7779,6 +7777,7 @@ static int i40e_init_msix(struct i40e_pf *pf)
 			pf->num_lan_msix = min_t(int,
 			       (vec - (pf->num_iwarp_msix + pf->num_vmdq_vsis)),
 							      pf->num_lan_msix);
+			pf->num_lan_qps = pf->num_lan_msix;
 #ifdef I40E_FCOE
 			/* give one vector to FCoE */
 			if (pf->flags & I40E_FLAG_FCOE_ENABLED) {
@@ -7808,6 +7807,13 @@ static int i40e_init_msix(struct i40e_pf *pf)
 		pf->flags &= ~I40E_FLAG_FCOE_ENABLED;
 	}
 #endif
+	i40e_debug(&pf->hw, I40E_DEBUG_INIT,
+		   "MSI-X vector distribution: PF %d, VMDq %d, FDSB %d, iWARP %d\n",
+		   pf->num_lan_msix,
+		   pf->num_vmdq_msix * pf->num_vmdq_vsis,
+		   pf->num_fdsb_msix,
+		   pf->num_iwarp_msix);
+
 	return v_actual;
 }
 
-- 
2.7.4
