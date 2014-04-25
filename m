From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net] i40e: fix Timesync Tx interrupt handler code
Date: Thu, 24 Apr 2014 18:05:03 -0700
Message-ID: <1398387903-30502-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:17595 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751395AbaDYBFH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2014 21:05:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch fixes the PTP Tx timestamp interrupt handler. The original
code misinterpreted the interrupt handler design. We were clearing the
ena_mask bit for the Timesync interrupts. This is done to indicate that
the interrupt will be handled in a scheduled work item (instead of
immediately) and that work item is responsible for re-enabling the
interrupts. However, the Tx timestamp was being handled immediately and
nothing was ever re-enabling it. This resulted in a single interrupt
working for the life of the driver.

This patch fixes the issue by instead clearing the bit from icr0 which
is used to indicate that the interrupt was immediately handled and can
be re-enabled right away. This patch also clears up a related issue due
to writing the PRTTSYN_STAT_0 register, which was unintentionally
clearing the cause bits for Timesync interrupts.

Change-ID: I057bd70d53c302f60fab78246989cbdfa469d83b
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Acked-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Acked-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 59eada3..cf0761f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2897,12 +2897,9 @@ static irqreturn_t i40e_intr(int irq, void *data)
 		u32 prttsyn_stat = rd32(hw, I40E_PRTTSYN_STAT_0);
 
 		if (prttsyn_stat & I40E_PRTTSYN_STAT_0_TXTIME_MASK) {
-			ena_mask &= ~I40E_PFINT_ICR0_ENA_TIMESYNC_MASK;
+			icr0 &= ~I40E_PFINT_ICR0_ENA_TIMESYNC_MASK;
 			i40e_ptp_tx_hwtstamp(pf);
-			prttsyn_stat &= ~I40E_PRTTSYN_STAT_0_TXTIME_MASK;
 		}
-
-		wr32(hw, I40E_PRTTSYN_STAT_0, prttsyn_stat);
 	}
 
 	/* If a critical error is pending we have no choice but to reset the
-- 
1.9.0
