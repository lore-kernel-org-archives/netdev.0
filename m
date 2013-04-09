From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH 1/2 v4] usbnet: allow status interrupt URB to always be
 active
Date: Tue, 09 Apr 2013 18:02:27 -0500
Message-ID: <1365548547.23372.2.camel@dcbw.foobar.com>
References: <20110727141246.GC29616@orbit.nwl.cc>
	 <1357318096.5370.15.camel@dcbw.foobar.com>
	 <1364488207.1877.20.camel@dcbw.foobar.com>
	 <CACVXFVMBAzTYZKiE_uSTqr_yB4f7c5_PSnK=LBP6=oWdWwYHfg@mail.gmail.com>
	 <1364832288.3059.12.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Oliver Neukum <oliver@neukum.org>,
	Elina Pasheva <epasheva@sierrawireless.com>,
	Network Development <netdev@vger.kernel.org>,
	linux-usb <linux-usb@vger.kernel.org>,
	Rory Filer <rfiler@sierrawireless.com>,
	Phil Sutter <phil@nwl.cc>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61590 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751767Ab3DIXB0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Apr 2013 19:01:26 -0400
In-Reply-To: <1364832288.3059.12.camel@dcbw.foobar.com>
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
 drivers/net/usb/usbnet.c   | 79 ++++++++++++++++++++++++++++++++++++++++++----
 include/linux/usb/usbnet.h |  5 +++
 2 files changed, 77 insertions(+), 7 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 51f3192..e8b363a 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -42,7 +42,7 @@
 #include <linux/workqueue.h>
 #include <linux/mii.h>
 #include <linux/usb.h>
-#include <linux/usb/usbnet.h>
+#include "usbnet.h"
 #include <linux/slab.h>
 #include <linux/kernel.h>
 #include <linux/pm_runtime.h>
@@ -252,6 +252,70 @@ static int init_status (struct usbnet *dev, struct usb_interface *intf)
 	return 0;
 }
 
+/* Submit the interrupt URB if it hasn't been submitted yet */
+static int __usbnet_status_start(struct usbnet *dev, gfp_t mem_flags,
+					bool force)
+{
+	int ret = 0;
+	bool submit = false;
+
+	if (!dev->interrupt)
+		return 0;
+
+	mutex_lock(&dev->interrupt_mutex);
+
+	if (force) {
+		/* Only submit now if the URB was previously submitted */
+		if (dev->interrupt_count)
+			submit = true;
+	} else if (++dev->interrupt_count == 1)
+		submit = true;
+
+	if (submit)
+		ret = usb_submit_urb(dev->interrupt, mem_flags);
+
+	dev_dbg(&dev->udev->dev, "incremented interrupt URB count to %d\n",
+		dev->interrupt_count);
+	mutex_unlock(&dev->interrupt_mutex);
+	return ret;
+}
+
+int usbnet_status_start(struct usbnet *dev, gfp_t mem_flags)
+{
+	/* Only drivers that implement a status hook should call this */
+	BUG_ON(dev->interrupt == NULL);
+
+	if (test_bit(EVENT_DEV_ASLEEP, &dev->flags))
+		return -EINVAL;
+
+	return __usbnet_status_start(dev, mem_flags, false);
+}
+EXPORT_SYMBOL_GPL(usbnet_status_start);
+
+/* Kill the interrupt URB if all submitters want it killed */
+static void __usbnet_status_stop(struct usbnet *dev, bool force)
+{
+	if (dev->interrupt) {
+		mutex_lock(&dev->interrupt_mutex);
+		if (!force)
+			BUG_ON(dev->interrupt_count == 0);
+
+		if (force || --dev->interrupt_count == 0)
+			usb_kill_urb(dev->interrupt);
+
+		dev_dbg(&dev->udev->dev,
+			"decremented interrupt URB count to %d\n",
+			dev->interrupt_count);
+		mutex_unlock(&dev->interrupt_mutex);
+	}
+}
+
+void usbnet_status_stop(struct usbnet *dev)
+{
+	__usbnet_status_stop(dev, false);
+}
+EXPORT_SYMBOL_GPL(usbnet_status_stop);
+
 /* Passes this packet up the stack, updating its accounting.
  * Some link protocols batch packets, so their rx_fixup paths
  * can return clones as well as just modify the original skb.
@@ -725,7 +789,7 @@ int usbnet_stop (struct net_device *net)
 	if (!(info->flags & FLAG_AVOID_UNLINK_URBS))
 		usbnet_terminate_urbs(dev);
 
-	usb_kill_urb(dev->interrupt);
+	usbnet_status_stop(dev);
 
 	usbnet_purge_paused_rxq(dev);
 
@@ -787,7 +851,7 @@ int usbnet_open (struct net_device *net)
 
 	/* start any status interrupt transfer */
 	if (dev->interrupt) {
-		retval = usb_submit_urb (dev->interrupt, GFP_KERNEL);
+		retval = usbnet_status_start(dev, GFP_KERNEL);
 		if (retval < 0) {
 			netif_err(dev, ifup, dev->net,
 				  "intr submit %d\n", retval);
@@ -1430,6 +1494,8 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 	dev->delay.data = (unsigned long) dev;
 	init_timer (&dev->delay);
 	mutex_init (&dev->phy_mutex);
+	mutex_init(&dev->interrupt_mutex);
+	dev->interrupt_count = 0;
 
 	dev->net = net;
 	strcpy (net->name, "usb%d");
@@ -1565,7 +1631,7 @@ int usbnet_suspend (struct usb_interface *intf, pm_message_t message)
 		 */
 		netif_device_detach (dev->net);
 		usbnet_terminate_urbs(dev);
-		usb_kill_urb(dev->interrupt);
+		__usbnet_status_stop(dev, true);
 
 		/*
 		 * reattach so runtime management can use and
@@ -1585,9 +1651,8 @@ int usbnet_resume (struct usb_interface *intf)
 	int                     retval;
 
 	if (!--dev->suspend_count) {
-		/* resume interrupt URBs */
-		if (dev->interrupt && test_bit(EVENT_DEV_OPEN, &dev->flags))
-			usb_submit_urb(dev->interrupt, GFP_NOIO);
+		/* resume interrupt URBs if they were submitted at suspend */
+		__usbnet_status_start(dev, GFP_NOIO, true);
 
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
-- 
1.8.1.4
