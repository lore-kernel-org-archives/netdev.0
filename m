From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/3] ethernet: Add new driver for Marvell Armada 375
 network unit
Date: Sat, 5 Jul 2014 23:03:59 +0200
Message-ID: <20140705210359.GA19441@electric-eye.fr.zoreil.com>
References: <1404498697-21978-1-git-send-email-ezequiel.garcia@free-electrons.com>
 <1404498697-21978-2-git-send-email-ezequiel.garcia@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Jason Cooper <jason@lakedaemon.net>,
	Marcin Wojtas <mw@semihalf.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>
To: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:33682 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753645AbaGEVEn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jul 2014 17:04:43 -0400
Content-Disposition: inline
In-Reply-To: <1404498697-21978-2-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Partial review below.

> diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
> new file mode 100644
> index 0000000..154b866
> --- /dev/null
> +++ b/drivers/net/ethernet/marvell/mvpp2.c
[...]
> +static int mvpp2_prs_tcam_first_free(struct mvpp2 *pp2, int start, int end)
> +{
> +	int tid;
> +	bool found = false;
> +
> +	if (start < end)
> +		for (tid = start; tid <= end; tid++) {
> +			if (!pp2->prs_shadow[tid].valid) {
> +				found = true;
> +				break;
> +			}
> +		}
> +	else
> +		for (tid = start; tid >= end; tid--) {
> +			if (!pp2->prs_shadow[tid].valid) {
> +				found = true;
> +				break;
> +			}
> +		}

Missing parenthsesis in "if ... else ..." block.

[...]
> +static void mvpp2_defaults_set(struct mvpp2_port *pp)
> +{
[...]
> +	/* At default, mask all interrupts to all present cpus */
> +	for_each_present_cpu(cpu)
> +		mvpp2_cpu_interrupts_disable(pp, cpu);

Would it hurt to issue a single write and disable all irqs ?

[...]
> +static int mvpp2_tx_frag_process(struct mvpp2_port *pp, struct sk_buff *skb,
> +				 struct mvpp2_tx_queue *aggr_txq,
> +				 struct mvpp2_tx_queue *txq)
> +{
[...]
> +error:
> +	/* Release all descriptors that were used to map fragments of
> +	 * this packet, as well as the corresponding DMA mappings
> +	 */
> +	for (i = i - 1; i >= 0; i--) {

You may consider "while (--i >= 0) {" as an idiom to balance a
"for (i = 0; .." loop. Your call.

> +		tx_desc = txq->descs + i;
> +		dma_unmap_single(pp->dev->dev.parent,
> +				 tx_desc->buf_phys_addr,
> +				 tx_desc->data_size,
> +				 DMA_TO_DEVICE);

		dma_unmap_single(pp->dev->dev.parent, tx_desc->buf_phys_addr,
				 tx_desc->data_size, DMA_TO_DEVICE);

You may also factor out mvpp2_dma_unmap_single(pp, tx_desc) or the whole
dma_unmap_single + mvpp2_txq_desc_put sequence.

[...]
> +/* Main tx processing */
> +static int mvpp2_tx(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct mvpp2_port *pp = netdev_priv(dev);
> +	struct mvpp2_tx_queue *txq, *aggr_txq;
> +	struct mvpp2_txq_pcpu *txq_pcpu;
> +	struct mvpp2_tx_desc *tx_desc;
> +	dma_addr_t buf_phys_addr;
> +	int frags = 0;
> +	u16 txq_id;
> +	u32 tx_cmd;
> +
> +	if (!netif_running(dev))
> +		goto out;

The driver is expected to netif_stop_queue when the device goes down, not
the opposite.

[...]
> +static int mvpp2_poll(struct napi_struct *napi, int budget)
> +{
> +	u32 cause_rx_tx, cause_rx;
> +	int rx_done = 0;
> +	struct mvpp2_port *pp = netdev_priv(napi->dev);
> +
> +	if (!netif_running(pp->dev)) {
> +		napi_complete(napi);
> +		return rx_done;
> +	}

Same thing as above.

[...]
> +static int mvpp2_ethtool_set_ringparam(struct net_device *dev,
> +				       struct ethtool_ringparam *ring)
> +{
> +	struct mvpp2_port *pp = netdev_priv(dev);
> +
> +	if ((ring->rx_pending == 0) || (ring->tx_pending == 0))
> +		return -EINVAL;
> +	pp->rx_ring_size = ring->rx_pending < MVPP2_MAX_RXD ?
> +		ring->rx_pending : MVPP2_MAX_RXD;
> +	pp->tx_ring_size = ring->tx_pending < MVPP2_MAX_TXD ?
> +		ring->tx_pending : MVPP2_MAX_TXD;
> +
> +	if (netif_running(dev)) {
> +		mvpp2_stop(dev);
> +		if (mvpp2_open(dev)) {

You aren't supposed to (ab)use net_device_ops.{ndo_open / stop} like that.
mvpp2_tx() is still racing with mvpp2_cleanup_txqs(). Even if you go through
the hassle of (1) avoiding this race, then (2) enforcing a safe double call
of mvpp2_stop without any mvpp2_open inbetween, nobody wants its device to
become unresponsive because of a failed ring parameter change: the driver
must stop and configure the physical device more gently.

Depending on the rework, you may consider postponing ethtool ring change to
a separate patch series.

[...]
> +static const struct net_device_ops mvpp2_netdev_ops = {
> +	.ndo_open            = mvpp2_open,
> +	.ndo_stop            = mvpp2_stop,
> +	.ndo_start_xmit      = mvpp2_tx,
> +	.ndo_set_rx_mode     = mvpp2_set_rx_mode,
> +	.ndo_set_mac_address = mvpp2_set_mac_address,
> +	.ndo_change_mtu      = mvpp2_change_mtu,
> +	.ndo_get_stats64     = mvpp2_get_stats64,
> +};

Please replace spaces by tabs before "=".

> +
> +static const struct ethtool_ops mvpp2_eth_tool_ops = {
> +	.get_link       = ethtool_op_get_link,
> +	.get_settings   = mvpp2_ethtool_get_settings,
> +	.set_settings   = mvpp2_ethtool_set_settings,
> +	.set_coalesce   = mvpp2_ethtool_set_coalesce,
> +	.get_coalesce   = mvpp2_ethtool_get_coalesce,
> +	.get_drvinfo    = mvpp2_ethtool_get_drvinfo,
> +	.get_ringparam  = mvpp2_ethtool_get_ringparam,
> +	.set_ringparam	= mvpp2_ethtool_set_ringparam,
> +};

Same as above.

[...]
> +static int mvpp2_port_init(struct mvpp2_port *pp)
> +{
> +	struct device *dev = pp->dev->dev.parent;
> +	struct mvpp2 *pp2 = pp->pp2;
> +	struct mvpp2_txq_pcpu *txq_pcpu;
> +	int queue, txp, cpu;
> +
> +	if (pp->first_rxq + rxq_number > MVPP2_RXQ_TOTAL_NUM)
> +		return -EINVAL;
> +
> +	/* Disable port */
> +	mvpp2_egress_disable(pp);
> +	mvpp2_port_disable(pp);
> +
> +	pp->txqs = devm_kzalloc(dev, pp->txp_num * txq_number *
> +				sizeof(struct mvpp2_tx_queue *), GFP_KERNEL);
> +	if (!pp->txqs)
> +		return -ENOMEM;
> +
> +	/* Associate physical Tx queues to this port and initialize.
> +	 * The mapping is predefined.
> +	 */
> +	for (txp = 0; txp < pp->txp_num; txp++) {
> +		for (queue = 0; queue < txq_number; queue++) {
> +			int txq_idx = txp * txq_number + queue;
> +			int queue_phy_id = mvpp2_txq_phys(pp->id, queue);
> +			struct mvpp2_tx_queue *txq;
> +
> +			txq = devm_kzalloc(dev, sizeof(*txq), GFP_KERNEL);
> +			if (!txq)
> +				return -ENOMEM;
> +
> +			txq->pcpu = alloc_percpu(struct mvpp2_txq_pcpu);
> +			if (!txq->pcpu)
> +				return -ENOMEM;

There is a per_cpu leak if mvpp2_port_init fails.

[...]
> +/* Ports initialization */
> +static int mvpp2_port_probe(struct platform_device *pdev,
> +			    struct device_node *port_node,
> +			    struct mvpp2 *pp2,
> +			    int *next_first_rxq)
> +{
> +	struct device_node *phy_node;
> +	struct mvpp2_port *pp;

(nit below)

I am not a huge fan of the "pp2" variable as there's no "pp1" but I've seen
worse. However naming "pp" some completely unrelated data imho verges on
confusing

[...]
> +	dev->irq = irq_of_parse_and_map(port_node, 0);
> +	if (dev->irq == 0) {
> +		err = -EINVAL;
> +		goto err_free_netdev;
> +	}

net_device.irq should be considered legacy. It would be nice to avoid
more uses of it. You may store it near pp->base for instance.

-- 
Ueimor
