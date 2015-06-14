From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v4] NET: Add ezchip ethernet driver
Date: Sun, 14 Jun 2015 13:25:44 -0700
Message-ID: <557DE348.2030105@gmail.com>
References: <1434044505-13327-1-git-send-email-noamc@ezchip.com> <1434263193-16877-1-git-send-email-noamc@ezchip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey.Brodkin@synopsys.com, vgupta@synopsys.com,
	giladb@ezchip.com, cmetcalf@ezchip.com,
	Tal Zilcer <talz@ezchip.com>
To: Noam Camus <noamc@ezchip.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:32829 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751060AbbFNUZq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Jun 2015 16:25:46 -0400
In-Reply-To: <1434263193-16877-1-git-send-email-noamc@ezchip.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 06/13/15 23:26, Noam Camus a =C3=A9crit :
> From: Noam Camus <noamc@ezchip.com>
>=20
> Simple LAN device for debug or management purposes.
> Device supports interrupts for RX and TX(completion).
> Device does not have DMA ability.
>=20
> Signed-off-by: Noam Camus <noamc@ezchip.com>
> Signed-off-by: Tal Zilcer <talz@ezchip.com>
> Acked-by: Alexey Brodkin <abrodkin@synopsys.com>
> ---
> +	/* copy last bytes (if any) */
> +	if (last) {
> +		u32 buf =3D nps_enet_reg_get(priv, NPS_ENET_REG_RX_BUF);
> +
> +		memcpy(reg, &buf, last);

memcpy_fromio() for this entire function?

> +	}
> +}
> +
> +static void nps_enet_rx_handler(struct net_device *ndev)
> +{
> +	struct nps_enet_priv *priv =3D netdev_priv(ndev);
> +	struct sk_buff *skb =3D priv->irq_data.skb;
> +	struct nps_enet_rx_ctl rx_ctrl;
> +	u32 frame_len;
> +
> +	rx_ctrl.value =3D priv->irq_data.rx_ctrl.value;
> +	frame_len =3D rx_ctrl.nr;
> +	/* Check if we got RX */
> +	if (!rx_ctrl.cr)
> +		return;
> +
> +	ndev->stats.rx_packets++;
> +	ndev->stats.rx_bytes +=3D frame_len;
> +
> +	netif_receive_skb(skb);

Not sure why nps_enet_rx_handler here does not do most of the processin=
g
of what nps_enet_rx_prep() does, but see below:

> +}
> +
> +static s32 nps_enet_rx_prep(struct net_device *ndev)
> +{
> +	struct nps_enet_priv *priv =3D netdev_priv(ndev);
> +	struct sk_buff *skb;
> +	struct nps_enet_rx_ctl rx_ctrl;
> +	u32 frame_len, err =3D 0;
> +	s32 ret =3D 0;

You do not seem to be propagating anything different than 1 or 0, does
that need to be signed?

> +
> +	rx_ctrl.value =3D nps_enet_reg_get(priv, NPS_ENET_REG_RX_CTL);
> +	frame_len =3D rx_ctrl.nr;
> +
> +	/* Check if we got RX */
> +	if (!rx_ctrl.cr) {
> +		priv->irq_data.rx_ctrl.value =3D 0;
> +		return ret;
> +	}
> +
> +	/* Check Rx error */
> +	if (rx_ctrl.er) {
> +		ndev->stats.rx_errors++;
> +		err =3D 1;
> +	}
> +
> +	/* Check Rx CRC error */
> +	if (rx_ctrl.crc) {
> +		ndev->stats.rx_crc_errors++;
> +		ndev->stats.rx_dropped++;
> +		err =3D 1;
> +	}
> +
> +	/* Check Frame length Min 64b */
> +	if (unlikely(frame_len < ETH_ZLEN)) {
> +		ndev->stats.rx_length_errors++;
> +		ndev->stats.rx_dropped++;
> +		err =3D 1;
> +	}
> +
> +	if (err)
> +		goto rx_irq_clean;

Ok, so ret =3D 0 means errors and ret =3D 1 means success, that is pret=
ty
counter intuititive to what other parts of the kernel do.

> +
> +	/* Skb allocation */
> +	skb =3D netdev_alloc_skb_ip_align(ndev, frame_len);
> +	if (unlikely(!skb)) {
> +		ndev->stats.rx_errors++;
> +		ndev->stats.rx_dropped++;
> +		goto rx_irq_clean;
> +	}
> +
> +	/* Copy frame from Rx fifo into the skb */
> +	nps_enet_read_rx_fifo(ndev, skb->data, frame_len);
> +
> +	skb_put(skb, frame_len);
> +	skb->dev =3D ndev;

eth_type_trans does that assignement for you already.

> +	skb->protocol =3D eth_type_trans(skb, ndev);
> +	skb->ip_summed =3D CHECKSUM_UNNECESSARY;
> +
> +	priv->irq_data.skb =3D skb;
> +	priv->irq_data.rx_ctrl.value =3D rx_ctrl.value;

So you are retaining the SKB here, called from hard interrupt context
and only processing it in nps_enet_rx_handler(), is there a particular
reason why you are not storing the rx_ctrl status word in top-half and
processing the SKB in bottom-half entirely instead? This needs to be
documented in your driver design.

> +	ret =3D 1;
> +	goto rx_irq_frame_done;
> +
> +rx_irq_clean:
> +	/* Clean Rx fifo */
> +	nps_enet_clean_rx_fifo(ndev, frame_len);
> +	priv->irq_data.rx_ctrl.value =3D 0;
> +
> +rx_irq_frame_done:
> +	/* Ack Rx ctrl register */
> +	nps_enet_reg_set(priv, NPS_ENET_REG_RX_CTL, 0);
> +
> +	return ret;
> +}
> +
> +static void nps_enet_tx_handler(struct net_device *ndev)
> +{
> +	struct nps_enet_priv *priv =3D netdev_priv(ndev);
> +	struct nps_enet_tx_ctl tx_ctrl;
> +
> +	tx_ctrl.value =3D priv->irq_data.tx_ctrl.value;
> +	/* Check if we got TX */
> +	if (!priv->tx_packet_sent || tx_ctrl.ct)
> +		return;
> +
> +	/* Check Tx transmit error */
> +	if (unlikely(tx_ctrl.et)) {
> +		ndev->stats.tx_errors++;
> +	} else {
> +		ndev->stats.tx_packets++;
> +		ndev->stats.tx_bytes +=3D tx_ctrl.nt;
> +	}
> +
> +	/* In nps_enet_start_xmit we disabled sending frames*/
> +	netif_wake_queue(ndev);

You might want to explain why this is safe to do here, presumably since
this seems to be a FIFO with a single entry (is that the case?) you can
do that as soon as you get the TX completion interrupt, but this needs
to be documented.

> +
> +	priv->tx_packet_sent =3D false;
> +}
> +
> +static s32 nps_enet_tx_prep(struct net_device *ndev)
> +{
> +	struct nps_enet_priv *priv =3D netdev_priv(ndev);
> +	struct nps_enet_tx_ctl tx_ctrl;
> +	s32 ret =3D 0;
> +
> +	tx_ctrl.value =3D nps_enet_reg_get(priv, NPS_ENET_REG_TX_CTL);
> +	if (!tx_ctrl.ct && priv->tx_packet_sent) {
> +		/* Ack Tx ctrl register */
> +		nps_enet_reg_set(priv, NPS_ENET_REG_TX_CTL, 0);
> +		priv->irq_data.tx_ctrl.value =3D tx_ctrl.value;
> +		ret =3D 1;
> +	} else {
> +		priv->irq_data.tx_ctrl.value =3D 0;
> +	}
> +
> +	return ret;
> +}
> +
> +static s32 nps_enet_prep(struct net_device *ndev)
> +{
> +	s32 ret =3D 0;
> +
> +	ret |=3D nps_enet_tx_prep(ndev);
> +	ret |=3D nps_enet_rx_prep(ndev);

Ok, now it is a little clearer why these two functions return 0 for
error/nothing than 1, these should probably be named something like
nps_enet_tx_has_work() or something like that.

> +
> +	return ret;
> +}
> +
> +/**
> + * nps_enet_poll - NAPI poll handler.
> + * @napi:       Pointer to napi_struct structure.
> + * @budget:     How many frames to process on 1 call.
> + *
> + * returns:     Number of processed frames
> + */
> +static int nps_enet_poll(struct napi_struct *napi, int budget)
> +{
> +	struct net_device *ndev =3D napi->dev;
> +	struct nps_enet_priv *priv =3D netdev_priv(ndev);
> +	struct nps_enet_buf_int_enable buf_int_enable =3D {
> +		.rx_rdy =3D NPS_ENET_ENABLE,
> +		.tx_done =3D NPS_ENET_ENABLE,};
> +
> +	nps_enet_tx_handler(ndev);
> +	nps_enet_rx_handler(ndev);
> +	napi_complete(napi);

That is not so simple, tx_handler should not be bounded to a particular
budget, however your RX handlers should not exceed bugdet. If you
process less than budget, you can go ahead and call napi_complete to
exit ->poll() if not, then you need to poll again the RX queue for more
packets.

If you only have a capacity of one oustanding packet in your FIFO, you
would want to adjust your budget accordingly.

> +	nps_enet_reg_set(priv, NPS_ENET_REG_BUF_INT_ENABLE,
> +			 buf_int_enable.value);
> +
> +	return budget;
> +}
> +

[snip]

> +/**
> + * nps_enet_start_xmit - Starts the data transmission.
> + * @skb:        sk_buff pointer that contains data to be Transmitted=
=2E
> + * @ndev:       Pointer to net_device structure.
> + *
> + * returns: NETDEV_TX_OK, on success
> + *              NETDEV_TX_BUSY, if any of the descriptors are not fr=
ee.
> + *
> + * This function is invoked from upper layers to initiate transmissi=
on.
> + */
> +static netdev_tx_t nps_enet_start_xmit(struct sk_buff *skb,
> +				       struct net_device *ndev)
> +{
> +	/* This driver handles one frame at a time  */
> +	netif_stop_queue(ndev);
> +
> +	nps_enet_send_frame(ndev, skb);
> +
> +	dev_kfree_skb(skb);

You do have a TX completion handler, so you should not be freeing the
SKB just now, instead you should retain a reference to it, limit to onl=
y
how many outstanding transmits as allowed by your hardware, and call
dev_kfree_skb() in your tx_handler() instead. Here you are lying to the
networking stack by telling it earlier than you should that the packet
has been transmitted.

> +
> +	return NETDEV_TX_OK;
> +}
> +
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +static void nps_enet_poll_controller(struct net_device *ndev)
> +{
> +	disable_irq(ndev->irq);
> +	nps_enet_board_irq_handler(ndev->irq, ndev);
> +	enable_irq(ndev->irq);
> +}
> +#endif
> +
> +static const struct net_device_ops nps_netdev_ops =3D {
> +	.ndo_open		=3D nps_enet_open,
> +	.ndo_stop		=3D nps_enet_stop,
> +	.ndo_start_xmit		=3D nps_enet_start_xmit,
> +	.ndo_set_mac_address	=3D nps_enet_set_mac_address,
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +	.ndo_poll_controller	=3D nps_enet_poll_controller,
> +#endif

No set_rx_mode callback implemented at all?

> +};
> +
> +static s32 nps_enet_probe(struct platform_device *pdev)
> +{
> +	struct device *dev =3D &pdev->dev;
> +	struct net_device *ndev;
> +	struct nps_enet_priv *priv;
> +	s32 err =3D 0;
> +	const char *mac_addr;
> +	struct resource res_regs;
> +
> +	if (!dev->of_node)
> +		return -ENODEV;
> +
> +	ndev =3D alloc_etherdev(sizeof(struct nps_enet_priv));
> +	if (!ndev)
> +		return -ENOMEM;
> +
> +	platform_set_drvdata(pdev, ndev);
> +	SET_NETDEV_DEV(ndev, dev);
> +	priv =3D netdev_priv(ndev);
> +
> +	/* Get ENET registers base address from device tree */
> +	err =3D of_address_to_resource(dev->of_node, 0, &res_regs);
> +	if (err) {
> +		dev_err(dev, "failed to retrieve registers base from device tree\n=
");
> +		err =3D -ENODEV;
> +		goto out_netdev;
> +	}

You could do platform_get_resource() here and save a check against this=
,
since devm_ioremap_resource() already checks for the resource pointer
correctness.

> +
> +	/* The EZ NET specific entries in the device structure. */
> +	ndev->netdev_ops =3D &nps_netdev_ops;
> +	ndev->watchdog_timeo =3D (400 * HZ / 1000);
> +	ndev->flags &=3D ~IFF_MULTICAST;

Since you are disabling multicast at the hardware level, it still seems
like this is something that could be fixed in the future by properly
adding support for this, even though that means filtering mutlicast
groups entirely in software.

> +
> +	priv->regs_base =3D devm_ioremap_resource(dev, &res_regs);
> +	if (IS_ERR(priv->regs_base)) {
> +		err =3D PTR_ERR(priv->regs_base);
> +		goto out_netdev;
> +	}
> +	dev_dbg(dev, "Registers base address is 0x%p\n", priv->regs_base);
> +
> +	/* set kernel MAC address to dev */
> +	mac_addr =3D of_get_mac_address(dev->of_node);
> +	if (mac_addr)
> +		ether_addr_copy(ndev->dev_addr, mac_addr);
> +	else
> +		eth_hw_addr_random(ndev);
> +
> +	/* Get IRQ number from device tree */
> +	priv->irq =3D irq_of_parse_and_map(dev->of_node, 0);
> +	if (!priv->irq) {
> +		dev_err(dev, "failed to retrieve <irq Rx-Tx> value from device tre=
e\n");
> +		err =3D -ENODEV;
> +		goto out_netdev;
> +	}

platform_get_irq() is a little shorter and friendlier towards non-DT
platforms (just in case).

> +
> +	netif_napi_add(ndev, &priv->napi, nps_enet_poll, NAPI_POLL_WEIGHT);
> +
> +	/* Register the driver. Should be the last thing in probe */
> +	err =3D register_netdev(ndev);
> +	if (err) {
> +		dev_err(dev, "Failed to register ndev for %s, err =3D 0x%08x\n",
> +			ndev->name, (s32)err);
> +		err =3D -ENODEV;
> +		goto out_netif_api;
> +	}
> +
> +	dev_info(dev, "(rx/tx=3D%d)\n", priv->irq);

You are still taking an error path here, you probably want to return
here with 0.

> +
> +out_netif_api:
> +	netif_napi_del(&priv->napi);
> +out_netdev:
> +	if (err)
> +		free_netdev(ndev);
> +
> +	return 0;
> +}

--=20
=46lorian
