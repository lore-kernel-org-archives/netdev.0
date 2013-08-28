From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH v4][for net-next] driver:net:stmmac: Disable DMA store
 and forward mode if platform data force_thresh_dma_mode is set.
Date: Wed, 28 Aug 2013 12:39:46 +0200
Message-ID: <521DD372.9090605@st.com>
References: <1377686458-9943-1-git-send-email-sonic.adi@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adi-buildroot-devel@lists.sourceforge.net,
	Sonic Zhang <sonic.zhang@analog.com>
To: Sonic Zhang <sonic.adi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:34677 "EHLO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752184Ab3H1Kj7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 06:39:59 -0400
In-Reply-To: <1377686458-9943-1-git-send-email-sonic.adi@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/28/2013 12:40 PM, Sonic Zhang wrote:
> From: Sonic Zhang<sonic.zhang@analog.com>
>
> Some synopsys ip implementation doesn't support DMA store and forward mode,
> such as BF60x. So, set force_thresh_dma_mode to use DMA thresholds only.
> Update document and devicetree as well.
>
> Signed-off-by: Sonic Zhang<sonic.zhang@analog.com>
> ---
>   Documentation/devicetree/bindings/net/stmmac.txt      | 5 +++++
>   Documentation/networking/stmmac.txt                   | 3 +++
>   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c     | 4 +++-
>   drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 3 +++
>   include/linux/stmmac.h                                | 1 +
>   5 files changed, 15 insertions(+), 1 deletion(-)
>
> diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
> index 261c563..eba0e5e 100644
> --- a/Documentation/devicetree/bindings/net/stmmac.txt
> +++ b/Documentation/devicetree/bindings/net/stmmac.txt
> @@ -22,6 +22,11 @@ Required properties:
>   - snps,pbl		Programmable Burst Length
>   - snps,fixed-burst	Program the DMA to use the fixed burst mode
>   - snps,mixed-burst	Program the DMA to use the mixed burst mode
> +- snps,force_thresh_dma_mode	Force DMA to use the threshold mode for
> +				both tx and rx
> +- snps,force_sf_dma_mode	Force DMA to use the Store and Forward
> +				mode for both tx and rx. This flag is
> +				ignored if force_thresh_dma_mode is set.
>
>   Optional properties:
>   - mac-address: 6 bytes, mac address
> diff --git a/Documentation/networking/stmmac.txt b/Documentation/networking/stmmac.txt
> index 654d2e5..457b8bb 100644
> --- a/Documentation/networking/stmmac.txt
> +++ b/Documentation/networking/stmmac.txt
> @@ -123,6 +123,7 @@ struct plat_stmmacenet_data {
>   	int bugged_jumbo;
>   	int pmt;
>   	int force_sf_dma_mode;
> +	int force_thresh_dma_mode;
>   	int riwt_off;
>   	void (*fix_mac_speed)(void *priv, unsigned int speed);
>   	void (*bus_setup)(void __iomem *ioaddr);
> @@ -159,6 +160,8 @@ Where:
>    o pmt: core has the embedded power module (optional).
>    o force_sf_dma_mode: force DMA to use the Store and Forward mode
>   		     instead of the Threshold.
> + o force_thresh_dma_mode: force DMA to use the Shreshold mode other than
> +		     the Store and Forward mode.
>    o riwt_off: force to disable the RX watchdog feature and switch to NAPI mode.
>    o fix_mac_speed: this callback is used for modifying some syscfg registers
>   		 (on ST SoCs) according to the link speed negotiated by the
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index be40691..8d4ccd3 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -1224,7 +1224,9 @@ static void free_dma_desc_resources(struct stmmac_priv *priv)
>    */
>   static void stmmac_dma_operation_mode(struct stmmac_priv *priv)
>   {
> -	if (priv->plat->force_sf_dma_mode || priv->plat->tx_coe) {
> +	if (priv->plat->force_thresh_dma_mode)
> +		priv->hw->dma->dma_mode(priv->ioaddr, tc, tc);
> +	else if (priv->plat->force_sf_dma_mode || priv->plat->tx_coe) {
>   		/*
>   		 * In case of GMAC, SF mode can be enabled
>   		 * to perform the TX COE in HW. This depends on:
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> index da8be6e..865c944 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> @@ -79,6 +79,9 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
>   	of_property_read_u32(np, "snps,pbl", &dma_cfg->pbl);
>   	dma_cfg->fixed_burst = of_property_read_bool(np, "snps,fixed-burst");
>   	dma_cfg->mixed_burst = of_property_read_bool(np, "snps,mixed-burst");
> +	plat->force_thresh_dma_mode = of_property_read_bool(np, "snps,force_thresh_dma_mode");
> +	if (plat->force_thresh_dma_mode)
> +		plat->force_sf_dma_mode = 0;
>

ok this solution looks to be a compromise and avoids to disturb 
platforms that already use the force_sf_dma_mode.

can I only ask you to add a pr_warn here

thanks a lot
peppe
