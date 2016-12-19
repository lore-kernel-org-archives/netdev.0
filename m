From: Niklas Cassel <niklas.cassel@axis.com>
Subject: Re: [PATCH] stmmac: fix memory barriers
Date: Mon, 19 Dec 2016 16:08:16 +0100
Message-ID: <b78639f7-d225-22c1-d575-7d1e0016847d@axis.com>
References: <20161218203812.GA1012@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
To: Pavel Machek <pavel@ucw.cz>, <LinoSanfilippo@gmx.de>,
        <peppe.cavallaro@st.com>, <alexandre.torgue@st.com>,
        <davem@davemloft.net>, <linux-kernel@vger.kernel.org>,
        <netdev@vger.kernel.org>, <Joao.Pinto@synopsys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161218203812.GA1012@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tested-by: Niklas Cassel <niklas.cassel@axis.com>

On 12/18/2016 09:38 PM, Pavel Machek wrote:
> Fix up memory barriers in stmmac driver. They are meant to protect
> against DMA engine, so smp_ variants are certainly wrong, and dma_
> variants are preferable.
>     
> Signed-off-by: Pavel Machek <pavel@denx.de>
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
> index a340fc8..8816515 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
> @@ -334,7 +334,7 @@ static void dwmac4_rd_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
>  		 * descriptors for the same frame has to be set before, to
>  		 * avoid race condition.
>  		 */
> -		wmb();
> +		dma_wmb();
>  
>  	p->des3 = cpu_to_le32(tdes3);
>  }
> @@ -377,7 +377,7 @@ static void dwmac4_rd_prepare_tso_tx_desc(struct dma_desc *p, int is_fs,
>  		 * descriptors for the same frame has to be set before, to
>  		 * avoid race condition.
>  		 */
> -		wmb();
> +		dma_wmb();
>  
>  	p->des3 = cpu_to_le32(tdes3);
>  }
> diff --git a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
> index ce97e52..f0d8632 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
> @@ -350,7 +350,7 @@ static void enh_desc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
>  		 * descriptors for the same frame has to be set before, to
>  		 * avoid race condition.
>  		 */
> -		wmb();
> +		dma_wmb();
>  
>  	p->des0 = cpu_to_le32(tdes0);
>  }
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 3e40578..bb40382 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -2125,7 +2125,7 @@ static netdev_tx_t stmmac_tso_xmit(struct sk_buff *skb, struct net_device *dev)
>  	 * descriptor and then barrier is needed to make sure that
>  	 * all is coherent before granting the DMA engine.
>  	 */
> -	smp_wmb();
> +	dma_wmb();
>  
>  	if (netif_msg_pktdata(priv)) {
>  		pr_info("%s: curr=%d dirty=%d f=%d, e=%d, f_p=%p, nfrags %d\n",
> @@ -2338,7 +2338,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
>  		 * descriptor and then barrier is needed to make sure that
>  		 * all is coherent before granting the DMA engine.
>  		 */
> -		smp_wmb();
> +		dma_wmb();
>  	}
>  
>  	netdev_sent_queue(dev, skb->len);
> @@ -2443,14 +2443,14 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
>  			netif_dbg(priv, rx_status, priv->dev,
>  				  "refill entry #%d\n", entry);
>  		}
> -		wmb();
> +		dma_wmb();
>  
>  		if (unlikely(priv->synopsys_id >= DWMAC_CORE_4_00))
>  			priv->hw->desc->init_rx_desc(p, priv->use_riwt, 0, 0);
>  		else
>  			priv->hw->desc->set_rx_owner(p);
>  
> -		wmb();
> +		dma_wmb();
>  
>  		entry = STMMAC_GET_ENTRY(entry, DMA_RX_SIZE);
>  	}
>
