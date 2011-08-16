From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 06/14] bna: TX Path and RX Path Changes
Date: Tue, 16 Aug 2011 22:45:55 +0100
Message-ID: <1313531155.2725.61.camel@bwh-desktop>
References: <1313529591-3718-1-git-send-email-rmody@brocade.com>
	 <1313529591-3718-7-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	adapter_linux_open_src_team@brocade.com,
	Gurunatha Karaje <gkaraje@brocade.com>
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:2923 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751816Ab1HPVqB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2011 17:46:01 -0400
In-Reply-To: <1313529591-3718-7-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-08-16 at 14:19 -0700, Rasesh Mody wrote:
> Change details:
>  - Disable and enable interrupts from the same polling context to prevent
>    reordering in Rx path.
>  - Add Rx NAPI debug counters.
>  - Make NAPI budget check more generic
>  - Add a macro bnad_dim_timer_stop for DIM(Dynamic Interrupt Moderation)
>    timer stop
>  - Handle reduced MSI-X vectors case in bnad_enable_msix
>  - Replace existing checks with macros and add more checks for illegal skbs
>    in transmit path. Add more tx_skb counters for dropped skbs.
>  - Check for single frame TSO skbs and send them out as non-TSO.
>  - Put memory barrier after bna_txq_prod_indx_doorbell()
> 
> Signed-off-by: Gurunatha Karaje <gkaraje@brocade.com>
> Signed-off-by: Rasesh Mody <rmody@brocade.com>
> ---
>  drivers/net/ethernet/brocade/bna/bnad.c |  207 +++++++++++++++++--------------
>  drivers/net/ethernet/brocade/bna/bnad.h |   33 +++++-
>  2 files changed, 148 insertions(+), 92 deletions(-)
> 
> diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
> index 64e2106..0faa8a1 100644
> --- a/drivers/net/ethernet/brocade/bna/bnad.c
> +++ b/drivers/net/ethernet/brocade/bna/bnad.c
> @@ -532,7 +532,7 @@ bnad_poll_cq(struct bnad *bnad, struct bna_ccb *ccb, int budget)
>  		      (flags & BNA_CQ_EF_L4_CKSUM_OK)))
>  			skb->ip_summed = CHECKSUM_UNNECESSARY;
>  		else
> -			skb_checksum_none_assert(skb);
> +			skb->ip_summed = CHECKSUM_NONE;
>  
>  		rcb->rxq->rx_packets++;
>  		rcb->rxq->rx_bytes += skb->len;
[...]

This is reverting part of:

commit bc8acf2c8c3e43fcc192762a9f964b3e9a17748b
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Thu Sep 2 13:07:41 2010 -0700

    drivers/net: avoid some skb->ip_summed initializations

and I don't see any justification for that.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

