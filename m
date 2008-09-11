From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 3/3]: tg3: Use SKB DMA helper functions for TX.
Date: Thu, 11 Sep 2008 10:58:41 -0700
Message-ID: <1221155921.12785.9.camel@HP1>
References: <20080911.050311.57379088.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2702 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752608AbYIKSAD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Sep 2008 14:00:03 -0400
In-Reply-To: <20080911.050311.57379088.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2008-09-11 at 05:03 -0700, David Miller wrote:
> tg3: Use SKB DMA helper functions for TX.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  drivers/net/tg3.c |   88 ++++++++++++++++++----------------------------------
>  drivers/net/tg3.h |    1 -
>  2 files changed, 31 insertions(+), 58 deletions(-)
> 
> diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> index 71d2c5c..355e8bc 100644
> --- a/drivers/net/tg3.c
> +++ b/drivers/net/tg3.c
> @@ -3861,10 +3861,7 @@ static void tg3_tx(struct tg3 *tp)
>                         return;
>                 }
> 
> -               pci_unmap_single(tp->pdev,
> -                                pci_unmap_addr(ri, mapping),
> -                                skb_headlen(skb),
> -                                PCI_DMA_TODEVICE);
> +               skb_dma_unmap(&tp->pdev->dev, skb, DMA_TO_DEVICE);
> 
>                 ri->skb = NULL;
> 
> @@ -3874,12 +3871,6 @@ static void tg3_tx(struct tg3 *tp)
>                         ri = &tp->tx_buffers[sw_idx];
>                         if (unlikely(ri->skb != NULL || sw_idx == hw_idx))
>                                 tx_bug = 1;
> -
> -                       pci_unmap_page(tp->pdev,
> -                                      pci_unmap_addr(ri, mapping),
> -                                      skb_shinfo(skb)->frags[i].size,
> -                                      PCI_DMA_TODEVICE);
> -
>                         sw_idx = NEXT_TX(sw_idx);
>                 }
> 
> @@ -4633,12 +4624,13 @@ static int tigon3_dma_hwbug_workaround(struct tg3 *tp, struct sk_buff *skb,
>         } else {
>                 /* New SKB is guaranteed to be linear. */
>                 entry = *start;
> -               new_addr = pci_map_single(tp->pdev, new_skb->data, new_skb->len,
> -                                         PCI_DMA_TODEVICE);
> +               ret = skb_dma_map(&tp->pdev->dev, new_skb, DMA_TO_DEVICE);
> +               new_addr = skb_shinfo(new_skb)->dma_maps[0];
> +
>                 /* Make sure new skb does not cross any 4G boundaries.
>                  * Drop the packet if it does.
>                  */
> -               if (tg3_4g_overflow_test(new_addr, new_skb->len)) {
> +               if (ret || tg3_4g_overflow_test(new_addr, new_skb->len)) {
>                         ret = -1;

Looks like we are missing an unmap call here even in the original code.
If skb_dma_map() returns 0 but overflow test fails, we need to call
unmap here.

>                         dev_kfree_skb(new_skb);
>                         new_skb = NULL;



