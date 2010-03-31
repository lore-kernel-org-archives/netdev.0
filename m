From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCHv3] drivers/net/usb: Add new driver ipheth
Date: Thu, 01 Apr 2010 00:18:58 +0100
Message-ID: <1270077538.8653.484.camel@localhost>
References: <1269984864-28159-1-git-send-email-agimenez@sysvalve.es>
	 <1270064527-8485-1-git-send-email-agimenez@sysvalve.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, oliver@neukum.org,
	linville@tuxdriver.com, j.dumon@option.com,
	steve.glendinning@smsc.com, davem@davemloft.net, gregkh@suse.de,
	dgiagio@gmail.com, dborca@yahoo.com
To: "L. Alberto" =?ISO-8859-1?Q?Gim=E9nez?= <agimenez@sysvalve.es>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1270064527-8485-1-git-send-email-agimenez@sysvalve.es>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-03-31 at 21:42 +0200, L. Alberto Gim=C3=A9nez wrote:
[...]
> --- /dev/null
> +++ b/drivers/net/usb/ipheth.c
[...]
> +#include <linux/kernel.h>
> +#include <linux/errno.h>
> +#include <linux/init.h>
> +#include <linux/slab.h>
> +#include <linux/module.h>
> +#include <linux/netdevice.h>
> +#include <linux/etherdevice.h>
> +#include <linux/ethtool.h>
> +#include <linux/uaccess.h>

I don't think you need this header.

> +#include <linux/usb.h>
> +#include <linux/workqueue.h>
> +
> +#define USB_VENDOR_APPLE        0x05ac
> +#define USB_PRODUCT_IPHETH     0x1290
> +#define USB_PRODUCT_IPHETH_3G   0x1292
> +#define USB_PRODUCT_IPHETH_3GS  0x1294

Apple doesn't assign device ids to ipheth so either the names are
incorrect or you should get proper device ids.  I believe the Linux
=46oundation has a USB vendor id and could assign device ids under that=
=2E

> +struct ipheth_device {
> +	struct usb_device *udev;
> +	struct usb_interface *intf;
> +	struct net_device *net;
> +	struct net_device_stats stats;

You can store stats in the net_device.

> +	struct sk_buff *tx_skb;
> +	struct urb *tx_urb;
> +	struct urb *rx_urb;
> +	unsigned char *tx_buf;
> +	unsigned char *rx_buf;
> +	unsigned char *ctrl_buf;
> +	__u8 bulk_in;
> +	__u8 bulk_out;

No need for the double-underscores; that's a convention for use in
definitions shared with user-space.

> +	struct delayed_work carrier_work;
> +};
[...]
> +static int ipheth_open(struct net_device *net)
> +{
> +	struct ipheth_device *dev =3D netdev_priv(net);
> +	struct usb_device *udev =3D dev->udev;
> +	int retval =3D 0;
> +
> +	usb_set_interface(udev, IPHETH_INTFNUM, IPHETH_ALT_INTFNUM);
> +	usb_clear_halt(udev, usb_rcvbulkpipe(udev, dev->bulk_in));
> +	usb_clear_halt(udev, usb_sndbulkpipe(udev, dev->bulk_out));
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
> +	netif_start_queue(net);
> +error:
> +	return retval;
> +}

There is no cleanup here (and none appears to be needed) so you could
take out the label and replace the gotos with returns.

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

Use WARN here as this would indicate a bug.

Again the goto is unnecessary.

> +	memset(dev->tx_buf, 0, IPHETH_BUF_SIZE);
> +	memcpy(dev->tx_buf, skb->data, skb->len);

This is wasteful.  If you really must pad the buffer then do so, but
don't clear the area that is going to be filled with real data.

> +	usb_fill_bulk_urb(dev->tx_urb, udev,
> +			  usb_sndbulkpipe(udev, dev->bulk_out),
> +			  dev->tx_buf, IPHETH_BUF_SIZE,
> +			  ipheth_sndbulk_callback,
> +			  dev);
> +	dev->tx_urb->transfer_flags |=3D URB_NO_TRANSFER_DMA_MAP;
> +
> +	retval =3D usb_submit_urb(dev->tx_urb, GFP_ATOMIC);
> +	if (retval) {
> +		err("%s: usb_submit_urb: %d", __func__, retval);
> +		dev->stats.tx_errors++;
> +		dev_kfree_skb_irq(skb);
> +	} else {
> +		net->trans_start =3D jiffies;

No longer needed.

> +		dev->tx_skb =3D skb;
> +
> +		dev->stats.tx_packets++;
> +		dev->stats.tx_bytes +=3D skb->len;
> +		netif_stop_queue(net);
> +	}
> +exit:
> +	return NETDEV_TX_OK;
> +}
[...]
> +#ifdef HAVE_NET_DEVICE_OPS
> +static const struct net_device_ops ipheth_netdev_ops =3D {
> +       .ndo_open =3D &ipheth_open,
> +       .ndo_stop =3D &ipheth_close,
> +       .ndo_start_xmit =3D &ipheth_tx,
> +       .ndo_tx_timeout =3D &ipheth_tx_timeout,
> +       .ndo_get_stats =3D &ipheth_stats,
> +};
> +#endif

Remove the #ifdef, there is no question whether we have net_device_ops.

> +static int ipheth_probe(struct usb_interface *intf,
> +			 const struct usb_device_id *id)
> +{
[...]
> +#ifdef HAVE_NET_DEVICE_OPS
> +	netdev->netdev_ops =3D &ipheth_netdev_ops;
> +#else /* CONFIG_COMPAT_NET_DEV_OPS */
> +	netdev->open =3D &ipheth_open;
> +	netdev->stop =3D &ipheth_close;
> +	netdev->hard_start_xmit =3D &ipheth_tx;
> +	netdev->tx_timeout =3D &ipheth_tx_timeout;
> +	netdev->get_stats =3D &ipheth_stats;
> +#endif
[...]

Similarly here.

As a general point, you should now be using netdev_err(), netdev_info()=
,
etc. for logging messages related to net devices.

I have no idea about USB so I haven't checked the USB API usage at all.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
