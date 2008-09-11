From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3]: tg3: Use SKB DMA helper functions for TX.
Date: Thu, 11 Sep 2008 15:45:31 -0700 (PDT)
Message-ID: <20080911.154531.136830945.davem@davemloft.net>
References: <20080911.050311.57379088.davem@davemloft.net>
	<1221155921.12785.9.camel@HP1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59225
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752634AbYIKWph (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 18:45:37 -0400
In-Reply-To: <1221155921.12785.9.camel@HP1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 11 Sep 2008 10:58:41 -0700

> On Thu, 2008-09-11 at 05:03 -0700, David Miller wrote:
> > @@ -4633,12 +4624,13 @@ static int tigon3_dma_hwbug_workaround(struct tg3 *tp, struct sk_buff *skb,
> >         } else {
> >                 /* New SKB is guaranteed to be linear. */
> >                 entry = *start;
> > -               new_addr = pci_map_single(tp->pdev, new_skb->data, new_skb->len,
> > -                                         PCI_DMA_TODEVICE);
> > +               ret = skb_dma_map(&tp->pdev->dev, new_skb, DMA_TO_DEVICE);
> > +               new_addr = skb_shinfo(new_skb)->dma_maps[0];
> > +
> >                 /* Make sure new skb does not cross any 4G boundaries.
> >                  * Drop the packet if it does.
> >                  */
> > -               if (tg3_4g_overflow_test(new_addr, new_skb->len)) {
> > +               if (ret || tg3_4g_overflow_test(new_addr, new_skb->len)) {
> >                         ret = -1;
> 
> Looks like we are missing an unmap call here even in the original code.
> If skb_dma_map() returns 0 but overflow test fails, we need to call
> unmap here.

Good catch, I'll fix it as follows:

tg3: Fix DMA mapping leak in tigon3_dma_hwbug_workaround().

Noticed by Michael Chan.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/tg3.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 355e8bc..1239207 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4631,6 +4631,9 @@ static int tigon3_dma_hwbug_workaround(struct tg3 *tp, struct sk_buff *skb,
 		 * Drop the packet if it does.
 		 */
 		if (ret || tg3_4g_overflow_test(new_addr, new_skb->len)) {
+			if (!ret)
+				skb_dma_unmap(&tp->pdev->dev, new_skb,
+					      DMA_TO_DEVICE);
 			ret = -1;
 			dev_kfree_skb(new_skb);
 			new_skb = NULL;
-- 
1.5.6.5.GIT

