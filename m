From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: bcmgenet: Use correct I/O accessors
Date: Tue, 29 Aug 2017 12:29:51 -0700
Message-ID: <1492d575-dad7-1b16-1717-b64909b1e8ed@gmail.com>
References: <1504034587-31113-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, opendmb@gmail.com, jaedon.shin@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:37182 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751237AbdH2T34 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 15:29:56 -0400
Received: by mail-qk0-f194.google.com with SMTP id m4so3691601qke.4
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 12:29:56 -0700 (PDT)
In-Reply-To: <1504034587-31113-1-git-send-email-f.fainelli@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/29/2017 12:23 PM, Florian Fainelli wrote:
> From: Florian Fainelli <florian.fainelli@broadcom.com>

Oh nooo I just exposed myself, let me resend with the gmail address.

> 
> The GENET driver currently uses __raw_{read,write}l which means
> native I/O endian. This works correctly for an ARM LE kernel (default)
> but fails miserably on an ARM BE (BE8) kernel where registers are kept
> little endian, so replace uses with {read,write}l_relaxed here which is
> what we want because this is all performance sensitive code.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
> This was tested on ARM LE and ARM BE, but I would appreciate Doug's
> review on this to make sure I did not add bugs
> 
>  drivers/net/ethernet/broadcom/genet/bcmgenet.c | 75 ++++++++++++++++----------
>  drivers/net/ethernet/broadcom/genet/bcmgenet.h | 13 ++++-
>  2 files changed, 58 insertions(+), 30 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> index a981c4ee9d72..612d1ef3b5f5 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> @@ -72,23 +72,42 @@
>  #define GENET_RDMA_REG_OFF	(priv->hw_params->rdma_offset + \
>  				TOTAL_DESC * DMA_DESC_SIZE)
>  
> +static inline void bcmgenet_writel(u32 value, void __iomem *offset)
> +{
> +	/* MIPS chips strapped for BE will automagically configure the
> +	 * peripheral registers for CPU-native byte order.
> +	 */
> +	if (IS_ENABLED(CONFIG_MIPS) && IS_ENABLED(CONFIG_CPU_BIG_ENDIAN))
> +		__raw_writel(value, offset);
> +	else
> +		writel_relaxed(value, offset);
> +}
> +
> +static inline u32 bcmgenet_readl(void __iomem *offset)
> +{
> +	if (IS_ENABLED(CONFIG_MIPS) && IS_ENABLED(CONFIG_CPU_BIG_ENDIAN))
> +		return __raw_readl(offset);
> +	else
> +		return readl_relaxed(offset);
> +}
> +
>  static inline void dmadesc_set_length_status(struct bcmgenet_priv *priv,
>  					     void __iomem *d, u32 value)
>  {
> -	__raw_writel(value, d + DMA_DESC_LENGTH_STATUS);
> +	bcmgenet_writel(value, d + DMA_DESC_LENGTH_STATUS);
>  }
>  
>  static inline u32 dmadesc_get_length_status(struct bcmgenet_priv *priv,
>  					    void __iomem *d)
>  {
> -	return __raw_readl(d + DMA_DESC_LENGTH_STATUS);
> +	return bcmgenet_readl(d + DMA_DESC_LENGTH_STATUS);
>  }
>  
>  static inline void dmadesc_set_addr(struct bcmgenet_priv *priv,
>  				    void __iomem *d,
>  				    dma_addr_t addr)
>  {
> -	__raw_writel(lower_32_bits(addr), d + DMA_DESC_ADDRESS_LO);
> +	bcmgenet_writel(lower_32_bits(addr), d + DMA_DESC_ADDRESS_LO);
>  
>  	/* Register writes to GISB bus can take couple hundred nanoseconds
>  	 * and are done for each packet, save these expensive writes unless
> @@ -96,7 +115,7 @@ static inline void dmadesc_set_addr(struct bcmgenet_priv *priv,
>  	 */
>  #ifdef CONFIG_PHYS_ADDR_T_64BIT
>  	if (priv->hw_params->flags & GENET_HAS_40BITS)
> -		__raw_writel(upper_32_bits(addr), d + DMA_DESC_ADDRESS_HI);
> +		bcmgenet_writel(upper_32_bits(addr), d + DMA_DESC_ADDRESS_HI);
>  #endif
>  }
>  
> @@ -113,7 +132,7 @@ static inline dma_addr_t dmadesc_get_addr(struct bcmgenet_priv *priv,
>  {
>  	dma_addr_t addr;
>  
> -	addr = __raw_readl(d + DMA_DESC_ADDRESS_LO);
> +	addr = bcmgenet_readl(d + DMA_DESC_ADDRESS_LO);
>  
>  	/* Register writes to GISB bus can take couple hundred nanoseconds
>  	 * and are done for each packet, save these expensive writes unless
> @@ -121,7 +140,7 @@ static inline dma_addr_t dmadesc_get_addr(struct bcmgenet_priv *priv,
>  	 */
>  #ifdef CONFIG_PHYS_ADDR_T_64BIT
>  	if (priv->hw_params->flags & GENET_HAS_40BITS)
> -		addr |= (u64)__raw_readl(d + DMA_DESC_ADDRESS_HI) << 32;
> +		addr |= (u64)bcmgenet_readl(d + DMA_DESC_ADDRESS_HI) << 32;
>  #endif
>  	return addr;
>  }
> @@ -156,8 +175,8 @@ static inline u32 bcmgenet_tbuf_ctrl_get(struct bcmgenet_priv *priv)
>  	if (GENET_IS_V1(priv))
>  		return bcmgenet_rbuf_readl(priv, TBUF_CTRL_V1);
>  	else
> -		return __raw_readl(priv->base +
> -				priv->hw_params->tbuf_offset + TBUF_CTRL);
> +		return bcmgenet_readl(priv->base +
> +				      priv->hw_params->tbuf_offset + TBUF_CTRL);
>  }
>  
>  static inline void bcmgenet_tbuf_ctrl_set(struct bcmgenet_priv *priv, u32 val)
> @@ -165,7 +184,7 @@ static inline void bcmgenet_tbuf_ctrl_set(struct bcmgenet_priv *priv, u32 val)
>  	if (GENET_IS_V1(priv))
>  		bcmgenet_rbuf_writel(priv, val, TBUF_CTRL_V1);
>  	else
> -		__raw_writel(val, priv->base +
> +		bcmgenet_writel(val, priv->base +
>  				priv->hw_params->tbuf_offset + TBUF_CTRL);
>  }
>  
> @@ -174,8 +193,8 @@ static inline u32 bcmgenet_bp_mc_get(struct bcmgenet_priv *priv)
>  	if (GENET_IS_V1(priv))
>  		return bcmgenet_rbuf_readl(priv, TBUF_BP_MC_V1);
>  	else
> -		return __raw_readl(priv->base +
> -				priv->hw_params->tbuf_offset + TBUF_BP_MC);
> +		return bcmgenet_readl(priv->base +
> +				      priv->hw_params->tbuf_offset + TBUF_BP_MC);
>  }
>  
>  static inline void bcmgenet_bp_mc_set(struct bcmgenet_priv *priv, u32 val)
> @@ -183,7 +202,7 @@ static inline void bcmgenet_bp_mc_set(struct bcmgenet_priv *priv, u32 val)
>  	if (GENET_IS_V1(priv))
>  		bcmgenet_rbuf_writel(priv, val, TBUF_BP_MC_V1);
>  	else
> -		__raw_writel(val, priv->base +
> +		bcmgenet_writel(val, priv->base +
>  				priv->hw_params->tbuf_offset + TBUF_BP_MC);
>  }
>  
> @@ -326,28 +345,28 @@ static inline struct bcmgenet_priv *dev_to_priv(struct device *dev)
>  static inline u32 bcmgenet_tdma_readl(struct bcmgenet_priv *priv,
>  				      enum dma_reg r)
>  {
> -	return __raw_readl(priv->base + GENET_TDMA_REG_OFF +
> -			DMA_RINGS_SIZE + bcmgenet_dma_regs[r]);
> +	return bcmgenet_readl(priv->base + GENET_TDMA_REG_OFF +
> +			      DMA_RINGS_SIZE + bcmgenet_dma_regs[r]);
>  }
>  
>  static inline void bcmgenet_tdma_writel(struct bcmgenet_priv *priv,
>  					u32 val, enum dma_reg r)
>  {
> -	__raw_writel(val, priv->base + GENET_TDMA_REG_OFF +
> +	bcmgenet_writel(val, priv->base + GENET_TDMA_REG_OFF +
>  			DMA_RINGS_SIZE + bcmgenet_dma_regs[r]);
>  }
>  
>  static inline u32 bcmgenet_rdma_readl(struct bcmgenet_priv *priv,
>  				      enum dma_reg r)
>  {
> -	return __raw_readl(priv->base + GENET_RDMA_REG_OFF +
> -			DMA_RINGS_SIZE + bcmgenet_dma_regs[r]);
> +	return bcmgenet_readl(priv->base + GENET_RDMA_REG_OFF +
> +			      DMA_RINGS_SIZE + bcmgenet_dma_regs[r]);
>  }
>  
>  static inline void bcmgenet_rdma_writel(struct bcmgenet_priv *priv,
>  					u32 val, enum dma_reg r)
>  {
> -	__raw_writel(val, priv->base + GENET_RDMA_REG_OFF +
> +	bcmgenet_writel(val, priv->base + GENET_RDMA_REG_OFF +
>  			DMA_RINGS_SIZE + bcmgenet_dma_regs[r]);
>  }
>  
> @@ -418,16 +437,16 @@ static inline u32 bcmgenet_tdma_ring_readl(struct bcmgenet_priv *priv,
>  					   unsigned int ring,
>  					   enum dma_ring_reg r)
>  {
> -	return __raw_readl(priv->base + GENET_TDMA_REG_OFF +
> -			(DMA_RING_SIZE * ring) +
> -			genet_dma_ring_regs[r]);
> +	return bcmgenet_readl(priv->base + GENET_TDMA_REG_OFF +
> +			      (DMA_RING_SIZE * ring) +
> +			      genet_dma_ring_regs[r]);
>  }
>  
>  static inline void bcmgenet_tdma_ring_writel(struct bcmgenet_priv *priv,
>  					     unsigned int ring, u32 val,
>  					     enum dma_ring_reg r)
>  {
> -	__raw_writel(val, priv->base + GENET_TDMA_REG_OFF +
> +	bcmgenet_writel(val, priv->base + GENET_TDMA_REG_OFF +
>  			(DMA_RING_SIZE * ring) +
>  			genet_dma_ring_regs[r]);
>  }
> @@ -436,16 +455,16 @@ static inline u32 bcmgenet_rdma_ring_readl(struct bcmgenet_priv *priv,
>  					   unsigned int ring,
>  					   enum dma_ring_reg r)
>  {
> -	return __raw_readl(priv->base + GENET_RDMA_REG_OFF +
> -			(DMA_RING_SIZE * ring) +
> -			genet_dma_ring_regs[r]);
> +	return bcmgenet_readl(priv->base + GENET_RDMA_REG_OFF +
> +			      (DMA_RING_SIZE * ring) +
> +			      genet_dma_ring_regs[r]);
>  }
>  
>  static inline void bcmgenet_rdma_ring_writel(struct bcmgenet_priv *priv,
>  					     unsigned int ring, u32 val,
>  					     enum dma_ring_reg r)
>  {
> -	__raw_writel(val, priv->base + GENET_RDMA_REG_OFF +
> +	bcmgenet_writel(val, priv->base + GENET_RDMA_REG_OFF +
>  			(DMA_RING_SIZE * ring) +
>  			genet_dma_ring_regs[r]);
>  }
> @@ -991,12 +1010,12 @@ static void bcmgenet_eee_enable_set(struct net_device *dev, bool enable)
>  	bcmgenet_umac_writel(priv, reg, UMAC_EEE_CTRL);
>  
>  	/* Enable EEE and switch to a 27Mhz clock automatically */
> -	reg = __raw_readl(priv->base + off);
> +	reg = bcmgenet_readl(priv->base + off);
>  	if (enable)
>  		reg |= TBUF_EEE_EN | TBUF_PM_EN;
>  	else
>  		reg &= ~(TBUF_EEE_EN | TBUF_PM_EN);
> -	__raw_writel(reg, priv->base + off);
> +	bcmgenet_writel(reg, priv->base + off);
>  
>  	/* Do the same for thing for RBUF */
>  	reg = bcmgenet_rbuf_readl(priv, RBUF_ENERGY_CTRL);
> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
> index 3a34fdba5301..4b31e6c172b6 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
> @@ -671,12 +671,21 @@ struct bcmgenet_priv {
>  static inline u32 bcmgenet_##name##_readl(struct bcmgenet_priv *priv,	\
>  					u32 off)			\
>  {									\
> -	return __raw_readl(priv->base + offset + off);			\
> +	/* MIPS chips strapped for BE will automagically configure the	\
> +	 * peripheral registers for CPU-native byte order.		\
> +	 */								\
> +	if (IS_ENABLED(CONFIG_MIPS) && IS_ENABLED(CONFIG_CPU_BIG_ENDIAN)) \
> +		return __raw_readl(priv->base + offset + off);		\
> +	else								\
> +		return readl_relaxed(priv->base + offset + off);	\
>  }									\
>  static inline void bcmgenet_##name##_writel(struct bcmgenet_priv *priv,	\
>  					u32 val, u32 off)		\
>  {									\
> -	__raw_writel(val, priv->base + offset + off);			\
> +	if (IS_ENABLED(CONFIG_MIPS) && IS_ENABLED(CONFIG_CPU_BIG_ENDIAN)) \
> +		return __raw_writel(val, priv->base + offset + off);	\
> +	else								\
> +		writel_relaxed(val, priv->base + offset + off);		\
>  }
>  
>  GENET_IO_MACRO(ext, GENET_EXT_OFF);
> 


-- 
Florian
