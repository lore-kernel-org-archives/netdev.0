From: Haavard Skinnemoen <hskinnemoen@atmel.com>
Subject: Re: [PATCH] MACB: clear transmit buffers properly on TX Underrun
Date: Thu, 13 Dec 2007 12:33:08 +0100
Message-ID: <20071213123308.156ab7dd@dhcp-252-066.norway.atmel.com>
References: <4760E49D.5040406@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org
To: Gregory CLEMENT <novexz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat-132.atmel.no ([80.232.32.132]:59375 "EHLO relay.atmel.no"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752561AbXLMLda (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2007 06:33:30 -0500
In-Reply-To: <4760E49D.5040406@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 13 Dec 2007 08:51:57 +0100
Gregory CLEMENT <novexz@gmail.com> wrote:

> Hi,
> I generated this patch for linux 2.6.24-rc5 and test it on AT91SAM9263 
> with iperf.
> 
> From: Gregory CLEMENT <gclement00@gmail.com>
> Date: Wed, 12 Dec 2007 18:10:14 +0100
> Subject: [PATCH] MACB: clear transmit buffers properly on TX Underrun
> 
> Initially transmit buffer pointers were only reset. But buffer descriptors
> were possibly still set as ready, and buffer in upper layer was not
> freed. This caused driver hang under big load.
> Now reset clean properly the buffer descriptor and freed upper layer.

Nice. I think we want this for 2.6.24.

But the patch is a bit mangled, so I don't think it will apply. Please
have a look in Documentation/email-clients.txt for information on how
to set up Thunderbird to avoid this.

> Signed-off-by: Gregory CLEMENT <gclement00@gmail.com>
> ---
>  drivers/net/macb.c |   26 +++++++++++++++++++++++++-
>  1 files changed, 25 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/macb.c b/drivers/net/macb.c
> index 047ea7b..2ee1dab 100644
> --- a/drivers/net/macb.c
> +++ b/drivers/net/macb.c
> @@ -307,9 +307,33 @@ static void macb_tx(struct macb *bp)
>          (unsigned long)status);
>  
>      if (status & MACB_BIT(UND)) {
> +        int i;
>          printk(KERN_ERR "%s: TX underrun, resetting buffers\n",
> -               bp->dev->name);
> +               bp->dev->name);
> +
> +        head = bp->tx_head;
> +
> +        /* free transmit buffer in upper layer*/
> +        for (tail = bp->tx_tail; tail != head; tail = NEXT_TX(tail)) {
> +            struct ring_info *rp = &bp->tx_skb[tail];
> +            struct sk_buff *skb = rp->skb;
> +
> +            BUG_ON(skb == NULL);
> +
> +            rmb();
> +
> +            dma_unmap_single(&bp->pdev->dev, rp->mapping, skb->len,
> +                             DMA_TO_DEVICE);
> +            rp->skb = NULL;
> +            dev_kfree_skb_irq(skb);
> +        }
> +
> +        /*Mark all the buffer as used to avoid sending a lost buffer*/
> +        for (i = 0; i < RX_RING_SIZE; i++)
> +            bp->tx_ring[i].ctrl = MACB_BIT(TX_USED);

That should be TX_RING_SIZE, shouldn't it?

I also think this should be done as part of the previous loop, before
they are freed. Having free buffers in the ring sounds dangerous, even
if it's only for a short time.

> +
>          bp->tx_head = bp->tx_tail = 0;

Now, I wonder if it would be better to just scan the ring descriptors,
find the one that failed and just move the DMA pointer to the next
entry. The hardware resets the DMA pointer when an underrun happens, so
I think your code will work, but we're losing more packets than
strictly necessary. In any case, it's better than the existing code.

Perhaps we need a check in macb_start_xmit() as well to avoid starting
a transmission when the ring has just been reset.

Haavard
