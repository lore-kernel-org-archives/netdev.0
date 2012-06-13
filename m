From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH] bnx2x: fix checksum validation
Date: Wed, 13 Jun 2012 16:42:37 +0300
Message-ID: <1339594957.13000.7.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1339581004.22704.340.camel@edumazet-glaptop>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Tom Herbert" <therbert@google.com>,
	"Robert Evans" <evansr@google.com>,
	"Willem de Bruijn" <willemb@google.com>,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Merav Sicron" <meravs@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4691 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753612Ab2FMNmv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2012 09:42:51 -0400
In-Reply-To: <1339581004.22704.340.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-13 at 11:50 +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> bnx2x driver incorrectly sets ip_summed to CHECKSUM_UNNECESSARY on
> encapsulated segments. TCP stack happily accepts frames with bad
> checksums, if they are inside a GRE or IPIP encapsulation.

So what you are saying is that the indication that the checksum is valid
is interpreted as the encapsulated checksum and not just the IP
header... This was not the intention of this code, it was meant to
indicate that the IP header is valid.

> Our understanding is that if no IP or L4 csum validation was done by the
> hardware, we should leave ip_summed as is (CHECKSUM_NONE), since
> hardware doesn't provide CHECKSUM_COMPLETE support in its cqe.
> 
> Then, if IP/L4 checksumming was done by the hardware, set
> CHECKSUM_UNNECESSARY if no error was flagged.
> 
> Patch based on findings and analysis from Robert Evans

I must admit that the code looks much better with this change. The only
down side is that there is no longer IP checksum offload for pure IP
packets, but that's negligible. The only thing that bothers me is that
there is no way to indicate anything about the encapsulated packet
separately from the outer header. Is that the way we want to keep it?

> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Eilon Greenstein <eilong@broadcom.com>
> Cc: Yaniv Rosner <yanivr@broadcom.com>
> Cc: Merav Sicron <meravs@broadcom.com>
> Cc: Tom Herbert <therbert@google.com>
> Cc: Robert Evans <evansr@google.com>
> Cc: Willem de Bruijn <willemb@google.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x.h     |   15 -------
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |   27 ++++++++++----
>  2 files changed, 21 insertions(+), 21 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
> index e30e2a2..7de8241 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
> @@ -747,21 +747,6 @@ struct bnx2x_fastpath {
>  
>  #define ETH_RX_ERROR_FALGS		ETH_FAST_PATH_RX_CQE_PHY_DECODE_ERR_FLG
>  
> -#define BNX2X_IP_CSUM_ERR(cqe) \
> -			(!((cqe)->fast_path_cqe.status_flags & \
> -			   ETH_FAST_PATH_RX_CQE_IP_XSUM_NO_VALIDATION_FLG) && \
> -			 ((cqe)->fast_path_cqe.type_error_flags & \
> -			  ETH_FAST_PATH_RX_CQE_IP_BAD_XSUM_FLG))
> -
> -#define BNX2X_L4_CSUM_ERR(cqe) \
> -			(!((cqe)->fast_path_cqe.status_flags & \
> -			   ETH_FAST_PATH_RX_CQE_L4_XSUM_NO_VALIDATION_FLG) && \
> -			 ((cqe)->fast_path_cqe.type_error_flags & \
> -			  ETH_FAST_PATH_RX_CQE_L4_BAD_XSUM_FLG))
> -
> -#define BNX2X_RX_CSUM_OK(cqe) \
> -			(!(BNX2X_L4_CSUM_ERR(cqe) || BNX2X_IP_CSUM_ERR(cqe)))
> -
>  #define BNX2X_PRS_FLAG_OVERETH_IPV4(flags) \
>  				(((le16_to_cpu(flags) & \
>  				   PARSING_FLAGS_OVER_ETHERNET_PROTOCOL) >> \
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> index ad0743b..cbc56f2 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> @@ -617,6 +617,25 @@ static int bnx2x_alloc_rx_data(struct bnx2x *bp,
>  	return 0;
>  }
>  
> +static void bnx2x_csum_validate(struct sk_buff *skb, union eth_rx_cqe *cqe,
> +				struct bnx2x_fastpath *fp)
> +{
> +	/* Do nothing if no IP/L4 csum validation was done */
> +
> +	if (cqe->fast_path_cqe.status_flags &
> +	    (ETH_FAST_PATH_RX_CQE_IP_XSUM_NO_VALIDATION_FLG |
> +	     ETH_FAST_PATH_RX_CQE_L4_XSUM_NO_VALIDATION_FLG))
> +		return;
> +
> +	/* If both IP/L4 validation were done, check if an error was found. */
> +
> +	if (cqe->fast_path_cqe.type_error_flags &
> +	    (ETH_FAST_PATH_RX_CQE_IP_BAD_XSUM_FLG |
> +	     ETH_FAST_PATH_RX_CQE_L4_BAD_XSUM_FLG))
> +		fp->eth_q_stats.hw_csum_err++;
> +	else
> +		skb->ip_summed = CHECKSUM_UNNECESSARY;
> +}
>  
>  int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
>  {
> @@ -806,13 +825,9 @@ reuse_rx:
>  
>  		skb_checksum_none_assert(skb);
>  
> -		if (bp->dev->features & NETIF_F_RXCSUM) {
> +		if (bp->dev->features & NETIF_F_RXCSUM)
> +			bnx2x_csum_validate(skb, cqe, fp);
>  
> -			if (likely(BNX2X_RX_CSUM_OK(cqe)))
> -				skb->ip_summed = CHECKSUM_UNNECESSARY;
> -			else
> -				fp->eth_q_stats.hw_csum_err++;
> -		}
>  
>  		skb_record_rx_queue(skb, fp->rx_queue);
>  
> 
> 
> 
