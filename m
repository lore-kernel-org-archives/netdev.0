From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2] net: mv643xx_eth: Fix highmem support in non-TSO
 egress path
Date: Thu, 22 Jan 2015 12:40:25 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAD0E4F@AcuExch.aculab.com>
References: <1421928859-17923-1-git-send-email-ezequiel.garcia@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"B38611@freescale.com" <B38611@freescale.com>,
	"fabio.estevam@freescale.com" <fabio.estevam@freescale.com>
To: 'Ezequiel Garcia' <ezequiel.garcia@free-electrons.com>,
	David Miller <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.181]:51387 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751128AbbAVMlY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 07:41:24 -0500
In-Reply-To: <1421928859-17923-1-git-send-email-ezequiel.garcia@free-electrons.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ezequiel Garcia
> Commit 69ad0dd7af22b61d9e0e68e56b6290121618b0fb
> Author: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
> Date:   Mon May 19 13:59:59 2014 -0300
> 
>     net: mv643xx_eth: Use dma_map_single() to map the skb fragments
> 
> caused a nasty regression by removing the support for highmem skb
> fragments. By using page_address() to get the address of a fragment's
> page, we are assuming a lowmem page. However, such assumption is incorrect,
> as fragments can be in highmem pages, resulting in very nasty issues.
> 
> This commit fixes this by using the skb_frag_dma_map() helper,
> which takes care of mapping the skb fragment properly. Additionally,
> the type of mapping is now tracked, so it can be unmapped using
> dma_unmap_page or dma_unmap_single when appropriate.
> 
> Fixes: 69ad0dd7af22 ("net: mv643xx_eth: Use dma_map_single() to map the skb fragments")
> Reported-by: Russell King <rmk+kernel@arm.linux.org.uk>
> Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
...
> @@ -2048,6 +2068,11 @@ static int txq_init(struct mv643xx_eth_private *mp, int index)
>  					nexti * sizeof(struct tx_desc);
>  	}
> 
> +	txq->tx_desc_mapping = kcalloc(txq->tx_ring_size, sizeof(char),
> +				       GFP_KERNEL);
> +	if (!txq->tx_desc_mapping)
> +		return -ENOMEM;
> +
>  	/* Allocate DMA buffers for TSO MAC/IP/TCP headers */
>  	txq->tso_hdrs = dma_alloc_coherent(mp->dev->dev.parent,
>  					   txq->tx_ring_size * TSO_HEADER_SIZE,

I'm guessing there is an error path for dma_alloc_coherent() failing.
You've not modified it to free tx_desc_mapping.

	David
