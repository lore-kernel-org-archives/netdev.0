From: John Crispin <john@phrozen.org>
Subject: Re: [PATCH net-next 2/3] net: ethernet: mediatek: get hw lro
 capability by the chip id instead of by the dtsi
Date: Mon, 3 Oct 2016 21:18:46 +0200
Message-ID: <cc222256-9f7e-3b61-0f6d-f1969bd6ca02@phrozen.org>
References: <1475479131-19822-1-git-send-email-nelson.chang@mediatek.com>
 <1475479131-19822-3-git-send-email-nelson.chang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nbd@openwrt.org,
        linux-mediatek@lists.infradead.org, nelsonch.tw@gmail.com
To: Nelson Chang <nelson.chang@mediatek.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:56548 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752545AbcJCTSx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 3 Oct 2016 15:18:53 -0400
In-Reply-To: <1475479131-19822-3-git-send-email-nelson.chang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Nelson,

comment inline

On 03/10/2016 09:18, Nelson Chang wrote:
> Because hw lro started to be supported from MT7623, the proper way to check if
> the feature is capable is to judge by the chip id instead of by the dtsi.
> 
> Signed-off-by: Nelson Chang <nelson.chang@mediatek.com>
> ---
>  drivers/net/ethernet/mediatek/mtk_eth_soc.c | 12 ++++++++++--
>  drivers/net/ethernet/mediatek/mtk_eth_soc.h |  1 +
>  2 files changed, 11 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> index a3e4ae6..3d16a0c 100644
> --- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> +++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> @@ -2344,6 +2344,14 @@ static u32 mtk_get_chip_id(struct mtk_eth *eth)
>  	return chip_id;
>  }
>  
> +static bool mtk_is_hwlro_supported(struct mtk_eth *eth)
> +{
> +	if (eth->chip_id == MT7623_ETH)
> +		return true;
> +	else
> +		return false;
> +}
> +
>  static int mtk_probe(struct platform_device *pdev)
>  {
>  	struct resource *res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> @@ -2383,8 +2391,6 @@ static int mtk_probe(struct platform_device *pdev)
>  		return PTR_ERR(eth->pctl);
>  	}
>  
> -	eth->hwlro = of_property_read_bool(pdev->dev.of_node, "mediatek,hwlro");
> -
>  	for (i = 0; i < 3; i++) {
>  		eth->irq[i] = platform_get_irq(pdev, i);
>  		if (eth->irq[i] < 0) {
> @@ -2415,6 +2421,8 @@ static int mtk_probe(struct platform_device *pdev)
>  		return -ENODEV;
>  	}
>  
> +	eth->hwlro = mtk_is_hwlro_supported(eth);
> +

do you plan to add more chips to the mtk_is_hwlro_supporte() function ?
if not a simple

	eth->hwlro = (eth->chip_id == MT7623_ETH);

might be enough

	John


>  	for_each_child_of_node(pdev->dev.of_node, mac_np) {
>  		if (!of_device_is_compatible(mac_np,
>  					     "mediatek,eth-mac"))
> diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.h b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
> index a5b422b..58738fd 100644
> --- a/drivers/net/ethernet/mediatek/mtk_eth_soc.h
> +++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
> @@ -345,6 +345,7 @@
>  /* ethernet subsystem chip id register */
>  #define ETHSYS_CHIPID0_3	0x0
>  #define ETHSYS_CHIPID4_7	0x4
> +#define MT7623_ETH		(7623)
>  
>  /* ethernet subsystem config register */
>  #define ETHSYS_SYSCFG0		0x14
> 
