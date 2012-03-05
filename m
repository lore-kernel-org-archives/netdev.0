From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v4] lpc32xx: Added ethernet driver
Date: Mon, 5 Mar 2012 22:45:24 +0000
Message-ID: <1330987524.2538.61.camel@bwh-desktop>
References: <1330983641-32622-1-git-send-email-stigge@antcom.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <jeffrey.t.kirsher@intel.com>,
	<alexander.h.duyck@intel.com>, <eilong@broadcom.com>,
	<ian.campbell@citrix.com>, <netdev@vger.kernel.org>,
	<w.sang@pengutronix.de>, <linux-kernel@vger.kernel.org>,
	<kevin.wells@nxp.com>, <linux-arm-kernel@lists.infradead.org>,
	<arnd@arndb.de>, <baruch@tkos.co.il>, <joe@perches.com>
To: Roland Stigge <stigge@antcom.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330983641-32622-1-git-send-email-stigge@antcom.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-03-05 at 22:40 +0100, Roland Stigge wrote:
[...]
> --- /dev/null
> +++ linux-2.6/drivers/net/ethernet/nxp/lpc_eth.c
[...]
> +/*
> + * Transmit timeout, default 2.5 seconds.
> + */
> +static int watchdog = 2500;
> +module_param(watchdog, int, 0400);
> +MODULE_PARM_DESC(watchdog, "transmit timeout in milliseconds");

Why does this need to be a parameter?

> +/*
> + * Structure of a TX/RX descriptors and RX status
> + */
> +struct txrx_desc_t {
> +	volatile u32 packet;
> +	volatile u32 control;
> +};
> +struct rx_status_t {
> +	volatile u32 statusinfo;
> +	volatile u32 statushashcrc;
> +};

Use of volatile here is probably wrong; see
Documentation/volatile-considered-harmful.txt.

> +/*
> + * Device driver data structure
> + */
> +struct netdata_local {
> +	struct platform_device	*pdev;
> +	struct net_device	*ndev;
> +	spinlock_t		lock;
> +	void __iomem		*net_base;
> +	u32			msg_enable;
> +	struct sk_buff		*skb[ENET_TX_DESC];
> +	unsigned int		last_tx_idx;
> +	unsigned int		num_used_tx_buffs;
> +	struct mii_bus		*mii_bus;
> +	struct phy_device	*phy_dev;
> +	struct clk		*clk;
> +	dma_addr_t		dma_buff_base_p;
> +	void			*dma_buff_base_v;
> +	size_t			dma_buff_size;
> +	struct txrx_desc_t	*tx_desc_v[ENET_TX_DESC];
> +	u32			*tx_stat_v[ENET_TX_DESC];
> +	void			*tx_buff_v[ENET_TX_DESC];
> +	struct txrx_desc_t	*rx_desc_v[ENET_RX_DESC];
> +	struct rx_status_t	*rx_stat_v[ENET_RX_DESC];
> +	void			*rx_buff_v[ENET_RX_DESC];

Why are these 6 members defined as arrays of pointers and not single
pointers to arrays?  It appears that each array element is initialised
to point into an array and then never changed; for example
tx_desc_v[i] == tx_desc_v[0] + i.

[...]
> +static void __lpc_eth_init(struct netdata_local *pldat)
> +{
[...]
> +	/* Clear and enable interrupts */
> +	writel(0xFFFF, LPC_ENET_INTCLEAR(pldat->net_base));
> +	lpc_eth_enable_int(pldat->net_base);
> +
> +	/* Get the next TX buffer output index */
> +	pldat->num_used_tx_buffs = 0;
> +	pldat->last_tx_idx =
> +		readl(LPC_ENET_TXCONSUMEINDEX(pldat->net_base));

Doesn't this need to be done *before* enabling interrupts?  Also, I
think you need an smp_wmb() so that the interrupt handler is guaranteed
to see all these writes.

[...]
> +static void lpc_handle_link_change(struct net_device *ndev)
> +{
> +	struct netdata_local *pldat = netdev_priv(ndev);
> +	struct phy_device *phydev = pldat->phy_dev;
> +	unsigned long flags;
> +
> +	int status_change = 0;

This is logically a boolean, so use bool/true/false.

[...]
> +static void __lpc_handle_xmit(struct net_device *ndev)
> +{
[...]
> +		/* Any errors occurred? */
> +		if (txstat & TXSTATUS_ERROR) {
> +			if (txstat & TXSTATUS_UNDERRUN) {
> +				/* FIFO underrun */
> +				ndev->stats.tx_fifo_errors++;
> +			}
> +			if (txstat & TXSTATUS_LATECOLL) {
> +				/* Late collision */
> +				ndev->stats.tx_aborted_errors++;
> +			}
> +			if (txstat & TXSTATUS_EXCESSCOLL) {
> +				/* Excessive collision */
> +				ndev->stats.tx_aborted_errors++;
> +			}
> +			if (txstat & TXSTATUS_EXCESSDEFER) {
> +				/* Defer limit */
> +				ndev->stats.tx_aborted_errors++;
> +			}
> +			ndev->stats.tx_errors++;
> +
> +			/* Buffer transmit failed, requeue it */
> +			lpc_eth_hard_start_xmit(skb, ndev);

It is not the responsibility of an Ethernet network driver to retry
transmission.  Also, this will deadlock on an SMP system since
lpc_eth_hard_start_xmit() will try to acquire pldat->lock which is
already held.  I suggest you test with lockdep in case there any other
such bugs which are being masked by running on a UP system.

[...]
> +static int __lpc_handle_recv(struct net_device *ndev, int budget)
> +{
[...]
> +			/* Packet is good */
> +			skb = dev_alloc_skb(len + 8);
> +			if (!skb)
> +				ndev->stats.rx_dropped++;
> +			else {
> +				skb_reserve(skb, 8);

What are you reserving this space for?

> +				prdbuf = skb_put(skb, (len - 0));

len - 0??

> +				/* Copy packet from buffer */
> +				memcpy(prdbuf,
> +					pldat->rx_buff_v[rxconsidx], len);
> +
> +				/* Pass to upper layer */
> +				skb->protocol = eth_type_trans(skb, ndev);
> +				netif_rx(skb);
> +				ndev->last_rx = jiffies;

Drivers don't need to set last_rx any more.

[...]
> +static int lpc_eth_poll(struct napi_struct *napi, int budget)
> +{
> +	struct netdata_local *pldat = container_of(napi,
> +			struct netdata_local, napi);
> +	struct net_device *ndev = pldat->ndev;
> +	unsigned long flags;
> +	int rx_done = 0;
> +
> +	spin_lock_irqsave(&pldat->lock, flags);
> +
> +	__lpc_handle_xmit(ndev);
> +	rx_done = __lpc_handle_recv(ndev, budget);
> +
> +	if (rx_done < budget) {
> +		napi_complete(napi);
> +		lpc_eth_enable_int(pldat->net_base);
> +	}
> +
> +	spin_unlock_irqrestore(&pldat->lock, flags);

This is really sad.  You implement NAPI but then take away most of the
benefits of that by disabling interrupts.

It looks like you could safely unlock pldat->lock before calling
__lpc_handle_recv - nothing else manipulates RX queue state so no lock
is required.

As for the TX side, you can probably use the TX queue lock
(__netif_tx_lock, __netif_tx_unlock) to serialise with
lpc_eth_hard_start_xmit() and avoid taking pldat->lock in either
__lpc_handle_xmit() or here.

[...]
> +	return rx_done;
> +}
> +
> +static irqreturn_t __lpc_eth_interrupt(int irq, void *dev_id)
> +{
> +	struct net_device *ndev = dev_id;
> +	struct netdata_local *pldat = netdev_priv(ndev);
> +	u32 tmp;
> +
> +	spin_lock(&pldat->lock);
> +
> +	tmp = readl(LPC_ENET_INTSTATUS(pldat->net_base));
> +	/* Clear interrupts */
> +	writel(tmp, LPC_ENET_INTCLEAR(pldat->net_base));
> +
> +	if (likely(napi_schedule_prep(&pldat->napi))) {
> +		lpc_eth_disable_int(pldat->net_base);
> +		__napi_schedule(&pldat->napi);
> +	}

I think you need to mask the interrupt unconditionally here.  See my
next comment.

> +	spin_unlock(&pldat->lock);
> +
> +	return IRQ_HANDLED;
> +}
> +
> +static int lpc_eth_close(struct net_device *ndev)
> +{
> +	unsigned long flags;
> +	struct netdata_local *pldat = netdev_priv(ndev);
> +
> +	if (netif_msg_ifdown(pldat))
> +		dev_dbg(&pldat->pdev->dev, "shutting down %s\n", ndev->name);
> +
> +	napi_disable(&pldat->napi);

If an interrupt is received after this returns, napi_schedule_prep()
will return false and the interrupt will not be masked.

There is a similar problem in lpc_eth_open() where you enable interrupts
before NAPI.

> +	netif_stop_queue(ndev);
> +
> +	if (pldat->phy_dev)
> +		phy_stop(pldat->phy_dev);
> +
> +	spin_lock_irqsave(&pldat->lock, flags);
> +	__lpc_eth_reset(pldat);
> +	netif_carrier_off(ndev);
> +	writel(0, LPC_ENET_MAC1(pldat->net_base));
> +	writel(0, LPC_ENET_MAC2(pldat->net_base));
> +	spin_unlock_irqrestore(&pldat->lock, flags);
> +
> +	__lpc_eth_clock_enable(pldat, 0);
> +
> +	return 0;
> +}
[...]
> +static int lpc_eth_hard_start_xmit(struct sk_buff *skb, struct net_device *ndev)
> +{
> +	struct netdata_local *pldat = netdev_priv(ndev);
> +	u32 len, txidx;
> +	u32 *ptxstat;
> +	struct txrx_desc_t *ptxrxdesc;
> +
> +	len = skb->len;
> +
> +	spin_lock_irq(&pldat->lock);
> +
> +	if (pldat->num_used_tx_buffs >= (ENET_TX_DESC - 1)) {
> +		/* This function should never be called when there are no
> +		   buffers, log the error */

So use WARN to make the error really obvious.

> +		netif_stop_queue(ndev);
> +		spin_unlock_irq(&pldat->lock);
> +		dev_err(&pldat->pdev->dev,
> +			"BUG! TX request when no free TX buffers!\n");
> +		return 1;

This is not a valid return value; you need to return NETDEV_TX_BUSY.

> +	}
> +
> +	/* Get the next TX descriptor index */
> +	txidx = readl(LPC_ENET_TXPRODUCEINDEX(pldat->net_base));
> +
> +	/* Setup control for the transfer */
> +	ptxstat = pldat->tx_stat_v[txidx];
> +	*ptxstat = 0;
> +	ptxrxdesc = pldat->tx_desc_v[txidx];
> +	ptxrxdesc->control =
> +		(len - 1) | TXDESC_CONTROL_LAST | TXDESC_CONTROL_INT;
> +
> +	/* Copy data to the DMA buffer */
> +	memcpy(pldat->tx_buff_v[txidx], skb->data, len);
> +
> +	/* Save the buffer and increment the buffer counter */
> +	pldat->skb[txidx] = skb;
> +	pldat->num_used_tx_buffs++;
> +
> +	/* Start transmit */
> +	txidx++;
> +	if (txidx >= ENET_TX_DESC)
> +		txidx = 0;
> +	writel(txidx, LPC_ENET_TXPRODUCEINDEX(pldat->net_base));
> +
> +	/* Stop queue if no more TX buffers */
> +	if (pldat->num_used_tx_buffs >= (ENET_TX_DESC - 1))
> +		netif_stop_queue(ndev);
> +
> +	spin_unlock_irq(&pldat->lock);
> +	ndev->trans_start = jiffies;

Drivers don't need to set trans_start any more.

> +	return 0;

NETDEV_TX_OK

> +}
[...]
> +static void lpc_eth_timeout(struct net_device *ndev)
> +{
> +	struct netdata_local *pldat = netdev_priv(ndev);
> +
> +	/* This should never happen and indicates a problem */
> +	dev_err(&pldat->pdev->dev, "BUG! TX timeout occurred!\n");
> +}

The networking core will print a big fat warning before calling this
function, so this message is redundant.  Also, timeout isn't necessarily
a bug; it can be caused by a misconfigured switch.

[...]
> +static int lpc_eth_ethtool_getsettings(struct net_device *ndev,
> +	struct ethtool_cmd *cmd)
> +{
> +	struct netdata_local *pldat = netdev_priv(ndev);
> +	struct phy_device *phydev = pldat->phy_dev;
> +
> +	if (!phydev)
> +		return -ENODEV;

-EOPNOTSUPP

> +	return phy_ethtool_gset(phydev, cmd);
> +}
> +
> +static int lpc_eth_ethtool_setsettings(struct net_device *ndev,
> +	struct ethtool_cmd *cmd)
> +{
> +	struct netdata_local *pldat = netdev_priv(ndev);
> +	struct phy_device *phydev = pldat->phy_dev;
> +
> +	if (!phydev)
> +		return -ENODEV;
[...]

-EOPNOTSUPP

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
