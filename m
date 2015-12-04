From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/17] fm10k: Update adaptive ITR algorithm
Date: Thu,  3 Dec 2015 16:29:50 -0800
Message-ID: <1449188994-64940-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449188994-64940-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:14336 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754370AbbLDA36 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 19:29:58 -0500
In-Reply-To: <1449188994-64940-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The existing adaptive ITR algorithm is overly restrictive. It throttles
incorrectly for various traffic rates, and does not produce good
performance. The algorithm now allows for more interrupts per second,
and does some calculation to help improve for smaller packet loads. In
addition, take into account the new itr_scale from the hardware which
indicates how much to scale due to PCIe link speed.

Reported-by: Matthew Vick <matthew.vick@intel.com>
Reported-by: Alex Duyck <alexander.duyck@gmail.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k.h      |  1 +
 drivers/net/ethernet/intel/fm10k/fm10k_main.c | 52 ++++++++++++++++++++-------
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c  |  6 ++--
 3 files changed, 45 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index cea0d94..bb799b3 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -164,6 +164,7 @@ struct fm10k_ring_container {
 	unsigned int total_packets;	/* total packets processed this int */
 	u16 work_limit;			/* total work allowed per interrupt */
 	u16 itr;			/* interrupt throttle rate value */
+	u8 itr_scale;			/* ITR adjustment scaler based on PCI speed */
 	u8 count;			/* total number of rings in vector */
 };
 
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index 8207ee1..c72c805 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -1367,7 +1367,7 @@ static bool fm10k_clean_tx_irq(struct fm10k_q_vector *q_vector,
  **/
 static void fm10k_update_itr(struct fm10k_ring_container *ring_container)
 {
-	unsigned int avg_wire_size, packets;
+	unsigned int avg_wire_size, packets, itr_round;
 
 	/* Only update ITR if we are using adaptive setting */
 	if (!ITR_IS_ADAPTIVE(ring_container->itr))
@@ -1379,18 +1379,44 @@ static void fm10k_update_itr(struct fm10k_ring_container *ring_container)
 
 	avg_wire_size = ring_container->total_bytes / packets;
 
-	/* Add 24 bytes to size to account for CRC, preamble, and gap */
-	avg_wire_size += 24;
-
-	/* Don't starve jumbo frames */
-	if (avg_wire_size > 3000)
-		avg_wire_size = 3000;
+	/* The following is a crude approximation of:
+	 *  wmem_default / (size + overhead) = desired_pkts_per_int
+	 *  rate / bits_per_byte / (size + ethernet overhead) = pkt_rate
+	 *  (desired_pkt_rate / pkt_rate) * usecs_per_sec = ITR value
+	 *
+	 * Assuming wmem_default is 212992 and overhead is 640 bytes per
+	 * packet, (256 skb, 64 headroom, 320 shared info), we can reduce the
+	 * formula down to
+	 *
+	 *  (34 * (size + 24)) / (size + 640) = ITR
+	 *
+	 * We first do some math on the packet size and then finally bitshift
+	 * by 8 after rounding up. We also have to account for PCIe link speed
+	 * difference as ITR scales based on this.
+	 */
+	if (avg_wire_size <= 360) {
+		/* Start at 250K ints/sec and gradually drop to 77K ints/sec */
+		avg_wire_size *= 8;
+		avg_wire_size += 376;
+	} else if (avg_wire_size <= 1152) {
+		/* 77K ints/sec to 45K ints/sec */
+		avg_wire_size *= 3;
+		avg_wire_size += 2176;
+	} else if (avg_wire_size <= 1920) {
+		/* 45K ints/sec to 38K ints/sec */
+		avg_wire_size += 4480;
+	} else {
+		/* plateau at a limit of 38K ints/sec */
+		avg_wire_size = 6656;
+	}
 
-	/* Give a little boost to mid-size frames */
-	if ((avg_wire_size > 300) && (avg_wire_size < 1200))
-		avg_wire_size /= 3;
-	else
-		avg_wire_size /= 2;
+	/* Perform final bitshift for division after rounding up to ensure
+	 * that the calculation will never get below a 1. The bit shift
+	 * accounts for changes in the ITR due to PCIe link speed.
+	 */
+	itr_round = ACCESS_ONCE(ring_container->itr_scale) + 8;
+	avg_wire_size += (1 << itr_round) - 1;
+	avg_wire_size >>= itr_round;
 
 	/* write back value and retain adaptive flag */
 	ring_container->itr = avg_wire_size | FM10K_ITR_ADAPTIVE;
@@ -1608,6 +1634,7 @@ static int fm10k_alloc_q_vector(struct fm10k_intfc *interface,
 	q_vector->tx.ring = ring;
 	q_vector->tx.work_limit = FM10K_DEFAULT_TX_WORK;
 	q_vector->tx.itr = interface->tx_itr;
+	q_vector->tx.itr_scale = interface->hw.mac.itr_scale;
 	q_vector->tx.count = txr_count;
 
 	while (txr_count) {
@@ -1636,6 +1663,7 @@ static int fm10k_alloc_q_vector(struct fm10k_intfc *interface,
 	/* save Rx ring container info */
 	q_vector->rx.ring = ring;
 	q_vector->rx.itr = interface->rx_itr;
+	q_vector->rx.itr_scale = interface->hw.mac.itr_scale;
 	q_vector->rx.count = rxr_count;
 
 	while (rxr_count) {
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index faf8149..1f0d9bc 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -880,7 +880,8 @@ static irqreturn_t fm10k_msix_mbx_vf(int __always_unused irq, void *data)
 
 	/* re-enable mailbox interrupt and indicate 20us delay */
 	fm10k_write_reg(hw, FM10K_VFITR(FM10K_MBX_VECTOR),
-			FM10K_ITR_ENABLE | FM10K_MBX_INT_DELAY);
+			FM10K_ITR_ENABLE | (FM10K_MBX_INT_DELAY >>
+					    hw->mac.itr_scale));
 
 	/* service upstream mailbox */
 	if (fm10k_mbx_trylock(interface)) {
@@ -1111,7 +1112,8 @@ static irqreturn_t fm10k_msix_mbx_pf(int __always_unused irq, void *data)
 
 	/* re-enable mailbox interrupt and indicate 20us delay */
 	fm10k_write_reg(hw, FM10K_ITR(FM10K_MBX_VECTOR),
-			FM10K_ITR_ENABLE | FM10K_MBX_INT_DELAY);
+			FM10K_ITR_ENABLE | (FM10K_MBX_INT_DELAY >>
+					    hw->mac.itr_scale));
 
 	return IRQ_HANDLED;
 }
-- 
2.5.0
