From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [PATCH] defxx: Fix !DYNAMIC_BUFFERS compilation warnings
Date: Sun, 29 Jun 2014 02:09:19 +0100 (BST)
Message-ID: <alpine.LFD.2.11.1406290146390.15455@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([78.24.191.182]:34124 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751102AbaF2BJV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jun 2014 21:09:21 -0400
Received: from localhost.localdomain ([127.0.0.1]:50815 "EHLO
        localhost.localdomain" rhost-flags-OK-OK-OK-OK)
        by eddie.linux-mips.org with ESMTP id S6822067AbaF2BJTNk-00 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jun 2014 03:09:19 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes compilation warnings:

drivers/net/fddi/defxx.c:294: warning: 'dfx_rcv_flush' declared inline after being called
drivers/net/fddi/defxx.c:294: warning: previous declaration of 'dfx_rcv_flush' was here
drivers/net/fddi/defxx.c:2854: warning: 'my_skb_align' defined but not used

triggered when the driver is built with DYNAMIC_BUFFERS undefined.  Code 
tested to work just fine with these changes and a few DEFPA and DEFTA 
boards.

Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
---
 Eventually I plan to discard !DYNAMIC_BUFFERS code, however the current 
implementation of dynamic allocation suffers from a problem that causes it 
to fail sometimes on a loaded system when the card is rebooted at run 
time, a legitimate though infrequent event in the course of a ring fault 
recovery process triggered by a PC Trace signal received.  The driver does 
it all in the hardirq handler, that I think is awful.  This can be worked 
around by undefining DYNAMIC_BUFFERS, in which case the same static 
buffers will be reused after a card reboot.

 I plan to rewrite this code by copying the approach I took with the defza 
driver I posted recently, that handles the same scenario in a way that 
does not suffer from this problem.  I think it's only then that the static 
allocation code can go.

 So for the time being, please apply.

  Maciej

linux-defxx-static-buffers-fixes.patch
Index: linux-20140623-4maxp64/drivers/net/fddi/defxx.c
===================================================================
--- linux-20140623-4maxp64.orig/drivers/net/fddi/defxx.c
+++ linux-20140623-4maxp64/drivers/net/fddi/defxx.c
@@ -291,7 +291,11 @@ static int		dfx_hw_dma_uninit(DFX_board_
 
 static int		dfx_rcv_init(DFX_board_t *bp, int get_buffers);
 static void		dfx_rcv_queue_process(DFX_board_t *bp);
+#ifdef DYNAMIC_BUFFERS
 static void		dfx_rcv_flush(DFX_board_t *bp);
+#else
+static inline void	dfx_rcv_flush(DFX_board_t *bp) {}
+#endif
 
 static netdev_tx_t dfx_xmt_queue_pkt(struct sk_buff *skb,
 				     struct net_device *dev);
@@ -2849,7 +2853,7 @@ static int dfx_hw_dma_uninit(DFX_board_t
  *	Align an sk_buff to a boundary power of 2
  *
  */
-
+#ifdef DYNAMIC_BUFFERS
 static void my_skb_align(struct sk_buff *skb, int n)
 {
 	unsigned long x = (unsigned long)skb->data;
@@ -2859,7 +2863,7 @@ static void my_skb_align(struct sk_buff 
 
 	skb_reserve(skb, v - x);
 }
-
+#endif
 
 /*
  * ================
@@ -3450,10 +3454,6 @@ static void dfx_rcv_flush( DFX_board_t *
 		}
 
 	}
-#else
-static inline void dfx_rcv_flush( DFX_board_t *bp )
-{
-}
 #endif /* DYNAMIC_BUFFERS */
 
 /*
