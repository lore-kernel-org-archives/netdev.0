From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v5 03/17] i40e: Suppress HMC error to Interrupt message level
Date: Fri,  3 Jan 2014 21:56:31 -0800
Message-ID: <1388815005-23166-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1388815005-23166-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Shannon Nelson <shannon.nelson@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:31987 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751852AbaADF4w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Jan 2014 00:56:52 -0500
In-Reply-To: <1388815005-23166-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

The HMC error interrupt would generate an un-necessary message
"unhandled interrupt", causing extra log spam, in addition to causing
a reset that was not necessary.  Prevent this issue by handling the
HMC error case explicitly, and only reset if the interrupt was from
some of the other causes.

Change-Id: Iabd203ba1dfc26a136b638597f3e9991acfa29f3
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index efdf8a2..f14b31c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2814,6 +2814,11 @@ static irqreturn_t i40e_intr(int irq, void *data)
 			pf->empr_count++;
 	}
 
+	if (icr0 & I40E_PFINT_ICR0_HMC_ERR_MASK) {
+		icr0 &= ~I40E_PFINT_ICR0_HMC_ERR_MASK;
+		dev_info(&pf->pdev->dev, "HMC error interrupt\n");
+	}
+
 	/* If a critical error is pending we have no choice but to reset the
 	 * device.
 	 * Report and mask out any remaining unexpected interrupts.
@@ -2822,18 +2827,13 @@ static irqreturn_t i40e_intr(int irq, void *data)
 	if (icr0_remaining) {
 		dev_info(&pf->pdev->dev, "unhandled interrupt icr0=0x%08x\n",
 			 icr0_remaining);
-		if ((icr0_remaining & I40E_PFINT_ICR0_HMC_ERR_MASK) ||
-		    (icr0_remaining & I40E_PFINT_ICR0_PE_CRITERR_MASK) ||
+		if ((icr0_remaining & I40E_PFINT_ICR0_PE_CRITERR_MASK) ||
 		    (icr0_remaining & I40E_PFINT_ICR0_PCI_EXCEPTION_MASK) ||
 		    (icr0_remaining & I40E_PFINT_ICR0_ECC_ERR_MASK) ||
 		    (icr0_remaining & I40E_PFINT_ICR0_MAL_DETECT_MASK)) {
-			if (icr0 & I40E_PFINT_ICR0_HMC_ERR_MASK) {
-				dev_info(&pf->pdev->dev, "HMC error interrupt\n");
-			} else {
-				dev_info(&pf->pdev->dev, "device will be reset\n");
-				set_bit(__I40E_PF_RESET_REQUESTED, &pf->state);
-				i40e_service_event_schedule(pf);
-			}
+			dev_info(&pf->pdev->dev, "device will be reset\n");
+			set_bit(__I40E_PF_RESET_REQUESTED, &pf->state);
+			i40e_service_event_schedule(pf);
 		}
 		ena_mask &= ~icr0_remaining;
 	}
-- 
1.8.3.1
