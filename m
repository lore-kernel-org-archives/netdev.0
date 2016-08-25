From: John Crispin <john@phrozen.org>
Subject: Re: [PATCH net-next v3 1/2] net: ethernet: mediatek: modify to use
 the PDMA instead of the QDMA for Ethernet RX
Date: Thu, 25 Aug 2016 14:09:44 +0200
Message-ID: <e23ea619-62ac-7a65-7d69-79a624bd605f@phrozen.org>
References: <1472091991-1814-1-git-send-email-nelson.chang@mediatek.com>
 <1472091991-1814-2-git-send-email-nelson.chang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nbd@openwrt.org,
        linux-mediatek@lists.infradead.org, nelsonch.tw@gmail.com
To: Nelson Chang <nelson.chang@mediatek.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:52317 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933048AbcHYMJ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 Aug 2016 08:09:56 -0400
In-Reply-To: <1472091991-1814-2-git-send-email-nelson.chang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 25/08/2016 04:26, Nelson Chang wrote:
> Because the PDMA has richer features than the QDMA for Ethernet RX
> (such as multiple RX rings, HW LRO, etc.),
> the patch modifies to use the PDMA to handle Ethernet RX.
> 
> Signed-off-by: Nelson Chang <nelson.chang@mediatek.com>

Acked-by: John Crispin <john@phrozen.org>


> ---
>  drivers/net/ethernet/mediatek/mtk_eth_soc.c | 76 +++++++++++++++++------------
>  drivers/net/ethernet/mediatek/mtk_eth_soc.h | 31 +++++++++++-
>  2 files changed, 74 insertions(+), 33 deletions(-)
>  mode change 100644 => 100755 drivers/net/ethernet/mediatek/mtk_eth_soc.c
>  mode change 100644 => 100755 drivers/net/ethernet/mediatek/mtk_eth_soc.h
> 
> diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> old mode 100644
> new mode 100755
> index 1801fd8..cbeb793
> --- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> +++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> @@ -342,25 +342,27 @@ static void mtk_mdio_cleanup(struct mtk_eth *eth)
>  	mdiobus_free(eth->mii_bus);
>  }
>  
> -static inline void mtk_irq_disable(struct mtk_eth *eth, u32 mask)
> +static inline void mtk_irq_disable(struct mtk_eth *eth,
> +				   unsigned reg, u32 mask)
>  {
>  	unsigned long flags;
>  	u32 val;
>  
>  	spin_lock_irqsave(&eth->irq_lock, flags);
> -	val = mtk_r32(eth, MTK_QDMA_INT_MASK);
> -	mtk_w32(eth, val & ~mask, MTK_QDMA_INT_MASK);
> +	val = mtk_r32(eth, reg);
> +	mtk_w32(eth, val & ~mask, reg);
>  	spin_unlock_irqrestore(&eth->irq_lock, flags);
>  }
>  
> -static inline void mtk_irq_enable(struct mtk_eth *eth, u32 mask)
> +static inline void mtk_irq_enable(struct mtk_eth *eth,
> +				  unsigned reg, u32 mask)
>  {
>  	unsigned long flags;
>  	u32 val;
>  
>  	spin_lock_irqsave(&eth->irq_lock, flags);
> -	val = mtk_r32(eth, MTK_QDMA_INT_MASK);
> -	mtk_w32(eth, val | mask, MTK_QDMA_INT_MASK);
> +	val = mtk_r32(eth, reg);
> +	mtk_w32(eth, val | mask, reg);
>  	spin_unlock_irqrestore(&eth->irq_lock, flags);
>  }
>  
> @@ -897,12 +899,12 @@ release_desc:
>  		 * we continue
>  		 */
>  		wmb();
> -		mtk_w32(eth, ring->calc_idx, MTK_QRX_CRX_IDX0);
> +		mtk_w32(eth, ring->calc_idx, MTK_PRX_CRX_IDX0);
>  		done++;
>  	}
>  
>  	if (done < budget)
> -		mtk_w32(eth, MTK_RX_DONE_INT, MTK_QMTK_INT_STATUS);
> +		mtk_w32(eth, MTK_RX_DONE_INT, MTK_PDMA_INT_STATUS);
>  
>  	return done;
>  }
> @@ -1012,7 +1014,7 @@ static int mtk_napi_tx(struct napi_struct *napi, int budget)
>  		return budget;
>  
>  	napi_complete(napi);
> -	mtk_irq_enable(eth, MTK_TX_DONE_INT);
> +	mtk_irq_enable(eth, MTK_QDMA_INT_MASK, MTK_TX_DONE_INT);
>  
>  	return tx_done;
>  }
> @@ -1024,12 +1026,12 @@ static int mtk_napi_rx(struct napi_struct *napi, int budget)
>  	int rx_done = 0;
>  
>  	mtk_handle_status_irq(eth);
> -	mtk_w32(eth, MTK_RX_DONE_INT, MTK_QMTK_INT_STATUS);
> +	mtk_w32(eth, MTK_RX_DONE_INT, MTK_PDMA_INT_STATUS);
>  	rx_done = mtk_poll_rx(napi, budget, eth);
>  
>  	if (unlikely(netif_msg_intr(eth))) {
> -		status = mtk_r32(eth, MTK_QMTK_INT_STATUS);
> -		mask = mtk_r32(eth, MTK_QDMA_INT_MASK);
> +		status = mtk_r32(eth, MTK_PDMA_INT_STATUS);
> +		mask = mtk_r32(eth, MTK_PDMA_INT_MASK);
>  		dev_info(eth->dev,
>  			 "done rx %d, intr 0x%08x/0x%x\n",
>  			 rx_done, status, mask);
> @@ -1038,12 +1040,12 @@ static int mtk_napi_rx(struct napi_struct *napi, int budget)
>  	if (rx_done == budget)
>  		return budget;
>  
> -	status = mtk_r32(eth, MTK_QMTK_INT_STATUS);
> +	status = mtk_r32(eth, MTK_PDMA_INT_STATUS);
>  	if (status & MTK_RX_DONE_INT)
>  		return budget;
>  
>  	napi_complete(napi);
> -	mtk_irq_enable(eth, MTK_RX_DONE_INT);
> +	mtk_irq_enable(eth, MTK_PDMA_INT_MASK, MTK_RX_DONE_INT);
>  
>  	return rx_done;
>  }
> @@ -1092,6 +1094,7 @@ static int mtk_tx_alloc(struct mtk_eth *eth)
>  	mtk_w32(eth,
>  		ring->phys + ((MTK_DMA_SIZE - 1) * sz),
>  		MTK_QTX_DRX_PTR);
> +	mtk_w32(eth, (QDMA_RES_THRES << 8) | QDMA_RES_THRES, MTK_QTX_CFG(0));
>  
>  	return 0;
>  
> @@ -1162,11 +1165,10 @@ static int mtk_rx_alloc(struct mtk_eth *eth)
>  	 */
>  	wmb();
>  
> -	mtk_w32(eth, eth->rx_ring.phys, MTK_QRX_BASE_PTR0);
> -	mtk_w32(eth, MTK_DMA_SIZE, MTK_QRX_MAX_CNT0);
> -	mtk_w32(eth, eth->rx_ring.calc_idx, MTK_QRX_CRX_IDX0);
> -	mtk_w32(eth, MTK_PST_DRX_IDX0, MTK_QDMA_RST_IDX);
> -	mtk_w32(eth, (QDMA_RES_THRES << 8) | QDMA_RES_THRES, MTK_QTX_CFG(0));
> +	mtk_w32(eth, eth->rx_ring.phys, MTK_PRX_BASE_PTR0);
> +	mtk_w32(eth, MTK_DMA_SIZE, MTK_PRX_MAX_CNT0);
> +	mtk_w32(eth, eth->rx_ring.calc_idx, MTK_PRX_CRX_IDX0);
> +	mtk_w32(eth, MTK_PST_DRX_IDX0, MTK_PDMA_RST_IDX);
>  
>  	return 0;
>  }
> @@ -1285,7 +1287,7 @@ static irqreturn_t mtk_handle_irq_rx(int irq, void *_eth)
>  
>  	if (likely(napi_schedule_prep(&eth->rx_napi))) {
>  		__napi_schedule(&eth->rx_napi);
> -		mtk_irq_disable(eth, MTK_RX_DONE_INT);
> +		mtk_irq_disable(eth, MTK_PDMA_INT_MASK, MTK_RX_DONE_INT);
>  	}
>  
>  	return IRQ_HANDLED;
> @@ -1297,7 +1299,7 @@ static irqreturn_t mtk_handle_irq_tx(int irq, void *_eth)
>  
>  	if (likely(napi_schedule_prep(&eth->tx_napi))) {
>  		__napi_schedule(&eth->tx_napi);
> -		mtk_irq_disable(eth, MTK_TX_DONE_INT);
> +		mtk_irq_disable(eth, MTK_QDMA_INT_MASK, MTK_TX_DONE_INT);
>  	}
>  
>  	return IRQ_HANDLED;
> @@ -1308,11 +1310,12 @@ static void mtk_poll_controller(struct net_device *dev)
>  {
>  	struct mtk_mac *mac = netdev_priv(dev);
>  	struct mtk_eth *eth = mac->hw;
> -	u32 int_mask = MTK_TX_DONE_INT | MTK_RX_DONE_INT;
>  
> -	mtk_irq_disable(eth, int_mask);
> +	mtk_irq_disable(eth, MTK_QDMA_INT_MASK, MTK_TX_DONE_INT);
> +	mtk_irq_disable(eth, MTK_PDMA_INT_MASK, MTK_RX_DONE_INT);
>  	mtk_handle_irq_rx(eth->irq[2], dev);
> -	mtk_irq_enable(eth, int_mask);
> +	mtk_irq_enable(eth, MTK_QDMA_INT_MASK, MTK_TX_DONE_INT);
> +	mtk_irq_enable(eth, MTK_PDMA_INT_MASK, MTK_RX_DONE_INT);
>  }
>  #endif
>  
> @@ -1327,11 +1330,15 @@ static int mtk_start_dma(struct mtk_eth *eth)
>  	}
>  
>  	mtk_w32(eth,
> -		MTK_TX_WB_DDONE | MTK_RX_DMA_EN | MTK_TX_DMA_EN |
> -		MTK_RX_2B_OFFSET | MTK_DMA_SIZE_16DWORDS |
> -		MTK_RX_BT_32DWORDS | MTK_NDP_CO_PRO,
> +		MTK_TX_WB_DDONE | MTK_TX_DMA_EN |
> +		MTK_DMA_SIZE_16DWORDS | MTK_NDP_CO_PRO,
>  		MTK_QDMA_GLO_CFG);
>  
> +	mtk_w32(eth,
> +		MTK_RX_DMA_EN | MTK_RX_2B_OFFSET |
> +		MTK_RX_BT_32DWORDS | MTK_MULTI_EN,
> +		MTK_PDMA_GLO_CFG);
> +
>  	return 0;
>  }
>  
> @@ -1349,7 +1356,8 @@ static int mtk_open(struct net_device *dev)
>  
>  		napi_enable(&eth->tx_napi);
>  		napi_enable(&eth->rx_napi);
> -		mtk_irq_enable(eth, MTK_TX_DONE_INT | MTK_RX_DONE_INT);
> +		mtk_irq_enable(eth, MTK_QDMA_INT_MASK, MTK_TX_DONE_INT);
> +		mtk_irq_enable(eth, MTK_PDMA_INT_MASK, MTK_RX_DONE_INT);
>  	}
>  	atomic_inc(&eth->dma_refcnt);
>  
> @@ -1394,7 +1402,8 @@ static int mtk_stop(struct net_device *dev)
>  	if (!atomic_dec_and_test(&eth->dma_refcnt))
>  		return 0;
>  
> -	mtk_irq_disable(eth, MTK_TX_DONE_INT | MTK_RX_DONE_INT);
> +	mtk_irq_disable(eth, MTK_QDMA_INT_MASK, MTK_TX_DONE_INT);
> +	mtk_irq_disable(eth, MTK_PDMA_INT_MASK, MTK_RX_DONE_INT);
>  	napi_disable(&eth->tx_napi);
>  	napi_disable(&eth->rx_napi);
>  
> @@ -1448,7 +1457,9 @@ static int __init mtk_hw_init(struct mtk_eth *eth)
>  
>  	/* disable delay and normal interrupt */
>  	mtk_w32(eth, 0, MTK_QDMA_DELAY_INT);
> -	mtk_irq_disable(eth, ~0);
> +	mtk_w32(eth, 0, MTK_PDMA_DELAY_INT);
> +	mtk_irq_disable(eth, MTK_QDMA_INT_MASK, ~0);
> +	mtk_irq_disable(eth, MTK_PDMA_INT_MASK, ~0);
>  	mtk_w32(eth, RST_GL_PSE, MTK_RST_GL);
>  	mtk_w32(eth, 0, MTK_RST_GL);
>  
> @@ -1504,7 +1515,8 @@ static void mtk_uninit(struct net_device *dev)
>  
>  	phy_disconnect(mac->phy_dev);
>  	mtk_mdio_cleanup(eth);
> -	mtk_irq_disable(eth, ~0);
> +	mtk_irq_disable(eth, MTK_QDMA_INT_MASK, ~0);
> +	mtk_irq_disable(eth, MTK_PDMA_INT_MASK, ~0);
>  	free_irq(eth->irq[1], dev);
>  	free_irq(eth->irq[2], dev);
>  }
> @@ -1683,7 +1695,7 @@ static void mtk_get_ethtool_stats(struct net_device *dev,
>  	}
>  
>  	do {
> -		data_src = (u64*)hwstats;
> +		data_src = (u64 *)hwstats;
>  		data_dst = data;
>  		start = u64_stats_fetch_begin_irq(&hwstats->syncp);
>  
> diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.h b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
> old mode 100644
> new mode 100755
> index f82e3ac..7c1f3f2
> --- a/drivers/net/ethernet/mediatek/mtk_eth_soc.h
> +++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
> @@ -68,6 +68,32 @@
>  /* Unicast Filter MAC Address Register - High */
>  #define MTK_GDMA_MAC_ADRH(x)	(0x50C + (x * 0x1000))
>  
> +/* PDMA RX Base Pointer Register */
> +#define MTK_PRX_BASE_PTR0	0x900
> +
> +/* PDMA RX Maximum Count Register */
> +#define MTK_PRX_MAX_CNT0	0x904
> +
> +/* PDMA RX CPU Pointer Register */
> +#define MTK_PRX_CRX_IDX0	0x908
> +
> +/* PDMA Global Configuration Register */
> +#define MTK_PDMA_GLO_CFG	0xa04
> +#define MTK_MULTI_EN		BIT(10)
> +
> +/* PDMA Reset Index Register */
> +#define MTK_PDMA_RST_IDX	0xa08
> +#define MTK_PST_DRX_IDX0	BIT(16)
> +
> +/* PDMA Delay Interrupt Register */
> +#define MTK_PDMA_DELAY_INT	0xa0c
> +
> +/* PDMA Interrupt Status Register */
> +#define MTK_PDMA_INT_STATUS	0xa20
> +
> +/* PDMA Interrupt Mask Register */
> +#define MTK_PDMA_INT_MASK	0xa28
> +
>  /* PDMA Interrupt grouping registers */
>  #define MTK_PDMA_INT_GRP1	0xa50
>  #define MTK_PDMA_INT_GRP2	0xa54
> @@ -119,13 +145,16 @@
>  
>  /* QDMA Interrupt Status Register */
>  #define MTK_QMTK_INT_STATUS	0x1A18
> +#define MTK_RX_DONE_INT3	BIT(19)
> +#define MTK_RX_DONE_INT2	BIT(18)
>  #define MTK_RX_DONE_INT1	BIT(17)
>  #define MTK_RX_DONE_INT0	BIT(16)
>  #define MTK_TX_DONE_INT3	BIT(3)
>  #define MTK_TX_DONE_INT2	BIT(2)
>  #define MTK_TX_DONE_INT1	BIT(1)
>  #define MTK_TX_DONE_INT0	BIT(0)
> -#define MTK_RX_DONE_INT		(MTK_RX_DONE_INT0 | MTK_RX_DONE_INT1)
> +#define MTK_RX_DONE_INT		(MTK_RX_DONE_INT0 | MTK_RX_DONE_INT1 | \
> +				 MTK_RX_DONE_INT2 | MTK_RX_DONE_INT3)
>  #define MTK_TX_DONE_INT		(MTK_TX_DONE_INT0 | MTK_TX_DONE_INT1 | \
>  				 MTK_TX_DONE_INT2 | MTK_TX_DONE_INT3)
>  
> 
