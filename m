From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2.6.19] AT91RM9200 Ethernet update 3
Date: Mon, 4 Dec 2006 10:08:31 -0800
Message-ID: <20061204100831.0af6790f@freekitty>
References: <1165236624.4606.111.camel@fuzzie.sanpeople.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:47021 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936673AbWLDSIn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 13:08:43 -0500
To: Andrew Victor <andrew@sanpeople.com>
In-Reply-To: <1165236624.4606.111.camel@fuzzie.sanpeople.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04 Dec 2006 14:50:24 +0200
Andrew Victor <andrew@sanpeople.com> wrote:

> A minor fix to the Atmel AT91RM9200 Ethernet driver.
> 
> 1. Use dev_alloc_skb() instead of alloc_skb().
> 2. It is not necessary to adjust skb->len manually.
> 
> 
> Signed-off-by: Andrew Victor <andrew@sanpeople.com>
> 
> 
> diff -urN linux-2.6.19-final.orig/drivers/net/arm/at91_ether.c linux-2.6.19-final/drivers/net/arm/at91_ether.c
> --- linux-2.6.19-final.orig/drivers/net/arm/at91_ether.c	Mon Dec  4 14:42:05 2006
> +++ linux-2.6.19-final/drivers/net/arm/at91_ether.c	Mon Dec  4 14:43:57 2006
> @@ -855,14 +855,13 @@
>  	while (dlist->descriptors[lp->rxBuffIndex].addr & EMAC_DESC_DONE) {
>  		p_recv = dlist->recv_buf[lp->rxBuffIndex];
>  		pktlen = dlist->descriptors[lp->rxBuffIndex].size & 0x7ff;	/* Length of frame including FCS */
> -		skb = alloc_skb(pktlen + 2, GFP_ATOMIC);
> +		skb = dev_alloc_skb(pktlen + 2);
>  		if (skb != NULL) {
>  			skb_reserve(skb, 2);
>  			memcpy(skb_put(skb, pktlen), p_recv, pktlen);
>  
>  			skb->dev = dev;
>  			skb->protocol = eth_type_trans(skb, dev);
> -			skb->len = pktlen;
>  			dev->last_rx = jiffies;
>  			lp->stats.rx_bytes += pktlen;
>  			netif_rx(skb);
>

Use netdev_alloc_skb instead. It sets skb->dev so you don't have to.
Setting skb->len is redundant since that is what skb_put() does.

It would be best if you didn't have to copy data at all and could
receive directly into the skb.

If you have to copy received data, it is better to implement NAPI since that
allows you to copy data in soft irq. The existing code will cause poor realtime
performance since the driver is copying received data with IRQ's disabled.

-- 
Stephen Hemminger <shemminger@osdl.org>
