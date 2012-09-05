From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH 1/4] net: mvneta: driver for Marvell Armada 370/XP network
 unit
Date: Wed, 05 Sep 2012 17:25:33 +0200
Message-ID: <4239536.AWX2eoRGLK@flexo>
References: <1346764004-16332-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <1346764004-16332-2-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Lior Amsalem <alior@marvell.com>, Andrew Lunn <andrew@lunn.ch>,
 Ike Pan <ike.pan@canonical.com>, Albert Stone <albert.stone@canonical.com>,
 Nadav Haklai <nadavh@marvell.com>, Ian Molton <ian.molton@codethink.co.uk>,
 Lennert Buytenhek <kernel@wantstofly.org>, David Marlin <dmarlin@redhat.com>,
 Rami Rosen <rosenr@marvell.com>, Yehuda Yitschak <yehuday@marvell.com>,
 Jani Monoses <jani.monoses@canonical.com>, Tawfik Bayouk <tawfik@marvell.com>,
 Dan Frazier <dann.frazier@canonical.com>, Eran Ben-Avi <benavi@marvell.com>,
 Li Li <li.li@canonical.com>, Leif Lindholm <leif.lindholm@arm.com>,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
 Jason Cooper <jason@lakedaemon.net>, Arnd Bergmann <arnd@arndb.de>,
 Jon Masters <jcm@redhat.com>, Ben Dooks <ben-linux@fluff.org>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Thomas Petazzoni <thomas.petazzoni@free-electrons.co
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1346764004-16332-2-git-send-email-thomas.petazzoni@free-electrons.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hello Thomas,

The overall driver looks very nice, my biggest concern with this driver being 
that it does not implement phylib and therefore reimplements a bit of existing 
code. I am not commentin on how to represent this MDIO/PHY devices using 
Device Tree since this has been addressed already.

Once you register a MDIO bus for your interface, please make sure that you 
give it a unique name in the system (<pdev->name>-<pdev->id>).

Other comments inline.

On Tuesday 04 September 2012 15:06:41 Thomas Petazzoni wrote:
[snip]
> +
> +/* Increment txq get counter */
> +static void mvneta_inc_get(struct mvneta_tx_queue *txq)
> +{
> +	txq->txq_get_index++;
> +	if (txq->txq_get_index == txq->size)
> +		txq->txq_get_index = 0;
> +}
> +
> +/* Increment txq put counter */
> +static void mvneta_inc_put(struct mvneta_tx_queue *txq)
> +{
> +	txq->txq_put_index++;
> +	if (txq->txq_put_index == txq->size)
> +		txq->txq_put_index = 0;
> +}

I would make it clear that these helpers operate on the txq, and suffix it with 
_txq.

> +
> +
> +/* Clear all MIB counters */
> +static void mvneta_mib_counters_clear(struct mvneta_port *pp)
> +{
> +	int i;
> +	u32 dummy;
> +
> +	/* Perform dummy reads from MIB counters */
> +	for (i = 0; i < MVNETA_MIB_LATE_COLLISION; i += 4)
> +		dummy = mvreg_read(pp, (MVNETA_MIB_COUNTERS_BASE + i));
> +}
> +
> +/* Read speed, duplex, and flow control from port status register */
> +static int mvneta_link_status(struct mvneta_port *pp,
> +			      struct mvneta_lnk_status *status)
> +{
> +	u32 val;
> +
> +	val = mvreg_read(pp, MVNETA_GMAC_STATUS);
> +
> +	if (val & MVNETA_GMAC_SPEED_1000_MASK)
> +		status->speed = MVNETA_SPEED_1000;
> +	else if (val & MVNETA_GMAC_SPEED_100_MASK)
> +		status->speed = MVNETA_SPEED_100;
> +	else
> +		status->speed = MVNETA_SPEED_10;
> +
> +	if (val & MVNETA_GMAC_LINK_UP_MASK)
> +		status->linkup = 1;
> +	else
> +		status->linkup = 0;
> +
> +	if (val & MVNETA_GMAC_FULL_DUPLEX_MASK)
> +		status->duplex = MVNETA_DUPLEX_FULL;
> +	else
> +		status->duplex = MVNETA_DUPLEX_HALF;
> +
> +	if (val & MVNETA_GMAC_TX_FLOW_CTRL_ACTIVE_MASK)
> +		status->tx_fc = MVNETA_FC_ACTIVE;
> +	else if (val & MVNETA_GMAC_TX_FLOW_CTRL_ENABLE_MASK)
> +		status->tx_fc = MVNETA_FC_ENABLE;
> +	else
> +		status->tx_fc = MVNETA_FC_DISABLE;
> +
> +	if (val & MVNETA_GMAC_RX_FLOW_CTRL_ACTIVE_MASK)
> +		status->rx_fc = MVNETA_FC_ACTIVE;
> +	else if (val & MVNETA_GMAC_RX_FLOW_CTRL_ENABLE_MASK)
> +		status->rx_fc = MVNETA_FC_ENABLE;
> +	else
> +		status->rx_fc = MVNETA_FC_DISABLE;
> +

I would rather see you use a struct phy_device and update its properties 
instead of keeping a local copy of it. This would allow you to have consistent 
reporting through ethtool, I have more comments on this later on as well.


> +static void mvneta_rxq_non_occup_desc_add(struct mvneta_port *pp,
> +					  struct mvneta_rx_queue *rxq,
> +					  int rx_desc)
> +{
> +	u32 val;
> +
> +	/* Only 255 descriptors can be added at once */
> +	while (rx_desc > 0xff) {
> +		val = (0xff << MVNETA_RXQ_ADD_NON_OCCUPIED_OFFS);
> +		mvreg_write(pp, MVNETA_RXQ_STATUS_UPDATE_REG(rxq->id), val);
> +		rx_desc = rx_desc - 0xff;
> +	}

You could probably use a define here for 255/0xff.

[snip]

> +	m_delay = 0;

This does not look like an useful name, count would be better

> +	do {
> +		if (m_delay >= MVNETA_RX_DISABLE_TIMEOUT_MSEC) {
> +			netdev_info(pp->dev,
> +				"TIMEOUT for RX stopped ! rx_queue_cmd: 0x08%x\n",
> +				val);

Please use a different logging level such as netdev_err() or netdev_warn() for 
instance.

> +			break;
> +		}
> +		mdelay(1);
> +		m_delay++;

What about using msleep() instead here?

> +
> +		val = mvreg_read(pp, MVNETA_RXQ_CMD);
> +	} while (val & 0xff);
> +
> +	/* Stop Tx port activity. Check port Tx activity. Issue stop
> +	   command for active channels only  */
> +	val = (mvreg_read(pp, MVNETA_TXQ_CMD)) & MVNETA_TXQ_ENABLE_MASK;
> +
> +	if (val != 0)
> +		mvreg_write(pp, MVNETA_TXQ_CMD,
> +			(val << MVNETA_TXQ_DISABLE_OFFS));
> +
> +	/* Wait for all Tx activity to terminate. */
> +	m_delay = 0;
> +	do {
> +		if (m_delay >= MVNETA_TX_DISABLE_TIMEOUT_MSEC) {
> +			netdev_info(pp->dev,
> +				"TIMEOUT for TX stopped tx_queue_cmd - 0x%08x\n",
> +				val);
> +			break;
> +		}
> +		mdelay(1);
> +		m_delay++;
> +
> +		/* Check TX Command reg that all Txqs are stopped */
> +		val = mvreg_read(pp, MVNETA_TXQ_CMD);

Ditto

> +
> +	} while (val & 0xff);
> +	tx_fifo_empty_mask |= MVNETA_TX_FIFO_EMPTY_MASK;
> +	tx_in_prog_mask    |= MVNETA_TX_IN_PRGRS_MASK;
> +
> +	/* Double check to verify that TX FIFO is empty */
> +	m_delay = 0;
> +	while (1) {
> +		do {
> +			if (m_delay >= MVNETA_TX_FIFO_EMPTY_TIMEOUT) {
> +				netdev_info(pp->dev,
> +					    "TX FIFO empty timeout status=0x08%x, 
empty=%x, in_prog=%x",
> +					    val, tx_fifo_empty_mask,
> +					    tx_in_prog_mask);
> +				break;
> +			}
> +			mdelay(1);
> +			m_delay++;

Ditto

> +
> +			val = mvreg_read(pp, MVNETA_PORT_STATUS);
> +		} while (((val & tx_fifo_empty_mask) != tx_fifo_empty_mask)
> +			 || ((val & tx_in_prog_mask) != 0));
> +
> +		if (m_delay >= MVNETA_TX_FIFO_EMPTY_TIMEOUT)
> +			break;
> +
> +		val = mvreg_read(pp, MVNETA_PORT_STATUS);
> +		if (((val & tx_fifo_empty_mask) == tx_fifo_empty_mask) &&
> +		    ((val & tx_in_prog_mask) == 0))
> +			break;
> +		else
> +			netdev_info(pp->dev, "TX FIFO Empty double check failed. %d 
msec status=0x%x, empty=0x%x, in_prog=0x%x\n",
> +				    m_delay, val, tx_fifo_empty_mask,
> +				    tx_in_prog_mask);
> +	}
> +
> +	udelay(200);
> +}

[snip]

> +
> +/* This method sets defaults to the NETA port:
> + *	Clears interrupt Cause and Mask registers.
> + *	Clears all MAC tables.
> + *	Sets defaults to all registers.
> + *	Resets RX and TX descriptor rings.
> + *	Resets PHY.
> + * This method can be called after mvneta_port_down() to return the port
> + *	settings to defaults.
> + */

Please use standard kernel-doc style comments.

[snip]

> +/* Read the Link Up bit (LinkUp) in port MAC control register */
> +static int mvneta_link_is_up(struct mvneta_port *pp)
> +{
> +	u32 val;
> +	val = mvreg_read(pp, MVNETA_GMAC_STATUS);
> +	if (val & MVNETA_GMAC_LINK_UP_MASK)
> +		return 1;

	return mvreg_read(pp, MVNETA_GMAC_STATUS) & MVNETA_GMAC_LINK_UP_MASK;
and make it static inline.

> +
> +	return 0;
> +}
> +
> +/* Get phy address */
> +static int mvneta_phy_addr_get(struct mvneta_port *pp)
> +{
> +	unsigned int val;
> +
> +	val = mvreg_read(pp, MVNETA_PHY_ADDR);
> +	val &= 0x1f;

Use PHY_MAX_ADDR - 1 instead here.

> +	return val;
> +}
> +

[snip]

> +/* Display status (link, duplex, speed) of the port */
> +void mvneta_link_status_print(struct mvneta_port *pp)
> +{
> +	struct mvneta_lnk_status link;
> +	char *speedstr, *duplexstr;
> +
> +	mvneta_link_status(pp, &link);
> +
> +	if (link.linkup) {
> +		if (link.speed == MVNETA_SPEED_1000)
> +			speedstr = "1 Gbps";
> +		else if (link.speed == MVNETA_SPEED_100)
> +			speedstr = "100 Mbps";
> +		else
> +			speedstr = "10 Mbps";
> +
> +		if (link.duplex == MVNETA_DUPLEX_FULL)
> +			duplexstr = "full";
> +		else
> +			duplexstr = "half";
> +
> +		netdev_info(pp->dev,
> +			    "link up, %s duplex, speed %s\n",
> +			    duplexstr, speedstr);
> +	} else
> +		netdev_info(pp->dev, "link down\n");
> +}

You should rather define a phylib adjust_link callback to do this. Otherwise 
please reduce the indentation by handling the case when the link is down first.

> +
> +/* Display more error info */
> +static void mvneta_rx_error(struct mvneta_port *pp,
> +			    struct mvneta_rx_desc *rx_desc)
> +{
> +	u32 status = rx_desc->status;
> +
> +	if (pp->dev)
> +		pp->dev->stats.rx_errors++;

Please do this outside of this function and just let it print the error.

> +
> +	if ((status & MVNETA_RXD_FIRST_LAST_DESC_MASK)
> +	    != MVNETA_RXD_FIRST_LAST_DESC_MASK) {
> +		netdev_err(pp->dev,
> +			   "bad rx status %08x (buffer oversize), size=%d\n",
> +			   rx_desc->status, rx_desc->data_size);
> +		return;
> +	}

[snip]

> +
> +/* Refill processing */
> +static int mvneta_rx_refill(struct mvneta_port *pp,
> +			    struct mvneta_rx_desc *rx_desc)
> +
> +{
> +	unsigned long phys_addr;
> +	struct sk_buff *skb;
> +
> +	skb = netdev_alloc_skb(pp->dev, pp->pkt_size);
> +	if (!skb) {
> +		mvneta_add_cleanup_timer(pp);
> +		return 1;
> +	}
> +
> +	phys_addr = dma_map_single(pp->dev->dev.parent, skb->head,
> +				   MVNETA_RX_BUF_SIZE(pp->pkt_size),
> +				   DMA_FROM_DEVICE);

Check that your phys_addr cookie has been successfully mapped using 
dma_mapping_error().

[snip]

> +/* Main tx processing */
> +static int mvneta_tx(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct mvneta_port *pp = netdev_priv(dev);
> +
> +	int frags = 0;
> +	int res = NETDEV_TX_OK;
> +	u32 tx_cmd;
> +	struct mvneta_tx_queue *txq = NULL;
> +	struct mvneta_tx_desc *tx_desc;
> +
> +	if (!test_bit(MVNETA_F_STARTED_BIT, &pp->flags))
> +		goto out;

Is not this equivalent to !netif_running(dev)? At least print some message so 
we know that this is not supposed to happen.

> +
> +	txq = &pp->txqs[mvneta_txq_def];
> +
> +	frags = skb_shinfo(skb)->nr_frags + 1;
> +
> +	tx_desc = mvneta_tx_desc_get(pp, txq, frags);
> +	if (tx_desc == NULL) {
> +		frags = 0;
> +		dev->stats.tx_dropped++;
> +		res = NETDEV_TX_BUSY;
> +		goto out;
> +	}


> +
> +	tx_cmd = mvneta_skb_tx_csum(pp, skb);
> +
> +	tx_desc->data_size = skb_headlen(skb);
> +
> +	tx_desc->buf_phys_addr = dma_map_single(dev->dev.parent, skb->data,
> +						tx_desc->data_size,
> +						DMA_TO_DEVICE);

Please check this dma_map_single() return value too.

[snip]

> +static int mvneta_addr_crc(unsigned char *addr)
> +{
> +	int crc = 0;
> +	int i;
> +
> +	for (i = 0; i < 6; i++) {

ETH_ALEN instead of 6 to make it clear it operates on addresses.

> +		int j;
> +
> +		crc = (crc ^ addr[i]) << 8;
> +		for (j = 7; j >= 0; j--) {
> +			if (crc & (0x100 << j))
> +				crc ^= 0x107 << j;
> +		}
> +	}
> +
> +	return crc;
> +}

[snip]

> +
> +/* Interrupt handling - the callback for request_irq() */
> +static irqreturn_t mvneta_isr(int irq, void *dev_id)
> +{
> +	struct mvneta_port *pp = (struct mvneta_port *)dev_id;
> +
> +	/* Mask all interrupts */
> +	mvreg_write(pp, MVNETA_INTR_NEW_MASK, 0);
> +
> +	/* Verify that the device not already on the polling list */
> +	if (napi_schedule_prep(&pp->napi))
> +		__napi_schedule(&pp->napi);

Does not the hardware generate interrupts for tx completion, PHY interrupts 
etc ...?

> +
> +	return IRQ_HANDLED;
> +}
> +
> +/* Handle link event */
> +static void mvneta_link_event(struct mvneta_port *pp)
> +{
> +	struct net_device *dev = pp->dev;
> +
> +	/* Check Link status on ethernet port */
> +
> +	if (mvneta_link_is_up(pp)) {
> +		mvneta_port_up(pp);
> +		set_bit(MVNETA_F_LINK_UP_BIT, &pp->flags);
> +
> +		if (dev) {
> +			netif_carrier_on(dev);
> +			netif_tx_wake_all_queues(dev);
> +		}
> +	} else {
> +		if (dev) {
> +			netif_carrier_off(dev);
> +			netif_tx_stop_all_queues(dev);
> +		}
> +		mvneta_port_down(pp);
> +		clear_bit(MVNETA_F_LINK_UP_BIT, &pp->flags);
> +	}
> +
> +	mvneta_link_status_print(pp);

Again, this is taken care of by phylib nicely, and does not require you to 
have this F_LINK_UP_BIT.

[snip]

> +
> +/* Handle rxq fill: allocates rxq skbs; called when initializing a port */
> +static int mvneta_rxq_fill(struct mvneta_port *pp, struct mvneta_rx_queue 
*rxq,
> +			   int num)
> +{
> +	int i;
> +	struct sk_buff *skb;
> +	struct mvneta_rx_desc *rx_desc;
> +	unsigned long phys_addr;
> +	struct net_device *dev = pp->dev;
> +
> +	for (i = 0; i < num; i++) {
> +		skb = dev_alloc_skb(pp->pkt_size);
> +		if (!skb) {
> +			netdev_err(pp->dev, "%s:rxq %d, %d of %d buffs filled\n",
> +				   __func__, rxq->id, i, num);
> +			break;
> +		}
> +
> +		rx_desc = rxq->descs + i;
> +		memset(rx_desc, 0, sizeof(struct mvneta_rx_desc));
> +		phys_addr = dma_map_single(dev->dev.parent, skb->head,
> +					   MVNETA_RX_BUF_SIZE(pp->pkt_size),
> +					   DMA_FROM_DEVICE);

Here again, check phys_addr.

> +		mvneta_rx_desc_fill(rx_desc, phys_addr, (u32)skb);
> +	}
> +
> +	/* add this num of RX descriptors as non occupied (ready to get pkts) */
> +	mvneta_rxq_non_occup_desc_add(pp, rxq, i);
> +
> +	return i;
> +}
> +
[snip]
> +
> +/* Create a specified RX queue */
> +static int mvneta_rxq_init(struct mvneta_port *pp,
> +			   struct mvneta_rx_queue *rxq)
> +
> +{
> +	rxq->size = pp->rx_ring_size;
> +
> +	/* Allocate DMA descriptors array */
> +	rxq->descs_orig = dma_alloc_coherent(pp->dev->dev.parent,
> +					     MVNETA_RX_TOTAL_DESCS_SIZE(rxq),
> +					     &rxq->descs_phys_orig,
> +					     GFP_KERNEL);
> +	if (rxq->descs_orig == NULL) {

Use dma_mapping_error() instead.

> +		netdev_err(pp->dev, "rxQ=%d: Can't allocate %d bytes for %d RX 
descr\n",
> +			   rxq->id, MVNETA_RX_TOTAL_DESCS_SIZE(rxq), rxq->size);
> +		return -ENOMEM;
> +	}
> +
> +	/* Make sure descriptor address is cache line size aligned  */
> +	rxq->descs = PTR_ALIGN(rxq->descs_orig, MVNETA_CPU_D_CACHE_LINE_SIZE);
> +	rxq->descs_phys = ALIGN(rxq->descs_phys_orig,
> +				MVNETA_CPU_D_CACHE_LINE_SIZE);
> +
> +	rxq->last_desc = rxq->size - 1;

Don't you need some kind of barrier here? I do not know exactly how coherent 
your peripherals and memory are, just wondering.

> +
> +	/* Set Rx descriptors queue starting address */
> +	mvreg_write(pp, MVNETA_RXQ_BASE_ADDR_REG(rxq->id), rxq->descs_phys);
> +	mvreg_write(pp, MVNETA_RXQ_SIZE_REG(rxq->id), rxq->size);
> +
> +	/* Set Offset */
> +	mvneta_rxq_offset_set(pp, rxq, NET_SKB_PAD);
> +
> +	/* Set coalescing pkts and time */
> +	mvneta_rx_pkts_coal_set(pp, rxq, rxq->pkts_coal);
> +	mvneta_rx_time_coal_set(pp, rxq, rxq->time_coal);
> +
> +	/* Fill RXQ with buffers from RX pool */
> +	mvneta_rxq_buf_size_set(pp, rxq, MVNETA_RX_BUF_SIZE(pp->pkt_size));
> +	mvneta_rxq_bm_disable(pp, rxq);
> +	mvneta_rxq_fill(pp, rxq, rxq->size);
> +
> +	return 0;
> +}
> +
[snip]

> +static int mvneta_txq_init(struct mvneta_port *pp,
> +			   struct mvneta_tx_queue *txq)
> +{
> +	txq->size = pp->tx_ring_size;
> +
> +	/* Allocate DMA descriptors array */
> +	txq->descs_orig = dma_alloc_coherent(pp->dev->dev.parent,
> +					     MVNETA_TX_TOTAL_DESCS_SIZE(txq),
> +					     &txq->descs_phys_orig,
> +					     GFP_KERNEL);
> +	if (txq->descs_orig == NULL) {

Use dma_mapping_error().

> +		netdev_err(pp->dev, "txQ=%d: Can't allocate %d bytes for %d TX 
descr\n",
> +			   txq->id, MVNETA_TX_TOTAL_DESCS_SIZE(txq), txq->size);
> +		return -ENOMEM;
> +	}
> +
[snip]

> +/* Fill rx buffers, start Rx/Tx activity, set coalesing,
> +*  clear and unmask interrupt bits
> +*/
> +static int mvneta_start_internals(struct mvneta_port *pp, int mtu)
> +{
> +	int err = 0;
> +
> +	pp->pkt_size = MVNETA_RX_PKT_SIZE(mtu);
> +	if (test_bit(MVNETA_F_STARTED_BIT, &pp->flags))
> +		return -EINVAL;

You probably mean -EBUSY here instead?

> +
> +	if (mvneta_max_rx_size_set(pp, MVNETA_RX_PKT_SIZE(mtu))) {
> +		netdev_err(pp->dev,
> +			   "%s: can't set maxRxSize=%d mtu=%d\n",
> +			   __func__, MVNETA_RX_PKT_SIZE(mtu), mtu);
> +		return -EINVAL;
> +	}
> +
> +	err = mvneta_setup_rxqs(pp);
> +	if (unlikely(err))
> +		return err;
> +
> +	err = mvneta_setup_txqs(pp);
> +	if (unlikely(err)) {
> +		mvneta_cleanup_rxqs(pp);
> +		return err;
> +	}
> +
> +	mvneta_txq_max_tx_size_set(pp, MVNETA_RX_PKT_SIZE(mtu));
> +
> +	/* start the Rx/Tx activity */
> +	mvneta_port_enable(pp);
> +
> +	set_bit(MVNETA_F_LINK_UP_BIT, &pp->flags);
> +	set_bit(MVNETA_F_STARTED_BIT, &pp->flags);
> +
> +	return 0;
> +}
> +
> +/* Stop port Rx/Tx activity, free skb's from Rx/Tx rings */
> +static int mvneta_stop_internals(struct mvneta_port *pp)
> +{
> +	clear_bit(MVNETA_F_STARTED_BIT, &pp->flags);
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
> +	smp_call_function_many(cpu_online_mask, mvneta_interrupts_mask,
> +			       pp, 1);
> +
> +	/* Reset TX port here. */
> +	mvneta_tx_reset(pp);
> +
> +	mvneta_cleanup_rxqs(pp);
> +	mvneta_cleanup_txqs(pp);
> +
> +	return 0;
> +
> +}
> +
> +/* Start the port, connect to port interrupt line, unmask interrupts  */
> +static int mvneta_start(struct net_device *dev)
> +{
> +	struct mvneta_port *pp = netdev_priv(dev);
> +
> +	/* In default link is down */
> +	netif_carrier_off(dev);
> +	netif_tx_stop_all_queues(dev);
> +
> +	/* Fill rx buffers, start Rx/Tx activity, set coalescing */
> +	if (mvneta_start_internals(pp, dev->mtu) != 0) {
> +		netdev_err(dev, "start internals failed\n");
> +		return -ENODEV;
> +	}
> +
> +	/* Enable polling on the port, must be used after netif_poll_disable */
> +	napi_enable(&pp->napi);
> +
> +	if (pp->flags & MVNETA_F_LINK_UP) {
> +		netif_carrier_on(dev);
> +		netif_tx_wake_all_queues(dev);
> +	} else {
> +		netdev_info(dev, "%s: NOT MVNETA_F_LINK_UP\n", __func__);
> +	}

Remove this message as well.

> +
> +	/* Connect to port interrupt line */
> +	if (request_irq(dev->irq, mvneta_isr, (IRQF_DISABLED), "mv_eth", pp)) {
> +		netdev_err(dev, "cannot request irq %d\n", dev->irq);
> +		napi_disable(&pp->napi);
> +		goto error;
> +	}

You should probably request the interrupt prior to calling napi_enable()

> +
> +	/* Unmask interrupts */
> +	mvneta_interrupts_unmask(pp);
> +	smp_call_function_many(cpu_online_mask,
> +			       mvneta_interrupts_unmask,
> +			       pp, 1);
> +
> +	netdev_info(dev, "started\n");

Remove this please.

> +	return 0;
> +
> +error:
> +	netdev_err(dev, "start failed\n");
> +	mvneta_cleanup_rxqs(pp);
> +	mvneta_cleanup_txqs(pp);
> +
> +	return -ENODEV;
> +}
> +

> +	if (dev->irq != 0)
> +		free_irq(dev->irq, pp);

This looks superfluous, you refuse to bring up the interface if the interrupt 
requesting fails.

> +
> +	netdev_info(dev, "stopped\n");
> +
> +	return 0;
> +}
> +
> +
> +/* tx timeout callback - display a message and stop/start the network 
device */
> +static void mvneta_tx_timeout(struct net_device *dev)
> +{
> +	netdev_info(dev, "tx timeout\n");
> +	if (netif_running(dev)) {
> +		mvneta_stop(dev);
> +		mvneta_start(dev);
> +	}

You should never end-up with the case where the interface is not running and 
you face a transmit timeout.

[snip]

> +/* Change the device mtu */
> +static int mvneta_change_mtu(struct net_device *dev, int mtu)
> +{
> +	int old_mtu = dev->mtu;
> +
> +	mtu = mvneta_check_mtu_valid(dev, mtu);
> +	if (mtu < 0)
> +		return -EINVAL;
> +
> +	dev->mtu = mtu;
> +
> +	if (!netif_running(dev)) {
> +		netdev_info(dev, "change mtu %d (buffer-size %d) to %d (buffer-size 
%d)\n",
> +			old_mtu, MVNETA_RX_PKT_SIZE(old_mtu),
> +			dev->mtu, MVNETA_RX_PKT_SIZE(dev->mtu));
> +		return 0;

Remove this message.

> +	}
> +
> +	if (mvneta_stop(dev)) {
> +		netdev_err(dev, "stop interface failed\n");
> +		goto error;
> +	}
> +
> +	if (mvneta_start(dev)) {
> +		netdev_err(dev, "start interface failed\n");
> +		goto error;
> +	}

Propagate the returned error codes back to the caller.

> +
> +	netdev_info(dev, "change mtu %d (buffer-size %d) to %d (buffer-size %d)\n",
> +		old_mtu, MVNETA_RX_PKT_SIZE(old_mtu),
> +		dev->mtu, MVNETA_RX_PKT_SIZE(dev->mtu));

Remove this message too.

> +
> +	return 0;
> +
> +error:
> +	netdev_info(dev, "change mtu failed\n");
> +	return -EINVAL;
> +}
> +
> +/* Handle setting mac address (low level) */
> +static int mvneta_set_mac_addr_internals(struct net_device *dev, void 
*addr)
> +{
> +	struct mvneta_port *pp = netdev_priv(dev);
> +	u8 *mac = addr + 2;
> +	int i;
> +
> +	/* Remove previous address table entry */
> +	if (mvneta_mac_addr_set(pp, dev->dev_addr, -1) != 0) {
> +		netdev_err(dev, "mvneta_mac_addr_set failed\n");
> +		return -EINVAL;
> +	}
> +
> +	/* Set new addr in hw */
> +	if (mvneta_mac_addr_set(pp, mac, mvneta_rxq_def) != 0) {
> +		netdev_err(dev, "mvneta_mac_addr_set failed\n");
> +		return -EINVAL;
> +	}
> +
> +	/* Set addr in the device */
> +	for (i = 0; i < MVNETA_MAC_ADDR_SIZE; i++)
> +		dev->dev_addr[i] = mac[i];

ETH_ALEN.

> +
> +	netdev_info(dev, "mac address changed\n");

Remove this please.

> +
> +	return 0;
> +}
> +
> +/* Handle setting mac address */
> +static int mvneta_set_mac_addr(struct net_device *dev, void *addr)
> +{
> +	if (!netif_running(dev)) {
> +		if (mvneta_set_mac_addr_internals(dev, addr) == -1)
> +			goto error;
> +		return 0;
> +	}

Usually you just check if the interface is running, and if it is return 
something like -EBUSY.

> +
> +	if (mvneta_stop(dev)) {
> +		netdev_err(dev, "stop interface failed\n");
> +		goto error;
> +	}
> +
> +	if (mvneta_set_mac_addr_internals(dev, addr) == -1)
> +		goto error;
> +
> +	if (mvneta_start(dev)) {
> +		netdev_err(dev, "start interface failed\n");
> +		goto error;
> +	}

Propagate error codes here too please.

> +
> +	return 0;
> +
> +error:
> +	netdev_err(dev, "set mac addr failed\n");
> +	return -EINVAL;
> +}
> +
> +/*
> + * Called when a network interface is made active.
> + * Returns 0 on success, -EINVAL or =ENODEV on failure
> + * mvneta_open() is called when a network interface is made
> + * active by the system (IFF_UP). We set the mac address and
> + * invoke mvneta_start() to start the device.
> + */
> +static int mvneta_open(struct net_device *dev)
> +{
> +	struct mvneta_port *pp = netdev_priv(dev);
> +	int queue = mvneta_rxq_def;
> +
> +	if (mvneta_mac_addr_set(pp, dev->dev_addr, queue) != 0) {
> +		netdev_err(dev, "mvneta_mac_addr_set failed\n");
> +		return -EINVAL;
> +	}
> +
> +	if (mvneta_start(dev)) {
> +		netdev_err(dev, "start interface failed\n");
> +		return -ENODEV;
> +	}
> +
> +	return 0;

Propagate the error code here too.

[snip]

> +static void mvneta_ethtool_get_drvinfo(struct net_device *dev,
> +				    struct ethtool_drvinfo *drvinfo)
> +{
> +	strlcpy(drvinfo->driver, mvneta_driver_name,
> +		sizeof(drvinfo->driver));
> +	strlcpy(drvinfo->version, mvneta_driver_version,
> +		sizeof(drvinfo->version));

You can probably also provide informations about the firmware version, bus_info 
at least.

[snip]

> +/* Device initialization routine */
> +static int __devinit mvneta_probe(struct platform_device *pdev)
> +{
> +	int err = -EINVAL;
> +	struct mvneta_port *pp;
> +	struct net_device *dev;
> +	u32 phy_addr, clk;
> +	int phy_mode;
> +	const char *mac_addr;
> +	const struct mbus_dram_target_info *dram_target_info;
> +	struct device_node *dn = pdev->dev.of_node;
> +
> +	dev = alloc_etherdev_mq(sizeof(struct mvneta_port), 8);
> +	if (!dev)
> +		return -ENOMEM;
> +
> +	dev->irq = irq_of_parse_and_map(dn, 0);
> +	if (dev->irq == 0) {
> +		err = -EINVAL;
> +		goto err_irq;
> +	}
> +
> +	if (of_property_read_u32(dn, "phy-addr", &phy_addr) != 0) {
> +		dev_err(&pdev->dev, "could not read phy_addr\n");
> +		err = -ENODEV;
> +		goto err_node;
> +	}
> +
> +	phy_mode = of_get_phy_mode(dn);
> +	if (phy_mode < 0) {
> +		dev_err(&pdev->dev, "wrong phy-mode\n");
> +		err = -EINVAL;
> +		goto err_node;
> +	}
> +
> +	if (of_property_read_u32(dn, "clock-frequency", &clk) != 0) {
> +		dev_err(&pdev->dev, "could not read clock-frequency\n");
> +		err = -EINVAL;
> +		goto err_node;
> +	}
> +
> +	mac_addr = of_get_mac_address(dn);
> +
> +	if (!mac_addr || !is_valid_ether_addr(mac_addr))
> +		eth_hw_addr_random(dev);
> +	else
> +		memcpy(dev->dev_addr, mac_addr, 6);
> +
> +	dev->tx_queue_len = MVNETA_MAX_TXD;
> +	dev->watchdog_timeo = 5 * HZ;
> +	dev->netdev_ops = &mvneta_netdev_ops;
> +
> +	SET_ETHTOOL_OPS(dev, &mvneta_eth_tool_ops);
> +
> +	pp = netdev_priv(dev);
> +
> +	pp->tx_done_timer.function = mvneta_tx_done_timer_callback;
> +	init_timer(&pp->tx_done_timer);
> +	clear_bit(MVNETA_F_TX_DONE_TIMER_BIT, &pp->flags);
> +	pp->cleanup_timer.function = mvneta_cleanup_timer_callback;
> +	init_timer(&pp->cleanup_timer);
> +	clear_bit(MVNETA_F_CLEANUP_TIMER_BIT, &pp->flags);
> +
> +	pp->weight = MVNETA_RX_POLL_WEIGHT;
> +	pp->clk = clk;

Rename this clk_freq so make it less ambiguous, because this is not a proper 
struct clk pointer.

> +
> +	pp->base = of_iomap(dn, 0);
> +	if (pp->base == NULL) {
> +		err = -ENOMEM;
> +		goto err_node;
> +	}
> +
> +	pp->tx_done_timer.data = (unsigned long)dev;
> +	pp->cleanup_timer.data = (unsigned long)dev;
> +
> +	pp->tx_ring_size = MVNETA_MAX_TXD;
> +	pp->rx_ring_size = MVNETA_MAX_RXD;
> +
> +	pp->dev = dev;
> +
> +	if (mvneta_init(pp, phy_addr)) {
> +		dev_err(&pdev->dev, "can't init eth hal\n");
> +		err = -ENODEV;
> +		goto err_base;
> +	}
> +	mvneta_port_power_up(pp, phy_mode);
> +
> +	dram_target_info = mv_mbus_dram_info();
> +	if (dram_target_info)
> +		mvneta_conf_mbus_windows(pp, dram_target_info);
> +
> +	netif_napi_add(dev, &pp->napi, mvneta_poll, pp->weight);
> +
> +	SET_NETDEV_DEV(dev, &pdev->dev);
> +
> +	if (register_netdev(dev)) {
> +		dev_err(&pdev->dev, "failed to register\n");
> +		err = ENOMEM;
> +		goto err_base;
> +	}
> +
> +	dev->features = NETIF_F_SG;
> +	dev->hw_features =  NETIF_F_SG;
> +	dev->priv_flags |= IFF_UNICAST_FLT;
> +
> +	if (dev->mtu <= MVNETA_TX_CSUM_MAX_SIZE) {
> +		dev->features |= NETIF_F_IP_CSUM;
> +		dev->hw_features |= NETIF_F_IP_CSUM;
> +	}

At this point, the condition is always true, so just set these features and 
update them when the MTU changes.

> +
> +	dev_info(&pdev->dev, "%s, mac: %pM pp->base=%p\n", dev->name,
> +		 dev->dev_addr, pp->base);
> +
> +	platform_set_drvdata(pdev, pp->dev);
> +
> +	return 0;
> +err_base:
> +	iounmap(pp->base);
> +err_node:
> +	irq_dispose_mapping(dev->irq);
> +err_irq:
> +	free_netdev(dev);
> +	return err;
> +}
> +
> +/* Device removal routine */
> +static int __devexit mvneta_remove(struct platform_device *pdev)
> +{
> +	struct net_device  *dev = platform_get_drvdata(pdev);
> +	struct mvneta_port *pp = netdev_priv(dev);
> +
> +	dev_info(&pdev->dev, "Removing Marvell Ethernet Driver\n");

I would remove this message.
