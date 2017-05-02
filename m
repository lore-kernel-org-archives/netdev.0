From: sunil.kovvuri@gmail.com
Subject: [PATCH 6/9] net: thunderx: Add support for XDP_DROP
Date: Tue,  2 May 2017 18:36:55 +0530
Message-ID: <1493730418-24606-7-git-send-email-sunil.kovvuri@gmail.com>
References: <1493730418-24606-1-git-send-email-sunil.kovvuri@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        Sunil Goutham <sgoutham@cavium.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34902 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751574AbdEBNHt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 09:07:49 -0400
In-Reply-To: <1493730418-24606-1-git-send-email-sunil.kovvuri@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sunil Goutham <sgoutham@cavium.com>

Adds support for XDP_DROP.
Also since in XDP mode there is just a single buffer per page,
made changes to recycle DMA mapping info as well along with pages.

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   | 23 ++++++-
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c | 77 ++++++++++++++++------
 drivers/net/ethernet/cavium/thunder/nicvf_queues.h |  4 +-
 3 files changed, 79 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index 9c48873..a58cc1e 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -18,6 +18,7 @@
 #include <linux/irq.h>
 #include <linux/iommu.h>
 #include <linux/bpf.h>
+#include <linux/bpf_trace.h>
 #include <linux/filter.h>
 
 #include "nic_reg.h"
@@ -505,6 +506,7 @@ static inline bool nicvf_xdp_rx(struct nicvf *nic,
 				struct cqe_rx_t *cqe_rx)
 {
 	struct xdp_buff xdp;
+	struct page *page;
 	u32 action;
 	u16 len;
 	u64 dma_addr, cpu_addr;
@@ -527,12 +529,27 @@ static inline bool nicvf_xdp_rx(struct nicvf *nic,
 	switch (action) {
 	case XDP_PASS:
 	case XDP_TX:
-	case XDP_ABORTED:
-	case XDP_DROP:
 		/* Pass on all packets to network stack */
 		return false;
 	default:
 		bpf_warn_invalid_xdp_action(action);
+	case XDP_ABORTED:
+		trace_xdp_exception(nic->netdev, prog, action);
+	case XDP_DROP:
+		page = virt_to_page(xdp.data);
+		/* Check if it's a recycled page, if not
+		 * unmap the DMA mapping.
+		 *
+		 * Recycled page holds an extra reference.
+		 */
+		if (page_ref_count(page) == 1) {
+			dma_addr &= PAGE_MASK;
+			dma_unmap_page_attrs(&nic->pdev->dev, dma_addr,
+					     RCV_FRAG_LEN, DMA_FROM_DEVICE,
+					     DMA_ATTR_SKIP_CPU_SYNC);
+		}
+		put_page(page);
+		return true;
 	}
 	return false;
 }
@@ -645,7 +662,7 @@ static void nicvf_rcv_pkt_handler(struct net_device *netdev,
 		if (nicvf_xdp_rx(snic, nic->xdp_prog, cqe_rx))
 			return;
 
-	skb = nicvf_get_rcv_skb(snic, cqe_rx);
+	skb = nicvf_get_rcv_skb(snic, cqe_rx, nic->xdp_prog ? true : false);
 	if (!skb) {
 		netdev_dbg(nic->netdev, "Packet not received\n");
 		return;
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
index 8c3c571..5009f49 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
@@ -117,6 +117,7 @@ static struct pgcache *nicvf_alloc_page(struct nicvf *nic,
 
 		/* Save the page in page cache */
 		pgcache->page = page;
+		pgcache->dma_addr = 0;
 		rbdr->pgalloc++;
 	}
 
@@ -144,7 +145,7 @@ static inline int nicvf_alloc_rcv_buffer(struct nicvf *nic, struct rbdr *rbdr,
 	/* Check if request can be accomodated in previous allocated page.
 	 * But in XDP mode only one buffer per page is permitted.
 	 */
-	if (!nic->pnicvf->xdp_prog && nic->rb_page &&
+	if (!rbdr->is_xdp && nic->rb_page &&
 	    ((nic->rb_page_offset + buf_len) <= PAGE_SIZE)) {
 		nic->rb_pageref++;
 		goto ret;
@@ -165,18 +166,24 @@ static inline int nicvf_alloc_rcv_buffer(struct nicvf *nic, struct rbdr *rbdr,
 	if (pgcache)
 		nic->rb_page = pgcache->page;
 ret:
-	/* HW will ensure data coherency, CPU sync not required */
-	*rbuf = (u64)dma_map_page_attrs(&nic->pdev->dev, nic->rb_page,
-					nic->rb_page_offset, buf_len,
-					DMA_FROM_DEVICE,
-					DMA_ATTR_SKIP_CPU_SYNC);
-	if (dma_mapping_error(&nic->pdev->dev, (dma_addr_t)*rbuf)) {
-		if (!nic->rb_page_offset)
-			__free_pages(nic->rb_page, 0);
-		nic->rb_page = NULL;
-		return -ENOMEM;
+	if (rbdr->is_xdp && pgcache && pgcache->dma_addr) {
+		*rbuf = pgcache->dma_addr;
+	} else {
+		/* HW will ensure data coherency, CPU sync not required */
+		*rbuf = (u64)dma_map_page_attrs(&nic->pdev->dev, nic->rb_page,
+						nic->rb_page_offset, buf_len,
+						DMA_FROM_DEVICE,
+						DMA_ATTR_SKIP_CPU_SYNC);
+		if (dma_mapping_error(&nic->pdev->dev, (dma_addr_t)*rbuf)) {
+			if (!nic->rb_page_offset)
+				__free_pages(nic->rb_page, 0);
+			nic->rb_page = NULL;
+			return -ENOMEM;
+		}
+		if (pgcache)
+			pgcache->dma_addr = *rbuf;
+		nic->rb_page_offset += buf_len;
 	}
-	nic->rb_page_offset += buf_len;
 
 	return 0;
 }
@@ -230,8 +237,16 @@ static int  nicvf_init_rbdr(struct nicvf *nic, struct rbdr *rbdr,
 	 * On embedded platforms i.e 81xx/83xx available memory itself
 	 * is low and minimum ring size of RBDR is 8K, that takes away
 	 * lots of memory.
+	 *
+	 * But for XDP it has to be a single buffer per page.
 	 */
-	rbdr->pgcnt = ring_len / (PAGE_SIZE / buf_size);
+	if (!nic->pnicvf->xdp_prog) {
+		rbdr->pgcnt = ring_len / (PAGE_SIZE / buf_size);
+		rbdr->is_xdp = false;
+	} else {
+		rbdr->pgcnt = ring_len;
+		rbdr->is_xdp = true;
+	}
 	rbdr->pgcnt = roundup_pow_of_two(rbdr->pgcnt);
 	rbdr->pgcache = kzalloc(sizeof(*rbdr->pgcache) *
 				rbdr->pgcnt, GFP_KERNEL);
@@ -1454,8 +1469,31 @@ static inline unsigned frag_num(unsigned i)
 #endif
 }
 
+static void nicvf_unmap_rcv_buffer(struct nicvf *nic, u64 dma_addr,
+				   u64 buf_addr, bool xdp)
+{
+	struct page *page = NULL;
+	int len = RCV_FRAG_LEN;
+
+	if (xdp) {
+		page = virt_to_page(phys_to_virt(buf_addr));
+		/* Check if it's a recycled page, if not
+		 * unmap the DMA mapping.
+		 *
+		 * Recycled page holds an extra reference.
+		 */
+		if (page_ref_count(page) != 1)
+			return;
+		/* Receive buffers in XDP mode are mapped from page start */
+		dma_addr &= PAGE_MASK;
+	}
+	dma_unmap_page_attrs(&nic->pdev->dev, dma_addr, len,
+			     DMA_FROM_DEVICE, DMA_ATTR_SKIP_CPU_SYNC);
+}
+
 /* Returns SKB for a received packet */
-struct sk_buff *nicvf_get_rcv_skb(struct nicvf *nic, struct cqe_rx_t *cqe_rx)
+struct sk_buff *nicvf_get_rcv_skb(struct nicvf *nic,
+				  struct cqe_rx_t *cqe_rx, bool xdp)
 {
 	int frag;
 	int payload_len = 0;
@@ -1490,10 +1528,9 @@ struct sk_buff *nicvf_get_rcv_skb(struct nicvf *nic, struct cqe_rx_t *cqe_rx)
 
 		if (!frag) {
 			/* First fragment */
-			dma_unmap_page_attrs(&nic->pdev->dev,
-					     *rb_ptrs - cqe_rx->align_pad,
-					     RCV_FRAG_LEN, DMA_FROM_DEVICE,
-					     DMA_ATTR_SKIP_CPU_SYNC);
+			nicvf_unmap_rcv_buffer(nic,
+					       *rb_ptrs - cqe_rx->align_pad,
+					       phys_addr, xdp);
 			skb = nicvf_rb_ptr_to_skb(nic,
 						  phys_addr - cqe_rx->align_pad,
 						  payload_len);
@@ -1503,9 +1540,7 @@ struct sk_buff *nicvf_get_rcv_skb(struct nicvf *nic, struct cqe_rx_t *cqe_rx)
 			skb_put(skb, payload_len);
 		} else {
 			/* Add fragments */
-			dma_unmap_page_attrs(&nic->pdev->dev, *rb_ptrs,
-					     RCV_FRAG_LEN, DMA_FROM_DEVICE,
-					     DMA_ATTR_SKIP_CPU_SYNC);
+			nicvf_unmap_rcv_buffer(nic, *rb_ptrs, phys_addr, xdp);
 			page = virt_to_page(phys_to_virt(phys_addr));
 			offset = phys_to_virt(phys_addr) - page_address(page);
 			skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags, page,
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.h b/drivers/net/ethernet/cavium/thunder/nicvf_queues.h
index 07136a2..db04c0e 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.h
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.h
@@ -228,6 +228,7 @@ struct rbdr {
 	u32		head;
 	u32		tail;
 	struct q_desc_mem   dmem;
+	bool		is_xdp;
 
 	/* For page recycling */
 	int		pgidx;
@@ -339,7 +340,8 @@ void nicvf_sq_free_used_descs(struct net_device *netdev,
 int nicvf_sq_append_skb(struct nicvf *nic, struct snd_queue *sq,
 			struct sk_buff *skb, u8 sq_num);
 
-struct sk_buff *nicvf_get_rcv_skb(struct nicvf *nic, struct cqe_rx_t *cqe_rx);
+struct sk_buff *nicvf_get_rcv_skb(struct nicvf *nic,
+				  struct cqe_rx_t *cqe_rx, bool xdp);
 void nicvf_rbdr_task(unsigned long data);
 void nicvf_rbdr_work(struct work_struct *work);
 
-- 
2.7.4
