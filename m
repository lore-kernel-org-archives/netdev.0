From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/10] ixgbe: Update layout of ixgbe_ring structure to improve cache performance
Date: Mon, 19 Mar 2012 14:22:30 -0700
Message-ID: <1332192158-14771-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1332192158-14771-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:11090 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755197Ab2CSVWm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Mar 2012 17:22:42 -0400
In-Reply-To: <1332192158-14771-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change makes it so that only the 2nd cache line in the ring structure
should see frequent updates.  The advantage to this is that it should
reduce the amount of cross CPU cache bouncing since only the 2nd cache line
will be changing between most network transactions.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 468cb90..8620414 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -208,15 +208,18 @@ enum ixgbe_ring_state_t {
 	clear_bit(__IXGBE_RX_RSC_ENABLED, &(ring)->state)
 struct ixgbe_ring {
 	struct ixgbe_ring *next;	/* pointer to next ring in q_vector */
+	struct ixgbe_q_vector *q_vector; /* backpointer to host q_vector */
+	struct net_device *netdev;	/* netdev ring belongs to */
+	struct device *dev;		/* device for DMA mapping */
 	void *desc;			/* descriptor ring memory */
-	struct device *dev;             /* device for DMA mapping */
-	struct net_device *netdev;      /* netdev ring belongs to */
 	union {
 		struct ixgbe_tx_buffer *tx_buffer_info;
 		struct ixgbe_rx_buffer *rx_buffer_info;
 	};
 	unsigned long state;
 	u8 __iomem *tail;
+	dma_addr_t dma;			/* phys. address of descriptor ring */
+	unsigned int size;		/* length in bytes */
 
 	u16 count;			/* amount of descriptors */
 
@@ -226,17 +229,17 @@ struct ixgbe_ring {
 					 * associated with this ring, which is
 					 * different for DCB and RSS modes
 					 */
+	u16 next_to_use;
+	u16 next_to_clean;
+
 	union {
+		u16 next_to_alloc;
 		struct {
 			u8 atr_sample_rate;
 			u8 atr_count;
 		};
-		u16 next_to_alloc;
 	};
 
-	u16 next_to_use;
-	u16 next_to_clean;
-
 	u8 dcb_tc;
 	struct ixgbe_queue_stats stats;
 	struct u64_stats_sync syncp;
@@ -244,9 +247,6 @@ struct ixgbe_ring {
 		struct ixgbe_tx_queue_stats tx_stats;
 		struct ixgbe_rx_queue_stats rx_stats;
 	};
-	unsigned int size;		/* length in bytes */
-	dma_addr_t dma;			/* phys. address of descriptor ring */
-	struct ixgbe_q_vector *q_vector; /* back-pointer to host q_vector */
 } ____cacheline_internodealigned_in_smp;
 
 enum ixgbe_ring_f_enum {
-- 
1.7.7.6
