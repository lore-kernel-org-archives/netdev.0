From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 3/4] net: qcom/emac: enforce DMA address restrictions
Date: Thu, 12 Oct 2017 09:30:52 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD00923AE@AcuExch.aculab.com>
References: <1507751546-10265-1-git-send-email-timur@codeaurora.org>
 <1507751546-10265-4-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'Timur Tabi' <timur@codeaurora.org>,
        "David S. Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.194]:51993 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751455AbdJLJax (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 05:30:53 -0400
In-Reply-To: <1507751546-10265-4-git-send-email-timur@codeaurora.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi
> Sent: 11 October 2017 20:52
> The EMAC has a restriction that the upper 32 bits of the base addresses
> for the RFD and RRD rings must be the same.  The ensure that restriction,
> we allocate twice the space for the RRD and locate it at an appropriate
> address.
> 
> We also re-arrange the allocations so that invalid addresses are even
> less likely.
> 
> Signed-off-by: Timur Tabi <timur@codeaurora.org>
> ---
>  drivers/net/ethernet/qualcomm/emac/emac-mac.c | 39 ++++++++++++++++-----------
>  1 file changed, 24 insertions(+), 15 deletions(-)
> 
> diff --git a/drivers/net/ethernet/qualcomm/emac/emac-mac.c b/drivers/net/ethernet/qualcomm/emac/emac-
> mac.c
> index 9cbb27263742..0f5ece5d9507 100644
> --- a/drivers/net/ethernet/qualcomm/emac/emac-mac.c
> +++ b/drivers/net/ethernet/qualcomm/emac/emac-mac.c
> @@ -734,6 +734,11 @@ static int emac_rx_descs_alloc(struct emac_adapter *adpt)
>  	rx_q->rrd.size = rx_q->rrd.count * (adpt->rrd_size * 4);
>  	rx_q->rfd.size = rx_q->rfd.count * (adpt->rfd_size * 4);
> 
> +	/* Check if the RRD and RFD are aligned properly, and if not, adjust. */
> +	if (upper_32_bits(ring_header->dma_addr) !=
> +	    upper_32_bits(ring_header->dma_addr + ALIGN(rx_q->rrd.size, 8)))
> +		ring_header->used = ALIGN(rx_q->rrd.size, 8);
> +

Isn't the memory allocated by a single kzalloc() call?
IIRC that guarantees it doesn't cross a power or 2 boundary less than
the size.
So if you allocate any size between 4k and 8k it won't cross an odd
4k boundary (etc).

So these checks are entirely pointless.

	David
