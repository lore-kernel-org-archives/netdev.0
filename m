From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] PA Semi PWRficient Ethernet driver
Date: Mon, 29 Jan 2007 10:22:33 -0800
Message-ID: <20070129102233.27f236ee@freekitty>
References: <20070129060852.GA7814@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:49532 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752550AbXA2SZQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jan 2007 13:25:16 -0500
In-Reply-To: <20070129060852.GA7814@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Basic initalization, setup comments.

> +static int pasemi_mac_open(struct net_device *dev)
> +{
> +	struct pasemi_mac *mac = netdev_priv(dev);
> +	unsigned int flags;
> +	int ret;
> +
> +	pr_debug("pasemi_mac_open\n");

dev_dbg() ?

> +
> +	/* enable rx section */
> +	pci_write_config_dword(mac->dma_pdev, PAS_DMA_COM_RXCMD,
> +			       PAS_DMA_COM_RXCMD_EN);
> +
> +	/* enable tx section */
> +	pci_write_config_dword(mac->dma_pdev, PAS_DMA_COM_TXCMD,
> +			       PAS_DMA_COM_TXCMD_EN);
> +
> +	flags = PAS_MAC_CFG_TXP_FCE | PAS_MAC_CFG_TXP_FPC(3) |
> +		PAS_MAC_CFG_TXP_SL(3) | PAS_MAC_CFG_TXP_COB(0xf) |
> +		PAS_MAC_CFG_TXP_TIFT(8) | PAS_MAC_CFG_TXP_TIFG(12);
> +
> +	pci_write_config_dword(mac->pdev, PAS_MAC_CFG_TXP, flags);
> +
> +	flags = PAS_MAC_CFG_PCFG_S1 | PAS_MAC_CFG_PCFG_PE |
> +		PAS_MAC_CFG_PCFG_PR | PAS_MAC_CFG_PCFG_CE;
> +
> +	flags |= PAS_MAC_CFG_PCFG_TSR_1G | PAS_MAC_CFG_PCFG_SPD_1G;
> +
> +	pci_write_config_dword(mac->iob_pdev, PAS_IOB_DMA_RXCH_CFG(mac->dma_rxch),
> +			       PAS_IOB_DMA_RXCH_CFG_CNTTH(30));
> +
> +	pci_write_config_dword(mac->iob_pdev, PAS_IOB_DMA_COM_TIMEOUTCFG,
> +			       PAS_IOB_DMA_COM_TIMEOUTCFG_TCNT(1000000));
> +
> +	pci_write_config_dword(mac->pdev, PAS_MAC_CFG_PCFG, flags);
> +
> +	pasemi_mac_setup_rx_resources(dev);
> +	pasemi_mac_setup_tx_resources(dev);
> +
> +	pci_write_config_dword(mac->pdev, PAS_MAC_IPC_CHNL,
> +			       PAS_MAC_IPC_CHNL_DCHNO(mac->dma_rxch) |
> +			       PAS_MAC_IPC_CHNL_BCH(mac->dma_rxch));
> +
> +	/* enable rx if */
> +	pci_write_config_dword(mac->dma_pdev,
> +			       PAS_DMA_RXINT_RCMDSTA(mac->dma_if),
> +			       PAS_DMA_RXINT_RCMDSTA_EN);
> +
> +	/* enable rx channel */
> +	pci_write_config_dword(mac->dma_pdev,
> +			       PAS_DMA_RXCHAN_CCMDSTA(mac->dma_rxch),
> +			       PAS_DMA_RXCHAN_CCMDSTA_EN |
> +			       PAS_DMA_RXCHAN_CCMDSTA_DU);
> +
> +	/* enable tx channel */
> +	pci_write_config_dword(mac->dma_pdev,
> +			       PAS_DMA_TXCHAN_TCMDSTA(mac->dma_txch),
> +			       PAS_DMA_TXCHAN_TCMDSTA_EN);
> +
> +	pasemi_mac_replenish_rx_ring(dev);
> +
> +	netif_start_queue(dev);
> +	netif_poll_enable(dev);
> +
> +	ret = request_irq(128 + mac->dma_txch, &pasemi_mac_tx_intr,
> +			  IRQF_DISABLED, "pasemi_mac tx", dev);

Shouldn't you get IRQ value from PCI config?

> +	if (ret)
> +		printk("request_irq of irq %d failed: %d\n",
> +		       mac->dma_pdev->irq + mac->dma_txch, ret);
> +
> +	ret = request_irq(128 + 20 + mac->dma_rxch, &pasemi_mac_rx_intr,
> +			  IRQF_DISABLED, "pasemi_mac rx", dev);
> +	if (ret)
> +		printk("request_irq of irq %d failed: %d\n",
> +		       mac->dma_pdev->irq + 20 + mac->dma_rxch, ret);

You need to return error code and unwind other request_irq.

> +	return 0;
> +}
> +
> +static int pasemi_mac_close(struct net_device *dev)
> +{
> +	struct pasemi_mac *mac = netdev_priv(dev);
> +	unsigned int stat;
> +
> +	netif_stop_queue(dev);
> +
> +	/* Clean out any pending buffers */
> +	pasemi_mac_clean_tx(mac);
> +	pasemi_mac_clean_rx(mac, mac->rx->count);
> +
> +	/* Disable interface */
> +	pci_write_config_dword(mac->dma_pdev,
> +			       PAS_DMA_TXCHAN_TCMDSTA(mac->dma_txch),
> +			       PAS_DMA_TXCHAN_TCMDSTA_ST);
> +	pci_write_config_dword(mac->dma_pdev,
> +		      PAS_DMA_RXINT_RCMDSTA(mac->dma_if),
> +		      PAS_DMA_RXINT_RCMDSTA_ST);
> +	pci_write_config_dword(mac->dma_pdev,
> +		      PAS_DMA_RXCHAN_CCMDSTA(mac->dma_rxch),
> +		      PAS_DMA_RXCHAN_CCMDSTA_ST);
> +
> +	do {
> +		pci_read_config_dword(mac->dma_pdev,
> +				      PAS_DMA_TXCHAN_TCMDSTA(mac->dma_txch),
> +				      &stat);
> +	} while (stat & PAS_DMA_TXCHAN_TCMDSTA_ACT);
> +
> +	do {
> +		pci_read_config_dword(mac->dma_pdev,
> +				      PAS_DMA_RXCHAN_CCMDSTA(mac->dma_rxch),
> +				      &stat);
> +	} while (stat & PAS_DMA_RXCHAN_CCMDSTA_ACT);
> +
> +	do {
> +		pci_read_config_dword(mac->dma_pdev,
> +				      PAS_DMA_RXINT_RCMDSTA(mac->dma_if),
> +				      &stat);
> +	} while (stat & PAS_DMA_RXINT_RCMDSTA_ACT);
> +
> +	/* Then, disable the channel. This must be done separately from
> +	 * stopping, since you can't disable when active.
> +	 */
> +
> +	pci_write_config_dword(mac->dma_pdev,
> +			       PAS_DMA_TXCHAN_TCMDSTA(mac->dma_txch), 0);
> +	pci_write_config_dword(mac->dma_pdev,
> +			       PAS_DMA_RXCHAN_CCMDSTA(mac->dma_rxch), 0);
> +	pci_write_config_dword(mac->dma_pdev,
> +			       PAS_DMA_RXINT_RCMDSTA(mac->dma_if), 0);
> +
> +	free_irq(mac->dma_pdev->irq + mac->dma_txch, dev);
> +	free_irq(mac->dma_pdev->irq + 20 + mac->dma_rxch, dev);
> +
> +	/* Free resources */
> +	pasemi_mac_free_resources(dev);
> +
> +	return 0;
> +}
> +
> +static int pasemi_mac_start_tx(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct pasemi_mac *mac = netdev_priv(dev);
> +	struct pasemi_mac_txring *txring;
> +	u64 flags;
> +	dma_addr_t map;
> +
> +	if (mac->tx->next_to_clean+mac->tx->count == mac->tx->next_to_use)
> +		pasemi_mac_clean_tx(mac);
> +
> +	mac->stats.tx_packets++;
> +	mac->stats.tx_bytes += skb->len;
> +
> +	txring = mac->tx;
> +
> +	flags = XCT_MACTX_O | XCT_MACTX_ST |
> +		XCT_MACTX_SS | XCT_MACTX_CRC_PAD;
> +
> +	if (skb->ip_summed == CHECKSUM_PARTIAL) {
> +		switch (skb->nh.iph->protocol) {
> +		case IPPROTO_TCP:
> +			flags |= XCT_MACTX_CSUM_TCP;
> +			flags |= XCT_MACTX_IPH((skb->h.raw - skb->nh.raw) >> 2);
> +			flags |= XCT_MACTX_IPO(skb->nh.raw - skb->data);
> +			break;
> +		case IPPROTO_UDP:
> +			flags |= XCT_MACTX_CSUM_UDP;
> +			flags |= XCT_MACTX_IPH((skb->h.raw - skb->nh.raw) >> 2);
> +			flags |= XCT_MACTX_IPO(skb->nh.raw - skb->data);
> +			break;
> +		}
> +	}
> +
> +	map = virt_to_phys(skb->data);
> +
> +	DESCR(txring, txring->next_to_use).mactx = flags |
> +						XCT_MACTX_LLEN(skb->len);
> +	DESCR(txring, txring->next_to_use).ptr = XCT_PTR_LEN(skb->len) |
> +						XCT_PTR_ADDR(map);
> +	INFO(txring, txring->next_to_use).dma = map;
> +	INFO(txring, txring->next_to_use).skb = skb;
> +	/* XXXOJN Deal with fragmented packets when larger MTU is supported */
> +
> +	txring->next_to_use++;
> +
> +	pci_write_config_dword(mac->dma_pdev,
> +			       PAS_DMA_TXCHAN_INCR(mac->dma_txch), 1);

You need to handle flow control and do netif_stop_queue/netif_wake_queue
when your transmit ring gets full.

> +
> +	return NETDEV_TX_OK;
> +}
> +
> +static struct net_device_stats *pasemi_mac_get_stats(struct net_device *dev)
> +{
> +	struct pasemi_mac *mac = netdev_priv(dev);
> +
> +	return &mac->stats;
> +}
> +
> +static void pasemi_mac_set_rx_mode(struct net_device *dev)
> +{
> +	struct pasemi_mac *mac = netdev_priv(dev);
> +	unsigned int flags;
> +
> +	return;
> +
> +	pci_read_config_dword(mac->pdev, PAS_MAC_CFG_PCFG, &flags);
> +
> +	/* Set promiscuous */
> +	if (dev->flags & IFF_PROMISC)
> +		flags |= PAS_MAC_CFG_PCFG_PR;
> +	else
> +		flags &= ~PAS_MAC_CFG_PCFG_PR;
> +
> +	pci_write_config_dword(mac->pdev, PAS_MAC_CFG_PCFG, flags);
> +}
> +
> +
> +static int pasemi_mac_clean_rx(struct pasemi_mac *mac, int limit)
> +{
> +	int i, j;
> +	struct pas_dma_xct_descr descr;
> +	struct pasemi_mac_buffer *info;
> +	struct sk_buff *skb;
> +	unsigned int len;
> +	int start;
> +	int count;
> +	dma_addr_t dma;
> +
> +	start = mac->rx->next_to_clean;
> +	count = 0;
> +
> +	for (i = start; i < start+mac->rx->count && count < limit; i++) {
> +		rmb();
> +		mb();
> +		descr = DESCR(mac->rx, i);
> +		if (!(descr.macrx & XCT_MACRX_O))
> +			break;
> +
> +		count++;
> +
> +		info = NULL;
> +
> +		/* We have to scan for our skb since there's no way
> +		 * to back-map them from the descriptor, and if we
> +		 * have several receive channels then they might not
> +		 * show up in the same order as they were put on the
> +		 * interface ring.
> +		 */
> +
> +		dma = (descr.ptr & XCT_PTR_ADDR_M);
> +		for (j = start; j < start+mac->rx->count; j++)
> +			if (INFO(mac->rx, j).dma == dma) {
> +				info = &INFO(mac->rx, j);
> +				break;
> +			}
> +
> +		BUG_ON(!info);
> +
> +		skb = info->skb;
> +
> +		len = (descr.macrx & XCT_MACRX_LLEN_M) >> XCT_MACRX_LLEN_S;
> +
> +		skb_put(skb, len);
> +
> +		skb->protocol = eth_type_trans(skb, mac->netdev);
> +
> +		if ((descr.macrx & XCT_MACRX_HTY_M) == XCT_MACRX_HTY_IPV4_OK) {
> +			skb->ip_summed = CHECKSUM_COMPLETE;
> +			skb->csum = (descr.macrx & XCT_MACRX_CSUM_M) >>
> +					   XCT_MACRX_CSUM_S;
> +		} else
> +			skb->ip_summed = CHECKSUM_NONE;
> +
> +		mac->stats.rx_bytes += len;
> +		mac->stats.rx_packets++;
> +
> +		netif_receive_skb(skb);
> +
> +		DESCR(mac->rx, i).ptr = 0;
> +		DESCR(mac->rx, i).macrx = 0;
> +		info->dma = 0;
> +		info->skb = 0;
> +		mb();
> +	}
> +
> +	mac->rx->next_to_clean += count;
> +	pasemi_mac_replenish_rx_ring(mac->netdev);
> +
> +	return count;
> +}
> +
> +static int pasemi_mac_clean_tx(struct pasemi_mac *mac)
> +{
> +	int i;
> +	struct pasemi_mac_buffer *info;
> +	struct pas_dma_xct_descr *dp;
> +	int start;
> +	int count;
> +
> +	start = mac->tx->next_to_clean;
> +	count = 0;
> +
> +	for (i = start; i < mac->tx->next_to_use; i++) {
> +		dp = &DESCR(mac->tx, i);
> +		if (!dp || (dp->mactx & XCT_MACTX_O))
> +			break;
> +
> +		count++;
> +
> +		info = &INFO(mac->tx, i);
> +
> +		dev_kfree_skb_irq(info->skb);
> +		info->skb = NULL;
> +		info->dma = 0;
> +		dp->mactx = 0;
> +		dp->ptr = 0;
> +	}
> +	mac->tx->next_to_clean += count;
> +	return count;
> +}
> +
> +
> +static int pasemi_mac_poll(struct net_device *dev, int *budget)
> +{
> +	int pkts, limit = min(*budget, dev->quota);
> +	struct pasemi_mac *mac = netdev_priv(dev);
> +
> +	pkts = pasemi_mac_clean_rx(mac, limit);
> +
> +	if (pkts < limit) {
> +		/* all done, no more packets present */
> +		netif_rx_complete(dev);
> +
> +		/* re-enable receive interrupts */
> +		pci_write_config_dword(mac->iob_pdev, PAS_IOB_DMA_COM_TIMEOUTCFG,
> +				       PAS_IOB_DMA_COM_TIMEOUTCFG_TCNT(1000000));
> +		return 0;
> +	} else {
> +		/* used up our quantum, so reschedule */
> +		dev->quota -= pkts;
> +		*budget -= pkts;
> +		return 1;
> +	}
> +}
> +
> +
> +static irqreturn_t pasemi_mac_rx_intr(int irq, void *data)
> +{
> +	struct net_device *dev = data;
> +	struct pasemi_mac *mac = netdev_priv(dev);
> +	unsigned int reg;
> +
> +	netif_rx_schedule(dev);
> +	pci_write_config_dword(mac->iob_pdev, PAS_IOB_DMA_COM_TIMEOUTCFG,
> +			       PAS_IOB_DMA_COM_TIMEOUTCFG_TCNT(0));
> +
> +	reg = PAS_IOB_DMA_RXCH_RESET_PINTC | PAS_IOB_DMA_RXCH_RESET_SINTC |
> +	      PAS_IOB_DMA_RXCH_RESET_DINTC;
> +	if (*mac->rx_status & PAS_STATUS_TIMER)
> +		reg |= PAS_IOB_DMA_RXCH_RESET_TINTC;
> +
> +	pci_write_config_dword(mac->iob_pdev,
> +			       PAS_IOB_DMA_RXCH_RESET(mac->dma_rxch), reg);
> +
> +
> +	return IRQ_HANDLED;
> +}
> +
> +static irqreturn_t pasemi_mac_tx_intr(int irq, void *data)
> +{
> +	struct net_device *dev = data;
> +	struct pasemi_mac *mac = netdev_priv(dev);
> +	unsigned int reg;
> +
> +	pasemi_mac_clean_tx(mac);
> +
> +	reg = PAS_IOB_DMA_TXCH_RESET_PINTC | PAS_IOB_DMA_TXCH_RESET_SINTC;
> +	if (*mac->tx_status & PAS_STATUS_TIMER)
> +		reg |= PAS_IOB_DMA_TXCH_RESET_TINTC;
> +
> +	pci_write_config_dword(mac->iob_pdev, PAS_IOB_DMA_TXCH_RESET(mac->dma_txch),
> +			       reg);
> +
> +	return IRQ_HANDLED;
> +}

To do shared IRQ's properly you need to check to see if
this is your device IRQ or not. Maybe reading config value?

> +static int __devinit
> +pasemi_mac_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
> +{
> +	static int index = 0;
> +	struct net_device *dev;
> +	struct pasemi_mac *mac;
> +	int err;
> +
> +	err = pci_enable_device(pdev);
> +	if (err) {
> +		dev_err(&pdev->dev, "pasemi_mac: Could not enable device.\n");
> +		return -ENODEV;

Please return err instead. This allows propagating a possibly
useful value.

> +	}
> +	dev = alloc_etherdev(sizeof(struct pasemi_mac));
> +	if (dev == NULL) {
> +		dev_err(&pdev->dev,
> +			"pasemi_mac: Could not allocate ethernet device.\n");
> +		return -ENODEV;
	return -ENOMEM;

> +	}
> +	SET_MODULE_OWNER(dev);
> +
> +	pci_set_drvdata(pdev, dev);
> +	SET_NETDEV_DEV(dev, &pdev->dev);
> +
> +	mac = netdev_priv(dev);
> +	memset(mac, 0, sizeof(struct pasemi_mac));

Unnecessary, alloc_etherdev already zeros.

> +	mac->pdev = pdev;
> +	mac->netdev = dev;
> +	mac->dma_pdev = pci_find_device(0x1959, 0xa007, NULL);

Do not use pci_find_device in new code. See comment in kernel doc's.
Use pci_get_device instead. You are not checking for error values.

> +	mac->iob_pdev = pci_find_device(0x1959, 0xa001, NULL);
> +
> +	if (!mac->iob_pdev) {
> +		dev_err(&pdev->dev, "Can't find I/O Bridge\n");
> +		return -ENODEV;
> +	}
> +
> +	/* These should come out of the device tree eventually */
> +	mac->dma_txch = index;
> +	mac->dma_rxch = index;
> +
> +	/* We probe GMAC before XAUI, but the DMA interfaces are
> +	 * in XAUI, GMAC order.
> +	 */
> +	if (index < 4)
> +		mac->dma_if = index + 2;
> +	else
> +		mac->dma_if = index - 4;
> +	index++;
> +
> +	switch (pdev->device) {
> +	case 0xa005:
> +		mac->type = MAC_TYPE_GMAC;
> +		break;
> +	case 0xa006:
> +		mac->type = MAC_TYPE_XAUI;
> +		break;
> +	default:
> +		err = -ENODEV;
> +		goto out;
> +	}
> +
> +	/* get mac addr from device tree */
> +	if (pasemi_set_mac_addr(mac)) {
> +		err = -ENODEV;
> +		goto out;
> +	}
> +	memcpy(dev->dev_addr, mac->mac_addr, sizeof(mac->mac_addr));
> +
> +	strcpy(dev->name, "eth%d");

alloc_etherdev already sets this for dev->name


> +	dev->open = pasemi_mac_open;
> +	dev->stop = pasemi_mac_close;
> +	dev->hard_start_xmit = pasemi_mac_start_tx;
> +	dev->get_stats = pasemi_mac_get_stats;
> +	dev->set_multicast_list = pasemi_mac_set_rx_mode;
> +	dev->weight = 64;
> +	dev->poll = pasemi_mac_poll;
> +	dev->features = NETIF_F_HW_CSUM;
> +
> +	/* The dma status structure is located in the I/O bridge, and
> +	 * is cache coherent.
> +	 */
> +	if (!dma_status)
> +		/* XXXOJN This should come from the device tree */
> +		dma_status = __ioremap(0xfd800000, 0x1000, 0);
> +
> +	mac->rx_status = &dma_status->rx_sta[mac->dma_rxch];
> +	mac->tx_status = &dma_status->tx_sta[mac->dma_txch];
> +
> +	err = register_netdev(dev);
> +
> +	if (err)
> +		printk("register_netdev failed with error %d\n", err);

You are leaking netdevice, and all your pci setup needs to
be undone.

> +	else
> +		printk(KERN_INFO "%s: PA Semi %s: intf %d, txch %d, rxch %d, "
> +		       "hw addr %02x:%02x:%02x:%02x:%02x:%02x\n",
> +		       dev->name, mac->type == MAC_TYPE_GMAC ? "GMAC" : "XAUI",
> +		       mac->dma_if, mac->dma_txch, mac->dma_rxch,
> +		       dev->dev_addr[0], dev->dev_addr[1], dev->dev_addr[2],
> +		       dev->dev_addr[3], dev->dev_addr[4], dev->dev_addr[5]);
> +
> +	return err;
> +
> +out:
> +	printk(KERN_ERR "pasemi_mac: init failed\n");

You need to unwind the pci_ stuff.

> +	pci_disable_device(pdev);
> +	free_netdev(dev);
> +	return err;
> +}
> +
> +static struct pci_device_id pasemi_mac_pci_tbl[] = {
> +	{ PCI_DEVICE(0x1959, 0xa005) },
> +	{ PCI_DEVICE(0x1959, 0xa006) },
> +	{ 0 }
> +};
> +
> +MODULE_DEVICE_TABLE(pci, pasemi_mac_pci_tbl);
> +
> +static struct pci_driver pasemi_mac_driver = {
> +	.name = "pasemi_mac",
> +	.id_table = pasemi_mac_pci_tbl,
> +	.probe = pasemi_mac_probe,

Don't you need a remove routine?

> +};
> +
> +static void __exit pasemi_mac_cleanup_module(void)
> +{
> +	pci_unregister_driver(&pasemi_mac_driver);
> +}
> +
> +int pasemi_mac_init_module(void)
> +{
> +	return pci_module_init(&pasemi_mac_driver);

pci_module_init is marked as obsolete, please use pci_register_driver

> +}
> +module_init(pasemi_mac_init_module);
> +module_exit(pasemi_mac_cleanup_module);


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
