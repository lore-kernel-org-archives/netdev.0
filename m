From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bnx2x: fix rx checksum validation for IPv6
Date: Fri, 14 Sep 2012 01:14:39 +0200
Message-ID: <1347578079.8555.141.camel@edumazet-glaptop>
References: <1347577184-8417-1-git-send-email-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eilon Greenstein <eilong@broadcom.com>,
	Eric Dumazet <edumazet@google.com>,
	Yaniv Rosner <yanivr@broadcom.com>,
	Yuval Mintz <yuvalmin@broadcom.com>,
	Merav Sicron <meravs@broadcom.com>,
	Robert Evans <evansr@google.com>,
	Tom Herbert <therbert@google.com>,
	Willem de Bruijn <willemb@google.com>,
	David Miller <davem@davemloft.net>,
	Havard Skinnemoen <hskinnemoen@google.com>
To: Michal Schmidt <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:52837 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750958Ab2IMXOp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 19:14:45 -0400
Received: by weyx8 with SMTP id x8so2018775wey.19
        for <netdev@vger.kernel.org>; Thu, 13 Sep 2012 16:14:44 -0700 (PDT)
In-Reply-To: <1347577184-8417-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-09-14 at 00:59 +0200, Michal Schmidt wrote:
> Commit d6cb3e41 "bnx2x: fix checksum validation" caused a performance
> regression for IPv6. Rx checksum offload does not work. IPv6 packets
> are passed to the stack with CHECKSUM_NONE.
> 
> The hardware obviously cannot perform IP checksum validation for IPv6,
> because there is no checksum in the IPv6 header. This should not prevent
> us from setting CHECKSUM_UNNECESSARY.
> 
> Tested on BCM57711.
> 
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 12 +++++++-----
>  1 file changed, 7 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> index af20c6e..e8e97a7 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> @@ -662,14 +662,16 @@ void bnx2x_csum_validate(struct sk_buff *skb, union eth_rx_cqe *cqe,
>  				 struct bnx2x_fastpath *fp,
>  				 struct bnx2x_eth_q_stats *qstats)
>  {
> -	/* Do nothing if no IP/L4 csum validation was done */
> -
> +	/* Do nothing if no L4 csum validation was done.
> +	 * We do not check whether IP csum was validated. For IPv4 we assume
> +	 * that if the card got as far as validating the L4 csum, it also
> +	 * validated the IP csum. IPv6 has no IP csum.
> +	 */
>  	if (cqe->fast_path_cqe.status_flags &
> -	    (ETH_FAST_PATH_RX_CQE_IP_XSUM_NO_VALIDATION_FLG |
> -	     ETH_FAST_PATH_RX_CQE_L4_XSUM_NO_VALIDATION_FLG))
> +	    ETH_FAST_PATH_RX_CQE_L4_XSUM_NO_VALIDATION_FLG)
>  		return;
>  
> -	/* If both IP/L4 validation were done, check if an error was found. */
> +	/* If L4 validation was done, check if an error was found. */
>  
>  	if (cqe->fast_path_cqe.type_error_flags &
>  	    (ETH_FAST_PATH_RX_CQE_IP_BAD_XSUM_FLG |

Thanks for fixing this bug !

Acked-by: Eric Dumazet <edumazet@google.com>
