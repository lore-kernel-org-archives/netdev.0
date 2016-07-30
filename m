From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next 02/10] drivers: net: xgene: fix: Add dma_unmap_single
Date: Fri, 29 Jul 2016 17:33:55 -0700
Message-ID: <1469838843-19943-3-git-send-email-isubramanian@apm.com>
References: <1469838843-19943-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	linux@armlinux.org.uk, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35789 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752852AbcG3Ad0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2016 20:33:26 -0400
Received: by mail-pa0-f42.google.com with SMTP id iw10so35328515pac.2
        for <netdev@vger.kernel.org>; Fri, 29 Jul 2016 17:33:26 -0700 (PDT)
In-Reply-To: <1469838843-19943-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In addition to xgene_enet_delete_bufpool() freeing skbs, their associated
dma memory should also be unmapped.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index d1d6b5e..5246457 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -72,7 +72,6 @@ static int xgene_enet_refill_bufpool(struct xgene_enet_desc_ring *buf_pool,
 		skb = netdev_alloc_skb_ip_align(ndev, len);
 		if (unlikely(!skb))
 			return -ENOMEM;
-		buf_pool->rx_skb[tail] = skb;
 
 		dma_addr = dma_map_single(dev, skb->data, len, DMA_FROM_DEVICE);
 		if (dma_mapping_error(dev, dma_addr)) {
@@ -81,6 +80,8 @@ static int xgene_enet_refill_bufpool(struct xgene_enet_desc_ring *buf_pool,
 			return -EINVAL;
 		}
 
+		buf_pool->rx_skb[tail] = skb;
+
 		raw_desc->m1 = cpu_to_le64(SET_VAL(DATAADDR, dma_addr) |
 					   SET_VAL(BUFDATALEN, bufdatalen) |
 					   SET_BIT(COHERENT));
@@ -102,12 +103,21 @@ static u8 xgene_enet_hdr_len(const void *data)
 
 static void xgene_enet_delete_bufpool(struct xgene_enet_desc_ring *buf_pool)
 {
+	struct device *dev = ndev_to_dev(buf_pool->ndev);
+	struct xgene_enet_raw_desc16 *raw_desc;
+	dma_addr_t dma_addr;
 	int i;
 
 	/* Free up the buffers held by hardware */
 	for (i = 0; i < buf_pool->slots; i++) {
-		if (buf_pool->rx_skb[i])
+		if (buf_pool->rx_skb[i]) {
 			dev_kfree_skb_any(buf_pool->rx_skb[i]);
+
+			raw_desc = &buf_pool->raw_desc16[i];
+			dma_addr = GET_VAL(DATAADDR, le64_to_cpu(raw_desc->m1));
+			dma_unmap_single(dev, dma_addr, XGENE_ENET_MAX_MTU,
+					 DMA_FROM_DEVICE);
+		}
 	}
 }
 
-- 
1.9.1
