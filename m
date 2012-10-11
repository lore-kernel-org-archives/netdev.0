From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2 1/4] net: mvneta: driver for Marvell Armada 370/XP network unit
Date: Thu, 11 Oct 2012 23:26:29 +0200
Message-ID: <20121011212629.GA14171@electric-eye.fr.zoreil.com>
References: <1349969282-12676-1-git-send-email-thomas.petazzoni@free-electrons.com> <1349969282-12676-2-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Lennert Buytenhek <kernel@wantstofly.org>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Maen Suleiman <maen@marvell.com>,
	Rami Rosen <rosenr@marvell.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:52349 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759414Ab2JKVrG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 17:47:06 -0400
Content-Disposition: inline
In-Reply-To: <1349969282-12676-2-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Petazzoni <thomas.petazzoni@free-electrons.com> :
[...]
> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
> new file mode 100644
> index 0000000..4f7fe08
> --- /dev/null
> +++ b/drivers/net/ethernet/marvell/mvneta.c
[...]
> +struct mvneta_port {
> +	/* Packet size in bytes */
> +	int pkt_size;
> +
> +	/* Base virtual address of the Ethernet controller registers */
> +	void __iomem *base;
> +
> +	/* Array of RX queues */
> +	struct mvneta_rx_queue *rxqs;
> +
> +	/* Array of TX queues */
> +	struct mvneta_tx_queue *txqs;
> +
> +	/* Timer */
> +	struct timer_list tx_done_timer;
> +
> +	/* Back pointer to the Linux network interface device */
> +	struct net_device *dev;

You can avoid five comments.

> +
> +	u32 cause_rx_tx[CONFIG_NR_CPUS];
> +	struct napi_struct napi;
> +
> +	/* Flags */
> +	unsigned long flags;
> +#define MVNETA_F_TX_DONE_TIMER_BIT  0
> +
> +	/* Napi weight */
> +	int weight;
> +
> +	/* Core clock [Hz] */
> +	unsigned int clk_rate;

clk_rate_hz

[...]
> +/* Get System Network Statistics */
> +struct rtnl_link_stats64 *mvneta_get_stats64(struct net_device *dev,
> +					     struct rtnl_link_stats64 *stats)
> +{
> +	struct mvneta_port *pp = netdev_priv(dev);
> +	unsigned int start;
> +
> +	memset(stats, 0, sizeof(struct rtnl_link_stats64));
> +
> +	do {
> +		start = u64_stats_fetch_begin_bh(&pp->rx_stats.syncp);
> +		stats->rx_packets = pp->rx_stats.packets;
> +		stats->rx_bytes	= pp->rx_stats.bytes;
> +	} while (u64_stats_fetch_retry_bh(&pp->rx_stats.syncp, start));
> +
> +
> +	do {
> +		start = u64_stats_fetch_begin_bh(&pp->tx_stats.syncp);
> +		stats->tx_packets = pp->tx_stats.packets;
> +		stats->tx_bytes	= pp->tx_stats.bytes;
> +	} while (u64_stats_fetch_retry_bh(&pp->tx_stats.syncp, start));
> +
> +	stats->rx_errors	= dev->stats.rx_errors;
> +	stats->rx_dropped	= dev->stats.rx_dropped;
> +
> +	stats->tx_dropped	= dev->stats.tx_dropped;
> +
> +	return stats;
> +
> +}

Excess empty line.

[...]
> +static void mvneta_rxq_desc_num_update(struct mvneta_port *pp,
> +				       struct mvneta_rx_queue *rxq,
> +				       int rx_done, int rx_filled)
> +{
> +	u32 val;
> +
> +	if ((rx_done <= 0xff) && (rx_filled <= 0xff)) {
> +		val = rx_done |
> +		  (rx_filled << MVNETA_RXQ_ADD_NON_OCCUPIED_SHIFT);
> +		mvreg_write(pp, MVNETA_RXQ_STATUS_UPDATE_REG(rxq->id), val);
> +		return;
> +	}
> +
> +	/* Only 255 descriptors can be added at once */
> +	while ((rx_done > 0) || (rx_filled > 0)) {
> +		if (rx_done <= 0xff) {
> +			val = rx_done;
> +			rx_done = 0;
> +		} else {
> +			val = 0xff;
> +			rx_done -= 0xff;
> +		}
> +		if (rx_filled <= 0xff) {
> +			val |= rx_filled
> +				<< MVNETA_RXQ_ADD_NON_OCCUPIED_SHIFT;

			val |= rx_filled << MVNETA_RXQ_ADD_NON_OCCUPIED_SHIFT;

> +			rx_filled = 0;
> +		} else {
> +			val |= 0xff << MVNETA_RXQ_ADD_NON_OCCUPIED_SHIFT;
> +			rx_filled -= 0xff;
> +		}
> +		mvreg_write(pp, MVNETA_RXQ_STATUS_UPDATE_REG(rxq->id), val);
> +	}
> +}
> +
> +/* Get pointer to next RX descriptor to be processed by SW */
> +static struct mvneta_rx_desc *
> +mvneta_rxq_next_desc_get(struct mvneta_rx_queue *rxq)
> +{
> +	int rx_desc = rxq->next_desc_to_proc;
> +
> +	rxq->next_desc_to_proc =
> +		MVNETA_QUEUE_NEXT_DESC(rxq, rx_desc);

	rxq->next_desc_to_proc = MVNETA_QUEUE_NEXT_DESC(rxq, rx_desc);

> +
> +	return rxq->descs + rx_desc;
> +}
> +
> +/* Change maximum receive size of the port. */
> +static void mvneta_max_rx_size_set(struct mvneta_port *pp, int max_rx_size)
> +{
> +	u32 val;
> +
> +	val =  mvreg_read(pp, MVNETA_GMAC_CTRL_0);
> +	val &= ~MVNETA_GMAC_MAX_RX_SIZE_MASK;
> +	val |= (((max_rx_size - MVNETA_MH_SIZE) / 2)
> +		    << MVNETA_GMAC_MAX_RX_SIZE_SHIFT);

Excess parenthesis.
Operator on start of line.

[...]
> +static struct mvneta_tx_desc *
> +mvneta_txq_next_desc_get(struct mvneta_tx_queue *txq)
> +{
> +	int tx_desc = txq->next_desc_to_proc;
> +	txq->next_desc_to_proc =
> +		MVNETA_QUEUE_NEXT_DESC(txq, tx_desc);

	int tx_desc = txq->next_desc_to_proc;

	txq->next_desc_to_proc = MVNETA_QUEUE_NEXT_DESC(txq, tx_desc);

[...]
> +static void mvneta_port_up(struct mvneta_port *pp)
> +{
> +	int queue;
> +	u32 q_map;
> +
> +	/* Enable all initialized TXs. */
> +	mvneta_mib_counters_clear(pp);
> +	q_map = 0;
> +	for (queue = 0; queue < mvneta_txq_number; queue++) {
> +		struct mvneta_tx_queue *txq = &pp->txqs[queue];

> +		if (txq->descs != NULL)
> +			q_map |= (1 << queue);
> +	}
> +	mvreg_write(pp, MVNETA_TXQ_CMD, q_map);
> +
> +	/* Enable all initialized RXQs. */
> +	q_map = 0;
> +	for (queue = 0; queue < mvneta_rxq_number; queue++) {
> +		struct mvneta_rx_queue *rxq = &pp->rxqs[queue];

> +		if (rxq->descs != NULL)
> +			q_map |= (1 << queue);
> +	}
> +
> +	mvreg_write(pp, MVNETA_RXQ_CMD, q_map);
> +}
> +
> +/* Stop the Ethernet port activity */
> +static void mvneta_port_down(struct mvneta_port *pp)
> +{
> +	u32 val;
> +	int count;
> +
> +	/* Stop Rx port activity. Check port Rx activity. */
> +	val = (mvreg_read(pp, MVNETA_RXQ_CMD))
> +		& MVNETA_RXQ_ENABLE_MASK;

	val = mvreg_read(pp, MVNETA_RXQ_CMD) & MVNETA_RXQ_ENABLE_MASK;

> +	/* Issue stop command for active channels only */
> +	if (val != 0)
> +		mvreg_write(pp, MVNETA_RXQ_CMD,
> +			    val << MVNETA_RXQ_DISABLE_SHIFT);

Too bad "val" isn't one character shorter.

> +
> +	/* Wait for all Rx activity to terminate. */
> +	count = 0;
> +	do {
> +		if (count >= MVNETA_RX_DISABLE_TIMEOUT_MSEC) {
> +			netdev_warn(pp->dev,
> +				    "TIMEOUT for RX stopped ! rx_queue_cmd: 0x08%x\n",
> +				    val);
> +			break;
> +		}
> +		mdelay(1);
> +		count++;
> +
> +		val = mvreg_read(pp, MVNETA_RXQ_CMD);
> +	} while (val & 0xff);

You can test "if (count++ >= MVNETA_RX_DISABLE_TIMEOUT_MSEC) {". Nobody
will notice.

> +
> +	/* Stop Tx port activity. Check port Tx activity. Issue stop
> +	   command for active channels only  */
> +	val = (mvreg_read(pp, MVNETA_TXQ_CMD)) & MVNETA_TXQ_ENABLE_MASK;
> +
> +	if (val != 0)
> +		mvreg_write(pp, MVNETA_TXQ_CMD,
> +			    (val << MVNETA_TXQ_DISABLE_SHIFT));
> +
> +	/* Wait for all Tx activity to terminate. */
> +	count = 0;
> +	do {
> +		if (count >= MVNETA_TX_DISABLE_TIMEOUT_MSEC) {
> +			netdev_warn(pp->dev,
> +				    "TIMEOUT for TX stopped tx_queue_cmd - 0x%08x\n",
> +				    val);
> +			break;
> +		}
> +		mdelay(1);
> +		count++;
> +
> +		/* Check TX Command reg that all Txqs are stopped */
> +		val = mvreg_read(pp, MVNETA_TXQ_CMD);
> +
> +	} while (val & 0xff);
> +
> +	/* Double check to verify that TX FIFO is empty */
> +	count = 0;
> +	do {
> +		if (count >= MVNETA_TX_FIFO_EMPTY_TIMEOUT) {
> +			netdev_warn(pp->dev,
> +				    "TX FIFO empty timeout status=0x08%x",
> +				    val);

				    "TX FIFO empty timeout status=0x08%x", val);

> +			break;
> +		}
> +		mdelay(1);
> +		count++;
> +
> +		val = mvreg_read(pp, MVNETA_PORT_STATUS);
> +	} while (!(val & MVNETA_TX_FIFO_EMPTY) &&
> +		 (val & MVNETA_TX_IN_PRGRS));
> +
> +	udelay(200);
> +}
> +
> +/* Enable the port by setting the port enable bit of the MAC control register */
> +static void mvneta_port_enable(struct mvneta_port *pp)
> +{
> +	u32 val;
> +
> +	/* Enable port */
> +	val = mvreg_read(pp, MVNETA_GMAC_CTRL_0);
> +	val |= MVNETA_GMAC0_PORT_ENABLE;
> +	mvreg_write(pp, MVNETA_GMAC_CTRL_0, val);
> +}
> +
> +/* Disable the port and wait for about 200 usec before retuning */
> +static void mvneta_port_disable(struct mvneta_port *pp)
> +{
> +	u32 val;
> +
> +	/* Reset the Enable bit in the Serial Control Register */
> +	val = mvreg_read(pp, MVNETA_GMAC_CTRL_0);
> +	val &= ~(MVNETA_GMAC0_PORT_ENABLE);

Excess parenthesis.

> +	mvreg_write(pp, MVNETA_GMAC_CTRL_0, val);
> +
> +	udelay(200);
> +}
> +
> +/* Multicast tables methods */
> +
> +/* Set all entries in Unicast MAC Table; queue==-1 means reject all */
> +static void mvneta_set_ucast_table(struct mvneta_port *pp, int queue)
> +{
> +	int offset;
> +	u32 val;
> +
> +	if (queue == -1) {
> +		val = 0;
> +	} else {
> +		val =	(((0x01 | (queue << 1)) << 0) |
> +			((0x01 | (queue << 1)) << 8) |
> +			((0x01 | (queue << 1)) << 16) |
> +			((0x01 | (queue << 1)) << 24));

		val =  (0x01 | (queue << 1)) |
		      ((0x01 | (queue << 1)) << 8) |
		      ((0x01 | (queue << 1)) << 16) |
		      ((0x01 | (queue << 1)) << 24);

		val  = 0x01 | (queue << 1);
		val |= (val << 24) | (val << 16) | (val << 8);
> +	}
> +
> +	for (offset = 0; offset <= 0xc; offset += 4)
> +		mvreg_write(pp, MVNETA_DA_FILT_UCAST_BASE + offset, val);
> +}
> +
> +/* Set all entries in Special Multicast MAC Table; queue==-1 means reject all */
> +static void mvneta_set_special_mcast_table(struct mvneta_port *pp, int queue)
> +{
> +	int offs;
> +	u32 val;
> +
> +	if (queue == -1) {
> +		val = 0;
> +	} else {
> +		val =	(((0x01 | (queue << 1)) << 0) |
> +			((0x01 | (queue << 1)) << 8) |
> +			((0x01 | (queue << 1)) << 16) |
> +			((0x01 | (queue << 1)) << 24));

Bis.

> +	}
> +
> +	for (offs = 0; offs <= 0xfc; offs += 4)
> +		mvreg_write(pp, (MVNETA_DA_FILT_SPEC_MCAST + offs), val);
> +
> +}
> +
> +/* Set all entries in Other Multicast MAC Table. queue==-1 means reject all */
> +static void mvneta_set_other_mcast_table(struct mvneta_port *pp, int queue)
> +{
> +	int offset;
> +	u32 val;
> +
> +	if (queue == -1) {
> +		memset(pp->mcast_count, 0, sizeof(pp->mcast_count));
> +		val = 0;
> +	} else {
> +		memset(pp->mcast_count, 1, sizeof(pp->mcast_count));
> +		val = (((0x01 | (queue << 1)) << 0) |
> +			  ((0x01 | (queue << 1)) << 8) |
> +			  ((0x01 | (queue << 1)) << 16) |
> +			  ((0x01 | (queue << 1)) << 24));

Ter.

[...]
> +static void mvneta_rx_pkts_coal_set(struct mvneta_port *pp,
> +				    struct mvneta_rx_queue *rxq, u32 value)
> +{
> +	mvreg_write(pp, MVNETA_RXQ_THRESHOLD_REG(rxq->id),
> +		    (value | MVNETA_RXQ_NON_OCCUPIED(0)));

Excess parenthesis.

> +	rxq->pkts_coal = value;
> +}
> +
> +/*
> + * Set the time delay in usec before
> + * RX interrupt will be generated by HW.
> + */
> +static void mvneta_rx_time_coal_set(struct mvneta_port *pp,
> +				    struct mvneta_rx_queue *rxq, u32 value)
> +{
> +	u32 val = (pp->clk_rate / 1000000) * value;
> +
> +	mvreg_write(pp, MVNETA_RXQ_TIME_COAL_REG(rxq->id), val);
> +	rxq->time_coal = value;
> +}
> +
> +/* Set threshold for TX_DONE pkts coalescing */
> +static void mvneta_tx_done_pkts_coal_set(struct mvneta_port *pp,
> +					 struct mvneta_tx_queue *txq, u32 value)
> +{
> +	u32 val;
> +
> +	val = mvreg_read(pp, MVNETA_TXQ_SIZE_REG(txq->id));
> +
> +	val &= ~MVNETA_TXQ_SENT_THRESH_ALL_MASK;
> +	val |= MVNETA_TXQ_SENT_THRESH_MASK(value);
> +
> +	mvreg_write(pp, MVNETA_TXQ_SIZE_REG(txq->id), val);
> +
> +	txq->done_pkts_coal = value;
> +}
> +
> +/* Trigger tx done timer in MVNETA_TX_DONE_TIMER_PERIOD msecs */
> +static void mvneta_add_tx_done_timer(struct mvneta_port *pp)
> +{
> +	if (test_and_set_bit(MVNETA_F_TX_DONE_TIMER_BIT, &pp->flags) == 0) {
> +		pp->tx_done_timer.expires = jiffies +
> +			msecs_to_jiffies(MVNETA_TX_DONE_TIMER_PERIOD);
> +		add_timer(&pp->tx_done_timer);
> +	}
> +}
> +
> +
> +/* Handle rx descriptor fill by setting buf_cookie and buf_phys_addr */
> +static void mvneta_rx_desc_fill(struct mvneta_rx_desc *rx_desc,
> +				u32 phys_addr, u32 cookie)
> +{
> +	rx_desc->buf_cookie = cookie;
> +	rx_desc->buf_phys_addr = phys_addr;
> +}
> +
> +/* Decrement sent descriptors counter */
> +static void mvneta_txq_sent_desc_dec(struct mvneta_port *pp,
> +				     struct mvneta_tx_queue *txq,
> +				     int sent_desc)
> +{
> +	u32 val;
> +
> +	/* Only 255 TX descriptors can be updated at once */
> +	while (sent_desc > 0xff) {
> +		val = (0xff << MVNETA_TXQ_DEC_SENT_SHIFT);

Parenthesis.

> +		mvreg_write(pp, MVNETA_TXQ_UPDATE_REG(txq->id), val);
> +		sent_desc = sent_desc - 0xff;
> +	}
> +
> +	val = (sent_desc << MVNETA_TXQ_DEC_SENT_SHIFT);

Parenthesis.

[...]
> +static u32 mvneta_txq_desc_csum(int l3_offs, int l3_proto,
> +				int ip_hdr_len, int l4_proto)
> +{
> +	u32 command;
> +
> +	/* Fields: L3_offset, IP_hdrlen, L3_type, G_IPv4_chk,
> +	   G_L4_chk, L4_type; required only for checksum
> +	   calculation */
> +	command =  (l3_offs    << MVNETA_TX_L3_OFF_SHIFT);
> +	command |= (ip_hdr_len << MVNETA_TX_IP_HLEN_SHIFT);

Parenthesis.

> +
> +	if (l3_proto == swab16(ETH_P_IP))
> +		command |= MVNETA_TXD_IP_CSUM;
> +	else
> +		command |= MVNETA_TX_L3_IP6;
> +
> +	if (l4_proto == IPPROTO_TCP)
> +		command |=  MVNETA_TX_L4_CSUM_FULL;
> +	else if (l4_proto == IPPROTO_UDP)
> +		command |= (MVNETA_TX_L4_UDP | MVNETA_TX_L4_CSUM_FULL);
> +	else
> +		command |= MVNETA_TX_L4_CSUM_NOT;
> +
> +	return command;
> +}
> +
> +/* Display more error info */
> +static void mvneta_rx_error(struct mvneta_port *pp,
> +			    struct mvneta_rx_desc *rx_desc)
> +{
> +	u32 status = rx_desc->status;
> +
> +	if ((status & MVNETA_RXD_FIRST_LAST_DESC)
> +	    != MVNETA_RXD_FIRST_LAST_DESC) {

	if ((status & MVNETA_RXD_FIRST_LAST_DESC) !=
	    MVNETA_RXD_FIRST_LAST_DESC) {

The length of the MVNETA prefix is a self inflicted pain.

(...]
> +static struct mvneta_tx_queue *mvneta_tx_done_policy(struct mvneta_port *pp,
> +						     u32 cause)
> +{
> +	int queue;

> +	queue = fls(cause) - 1;
> +	if (queue < 0 || queue >= mvneta_txq_number)
> +		return NULL;
> +	return &pp->txqs[queue];

	return (q < 0 || q >= mvneta_txq_number) ? NULL : &pp->txqs[q]; ?

(I admit it will obviously not resurrect an unicorn)

> +}
> +
> +/* Free tx queue skbuffs */
> +static void mvneta_txq_bufs_free(struct mvneta_port *pp,
> +				 struct mvneta_tx_queue *txq, int num)
> +{
> +	struct sk_buff *skb;
> +	int i;
> +	struct mvneta_tx_desc *tx_desc;

	int i;

> +	for (i = 0; i < num; i++) {
> +		skb = txq->tx_skb[txq->txq_get_index];
> +		tx_desc = txq->descs + txq->txq_get_index;

		struct mvneta_tx_desc *tx_desc = txq->descs + txq->txq_get_index;
		struct sk_buff *skb = txq->tx_skb[txq->txq_get_index];
> +
> +		mvneta_txq_inc_get(txq);
> +
> +		if (!skb)
> +			continue;
> +		if (tx_desc) {
> +			dma_unmap_single(pp->dev->dev.parent,
> +					 tx_desc->buf_phys_addr,
> +					 tx_desc->data_size,
> +					 DMA_TO_DEVICE);
> +			dev_kfree_skb_any(skb);

		if (!(skb && txd))
			continue;

		dma_unmap_single(pp->dev->dev.parent, tx_desc->buf_phys_addr,
				 tx_desc->data_size, DMA_TO_DEVICE);

> +		}
> +	}
> +}
> +
> +/* Handle end of transmission */
> +static int mvneta_txq_done(struct mvneta_port *pp,
> +			   struct mvneta_tx_queue *txq)
> +{
> +	int tx_done;
> +
> +	tx_done = mvneta_txq_sent_desc_proc(pp, txq);
> +	if (tx_done == 0)
> +		return tx_done;
> +	mvneta_txq_bufs_free(pp, txq, tx_done);
> +
> +	txq->count -= tx_done;
> +
> +	return tx_done;
> +}
> +
> +/* Refill processing */
> +static int mvneta_rx_refill(struct mvneta_port *pp,
> +			    struct mvneta_rx_desc *rx_desc)
> +
> +{
> +	unsigned long phys_addr;

	dma_addr_t phys_addr;

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
> +		dev_kfree_skb_irq(skb);

dev_kfree_skb in softirq context.

[...]
> +static struct mvneta_rx_queue *mvneta_rx_policy(struct mvneta_port *pp,
> +						u32 cause)
> +{
> +	int queue = fls(cause >> 8) - 1;

> +	if (queue < 0 || queue >= mvneta_rxq_number)
> +		return NULL;
> +	return &pp->rxqs[queue];
> +}
> +
> +/* Drop packets received by the RXQ and free buffers */
> +static void mvneta_rxq_drop_pkts(struct mvneta_port *pp,
> +				 struct mvneta_rx_queue *rxq)
> +{
> +	struct mvneta_rx_desc *rx_desc;
> +	struct sk_buff *skb;

Variable scope.

> +	int rx_done, i;
> +
> +	rx_done = mvneta_rxq_busy_desc_num_get(pp, rxq);
> +	for (i = 0; i < rxq->size; i++) {
> +		rx_desc = rxq->descs + i;
> +		skb = (struct sk_buff *)rx_desc->buf_cookie;
> +		dev_kfree_skb_any(skb);
> +		dma_unmap_single(pp->dev->dev.parent, rx_desc->buf_phys_addr,
> +				 rx_desc->data_size, DMA_FROM_DEVICE);
> +
> +
> +	}
> +	if (rx_done)
> +		mvneta_rxq_desc_num_update(pp, rxq, rx_done, rx_done);
> +}
> +
> +
> +/* Main rx processing */
> +static int mvneta_rx(struct mvneta_port *pp, int rx_todo,
> +		     struct mvneta_rx_queue *rxq)
> +{
> +	struct net_device *dev = pp->dev;
> +
> +	int rx_done, rx_filled, err;
> +	struct mvneta_rx_desc *rx_desc;

Variable scope.

> +	u32 rx_status;
> +	int rx_bytes;
> +	struct sk_buff *skb;
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
> +		rx_desc = mvneta_rxq_next_desc_get(rxq);
> +		prefetch(rx_desc);
> +		rx_done++;
> +		rx_filled++;
> +		rx_status = rx_desc->status;
> +		skb = (struct sk_buff *)rx_desc->buf_cookie;
> +
> +		if (((rx_status & MVNETA_RXD_FIRST_LAST_DESC)
> +		     != MVNETA_RXD_FIRST_LAST_DESC)
> +		    || (rx_status & MVNETA_RXD_ERR_SUMMARY)) {

...

> +			dev->stats.rx_errors++;
> +			mvneta_rx_error(pp, rx_desc);
> +			mvneta_rx_desc_fill(rx_desc, rx_desc->buf_phys_addr,
> +					    (u32)skb);
> +			continue;
> +		}
> +
> +		dma_unmap_single(pp->dev->dev.parent, rx_desc->buf_phys_addr,
> +				 rx_desc->data_size, DMA_FROM_DEVICE);
> +
> +		rx_bytes = rx_desc->data_size -
> +			(MVNETA_ETH_CRC_SIZE + MVNETA_MH_SIZE);
> +		u64_stats_update_begin(&pp->rx_stats.syncp);
> +		pp->rx_stats.packets++;
> +		pp->rx_stats.bytes += rx_bytes;
> +		u64_stats_update_end(&pp->rx_stats.syncp);
> +
> +		/* Linux processing */
> +		skb->data += MVNETA_MH_SIZE;
> +		skb->tail += (rx_bytes + MVNETA_MH_SIZE);

skb_reserve + skb_put would be more idiomatic imho.

> +		skb->len = rx_bytes;
> +
> +		skb->protocol = eth_type_trans(skb, dev);
> +
> +		mvneta_rx_csum(pp, rx_desc, skb);
> +
> +		if (dev->features & NETIF_F_GRO)
> +			napi_gro_receive(&pp->napi, skb);
> +		else
> +			netif_receive_skb(skb);

No test. Go for straight napi_gro_receive.

> +
> +		/* Refill processing */
> +		err = mvneta_rx_refill(pp, rx_desc);
> +		if (err) {
> +			netdev_err(pp->dev, "Linux processing - Can't refill\n");
> +			rxq->missed++;
> +			rx_filled--;
> +		}
> +	}
> +
> +	/* Update rxq management counters */
> +	mvneta_rxq_desc_num_update(pp, rxq, rx_done, rx_filled);
> +
> +	return rx_done;
> +}
> +
> +/* Handle tx fragmentation processing */
> +static int mvneta_tx_frag_process(struct mvneta_port *pp, struct sk_buff *skb,
> +				  struct mvneta_tx_queue *txq)
> +{
> +	int i, j;
> +	struct mvneta_tx_desc *tx_desc;
> +	skb_frag_t *frag;

	struct device *d = pp->dev->dev.parent;
	struct mvneta_tx_desc *tx_desc;
	int i, j;

> +
> +	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
> +		frag = &skb_shinfo(skb)->frags[i];

		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
		void *addr = page_address(frag->page.p) + frag->page_offset;

> +
> +		tx_desc = mvneta_txq_next_desc_get(txq);
> +		tx_desc->data_size = frag->size;
> +
> +		tx_desc->buf_phys_addr =
> +			dma_map_single(pp->dev->dev.parent,
> +				       page_address(frag->page.p) +
> +				       frag->page_offset, tx_desc->data_size,
> +				       DMA_TO_DEVICE);

		tx_desc->buf_phys_addr = dma_map_single(d, addr, frag->size,
							DMA_TO_DEVICE);

[...]
> +static int mvneta_tx(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct mvneta_port *pp = netdev_priv(dev);
> +	int frags = 0;
> +	int res = NETDEV_TX_OK;
> +	u32 tx_cmd;
> +	struct mvneta_tx_queue *txq = &pp->txqs[mvneta_txq_def];
> +	struct mvneta_tx_desc *tx_desc;

Longer first.

> +
> +	if (!netif_running(dev))
> +		goto out;
> +
> +	frags = skb_shinfo(skb)->nr_frags + 1;
> +
> +	/* Are there enough TX descriptors to send packet ? */

Never. You must disable queueing before it's too late.

> +	if ((txq->count + frags) >= txq->size) {
> +		frags = 0;
> +		res = NETDEV_TX_BUSY;
> +		goto out;
> +	}
> +
> +	/* Get a descriptor for the first part of the packet */
> +	tx_desc = mvneta_txq_next_desc_get(txq);
> +
> +	tx_cmd = mvneta_skb_tx_csum(pp, skb);
> +
> +	tx_desc->data_size = skb_headlen(skb);
> +
> +	tx_desc->buf_phys_addr = dma_map_single(dev->dev.parent, skb->data,
> +						tx_desc->data_size,
> +						DMA_TO_DEVICE);
> +	if (unlikely(dma_mapping_error(dev->dev.parent,
> +				       tx_desc->buf_phys_addr))) {
> +		mvneta_txq_desc_put(txq);
> +		frags = 0;
> +		res = NETDEV_TX_BUSY;

Neither. You drop the packet, update the stats and return ok.

> +		goto out;
> +	}
> +
> +	if (frags == 1) {
> +		/* First and Last descriptor */
> +		tx_cmd |= MVNETA_TXD_FLZ_DESC;
> +		tx_desc->command = tx_cmd;
> +		txq->tx_skb[txq->txq_put_index] = skb;
> +		mvneta_txq_inc_put(txq);
> +	} else {
> +		/* First but not Last */
> +		tx_cmd |= MVNETA_TXD_F_DESC;
> +		txq->tx_skb[txq->txq_put_index] = NULL;
> +		mvneta_txq_inc_put(txq);
> +		tx_desc->command = tx_cmd;
> +		/* Continue with other skb fragments */
> +		if (mvneta_tx_frag_process(pp, skb, txq)) {
> +			dma_unmap_single(dev->dev.parent,
> +					 tx_desc->buf_phys_addr,
> +					 tx_desc->data_size,
> +					 DMA_TO_DEVICE);
> +			mvneta_txq_desc_put(txq);
> +			frags = 0;
> +			res = NETDEV_TX_BUSY;

Sic.

[...]
> +/* handle tx done - called from tx done timer callback */
> +static u32 mvneta_tx_done_gbe(struct mvneta_port *pp, u32 cause_tx_done,
> +			      int *tx_todo)

Why is it not done in napi context ?

-- 
Ueimor
