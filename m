From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 4/4] ixgbe: Remove tail write abstraction and add
 missing barrier
Date: Thu, 13 Nov 2014 08:18:39 -0800
Message-ID: <20141113161839.2790.51764.stgit@ahduyck-vm-fedora20>
References: <20141113161148.2790.22082.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Don Skidmore <donald.c.skidmore@intel.com>,
	jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51252 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753304AbaKMQSo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Nov 2014 11:18:44 -0500
In-Reply-To: <20141113161148.2790.22082.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change cleans up the tail writes for the ixgbe descriptor queues.  The
current implementation had me confused as I wasn't sure if it was still
making use of the suprise remove logic or not.

It also adds the mmiowb which is needed on ia64, mips, and a couple other
architectures in order to synchronize the MMIO writes with the Tx queue
_xmit_lock spinlock.

Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |    5 ---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   40 +++++++++++++------------
 2 files changed, 20 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 5032a60..86fa607 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -553,11 +553,6 @@ static inline u16 ixgbe_desc_unused(struct ixgbe_ring *ring)
 	return ((ntc > ntu) ? 0 : ring->count) + ntc - ntu - 1;
 }
 
-static inline void ixgbe_write_tail(struct ixgbe_ring *ring, u32 value)
-{
-	writel(value, ring->tail);
-}
-
 #define IXGBE_RX_DESC(R, i)	    \
 	(&(((union ixgbe_adv_rx_desc *)((R)->desc))[i]))
 #define IXGBE_TX_DESC(R, i)	    \
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index a72c852..6b29dfe 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1416,22 +1416,6 @@ static inline void ixgbe_rx_checksum(struct ixgbe_ring *ring,
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 }
 
-static inline void ixgbe_release_rx_desc(struct ixgbe_ring *rx_ring, u32 val)
-{
-	rx_ring->next_to_use = val;
-
-	/* update next to alloc since we have filled the ring */
-	rx_ring->next_to_alloc = val;
-	/*
-	 * Force memory writes to complete before letting h/w
-	 * know there are new descriptors to fetch.  (Only
-	 * applicable for weak-ordered memory model archs,
-	 * such as IA-64).
-	 */
-	wmb();
-	ixgbe_write_tail(rx_ring, val);
-}
-
 static bool ixgbe_alloc_mapped_page(struct ixgbe_ring *rx_ring,
 				    struct ixgbe_rx_buffer *bi)
 {
@@ -1517,8 +1501,20 @@ void ixgbe_alloc_rx_buffers(struct ixgbe_ring *rx_ring, u16 cleaned_count)
 
 	i += rx_ring->count;
 
-	if (rx_ring->next_to_use != i)
-		ixgbe_release_rx_desc(rx_ring, i);
+	if (rx_ring->next_to_use != i) {
+		rx_ring->next_to_use = i;
+
+		/* update next to alloc since we have filled the ring */
+		rx_ring->next_to_alloc = i;
+
+		/* Force memory writes to complete before letting h/w
+		 * know there are new descriptors to fetch.  (Only
+		 * applicable for weak-ordered memory model archs,
+		 * such as IA-64).
+		 */
+		wmb();
+		writel(i, rx_ring->tail);
+	}
 }
 
 static void ixgbe_set_rsc_gso_size(struct ixgbe_ring *ring,
@@ -6955,8 +6951,12 @@ static void ixgbe_tx_map(struct ixgbe_ring *tx_ring,
 	ixgbe_maybe_stop_tx(tx_ring, DESC_NEEDED);
 
 	if (netif_xmit_stopped(txring_txq(tx_ring)) || !skb->xmit_more) {
-		/* notify HW of packet */
-		ixgbe_write_tail(tx_ring, i);
+		writel(i, tx_ring->tail);
+
+		/* we need this if more than one processor can write to our tail
+		 * at a time, it synchronizes IO on IA64/Altix systems
+		 */
+		mmiowb();
 	}
 
 	return;
