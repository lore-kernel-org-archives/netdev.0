From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: [rft]testers for suspend/resume support for cdc-phonet
Date: Fri, 2 Jul 2010 23:46:53 +0200
Message-ID: <201007022346.53635.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

I am looking for someone who is willing to test a patch for cdc-phonet
implementing suspend/resume.

	Regards
		Oliver

diff --git a/drivers/net/usb/cdc-phonet.c b/drivers/net/usb/cdc-phonet.c
index 109751b..d182835 100644
--- a/drivers/net/usb/cdc-phonet.c
+++ b/drivers/net/usb/cdc-phonet.c
@@ -42,9 +42,12 @@ struct usbpn_dev {
 	unsigned int		tx_pipe, rx_pipe;
 	u8 active_setting;
 	u8 disconnected;
+	u8 suspended;
+	u8 opened;
 
 	unsigned		tx_queue;
 	spinlock_t		tx_lock;
+	struct usb_anchor	tx_anchor;
 
 	spinlock_t		rx_lock;
 	struct sk_buff		*rx_skb;
@@ -73,8 +76,10 @@ static netdev_tx_t usbpn_xmit(struct sk_buff *skb, struct net_device *dev)
 	usb_fill_bulk_urb(req, pnd->usb, pnd->tx_pipe, skb->data, skb->len,
 				tx_complete, skb);
 	req->transfer_flags = URB_ZERO_PACKET;
+	usb_anchor_urb(req, &pnd->tx_anchor);
 	err = usb_submit_urb(req, GFP_ATOMIC);
 	if (err) {
+		usb_unanchor_urb(req);
 		usb_free_urb(req);
 		goto drop;
 	}
@@ -235,6 +240,7 @@ static int usbpn_open(struct net_device *dev)
 		pnd->urbs[i] = req;
 	}
 
+	pnd->opened = 1;
 	netif_wake_queue(dev);
 	return 0;
 }
@@ -256,6 +262,7 @@ static int usbpn_close(struct net_device *dev)
 		usb_free_urb(req);
 		pnd->urbs[i] = NULL;
 	}
+	pnd->opened = 0;
 
 	return usb_set_interface(pnd->usb, num, !pnd->active_setting);
 }
@@ -400,6 +407,7 @@ int usbpn_probe(struct usb_interface *intf, const struct usb_device_id *id)
 	pnd->data_intf = data_intf;
 	spin_lock_init(&pnd->tx_lock);
 	spin_lock_init(&pnd->rx_lock);
+	init_usb_anchor(&pnd->tx_anchor);
 	/* Endpoints */
 	if (usb_pipein(data_desc->endpoint[0].desc.bEndpointAddress)) {
 		pnd->rx_pipe = usb_rcvbulkpipe(usbdev,
@@ -453,10 +461,52 @@ static void usbpn_disconnect(struct usb_interface *intf)
 	usb_put_dev(usb);
 }
 
+static int usbpn_suspend(struct usb_interface *intf, pm_message_t message)
+{
+	struct usbpn_dev *pnd = usb_get_intfdata(intf);
+	int i;
+
+	if (pnd->suspended++)
+		return 0;
+	if (!pnd->opened)
+		return 0;
+	
+	for (i = 0; i < rxq_size; i++) {
+		struct urb *req = pnd->urbs[i];
+		usb_kill_urb(req);
+	}
+
+	usb_kill_anchored_urbs(&pnd->tx_anchor);
+	return 0;
+}
+
+static int usbpn_resume(struct usb_interface *intf)
+{
+	struct usbpn_dev *pnd = usb_get_intfdata(intf);
+	int i, r, rv = 0;
+
+	if (--pnd->suspended)
+		return 0;
+	if (!pnd->opened)
+		return 0;
+
+	for (i = 0; i < rxq_size; i++) {
+		struct urb *req = pnd->urbs[i];
+
+		r = rx_submit(pnd, req, GFP_NOIO);
+		if (r)
+			rv++;
+	}
+
+	return rv ? -EIO : 0;
+}
+
 static struct usb_driver usbpn_driver = {
 	.name =		"cdc_phonet",
 	.probe =	usbpn_probe,
 	.disconnect =	usbpn_disconnect,
+	.suspend =	usbpn_suspend,
+	.resume =	usbpn_resume,
 	.id_table =	usbpn_ids,
 };
 
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
