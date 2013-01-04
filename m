From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH 1/2] usbnet: allow status interrupt URB to always be active
Date: Fri, 04 Jan 2013 10:48:16 -0600
Message-ID: <1357318096.5370.15.camel@dcbw.foobar.com>
References: <20110727141246.GC29616@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Elina Pasheva <epasheva@sierrawireless.com>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Rory Filer <rfiler@sierrawireless.com>,
	Phil Sutter <phil@nwl.cc>
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28570 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754952Ab3ADQqC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jan 2013 11:46:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some drivers (ex sierra_net) need the status interrupt URB
active even when the device is closed, because they receive
custom indications from firmware.  Allow sub-drivers to set
a flag that submits the status interrupt URB on probe and
keeps the URB alive over device open/close.  The URB is still
killed/re-submitted for suspend/resume, as before.

Signed-off-by: Dan Williams <dcbw@redhat.com>
---
Oliver: alternatively, is there a problem with *always*
submitting the interrupt URB, and then simply not calling
the subdriver's .status function when the netdev is
closed?  That would be a much simpler patch.

 drivers/net/usb/usbnet.c   | 43 +++++++++++++++++++++++++++++++------------
 include/linux/usb/usbnet.h |  3 +++
 2 files changed, 34 insertions(+), 12 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 3d4bf01..081b685 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -206,13 +206,13 @@ static void intr_complete (struct urb *urb)
 		break;
 	}
 
-	if (!netif_running (dev->net))
-		return;
-
-	status = usb_submit_urb (urb, GFP_ATOMIC);
-	if (status != 0)
-		netif_err(dev, timer, dev->net,
-			  "intr resubmit --> %d\n", status);
+	if (dev->driver_info->flags & FLAG_INTR_ALWAYS ||
+			netif_running(dev->net)) {
+		status = usb_submit_urb(urb, GFP_ATOMIC);
+		if (status != 0)
+			netif_err(dev, timer, dev->net,
+				  "intr resubmit --> %d\n", status);
+	}
 }
 
 static int init_status (struct usbnet *dev, struct usb_interface *intf)
@@ -708,7 +708,8 @@ int usbnet_stop (struct net_device *net)
 	if (!(info->flags & FLAG_AVOID_UNLINK_URBS))
 		usbnet_terminate_urbs(dev);
 
-	usb_kill_urb(dev->interrupt);
+	if (!(info->flags & FLAG_INTR_ALWAYS))
+		usb_kill_urb(dev->interrupt);
 
 	usbnet_purge_paused_rxq(dev);
 
@@ -769,7 +770,7 @@ int usbnet_open (struct net_device *net)
 	}
 
 	/* start any status interrupt transfer */
-	if (dev->interrupt) {
+	if (dev->interrupt && !(info->flags & FLAG_INTR_ALWAYS)) {
 		retval = usb_submit_urb (dev->interrupt, GFP_KERNEL);
 		if (retval < 0) {
 			netif_err(dev, ifup, dev->net,
@@ -1469,6 +1470,15 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 	if (status < 0)
 		goto out3;
 
+	/* Submit status interrupt URB immediately if sub-driver wants */
+	if (dev->interrupt && (info->flags & FLAG_INTR_ALWAYS)) {
+		status = usb_submit_urb(dev->interrupt, GFP_KERNEL);
+		if (status < 0) {
+			dev_err(&udev->dev, "intr submit %d\n", status);
+			goto out4;
+		}
+	}
+
 	if (!dev->rx_urb_size)
 		dev->rx_urb_size = dev->hard_mtu;
 	dev->maxpacket = usb_maxpacket (dev->udev, dev->out, 1);
@@ -1480,7 +1490,7 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 
 	status = register_netdev (net);
 	if (status)
-		goto out4;
+		goto out5;
 	netif_info(dev, probe, dev->net,
 		   "register '%s' at usb-%s-%s, %s, %pM\n",
 		   udev->dev.driver->name,
@@ -1498,6 +1508,8 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 
 	return 0;
 
+out5:
+	usb_kill_urb(dev->interrupt);
 out4:
 	usb_free_urb(dev->interrupt);
 out3:
@@ -1559,8 +1571,15 @@ int usbnet_resume (struct usb_interface *intf)
 
 	if (!--dev->suspend_count) {
 		/* resume interrupt URBs */
-		if (dev->interrupt && test_bit(EVENT_DEV_OPEN, &dev->flags))
-			usb_submit_urb(dev->interrupt, GFP_NOIO);
+		if (dev->interrupt &&
+			(dev->driver_info->flags & FLAG_INTR_ALWAYS ||
+				test_bit(EVENT_DEV_OPEN, &dev->flags))) {
+			retval = usb_submit_urb(dev->interrupt, GFP_NOIO);
+			if (retval < 0) {
+				netif_err(dev, ifup, dev->net,
+					  "intr submit %d\n", retval);
+			}
+		}
 
 		spin_lock_irq(&dev->txq.lock);
 		while ((res = usb_get_from_anchor(&dev->deferred))) {
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index bd45eb7..8503920 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -108,6 +108,9 @@ struct driver_info {
 #define FLAG_MULTI_PACKET	0x2000
 #define FLAG_RX_ASSEMBLE	0x4000	/* rx packets may span >1 frames */
 
+/* Indicates that the interrupt URB should not depend on netdev open/close */
+#define FLAG_INTR_ALWAYS	0x8000
+
 	/* init device ... can sleep, or cause probe() failure */
 	int	(*bind)(struct usbnet *, struct usb_interface *);
 
-- 
1.7.11.7
