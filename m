From: Lan Tianyu <tianyu.lan@intel.com>
Subject: [RFC Patch 12/12] IXGBEVF: Track dma dirty pages
Date: Thu, 22 Oct 2015 00:37:44 +0800
Message-ID: <1445445464-5056-13-git-send-email-tianyu.lan@intel.com>
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
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1445445464-5056-1-git-send-email-tianyu.lan@intel.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Migration relies on tracking dirty page to migrate memory.
Hardware can't automatically mark a page as dirty after DMA
memory access. VF descriptor rings and data buffers are modified
by hardware when receive and transmit data. To track such dirty memory
manually, do dummy writes(read a byte and write it back) during receive
and transmit data.

Signed-off-by: Lan Tianyu <tianyu.lan@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index d22160f..ce7bd7a 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -414,6 +414,9 @@ static bool ixgbevf_clean_tx_irq(struct ixgbevf_q_vector *q_vector,
 		if (!(eop_desc->wb.status & cpu_to_le32(IXGBE_TXD_STAT_DD)))
 			break;
 
+		/* write back status to mark page dirty */
+		eop_desc->wb.status = eop_desc->wb.status;
+
 		/* clear next_to_watch to prevent false hangs */
 		tx_buffer->next_to_watch = NULL;
 		tx_buffer->desc_num = 0;
@@ -946,15 +949,17 @@ static struct sk_buff *ixgbevf_fetch_rx_buffer(struct ixgbevf_ring *rx_ring,
 {
 	struct ixgbevf_rx_buffer *rx_buffer;
 	struct page *page;
+	u8 *page_addr;
 
 	rx_buffer = &rx_ring->rx_buffer_info[rx_ring->next_to_clean];
 	page = rx_buffer->page;
 	prefetchw(page);
 
-	if (likely(!skb)) {
-		void *page_addr = page_address(page) +
-				  rx_buffer->page_offset;
+	/* Mark page dirty */
+	page_addr = page_address(page) + rx_buffer->page_offset;
+	*page_addr = *page_addr;
 
+	if (likely(!skb)) {
 		/* prefetch first cache line of first page */
 		prefetch(page_addr);
 #if L1_CACHE_BYTES < 128
@@ -1032,6 +1037,9 @@ static int ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 		if (!ixgbevf_test_staterr(rx_desc, IXGBE_RXD_STAT_DD))
 			break;
 
+		/* Write back status to mark page dirty */
+		rx_desc->wb.upper.status_error = rx_desc->wb.upper.status_error;
+
 		/* This memory barrier is needed to keep us from reading
 		 * any other fields out of the rx_desc until we know the
 		 * RXD_STAT_DD bit is set
-- 
1.8.4.rc0.1.g8f6a3e5.dirty

