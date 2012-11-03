From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v4] Network driver for the Armada 370 and Armada XP ARM Marvell SoCs
Date: Sat, 3 Nov 2012 12:53:21 +0100
Message-ID: <20121103115321.GA4539@electric-eye.fr.zoreil.com>
References: <1351245804-31478-1-git-send-email-thomas.petazzoni@free-electrons.com> <20121030105154.5b7c8e48@skate> <20121102232137.3c9da5e4@skate>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Lennert Buytenhek <kernel@wantstofly.org>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Maen Suleiman <maen@marvell.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:50559 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932075Ab2KCMPx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2012 08:15:53 -0400
Content-Disposition: inline
In-Reply-To: <20121102232137.3c9da5e4@skate>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Petazzoni <thomas.petazzoni@free-electrons.com> :
[...]
> Any comments on this patch set? What should I do to make it progress
> towards integration?

Nits review above. I'll search more substantial things this evening.
It looks quite good.

Thomas Petazzoni <thomas.petazzoni@free-electrons.com> :
[...]
> +mvneta_rxq_next_desc_get(struct mvneta_rx_queue *rxq)
> +{
> +	int rx_desc = rxq->next_desc_to_proc;
> +	rxq->next_desc_to_proc = MVNETA_QUEUE_NEXT_DESC(rxq, rx_desc);

Insert an empty line after local variables declaration.

[...]
> +static struct mvneta_tx_desc *
> +mvneta_txq_next_desc_get(struct mvneta_tx_queue *txq)
> +{
> +	int tx_desc = txq->next_desc_to_proc;
> +	txq->next_desc_to_proc = MVNETA_QUEUE_NEXT_DESC(txq, tx_desc);

Insert an empty line after local variables declaration.

[...]
> +static struct mvneta_tx_queue *mvneta_tx_done_policy(struct mvneta_port *pp,
> +						     u32 cause)
> +{
> +	int queue;
> +	queue = fls(cause) - 1;

Insert an empty line after local variables declaration.

You may set this variable when you declare it.

> +	if (queue < 0 || queue >= txq_number)
> +		return NULL;
> +	return &pp->txqs[queue];

	return (queue < 0 || queue >= txq_number) ? NULL : &pp->txqs[queue];

[...]
> +static int mvneta_rx_refill(struct mvneta_port *pp,
> +			    struct mvneta_rx_desc *rx_desc)
> +
> +{
> +	dma_addr_t phys_addr;
> +	struct sk_buff *skb;
> +
> +	skb = netdev_alloc_skb(pp->dev, pp->pkt_size);
> +	if (!skb)
> +		return 1;
> +
> +	phys_addr = dma_map_single(pp->dev->dev.parent, skb->head,
> +				   MVNETA_RX_BUF_SIZE(pp->pkt_size),
> +				   DMA_FROM_DEVICE);
> +	if (unlikely(dma_mapping_error(pp->dev->dev.parent,
> +				       phys_addr))) {

	if (unlikely(dma_mapping_error(pp->dev->dev.parent, phys_addr))) {

> +		dev_kfree_skb(skb);
> +		return 1;
> +	}
> +
> +	mvneta_rx_desc_fill(rx_desc, phys_addr, (u32)skb);
> +
> +	return 0;
> +}

This is a bool returning function in disguise.

Were it supposed to be an error returning function, it should return <= 0

[...]
> +static struct mvneta_rx_queue *mvneta_rx_policy(struct mvneta_port *pp,
> +						u32 cause)
> +{
> +	int queue = fls(cause >> 8) - 1;

Insert an empty line after local variables declaration.

> +	if (queue < 0 || queue >= rxq_number)
> +		return NULL;
> +	return &pp->rxqs[queue];

See mvneta_tx_done_policy above.

[...]
> +static void mvneta_rxq_drop_pkts(struct mvneta_port *pp,
> +				 struct mvneta_rx_queue *rxq)
> +{
> +	int rx_done, i;
> +
> +	rx_done = mvneta_rxq_busy_desc_num_get(pp, rxq);
> +	for (i = 0; i < rxq->size; i++) {
> +		struct mvneta_rx_desc *rx_desc = rxq->descs + i;
> +		struct sk_buff *skb = (struct sk_buff *)rx_desc->buf_cookie;
> +		dev_kfree_skb_any(skb);

Insert an empty line after local variables declaration.

[...]
> +static int mvneta_rx(struct mvneta_port *pp, int rx_todo,
> +		     struct mvneta_rx_queue *rxq)
> +{
> +	struct net_device *dev = pp->dev;
> +	int rx_done, rx_filled;
> +
> +	/* Get number of received packets */
> +	rx_done = mvneta_rxq_busy_desc_num_get(pp, rxq);
> +
> +	if (rx_todo > rx_done)
> +		rx_todo = rx_done;
> +
> +	rx_done = 0;
> +	rx_filled = 0;
> +
> +	/* Fairness NAPI loop */
> +	while (rx_done < rx_todo) {
> +		struct mvneta_rx_desc *rx_desc = mvneta_rxq_next_desc_get(rxq);
> +		struct sk_buff *skb;
> +		u32 rx_status;
> +		int rx_bytes, err;
> +
> +		prefetch(rx_desc);
> +		rx_done++;
> +		rx_filled++;
> +		rx_status = rx_desc->status;
> +		skb = (struct sk_buff *)rx_desc->buf_cookie;
> +
> +		if (((rx_status & MVNETA_RXD_FIRST_LAST_DESC)
> +		     != MVNETA_RXD_FIRST_LAST_DESC)
> +		    || (rx_status & MVNETA_RXD_ERR_SUMMARY)) {

Operators appear at the end.

A dedicated (inline) function will help.

[...]
> +static int mvneta_tx_frag_process(struct mvneta_port *pp, struct sk_buff *skb,
[...]
> +		if (i == (skb_shinfo(skb)->nr_frags - 1)) {
> +			/* Last descriptor */
> +			tx_desc->command = (MVNETA_TXD_L_DESC |
> +					    MVNETA_TXD_Z_PAD);

			tx_desc->command = MVNETA_TXD_L_DESC | MVNETA_TXD_Z_PAD;

[...]
> +error:
> +	/* Release all descriptors that were used to map fragments of
> +	 * this packet, as well as the corresponding DMA mappings */
> +	for (j = i - 1; j >= 0; j--) {

j isn't needed. Recycle i.

[...]
> +static int mvneta_tx(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct mvneta_port *pp = netdev_priv(dev);
> +	struct mvneta_tx_queue *txq = &pp->txqs[txq_def];
> +	struct netdev_queue *nq;
> +	struct mvneta_tx_desc *tx_desc;
> +	int frags = 0;
> +	u32 tx_cmd;

Long lines first when possible.

[...]
> +		/* Continue with other skb fragments */
> +		if (mvneta_tx_frag_process(pp, skb, txq)) {

			got out_unmap;

> +			dma_unmap_single(dev->dev.parent,
> +					 tx_desc->buf_phys_addr,
> +					 tx_desc->data_size,
> +					 DMA_TO_DEVICE);
> +			mvneta_txq_desc_put(txq);
> +			frags = 0;
> +			goto out;
> +		}

[...]
> +static void mvneta_txq_done_force(struct mvneta_port *pp,
> +				  struct mvneta_tx_queue *txq)
> +
> +{
> +	int tx_done = txq->count;
> +	mvneta_txq_bufs_free(pp, txq, tx_done);

Insert an empty line after local variables declaration.

[...]
> +static int mvneta_rxq_fill(struct mvneta_port *pp, struct mvneta_rx_queue *rxq,
> +			   int num)
> +{
> +	int i;
> +	struct net_device *dev = pp->dev;

Long lines first when possible.

[...]
> +static int mvneta_rxq_init(struct mvneta_port *pp,
> +			   struct mvneta_rx_queue *rxq)
> +
> +{
> +	rxq->size = pp->rx_ring_size;
> +
> +	/* Allocate memory for RX descriptors */
> +	rxq->descs = dma_alloc_coherent(pp->dev->dev.parent,
> +					rxq->size * MVNETA_DESC_ALIGNED_SIZE,
> +					&rxq->descs_phys,
> +					GFP_KERNEL);

					&rxq->descs_phys, GFP_KERNEL);

> +	if (rxq->descs == NULL) {
> +		netdev_err(pp->dev,
> +			   "rxQ=%d: Can't allocate %d bytes for %d RX descr\n",
> +			   rxq->id, rxq->size * MVNETA_DESC_ALIGNED_SIZE,
> +			   rxq->size);
> +		return -ENOMEM;
> +	}
> +
> +	BUG_ON(rxq->descs !=
> +	       PTR_ALIGN(rxq->descs, MVNETA_CPU_D_CACHE_LINE_SIZE));

There is no reason to crash.

(...]
> +static int mvneta_txq_init(struct mvneta_port *pp,
> +			   struct mvneta_tx_queue *txq)
> +{
> +	txq->size = pp->tx_ring_size;
> +
> +	/* Allocate memory for TX descriptors */
> +	txq->descs = dma_alloc_coherent(pp->dev->dev.parent,
> +					txq->size * MVNETA_DESC_ALIGNED_SIZE,
> +					&txq->descs_phys,
> +					DMA_BIDIRECTIONAL);

					&txq->descs_phys, DMA_BIDIRECTIONAL);

> +	if (txq->descs == NULL) {
> +		netdev_err(pp->dev,
> +			   "txQ=%d: Can't allocate %d bytes for %d TX descr\n",
> +			   txq->id, txq->size * MVNETA_DESC_ALIGNED_SIZE,
> +			   txq->size);
> +		return -ENOMEM;
> +	}
> +
> +	/* Make sure descriptor address is cache line size aligned  */
> +	BUG_ON(txq->descs !=
> +	       PTR_ALIGN(txq->descs, MVNETA_CPU_D_CACHE_LINE_SIZE));

There is no reason to crash.

[...]
> +	txq->tx_skb = kmalloc(txq->size * sizeof(*txq->tx_skb),
> +			      GFP_KERNEL);

	txq->tx_skb = kmalloc(txq->size * sizeof(*txq->tx_skb), GFP_KERNEL);

[...]
> +static void mvneta_txq_deinit(struct mvneta_port *pp,
> +			      struct mvneta_tx_queue *txq)
> +{
> +	kfree(txq->tx_skb);
> +
> +	if (txq->descs)
> +		dma_free_coherent(pp->dev->dev.parent,
> +				  txq->size * MVNETA_DESC_ALIGNED_SIZE,
> +				  txq->descs,
> +				  txq->descs_phys);

				  txq->descs, txq->descs_phys);

[...]
> +static void mvneta_cleanup_txqs(struct mvneta_port *pp)
> +{
> +	int queue;
> +	for (queue = 0; queue < txq_number; queue++)
> +		mvneta_txq_deinit(pp, &pp->txqs[queue]);

Insert an empty line after local variables declaration.

[...]
> +static void mvneta_cleanup_rxqs(struct mvneta_port *pp)
> +{
> +	int queue;
> +	for (queue = 0; queue < rxq_number; queue++)
> +		mvneta_rxq_deinit(pp, &pp->rxqs[queue]);

Insert an empty line after local variables declaration.

[...]
> +static int mvneta_setup_rxqs(struct mvneta_port *pp)
> +{
> +	int queue;
> +
> +	for (queue = 0; queue < rxq_number; queue++) {
> +		int err = mvneta_rxq_init(pp, &pp->rxqs[queue]);
> +		if (err) {
> +			netdev_err(pp->dev,
> +				   "%s: can't create RxQ rxq=%d\n",

			netdev_err(pp->dev, "%s: can't create RxQ rxq=%d\n",

> +				   __func__, queue);
> +			mvneta_cleanup_rxqs(pp);
> +			return -ENODEV;

mvneta_rxq_init should return a proper error code and it should be
propagated (option: break instead of return and mvneta_setup_rxqs scoped
err variable)

[...]
> +static int mvneta_setup_txqs(struct mvneta_port *pp)
> +{
> +	int queue;
> +
> +	for (queue = 0; queue < txq_number; queue++) {
> +		int err = mvneta_txq_init(pp, &pp->txqs[queue]);
> +		if (err) {
> +			netdev_err(pp->dev,
> +				   "%s: can't create TxQ txq=%d\n",
> +				   __func__, queue);
> +			mvneta_cleanup_txqs(pp);
> +			return err;
> +		}
> +	}

See mvneta_setup_rxqs above.

[...]
> +static void mvneta_start_dev(struct mvneta_port *pp)
> +{
> +	mvneta_max_rx_size_set(pp, pp->pkt_size);
> +	mvneta_txq_max_tx_size_set(pp, pp->pkt_size);
> +
> +	/* start the Rx/Tx activity */
> +	mvneta_port_enable(pp);
> +
> +	/* Enable polling on the port */
> +	napi_enable(&pp->napi);
> +
> +	/* Unmask interrupts */
> +	mvneta_interrupts_unmask(pp);
> +	smp_call_function_many(cpu_online_mask,
> +			       mvneta_interrupts_unmask,
> +			       pp, 1);

	smp_call_function_many(cpu_online_mask, mvneta_interrupts_unmask,

(as done in mvneta_stop_dev)

> +
> +	phy_start(pp->phy_dev);
> +	netif_tx_start_all_queues(pp->dev);
> +}
> +
> +static void mvneta_stop_dev(struct mvneta_port *pp)
> +{
> +	phy_stop(pp->phy_dev);
> +
> +	napi_disable(&pp->napi);
> +
> +	/* Stop upper layer */
> +	netif_carrier_off(pp->dev);

Useless comment.

> +
> +	mvneta_port_down(pp);
> +	netif_tx_stop_all_queues(pp->dev);
> +
> +	/* Stop the port activity */
> +	mvneta_port_disable(pp);
> +
> +	/* Clear all ethernet port interrupts */
> +	mvreg_write(pp, MVNETA_INTR_MISC_CAUSE, 0);
> +	mvreg_write(pp, MVNETA_INTR_OLD_CAUSE, 0);
> +
> +	/* Mask all interrupts */
> +	mvneta_interrupts_mask(pp);

Useless comment.

> +	smp_call_function_many(cpu_online_mask, mvneta_interrupts_mask,
> +			       pp, 1);
> +
> +	/* Reset TX port here. */
> +	mvneta_tx_reset(pp);
> +	mvneta_rx_reset(pp);

Useless comment.

> +}
> +
> +/* tx timeout callback - display a message and stop/start the network device */
> +static void mvneta_tx_timeout(struct net_device *dev)
> +{
> +	struct mvneta_port *pp = netdev_priv(dev);
> +	netdev_info(dev, "tx timeout\n");

Insert an empty line after local variables declaration.

[...]
> +static int mvneta_check_mtu_valid(struct net_device *dev, int mtu)
> +{
> +	if (mtu < 68) {
> +		netdev_err(dev, "cannot change mtu to less than 68\n");
> +		return -EINVAL;
> +	}
> +
> +	if (mtu > 9676 /* 9700 - 20 and rounding to 8 */) {

Please use a different comment style, say on a proper line, or a define with
a comment above it.

[...]
> +static int mvneta_ethtool_set_coalesce(struct net_device *dev,
> +				       struct ethtool_coalesce *c)
> +{
> +	int queue;
> +	struct mvneta_port *pp = netdev_priv(dev);

Long lines first when possible.

[...]
> +static const struct net_device_ops mvneta_netdev_ops = {
> +	.ndo_open = mvneta_open,
> +	.ndo_stop = mvneta_stop,
> +	.ndo_start_xmit = mvneta_tx,
> +	.ndo_set_rx_mode = mvneta_set_rx_mode,
> +	.ndo_set_mac_address = mvneta_set_mac_addr,
> +	.ndo_change_mtu = mvneta_change_mtu,
> +	.ndo_tx_timeout = mvneta_tx_timeout,
> +	.ndo_get_stats64 = mvneta_get_stats64,

Please use tabs before '=' and line things up.

> +};
> +
> +const struct ethtool_ops mvneta_eth_tool_ops = {
> +	.get_link = ethtool_op_get_link,
> +	.get_settings = mvneta_ethtool_get_settings,
> +	.set_settings = mvneta_ethtool_set_settings,
> +	.set_coalesce = mvneta_ethtool_set_coalesce,
> +	.get_coalesce = mvneta_ethtool_get_coalesce,
> +	.get_drvinfo  = mvneta_ethtool_get_drvinfo,
> +	.get_ringparam	= mvneta_ethtool_get_ringparam,
> +	.set_ringparam	= mvneta_ethtool_set_ringparam,

Please use tabs before '=' and line things up.

[...]
> +static int __devinit mvneta_init(struct mvneta_port *pp, int phy_addr)
> +{
> +	int queue, i, ret = 0;
> +
> +	/* Disable port */
> +	mvneta_port_disable(pp);
> +
> +	/* Set port default values */
> +	mvneta_defaults_set(pp);
> +
> +	pp->txqs = kzalloc(txq_number * sizeof(struct mvneta_tx_queue),
> +			   GFP_KERNEL);
> +	if (!pp->txqs) {
> +		netdev_err(pp->dev, "out of memory in allocating tx queue\n");

I doubt a message is really needed when a GFP_KERNEL oom triggers.

(...]
> +static void __devinit mvneta_conf_mbus_windows(struct mvneta_port *pp,
> +				const struct mbus_dram_target_info *dram)
> +{
[...]
> +	for (i = 0; i < dram->num_cs; i++) {
> +		const struct mbus_dram_window *cs = dram->cs + i;
> +		mvreg_write(pp, MVNETA_WIN_BASE(i),
> +			    (cs->base & 0xffff0000) |
> +			    (cs->mbus_attr << 8) |
> +			    dram->mbus_dram_target_id);

		mvreg_write(pp, MVNETA_WIN_BASE(i), (cs->base & 0xffff0000) |
			    (cs->mbus_attr << 8) | dram->mbus_dram_target_id);

[...]
> +static int __devinit mvneta_probe(struct platform_device *pdev)
> +{
> +	int err = -EINVAL;
> +	struct mvneta_port *pp;
> +	struct net_device *dev;
> +	u32 phy_addr, clk_rate_hz;
> +	int phy_mode;
> +	const char *mac_addr;
> +	const struct mbus_dram_target_info *dram_target_info;
> +	struct device_node *dn = pdev->dev.of_node;

Long lines first when possible.

-- 
Ueimor
