From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH] driver:net:stmmac: Disable DMA store and forward mode
 if platform data force_sf_dma_mode is negative.
Date: Mon, 19 Aug 2013 08:03:16 +0200
Message-ID: <5211B524.4030609@st.com>
References: <1376552256-7421-1-git-send-email-sonic.adi@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adi-buildroot-devel@lists.sourceforge.net,
	Sonic Zhang <sonic.zhang@analog.com>
To: Sonic Zhang <sonic.adi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:36439 "EHLO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750806Ab3HSGVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 02:21:06 -0400
In-Reply-To: <1376552256-7421-1-git-send-email-sonic.adi@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Sonic

On 8/15/2013 9:37 AM, Sonic Zhang wrote:
> From: Sonic Zhang <sonic.zhang@analog.com>
>
> Some synopsys ip implementation doesn't support DMA store and forward mode,
> such as BF60x. So, define force_sf_dma_mode negative to use DMA thresholds only.

I think that you should not pass the force_sf_dma_mode platform field
at all (and it doesn't make sense to force it as negative).
To use the threshold you should reset tx_coe. In fact, your HW cannot
perform the Hw csum if SF is not available.
Note that, the HW cap register (if available) can override (set/reset)
  tx_coe.

I tested, long time ago, this scenario on old mac w/o HW cap register
and w/o SF.

let me know if it is ok

I have just noticed that the no_csum_insertion could be removed and I'll
provide a patch for it.

peppe

>
> Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
> ---
>   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 4 +++-
>   1 file changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index f2ccb36..b0e003a 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -1157,7 +1157,9 @@ static void free_dma_desc_resources(struct stmmac_priv *priv)
>    */
>   static void stmmac_dma_operation_mode(struct stmmac_priv *priv)
>   {
> -	if (likely(priv->plat->force_sf_dma_mode ||
> +	if (priv->plat->force_sf_dma_mode < 0)
> +		priv->hw->dma->dma_mode(priv->ioaddr, tc, tc);
> +	else if (likely(priv->plat->force_sf_dma_mode > 0 ||
>   		   ((priv->plat->tx_coe) && (!priv->no_csum_insertion)))) {
>   		/*
>   		 * In case of GMAC, SF mode can be enabled
>
