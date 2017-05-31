From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/9] i40e: avoid permanent lock of *_PTP_TX_IN_PROGRESS
Date: Wed, 31 May 2017 03:48:52 -0700
Message-ID: <20170531104856.47929-6-jeffrey.t.kirsher@intel.com>
References: <20170531104856.47929-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:32543 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751125AbdEaKtC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 May 2017 06:49:02 -0400
In-Reply-To: <20170531104856.47929-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The i40e driver uses a bit lock to indicate when a Tx timestamp is in
progress to avoid attempting to timestamp multiple packets at once. This
is required because hardware only has registers to handle one request at
a time.

There is a corner case where we failed to cleanup the bit lock after
a failed transmit. This can potentially result in a state bit being
locked forever.

Add some cleanup code to i40e_xmit_frame_ring to check and make sure we
cleanup incase of these failures. We also modify i40e_tx_map to return
an error code indication DMA failure.

Reported-by: Reported-by: David Mirabito <davidm@metamako.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 26 ++++++++++++++++++++------
 1 file changed, 20 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 29321a6167a6..19984be0f70c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2932,10 +2932,12 @@ bool __i40e_chk_linearize(struct sk_buff *skb)
  * @hdr_len:  size of the packet header
  * @td_cmd:   the command field in the descriptor
  * @td_offset: offset for checksum or crc
+ *
+ * Returns 0 on success, -1 on failure to DMA
  **/
-static inline void i40e_tx_map(struct i40e_ring *tx_ring, struct sk_buff *skb,
-			       struct i40e_tx_buffer *first, u32 tx_flags,
-			       const u8 hdr_len, u32 td_cmd, u32 td_offset)
+static inline int i40e_tx_map(struct i40e_ring *tx_ring, struct sk_buff *skb,
+			      struct i40e_tx_buffer *first, u32 tx_flags,
+			      const u8 hdr_len, u32 td_cmd, u32 td_offset)
 {
 	unsigned int data_len = skb->data_len;
 	unsigned int size = skb_headlen(skb);
@@ -3093,7 +3095,7 @@ static inline void i40e_tx_map(struct i40e_ring *tx_ring, struct sk_buff *skb,
 		mmiowb();
 	}
 
-	return;
+	return 0;
 
 dma_error:
 	dev_info(tx_ring->dev, "TX DMA map failed\n");
@@ -3110,6 +3112,8 @@ static inline void i40e_tx_map(struct i40e_ring *tx_ring, struct sk_buff *skb,
 	}
 
 	tx_ring->next_to_use = i;
+
+	return -1;
 }
 
 /**
@@ -3210,8 +3214,9 @@ static netdev_tx_t i40e_xmit_frame_ring(struct sk_buff *skb,
 	 */
 	i40e_atr(tx_ring, skb, tx_flags);
 
-	i40e_tx_map(tx_ring, skb, first, tx_flags, hdr_len,
-		    td_cmd, td_offset);
+	if (i40e_tx_map(tx_ring, skb, first, tx_flags, hdr_len,
+			td_cmd, td_offset))
+		goto cleanup_tx_tstamp;
 
 	return NETDEV_TX_OK;
 
@@ -3219,6 +3224,15 @@ static netdev_tx_t i40e_xmit_frame_ring(struct sk_buff *skb,
 	i40e_trace(xmit_frame_ring_drop, first->skb, tx_ring);
 	dev_kfree_skb_any(first->skb);
 	first->skb = NULL;
+cleanup_tx_tstamp:
+	if (unlikely(tx_flags & I40E_TX_FLAGS_TSYN)) {
+		struct i40e_pf *pf = i40e_netdev_to_pf(tx_ring->netdev);
+
+		dev_kfree_skb_any(pf->ptp_tx_skb);
+		pf->ptp_tx_skb = NULL;
+		clear_bit_unlock(__I40E_PTP_TX_IN_PROGRESS, pf->state);
+	}
+
 	return NETDEV_TX_OK;
 }
 
-- 
2.12.2
