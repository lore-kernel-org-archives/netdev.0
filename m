From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: bcmgenet: add support for Rx priority queues
Date: Tue, 02 Dec 2014 13:39:30 -0800
Message-ID: <547E3192.4080400@gmail.com>
References: <20141202210000.BD68A220728@puck.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Petri Gynther <pgynther@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:45608 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750769AbaLBVji (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 16:39:38 -0500
Received: by mail-pa0-f46.google.com with SMTP id lj1so14172423pab.5
        for <netdev@vger.kernel.org>; Tue, 02 Dec 2014 13:39:37 -0800 (PST)
In-Reply-To: <20141202210000.BD68A220728@puck.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/12/14 13:00, Petri Gynther wrote:
> bcmgenet hardware supports 16 Rx priority queues + 1 Rx default queue.
> Currently, the driver only supports the Rx default queue.
> Add support for the Rx priority queues.

You are doing many things in one patch here, I see at least 3 separate
commits:

- move TX completion to NAPI
- introduce a RX ring change that just applies to RX ring 16
- introduce support for RX rings 0 through 15

Eventually a 4th one which caches the reads and writes to the INTRL2_0
registers and uses int0_mask, which BTW, I had problems with on GENETv4,
hence the reason why it is not currently adopted.

Have you tried the following NAPI/queue partitioning:

- one NAPI context per TX queue, except ring 16
- one NAPI context per RX queue, except ring 16
- one shared NAPI context for RX & TX queue 16 (today's scheme)

The changes are looking good, but since there are many things that
change, it is harder to review, which is why I would prefer separate
individual patches.

Thanks!

> 
> Signed-off-by: Petri Gynther <pgynther@google.com>
> ---
>  drivers/net/ethernet/broadcom/genet/bcmgenet.c | 432 +++++++++++++++----------
>  drivers/net/ethernet/broadcom/genet/bcmgenet.h |  27 +-
>  2 files changed, 289 insertions(+), 170 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> index f2fadb0..aced105 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> @@ -53,8 +53,10 @@
>  /* Default highest priority queue for multi queue support */
>  #define GENET_Q0_PRIORITY	0
>  
> -#define GENET_DEFAULT_BD_CNT	\
> -	(TOTAL_DESC - priv->hw_params->tx_queues * priv->hw_params->bds_cnt)
> +#define GENET_Q16_RX_BD_CNT	\
> +	(TOTAL_DESC - priv->hw_params->rx_queues * priv->hw_params->rx_bds_cnt)
> +#define GENET_Q16_TX_BD_CNT	\
> +	(TOTAL_DESC - priv->hw_params->tx_queues * priv->hw_params->tx_bds_cnt)
>  
>  #define RX_BUF_LENGTH		2048
>  #define SKB_ALIGNMENT		32
> @@ -1313,7 +1315,8 @@ out:
>  }
>  
>  
> -static int bcmgenet_rx_refill(struct bcmgenet_priv *priv, struct enet_cb *cb)
> +static int bcmgenet_rx_refill(struct bcmgenet_priv *priv,
> +			      struct bcmgenet_rx_ring *ring, struct enet_cb *cb)
>  {
>  	struct device *kdev = &priv->pdev->dev;
>  	struct sk_buff *skb;
> @@ -1341,14 +1344,16 @@ static int bcmgenet_rx_refill(struct bcmgenet_priv *priv, struct enet_cb *cb)
>  	dma_unmap_addr_set(cb, dma_addr, mapping);
>  	/* assign packet, prepare descriptor, and advance pointer */
>  
> -	dmadesc_set_addr(priv, priv->rx_bd_assign_ptr, mapping);
> +	dmadesc_set_addr(priv, ring->bd_assign_ptr, mapping);
>  
>  	/* turn on the newly assigned BD for DMA to use */
> -	priv->rx_bd_assign_index++;
> -	priv->rx_bd_assign_index &= (priv->num_rx_bds - 1);
> +	if (likely(ring->bd_assign_idx < ring->end_ptr))
> +		ring->bd_assign_idx++;
> +	else
> +		ring->bd_assign_idx = ring->cb_ptr;
>  
> -	priv->rx_bd_assign_ptr = priv->rx_bds +
> -		(priv->rx_bd_assign_index * DMA_DESC_SIZE);
> +	ring->bd_assign_ptr = priv->rx_bds +
> +		(ring->bd_assign_idx * DMA_DESC_SIZE);
>  
>  	return 0;
>  }
> @@ -1357,8 +1362,10 @@ static int bcmgenet_rx_refill(struct bcmgenet_priv *priv, struct enet_cb *cb)
>   * this could be called from bottom half, or from NAPI polling method.
>   */
>  static unsigned int bcmgenet_desc_rx(struct bcmgenet_priv *priv,
> -				     unsigned int budget)
> +				     unsigned int index,
> +				     struct napi_struct *napi, int budget)
>  {
> +	struct bcmgenet_rx_ring *ring = &priv->rx_rings[index];
>  	struct net_device *dev = priv->dev;
>  	struct enet_cb *cb;
>  	struct sk_buff *skb;
> @@ -1369,21 +1376,21 @@ static unsigned int bcmgenet_desc_rx(struct bcmgenet_priv *priv,
>  	unsigned int p_index;
>  	unsigned int chksum_ok = 0;
>  
> -	p_index = bcmgenet_rdma_ring_readl(priv, DESC_INDEX, RDMA_PROD_INDEX);
> +	p_index = bcmgenet_rdma_ring_readl(priv, index, RDMA_PROD_INDEX);
>  	p_index &= DMA_P_INDEX_MASK;
>  
> -	if (p_index < priv->rx_c_index)
> -		rxpkttoprocess = (DMA_C_INDEX_MASK + 1) -
> -			priv->rx_c_index + p_index;
> +	if (likely(p_index >= ring->c_index))
> +		rxpkttoprocess = p_index - ring->c_index;
>  	else
> -		rxpkttoprocess = p_index - priv->rx_c_index;
> +		rxpkttoprocess = (DMA_C_INDEX_MASK + 1) -
> +			ring->c_index + p_index;
>  
>  	netif_dbg(priv, rx_status, dev,
>  		  "RDMA: rxpkttoprocess=%d\n", rxpkttoprocess);
>  
>  	while ((rxpktprocessed < rxpkttoprocess) &&
>  	       (rxpktprocessed < budget)) {
> -		cb = &priv->rx_cbs[priv->rx_read_ptr];
> +		cb = &priv->rx_cbs[ring->read_ptr];
>  		skb = cb->skb;
>  
>  		/* We do not have a backing SKB, so we do not have a
> @@ -1408,7 +1415,7 @@ static unsigned int bcmgenet_desc_rx(struct bcmgenet_priv *priv,
>  			dma_length_status =
>  				dmadesc_get_length_status(priv,
>  							  priv->rx_bds +
> -							  (priv->rx_read_ptr *
> +							  (ring->read_ptr *
>  							   DMA_DESC_SIZE));
>  		} else {
>  			struct status_64 *status;
> @@ -1425,8 +1432,8 @@ static unsigned int bcmgenet_desc_rx(struct bcmgenet_priv *priv,
>  
>  		netif_dbg(priv, rx_status, dev,
>  			  "%s:p_ind=%d c_ind=%d read_ptr=%d len_stat=0x%08x\n",
> -			  __func__, p_index, priv->rx_c_index,
> -			  priv->rx_read_ptr, dma_length_status);
> +			  __func__, p_index, ring->c_index,
> +			  ring->read_ptr, dma_length_status);
>  
>  		if (unlikely(!(dma_flag & DMA_EOP) || !(dma_flag & DMA_SOP))) {
>  			netif_err(priv, rx_status, dev,
> @@ -1491,28 +1498,34 @@ static unsigned int bcmgenet_desc_rx(struct bcmgenet_priv *priv,
>  			dev->stats.multicast++;
>  
>  		/* Notify kernel */
> -		napi_gro_receive(&priv->napi, skb);
> +		napi_gro_receive(napi, skb);
>  		cb->skb = NULL;
>  		netif_dbg(priv, rx_status, dev, "pushed up to kernel\n");
>  
>  		/* refill RX path on the current control block */
>  refill:
> -		err = bcmgenet_rx_refill(priv, cb);
> +		err = bcmgenet_rx_refill(priv, ring, cb);
>  		if (err) {
>  			priv->mib.alloc_rx_buff_failed++;
>  			netif_err(priv, rx_err, dev, "Rx refill failed\n");
>  		}
>  
>  		rxpktprocessed++;
> -		priv->rx_read_ptr++;
> -		priv->rx_read_ptr &= (priv->num_rx_bds - 1);
> +		if (likely(ring->read_ptr < ring->end_ptr))
> +			ring->read_ptr++;
> +		else
> +			ring->read_ptr = ring->cb_ptr;
> +
> +		ring->c_index = (ring->c_index + 1) & DMA_C_INDEX_MASK;
> +		bcmgenet_rdma_ring_writel(priv, index, ring->c_index, RDMA_CONS_INDEX);
>  	}
>  
>  	return rxpktprocessed;
>  }
>  
>  /* Assign skb to RX DMA descriptor. */
> -static int bcmgenet_alloc_rx_buffers(struct bcmgenet_priv *priv)
> +static int bcmgenet_alloc_rx_buffers(struct bcmgenet_priv *priv,
> +				     struct bcmgenet_rx_ring *ring)
>  {
>  	struct enet_cb *cb;
>  	int ret = 0;
> @@ -1521,12 +1534,12 @@ static int bcmgenet_alloc_rx_buffers(struct bcmgenet_priv *priv)
>  	netif_dbg(priv, hw, priv->dev, "%s:\n", __func__);
>  
>  	/* loop here for each buffer needing assign */
> -	for (i = 0; i < priv->num_rx_bds; i++) {
> -		cb = &priv->rx_cbs[priv->rx_bd_assign_index];
> +	for (i = 0; i < ring->size; i++) {
> +		cb = &priv->rx_cbs[ring->bd_assign_idx];
>  		if (cb->skb)
> -			continue;
> +			bcmgenet_free_cb(cb);
>  
> -		ret = bcmgenet_rx_refill(priv, cb);
> +		ret = bcmgenet_rx_refill(priv, ring, cb);
>  		if (ret)
>  			break;
>  	}
> @@ -1607,9 +1620,11 @@ static int reset_umac(struct bcmgenet_priv *priv)
>  static void bcmgenet_intr_disable(struct bcmgenet_priv *priv)
>  {
>  	/* Mask all interrupts.*/
> +	priv->int0_mask = 0xFFFFFFFF;
>  	bcmgenet_intrl2_0_writel(priv, 0xFFFFFFFF, INTRL2_CPU_MASK_SET);
>  	bcmgenet_intrl2_0_writel(priv, 0xFFFFFFFF, INTRL2_CPU_CLEAR);
>  	bcmgenet_intrl2_0_writel(priv, 0, INTRL2_CPU_MASK_CLEAR);
> +	priv->int1_mask = 0xFFFFFFFF;
>  	bcmgenet_intrl2_1_writel(priv, 0xFFFFFFFF, INTRL2_CPU_MASK_SET);
>  	bcmgenet_intrl2_1_writel(priv, 0xFFFFFFFF, INTRL2_CPU_CLEAR);
>  	bcmgenet_intrl2_1_writel(priv, 0, INTRL2_CPU_MASK_CLEAR);
> @@ -1619,7 +1634,8 @@ static int init_umac(struct bcmgenet_priv *priv)
>  {
>  	struct device *kdev = &priv->pdev->dev;
>  	int ret;
> -	u32 reg, cpu_mask_clear;
> +	u32 reg;
> +	u32 i;
>  
>  	dev_dbg(&priv->pdev->dev, "bcmgenet: init_umac\n");
>  
> @@ -1646,15 +1662,15 @@ static int init_umac(struct bcmgenet_priv *priv)
>  
>  	bcmgenet_intr_disable(priv);
>  
> -	cpu_mask_clear = UMAC_IRQ_RXDMA_BDONE;
> -
> -	dev_dbg(kdev, "%s:Enabling RXDMA_BDONE interrupt\n", __func__);
> +	/* Enable Rx and Tx interrupts for the default queue 16 */
> +	priv->int0_mask &= ~(UMAC_IRQ_RXDMA_BDONE | UMAC_IRQ_RXDMA_PDONE |
> +			     UMAC_IRQ_TXDMA_BDONE | UMAC_IRQ_TXDMA_PDONE);
>  
>  	/* Monitor cable plug/unplugged event for internal PHY */
>  	if (phy_is_internal(priv->phydev)) {
> -		cpu_mask_clear |= (UMAC_IRQ_LINK_DOWN | UMAC_IRQ_LINK_UP);
> +		priv->int0_mask &= ~(UMAC_IRQ_LINK_DOWN | UMAC_IRQ_LINK_UP);
>  	} else if (priv->ext_phy) {
> -		cpu_mask_clear |= (UMAC_IRQ_LINK_DOWN | UMAC_IRQ_LINK_UP);
> +		priv->int0_mask &= ~(UMAC_IRQ_LINK_DOWN | UMAC_IRQ_LINK_UP);
>  	} else if (priv->phy_interface == PHY_INTERFACE_MODE_MOCA) {
>  		reg = bcmgenet_bp_mc_get(priv);
>  		reg |= BIT(priv->hw_params->bp_in_en_shift);
> @@ -1669,9 +1685,18 @@ static int init_umac(struct bcmgenet_priv *priv)
>  
>  	/* Enable MDIO interrupts on GENET v3+ */
>  	if (priv->hw_params->flags & GENET_HAS_MDIO_INTR)
> -		cpu_mask_clear |= UMAC_IRQ_MDIO_DONE | UMAC_IRQ_MDIO_ERROR;
> +		priv->int0_mask &= ~(UMAC_IRQ_MDIO_DONE | UMAC_IRQ_MDIO_ERROR);
>  
> -	bcmgenet_intrl2_0_writel(priv, cpu_mask_clear, INTRL2_CPU_MASK_CLEAR);
> +	/* Enable Tx priority queue interrupts */
> +	for (i = 0; i < priv->hw_params->tx_queues; i++)
> +		priv->int1_mask &= ~(1 << i);
> +
> +	/* Enable Rx priority queue interrupts */
> +	for (i = 0; i < priv->hw_params->rx_queues; i++)
> +		priv->int1_mask &= ~(1 << (UMAC_IRQ1_RX_INTR_SHIFT + i));
> +
> +	bcmgenet_intrl2_0_writel(priv, ~priv->int0_mask, INTRL2_CPU_MASK_CLEAR);
> +	bcmgenet_intrl2_1_writel(priv, ~priv->int1_mask, INTRL2_CPU_MASK_CLEAR);
>  
>  	/* Enable rx/tx engine.*/
>  	dev_dbg(kdev, "done init umac\n");
> @@ -1684,12 +1709,11 @@ static int init_umac(struct bcmgenet_priv *priv)
>   */
>  static void bcmgenet_init_tx_ring(struct bcmgenet_priv *priv,
>  				  unsigned int index, unsigned int size,
> -				  unsigned int write_ptr, unsigned int end_ptr)
> +				  unsigned int start_ptr, unsigned int end_ptr)
>  {
>  	struct bcmgenet_tx_ring *ring = &priv->tx_rings[index];
>  	u32 words_per_bd = WORDS_PER_BD(priv);
>  	u32 flow_period_val = 0;
> -	unsigned int first_bd;
>  
>  	spin_lock_init(&ring->lock);
>  	ring->index = index;
> @@ -1702,12 +1726,12 @@ static void bcmgenet_init_tx_ring(struct bcmgenet_priv *priv,
>  		ring->int_enable = bcmgenet_tx_ring_int_enable;
>  		ring->int_disable = bcmgenet_tx_ring_int_disable;
>  	}
> -	ring->cbs = priv->tx_cbs + write_ptr;
> +	ring->cbs = priv->tx_cbs + start_ptr;
>  	ring->size = size;
>  	ring->c_index = 0;
>  	ring->free_bds = size;
> -	ring->write_ptr = write_ptr;
> -	ring->cb_ptr = write_ptr;
> +	ring->write_ptr = start_ptr;
> +	ring->cb_ptr = start_ptr;
>  	ring->end_ptr = end_ptr - 1;
>  	ring->prod_index = 0;
>  
> @@ -1718,22 +1742,16 @@ static void bcmgenet_init_tx_ring(struct bcmgenet_priv *priv,
>  	bcmgenet_tdma_ring_writel(priv, index, 0, TDMA_PROD_INDEX);
>  	bcmgenet_tdma_ring_writel(priv, index, 0, TDMA_CONS_INDEX);
>  	bcmgenet_tdma_ring_writel(priv, index, 1, DMA_MBUF_DONE_THRESH);
> -	/* Disable rate control for now */
>  	bcmgenet_tdma_ring_writel(priv, index, flow_period_val,
>  				  TDMA_FLOW_PERIOD);
> -	/* Unclassified traffic goes to ring 16 */
>  	bcmgenet_tdma_ring_writel(priv, index,
>  				  ((size << DMA_RING_SIZE_SHIFT) |
>  				   RX_BUF_LENGTH), DMA_RING_BUF_SIZE);
> -
> -	first_bd = write_ptr;
> -
> -	/* Set start and end address, read and write pointers */
> -	bcmgenet_tdma_ring_writel(priv, index, first_bd * words_per_bd,
> +	bcmgenet_tdma_ring_writel(priv, index, start_ptr * words_per_bd,
>  				  DMA_START_ADDR);
> -	bcmgenet_tdma_ring_writel(priv, index, first_bd * words_per_bd,
> +	bcmgenet_tdma_ring_writel(priv, index, start_ptr * words_per_bd,
>  				  TDMA_READ_PTR);
> -	bcmgenet_tdma_ring_writel(priv, index, first_bd,
> +	bcmgenet_tdma_ring_writel(priv, index, start_ptr * words_per_bd,
>  				  TDMA_WRITE_PTR);
>  	bcmgenet_tdma_ring_writel(priv, index, end_ptr * words_per_bd - 1,
>  				  DMA_END_ADDR);
> @@ -1741,42 +1759,44 @@ static void bcmgenet_init_tx_ring(struct bcmgenet_priv *priv,
>  
>  /* Initialize a RDMA ring */
>  static int bcmgenet_init_rx_ring(struct bcmgenet_priv *priv,
> -				 unsigned int index, unsigned int size)
> +				 unsigned int index, unsigned int size,
> +				 unsigned int start_ptr, unsigned int end_ptr)
>  {
> +	struct bcmgenet_rx_ring *ring = &priv->rx_rings[index];
>  	u32 words_per_bd = WORDS_PER_BD(priv);
>  	int ret;
>  
> -	priv->num_rx_bds = TOTAL_DESC;
> -	priv->rx_bds = priv->base + priv->hw_params->rdma_offset;
> -	priv->rx_bd_assign_ptr = priv->rx_bds;
> -	priv->rx_bd_assign_index = 0;
> -	priv->rx_c_index = 0;
> -	priv->rx_read_ptr = 0;
> -	priv->rx_cbs = kcalloc(priv->num_rx_bds, sizeof(struct enet_cb),
> -			       GFP_KERNEL);
> -	if (!priv->rx_cbs)
> -		return -ENOMEM;
> +	ring->index = index;
> +	ring->cbs = priv->rx_cbs + start_ptr;
> +	ring->size = size;
> +	ring->c_index = 0;
> +	ring->read_ptr = start_ptr;
> +	ring->cb_ptr = start_ptr;
> +	ring->end_ptr = end_ptr - 1;
>  
> -	ret = bcmgenet_alloc_rx_buffers(priv);
> +	ret = bcmgenet_alloc_rx_buffers(priv, ring);
>  	if (ret) {
> -		kfree(priv->rx_cbs);
>  		return ret;
>  	}
>  
> -	bcmgenet_rdma_ring_writel(priv, index, 0, RDMA_WRITE_PTR);
>  	bcmgenet_rdma_ring_writel(priv, index, 0, RDMA_PROD_INDEX);
>  	bcmgenet_rdma_ring_writel(priv, index, 0, RDMA_CONS_INDEX);
> +	bcmgenet_rdma_ring_writel(priv, index, 1, DMA_MBUF_DONE_THRESH);
>  	bcmgenet_rdma_ring_writel(priv, index,
>  				  ((size << DMA_RING_SIZE_SHIFT) |
>  				   RX_BUF_LENGTH), DMA_RING_BUF_SIZE);
> -	bcmgenet_rdma_ring_writel(priv, index, 0, DMA_START_ADDR);
> -	bcmgenet_rdma_ring_writel(priv, index,
> -				  words_per_bd * size - 1, DMA_END_ADDR);
>  	bcmgenet_rdma_ring_writel(priv, index,
>  				  (DMA_FC_THRESH_LO <<
>  				   DMA_XOFF_THRESHOLD_SHIFT) |
>  				   DMA_FC_THRESH_HI, RDMA_XON_XOFF_THRESH);
> -	bcmgenet_rdma_ring_writel(priv, index, 0, RDMA_READ_PTR);
> +	bcmgenet_rdma_ring_writel(priv, index, start_ptr * words_per_bd,
> +				  DMA_START_ADDR);
> +	bcmgenet_rdma_ring_writel(priv, index, start_ptr * words_per_bd,
> +				  RDMA_READ_PTR);
> +	bcmgenet_rdma_ring_writel(priv, index, start_ptr * words_per_bd,
> +				  RDMA_WRITE_PTR);
> +	bcmgenet_rdma_ring_writel(priv, index, end_ptr * words_per_bd - 1,
> +				  DMA_END_ADDR);
>  
>  	return ret;
>  }
> @@ -1784,75 +1804,113 @@ static int bcmgenet_init_rx_ring(struct bcmgenet_priv *priv,
>  /* init multi xmit queues, only available for GENET2+
>   * the queue is partitioned as follows:
>   *
> - * queue 0 - 3 is priority based, each one has 32 descriptors,
> + * queues 0-3 are priority based, each one has 32 descriptors,
>   * with queue 0 being the highest priority queue.
>   *
> - * queue 16 is the default tx queue with GENET_DEFAULT_BD_CNT
> + * queue 16 is the default tx queue with GENET_Q16_TX_BD_CNT
>   * descriptors: 256 - (number of tx queues * bds per queues) = 128
>   * descriptors.
>   *
>   * The transmit control block pool is then partitioned as following:
> - * - tx_cbs[0...127] are for queue 16
> - * - tx_ring_cbs[0] points to tx_cbs[128..159]
> - * - tx_ring_cbs[1] points to tx_cbs[160..191]
> - * - tx_ring_cbs[2] points to tx_cbs[192..223]
> - * - tx_ring_cbs[3] points to tx_cbs[224..255]
> + * - tx_ring_cbs[0] points to tx_cbs[0..31]
> + * - tx_ring_cbs[1] points to tx_cbs[32..63]
> + * - tx_ring_cbs[2] points to tx_cbs[64..95]
> + * - tx_ring_cbs[3] points to tx_cbs[96..127]
> + * - tx ring 16 uses tx_cbs[128..255]
>   */
> -static void bcmgenet_init_multiq(struct net_device *dev)
> +static void bcmgenet_init_tx_queues(struct net_device *dev)
>  {
>  	struct bcmgenet_priv *priv = netdev_priv(dev);
>  	unsigned int i, dma_enable;
> -	u32 reg, dma_ctrl, ring_cfg = 0;
> +	u32 dma_ctrl, ring_cfg;
>  	u32 dma_priority[3] = {0, 0, 0};
>  
> -	if (!netif_is_multiqueue(dev)) {
> -		netdev_warn(dev, "called with non multi queue aware HW\n");
> -		return;
> -	}
> -
>  	dma_ctrl = bcmgenet_tdma_readl(priv, DMA_CTRL);
>  	dma_enable = dma_ctrl & DMA_EN;
>  	dma_ctrl &= ~DMA_EN;
>  	bcmgenet_tdma_writel(priv, dma_ctrl, DMA_CTRL);
>  
> +	dma_ctrl = 0;
> +	ring_cfg = 0;
> +
>  	/* Enable strict priority arbiter mode */
>  	bcmgenet_tdma_writel(priv, DMA_ARBITER_SP, DMA_ARB_CTRL);
>  
> +	/* Initialize Tx priority queues */
>  	for (i = 0; i < priv->hw_params->tx_queues; i++) {
> -		/* first 64 tx_cbs are reserved for default tx queue
> -		 * (ring 16)
> -		 */
> -		bcmgenet_init_tx_ring(priv, i, priv->hw_params->bds_cnt,
> -				      i * priv->hw_params->bds_cnt,
> -				      (i + 1) * priv->hw_params->bds_cnt);
> +		bcmgenet_init_tx_ring(priv, i, priv->hw_params->tx_bds_cnt,
> +				      i * priv->hw_params->tx_bds_cnt,
> +				      (i + 1) * priv->hw_params->tx_bds_cnt);
>  
>  		/* Configure ring as descriptor ring and setup priority */
> -		ring_cfg |= 1 << i;
> -		dma_ctrl |= 1 << (i + DMA_RING_BUF_EN_SHIFT);
> +		ring_cfg |= (1 << i);
> +		dma_ctrl |= (1 << (i + DMA_RING_BUF_EN_SHIFT));
>  
>  		dma_priority[DMA_PRIO_REG_INDEX(i)] |=
>  			((GENET_Q0_PRIORITY + i) << DMA_PRIO_REG_SHIFT(i));
>  	}
>  
> -	/* Set ring 16 priority and program the hardware registers */
> +	/* Initialize Tx default queue 16 */
> +	bcmgenet_init_tx_ring(priv, DESC_INDEX, GENET_Q16_TX_BD_CNT,
> +			      priv->hw_params->tx_queues *
> +			      priv->hw_params->tx_bds_cnt, TOTAL_DESC);
> +	ring_cfg |= (1 << DESC_INDEX);
> +	dma_ctrl |= (1 << (DESC_INDEX + DMA_RING_BUF_EN_SHIFT));
>  	dma_priority[DMA_PRIO_REG_INDEX(DESC_INDEX)] |=
>  		((GENET_Q0_PRIORITY + priv->hw_params->tx_queues) <<
>  		 DMA_PRIO_REG_SHIFT(DESC_INDEX));
> +
> +	/* Set Tx ring priorities */
>  	bcmgenet_tdma_writel(priv, dma_priority[0], DMA_PRIORITY_0);
>  	bcmgenet_tdma_writel(priv, dma_priority[1], DMA_PRIORITY_1);
>  	bcmgenet_tdma_writel(priv, dma_priority[2], DMA_PRIORITY_2);
>  
>  	/* Enable rings */
> -	reg = bcmgenet_tdma_readl(priv, DMA_RING_CFG);
> -	reg |= ring_cfg;
> -	bcmgenet_tdma_writel(priv, reg, DMA_RING_CFG);
> +	bcmgenet_tdma_writel(priv, ring_cfg, DMA_RING_CFG);
>  
>  	/* Configure ring as descriptor ring and re-enable DMA if enabled */
> -	reg = bcmgenet_tdma_readl(priv, DMA_CTRL);
> -	reg |= dma_ctrl;
>  	if (dma_enable)
> -		reg |= DMA_EN;
> -	bcmgenet_tdma_writel(priv, reg, DMA_CTRL);
> +		dma_ctrl |= DMA_EN;
> +	bcmgenet_tdma_writel(priv, dma_ctrl, DMA_CTRL);
> +}
> +
> +static void bcmgenet_init_rx_queues(struct net_device *dev)
> +{
> +	struct bcmgenet_priv *priv = netdev_priv(dev);
> +	unsigned int i, dma_enable;
> +	u32 dma_ctrl, ring_cfg;
> +
> +	dma_ctrl = bcmgenet_rdma_readl(priv, DMA_CTRL);
> +	dma_enable = dma_ctrl & DMA_EN;
> +	dma_ctrl &= ~DMA_EN;
> +	bcmgenet_rdma_writel(priv, dma_ctrl, DMA_CTRL);
> +
> +	dma_ctrl = 0;
> +	ring_cfg = 0;
> +
> +	/* Initialize Rx priority queues */
> +	for (i = 0; i < priv->hw_params->rx_queues; i++) {
> +		bcmgenet_init_rx_ring(priv, i, priv->hw_params->rx_bds_cnt,
> +				      i * priv->hw_params->rx_bds_cnt,
> +				      (i + 1) * priv->hw_params->rx_bds_cnt);
> +		ring_cfg |= (1 << i);
> +		dma_ctrl |= (1 << (i + DMA_RING_BUF_EN_SHIFT));
> +	}
> +
> +	/* Initialize Rx default queue 16 */
> +	bcmgenet_init_rx_ring(priv, DESC_INDEX, GENET_Q16_RX_BD_CNT,
> +			      priv->hw_params->rx_queues *
> +			      priv->hw_params->rx_bds_cnt, TOTAL_DESC);
> +	ring_cfg |= (1 << DESC_INDEX);
> +	dma_ctrl |= (1 << (DESC_INDEX + DMA_RING_BUF_EN_SHIFT));
> +
> +	/* Enable rings */
> +	bcmgenet_rdma_writel(priv, ring_cfg, DMA_RING_CFG);
> +
> +	/* Configure ring as descriptor ring and re-enable DMA if enabled */
> +	if (dma_enable)
> +		dma_ctrl |= DMA_EN;
> +	bcmgenet_rdma_writel(priv, dma_ctrl, DMA_CTRL);
>  }
>  
>  static int bcmgenet_dma_teardown(struct bcmgenet_priv *priv)
> @@ -1928,24 +1986,28 @@ static void bcmgenet_fini_dma(struct bcmgenet_priv *priv)
>  /* init_edma: Initialize DMA control register */
>  static int bcmgenet_init_dma(struct bcmgenet_priv *priv)
>  {
> -	int ret;
> +	netif_dbg(priv, hw, priv->dev, "bcmgenet: init_dma\n");
>  
> -	netif_dbg(priv, hw, priv->dev, "bcmgenet: init_edma\n");
> +	/* init rDma */
> +	bcmgenet_rdma_writel(priv, DMA_MAX_BURST_LENGTH, DMA_SCB_BURST_SIZE);
>  
> -	/* by default, enable ring 16 (descriptor based) */
> -	ret = bcmgenet_init_rx_ring(priv, DESC_INDEX, TOTAL_DESC);
> -	if (ret) {
> -		netdev_err(priv->dev, "failed to initialize RX ring\n");
> -		return ret;
> +	/* init common Rx ring structures */
> +	priv->rx_bds = priv->base + priv->hw_params->rdma_offset;
> +	priv->num_rx_bds = TOTAL_DESC;
> +	priv->rx_cbs = kcalloc(priv->num_rx_bds, sizeof(struct enet_cb),
> +			       GFP_KERNEL);
> +	if (!priv->rx_cbs) {
> +		bcmgenet_fini_dma(priv);
> +		return -ENOMEM;
>  	}
>  
> -	/* init rDma */
> -	bcmgenet_rdma_writel(priv, DMA_MAX_BURST_LENGTH, DMA_SCB_BURST_SIZE);
> +	/* init Rx queues */
> +	bcmgenet_init_rx_queues(priv->dev);
>  
> -	/* Init tDma */
> +	/* init tDma */
>  	bcmgenet_tdma_writel(priv, DMA_MAX_BURST_LENGTH, DMA_SCB_BURST_SIZE);
>  
> -	/* Initialize common TX ring structures */
> +	/* init common Tx ring structures */
>  	priv->tx_bds = priv->base + priv->hw_params->tdma_offset;
>  	priv->num_tx_bds = TOTAL_DESC;
>  	priv->tx_cbs = kcalloc(priv->num_tx_bds, sizeof(struct enet_cb),
> @@ -1955,38 +2017,75 @@ static int bcmgenet_init_dma(struct bcmgenet_priv *priv)
>  		return -ENOMEM;
>  	}
>  
> -	/* initialize multi xmit queue */
> -	bcmgenet_init_multiq(priv->dev);
> -
> -	/* initialize special ring 16 */
> -	bcmgenet_init_tx_ring(priv, DESC_INDEX, GENET_DEFAULT_BD_CNT,
> -			      priv->hw_params->tx_queues *
> -			      priv->hw_params->bds_cnt,
> -			      TOTAL_DESC);
> +	/* init Tx queues */
> +	bcmgenet_init_tx_queues(priv->dev);
>  
>  	return 0;
>  }
>  
> -/* NAPI polling method*/
> +/* NAPI polling method for Rx and Tx default queues */
>  static int bcmgenet_poll(struct napi_struct *napi, int budget)
>  {
> -	struct bcmgenet_priv *priv = container_of(napi,
> -			struct bcmgenet_priv, napi);
> -	unsigned int work_done;
> +	struct bcmgenet_priv *priv =
> +			container_of(napi, struct bcmgenet_priv, napi);
> +	int work_done = 0;
>  
> -	/* tx reclaim */
> +	/* Tx default queue processing */
>  	bcmgenet_tx_reclaim(priv->dev, &priv->tx_rings[DESC_INDEX]);
>  
> -	work_done = bcmgenet_desc_rx(priv, budget);
> +	/* Rx default queue processing */
> +	work_done += bcmgenet_desc_rx(priv, DESC_INDEX, napi, budget);
> +
> +	if (work_done < budget) {
> +		napi_complete(napi);
> +		bcmgenet_intrl2_0_writel(priv,
> +				UMAC_IRQ_RXDMA_BDONE | UMAC_IRQ_RXDMA_PDONE |
> +				UMAC_IRQ_TXDMA_BDONE | UMAC_IRQ_TXDMA_PDONE,
> +				INTRL2_CPU_MASK_CLEAR);
> +	}
> +
> +	return work_done;
> +}
> +
> +/* NAPI polling method for Rx and Tx priority queues */
> +static int bcmgenet_poll_priority(struct napi_struct *napi, int budget)
> +{
> +	struct bcmgenet_priv *priv =
> +			container_of(napi, struct bcmgenet_priv, napi_priority);
> +	int work_done = 0;
> +	unsigned int index;
> +	unsigned int active_rings;
> +
> +	priv->irq1_stat |= (bcmgenet_intrl2_1_readl(priv, INTRL2_CPU_STAT) &
> +			    ~priv->int1_mask);
> +
> +	/* Tx priority queue processing */
> +	index = 0;
> +	active_rings = priv->irq1_stat & UMAC_IRQ1_TX_INTR_MASK;
> +	while (active_rings) {
> +		if (active_rings & 0x1)
> +			bcmgenet_tx_reclaim(priv->dev, &priv->tx_rings[index]);
> +		active_rings >>= 1;
> +		index++;
> +	}
> +
> +	/* Rx priority queue processing */
> +	index = 0;
> +	active_rings = (priv->irq1_stat >> UMAC_IRQ1_RX_INTR_SHIFT) &
> +			UMAC_IRQ1_RX_INTR_MASK;
> +	while (active_rings && work_done < budget) {
> +		if (active_rings & 0x1)
> +			work_done += bcmgenet_desc_rx(priv, index, napi,
> +						      budget - work_done);
> +		active_rings >>= 1;
> +		index++;
> +	}
> +
> +	priv->irq1_stat = 0;
>  
> -	/* Advancing our consumer index*/
> -	priv->rx_c_index += work_done;
> -	priv->rx_c_index &= DMA_C_INDEX_MASK;
> -	bcmgenet_rdma_ring_writel(priv, DESC_INDEX,
> -				  priv->rx_c_index, RDMA_CONS_INDEX);
>  	if (work_done < budget) {
>  		napi_complete(napi);
> -		bcmgenet_intrl2_0_writel(priv, UMAC_IRQ_RXDMA_BDONE,
> +		bcmgenet_intrl2_1_writel(priv, ~priv->int1_mask,
>  					 INTRL2_CPU_MASK_CLEAR);
>  	}
>  
> @@ -2017,36 +2116,34 @@ static void bcmgenet_irq_task(struct work_struct *work)
>  	}
>  }
>  
> -/* bcmgenet_isr1: interrupt handler for ring buffer. */
> +/* bcmgenet_isr1: handle Rx and Tx priority queues */
>  static irqreturn_t bcmgenet_isr1(int irq, void *dev_id)
>  {
>  	struct bcmgenet_priv *priv = dev_id;
> -	unsigned int index;
>  
>  	/* Save irq status for bottom-half processing. */
>  	priv->irq1_stat =
>  		bcmgenet_intrl2_1_readl(priv, INTRL2_CPU_STAT) &
>  		~priv->int1_mask;
> +
>  	/* clear interrupts */
>  	bcmgenet_intrl2_1_writel(priv, priv->irq1_stat, INTRL2_CPU_CLEAR);
>  
>  	netif_dbg(priv, intr, priv->dev,
>  		  "%s: IRQ=0x%x\n", __func__, priv->irq1_stat);
> -	/* Check the MBDONE interrupts.
> -	 * packet is done, reclaim descriptors
> -	 */
> -	if (priv->irq1_stat & 0x0000ffff) {
> -		index = 0;
> -		for (index = 0; index < 16; index++) {
> -			if (priv->irq1_stat & (1 << index))
> -				bcmgenet_tx_reclaim(priv->dev,
> -						    &priv->tx_rings[index]);
> +
> +	if (priv->irq1_stat) {
> +		if (likely(napi_schedule_prep(&priv->napi_priority))) {
> +			bcmgenet_intrl2_1_writel(priv, ~priv->int1_mask,
> +						 INTRL2_CPU_MASK_SET);
> +			__napi_schedule(&priv->napi_priority);
>  		}
>  	}
> +
>  	return IRQ_HANDLED;
>  }
>  
> -/* bcmgenet_isr0: Handle various interrupts. */
> +/* bcmgenet_isr0: handle Rx and Tx default queues + other stuff */
>  static irqreturn_t bcmgenet_isr0(int irq, void *dev_id)
>  {
>  	struct bcmgenet_priv *priv = dev_id;
> @@ -2054,29 +2151,25 @@ static irqreturn_t bcmgenet_isr0(int irq, void *dev_id)
>  	/* Save irq status for bottom-half processing. */
>  	priv->irq0_stat =
>  		bcmgenet_intrl2_0_readl(priv, INTRL2_CPU_STAT) &
> -		~bcmgenet_intrl2_0_readl(priv, INTRL2_CPU_MASK_STATUS);
> +		~priv->int0_mask;
> +
>  	/* clear interrupts */
>  	bcmgenet_intrl2_0_writel(priv, priv->irq0_stat, INTRL2_CPU_CLEAR);
>  
>  	netif_dbg(priv, intr, priv->dev,
>  		  "IRQ=0x%x\n", priv->irq0_stat);
>  
> -	if (priv->irq0_stat & (UMAC_IRQ_RXDMA_BDONE | UMAC_IRQ_RXDMA_PDONE)) {
> -		/* We use NAPI(software interrupt throttling, if
> -		 * Rx Descriptor throttling is not used.
> -		 * Disable interrupt, will be enabled in the poll method.
> -		 */
> +	if (priv->irq0_stat & (UMAC_IRQ_RXDMA_BDONE | UMAC_IRQ_RXDMA_PDONE |
> +				UMAC_IRQ_TXDMA_BDONE | UMAC_IRQ_TXDMA_PDONE)) {
>  		if (likely(napi_schedule_prep(&priv->napi))) {
> -			bcmgenet_intrl2_0_writel(priv, UMAC_IRQ_RXDMA_BDONE,
> -						 INTRL2_CPU_MASK_SET);
> +			bcmgenet_intrl2_0_writel(priv,
> +				UMAC_IRQ_RXDMA_BDONE | UMAC_IRQ_RXDMA_PDONE |
> +				UMAC_IRQ_TXDMA_BDONE | UMAC_IRQ_TXDMA_PDONE,
> +				INTRL2_CPU_MASK_SET);
>  			__napi_schedule(&priv->napi);
>  		}
>  	}
> -	if (priv->irq0_stat &
> -			(UMAC_IRQ_TXDMA_BDONE | UMAC_IRQ_TXDMA_PDONE)) {
> -		/* Tx reclaim */
> -		bcmgenet_tx_reclaim(priv->dev, &priv->tx_rings[DESC_INDEX]);
> -	}
> +
>  	if (priv->irq0_stat & (UMAC_IRQ_PHY_DET_R |
>  				UMAC_IRQ_PHY_DET_F |
>  				UMAC_IRQ_LINK_UP |
> @@ -2170,6 +2263,7 @@ static void bcmgenet_netif_start(struct net_device *dev)
>  
>  	/* Start the network engine */
>  	napi_enable(&priv->napi);
> +	napi_enable(&priv->napi_priority);
>  
>  	umac_enable_set(priv, CMD_TX_EN | CMD_RX_EN, true);
>  
> @@ -2269,6 +2363,7 @@ static void bcmgenet_netif_stop(struct net_device *dev)
>  
>  	netif_tx_stop_all_queues(dev);
>  	napi_disable(&priv->napi);
> +	napi_disable(&priv->napi_priority);
>  	phy_stop(priv->phydev);
>  
>  	bcmgenet_intr_disable(priv);
> @@ -2436,8 +2531,9 @@ static const struct net_device_ops bcmgenet_netdev_ops = {
>  static struct bcmgenet_hw_params bcmgenet_hw_params[] = {
>  	[GENET_V1] = {
>  		.tx_queues = 0,
> +		.tx_bds_cnt = 0,
>  		.rx_queues = 0,
> -		.bds_cnt = 0,
> +		.rx_bds_cnt = 0,
>  		.bp_in_en_shift = 16,
>  		.bp_in_mask = 0xffff,
>  		.hfb_filter_cnt = 16,
> @@ -2449,8 +2545,9 @@ static struct bcmgenet_hw_params bcmgenet_hw_params[] = {
>  	},
>  	[GENET_V2] = {
>  		.tx_queues = 4,
> -		.rx_queues = 4,
> -		.bds_cnt = 32,
> +		.tx_bds_cnt = 32,
> +		.rx_queues = 0,
> +		.rx_bds_cnt = 0,
>  		.bp_in_en_shift = 16,
>  		.bp_in_mask = 0xffff,
>  		.hfb_filter_cnt = 16,
> @@ -2465,8 +2562,9 @@ static struct bcmgenet_hw_params bcmgenet_hw_params[] = {
>  	},
>  	[GENET_V3] = {
>  		.tx_queues = 4,
> -		.rx_queues = 4,
> -		.bds_cnt = 32,
> +		.tx_bds_cnt = 32,
> +		.rx_queues = 0,
> +		.rx_bds_cnt = 0,
>  		.bp_in_en_shift = 17,
>  		.bp_in_mask = 0x1ffff,
>  		.hfb_filter_cnt = 48,
> @@ -2481,8 +2579,9 @@ static struct bcmgenet_hw_params bcmgenet_hw_params[] = {
>  	},
>  	[GENET_V4] = {
>  		.tx_queues = 4,
> -		.rx_queues = 4,
> -		.bds_cnt = 32,
> +		.tx_bds_cnt = 32,
> +		.rx_queues = 0,
> +		.rx_bds_cnt = 0,
>  		.bp_in_en_shift = 17,
>  		.bp_in_mask = 0x1ffff,
>  		.hfb_filter_cnt = 48,
> @@ -2560,14 +2659,15 @@ static void bcmgenet_set_hw_params(struct bcmgenet_priv *priv)
>  #endif
>  
>  	pr_debug("Configuration for version: %d\n"
> -		"TXq: %1d, RXq: %1d, BDs: %1d\n"
> +		"TXq: %1d, TXBDs: %1d, RXq: %1d, RXBDs: %1d\n"
>  		"BP << en: %2d, BP msk: 0x%05x\n"
>  		"HFB count: %2d, QTAQ msk: 0x%05x\n"
>  		"TBUF: 0x%04x, HFB: 0x%04x, HFBreg: 0x%04x\n"
>  		"RDMA: 0x%05x, TDMA: 0x%05x\n"
>  		"Words/BD: %d\n",
>  		priv->version,
> -		params->tx_queues, params->rx_queues, params->bds_cnt,
> +		params->tx_queues, params->tx_bds_cnt,
> +		params->rx_queues, params->rx_bds_cnt,
>  		params->bp_in_en_shift, params->bp_in_mask,
>  		params->hfb_filter_cnt, params->qtag_mask,
>  		params->tbuf_offset, params->hfb_offset,
> @@ -2594,8 +2694,9 @@ static int bcmgenet_probe(struct platform_device *pdev)
>  	struct resource *r;
>  	int err = -EIO;
>  
> -	/* Up to GENET_MAX_MQ_CNT + 1 TX queues and a single RX queue */
> -	dev = alloc_etherdev_mqs(sizeof(*priv), GENET_MAX_MQ_CNT + 1, 1);
> +	/* Up to GENET_MAX_MQ_CNT + 1 TX queues and RX queues */
> +	dev = alloc_etherdev_mqs(sizeof(*priv), GENET_MAX_MQ_CNT + 1,
> +				 GENET_MAX_MQ_CNT + 1);
>  	if (!dev) {
>  		dev_err(&pdev->dev, "can't allocate net device\n");
>  		return -ENOMEM;
> @@ -2635,7 +2736,8 @@ static int bcmgenet_probe(struct platform_device *pdev)
>  	dev->watchdog_timeo = 2 * HZ;
>  	dev->ethtool_ops = &bcmgenet_ethtool_ops;
>  	dev->netdev_ops = &bcmgenet_netdev_ops;
> -	netif_napi_add(dev, &priv->napi, bcmgenet_poll, 64);
> +	netif_napi_add(dev, &priv->napi, bcmgenet_poll, 16);
> +	netif_napi_add(dev, &priv->napi_priority, bcmgenet_poll_priority, 64);
>  
>  	priv->msg_enable = netif_msg_init(-1, GENET_MSG_DEFAULT);
>  
> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
> index b36ddec..80d9715 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
> @@ -310,6 +310,11 @@ struct bcmgenet_mib_counters {
>  #define UMAC_IRQ_MDIO_DONE		(1 << 23)
>  #define UMAC_IRQ_MDIO_ERROR		(1 << 24)
>  
> +/* INTRL2 instance 1 definitions */
> +#define UMAC_IRQ1_TX_INTR_MASK		0xFFFF
> +#define UMAC_IRQ1_RX_INTR_MASK		0xFFFF
> +#define UMAC_IRQ1_RX_INTR_SHIFT		16
> +
>  /* Register block offsets */
>  #define GENET_SYS_OFF			0x0000
>  #define GENET_GR_BRIDGE_OFF		0x0040
> @@ -503,8 +508,9 @@ enum bcmgenet_version {
>   */
>  struct bcmgenet_hw_params {
>  	u8		tx_queues;
> +	u8		tx_bds_cnt;
>  	u8		rx_queues;
> -	u8		bds_cnt;
> +	u8		rx_bds_cnt;
>  	u8		bp_in_en_shift;
>  	u32		bp_in_mask;
>  	u8		hfb_filter_cnt;
> @@ -536,6 +542,18 @@ struct bcmgenet_tx_ring {
>  			    struct bcmgenet_tx_ring *);
>  };
>  
> +struct bcmgenet_rx_ring {
> +	unsigned int	index;		/* Rx ring index */
> +	struct enet_cb	*cbs;		/* Rx ring buffer control block */
> +	unsigned int	size;		/* Rx ring size */
> +	unsigned int	c_index;	/* Rx last consumer index */
> +	unsigned int	read_ptr;	/* Rx ring read pointer */
> +	unsigned int	cb_ptr;		/* Rx ring initial CB ptr */
> +	unsigned int	end_ptr;	/* Rx ring end CB ptr */
> +	void __iomem	*bd_assign_ptr;	/* Rx ring refill ptr */
> +	unsigned int	bd_assign_idx;	/* Rx ring refill index */
> +};
> +
>  /* device context */
>  struct bcmgenet_priv {
>  	void __iomem *base;
> @@ -546,6 +564,7 @@ struct bcmgenet_priv {
>  
>  	/* NAPI for descriptor based rx */
>  	struct napi_struct napi ____cacheline_aligned;
> +	struct napi_struct napi_priority ____cacheline_aligned;
>  
>  	/* transmit variables */
>  	void __iomem *tx_bds;
> @@ -556,13 +575,11 @@ struct bcmgenet_priv {
>  
>  	/* receive variables */
>  	void __iomem *rx_bds;
> -	void __iomem *rx_bd_assign_ptr;
> -	int rx_bd_assign_index;
>  	struct enet_cb *rx_cbs;
>  	unsigned int num_rx_bds;
>  	unsigned int rx_buf_len;
> -	unsigned int rx_read_ptr;
> -	unsigned int rx_c_index;
> +
> +	struct bcmgenet_rx_ring rx_rings[DESC_INDEX + 1];
>  
>  	/* other misc variables */
>  	struct bcmgenet_hw_params *hw_params;
> 
