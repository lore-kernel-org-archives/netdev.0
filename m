From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: Re: [PATCH RFC] fix problems with NETIF_F_HIGHDMA in networking
 drivers v2
Date: Wed, 31 Mar 2010 17:35:50 +0900
Message-ID: <20100331173507I.fujita.tomonori@lab.ntt.co.jp>
References: <51f3faa71003251803q7ccec5d5x82bc277c590e2848@mail.gmail.com>
	<20100326123250A.fujita.tomonori@lab.ntt.co.jp>
	<20100325.203520.234306178.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fujita.tomonori@lab.ntt.co.jp, hancockrwd@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, bzolnier@gmail.com
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100325.203520.234306178.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 25 Mar 2010 20:35:20 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
> Date: Fri, 26 Mar 2010 12:33:12 +0900
> 
> > On Thu, 25 Mar 2010 19:03:37 -0600
> > Robert Hancock <hancockrwd@gmail.com> wrote:
> > 
> >> This seems like it could be a reasonable approach. The only thing is
> >> that in this code you're returning 1 if the parent device has no DMA
> >> mask set. Wouldn't it make more sense to return 0 in this case? I'm
> >> assuming that in that situation it's a virtual device not backed by
> >> any hardware and there should be no DMA mask restriction...
> > 
> > I chose the safer option because I don't know enough how net_device
> > structure is used. If returning zero in such case is always safe, it's
> > fine by me. any example of such virtual device driver?
> 
> Like Fujita I'd rather play it safe here.
> 
> Even for virtual devices, DMA information up to the root bus
> ought to be sane.

Agreed. 

Here's the patch in the proper format.

Probably, PCI_DMA_BUS_IS_PHYS should be renamed to something like
DMA_BUS_IS_PHYS and moved to the better place. Then we can avoid
including linux/pci.h.

=
From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: [PATCH] net: change illegal_highdma to use dma_mask

Robert Hancock pointed out two problems about NETIF_F_HIGHDMA:

-Many drivers only set the flag when they detect they can use 64-bit DMA,
since otherwise they could receive DMA addresses that they can't handle
(which on platforms without IOMMU/SWIOTLB support is fatal). This means that if
64-bit support isn't available, even buffers located below 4GB will get copied
unnecessarily.

-Some drivers set the flag even though they can't actually handle 64-bit DMA,
which would mean that on platforms without IOMMU/SWIOTLB they would get a DMA
mapping error if the memory they received happened to be located above 4GB.

http://lkml.org/lkml/2010/3/3/530


We can use the dma_mask if we need bouncing or not here. Then we can
safely fix drivers that misuse NETIF_F_HIGHDMA.

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 net/core/dev.c |   20 ++++++++++++++------
 1 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 5e3dc28..3a09f76 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -129,6 +129,7 @@
 #include <linux/jhash.h>
 #include <linux/random.h>
 #include <trace/events/napi.h>
+#include <linux/pci.h>
 
 #include "net-sysfs.h"
 
@@ -1790,14 +1791,21 @@ static inline int illegal_highdma(struct net_device *dev, struct sk_buff *skb)
 {
 #ifdef CONFIG_HIGHMEM
 	int i;
+	if (!(dev->features & NETIF_F_HIGHDMA)) {
+		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
+			if (PageHighMem(skb_shinfo(skb)->frags[i].page))
+				return 1;
+	}
 
-	if (dev->features & NETIF_F_HIGHDMA)
-		return 0;
-
-	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
-		if (PageHighMem(skb_shinfo(skb)->frags[i].page))
-			return 1;
+	if (PCI_DMA_BUS_IS_PHYS) {
+		struct device *pdev = dev->dev.parent;
 
+		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+			dma_addr_t addr = page_to_phys(skb_shinfo(skb)->frags[i].page);
+			if (!pdev->dma_mask || addr + PAGE_SIZE - 1 > *pdev->dma_mask)
+				return 1;
+		}
+	}
 #endif
 	return 0;
 }
-- 
1.7.0
