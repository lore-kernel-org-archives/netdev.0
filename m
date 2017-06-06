From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/11] igb: avoid permanent lock of *_PTP_TX_IN_PROGRESS
Date: Tue,  6 Jun 2017 01:58:03 -0700
Message-ID: <20170606085809.78571-6-jeffrey.t.kirsher@intel.com>
References: <20170606085809.78571-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:20068 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751423AbdFFI6Q (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Jun 2017 04:58:16 -0400
In-Reply-To: <20170606085809.78571-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The igb driver uses a state bit lock to avoid handling more than one Tx
timestamp request at once. This is required because hardware is limited
to a single set of registers for Tx timestamps.

The state bit lock is not properly cleaned up during
igb_xmit_frame_ring() if the transmit fails such as due to DMA or TSO
failure. In some hardware this results in blocking timestamps until the
service task times out. In other hardware this results in a permanent
lock of the timestamp bit because we never receive an interrupt
indicating the timestamp occurred, since indeed the packet was never
transmitted.

Fix this by checking for DMA and TSO errors in igb_xmit_frame_ring() and
properly cleaning up after ourselves when these occur.

Reported-by: Reported-by: David Mirabito <davidm@metamako.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 23 ++++++++++++++++++-----
 1 file changed, 18 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 2d5bdb1fd37d..fefa46120cbc 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -5197,9 +5197,9 @@ static inline int igb_maybe_stop_tx(struct igb_ring *tx_ring, const u16 size)
 	return __igb_maybe_stop_tx(tx_ring, size);
 }
 
-static void igb_tx_map(struct igb_ring *tx_ring,
-		       struct igb_tx_buffer *first,
-		       const u8 hdr_len)
+static int igb_tx_map(struct igb_ring *tx_ring,
+		      struct igb_tx_buffer *first,
+		      const u8 hdr_len)
 {
 	struct sk_buff *skb = first->skb;
 	struct igb_tx_buffer *tx_buffer;
@@ -5310,7 +5310,7 @@ static void igb_tx_map(struct igb_ring *tx_ring,
 		 */
 		mmiowb();
 	}
-	return;
+	return 0;
 
 dma_error:
 	dev_err(tx_ring->dev, "TX DMA map failed\n");
@@ -5341,6 +5341,8 @@ static void igb_tx_map(struct igb_ring *tx_ring,
 	tx_buffer->skb = NULL;
 
 	tx_ring->next_to_use = i;
+
+	return -1;
 }
 
 netdev_tx_t igb_xmit_frame_ring(struct sk_buff *skb,
@@ -5406,13 +5408,24 @@ netdev_tx_t igb_xmit_frame_ring(struct sk_buff *skb,
 	else if (!tso)
 		igb_tx_csum(tx_ring, first);
 
-	igb_tx_map(tx_ring, first, hdr_len);
+	if (igb_tx_map(tx_ring, first, hdr_len))
+		goto cleanup_tx_tstamp;
 
 	return NETDEV_TX_OK;
 
 out_drop:
 	dev_kfree_skb_any(first->skb);
 	first->skb = NULL;
+cleanup_tx_tstamp:
+	if (unlikely(tx_flags & IGB_TX_FLAGS_TSTAMP)) {
+		struct igb_adapter *adapter = netdev_priv(tx_ring->netdev);
+
+		dev_kfree_skb_any(adapter->ptp_tx_skb);
+		adapter->ptp_tx_skb = NULL;
+		if (adapter->hw.mac.type == e1000_82576)
+			cancel_work_sync(&adapter->ptp_tx_work);
+		clear_bit_unlock(__IGB_PTP_TX_IN_PROGRESS, &adapter->state);
+	}
 
 	return NETDEV_TX_OK;
 }
-- 
2.12.2
