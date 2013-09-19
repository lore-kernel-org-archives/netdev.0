From: Mikulas Patocka <mpatocka@redhat.com>
Subject: [PATCH] skge: fix broken driver
Date: Thu, 19 Sep 2013 12:33:30 -0400 (EDT)
Message-ID: <alpine.LRH.2.02.1309191229480.32035@file01.intranet.prod.int.rdu2.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13234 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752417Ab3ISQdd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Sep 2013 12:33:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch 136d8f377e1575463b47840bc5f1b22d94bf8f63 broke the skge driver.

Note this part of the patch:
+               if (skge_rx_setup(skge, e, nskb, skge->rx_buf_size) < 0) {
+                       dev_kfree_skb(nskb);
+                       goto resubmit;
+               }
+
                pci_unmap_single(skge->hw->pdev,
                                 dma_unmap_addr(e, mapaddr),
                                 dma_unmap_len(e, maplen),
                                 PCI_DMA_FROMDEVICE);
                skb = e->skb;
                prefetch(skb->data);
-               skge_rx_setup(skge, e, nskb, skge->rx_buf_size);

The function skge_rx_setup modifies e->skb to point to the new skb. Thus,
after this change, the new buffer, not the old, is returned to the
networking stack.

This bug is present in kernels 3.11, 3.11.1 and 3.12-rc1.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
Cc: stable@kernel.org # 3.11

---
 drivers/net/ethernet/marvell/skge.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

Index: linux-3.11.1-fast/drivers/net/ethernet/marvell/skge.c
===================================================================
--- linux-3.11.1-fast.orig/drivers/net/ethernet/marvell/skge.c	2013-09-10 19:46:58.000000000 +0200
+++ linux-3.11.1-fast/drivers/net/ethernet/marvell/skge.c	2013-09-19 18:20:43.000000000 +0200
@@ -3092,6 +3092,9 @@ static struct sk_buff *skge_rx_get(struc
 		if (!nskb)
 			goto resubmit;
 
+		skb = e->skb;
+		prefetch(skb->data);
+
 		if (skge_rx_setup(skge, e, nskb, skge->rx_buf_size) < 0) {
 			dev_kfree_skb(nskb);
 			goto resubmit;
@@ -3101,8 +3104,6 @@ static struct sk_buff *skge_rx_get(struc
 				 dma_unmap_addr(e, mapaddr),
 				 dma_unmap_len(e, maplen),
 				 PCI_DMA_FROMDEVICE);
-		skb = e->skb;
-		prefetch(skb->data);
 	}
 
 	skb_put(skb, len);
