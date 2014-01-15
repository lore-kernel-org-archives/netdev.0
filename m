From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net v2] be2net: add dma_mapping_error() check for dma_map_page()
Date: Wed, 15 Jan 2014 11:11:34 +0100
Message-ID: <1389780694-6299-1-git-send-email-ivecera@redhat.com>
Cc: sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34365 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751562AbaAOKL6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jan 2014 05:11:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver does not check value returned by dma_map_page. The patch
fixes this.

v2: Removed the bugfix for non-bug ;-) (thanks Sathya)

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index bf40fda..a37039d 100644
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
-- 
1.8.3.2
