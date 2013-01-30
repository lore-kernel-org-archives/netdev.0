From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [net-next 02/13] ixgbe: Adding Tx encapsulation capability
Date: Wed, 30 Jan 2013 08:58:46 -0800
Message-ID: <51095146.7030404@intel.com>
References: <1359546286-18179-1-git-send-email-jeffrey.t.kirsher@intel.com> <1359546286-18179-3-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:50209 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754572Ab3A3Q6t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2013 11:58:49 -0500
In-Reply-To: <1359546286-18179-3-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NAK, this is not a production patch.  This was just meant to be proof of
concept code.

Thanks,

Alex

On 01/30/2013 03:44 AM, Jeff Kirsher wrote:
> From: Joseph Gasparakis <joseph.gasparakis@intel.com>
> 
> This patch allows ixgbe to recognize encapsulated packets and do the
> Tx checksum offload in hardware.
> 
> Signed-off-by: Joseph Gasparakis <joseph.gasparakis@intel.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 46 +++++++++++++++++++++------
>  1 file changed, 37 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index 5989b3f..3719f32 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -5975,17 +5975,42 @@ static void ixgbe_tx_csum(struct ixgbe_ring *tx_ring,
>  		if (!(first->tx_flags & IXGBE_TX_FLAGS_HW_VLAN) &&
>  		    !(first->tx_flags & IXGBE_TX_FLAGS_CC))
>  			return;
> +		vlan_macip_lens |= skb_network_offset(skb) <<
> +				   IXGBE_ADVTXD_MACLEN_SHIFT;
>  	} else {
>  		u8 l4_hdr = 0;
> -		switch (first->protocol) {
> -		case __constant_htons(ETH_P_IP):
> -			vlan_macip_lens |= skb_network_header_len(skb);
> +		union {
> +			struct iphdr *ipv4;
> +			struct ipv6hdr *ipv6;
> +			u8 *raw;
> +		} network_hdr;
> +		union {
> +			struct tcphdr *tcphdr;
> +			u8 *raw;
> +		} transport_hdr;
> +
> +		if (skb->encapsulation) {
> +			network_hdr.raw = skb_inner_network_header(skb);
> +			transport_hdr.raw = skb_inner_transport_header(skb);
> +			vlan_macip_lens |= skb_inner_network_offset(skb) <<
> +					   IXGBE_ADVTXD_MACLEN_SHIFT;
> +		} else {
> +			network_hdr.raw = skb_network_header(skb);
> +			transport_hdr.raw = skb_transport_header(skb);
> +			vlan_macip_lens |= skb_network_offset(skb) <<
> +					   IXGBE_ADVTXD_MACLEN_SHIFT;
> +		}
> +
> +		/* use first 4 bits to determine IP version */
> +		switch (network_hdr.ipv4->version) {
> +		case 4:
> +			vlan_macip_lens |= transport_hdr.raw - network_hdr.raw;
>  			type_tucmd |= IXGBE_ADVTXD_TUCMD_IPV4;
> -			l4_hdr = ip_hdr(skb)->protocol;
> +			l4_hdr = network_hdr.ipv4->protocol;
>  			break;
> -		case __constant_htons(ETH_P_IPV6):
> -			vlan_macip_lens |= skb_network_header_len(skb);
> -			l4_hdr = ipv6_hdr(skb)->nexthdr;
> +		case 6:
> +			vlan_macip_lens |= transport_hdr.raw - network_hdr.raw;
> +			l4_hdr = network_hdr.ipv6->nexthdr;
>  			break;
>  		default:
>  			if (unlikely(net_ratelimit())) {
> @@ -5999,7 +6024,7 @@ static void ixgbe_tx_csum(struct ixgbe_ring *tx_ring,
>  		switch (l4_hdr) {
>  		case IPPROTO_TCP:
>  			type_tucmd |= IXGBE_ADVTXD_TUCMD_L4T_TCP;
> -			mss_l4len_idx = tcp_hdrlen(skb) <<
> +			mss_l4len_idx = (transport_hdr.tcphdr->doff * 4) <<
>  					IXGBE_ADVTXD_L4LEN_SHIFT;
>  			break;
>  		case IPPROTO_SCTP:
> @@ -6025,7 +6050,6 @@ static void ixgbe_tx_csum(struct ixgbe_ring *tx_ring,
>  	}
>  
>  	/* vlan_macip_lens: MACLEN, VLAN tag */
> -	vlan_macip_lens |= skb_network_offset(skb) << IXGBE_ADVTXD_MACLEN_SHIFT;
>  	vlan_macip_lens |= first->tx_flags & IXGBE_TX_FLAGS_VLAN_MASK;
>  
>  	ixgbe_tx_ctxtdesc(tx_ring, vlan_macip_lens, 0,
> @@ -7406,6 +7430,10 @@ skip_sriov:
>  
>  	netdev->hw_features = netdev->features;
>  
> +	netdev->hw_enc_features = NETIF_F_IP_CSUM |
> +				  NETIF_F_IPV6_CSUM |
> +				  NETIF_F_SG;
> +
>  	switch (adapter->hw.mac.type) {
>  	case ixgbe_mac_82599EB:
>  	case ixgbe_mac_X540:
> 
