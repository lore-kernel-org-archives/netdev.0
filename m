From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] bgmac: ratelimit warning messages
Date: Fri, 06 Mar 2015 11:50:58 -0800
Message-ID: <1425671458.12017.41.camel@perches.com>
References: <1425665874-14870-1-git-send-email-peter.senna@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, hauke@hauke-m.de,
	w-lkml@lebenslange-mailadresse.de, zajec5@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Peter Senna Tschudin <peter.senna@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0127.hostedemail.com ([216.40.44.127]:60219 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756401AbbCFTvC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 14:51:02 -0500
In-Reply-To: <1425665874-14870-1-git-send-email-peter.senna@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-03-06 at 19:17 +0100, Peter Senna Tschudin wrote:
> On my test environment the troughput of a file transfer drops from
> 4.4Mbps to 116Kbps due the number of repeated warning messages.
> Adding printk_ratelimit() solves the issue without removing the
> warning message.

What value is there for this message being emitted more than once?

> diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c

> @@ -302,7 +302,7 @@ static int bgmac_dma_rx_skb_for_slot(struct bgmac *bgmac,
>  	slot->skb = skb;
>  	slot->dma_addr = dma_addr;
>  
> -	if (slot->dma_addr & 0xC0000000)
> +	if ((slot->dma_addr & 0xC0000000) && printk_ratelimit())
>  		bgmac_warn(bgmac, "DMA address using 0xC0000000 bit(s), it may need translation trick\n");

Maybe better as a static function

static void check_translate_address(struct bgmac *bgmac, dma_addr_t addr)
{
	static bool printed;

	if (!printed && (addr & (dma_addr_t)0xC0000000)))
		printed = true;
		bgmac_warn(bgmac, etc...);
	}
}

[...]

	check_translate_address(bgmac, slot->dma_addr);

>  	return 0;
> @@ -505,7 +505,7 @@ static int bgmac_dma_alloc(struct bgmac *bgmac)
>  				  ring->mmio_base);
>  			goto err_dma_free;
>  		}
> -		if (ring->dma_base & 0xC0000000)
> +		if ((ring->dma_base & 0xC0000000) && printk_ratelimit())
>  			bgmac_warn(bgmac, "DMA address using 0xC0000000 bit(s), it may need translation trick\n");
>  
>  		ring->unaligned = bgmac_dma_unaligned(bgmac, ring,
> @@ -536,7 +536,7 @@ static int bgmac_dma_alloc(struct bgmac *bgmac)
>  			err = -ENOMEM;
>  			goto err_dma_free;
>  		}
> -		if (ring->dma_base & 0xC0000000)
> +		if ((ring->dma_base & 0xC0000000) && printk_ratelimit())
>  			bgmac_warn(bgmac, "DMA address using 0xC0000000 bit(s), it may need translation trick\n");
>  
>  		ring->unaligned = bgmac_dma_unaligned(bgmac, ring,
