From: Lan Tianyu <tianyu.lan@intel.com>
Subject: [RFC Patch 08/12] IXGBEVF: Rework code of finding the end transmit desc of package
Date: Thu, 22 Oct 2015 00:37:40 +0800
Message-ID: <1445445464-5056-9-git-send-email-tianyu.lan@intel.com>
References: <1445445464-5056-1-git-send-email-tianyu.lan@intel.com>
Cc: Lan Tianyu <tianyu.lan@intel.com>
To: bhelgaas@google.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, eddie.dong@intel.com,
	nrupal.jani@intel.com, yang.z.zhang@intel.com, agraf@suse.de,
	kvm@vger.kernel.org, pbonzini@redhat.com, qemu-devel@nongnu.org,
	emil.s.tantilov@intel.com, intel-wired-lan@lists.osuosl.org,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	john.ronciak@intel.com, linux-kernel@vger.kernel.org,
	linux-pci@vger.kernel.org, matthew.vick@intel.com,
	mitch.a.williams@intel.com, netdev@vger.kernel.org,
	shannon.nelson@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445445464-5056-1-git-send-email-tianyu.lan@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When transmit a package, the end transmit desc of package
indicates whether package is sent already. Current code records
the end desc's pointer in the next_to_watch of struct tx buffer.
This code will be broken if shifting desc ring after migration.
The pointer will be invalid. This patch is to replace recording
pointer with recording the desc number of the package and find
the end decs via the first desc and desc number.

Signed-off-by: Lan Tianyu <tianyu.lan@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |  1 +
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 19 ++++++++++++++++---
 2 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index 775d089..c823616 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -54,6 +54,7 @@
  */
 struct ixgbevf_tx_buffer {
 	union ixgbe_adv_tx_desc *next_to_watch;
+	u16 desc_num;
 	unsigned long time_stamp;
 	struct sk_buff *skb;
 	unsigned int bytecount;
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 4446916..056841c 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -210,6 +210,7 @@ static void ixgbevf_unmap_and_free_tx_resource(struct ixgbevf_ring *tx_ring,
 			       DMA_TO_DEVICE);
 	}
 	tx_buffer->next_to_watch = NULL;
+	tx_buffer->desc_num = 0;
 	tx_buffer->skb = NULL;
 	dma_unmap_len_set(tx_buffer, len, 0);
 	/* tx_buffer must be completely set up in the transmit path */
@@ -295,7 +296,7 @@ static bool ixgbevf_clean_tx_irq(struct ixgbevf_q_vector *q_vector,
 	union ixgbe_adv_tx_desc *tx_desc;
 	unsigned int total_bytes = 0, total_packets = 0;
 	unsigned int budget = tx_ring->count / 2;
-	unsigned int i = tx_ring->next_to_clean;
+	int i, watch_index;
 
 	if (test_bit(__IXGBEVF_DOWN, &adapter->state))
 		return true;
@@ -305,9 +306,17 @@ static bool ixgbevf_clean_tx_irq(struct ixgbevf_q_vector *q_vector,
 	i -= tx_ring->count;
 
 	do {
-		union ixgbe_adv_tx_desc *eop_desc = tx_buffer->next_to_watch;
+		union ixgbe_adv_tx_desc *eop_desc;
+
+		if (!tx_buffer->desc_num)
+			break;
+
+		if (i + tx_buffer->desc_num >= 0)
+			watch_index = i + tx_buffer->desc_num;
+		else
+			watch_index = i + tx_ring->count + tx_buffer->desc_num;
 
-		/* if next_to_watch is not set then there is no work pending */
+		eop_desc = IXGBEVF_TX_DESC(tx_ring, watch_index);
 		if (!eop_desc)
 			break;
 
@@ -320,6 +329,7 @@ static bool ixgbevf_clean_tx_irq(struct ixgbevf_q_vector *q_vector,
 
 		/* clear next_to_watch to prevent false hangs */
 		tx_buffer->next_to_watch = NULL;
+		tx_buffer->desc_num = 0;
 
 		/* update the statistics for this packet */
 		total_bytes += tx_buffer->bytecount;
@@ -3457,6 +3467,7 @@ static void ixgbevf_tx_map(struct ixgbevf_ring *tx_ring,
 	u32 tx_flags = first->tx_flags;
 	__le32 cmd_type;
 	u16 i = tx_ring->next_to_use;
+	u16 start;
 
 	tx_desc = IXGBEVF_TX_DESC(tx_ring, i);
 
@@ -3540,6 +3551,8 @@ static void ixgbevf_tx_map(struct ixgbevf_ring *tx_ring,
 
 	/* set next_to_watch value indicating a packet is present */
 	first->next_to_watch = tx_desc;
+	start = first - tx_ring->tx_buffer_info;
+	first->desc_num = (i - start >= 0) ? i - start: i + tx_ring->count - start;
 
 	i++;
 	if (i == tx_ring->count)
-- 
1.8.4.rc0.1.g8f6a3e5.dirty
