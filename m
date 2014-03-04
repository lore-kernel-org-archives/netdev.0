From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next] be2net: dma_sync each RX frag before passing it to the stack
Date: Tue, 4 Mar 2014 12:14:38 +0530
Message-ID: <1393915478-8433-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:35901 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751584AbaCDGk1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 01:40:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver currently maps a page for DMA, divides the page into multiple
frags and posts them to the HW. It un-maps the page after data is received
on all the frags of the page. This scheme doesn't work when bounce buffers
are used for DMA (swiotlb=force kernel param).

This patch fixes this problem by calling dma_sync_single_for_cpu() for each
frag (excepting the last one) so that the data is copied from the bounce
buffers. The page is un-mapped only when DMA finishes on the last frag of
the page.
(Thanks Ben H. for suggesting the dma_sync API!)

This patch also renames the "last_page_user" field of be_rx_page_info{}
struct to "last_frag" to improve readability of the fixed code.

Reported-by: Li Fengmao <li.fengmao@zte.com.cn>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---

Dave, I'm guessing the swiotlb option is not used much(?). So, this patch
is not a critical fix and is a better fit for the net-next tree. Thanks.

 drivers/net/ethernet/emulex/benet/be.h      |    3 +-
 drivers/net/ethernet/emulex/benet/be_main.c |   32 ++++++++++++++++++--------
 2 files changed, 24 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index a150401..bf5ca71 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -261,9 +261,10 @@ struct be_tx_obj {
 /* Struct to remember the pages posted for rx frags */
 struct be_rx_page_info {
 	struct page *page;
+	/* set to page-addr for last frag of the page & frag-addr otherwise */
 	DEFINE_DMA_UNMAP_ADDR(bus);
 	u16 page_offset;
-	bool last_page_user;
+	bool last_frag;		/* last frag of the page */
 };
 
 struct be_rx_stats {
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 4f87f5c..3464496 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1448,11 +1448,15 @@ static struct be_rx_page_info *get_rx_page_info(struct be_rx_obj *rxo)
 	rx_page_info = &rxo->page_info_tbl[frag_idx];
 	BUG_ON(!rx_page_info->page);
 
-	if (rx_page_info->last_page_user) {
+	if (rx_page_info->last_frag) {
 		dma_unmap_page(&adapter->pdev->dev,
 			       dma_unmap_addr(rx_page_info, bus),
 			       adapter->big_page_size, DMA_FROM_DEVICE);
-		rx_page_info->last_page_user = false;
+		rx_page_info->last_frag = false;
+	} else {
+		dma_sync_single_for_cpu(&adapter->pdev->dev,
+					dma_unmap_addr(rx_page_info, bus),
+					rx_frag_size, DMA_FROM_DEVICE);
 	}
 
 	queue_tail_inc(rxq);
@@ -1786,17 +1790,16 @@ static void be_post_rx_frags(struct be_rx_obj *rxo, gfp_t gfp)
 				rx_stats(rxo)->rx_post_fail++;
 				break;
 			}
-			page_info->page_offset = 0;
+			page_offset = 0;
 		} else {
 			get_page(pagep);
-			page_info->page_offset = page_offset + rx_frag_size;
+			page_offset += rx_frag_size;
 		}
-		page_offset = page_info->page_offset;
+		page_info->page_offset = page_offset;
 		page_info->page = pagep;
-		dma_unmap_addr_set(page_info, bus, page_dmaaddr);
-		frag_dmaaddr = page_dmaaddr + page_info->page_offset;
 
 		rxd = queue_head_node(rxq);
+		frag_dmaaddr = page_dmaaddr + page_info->page_offset;
 		rxd->fragpa_lo = cpu_to_le32(frag_dmaaddr & 0xFFFFFFFF);
 		rxd->fragpa_hi = cpu_to_le32(upper_32_bits(frag_dmaaddr));
 
@@ -1804,15 +1807,24 @@ static void be_post_rx_frags(struct be_rx_obj *rxo, gfp_t gfp)
 		if ((page_offset + rx_frag_size + rx_frag_size) >
 					adapter->big_page_size) {
 			pagep = NULL;
-			page_info->last_page_user = true;
+			page_info->last_frag = true;
+			dma_unmap_addr_set(page_info, bus, page_dmaaddr);
+		} else {
+			dma_unmap_addr_set(page_info, bus, frag_dmaaddr);
 		}
 
 		prev_page_info = page_info;
 		queue_head_inc(rxq);
 		page_info = &rxo->page_info_tbl[rxq->head];
 	}
-	if (pagep)
-		prev_page_info->last_page_user = true;
+
+	/* Mark the last frag of a page when we break out of the above loop
+	 * with no more slots available in the RXQ
+	 */
+	if (pagep) {
+		prev_page_info->last_frag = true;
+		dma_unmap_addr_set(prev_page_info, bus, page_dmaaddr);
+	}
 
 	if (posted) {
 		atomic_add(posted, &rxq->used);
-- 
1.7.1
