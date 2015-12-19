From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] sh_eth: fix 16-bit descriptor field access endianness too
Date: Sun, 20 Dec 2015 01:48:04 +0300
Message-ID: <16692899.McEvu8S87q@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:33157 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753929AbbLSWsJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Dec 2015 17:48:09 -0500
Received: by mail-lb0-f178.google.com with SMTP id kw15so80903372lbb.0
        for <netdev@vger.kernel.org>; Sat, 19 Dec 2015 14:48:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 1299653affa4 ("sh_eth: fix descriptor access endianness") only
addressed the 32-bit buffer address field byte-swapping  but the driver
still accesses 16-bit frame/buffer length descriptor fields without the
necessary byte-swapping -- which should affect the big-endian kernels.
In order to be able to use {cpu|edmac}_to_{edmac|cpu}(), we need to declare
the RX/TX descriptor word 1 as a 32-bit field and use shifts/masking to
access the 16-bit subfields (which gets rid of the ugly #ifdef'ery too)...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against DaveM's 'net.git' repo.

 drivers/net/ethernet/renesas/sh_eth.c |   25 ++++++++++++++-----------
 drivers/net/ethernet/renesas/sh_eth.h |   33 ++++++++++++++++-----------------
 2 files changed, 30 insertions(+), 28 deletions(-)

Index: net/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net/drivers/net/ethernet/renesas/sh_eth.c
@@ -1167,6 +1167,7 @@ static void sh_eth_ring_format(struct ne
 	int tx_ringsize = sizeof(*txdesc) * mdp->num_tx_ring;
 	int skbuff_size = mdp->rx_buf_sz + SH_ETH_RX_ALIGN + 32 - 1;
 	dma_addr_t dma_addr;
+	u32 buf_len;
 
 	mdp->cur_rx = 0;
 	mdp->cur_tx = 0;
@@ -1187,9 +1188,9 @@ static void sh_eth_ring_format(struct ne
 		/* RX descriptor */
 		rxdesc = &mdp->rx_ring[i];
 		/* The size of the buffer is a multiple of 32 bytes. */
-		rxdesc->buffer_length = ALIGN(mdp->rx_buf_sz, 32);
-		dma_addr = dma_map_single(&ndev->dev, skb->data,
-					  rxdesc->buffer_length,
+		buf_len = ALIGN(mdp->rx_buf_sz, 32);
+		rxdesc->len = cpu_to_edmac(mdp, buf_len << 16);
+		dma_addr = dma_map_single(&ndev->dev, skb->data, buf_len,
 					  DMA_FROM_DEVICE);
 		if (dma_mapping_error(&ndev->dev, dma_addr)) {
 			kfree_skb(skb);
@@ -1220,7 +1221,7 @@ static void sh_eth_ring_format(struct ne
 		mdp->tx_skbuff[i] = NULL;
 		txdesc = &mdp->tx_ring[i];
 		txdesc->status = cpu_to_edmac(mdp, TD_TFP);
-		txdesc->buffer_length = 0;
+		txdesc->len = cpu_to_edmac(mdp, 0);
 		if (i == 0) {
 			/* Tx descriptor address set */
 			sh_eth_write(ndev, mdp->tx_desc_dma, TDLAR);
@@ -1429,7 +1430,8 @@ static int sh_eth_txfree(struct net_devi
 		if (mdp->tx_skbuff[entry]) {
 			dma_unmap_single(&ndev->dev,
 					 edmac_to_cpu(mdp, txdesc->addr),
-					 txdesc->buffer_length, DMA_TO_DEVICE);
+					 edmac_to_cpu(mdp, txdesc->len) >> 16,
+					 DMA_TO_DEVICE);
 			dev_kfree_skb_irq(mdp->tx_skbuff[entry]);
 			mdp->tx_skbuff[entry] = NULL;
 			free_num++;
@@ -1439,7 +1441,7 @@ static int sh_eth_txfree(struct net_devi
 			txdesc->status |= cpu_to_edmac(mdp, TD_TDLE);
 
 		ndev->stats.tx_packets++;
-		ndev->stats.tx_bytes += txdesc->buffer_length;
+		ndev->stats.tx_bytes += edmac_to_cpu(mdp, txdesc->len) >> 16;
 	}
 	return free_num;
 }
@@ -1458,6 +1460,7 @@ static int sh_eth_rx(struct net_device *
 	u32 desc_status;
 	int skbuff_size = mdp->rx_buf_sz + SH_ETH_RX_ALIGN + 32 - 1;
 	dma_addr_t dma_addr;
+	u32 buf_len;
 
 	boguscnt = min(boguscnt, *quota);
 	limit = boguscnt;
@@ -1466,7 +1469,7 @@ static int sh_eth_rx(struct net_device *
 		/* RACT bit must be checked before all the following reads */
 		dma_rmb();
 		desc_status = edmac_to_cpu(mdp, rxdesc->status);
-		pkt_len = rxdesc->frame_length;
+		pkt_len = edmac_to_cpu(mdp, rxdesc->len) & RD_RFL;
 
 		if (--boguscnt < 0)
 			break;
@@ -1532,7 +1535,8 @@ static int sh_eth_rx(struct net_device *
 		entry = mdp->dirty_rx % mdp->num_rx_ring;
 		rxdesc = &mdp->rx_ring[entry];
 		/* The size of the buffer is 32 byte boundary. */
-		rxdesc->buffer_length = ALIGN(mdp->rx_buf_sz, 32);
+		buf_len = ALIGN(mdp->rx_buf_sz, 32);
+		rxdesc->len = cpu_to_edmac(mdp, buf_len << 16);
 
 		if (mdp->rx_skbuff[entry] == NULL) {
 			skb = netdev_alloc_skb(ndev, skbuff_size);
@@ -1540,8 +1544,7 @@ static int sh_eth_rx(struct net_device *
 				break;	/* Better luck next round. */
 			sh_eth_set_receive_align(skb);
 			dma_addr = dma_map_single(&ndev->dev, skb->data,
-						  rxdesc->buffer_length,
-						  DMA_FROM_DEVICE);
+						  buf_len, DMA_FROM_DEVICE);
 			if (dma_mapping_error(&ndev->dev, dma_addr)) {
 				kfree_skb(skb);
 				break;
@@ -2407,7 +2410,7 @@ static int sh_eth_start_xmit(struct sk_b
 		return NETDEV_TX_OK;
 	}
 	txdesc->addr = cpu_to_edmac(mdp, dma_addr);
-	txdesc->buffer_length = skb->len;
+	txdesc->len  = cpu_to_edmac(mdp, skb->len << 16);
 
 	dma_wmb(); /* TACT bit must be set after all the above writes */
 	if (entry >= mdp->num_tx_ring - 1)
Index: net/drivers/net/ethernet/renesas/sh_eth.h
===================================================================
--- net.orig/drivers/net/ethernet/renesas/sh_eth.h
+++ net/drivers/net/ethernet/renesas/sh_eth.h
@@ -283,7 +283,7 @@ enum DMAC_IM_BIT {
 	DMAC_M_RINT1 = 0x00000001,
 };
 
-/* Receive descriptor bit */
+/* Receive descriptor 0 bits */
 enum RD_STS_BIT {
 	RD_RACT = 0x80000000, RD_RDLE = 0x40000000,
 	RD_RFP1 = 0x20000000, RD_RFP0 = 0x10000000,
@@ -298,6 +298,12 @@ enum RD_STS_BIT {
 #define RDFEND	RD_RFP0
 #define RD_RFP	(RD_RFP1|RD_RFP0)
 
+/* Receive descriptor 1 bits */
+enum RD_LEN_BIT {
+	RD_RFL	= 0x0000ffff,	/* receive frame  length */
+	RD_RBL	= 0xffff0000,	/* receive buffer length */
+};
+
 /* FCFTR */
 enum FCFTR_BIT {
 	FCFTR_RFF2 = 0x00040000, FCFTR_RFF1 = 0x00020000,
@@ -307,7 +313,7 @@ enum FCFTR_BIT {
 #define DEFAULT_FIFO_F_D_RFF	(FCFTR_RFF2 | FCFTR_RFF1 | FCFTR_RFF0)
 #define DEFAULT_FIFO_F_D_RFD	(FCFTR_RFD2 | FCFTR_RFD1 | FCFTR_RFD0)
 
-/* Transmit descriptor bit */
+/* Transmit descriptor 0 bits */
 enum TD_STS_BIT {
 	TD_TACT = 0x80000000, TD_TDLE = 0x40000000,
 	TD_TFP1 = 0x20000000, TD_TFP0 = 0x10000000,
@@ -317,6 +323,11 @@ enum TD_STS_BIT {
 #define TDFEND	TD_TFP0
 #define TD_TFP	(TD_TFP1|TD_TFP0)
 
+/* Transmit descriptor 1 bits */
+enum TD_LEN_BIT {
+	TD_TBL	= 0xffff0000,	/* transmit buffer length */
+};
+
 /* RMCR */
 enum RMCR_BIT {
 	RMCR_RNC = 0x00000001,
@@ -425,15 +436,9 @@ enum TSU_FWSLC_BIT {
  */
 struct sh_eth_txdesc {
 	u32 status;		/* TD0 */
-#if defined(__LITTLE_ENDIAN)
-	u16 pad0;		/* TD1 */
-	u16 buffer_length;	/* TD1 */
-#else
-	u16 buffer_length;	/* TD1 */
-	u16 pad0;		/* TD1 */
-#endif
+	u32 len;		/* TD1 */
 	u32 addr;		/* TD2 */
-	u32 pad1;		/* padding data */
+	u32 pad0;		/* padding data */
 } __aligned(2) __packed;
 
 /* The sh ether Rx buffer descriptors.
@@ -441,13 +446,7 @@ struct sh_eth_txdesc {
  */
 struct sh_eth_rxdesc {
 	u32 status;		/* RD0 */
-#if defined(__LITTLE_ENDIAN)
-	u16 frame_length;	/* RD1 */
-	u16 buffer_length;	/* RD1 */
-#else
-	u16 buffer_length;	/* RD1 */
-	u16 frame_length;	/* RD1 */
-#endif
+	u32 len;		/* RD1 */
 	u32 addr;		/* RD2 */
 	u32 pad0;		/* padding data */
 } __aligned(2) __packed;
