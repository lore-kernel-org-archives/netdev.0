From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH v6 2/7] net: mvneta: driver for Marvell Armada 370/XP
 network unit
Date: Wed, 14 Nov 2012 15:04:06 +0100
Message-ID: <20121114150406.6e85dcc5@skate>
References: <1352818843-4457-1-git-send-email-thomas.petazzoni@free-electrons.com>
	<1352818843-4457-3-git-send-email-thomas.petazzoni@free-electrons.com>
	<20121113231248.GA30391@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Lennert Buytenhek <kernel@wantstofly.org>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Dmitri Epshtein <dima@marvell.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([88.190.12.23]:60929 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422942Ab2KNOEW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 09:04:22 -0500
In-Reply-To: <20121113231248.GA30391@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois,

Thanks again for your detailed review. I have a few comments/questions
below.

On Wed, 14 Nov 2012 00:12:48 +0100, Francois Romieu wrote:
> Thomas Petazzoni <thomas.petazzoni@free-electrons.com> :
> [...]
> > +static int mvneta_mac_addr_set(struct mvneta_port *pp, unsigned
> > char *addr,
> > +			       int queue)
> > +{
> > +	unsigned int mac_h;
> > +	unsigned int mac_l;
> > +
> > +	if (queue >= 1) {
> > +		netdev_err(pp->dev, "RX queue #%d is out of
> > range\n", queue);
> > +		return -EINVAL;
> > +	}
> 
> (whence q <= 0)

After changing the code as per your below comments, I have removed this
check.

> > +
> > +	if (queue != -1) {
> > +		mac_l = (addr[4] << 8) | (addr[5]);
> > +		mac_h = (addr[0] << 24) | (addr[1] << 16) |
> > +			(addr[2] << 8) | (addr[3] << 0);
> > +
> > +		mvreg_write(pp, MVNETA_MAC_ADDR_LOW, mac_l);
> > +		mvreg_write(pp, MVNETA_MAC_ADDR_HIGH, mac_h);
> > +	}
> 
> What is it trying to achieve with the "queue" argument ?

Basically: queue == -1 is a special value to say "I want to discard the
entries in the ucast table". It's used when switching from one MAC
address to another: we remove the old entries by specifying queue=-1,
and then add the new entries by specifying queue=0.

The thing is that the driver does not yet support the multiqueue
aspects of the device, but since many registers have queue-related
aspects, we still have to worry about queues a little bit in the
driver. Complete multiqueue support is planned as a second step.

> [...]
> > +/* Refill processing */
> > +static int mvneta_rx_refill(struct mvneta_port *pp,
> > +			    struct mvneta_rx_desc *rx_desc)
> > +
> > +{
> > +	dma_addr_t phys_addr;
> > +	struct sk_buff *skb;
> > +
> > +	skb = netdev_alloc_skb(pp->dev, pp->pkt_size);
> > +	if (!skb)
> > +		return -ENOMEM;
> 
> Could netdev_alloc_skb_ip_align be an option ?

If I'm correct netdev_alloc_skb_ip_align() automatically reserve the
two bytes at the beginning of the Ethernet header to ensure that the IP
header will be aligned.

However, with the Marvell hardware, it isn't needed: the hardware
automatically pads with two empty bytes in the receiving RX buffer
before putting the real data (Ethernet header).

> [...]
> > +static int mvneta_rx(struct mvneta_port *pp, int rx_todo,
> > +		     struct mvneta_rx_queue *rxq)
> > +{
> > +	struct net_device *dev = pp->dev;
> > +	int rx_done, rx_filled;
> > +
> > +	/* Get number of received packets */
> > +	rx_done = mvneta_rxq_busy_desc_num_get(pp, rxq);
> > +
> > +	if (rx_todo > rx_done)
> > +		rx_todo = rx_done;
> > +
> > +	rx_done = 0;
> > +	rx_filled = 0;
> > +
> > +	/* Fairness NAPI loop */
> > +	while (rx_done < rx_todo) {
> > +		struct mvneta_rx_desc *rx_desc =
> > mvneta_rxq_next_desc_get(rxq);
> > +		struct sk_buff *skb;
> > +		u32 rx_status;
> > +		int rx_bytes, err;
> > +
> > +		prefetch(rx_desc);
> > +		rx_done++;
> > +		rx_filled++;
> > +		rx_status = rx_desc->status;
> > +		skb = (struct sk_buff *)rx_desc->buf_cookie;
> > +
> > +		if (!mvneta_rxq_desc_is_first_last(rx_desc) ||
> > +		    (rx_status & MVNETA_RXD_ERR_SUMMARY)) {
> > +			dev->stats.rx_errors++;
> > +			mvneta_rx_error(pp, rx_desc);
> > +			mvneta_rx_desc_fill(rx_desc,
> > rx_desc->buf_phys_addr,
> > +					    (u32)skb);
> > +			continue;
> > +		}
> > +
> > +		dma_unmap_single(pp->dev->dev.parent,
> > rx_desc->buf_phys_addr,
> > +				 rx_desc->data_size,
> > DMA_FROM_DEVICE); +
> > +		rx_bytes = rx_desc->data_size -
> > +			(MVNETA_ETH_CRC_SIZE + MVNETA_MH_SIZE);
> > +		u64_stats_update_begin(&pp->rx_stats.syncp);
> > +		pp->rx_stats.packets++;
> > +		pp->rx_stats.bytes += rx_bytes;
> > +		u64_stats_update_end(&pp->rx_stats.syncp);
> > +
> > +		/* Linux processing */
> > +		skb_reserve(skb, MVNETA_MH_SIZE);
> > +		skb_put(skb, rx_bytes);
> 
> (I suggested to use skb_reserve / skb_put instead of hand-crafted
> code but I may have ignored the elephant in the living room)
> 
> I understand the skb_put, ok. What is the purpose of the skb_reserve ?

As explained above, to skip the starting 2 bytes filled with zeroes by
the Marvell hardware, before passing the SKB up to the networking stack.

> Are MVNETA_ETH_CRC_SIZE (4) and MVNETA_MH_SIZE (2) really different
> from ETH_FCS_LEN and NET_IP_ALIGN ?

I have replaced MVNETA_ETH_CRC_SIZE with ETH_FCS_LEN since they are
indeed the same. However, I am not sure using NET_IP_ALIGN directly
instead of MVNETA_MH_SIZE is correct: the Marvell Header (MH) is always
two bytes: those two bytes are filled with zeroes in the normal case,
or otherwise they are used for some custom interaction between the
Marvell Ethernet controller and specific Marvell switches (this
feature is not supported by the driver being submitted). On the other
hand, the NET_IP_ALIGN value is not necessarily zero apparently, so I
have the feeling that those things should remain two separate values.

> > +	if (napi_schedule_prep(&pp->napi))
> > +		__napi_schedule(&pp->napi);
> 
> Hand-crafted napi_schedule.

Agreed, fixed.

> > +	ret = mvneta_mac_addr_set(pp, dev->dev_addr, rxq_def);
> > +	if (ret < 0) {
> > +		netdev_err(dev, "mvneta_mac_addr_set failed\n");
> > +		goto mac_addr_set_failure;
> > +	}
> 
> AFAIU mvneta_mac_addr_set can only fail when (module parameter)
> rxq_def is not set correctly. It imho calls for a check in
> probe/remove and a removal of the failure case in mvneta_mac_addr_set.

Good point, fixed.

> > +	/* Connect to port interrupt line */
> > +	ret = request_irq(pp->dev->irq, mvneta_isr, IRQF_DISABLED,
> > +			  MVNETA_DRIVER_NAME, pp);
> 
> include/linux/interrupt.h
> [...]
>  * IRQF_DISABLED - keep irqs disabled when calling the action handler.
>  *                 DEPRECATED. This flag is a NOOP and scheduled to
> be removed

Fixed.

> > +	if (mvneta_init(pp, phy_addr)) {
> > +		dev_err(&pdev->dev, "can't init eth hal\n");
> > +		err = -ENODEV;
> > +		goto err_base;
> > +	}
> 
> The error code from mvneta_init() should be used.

Fixed.

> > +	if (register_netdev(dev)) {
> > +		dev_err(&pdev->dev, "failed to register\n");
> > +		err = ENOMEM;
> > +		goto err_base;
> > +	}
> 
> - The error code from register_netdev() should be used.
> - Leak: allocations in mvneta_init() are not balanced.
> - Nit: the "err_where_did_it_trigger_first" style of label shows its
>   downside when compared to the "err_what_should_be_done" when
>   it gets used several times.

Fixed.

> > +/* Device removal routine */
> > +static int __devexit mvneta_remove(struct platform_device *pdev)
> > +{
> > +	struct net_device  *dev = platform_get_drvdata(pdev);
> > +	struct mvneta_port *pp = netdev_priv(dev);
> > +
> > +	iounmap(pp->base);
> > +
> > +	unregister_netdev(dev);
> > +	irq_dispose_mapping(dev->irq);
> > +	free_netdev(dev);
> > +	mvneta_deinit(pp);
> 
> One may expect the same ordering as the mvneta_probe unroll sequence.

Fixed as well!

Thanks,

Thomas
-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
