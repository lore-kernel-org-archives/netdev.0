From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] gianfar: handle map error in gfar_new_rxbdp()
Date: Tue, 09 Dec 2014 15:37:53 -0500 (EST)
Message-ID: <20141209.153753.198847867496667798.davem@davemloft.net>
References: <1417775874-17775-1-git-send-email-asolokha@kb.kras.ru>
	<1417775874-17775-2-git-send-email-asolokha@kb.kras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: claudiu.manoil@freescale.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: asolokha@kb.kras.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417775874-17775-2-git-send-email-asolokha@kb.kras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arseny Solokha <asolokha@kb.kras.ru>
Date: Fri,  5 Dec 2014 17:37:53 +0700

> @@ -2854,7 +2866,15 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
>  		rx_queue->rx_skbuff[rx_queue->skb_currx] = newskb;
>  
>  		/* Setup the new bdp */
> -		gfar_new_rxbdp(rx_queue, bdp, newskb);
> +		rxbdpret = gfar_new_rxbdp(rx_queue, bdp, newskb);
> +		if (unlikely(rxbdpret)) {
> +			/* We drop the frame if we failed to map a new DMA
> +			 * buffer
> +			 */
> +			count_errors(bdp->status, dev);
> +			dev_kfree_skb(newskb);
> +			continue;
> +		}
>  
>  		/* Update to the next pointer */
>  		bdp = next_bd(bdp, base, rx_queue->rx_ring_size);

You need to add much more sophisticated handling of this error.

Otherwise the chip will just stop when it gets to the first
descriptor for which a DMA mapping failed in this way.

What you need to do is allocate and attempt to map the new SKB
_first_, and only if that succeeds will you pass the original
SKB up into the networking stack.

If the DMA mapping fails, you leave the OLD skb in the RX ring
and advance the ring pointer, as if the received packet never
happened.  You are essentially dropping it.
