From: yzhu1 <Yanjun.Zhu@windriver.com>
Subject: Re: [PATCH 1/2] net: Remove ndo_xmit_flush netdev operation, use
 signalling instead.
Date: Tue, 1 Sep 2015 14:46:38 +0800
Message-ID: <55E549CE.4010509@windriver.com>
References: <20140825.163502.973913220915588977.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <therbert@google.com>, <jhs@mojatatu.com>,
	<hannes@stressinduktion.org>, <edumazet@google.com>,
	<jeffrey.t.kirsher@intel.com>, <rusty@rustcorp.com.au>,
	<dborkman@redhat.com>, <brouer@redhat.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:35818 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752866AbbIAGqz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 02:46:55 -0400
In-Reply-To: <20140825.163502.973913220915588977.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/26/2014 07:35 AM, David Miller wrote:
> As reported by Jesper Dangaard Brouer, for high packet rates the
> overhead of having another indirect call in the TX path is
> non-trivial.
>
> There is the indirect call itself, and then there is all of the
> reloading of the state to refetch the tail pointer value and
> then write the device register.
>
> Move to a more passive scheme, which requires very light modifications
> to the device drivers.
>
> The signal is a new skb->xmit_more value, if it is non-zero it means
> that more SKBs are pending to be transmitted on the same queue as the
> current SKB.  And therefore, the driver may elide the tail pointer
> update.
>
> Right now skb->xmit_more is always zero.
Hi, Miller

After I applied this patch, the skb->xmit_more is not always zero.

My igb driver is as below:

09:00.0 Ethernet controller: Intel Corporation I350 Gigabit Network 
Connection (rev 01)
     Subsystem: Intel Corporation I350 Gigabit Network Connection
     Flags: bus master, fast devsel, latency 0, IRQ 16
     Memory at d0960000 (32-bit, non-prefetchable) [size=128K]
     I/O ports at 2060 [size=32]
     Memory at d09b0000 (32-bit, non-prefetchable) [size=16K]
     Capabilities: [40] Power Management version 3
     Capabilities: [50] MSI: Enable- Count=1/1 Maskable+ 64bit+
     Capabilities: [70] MSI-X: Enable+ Count=10 Masked-
     Capabilities: [a0] Express Endpoint, MSI 00
     Capabilities: [e0] Vital Product Data
     Capabilities: [100] Advanced Error Reporting
     Capabilities: [140] Device Serial Number 00-1e-67-ff-ff-65-8d-9c
     Capabilities: [150] Alternative Routing-ID Interpretation (ARI)
     Capabilities: [160] Single Root I/O Virtualization (SR-IOV)
     Capabilities: [1a0] Transaction Processing Hints
     Capabilities: [1c0] Latency Tolerance Reporting
     Capabilities: [1d0] Access Control Services
     Kernel driver in use: igb

And the logs are as below:

[  917.489934] func:igb_tx_map, line:4860,skb->xmit_more:1
[  929.616829] func:igb_tx_map, line:4860,skb->xmit_more:1
[  929.621548] func:igb_tx_map, line:4860,skb->xmit_more:1
[  940.675453] func:igb_tx_map, line:4860,skb->xmit_more:1
[  951.811508] func:igb_tx_map, line:4860,skb->xmit_more:1
[  961.903057] func:igb_tx_map, line:4860,skb->xmit_more:1
[  974.032852] func:igb_tx_map, line:4860,skb->xmit_more:1
[  974.075644] func:igb_tx_map, line:4860,skb->xmit_more:1

Maybe the assumption that skb->xmit_more is always 0 is not correct.

Sometimes skb->xmit_more is not always 0 because of compiler or other 
reasons.

Best Regards!
Zhu Yanjun

.
>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>   drivers/net/ethernet/intel/igb/igb_main.c | 36 +++++++++++--------------------
>   drivers/net/virtio_net.c                  | 12 +++--------
>   include/linux/netdevice.h                 | 25 ++-------------------
>   include/linux/skbuff.h                    |  2 ++
>   4 files changed, 19 insertions(+), 56 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
> index b9c020a..89c29b4 100644
> --- a/drivers/net/ethernet/intel/igb/igb_main.c
> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> @@ -136,7 +136,6 @@ static void igb_update_phy_info(unsigned long);
>   static void igb_watchdog(unsigned long);
>   static void igb_watchdog_task(struct work_struct *);
>   static netdev_tx_t igb_xmit_frame(struct sk_buff *skb, struct net_device *);
> -static void igb_xmit_flush(struct net_device *netdev, u16 queue);
>   static struct rtnl_link_stats64 *igb_get_stats64(struct net_device *dev,
>   					  struct rtnl_link_stats64 *stats);
>   static int igb_change_mtu(struct net_device *, int);
> @@ -2076,7 +2075,6 @@ static const struct net_device_ops igb_netdev_ops = {
>   	.ndo_open		= igb_open,
>   	.ndo_stop		= igb_close,
>   	.ndo_start_xmit		= igb_xmit_frame,
> -	.ndo_xmit_flush		= igb_xmit_flush,
>   	.ndo_get_stats64	= igb_get_stats64,
>   	.ndo_set_rx_mode	= igb_set_rx_mode,
>   	.ndo_set_mac_address	= igb_set_mac,
> @@ -4917,6 +4915,14 @@ static void igb_tx_map(struct igb_ring *tx_ring,
>   
>   	tx_ring->next_to_use = i;
>   
> +	if (!skb->xmit_more) {
> +		writel(i, tx_ring->tail);
> +
> +		/* we need this if more than one processor can write to our tail
> +		 * at a time, it synchronizes IO on IA64/Altix systems
> +		 */
> +		mmiowb();
> +	}
>   	return;
>   
>   dma_error:
> @@ -5052,20 +5058,17 @@ out_drop:
>   	return NETDEV_TX_OK;
>   }
>   
> -static struct igb_ring *__igb_tx_queue_mapping(struct igb_adapter *adapter, unsigned int r_idx)
> +static inline struct igb_ring *igb_tx_queue_mapping(struct igb_adapter *adapter,
> +						    struct sk_buff *skb)
>   {
> +	unsigned int r_idx = skb->queue_mapping;
> +
>   	if (r_idx >= adapter->num_tx_queues)
>   		r_idx = r_idx % adapter->num_tx_queues;
>   
>   	return adapter->tx_ring[r_idx];
>   }
>   
> -static inline struct igb_ring *igb_tx_queue_mapping(struct igb_adapter *adapter,
> -						    struct sk_buff *skb)
> -{
> -	return __igb_tx_queue_mapping(adapter, skb->queue_mapping);
> -}
> -
>   static netdev_tx_t igb_xmit_frame(struct sk_buff *skb,
>   				  struct net_device *netdev)
>   {
> @@ -5094,21 +5097,6 @@ static netdev_tx_t igb_xmit_frame(struct sk_buff *skb,
>   	return igb_xmit_frame_ring(skb, igb_tx_queue_mapping(adapter, skb));
>   }
>   
> -static void igb_xmit_flush(struct net_device *netdev, u16 queue)
> -{
> -	struct igb_adapter *adapter = netdev_priv(netdev);
> -	struct igb_ring *tx_ring;
> -
> -	tx_ring = __igb_tx_queue_mapping(adapter, queue);
> -
> -	writel(tx_ring->next_to_use, tx_ring->tail);
> -
> -	/* we need this if more than one processor can write to our tail
> -	 * at a time, it synchronizes IO on IA64/Altix systems
> -	 */
> -	mmiowb();
> -}
> -
>   /**
>    *  igb_tx_timeout - Respond to a Tx Hang
>    *  @netdev: network interface device structure
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 6242108..f0c2824 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -953,15 +953,10 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
>   		}
>   	}
>   
> -	return NETDEV_TX_OK;
> -}
> +	if (!skb->xmit_more)
> +		virtqueue_kick(sq->vq);
>   
> -static void xmit_flush(struct net_device *dev, u16 qnum)
> -{
> -	struct virtnet_info *vi = netdev_priv(dev);
> -	struct send_queue *sq = &vi->sq[qnum];
> -
> -	virtqueue_kick(sq->vq);
> +	return NETDEV_TX_OK;
>   }
>   
>   /*
> @@ -1393,7 +1388,6 @@ static const struct net_device_ops virtnet_netdev = {
>   	.ndo_open            = virtnet_open,
>   	.ndo_stop   	     = virtnet_close,
>   	.ndo_start_xmit      = start_xmit,
> -	.ndo_xmit_flush      = xmit_flush,
>   	.ndo_validate_addr   = eth_validate_addr,
>   	.ndo_set_mac_address = virtnet_set_mac_address,
>   	.ndo_set_rx_mode     = virtnet_set_rx_mode,
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 220c509..039b237 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -782,19 +782,6 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
>    *        (can also return NETDEV_TX_LOCKED iff NETIF_F_LLTX)
>    *	Required can not be NULL.
>    *
> - * void (*ndo_xmit_flush)(struct net_device *dev, u16 queue);
> - *	A driver implements this function when it wishes to support
> - *	deferred TX queue flushing.  The idea is that the expensive
> - *	operation to trigger TX queue processing can be done after
> - *	N calls to ndo_start_xmit rather than being done every single
> - *	time.  In this regime ndo_start_xmit will be called one or more
> - *	times, and then a final ndo_xmit_flush call will be made to
> - *	have the driver tell the device about the new pending TX queue
> - *	entries.  The kernel keeps track of which queues need flushing
> - *	by monitoring skb->queue_mapping of the packets it submits to
> - *	ndo_start_xmit.  This is the queue value that will be passed
> - *	to ndo_xmit_flush.
> - *
>    * u16 (*ndo_select_queue)(struct net_device *dev, struct sk_buff *skb,
>    *                         void *accel_priv, select_queue_fallback_t fallback);
>    *	Called to decide which queue to when device supports multiple
> @@ -1018,7 +1005,6 @@ struct net_device_ops {
>   	int			(*ndo_stop)(struct net_device *dev);
>   	netdev_tx_t		(*ndo_start_xmit) (struct sk_buff *skb,
>   						   struct net_device *dev);
> -	void			(*ndo_xmit_flush)(struct net_device *dev, u16 queue);
>   	u16			(*ndo_select_queue)(struct net_device *dev,
>   						    struct sk_buff *skb,
>   						    void *accel_priv,
> @@ -3447,15 +3433,8 @@ int __init dev_proc_init(void);
>   static inline netdev_tx_t __netdev_start_xmit(const struct net_device_ops *ops,
>   					      struct sk_buff *skb, struct net_device *dev)
>   {
> -	netdev_tx_t ret;
> -	u16 q;
> -
> -	q = skb->queue_mapping;
> -	ret = ops->ndo_start_xmit(skb, dev);
> -	if (dev_xmit_complete(ret) && ops->ndo_xmit_flush)
> -		ops->ndo_xmit_flush(dev, q);
> -
> -	return ret;
> +	skb->xmit_more = 0;
> +	return ops->ndo_start_xmit(skb, dev);
>   }
>   
>   static inline netdev_tx_t netdev_start_xmit(struct sk_buff *skb, struct net_device *dev)
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 18ddf96..9b3802a 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -452,6 +452,7 @@ static inline u32 skb_mstamp_us_delta(const struct skb_mstamp *t1,
>    *	@tc_verd: traffic control verdict
>    *	@hash: the packet hash
>    *	@queue_mapping: Queue mapping for multiqueue devices
> + *	@xmit_more: More SKBs are pending for this queue
>    *	@ndisc_nodetype: router type (from link layer)
>    *	@ooo_okay: allow the mapping of a socket to a queue to be changed
>    *	@l4_hash: indicate hash is a canonical 4-tuple hash over transport
> @@ -558,6 +559,7 @@ struct sk_buff {
>   
>   	__u16			queue_mapping;
>   	kmemcheck_bitfield_begin(flags2);
> +	__u8			xmit_more:1;
>   #ifdef CONFIG_IPV6_NDISC_NODETYPE
>   	__u8			ndisc_nodetype:2;
>   #endif
