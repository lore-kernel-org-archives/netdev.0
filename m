From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next 09/14] igb: Report L4 Rx hash via skb->l4_rxhash
Date: Thu, 17 Jan 2013 06:19:45 -0800
Message-ID: <1358432385.29723.6.camel@edumazet-glaptop>
References: <1358422519-20981-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1358422519-20981-10-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:61517 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750953Ab3AQOTu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 09:19:50 -0500
Received: by mail-pa0-f54.google.com with SMTP id bi5so1494482pad.13
        for <netdev@vger.kernel.org>; Thu, 17 Jan 2013 06:19:49 -0800 (PST)
In-Reply-To: <1358422519-20981-10-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-01-17 at 03:35 -0800, Jeff Kirsher wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This change makes it so that we report when the Rx hash data is based on L4
> protocol inputs, specifically TCP or UDP port numbers.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/igb/e1000_82575.h |  9 +++++++++
>  drivers/net/ethernet/intel/igb/igb_main.c    | 21 +++++++++++++++++++--
>  2 files changed, 28 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.h b/drivers/net/ethernet/intel/igb/e1000_82575.h
> index 444f6f5..fa13e70 100644
> --- a/drivers/net/ethernet/intel/igb/e1000_82575.h
> +++ b/drivers/net/ethernet/intel/igb/e1000_82575.h
> @@ -112,11 +112,20 @@ union e1000_adv_rx_desc {
>  	} wb;  /* writeback */
>  };
>  
> +#define E1000_RXDADV_RSSTYPE_MASK	0x0000000F
>  #define E1000_RXDADV_HDRBUFLEN_MASK      0x7FE0
>  #define E1000_RXDADV_HDRBUFLEN_SHIFT     5
>  #define E1000_RXDADV_STAT_TS             0x10000 /* Pkt was time stamped */
>  #define E1000_RXDADV_STAT_TSIP           0x08000 /* timestamp in packet */
>  
> +/* RSS Hash results */
> +#define E1000_RXDADV_RSSTYPE_IPV4_TCP	0x00000001
> +#define E1000_RXDADV_RSSTYPE_IPV6_TCP	0x00000003
> +#define E1000_RXDADV_RSSTYPE_IPV6_TCP_EX 0x00000006
> +#define E1000_RXDADV_RSSTYPE_IPV4_UDP	0x00000007
> +#define E1000_RXDADV_RSSTYPE_IPV6_UDP	0x00000008
> +#define E1000_RXDADV_RSSTYPE_IPV6_UDP_EX 0x00000009
> +
>  /* Transmit Descriptor - Advanced */
>  union e1000_adv_tx_desc {
>  	struct {
> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
> index a9cb84a..2c66ec8 100644
> --- a/drivers/net/ethernet/intel/igb/igb_main.c
> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> @@ -6280,12 +6280,29 @@ static inline void igb_rx_checksum(struct igb_ring *ring,
>  		le32_to_cpu(rx_desc->wb.upper.status_error));
>  }
>  
> +#define IGB_RSS_L4TYPES \
> +	(((u16)1 << E1000_RXDADV_RSSTYPE_IPV4_TCP) | \
> +	 ((u16)1 << E1000_RXDADV_RSSTYPE_IPV4_UDP) | \
> +	 ((u16)1 << E1000_RXDADV_RSSTYPE_IPV6_TCP) | \
> +	 ((u16)1 << E1000_RXDADV_RSSTYPE_IPV6_UDP) | \
> +	 ((u16)1 << E1000_RXDADV_RSSTYPE_IPV6_TCP_EX) | \
> +	 ((u16)1 << E1000_RXDADV_RSSTYPE_IPV6_UDP_EX))
> +
>  static inline void igb_rx_hash(struct igb_ring *ring,
>  			       union e1000_adv_rx_desc *rx_desc,
>  			       struct sk_buff *skb)
>  {
> -	if (ring->netdev->features & NETIF_F_RXHASH)
> -		skb->rxhash = le32_to_cpu(rx_desc->wb.lower.hi_dword.rss);
> +	u16 rss_type;
> +
> +	if (!(ring->netdev->features & NETIF_F_RXHASH))
> +		return;
> +
> +	skb->rxhash = le32_to_cpu(rx_desc->wb.lower.hi_dword.rss);
> +
> +	rss_type = le16_to_cpu(rx_desc->wb.lower.lo_dword.pkt_info) &
> +		   E1000_RXDADV_RSSTYPE_MASK;
> +
> +	skb->l4_rxhash = (IGB_RSS_L4TYPES >> rss_type) & 0x1;
>  }
>  

Problem is that we should not set l4_rxhash for UDP traffic, as it might
contains encapsulated protocol.

Also, is IGB really using the ports in the rss for UDP packets ?
