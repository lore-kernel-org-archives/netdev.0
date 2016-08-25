From: John Crispin <john@phrozen.org>
Subject: Re: [RESEND PATCH net 02/10] net: ethernet: mediatek: fix incorrect
 return value of devm_clk_get with EPROBE_DEFER
Date: Thu, 25 Aug 2016 15:49:10 +0200
Message-ID: <e1e9ca7a-c33b-3a9e-fd47-48f80bb10a32@phrozen.org>
References: <1472121901-15629-1-git-send-email-sean.wang@mediatek.com>
 <1472121901-15629-3-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nbd@openwrt.org,
        linux-mediatek@lists.infradead.org, keyhaede@gmail.com
To: Sean Wang <sean.wang@mediatek.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:55454 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934169AbcHYNtQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 Aug 2016 09:49:16 -0400
In-Reply-To: <1472121901-15629-3-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 25/08/2016 12:44, Sean Wang wrote:
> If the return value of devm_clk_get is EPROBE_DEFER, we should
> defer probing the driver. The change is verified and works based
> on 4.8-rc1 staying with the latest clk-next code for MT7623.
> 
> Signed-off-by: Sean Wang <sean.wang@mediatek.com>
> ---
>  drivers/net/ethernet/mediatek/mtk_eth_soc.c | 11 +++++++++--
>  1 file changed, 9 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> index 6e4a6ca..02b048f 100644
> --- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> +++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> @@ -1851,8 +1851,15 @@ static int mtk_probe(struct platform_device *pdev)
>  	eth->clk_gp1 = devm_clk_get(&pdev->dev, "gp1");
>  	eth->clk_gp2 = devm_clk_get(&pdev->dev, "gp2");
>  	if (IS_ERR(eth->clk_esw) || IS_ERR(eth->clk_gp1) ||
> -	    IS_ERR(eth->clk_gp2) || IS_ERR(eth->clk_ethif))
> -		return -ENODEV;
> +	    IS_ERR(eth->clk_gp2) || IS_ERR(eth->clk_ethif)) {
> +		if (PTR_ERR(eth->clk_esw) == -EPROBE_DEFER ||
> +		    PTR_ERR(eth->clk_gp1) == -EPROBE_DEFER ||
> +		    PTR_ERR(eth->clk_gp1) == -EPROBE_DEFER ||
> +		    PTR_ERR(eth->clk_gp2) == -EPROBE_DEFER)
> +			return -EPROBE_DEFER;
> +		else
> +			return -ENODEV;
> +	}

Hi Sean,

this looks a bit tedious. maybe a better solution would be to add an
array to struct mtk_eth for the clocks and an enum for the index
mapping. that would allow the usage of loops to work out if all clocks
are fine. the following code calling clk_prepare_enable() could then
also be turned into a loop

	John

>  
>  	clk_prepare_enable(eth->clk_ethif);
>  	clk_prepare_enable(eth->clk_esw);
> 
