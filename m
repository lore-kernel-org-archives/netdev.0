From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCHv3] drivers/net/usb: Add new driver ipheth
Date: Wed, 31 Mar 2010 22:33:26 +0200
Message-ID: <201003312233.26130.oliver@neukum.org>
References: <1269984864-28159-1-git-send-email-agimenez@sysvalve.es> <1270064527-8485-1-git-send-email-agimenez@sysvalve.es>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linville@tuxdriver.com,
	j.dumon@option.com, steve.glendinning@smsc.com,
	davem@davemloft.net, gregkh@suse.de, dgiagio@gmail.com,
	dborca@yahoo.com
To: "L. Alberto =?utf-8?q?Gim=C3=A9nez?=" <agimenez@sysvalve.es>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1270064527-8485-1-git-send-email-agimenez@sysvalve.es>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Mittwoch, 31. M=C3=A4rz 2010 21:42:07 schrieb L. Alberto Gim=C3=A9ne=
z:

Hi,

a few comments below.

	Regards
		Oliver

> +
> +static struct usb_device_id ipheth_table[] =3D {
> +	{ USB_DEVICE(USB_VENDOR_APPLE, USB_PRODUCT_IPHETH) },
> +	{ USB_DEVICE(USB_VENDOR_APPLE, USB_PRODUCT_IPHETH_3G) },
> +	{ USB_DEVICE(USB_VENDOR_APPLE, USB_PRODUCT_IPHETH_3GS) },

Please use the macros specifying the interface.

> +	{ }
> +};
> +MODULE_DEVICE_TABLE(usb, ipheth_table);


> +static void ipheth_unlink_urbs(struct ipheth_device *dev)

The naming might be misleading.

> +{
> +	usb_kill_urb(dev->tx_urb);
> +	usb_kill_urb(dev->rx_urb);
> +}

> +
> +static void ipheth_sndbulk_callback(struct urb *urb)
> +{
> +	struct ipheth_device *dev;
> +
> +	dev =3D urb->context;
> +	if (dev =3D=3D NULL)
> +		return;
> +
> +	if (urb->status !=3D 0 &&
> +	    urb->status !=3D -ENOENT &&
> +	    urb->status !=3D -ECONNRESET &&
> +	    urb->status !=3D -ESHUTDOWN)
> +		err("%s: urb status: %d", __func__, urb->status);
> +
> +	netif_wake_queue(dev->net);
> +	dev_kfree_skb_irq(dev->tx_skb);

Race condition. You must free the skb before you wake the queue.

> +}

> +
> +static int ipheth_open(struct net_device *net)
> +{
> +	struct ipheth_device *dev =3D netdev_priv(net);
> +	struct usb_device *udev =3D dev->udev;
> +	int retval =3D 0;
> +
> +	usb_set_interface(udev, IPHETH_INTFNUM, IPHETH_ALT_INTFNUM);
> +	usb_clear_halt(udev, usb_rcvbulkpipe(udev, dev->bulk_in));
> +	usb_clear_halt(udev, usb_sndbulkpipe(udev, dev->bulk_out));

Is this really needed? If so, please add a comment.

> +
> +	retval =3D ipheth_carrier_set(dev);
> +	if (retval)
> +		goto error;
> +
> +	retval =3D ipheth_rx_submit(dev, GFP_KERNEL);
> +	if (retval)
> +		goto error;
> +
> +	schedule_delayed_work(&dev->carrier_work, IPHETH_CARRIER_CHECK_TIME=
OUT);

Does it make sense to start rx while you have no carrier?

> +	netif_start_queue(net);
> +error:
> +	return retval;
> +}

> +static int ipheth_tx(struct sk_buff *skb, struct net_device *net)
> +{
> +	struct ipheth_device *dev =3D netdev_priv(net);
> +	struct usb_device *udev =3D dev->udev;
> +	int retval;
> +
> +	/* Paranoid */
> +	if (skb->len > IPHETH_BUF_SIZE) {
> +		err("%s: skb too large: %d bytes", __func__, skb->len);
> +		dev->stats.tx_dropped++;
> +		dev_kfree_skb_irq(skb);
> +		goto exit;
> +	}
> +
> +	memset(dev->tx_buf, 0, IPHETH_BUF_SIZE);
> +	memcpy(dev->tx_buf, skb->data, skb->len);

a bit wasteful

> +static int ipheth_probe(struct usb_interface *intf,
> +			 const struct usb_device_id *id)
> +{
> +	struct usb_device *udev =3D interface_to_usbdev(intf);
> +	struct usb_host_interface *hintf;
> +	struct usb_endpoint_descriptor *endp;
> +	struct ipheth_device *dev;
> +	struct net_device *netdev;
> +	int i;
> +	int retval;
> +
> +	/* Ensure we are probing the right interface */
> +	if (intf->cur_altsetting->desc.bInterfaceClass !=3D IPHETH_USBINTF_=
CLASS ||
> +	    intf->cur_altsetting->desc.bInterfaceSubClass !=3D IPHETH_USBIN=
TF_SUBCLASS)
> +		return -ENODEV;

Please use the correct macro to specify the interface you are intereste=
d in

> +static void ipheth_disconnect(struct usb_interface *intf)
> +{
> +	struct ipheth_device *dev;
> +
> +	dev =3D usb_get_intfdata(intf);
> +	if (dev !=3D NULL) {

is this check needed?

> +static struct usb_driver ipheth_driver =3D {
> +	.name =3D		"ipheth",
> +	.probe =3D	ipheth_probe,
> +	.disconnect =3D	ipheth_disconnect,
> +	.id_table =3D	ipheth_table,
> +	.supports_autosuspend =3D 0,

redundant
