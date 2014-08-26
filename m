From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH 2/2] ixgbe: support skb->xmit_more in netdev_ops->ndo_start_xmit()
Date: Tue, 26 Aug 2014 08:00:10 -0700
Message-ID: <53FCA0FA.20600@intel.com>
References: <20140825.163505.1969688661687017343.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, jhs@mojatatu.com, hannes@stressinduktion.org,
	edumazet@google.com, jeffrey.t.kirsher@intel.com,
	rusty@rustcorp.com.au, dborkman@redhat.com, brouer@redhat.com
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:17016 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758273AbaHZPAU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2014 11:00:20 -0400
In-Reply-To: <20140825.163505.1969688661687017343.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/25/2014 04:35 PM, David Miller wrote:
> 
> From: Daniel Borkmann <dborkman@redhat.com>
> 
> This implements the deferred tail pointer flush API for the ixgbe
> driver. Similar version also proposed longer time ago by Alexander Duyck.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index 87bd53f..ba9ceaa 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -6958,9 +6958,10 @@ static void ixgbe_tx_map(struct ixgbe_ring *tx_ring,
>  
>  	tx_ring->next_to_use = i;
>  
> -	/* notify HW of packet */
> -	ixgbe_write_tail(tx_ring, i);
> -
> +	if (!skb->xmit_more) {
> +		/* notify HW of packet */
> +		ixgbe_write_tail(tx_ring, i);
> +	}
>  	return;
>  dma_error:
>  	dev_err(tx_ring->dev, "TX DMA map failed\n");
> 

It might help to add some handling for the case where xmit_more is set,
but the ring has become full.  This current implementation introduces
the risk of triggering a Tx hang.

My advice would be to pull the ixgbe_maybe_stop_tx code at the end of
xmit_frame into the if check here, and perhaps look into adding an
additional check to see if BQL has stopped the ring as well.

Thanks,

Alex
