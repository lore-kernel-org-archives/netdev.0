From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH v2] b44: fix misalignment and wasted space in rx handling
Date: Fri, 9 Jan 2009 23:25:50 +0100
Message-ID: <200901092325.50955.mb@bu3sch.de>
References: <4967459D.3070207@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, zambrano@broadcom.com
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bu3sch.de ([62.75.166.246]:39949 "EHLO vs166246.vserver.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758984AbZAIW12 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 17:27:28 -0500
In-Reply-To: <4967459D.3070207@openwrt.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 09 January 2009 13:39:57 Felix Fietkau wrote:
> --- a/drivers/net/b44.c
> +++ b/drivers/net/b44.c
> @@ -73,8 +73,8 @@
>  	  (BP)->tx_cons - (BP)->tx_prod - TX_RING_GAP(BP))
>  #define NEXT_TX(N)		(((N) + 1) & (B44_TX_RING_SIZE - 1))
>  
> -#define RX_PKT_OFFSET		30
> -#define RX_PKT_BUF_SZ		(1536 + RX_PKT_OFFSET + 64)
> +#define RX_PKT_OFFSET		(RX_HEADER_LEN + 2)
> +#define RX_PKT_BUF_SZ		(1536 + RX_PKT_OFFSET)
>  
>  /* minimum number of free TX descriptors required to wake up TX process */
>  #define B44_TX_WAKEUP_THRESH		(B44_TX_RING_SIZE / 4)
> @@ -682,7 +682,6 @@ static int b44_alloc_rx_skb(struct b44 *
>  	}
>  
>  	rh = (struct rx_header *) skb->data;
> -	skb_reserve(skb, RX_PKT_OFFSET);

Looks correct.

>  	rh->len = 0;
>  	rh->flags = 0;
> @@ -693,13 +692,13 @@ static int b44_alloc_rx_skb(struct b44 *
>  	if (src_map != NULL)
>  		src_map->skb = NULL;
>  
> -	ctrl  = (DESC_CTRL_LEN & (RX_PKT_BUF_SZ - RX_PKT_OFFSET));
> +	ctrl = (DESC_CTRL_LEN & RX_PKT_BUF_SZ);

Are you sure this is right? b43 has the same DMA engine, and we
subtract the offset from the buffer size there. So we end up with
the descriptor control field telling the space available for the frame payload.

So I think the correct code would be
	ctrl = (DESC_CTRL_LEN & (RX_PKT_BUF_SZ - RX_PKT_OFFSET));

>  	if (dest_idx == (B44_RX_RING_SIZE - 1))
>  		ctrl |= DESC_CTRL_EOT;
>  
>  	dp = &bp->rx_ring[dest_idx];
>  	dp->ctrl = cpu_to_le32(ctrl);
> -	dp->addr = cpu_to_le32((u32) mapping + RX_PKT_OFFSET + bp->dma_offset);
> +	dp->addr = cpu_to_le32((u32) mapping + bp->dma_offset);

This looks correct.

-- 
Greetings, Michael.
