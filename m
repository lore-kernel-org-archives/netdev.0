From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/18] i40e/i40evf: Fix handling of boolean logic in polling routines
Date: Tue,  5 Apr 2016 13:17:21 -0700
Message-ID: <1459887455-146634-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459887455-146634-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:10824 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759954AbcDEURj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 16:17:39 -0400
In-Reply-To: <1459887455-146634-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

In the polling routines for i40e and i40evf we were using bitwise operators
to avoid the side effects of the logical operators, specifically the fact
that if the first case is true with "||" we skip the second case, or if it
is false with "&&" we skip the second case.  This fixes an earlier patch
that converted the bitwise operators over to the logical operators and
instead replaces the entire thing with just an if statement since it should
be more readable what we are trying to do this way.

Fixes: 1a36d7fadd14 ("i40e/i40evf: use logical operators, not bitwise")
Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 13 ++++++++-----
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 13 ++++++++-----
 2 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 9af1411..8fb2a96 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1975,9 +1975,11 @@ int i40e_napi_poll(struct napi_struct *napi, int budget)
 	 * budget and be more aggressive about cleaning up the Tx descriptors.
 	 */
 	i40e_for_each_ring(ring, q_vector->tx) {
-		clean_complete = clean_complete &&
-				 i40e_clean_tx_irq(ring, vsi->work_limit);
-		arm_wb = arm_wb || ring->arm_wb;
+		if (!i40e_clean_tx_irq(ring, vsi->work_limit)) {
+			clean_complete = false;
+			continue;
+		}
+		arm_wb |= ring->arm_wb;
 		ring->arm_wb = false;
 	}
 
@@ -1999,8 +2001,9 @@ int i40e_napi_poll(struct napi_struct *napi, int budget)
 			cleaned = i40e_clean_rx_irq_1buf(ring, budget_per_ring);
 
 		work_done += cleaned;
-		/* if we didn't clean as many as budgeted, we must be done */
-		clean_complete = clean_complete && (budget_per_ring > cleaned);
+		/* if we clean as many as budgeted, we must not be done */
+		if (cleaned >= budget_per_ring)
+			clean_complete = false;
 	}
 
 	/* If work not completed, return budget and polling will return */
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 5f9c1bb..839a6df 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1411,9 +1411,11 @@ int i40evf_napi_poll(struct napi_struct *napi, int budget)
 	 * budget and be more aggressive about cleaning up the Tx descriptors.
 	 */
 	i40e_for_each_ring(ring, q_vector->tx) {
-		clean_complete = clean_complete &&
-				 i40e_clean_tx_irq(ring, vsi->work_limit);
-		arm_wb = arm_wb || ring->arm_wb;
+		if (!i40e_clean_tx_irq(ring, vsi->work_limit)) {
+			clean_complete = false;
+			continue;
+		}
+		arm_wb |= ring->arm_wb;
 		ring->arm_wb = false;
 	}
 
@@ -1435,8 +1437,9 @@ int i40evf_napi_poll(struct napi_struct *napi, int budget)
 			cleaned = i40e_clean_rx_irq_1buf(ring, budget_per_ring);
 
 		work_done += cleaned;
-		/* if we didn't clean as many as budgeted, we must be done */
-		clean_complete = clean_complete && (budget_per_ring > cleaned);
+		/* if we clean as many as budgeted, we must not be done */
+		if (cleaned >= budget_per_ring)
+			clean_complete = false;
 	}
 
 	/* If work not completed, return budget and polling will return */
-- 
2.5.5
