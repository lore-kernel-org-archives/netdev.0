From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH net v2 1/3] net: mvpp2: fix parsing fragmentation
 detection
Date: Mon, 25 Sep 2017 15:10:45 +0200
Message-ID: <20170925131045.GG19364@kwain>
References: <20170925125948.13507-1-antoine.tenart@free-electrons.com>
 <20170925125948.13507-2-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Stefan Chulski <stefanc@marvell.com>, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com,
        miquel.raynal@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, netdev@vger.kernel.org,
        Antoine Tenart <antoine.tenart@free-electrons.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170925125948.13507-2-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 25, 2017 at 02:59:46PM +0200, Antoine Tenart wrote:
> From: Stefan Chulski <stefanc@marvell.com>
> 
> Parsing fragmentation detection failed due to wrong configured
> parser TCAM entry's. Some traffic was marked as fragmented in RX
> descriptor, even it wasn't IP fragmented. The hardware also failed to
> calculate checksums which lead to use software checksum and caused
> performance degradation.
> 
> Fixes: 3f518509dedc ("ethernet: Add new driver for Marvell Armada 375 network unit")

With,

Signed-off-by: Stefan Chulski <stefanc@marvell.com>

I don't know why this SoB was removed but it should be added back.

Antoine

> Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
> ---
>  drivers/net/ethernet/marvell/mvpp2.c | 20 ++++++++++++++------
>  1 file changed, 14 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
> index dd0ee2691c86..da04939a2748 100644
> --- a/drivers/net/ethernet/marvell/mvpp2.c
> +++ b/drivers/net/ethernet/marvell/mvpp2.c
> @@ -676,6 +676,7 @@ enum mvpp2_tag_type {
>  #define MVPP2_PRS_RI_L3_MCAST			BIT(15)
>  #define MVPP2_PRS_RI_L3_BCAST			(BIT(15) | BIT(16))
>  #define MVPP2_PRS_RI_IP_FRAG_MASK		0x20000
> +#define MVPP2_PRS_RI_IP_FRAG_TRUE		BIT(17)
>  #define MVPP2_PRS_RI_UDF3_MASK			0x300000
>  #define MVPP2_PRS_RI_UDF3_RX_SPECIAL		BIT(21)
>  #define MVPP2_PRS_RI_L4_PROTO_MASK		0x1c00000
> @@ -2315,7 +2316,7 @@ static int mvpp2_prs_ip4_proto(struct mvpp2 *priv, unsigned short proto,
>  	    (proto != IPPROTO_IGMP))
>  		return -EINVAL;
>  
> -	/* Fragmented packet */
> +	/* Not fragmented packet */
>  	tid = mvpp2_prs_tcam_first_free(priv, MVPP2_PE_FIRST_FREE_TID,
>  					MVPP2_PE_LAST_FREE_TID);
>  	if (tid < 0)
> @@ -2334,8 +2335,12 @@ static int mvpp2_prs_ip4_proto(struct mvpp2 *priv, unsigned short proto,
>  				  MVPP2_PRS_SRAM_OP_SEL_UDF_ADD);
>  	mvpp2_prs_sram_ai_update(&pe, MVPP2_PRS_IPV4_DIP_AI_BIT,
>  				 MVPP2_PRS_IPV4_DIP_AI_BIT);
> -	mvpp2_prs_sram_ri_update(&pe, ri | MVPP2_PRS_RI_IP_FRAG_MASK,
> -				 ri_mask | MVPP2_PRS_RI_IP_FRAG_MASK);
> +	mvpp2_prs_sram_ri_update(&pe, ri, ri_mask | MVPP2_PRS_RI_IP_FRAG_MASK);
> +
> +	mvpp2_prs_tcam_data_byte_set(&pe, 2, 0x00,
> +				     MVPP2_PRS_TCAM_PROTO_MASK_L);
> +	mvpp2_prs_tcam_data_byte_set(&pe, 3, 0x00,
> +				     MVPP2_PRS_TCAM_PROTO_MASK);
>  
>  	mvpp2_prs_tcam_data_byte_set(&pe, 5, proto, MVPP2_PRS_TCAM_PROTO_MASK);
>  	mvpp2_prs_tcam_ai_update(&pe, 0, MVPP2_PRS_IPV4_DIP_AI_BIT);
> @@ -2346,7 +2351,7 @@ static int mvpp2_prs_ip4_proto(struct mvpp2 *priv, unsigned short proto,
>  	mvpp2_prs_shadow_set(priv, pe.index, MVPP2_PRS_LU_IP4);
>  	mvpp2_prs_hw_write(priv, &pe);
>  
> -	/* Not fragmented packet */
> +	/* Fragmented packet */
>  	tid = mvpp2_prs_tcam_first_free(priv, MVPP2_PE_FIRST_FREE_TID,
>  					MVPP2_PE_LAST_FREE_TID);
>  	if (tid < 0)
> @@ -2358,8 +2363,11 @@ static int mvpp2_prs_ip4_proto(struct mvpp2 *priv, unsigned short proto,
>  	pe.sram.word[MVPP2_PRS_SRAM_RI_CTRL_WORD] = 0x0;
>  	mvpp2_prs_sram_ri_update(&pe, ri, ri_mask);
>  
> -	mvpp2_prs_tcam_data_byte_set(&pe, 2, 0x00, MVPP2_PRS_TCAM_PROTO_MASK_L);
> -	mvpp2_prs_tcam_data_byte_set(&pe, 3, 0x00, MVPP2_PRS_TCAM_PROTO_MASK);
> +	mvpp2_prs_sram_ri_update(&pe, ri | MVPP2_PRS_RI_IP_FRAG_TRUE,
> +				 ri_mask | MVPP2_PRS_RI_IP_FRAG_MASK);
> +
> +	mvpp2_prs_tcam_data_byte_set(&pe, 2, 0x00, 0x0);
> +	mvpp2_prs_tcam_data_byte_set(&pe, 3, 0x00, 0x0);
>  
>  	/* Update shadow table and hw entry */
>  	mvpp2_prs_shadow_set(priv, pe.index, MVPP2_PRS_LU_IP4);
> -- 
> 2.13.5
> 

-- 
Antoine Ténart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
