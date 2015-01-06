From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/3] i40e: fix un-necessary Tx hangs
Date: Tue,  6 Jan 2015 00:44:22 -0800
Message-ID: <1420533864-13125-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1420533864-13125-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:24564 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752802AbbAFIo1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2015 03:44:27 -0500
In-Reply-To: <1420533864-13125-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

When the driver was polling with interrupts disabled the hardware
will occasionally not write back descriptors.  This patch causes
the driver to detect this situation and force an interrupt to
fire which will flush the stuck descriptor.  Does not conflict
with NAPI because if we are already polling the napi_schedule is
ignored.  Additionally the extra interrupts are rate limited, so
don't cause a burden to the CPU.

Change-ID: Iba4616d2a71288672a5f08e4512e2704b97335e8
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 35 ++++++++++++++++++++++++-----
 1 file changed, 29 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 04b4414..9995598 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -658,6 +658,8 @@ static inline u32 i40e_get_head(struct i40e_ring *tx_ring)
 	return le32_to_cpu(*(volatile __le32 *)head);
 }
 
+#define WB_STRIDE 0x3
+
 /**
  * i40e_clean_tx_irq - Reclaim resources after transmit completes
  * @tx_ring:  tx ring to clean
@@ -759,6 +761,25 @@ static bool i40e_clean_tx_irq(struct i40e_ring *tx_ring, int budget)
 	tx_ring->q_vector->tx.total_bytes += total_bytes;
 	tx_ring->q_vector->tx.total_packets += total_packets;
 
+	/* check to see if there are any non-cache aligned descriptors
+	 * waiting to be written back, and kick the hardware to force
+	 * them to be written back in case of napi polling
+	 */
+	if (budget &&
+	    !((i & WB_STRIDE) == WB_STRIDE) &&
+	    !test_bit(__I40E_DOWN, &tx_ring->vsi->state) &&
+	    (I40E_DESC_UNUSED(tx_ring) != tx_ring->count)) {
+		u32 val = I40E_PFINT_DYN_CTLN_INTENA_MASK |
+			  I40E_PFINT_DYN_CTLN_SWINT_TRIG_MASK |
+			  I40E_PFINT_DYN_CTLN_SW_ITR_INDX_ENA_MASK;
+			  /* allow 00 to be written to the index */
+
+		wr32(&tx_ring->vsi->back->hw,
+		     I40E_PFINT_DYN_CTLN(tx_ring->q_vector->v_idx +
+					 tx_ring->vsi->base_vector - 1),
+		     val);
+	}
+
 	if (check_for_tx_hang(tx_ring) && i40e_check_tx_hang(tx_ring)) {
 		/* schedule immediate reset if we believe we hung */
 		dev_info(tx_ring->dev, "Detected Tx Unit Hang\n"
@@ -777,13 +798,16 @@ static bool i40e_clean_tx_irq(struct i40e_ring *tx_ring, int budget)
 		netif_stop_subqueue(tx_ring->netdev, tx_ring->queue_index);
 
 		dev_info(tx_ring->dev,
-			 "tx hang detected on queue %d, resetting adapter\n",
+			 "tx hang detected on queue %d, reset requested\n",
 			 tx_ring->queue_index);
 
-		tx_ring->netdev->netdev_ops->ndo_tx_timeout(tx_ring->netdev);
+		/* do not fire the reset immediately, wait for the stack to
+		 * decide we are truly stuck, also prevents every queue from
+		 * simultaneously requesting a reset
+		 */
 
-		/* the adapter is about to reset, no point in enabling stuff */
-		return true;
+		/* the adapter is about to reset, no point in enabling polling */
+		budget = 1;
 	}
 
 	netdev_tx_completed_queue(netdev_get_tx_queue(tx_ring->netdev,
@@ -806,7 +830,7 @@ static bool i40e_clean_tx_irq(struct i40e_ring *tx_ring, int budget)
 		}
 	}
 
-	return budget > 0;
+	return !!budget;
 }
 
 /**
@@ -2198,7 +2222,6 @@ static void i40e_tx_map(struct i40e_ring *tx_ring, struct sk_buff *skb,
 	/* Place RS bit on last descriptor of any packet that spans across the
 	 * 4th descriptor (WB_STRIDE aka 0x3) in a 64B cacheline.
 	 */
-#define WB_STRIDE 0x3
 	if (((i & WB_STRIDE) != WB_STRIDE) &&
 	    (first <= &tx_ring->tx_bi[i]) &&
 	    (first >= &tx_ring->tx_bi[i & ~WB_STRIDE])) {
-- 
1.9.3
