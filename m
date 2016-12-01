From: Jisheng Zhang <jszhang@marvell.com>
Subject: Re: [PATCH v5 net-next 3/7] net: mvneta: Use cacheable memory to
 store the rx buffer virtual address
Date: Thu, 1 Dec 2016 19:38:10 +0800
Message-ID: <20161201193810.3192310f@xhacker>
References: <cover.0270f6d2413a709521fe2c8c17fbebea6f2e78d1.1480542157.git-series.gregory.clement@free-electrons.com>
 <2e54b7711de0b971a7a9ee3662dad02d12bec385.1480542157.git-series.gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 Andrew Lunn <andrew@lunn.ch>, Jason Cooper <jason@lakedaemon.net>,
 Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, Dmitri Epshtein <dima@marvell.com>,
 Nadav Haklai <nadavh@marvell.com>, Yelena Krivosheev <yelena@marvell.com>,
 Marcin Wojtas <mw@semihalf.com>, "David S. Miller" <davem@davemloft.net>,
 linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <2e54b7711de0b971a7a9ee3662dad02d12bec385.1480542157.git-series.gregory.clement@free-electrons.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Wed, 30 Nov 2016 22:42:48 +0100 Gregory CLEMENT wrote:

> Until now the virtual address of the received buffer were stored in the
> cookie field of the rx descriptor. However, this field is 32-bits only
> which prevents to use the driver on a 64-bits architecture.
> 
> With this patch the virtual address is stored in an array not shared with
> the hardware (no more need to use the DMA API). Thanks to this, it is
> possible to use cache contrary to the access of the rx descriptor member.
> 
> The change is done in the swbm path only because the hwbm uses the cookie
> field, this also means that currently the hwbm is not usable in 64-bits.
> 
> Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>

Reviewed-by: Jisheng Zhang <jszhang@marvell.com>

Thanks,
Jisheng

> ---
>  drivers/net/ethernet/marvell/mvneta.c | 34 +++++++++++++++++++---------
>  1 file changed, 24 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
> index f5319c50f8d9..92b9af14c352 100644
> --- a/drivers/net/ethernet/marvell/mvneta.c
> +++ b/drivers/net/ethernet/marvell/mvneta.c
> @@ -561,6 +561,9 @@ struct mvneta_rx_queue {
>  	u32 pkts_coal;
>  	u32 time_coal;
>  
> +	/* Virtual address of the RX buffer */
> +	void  **buf_virt_addr;
> +
>  	/* Virtual address of the RX DMA descriptors array */
>  	struct mvneta_rx_desc *descs;
>  
> @@ -1573,10 +1576,14 @@ static void mvneta_tx_done_pkts_coal_set(struct mvneta_port *pp,
>  
>  /* Handle rx descriptor fill by setting buf_cookie and buf_phys_addr */
>  static void mvneta_rx_desc_fill(struct mvneta_rx_desc *rx_desc,
> -				u32 phys_addr, u32 cookie)
> +				u32 phys_addr, void *virt_addr,
> +				struct mvneta_rx_queue *rxq)
>  {
> -	rx_desc->buf_cookie = cookie;
> +	int i;
> +
>  	rx_desc->buf_phys_addr = phys_addr;
> +	i = rx_desc - rxq->descs;
> +	rxq->buf_virt_addr[i] = virt_addr;
>  }
>  
>  /* Decrement sent descriptors counter */
> @@ -1781,7 +1788,8 @@ EXPORT_SYMBOL_GPL(mvneta_frag_free);
>  
>  /* Refill processing for SW buffer management */
>  static int mvneta_rx_refill(struct mvneta_port *pp,
> -			    struct mvneta_rx_desc *rx_desc)
> +			    struct mvneta_rx_desc *rx_desc,
> +			    struct mvneta_rx_queue *rxq)
>  
>  {
>  	dma_addr_t phys_addr;
> @@ -1799,7 +1807,7 @@ static int mvneta_rx_refill(struct mvneta_port *pp,
>  		return -ENOMEM;
>  	}
>  
> -	mvneta_rx_desc_fill(rx_desc, phys_addr, (u32)data);
> +	mvneta_rx_desc_fill(rx_desc, phys_addr, data, rxq);
>  	return 0;
>  }
>  
> @@ -1861,7 +1869,7 @@ static void mvneta_rxq_drop_pkts(struct mvneta_port *pp,
>  
>  	for (i = 0; i < rxq->size; i++) {
>  		struct mvneta_rx_desc *rx_desc = rxq->descs + i;
> -		void *data = (void *)rx_desc->buf_cookie;
> +		void *data = rxq->buf_virt_addr[i];
>  
>  		dma_unmap_single(pp->dev->dev.parent, rx_desc->buf_phys_addr,
>  				 MVNETA_RX_BUF_SIZE(pp->pkt_size), DMA_FROM_DEVICE);
> @@ -1894,12 +1902,13 @@ static int mvneta_rx_swbm(struct mvneta_port *pp, int rx_todo,
>  		unsigned char *data;
>  		dma_addr_t phys_addr;
>  		u32 rx_status, frag_size;
> -		int rx_bytes, err;
> +		int rx_bytes, err, index;
>  
>  		rx_done++;
>  		rx_status = rx_desc->status;
>  		rx_bytes = rx_desc->data_size - (ETH_FCS_LEN + MVNETA_MH_SIZE);
> -		data = (unsigned char *)rx_desc->buf_cookie;
> +		index = rx_desc - rxq->descs;
> +		data = rxq->buf_virt_addr[index];
>  		phys_addr = rx_desc->buf_phys_addr;
>  
>  		if (!mvneta_rxq_desc_is_first_last(rx_status) ||
> @@ -1938,7 +1947,7 @@ static int mvneta_rx_swbm(struct mvneta_port *pp, int rx_todo,
>  		}
>  
>  		/* Refill processing */
> -		err = mvneta_rx_refill(pp, rx_desc);
> +		err = mvneta_rx_refill(pp, rx_desc, rxq);
>  		if (err) {
>  			netdev_err(dev, "Linux processing - Can't refill\n");
>  			rxq->missed++;
> @@ -2020,7 +2029,7 @@ static int mvneta_rx_hwbm(struct mvneta_port *pp, int rx_todo,
>  		rx_done++;
>  		rx_status = rx_desc->status;
>  		rx_bytes = rx_desc->data_size - (ETH_FCS_LEN + MVNETA_MH_SIZE);
> -		data = (unsigned char *)rx_desc->buf_cookie;
> +		data = (u8 *)(uintptr_t)rx_desc->buf_cookie;
>  		phys_addr = rx_desc->buf_phys_addr;
>  		pool_id = MVNETA_RX_GET_BM_POOL_ID(rx_desc);
>  		bm_pool = &pp->bm_priv->bm_pools[pool_id];
> @@ -2716,7 +2725,7 @@ static int mvneta_rxq_fill(struct mvneta_port *pp, struct mvneta_rx_queue *rxq,
>  
>  	for (i = 0; i < num; i++) {
>  		memset(rxq->descs + i, 0, sizeof(struct mvneta_rx_desc));
> -		if (mvneta_rx_refill(pp, rxq->descs + i) != 0) {
> +		if (mvneta_rx_refill(pp, rxq->descs + i, rxq) != 0) {
>  			netdev_err(pp->dev, "%s:rxq %d, %d of %d buffs  filled\n",
>  				__func__, rxq->id, i, num);
>  			break;
> @@ -3865,6 +3874,11 @@ static int mvneta_init(struct device *dev, struct mvneta_port *pp)
>  		rxq->size = pp->rx_ring_size;
>  		rxq->pkts_coal = MVNETA_RX_COAL_PKTS;
>  		rxq->time_coal = MVNETA_RX_COAL_USEC;
> +		rxq->buf_virt_addr = devm_kmalloc(pp->dev->dev.parent,
> +						  rxq->size * sizeof(void *),
> +						  GFP_KERNEL);
> +		if (!rxq->buf_virt_addr)
> +			return -ENOMEM;
>  	}
>  
>  	return 0;
