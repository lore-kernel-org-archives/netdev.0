From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/2 v6 RESEND] usbnet: allow status interrupt URB to always
 be active
Date: Mon, 06 May 2013 16:29:23 -0500
Message-ID: <1367875763.31762.9.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-usb <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Rory Filer <rfiler-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>,
	Phil Sutter <phil-ydcDiazATMQ@public.gmane.org>
To: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

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

Signed-off-by: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
NOTE: Oliver already ACK-ed this series, but Ming disagreed about the
mem_flags argument to usbnet_status_start() and consensus seems far away;
given that it's not userspace API/ABI, I'd like to see the series go in.

 drivers/net/usb/usbnet.c   | 77 ++++++++++++++++++++++++++++++++++++++++++----
 include/linux/usb/usbnet.h |  5 +++
 2 files changed, 76 insertions(+), 6 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 1e5a9b7..f95cb03 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -252,6 +252,70 @@ static int init_status (struct usbnet *dev, struct usb_interface *intf)
 	return 0;
 }
 
+/* Submit the interrupt URB if not previously submitted, increasing refcount */
+int usbnet_status_start(struct usbnet *dev, gfp_t mem_flags)
+{
+	int ret = 0;
+
+	WARN_ON_ONCE(dev->interrupt == NULL);
+	if (dev->interrupt) {
+		mutex_lock(&dev->interrupt_mutex);
+
+		if (++dev->interrupt_count == 1)
+			ret = usb_submit_urb(dev->interrupt, mem_flags);
+
+		dev_dbg(&dev->udev->dev, "incremented interrupt URB count to %d\n",
+			dev->interrupt_count);
+		mutex_unlock(&dev->interrupt_mutex);
+	}
+	return ret;
+}
+EXPORT_SYMBOL_GPL(usbnet_status_start);
+
+/* For resume; submit interrupt URB if previously submitted */
+static int __usbnet_status_start_force(struct usbnet *dev, gfp_t mem_flags)
+{
+	int ret = 0;
+
+	mutex_lock(&dev->interrupt_mutex);
+	if (dev->interrupt_count) {
+		ret = usb_submit_urb(dev->interrupt, mem_flags);
+		dev_dbg(&dev->udev->dev,
+			"submitted interrupt URB for resume\n");
+	}
+	mutex_unlock(&dev->interrupt_mutex);
+	return ret;
+}
+
+/* Kill the interrupt URB if all submitters want it killed */
+void usbnet_status_stop(struct usbnet *dev)
+{
+	if (dev->interrupt) {
+		mutex_lock(&dev->interrupt_mutex);
+		WARN_ON(dev->interrupt_count == 0);
+
+		if (dev->interrupt_count && --dev->interrupt_count == 0)
+			usb_kill_urb(dev->interrupt);
+
+		dev_dbg(&dev->udev->dev,
+			"decremented interrupt URB count to %d\n",
+			dev->interrupt_count);
+		mutex_unlock(&dev->interrupt_mutex);
+	}
+}
+EXPORT_SYMBOL_GPL(usbnet_status_stop);
+
+/* For suspend; always kill interrupt URB */
+static void __usbnet_status_stop_force(struct usbnet *dev)
+{
+	if (dev->interrupt) {
+		mutex_lock(&dev->interrupt_mutex);
+		usb_kill_urb(dev->interrupt);
+		dev_dbg(&dev->udev->dev, "killed interrupt URB for suspend\n");
+		mutex_unlock(&dev->interrupt_mutex);
+	}
+}
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
@@ -1458,6 +1522,8 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 	dev->delay.data = (unsigned long) dev;
 	init_timer (&dev->delay);
 	mutex_init (&dev->phy_mutex);
+	mutex_init(&dev->interrupt_mutex);
+	dev->interrupt_count = 0;
 
 	dev->net = net;
 	strcpy (net->name, "usb%d");
@@ -1593,7 +1659,7 @@ int usbnet_suspend (struct usb_interface *intf, pm_message_t message)
 		 */
 		netif_device_detach (dev->net);
 		usbnet_terminate_urbs(dev);
-		usb_kill_urb(dev->interrupt);
+		__usbnet_status_stop_force(dev);
 
 		/*
 		 * reattach so runtime management can use and
@@ -1613,9 +1679,8 @@ int usbnet_resume (struct usb_interface *intf)
 	int                     retval;
 
 	if (!--dev->suspend_count) {
-		/* resume interrupt URBs */
-		if (dev->interrupt && test_bit(EVENT_DEV_OPEN, &dev->flags))
-			usb_submit_urb(dev->interrupt, GFP_NOIO);
+		/* resume interrupt URB if it was previously submitted */
+		__usbnet_status_start_force(dev, GFP_NOIO);
 
 		spin_lock_irq(&dev->txq.lock);
 		while ((res = usb_get_from_anchor(&dev->deferred))) {
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index da46327..3af84ec 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -56,6 +56,8 @@ struct usbnet {
 	struct sk_buff_head	done;
 	struct sk_buff_head	rxq_pause;
 	struct urb		*interrupt;
+	unsigned		interrupt_count;
+	struct mutex		interrupt_mutex;
 	struct usb_anchor	deferred;
 	struct tasklet_struct	bh;
 
@@ -248,4 +250,7 @@ extern int usbnet_nway_reset(struct net_device *net);
 extern int usbnet_manage_power(struct usbnet *, int);
 extern void usbnet_link_change(struct usbnet *, bool, bool);
 
+extern int usbnet_status_start(struct usbnet *dev, gfp_t mem_flags);
+extern void usbnet_status_stop(struct usbnet *dev);
+
 #endif /* __LINUX_USB_USBNET_H */
-- 
1.8.1.4


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
