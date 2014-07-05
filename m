From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [PATCH 5/5] defxx: Add missing DMA synchronisation calls
Date: Sat, 5 Jul 2014 15:14:46 +0100 (BST)
Message-ID: <alpine.LFD.2.11.1407020616360.15455@eddie.linux-mips.org>
References: <alpine.LFD.2.11.1407020439490.15455@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Robert Coerver <Robert.Coerver@ll.mit.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([78.24.191.182]:59876 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932098AbaGEOOr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jul 2014 10:14:47 -0400
Received: from localhost.localdomain ([127.0.0.1]:48345 "EHLO
        localhost.localdomain" rhost-flags-OK-OK-OK-OK)
        by eddie.linux-mips.org with ESMTP id S6859971AbaGEOOqQNnoC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Jul 2014 16:14:46 +0200
In-Reply-To: <alpine.LFD.2.11.1407020439490.15455@eddie.linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds DMA synchronisation calls needed in the receive path:

1. To retrieve the Receive Status word that is prepended by the PDQ DMA
   engine in the receive buffer, and provides information about the
   frame received, including its size and any errors.

2. To make data received available for copying in the small-frame case
   (size <= SKBUFF_RX_COPYBREAK) where the original DMA buffer will be
   returned to the receive descriptor ring and therefore its mapping
   retained.

   With DMA mapping error handling in place, added by the other patch,
   this may now also trigger where an attempt to map a newly allocated
   buffer for DMA has failed.  In that case data from the original buffer
   will be copied out and the buffer returned to the DMA descriptor ring.

These calls may do nothing when data is in the host DMA addressing range
of the FDDI interface, such as always on 32-bit systems, however their
absence makes frame reception stop functioning reliably on systems that
have memory beyond the low 4GB of the address space.

Reported-by: Robert Coerver <Robert.Coerver@ll.mit.edu>
Tested-by: Robert Coerver <Robert.Coerver@ll.mit.edu>
Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
---
 Please apply,

  Maciej

linux-defxx-dma-map-sync.patch
Index: linux-20140623-swarm64-eb/drivers/net/fddi/defxx.c
===================================================================
--- linux-20140623-swarm64-eb.orig/drivers/net/fddi/defxx.c
+++ linux-20140623-swarm64-eb/drivers/net/fddi/defxx.c
@@ -196,6 +196,7 @@
  *		14 Jun 2005	macro		Use irqreturn_t.
  *		23 Oct 2006	macro		Big-endian host support.
  *		14 Dec 2006	macro		TURBOchannel support.
+ *		01 Jul 2014	macro		Fixes for DMA on 64-bit hosts.
  */
 
 /* Include files */
@@ -224,8 +225,8 @@
 
 /* Version information string should be updated prior to each new release!  */
 #define DRV_NAME "defxx"
-#define DRV_VERSION "v1.10"
-#define DRV_RELDATE "2006/12/14"
+#define DRV_VERSION "v1.11"
+#define DRV_RELDATE "2014/07/01"
 
 static char version[] =
 	DRV_NAME ": " DRV_VERSION " " DRV_RELDATE
@@ -3030,7 +3031,7 @@ static void dfx_rcv_queue_process(
 	while (bp->rcv_xmt_reg.index.rcv_comp != p_type_2_cons->index.rcv_cons)
 		{
 		/* Process any errors */
-
+		dma_addr_t dma_addr;
 		int entry;
 
 		entry = bp->rcv_xmt_reg.index.rcv_comp;
@@ -3039,6 +3040,11 @@ static void dfx_rcv_queue_process(
 #else
 		p_buff = bp->p_rcv_buff_va[entry];
 #endif
+		dma_addr = bp->descr_block_virt->rcv_data[entry].long_1;
+		dma_sync_single_for_cpu(bp->bus_dev,
+					dma_addr + RCV_BUFF_K_DESCR,
+					sizeof(u32),
+					DMA_FROM_DEVICE);
 		memcpy(&descr, p_buff + RCV_BUFF_K_DESCR, sizeof(u32));
 
 		if (descr & PI_FMC_DESCR_M_RCC_FLUSH)
@@ -3086,7 +3092,7 @@ static void dfx_rcv_queue_process(
 
 						skb = (struct sk_buff *)bp->p_rcv_buff_va[entry];
 						dma_unmap_single(bp->bus_dev,
-							bp->descr_block_virt->rcv_data[entry].long_1,
+							dma_addr,
 							PI_RCV_DATA_K_SIZE_MAX,
 							DMA_FROM_DEVICE);
 						skb_reserve(skb, RCV_BUFF_K_PADDING);
@@ -3109,6 +3115,12 @@ static void dfx_rcv_queue_process(
 				else {
 					if (!rx_in_place) {
 						/* Receive buffer allocated, pass receive packet up */
+						dma_sync_single_for_cpu(
+							bp->bus_dev,
+							dma_addr +
+							RCV_BUFF_K_PADDING,
+							pkt_len + 3,
+							DMA_FROM_DEVICE);
 
 						skb_copy_to_linear_data(skb,
 							       p_buff + RCV_BUFF_K_PADDING,
