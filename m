From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH 1/2 v2] usbnet: allow status interrupt URB to always be
 active
Date: Wed, 06 Feb 2013 12:36:38 -0600
Message-ID: <1360175798.11742.12.camel@dcbw.foobar.com>
References: <20110727141246.GC29616@orbit.nwl.cc>
	 <1357318096.5370.15.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Elina Pasheva <epasheva@sierrawireless.com>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Rory Filer <rfiler@sierrawireless.com>,
	Phil Sutter <phil@nwl.cc>
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50459 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755038Ab3BFSg1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2013 13:36:27 -0500
In-Reply-To: <1357318096.5370.15.camel@dcbw.foobar.com>
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
Note: unchanged from previous version, but rebased.

 drivers/net/usb/usbnet.c   | 43 +++++++++++++++++++++++++++++++------------
 include/linux/usb/usbnet.h |  3 +++
 2 files changed, 34 insertions(+), 12 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 5e33606..5019cc7 100644
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
@@ -725,7 +725,8 @@ int usbnet_stop (struct net_device *net)
 	if (!(info->flags & FLAG_AVOID_UNLINK_URBS))
 		usbnet_terminate_urbs(dev);
 
-	usb_kill_urb(dev->interrupt);
+	if (!(info->flags & FLAG_INTR_ALWAYS))
+		usb_kill_urb(dev->interrupt);
 
 	usbnet_purge_paused_rxq(dev);
 
@@ -786,7 +787,7 @@ int usbnet_open (struct net_device *net)
 	}
 
 	/* start any status interrupt transfer */
-	if (dev->interrupt) {
+	if (dev->interrupt && !(info->flags & FLAG_INTR_ALWAYS)) {
 		retval = usb_submit_urb (dev->interrupt, GFP_KERNEL);
 		if (retval < 0) {
 			netif_err(dev, ifup, dev->net,
@@ -1496,6 +1497,15 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
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
@@ -1507,7 +1517,7 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 
 	status = register_netdev (net);
 	if (status)
-		goto out4;
+		goto out5;
 	netif_info(dev, probe, dev->net,
 		   "register '%s' at usb-%s-%s, %s, %pM\n",
 		   udev->dev.driver->name,
@@ -1525,6 +1535,8 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 
 	return 0;
 
+out5:
+	usb_kill_urb(dev->interrupt);
 out4:
 	usb_free_urb(dev->interrupt);
 out3:
@@ -1586,8 +1598,15 @@ int usbnet_resume (struct usb_interface *intf)
 
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
index 0de078d..b0f17f6 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -111,6 +111,9 @@ struct driver_info {
 #define FLAG_MULTI_PACKET	0x2000
 #define FLAG_RX_ASSEMBLE	0x4000	/* rx packets may span >1 frames */
 
+/* Indicates that the interrupt URB should not depend on netdev open/close */
+#define FLAG_INTR_ALWAYS	0x8000
+
 	/* init device ... can sleep, or cause probe() failure */
 	int	(*bind)(struct usbnet *, struct usb_interface *);
 
-- 
1.7.11.7
