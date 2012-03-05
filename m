From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH, RFC] skge: Fix race in tx path
Date: Sun, 4 Mar 2012 21:25:07 -0800
Message-ID: <20120304212507.6d910d99@nehalam.linuxnetplumber.net>
References: <4142816.cJc9u7kBPI@asus>
	<20120226202710.GA23874@electric-eye.fr.zoreil.com>
	<3669580.gQc5FCr96Z@asus>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@osdl.org>,
	Jeff Garzik <jeff@garzik.org>
To: Bart Van Assche <bvanassche@acm.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58819 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751267Ab2CEFZM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2012 00:25:12 -0500
In-Reply-To: <3669580.gQc5FCr96Z@asus>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 27 Feb 2012 19:18:58 +0000
Bart Van Assche <bvanassche@acm.org> wrote:

> > With this change it seems possible for skge_tx_done to unmap a buffer
> > before it is sent when the requests for skge_xmit_frame are close enough.
> 
> Thanks for the feedback. Does the patch below look better ? 
> 
> ---
>  drivers/net/ethernet/marvell/skge.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/marvell/skge.c b/drivers/net/ethernet/marvell/skge.c
> index 33947ac..55723b5 100644
> --- a/drivers/net/ethernet/marvell/skge.c
> +++ b/drivers/net/ethernet/marvell/skge.c
> @@ -2800,15 +2800,15 @@ static netdev_tx_t skge_xmit_frame(struct sk_buff *skb,
>  
>  	netdev_sent_queue(dev, skb->len);
>  
> +	skge->tx_ring.to_use = e->next;
> +	smp_wmb();
> +
>  	skge_write8(hw, Q_ADDR(txqaddr[skge->port], Q_CSR), CSR_START);
>  
>  	netif_printk(skge, tx_queued, KERN_DEBUG, skge->netdev,
>  		     "tx queued, slot %td, len %d\n",
>  		     e - skge->tx_ring.start, skb->len);
>  
> -	skge->tx_ring.to_use = e->next;
> -	smp_wmb();
> -
>  	if (skge_avail(&skge->tx_ring) <= TX_LOW_WATER) {
>  		netdev_dbg(dev, "transmit queue full\n");
>  		netif_stop_queue(dev);

I don't see how the problem you are seeing.
If the race happens with old code:
  
     ring element is setup and started.
        IRQ happens
                     ........ skge_tx_done()
                                starts cleaning
                                stops prematurely 
     ring_to_use is updated
     one skb stays stuck in ring until next TX clean

So the race would just leave one skb behind (until next transmit).
Looking at tg3, you will see similar code.
More likely mmiowb() is needd at end of tx.
