From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 1/2] drivers: net: xgene: Add support RGMII TX/RX
 delay configuration
Date: Fri, 16 Oct 2015 14:36:14 -0700
Message-ID: <56216DCE.6020800@gmail.com>
References: <1445027752-16982-1-git-send-email-isubramanian@apm.com> <1445027752-16982-2-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	patches@apm.com
To: Iyappan Subramanian <isubramanian@apm.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34756 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750772AbbJPVgn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 17:36:43 -0400
In-Reply-To: <1445027752-16982-2-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/10/15 13:35, Iyappan Subramanian wrote:
> Add RGMII TX/RX delay configuration support. RGMII standard requires 2ns
> delay to help the RGMII bridge receiver to sample data correctly. If the
> default value does not provide proper centering of the data sample, the
> TX/RX delay parameters can be used to adjust accordingly.

There is a standard 'phy-mode' property which can take multiple values
for RGMII: "rgmii" (no delay), "rgmii-txid" (transmit delay),
"rgmii-rxid" (receive delay) and "rgmii-id" (symetric delay). There does
not seem to be any verification of whether the rx or tx delay parameters
you introduce are going to be either sensible, or not conflicting with
the 'phy-mode' that should be configured.

> 
> Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
> ---
>  drivers/net/ethernet/apm/xgene/xgene_enet_hw.c   |  8 +++-
>  drivers/net/ethernet/apm/xgene/xgene_enet_hw.h   |  1 +
>  drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 49 ++++++++++++++++++++++++
>  drivers/net/ethernet/apm/xgene/xgene_enet_main.h |  2 +
>  4 files changed, 59 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
> index 652f218..33850a0 100644
> --- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
> +++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
> @@ -461,6 +461,7 @@ static void xgene_gmac_reset(struct xgene_enet_pdata *pdata)
>  
>  static void xgene_gmac_init(struct xgene_enet_pdata *pdata)
>  {
> +	struct device *dev = &pdata->pdev->dev;
>  	u32 value, mc2;
>  	u32 intf_ctl, rgmii;
>  	u32 icm0, icm2;
> @@ -490,7 +491,12 @@ static void xgene_gmac_init(struct xgene_enet_pdata *pdata)
>  	default:
>  		ENET_INTERFACE_MODE2_SET(&mc2, 2);
>  		intf_ctl |= ENET_GHD_MODE;
> -		CFG_TXCLK_MUXSEL0_SET(&rgmii, 4);
> +
> +		if (dev->of_node) {
> +			CFG_TXCLK_MUXSEL0_SET(&rgmii, pdata->tx_delay);
> +			CFG_RXCLK_MUXSEL0_SET(&rgmii, pdata->rx_delay);
> +		}
> +
>  		xgene_enet_rd_csr(pdata, DEBUG_REG_ADDR, &value);
>  		value |= CFG_BYPASS_UNISEC_TX | CFG_BYPASS_UNISEC_RX;
>  		xgene_enet_wr_csr(pdata, DEBUG_REG_ADDR, value);
> diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
> index ff05bbc..6dee73c 100644
> --- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
> +++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
> @@ -144,6 +144,7 @@ enum xgene_enet_rm {
>  #define CFG_BYPASS_UNISEC_RX		BIT(1)
>  #define CFG_CLE_BYPASS_EN0		BIT(31)
>  #define CFG_TXCLK_MUXSEL0_SET(dst, val)	xgene_set_bits(dst, val, 29, 3)
> +#define CFG_RXCLK_MUXSEL0_SET(dst, val)	xgene_set_bits(dst, val, 26, 3)
>  
>  #define CFG_CLE_IP_PROTOCOL0_SET(dst, val)	xgene_set_bits(dst, val, 16, 2)
>  #define CFG_CLE_DSTQID0_SET(dst, val)		xgene_set_bits(dst, val, 0, 12)
> diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> index 6b1846d..ce10687 100644
> --- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> +++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> @@ -1118,6 +1118,47 @@ static int xgene_get_port_id_dt(struct device *dev, struct xgene_enet_pdata *pda
>  	return ret;
>  }
>  
> +static int xgene_get_tx_delay(struct xgene_enet_pdata *pdata)
> +{
> +	struct device *dev = &pdata->pdev->dev;
> +	int delay, ret;
> +
> +	ret = of_property_read_u32(dev->of_node, "tx-delay", &delay);
> +	if (ret) {
> +		pdata->tx_delay = 4;
> +		return 0;
> +	}
> +
> +	if (delay < 0 || delay > 7) {
> +		dev_err(dev, "Invalid tx-delay specified\n");
> +		return -EINVAL;
> +	}
> +
> +	pdata->tx_delay = delay;
> +
> +	return 0;
> +}
> +
> +static int xgene_get_rx_delay(struct xgene_enet_pdata *pdata)
> +{
> +	struct device *dev = &pdata->pdev->dev;
> +	int delay, ret;
> +
> +	ret = of_property_read_u32(dev->of_node, "rx-delay", &delay);
> +	if (ret) {
> +		pdata->rx_delay = 2;
> +		return 0;
> +	}
> +
> +	if (delay < 0 || delay > 7) {
> +		dev_err(dev, "Invalid rx-delay specified\n");
> +		return -EINVAL;
> +	}
> +
> +	pdata->rx_delay = delay;
> +
> +	return 0;
> +}
>  
>  static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
>  {
> @@ -1194,6 +1235,14 @@ static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
>  		return -ENODEV;
>  	}
>  
> +	ret = xgene_get_tx_delay(pdata);
> +	if (ret)
> +		return ret;
> +
> +	ret = xgene_get_rx_delay(pdata);
> +	if (ret)
> +		return ret;
> +
>  	ret = platform_get_irq(pdev, 0);
>  	if (ret <= 0) {
>  		dev_err(dev, "Unable to get ENET Rx IRQ\n");
> diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
> index ff89a5d..a6e56b8 100644
> --- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
> +++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
> @@ -184,6 +184,8 @@ struct xgene_enet_pdata {
>  	u8 bp_bufnum;
>  	u16 ring_num;
>  	u32 mss;
> +	u8 tx_delay;
> +	u8 rx_delay;
>  };
>  
>  struct xgene_indirect_ctl {
> 


-- 
Florian
