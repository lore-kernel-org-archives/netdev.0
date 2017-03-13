From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 3/4] net-next: ethernet: mediatek: add CDM able
 to recognize the tag for DSA
Date: Mon, 13 Mar 2017 09:39:22 -0700
Message-ID: <6f85f6ee-6ded-9bda-a4aa-4bbf9c892848@gmail.com>
References: <1489421488-300-1-git-send-email-sean.wang@mediatek.com>
 <1489421488-300-4-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mediatek@lists.infradead.org,
        davem@davemloft.net, Landen.Chao@mediatek.com, keyhaede@gmail.com,
        objelf@gmail.com
To: sean.wang@mediatek.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, matthias.bgg@gmail.com,
        robh+dt@kernel.org, mark.rutland@arm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35809 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932114AbdCMQjd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 12:39:33 -0400
In-Reply-To: <1489421488-300-4-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/13/2017 09:11 AM, sean.wang@mediatek.com wrote:
> From: Sean Wang <sean.wang@mediatek.com>
> 
> Allowing CDM can recognize these packets with carrying port-distinguishing
> tag when CONFIG_NET_DSA_TAG_MTK is enabled. Otherwise, these packets will
> be dropped by CDM ingress.
> 
> Signed-off-by: Sean Wang <sean.wang@mediatek.com>
> Signed-off-by: Landen Chao <Landen.Chao@mediatek.com>
> ---
>  drivers/net/ethernet/mediatek/mtk_eth_soc.c | 8 ++++++++
>  drivers/net/ethernet/mediatek/mtk_eth_soc.h | 5 +++++
>  2 files changed, 13 insertions(+)
> 
> diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> index 3dd8788..19944e0 100644
> --- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> +++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> @@ -1848,6 +1848,14 @@ static int mtk_hw_init(struct mtk_eth *eth)
>  	/* GE2, Force 1000M/FD, FC ON */
>  	mtk_w32(eth, MAC_MCR_FIXED_LINK, MTK_MAC_MCR(1));
>  
> +#if defined(CONFIG_NET_DSA_TAG_MTK)
> +	/* Tell CDMQ to parse the MTK special tag from CPU  */
> +	/* QDMA Tx Use CDMQ */
> +	u32 val2 = mtk_r32(eth, MTK_CDMQ_IG_CTRL);
> +
> +	mtk_w32(eth, val2 | MTK_CDMQ_STAG_EN, MTK_CDMQ_IG_CTRL);
> +#endif
> +

Depending on how early you call this function, can you use
netdev_uses_dsa() instead of this? You may want to consider using #if
IS_ENABLED() to cover the modular case as well.

>  	/* Enable RX VLan Offloading */
>  	mtk_w32(eth, 1, MTK_CDMP_EG_CTRL);
>  
> diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.h b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
> index 99b1c8e..79606db 100644
> --- a/drivers/net/ethernet/mediatek/mtk_eth_soc.h
> +++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
> @@ -70,11 +70,16 @@
>  /* Frame Engine Interrupt Grouping Register */
>  #define MTK_FE_INT_GRP		0x20
>  
> +/* CDMP Ingress Control Register */
> +#define MTK_CDMQ_IG_CTRL	0x1400
> +#define MTK_CDMQ_STAG_EN	BIT(0)
> +
>  /* CDMP Exgress Control Register */
>  #define MTK_CDMP_EG_CTRL	0x404
>  
>  /* GDM Exgress Control Register */
>  #define MTK_GDMA_FWD_CFG(x)	(0x500 + (x * 0x1000))
> +#define MTK_GDMA_STAG_EN	BIT(24)
>  #define MTK_GDMA_ICS_EN		BIT(22)
>  #define MTK_GDMA_TCS_EN		BIT(21)
>  #define MTK_GDMA_UCS_EN		BIT(20)
> 


-- 
Florian
