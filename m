From: Alexandre Torgue <alexandre.torgue@st.com>
Subject: Re: [PATCH] stmmac: reduce code duplication getting basic descriptors
Date: Fri, 2 Dec 2016 15:09:00 +0100
Message-ID: <82b6c16d-49d1-30b2-78a3-8d150c5e24a0@st.com>
References: <20161123105125.GA26394@amd> <20161124085506.GA25007@amd>
 <20161124.110416.198867271899443489.davem@davemloft.net>
 <20161128121736.GD15034@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <peppe.cavallaro@st.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Pavel Machek <pavel@ucw.cz>, David Miller <davem@davemloft.net>,
        Andrew Morton <akpm@osdl.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161128121736.GD15034@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Pavel,

On 11/28/2016 01:17 PM, Pavel Machek wrote:
>
> Remove code duplication getting basic descriptors.

I agree with your patch, it will make code easier to understand.
After fix kbuild issue you can add my Acked-by;

Regards
Alex

>
> Signed-off-by: Pavel Machek <pavel@denx.de>
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index f7133d0..ed20668 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -929,6 +929,17 @@ static int stmmac_set_bfsize(int mtu, int bufsize)
>  	return ret;
>  }
>
> +static inline struct dma_desc *stmmac_tx_desc(struct stmmac_priv *priv, int i)
> +{
> +	struct dma_desc *p;
> +	if (priv->extend_desc)
> +		p = &((priv->dma_etx + i)->basic);
> +	else
> +		p = priv->dma_tx + i;
> +	return p;
> +}
> +
> +
>  /**
>   * stmmac_clear_descriptors - clear descriptors
>   * @priv: driver private structure
> @@ -1078,11 +1089,7 @@ static int init_dma_desc_rings(struct net_device *dev, gfp_t flags)
>
>  	/* TX INITIALIZATION */
>  	for (i = 0; i < DMA_TX_SIZE; i++) {
> -		struct dma_desc *p;
> -		if (priv->extend_desc)
> -			p = &((priv->dma_etx + i)->basic);
> -		else
> -			p = priv->dma_tx + i;
> +		struct dma_desc *p = stmmac_tx_desc(priv, i);
>
>  		if (priv->synopsys_id >= DWMAC_CORE_4_00) {
>  			p->des0 = 0;
> @@ -1129,12 +1136,7 @@ static void dma_free_tx_skbufs(struct stmmac_priv *priv)
>  	int i;
>
>  	for (i = 0; i < DMA_TX_SIZE; i++) {
> -		struct dma_desc *p;
> -
> -		if (priv->extend_desc)
> -			p = &((priv->dma_etx + i)->basic);
> -		else
> -			p = priv->dma_tx + i;
> +		struct dma_desc *p = stmmac_tx_desc(priv, i);
>
>  		if (priv->tx_skbuff_dma[i].buf) {
>  			if (priv->tx_skbuff_dma[i].map_as_page)
> @@ -1314,14 +1316,9 @@ static void __stmmac_tx_clean(struct stmmac_priv *priv)
>
>  	while (entry != priv->cur_tx) {
>  		struct sk_buff *skb = priv->tx_skbuff[entry];
> -		struct dma_desc *p;
> +		struct dma_desc *p = stmmac_tx_desc(priv, entry);
>  		int status;
>
> -		if (priv->extend_desc)
> -			p = (struct dma_desc *)(priv->dma_etx + entry);
> -		else
> -			p = priv->dma_tx + entry;
> -
>  		status = priv->hw->desc->tx_status(&priv->dev->stats,
>  						      &priv->xstats, p,
>  						      priv->ioaddr);
> @@ -2227,11 +2224,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
>
>  	csum_insertion = (skb->ip_summed == CHECKSUM_PARTIAL);
>
> -	if (likely(priv->extend_desc))
> -		desc = (struct dma_desc *)(priv->dma_etx + entry);
> -	else
> -		desc = priv->dma_tx + entry;
> -
> +	desc = stmmac_tx_desc(priv, entry);
>  	first = desc;
>
>  	priv->tx_skbuff[first_entry] = skb;
> @@ -2254,10 +2247,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
>
>  		entry = STMMAC_GET_ENTRY(entry, DMA_TX_SIZE);
>
> -		if (likely(priv->extend_desc))
> -			desc = (struct dma_desc *)(priv->dma_etx + entry);
> -		else
> -			desc = priv->dma_tx + entry;
> +		desc = stmmac_tx_desc(priv, entry);
>
>  		des = skb_frag_dma_map(priv->device, frag, 0, len,
>  				       DMA_TO_DEVICE);
>
