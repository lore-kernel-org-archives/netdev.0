From: Brice Goglin <brice@myri.com>
Subject: [PATCH 1/2] myri10ge: remove wcfifo
Date: Mon, 21 Jul 2008 10:25:50 +0200
Message-ID: <4884480E.6080706@myri.com>
References: <488447E7.2060505@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1861 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753570AbYGUI0X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jul 2008 04:26:23 -0400
In-Reply-To: <488447E7.2060505@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the wcfifo since it never gave any performance improvement.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |   54 ++--------------------------------------
 1 file changed, 3 insertions(+), 51 deletions(-)

Index: linux-2.6/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-2.6.orig/drivers/net/myri10ge/myri10ge.c	2008-07-21 09:23:20.000000000 +0200
+++ linux-2.6/drivers/net/myri10ge/myri10ge.c	2008-07-21 09:24:21.000000000 +0200
@@ -125,7 +125,6 @@
 
 struct myri10ge_rx_buf {
 	struct mcp_kreq_ether_recv __iomem *lanai;	/* lanai ptr for recv ring */
-	u8 __iomem *wc_fifo;	/* w/c rx dma addr fifo address */
 	struct mcp_kreq_ether_recv *shadow;	/* host shadow of recv ring */
 	struct myri10ge_rx_buffer_state *info;
 	struct page *page;
@@ -140,7 +139,6 @@
 
 struct myri10ge_tx_buf {
 	struct mcp_kreq_ether_send __iomem *lanai;	/* lanai ptr for sendq */
-	u8 __iomem *wc_fifo;	/* w/c send fifo address */
 	struct mcp_kreq_ether_send *req_list;	/* host shadow of sendq */
 	char *req_bytes;
 	struct myri10ge_tx_buffer_state *info;
@@ -332,10 +330,6 @@
 
 static int myri10ge_reset_recover = 1;
 
-static int myri10ge_wcfifo = 0;
-module_param(myri10ge_wcfifo, int, S_IRUGO);
-MODULE_PARM_DESC(myri10ge_wcfifo, "Enable WC Fifo when WC is enabled");
-
 static int myri10ge_max_slices = 1;
 module_param(myri10ge_max_slices, int, S_IRUGO);
 MODULE_PARM_DESC(myri10ge_max_slices, "Max tx/rx queues");
@@ -1218,14 +1212,8 @@
 
 		/* copy 8 descriptors to the firmware at a time */
 		if ((idx & 7) == 7) {
-			if (rx->wc_fifo == NULL)
-				myri10ge_submit_8rx(&rx->lanai[idx - 7],
-						    &rx->shadow[idx - 7]);
-			else {
-				mb();
-				myri10ge_pio_copy(rx->wc_fifo,
-						  &rx->shadow[idx - 7], 64);
-			}
+			myri10ge_submit_8rx(&rx->lanai[idx - 7],
+					    &rx->shadow[idx - 7]);
 		}
 	}
 }
@@ -2229,18 +2217,6 @@
 	ss->rx_big.lanai = (struct mcp_kreq_ether_recv __iomem *)
 	    (mgp->sram + cmd.data0);
 
-	if (myri10ge_wcfifo && mgp->wc_enabled) {
-		ss->tx.wc_fifo = (u8 __iomem *)
-		    mgp->sram + MXGEFW_ETH_SEND_4 + 64 * slice;
-		ss->rx_small.wc_fifo = (u8 __iomem *)
-		    mgp->sram + MXGEFW_ETH_RECV_SMALL + 64 * slice;
-		ss->rx_big.wc_fifo = (u8 __iomem *)
-		    mgp->sram + MXGEFW_ETH_RECV_BIG + 64 * slice;
-	} else {
-		ss->tx.wc_fifo = NULL;
-		ss->rx_small.wc_fifo = NULL;
-		ss->rx_big.wc_fifo = NULL;
-	}
 	return status;
 
 }
@@ -2573,27 +2549,6 @@
 	mb();
 }
 
-static inline void
-myri10ge_submit_req_wc(struct myri10ge_tx_buf *tx,
-		       struct mcp_kreq_ether_send *src, int cnt)
-{
-	tx->req += cnt;
-	mb();
-	while (cnt >= 4) {
-		myri10ge_pio_copy(tx->wc_fifo, src, 64);
-		mb();
-		src += 4;
-		cnt -= 4;
-	}
-	if (cnt > 0) {
-		/* pad it to 64 bytes.  The src is 64 bytes bigger than it
-		 * needs to be so that we don't overrun it */
-		myri10ge_pio_copy(tx->wc_fifo + MXGEFW_ETH_SEND_OFFSET(cnt),
-				  src, 64);
-		mb();
-	}
-}
-
 /*
  * Transmit a packet.  We need to split the packet so that a single
  * segment does not cross myri10ge->tx_boundary, so this makes segment
@@ -2830,10 +2785,7 @@
 					 MXGEFW_FLAGS_FIRST)));
 	idx = ((count - 1) + tx->req) & tx->mask;
 	tx->info[idx].last = 1;
-	if (tx->wc_fifo == NULL)
-		myri10ge_submit_req(tx, tx->req_list, count);
-	else
-		myri10ge_submit_req_wc(tx, tx->req_list, count);
+	myri10ge_submit_req(tx, tx->req_list, count);
 	tx->pkt_start++;
 	if ((avail - count) < MXGEFW_MAX_SEND_DESC) {
 		tx->stop_queue++;


