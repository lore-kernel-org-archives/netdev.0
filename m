From: Oliver Neukum <oneukum@suse.de>
Subject: [patch]support for USB autosuspend in the asix driver
Date: Fri, 3 Aug 2007 13:52:19 +0200
Message-ID: <200708031352.19419.oneukum@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: jgarzik@pobox.com, netdev@vger.kernel.org,
	David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:32992 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760155AbXHCLuG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Aug 2007 07:50:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

this implements support for USB autosuspend in the asix USB ethernet
driver.

	Regards
		Oliver
Signed-off-by: Oliver Neukum <oneukum@suse.de>
---

--- a/drivers/net/usb/asix.c	2007-08-03 13:16:31.000000000 +0200
+++ b/drivers/net/usb/asix.c	2007-08-03 13:17:05.000000000 +0200
@@ -1474,6 +1474,7 @@ static struct usb_driver asix_driver = {
 	.suspend =	usbnet_suspend,
 	.resume =	usbnet_resume,
 	.disconnect =	usbnet_disconnect,
+	.supports_autosuspend = 1,
 };
 
 static int __init asix_init(void)
--- a/drivers/net/usb/usbnet.c	2007-08-03 13:16:53.000000000 +0200
+++ b/drivers/net/usb/usbnet.c	2007-08-03 13:19:31.000000000 +0200
@@ -588,6 +588,7 @@ static int usbnet_stop (struct net_devic
 	dev->flags = 0;
 	del_timer_sync (&dev->delay);
 	tasklet_kill (&dev->bh);
+	usb_autopm_put_interface(dev->intf);
 
 	return 0;
 }
@@ -601,9 +602,19 @@ static int usbnet_stop (struct net_devic
 static int usbnet_open (struct net_device *net)
 {
 	struct usbnet		*dev = netdev_priv(net);
-	int			retval = 0;
+	int			retval;
 	struct driver_info	*info = dev->driver_info;
 
+	if ((retval = usb_autopm_get_interface(dev->intf)) < 0) {
+		if (netif_msg_ifup (dev))
+			devinfo (dev,
+				"resumption fail (%d) usbnet usb-%s-%s, %s",
+				retval,
+				dev->udev->bus->bus_name, dev->udev->devpath,
+			info->description);
+		goto done_nopm;
+	}
+
 	// put into "known safe" state
 	if (info->reset && (retval = info->reset (dev)) < 0) {
 		if (netif_msg_ifup (dev))
@@ -657,7 +668,10 @@ static int usbnet_open (struct net_devic
 
 	// delay posting reads until we're fully open
 	tasklet_schedule (&dev->bh);
+	return retval;
 done:
+	usb_autopm_put_interface(dev->intf);
+done_nopm:
 	return retval;
 }
 
@@ -1141,6 +1155,7 @@ usbnet_probe (struct usb_interface *udev
 
 	dev = netdev_priv(net);
 	dev->udev = xdev;
+	dev->intf = udev;
 	dev->driver_info = info;
 	dev->driver_name = name;
 	dev->msg_enable = netif_msg_init (msg_level, NETIF_MSG_DRV
@@ -1265,12 +1280,18 @@ int usbnet_suspend (struct usb_interface
 	struct usbnet		*dev = usb_get_intfdata(intf);
 
 	if (!dev->suspend_count++) {
-		/* accelerate emptying of the rx and queues, to avoid
+		/*
+		 * accelerate emptying of the rx and queues, to avoid
 		 * having everything error out.
 		 */
 		netif_device_detach (dev->net);
 		(void) unlink_urbs (dev, &dev->rxq);
 		(void) unlink_urbs (dev, &dev->txq);
+		/*
+		 * reattach so runtime management can use and
+		 * wake the device
+		 */
+		netif_device_attach (dev->net);
 	}
 	return 0;
 }
@@ -1280,10 +1301,9 @@ int usbnet_resume (struct usb_interface 
 {
 	struct usbnet		*dev = usb_get_intfdata(intf);
 
-	if (!--dev->suspend_count) {
-		netif_device_attach (dev->net);
+	if (!--dev->suspend_count)
 		tasklet_schedule (&dev->bh);
-	}
+
 	return 0;
 }
 EXPORT_SYMBOL_GPL(usbnet_resume);
--- a/drivers/net/usb/usbnet.h	2007-08-03 13:16:44.000000000 +0200
+++ b/drivers/net/usb/usbnet.h	2007-08-03 13:17:05.000000000 +0200
@@ -28,6 +28,7 @@
 struct usbnet {
 	/* housekeeping */
 	struct usb_device	*udev;
+	struct usb_interface	*intf;
 	struct driver_info	*driver_info;
 	const char		*driver_name;
 	wait_queue_head_t	*wait;
