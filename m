From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH net-next] ixgbe: flush when in xmit_more mode and under
 descriptor pressure
Date: Tue, 26 Aug 2014 09:01:48 -0700
Message-ID: <53FCAF6C.2070401@intel.com>
References: <1409068105-16634-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:47352 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750858AbaHZQBu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2014 12:01:50 -0400
In-Reply-To: <1409068105-16634-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/26/2014 08:48 AM, Daniel Borkmann wrote:
> When xmit_more mode is being used and the ring is about to become
> full, enforce a tail pointer write to the hw. Otherwise, we could
> risk a Tx hang as pointed out by Alex.
> 
> Suggested-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  Hi Alex, something along that lines regarding your first comment?
> 
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 67 +++++++++++++++------------
>  1 file changed, 38 insertions(+), 29 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index ba9ceaa..f851e84 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -6853,6 +6883,7 @@ static void ixgbe_tx_map(struct ixgbe_ring *tx_ring,
>  	u32 tx_flags = first->tx_flags;
>  	u32 cmd_type = ixgbe_tx_cmd_type(skb, tx_flags);
>  	u16 i = tx_ring->next_to_use;
> +	bool desc_pressure;
>  
>  	tx_desc = IXGBE_TX_DESC(tx_ring, i);
>  
> @@ -6958,10 +6989,15 @@ static void ixgbe_tx_map(struct ixgbe_ring *tx_ring,
>  
>  	tx_ring->next_to_use = i;
>  
> -	if (!skb->xmit_more) {
> +	desc_pressure = (ixgbe_desc_unused(tx_ring) < DESC_NEEDED);
> +	if (!skb->xmit_more || unlikely(desc_pressure)) {
>  		/* notify HW of packet */
>  		ixgbe_write_tail(tx_ring, i);
> +
> +		if (unlikely(desc_pressure))
> +			__ixgbe_maybe_stop_tx(tx_ring, DESC_NEEDED);
>  	}
> +
>  	return;
>  dma_error:
>  	dev_err(tx_ring->dev, "TX DMA map failed\n");
> @@ -6978,6 +7014,7 @@ dma_error:
>  	}
>  
>  	tx_ring->next_to_use = i;
> +	ixgbe_maybe_stop_tx(tx_ring, DESC_NEEDED);
>  }
>  

Actually this bit here is much more complicated than it probably needs
to be.

My thought is to just fold ixgbe_maybe_stop_tx into the if statement.

So it shoudl be:
 if (!skb->smit_more || ixgbe_maybe_stop_tx(tx_ring, DESC_NEEDED))

If the BQL bit is folded into the xmit_more check somewhere then that
should be enough to resolve any possible ring stalls.

Thanks,

Alex
