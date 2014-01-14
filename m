From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net] be2net: add dma_mapping_error() check for dma_map_page()
Date: Tue, 14 Jan 2014 19:28:59 +0100
Message-ID: <1389724139-27111-1-git-send-email-ivecera@redhat.com>
Cc: sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42721 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751669AbaANS3D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 13:29:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver does not check value returned by dma_map_page. The patch
fixes this as well as one additional bug. The prev_page_info is
dereferenced after 'for' loop but if the 1st be_alloc_pages fails its
value is NULL.

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index bf40fda..f2811b5 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1776,6 +1776,7 @@ static void be_post_rx_frags(struct be_rx_obj *rxo, gfp_t gfp)
 	struct be_rx_page_info *page_info = NULL, *prev_page_info = NULL;
 	struct be_queue_info *rxq = &rxo->q;
 	struct page *pagep = NULL;
+	struct device *dev = &adapter->pdev->dev;
 	struct be_eth_rx_d *rxd;
 	u64 page_dmaaddr = 0, frag_dmaaddr;
 	u32 posted, page_offset = 0;
@@ -1788,9 +1789,15 @@ static void be_post_rx_frags(struct be_rx_obj *rxo, gfp_t gfp)
 				rx_stats(rxo)->rx_post_fail++;
 				break;
 			}
-			page_dmaaddr = dma_map_page(&adapter->pdev->dev, pagep,
-						    0, adapter->big_page_size,
+			page_dmaaddr = dma_map_page(dev, pagep, 0,
+						    adapter->big_page_size,
 						    DMA_FROM_DEVICE);
+			if (dma_mapping_error(dev, page_dmaaddr)) {
+				put_page(pagep);
+				pagep = NULL;
+				rx_stats(rxo)->rx_post_fail++;
+				break;
+			}
 			page_info->page_offset = 0;
 		} else {
 			get_page(pagep);
@@ -1816,7 +1823,7 @@ static void be_post_rx_frags(struct be_rx_obj *rxo, gfp_t gfp)
 		queue_head_inc(rxq);
 		page_info = &rxo->page_info_tbl[rxq->head];
 	}
-	if (pagep)
+	if (pagep && prev_page_info)
 		prev_page_info->last_page_user = true;
 
 	if (posted) {
-- 
1.8.3.2
