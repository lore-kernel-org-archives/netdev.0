From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH 2/2] ems_usb: Added support for EMS CPC-USB/ARM7 CAN/USB
 interface
Date: Tue, 15 Sep 2009 12:57:05 +0200
Message-ID: <4AAF7301.60608@grandegger.com>
References: <20090914080945.5441.45509.stgit@localhost.localdomain> <20090914082229.5441.16650.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org, oliver-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Sebastian Haas <haas-zsNKPWJ8Pib6hrUXjxyGrA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090914082229.5441.16650.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Sebastian,

Sebastian Haas wrote:
> This patch adds support for one channel CAN/USB interace CPC-USB/ARM7 from
> EMS Dr. Thomas Wuensche (http://www.ems-wuensche.com).
> 
> Signed-off-by: Sebastian Haas <haas-zsNKPWJ8Pib6hrUXjxyGrA@public.gmane.org>

The driver is almost OK from the Socket-CAN point of view. Just some
*final* nitpicking:

[snip]
> +static void ems_usb_read_interrupt_callback(struct urb *urb)
> +{
> +	struct ems_usb *dev = urb->context;
> +	struct net_device *netdev;
> +	int err;
> +
> +	netdev = dev->netdev;

Could be done in the declaration part above.

> +	if (!netif_device_present(netdev))
> +		return;
> +
> +	switch (urb->status) {
> +	case 0:
> +		dev->free_slots = dev->intr_in_buffer[1];
> +		break;
> +
> +	case -ECONNRESET: /* unlink */
> +	case -ENOENT:
> +	case -ESHUTDOWN:
> +		return;
> +
> +	default:
> +		dev_info(netdev->dev.parent, "Rx interrupt aborted %d\n",
> +			 urb->status);
> +		break;
> +	}
> +
> +	err = usb_submit_urb(urb, GFP_ATOMIC);
> +
> +	if (err == -ENODEV)
> +		netif_device_detach(netdev);
> +	else if (err)
> +		dev_err(netdev->dev.parent,
> +			"failed resubmitting intr urb: %d\n", err);
> +
> +	return;
> +}
> +
> +static void ems_usb_rx_can_msg(struct ems_usb *dev, struct ems_cpc_msg *msg)
> +{
> +	struct can_frame *cf;
> +	struct sk_buff *skb;
> +	int i;
> +	struct net_device_stats *stats = &dev->netdev->stats;
> +
> +	skb = dev_alloc_skb(sizeof(struct can_frame));

Please use netdev_alloc_skb() ...

> +	if (skb == NULL)
> +		return;
> +
> +	skb->dev = dev->netdev;

... making the line above obsolete.

> +	skb->protocol = htons(ETH_P_CAN);
> +
> +	cf = (struct can_frame *)skb_put(skb, sizeof(struct can_frame));
> +
> +	cf->can_id = msg->msg.can_msg.id;
> +	cf->can_dlc = min_t(u8, msg->msg.can_msg.length, 8);
> +
> +	if (msg->type == CPC_MSG_TYPE_EXT_CAN_FRAME
> +	    || msg->type == CPC_MSG_TYPE_EXT_RTR_FRAME)
> +		cf->can_id |= CAN_EFF_FLAG;
> +
> +	if (msg->type == CPC_MSG_TYPE_RTR_FRAME
> +	    || msg->type == CPC_MSG_TYPE_EXT_RTR_FRAME) {
> +		cf->can_id |= CAN_RTR_FLAG;
> +	} else {
> +		for (i = 0; i < cf->can_dlc; i++)
> +			cf->data[i] = msg->msg.can_msg.msg[i];
> +	}
> +
> +	netif_rx(skb);
> +
> +	dev->netdev->last_rx = jiffies;
> +	stats->rx_packets++;
> +	stats->rx_bytes += cf->can_dlc;
> +}
> +
> +static void ems_usb_rx_err(struct ems_usb *dev, struct ems_cpc_msg *msg)
> +{
> +	struct can_frame *cf;
> +	struct sk_buff *skb;
> +	struct net_device_stats *stats = &dev->netdev->stats;
> +
> +	skb = dev_alloc_skb(sizeof(struct can_frame));
> +	if (skb == NULL)
> +		return;
> +
> +	skb->dev = dev->netdev;

Ditto.

[snip]
> +static int ems_usb_start_xmit(struct sk_buff *skb, struct net_device *netdev)
> +{
> +	struct ems_usb *dev = netdev_priv(netdev);
> +	struct ems_tx_urb_context *context = NULL;
> +	struct net_device_stats *stats = &netdev->stats;
> +	struct can_frame *cf = (struct can_frame *)skb->data;
> +	struct ems_cpc_msg *msg;
> +	struct urb *urb;
> +	u8 *buf;
> +	int i, err;
> +	size_t size = CPC_HEADER_SIZE + CPC_MSG_HEADER_LEN
> +			+ sizeof(struct cpc_can_msg);
> +
> +	/* create a URB, and a buffer for it, and copy the data to the URB */
> +	urb = usb_alloc_urb(0, GFP_ATOMIC);
> +	if (!urb) {
> +		dev_err(netdev->dev.parent, "No memory left for URBs\n");
> +		goto nomem;
> +	}
> +
> +	buf = usb_buffer_alloc(dev->udev, size, GFP_ATOMIC, &urb->transfer_dma);
> +	if (!buf) {
> +		dev_err(netdev->dev.parent, "No memory left for USB buffer\n");
> +		usb_free_urb(urb);
> +		goto nomem;
> +	}
> +
> +	msg = (struct ems_cpc_msg *)&buf[CPC_HEADER_SIZE];
> +
> +	msg->msg.can_msg.id = cf->can_id & 0x1FFFFFFFU;

Please use CAN_ERR_MASK instead (even if the name is somehow
misleading). See http://lxr.linux.no/#linux+v2.6.31/include/linux/can.h#L31.

[snip]
> +}
> +
> +

Remove one empty line, please.

> +static void init_params_sja1000(struct ems_cpc_msg *msg)
> +{
> +	struct cpc_sja1000_params *sja1000 =
> +		&msg->msg.can_params.cc_params.sja1000;
> +
> +	msg->type = CPC_CMD_TYPE_CAN_PARAMS;
> +	msg->length = sizeof(struct cpc_can_params);
> +	msg->msgid = 0;
> +
> +	msg->msg.can_params.cc_type = CPC_CC_TYPE_SJA1000;
> +
> +	/* Acceptance filter open */
> +	sja1000->acc_code0 = 0x00;
> +	sja1000->acc_code1 = 0x00;
> +	sja1000->acc_code2 = 0x00;
> +	sja1000->acc_code3 = 0x00;
> +
> +	/* Acceptance filter open */
> +	sja1000->acc_mask0 = 0xFF;
> +	sja1000->acc_mask1 = 0xFF;
> +	sja1000->acc_mask2 = 0xFF;
> +	sja1000->acc_mask3 = 0xFF;
> +
> +	sja1000->btr0 = 0;
> +	sja1000->btr1 = 0;
> +
> +	sja1000->outp_contr = SJA1000_DEFAULT_OUTPUT_CONTROL;
> +	sja1000->mode = SJA1000_MOD_RM;
> +}
> +
> +/*
> + * probe function for new CPC-USB devices
> + */
> +static int ems_usb_probe(struct usb_interface *intf,
> +			 const struct usb_device_id *id)
> +{
> +	struct net_device *netdev;
> +	struct ems_usb *dev;
> +	int i, err;
> +
> +	netdev = alloc_candev(sizeof(struct ems_usb));
> +	if (!netdev) {
> +		dev_err(netdev->dev.parent, "Couldn't alloc candev\n");
> +		return -ENOMEM;
> +	}
> +
> +	dev = netdev_priv(netdev);
> +
> +	dev->udev = interface_to_usbdev(intf);
> +	dev->netdev = netdev;
> +
> +	dev->can.state = CAN_STATE_STOPPED;
> +	dev->can.bittiming_const = &ems_usb_bittiming_const;
> +	dev->can.do_set_bittiming = ems_usb_set_bittiming;
> +	dev->can.do_set_mode = ems_usb_set_mode;
> +
> +	netdev->flags |= IFF_ECHO; /* we support local echo */
> +
> +	/*
> +	 * The device actually uses a 16MHz clock to generate the CAN clock
> +	 * but it expects SJA1000 bit settings based on 8MHz (is internally
> +	 * converted).
> +	 */

Should go up to the macro definition.

> +	dev->can.clock.freq = EMS_USB_ARM7_CLOCK;
> +
> +	netdev->netdev_ops = &ems_usb_netdev_ops;
> +
> +	netdev->flags |= IFF_ECHO; /* we support local echo */
> +
> +	init_usb_anchor(&dev->rx_submitted);
> +
> +	init_usb_anchor(&dev->tx_submitted);
> +	atomic_set(&dev->active_tx_urbs, 0);
> +
> +	for (i = 0; i < MAX_TX_URBS; i++)
> +		dev->tx_contexts[i].echo_index = MAX_TX_URBS;
> +
> +	dev->intr_urb = usb_alloc_urb(0, GFP_KERNEL);
> +	if (!dev->intr_urb) {
> +		dev_err(netdev->dev.parent, "Couldn't alloc intr URB\n");
> +		free_candev(netdev);

Please use goto's for cleanup to avoid code duplication.

> +		return -ENOMEM;
> +	}
> +
> +	dev->intr_in_buffer = kzalloc(INTR_IN_BUFFER_SIZE, GFP_KERNEL);
> +	if (!dev->intr_in_buffer) {
> +		dev_err(netdev->dev.parent, "Couldn't alloc Intr buffer\n");
> +		free_candev(netdev);
> +		usb_free_urb(dev->intr_urb);
> +		return -ENOMEM;

Ditto.

> +	}
> +
> +	dev->tx_msg_buffer = kzalloc(CPC_HEADER_SIZE +
> +				     sizeof(struct ems_cpc_msg), GFP_KERNEL);
> +	if (!dev->tx_msg_buffer) {
> +		dev_err(netdev->dev.parent, "Couldn't alloc Tx buffer\n");
> +		free_candev(netdev);
> +		usb_free_urb(dev->intr_urb);
> +		kfree(dev->intr_in_buffer);
> +		return -ENOMEM;

Ditto.

> +	}
> +
> +	usb_set_intfdata(intf, dev);
> +
> +	SET_NETDEV_DEV(netdev, &intf->dev);
> +
> +	init_params_sja1000(&dev->active_params);
> +
> +	err = ems_usb_command_msg(dev, &dev->active_params);
> +	if (err) {
> +		dev_err(netdev->dev.parent,
> +			"couldn't initialize controller: %d\n", err);
> +		free_candev(netdev);
> +		usb_free_urb(dev->intr_urb);
> +		return err;

Ditto. Also kfree(dev->intr_in_buffer) seems to be missing.

Please add a version number to the next patch, e.g. [PATCH v3 ...].

It would also be nice, if some USB guru's could have a look as well.

Thanks,

Wolfgang.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
