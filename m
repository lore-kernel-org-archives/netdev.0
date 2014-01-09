From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/15] i40e: Re-enable interrupt on ICR0
Date: Thu,  9 Jan 2014 04:52:10 -0800
Message-ID: <1389271944-26227-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1389271944-26227-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:49141 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754867AbaAIMw2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 07:52:28 -0500
In-Reply-To: <1389271944-26227-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

The hardware can occasionally give an interrupt on the misc
queue for which there is no driver work to do.  In that case
the driver was not re-enabling interrupts even though they
were auto masked by hardware.  This left interrupts disabled
on this queue.

Re-enable the interrupt whenever leaving this function.

Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index f736c44..38ec66f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2758,16 +2758,16 @@ static irqreturn_t i40e_intr(int irq, void *data)
 {
 	struct i40e_pf *pf = (struct i40e_pf *)data;
 	struct i40e_hw *hw = &pf->hw;
+	irqreturn_t ret = IRQ_NONE;
 	u32 icr0, icr0_remaining;
 	u32 val, ena_mask;
 
 	icr0 = rd32(hw, I40E_PFINT_ICR0);
+	ena_mask = rd32(hw, I40E_PFINT_ICR0_ENA);
 
 	/* if sharing a legacy IRQ, we might get called w/o an intr pending */
 	if ((icr0 & I40E_PFINT_ICR0_INTEVENT_MASK) == 0)
-		return IRQ_NONE;
-
-	ena_mask = rd32(hw, I40E_PFINT_ICR0_ENA);
+		goto enable_intr;
 
 	/* if interrupt but no bits showing, must be SWINT */
 	if (((icr0 & ~I40E_PFINT_ICR0_INTEVENT_MASK) == 0) ||
@@ -2843,7 +2843,9 @@ static irqreturn_t i40e_intr(int irq, void *data)
 		}
 		ena_mask &= ~icr0_remaining;
 	}
+	ret = IRQ_HANDLED;
 
+enable_intr:
 	/* re-enable interrupt causes */
 	wr32(hw, I40E_PFINT_ICR0_ENA, ena_mask);
 	if (!test_bit(__I40E_DOWN, &pf->state)) {
@@ -2851,7 +2853,7 @@ static irqreturn_t i40e_intr(int irq, void *data)
 		i40e_irq_dynamic_enable_icr0(pf);
 	}
 
-	return IRQ_HANDLED;
+	return ret;
 }
 
 /**
-- 
1.8.3.1
