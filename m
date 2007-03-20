From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [PATCH 09/31] [FORCEDETH]: Use skb_tailroom where appropriate
Date: Tue, 20 Mar 2007 20:06:07 -0300
Message-ID: <20070320230607.GW17811@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.230]:34121 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752079AbXCTXGV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 19:06:21 -0400
Received: by wx-out-0506.google.com with SMTP id h31so64649wxd
        for <netdev@vger.kernel.org>; Tue, 20 Mar 2007 16:06:21 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reducing the number of skb->data direct accesses.

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 drivers/net/forcedeth.c |   18 +++++++-----------
 1 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 442f10e..423415d 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -1388,11 +1388,9 @@ static int nv_alloc_rx(struct net_device *dev)
 			np->put_rx_ctx->skb = skb;
 			np->put_rx_ctx->dma = pci_map_single(np->pci_dev,
 							     skb->data,
-							(skb_end_pointer(skb) -
-							 skb->data),
+							     skb_tailroom(skb),
 							     PCI_DMA_FROMDEVICE);
-			np->put_rx_ctx->dma_len = (skb_end_pointer(skb) -
-						   skb->data);
+			np->put_rx_ctx->dma_len = skb_tailroom(skb);
 			np->put_rx.orig->buf = cpu_to_le32(np->put_rx_ctx->dma);
 			wmb();
 			np->put_rx.orig->flaglen = cpu_to_le32(np->rx_buf_sz | NV_RX_AVAIL);
@@ -1422,11 +1420,9 @@ static int nv_alloc_rx_optimized(struct net_device *dev)
 			np->put_rx_ctx->skb = skb;
 			np->put_rx_ctx->dma = pci_map_single(np->pci_dev,
 							     skb->data,
-							     (skb_end_pointer(skb) -
-							      skb->data),
+							     skb_tailroom(skb),
 							     PCI_DMA_FROMDEVICE);
-			np->put_rx_ctx->dma_len = (skb_end_pointer(skb) -
-						   skb->data);
+			np->put_rx_ctx->dma_len = skb_tailroom(skb);
 			np->put_rx.ex->bufhigh = cpu_to_le64(np->put_rx_ctx->dma) >> 32;
 			np->put_rx.ex->buflow = cpu_to_le64(np->put_rx_ctx->dma) & 0x0FFFFFFFF;
 			wmb();
@@ -4379,12 +4375,12 @@ static int nv_loopback_test(struct net_device *dev)
 		ret = 0;
 		goto out;
 	}
+	test_dma_addr = pci_map_single(np->pci_dev, tx_skb->data,
+				       skb_tailroom(tx_skb),
+				       PCI_DMA_FROMDEVICE);
 	pkt_data = skb_put(tx_skb, pkt_len);
 	for (i = 0; i < pkt_len; i++)
 		pkt_data[i] = (u8)(i & 0xff);
-	test_dma_addr = pci_map_single(np->pci_dev, tx_skb->data,
-				       (skb_end_pointer(tx_skb) -
-					tx_skb->data), PCI_DMA_FROMDEVICE);
 
 	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
 		np->tx_ring.orig[0].buf = cpu_to_le32(test_dma_addr);
-- 
1.5.0.3

