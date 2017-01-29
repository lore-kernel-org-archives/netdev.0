From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH stable v1 05/13] net: ethernet: aquantia: Support for
 NIC-specific code
Date: Sun, 29 Jan 2017 16:06:13 +0100
Message-ID: <f9c6b228-bf23-a35d-6d73-c62be1764d1d@gmx.de>
References: <cover.1485665881.git.vomlehn@texas.net>
 <b46be5c30bbf72be8825fafb299feb8954b35872.1485665881.git.vomlehn@texas.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>,
        Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>
To: Alexander Loktionov <Alexander.Loktionov@aquantia.com>,
        netdev@vger.kernel.org, David VomLehn <vomlehn@texas.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:59740 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751231AbdA2PPD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 29 Jan 2017 10:15:03 -0500
In-Reply-To: <b46be5c30bbf72be8825fafb299feb8954b35872.1485665881.git.vomlehn@texas.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29.01.2017 06:09, Alexander Loktionov wrote:

> +
> +static int aq_ndev_start_xmit(struct sk_buff *skb, struct net_device *ndev)
> +{
> +	struct aq_nic_s *aq_nic = netdev_priv(ndev);
> +	int err = 0;
> +
> +	err = aq_nic_xmit(aq_nic, skb);

Initialization of err is superfluous.


> +	if (err < 0)
> +		goto err_exit;
> +
> +err_exit:
> +	return err;
> +}
> +
> +static int aq_ndev_change_mtu(struct net_device *ndev, int new_mtu)
> +{
> +	struct aq_nic_s *aq_nic = netdev_priv(ndev);
> +	int err = 0;
> +
> +	if (new_mtu == ndev->mtu) {

This check is not needed. This function wont be called if mtu has not 
changed.


> +
> +static int aq_pci_probe(struct pci_dev *pdev,
> +			const struct pci_device_id *pci_id)
> +{
> +	struct aq_hw_ops *aq_hw_ops = NULL;
> +	struct aq_pci_func_s *aq_pci_func = NULL;
> +	int err = 0;
> +
> +	err = pci_enable_device(pdev);
> +	if (err < 0)
> +		goto err_exit;
> +	aq_hw_ops = aq_pci_probe_get_hw_ops_by_id(pdev);
> +	aq_pci_func = aq_pci_func_alloc(aq_hw_ops, pdev,
> +					&aq_ndev_ops, &aq_ethtool_ops);
> +	if (!aq_pci_func) {

pci_disable_device() is missing.

> +
> +static int __init aq_module_init(void)
> +{
> +	int err = 0;
> +
> +	err = pci_register_driver(&aq_pci_ops);
> +	if (err < 0)
> +		goto err_exit;
> +
> +err_exit:
> +	return err;
> +}
> +
> +static void __exit aq_module_exit(void)
> +{
> +	pci_unregister_driver(&aq_pci_ops);
> +}
>

This can be reduced to a single line:

module_pci_driver(aq_pci_ops);

> +
> +static void aq_nic_service_timer_cb(unsigned long param)
> +{
> +	struct aq_nic_s *self = (struct aq_nic_s *)param;
> +	struct net_device *ndev = aq_nic_get_ndev(self);
> +	int err = 0;
> +	bool is_busy = false;
> +	unsigned int i = 0U;
> +	struct aq_hw_link_status_s link_status;
> +	struct aq_ring_stats_rx_s stats_rx;
> +	struct aq_ring_stats_tx_s stats_tx;
> +
> +	atomic_inc(&self->header.busy_count);
> +	is_busy = true;

What is "is_busy" needed for? Furthermore busy_count seems to be meant
for synchronization with the xmit function. Why do they have to be 
synchronized?


> +
> +	ndev->stats.rx_packets = stats_rx.packets;
> +	ndev->stats.rx_bytes = stats_rx.bytes;
> +	ndev->stats.rx_errors = stats_rx.errors;
> +	ndev->stats.tx_packets = stats_tx.packets;
> +	ndev->stats.tx_bytes = stats_tx.bytes;
> +	ndev->stats.tx_errors = stats_tx.errors;

You should consider the use of u64_stats_update_begin() and friends to
update and retrieve statistics. Also why do you have to update the
stats in a timer?


> +
> +struct aq_nic_s *aq_nic_alloc_cold(const struct net_device_ops *ndev_ops,
> +				   const struct ethtool_ops *et_ops,
> +				   struct device *dev,
> +				   struct aq_pci_func_s *aq_pci_func,
> +				   unsigned int port,
> +				   const struct aq_hw_ops *aq_hw_ops)
> +{
> +	struct net_device *ndev = NULL;
> +	struct aq_nic_s *self = NULL;
> +	int err = 0;
> +
> +	ndev = aq_nic_ndev_alloc();
> +	self = netdev_priv(ndev);
> +	if (!self) {

For this and all other checks of self:
how can self ever be NULL?

> +
> +int aq_nic_ndev_register(struct aq_nic_s *self)
> +{
> +	int err = 0;
> +	unsigned int i = 0U;
> +
> +	if (!self->ndev) {
> +		err = -EINVAL;
> +		goto err_exit;
> +	}
> +	err = self->aq_hw_ops.hw_get_mac_permanent(self->aq_hw,
> +			    self->aq_nic_cfg.aq_hw_caps,
> +			    self->ndev->dev_addr);
> +	if (err < 0)
> +		goto err_exit;
> +
> +#if defined(AQ_CFG_MAC_ADDR_PERMANENT)
> +	{
> +		static u8 mac_addr_permanent[] = AQ_CFG_MAC_ADDR_PERMANENT;
> +
> +		ether_addr_copy(self->ndev->dev_addr, mac_addr_permanent);
> +	}
> +#endif
> +	err = register_netdev(self->ndev);
> +	if (err < 0)
> +		goto err_exit;
> +

This looks racy. Note that as soon as you call register_netdev() your 
drivers open() function can be called. You have to setup everything
_before_ you call register_netdev().

> +	self->is_ndev_registered = true;
> +	netif_carrier_off(self->ndev);
> +
> +	for (i = AQ_CFG_VECS_MAX; i--;)
> +		aq_nic_ndev_queue_stop(self, i);
> +




> +
> +static unsigned int aq_nic_map_skb_frag(struct aq_nic_s *self,
> +					struct sk_buff *skb,
> +					struct aq_ring_buff_s *dx)
> +{
> +	unsigned int ret = 0U;
> +	unsigned int nr_frags = skb_shinfo(skb)->nr_frags;
> +	unsigned int frag_count = 0U;
> +
> +	dx->flags = 0U;
> +	dx->len = skb_headlen(skb);
> +	dx->pa = dma_map_single(aq_nic_get_dev(self), skb->data, dx->len,
> +				DMA_TO_DEVICE);

Mapping can fail. You have to check the result.

> +	dx->len_pkt = skb->len;
> +	dx->is_sop = 1U;
> +	dx->is_mapped = 1U;
> +
> +	++ret;
> +
> +	if (skb->ip_summed == CHECKSUM_PARTIAL) {
> +		dx->is_ip_cso = (htons(ETH_P_IP) == skb->protocol) ? 1U : 0U;
> +		dx->is_tcp_cso =
> +			(ip_hdr(skb)->protocol == IPPROTO_TCP) ? 1U : 0U;
> +		dx->is_udp_cso =
> +			(ip_hdr(skb)->protocol == IPPROTO_UDP) ? 1U : 0U;
> +	}
> +
> +	for (; nr_frags--; ++frag_count) {
> +		unsigned int frag_len;
> +		dma_addr_t frag_pa;
> +		skb_frag_t *frag = &skb_shinfo(skb)->frags[frag_count];
> +
> +		frag_len = skb_frag_size(frag);
> +
> +		frag_pa = skb_frag_dma_map(aq_nic_get_dev(self), frag, 0,
> +					   frag_len, DMA_TO_DEVICE);

Same here, you have to check if mapping was successful.

> +
> +int aq_nic_xmit(struct aq_nic_s *self, struct sk_buff *skb)
> +__releases(&ring->lock)
> +__acquires(&ring->lock)
> +{
> +	struct aq_ring_s *ring = NULL;
> +	unsigned int frags = 0U;
> +	unsigned int vec = skb->queue_mapping % self->aq_nic_cfg.vecs;
> +	unsigned int tc = 0U;
> +	unsigned int trys = AQ_CFG_LOCK_TRYS;
> +	int err = 0;

Please use NETDEV_TX_OK instead of 0 as the return value for successful 
transmission.

> +	bool is_nic_in_bad_state;
> +	bool is_busy = false;

What is "is_busy" needed for?

> +	struct aq_ring_buff_s buffers[AQ_CFG_SKB_FRAGS_MAX];

You allocate quite large buffers on a very limited resource (the kernel 
stack) only to copy the data from the local buffers to the xmit buffer
via aq_ring_tx_append_buffs(). Why dont map the xmit buffers directly?

> +
> +	frags = skb_shinfo(skb)->nr_frags + 1;
> +
> +	ring = self->aq_ring_tx[AQ_NIC_TCVEC2RING(self, tc, vec)];
> +
> +	atomic_inc(&self->header.busy_count);
> +	is_busy = true;
> +
> +	if (frags > AQ_CFG_SKB_FRAGS_MAX) {
> +		dev_kfree_skb_any(skb);
> +		goto err_exit;
> +	}
> +
> +	is_nic_in_bad_state = aq_utils_obj_test(&self->header.flags,
> +						AQ_NIC_FLAGS_IS_NOT_TX_READY) ||
> +						(aq_ring_avail_dx(ring) <
> +						AQ_CFG_SKB_FRAGS_MAX);
> +
> +	if (is_nic_in_bad_state) {
> +		aq_nic_ndev_queue_stop(self, ring->idx);
> +		err = NETDEV_TX_BUSY;
> +		goto err_exit;
> +	}
> +
> +	do {
> +		if (spin_trylock(&ring->header.lock)) {
> +			frags = aq_nic_map_skb(self, skb, &buffers[0]);
> +
> +			aq_ring_tx_append_buffs(ring, &buffers[0], frags);
> +
> +			err = self->aq_hw_ops.hw_ring_tx_xmit(self->aq_hw,
> +							      ring, frags);
> +			if (err >= 0) {
> +				if (aq_ring_avail_dx(ring) <
> +				    AQ_CFG_SKB_FRAGS_MAX + 1)
> +					aq_nic_ndev_queue_stop(self, ring->idx);
> +			}
> +			spin_unlock(&ring->header.lock);
> +
> +			if (err >= 0) {
> +				++ring->stats.tx.packets;
> +				ring->stats.tx.bytes += skb->len;
> +			}
> +			break;
> +		}
> +	} while (--trys);

AFAICS busy_count is only used in the timer callback. Why do they have 
to be synchronized?

> +
> +int aq_nic_stop(struct aq_nic_s *self)
> +{
> +	struct aq_vec_s *aq_vec = NULL;
> +	unsigned int i = 0U;
> +
> +	for (i = 0U, aq_vec = self->aq_vec[0];
> +		self->aq_vecs > i; ++i, aq_vec = self->aq_vec[i])
> +		aq_nic_ndev_queue_stop(self, i);
> +
> +	del_timer_sync(&self->service_timer);

This is not sufficient. You also have to make sure that the timer 
callback does not restart the timer.

> +
> +int aq_nic_change_pm_state(struct aq_nic_s *self, pm_message_t *pm_msg)
> +{
> +	int err = 0;
> +
> +	if (!netif_running(self->ndev)) {
> +		err = 0;
> +		goto err_exit;
> +	}
> +	rtnl_lock();
> +	if (pm_msg->event & PM_EVENT_SLEEP || pm_msg->event & PM_EVENT_FREEZE) {
> +		self->power_state = AQ_HW_POWER_STATE_D3;
> +		netif_device_detach(self->ndev);
> +		netif_tx_stop_all_queues(self->ndev);
> +
> +		err = aq_nic_stop(self);
> +		if (err < 0)
> +			goto err_exit;

rtnl_unlock() is missing.

> +
> +		aq_nic_deinit(self);
> +	} else {
> +		err = aq_nic_init(self);
> +		if (err < 0)
> +			goto err_exit;
> +
> +		err = aq_nic_start(self);
> +		if (err < 0)
> +			goto err_exit;
> +
> +		netif_device_attach(self->ndev);
> +		netif_tx_start_all_queues(self->ndev);
> +	}
> +	rtnl_unlock();
> +
> +err_exit:
> +	return err;
> +}


Regards,
Lino
