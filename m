From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 04/11] ixgbe: delay tail write to every 'n' packets
Date: Sat, 29 Apr 2017 20:08:03 -0700
Message-ID: <20170430030810.56415-5-jeffrey.t.kirsher@intel.com>
References: <20170430030810.56415-1-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:34650 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S969705AbdD3DIR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 29 Apr 2017 23:08:17 -0400
In-Reply-To: <20170430030810.56415-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

Current XDP implementation hits the tail on every XDP_TX return
code. This patch changes driver behavior to only hit the tail after
packet processing is complete.

With this patch I can run XDP drop programs @ 14+Mpps and XDP_TX
programs are at ~13.5Mpps.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 28 ++++++++++++++++-----------
 1 file changed, 17 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index cb5be7de2c91..3d7b09100945 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2283,6 +2283,7 @@ static int ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 	unsigned int mss = 0;
 #endif /* IXGBE_FCOE */
 	u16 cleaned_count = ixgbe_desc_unused(rx_ring);
+	bool xdp_xmit = false;
 
 	while (likely(total_rx_packets < budget)) {
 		union ixgbe_adv_rx_desc *rx_desc;
@@ -2322,10 +2323,12 @@ static int ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 		}
 
 		if (IS_ERR(skb)) {
-			if (PTR_ERR(skb) == -IXGBE_XDP_TX)
+			if (PTR_ERR(skb) == -IXGBE_XDP_TX) {
+				xdp_xmit = true;
 				ixgbe_rx_buffer_flip(rx_ring, rx_buffer, size);
-			else
+			} else {
 				rx_buffer->pagecnt_bias++;
+			}
 			total_rx_packets++;
 			total_rx_bytes += size;
 		} else if (skb) {
@@ -2393,6 +2396,16 @@ static int ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 		total_rx_packets++;
 	}
 
+	if (xdp_xmit) {
+		struct ixgbe_ring *ring = adapter->xdp_ring[smp_processor_id()];
+
+		/* Force memory writes to complete before letting h/w
+		 * know there are new descriptors to fetch.
+		 */
+		wmb();
+		writel(ring->next_to_use, ring->tail);
+	}
+
 	u64_stats_update_begin(&rx_ring->syncp);
 	rx_ring->stats.packets += total_rx_packets;
 	rx_ring->stats.bytes += total_rx_bytes;
@@ -8238,14 +8251,8 @@ static int ixgbe_xmit_xdp_ring(struct ixgbe_adapter *adapter,
 	tx_desc->read.olinfo_status =
 		cpu_to_le32(len << IXGBE_ADVTXD_PAYLEN_SHIFT);
 
-	/* Force memory writes to complete before letting h/w know there
-	 * are new descriptors to fetch.  (Only applicable for weak-ordered
-	 * memory model archs, such as IA-64).
-	 *
-	 * We also need this memory barrier to make certain all of the
-	 * status bits have been updated before next_to_watch is written.
-	 */
-	wmb();
+	/* Avoid any potential race with xdp_xmit and cleanup */
+	smp_wmb();
 
 	/* set next_to_watch value indicating a packet is present */
 	i++;
@@ -8255,7 +8262,6 @@ static int ixgbe_xmit_xdp_ring(struct ixgbe_adapter *adapter,
 	tx_buffer->next_to_watch = tx_desc;
 	ring->next_to_use = i;
 
-	writel(i, ring->tail);
 	return IXGBE_XDP_TX;
 }
 
-- 
2.12.2
