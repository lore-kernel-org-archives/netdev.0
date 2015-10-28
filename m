From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/4] sfc: allocate rx pages on the same node as
 the interrupt
Date: Wed, 28 Oct 2015 08:59:56 -0700
Message-ID: <1446047996.7476.71.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5630E2FD.3070609@solarflare.com>
	 <5630E356.60109@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Shradha Shah <sshah@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34199 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965806AbbJ1P76 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2015 11:59:58 -0400
Received: by padhk11 with SMTP id hk11so10845162pad.1
        for <netdev@vger.kernel.org>; Wed, 28 Oct 2015 08:59:58 -0700 (PDT)
In-Reply-To: <5630E356.60109@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-10-28 at 15:01 +0000, Shradha Shah wrote:
> From: Daniel Pieczko <dpieczko@solarflare.com>
> 
> When the interrupt servicing a channel is on a NUMA node that is
> not local to the device, performance is improved by allocating
> rx pages on the node local to the interrupt (remote to the device)
> 
> The performance-optimal case, where interrupts and applications
> are pinned to CPUs on the same node as the device, is not altered
> by this change.
> 
> This change gave a 1% improvement in transaction rate using Nginx
> with all interrupts and Nginx threads on the node remote to the
> device. It also gave a small reduction in round-trip latency,
> again with the interrupt and application on a different node to
> the device.
> 
> Allocating rx pages based on the channel->irq_node value is only
> valid for the initial driver-load interrupt affinities; if an
> interrupt is moved later, the wrong node may be used for the
> allocation.
> 
> Signed-off-by: Shradha Shah <sshah@solarflare.com>
> ---
>  drivers/net/ethernet/sfc/efx.c        |  1 +
>  drivers/net/ethernet/sfc/net_driver.h |  3 +++
>  drivers/net/ethernet/sfc/rx.c         | 14 +++++++++-----
>  3 files changed, 13 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
> index 974637d..89fbd03 100644
> --- a/drivers/net/ethernet/sfc/efx.c
> +++ b/drivers/net/ethernet/sfc/efx.c
> @@ -445,6 +445,7 @@ efx_alloc_channel(struct efx_nic *efx, int i, struct efx_channel *old_channel)
>  	channel->efx = efx;
>  	channel->channel = i;
>  	channel->type = &efx_default_channel_type;
> +	channel->irq_node = NUMA_NO_NODE;
>  
>  	for (j = 0; j < EFX_TXQ_TYPES; j++) {
>  		tx_queue = &channel->tx_queue[j];
> diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
> index ad56231..0ab9080a 100644
> --- a/drivers/net/ethernet/sfc/net_driver.h
> +++ b/drivers/net/ethernet/sfc/net_driver.h
> @@ -419,6 +419,7 @@ enum efx_sync_events_state {
>   * @sync_events_state: Current state of sync events on this channel
>   * @sync_timestamp_major: Major part of the last ptp sync event
>   * @sync_timestamp_minor: Minor part of the last ptp sync event
> + * @irq_node: NUMA node of interrupt
>   */
>  struct efx_channel {
>  	struct efx_nic *efx;
> @@ -477,6 +478,8 @@ struct efx_channel {
>  	enum efx_sync_events_state sync_events_state;
>  	u32 sync_timestamp_major;
>  	u32 sync_timestamp_minor;
> +
> +	int irq_node;
>  };
>  
>  #ifdef CONFIG_NET_RX_BUSY_POLL
> diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
> index 3f0e129..c5ef1e8 100644
> --- a/drivers/net/ethernet/sfc/rx.c
> +++ b/drivers/net/ethernet/sfc/rx.c
> @@ -168,11 +168,15 @@ static int efx_init_rx_buffers(struct efx_rx_queue *rx_queue, bool atomic)
>  			 * context in such a case.  So, use __GFP_NO_WARN
>  			 * in case of atomic.
>  			 */
> -			page = alloc_pages(__GFP_COLD | __GFP_COMP |
> -					   (atomic ?
> -					    (GFP_ATOMIC | __GFP_NOWARN)
> -					    : GFP_KERNEL),
> -					   efx->rx_buffer_order);
> +			struct efx_channel *channel;
> +
> +			channel = efx_rx_queue_channel(rx_queue);
> +			page = alloc_pages_node(channel->irq_node, __GFP_COMP |
> +						(atomic ?
> +						 (GFP_ATOMIC | __GFP_NOWARN)
> +						 : GFP_KERNEL),
> +						efx->rx_buffer_order);
> +
>  			if (unlikely(page == NULL))
>  				return -ENOMEM;
>  			dma_addr =
> 


Sorry, I do not understand this patch, and why the following one is not
squashed on this one.

irq_node is always NUMA_NO_NODE (in this patch)

So you claim a 1% improvement, switching from alloc_pages(...) to
alloc_pages_node(NUMA_NO_NODE, ...) ???
