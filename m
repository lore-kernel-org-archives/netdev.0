From: Niklas Cassel <niklas.cassel@axis.com>
Subject: Re: [PATCH 3/4 v3 net-next] net: stmmac: adding multiple buffers for
 TX
Date: Thu, 6 Apr 2017 11:08:01 +0200
Message-ID: <1317e319-e602-43b7-886a-c9a2b4852fc4@axis.com>
References: <cover.1491467980.git.jpinto@synopsys.com>
 <75f554a1f54dc27acfec54645a6b111cf3fd4e76.1491467980.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Joao Pinto <Joao.Pinto@synopsys.com>, <davem@davemloft.net>,
        <clabbe.montjoie@gmail.com>, <treding@nvidia.com>,
        <julia.lawall@lip6.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bes.se.axis.com ([195.60.68.10]:44485 "EHLO bes.se.axis.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755413AbdDFJIO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Apr 2017 05:08:14 -0400
In-Reply-To: <75f554a1f54dc27acfec54645a6b111cf3fd4e76.1491467980.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Survived 10/10 reboot + ping test

Tested-by: Niklas Cassel <niklas.cassel@axis.com>

On 04/06/2017 10:49 AM, Joao Pinto wrote:
> This patch adds the structure stmmac_tx_queue which contains
> tx queues specific data (previously in stmmac_priv).
> 
> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
> ---
> changes v1->v3:
> - just to keep up with patch-set version
> 
>  drivers/net/ethernet/stmicro/stmmac/chain_mode.c  |  38 +-
>  drivers/net/ethernet/stmicro/stmmac/ring_mode.c   |  46 +-
>  drivers/net/ethernet/stmicro/stmmac/stmmac.h      |  26 +-
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 519 +++++++++++++---------
>  4 files changed, 374 insertions(+), 255 deletions(-)
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
> index 8db5a80..37881f8 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
> @@ -26,12 +26,15 @@
>  
>  static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
>  {
> -	struct stmmac_priv *priv = (struct stmmac_priv *)p;
> -	unsigned int entry = priv->cur_tx;
> -	struct dma_desc *desc = priv->dma_tx + entry;
> +	struct stmmac_tx_queue *tx_q = (struct stmmac_tx_queue *)p;
>  	unsigned int nopaged_len = skb_headlen(skb);
> +	struct stmmac_priv *priv = tx_q->priv_data;
> +	unsigned int entry = tx_q->cur_tx;
>  	unsigned int bmax, des2;
>  	unsigned int i = 1, len;
> +	struct dma_desc *desc;
> +
> +	desc = tx_q->dma_tx + entry;
>  
>  	if (priv->plat->enh_desc)
>  		bmax = BUF_SIZE_8KiB;
> @@ -45,16 +48,16 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
>  	desc->des2 = cpu_to_le32(des2);
>  	if (dma_mapping_error(priv->device, des2))
>  		return -1;
> -	priv->tx_skbuff_dma[entry].buf = des2;
> -	priv->tx_skbuff_dma[entry].len = bmax;
> +	tx_q->tx_skbuff_dma[entry].buf = des2;
> +	tx_q->tx_skbuff_dma[entry].len = bmax;
>  	/* do not close the descriptor and do not set own bit */
>  	priv->hw->desc->prepare_tx_desc(desc, 1, bmax, csum, STMMAC_CHAIN_MODE,
>  					0, false);
>  
>  	while (len != 0) {
> -		priv->tx_skbuff[entry] = NULL;
> +		tx_q->tx_skbuff[entry] = NULL;
>  		entry = STMMAC_GET_ENTRY(entry, DMA_TX_SIZE);
> -		desc = priv->dma_tx + entry;
> +		desc = tx_q->dma_tx + entry;
>  
>  		if (len > bmax) {
>  			des2 = dma_map_single(priv->device,
> @@ -63,8 +66,8 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
>  			desc->des2 = cpu_to_le32(des2);
>  			if (dma_mapping_error(priv->device, des2))
>  				return -1;
> -			priv->tx_skbuff_dma[entry].buf = des2;
> -			priv->tx_skbuff_dma[entry].len = bmax;
> +			tx_q->tx_skbuff_dma[entry].buf = des2;
> +			tx_q->tx_skbuff_dma[entry].len = bmax;
>  			priv->hw->desc->prepare_tx_desc(desc, 0, bmax, csum,
>  							STMMAC_CHAIN_MODE, 1,
>  							false);
> @@ -77,8 +80,8 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
>  			desc->des2 = cpu_to_le32(des2);
>  			if (dma_mapping_error(priv->device, des2))
>  				return -1;
> -			priv->tx_skbuff_dma[entry].buf = des2;
> -			priv->tx_skbuff_dma[entry].len = len;
> +			tx_q->tx_skbuff_dma[entry].buf = des2;
> +			tx_q->tx_skbuff_dma[entry].len = len;
>  			/* last descriptor can be set now */
>  			priv->hw->desc->prepare_tx_desc(desc, 0, len, csum,
>  							STMMAC_CHAIN_MODE, 1,
> @@ -87,7 +90,7 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
>  		}
>  	}
>  
> -	priv->cur_tx = entry;
> +	tx_q->cur_tx = entry;
>  
>  	return entry;
>  }
> @@ -152,17 +155,18 @@ static void stmmac_refill_desc3(void *priv_ptr, struct dma_desc *p)
>  
>  static void stmmac_clean_desc3(void *priv_ptr, struct dma_desc *p)
>  {
> -	struct stmmac_priv *priv = (struct stmmac_priv *)priv_ptr;
> -	unsigned int entry = priv->dirty_tx;
> +	struct stmmac_tx_queue *tx_q = (struct stmmac_tx_queue *)priv_ptr;
> +	struct stmmac_priv *priv = tx_q->priv_data;
> +	unsigned int entry = tx_q->dirty_tx;
>  
> -	if (priv->tx_skbuff_dma[entry].last_segment && !priv->extend_desc &&
> +	if (tx_q->tx_skbuff_dma[entry].last_segment && !priv->extend_desc &&
>  	    priv->hwts_tx_en)
>  		/* NOTE: Device will overwrite des3 with timestamp value if
>  		 * 1588-2002 time stamping is enabled, hence reinitialize it
>  		 * to keep explicit chaining in the descriptor.
>  		 */
> -		p->des3 = cpu_to_le32((unsigned int)((priv->dma_tx_phy +
> -				      ((priv->dirty_tx + 1) % DMA_TX_SIZE))
> +		p->des3 = cpu_to_le32((unsigned int)((tx_q->dma_tx_phy +
> +				      ((tx_q->dirty_tx + 1) % DMA_TX_SIZE))
>  				      * sizeof(struct dma_desc)));
>  }
>  
> diff --git a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
> index 452f256..31213e6 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
> @@ -26,16 +26,17 @@
>  
>  static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
>  {
> -	struct stmmac_priv *priv = (struct stmmac_priv *)p;
> -	unsigned int entry = priv->cur_tx;
> -	struct dma_desc *desc;
> +	struct stmmac_tx_queue *tx_q = (struct stmmac_tx_queue *)p;
>  	unsigned int nopaged_len = skb_headlen(skb);
> +	struct stmmac_priv *priv = tx_q->priv_data;
> +	unsigned int entry = tx_q->cur_tx;
>  	unsigned int bmax, len, des2;
> +	struct dma_desc *desc;
>  
>  	if (priv->extend_desc)
> -		desc = (struct dma_desc *)(priv->dma_etx + entry);
> +		desc = (struct dma_desc *)(tx_q->dma_etx + entry);
>  	else
> -		desc = priv->dma_tx + entry;
> +		desc = tx_q->dma_tx + entry;
>  
>  	if (priv->plat->enh_desc)
>  		bmax = BUF_SIZE_8KiB;
> @@ -52,29 +53,29 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
>  		if (dma_mapping_error(priv->device, des2))
>  			return -1;
>  
> -		priv->tx_skbuff_dma[entry].buf = des2;
> -		priv->tx_skbuff_dma[entry].len = bmax;
> -		priv->tx_skbuff_dma[entry].is_jumbo = true;
> +		tx_q->tx_skbuff_dma[entry].buf = des2;
> +		tx_q->tx_skbuff_dma[entry].len = bmax;
> +		tx_q->tx_skbuff_dma[entry].is_jumbo = true;
>  
>  		desc->des3 = cpu_to_le32(des2 + BUF_SIZE_4KiB);
>  		priv->hw->desc->prepare_tx_desc(desc, 1, bmax, csum,
>  						STMMAC_RING_MODE, 0, false);
> -		priv->tx_skbuff[entry] = NULL;
> +		tx_q->tx_skbuff[entry] = NULL;
>  		entry = STMMAC_GET_ENTRY(entry, DMA_TX_SIZE);
>  
>  		if (priv->extend_desc)
> -			desc = (struct dma_desc *)(priv->dma_etx + entry);
> +			desc = (struct dma_desc *)(tx_q->dma_etx + entry);
>  		else
> -			desc = priv->dma_tx + entry;
> +			desc = tx_q->dma_tx + entry;
>  
>  		des2 = dma_map_single(priv->device, skb->data + bmax, len,
>  				      DMA_TO_DEVICE);
>  		desc->des2 = cpu_to_le32(des2);
>  		if (dma_mapping_error(priv->device, des2))
>  			return -1;
> -		priv->tx_skbuff_dma[entry].buf = des2;
> -		priv->tx_skbuff_dma[entry].len = len;
> -		priv->tx_skbuff_dma[entry].is_jumbo = true;
> +		tx_q->tx_skbuff_dma[entry].buf = des2;
> +		tx_q->tx_skbuff_dma[entry].len = len;
> +		tx_q->tx_skbuff_dma[entry].is_jumbo = true;
>  
>  		desc->des3 = cpu_to_le32(des2 + BUF_SIZE_4KiB);
>  		priv->hw->desc->prepare_tx_desc(desc, 0, len, csum,
> @@ -85,15 +86,15 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
>  		desc->des2 = cpu_to_le32(des2);
>  		if (dma_mapping_error(priv->device, des2))
>  			return -1;
> -		priv->tx_skbuff_dma[entry].buf = des2;
> -		priv->tx_skbuff_dma[entry].len = nopaged_len;
> -		priv->tx_skbuff_dma[entry].is_jumbo = true;
> +		tx_q->tx_skbuff_dma[entry].buf = des2;
> +		tx_q->tx_skbuff_dma[entry].len = nopaged_len;
> +		tx_q->tx_skbuff_dma[entry].is_jumbo = true;
>  		desc->des3 = cpu_to_le32(des2 + BUF_SIZE_4KiB);
>  		priv->hw->desc->prepare_tx_desc(desc, 1, nopaged_len, csum,
>  						STMMAC_RING_MODE, 0, true);
>  	}
>  
> -	priv->cur_tx = entry;
> +	tx_q->cur_tx = entry;
>  
>  	return entry;
>  }
> @@ -125,12 +126,13 @@ static void stmmac_init_desc3(struct dma_desc *p)
>  
>  static void stmmac_clean_desc3(void *priv_ptr, struct dma_desc *p)
>  {
> -	struct stmmac_priv *priv = (struct stmmac_priv *)priv_ptr;
> -	unsigned int entry = priv->dirty_tx;
> +	struct stmmac_tx_queue *tx_q = (struct stmmac_tx_queue *)priv_ptr;
> +	struct stmmac_priv *priv = tx_q->priv_data;
> +	unsigned int entry = tx_q->dirty_tx;
>  
>  	/* des3 is only used for jumbo frames tx or time stamping */
> -	if (unlikely(priv->tx_skbuff_dma[entry].is_jumbo ||
> -		     (priv->tx_skbuff_dma[entry].last_segment &&
> +	if (unlikely(tx_q->tx_skbuff_dma[entry].is_jumbo ||
> +		     (tx_q->tx_skbuff_dma[entry].last_segment &&
>  		      !priv->extend_desc && priv->hwts_tx_en)))
>  		p->des3 = 0;
>  }
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
> index c7ad9e4..359f8fd 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
> @@ -46,6 +46,20 @@ struct stmmac_tx_info {
>  	bool is_jumbo;
>  };
>  
> +/* Frequently used values are kept adjacent for cache effect */
> +struct stmmac_tx_queue {
> +	u32 queue_index;
> +	struct stmmac_priv *priv_data;
> +	struct dma_extended_desc *dma_etx ____cacheline_aligned_in_smp;
> +	struct dma_desc *dma_tx;
> +	struct sk_buff **tx_skbuff;
> +	struct stmmac_tx_info *tx_skbuff_dma;
> +	unsigned int cur_tx;
> +	unsigned int dirty_tx;
> +	dma_addr_t dma_tx_phy;
> +	u32 tx_tail_addr;
> +};
> +
>  struct stmmac_rx_queue {
>  	u32 queue_index;
>  	struct stmmac_priv *priv_data;
> @@ -62,16 +76,10 @@ struct stmmac_rx_queue {
>  
>  struct stmmac_priv {
>  	/* Frequently used values are kept adjacent for cache effect */
> -	struct dma_extended_desc *dma_etx ____cacheline_aligned_in_smp;
> -	struct dma_desc *dma_tx;
> -	struct sk_buff **tx_skbuff;
> -	unsigned int cur_tx;
> -	unsigned int dirty_tx;
>  	u32 tx_count_frames;
>  	u32 tx_coal_frames;
>  	u32 tx_coal_timer;
> -	struct stmmac_tx_info *tx_skbuff_dma;
> -	dma_addr_t dma_tx_phy;
> +
>  	int tx_coalesce;
>  	int hwts_tx_en;
>  	bool tx_path_in_lpi_mode;
> @@ -94,6 +102,9 @@ struct stmmac_priv {
>  	/* RX Queue */
>  	struct stmmac_rx_queue rx_queue[MTL_MAX_RX_QUEUES];
>  
> +	/* TX Queue */
> +	struct stmmac_tx_queue tx_queue[MTL_MAX_TX_QUEUES];
> +
>  	int oldlink;
>  	int speed;
>  	int oldduplex;
> @@ -128,7 +139,6 @@ struct stmmac_priv {
>  	spinlock_t ptp_lock;
>  	void __iomem *mmcaddr;
>  	void __iomem *ptpaddr;
> -	u32 tx_tail_addr;
>  	u32 mss;
>  
>  #ifdef CONFIG_DEBUG_FS
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 77caba4..56a081f 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -185,14 +185,15 @@ static void print_pkt(unsigned char *buf, int len)
>  	print_hex_dump_bytes("", DUMP_PREFIX_OFFSET, buf, len);
>  }
>  
> -static inline u32 stmmac_tx_avail(struct stmmac_priv *priv)
> +static inline u32 stmmac_tx_avail(struct stmmac_priv *priv, u32 queue)
>  {
> +	struct stmmac_tx_queue *tx_q = &priv->tx_queue[queue];
>  	u32 avail;
>  
> -	if (priv->dirty_tx > priv->cur_tx)
> -		avail = priv->dirty_tx - priv->cur_tx - 1;
> +	if (tx_q->dirty_tx > tx_q->cur_tx)
> +		avail = tx_q->dirty_tx - tx_q->cur_tx - 1;
>  	else
> -		avail = DMA_TX_SIZE - priv->cur_tx + priv->dirty_tx - 1;
> +		avail = DMA_TX_SIZE - tx_q->cur_tx + tx_q->dirty_tx - 1;
>  
>  	return avail;
>  }
> @@ -238,9 +239,19 @@ static inline void stmmac_hw_fix_mac_speed(struct stmmac_priv *priv)
>   */
>  static void stmmac_enable_eee_mode(struct stmmac_priv *priv)
>  {
> +	u32 tx_cnt = priv->plat->tx_queues_to_use;
> +	u32 queue;
> +
> +	/* check if all TX queues have the work finished */
> +	for (queue = 0; queue < tx_cnt; queue++) {
> +		struct stmmac_tx_queue *tx_q = &priv->tx_queue[queue];
> +
> +		if (tx_q->dirty_tx != tx_q->cur_tx)
> +			return; /* still unfinished work */
> +	}
> +
>  	/* Check and enter in LPI mode */
> -	if ((priv->dirty_tx == priv->cur_tx) &&
> -	    (priv->tx_path_in_lpi_mode == false))
> +	if (!priv->tx_path_in_lpi_mode)
>  		priv->hw->mac->set_eee_mode(priv->hw,
>  					    priv->plat->en_tx_lpi_clockgating);
>  }
> @@ -919,15 +930,23 @@ static void stmmac_display_rx_rings(struct stmmac_priv *priv)
>  
>  static void stmmac_display_tx_rings(struct stmmac_priv *priv)
>  {
> +	u32 tx_cnt = priv->plat->tx_queues_to_use;
>  	void *head_tx;
> +	u32 queue;
>  
> -	if (priv->extend_desc)
> -		head_tx = (void *)priv->dma_etx;
> -	else
> -		head_tx = (void *)priv->dma_tx;
> +	/* Display TX rings */
> +	for (queue = 0; queue < tx_cnt; queue++) {
> +		struct stmmac_tx_queue *tx_q = &priv->tx_queue[queue];
>  
> -	/* Display TX ring */
> -	priv->hw->desc->display_ring(head_tx, DMA_TX_SIZE, false);
> +		pr_info("\tTX Queue %d rings\n", queue);
> +
> +		if (priv->extend_desc)
> +			head_tx = (void *)tx_q->dma_etx;
> +		else
> +			head_tx = (void *)tx_q->dma_tx;
> +
> +		priv->hw->desc->display_ring(head_tx, DMA_TX_SIZE, false);
> +	}
>  }
>  
>  static void stmmac_display_rings(struct stmmac_priv *priv)
> @@ -982,21 +1001,23 @@ static void stmmac_clear_rx_descriptors(struct stmmac_priv *priv, u32 queue)
>  /**
>   * stmmac_clear_tx_descriptors - clear tx descriptors
>   * @priv: driver private structure
> + * @queue: TX queue index.
>   * Description: this function is called to clear the TX descriptors
>   * in case of both basic and extended descriptors are used.
>   */
> -static void stmmac_clear_tx_descriptors(struct stmmac_priv *priv)
> +static void stmmac_clear_tx_descriptors(struct stmmac_priv *priv, u32 queue)
>  {
> +	struct stmmac_tx_queue *tx_q = &priv->tx_queue[queue];
>  	int i;
>  
>  	/* Clear the TX descriptors */
>  	for (i = 0; i < DMA_TX_SIZE; i++)
>  		if (priv->extend_desc)
> -			priv->hw->desc->init_tx_desc(&priv->dma_etx[i].basic,
> +			priv->hw->desc->init_tx_desc(&tx_q->dma_etx[i].basic,
>  						     priv->mode,
>  						     (i == DMA_TX_SIZE - 1));
>  		else
> -			priv->hw->desc->init_tx_desc(&priv->dma_tx[i],
> +			priv->hw->desc->init_tx_desc(&tx_q->dma_tx[i],
>  						     priv->mode,
>  						     (i == DMA_TX_SIZE - 1));
>  }
> @@ -1010,6 +1031,7 @@ static void stmmac_clear_tx_descriptors(struct stmmac_priv *priv)
>  static void stmmac_clear_descriptors(struct stmmac_priv *priv)
>  {
>  	u32 rx_queue_cnt = priv->plat->rx_queues_to_use;
> +	u32 tx_queue_cnt = priv->plat->tx_queues_to_use;
>  	u32 queue;
>  
>  	/* Clear the RX descriptors */
> @@ -1017,7 +1039,8 @@ static void stmmac_clear_descriptors(struct stmmac_priv *priv)
>  		stmmac_clear_rx_descriptors(priv, queue);
>  
>  	/* Clear the TX descriptors */
> -	stmmac_clear_tx_descriptors(priv);
> +	for (queue = 0; queue < tx_queue_cnt; queue++)
> +		stmmac_clear_tx_descriptors(priv, queue);
>  }
>  
>  /**
> @@ -1085,28 +1108,31 @@ static void stmmac_free_rx_buffer(struct stmmac_priv *priv, u32 queue, int i)
>  /**
>   * stmmac_free_tx_buffer - free RX dma buffers
>   * @priv: private structure
> + * @queue: RX queue index
>   * @i: buffer index.
>   */
> -static void stmmac_free_tx_buffer(struct stmmac_priv *priv, int i)
> +static void stmmac_free_tx_buffer(struct stmmac_priv *priv, u32 queue, int i)
>  {
> -	if (priv->tx_skbuff_dma[i].buf) {
> -		if (priv->tx_skbuff_dma[i].map_as_page)
> +	struct stmmac_tx_queue *tx_q = &priv->tx_queue[queue];
> +
> +	if (tx_q->tx_skbuff_dma[i].buf) {
> +		if (tx_q->tx_skbuff_dma[i].map_as_page)
>  			dma_unmap_page(priv->device,
> -				       priv->tx_skbuff_dma[i].buf,
> -				       priv->tx_skbuff_dma[i].len,
> +				       tx_q->tx_skbuff_dma[i].buf,
> +				       tx_q->tx_skbuff_dma[i].len,
>  				       DMA_TO_DEVICE);
>  		else
>  			dma_unmap_single(priv->device,
> -					 priv->tx_skbuff_dma[i].buf,
> -					 priv->tx_skbuff_dma[i].len,
> +					 tx_q->tx_skbuff_dma[i].buf,
> +					 tx_q->tx_skbuff_dma[i].len,
>  					 DMA_TO_DEVICE);
>  	}
>  
> -	if (priv->tx_skbuff[i]) {
> -		dev_kfree_skb_any(priv->tx_skbuff[i]);
> -		priv->tx_skbuff[i] = NULL;
> -		priv->tx_skbuff_dma[i].buf = 0;
> -		priv->tx_skbuff_dma[i].map_as_page = false;
> +	if (tx_q->tx_skbuff[i]) {
> +		dev_kfree_skb_any(tx_q->tx_skbuff[i]);
> +		tx_q->tx_skbuff[i] = NULL;
> +		tx_q->tx_skbuff_dma[i].buf = 0;
> +		tx_q->tx_skbuff_dma[i].map_as_page = false;
>  	}
>  }
>  
> @@ -1211,46 +1237,57 @@ static int init_dma_rx_desc_rings(struct net_device *dev, gfp_t flags)
>  static int init_dma_tx_desc_rings(struct net_device *dev)
>  {
>  	struct stmmac_priv *priv = netdev_priv(dev);
> +	u32 tx_queue_cnt = priv->plat->tx_queues_to_use;
> +	u32 queue;
>  	int i;
>  
> -	netif_dbg(priv, probe, priv->dev,
> -		  "(%s) dma_tx_phy=0x%08x\n", __func__, (u32)priv->dma_tx_phy);
> +	for (queue = 0; queue < tx_queue_cnt; queue++) {
> +		struct stmmac_tx_queue *tx_q = &priv->tx_queue[queue];
>  
> -	/* Setup the chained descriptor addresses */
> -	if (priv->mode == STMMAC_CHAIN_MODE) {
> -		if (priv->extend_desc)
> -			priv->hw->mode->init(priv->dma_etx, priv->dma_tx_phy,
> -					     DMA_TX_SIZE, 1);
> -		else
> -			priv->hw->mode->init(priv->dma_tx, priv->dma_tx_phy,
> -					     DMA_TX_SIZE, 0);
> -	}
> +		netif_dbg(priv, probe, priv->dev,
> +			  "(%s) dma_tx_phy=0x%08x\n", __func__,
> +			 (u32)tx_q->dma_tx_phy);
>  
> -	for (i = 0; i < DMA_TX_SIZE; i++) {
> -		struct dma_desc *p;
> -		if (priv->extend_desc)
> -			p = &((priv->dma_etx + i)->basic);
> -		else
> -			p = priv->dma_tx + i;
> +		/* Setup the chained descriptor addresses */
> +		if (priv->mode == STMMAC_CHAIN_MODE) {
> +			if (priv->extend_desc)
> +				priv->hw->mode->init(tx_q->dma_etx,
> +						     tx_q->dma_tx_phy,
> +						     DMA_TX_SIZE, 1);
> +			else
> +				priv->hw->mode->init(tx_q->dma_tx,
> +						     tx_q->dma_tx_phy,
> +						     DMA_TX_SIZE, 0);
> +		}
>  
> -		if (priv->synopsys_id >= DWMAC_CORE_4_00) {
> -			p->des0 = 0;
> -			p->des1 = 0;
> -			p->des2 = 0;
> -			p->des3 = 0;
> -		} else {
> -			p->des2 = 0;
> +		for (i = 0; i < DMA_TX_SIZE; i++) {
> +			struct dma_desc *p;
> +
> +			if (priv->extend_desc)
> +				p = &((tx_q->dma_etx + i)->basic);
> +			else
> +				p = tx_q->dma_tx + i;
> +
> +			if (priv->synopsys_id >= DWMAC_CORE_4_00) {
> +				p->des0 = 0;
> +				p->des1 = 0;
> +				p->des2 = 0;
> +				p->des3 = 0;
> +			} else {
> +				p->des2 = 0;
> +			}
> +
> +			tx_q->tx_skbuff_dma[i].buf = 0;
> +			tx_q->tx_skbuff_dma[i].map_as_page = false;
> +			tx_q->tx_skbuff_dma[i].len = 0;
> +			tx_q->tx_skbuff_dma[i].last_segment = false;
> +			tx_q->tx_skbuff[i] = NULL;
>  		}
>  
> -		priv->tx_skbuff_dma[i].buf = 0;
> -		priv->tx_skbuff_dma[i].map_as_page = false;
> -		priv->tx_skbuff_dma[i].len = 0;
> -		priv->tx_skbuff_dma[i].last_segment = false;
> -		priv->tx_skbuff[i] = NULL;
> +		tx_q->dirty_tx = 0;
> +		tx_q->cur_tx = 0;
>  	}
>  
> -	priv->dirty_tx = 0;
> -	priv->cur_tx = 0;
>  	netdev_reset_queue(priv->dev);
>  
>  	return 0;
> @@ -1299,13 +1336,14 @@ static void dma_free_rx_skbufs(struct stmmac_priv *priv, u32 queue)
>  /**
>   * dma_free_tx_skbufs - free TX dma buffers
>   * @priv: private structure
> + * @queue: TX queue index
>   */
> -static void dma_free_tx_skbufs(struct stmmac_priv *priv)
> +static void dma_free_tx_skbufs(struct stmmac_priv *priv, u32 queue)
>  {
>  	int i;
>  
>  	for (i = 0; i < DMA_TX_SIZE; i++)
> -		stmmac_free_tx_buffer(priv, i);
> +		stmmac_free_tx_buffer(priv, queue, i);
>  }
>  
>  /**
> @@ -1340,6 +1378,37 @@ static void free_dma_rx_desc_resources(struct stmmac_priv *priv)
>  }
>  
>  /**
> + * free_dma_tx_desc_resources - free TX dma desc resources
> + * @priv: private structure
> + */
> +static void free_dma_tx_desc_resources(struct stmmac_priv *priv)
> +{
> +	u32 tx_count = priv->plat->tx_queues_to_use;
> +	u32 queue = 0;
> +
> +	/* Free TX queue resources */
> +	for (queue = 0; queue < tx_count; queue++) {
> +		struct stmmac_tx_queue *tx_q = &priv->tx_queue[queue];
> +
> +		/* Release the DMA TX socket buffers */
> +		dma_free_tx_skbufs(priv, queue);
> +
> +		/* Free DMA regions of consistent memory previously allocated */
> +		if (!priv->extend_desc)
> +			dma_free_coherent(priv->device,
> +					  DMA_TX_SIZE * sizeof(struct dma_desc),
> +					  tx_q->dma_tx, tx_q->dma_tx_phy);
> +		else
> +			dma_free_coherent(priv->device, DMA_TX_SIZE *
> +					  sizeof(struct dma_extended_desc),
> +					  tx_q->dma_etx, tx_q->dma_tx_phy);
> +
> +		kfree(tx_q->tx_skbuff_dma);
> +		kfree(tx_q->tx_skbuff);
> +	}
> +}
> +
> +/**
>   * alloc_dma_rx_desc_resources - alloc RX resources.
>   * @priv: private structure
>   * Description: according to which descriptor can be used (extend or basic)
> @@ -1412,42 +1481,55 @@ static int alloc_dma_rx_desc_resources(struct stmmac_priv *priv)
>   */
>  static int alloc_dma_tx_desc_resources(struct stmmac_priv *priv)
>  {
> +	u32 tx_count = priv->plat->tx_queues_to_use;
>  	int ret = -ENOMEM;
> +	u32 queue;
>  
> -	priv->tx_skbuff_dma = kmalloc_array(DMA_TX_SIZE,
> -					    sizeof(*priv->tx_skbuff_dma),
> -					    GFP_KERNEL);
> -	if (!priv->tx_skbuff_dma)
> -		return -ENOMEM;
> +	/* TX queues buffers and DMA */
> +	for (queue = 0; queue < tx_count; queue++) {
> +		struct stmmac_tx_queue *tx_q = &priv->tx_queue[queue];
>  
> -	priv->tx_skbuff = kmalloc_array(DMA_TX_SIZE, sizeof(struct sk_buff *),
> -					GFP_KERNEL);
> -	if (!priv->tx_skbuff)
> -		goto err_tx_skbuff;
> +		tx_q->queue_index = queue;
> +		tx_q->priv_data = priv;
>  
> -	if (priv->extend_desc) {
> -		priv->dma_etx = dma_zalloc_coherent(priv->device, DMA_TX_SIZE *
> -						    sizeof(struct
> -							   dma_extended_desc),
> -						    &priv->dma_tx_phy,
> +		tx_q->tx_skbuff_dma = kmalloc_array(DMA_TX_SIZE,
> +						    sizeof(*tx_q->tx_skbuff_dma),
>  						    GFP_KERNEL);
> -		if (!priv->dma_etx)
> -			goto err_dma;
> -	} else {
> -		priv->dma_tx = dma_zalloc_coherent(priv->device, DMA_TX_SIZE *
> -						   sizeof(struct dma_desc),
> -						   &priv->dma_tx_phy,
> -						   GFP_KERNEL);
> -		if (!priv->dma_tx)
> -			goto err_dma;
> +		if (!tx_q->tx_skbuff_dma)
> +			return -ENOMEM;
> +
> +		tx_q->tx_skbuff = kmalloc_array(DMA_TX_SIZE,
> +						sizeof(struct sk_buff *),
> +						GFP_KERNEL);
> +		if (!tx_q->tx_skbuff)
> +			goto err_dma_buffers;
> +
> +		if (priv->extend_desc) {
> +			tx_q->dma_etx = dma_zalloc_coherent(priv->device,
> +							    DMA_TX_SIZE *
> +							    sizeof(struct
> +							    dma_extended_desc),
> +							    &tx_q->dma_tx_phy,
> +							    GFP_KERNEL);
> +			if (!tx_q->dma_etx)
> +				goto err_dma_buffers;
> +		} else {
> +			tx_q->dma_tx = dma_zalloc_coherent(priv->device,
> +							   DMA_TX_SIZE *
> +							   sizeof(struct
> +								  dma_desc),
> +							   &tx_q->dma_tx_phy,
> +							   GFP_KERNEL);
> +			if (!tx_q->dma_tx)
> +				goto err_dma_buffers;
> +		}
>  	}
>  
>  	return 0;
>  
> -err_dma:
> -	kfree(priv->tx_skbuff);
> -err_tx_skbuff:
> -	kfree(priv->tx_skbuff_dma);
> +err_dma_buffers:
> +	free_dma_tx_desc_resources(priv);
> +
>  	return ret;
>  }
>  
> @@ -1473,29 +1555,6 @@ static int alloc_dma_desc_resources(struct stmmac_priv *priv)
>  }
>  
>  /**
> - * free_dma_tx_desc_resources - free TX dma desc resources
> - * @priv: private structure
> - */
> -static void free_dma_tx_desc_resources(struct stmmac_priv *priv)
> -{
> -	/* Release the DMA TX socket buffers */
> -	dma_free_tx_skbufs(priv);
> -
> -	/* Free DMA regions of consistent memory previously allocated */
> -	if (!priv->extend_desc)
> -		dma_free_coherent(priv->device,
> -				  DMA_TX_SIZE * sizeof(struct dma_desc),
> -				  priv->dma_tx, priv->dma_tx_phy);
> -	else
> -		dma_free_coherent(priv->device, DMA_TX_SIZE *
> -				  sizeof(struct dma_extended_desc),
> -				  priv->dma_etx, priv->dma_tx_phy);
> -
> -	kfree(priv->tx_skbuff_dma);
> -	kfree(priv->tx_skbuff);
> -}
> -
> -/**
>   * free_dma_desc_resources - free dma desc resources
>   * @priv: private structure
>   */
> @@ -1669,26 +1728,28 @@ static void stmmac_dma_operation_mode(struct stmmac_priv *priv)
>  /**
>   * stmmac_tx_clean - to manage the transmission completion
>   * @priv: driver private structure
> + * @queue: TX queue index
>   * Description: it reclaims the transmit resources after transmission completes.
>   */
> -static void stmmac_tx_clean(struct stmmac_priv *priv)
> +static void stmmac_tx_clean(struct stmmac_priv *priv, u32 queue)
>  {
> +	struct stmmac_tx_queue *tx_q = &priv->tx_queue[queue];
>  	unsigned int bytes_compl = 0, pkts_compl = 0;
> -	unsigned int entry = priv->dirty_tx;
> +	unsigned int entry = tx_q->dirty_tx;
>  
>  	netif_tx_lock(priv->dev);
>  
>  	priv->xstats.tx_clean++;
>  
> -	while (entry != priv->cur_tx) {
> -		struct sk_buff *skb = priv->tx_skbuff[entry];
> +	while (entry != tx_q->cur_tx) {
> +		struct sk_buff *skb = tx_q->tx_skbuff[entry];
>  		struct dma_desc *p;
>  		int status;
>  
>  		if (priv->extend_desc)
> -			p = (struct dma_desc *)(priv->dma_etx + entry);
> +			p = (struct dma_desc *)(tx_q->dma_etx + entry);
>  		else
> -			p = priv->dma_tx + entry;
> +			p = tx_q->dma_tx + entry;
>  
>  		status = priv->hw->desc->tx_status(&priv->dev->stats,
>  						      &priv->xstats, p,
> @@ -1709,45 +1770,45 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
>  			stmmac_get_tx_hwtstamp(priv, p, skb);
>  		}
>  
> -		if (likely(priv->tx_skbuff_dma[entry].buf)) {
> -			if (priv->tx_skbuff_dma[entry].map_as_page)
> +		if (likely(tx_q->tx_skbuff_dma[entry].buf)) {
> +			if (tx_q->tx_skbuff_dma[entry].map_as_page)
>  				dma_unmap_page(priv->device,
> -					       priv->tx_skbuff_dma[entry].buf,
> -					       priv->tx_skbuff_dma[entry].len,
> +					       tx_q->tx_skbuff_dma[entry].buf,
> +					       tx_q->tx_skbuff_dma[entry].len,
>  					       DMA_TO_DEVICE);
>  			else
>  				dma_unmap_single(priv->device,
> -						 priv->tx_skbuff_dma[entry].buf,
> -						 priv->tx_skbuff_dma[entry].len,
> +						 tx_q->tx_skbuff_dma[entry].buf,
> +						 tx_q->tx_skbuff_dma[entry].len,
>  						 DMA_TO_DEVICE);
> -			priv->tx_skbuff_dma[entry].buf = 0;
> -			priv->tx_skbuff_dma[entry].len = 0;
> -			priv->tx_skbuff_dma[entry].map_as_page = false;
> +			tx_q->tx_skbuff_dma[entry].buf = 0;
> +			tx_q->tx_skbuff_dma[entry].len = 0;
> +			tx_q->tx_skbuff_dma[entry].map_as_page = false;
>  		}
>  
>  		if (priv->hw->mode->clean_desc3)
> -			priv->hw->mode->clean_desc3(priv, p);
> +			priv->hw->mode->clean_desc3(tx_q, p);
>  
> -		priv->tx_skbuff_dma[entry].last_segment = false;
> -		priv->tx_skbuff_dma[entry].is_jumbo = false;
> +		tx_q->tx_skbuff_dma[entry].last_segment = false;
> +		tx_q->tx_skbuff_dma[entry].is_jumbo = false;
>  
>  		if (likely(skb != NULL)) {
>  			pkts_compl++;
>  			bytes_compl += skb->len;
>  			dev_consume_skb_any(skb);
> -			priv->tx_skbuff[entry] = NULL;
> +			tx_q->tx_skbuff[entry] = NULL;
>  		}
>  
>  		priv->hw->desc->release_tx_desc(p, priv->mode);
>  
>  		entry = STMMAC_GET_ENTRY(entry, DMA_TX_SIZE);
>  	}
> -	priv->dirty_tx = entry;
> +	tx_q->dirty_tx = entry;
>  
>  	netdev_completed_queue(priv->dev, pkts_compl, bytes_compl);
>  
>  	if (unlikely(netif_queue_stopped(priv->dev) &&
> -	    stmmac_tx_avail(priv) > STMMAC_TX_THRESH)) {
> +	    stmmac_tx_avail(priv, queue) > STMMAC_TX_THRESH)) {
>  		netif_dbg(priv, tx_done, priv->dev,
>  			  "%s: restart transmit\n", __func__);
>  		netif_wake_queue(priv->dev);
> @@ -1779,22 +1840,24 @@ static inline void stmmac_disable_dma_irq(struct stmmac_priv *priv, u32 chan)
>   */
>  static void stmmac_tx_err(struct stmmac_priv *priv, u32 chan)
>  {
> +	struct stmmac_tx_queue *tx_q = &priv->tx_queue[chan];
>  	int i;
> +
>  	netif_stop_queue(priv->dev);
>  
>  	stmmac_stop_tx_dma(priv, chan);
> -	dma_free_tx_skbufs(priv);
> +	dma_free_tx_skbufs(priv, chan);
>  	for (i = 0; i < DMA_TX_SIZE; i++)
>  		if (priv->extend_desc)
> -			priv->hw->desc->init_tx_desc(&priv->dma_etx[i].basic,
> +			priv->hw->desc->init_tx_desc(&tx_q->dma_etx[i].basic,
>  						     priv->mode,
>  						     (i == DMA_TX_SIZE - 1));
>  		else
> -			priv->hw->desc->init_tx_desc(&priv->dma_tx[i],
> +			priv->hw->desc->init_tx_desc(&tx_q->dma_tx[i],
>  						     priv->mode,
>  						     (i == DMA_TX_SIZE - 1));
> -	priv->dirty_tx = 0;
> -	priv->cur_tx = 0;
> +	tx_q->dirty_tx = 0;
> +	tx_q->cur_tx = 0;
>  	netdev_reset_queue(priv->dev);
>  	stmmac_start_tx_dma(priv, chan);
>  
> @@ -1983,6 +2046,7 @@ static int stmmac_init_dma_engine(struct stmmac_priv *priv)
>  	u32 rx_channels_count = priv->plat->rx_queues_to_use;
>  	u32 tx_channels_count = priv->plat->tx_queues_to_use;
>  	struct stmmac_rx_queue *rx_q;
> +	struct stmmac_tx_queue *tx_q;
>  	u32 dummy_dma_rx_phy = 0;
>  	u32 dummy_dma_tx_phy = 0;
>  	u32 chan = 0;
> @@ -2025,24 +2089,27 @@ static int stmmac_init_dma_engine(struct stmmac_priv *priv)
>  
>  		/* DMA TX Channel Configuration */
>  		for (chan = 0; chan < tx_channels_count; chan++) {
> +			tx_q = &priv->tx_queue[chan];
> +
>  			priv->hw->dma->init_chan(priv->ioaddr,
> -							priv->plat->dma_cfg,
> -							chan);
> +						 priv->plat->dma_cfg,
> +						 chan);
>  
>  			priv->hw->dma->init_tx_chan(priv->ioaddr,
>  						    priv->plat->dma_cfg,
> -						    priv->dma_tx_phy, chan);
> +						    tx_q->dma_tx_phy, chan);
>  
> -			priv->tx_tail_addr = priv->dma_tx_phy +
> +			tx_q->tx_tail_addr = tx_q->dma_tx_phy +
>  				    (DMA_TX_SIZE * sizeof(struct dma_desc));
>  			priv->hw->dma->set_tx_tail_ptr(priv->ioaddr,
> -						       priv->tx_tail_addr,
> +						       tx_q->tx_tail_addr,
>  						       chan);
>  		}
>  	} else {
>  		rx_q = &priv->rx_queue[chan];
> +		tx_q = &priv->tx_queue[chan];
>  		priv->hw->dma->init(priv->ioaddr, priv->plat->dma_cfg,
> -				    priv->dma_tx_phy, rx_q->dma_rx_phy, atds);
> +				    tx_q->dma_tx_phy, rx_q->dma_rx_phy, atds);
>  	}
>  
>  	if (priv->plat->axi && priv->hw->dma->axi)
> @@ -2060,8 +2127,12 @@ static int stmmac_init_dma_engine(struct stmmac_priv *priv)
>  static void stmmac_tx_timer(unsigned long data)
>  {
>  	struct stmmac_priv *priv = (struct stmmac_priv *)data;
> +	u32 tx_queues_count = priv->plat->tx_queues_to_use;
> +	u32 queue;
>  
> -	stmmac_tx_clean(priv);
> +	/* let's scan all the tx queues */
> +	for (queue = 0; queue < tx_queues_count; queue++)
> +		stmmac_tx_clean(priv, queue);
>  }
>  
>  /**
> @@ -2566,22 +2637,24 @@ static int stmmac_release(struct net_device *dev)
>   *  @des: buffer start address
>   *  @total_len: total length to fill in descriptors
>   *  @last_segmant: condition for the last descriptor
> + *  @queue: TX queue index
>   *  Description:
>   *  This function fills descriptor and request new descriptors according to
>   *  buffer length to fill
>   */
>  static void stmmac_tso_allocator(struct stmmac_priv *priv, unsigned int des,
> -				 int total_len, bool last_segment)
> +				 int total_len, bool last_segment, u32 queue)
>  {
> +	struct stmmac_tx_queue *tx_q = &priv->tx_queue[queue];
>  	struct dma_desc *desc;
> -	int tmp_len;
>  	u32 buff_size;
> +	int tmp_len;
>  
>  	tmp_len = total_len;
>  
>  	while (tmp_len > 0) {
> -		priv->cur_tx = STMMAC_GET_ENTRY(priv->cur_tx, DMA_TX_SIZE);
> -		desc = priv->dma_tx + priv->cur_tx;
> +		tx_q->cur_tx = STMMAC_GET_ENTRY(tx_q->cur_tx, DMA_TX_SIZE);
> +		desc = tx_q->dma_tx + tx_q->cur_tx;
>  
>  		desc->des0 = cpu_to_le32(des + (total_len - tmp_len));
>  		buff_size = tmp_len >= TSO_MAX_BUFF_SIZE ?
> @@ -2625,20 +2698,24 @@ static void stmmac_tso_allocator(struct stmmac_priv *priv, unsigned int des,
>   */
>  static netdev_tx_t stmmac_tso_xmit(struct sk_buff *skb, struct net_device *dev)
>  {
> -	u32 pay_len, mss;
> -	int tmp_pay_len = 0;
> +	struct dma_desc *desc, *first, *mss_desc = NULL;
>  	struct stmmac_priv *priv = netdev_priv(dev);
>  	int nfrags = skb_shinfo(skb)->nr_frags;
> +	u32 queue = skb_get_queue_mapping(skb);
>  	unsigned int first_entry, des;
> -	struct dma_desc *desc, *first, *mss_desc = NULL;
> +	struct stmmac_tx_queue *tx_q;
> +	int tmp_pay_len = 0;
> +	u32 pay_len, mss;
>  	u8 proto_hdr_len;
>  	int i;
>  
> +	tx_q = &priv->tx_queue[queue];
> +
>  	/* Compute header lengths */
>  	proto_hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
>  
>  	/* Desc availability based on threshold should be enough safe */
> -	if (unlikely(stmmac_tx_avail(priv) <
> +	if (unlikely(stmmac_tx_avail(priv, queue) <
>  		(((skb->len - proto_hdr_len) / TSO_MAX_BUFF_SIZE + 1)))) {
>  		if (!netif_queue_stopped(dev)) {
>  			netif_stop_queue(dev);
> @@ -2656,10 +2733,10 @@ static netdev_tx_t stmmac_tso_xmit(struct sk_buff *skb, struct net_device *dev)
>  
>  	/* set new MSS value if needed */
>  	if (mss != priv->mss) {
> -		mss_desc = priv->dma_tx + priv->cur_tx;
> +		mss_desc = tx_q->dma_tx + tx_q->cur_tx;
>  		priv->hw->desc->set_mss(mss_desc, mss);
>  		priv->mss = mss;
> -		priv->cur_tx = STMMAC_GET_ENTRY(priv->cur_tx, DMA_TX_SIZE);
> +		tx_q->cur_tx = STMMAC_GET_ENTRY(tx_q->cur_tx, DMA_TX_SIZE);
>  	}
>  
>  	if (netif_msg_tx_queued(priv)) {
> @@ -2669,9 +2746,9 @@ static netdev_tx_t stmmac_tso_xmit(struct sk_buff *skb, struct net_device *dev)
>  			skb->data_len);
>  	}
>  
> -	first_entry = priv->cur_tx;
> +	first_entry = tx_q->cur_tx;
>  
> -	desc = priv->dma_tx + first_entry;
> +	desc = tx_q->dma_tx + first_entry;
>  	first = desc;
>  
>  	/* first descriptor: fill Headers on Buf1 */
> @@ -2680,9 +2757,9 @@ static netdev_tx_t stmmac_tso_xmit(struct sk_buff *skb, struct net_device *dev)
>  	if (dma_mapping_error(priv->device, des))
>  		goto dma_map_err;
>  
> -	priv->tx_skbuff_dma[first_entry].buf = des;
> -	priv->tx_skbuff_dma[first_entry].len = skb_headlen(skb);
> -	priv->tx_skbuff[first_entry] = skb;
> +	tx_q->tx_skbuff_dma[first_entry].buf = des;
> +	tx_q->tx_skbuff_dma[first_entry].len = skb_headlen(skb);
> +	tx_q->tx_skbuff[first_entry] = skb;
>  
>  	first->des0 = cpu_to_le32(des);
>  
> @@ -2693,7 +2770,7 @@ static netdev_tx_t stmmac_tso_xmit(struct sk_buff *skb, struct net_device *dev)
>  	/* If needed take extra descriptors to fill the remaining payload */
>  	tmp_pay_len = pay_len - TSO_MAX_BUFF_SIZE;
>  
> -	stmmac_tso_allocator(priv, des, tmp_pay_len, (nfrags == 0));
> +	stmmac_tso_allocator(priv, des, tmp_pay_len, (nfrags == 0), queue);
>  
>  	/* Prepare fragments */
>  	for (i = 0; i < nfrags; i++) {
> @@ -2706,19 +2783,19 @@ static netdev_tx_t stmmac_tso_xmit(struct sk_buff *skb, struct net_device *dev)
>  			goto dma_map_err;
>  
>  		stmmac_tso_allocator(priv, des, skb_frag_size(frag),
> -				     (i == nfrags - 1));
> +				     (i == nfrags - 1), queue);
>  
> -		priv->tx_skbuff_dma[priv->cur_tx].buf = des;
> -		priv->tx_skbuff_dma[priv->cur_tx].len = skb_frag_size(frag);
> -		priv->tx_skbuff[priv->cur_tx] = NULL;
> -		priv->tx_skbuff_dma[priv->cur_tx].map_as_page = true;
> +		tx_q->tx_skbuff_dma[tx_q->cur_tx].buf = des;
> +		tx_q->tx_skbuff_dma[tx_q->cur_tx].len = skb_frag_size(frag);
> +		tx_q->tx_skbuff[tx_q->cur_tx] = NULL;
> +		tx_q->tx_skbuff_dma[tx_q->cur_tx].map_as_page = true;
>  	}
>  
> -	priv->tx_skbuff_dma[priv->cur_tx].last_segment = true;
> +	tx_q->tx_skbuff_dma[tx_q->cur_tx].last_segment = true;
>  
> -	priv->cur_tx = STMMAC_GET_ENTRY(priv->cur_tx, DMA_TX_SIZE);
> +	tx_q->cur_tx = STMMAC_GET_ENTRY(tx_q->cur_tx, DMA_TX_SIZE);
>  
> -	if (unlikely(stmmac_tx_avail(priv) <= (MAX_SKB_FRAGS + 1))) {
> +	if (unlikely(stmmac_tx_avail(priv, queue) <= (MAX_SKB_FRAGS + 1))) {
>  		netif_dbg(priv, hw, priv->dev, "%s: stop transmitted packets\n",
>  			  __func__);
>  		netif_stop_queue(dev);
> @@ -2753,7 +2830,7 @@ static netdev_tx_t stmmac_tso_xmit(struct sk_buff *skb, struct net_device *dev)
>  	priv->hw->desc->prepare_tso_tx_desc(first, 1,
>  			proto_hdr_len,
>  			pay_len,
> -			1, priv->tx_skbuff_dma[first_entry].last_segment,
> +			1, tx_q->tx_skbuff_dma[first_entry].last_segment,
>  			tcp_hdrlen(skb) / 4, (skb->len - proto_hdr_len));
>  
>  	/* If context desc is used to change MSS */
> @@ -2768,10 +2845,10 @@ static netdev_tx_t stmmac_tso_xmit(struct sk_buff *skb, struct net_device *dev)
>  
>  	if (netif_msg_pktdata(priv)) {
>  		pr_info("%s: curr=%d dirty=%d f=%d, e=%d, f_p=%p, nfrags %d\n",
> -			__func__, priv->cur_tx, priv->dirty_tx, first_entry,
> -			priv->cur_tx, first, nfrags);
> +			__func__, tx_q->cur_tx, tx_q->dirty_tx, first_entry,
> +			tx_q->cur_tx, first, nfrags);
>  
> -		priv->hw->desc->display_ring((void *)priv->dma_tx, DMA_TX_SIZE,
> +		priv->hw->desc->display_ring((void *)tx_q->dma_tx, DMA_TX_SIZE,
>  					     0);
>  
>  		pr_info(">>> frame to be transmitted: ");
> @@ -2780,8 +2857,8 @@ static netdev_tx_t stmmac_tso_xmit(struct sk_buff *skb, struct net_device *dev)
>  
>  	netdev_sent_queue(dev, skb->len);
>  
> -	priv->hw->dma->set_tx_tail_ptr(priv->ioaddr, priv->tx_tail_addr,
> -				       STMMAC_CHAN0);
> +	priv->hw->dma->set_tx_tail_ptr(priv->ioaddr, tx_q->tx_tail_addr,
> +				       queue);
>  
>  	return NETDEV_TX_OK;
>  
> @@ -2805,19 +2882,23 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
>  	struct stmmac_priv *priv = netdev_priv(dev);
>  	unsigned int nopaged_len = skb_headlen(skb);
>  	int i, csum_insertion = 0, is_jumbo = 0;
> +	u32 queue = skb_get_queue_mapping(skb);
>  	int nfrags = skb_shinfo(skb)->nr_frags;
>  	unsigned int entry, first_entry;
>  	struct dma_desc *desc, *first;
> +	struct stmmac_tx_queue *tx_q;
>  	unsigned int enh_desc;
>  	unsigned int des;
>  
> +	tx_q = &priv->tx_queue[queue];
> +
>  	/* Manage oversized TCP frames for GMAC4 device */
>  	if (skb_is_gso(skb) && priv->tso) {
>  		if (ip_hdr(skb)->protocol == IPPROTO_TCP)
>  			return stmmac_tso_xmit(skb, dev);
>  	}
>  
> -	if (unlikely(stmmac_tx_avail(priv) < nfrags + 1)) {
> +	if (unlikely(stmmac_tx_avail(priv, queue) < nfrags + 1)) {
>  		if (!netif_queue_stopped(dev)) {
>  			netif_stop_queue(dev);
>  			/* This is a hard error, log it. */
> @@ -2831,19 +2912,19 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
>  	if (priv->tx_path_in_lpi_mode)
>  		stmmac_disable_eee_mode(priv);
>  
> -	entry = priv->cur_tx;
> +	entry = tx_q->cur_tx;
>  	first_entry = entry;
>  
>  	csum_insertion = (skb->ip_summed == CHECKSUM_PARTIAL);
>  
>  	if (likely(priv->extend_desc))
> -		desc = (struct dma_desc *)(priv->dma_etx + entry);
> +		desc = (struct dma_desc *)(tx_q->dma_etx + entry);
>  	else
> -		desc = priv->dma_tx + entry;
> +		desc = tx_q->dma_tx + entry;
>  
>  	first = desc;
>  
> -	priv->tx_skbuff[first_entry] = skb;
> +	tx_q->tx_skbuff[first_entry] = skb;
>  
>  	enh_desc = priv->plat->enh_desc;
>  	/* To program the descriptors according to the size of the frame */
> @@ -2852,7 +2933,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
>  
>  	if (unlikely(is_jumbo) && likely(priv->synopsys_id <
>  					 DWMAC_CORE_4_00)) {
> -		entry = priv->hw->mode->jumbo_frm(priv, skb, csum_insertion);
> +		entry = priv->hw->mode->jumbo_frm(tx_q, skb, csum_insertion);
>  		if (unlikely(entry < 0))
>  			goto dma_map_err;
>  	}
> @@ -2865,26 +2946,26 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
>  		entry = STMMAC_GET_ENTRY(entry, DMA_TX_SIZE);
>  
>  		if (likely(priv->extend_desc))
> -			desc = (struct dma_desc *)(priv->dma_etx + entry);
> +			desc = (struct dma_desc *)(tx_q->dma_etx + entry);
>  		else
> -			desc = priv->dma_tx + entry;
> +			desc = tx_q->dma_tx + entry;
>  
>  		des = skb_frag_dma_map(priv->device, frag, 0, len,
>  				       DMA_TO_DEVICE);
>  		if (dma_mapping_error(priv->device, des))
>  			goto dma_map_err; /* should reuse desc w/o issues */
>  
> -		priv->tx_skbuff[entry] = NULL;
> +		tx_q->tx_skbuff[entry] = NULL;
>  
> -		priv->tx_skbuff_dma[entry].buf = des;
> +		tx_q->tx_skbuff_dma[entry].buf = des;
>  		if (unlikely(priv->synopsys_id >= DWMAC_CORE_4_00))
>  			desc->des0 = cpu_to_le32(des);
>  		else
>  			desc->des2 = cpu_to_le32(des);
>  
> -		priv->tx_skbuff_dma[entry].map_as_page = true;
> -		priv->tx_skbuff_dma[entry].len = len;
> -		priv->tx_skbuff_dma[entry].last_segment = last_segment;
> +		tx_q->tx_skbuff_dma[entry].map_as_page = true;
> +		tx_q->tx_skbuff_dma[entry].len = len;
> +		tx_q->tx_skbuff_dma[entry].last_segment = last_segment;
>  
>  		/* Prepare the descriptor and set the own bit too */
>  		priv->hw->desc->prepare_tx_desc(desc, 0, len, csum_insertion,
> @@ -2893,20 +2974,20 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
>  
>  	entry = STMMAC_GET_ENTRY(entry, DMA_TX_SIZE);
>  
> -	priv->cur_tx = entry;
> +	tx_q->cur_tx = entry;
>  
>  	if (netif_msg_pktdata(priv)) {
>  		void *tx_head;
>  
>  		netdev_dbg(priv->dev,
>  			   "%s: curr=%d dirty=%d f=%d, e=%d, first=%p, nfrags=%d",
> -			   __func__, priv->cur_tx, priv->dirty_tx, first_entry,
> +			   __func__, tx_q->cur_tx, tx_q->dirty_tx, first_entry,
>  			   entry, first, nfrags);
>  
>  		if (priv->extend_desc)
> -			tx_head = (void *)priv->dma_etx;
> +			tx_head = (void *)tx_q->dma_etx;
>  		else
> -			tx_head = (void *)priv->dma_tx;
> +			tx_head = (void *)tx_q->dma_tx;
>  
>  		priv->hw->desc->display_ring(tx_head, DMA_TX_SIZE, false);
>  
> @@ -2914,7 +2995,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
>  		print_pkt(skb->data, skb->len);
>  	}
>  
> -	if (unlikely(stmmac_tx_avail(priv) <= (MAX_SKB_FRAGS + 1))) {
> +	if (unlikely(stmmac_tx_avail(priv, queue) <= (MAX_SKB_FRAGS + 1))) {
>  		netif_dbg(priv, hw, priv->dev, "%s: stop transmitted packets\n",
>  			  __func__);
>  		netif_stop_queue(dev);
> @@ -2952,14 +3033,14 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
>  		if (dma_mapping_error(priv->device, des))
>  			goto dma_map_err;
>  
> -		priv->tx_skbuff_dma[first_entry].buf = des;
> +		tx_q->tx_skbuff_dma[first_entry].buf = des;
>  		if (unlikely(priv->synopsys_id >= DWMAC_CORE_4_00))
>  			first->des0 = cpu_to_le32(des);
>  		else
>  			first->des2 = cpu_to_le32(des);
>  
> -		priv->tx_skbuff_dma[first_entry].len = nopaged_len;
> -		priv->tx_skbuff_dma[first_entry].last_segment = last_segment;
> +		tx_q->tx_skbuff_dma[first_entry].len = nopaged_len;
> +		tx_q->tx_skbuff_dma[first_entry].last_segment = last_segment;
>  
>  		if (unlikely((skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) &&
>  			     priv->hwts_tx_en)) {
> @@ -2985,8 +3066,8 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
>  	if (priv->synopsys_id < DWMAC_CORE_4_00)
>  		priv->hw->dma->enable_dma_transmission(priv->ioaddr);
>  	else
> -		priv->hw->dma->set_tx_tail_ptr(priv->ioaddr, priv->tx_tail_addr,
> -					       STMMAC_CHAN0);
> +		priv->hw->dma->set_tx_tail_ptr(priv->ioaddr, tx_q->tx_tail_addr,
> +					       queue);
>  
>  	return NETDEV_TX_OK;
>  
> @@ -3306,12 +3387,18 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit, u32 queue)
>  static int stmmac_poll(struct napi_struct *napi, int budget)
>  {
>  	struct stmmac_priv *priv = container_of(napi, struct stmmac_priv, napi);
> +	u32 tx_count = priv->plat->tx_queues_to_use;
>  	u32 chan = STMMAC_CHAN0;
>  	int work_done = 0;
>  	u32 queue = chan;
>  
>  	priv->xstats.napi_poll++;
> -	stmmac_tx_clean(priv);
> +
> +	/* check all the queues */
> +	for (queue = 0; queue < tx_count; queue++)
> +		stmmac_tx_clean(priv, queue);
> +
> +	queue = chan;
>  
>  	work_done = stmmac_rx(priv, budget, queue);
>  	if (work_done < budget) {
> @@ -3332,10 +3419,12 @@ static int stmmac_poll(struct napi_struct *napi, int budget)
>  static void stmmac_tx_timeout(struct net_device *dev)
>  {
>  	struct stmmac_priv *priv = netdev_priv(dev);
> -	u32 chan = STMMAC_CHAN0;
> +	u32 tx_count = priv->plat->tx_queues_to_use;
> +	u32 chan;
>  
>  	/* Clear Tx resources and restart transmitting again */
> -	stmmac_tx_err(priv, chan);
> +	for (chan = 0; chan < tx_count; chan++)
> +		stmmac_tx_err(priv, chan);
>  }
>  
>  /**
> @@ -3585,6 +3674,7 @@ static int stmmac_sysfs_ring_read(struct seq_file *seq, void *v)
>  	struct net_device *dev = seq->private;
>  	struct stmmac_priv *priv = netdev_priv(dev);
>  	u32 rx_count = priv->plat->rx_queues_to_use;
> +	u32 tx_count = priv->plat->tx_queues_to_use;
>  	u32 queue;
>  
>  	for (queue = 0; queue < rx_count; queue++) {
> @@ -3603,12 +3693,20 @@ static int stmmac_sysfs_ring_read(struct seq_file *seq, void *v)
>  		}
>  	}
>  
> -	if (priv->extend_desc) {
> -		seq_printf(seq, "Extended TX descriptor ring:\n");
> -		sysfs_display_ring((void *)priv->dma_etx, DMA_TX_SIZE, 1, seq);
> -	} else {
> -		seq_printf(seq, "TX descriptor ring:\n");
> -		sysfs_display_ring((void *)priv->dma_tx, DMA_TX_SIZE, 0, seq);
> +	for (queue = 0; queue < tx_count; queue++) {
> +		struct stmmac_tx_queue *tx_q = &priv->tx_queue[queue];
> +
> +		seq_printf(seq, "TX Queue %d:\n", queue);
> +
> +		if (priv->extend_desc) {
> +			seq_printf(seq, "Extended descriptor ring:\n");
> +			sysfs_display_ring((void *)tx_q->dma_etx,
> +					   DMA_TX_SIZE, 1, seq);
> +		} else {
> +			seq_printf(seq, "Descriptor ring:\n");
> +			sysfs_display_ring((void *)tx_q->dma_tx,
> +					   DMA_TX_SIZE, 0, seq);
> +		}
>  	}
>  
>  	return 0;
> @@ -4127,6 +4225,7 @@ EXPORT_SYMBOL_GPL(stmmac_suspend);
>  static void stmmac_reset_queues_param(struct stmmac_priv *priv)
>  {
>  	u32 rx_cnt = priv->plat->rx_queues_to_use;
> +	u32 tx_cnt = priv->plat->tx_queues_to_use;
>  	u32 queue;
>  
>  	for (queue = 0; queue < rx_cnt; queue++) {
> @@ -4136,8 +4235,12 @@ static void stmmac_reset_queues_param(struct stmmac_priv *priv)
>  		rx_q->dirty_rx = 0;
>  	}
>  
> -	priv->dirty_tx = 0;
> -	priv->cur_tx = 0;
> +	for (queue = 0; queue < tx_cnt; queue++) {
> +		struct stmmac_tx_queue *tx_q = &priv->tx_queue[queue];
> +
> +		tx_q->cur_tx = 0;
> +		tx_q->dirty_tx = 0;
> +	}
>  }
>  
>  /**
> 
