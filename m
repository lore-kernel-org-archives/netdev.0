From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Re: [PATCH] net: netcp: fix unused interface rx buffer size configuration
Date: Thu, 6 Aug 2015 17:17:41 -0400
Message-ID: <55C3CEF5.6040108@ti.com>
References: <1438721813-14044-1-git-send-email-w-kwok2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
To: WingMan Kwok <w-kwok2@ti.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438721813-14044-1-git-send-email-w-kwok2@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/04/2015 04:56 PM, WingMan Kwok wrote:
> Prior to this patch, rx buffer size for each rx queue
> of an interface is configurable through dts bindings.
> But for an interface, the first rx queue's rx buffer
> size is always the usual MTU size (plus usual overhead)
> and page size for the remaining rx queues (if they are
> enabled by specifying a non-zero rx queue depth dts
> binding of the corresponding interface).  This patch
> removes the rx buffer size configuration capability.
>
> Signed-off-by: WingMan Kwok <w-kwok2@ti.com>
> ---
>   drivers/net/ethernet/ti/netcp.h      |    1 -
>   drivers/net/ethernet/ti/netcp_core.c |   35 +++++++++++++---------------------
>   2 files changed, 13 insertions(+), 23 deletions(-)
>
> diff --git a/drivers/net/ethernet/ti/netcp.h b/drivers/net/ethernet/ti/netcp.h
> index a8a7306..bb1bb72 100644
> --- a/drivers/net/ethernet/ti/netcp.h
> +++ b/drivers/net/ethernet/ti/netcp.h
> @@ -85,7 +85,6 @@ struct netcp_intf {
>   	struct list_head	rxhook_list_head;
>   	unsigned int		rx_queue_id;
>   	void			*rx_fdq[KNAV_DMA_FDQ_PER_CHAN];
> -	u32			rx_buffer_sizes[KNAV_DMA_FDQ_PER_CHAN];
>   	struct napi_struct	rx_napi;
>   	struct napi_struct	tx_napi;
>
> diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
> index 9749dfd..4755838 100644
> --- a/drivers/net/ethernet/ti/netcp_core.c
> +++ b/drivers/net/ethernet/ti/netcp_core.c
> @@ -34,6 +34,7 @@
>   #define NETCP_SOP_OFFSET	(NET_IP_ALIGN + NET_SKB_PAD)
>   #define NETCP_NAPI_WEIGHT	64
>   #define NETCP_TX_TIMEOUT	(5 * HZ)
> +#define NETCP_PACKET_SIZE	(ETH_FRAME_LEN + ETH_FCS_LEN)
>   #define NETCP_MIN_PACKET_SIZE	ETH_ZLEN
>   #define NETCP_MAX_MCAST_ADDR	16
>
> @@ -804,30 +805,28 @@ static void netcp_allocate_rx_buf(struct netcp_intf *netcp, int fdq)
>   	if (likely(fdq == 0)) {
>   		unsigned int primary_buf_len;
>   		/* Allocate a primary receive queue entry */
> -		buf_len = netcp->rx_buffer_sizes[0] + NETCP_SOP_OFFSET;
> +		buf_len = NETCP_PACKET_SIZE + NETCP_SOP_OFFSET;
>   		primary_buf_len = SKB_DATA_ALIGN(buf_len) +
>   				SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
>
> -		if (primary_buf_len <= PAGE_SIZE) {
> -			bufptr = netdev_alloc_frag(primary_buf_len);
> -			pad[1] = primary_buf_len;
> -		} else {
> -			bufptr = kmalloc(primary_buf_len, GFP_ATOMIC |
> -					 GFP_DMA32 | __GFP_COLD);
> -			pad[1] = 0;
> -		}
> +		bufptr = netdev_alloc_frag(primary_buf_len);
> +		pad[1] = primary_buf_len;
>
>   		if (unlikely(!bufptr)) {
> -			dev_warn_ratelimited(netcp->ndev_dev, "Primary RX buffer alloc failed\n");
> +			dev_warn_ratelimited(netcp->ndev_dev,
> +					     "Primary RX buffer alloc failed\n");
>   			goto fail;
>   		}
>   		dma = dma_map_single(netcp->dev, bufptr, buf_len,
>   				     DMA_TO_DEVICE);
> +		if (unlikely(dma_mapping_error(netcp->dev, dma)))
> +			goto fail;
> +
>   		pad[0] = (u32)bufptr;
>
>   	} else {
>   		/* Allocate a secondary receive queue entry */
> -		page = alloc_page(GFP_ATOMIC | GFP_DMA32 | __GFP_COLD);
> +		page = alloc_page(GFP_ATOMIC | GFP_DMA | __GFP_COLD);
>   		if (unlikely(!page)) {
>   			dev_warn_ratelimited(netcp->ndev_dev, "Secondary page alloc failed\n");
>   			goto fail;
> @@ -1010,7 +1009,7 @@ netcp_tx_map_skb(struct sk_buff *skb, struct netcp_intf *netcp)
>
>   	/* Map the linear buffer */
>   	dma_addr = dma_map_single(dev, skb->data, pkt_len, DMA_TO_DEVICE);
> -	if (unlikely(!dma_addr)) {
> +	if (unlikely(dma_mapping_error(dev, dma_addr))) {
>   		dev_err(netcp->ndev_dev, "Failed to map skb buffer\n");
>   		return NULL;
>   	}
> @@ -1546,8 +1545,8 @@ static int netcp_setup_navigator_resources(struct net_device *ndev)
>   	knav_queue_disable_notify(netcp->rx_queue);
>
>   	/* open Rx FDQs */
> -	for (i = 0; i < KNAV_DMA_FDQ_PER_CHAN &&
> -	     netcp->rx_queue_depths[i] && netcp->rx_buffer_sizes[i]; ++i) {
> +	for (i = 0; i < KNAV_DMA_FDQ_PER_CHAN && netcp->rx_queue_depths[i];
> +	     ++i) {
>   		snprintf(name, sizeof(name), "rx-fdq-%s-%d", ndev->name, i);
>   		netcp->rx_fdq[i] = knav_queue_open(name, KNAV_QUEUE_GP, 0);
>   		if (IS_ERR_OR_NULL(netcp->rx_fdq[i])) {
> @@ -1941,14 +1940,6 @@ static int netcp_create_interface(struct netcp_device *netcp_device,
>   		netcp->rx_queue_depths[0] = 128;
>   	}
>
> -	ret = of_property_read_u32_array(node_interface, "rx-buffer-size",
> -					 netcp->rx_buffer_sizes,
> -					 KNAV_DMA_FDQ_PER_CHAN);
> -	if (ret) {
> -		dev_err(dev, "missing \"rx-buffer-size\" parameter\n");
> -		netcp->rx_buffer_sizes[0] = 1536;
> -	}
> -
>   	ret = of_property_read_u32_array(node_interface, "rx-pool", temp, 2);
>   	if (ret < 0) {
>   		dev_err(dev, "missing \"rx-pool\" parameter\n");
>
Acked-by: Murali Karicheri <m-karicheri2@ti.com>

-- 
Murali Karicheri
Linux Kernel, Keystone
