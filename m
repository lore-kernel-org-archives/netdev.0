From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH 1/2 v3] usbnet: allow status interrupt URB to always be
 active
Date: Thu, 28 Mar 2013 11:30:07 -0500
Message-ID: <1364488207.1877.20.camel@dcbw.foobar.com>
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
Received: from mx1.redhat.com ([209.132.183.28]:19686 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753268Ab3C1Q3a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Mar 2013 12:29:30 -0400
In-Reply-To: <1357318096.5370.15.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some drivers (sierra_net) need the status interrupt URB
active even when the device is closed, because they receive
custom indications from firmware.  Add functions to refcount
the status interrupt URB submit/kill operation so that
sub-drivers and the generic driver don't fight over whether
the status interrupt URB is active or not.

A sub-driver can call usbnet_status_start() at any time, but
the URB is only submitted the first time the function is
called.  Likewise, when the sub-driver is done with the URB,
it calls usbnet_status_stop() but the URB is only killed when
all users have stopped it.  The URB is still killed and
re-submitted for suspend/resume, as before, with the same
refcount it had at suspend.

Signed-off-by: Dan Williams <dcbw@redhat.com>
---
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 51f3192..6431a03 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -252,6 +252,43 @@ static int init_status (struct usbnet *dev, struct usb_interface *intf)
 	return 0;
 }
 
+/* Submit the interrupt URB if it hasn't been submitted yet */
+int usbnet_status_start(struct usbnet *dev, gfp_t mem_flags)
+{
+	int ret = 0;
+
+	/* Only drivers that implement a status hook should call this */
+	BUG_ON(dev->interrupt == NULL);
+
+	if (test_bit (EVENT_DEV_ASLEEP, &dev->flags))
+		return -EINVAL;
+
+	mutex_lock (&dev->interrupt_mutex);
+	if (++dev->interrupt_count == 1)
+		ret = usb_submit_urb (dev->interrupt, mem_flags);
+	dev_dbg(&dev->udev->dev, "incremented interrupt URB count to %d\n",
+		dev->interrupt_count);
+	mutex_unlock (&dev->interrupt_mutex);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(usbnet_status_start);
+
+/* Kill the interrupt URB if all submitters want it killed */
+void usbnet_status_stop(struct usbnet *dev)
+{
+	if (dev->interrupt) {
+		mutex_lock (&dev->interrupt_mutex);
+		BUG_ON(dev->interrupt_count == 0);
+		if (dev->interrupt_count && --dev->interrupt_count == 0)
+			usb_kill_urb(dev->interrupt);
+		dev_dbg(&dev->udev->dev,
+			"decremented interrupt URB count to %d\n",
+			dev->interrupt_count);
+		mutex_unlock (&dev->interrupt_mutex);
+	}
+}
+EXPORT_SYMBOL_GPL(usbnet_status_stop);
+
 /* Passes this packet up the stack, updating its accounting.
  * Some link protocols batch packets, so their rx_fixup paths
  * can return clones as well as just modify the original skb.
@@ -725,7 +762,7 @@ int usbnet_stop (struct net_device *net)
 	if (!(info->flags & FLAG_AVOID_UNLINK_URBS))
 		usbnet_terminate_urbs(dev);
 
-	usb_kill_urb(dev->interrupt);
+	usbnet_status_stop(dev);
 
 	usbnet_purge_paused_rxq(dev);
 
@@ -787,7 +824,7 @@ int usbnet_open (struct net_device *net)
 
 	/* start any status interrupt transfer */
 	if (dev->interrupt) {
-		retval = usb_submit_urb (dev->interrupt, GFP_KERNEL);
+		retval = usbnet_status_start(dev, GFP_KERNEL);
 		if (retval < 0) {
 			netif_err(dev, ifup, dev->net,
 				  "intr submit %d\n", retval);
@@ -1430,6 +1467,8 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 	dev->delay.data = (unsigned long) dev;
 	init_timer (&dev->delay);
 	mutex_init (&dev->phy_mutex);
+	mutex_init (&dev->interrupt_mutex);
+	dev->interrupt_count = 0;
 
 	dev->net = net;
 	strcpy (net->name, "usb%d");
@@ -1585,9 +1624,13 @@ int usbnet_resume (struct usb_interface *intf)
 	int                     retval;
 
 	if (!--dev->suspend_count) {
-		/* resume interrupt URBs */
-		if (dev->interrupt && test_bit(EVENT_DEV_OPEN, &dev->flags))
-			usb_submit_urb(dev->interrupt, GFP_NOIO);
+		/* resume interrupt URBs if they were submitted at suspend */
+		if (dev->interrupt) {
+			mutex_lock (&dev->interrupt_mutex);
+			if (dev->interrupt_count)
+				usb_submit_urb(dev->interrupt, GFP_NOIO);
+			mutex_unlock (&dev->interrupt_mutex);
+		}
 
 		spin_lock_irq(&dev->txq.lock);
 		while ((res = usb_get_from_anchor(&dev->deferred))) {
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index 0e5ac93..d71f44c 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -56,6 +56,8 @@ struct usbnet {
 	struct sk_buff_head	done;
 	struct sk_buff_head	rxq_pause;
 	struct urb		*interrupt;
+	unsigned		interrupt_count;
+	struct mutex            interrupt_mutex;
 	struct usb_anchor	deferred;
 	struct tasklet_struct	bh;
 
@@ -246,4 +248,7 @@ extern int usbnet_nway_reset(struct net_device *net);
 
 extern int usbnet_manage_power(struct usbnet *, int);
 
+int usbnet_status_start(struct usbnet *dev, gfp_t mem_flags);
+void usbnet_status_stop(struct usbnet *dev);
+
 #endif /* __LINUX_USB_USBNET_H */
