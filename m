From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [PATCH 4/5] defxx: Handle DMA mapping errors
Date: Sat, 5 Jul 2014 15:14:40 +0100 (BST)
Message-ID: <alpine.LFD.2.11.1407020604200.15455@eddie.linux-mips.org>
References: <alpine.LFD.2.11.1407020439490.15455@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Robert Coerver <Robert.Coerver@ll.mit.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([78.24.191.182]:59876 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753735AbaGEOOl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jul 2014 10:14:41 -0400
Received: from localhost.localdomain ([127.0.0.1]:48342 "EHLO
        localhost.localdomain" rhost-flags-OK-OK-OK-OK)
        by eddie.linux-mips.org with ESMTP id S6859943AbaGEOOkgTB2U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Jul 2014 16:14:40 +0200
In-Reply-To: <alpine.LFD.2.11.1407020439490.15455@eddie.linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds error handling for DMA mapping requests; I think there isn't
much else to say about it.

A good side-effect is the mapping in the transmit path is now made with
the board lock released.  Also if DMA mapping fails for a newly
allocated receive buffer, then data from the old buffer will be copied
out (as is presently done for small frames only whose size does not
exceed SKBUFF_RX_COPYBREAK) and the original buffer returned, with its 
mapping unchanged, to the DMA descriptor ring.

Reported-by: Robert Coerver <Robert.Coerver@ll.mit.edu>
Tested-by: Robert Coerver <Robert.Coerver@ll.mit.edu>
Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
---
 Please apply,

  Maciej

linux-defxx-dma-map-error.patch
Index: linux-20140623-swarm64-eb/drivers/net/fddi/defxx.c
===================================================================
--- linux-20140623-swarm64-eb.orig/drivers/net/fddi/defxx.c
+++ linux-20140623-swarm64-eb/drivers/net/fddi/defxx.c
@@ -2927,21 +2927,35 @@ static int dfx_rcv_init(DFX_board_t *bp,
 	for (i = 0; i < (int)(bp->rcv_bufs_to_post); i++)
 		for (j = 0; (i + j) < (int)PI_RCV_DATA_K_NUM_ENTRIES; j += bp->rcv_bufs_to_post)
 		{
-			struct sk_buff *newskb = __netdev_alloc_skb(bp->dev, NEW_SKB_SIZE, GFP_NOIO);
+			struct sk_buff *newskb;
+			dma_addr_t dma_addr;
+
+			newskb = __netdev_alloc_skb(bp->dev, NEW_SKB_SIZE,
+						    GFP_NOIO);
 			if (!newskb)
 				return -ENOMEM;
-			bp->descr_block_virt->rcv_data[i+j].long_0 = (u32) (PI_RCV_DESCR_M_SOP |
-				((PI_RCV_DATA_K_SIZE_MAX / PI_ALIGN_K_RCV_DATA_BUFF) << PI_RCV_DESCR_V_SEG_LEN));
 			/*
 			 * align to 128 bytes for compatibility with
 			 * the old EISA boards.
 			 */
 
 			my_skb_align(newskb, 128);
+			dma_addr = dma_map_single(bp->bus_dev,
+						  newskb->data,
+						  PI_RCV_DATA_K_SIZE_MAX,
+						  DMA_FROM_DEVICE);
+			if (dma_mapping_error(bp->bus_dev, dma_addr)) {
+				dev_kfree_skb(newskb);
+				return -ENOMEM;
+			}
+			bp->descr_block_virt->rcv_data[i + j].long_0 =
+				(u32)(PI_RCV_DESCR_M_SOP |
+				      ((PI_RCV_DATA_K_SIZE_MAX /
+					PI_ALIGN_K_RCV_DATA_BUFF) <<
+				       PI_RCV_DESCR_V_SEG_LEN));
 			bp->descr_block_virt->rcv_data[i + j].long_1 =
-				(u32)dma_map_single(bp->bus_dev, newskb->data,
-						    PI_RCV_DATA_K_SIZE_MAX,
-						    DMA_FROM_DEVICE);
+				(u32)dma_addr;
+
 			/*
 			 * p_rcv_buff_va is only used inside the
 			 * kernel so we put the skb pointer here.
@@ -3008,7 +3022,7 @@ static void dfx_rcv_queue_process(
 	PI_TYPE_2_CONSUMER	*p_type_2_cons;		/* ptr to rcv/xmt consumer block register */
 	char				*p_buff;			/* ptr to start of packet receive buffer (FMC descriptor) */
 	u32					descr, pkt_len;		/* FMC descriptor field and packet length */
-	struct sk_buff		*skb;				/* pointer to a sk_buff to hold incoming packet data */
+	struct sk_buff		*skb = NULL;			/* pointer to a sk_buff to hold incoming packet data */
 
 	/* Service all consumed LLC receive frames */
 
@@ -3046,15 +3060,30 @@ static void dfx_rcv_queue_process(
 				bp->rcv_length_errors++;
 			else{
 #ifdef DYNAMIC_BUFFERS
+				struct sk_buff *newskb = NULL;
+
 				if (pkt_len > SKBUFF_RX_COPYBREAK) {
-					struct sk_buff *newskb;
+					dma_addr_t new_dma_addr;
 
 					newskb = netdev_alloc_skb(bp->dev,
 								  NEW_SKB_SIZE);
 					if (newskb){
+						my_skb_align(newskb, 128);
+						new_dma_addr = dma_map_single(
+								bp->bus_dev,
+								newskb->data,
+								PI_RCV_DATA_K_SIZE_MAX,
+								DMA_FROM_DEVICE);
+						if (dma_mapping_error(
+								bp->bus_dev,
+								new_dma_addr)) {
+							dev_kfree_skb(newskb);
+							newskb = NULL;
+						}
+					}
+					if (newskb) {
 						rx_in_place = 1;
 
-						my_skb_align(newskb, 128);
 						skb = (struct sk_buff *)bp->p_rcv_buff_va[entry];
 						dma_unmap_single(bp->bus_dev,
 							bp->descr_block_virt->rcv_data[entry].long_1,
@@ -3062,14 +3091,10 @@ static void dfx_rcv_queue_process(
 							DMA_FROM_DEVICE);
 						skb_reserve(skb, RCV_BUFF_K_PADDING);
 						bp->p_rcv_buff_va[entry] = (char *)newskb;
-						bp->descr_block_virt->rcv_data[entry].long_1 =
-							(u32)dma_map_single(bp->bus_dev,
-								newskb->data,
-								PI_RCV_DATA_K_SIZE_MAX,
-								DMA_FROM_DEVICE);
-					} else
-						skb = NULL;
-				} else
+						bp->descr_block_virt->rcv_data[entry].long_1 = (u32)new_dma_addr;
+					}
+				}
+				if (!newskb)
 #endif
 					/* Alloc new buffer to pass up,
 					 * add room for PRH. */
@@ -3186,6 +3211,7 @@ static netdev_tx_t dfx_xmt_queue_pkt(str
 	u8			prod;				/* local transmit producer index */
 	PI_XMT_DESCR		*p_xmt_descr;		/* ptr to transmit descriptor block entry */
 	XMT_DRIVER_DESCR	*p_xmt_drv_descr;	/* ptr to transmit driver descriptor */
+	dma_addr_t		dma_addr;
 	unsigned long		flags;
 
 	netif_stop_queue(dev);
@@ -3233,6 +3259,20 @@ static netdev_tx_t dfx_xmt_queue_pkt(str
 			}
 		}
 
+	/* Write the three PRH bytes immediately before the FC byte */
+
+	skb_push(skb, 3);
+	skb->data[0] = DFX_PRH0_BYTE;	/* these byte values are defined */
+	skb->data[1] = DFX_PRH1_BYTE;	/* in the Motorola FDDI MAC chip */
+	skb->data[2] = DFX_PRH2_BYTE;	/* specification */
+
+	dma_addr = dma_map_single(bp->bus_dev, skb->data, skb->len,
+				  DMA_TO_DEVICE);
+	if (dma_mapping_error(bp->bus_dev, dma_addr)) {
+		skb_pull(skb, 3);
+		return NETDEV_TX_BUSY;
+	}
+
 	spin_lock_irqsave(&bp->lock, flags);
 
 	/* Get the current producer and the next free xmt data descriptor */
@@ -3253,13 +3293,6 @@ static netdev_tx_t dfx_xmt_queue_pkt(str
 
 	p_xmt_drv_descr = &(bp->xmt_drv_descr_blk[prod++]);	/* also bump producer index */
 
-	/* Write the three PRH bytes immediately before the FC byte */
-
-	skb_push(skb,3);
-	skb->data[0] = DFX_PRH0_BYTE;	/* these byte values are defined */
-	skb->data[1] = DFX_PRH1_BYTE;	/* in the Motorola FDDI MAC chip */
-	skb->data[2] = DFX_PRH2_BYTE;	/* specification */
-
 	/*
 	 * Write the descriptor with buffer info and bump producer
 	 *
@@ -3288,8 +3321,7 @@ static netdev_tx_t dfx_xmt_queue_pkt(str
 	 */
 
 	p_xmt_descr->long_0	= (u32) (PI_XMT_DESCR_M_SOP | PI_XMT_DESCR_M_EOP | ((skb->len) << PI_XMT_DESCR_V_SEG_LEN));
-	p_xmt_descr->long_1 = (u32)dma_map_single(bp->bus_dev, skb->data,
-						  skb->len, DMA_TO_DEVICE);
+	p_xmt_descr->long_1 = (u32)dma_addr;
 
 	/*
 	 * Verify that descriptor is actually available
