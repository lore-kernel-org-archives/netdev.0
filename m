From: "Vlad Zolotarov" <vladz@broadcom.com>
Subject: Re: [PATCH 1/7] bnx2x: remove unused fields in struct
 bnx2x_func_init_params
Date: Wed, 31 Aug 2011 13:07:51 +0300
Message-ID: <201108311307.52165.vladz@broadcom.com>
References: <1314714646-3642-1-git-send-email-mschmidt@redhat.com>
 <1314714646-3642-2-git-send-email-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Michal Schmidt" <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2589 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751365Ab1HaKIa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Aug 2011 06:08:30 -0400
In-Reply-To: <1314714646-3642-2-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 30 August 2011 17:30:40 Michal Schmidt wrote:
> func_flgs is not used for anything. The only flag that's ever checked
> (FUNC_FLG_SPQ) is always set. The other flags are never read.
> 
> fw_stat_map is not used at all.
> 
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |   15 ++-------------
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   18 +++---------------
>  2 files changed, 5 insertions(+), 28 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
> b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h index f127768..735e491
> 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
> @@ -1490,24 +1490,13 @@ extern int num_queues;
>  #define RSS_IPV6_TCP_CAP_MASK						
\
>  	TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV6_TCP_CAPABILITY
> 
> -/* func init flags */
> -#define FUNC_FLG_RSS		0x0001
> -#define FUNC_FLG_STATS		0x0002
> -/* removed  FUNC_FLG_UNMATCHED	0x0004 */
> -#define FUNC_FLG_TPA		0x0008
> -#define FUNC_FLG_SPQ		0x0010
> -#define FUNC_FLG_LEADING	0x0020	/* PF only */
> -
> -
>  struct bnx2x_func_init_params {
>  	/* dma */
> -	dma_addr_t	fw_stat_map;	/* valid iff FUNC_FLG_STATS */
> -	dma_addr_t	spq_map;	/* valid iff FUNC_FLG_SPQ */
> +	dma_addr_t	spq_map;
> 
> -	u16		func_flgs;
>  	u16		func_id;	/* abs fid */
>  	u16		pf_id;
> -	u16		spq_prod;	/* valid iff FUNC_FLG_SPQ */
> +	u16		spq_prod;
>  };
> 
>  #define for_each_eth_queue(bp, var) \
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c index 85dd294..e7b584b
> 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> @@ -2661,11 +2661,9 @@ void bnx2x_func_init(struct bnx2x *bp, struct
> bnx2x_func_init_params *p) storm_memset_func_en(bp, p->func_id, 1);
> 
>  	/* spq */
> -	if (p->func_flgs & FUNC_FLG_SPQ) {
> -		storm_memset_spq_addr(bp, p->spq_map, p->func_id);
> -		REG_WR(bp, XSEM_REG_FAST_MEMORY +
> -		       XSTORM_SPQ_PROD_OFFSET(p->func_id), p->spq_prod);
> -	}
> +	storm_memset_spq_addr(bp, p->spq_map, p->func_id);
> +	REG_WR(bp, XSEM_REG_FAST_MEMORY +
> +	       XSTORM_SPQ_PROD_OFFSET(p->func_id), p->spq_prod);
>  }
> 
>  /**
> @@ -2838,7 +2836,6 @@ static void bnx2x_pf_init(struct bnx2x *bp)
>  {
>  	struct bnx2x_func_init_params func_init = {0};
>  	struct event_ring_data eq_data = { {0} };
> -	u16 flags;
> 
>  	if (!CHIP_IS_E1x(bp)) {
>  		/* reset IGU PF statistics: MSIX + ATTN */
> @@ -2855,15 +2852,6 @@ static void bnx2x_pf_init(struct bnx2x *bp)
>  				BP_FUNC(bp) : BP_VN(bp))*4, 0);
>  	}
> 
> -	/* function setup flags */
> -	flags = (FUNC_FLG_STATS | FUNC_FLG_LEADING | FUNC_FLG_SPQ);
> -
> -	/* This flag is relevant for E1x only.
> -	 * E2 doesn't have a TPA configuration in a function level.
> -	 */
> -	flags |= (bp->flags & TPA_ENABLE_FLAG) ? FUNC_FLG_TPA : 0;
> -
> -	func_init.func_flgs = flags;
>  	func_init.pf_id = BP_FUNC(bp);
>  	func_init.func_id = BP_FUNC(bp);
>  	func_init.spq_map = bp->spq_mapping;

Acked-by: Vladislav Zolotarov <vladz@broadcom.com>
