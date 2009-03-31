From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH] ucc_geth: Pass proper device to DMA routines, otherwise
	oops happens
Date: Tue, 31 Mar 2009 22:58:37 +0400
Message-ID: <20090331185837.GA22545@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>,
	Andy Fleming <afleming@freescale.com>,
	Li Yang <leoli@freescale.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [213.79.90.228] ([213.79.90.228]:2868 "EHLO
	buildserver.ru.mvista.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1760878AbZCaS6k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 14:58:40 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver should pass a device that actually specifies internal DMA
ops, but currently it passes netdev's device, which is wrong and that
causes following oops:

Kernel BUG at c01c4df8 [verbose debug info unavailable]
Oops: Exception in kernel mode, sig: 5 [#1]
[...]
NIP [c01c4df8] get_new_skb+0x7c/0xf8
LR [c01c4da4] get_new_skb+0x28/0xf8
Call Trace:
[ef82be00] [c01c4da4] get_new_skb+0x28/0xf8 (unreliable)
[ef82be20] [c01c4eb8] rx_bd_buffer_set+0x44/0x98
[ef82be40] [c01c62bc] ucc_geth_startup+0x11b0/0x147c
[ef82be80] [c01c6674] ucc_geth_open+0xec/0x2a4
[ef82bea0] [c02288a4] dev_open+0xc0/0x11c
[...]

Fix this by passing of_device's device that specifies DMA ops in its
archdata.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/ucc_geth.c |   21 +++++++++++----------
 drivers/net/ucc_geth.h |    3 ++-
 2 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 933fcfb..3ed402c 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -223,10 +223,10 @@ static struct sk_buff *get_new_skb(struct ucc_geth_private *ugeth,
 		    (((unsigned)skb->data) & (UCC_GETH_RX_DATA_BUF_ALIGNMENT -
 					      1)));
 
-	skb->dev = ugeth->dev;
+	skb->dev = ugeth->ndev;
 
 	out_be32(&((struct qe_bd __iomem *)bd)->buf,
-		      dma_map_single(&ugeth->dev->dev,
+		      dma_map_single(ugeth->dev,
 				     skb->data,
 				     ugeth->ug_info->uf_info.max_rx_buf_length +
 				     UCC_GETH_RX_DATA_BUF_ALIGNMENT,
@@ -1872,7 +1872,7 @@ static void ucc_geth_memclean(struct ucc_geth_private *ugeth)
 			continue;
 		for (j = 0; j < ugeth->ug_info->bdRingLenTx[i]; j++) {
 			if (ugeth->tx_skbuff[i][j]) {
-				dma_unmap_single(&ugeth->dev->dev,
+				dma_unmap_single(ugeth->dev,
 						 in_be32(&((struct qe_bd __iomem *)bd)->buf),
 						 (in_be32((u32 __iomem *)bd) &
 						  BD_LENGTH_MASK),
@@ -1900,7 +1900,7 @@ static void ucc_geth_memclean(struct ucc_geth_private *ugeth)
 			bd = ugeth->p_rx_bd_ring[i];
 			for (j = 0; j < ugeth->ug_info->bdRingLenRx[i]; j++) {
 				if (ugeth->rx_skbuff[i][j]) {
-					dma_unmap_single(&ugeth->dev->dev,
+					dma_unmap_single(ugeth->dev,
 						in_be32(&((struct qe_bd __iomem *)bd)->buf),
 						ugeth->ug_info->
 						uf_info.max_rx_buf_length +
@@ -3071,7 +3071,7 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* set up the buffer descriptor */
 	out_be32(&((struct qe_bd __iomem *)bd)->buf,
-		      dma_map_single(&ugeth->dev->dev, skb->data,
+		      dma_map_single(ugeth->dev, skb->data,
 			      skb->len, DMA_TO_DEVICE));
 
 	/* printk(KERN_DEBUG"skb->data is 0x%x\n",skb->data); */
@@ -3127,7 +3127,7 @@ static int ucc_geth_rx(struct ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit
 
 	ugeth_vdbg("%s: IN", __func__);
 
-	dev = ugeth->dev;
+	dev = ugeth->ndev;
 
 	/* collect received buffers */
 	bd = ugeth->rxBd[rxQ];
@@ -3161,7 +3161,7 @@ static int ucc_geth_rx(struct ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit
 			skb_put(skb, length);
 
 			/* Tell the skb what kind of packet this is */
-			skb->protocol = eth_type_trans(skb, ugeth->dev);
+			skb->protocol = eth_type_trans(skb, ugeth->ndev);
 
 			dev->stats.rx_bytes += length;
 			/* Send the packet up the stack */
@@ -3432,7 +3432,7 @@ static int ucc_geth_close(struct net_device *dev)
 
 	ucc_geth_stop(ugeth);
 
-	free_irq(ugeth->ug_info->uf_info.irq, ugeth->dev);
+	free_irq(ugeth->ug_info->uf_info.irq, ugeth->ndev);
 
 	netif_stop_queue(dev);
 
@@ -3446,7 +3446,7 @@ static void ucc_geth_timeout_work(struct work_struct *work)
 	struct net_device *dev;
 
 	ugeth = container_of(work, struct ucc_geth_private, timeout_work);
-	dev = ugeth->dev;
+	dev = ugeth->ndev;
 
 	ugeth_vdbg("%s: IN", __func__);
 
@@ -3756,7 +3756,8 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 		memcpy(dev->dev_addr, mac_addr, 6);
 
 	ugeth->ug_info = ug_info;
-	ugeth->dev = dev;
+	ugeth->dev = device;
+	ugeth->ndev = dev;
 	ugeth->node = np;
 
 	return 0;
diff --git a/drivers/net/ucc_geth.h b/drivers/net/ucc_geth.h
index e3a25e6..a6f5d0b 100644
--- a/drivers/net/ucc_geth.h
+++ b/drivers/net/ucc_geth.h
@@ -1129,7 +1129,8 @@ struct ucc_geth_info {
 struct ucc_geth_private {
 	struct ucc_geth_info *ug_info;
 	struct ucc_fast_private *uccf;
-	struct net_device *dev;
+	struct device *dev;
+	struct net_device *ndev;
 	struct napi_struct napi;
 	struct work_struct timeout_work;
 	struct ucc_geth __iomem *ug_regs;
-- 
1.5.6.5
