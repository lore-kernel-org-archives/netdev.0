From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net] ixgbe: Only set gso_type to SKB_GSO_TCPV4 as RSC
 does not support IPv6
Date: Tue, 12 Feb 2013 22:51:51 +0200
Message-ID: <20130212205151.GC6972@redhat.com>
References: <20130212193624.17818.13843.stgit@ahduyck-cp1.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	davem@davemloft.net
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31921 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759117Ab3BLUwL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Feb 2013 15:52:11 -0500
Content-Disposition: inline
In-Reply-To: <20130212193624.17818.13843.stgit@ahduyck-cp1.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 12, 2013 at 11:45:44AM -0800, Alexander Duyck wrote:
> The original fix that was applied for setting gso_type required more change
> than necessary because it was assumed ixgbe does RSC on IPv6 frames and this
> is not correct.  RSC is only supported with IPv4/TCP frames only.  As such we
> can simplify the fix and avoid the unnecessary move of eth_type_trans.
> 
> The previous patch "ixgbe: fix gso type" and this patch reduce the entire fix
> to one line that sets gso_type to TCPV4 if the frame is RSC.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

Is this architectural? Is it safe to assume there won't be an update
that does RSC on IPv6?

> ---
> 
> Sorry about not speaking up last week which would have allowed us to avoid
> this patch but I was out on a business trip and had limited access to email
> between flights.
> 
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    9 +++------
>  1 files changed, 3 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index e1b2d22..b3e3294 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -1401,10 +1401,7 @@ static void ixgbe_set_rsc_gso_size(struct ixgbe_ring *ring,
>  	/* set gso_size to avoid messing up TCP MSS */
>  	skb_shinfo(skb)->gso_size = DIV_ROUND_UP((skb->len - hdr_len),
>  						 IXGBE_CB(skb)->append_cnt);
> -	if (skb->protocol == __constant_htons(ETH_P_IPV6))
> -		skb_shinfo(skb)->gso_type = SKB_GSO_TCPV6;
> -	else
> -		skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
> +	skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
>  }
>  
>  static void ixgbe_update_rsc_stats(struct ixgbe_ring *rx_ring,
> @@ -1439,8 +1436,6 @@ static void ixgbe_process_skb_fields(struct ixgbe_ring *rx_ring,
>  {
>  	struct net_device *dev = rx_ring->netdev;
>  
> -	skb->protocol = eth_type_trans(skb, dev);
> -
>  	ixgbe_update_rsc_stats(rx_ring, skb);
>  
>  	ixgbe_rx_hash(rx_ring, rx_desc, skb);
> @@ -1456,6 +1451,8 @@ static void ixgbe_process_skb_fields(struct ixgbe_ring *rx_ring,
>  	}
>  
>  	skb_record_rx_queue(skb, rx_ring->queue_index);
> +
> +	skb->protocol = eth_type_trans(skb, dev);
>  }
>  
>  static void ixgbe_rx_skb(struct ixgbe_q_vector *q_vector,
