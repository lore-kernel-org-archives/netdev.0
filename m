From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH RFC 1/5] net:stmmac: set threshold/store and forward mode
 according to mtu size.
Date: Mon, 21 Oct 2013 10:47:00 +0200
Message-ID: <5264EA04.1040002@st.com>
References: <1381937052-8999-1-git-send-email-jimmy.perchet@parrot.com> <1381937052-8999-2-git-send-email-jimmy.perchet@parrot.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Jimmy Perchet <jimmy.perchet@parrot.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:46855 "EHLO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754009Ab3JUJLN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 05:11:13 -0400
In-Reply-To: <1381937052-8999-2-git-send-email-jimmy.perchet@parrot.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/16/2013 5:24 PM, Jimmy Perchet wrote:
> Threshold mode dma is needed on rx path if jumbo frames are expected.

I think we should not force the threshold mode depending on the mtu.

For example, I worked on hw with rx buffers ~16KiB so able to SF
an oversized frame.

Maybe we could solve this configuration problem at platform time.
We added the fields: force_thresh_dma_mode, force_sf_dma_mode
to cover this scenarios. If these need to be enforced so we can
prepare a patch.

let me know
peppe

>
>
> Signed-off-by: Jimmy Perchet <jimmy.perchet@parrot.com>
> ---
>   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 48 ++++++++++++++++-------
>   1 file changed, 33 insertions(+), 15 deletions(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 8d4ccd3..170f043 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -1222,22 +1222,40 @@ static void free_dma_desc_resources(struct stmmac_priv *priv)
>    *  Description: it sets the DMA operation mode: tx/rx DMA thresholds
>    *  or Store-And-Forward capability.
>    */
> -static void stmmac_dma_operation_mode(struct stmmac_priv *priv)
> -{
> -	if (priv->plat->force_thresh_dma_mode)
> -		priv->hw->dma->dma_mode(priv->ioaddr, tc, tc);
> -	else if (priv->plat->force_sf_dma_mode || priv->plat->tx_coe) {
> -		/*
> -		 * In case of GMAC, SF mode can be enabled
> -		 * to perform the TX COE in HW. This depends on:
> -		 * 1) TX COE if actually supported
> -		 * 2) There is no bugged Jumbo frame support
> -		 *    that needs to not insert csum in the TDES.
> -		 */
> -		priv->hw->dma->dma_mode(priv->ioaddr, SF_DMA_MODE, SF_DMA_MODE);
> +static void stmmac_dma_operation_mode(int mtu, struct stmmac_priv *priv)
> +{
> +	int rx_tc, tx_tc;
> +
> +	/*
> +	 * In case of GMAC, SF mode can be enabled
> +	 * to perform the TX COE in HW. This depends on:
> +	 * 1) TX COE if actually supported
> +	 * 2) There is no bugged Jumbo frame support
> +	 *    that needs to not insert csum in the TDES.
> +	 */
> +	if (priv->plat->tx_coe &&
> +	    !(priv->plat->bugged_jumbo && (mtu > ETH_DATA_LEN))) {
>   		tc = SF_DMA_MODE;
> +		tx_tc = SF_DMA_MODE;
>   	} else
> -		priv->hw->dma->dma_mode(priv->ioaddr, tc, SF_DMA_MODE);
> +		tx_tc = tc;
> +
> +	if (mtu > ETH_DATA_LEN && priv->hw_cap_support
> +	    && !priv->dma_cap.rxfifo_over_2048)
> +		rx_tc = tc;
> +	else
> +		rx_tc = SF_DMA_MODE;
> +
> +	if (priv->plat->force_sf_dma_mode) {
> +		tc = SF_DMA_MODE;
> +		tx_tc = SF_DMA_MODE;
> +		rx_tc = SF_DMA_MODE;
> +	} else if (priv->plat->force_thresh_dma_mode) {
> +		tx_tc = tc;
> +		rx_tc = tc;
> +	}
> +
> +	priv->hw->dma->dma_mode(priv->ioaddr, tx_tc, rx_tc);
>   }
>
>   /**
> @@ -1687,7 +1705,7 @@ static int stmmac_open(struct net_device *dev)
>   	stmmac_set_mac(priv->ioaddr, true);
>
>   	/* Set the HW DMA mode and the COE */
> -	stmmac_dma_operation_mode(priv);
> +	stmmac_dma_operation_mode(dev->mtu, priv);
>
>   	/* Extra statistics */
>   	memset(&priv->xstats, 0, sizeof(struct stmmac_extra_stats));
>
