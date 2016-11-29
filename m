From: Marcin Wojtas <mw@semihalf.com>
Subject: Re: [PATCH v3 net-next 2/6] net: mvneta: Use cacheable memory to
 store the rx buffer virtual address
Date: Tue, 29 Nov 2016 10:50:39 +0100
Message-ID: <CAPv3WKcn27QsqLamzS2QV-RF1GD3bgsYCYD-2q9tpTtqF+eiWQ@mail.gmail.com>
References: <cover.a09aeaf5ba62853d595153626b6121ef52a3e9b4.1480412215.git-series.gregory.clement@free-electrons.com>
 <a010f2cde3de80132d82acb2812b82343ea54c95.1480412215.git-series.gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        Jisheng Zhang <jszhang@marvell.com>,
        Arnd Bergmann <arnd@arndb.de>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        Nadav Haklai <nadavh@marvell.com>,
        Dmitri Epshtein <dima@marvell.com>,
        Yelena Krivosheev <yelena@marvell.com>
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a010f2cde3de80132d82acb2812b82343ea54c95.1480412215.git-series.gregory.clement@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Gregory,

Apparently HWBM had a mistake in implementation, please see below.

2016-11-29 10:37 GMT+01:00 Gregory CLEMENT <gregory.clement@free-electrons.com>:
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
> ---
>  drivers/net/ethernet/marvell/mvneta.c | 93 ++++++++++++++++++++++++----
>  1 file changed, 81 insertions(+), 12 deletions(-)
>
> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
> index 1b84f746d748..32b142d0e44e 100644
> --- a/drivers/net/ethernet/marvell/mvneta.c
> +++ b/drivers/net/ethernet/marvell/mvneta.c
> @@ -561,6 +561,9 @@ struct mvneta_rx_queue {
>         u32 pkts_coal;
>         u32 time_coal;
>
> +       /* Virtual address of the RX buffer */
> +       void  **buf_virt_addr;
> +
>         /* Virtual address of the RX DMA descriptors array */
>         struct mvneta_rx_desc *descs;
>
> @@ -1573,10 +1576,14 @@ static void mvneta_tx_done_pkts_coal_set(struct mvneta_port *pp,
>
>  /* Handle rx descriptor fill by setting buf_cookie and buf_phys_addr */
>  static void mvneta_rx_desc_fill(struct mvneta_rx_desc *rx_desc,
> -                               u32 phys_addr, u32 cookie)
> +                               u32 phys_addr, void *virt_addr,
> +                               struct mvneta_rx_queue *rxq)
>  {
> -       rx_desc->buf_cookie = cookie;
> +       int i;
> +
>         rx_desc->buf_phys_addr = phys_addr;
> +       i = rx_desc - rxq->descs;
> +       rxq->buf_virt_addr[i] = virt_addr;
>  }
>
>  /* Decrement sent descriptors counter */
> @@ -1781,7 +1788,8 @@ EXPORT_SYMBOL_GPL(mvneta_frag_free);
>
>  /* Refill processing for SW buffer management */
>  static int mvneta_rx_refill(struct mvneta_port *pp,
> -                           struct mvneta_rx_desc *rx_desc)
> +                           struct mvneta_rx_desc *rx_desc,
> +                           struct mvneta_rx_queue *rxq)
>
>  {
>         dma_addr_t phys_addr;
> @@ -1799,7 +1807,7 @@ static int mvneta_rx_refill(struct mvneta_port *pp,
>                 return -ENOMEM;
>         }
>
> -       mvneta_rx_desc_fill(rx_desc, phys_addr, (u32)data);
> +       mvneta_rx_desc_fill(rx_desc, phys_addr, data, rxq);
>         return 0;
>  }
>
> @@ -1861,7 +1869,12 @@ static void mvneta_rxq_drop_pkts(struct mvneta_port *pp,
>
>         for (i = 0; i < rxq->size; i++) {
>                 struct mvneta_rx_desc *rx_desc = rxq->descs + i;
> -               void *data = (void *)rx_desc->buf_cookie;
> +               void *data;
> +
> +               if (!pp->bm_priv)
> +                       data = rxq->buf_virt_addr[i];
> +               else
> +                       data = (void *)(uintptr_t)rx_desc->buf_cookie;
>
>                 dma_unmap_single(pp->dev->dev.parent, rx_desc->buf_phys_addr,
>                                  MVNETA_RX_BUF_SIZE(pp->pkt_size), DMA_FROM_DEVICE);
> @@ -1894,12 +1907,13 @@ static int mvneta_rx_swbm(struct mvneta_port *pp, int rx_todo,
>                 unsigned char *data;
>                 dma_addr_t phys_addr;
>                 u32 rx_status, frag_size;
> -               int rx_bytes, err;
> +               int rx_bytes, err, index;
>
>                 rx_done++;
>                 rx_status = rx_desc->status;
>                 rx_bytes = rx_desc->data_size - (ETH_FCS_LEN + MVNETA_MH_SIZE);
> -               data = (unsigned char *)rx_desc->buf_cookie;
> +               index = rx_desc - rxq->descs;
> +               data = (unsigned char *)rxq->buf_virt_addr[index];
>                 phys_addr = rx_desc->buf_phys_addr;
>
>                 if (!mvneta_rxq_desc_is_first_last(rx_status) ||
> @@ -1938,7 +1952,7 @@ static int mvneta_rx_swbm(struct mvneta_port *pp, int rx_todo,
>                 }
>
>                 /* Refill processing */
> -               err = mvneta_rx_refill(pp, rx_desc);
> +               err = mvneta_rx_refill(pp, rx_desc, rxq);
>                 if (err) {
>                         netdev_err(dev, "Linux processing - Can't refill\n");
>                         rxq->missed++;
> @@ -2020,7 +2034,7 @@ static int mvneta_rx_hwbm(struct mvneta_port *pp, int rx_todo,
>                 rx_done++;
>                 rx_status = rx_desc->status;
>                 rx_bytes = rx_desc->data_size - (ETH_FCS_LEN + MVNETA_MH_SIZE);
> -               data = (unsigned char *)rx_desc->buf_cookie;
> +               data = (u8 *)(uintptr_t)rx_desc->buf_cookie;
>                 phys_addr = rx_desc->buf_phys_addr;
>                 pool_id = MVNETA_RX_GET_BM_POOL_ID(rx_desc);
>                 bm_pool = &pp->bm_priv->bm_pools[pool_id];
> @@ -2708,6 +2722,56 @@ static int mvneta_poll(struct napi_struct *napi, int budget)
>         return rx_done;
>  }
>
> +/* Refill processing for HW buffer management */
> +static int mvneta_rx_hwbm_refill(struct mvneta_port *pp,
> +                                struct mvneta_rx_desc *rx_desc)
> +
> +{
> +       dma_addr_t phys_addr;
> +       void *data;
> +
> +       data = mvneta_frag_alloc(pp->frag_size);
> +       if (!data)
> +               return -ENOMEM;
> +
> +       phys_addr = dma_map_single(pp->dev->dev.parent, data,
> +                                  MVNETA_RX_BUF_SIZE(pp->pkt_size),
> +                                  DMA_FROM_DEVICE);
> +       if (unlikely(dma_mapping_error(pp->dev->dev.parent, phys_addr))) {
> +               mvneta_frag_free(pp->frag_size, data);
> +               return -ENOMEM;
> +       }
> +
> +       rx_desc->buf_phys_addr = phys_addr;
> +       rx_desc->buf_cookie = (uintptr_t)data;
> +
> +       return 0;
> +}
> +
> +/* Handle rxq fill: allocates rxq skbs; called when initializing a port */
> +static int mvneta_rxq_bm_fill(struct mvneta_port *pp,
> +                             struct mvneta_rx_queue *rxq,
> +                             int num)
> +{
> +       int i;
> +
> +       for (i = 0; i < num; i++) {
> +               memset(rxq->descs + i, 0, sizeof(struct mvneta_rx_desc));
> +               if (mvneta_rx_hwbm_refill(pp, rxq->descs + i) != 0) {
> +                       netdev_err(pp->dev, "%s:rxq %d, %d of %d buffs  filled\n",
> +                                  __func__, rxq->id, i, num);
> +                       break;
> +               }
> +       }
> +
> +       /* Add this number of RX descriptors as non occupied (ready to
> +        * get packets)
> +        */
> +       mvneta_rxq_non_occup_desc_add(pp, rxq, i);
> +
> +       return i;
> +}
> +
>  /* Handle rxq fill: allocates rxq skbs; called when initializing a port */
>  static int mvneta_rxq_fill(struct mvneta_port *pp, struct mvneta_rx_queue *rxq,
>                            int num)
> @@ -2716,7 +2780,7 @@ static int mvneta_rxq_fill(struct mvneta_port *pp, struct mvneta_rx_queue *rxq,
>
>         for (i = 0; i < num; i++) {
>                 memset(rxq->descs + i, 0, sizeof(struct mvneta_rx_desc));
> -               if (mvneta_rx_refill(pp, rxq->descs + i) != 0) {
> +               if (mvneta_rx_refill(pp, rxq->descs + i, rxq) != 0) {
>                         netdev_err(pp->dev, "%s:rxq %d, %d of %d buffs  filled\n",
>                                 __func__, rxq->id, i, num);
>                         break;
> @@ -2784,14 +2848,14 @@ static int mvneta_rxq_init(struct mvneta_port *pp,
>                 mvneta_rxq_buf_size_set(pp, rxq,
>                                         MVNETA_RX_BUF_SIZE(pp->pkt_size));
>                 mvneta_rxq_bm_disable(pp, rxq);
> +               mvneta_rxq_fill(pp, rxq, rxq->size);
>         } else {
>                 mvneta_rxq_bm_enable(pp, rxq);
>                 mvneta_rxq_long_pool_set(pp, rxq);
>                 mvneta_rxq_short_pool_set(pp, rxq);
> +               mvneta_rxq_bm_fill(pp, rxq, rxq->size);

Manual filling descriptors with new buffers is redundant. For HWBM,
all buffers are allocated in mvneta_bm_construct() and in runtime they
are put into descriptors by hardware. I think it's enough to add here:
mvneta_rxq_non_occup_desc_add(pp, rxq, rxq->size);

And remove mvneta_rxq_bm_fill and mvneta_rx_hwbm_refill.

Best regards,
Marcin
