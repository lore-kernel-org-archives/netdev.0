From: Russell King - ARM Linux <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
Subject: Re: [PATCH 3/3] net: hisilicon: new hip04 ethernet driver
Date: Tue, 18 Mar 2014 10:46:16 +0000
Message-ID: <20140318104616.GT21483@n2100.arm.linux.org.uk>
References: <1395132017-15928-1-git-send-email-zhangfei.gao@linaro.org> <1395132017-15928-4-git-send-email-zhangfei.gao@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Zhangfei Gao <zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1395132017-15928-4-git-send-email-zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

I was just browsing this patch when I noticed some of these issues - I
haven't done a full review of this driver, I'm just commenting on the
things I've spotted.

On Tue, Mar 18, 2014 at 04:40:17PM +0800, Zhangfei Gao wrote:
> +static int hip04_rx_poll(struct napi_struct *napi, int budget)
> +{
> +	struct hip04_priv *priv = container_of(napi,
> +			      struct hip04_priv, napi);
> +	struct net_device *ndev = priv->ndev;
> +	struct sk_buff *skb;
> +	struct rx_desc *desc;
> +	unsigned char *buf;
> +	int rx = 0;
> +	unsigned int cnt = hip04_recv_cnt(priv);
> +	unsigned int len, tmp[16];
> +
> +	while (cnt) {
> +		buf = priv->rx_buf[priv->rx_head];
> +		skb = build_skb(buf, priv->rx_buf_size);
> +		if (unlikely(!skb))
> +			net_dbg_ratelimited("build_skb failed\n");
> +		dma_map_single(&ndev->dev, skb->data,
> +			RX_BUF_SIZE, DMA_FROM_DEVICE);

This is incorrect.

buf = buffer alloc()
/* CPU owns buffer and can read/write it, device does not */
dev_addr = dma_map_single(dev, buf, ..., DMA_FROM_DEVICE);
/* Device owns buffer and can write it, CPU does not access it */
dma_unmap_single(dev, dev_addr, ..., DMA_FROM_DEVICE);
/* CPU owns buffer again and can read/write it, device does not */

Please turn on DMA API debugging in the kernel debug options and verify
whether your driver causes it to complain (it will.)

I think you want dma_unmap_single() here.

> +		memcpy(tmp, skb->data, 64);
> +		endian_change((void *)tmp, 64);
> +		desc = (struct rx_desc *)tmp;
> +		len = desc->pkt_len;

This is a rather expensive way to do this.  Presumably the descriptors
are always big endian?  If so, why not:

		desc = skb->data;
		len = be16_to_cpu(desc->pkt_len);

?  You may need to lay the struct out differently for this to work so
the offset which pkt_len accesses is correct.

Also... do you not have any flags which indicate whether the packet
received was in error?

> +
> +		if (len > RX_BUF_SIZE)
> +			len = RX_BUF_SIZE;
> +		if (0 == len)
> +			break;
> +
> +		skb_reserve(skb, NET_SKB_PAD + NET_IP_ALIGN);
> +		skb_put(skb, len);
> +		skb->protocol = eth_type_trans(skb, ndev);
> +		napi_gro_receive(&priv->napi, skb);
> +
> +		buf = netdev_alloc_frag(priv->rx_buf_size);
> +		if (!buf)
> +			return -ENOMEM;
> +		priv->rx_buf[priv->rx_head] = buf;
> +		dma_map_single(&ndev->dev, buf, RX_BUF_SIZE, DMA_TO_DEVICE);
> +		hip04_set_recv_desc(priv, virt_to_phys(buf));

No need for virt_to_phys() here - dma_map_single() returns the device
address.

> +
> +		priv->rx_head = RX_NEXT(priv->rx_head);
> +		if (rx++ >= budget)
> +			break;
> +
> +		if (--cnt == 0)
> +			cnt = hip04_recv_cnt(priv);
> +	}
> +
> +	if (rx < budget) {
> +		napi_gro_flush(napi, false);
> +		__napi_complete(napi);
> +	}
> +
> +	/* enable rx interrupt */
> +	priv->reg_inten |= RCV_INT | RCV_NOBUF;
> +	writel_relaxed(priv->reg_inten, priv->base + PPE_INTEN);

This doesn't look right - you're supposed to re-enable receive interrupts
when you receive less than "budget" packets.

> +static irqreturn_t hip04_mac_interrupt(int irq, void *dev_id)
> +{
> +	struct net_device *ndev = (struct net_device *) dev_id;
> +	struct hip04_priv *priv = netdev_priv(ndev);
> +	u32 ists = readl_relaxed(priv->base + PPE_INTSTS);
> +	u32 val = DEF_INT_MASK;
> +
> +	writel_relaxed(val, priv->base + PPE_RINT);
> +
> +	if ((ists & RCV_INT) || (ists & RCV_NOBUF)) {

What you get with this is the compiler generating code to test RCV_INT,
and then if that's false, code to test RCV_NOBUF.  There's no possibility
for the compiler to optimise that because it's part of the language spec
that condition1 || condition2 will always have condition1 evaluated first,
and condition2 will only be evaluated if condition1 was false.

	if (ists & (RCV_INT | RCV_NOBUF)) {

would more than likely be more efficient here.

> +		if (napi_schedule_prep(&priv->napi)) {
> +			/* disable rx interrupt */
> +			priv->reg_inten &= ~(RCV_INT | RCV_NOBUF);
> +			writel_relaxed(priv->reg_inten, priv->base + PPE_INTEN);
> +			__napi_schedule(&priv->napi);
> +		}
> +	}
> +
> +	return IRQ_HANDLED;
> +}
> +
> +static void hip04_tx_reclaim(struct net_device *ndev, bool force)
> +{
> +	struct hip04_priv *priv = netdev_priv(ndev);
> +	unsigned tx_head = priv->tx_head;
> +	unsigned tx_tail = priv->tx_tail;
> +	struct tx_desc *desc = priv->td_ring[priv->tx_tail];
> +
> +	spin_lock_irq(&priv->txlock);

Do you know for certain that interrupts were (and always will be) definitely
enabled prior to this point?  If not, you should use spin_lock_irqsave()..
spin_unlock_irqrestore().

> +	while (tx_tail != tx_head) {
> +		if (desc->send_addr != 0) {
> +			if (force)
> +				desc->send_addr = 0;
> +			else
> +				break;
> +		}

dma_unmap_single(&ndev->dev, dev_addr, skb->len, DMA_TO_DEVICE) ?

It looks like your device zeros the send address when it has finished
transmitting - if this is true, then you will need to store dev_addr
separately for each transmit packet.

> +		dev_kfree_skb_irq(priv->tx_skb[tx_tail]);
> +		priv->tx_skb[tx_tail] = NULL;
> +		tx_tail = TX_NEXT(tx_tail);
> +		priv->tx_count--;

No processing of transmit statistics?

> +	}
> +	priv->tx_tail = tx_tail;
> +	spin_unlock_irq(&priv->txlock);

If you have freed up any packets, then you should call netif_wake_queue().
Do you not get any interrupts when a packet is transmitted?

> +}
> +
> +static int hip04_mac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
> +{
> +	struct hip04_priv *priv = netdev_priv(ndev);
> +	struct tx_desc *desc = priv->td_ring[priv->tx_head];
> +	unsigned int tx_head = priv->tx_head;
> +	int ret;
> +
> +	hip04_tx_reclaim(ndev, false);
> +
> +	spin_lock_irq(&priv->txlock);

Same comment here...

> +	if (priv->tx_count++ >= TX_DESC_NUM) {
> +		net_dbg_ratelimited("no TX space for packet\n");
> +		netif_stop_queue(ndev);
> +		ret = NETDEV_TX_BUSY;
> +		goto out_unlock;
> +	}

You shouldn't rely on this - you should stop the queue when you put the
last packet to fill the ring before returning from this function.  When
you clean the ring in your hip04_tx_reclaim() function, to wake the
queue.

> +
> +	priv->tx_skb[tx_head] = skb;
> +	dma_map_single(&ndev->dev, skb->data, skb->len, DMA_TO_DEVICE);
> +	memset((void *)desc, 0, sizeof(*desc));
> +	desc->send_addr = (unsigned int)virt_to_phys(skb->data);

Again, dma_map_single() gives you the device address, there's no need
to use virt_to_phys(), and there should be no need for a cast here
either.  Also consider cpu_to_be32() and similar for the other descriptor
writes.

> +	desc->send_size = skb->len;
> +	desc->cfg = DESC_DEF_CFG;
> +	desc->wb_addr = priv->td_phys[tx_head];
> +	endian_change(desc, 64);
> +	skb_tx_timestamp(skb);
> +	hip04_set_xmit_desc(priv, priv->td_phys[tx_head]);
> +
> +	priv->tx_head = TX_NEXT(tx_head);
> +	ret = NETDEV_TX_OK;

As mentioned above, if you have filled the ring, you need to also call
netif_stop_queue() here.

> +static int hip04_mac_probe(struct platform_device *pdev)
> +{
> +	struct device *d = &pdev->dev;
> +	struct device_node *node = d->of_node;
> +	struct net_device *ndev;
> +	struct hip04_priv *priv;
> +	struct resource *res;
> +	unsigned int irq, val;
> +	int ret;
> +
> +	ndev = alloc_etherdev(sizeof(struct hip04_priv));
> +	if (!ndev)
> +		return -ENOMEM;
> +
> +	priv = netdev_priv(ndev);
> +	priv->ndev = ndev;
> +	platform_set_drvdata(pdev, ndev);
> +	spin_lock_init(&priv->txlock);
> +	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +	if (!res) {
> +		ret = -EINVAL;
> +		goto init_fail;
> +	}
> +	ndev->base_addr = res->start;
> +	priv->base = devm_ioremap_resource(d, res);
> +	ret = IS_ERR(priv->base);
> +	if (ret) {
> +		dev_err(d, "devm_ioremap_resource failed\n");
> +		goto init_fail;
> +	}

If you're using devm_ioremap_resource(), you don't need to check the
resource above.  In any case, returning the value from IS_ERR() from
this function is not correct.

	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
	priv->base = devm_ioremap_resource(d, res);
	if (IS_ERR(priv->base) {
		ret = PTR_ERR(priv->base);
		goto init_fail;
	}

You don't need to fill in ndev->base_addr (many drivers don't.)

-- 
FTTC broadband for 0.8mile line: now at 9.7Mbps down 460kbps up... slowly
improving, and getting towards what was expected from it.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
