From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH v2] can: kvaser_usb: Add support for Kvaser CAN/USB devices
Date: Mon, 06 Aug 2012 10:10:43 +0200
Message-ID: <1377311.1NXjxk1Tbx@linux-lqwf.site>
References: <1343626352-24760-1-git-send-email-olivier@sobrie.be> <1344230489-16595-1-git-send-email-olivier@sobrie.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	linux-can@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Olivier Sobrie <olivier@sobrie.be>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1344230489-16595-1-git-send-email-olivier@sobrie.be>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 06 August 2012 07:21:29 Olivier Sobrie wrote:
> This driver provides support for several Kvaser CAN/USB devices.
> Such kind of devices supports up to three can network interfaces.
> 
> It has been tested with a Kvaser USB Leaf Light (one network interface)
> connected to a pch_can interface.
> The firmware version of the Kvaser device was 2.5.205.

> +static netdev_tx_t kvaser_usb_start_xmit(struct sk_buff *skb,
> +					 struct net_device *netdev)
> +{
> +	struct kvaser_usb_net_priv *priv = netdev_priv(netdev);
> +	struct kvaser_usb *dev = priv->dev;
> +	struct net_device_stats *stats = &netdev->stats;
> +	struct can_frame *cf = (struct can_frame *)skb->data;
> +	struct kvaser_usb_tx_urb_context *context = NULL;
> +	struct urb *urb;
> +	void *buf;
> +	struct kvaser_msg *msg;
> +	int i, err;
> +	int ret = NETDEV_TX_OK;
> +
> +	if (can_dropped_invalid_skb(netdev, skb))
> +		return NETDEV_TX_OK;
> +
> +	urb = usb_alloc_urb(0, GFP_ATOMIC);
> +	if (!urb) {
> +		netdev_err(netdev, "No memory left for URBs\n");
> +		stats->tx_dropped++;
> +		dev_kfree_skb(skb);
> +		return NETDEV_TX_OK;
> +	}
> +
> +	buf = usb_alloc_coherent(dev->udev, sizeof(struct kvaser_msg),
> +				 GFP_ATOMIC, &urb->transfer_dma);

usb_alloc_coherent() as a rule only makes sense if you reuse the buffer
and in some cases not even then. Please use a simple kmalloc()

> +	if (!buf) {
> +		netdev_err(netdev, "No memory left for USB buffer\n");
> +		stats->tx_dropped++;
> +		dev_kfree_skb(skb);
> +		goto nobufmem;
> +	}
> +
> +	msg = (struct kvaser_msg *)buf;
> +	msg->len = MSG_HEADER_LEN + sizeof(struct kvaser_msg_tx_can);
> +	msg->u.tx_can.flags = 0;
> +	msg->u.tx_can.channel = priv->channel;
> +
> +	if (cf->can_id & CAN_EFF_FLAG) {
> +		msg->id = CMD_TX_EXT_MESSAGE;
> +		msg->u.tx_can.msg[0] = (cf->can_id >> 24) & 0x1f;
> +		msg->u.tx_can.msg[1] = (cf->can_id >> 18) & 0x3f;
> +		msg->u.tx_can.msg[2] = (cf->can_id >> 14) & 0x0f;
> +		msg->u.tx_can.msg[3] = (cf->can_id >> 6) & 0xff;
> +		msg->u.tx_can.msg[4] = cf->can_id & 0x3f;
> +	} else {
> +		msg->id = CMD_TX_STD_MESSAGE;
> +		msg->u.tx_can.msg[0] = (cf->can_id >> 6) & 0x1f;
> +		msg->u.tx_can.msg[1] = cf->can_id & 0x3f;
> +	}
> +
> +	msg->u.tx_can.msg[5] = cf->can_dlc;
> +	memcpy(&msg->u.tx_can.msg[6], cf->data, cf->can_dlc);
> +
> +	if (cf->can_id & CAN_RTR_FLAG)
> +		msg->u.tx_can.flags |= MSG_FLAG_REMOTE_FRAME;
> +
> +	for (i = 0; i < ARRAY_SIZE(priv->tx_contexts); i++) {
> +		if (priv->tx_contexts[i].echo_index == MAX_TX_URBS) {
> +			context = &priv->tx_contexts[i];
> +			break;
> +		}
> +	}
> +
> +	if (!context) {
> +		netdev_warn(netdev, "cannot find free context\n");
> +		ret =  NETDEV_TX_BUSY;
> +		goto releasebuf;
> +	}
> +
> +	context->priv = priv;
> +	context->echo_index = i;
> +	context->dlc = cf->can_dlc;
> +
> +	msg->u.tx_can.tid = context->echo_index;
> +
> +	usb_fill_bulk_urb(urb, dev->udev,
> +			  usb_sndbulkpipe(dev->udev,
> +					  dev->bulk_out->bEndpointAddress),
> +			  buf, msg->len,
> +			  kvaser_usb_write_bulk_callback, context);
> +	urb->transfer_flags |= URB_NO_TRANSFER_DMA_MAP;
> +	usb_anchor_urb(urb, &priv->tx_submitted);
> +
> +	can_put_echo_skb(skb, netdev, context->echo_index);
> +
> +	atomic_inc(&priv->active_tx_urbs);
> +
> +	if (atomic_read(&priv->active_tx_urbs) >= MAX_TX_URBS)
> +		netif_stop_queue(netdev);
> +
> +	err = usb_submit_urb(urb, GFP_ATOMIC);
> +	if (unlikely(err)) {
> +		can_free_echo_skb(netdev, context->echo_index);
> +
> +		atomic_dec(&priv->active_tx_urbs);
> +		usb_unanchor_urb(urb);
> +
> +		stats->tx_dropped++;
> +
> +		if (err == -ENODEV)
> +			netif_device_detach(netdev);
> +		else
> +			netdev_warn(netdev, "Failed tx_urb %d\n", err);
> +
> +		goto releasebuf;
> +	}
> +
> +	netdev->trans_start = jiffies;
> +
> +	usb_free_urb(urb);
> +
> +	return NETDEV_TX_OK;
> +
> +releasebuf:
> +	usb_free_coherent(dev->udev, sizeof(struct kvaser_msg),
> +			  buf, urb->transfer_dma);
> +nobufmem:
> +	usb_free_urb(urb);
> +	return ret;
> +}

> +static int kvaser_usb_init_one(struct usb_interface *intf,
> +			       const struct usb_device_id *id, int channel)
> +{
> +	struct kvaser_usb *dev = usb_get_intfdata(intf);
> +	struct net_device *netdev;
> +	struct kvaser_usb_net_priv *priv;
> +	int i, err;
> +
> +	netdev = alloc_candev(sizeof(*priv), MAX_TX_URBS);
> +	if (!netdev) {
> +		dev_err(&intf->dev, "Cannot alloc candev\n");
> +		return -ENOMEM;
> +	}
> +
> +	priv = netdev_priv(netdev);
> +
> +	init_completion(&priv->start_comp);
> +	init_completion(&priv->stop_comp);
> +
> +	init_usb_anchor(&priv->tx_submitted);
> +	atomic_set(&priv->active_tx_urbs, 0);
> +
> +	for (i = 0; i < ARRAY_SIZE(priv->tx_contexts); i++)
> +		priv->tx_contexts[i].echo_index = MAX_TX_URBS;
> +
> +	priv->dev = dev;
> +	priv->netdev = netdev;
> +	priv->channel = channel;
> +
> +	priv->can.state = CAN_STATE_STOPPED;
> +	priv->can.clock.freq = CAN_USB_CLOCK;
> +	priv->can.bittiming_const = &kvaser_usb_bittiming_const;
> +	priv->can.do_set_bittiming = kvaser_usb_set_bittiming;
> +	priv->can.do_set_mode = kvaser_usb_set_mode;
> +	priv->can.ctrlmode_supported = CAN_CTRLMODE_3_SAMPLES;
> +	if (id->driver_info & KVASER_HAS_SILENT_MODE)
> +		priv->can.ctrlmode_supported |= CAN_CTRLMODE_LISTENONLY;
> +
> +	netdev->flags |= IFF_ECHO;
> +
> +	netdev->netdev_ops = &kvaser_usb_netdev_ops;
> +
> +	SET_NETDEV_DEV(netdev, &intf->dev);
> +
> +	err = register_candev(netdev);
> +	if (err) {
> +		dev_err(&intf->dev, "Failed to register can device\n");
> +		free_candev(netdev);
> +		return err;
> +	}
> +

Here the device is usable.

> +	dev->nets[channel] = priv;

And only know you init this field. Looks like a race condition.

> +	netdev_dbg(netdev, "device registered\n");
> +
> +	return 0;
> +}
> +

> +static void kvaser_usb_disconnect(struct usb_interface *intf)
> +{
> +	struct kvaser_usb *dev = usb_get_intfdata(intf);
> +	int i;
> +
> +	usb_set_intfdata(intf, NULL);
> +
> +	if (!dev)
> +		return;
> +
> +	for (i = 0; i < dev->nchannels; i++) {
> +		if (!dev->nets[i])
> +			continue;
> +
> +		unregister_netdev(dev->nets[i]->netdev);
> +		free_candev(dev->nets[i]->netdev);
> +	}
> +
> +	kvaser_usb_unlink_all_urbs(dev);

So what happens if an URB completes between freeing the candev
and unlinking and proceeds to push data to upper layers?

	Regards
		Oliver


