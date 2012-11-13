From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v6 2/7] net: mvneta: driver for Marvell Armada 370/XP network unit
Date: Wed, 14 Nov 2012 00:12:48 +0100
Message-ID: <20121113231248.GA30391@electric-eye.fr.zoreil.com>
References: <1352818843-4457-1-git-send-email-thomas.petazzoni@free-electrons.com> <1352818843-4457-3-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Lennert Buytenhek <kernel@wantstofly.org>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Dmitri Epshtein <dima@marvell.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:46529 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755086Ab2KMXgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 18:36:06 -0500
Content-Disposition: inline
In-Reply-To: <1352818843-4457-3-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Petazzoni <thomas.petazzoni@free-electrons.com> :
[...]
> +static int mvneta_mac_addr_set(struct mvneta_port *pp, unsigned char *addr,
> +			       int queue)
> +{
> +	unsigned int mac_h;
> +	unsigned int mac_l;
> +
> +	if (queue >= 1) {
> +		netdev_err(pp->dev, "RX queue #%d is out of range\n", queue);
> +		return -EINVAL;
> +	}

(whence q <= 0)

> +
> +	if (queue != -1) {
> +		mac_l = (addr[4] << 8) | (addr[5]);
> +		mac_h = (addr[0] << 24) | (addr[1] << 16) |
> +			(addr[2] << 8) | (addr[3] << 0);
> +
> +		mvreg_write(pp, MVNETA_MAC_ADDR_LOW, mac_l);
> +		mvreg_write(pp, MVNETA_MAC_ADDR_HIGH, mac_h);
> +	}

What is it trying to achieve with the "queue" argument ?

[...]
> +/* Refill processing */
> +static int mvneta_rx_refill(struct mvneta_port *pp,
> +			    struct mvneta_rx_desc *rx_desc)
> +
> +{
> +	dma_addr_t phys_addr;
> +	struct sk_buff *skb;
> +
> +	skb = netdev_alloc_skb(pp->dev, pp->pkt_size);
> +	if (!skb)
> +		return -ENOMEM;

Could netdev_alloc_skb_ip_align be an option ?

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
> +		if (!mvneta_rxq_desc_is_first_last(rx_desc) ||
> +		    (rx_status & MVNETA_RXD_ERR_SUMMARY)) {
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
> +		skb_reserve(skb, MVNETA_MH_SIZE);
> +		skb_put(skb, rx_bytes);

(I suggested to use skb_reserve / skb_put instead of hand-crafted code but
I may have ignored the elephant in the living room)

I understand the skb_put, ok. What is the purpose of the skb_reserve ?

Are MVNETA_ETH_CRC_SIZE (4) and MVNETA_MH_SIZE (2) really different from
ETH_FCS_LEN and NET_IP_ALIGN ?

[...]
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

Hand-crafted napi_schedule.

[...]
> +static int mvneta_open(struct net_device *dev)
> +{
> +	struct mvneta_port *pp = netdev_priv(dev);
> +	int ret;
> +
> +	ret = mvneta_mac_addr_set(pp, dev->dev_addr, rxq_def);
> +	if (ret < 0) {
> +		netdev_err(dev, "mvneta_mac_addr_set failed\n");
> +		goto mac_addr_set_failure;
> +	}

AFAIU mvneta_mac_addr_set can only fail when (module parameter) rxq_def is
not set correctly. It imho calls for a check in probe/remove and a removal
of the failure case in mvneta_mac_addr_set.

> +
> +	pp->pkt_size = MVNETA_RX_PKT_SIZE(pp->dev->mtu);
> +
> +	ret = mvneta_setup_rxqs(pp);
> +	if (ret)
> +		goto rxqs_setup_failure;
> +
> +	ret = mvneta_setup_txqs(pp);
> +	if (ret)
> +		goto txqs_setup_failure;
> +
> +	/* Connect to port interrupt line */
> +	ret = request_irq(pp->dev->irq, mvneta_isr, IRQF_DISABLED,
> +			  MVNETA_DRIVER_NAME, pp);

include/linux/interrupt.h
[...]
 * IRQF_DISABLED - keep irqs disabled when calling the action handler.
 *                 DEPRECATED. This flag is a NOOP and scheduled to be removed

[...]
> +static int __devinit mvneta_probe(struct platform_device *pdev)
> +{
> +	const struct mbus_dram_target_info *dram_target_info;
> +	struct device_node *dn = pdev->dev.of_node;
> +	struct device_node *phy_node;
> +	u32 phy_addr, clk_rate_hz;
> +	struct mvneta_port *pp;
> +	struct net_device *dev;
> +	const char *mac_addr;
> +	int phy_mode;
> +	int err;
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
> +	phy_node = of_parse_phandle(dn, "phy", 0);
> +	if (!phy_node) {
> +		dev_err(&pdev->dev, "no associated PHY\n");
> +		err = -ENODEV;
> +		goto err_node;
> +	}
> +
> +	phy_mode = of_get_phy_mode(dn);
> +	if (phy_mode < 0) {
> +		dev_err(&pdev->dev, "incorrect phy-mode\n");
> +		err = -EINVAL;
> +		goto err_node;
> +	}
> +
> +	if (of_property_read_u32(dn, "clock-frequency", &clk_rate_hz) != 0) {
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
> +		memcpy(dev->dev_addr, mac_addr, ETH_ALEN);
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
> +
> +	pp->weight = MVNETA_RX_POLL_WEIGHT;
> +	pp->clk_rate_hz = clk_rate_hz;
> +	pp->phy_node = phy_node;
> +	pp->phy_interface = phy_mode;
> +
> +	pp->base = of_iomap(dn, 0);
> +	if (pp->base == NULL) {
> +		err = -ENOMEM;
> +		goto err_node;
> +	}
> +
> +	pp->tx_done_timer.data = (unsigned long)dev;
> +
> +	pp->tx_ring_size = MVNETA_MAX_TXD;
> +	pp->rx_ring_size = MVNETA_MAX_RXD;
> +
> +	pp->dev = dev;
> +	SET_NETDEV_DEV(dev, &pdev->dev);
> +
> +	if (mvneta_init(pp, phy_addr)) {
> +		dev_err(&pdev->dev, "can't init eth hal\n");
> +		err = -ENODEV;
> +		goto err_base;
> +	}

The error code from mvneta_init() should be used.

> +	mvneta_port_power_up(pp, phy_mode);
> +
> +	dram_target_info = mv_mbus_dram_info();
> +	if (dram_target_info)
> +		mvneta_conf_mbus_windows(pp, dram_target_info);
> +
> +	netif_napi_add(dev, &pp->napi, mvneta_poll, pp->weight);
> +
> +	if (register_netdev(dev)) {
> +		dev_err(&pdev->dev, "failed to register\n");
> +		err = ENOMEM;
> +		goto err_base;
> +	}

- The error code from register_netdev() should be used.
- Leak: allocations in mvneta_init() are not balanced.
- Nit: the "err_where_did_it_trigger_first" style of label shows its
  downside when compared to the "err_what_should_be_done" when
  it gets used several times.

> +
> +	dev->features = NETIF_F_SG | NETIF_F_IP_CSUM;
> +	dev->hw_features =  NETIF_F_SG | NETIF_F_IP_CSUM;
> +	dev->priv_flags |= IFF_UNICAST_FLT;
> +
> +	dev_info(&pdev->dev, "%s, mac: %pM\n", dev->name,
> +		 dev->dev_addr);
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
> +	iounmap(pp->base);
> +
> +	unregister_netdev(dev);
> +	irq_dispose_mapping(dev->irq);
> +	free_netdev(dev);
> +	mvneta_deinit(pp);

One may expect the same ordering as the mvneta_probe unroll sequence.

-- 
Ueimor
