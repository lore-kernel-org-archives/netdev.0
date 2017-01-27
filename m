From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 1/2] ravb: Add tx and rx clock internal delays
 mode of APSR
Date: Fri, 27 Jan 2017 16:00:27 +0300
Message-ID: <57812c3f-3130-7141-c479-6beefb237907@cogentembedded.com>
References: <1485515090-7570-1-git-send-email-horms+renesas@verge.net.au>
 <1485515090-7570-2-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org,
        Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
To: Simon Horman <horms+renesas@verge.net.au>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f46.google.com ([209.85.215.46]:35766 "EHLO
        mail-lf0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754859AbdA0NAc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 08:00:32 -0500
Received: by mail-lf0-f46.google.com with SMTP id n124so161138751lfd.2
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 05:00:31 -0800 (PST)
In-Reply-To: <1485515090-7570-2-git-send-email-horms+renesas@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/27/2017 02:04 PM, Simon Horman wrote:

> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>
> This patch enables tx and rx clock internal delay modes (TDM and RDM).
>
> This is to address a failure in the case of 1Gbps communication using the
> by salvator-x board with the KSZ9031RNX phy. This has been reported to
> occur with both the r8a7795 (H3) and r8a7796 (M3-W) SoCs.
>
> With this change APSR internal delay modes are enabled for
> "rgmii-id", "rgmii-rxid" and "rgmii-txid" phy modes as follows:
>
> phy mode   | ASPR delay mode
> -----------+----------------
> rgmii-id   | TDM and RDM
> rgmii-rxid | RDM
> rgmii-txid | TDM
>
> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
>
> ---
> v1 [Simon Horman]
> - Combined patches
> - Reworded changelog
>
> v0 [Kazuya Mizuguchi]
[...]
> diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
> index 89ac1e3f6175..9fb4c04c5885 100644
> --- a/drivers/net/ethernet/renesas/ravb_main.c
> +++ b/drivers/net/ethernet/renesas/ravb_main.c
> @@ -1904,6 +1904,29 @@ static void ravb_set_config_mode(struct net_device *ndev)
>  	}
>  }
>
> +static void ravb_set_delay_mode(struct net_device *ndev)
> +{
> +	struct ravb_private *priv = netdev_priv(ndev);
> +
> +	if (priv->chip_id != RCAR_GEN2) {
> +		switch (priv->phy_interface) {
> +		case PHY_INTERFACE_MODE_RGMII_ID:
> +			ravb_modify(ndev, APSR, APSR_DM, APSR_DM_RDM |
> +				   APSR_DM_TDM);
> +			break;
> +		case PHY_INTERFACE_MODE_RGMII_RXID:
> +			ravb_modify(ndev, APSR, APSR_DM, APSR_DM_RDM);
> +			break;
> +		case PHY_INTERFACE_MODE_RGMII_TXID:
> +			ravb_modify(ndev, APSR, APSR_DM, APSR_DM_TDM);
> +			break;
> +		default:
> +			ravb_modify(ndev, APSR, APSR_DM, 0);
> +			break;
> +		}
> +	}
> +}
> +
>  static int ravb_probe(struct platform_device *pdev)
>  {
>  	struct device_node *np = pdev->dev.of_node;
> @@ -2016,6 +2039,9 @@ static int ravb_probe(struct platform_device *pdev)
>  	/* Request GTI loading */
>  	ravb_modify(ndev, GCCR, GCCR_LTI, GCCR_LTI);
>
> +	/* Set APSR */
> +	ravb_set_delay_mode(ndev);
> +
>  	/* Allocate descriptor base address table */
>  	priv->desc_bat_size = sizeof(struct ravb_desc) * DBAT_ENTRY_NUM;
>  	priv->desc_bat = dma_alloc_coherent(ndev->dev.parent, priv->desc_bat_size,
> @@ -2152,6 +2178,9 @@ static int __maybe_unused ravb_resume(struct device *dev)
>  	/* Request GTI loading */
>  	ravb_modify(ndev, GCCR, GCCR_LTI, GCCR_LTI);
>
> +	/* Set APSR */
> +	ravb_set_delay_mode(ndev);
> +

    So far the pattern was to first check if gen != 2, then calling a gen3 
specific function. I'd like to keep it, rather than checking in the function 
itself.

[...]

MBR, Sergei
