From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [net-next 03/13] ixgbe: Add debug counters for Tx Encap CSUM
Date: Wed, 30 Jan 2013 08:58:30 -0800
Message-ID: <51095136.90603@intel.com>
References: <1359546286-18179-1-git-send-email-jeffrey.t.kirsher@intel.com> <1359546286-18179-4-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:32165 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754572Ab3A3Q6e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2013 11:58:34 -0500
In-Reply-To: <1359546286-18179-4-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NAK, this is not a production patch.  This was just meant to be proof of
concept code.

Thanks,

Alex

On 01/30/2013 03:44 AM, Jeff Kirsher wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This patch adds counters for debugging the vxlan Tx offloading implementation.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe.h         | 4 ++++
>  drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 2 ++
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    | 7 +++++++
>  3 files changed, 13 insertions(+)
> 
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
> index 8371ae4..5d178ea 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
> @@ -190,6 +190,8 @@ struct ixgbe_tx_queue_stats {
>  	u64 restart_queue;
>  	u64 tx_busy;
>  	u64 tx_done_old;
> +	u64 csum_encap_good;
> +	u64 csum_good;
>  };
>  
>  struct ixgbe_rx_queue_stats {
> @@ -548,6 +550,8 @@ struct ixgbe_adapter {
>  	struct ixgbe_hw_stats stats;
>  
>  	u64 tx_busy;
> +	u64 tx_csum_encap_good;
> +	u64 tx_csum_good;
>  	unsigned int tx_ring_count;
>  	unsigned int rx_ring_count;
>  
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
> index 1513b10..036c0a5 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
> @@ -101,6 +101,8 @@ static const struct ixgbe_stats ixgbe_gstrings_stats[] = {
>  	{"rx_flow_control_xon", IXGBE_STAT(stats.lxonrxc)},
>  	{"tx_flow_control_xoff", IXGBE_STAT(stats.lxofftxc)},
>  	{"rx_flow_control_xoff", IXGBE_STAT(stats.lxoffrxc)},
> +	{"tx_csum_encap_good", IXGBE_STAT(tx_csum_encap_good)},
> +	{"tx_csum_good", IXGBE_STAT(tx_csum_good)},
>  	{"rx_csum_offload_errors", IXGBE_STAT(hw_csum_rx_error)},
>  	{"alloc_rx_page_failed", IXGBE_STAT(alloc_rx_page_failed)},
>  	{"alloc_rx_buff_failed", IXGBE_STAT(alloc_rx_buff_failed)},
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index 3719f32..c6cf1a6 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -5150,6 +5150,7 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
>  	u64 non_eop_descs = 0, restart_queue = 0, tx_busy = 0;
>  	u64 alloc_rx_page_failed = 0, alloc_rx_buff_failed = 0;
>  	u64 bytes = 0, packets = 0, hw_csum_rx_error = 0;
> +	u64 tx_csum_good = 0, tx_csum_encap_good = 0;
>  
>  	if (test_bit(__IXGBE_DOWN, &adapter->state) ||
>  	    test_bit(__IXGBE_RESETTING, &adapter->state))
> @@ -5191,9 +5192,13 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
>  		tx_busy += tx_ring->tx_stats.tx_busy;
>  		bytes += tx_ring->stats.bytes;
>  		packets += tx_ring->stats.packets;
> +		tx_csum_encap_good += tx_ring->tx_stats.csum_encap_good;
> +		tx_csum_good += tx_ring->tx_stats.csum_good;
>  	}
>  	adapter->restart_queue = restart_queue;
>  	adapter->tx_busy = tx_busy;
> +	adapter->tx_csum_encap_good = tx_csum_encap_good;
> +	adapter->tx_csum_good = tx_csum_good;
>  	netdev->stats.tx_bytes = bytes;
>  	netdev->stats.tx_packets = packets;
>  
> @@ -5994,11 +5999,13 @@ static void ixgbe_tx_csum(struct ixgbe_ring *tx_ring,
>  			transport_hdr.raw = skb_inner_transport_header(skb);
>  			vlan_macip_lens |= skb_inner_network_offset(skb) <<
>  					   IXGBE_ADVTXD_MACLEN_SHIFT;
> +			tx_ring->tx_stats.csum_encap_good++;
>  		} else {
>  			network_hdr.raw = skb_network_header(skb);
>  			transport_hdr.raw = skb_transport_header(skb);
>  			vlan_macip_lens |= skb_network_offset(skb) <<
>  					   IXGBE_ADVTXD_MACLEN_SHIFT;
> +			tx_ring->tx_stats.csum_good++;
>  		}
>  
>  		/* use first 4 bits to determine IP version */
> 
