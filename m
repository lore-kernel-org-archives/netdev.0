From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/1] net: macb: initialize checksum when using
 checksum offloading
Date: Thu, 01 Sep 2016 10:03:22 -0700 (PDT)
Message-ID: <20160901.100322.1508960040314798118.davem@davemloft.net>
References: <1471611898-3852-2-git-send-email-helmut.buchsbaum@gmail.com>
        <1472479045-8814-1-git-send-email-helmut.buchsbaum@gmail.com>
        <1472479045-8814-2-git-send-email-helmut.buchsbaum@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, nicolas.ferre@atmel.com,
        michal.simek@xilinx.com, netdev@vger.kernel.org,
        cyrille.pitchen@atmel.com
To: helmut.buchsbaum@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39458 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754231AbcIAVwb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 17:52:31 -0400
In-Reply-To: <1472479045-8814-2-git-send-email-helmut.buchsbaum@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
Date: Mon, 29 Aug 2016 15:57:25 +0200

> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index 89c0cfa..de2f791 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -1323,6 +1323,19 @@ dma_error:
>  	return 0;
>  }
>  
> +static inline void macb_clear_csum(struct sk_buff *skb)
> +{
> +	/* no change for packets without checksum offloading */
> +	if (skb->ip_summed != CHECKSUM_PARTIAL)
> +		return;
> +
> +	/* initialize checksum field
> +	 * This is required - at least for Zynq, which otherwise calculates
> +	 * wrong UDP header checksums for UDP packets with UDP data len <=2
> +	 */
> +	*(__sum16 *)(skb->head + skb->csum_start + skb->csum_offset) = 0;
> +}
> +

It is not valid to blindly modify the SKB contents, you must make sure that no
other references to this SKB's data exist.

You do this via skb_cow_head(skb, 0), which may fail.

See for example drivers/net/ethernet/broadcom/tg3.c's tg3_start_xmit()
