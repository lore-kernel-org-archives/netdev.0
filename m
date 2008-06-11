From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH 1/2] [UPDATED] ixgbe: add LRO support
Date: Wed, 11 Jun 2008 15:20:21 -0700
Message-ID: <20080611152021.1f6515cb.randy.dunlap@oracle.com>
References: <20080611221110.10978.82097.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzick.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	e1000-dev@lists.sourceforge.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:37703 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751155AbYFKWUh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2008 18:20:37 -0400
In-Reply-To: <20080611221110.10978.82097.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 11 Jun 2008 15:14:17 -0700 Jeff Kirsher wrote:

> 
> Support for in-kernel LRO with the ability to enable/disable via ethtool
> based on comments from Ben Hutchings.
> 
> Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Signed-off-by: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> ---
> 
>  drivers/net/ixgbe/ixgbe.h         |    9 +++
>  drivers/net/ixgbe/ixgbe_ethtool.c |   11 ++++
>  drivers/net/ixgbe/ixgbe_main.c    |  111 ++++++++++++++++++++++++++++++-------
>  3 files changed, 110 insertions(+), 21 deletions(-)

Is there also a patch to drivers/net/Kconfig that makes IXGBE depend on INET?
You can't just assume that the lro_* functions are always there....


> diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
> index d981134..956914a 100644
> --- a/drivers/net/ixgbe/ixgbe.h
> +++ b/drivers/net/ixgbe/ixgbe.h
> @@ -32,6 +32,7 @@
>  #include <linux/types.h>
>  #include <linux/pci.h>
>  #include <linux/netdevice.h>
> +#include <linux/inet_lro.h>
>  
>  #include "ixgbe_type.h"
>  #include "ixgbe_common.h"
> @@ -100,6 +101,9 @@
>  #define IXGBE_TX_FLAGS_VLAN_MASK	0xffff0000
>  #define IXGBE_TX_FLAGS_VLAN_SHIFT	16
>  
> +#define IXGBE_MAX_LRO_DESCRIPTORS       8
> +#define IXGBE_MAX_LRO_AGGREGATE         32
> +
>  /* wrapper around a pointer to a socket buffer,
>   * so a DMA handle can be stored along with the buffer */
>  struct ixgbe_tx_buffer {
> @@ -150,6 +154,8 @@ struct ixgbe_ring {
>  	/* cpu for tx queue */
>  	int cpu;
>  #endif
> +	struct net_lro_mgr lro_mgr;
> +	bool lro_used;
>  	struct ixgbe_queue_stats stats;
>  	u8 v_idx; /* maps directly to the index for this ring in the hardware
>  		   * vector array, can also be used for finding the bit in EICR
> @@ -287,6 +293,9 @@ struct ixgbe_adapter {
>  
>  	unsigned long state;
>  	u64 tx_busy;
> +	u64 lro_aggregated;
> +	u64 lro_flushed;
> +	u64 lro_no_desc;
>  };
>  
>  enum ixbge_state_t {
> diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
> index 4e46377..12990b1 100644
> --- a/drivers/net/ixgbe/ixgbe_ethtool.c
> +++ b/drivers/net/ixgbe/ixgbe_ethtool.c
> @@ -90,6 +90,8 @@ static struct ixgbe_stats ixgbe_gstrings_stats[] = {
>  	{"rx_header_split", IXGBE_STAT(rx_hdr_split)},
>  	{"alloc_rx_page_failed", IXGBE_STAT(alloc_rx_page_failed)},
>  	{"alloc_rx_buff_failed", IXGBE_STAT(alloc_rx_buff_failed)},
> +	{"lro_aggregated", IXGBE_STAT(lro_aggregated)},
> +	{"lro_flushed", IXGBE_STAT(lro_flushed)},
>  };
>  
>  #define IXGBE_QUEUE_STATS_LEN \
> @@ -787,6 +789,7 @@ static void ixgbe_get_ethtool_stats(struct net_device *netdev,
>  	int stat_count = sizeof(struct ixgbe_queue_stats) / sizeof(u64);
>  	int j, k;
>  	int i;
> +	u64 aggregated = 0, flushed = 0, no_desc = 0;
>  
>  	ixgbe_update_stats(adapter);
>  	for (i = 0; i < IXGBE_GLOBAL_STATS_LEN; i++) {
> @@ -801,11 +804,17 @@ static void ixgbe_get_ethtool_stats(struct net_device *netdev,
>  		i += k;
>  	}
>  	for (j = 0; j < adapter->num_rx_queues; j++) {
> +		aggregated += adapter->rx_ring[j].lro_mgr.stats.aggregated;
> +		flushed += adapter->rx_ring[j].lro_mgr.stats.flushed;
> +		no_desc += adapter->rx_ring[j].lro_mgr.stats.no_desc;
>  		queue_stat = (u64 *)&adapter->rx_ring[j].stats;
>  		for (k = 0; k < stat_count; k++)
>  			data[i + k] = queue_stat[k];
>  		i += k;
>  	}
> +	adapter->lro_aggregated = aggregated;
> +	adapter->lro_flushed = flushed;
> +	adapter->lro_no_desc = no_desc;
>  }
>  
>  static void ixgbe_get_strings(struct net_device *netdev, u32 stringset,
> @@ -973,6 +982,8 @@ static struct ethtool_ops ixgbe_ethtool_ops = {
>  	.get_ethtool_stats      = ixgbe_get_ethtool_stats,
>  	.get_coalesce           = ixgbe_get_coalesce,
>  	.set_coalesce           = ixgbe_set_coalesce,
> +	.get_flags              = ethtool_op_get_flags,
> +	.set_flags              = ethtool_op_set_flags,
>  };
>  
>  void ixgbe_set_ethtool_ops(struct net_device *netdev)
> diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
> index 7b85922..04c6482 100644
> --- a/drivers/net/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ixgbe/ixgbe_main.c
> @@ -389,24 +389,39 @@ static int __ixgbe_notify_dca(struct device *dev, void *data)
>   * ixgbe_receive_skb - Send a completed packet up the stack
>   * @adapter: board private structure
>   * @skb: packet to send up
> - * @is_vlan: packet has a VLAN tag
> - * @tag: VLAN tag from descriptor
> + * @status: hardware indication of status of receive
> + * @rx_ring: rx descriptor ring (for a specific queue) to setup
> + * @rx_desc: rx descriptor
>   **/
>  static void ixgbe_receive_skb(struct ixgbe_adapter *adapter,
> -			      struct sk_buff *skb, bool is_vlan,
> -			      u16 tag)
> +			      struct sk_buff *skb, u8 status,
> +			      struct ixgbe_ring *ring,
> +                              union ixgbe_adv_rx_desc *rx_desc)
>  {
> -	if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL)) {
> -		if (adapter->vlgrp && is_vlan)
> -			vlan_hwaccel_receive_skb(skb, adapter->vlgrp, tag);
> -		else
> -			netif_receive_skb(skb);
> -	} else {
> +	bool is_vlan = (status & IXGBE_RXD_STAT_VP);
> +	u16 tag = le16_to_cpu(rx_desc->wb.upper.vlan);
>  
> +	if (adapter->netdev->features & NETIF_F_LRO &&
> +	    skb->ip_summed == CHECKSUM_UNNECESSARY) {
>  		if (adapter->vlgrp && is_vlan)
> -			vlan_hwaccel_rx(skb, adapter->vlgrp, tag);
> +			lro_vlan_hwaccel_receive_skb(&ring->lro_mgr, skb,
> +			                             adapter->vlgrp, tag,
> +			                             rx_desc);
>  		else
> -			netif_rx(skb);
> +			lro_receive_skb(&ring->lro_mgr, skb, rx_desc);
> +		ring->lro_used = true;
> +	} else {
> +		if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL)) {
> +			if (adapter->vlgrp && is_vlan)
> +				vlan_nw_accel_receive_skb(skb, adapter->vlgrp, tag);
> +			else
> +				netif_receive_skb(skb);
> +		} else {
> +			if (adapter->vlgrp && is_vlan)
> +				vlan_hwaccel_rx(skb, adapter->vlgrp, tag);
> +			else
> +				netif_rx(skb);
> +		}
>  	}
>  }
>  
> @@ -546,8 +561,8 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_adapter *adapter,
>  	struct sk_buff *skb;
>  	unsigned int i;
>  	u32 upper_len, len, staterr;
> -	u16 hdr_info, vlan_tag;
> -	bool is_vlan, cleaned = false;
> +	u16 hdr_info;
> +	bool cleaned = false;
>  	int cleaned_count = 0;
>  	unsigned int total_rx_bytes = 0, total_rx_packets = 0;
>  
> @@ -556,8 +571,6 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_adapter *adapter,
>  	rx_desc = IXGBE_RX_DESC_ADV(*rx_ring, i);
>  	staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
>  	rx_buffer_info = &rx_ring->rx_buffer_info[i];
> -	is_vlan = (staterr & IXGBE_RXD_STAT_VP);
> -	vlan_tag = le16_to_cpu(rx_desc->wb.upper.vlan);
>  
>  	while (staterr & IXGBE_RXD_STAT_DD) {
>  		if (*work_done >= work_to_do)
> @@ -635,7 +648,7 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_adapter *adapter,
>  		total_rx_packets++;
>  
>  		skb->protocol = eth_type_trans(skb, netdev);
> -		ixgbe_receive_skb(adapter, skb, is_vlan, vlan_tag);
> +		ixgbe_receive_skb(adapter, skb, staterr, rx_ring, rx_desc);
>  		netdev->last_rx = jiffies;
>  
>  next_desc:
> @@ -652,8 +665,11 @@ next_desc:
>  		rx_buffer_info = next_buffer;
>  
>  		staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
> -		is_vlan = (staterr & IXGBE_RXD_STAT_VP);
> -		vlan_tag = le16_to_cpu(rx_desc->wb.upper.vlan);
> +	}
> +
> +	if (rx_ring->lro_used) {
> +		lro_flush_all(&rx_ring->lro_mgr);
> +		rx_ring->lro_used = false;
>  	}
>  
>  	rx_ring->next_to_clean = i;
> @@ -1382,6 +1398,33 @@ static void ixgbe_configure_tx(struct ixgbe_adapter *adapter)
>  
>  #define IXGBE_SRRCTL_BSIZEHDRSIZE_SHIFT			2
>  /**
> + * ixgbe_get_skb_hdr - helper function for LRO header processing
> + * @skb: pointer to sk_buff to be added to LRO packet
> + * @iphdr: pointer to tcp header structure
> + * @tcph: pointer to tcp header structure
> + * @hdr_flags: pointer to header flags
> + * @priv: private data
> + **/
> +static int ixgbe_get_skb_hdr(struct sk_buff *skb, void **iphdr, void **tcph,
> +                             u64 *hdr_flags, void *priv)
> +{
> +	union ixgbe_adv_rx_desc *rx_desc = priv;
> +
> +	/* Verify that this is a valid IPv4 TCP packet */
> +	if (!(rx_desc->wb.lower.lo_dword.pkt_info &
> +	    (IXGBE_RXDADV_PKTTYPE_IPV4 | IXGBE_RXDADV_PKTTYPE_TCP)))
> +		return -1;
> +
> +	/* Set network headers */
> +	skb_reset_network_header(skb);
> +	skb_set_transport_header(skb, ip_hdrlen(skb));
> +	*iphdr = ip_hdr(skb);
> +	*tcph = tcp_hdr(skb);
> +	*hdr_flags = LRO_IPV4 | LRO_TCP;
> +	return 0;
> +}
> +
> +/**
>   * ixgbe_configure_rx - Configure 8254x Receive Unit after Reset
>   * @adapter: board private structure
>   *
> @@ -1470,6 +1513,17 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
>  		adapter->rx_ring[i].tail = IXGBE_RDT(i);
>  	}
>  
> +	/* Intitial LRO Settings */
> +	adapter->rx_ring[i].lro_mgr.max_aggr = IXGBE_MAX_LRO_AGGREGATE;
> +	adapter->rx_ring[i].lro_mgr.max_desc = IXGBE_MAX_LRO_DESCRIPTORS;
> +	adapter->rx_ring[i].lro_mgr.get_skb_header = ixgbe_get_skb_hdr;
> +	adapter->rx_ring[i].lro_mgr.features = LRO_F_EXTRACT_VLAN_ID;
> +	if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL))
> +		adapter->rx_ring[i].lro_mgr.features |= LRO_F_NAPI;
> +	adapter->rx_ring[i].lro_mgr.dev = adapter->netdev;
> +	adapter->rx_ring[i].lro_mgr.ip_summed = CHECKSUM_UNNECESSARY;
> +	adapter->rx_ring[i].lro_mgr.ip_summed_aggr = CHECKSUM_UNNECESSARY;
> +
>  	if (adapter->flags & IXGBE_FLAG_RSS_ENABLED) {
>  		/* Fill out redirection table */
>  		for (i = 0, j = 0; i < 128; i++, j++) {
> @@ -2489,12 +2543,18 @@ int ixgbe_setup_rx_resources(struct ixgbe_adapter *adapter,
>  	struct pci_dev *pdev = adapter->pdev;
>  	int size;
>  
> +	size = sizeof(struct net_lro_desc) * IXGBE_MAX_LRO_DESCRIPTORS;
> +	rxdr->lro_mgr.lro_arr = vmalloc(size);
> +	if (!rxdr->lro_mgr.lro_arr)
> +		return -ENOMEM;
> +	memset(rxdr->lro_mgr.lro_arr, 0, size);
> +
>  	size = sizeof(struct ixgbe_rx_buffer) * rxdr->count;
>  	rxdr->rx_buffer_info = vmalloc(size);
>  	if (!rxdr->rx_buffer_info) {
>  		DPRINTK(PROBE, ERR,
>  			"vmalloc allocation failed for the rx desc ring\n");
> -		return -ENOMEM;
> +		goto alloc_failed;
>  	}
>  	memset(rxdr->rx_buffer_info, 0, size);
>  
> @@ -2508,13 +2568,18 @@ int ixgbe_setup_rx_resources(struct ixgbe_adapter *adapter,
>  		DPRINTK(PROBE, ERR,
>  			"Memory allocation failed for the rx desc ring\n");
>  		vfree(rxdr->rx_buffer_info);
> -		return -ENOMEM;
> +		goto alloc_failed;
>  	}
>  
>  	rxdr->next_to_clean = 0;
>  	rxdr->next_to_use = 0;
>  
>  	return 0;
> +
> +alloc_failed:
> +	vfree(rxdr->lro_mgr.lro_arr);
> +	rxdr->lro_mgr.lro_arr = NULL;
> +	return -ENOMEM;
>  }
>  
>  /**
> @@ -2565,6 +2630,9 @@ static void ixgbe_free_rx_resources(struct ixgbe_adapter *adapter,
>  {
>  	struct pci_dev *pdev = adapter->pdev;
>  
> +	vfree(rx_ring->lro_mgr.lro_arr);
> +	rx_ring->lro_mgr.lro_arr = NULL;
> +
>  	ixgbe_clean_rx_ring(adapter, rx_ring);
>  
>  	vfree(rx_ring->rx_buffer_info);
> @@ -3517,6 +3585,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
>  			   NETIF_F_HW_VLAN_RX |
>  			   NETIF_F_HW_VLAN_FILTER;
>  
> +	netdev->features |= NETIF_F_LRO;
>  	netdev->features |= NETIF_F_TSO;
>  
>  	netdev->features |= NETIF_F_TSO6;

---
~Randy
