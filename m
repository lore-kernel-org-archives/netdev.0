From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 13/17] net: stmmac: Implement NAPI for TX
Date: Tue, 31 Jan 2017 11:28:03 +0100
Message-ID: <cd8b200c-f419-80c3-714e-cb81a95da65c@st.com>
References: <20170131091152.13842-1-clabbe.montjoie@gmail.com>
 <20170131091152.13842-14-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <linux-kernel@vger.kernel.org>
To: Corentin Labbe <clabbe.montjoie@gmail.com>,
        <alexandre.torgue@st.com>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170131091152.13842-14-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/31/2017 10:11 AM, Corentin Labbe wrote:
> The stmmac driver run TX completion under NAPI but without checking the
> work done by the TX completion function.
>
> This patch add work/budget to the TX completion function.
>
> The visible effect is that it keep the driver longer under NAPI and
> boost performance.
> Under dwmac-sun8i the iperf goes from 140Mbit/s to 500Mbit/s.
> Under dwmac-sunxi an iperf run use half less interrupts.

I think that this patch should be sent separately with more details
about the implementation you are adopting and results.

For example, in the timer callback you force 256 (it seems
DMA_TX_SIZE/2); do you think this should be tunable or fixed to
NAPI budget?

I'd like to understand if performance you get are for TCP traffic;
can you tell me what happens on unidirectional traffic?

Thx a lot for your effort, pls let me know

Regards
peppe

>
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 18 ++++++++++++++----
>  1 file changed, 14 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 2df36bd..e53b727 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -1299,10 +1299,11 @@ static void stmmac_dma_operation_mode(struct stmmac_priv *priv)
>   * @priv: driver private structure
>   * Description: it reclaims the transmit resources after transmission completes.
>   */
> -static void stmmac_tx_clean(struct stmmac_priv *priv)
> +static int stmmac_tx_clean(struct stmmac_priv *priv, int budget)
>  {
>  	unsigned int bytes_compl = 0, pkts_compl = 0;
>  	unsigned int entry = priv->dirty_tx;
> +	int work = 0;
>
>  	netif_tx_lock(priv->dev);
>
> @@ -1369,6 +1370,9 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
>  		priv->hw->desc->release_tx_desc(p, priv->mode);
>
>  		entry = STMMAC_GET_ENTRY(entry, DMA_TX_SIZE);
> +		work++;
> +		if (work >= budget)
> +			break;
>  	}
>  	priv->dirty_tx = entry;
>
> @@ -1386,6 +1390,11 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
>  		mod_timer(&priv->eee_ctrl_timer, STMMAC_LPI_T(eee_timer));
>  	}
>  	netif_tx_unlock(priv->dev);
> +
> +	if (work < budget)
> +		work = 0;
> +
> +	return work;
>  }
>
>  static inline void stmmac_enable_dma_irq(struct stmmac_priv *priv)
> @@ -1617,7 +1626,7 @@ static void stmmac_tx_timer(unsigned long data)
>  {
>  	struct stmmac_priv *priv = (struct stmmac_priv *)data;
>
> -	stmmac_tx_clean(priv);
> +	stmmac_tx_clean(priv, 256);
>  }
>
>  /**
> @@ -2657,9 +2666,10 @@ static int stmmac_poll(struct napi_struct *napi, int budget)
>  	int work_done = 0;
>
>  	priv->xstats.napi_poll++;
> -	stmmac_tx_clean(priv);
> +	work_done += stmmac_tx_clean(priv, budget);
>
> -	work_done = stmmac_rx(priv, budget);
> +	if (work_done < budget)
> +		work_done += stmmac_rx(priv, budget - work_done);
>  	if (work_done < budget) {
>  		napi_complete(napi);
>  		stmmac_enable_dma_irq(priv);
>
