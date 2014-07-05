From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [PATCH 1/5] defxx: Correct the receive DMA map size
Date: Sat, 5 Jul 2014 15:14:22 +0100 (BST)
Message-ID: <alpine.LFD.2.11.1407020544430.15455@eddie.linux-mips.org>
References: <alpine.LFD.2.11.1407020439490.15455@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Robert Coerver <Robert.Coerver@ll.mit.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([78.24.191.182]:59876 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752824AbaGEOOX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jul 2014 10:14:23 -0400
Received: from localhost.localdomain ([127.0.0.1]:48337 "EHLO
        localhost.localdomain" rhost-flags-OK-OK-OK-OK)
        by eddie.linux-mips.org with ESMTP id S6859971AbaGEOOXBTIdC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Jul 2014 16:14:23 +0200
In-Reply-To: <alpine.LFD.2.11.1407020439490.15455@eddie.linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Receive DMA maps are oversized, they include EISA legacy 128-byte
alignment padding in size calculation whereas this padding is never used
for data.  Worse yet, if the skb's data area has been realigned indeed,
then data beyond the end of the buffer will be synchronised from the
receive DMA bounce buffer, possibly corrupting data structures residing
in memory beyond the actual end of this data buffer.

Therefore switch to using PI_RCV_DATA_K_SIZE_MAX rather than NEW_SKB_SIZE
in DMA mapping, the value the former macro expands to is written to the
receive ring DMA descriptor of the PDQ DMA chip and determines the
maximum amount of data PDQ will ever transfer to the corresponding data
buffer, including all headers and padding.

Reported-by: Robert Coerver <Robert.Coerver@ll.mit.edu>
Tested-by: Robert Coerver <Robert.Coerver@ll.mit.edu>
Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
---
 Please apply,

  Maciej

linux-defxx-rx-dma-map-size.patch
Index: linux-20140623-swarm64-eb/drivers/net/fddi/defxx.c
===================================================================
--- linux-20140623-swarm64-eb.orig/drivers/net/fddi/defxx.c
+++ linux-20140623-swarm64-eb/drivers/net/fddi/defxx.c
@@ -2940,7 +2940,7 @@ static int dfx_rcv_init(DFX_board_t *bp,
 			my_skb_align(newskb, 128);
 			bp->descr_block_virt->rcv_data[i + j].long_1 =
 				(u32)dma_map_single(bp->bus_dev, newskb->data,
-						    NEW_SKB_SIZE,
+						    PI_RCV_DATA_K_SIZE_MAX,
 						    DMA_FROM_DEVICE);
 			/*
 			 * p_rcv_buff_va is only used inside the
@@ -3057,14 +3057,14 @@ static void dfx_rcv_queue_process(
 						skb = (struct sk_buff *)bp->p_rcv_buff_va[entry];
 						dma_unmap_single(bp->bus_dev,
 							bp->descr_block_virt->rcv_data[entry].long_1,
-							NEW_SKB_SIZE,
+							PI_RCV_DATA_K_SIZE_MAX,
 							DMA_FROM_DEVICE);
 						skb_reserve(skb, RCV_BUFF_K_PADDING);
 						bp->p_rcv_buff_va[entry] = (char *)newskb;
 						bp->descr_block_virt->rcv_data[entry].long_1 =
 							(u32)dma_map_single(bp->bus_dev,
 								newskb->data,
-								NEW_SKB_SIZE,
+								PI_RCV_DATA_K_SIZE_MAX,
 								DMA_FROM_DEVICE);
 					} else
 						skb = NULL;
