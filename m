From: Yuusuke Ashiduka <ashiduka@jp.fujitsu.com>
Subject: [PATCH] net: fec: Fixed panic problem with non-tso
Date: Tue, 17 Jan 2017 16:48:20 +0900
Message-ID: <20170117074820.5106-1-ashiduka@jp.fujitsu.com>
Cc: netdev@vger.kernel.org, Yuusuke Ashiduka <ashiduka@jp.fujitsu.com>
To: fugang.duan@nxp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwkm02.jp.fujitsu.com ([202.219.69.169]:47196 "EHLO
        mgwkm02.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750787AbdAQIBl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 03:01:41 -0500
Received: from saturn.fct.css.fujitsu.com (saturn.fct.css.fujitsu.com [10.91.171.43])
        by kw-mxq.gw.nic.fujitsu.com (Postfix) with ESMTP id 65FA0AC00AF
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 16:49:48 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If highmem and 2GB or more of memory are valid,
"this_frag-> page.p" indicates the highmem area,
so the result of page_address() is NULL and panic occurs.

This commit fixes this by using the skb_frag_dma_map() helper,
which takes care of mapping the skb fragment properly. Additionally,
the type of mapping is now tracked, so it can be unmapped using
dma_unmap_page or dma_unmap_single when appropriate.
---
 drivers/net/ethernet/freescale/fec.h      |  1 +
 drivers/net/ethernet/freescale/fec_main.c | 48 +++++++++++++++++++++++--------
 2 files changed, 37 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index 5ea740b4cf14..5b187e8aacf0 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -463,6 +463,7 @@ struct bufdesc_prop {
 struct fec_enet_priv_tx_q {
 	struct bufdesc_prop bd;
 	unsigned char *tx_bounce[TX_RING_SIZE];
+	int tx_page_mapping[TX_RING_SIZE];
 	struct  sk_buff *tx_skbuff[TX_RING_SIZE];
 
 	unsigned short tx_stop_threshold;
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 38160c2bebcb..b1562107e337 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -60,6 +60,7 @@
 #include <linux/if_vlan.h>
 #include <linux/pinctrl/consumer.h>
 #include <linux/prefetch.h>
+#include <linux/highmem.h>
 #include <soc/imx/cpuidle.h>
 
 #include <asm/cacheflush.h>
@@ -377,20 +378,28 @@ fec_enet_txq_submit_frag_skb(struct fec_enet_priv_tx_q *txq,
 			ebdp->cbd_esc = cpu_to_fec32(estatus);
 		}
 
-		bufaddr = page_address(this_frag->page.p) + this_frag->page_offset;
-
 		index = fec_enet_get_bd_index(bdp, &txq->bd);
-		if (((unsigned long) bufaddr) & fep->tx_align ||
+		txq->tx_page_mapping[index] = 0;
+		if (this_frag->page_offset & fep->tx_align ||
 			fep->quirks & FEC_QUIRK_SWAP_FRAME) {
+			bufaddr = kmap_atomic(this_frag->page.p) +
+						this_frag->page_offset;
 			memcpy(txq->tx_bounce[index], bufaddr, frag_len);
+			kunmap_atomic(bufaddr);
 			bufaddr = txq->tx_bounce[index];
 
 			if (fep->quirks & FEC_QUIRK_SWAP_FRAME)
 				swap_buffer(bufaddr, frag_len);
+			addr = dma_map_single(&fep->pdev->dev,
+					      bufaddr,
+					      frag_len,
+					      DMA_TO_DEVICE);
+		} else {
+			txq->tx_page_mapping[index] = 1;
+			addr = skb_frag_dma_map(&fep->pdev->dev, this_frag, 0,
+						frag_len, DMA_TO_DEVICE);
 		}
 
-		addr = dma_map_single(&fep->pdev->dev, bufaddr, frag_len,
-				      DMA_TO_DEVICE);
 		if (dma_mapping_error(&fep->pdev->dev, addr)) {
 			if (net_ratelimit())
 				netdev_err(ndev, "Tx DMA memory map failed\n");
@@ -411,8 +420,16 @@ fec_enet_txq_submit_frag_skb(struct fec_enet_priv_tx_q *txq,
 	bdp = txq->bd.cur;
 	for (i = 0; i < frag; i++) {
 		bdp = fec_enet_get_nextdesc(bdp, &txq->bd);
-		dma_unmap_single(&fep->pdev->dev, fec32_to_cpu(bdp->cbd_bufaddr),
-				 fec16_to_cpu(bdp->cbd_datlen), DMA_TO_DEVICE);
+		if (txq->tx_page_mapping[index])
+			dma_unmap_page(&fep->pdev->dev,
+				       fec32_to_cpu(bdp->cbd_bufaddr),
+				       fec16_to_cpu(bdp->cbd_datlen),
+				       DMA_TO_DEVICE);
+		else
+			dma_unmap_single(&fep->pdev->dev,
+					 fec32_to_cpu(bdp->cbd_bufaddr),
+					 fec16_to_cpu(bdp->cbd_datlen),
+					 DMA_TO_DEVICE);
 	}
 	return ERR_PTR(-ENOMEM);
 }
@@ -1201,11 +1218,18 @@ fec_enet_tx_queue(struct net_device *ndev, u16 queue_id)
 
 		skb = txq->tx_skbuff[index];
 		txq->tx_skbuff[index] = NULL;
-		if (!IS_TSO_HEADER(txq, fec32_to_cpu(bdp->cbd_bufaddr)))
-			dma_unmap_single(&fep->pdev->dev,
-					 fec32_to_cpu(bdp->cbd_bufaddr),
-					 fec16_to_cpu(bdp->cbd_datlen),
-					 DMA_TO_DEVICE);
+		if (!IS_TSO_HEADER(txq, fec32_to_cpu(bdp->cbd_bufaddr))) {
+			if (txq->tx_page_mapping[index])
+				dma_unmap_page(&fep->pdev->dev,
+					       fec32_to_cpu(bdp->cbd_bufaddr),
+					       fec16_to_cpu(bdp->cbd_datlen),
+					       DMA_TO_DEVICE);
+			else
+				dma_unmap_single(&fep->pdev->dev,
+						 fec32_to_cpu(bdp->cbd_bufaddr),
+						 fec16_to_cpu(bdp->cbd_datlen),
+						 DMA_TO_DEVICE);
+		}
 		bdp->cbd_bufaddr = cpu_to_fec32(0);
 		if (!skb)
 			goto skb_done;
-- 
2.11.0
