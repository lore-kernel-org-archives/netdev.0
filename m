From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH] skge: fix broken driver
Date: Thu, 19 Sep 2013 14:04:38 -0400 (EDT)
Message-ID: <alpine.LRH.2.02.1309191359300.12162@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1309191229480.32035@file01.intranet.prod.int.rdu2.redhat.com> <20130919.135628.1201613770803318193.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62924 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752136Ab3ISSEl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Sep 2013 14:04:41 -0400
In-Reply-To: <20130919.135628.1201613770803318193.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, 19 Sep 2013, David Miller wrote:

> From: Mikulas Patocka <mpatocka@redhat.com>
> Date: Thu, 19 Sep 2013 12:33:30 -0400 (EDT)
> 
> > Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
> > Cc: stable@kernel.org # 3.11
> 
> First, this is missing the reported-by and tested-by tags provided
> by people who tested this patch.

I noticed the problem and tested the patch on my own machine. So I added 
myself to these tags.

> Secondly, CC:'ing stable is not the correct way to submit networking
> patches for -stable inclusion.  You simply ask me to queue them up
> for -stable explicitly instead.
> 
> Please re-submit this with the currect signoffs, thank you.

Here I'm re-submitting it.

---

skge: fix broken driver

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

This bug is present in kernels 3.11, 3.11.1 and 3.12-rc1. The patch should 
be queued for 3.11-stable.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
Reported-by: Mikulas Patocka <mpatocka@redhat.com>
Tested-by: Mikulas Patocka <mpatocka@redhat.com>

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
