From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] Add mac driver for w90p910
Date: Sun, 19 Jul 2009 11:16:08 +0100
Message-ID: <20090719101608.GP12062@n2100.arm.linux.org.uk>
References: <4A5F2329.9090901@gmail.com> <5d5443650907161042g428afc74jf40f5daf71db7620@mail.gmail.com> <4A605EC1.1070203@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trilok Soni <soni.trilok@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>,
	linux-arm-kernel <linux-arm-kernel@lists.arm.linux.org.uk>,
	"Eric.miao" <eric.y.miao@gmail.com>
To: Wan ZongShun <mcuos.com@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:52296 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752632AbZGSKQ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jul 2009 06:16:26 -0400
Content-Disposition: inline
In-Reply-To: <4A605EC1.1070203@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 17, 2009 at 07:21:37PM +0800, Wan ZongShun wrote:
> Some locks seems useless, So I remove them, and regarding the casting,
> I have to keep "(dma_addr_t *)" here, as I remove it, a "warning occurs, as following:
> "warning: passing argument 3 of 'dma_alloc_coherent' from incompatible pointer type"

This tends to mean you don't have things quite right then.  Below are
some suggestions which should resolve this.

> +struct  w90p910_ether {
> +	struct recv_pdesc *rdesc;
> +	struct recv_pdesc *rdesc_phys;

	dma_addr_t rdesc_phys;

> +	struct tran_pdesc *tdesc;
> +	struct tran_pdesc *tdesc_phys;

	dma_addr_t tdesc_phys;

> +	struct net_device_stats stats;
> +	struct platform_device *pdev;
> +	struct sk_buff *skb;
> +	struct clk *clk;
> +	struct clk *rmiiclk;
> +	struct mii_if_info mii;
> +	struct timer_list check_timer;
> +	void __iomem *reg;
> +	unsigned int rxirq;
> +	unsigned int txirq;
> +	unsigned int cur_tx;
> +	unsigned int cur_rx;
> +	unsigned int finish_tx;
> +	unsigned int rx_packets;
> +	unsigned int rx_bytes;
> +	unsigned int start_tx_ptr;
> +	unsigned int start_rx_ptr;
> +	unsigned int linkflag;
> +};
...
> +static void w90p910_init_desc(struct net_device *dev)
> +{
> +	struct w90p910_ether *ether;
> +	struct w90p910_txbd  *tdesc, *tdesc_phys;
> +	struct w90p910_rxbd  *rdesc, *rdesc_phys;
> +	unsigned int i, j;
> +
> +	ether = netdev_priv(dev);
> +
> +	ether->tdesc = (struct tran_pdesc *)
> +			dma_alloc_coherent(NULL, sizeof(struct tran_pdesc),
> +				(dma_addr_t *)&ether->tdesc_phys, GFP_KERNEL);
> +
> +	ether->rdesc = (struct recv_pdesc *)
> +			dma_alloc_coherent(NULL, sizeof(struct recv_pdesc),
> +				(dma_addr_t *)&ether->rdesc_phys, GFP_KERNEL);

	ether->tdesc = dma_alloc_cohernet(NULL, sizeof(struct tran_pdesc),
				&ether->tdesc_phys, GFP_KERNEL);
	ether->rdesc = dma_alloc_cohernet(NULL, sizeof(struct recv_pdesc),
				&ether->rdesc_phys, GFP_KERNEL);

Note that these functions can fail and return a NULL pointer - you need
to check for that.  Also I wonder why you're not passing &ether->pdev->dev
as the first argument.

> +
> +	for (i = 0; i < TX_DESC_SIZE; i++) {
> +		tdesc = &(ether->tdesc->desclist[i]);
> +
> +		j = ((i + 1) / TX_DESC_SIZE);
> +
> +		if (j != 0) {

This is a weird way of detecting the last interation in the loop.
Wouldn't:

		if (i == TX_DESC_SIZE - 1) {

be sufficient?

> +			tdesc_phys = &(ether->tdesc_phys->desclist[0]);
> +			ether->start_tx_ptr = (unsigned int)tdesc_phys;
> +			tdesc->next = (unsigned int)ether->start_tx_ptr;
> +		} else {
> +			tdesc_phys = &(ether->tdesc_phys->desclist[i+1]);
> +			tdesc->next = (unsigned int)tdesc_phys;
> +		}
> +
> +		tdesc->buffer = (unsigned int)ether->tdesc_phys->tran_buf[i];
> +		tdesc->sl = 0;
> +		tdesc->mode = 0;
> +	}

How about this instead:

	for (i = 0; i < TX_DESC_SIZE; i++) {
		unsigned int offset;

		tdesc = &(ether->tdesc->desclist[i]);

		if (i == TX_DESC_SIZE - 1)
			offset = offsetof(struct tran_pdesc, desclist[0]);
		else
			offset = offsetof(struct tran_pdesc, desclist[i + 1]);

		tdesc->next = ether->tdesc_phys + offset;
		tdesc->buffer = ether->tdesc_phys + 
			offsetof(struct tran_pdesc, tran_buf[i]);
		tdesc->sl = 0;
		tdesc->mode = 0;
	}

	ether->start_tx_ptr = ether->tdesc_phys;

> +
> +	for (i = 0; i < RX_DESC_SIZE; i++) {
> +		rdesc = &(ether->rdesc->desclist[i]);
> +
> +		j = ((i + 1) / RX_DESC_SIZE);
> +
> +		if (j != 0) {
> +			rdesc_phys = &(ether->rdesc_phys->desclist[0]);
> +			ether->start_rx_ptr = (unsigned int)rdesc_phys;
> +			rdesc->next = (unsigned int)ether->start_rx_ptr;
> +		} else {
> +			rdesc_phys = &(ether->rdesc_phys->desclist[i+1]);
> +			rdesc->next = (unsigned int)rdesc_phys;
> +		}
> +
> +		rdesc->sl = RX_OWEN_DMA;
> +		rdesc->buffer = (unsigned int)ether->rdesc_phys->recv_buf[i];
> +	  }

Same kind of fixup here.

> +}
...
> +static int w90p910_ether_close(struct net_device *dev)
> +{
> +	struct w90p910_ether *ether = netdev_priv(dev);
> +
> +	dma_free_writecombine(NULL, sizeof(struct w90p910_rxbd),
> +				ether->rdesc, (dma_addr_t)ether->rdesc_phys);
> +	dma_free_writecombine(NULL, sizeof(struct w90p910_txbd),
> +				ether->tdesc, (dma_addr_t)ether->tdesc_phys);

With rdesc_phys and tdesc_phys correctly typed, these casts can go away.
These functions should also be dma_free_cohernet(), and also note comment
about first argument for dma_alloc_coherent() also applies here.

> +
> +	netif_stop_queue(dev);
> +
> +	del_timer_sync(&ether->check_timer);
> +	clk_disable(ether->rmiiclk);
> +	clk_disable(ether->clk);
> +
> +	free_irq(ether->txirq, dev);
> +	free_irq(ether->rxirq, dev);
> +
> +	return 0;
> +}
...
> +static irqreturn_t w90p910_tx_interrupt(int irq, void *dev_id)
> +{
> +	struct w90p910_ether *ether;
> +	struct w90p910_txbd  *txbd;
> +	struct platform_device *pdev;
> +	struct tran_pdesc *tran_pdesc;
> +	struct net_device *dev;
> +	unsigned int cur_entry, entry, status;
> +
> +	dev = dev_id;
> +	ether = netdev_priv(dev);
> +	pdev = ether->pdev;
> +
> +	w90p910_get_and_clear_int(dev, &status);
> +
> +	cur_entry = __raw_readl(ether->reg + REG_CTXDSA);
> +
> +	tran_pdesc = ether->tdesc_phys;
> +	entry = (unsigned int)(&tran_pdesc->desclist[ether->finish_tx]);

	entry = ether->tdesc_phys +
		offsetof(struct tran_pdesc, desclist[ether->finish_tx]);

> +
> +	while (entry != cur_entry) {
> +		txbd = &ether->tdesc->desclist[ether->finish_tx];
> +
> +		ether->finish_tx = (ether->finish_tx + 1) % TX_DESC_SIZE;

Division and modulus can be expensive when not powers of two.  Would:

		if (++ether->finish_tx >= TX_DESC_SIZE)
			ether->finish_tx = 0;

be better?

> +
> +		if (txbd->sl & TXDS_TXCP) {
> +			ether->stats.tx_packets++;
> +			ether->stats.tx_bytes += txbd->sl & 0xFFFF;
> +		} else {
> +			ether->stats.tx_errors++;
> +		}
> +
> +		txbd->sl = 0x0;
> +		txbd->mode = 0x0;
> +
> +		if (netif_queue_stopped(dev))
> +			netif_wake_queue(dev);
> +
> +		entry = (unsigned int)(&tran_pdesc->desclist[ether->finish_tx]);

		entry = ether->tdesc_phys +
			offsetof(struct tran_pdesc, desclist[ether->finish_tx]);

> +	}
> +
> +	if (status & MISTA_EXDEF) {
> +		dev_err(&pdev->dev, "emc defer exceed interrupt\n");
> +	} else if (status & MISTA_TXBERR) {
> +		dev_err(&pdev->dev, "emc bus error interrupt\n");
> +		w90p910_reset_mac(dev);
> +	} else if (status & MISTA_TDU) {
> +		if (netif_queue_stopped(dev))
> +			netif_wake_queue(dev);
> +	}
> +
> +	return IRQ_HANDLED;
> +}
> +
> +static void netdev_rx(struct net_device *dev)
> +{
> +	struct w90p910_ether *ether;
> +	struct w90p910_rxbd *rxbd;
> +	struct platform_device *pdev;
> +	struct recv_pdesc *rdesc_phys;
> +	struct sk_buff *skb;
> +	unsigned char *data;
> +	unsigned int length, status, val, entry;
> +
> +	ether = netdev_priv(dev);
> +	pdev = ether->pdev;
> +	rdesc_phys = ether->rdesc_phys;
> +
> +	rxbd = &ether->rdesc->desclist[ether->cur_rx];
> +
> +	do {
> +		val = __raw_readl(ether->reg + REG_CRXDSA);
> +		entry = (unsigned int)&rdesc_phys->desclist[ether->cur_rx];

Same kind of fixups as above.

> +
> +		if (val == entry)
> +			break;
> +
> +		status = rxbd->sl;
> +		length = status & 0xFFFF;
> +
> +		if (status & RXDS_RXGD) {
> +			data = ether->rdesc->recv_buf[ether->cur_rx];
> +			skb = dev_alloc_skb(length+2);
> +			if (!skb) {
> +				dev_err(&pdev->dev, "get skb buffer error\n");
> +				ether->stats.rx_dropped++;
> +				return;
> +			}
> +
> +			skb->dev = dev;
> +			skb_reserve(skb, 2);
> +			skb_put(skb, length);
> +			skb_copy_to_linear_data(skb, data, length);
> +			skb->protocol = eth_type_trans(skb, dev);
> +			ether->stats.rx_packets++;
> +			ether->stats.rx_bytes += length;
> +			netif_rx(skb);
> +		} else {
> +			ether->stats.rx_errors++;
> +
> +			if (status & RXDS_RP) {
> +				dev_err(&pdev->dev, "rx runt err\n");
> +				ether->stats.rx_length_errors++;
> +			} else if (status & RXDS_CRCE) {
> +				dev_err(&pdev->dev, "rx crc err\n");
> +				ether->stats.rx_crc_errors++;
> +			} else if (status & RXDS_ALIE) {
> +				dev_err(&pdev->dev, "rx aligment err\n");
> +				ether->stats.rx_frame_errors++;
> +			} else if (status & RXDS_PTLE) {
> +				dev_err(&pdev->dev, "rx longer err\n");
> +				ether->stats.rx_over_errors++;
> +			}
> +		}
> +
> +		rxbd->sl = RX_OWEN_DMA;
> +		rxbd->reserved = 0x0;
> +		ether->cur_rx = (ether->cur_rx+1) % RX_DESC_SIZE;
> +		rxbd = &ether->rdesc->desclist[ether->cur_rx];
> +
> +		dev->last_rx = jiffies;
> +	} while (1);
> +}
...
> +static int __devexit w90p910_ether_remove(struct platform_device *pdev)
> +{
> +	struct net_device *dev = platform_get_drvdata(pdev);
> +	struct w90p910_ether *ether = netdev_priv(dev);
> +
> +	unregister_netdev(dev);
> +	clk_put(ether->rmiiclk);
> +	clk_put(ether->clk);
> +	del_timer_sync(&ether->check_timer);
> +	platform_set_drvdata(pdev, NULL);
> +	free_irq(ether->txirq, dev);
> +	free_irq(ether->rxirq, dev);

iounmap?  release_mem_region?

> +	free_netdev(dev);
> +	return 0;
> +}
