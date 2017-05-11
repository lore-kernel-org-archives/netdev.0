From: Lino Sanfilippo <LinoSanfilippo-Mmb7MZpHnFY@public.gmane.org>
Subject: Re: [PATCH v5 17/17] net: qualcomm: add QCA7000 UART driver
Date: Thu, 11 May 2017 23:58:31 +0200
Message-ID: <f39d7b94-ef8e-986e-710f-6d9524978f4d@gmx.de>
References: <1494406408-31760-1-git-send-email-stefan.wahren@i2se.com>
 <1494406408-31760-18-git-send-email-stefan.wahren@i2se.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
        Jiri Slaby <jslaby-IBi9RG/b67k@public.gmane.org>, linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Stefan Wahren <stefan.wahren-eS4NqCHxEME@public.gmane.org>,
        Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1494406408-31760-18-git-send-email-stefan.wahren-eS4NqCHxEME@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

On 10.05.2017 10:53, Stefan Wahren wrote:

> +static int qcauart_netdev_init(struct net_device *dev)
> +{
> +	struct qcauart *qca = netdev_priv(dev);
> +	size_t len;
> +
> +	/* Finish setting up the device info. */
> +	dev->mtu = QCAFRM_MAX_MTU;
> +	dev->type = ARPHRD_ETHER;
> +
> +	qca->rx_skb = netdev_alloc_skb_ip_align(qca->net_dev,
> +						qca->net_dev->mtu +
> +						VLAN_ETH_HLEN);
> +	if (!qca->rx_skb)
> +		return -ENOBUFS;
> +
> +	len = QCAFRM_HEADER_LEN + QCAFRM_MAX_LEN + QCAFRM_FOOTER_LEN;
> +	qca->tx_buffer = kmalloc(len, GFP_KERNEL);
> +	if (!qca->tx_buffer)
> +		return -ENOBUFS;

Freeing the rx_skb is missing here.

> +
> +static void qcauart_netdev_setup(struct net_device *dev)
> +{
> +	struct qcauart *qca;
> +
> +	dev->netdev_ops = &qcauart_netdev_ops;
> +	dev->watchdog_timeo = QCAUART_TX_TIMEOUT;
> +	dev->priv_flags &= ~IFF_TX_SKB_SHARING;
> +	dev->tx_queue_len = 100;
> +
> +	/* MTU range: 46 - 1500 */
> +	dev->min_mtu = QCAFRM_MIN_MTU;
> +	dev->max_mtu = QCAFRM_MAX_MTU;
> +
> +	qca = netdev_priv(dev);
> +	memset(qca, 0, sizeof(struct qcauart));

Zeroing the private data is not necessary since it is already done
at device allocation.


> +
> +static int qca_uart_probe(struct serdev_device *serdev)
> +{
> +	struct net_device *qcauart_dev = alloc_etherdev(sizeof(struct qcauart));
> +	struct qcauart *qca;
> +	const char *mac;
> +	u32 speed = 115200;
> +	int ret;
> +
> +	if (!qcauart_dev)
> +		return -ENOMEM;
> +
> +	qcauart_netdev_setup(qcauart_dev);
> +
> +	qca = netdev_priv(qcauart_dev);
> +	if (!qca) {
> +		pr_err("qca_uart: Fail to retrieve private structure\n");
> +		ret = -ENOMEM;
> +		goto free;
> +	}
> +	qca->net_dev = qcauart_dev;
> +	qca->serdev = serdev;
> +	qcafrm_fsm_init_uart(&qca->frm_handle);
> +
> +	spin_lock_init(&qca->lock);
> +	INIT_WORK(&qca->tx_work, qcauart_transmit);
> +
> +	of_property_read_u32(serdev->dev.of_node, "current-speed", &speed);
> +
> +	mac = of_get_mac_address(serdev->dev.of_node);
> +
> +	if (mac)
> +		ether_addr_copy(qca->net_dev->dev_addr, mac);
> +
> +	if (!is_valid_ether_addr(qca->net_dev->dev_addr)) {
> +		eth_hw_addr_random(qca->net_dev);
> +		dev_info(&serdev->dev, "Using random MAC address: %pM\n",
> +			 qca->net_dev->dev_addr);
> +	}
> +
> +	netif_carrier_on(qca->net_dev);
> +	serdev_device_set_drvdata(serdev, qca);
> +	serdev_device_set_client_ops(serdev, &qca_serdev_ops);
> +
> +	ret = serdev_device_open(serdev);
> +	if (ret) {
> +		dev_err(&serdev->dev, "Unable to open device %s\n",
> +			qcauart_dev->name);
> +		goto free;
> +	}
> +
> +	speed = serdev_device_set_baudrate(serdev, speed);
> +	dev_info(&serdev->dev, "Using baudrate: %u\n", speed);
> +
> +	serdev_device_set_flow_control(serdev, false);
> +
> +	ret = register_netdev(qcauart_dev);
> +	if (ret) {
> +		dev_err(&serdev->dev, "Unable to register net device %s\n",
> +			qcauart_dev->name);

	serdev_device_close() ?

> +		goto free;
> +	}
> +
> +	return 0;
> +
> +free:
> +	free_netdev(qcauart_dev);
> +	return ret;
> +}
> +
> +static void qca_uart_remove(struct serdev_device *serdev)
> +{
> +	struct qcauart *qca = serdev_device_get_drvdata(serdev);

	Here you should make sure that the tx_work is not running/pending any
	more (e.g by calling cancel_delayed_work_sync()).

> +	/* Flush any pending characters in the driver. */
> +	serdev_device_close(serdev);
> +
> +	netif_carrier_off(qca->net_dev);
> +	unregister_netdev(qca->net_dev);
> +	free_netdev(qca->net_dev);
> +}

Regards,
Lino

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
