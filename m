From: Viral Mehta <Viral.Mehta-oonXi/34qI7c+919tysfdA@public.gmane.org>
Subject: RE: [PATCH v3] can: Add driver for esd CAN-USB/2 device
Date: Wed, 26 May 2010 17:01:23 +0530
Message-ID: <70376CA23424B34D86F1C7DE6B9973430254343AD9@VSHINMSMBX01.vshodc.lntinfotech.com>
References: <201005261114.03214.matthias.fuchs@esd.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org" <Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Matthias Fuchs <matthias.fuchs-iOnpLzIbIdM@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201005261114.03214.matthias.fuchs-iOnpLzIbIdM@public.gmane.org>
Content-Language: en-US
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,
>________________________________________
>From: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org [linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org] On Behalf Of Matthias Fuchs [matthias.fuchs-iOnpLzIbIdM@public.gmane.org]
>Sent: Wednesday, May 26, 2010 2:44 PM
>To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org; linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>Subject: [PATCH v3] can: Add driver for esd CAN-USB/2 device
>
>This patch adds a driver for esd's USB high speed
>CAN interface. The driver supports devices with
>multiple CAN interfaces.
>
>Signed-off-by: Matthias Fuchs <matthias.fuchs-iOnpLzIbIdM@public.gmane.org>
>---

>+static void esd_usb2_write_bulk_callback(struct urb *urb)
>+{
>+       struct esd_tx_urb_context *context = urb->context;
>+       struct esd_usb2_net_priv *priv;
>+       struct esd_usb2 *dev;
>+       struct net_device *netdev;
>+       size_t size = sizeof(struct esd_usb2_msg);
>+
>+       BUG_ON(!context);

It is preferred to used WARN_ON and avoid using BUG_ON and thus dont kill the whole system....
[...]
>+
>+       priv = context->priv;
>+       netdev = priv->netdev;
>+       dev = priv->usb2;
>+       err = usb_submit_urb(urb, GFP_ATOMIC);
>+       if (err) {
>+               can_free_echo_skb(netdev, context->echo_index);
>+
>+               atomic_dec(&priv->active_tx_jobs);
>+               usb_unanchor_urb(urb);
>+
>+               stats->tx_dropped++;
>+
>+               if (err == -ENODEV)
>+                       netif_device_detach(netdev);
>+               else
>+                       dev_warn(netdev->dev.parent, "failed tx_urb %d\n", err);
>+
>+               goto releasebuf;

You probably want to set "ret" here or do you really want to return NETDEV_TX_OK
>+       }

[...]
>+static int esd_usb2_close(struct net_device *netdev)
>+{
>+       struct esd_usb2_net_priv *priv = netdev_priv(netdev);
>+       struct esd_usb2_msg msg;
>+       int i;
>+
>+       /* Disable all IDs (see esd_usb2_start()) */
>+       msg.msg.hdr.cmd = CMD_IDADD;
>+       msg.msg.hdr.len = 2 + ESD_MAX_ID_SEGMENT;
>+       msg.msg.filter.net = priv->index;
>+       msg.msg.filter.option = ESD_ID_ENABLE; /* start with segment 0 */
>+       for (i = 0; i <= ESD_MAX_ID_SEGMENT; i++)
>+               msg.msg.filter.mask[i] = 0;
>+       esd_usb2_send_msg(priv->usb2, &msg);

Probably, you may not care but it can return error value....
>+
>+       /* set CAN controller to reset mode */
>+       msg.msg.hdr.len = 2;
>+       msg.msg.hdr.cmd = CMD_SETBAUD;
>+       msg.msg.setbaud.net = priv->index;
>+       msg.msg.setbaud.rsvd = 0;
>+       msg.msg.setbaud.baud = cpu_to_le32(ESD_USB2_NO_BAUDRATE);
>+       esd_usb2_send_msg(priv->usb2, &msg);

Probably, you may not care but it can return error value....

>+
>+       priv->can.state = CAN_STATE_STOPPED;
>+
>+       netif_stop_queue(netdev);
>+
>+       close_candev(netdev);
>+

[...]
>+static int esd_usb2_probe(struct usb_interface *intf,
>+                        const struct usb_device_id *id)
>+{
>+       struct esd_usb2 *dev;
>+       struct esd_usb2_msg msg;
>+       int i, err = -ENOMEM;
>+
>+       dev = kzalloc(sizeof(*dev), GFP_KERNEL);
>+       if (!dev)
>+               return -ENOMEM;

You probably would like to rewrite "return" statements.... for example, above you define err=-ENOMEM
and then here you are saying "return -ENOMEM" later on at the end you are saying "return err";

Also, people prefer and practice to have only one return point. Read further.

>+
>+       dev->udev = interface_to_usbdev(intf);
>+
>+       init_usb_anchor(&dev->rx_submitted);
>+
>+       usb_set_intfdata(intf, dev);
>+
>+       /* query number of CAN interfaces (nets) */
>+       msg.msg.hdr.cmd = CMD_VERSION;
>+       msg.msg.hdr.len = 2;
>+       msg.msg.version.rsvd = 0;
>+       msg.msg.version.flags = 0;
>+       msg.msg.version.drv_version = 0;
>+
>+       if (esd_usb2_send_msg(dev, &msg) < 0) {
>+               dev_err(&intf->dev, "sending version message failed\n");
>+               goto free_dev;

You might like to set "err" here, since you are not propogating error values properly.....
Irrespective of what esd_usb2_send_msg and thus in turn usb_bulk_msg returns,
you are ignoring those values and always returning -ENOMEM at the end......
>+       }
>+
>+       if (esd_usb2_wait_msg(dev, &msg) < 0) {
>+               dev_err(&intf->dev, "no version message answer\n");
>+               goto free_dev;

Same here.

>+free_dev:
>+       kfree(dev);
>+       return err;
>+}

HTH,
Viral Mehta

This Email may contain confidential or privileged information for the intended recipient (s) If you are not the intended recipient, please do not use or disseminate the information, notify the sender and delete it from your system.

______________________________________________________________________
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
