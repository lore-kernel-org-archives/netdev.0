From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Subject: Re: [PATCH] net/macb: move to circ_buf macros and fix initial
 condition
Date: Mon, 19 Nov 2012 16:33:57 +0100
Message-ID: <20121119153357.GM4398@game.jcrosoft.org>
References: <1353338244-11506-1-git-send-email-nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Joachim Eastwood <manabian@gmail.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 19.mo5.mail-out.ovh.net ([46.105.35.78]:41433 "EHLO
	mo5.mail-out.ovh.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753059Ab2KSPgA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 10:36:00 -0500
Received: from mail404.ha.ovh.net (b9.ovh.net [213.186.33.59])
	by mo5.mail-out.ovh.net (Postfix) with SMTP id 5DB7A1010054
	for <netdev@vger.kernel.org>; Mon, 19 Nov 2012 16:43:45 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <1353338244-11506-1-git-send-email-nicolas.ferre@atmel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16:17 Mon 19 Nov     , Nicolas Ferre wrote:
> Move to circular buffers management macro and correct an error
> with circular buffer initial condition.
> 
> Without this patch, the macb_tx_ring_avail() function was
> not reporting the proper ring availability at startup:
> macb macb: eth0: BUG! Tx Ring full when queue awake!
> macb macb: eth0: tx_head = 0, tx_tail = 0
> And hanginig forever...
> 
> I remove the macb_tx_ring_avail() function and use the
> proven macros from circ_buf.h. CIRC_CNT() is used in the
> "consumer" part of the driver: macb_tx_interrupt() to match
> advice from Documentation/circular-buffers.txt.
> 
> Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>

Just tested on 9260
Tested-by: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>

Best Regards,
J.
> ---
>  drivers/net/ethernet/cadence/macb.c | 17 +++++++----------
>  1 file changed, 7 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index edb2aba..27991dd 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -14,6 +14,7 @@
>  #include <linux/moduleparam.h>
>  #include <linux/kernel.h>
>  #include <linux/types.h>
> +#include <linux/circ_buf.h>
>  #include <linux/slab.h>
>  #include <linux/init.h>
>  #include <linux/gpio.h>
> @@ -38,8 +39,8 @@
>  #define TX_RING_SIZE		128 /* must be power of 2 */
>  #define TX_RING_BYTES		(sizeof(struct macb_dma_desc) * TX_RING_SIZE)
>  
> -/* minimum number of free TX descriptors before waking up TX process */
> -#define MACB_TX_WAKEUP_THRESH	(TX_RING_SIZE / 4)
> +/* level of occupied TX descriptors under which we wake up TX process */
> +#define MACB_TX_WAKEUP_THRESH	(3 * TX_RING_SIZE / 4)
>  
>  #define MACB_RX_INT_FLAGS	(MACB_BIT(RCOMP) | MACB_BIT(RXUBR)	\
>  				 | MACB_BIT(ISR_ROVR))
> @@ -60,11 +61,6 @@ static unsigned int macb_tx_ring_wrap(unsigned int index)
>  	return index & (TX_RING_SIZE - 1);
>  }
>  
> -static unsigned int macb_tx_ring_avail(struct macb *bp)
> -{
> -	return (bp->tx_tail - bp->tx_head) & (TX_RING_SIZE - 1);
> -}
> -
>  static struct macb_dma_desc *macb_tx_desc(struct macb *bp, unsigned int index)
>  {
>  	return &bp->tx_ring[macb_tx_ring_wrap(index)];
> @@ -524,7 +520,8 @@ static void macb_tx_interrupt(struct macb *bp)
>  
>  	bp->tx_tail = tail;
>  	if (netif_queue_stopped(bp->dev)
> -			&& macb_tx_ring_avail(bp) > MACB_TX_WAKEUP_THRESH)
> +			&& CIRC_CNT(bp->tx_head, bp->tx_tail,
> +				    TX_RING_SIZE) <= MACB_TX_WAKEUP_THRESH)
>  		netif_wake_queue(bp->dev);
>  }
>  
> @@ -818,7 +815,7 @@ static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	spin_lock_irqsave(&bp->lock, flags);
>  
>  	/* This is a hard error, log it. */
> -	if (macb_tx_ring_avail(bp) < 1) {
> +	if (CIRC_SPACE(bp->tx_head, bp->tx_tail, TX_RING_SIZE) < 1) {
>  		netif_stop_queue(dev);
>  		spin_unlock_irqrestore(&bp->lock, flags);
>  		netdev_err(bp->dev, "BUG! Tx Ring full when queue awake!\n");
> @@ -855,7 +852,7 @@ static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  
>  	macb_writel(bp, NCR, macb_readl(bp, NCR) | MACB_BIT(TSTART));
>  
> -	if (macb_tx_ring_avail(bp) < 1)
> +	if (CIRC_SPACE(bp->tx_head, bp->tx_tail, TX_RING_SIZE) < 1)
>  		netif_stop_queue(dev);
>  
>  	spin_unlock_irqrestore(&bp->lock, flags);
> -- 
> 1.8.0
> 
