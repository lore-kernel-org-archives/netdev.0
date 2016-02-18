From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/15] i40e: Do not disable queues in the Legacy/MSI Interrupt handler
Date: Thu, 18 Feb 2016 01:04:06 -0800
Message-ID: <1455786252-71881-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455786252-71881-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:39536 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1425720AbcBRJEd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 04:04:33 -0500
In-Reply-To: <1455786252-71881-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

The queues should never be enabled/disabled in the interrupt handler,
ICR0 interrupt enable should be the only thing that needs to be
dynamically changed in the handler.

This patch fixes that. Without this patch X722 platforms were
seeing weird ping timings when in Legacy mode since it takes
a whole lot of time for the HW/FW to re-enable queues.

Change-ID: If065afc45d81c5a19d4a94a00cd5b8f61cefc40c
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 16 ++++++----------
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 13 -------------
 2 files changed, 6 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index adb2a04..7869d74 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -3462,16 +3462,12 @@ static irqreturn_t i40e_intr(int irq, void *data)
 		struct i40e_vsi *vsi = pf->vsi[pf->lan_vsi];
 		struct i40e_q_vector *q_vector = vsi->q_vectors[0];
 
-		/* temporarily disable queue cause for NAPI processing */
-		u32 qval = rd32(hw, I40E_QINT_RQCTL(0));
-
-		qval &= ~I40E_QINT_RQCTL_CAUSE_ENA_MASK;
-		wr32(hw, I40E_QINT_RQCTL(0), qval);
-
-		qval = rd32(hw, I40E_QINT_TQCTL(0));
-		qval &= ~I40E_QINT_TQCTL_CAUSE_ENA_MASK;
-		wr32(hw, I40E_QINT_TQCTL(0), qval);
-
+		/* We do not have a way to disarm Queue causes while leaving
+		 * interrupt enabled for all other causes, ideally
+		 * interrupt should be disabled while we are in NAPI but
+		 * this is not a performance path and napi_schedule()
+		 * can deal with rescheduling.
+		 */
 		if (!test_bit(__I40E_DOWN, &pf->state))
 			napi_schedule_irqoff(&q_vector->napi);
 	}
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 25e378c..65f2fd8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2051,19 +2051,6 @@ tx_only:
 	if (vsi->back->flags & I40E_FLAG_MSIX_ENABLED) {
 		i40e_update_enable_itr(vsi, q_vector);
 	} else { /* Legacy mode */
-		struct i40e_hw *hw = &vsi->back->hw;
-		/* We re-enable the queue 0 cause, but
-		 * don't worry about dynamic_enable
-		 * because we left it on for the other
-		 * possible interrupts during napi
-		 */
-		u32 qval = rd32(hw, I40E_QINT_RQCTL(0)) |
-			   I40E_QINT_RQCTL_CAUSE_ENA_MASK;
-
-		wr32(hw, I40E_QINT_RQCTL(0), qval);
-		qval = rd32(hw, I40E_QINT_TQCTL(0)) |
-		       I40E_QINT_TQCTL_CAUSE_ENA_MASK;
-		wr32(hw, I40E_QINT_TQCTL(0), qval);
 		i40e_irq_dynamic_enable_icr0(vsi->back, false);
 	}
 	return 0;
-- 
2.5.0
