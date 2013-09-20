From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH] skge: fix broken driver
Date: Fri, 20 Sep 2013 10:32:18 -0400 (EDT)
Message-ID: <alpine.LRH.2.02.1309201030420.30821@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1309191229480.32035@file01.intranet.prod.int.rdu2.redhat.com> <20130919.135628.1201613770803318193.davem@davemloft.net> <alpine.LRH.2.02.1309191359300.12162@file01.intranet.prod.int.rdu2.redhat.com> <1379614608.2331.0.camel@ThinkPad-X230.localdomain>
 <alpine.LRH.2.02.1309191427420.15640@file01.intranet.prod.int.rdu2.redhat.com> <20130919213218.GA31672@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Igor Gnatenko <i.gnatenko.brain@gmail.com>,
	David Miller <davem@davemloft.net>, stephen@networkplumber.org,
	netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7979 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751870Ab3ITOcZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Sep 2013 10:32:25 -0400
In-Reply-To: <20130919213218.GA31672@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, 19 Sep 2013, Francois Romieu wrote:

> Mikulas Patocka <mpatocka@redhat.com> :
> [...]
> > I see. My patch is a bit simpler - it doesn't allocate the structure 
> > skge_element on the stack.
> 
> Both patches don't behave exactly the same wrt pci_unmap_single.
> 
> -- 
> Ueimor

I see, my patch passes a wrong value to pci_unmap_single. So I made this 
change to make it pass the correct value. Do you agree with this patch?

---

skge: fix invalid value passed to pci_unmap_sigle

In my patch c194992cbe71c20bb3623a566af8d11b0bfaa721 I didn't fix the skge
bug correctly. The value of the new mapping (not old) was passed to
pci_unmap_single.

If we enable CONFIG_DMA_API_DEBUG, it results in this warning:
WARNING: CPU: 0 PID: 0 at lib/dma-debug.c:986 check_sync+0x4c4/0x580()
skge 0000:02:07.0: DMA-API: device driver tries to sync DMA memory it has
not allocated [device address=0x000000023a0096c0] [size=1536 bytes]

This patch makes the skge driver pass the correct value to
pci_unmap_single and fixes the warning. It copies the old descriptor to
on-stack variable "ee" and unmaps it if mapping of the new descriptor
succeeded.

This patch should be backported to 3.11-stable.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
Reported-by: Francois Romieu <romieu@fr.zoreil.com>
Tested-by: Mikulas Patocka <mpatocka@redhat.com>

---
 drivers/net/ethernet/marvell/skge.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

Index: linux-3.11.1-fast/drivers/net/ethernet/marvell/skge.c
===================================================================
--- linux-3.11.1-fast.orig/drivers/net/ethernet/marvell/skge.c	2013-09-20 16:13:24.000000000 +0200
+++ linux-3.11.1-fast/drivers/net/ethernet/marvell/skge.c	2013-09-20 16:18:13.000000000 +0200
@@ -3086,13 +3086,16 @@ static struct sk_buff *skge_rx_get(struc
 					       PCI_DMA_FROMDEVICE);
 		skge_rx_reuse(e, skge->rx_buf_size);
 	} else {
+		struct skge_element ee;
 		struct sk_buff *nskb;
 
 		nskb = netdev_alloc_skb_ip_align(dev, skge->rx_buf_size);
 		if (!nskb)
 			goto resubmit;
 
-		skb = e->skb;
+		ee = *e;
+
+		skb = ee.skb;
 		prefetch(skb->data);
 
 		if (skge_rx_setup(skge, e, nskb, skge->rx_buf_size) < 0) {
@@ -3101,8 +3104,8 @@ static struct sk_buff *skge_rx_get(struc
 		}
 
 		pci_unmap_single(skge->hw->pdev,
-				 dma_unmap_addr(e, mapaddr),
-				 dma_unmap_len(e, maplen),
+				 dma_unmap_addr(&ee, mapaddr),
+				 dma_unmap_len(&ee, maplen),
 				 PCI_DMA_FROMDEVICE);
 	}
 
