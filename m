From: Dan Williams <dcbw@redhat.com>
Subject: Re: [RFC] Revert "sierra_net: keep status interrupt URB active"
Date: Mon, 04 Nov 2013 14:27:07 -0600
Message-ID: <1383596827.29469.1.camel@dcbw.foobar.com>
References: <1383310428-19913-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	John Henderson <jhen@talk21.com>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24840 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750791Ab3KDU1W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Nov 2013 15:27:22 -0500
In-Reply-To: <1383310428-19913-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-11-01 at 13:53 +0100, Bj=C3=B8rn Mork wrote:
> This reverts commit 7b0c5f21f348a66de495868b8df0284e8dfd6bbf.
>=20
> It's not easy to create a driver for all the various firmware
> bugs out there.
>=20
> This change caused regressions for a number of devices, which
> started to fail link detection and therefore became completely
> non-functional. The exact reason is yet unknown, it looks like
> the affected firmwares might actually need all or some of the
> additional SYNC messages the patch got rid of.
>=20
> Reverting is not optimal, as it will re-introduce the original
> problem, but it is currently the only alternative known to fix
> this issue.

Instead, how does the following patch work for you?

Dan

---
diff --git a/drivers/net/usb/sierra_net.c b/drivers/net/usb/sierra_net.=
c
index a79e9d3..dd59d97 100644
--- a/drivers/net/usb/sierra_net.c
+++ b/drivers/net/usb/sierra_net.c
@@ -163,18 +163,19 @@ struct lsi_umts {
 #define SIERRA_NET_LSI_UMTS_LEN        (sizeof(struct lsi_umts))
 #define SIERRA_NET_LSI_UMTS_STATUS_LEN \
 	(SIERRA_NET_LSI_UMTS_LEN - SIERRA_NET_LSI_COMMON_LEN)
=20
 /* Forward definitions */
 static void sierra_sync_timer(unsigned long syncdata);
 static int sierra_net_change_mtu(struct net_device *net, int new_mtu);
+static int sierra_net_open (struct net_device *net);
=20
 /* Our own net device operations structure */
 static const struct net_device_ops sierra_net_device_ops =3D {
-	.ndo_open               =3D usbnet_open,
+	.ndo_open               =3D sierra_net_open,
 	.ndo_stop               =3D usbnet_stop,
 	.ndo_start_xmit         =3D usbnet_start_xmit,
 	.ndo_tx_timeout         =3D usbnet_tx_timeout,
 	.ndo_change_mtu         =3D sierra_net_change_mtu,
 	.ndo_set_mac_address    =3D eth_mac_addr,
 	.ndo_validate_addr      =3D eth_validate_addr,
 };
@@ -439,14 +440,15 @@ static void sierra_net_dosync(struct usbnet *dev)
 		netdev_err(dev->net,
 			"Send SYNC failed, status %d\n", status);
 	status =3D sierra_net_send_sync(dev);
 	if (status < 0)
 		netdev_err(dev->net,
 			"Send SYNC failed, status %d\n", status);
=20
+printk(KERN_INFO "%s: sent two SYNC messages\n", __func__);
 	/* Now, start a timer and make sure we get the Restart Indication */
 	priv->sync_timer.function =3D sierra_sync_timer;
 	priv->sync_timer.data =3D (unsigned long) dev;
 	priv->sync_timer.expires =3D jiffies + SIERRA_NET_SYNCDELAY;
 	add_timer(&priv->sync_timer);
 }
=20
@@ -497,31 +499,34 @@ static void sierra_net_kevent(struct work_struct =
*work)
 				netdev_err(dev->net, "%s: Bad packet, received"
 					" %d, expected %d\n",	__func__, len,
 					hh.hdrlen + hh.payload_len.word);
 				kfree(buf);
 				return;
 			}
=20
+printk(KERN_INFO "%s: received msg 0x%02x len %d\n", __func__, hh.msgi=
d.byte, len);
 			/* Switch on received message types */
 			switch (hh.msgid.byte) {
 			case SIERRA_NET_HIP_LSI_UMTSID:
 				dev_dbg(&dev->udev->dev, "LSI for ctx:%d",
 					hh.msgspecific.byte);
 				sierra_net_handle_lsi(dev, buf, &hh);
 				break;
 			case SIERRA_NET_HIP_RESTART_ID:
+printk(KERN_INFO "%s: RESTART received code 0x%02x\n", __func__, hh.ms=
gspecific.byte);
 				dev_dbg(&dev->udev->dev, "Restart reported: %d,"
 						" stopping sync timer",
 						hh.msgspecific.byte);
 				/* Got sync resp - stop timer & clear mask */
 				del_timer_sync(&priv->sync_timer);
 				clear_bit(SIERRA_NET_TIMER_EXPIRY,
 					  &priv->kevent_flags);
 				break;
 			case SIERRA_NET_HIP_HSYNC_ID:
+printk(KERN_INFO "%s: HSYNC received\n", __func__);
 				dev_dbg(&dev->udev->dev, "SYNC received");
 				err =3D sierra_net_send_sync(dev);
 				if (err < 0)
 					netdev_err(dev->net,
 						"Send SYNC failed %d\n", err);
 				break;
 			case SIERRA_NET_HIP_EXTENDEDID:
@@ -537,14 +542,15 @@ static void sierra_net_kevent(struct work_struct =
*work)
 				break;
 			}
 		}
 		kfree(buf);
 	}
 	/* The sync timer bit might be set */
 	if (test_bit(SIERRA_NET_TIMER_EXPIRY, &priv->kevent_flags)) {
+printk(KERN_INFO "%s: re-sending SYNC\n", __func__);
 		clear_bit(SIERRA_NET_TIMER_EXPIRY, &priv->kevent_flags);
 		dev_dbg(&dev->udev->dev, "Deferred sync timer expiry");
 		sierra_net_dosync(priv->usbnet);
 	}
=20
 	if (priv->kevent_flags)
 		dev_dbg(&dev->udev->dev, "sierra_net_kevent done, "
@@ -562,14 +568,15 @@ static void sierra_net_defer_kevent(struct usbnet=
 *dev, int work)
 /*
  * Sync Retransmit Timer Handler. On expiry, kick the work queue
  */
 static void sierra_sync_timer(unsigned long syncdata)
 {
 	struct usbnet *dev =3D (struct usbnet *)syncdata;
=20
+printk(KERN_INFO "%s: sync timer expired\n", __func__);
 	dev_dbg(&dev->udev->dev, "%s", __func__);
 	/* Kick the tasklet */
 	sierra_net_defer_kevent(dev, SIERRA_NET_TIMER_EXPIRY);
 }
=20
 static void sierra_net_status(struct usbnet *dev, struct urb *urb)
 {
@@ -584,14 +591,15 @@ static void sierra_net_status(struct usbnet *dev,=
 struct urb *urb)
 	event =3D urb->transfer_buffer;
 	switch (event->bNotificationType) {
 	case USB_CDC_NOTIFY_NETWORK_CONNECTION:
 	case USB_CDC_NOTIFY_SPEED_CHANGE:
 		/* USB 305 sends those */
 		break;
 	case USB_CDC_NOTIFY_RESPONSE_AVAILABLE:
+printk(KERN_INFO "%s: firmware indicates response available\n", __func=
__);
 		sierra_net_defer_kevent(dev, SIERRA_NET_EVENT_RESP_AVAIL);
 		break;
 	default:
 		netdev_err(dev->net, ": unexpected notification %02x!\n",
 				event->bNotificationType);
 		break;
 	}
@@ -767,20 +775,32 @@ static void sierra_net_unbind(struct usbnet *dev,=
 struct usb_interface *intf)
 	/* tell modem we are going away */
 	status =3D sierra_net_send_cmd(dev, priv->shdwn_msg,
 			sizeof(priv->shdwn_msg), "Shutdown");
 	if (status < 0)
 		netdev_err(dev->net,
 			"usb_control_msg failed, status %d\n", status);
=20
-	usbnet_status_stop(dev);
-
 	sierra_net_set_private(dev, NULL);
 	kfree(priv);
 }
=20
+static int sierra_net_open (struct net_device *net)
+{
+	int ret;
+
+	ret =3D usbnet_open(net);
+	if (ret =3D=3D 0) {
+		struct usbnet *dev =3D netdev_priv(net);
+
+		/* Interrupt URB now set up; initiate sync sequence */
+		sierra_net_dosync(dev);
+	}
+	return ret;
+}
+
 static struct sk_buff *sierra_net_skb_clone(struct usbnet *dev,
 		struct sk_buff *skb, int len)
 {
 	struct sk_buff *new_skb;
=20
 	/* clone skb */
 	new_skb =3D skb_clone(skb, GFP_ATOMIC);
@@ -910,14 +930,15 @@ static const struct driver_info sierra_net_info_d=
irect_ip =3D {
 	.bind =3D sierra_net_bind,
 	.unbind =3D sierra_net_unbind,
 	.status =3D sierra_net_status,
 	.rx_fixup =3D sierra_net_rx_fixup,
 	.tx_fixup =3D sierra_net_tx_fixup,
 };
=20
+#if 0
 static int
 sierra_net_probe(struct usb_interface *udev, const struct usb_device_i=
d *prod)
 {
 	int ret;
=20
 	ret =3D usbnet_probe(udev, prod);
 	if (ret =3D=3D 0) {
@@ -927,14 +948,15 @@ sierra_net_probe(struct usb_interface *udev, cons=
t struct usb_device_id *prod)
 		if (ret =3D=3D 0) {
 			/* Interrupt URB now set up; initiate sync sequence */
 			sierra_net_dosync(dev);
 		}
 	}
 	return ret;
 }
+#endif
=20
 #define DIRECT_IP_DEVICE(vend, prod) \
 	{USB_DEVICE_INTERFACE_NUMBER(vend, prod, 7), \
 	.driver_info =3D (unsigned long)&sierra_net_info_direct_ip}, \
 	{USB_DEVICE_INTERFACE_NUMBER(vend, prod, 10), \
 	.driver_info =3D (unsigned long)&sierra_net_info_direct_ip}, \
 	{USB_DEVICE_INTERFACE_NUMBER(vend, prod, 11), \
@@ -950,15 +972,15 @@ static const struct usb_device_id products[] =3D =
{
 };
 MODULE_DEVICE_TABLE(usb, products);
=20
 /* We are based on usbnet, so let it handle the USB driver specifics *=
/
 static struct usb_driver sierra_net_driver =3D {
 	.name =3D "sierra_net",
 	.id_table =3D products,
-	.probe =3D sierra_net_probe,
+	.probe =3D usbnet_probe,
 	.disconnect =3D usbnet_disconnect,
 	.suspend =3D usbnet_suspend,
 	.resume =3D usbnet_resume,
 	.no_dynamic_id =3D 1,
 	.disable_hub_initiated_lpm =3D 1,
 };
=20
