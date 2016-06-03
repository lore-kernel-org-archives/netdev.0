From: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH] net: ethernet: ti: cpsw: remove rx_descs property
Date: Fri, 3 Jun 2016 19:50:42 +0300
Message-ID: <5751B562.8020708@ti.com>
References: <1464907420-19694-1-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <pawel.moll-5wv7dgnIgG8@public.gmane.org>, <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	<ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>, <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	<bcousson-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>, <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Ivan Khoronzhuk <ivan.khoronzhuk-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	<mugunthanvnm-l0cyMroinI0@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1464907420-19694-1-git-send-email-ivan.khoronzhuk-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 06/03/2016 01:43 AM, Ivan Khoronzhuk wrote:
> There is no reason to hold s/w dependent parameter in device tree.
> Even more, there is no reason in this parameter because davinici_cpdma
> driver splits pool of descriptors equally between tx and rx channels.
> That is, if number of descriptors 256, 128 of them are for rx
> channels. While receiving, the descriptor is freed to the pool and
> then allocated with new skb. And if in DT the "rx_descs" is set to
> 64, then 128 - 64 = 64 descriptors are always in the pool and cannot
> be used, for tx, for instance. It's not correct resource usage,
> better to set it to half of pool, then the rx pool can be used in
> full. It will not have any impact on performance, as anyway, the
> "redundant" descriptors were unused.
>
> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> ---
>
> Based on master
>
>   Documentation/devicetree/bindings/net/cpsw.txt |  3 ---
>   arch/arm/boot/dts/am33xx.dtsi                  |  1 -
>   arch/arm/boot/dts/am4372.dtsi                  |  1 -
>   arch/arm/boot/dts/dm814x.dtsi                  |  1 -
>   arch/arm/boot/dts/dra7.dtsi                    |  1 -


Pls, split DT and non-DT changes, seems code changes should go first.

>   drivers/net/ethernet/ti/cpsw.c                 | 13 +++----------
>   drivers/net/ethernet/ti/cpsw.h                 |  1 -
>   drivers/net/ethernet/ti/davinci_cpdma.c        |  6 ++++++
>   drivers/net/ethernet/ti/davinci_cpdma.h        |  1 +
>   9 files changed, 10 insertions(+), 18 deletions(-)
>
> diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
> index 0ae0649..5fe6239 100644
> --- a/Documentation/devicetree/bindings/net/cpsw.txt
> +++ b/Documentation/devicetree/bindings/net/cpsw.txt
> @@ -15,7 +15,6 @@ Required properties:
>   - cpdma_channels 	: Specifies number of channels in CPDMA
>   - ale_entries		: Specifies No of entries ALE can hold
>   - bd_ram_size		: Specifies internal descriptor RAM size
> -- rx_descs		: Specifies number of Rx descriptors
>   - mac_control		: Specifies Default MAC control register content
>   			  for the specific platform
>   - slaves		: Specifies number for slaves
> @@ -70,7 +69,6 @@ Examples:

[....]

>   			slaves = <2>;
>   			active_slave = <0>;
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index 4b08a2f..635be3e 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -1277,6 +1277,7 @@ static int cpsw_ndo_open(struct net_device *ndev)
>   				  ALE_ALL_PORTS, ALE_ALL_PORTS, 0, 0);
>
>   	if (!cpsw_common_res_usage_state(priv)) {
> +		int buf_num;
>   		struct cpsw_priv *priv_sl0 = cpsw_get_slave_priv(priv, 0);
>
>   		/* setup tx dma to fixed prio and zero offset */
> @@ -1305,10 +1306,8 @@ static int cpsw_ndo_open(struct net_device *ndev)
>   			enable_irq(priv->irqs_table[0]);
>   		}
>
> -		if (WARN_ON(!priv->data.rx_descs))
> -			priv->data.rx_descs = 128;
> -
> -		for (i = 0; i < priv->data.rx_descs; i++) {
> +		buf_num = cpdma_chan_get_buf_num(priv->dma) / 2;

Could you get rid of "/ 2", pls?

> +		for (i = 0; i < buf_num; i++) {
>   			struct sk_buff *skb;
>
>   			ret = -ENOMEM;
> @@ -1999,12 +1998,6 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
>   	}
>   	data->bd_ram_size = prop;
>
> -	if (of_property_read_u32(node, "rx_descs", &prop)) {
> -		dev_err(&pdev->dev, "Missing rx_descs property in the DT.\n");
> -		return -EINVAL;
> -	}
> -	data->rx_descs = prop;
> -
>   	if (of_property_read_u32(node, "mac_control", &prop)) {
>   		dev_err(&pdev->dev, "Missing mac_control property in the DT.\n");
>   		return -EINVAL;
> diff --git a/drivers/net/ethernet/ti/cpsw.h b/drivers/net/ethernet/ti/cpsw.h
> index e50afd1..16b54c6 100644
> --- a/drivers/net/ethernet/ti/cpsw.h
> +++ b/drivers/net/ethernet/ti/cpsw.h
> @@ -35,7 +35,6 @@ struct cpsw_platform_data {
>   	u32	cpts_clock_shift; /* convert input clock ticks to nanoseconds */
>   	u32	ale_entries;	/* ale table size */
>   	u32	bd_ram_size;  /*buffer descriptor ram size */
> -	u32	rx_descs;	/* Number of Rx Descriptios */
>   	u32	mac_control;	/* Mac control register */
>   	u16	default_vlan;	/* Def VLAN for ALE lookup in VLAN aware mode*/
>   	bool	dual_emac;	/* Enable Dual EMAC mode */
> diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
> index 18bf3a8..395647c 100644
> --- a/drivers/net/ethernet/ti/davinci_cpdma.c
> +++ b/drivers/net/ethernet/ti/davinci_cpdma.c
> @@ -543,6 +543,12 @@ struct cpdma_chan *cpdma_chan_create(struct cpdma_ctlr *ctlr, int chan_num,
>   }
>   EXPORT_SYMBOL_GPL(cpdma_chan_create);
>
> +int cpdma_chan_get_buf_num(struct cpdma_ctlr *ctlr)
> +{
> +	return ctlr->pool->num_desc;
> +}
> +EXPORT_SYMBOL_GPL(cpdma_chan_get_buf_num);
> +
>   int cpdma_chan_destroy(struct cpdma_chan *chan)
>   {
>   	struct cpdma_ctlr *ctlr;
> diff --git a/drivers/net/ethernet/ti/davinci_cpdma.h b/drivers/net/ethernet/ti/davinci_cpdma.h
> index 86dee48..f059856 100644
> --- a/drivers/net/ethernet/ti/davinci_cpdma.h
> +++ b/drivers/net/ethernet/ti/davinci_cpdma.h
> @@ -81,6 +81,7 @@ int cpdma_ctlr_dump(struct cpdma_ctlr *ctlr);
>
>   struct cpdma_chan *cpdma_chan_create(struct cpdma_ctlr *ctlr, int chan_num,
>   				     cpdma_handler_fn handler);
> +int cpdma_chan_get_buf_num(struct cpdma_ctlr *ctlr);
>   int cpdma_chan_destroy(struct cpdma_chan *chan);
>   int cpdma_chan_start(struct cpdma_chan *chan);
>   int cpdma_chan_stop(struct cpdma_chan *chan);
>


-- 
regards,
-grygorii
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
