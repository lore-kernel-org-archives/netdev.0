From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [PATCH 2/5] defxx: Discard DMA maps on buffer deallocation
Date: Sat, 5 Jul 2014 15:14:30 +0100 (BST)
Message-ID: <alpine.LFD.2.11.1407020553450.15455@eddie.linux-mips.org>
References: <alpine.LFD.2.11.1407020439490.15455@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Robert Coerver <Robert.Coerver@ll.mit.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([78.24.191.182]:59876 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753017AbaGEOOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jul 2014 10:14:31 -0400
Received: from localhost.localdomain ([127.0.0.1]:48339 "EHLO
        localhost.localdomain" rhost-flags-OK-OK-OK-OK)
        by eddie.linux-mips.org with ESMTP id S6859971AbaGEOOaXDthp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Jul 2014 16:14:30 +0200
In-Reply-To: <alpine.LFD.2.11.1407020439490.15455@eddie.linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prearranged receive DMA bounce buffer mappings are not released in the
card reboot/shutdown path.  That does not affect frame reception, but
probably explains the random segmentation fault I observed the other day
on interface shutdown.  Card is rebooted as required by the spec in the
process of ring fault recovery when a PC Trace signal has been received.

This change fixes the problem in an obvious manner.

Reported-by: Robert Coerver <Robert.Coerver@ll.mit.edu>
Tested-by: Robert Coerver <Robert.Coerver@ll.mit.edu>
Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
---
 Please apply,

  Maciej

linux-defxx-rcv-flush-unmap.patch
Index: linux-20140623-swarm64-eb/drivers/net/fddi/defxx.c
===================================================================
--- linux-20140623-swarm64-eb.orig/drivers/net/fddi/defxx.c
+++ linux-20140623-swarm64-eb/drivers/net/fddi/defxx.c
@@ -3448,8 +3448,13 @@ static void dfx_rcv_flush( DFX_board_t *
 		{
 			struct sk_buff *skb;
 			skb = (struct sk_buff *)bp->p_rcv_buff_va[i+j];
-			if (skb)
+			if (skb) {
+				dma_unmap_single(bp->bus_dev,
+						 bp->descr_block_virt->rcv_data[i+j].long_1,
+						 PI_RCV_DATA_K_SIZE_MAX,
+						 DMA_FROM_DEVICE);
 				dev_kfree_skb(skb);
+			}
 			bp->p_rcv_buff_va[i+j] = NULL;
 		}
 
