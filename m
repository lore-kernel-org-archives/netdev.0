From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next v2 06/10] net: bcmgenet: add main driver file
Date: Thu, 13 Feb 2014 11:35:06 +0100
Message-ID: <20140213103506.GB14941@electric-eye.fr.zoreil.com>
References: <1392269395-23513-1-git-send-email-f.fainelli@gmail.com>
 <1392269395-23513-7-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, cernekee@gmail.com,
	devicetree@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:44088 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753203AbaBMKfL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 05:35:11 -0500
Content-Disposition: inline
In-Reply-To: <1392269395-23513-7-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <f.fainelli@gmail.com> :
[...]
> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> new file mode 100644
> index 0000000..ab71e81
> --- /dev/null
> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
[...]
> +static int bcmgenet_set_rx_csum(struct net_device *dev,
> +				netdev_features_t wanted)
> +{
> +	struct bcmgenet_priv *priv = netdev_priv(dev);
> +	u32 rbuf_chk_ctrl;
> +	int rx_csum_en;
> +
> +	rx_csum_en = !!(wanted & NETIF_F_RXCSUM);

It's a bool.

> +
> +	spin_lock_bh(&priv->bh_lock);
> +	rbuf_chk_ctrl = bcmgenet_rbuf_readl(priv, RBUF_CHK_CTRL);
> +
> +	/* enable rx checksumming */
> +	if (!rx_csum_en)
> +		rbuf_chk_ctrl &= ~RBUF_RXCHK_EN;
> +	else
> +		rbuf_chk_ctrl |= RBUF_RXCHK_EN;
> +	priv->desc_rxchk_en = rx_csum_en;
> +	bcmgenet_rbuf_writel(priv, rbuf_chk_ctrl, RBUF_CHK_CTRL);
> +
> +	spin_unlock_bh(&priv->bh_lock);
> +
> +	return 0;
> +}
> +static int bcmgenet_set_tx_csum(struct net_device *dev,

Missing empty line.

[...]
> +static void bcmgenet_update_mib_counters(struct bcmgenet_priv *priv)
> +{
> +	int i, j = 0;
> +
> +	for (i = 0; i < BCMGENET_STATS_LEN; i++) {
> +		const struct bcmgenet_stats *s;
> +		u32 val = 0;
> +		char *p;
> +		u8 offset = 0;

Xmas tree please.

[...]
> +static void bcmgenet_get_ethtool_stats(struct net_device *dev,
> +					struct ethtool_stats *stats,
> +					u64 *data)
> +{
> +	struct bcmgenet_priv *priv = netdev_priv(dev);
> +	int i;
> +
> +	mutex_lock(&priv->mib_mutex);
> +	if (netif_running(dev))
> +		bcmgenet_update_mib_counters(priv);
> +
> +	for (i = 0; i < BCMGENET_STATS_LEN; i++) {
> +		const struct bcmgenet_stats *s;
> +		char *p;
> +
> +		s = &bcmgenet_gstrings_stats[i];
> +		if (s->type == BCMGENET_STAT_NETDEV)
> +			p = (char *)&dev->stats;
> +		else
> +			p = (char *)priv;
> +		p += s->stat_offset;
> +		data[i] = *(u32 *)p;
> +	}
> +	mutex_unlock(&priv->mib_mutex);

The mutex is not used anywhere else and dev_ethtool runs under RTNL.

[...]
> +/* Assign skb to RX DMA descriptor. */
> +static int bcmgenet_alloc_rx_buffers(struct bcmgenet_priv *priv)
> +{
> +	struct enet_cb *cb;

Wrong scope.

> +	int ret = 0;
> +	int i;
> +	u32 reg;
> +
> +	netif_dbg(priv, hw, priv->dev, "%s:\n", __func__);
> +
> +	/* This function may be called from irq bottom-half. */
> +	spin_lock_bh(&priv->bh_lock);

The Rx part of the NAPI handler directly calls bcmgenet_rx_refill through
bcmgenet_desc_rx. bcmgenet_poll does not sync with bh_lock.

Either some factoring was forgotten or some legacy locking / comment was
left in place (there should not be any ->open vs ->poll race)

> +
> +	/* loop here for each buffer needing assign */
> +	for (i = 0; i < priv->num_rx_bds; i++) {
> +		cb = &priv->rx_cbs[priv->rx_bd_assign_index];
> +		if (cb->skb)
> +			continue;
> +
> +		/* set the DMA descriptor length once and for all
> +		 * it will only change if we support dynamically sizing
> +		 * priv->rx_buf_len, but we do not
> +		 */
> +		dmadesc_set_length_status(priv, priv->rx_bd_assign_ptr,
> +				priv->rx_buf_len << DMA_BUFLENGTH_SHIFT);
> +
> +		ret = bcmgenet_rx_refill(priv, cb);
> +		if (ret)
> +			break;
> +
> +	}
> +
> +	/* Enable rx DMA incase it was disabled due to running out of rx BD */

Nit: nothing proves even a single descriptor suceeded allocation.

[...]
> +static int reset_umac(struct bcmgenet_priv *priv)
> +{
> +	struct device *kdev = &priv->pdev->dev;
> +	unsigned int timeout = 0;
> +	u32 reg;
> +
> +	/* 7358a0/7552a0: bad default in RBUF_FLUSH_CTRL.umac_sw_rst */
> +	bcmgenet_rbuf_ctrl_set(priv, 0);
> +	udelay(10);
> +
> +	/* disable MAC while updating its registers */
> +	bcmgenet_umac_writel(priv, 0, UMAC_CMD);
> +
> +	/* issue soft reset, wait for it to complete */
> +	bcmgenet_umac_writel(priv, CMD_SW_RESET, UMAC_CMD);
> +	while (timeout++ < 1000) {
> +		reg = bcmgenet_umac_readl(priv, UMAC_CMD);
> +		if (!(reg & CMD_SW_RESET))
> +			break;

			return 0;

> +		udelay(1);
> +	}
> +
> +	if (timeout == 1000) {
> +		dev_err(kdev,
> +			"timeout waiting for MAC to come out of resetn\n");
> +		return -ETIMEDOUT;
> +	}
> +
> +	return 0;
> +}
> +
> +/* init_umac: Initializes the uniMac controller */

Useless.

> +static int init_umac(struct bcmgenet_priv *priv)
> +{
[...]
> +static void bcmgenet_init_multiq(struct net_device *dev)
> +{
> +	struct bcmgenet_priv *priv = netdev_priv(dev);
> +	unsigned int i, dma_enable;
> +	u32 reg, dma_ctrl, ring_cfg = 0, dma_priority = 0;
> +
> +	if (!netif_is_multiqueue(dev)) {
> +		netdev_warn(dev, "called with non multi queue aware HW\n");
> +		return;
> +	}
> +
> +	dma_ctrl = bcmgenet_tdma_readl(priv, DMA_CTRL);
> +	dma_enable = dma_ctrl & DMA_EN;
> +	dma_ctrl &= ~DMA_EN;
> +	bcmgenet_tdma_writel(priv, dma_ctrl, DMA_CTRL);
> +
> +	/* Enable strict priority arbiter mode */
> +	bcmgenet_tdma_writel(priv, DMA_ARBITER_SP, DMA_ARB_CTRL);
> +
> +	for (i = 0; i < priv->hw_params->tx_queues; i++) {
> +		/* first 64 tx_cbs are reserved for default tx queue
> +		 * (ring 16)
> +		 */
> +		bcmgenet_init_tx_ring(priv, i, priv->hw_params->bds_cnt,
> +					i * priv->hw_params->bds_cnt,
> +					(i + 1) * priv->hw_params->bds_cnt);
> +
> +		/* Configure ring as decriptor ring and setup priority */
> +		ring_cfg |= (1 << i);
> +		dma_priority |= ((GENET_Q0_PRIORITY + i) <<
> +				(GENET_MAX_MQ_CNT + 1) * i);
> +		dma_ctrl |= (1 << (i + DMA_RING_BUF_EN_SHIFT));

Excess parenthesis.

[...]
> +/* NAPI polling method*/
> +static int bcmgenet_poll(struct napi_struct *napi, int budget)
> +{
> +	struct bcmgenet_priv *priv = container_of(napi,
> +			struct bcmgenet_priv, napi);
> +	unsigned int work_done;
> +
> +	work_done = bcmgenet_desc_rx(priv, budget);
> +
> +	/* tx reclaim */
> +	bcmgenet_tx_reclaim(priv->dev, &priv->tx_rings[DESC_INDEX]);

You may move the quick Tx reclaim before the slower Rx protocol processing.

> +	/* Advancing our consumer index*/
> +	priv->rx_c_index += work_done;
> +	priv->rx_c_index &= DMA_C_INDEX_MASK;
> +	bcmgenet_rdma_ring_writel(priv, DESC_INDEX,
> +				priv->rx_c_index, RDMA_CONS_INDEX);
> +	if (work_done < budget) {
> +		napi_complete(napi);
> +		bcmgenet_intrl2_0_writel(priv,
> +			UMAC_IRQ_RXDMA_BDONE, INTRL2_CPU_MASK_CLEAR);
> +	}
> +
> +	return work_done;
> +}
> +
> +/* Interrupt bottom half */
> +static void bcmgenet_irq_task(struct work_struct *work)
> +{
> +	struct bcmgenet_priv *priv = container_of(
> +			work, struct bcmgenet_priv, bcmgenet_irq_work);
> +	struct net_device *dev;

	struct net_device *dev = priv->dev;

> +	u32 reg;
> +
> +	dev = priv->dev;
> +
> +	netif_dbg(priv, intr, dev, "%s\n", __func__);
> +	/* Cable plugged/unplugged event */
> +	if (priv->phy_interface == PHY_INTERFACE_MODE_INTERNAL) {
> +		if (priv->irq0_stat & UMAC_IRQ_PHY_DET_R) {
> +			priv->irq0_stat &= ~UMAC_IRQ_PHY_DET_R;
> +			netif_crit(priv, link, dev,
> +				"cable plugged in, powering up\n");
> +			bcmgenet_power_up(priv, GENET_POWER_CABLE_SENSE);
> +		} else if (priv->irq0_stat & UMAC_IRQ_PHY_DET_F) {
> +			priv->irq0_stat &= ~UMAC_IRQ_PHY_DET_F;
> +			netif_crit(priv, link, dev,
> +				"cable unplugged, powering down\n");
> +			bcmgenet_power_down(priv, GENET_POWER_CABLE_SENSE);
> +		}
> +	}
> +	if (priv->irq0_stat & UMAC_IRQ_MPD_R) {
> +		priv->irq0_stat &= ~UMAC_IRQ_MPD_R;
> +		netif_crit(priv, wol, dev,
> +			"magic packet detected, waking up\n");
> +		/* disable mpd interrupt */
> +		bcmgenet_intrl2_0_writel(priv,
> +			UMAC_IRQ_MPD_R, INTRL2_CPU_MASK_SET);
> +		/* disable CRC forward.*/
> +		reg = bcmgenet_umac_readl(priv, UMAC_CMD);
> +		reg &= ~CMD_CRC_FWD;
> +		bcmgenet_umac_writel(priv, reg, UMAC_CMD);
> +		priv->crc_fwd_en = 0;
> +		bcmgenet_power_up(priv, GENET_POWER_WOL_MAGIC);
> +
> +	} else if (priv->irq0_stat & (UMAC_IRQ_HFB_SM | UMAC_IRQ_HFB_MM)) {
> +		priv->irq0_stat &= ~(UMAC_IRQ_HFB_SM | UMAC_IRQ_HFB_MM);
> +		netif_crit(priv, wol, dev,
> +			"ACPI pattern matched, waking up\n");
> +		/* disable HFB match interrupts */
> +		bcmgenet_intrl2_0_writel(priv,
> +			UMAC_IRQ_HFB_SM | UMAC_IRQ_HFB_MM, INTRL2_CPU_MASK_SET);
> +		bcmgenet_power_up(priv, GENET_POWER_WOL_ACPI);
> +	}

It smells of half-backed wol / runtime power support. Imvho it deserves
some comment in the changelog message to hint about its maturity.

> +
> +	/* Link UP/DOWN event */
> +	if ((priv->hw_params->flags & GENET_HAS_MDIO_INTR) &&
> +		(priv->irq0_stat & (UMAC_IRQ_LINK_UP|UMAC_IRQ_LINK_DOWN))) {
> +		if (priv->phydev)
> +			phy_mac_interrupt(priv->phydev,
> +				(priv->irq0_stat & UMAC_IRQ_LINK_UP));
> +		priv->irq0_stat &= ~(UMAC_IRQ_LINK_UP|UMAC_IRQ_LINK_DOWN);
> +	}
> +}
> +
> +/* bcmgenet_isr1: interrupt handler for ring buffer. */
> +static irqreturn_t bcmgenet_isr1(int irq, void *dev_id)
> +{
> +	struct bcmgenet_priv *priv = dev_id;
> +	unsigned int index;

Wrong scope.

> +
> +	/* Save irq status for bottom-half processing. */
> +	priv->irq1_stat =
> +		bcmgenet_intrl2_1_readl(priv, INTRL2_CPU_STAT) &
> +		~priv->int1_mask;
> +	/* clear inerrupts*/
> +	bcmgenet_intrl2_1_writel(priv, priv->irq1_stat, INTRL2_CPU_CLEAR);
> +
> +	netif_dbg(priv, intr, priv->dev,
> +		"%s: IRQ=0x%x\n", __func__, priv->irq1_stat);
> +	/* Check the MBDONE interrupts.
> +	 * packet is done, reclaim descriptors
> +	 */
> +	if (priv->irq1_stat & 0x0000ffff) {
> +		index = 0;
> +		for (index = 0; index < 16; index++) {

Proofread patrol alert :o)

(...]
> +static int bcmgenet_dma_teardown(struct bcmgenet_priv *priv)
> +{
> +	int timeout = 0;
> +	u32 reg;
> +
> +	/* Disable TDMA to stop add more frames in TX DMA */
> +	reg = bcmgenet_tdma_readl(priv, DMA_CTRL);
> +	reg &= ~DMA_EN;
> +	bcmgenet_tdma_writel(priv, reg, DMA_CTRL);
> +
> +	/* Check TDMA status register to confirm TDMA is disabled */
> +	while (!(bcmgenet_tdma_readl(priv, DMA_STATUS) & DMA_DISABLED)) {
> +		if (timeout++ == 5000) {
> +			netdev_warn(priv->dev,
> +				"Timed out while disabling TX DMA\n");
> +			return -ETIMEDOUT;
> +		}
> +		udelay(1);
> +	}

On the stylistic side, the driver hesitates between "while", "for" timeout
and conditions loop. I'd go for the boring "int i; for (i = 0; i < max; i++)"
style but it's your call.

On the worrying side, even if Tx DMA does not stop, the driver should
try to disable Rx DMA.

> +
> +	/* Wait 10ms for packet drain in both tx and rx dma */
> +	usleep_range(10000, 20000);
> +
> +	/* Disable RDMA */
> +	reg = bcmgenet_rdma_readl(priv, DMA_CTRL);
> +	reg &= ~DMA_EN;
> +	bcmgenet_rdma_writel(priv, reg, DMA_CTRL);
> +
> +	timeout = 0;
> +	/* Check RDMA status register to confirm RDMA is disabled */
> +	while (!(bcmgenet_rdma_readl(priv, DMA_STATUS) & DMA_DISABLED)) {
> +		if (timeout++ == 5000) {
> +			netdev_warn(priv->dev,
> +				"Timed out while disabling RX DMA\n");
> +			return -ETIMEDOUT;
> +		}
> +		udelay(1);
> +	}
> +
> +	return 0;
> +}
[...]
> +static void bcmgenet_timeout(struct net_device *dev)
> +{
> +	struct bcmgenet_priv *priv = netdev_priv(dev);
> +
> +	BUG_ON(dev == NULL);

dev == NULL should be noticed quickly.

> +
> +	netif_dbg(priv, tx_err, dev, "bcmgenet_timeout\n");
> +
> +	dev->trans_start = jiffies;
> +
> +	dev->stats.tx_errors++;
> +
> +	netif_tx_wake_all_queues(dev);

dev_watchdog already complains (loudly).

Is it really supposed to recover ?

> +}
> +
> +#define MAX_MC_COUNT	16
> +
> +static inline void bcmgenet_set_mdf_addr(struct bcmgenet_priv *priv,
> +					 unsigned char *addr,
> +					 int *i,
> +					 int *mc)
> +{
> +	u32 reg;
> +
> +	bcmgenet_umac_writel(priv, addr[0] << 8 | addr[1],
> +			UMAC_MDF_ADDR + (*i * 4));
> +	bcmgenet_umac_writel(priv,
> +			addr[2] << 24 | addr[3] << 16 |
> +			addr[4] << 8 | addr[5],
> +			UMAC_MDF_ADDR + ((*i + 1) * 4));

I would not expect such an indent to pass beyond davem.

> +	reg = bcmgenet_umac_readl(priv, UMAC_MDF_CTRL);
> +	reg |= (1 << (MAX_MC_COUNT - *mc));
> +	bcmgenet_umac_writel(priv, reg, UMAC_MDF_CTRL);
> +	*i += 2;
> +	(*mc)++;
> +}
> +
> +static void bcmgenet_set_rx_mode(struct net_device *dev)
> +{
> +	struct bcmgenet_priv *priv = netdev_priv(dev);
> +	struct netdev_hw_addr *ha;
> +	int i, mc;
> +	u32 reg;
> +
> +	netif_dbg(priv, hw, dev, "%s: %08X\n", __func__, dev->flags);
> +
> +	/* Promiscous mode */
> +	reg = bcmgenet_umac_readl(priv, UMAC_CMD);
> +	if (dev->flags & IFF_PROMISC) {
> +		reg |= CMD_PROMISC;
> +		bcmgenet_umac_writel(priv, reg, UMAC_CMD);
> +		bcmgenet_umac_writel(priv, 0, UMAC_MDF_CTRL);
> +		return;
> +	} else {
> +		reg &= ~CMD_PROMISC;
> +		bcmgenet_umac_writel(priv, reg, UMAC_CMD);
> +	}
> +
> +	/* UniMac doesn't support ALLMULTI */
> +	if (dev->flags & IFF_ALLMULTI)
> +		return;

The driver did not fulfill the request. It could complain to help user.

[...]
> +static int bcmgenet_set_mac_addr(struct net_device *dev, void *p)
> +{
> +	struct sockaddr *addr = p;
> +
> +	if (netif_running(dev))
> +		return -EBUSY;

Add a comment to specify if it is a hardware shortcoming or something else ?

> +
> +	ether_addr_copy(dev->dev_addr, addr->sa_data);
> +
> +	return 0;
> +}

[...]
> +static const struct net_device_ops bcmgenet_netdev_ops = {
> +	.ndo_open = bcmgenet_open,
> +	.ndo_stop = bcmgenet_close,
> +	.ndo_start_xmit = bcmgenet_xmit,
> +	.ndo_select_queue = bcmgenet_select_queue,
> +	.ndo_tx_timeout = bcmgenet_timeout,
> +	.ndo_set_rx_mode = bcmgenet_set_rx_mode,
> +	.ndo_set_mac_address = bcmgenet_set_mac_addr,
> +	.ndo_do_ioctl = bcmgenet_ioctl,
> +	.ndo_set_features = bcmgenet_set_features,
> +};

Please use tabs before '=' to line things up.

[...]
> +static int bcmgenet_probe(struct platform_device *pdev)
> +{
> +	struct device_node *dn = pdev->dev.of_node;
> +	struct bcmgenet_priv *priv;
> +	struct net_device *dev;
> +	const void *macaddr;
> +	struct resource *r;
> +	int err = -EIO;
> +
> +	/* Up to GENET_MAX_MQ_CNT + 1 TX queues and a single RX queue */
> +	dev = alloc_etherdev_mqs(sizeof(*priv), GENET_MAX_MQ_CNT + 1, 1);
> +	if (!dev) {
> +		dev_err(&pdev->dev, "can't allocate net device\n");
> +		return -ENOMEM;
> +	}
> +
> +	priv = netdev_priv(dev);
> +	priv->irq0 = platform_get_irq(pdev, 0);
> +	priv->irq1 = platform_get_irq(pdev, 1);
> +	if (!priv->irq0 || !priv->irq1) {
> +		dev_err(&pdev->dev, "can't find IRQs\n");
> +		err = -EINVAL;
> +		goto err;
> +	}
> +
> +	macaddr = of_get_mac_address(dn);
> +	if (!macaddr) {
> +		dev_err(&pdev->dev, "can't find MAC address\n");
> +		err = -EINVAL;
> +		goto err;
> +	}
> +
> +	r = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +	priv->base = devm_request_and_ioremap(&pdev->dev, r);
> +	if (!priv->base) {
> +		dev_err(&pdev->dev, "can't ioremap\n");
> +		err = -EINVAL;
> +		goto err;
> +	}
> +
> +	dev->base_addr = (unsigned long)priv->base;

base_addr in net_device is a legacy hack.

> +	SET_NETDEV_DEV(dev, &pdev->dev);
> +	dev_set_drvdata(&pdev->dev, dev);
> +	ether_addr_copy(dev->dev_addr, macaddr);
> +	dev->irq = priv->irq0;

And so is irq.

-- 
Ueimor
