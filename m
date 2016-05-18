From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net 1/1] qede: Fix DMA address APIs usage
Date: Wed, 18 May 2016 07:43:57 -0400
Message-ID: <1463571837-8146-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@qlogic.com>,
	<Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:22230 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752825AbcERM0x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 08:26:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Driver incorrectly uses dma_unmap_addr_set() to set
a variable which is in truth a dma_addr_t
[i.e not defined using DEFINE_DMA_UNMAP_ADDR()] and is
being used by the driver flows other than unmapping
physical addresses. This patch fixes driver fastpath
where CONFIG_NEED_DMA_MAP_STATE is not set.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qede/qede_main.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 8114541..901a9acc 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -1076,8 +1076,7 @@ static void qede_tpa_start(struct qede_dev *edev,
 	 * start until its over and we don't want to risk allocation failing
 	 * here, so re-allocate when aggregation will be over.
 	 */
-	dma_unmap_addr_set(sw_rx_data_prod, mapping,
-			   dma_unmap_addr(replace_buf, mapping));
+	sw_rx_data_prod->mapping = replace_buf->mapping;
 
 	sw_rx_data_prod->data = replace_buf->data;
 	rx_bd_prod->addr.hi = cpu_to_le32(upper_32_bits(mapping));
@@ -2655,7 +2654,7 @@ static void qede_free_sge_mem(struct qede_dev *edev,
 
 		if (replace_buf->data) {
 			dma_unmap_page(&edev->pdev->dev,
-				       dma_unmap_addr(replace_buf, mapping),
+				       replace_buf->mapping,
 				       PAGE_SIZE, DMA_FROM_DEVICE);
 			__free_page(replace_buf->data);
 		}
@@ -2755,7 +2754,7 @@ static int qede_alloc_sge_mem(struct qede_dev *edev,
 			goto err;
 		}
 
-		dma_unmap_addr_set(replace_buf, mapping, mapping);
+		replace_buf->mapping = mapping;
 		tpa_info->replace_buf.page_offset = 0;
 
 		tpa_info->replace_buf_mapping = mapping;
-- 
2.7.2
