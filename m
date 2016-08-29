From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/14] fm10k: use software values when checking for Tx hangs in hot path
Date: Mon, 29 Aug 2016 02:13:34 -0700
Message-ID: <1472462026-42133-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1472462026-42133-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:61654 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756719AbcH2JNt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 29 Aug 2016 05:13:49 -0400
In-Reply-To: <1472462026-42133-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

A previous patch added support to check for hardware Tx pending in the
fm10k_down routine. This support was intended to ensure that we
accurately check what the hardware state is. However, checking for Tx
hangs in this manor during the hotpath results in a large performance
hit. Avoid this by making the hotpath check use the SW counters instead.

Fixes: a0f53cf49cb0 ("fm10k: use actual hardware registers when checking for pending Tx", 2016-06-08)
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k.h      |  2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_main.c | 19 +++++++++++++++----
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c  |  2 +-
 3 files changed, 17 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index c4cf08d..75429f2 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -458,7 +458,7 @@ __be16 fm10k_tx_encap_offload(struct sk_buff *skb);
 netdev_tx_t fm10k_xmit_frame_ring(struct sk_buff *skb,
 				  struct fm10k_ring *tx_ring);
 void fm10k_tx_timeout_reset(struct fm10k_intfc *interface);
-u64 fm10k_get_tx_pending(struct fm10k_ring *ring);
+u64 fm10k_get_tx_pending(struct fm10k_ring *ring, bool in_sw);
 bool fm10k_check_tx_hang(struct fm10k_ring *tx_ring);
 void fm10k_alloc_rx_buffers(struct fm10k_ring *rx_ring, u16 cleaned_count);
 
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index e9767b6..0d6e69d 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -1128,13 +1128,24 @@ static u64 fm10k_get_tx_completed(struct fm10k_ring *ring)
 	return ring->stats.packets;
 }
 
-u64 fm10k_get_tx_pending(struct fm10k_ring *ring)
+/**
+ * fm10k_get_tx_pending - how many Tx descriptors not processed
+ * @ring: the ring structure
+ * @in_sw: is tx_pending being checked in SW or in HW?
+ */
+u64 fm10k_get_tx_pending(struct fm10k_ring *ring, bool in_sw)
 {
 	struct fm10k_intfc *interface = ring->q_vector->interface;
 	struct fm10k_hw *hw = &interface->hw;
+	u32 head, tail;
 
-	u32 head = fm10k_read_reg(hw, FM10K_TDH(ring->reg_idx));
-	u32 tail = fm10k_read_reg(hw, FM10K_TDT(ring->reg_idx));
+	if (likely(in_sw)) {
+		head = ring->next_to_clean;
+		tail = ring->next_to_use;
+	} else {
+		head = fm10k_read_reg(hw, FM10K_TDH(ring->reg_idx));
+		tail = fm10k_read_reg(hw, FM10K_TDT(ring->reg_idx));
+	}
 
 	return ((head <= tail) ? tail : tail + ring->count) - head;
 }
@@ -1143,7 +1154,7 @@ bool fm10k_check_tx_hang(struct fm10k_ring *tx_ring)
 {
 	u32 tx_done = fm10k_get_tx_completed(tx_ring);
 	u32 tx_done_old = tx_ring->tx_stats.tx_done_old;
-	u32 tx_pending = fm10k_get_tx_pending(tx_ring);
+	u32 tx_pending = fm10k_get_tx_pending(tx_ring, true);
 
 	clear_check_for_tx_hang(tx_ring);
 
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 377a3fb..20c2a0c 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -1699,7 +1699,7 @@ void fm10k_down(struct fm10k_intfc *interface)
 
 		/* start checking at the last ring to have pending Tx */
 		for (; i < interface->num_tx_queues; i++)
-			if (fm10k_get_tx_pending(interface->tx_ring[i]))
+			if (fm10k_get_tx_pending(interface->tx_ring[i], false))
 				break;
 
 		/* if all the queues are drained, we can break now */
-- 
2.7.4
