From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: [PATCH 2/5] ucc_geth: Word align Ethernet RX data
Date: Tue, 18 Sep 2012 18:56:22 +0200
Message-ID: <1347987385-19071-2-git-send-email-Joakim.Tjernlund@transmode.se>
References: <1347987385-19071-1-git-send-email-Joakim.Tjernlund@transmode.se>
Cc: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([195.58.98.146]:51042 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751500Ab2IRQ4g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Sep 2012 12:56:36 -0400
Received: from mail1.transmode.se (mail1.transmode.se [192.168.201.18])
	by gw1.transmode.se (Postfix) with ESMTP id 3D5F12581E3
	for <netdev@vger.kernel.org>; Tue, 18 Sep 2012 18:56:35 +0200 (CEST)
In-Reply-To: <1347987385-19071-1-git-send-email-Joakim.Tjernlund@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

UCC controller can shift received Ethernet frames 2 bytes into the buffer,
making IP data word aligned, this patch enables that feature.

Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
---
 drivers/net/ethernet/freescale/ucc_geth.c |   19 +++++++++++--------
 drivers/net/ethernet/freescale/ucc_geth.h |    1 +
 2 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
index e609c93..5f1460a 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.c
+++ b/drivers/net/ethernet/freescale/ucc_geth.c
@@ -160,6 +160,7 @@ static struct ucc_geth_info ugeth_primary_info = {
 	.numThreadsRx = UCC_GETH_NUM_OF_THREADS_1,
 	.riscTx = QE_RISC_ALLOCATION_RISC1_AND_RISC2,
 	.riscRx = QE_RISC_ALLOCATION_RISC1_AND_RISC2,
+	.ipAddressAlignment = 1,
 };
 
 static struct ucc_geth_info ugeth_info[8];
@@ -211,12 +212,13 @@ static struct sk_buff *get_new_skb(struct ucc_geth_private *ugeth,
 		u8 __iomem *bd)
 {
 	struct sk_buff *skb = NULL;
+	u16 buf_len = ugeth->ug_info->uf_info.max_rx_buf_length +
+		UCC_GETH_RX_DATA_BUF_ALIGNMENT +
+		UCC_GETH_RX_IP_ALIGNMENT;
 
 	skb = __skb_dequeue(&ugeth->rx_recycle);
 	if (!skb)
-		skb = netdev_alloc_skb(ugeth->ndev,
-				      ugeth->ug_info->uf_info.max_rx_buf_length +
-				      UCC_GETH_RX_DATA_BUF_ALIGNMENT);
+		skb = netdev_alloc_skb(ugeth->ndev, buf_len);
 	if (skb == NULL)
 		return NULL;
 
@@ -231,10 +233,9 @@ static struct sk_buff *get_new_skb(struct ucc_geth_private *ugeth,
 	out_be32(&((struct qe_bd __iomem *)bd)->buf,
 		      dma_map_single(ugeth->dev,
 				     skb->data,
-				     ugeth->ug_info->uf_info.max_rx_buf_length +
-				     UCC_GETH_RX_DATA_BUF_ALIGNMENT,
+				     buf_len,
 				     DMA_FROM_DEVICE));
-
+	skb_reserve(skb, UCC_GETH_RX_IP_ALIGNMENT);
 	out_be32((u32 __iomem *)bd,
 			(R_E | R_I | (in_be32((u32 __iomem*)bd) & R_W)));
 
@@ -1877,7 +1878,8 @@ static void ucc_geth_free_rx(struct ucc_geth_private *ugeth)
 						in_be32(&((struct qe_bd __iomem *)bd)->buf),
 						ugeth->ug_info->
 						uf_info.max_rx_buf_length +
-						UCC_GETH_RX_DATA_BUF_ALIGNMENT,
+						UCC_GETH_RX_DATA_BUF_ALIGNMENT +
+						UCC_GETH_RX_IP_ALIGNMENT,
 						DMA_FROM_DEVICE);
 					dev_kfree_skb_any(
 						ugeth->rx_skbuff[i][j]);
@@ -3352,7 +3354,8 @@ static int ucc_geth_tx(struct net_device *dev, u8 txQ)
 		if (skb_queue_len(&ugeth->rx_recycle) < RX_BD_RING_LEN &&
 			     skb_recycle_check(skb,
 				    ugeth->ug_info->uf_info.max_rx_buf_length +
-				    UCC_GETH_RX_DATA_BUF_ALIGNMENT))
+				    UCC_GETH_RX_DATA_BUF_ALIGNMENT +
+				    UCC_GETH_RX_IP_ALIGNMENT))
 			__skb_queue_head(&ugeth->rx_recycle, skb);
 		else
 			dev_kfree_skb(skb);
diff --git a/drivers/net/ethernet/freescale/ucc_geth.h b/drivers/net/ethernet/freescale/ucc_geth.h
index f71b3e7..aeb743c 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.h
+++ b/drivers/net/ethernet/freescale/ucc_geth.h
@@ -855,6 +855,7 @@ struct ucc_geth_hardware_statistics {
 #define UCC_GETH_RX_BD_RING_SIZE_ALIGNMENT	4
 #define UCC_GETH_TX_BD_RING_SIZE_MEMORY_ALIGNMENT	32
 #define UCC_GETH_RX_DATA_BUF_ALIGNMENT		64
+#define UCC_GETH_RX_IP_ALIGNMENT		2 /* IP word alignment */
 
 #define UCC_GETH_TAD_EF                         0x80
 #define UCC_GETH_TAD_V                          0x40
-- 
1.7.8.6
