From: Greg Rose <gregory.v.rose@intel.com>
Subject: Re: [PATCH net-next] i40e: skb->xmit_more support
Date: Wed, 8 Oct 2014 10:02:58 -0700
Message-ID: <20141008100258.00006afd@intel.com>
References: <1412713823.11091.166.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:44611 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754242AbaJHREP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2014 13:04:15 -0400
In-Reply-To: <1412713823.11091.166.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 7 Oct 2014 13:30:23 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> Support skb->xmit_more in i40e is straightforward : we need to move
> around i40e_maybe_stop_tx() call to correctly test
> netif_xmit_stopped() before taking the decision to not kick the NIC.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Looks good to me.

- Greg

> ---
>  drivers/net/ethernet/intel/i40e/i40e_txrx.c |   90 +++++++++---------
>  1 file changed, 46 insertions(+), 44 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
> b/drivers/net/ethernet/intel/i40e/i40e_txrx.c index
> 267992b3de8a..3195d82e4942 100644 ---
> a/drivers/net/ethernet/intel/i40e/i40e_txrx.c +++
> b/drivers/net/ethernet/intel/i40e/i40e_txrx.c @@ -2053,6 +2053,47 @@
> static void i40e_create_tx_ctx(struct i40e_ring *tx_ring, }
>  
>  /**
> + * __i40e_maybe_stop_tx - 2nd level check for tx stop conditions
> + * @tx_ring: the ring to be checked
> + * @size:    the size buffer we want to assure is available
> + *
> + * Returns -EBUSY if a stop is needed, else 0
> + **/
> +static inline int __i40e_maybe_stop_tx(struct i40e_ring *tx_ring,
> int size) +{
> +	netif_stop_subqueue(tx_ring->netdev, tx_ring->queue_index);
> +	/* Memory barrier before checking head and tail */
> +	smp_mb();
> +
> +	/* Check again in a case another CPU has just made room
> available. */
> +	if (likely(I40E_DESC_UNUSED(tx_ring) < size))
> +		return -EBUSY;
> +
> +	/* A reprieve! - use start_queue because it doesn't call
> schedule */
> +	netif_start_subqueue(tx_ring->netdev, tx_ring->queue_index);
> +	++tx_ring->tx_stats.restart_queue;
> +	return 0;
> +}
> +
> +/**
> + * i40e_maybe_stop_tx - 1st level check for tx stop conditions
> + * @tx_ring: the ring to be checked
> + * @size:    the size buffer we want to assure is available
> + *
> + * Returns 0 if stop is not needed
> + **/
> +#ifdef I40E_FCOE
> +int i40e_maybe_stop_tx(struct i40e_ring *tx_ring, int size)
> +#else
> +static int i40e_maybe_stop_tx(struct i40e_ring *tx_ring, int size)
> +#endif
> +{
> +	if (likely(I40E_DESC_UNUSED(tx_ring) >= size))
> +		return 0;
> +	return __i40e_maybe_stop_tx(tx_ring, size);
> +}
> +
> +/**
>   * i40e_tx_map - Build the Tx descriptor
>   * @tx_ring:  ring to send buffer on
>   * @skb:      send buffer
> @@ -2195,8 +2236,12 @@ static void i40e_tx_map(struct i40e_ring
> *tx_ring, struct sk_buff *skb, 
>  	tx_ring->next_to_use = i;
>  
> +	i40e_maybe_stop_tx(tx_ring, DESC_NEEDED);
>  	/* notify HW of packet */
> -	writel(i, tx_ring->tail);
> +	if (!skb->xmit_more ||
> +	    netif_xmit_stopped(netdev_get_tx_queue(tx_ring->netdev,
> +
> tx_ring->queue_index)))
> +		writel(i, tx_ring->tail);
>  
>  	return;
>  
> @@ -2218,47 +2263,6 @@ dma_error:
>  }
>  
>  /**
> - * __i40e_maybe_stop_tx - 2nd level check for tx stop conditions
> - * @tx_ring: the ring to be checked
> - * @size:    the size buffer we want to assure is available
> - *
> - * Returns -EBUSY if a stop is needed, else 0
> - **/
> -static inline int __i40e_maybe_stop_tx(struct i40e_ring *tx_ring,
> int size) -{
> -	netif_stop_subqueue(tx_ring->netdev, tx_ring->queue_index);
> -	/* Memory barrier before checking head and tail */
> -	smp_mb();
> -
> -	/* Check again in a case another CPU has just made room
> available. */
> -	if (likely(I40E_DESC_UNUSED(tx_ring) < size))
> -		return -EBUSY;
> -
> -	/* A reprieve! - use start_queue because it doesn't call
> schedule */
> -	netif_start_subqueue(tx_ring->netdev, tx_ring->queue_index);
> -	++tx_ring->tx_stats.restart_queue;
> -	return 0;
> -}
> -
> -/**
> - * i40e_maybe_stop_tx - 1st level check for tx stop conditions
> - * @tx_ring: the ring to be checked
> - * @size:    the size buffer we want to assure is available
> - *
> - * Returns 0 if stop is not needed
> - **/
> -#ifdef I40E_FCOE
> -int i40e_maybe_stop_tx(struct i40e_ring *tx_ring, int size)
> -#else
> -static int i40e_maybe_stop_tx(struct i40e_ring *tx_ring, int size)
> -#endif
> -{
> -	if (likely(I40E_DESC_UNUSED(tx_ring) >= size))
> -		return 0;
> -	return __i40e_maybe_stop_tx(tx_ring, size);
> -}
> -
> -/**
>   * i40e_xmit_descriptor_count - calculate number of tx descriptors
> needed
>   * @skb:     send buffer
>   * @tx_ring: ring to send buffer on
> @@ -2372,8 +2376,6 @@ static netdev_tx_t i40e_xmit_frame_ring(struct
> sk_buff *skb, i40e_tx_map(tx_ring, skb, first, tx_flags, hdr_len,
>  		    td_cmd, td_offset);
>  
> -	i40e_maybe_stop_tx(tx_ring, DESC_NEEDED);
> -
>  	return NETDEV_TX_OK;
>  
>  out_drop:
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
