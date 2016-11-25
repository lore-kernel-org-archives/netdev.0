From: Edward Cree <ecree@solarflare.com>
Subject: Re: [patch v2 net-next] sfc: remove unneeded variable
Date: Fri, 25 Nov 2016 16:12:56 +0000
Message-ID: <2ba88df9-1335-b7e1-49bf-c8b50fc54b51@solarflare.com>
References: <20161125104304.GA5938@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Bert Kenward <bkenward@solarflare.com>, <netdev@vger.kernel.org>,
        <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>,
        Solarflare linux maintainers <linux-net-drivers@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:16782 "EHLO
        nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755412AbcKYQOJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 11:14:09 -0500
In-Reply-To: <20161125104304.GA5938@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/11/16 10:43, Dan Carpenter wrote:
> We don't use ->heap_buf after commit 46d1efd852cc ("sfc: remove Software
> TSO") so let's remove the last traces.
>
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
Acked-by: Edward Cree <ecree@solarflare.com>
> diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
> index f97f828..18aceb2 100644
> --- a/drivers/net/ethernet/sfc/net_driver.h
> +++ b/drivers/net/ethernet/sfc/net_driver.h
> @@ -139,8 +139,6 @@ struct efx_special_buffer {
>   * struct efx_tx_buffer - buffer state for a TX descriptor
>   * @skb: When @flags & %EFX_TX_BUF_SKB, the associated socket buffer to be
>   *	freed when descriptor completes
> - * @heap_buf: When @flags & %EFX_TX_BUF_HEAP, the associated heap buffer to be
> - *	freed when descriptor completes.
>   * @option: When @flags & %EFX_TX_BUF_OPTION, a NIC-specific option descriptor.
>   * @dma_addr: DMA address of the fragment.
>   * @flags: Flags for allocation and DMA mapping type
> @@ -151,10 +149,7 @@ struct efx_special_buffer {
>   * Only valid if @unmap_len != 0.
>   */
>  struct efx_tx_buffer {
> -	union {
> -		const struct sk_buff *skb;
> -		void *heap_buf;
> -	};
> +	const struct sk_buff *skb;
>  	union {
>  		efx_qword_t option;
>  		dma_addr_t dma_addr;
> @@ -166,7 +161,6 @@ struct efx_tx_buffer {
>  };
>  #define EFX_TX_BUF_CONT		1	/* not last descriptor of packet */
>  #define EFX_TX_BUF_SKB		2	/* buffer is last part of skb */
> -#define EFX_TX_BUF_HEAP		4	/* buffer was allocated with kmalloc() */
>  #define EFX_TX_BUF_MAP_SINGLE	8	/* buffer was mapped with dma_map_single() */
>  #define EFX_TX_BUF_OPTION	0x10	/* empty buffer for option descriptor */
>  
> diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
> index 1aa728c..bb07034 100644
> --- a/drivers/net/ethernet/sfc/tx.c
> +++ b/drivers/net/ethernet/sfc/tx.c
> @@ -84,8 +84,6 @@ static void efx_dequeue_buffer(struct efx_tx_queue *tx_queue,
>  		netif_vdbg(tx_queue->efx, tx_done, tx_queue->efx->net_dev,
>  			   "TX queue %d transmission id %x complete\n",
>  			   tx_queue->queue, tx_queue->read_count);
> -	} else if (buffer->flags & EFX_TX_BUF_HEAP) {
> -		kfree(buffer->heap_buf);
>  	}
>  
>  	buffer->len = 0;
