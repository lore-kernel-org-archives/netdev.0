From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH net-next v2 1/2] net: mvneta: avoid getting status from rx_desc as much as possible
Date: Fri, 17 Feb 2017 14:35:21 +0100
Message-ID: <87k28paqjq.fsf@free-electrons.com>
References: <20170217100233.2325-1-jszhang@marvell.com>
        <20170217100233.2325-2-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: <thomas.petazzoni@free-electrons.com>, <davem@davemloft.net>,
        <arnd@arndb.de>, <linux-arm-kernel@lists.infradead.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Jisheng Zhang <jszhang@marvell.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170217100233.2325-2-jszhang@marvell.com> (Jisheng Zhang's
        message of "Fri, 17 Feb 2017 18:02:32 +0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jisheng,
 
 On ven., févr. 17 2017, Jisheng Zhang <jszhang@marvell.com> wrote:

> In hot code path mvneta_rx_hwbm(), the rx_desc->status is read twice.
> The rx_desc is allocated by dma_alloc_coherent, it's uncacheable if
> the device isn't cache-coherent, reading from uncached memory is
> fairly slow. So reuse the read out rx_status to avoid the second
> reading from uncached memory.
>
> Signed-off-by: Jisheng Zhang <jszhang@marvell.com>
> Suggested-by: Arnd Bergmann <arnd@arndb.de>

This one is OK and I didn't see a regression:

Tested-by: Gregory CLEMENT <gregory.clement@free-electrons.com>

Gregory


> ---
>  drivers/net/ethernet/marvell/mvneta.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
> index 61dd4462411c..06df72b8da85 100644
> --- a/drivers/net/ethernet/marvell/mvneta.c
> +++ b/drivers/net/ethernet/marvell/mvneta.c
> @@ -313,8 +313,8 @@
>  	((addr >= txq->tso_hdrs_phys) && \
>  	 (addr < txq->tso_hdrs_phys + txq->size * TSO_HEADER_SIZE))
>  
> -#define MVNETA_RX_GET_BM_POOL_ID(rxd) \
> -	(((rxd)->status & MVNETA_RXD_BM_POOL_MASK) >> MVNETA_RXD_BM_POOL_SHIFT)
> +#define MVNETA_RX_GET_BM_POOL_ID(status) \
> +	(((status) & MVNETA_RXD_BM_POOL_MASK) >> MVNETA_RXD_BM_POOL_SHIFT)
>  
>  struct mvneta_statistic {
>  	unsigned short offset;
> @@ -1900,7 +1900,7 @@ static void mvneta_rxq_drop_pkts(struct mvneta_port *pp,
>  		for (i = 0; i < rx_done; i++) {
>  			struct mvneta_rx_desc *rx_desc =
>  						  mvneta_rxq_next_desc_get(rxq);
> -			u8 pool_id = MVNETA_RX_GET_BM_POOL_ID(rx_desc);
> +			u8 pool_id = MVNETA_RX_GET_BM_POOL_ID(rx_desc->status);
>  			struct mvneta_bm_pool *bm_pool;
>  
>  			bm_pool = &pp->bm_priv->bm_pools[pool_id];
> @@ -2075,7 +2075,7 @@ static int mvneta_rx_hwbm(struct mvneta_port *pp, int rx_todo,
>  		rx_bytes = rx_desc->data_size - (ETH_FCS_LEN + MVNETA_MH_SIZE);
>  		data = (u8 *)(uintptr_t)rx_desc->buf_cookie;
>  		phys_addr = rx_desc->buf_phys_addr;
> -		pool_id = MVNETA_RX_GET_BM_POOL_ID(rx_desc);
> +		pool_id = MVNETA_RX_GET_BM_POOL_ID(rx_status);
>  		bm_pool = &pp->bm_priv->bm_pools[pool_id];
>  
>  		if (!mvneta_rxq_desc_is_first_last(rx_status) ||
> -- 
> 2.11.0
>

-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
