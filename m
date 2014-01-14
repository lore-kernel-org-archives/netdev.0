From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next v3 2/2] stmmac: Fix kernel crashes for jumbo
 frames
Date: Tue, 14 Jan 2014 19:53:36 +0000
Message-ID: <1389729216.2025.197.camel@bwh-desktop.uk.level5networks.com>
References: <1389719859-29071-1-git-send-email-vbridgers2013@gmail.com>
	 <1389719859-29071-3-git-send-email-vbridgers2013@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <devicetree@vger.kernel.org>, <netdev@vger.kernel.org>,
	<peppe.cavallaro@st.com>, <robh+dt@kernel.org>,
	<pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<dinguyen@altera.com>, <rayagond@vayavyalabs.com>
To: Vince Bridgers <vbridgers2013@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:54623 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751462AbaANTxm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 14:53:42 -0500
In-Reply-To: <1389719859-29071-3-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-01-14 at 11:17 -0600, Vince Bridgers wrote:
> These changes correct the following issues with jumbo frames on the
> stmmac driver:
> 
> 1) The Synopsys EMAC can be configured to support different FIFO
> sizes at core configuration time. There's no way to query the
> controller and know the FIFO size, so the driver needs to get this
> information from the device tree in order to know how to correctly
> handle MTU changes and setting up dma buffers. The default
> max-frame-size is as currently used, which is the size of a jumbo
> frame.
> 
> 2) The driver was enabling Jumbo frames by default, but was not allocating
> dma buffers of sufficient size to handle the maximum possible packet
> size that could be received. This led to memory corruption since DMAs were
> occurring beyond the extent of the allocated receive buffers for certain types
> of network traffic.
[...]
> --- a/drivers/net/ethernet/stmicro/stmmac/common.h
> +++ b/drivers/net/ethernet/stmicro/stmmac/common.h
> @@ -293,6 +293,8 @@ struct dma_features {
>  #define STMMAC_CHAIN_MODE	0x1
>  #define STMMAC_RING_MODE	0x2
>  
> +#define JUMBO_LEN		9000
> +
>  struct stmmac_desc_ops {
>  	/* DMA RX descriptor ring initialization */
>  	void (*init_rx_desc) (struct dma_desc *p, int disable_rx_ic, int mode,
[...]
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> @@ -51,6 +51,10 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
>  	plat->mdio_bus_data = devm_kzalloc(&pdev->dev,
>  					   sizeof(struct stmmac_mdio_bus_data),
>  					   GFP_KERNEL);
> +	/* Set the maxmtu to a default of 1500 in case the
> +	 * parameter is not present in the device tree
> +	 */
> +	plat->maxmtu = JUMBO_LEN;

The comment disagrees with the definition of JUMBO_LEN.

>  
>  	/*
>  	 * Currently only the properties needed on SPEAr600
> @@ -60,6 +64,7 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
>  	if (of_device_is_compatible(np, "st,spear600-gmac") ||
>  		of_device_is_compatible(np, "snps,dwmac-3.70a") ||
>  		of_device_is_compatible(np, "snps,dwmac")) {
> +		of_property_read_u32(np, "max-frame-size", &plat->maxmtu);
[...]

Is it the maximum frame size, including Ethernet header?  (And then, is
the CRC or any VLAN header included in the frame size?)
Or is it the MTU, excluding all of those?
You really need to be very clear about what this number represents.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
