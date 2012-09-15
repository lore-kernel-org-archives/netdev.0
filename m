From: Ming Lei <ming.lei@canonical.com>
Subject: [RFC PATCH 3/3] usbnet: support runtime PM triggered by link change
Date: Sun, 16 Sep 2012 01:48:19 +0800
Message-ID: <1347731299-29898-4-git-send-email-ming.lei@canonical.com>
References: <1347731299-29898-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>, Fink Dmitry <finik@ti.com>,
	Rafael Wysocki <rjw@sisk.pl>,
	Alan Stern <stern@rowland.harvard.edu>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Ming Lei <ming.lei@canonical.com>
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:37685 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754287Ab2IORs7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Sep 2012 13:48:59 -0400
In-Reply-To: <1347731299-29898-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements runtime PM triggered by link change event
for devices which haven't defined manage_power() callback, based
on the below consideration:

- this kind of runtime PM has been supported by some PCI network
interfaces already, and it does make sense to suspend the usb
device to save power if no link is detected

- link down triggered runtime needn't to be implemented for devices
which have already supported traffic based runtime PM by .manage_power,
because runtime suspend can be triggered when no tx frames are to be
transmitted after link becoms down.

Unfortunately, some usbnet devices don't support remote wakeup,
or some devices may support it but the remote wakup can't be enabled
for link change event for some reason(no documents are public, not
supported ...).

This patch takes a periodic timer to wake up devices for detecting
the link change event if remote wakeup by link change can't be
supported. If the link is found to be down, put the device into
suspend immediately.

For the devices which support remote wakeup by link change and
don't support remote wakeup by incoming packets(not implement
manage_power callback), the patch can still make link change
triggered runtime PM working on these devices.

Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/net/usb/sierra_net.c |    3 +-
 drivers/net/usb/usbnet.c     |  211 +++++++++++++++++++++++++++++++++++++++++-
 include/linux/usb/usbnet.h   |   19 ++++
 3 files changed, 229 insertions(+), 4 deletions(-)

diff --git a/drivers/net/usb/sierra_net.c b/drivers/net/usb/sierra_net.c
index 08ed9e5..0993f2d 100644
--- a/drivers/net/usb/sierra_net.c
+++ b/drivers/net/usb/sierra_net.c
@@ -418,6 +418,7 @@ static void sierra_net_handle_lsi(struct usbnet *dev, char *data,
 		priv->link_up = 0;
 	}
 	usbnet_link_change(dev, link_up, 0);
+	usbnet_link_updated(dev);
 }
 
 static void sierra_net_dosync(struct usbnet *dev)
@@ -915,7 +916,7 @@ static struct sk_buff *sierra_net_tx_fixup(struct usbnet *dev,
 
 static const struct driver_info sierra_net_info_direct_ip = {
 	.description = "Sierra Wireless USB-to-WWAN Modem",
-	.flags = FLAG_WWAN | FLAG_SEND_ZLP,
+	.flags = FLAG_WWAN | FLAG_SEND_ZLP | FLAG_LINK_UPDATE_BY_DRIVER,
 	.bind = sierra_net_bind,
 	.unbind = sierra_net_unbind,
 	.status = sierra_net_status,
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 054ffd8..8db1618 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -677,6 +677,186 @@ static void usbnet_terminate_urbs(struct usbnet *dev)
 	remove_wait_queue(&unlink_wakeup, &wait);
 }
 
+void usbnet_link_updated(struct usbnet *dev)
+{
+	complete(&dev->link_update_completion);
+}
+EXPORT_SYMBOL_GPL(usbnet_link_updated);
+
+#define usbnet_link_suspend(dev) do { \
+	dev_dbg(&dev->intf->dev, "%s:link suspend", __func__); \
+	usb_autopm_put_interface_async(dev->intf); \
+} while(0)
+
+#define usbnet_link_resume(dev) do { \
+	dev_dbg(&dev->intf->dev, "%s:link resume", __func__); \
+	usb_autopm_get_interface_async(dev->intf); \
+} while(0)
+
+static int need_link_runtime_pm(struct usbnet *dev)
+{
+	if (dev->driver_info->manage_power)
+		return 0;
+
+	if (!dev->driver_info->status)
+		return 0;
+
+	return 1;
+}
+
+/* called by usbnet_suspend */
+static void start_link_detect(struct usbnet *dev)
+{
+	if (!dev->link_rpm_enabled)
+		return;
+
+	if (dev->link_remote_wakeup)
+		return;
+
+	if (dev->link_check_started)
+		return;
+
+	dev->link_check_started = 1;
+	schedule_delayed_work(&dev->link_detect_work,
+			      msecs_to_jiffies(3000));
+}
+
+/* called by usbnet_resume */
+static void end_link_detect(struct usbnet *dev, int force_cancel)
+{
+	if (!dev->link_rpm_enabled)
+		return;
+
+	if (!dev->link_check_started)
+		return;
+
+	/*
+	 * cancel the link detect work if usbnet is resumed
+	 * not by link detect work
+	 */
+	if (!dev->link_checking || force_cancel)
+		cancel_delayed_work_sync(&dev->link_detect_work);
+
+	dev->link_check_started = 0;
+}
+
+/* called by usbnet_open */
+static void enable_link_runtime_pm(struct usbnet *dev)
+{
+	dev->link_rpm_enabled = 1;
+
+	if (!dev->link_remote_wakeup) {
+		dev->old_autosuspend_delay =
+			dev->udev->dev.power.autosuspend_delay;
+		pm_runtime_set_autosuspend_delay(&dev->udev->dev, 1);
+	}
+
+	if (!netif_carrier_ok(dev->net)) {
+		dev->link_open_suspend = 1;
+		usbnet_link_suspend(dev);
+	}
+}
+
+/* called by usbnet_stop */
+static void disable_link_runtime_pm(struct usbnet *dev)
+{
+	if (!dev->link_rpm_enabled)
+		return;
+	dev->link_rpm_enabled = 0;
+	end_link_detect(dev, 1);
+	if (dev->link_open_suspend) {
+		usbnet_link_resume(dev);
+		dev->link_open_suspend = 0;
+	}
+	if (!dev->link_remote_wakeup)
+		pm_runtime_set_autosuspend_delay(&dev->udev->dev,
+						 dev->old_autosuspend_delay);
+}
+
+static void update_link_state(struct usbnet *dev)
+{
+	char		*buf = NULL;
+	unsigned	pipe = 0;
+	unsigned	maxp;
+	int		ret, act_len, timeout;
+	struct urb	urb;
+
+	pipe = usb_rcvintpipe(dev->udev,
+			      dev->status->desc.bEndpointAddress
+				& USB_ENDPOINT_NUMBER_MASK);
+	maxp = usb_maxpacket(dev->udev, pipe, 0);
+
+	/*
+	 * Take default timeout as 2 times of period.
+	 * It is observed that asix device can update its link
+	 * state duing one period(128ms). Low level driver can set
+	 * its default update link time in bind() callback.
+	 */
+	if (!dev->link_update_timeout) {
+		timeout = max((int) dev->status->desc.bInterval,
+			(dev->udev->speed == USB_SPEED_HIGH) ? 7 : 3);
+		timeout = 1 << timeout;
+		if (dev->udev->speed == USB_SPEED_HIGH)
+			timeout /= 8;
+		if (timeout < 128)
+			timeout = 128;
+	} else
+		timeout = dev->link_update_timeout;
+
+	buf = kmalloc(maxp, GFP_KERNEL);
+	if (!buf)
+		return;
+
+	dev_dbg(&dev->intf->dev, "%s: timeout %dms\n", __func__, timeout);
+	ret = usb_interrupt_msg(dev->udev, pipe, buf, maxp,
+			&act_len, timeout);
+	if (!ret) {
+		urb.status = 0;
+		urb.actual_length = act_len;
+		urb.transfer_buffer = buf;
+		urb.transfer_buffer_length = maxp;
+		dev->driver_info->status(dev, &urb);
+		if (dev->driver_info->flags &
+		    FLAG_LINK_UPDATE_BY_DRIVER)
+			wait_for_completion(&dev->link_update_completion);
+		dev_dbg(&dev->intf->dev, "%s: link updated\n", __func__);
+	} else
+		dev_dbg(&dev->intf->dev, "%s: link update failed %d\n",
+				__func__, ret);
+	kfree(buf);
+}
+
+static void link_detect_work(struct work_struct *work)
+{
+	struct usbnet	*dev = container_of(work, struct usbnet,
+					    link_detect_work.work);
+
+	dev_dbg(&dev->intf->dev, "%s: link resume\n", __func__);
+
+	dev->link_checking = 1;
+	usb_autopm_get_interface(dev->intf);
+	update_link_state(dev);
+	dev->link_checking = 0;
+
+	dev_dbg(&dev->intf->dev, "%s: link state %d\n",
+		__func__, netif_carrier_ok(dev->net));
+
+	if (!netif_carrier_ok(dev->net))
+		usb_autopm_put_interface(dev->intf);
+	else
+		usb_submit_urb(dev->interrupt, GFP_NOIO);
+}
+
+static void init_link_rpm(struct usbnet *dev)
+{
+	INIT_DELAYED_WORK(&dev->link_detect_work, link_detect_work);
+	init_completion(&dev->link_update_completion);
+
+	dev->link_remote_wakeup = !!(dev->driver_info->flags &
+				  FLAG_LINK_SUPPORT_REMOTE_WAKEUP);
+	dev->link_state = 1;
+}
+
 int usbnet_stop (struct net_device *net)
 {
 	struct usbnet		*dev = netdev_priv(net);
@@ -719,8 +899,10 @@ int usbnet_stop (struct net_device *net)
 	tasklet_kill (&dev->bh);
 	if (info->manage_power)
 		info->manage_power(dev, 0);
-	else
+	else {
+		disable_link_runtime_pm(dev);
 		usb_autopm_put_interface(dev->intf);
+	}
 
 	return 0;
 }
@@ -795,6 +977,9 @@ int usbnet_open (struct net_device *net)
 		if (retval < 0)
 			goto done_manage_power_error;
 		usb_autopm_put_interface(dev->intf);
+	} else {
+		if (need_link_runtime_pm(dev))
+			enable_link_runtime_pm(dev);
 	}
 	return retval;
 
@@ -1489,6 +1674,8 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 	if (dev->driver_info->flags & FLAG_LINK_INTR)
 		usbnet_link_change(dev, 0, 0);
 
+	init_link_rpm(dev);
+
 	return 0;
 
 out4:
@@ -1538,6 +1725,9 @@ int usbnet_suspend (struct usb_interface *intf, pm_message_t message)
 		 * wake the device
 		 */
 		netif_device_attach (dev->net);
+
+		if (PMSG_IS_AUTO(message))
+			start_link_detect(dev);
 	}
 	return 0;
 }
@@ -1552,8 +1742,10 @@ int usbnet_resume (struct usb_interface *intf)
 
 	if (!--dev->suspend_count) {
 		/* resume interrupt URBs */
-		if (dev->interrupt && test_bit(EVENT_DEV_OPEN, &dev->flags))
-			usb_submit_urb(dev->interrupt, GFP_NOIO);
+		if (dev->interrupt && test_bit(EVENT_DEV_OPEN, &dev->flags)) {
+			if (!dev->link_checking)
+				usb_submit_urb(dev->interrupt, GFP_NOIO);
+		}
 
 		spin_lock_irq(&dev->txq.lock);
 		while ((res = usb_get_from_anchor(&dev->deferred))) {
@@ -1586,6 +1778,8 @@ int usbnet_resume (struct usb_interface *intf)
 				netif_tx_wake_all_queues(dev->net);
 			tasklet_schedule (&dev->bh);
 		}
+
+		end_link_detect(dev, 0);
 	}
 	return 0;
 }
@@ -1593,6 +1787,9 @@ EXPORT_SYMBOL_GPL(usbnet_resume);
 
 void usbnet_link_change(struct usbnet *dev, int link, int need_reset)
 {
+	dev_dbg(&dev->intf->dev, "%s: old_link=%d link=%d\n", __func__,
+		dev->link_state, link);
+
 	if (link)
 		netif_carrier_on(dev->net);
 	else
@@ -1600,6 +1797,14 @@ void usbnet_link_change(struct usbnet *dev, int link, int need_reset)
 
 	if (need_reset && link)
 		usbnet_defer_kevent(dev, EVENT_LINK_RESET);
+
+	if (dev->link_rpm_enabled) {
+		if (!link && dev->link_state)
+			usbnet_link_suspend(dev);
+		else if (link && !dev->link_state && dev->link_remote_wakeup)
+			usbnet_link_resume(dev);
+	}
+	dev->link_state = link;
 }
 EXPORT_SYMBOL_GPL(usbnet_link_change);
 
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index 1937b74..c96a623 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -68,6 +68,18 @@ struct usbnet {
 #		define EVENT_RX_PAUSED	5
 #		define EVENT_DEV_ASLEEP 6
 #		define EVENT_DEV_OPEN	7
+
+	/* link down triggered runtime PM */
+	struct delayed_work	link_detect_work;
+	struct completion	link_update_completion;
+	int			link_update_timeout;
+	int			old_autosuspend_delay;
+	unsigned int		link_rpm_enabled:1;
+	unsigned int		link_check_started:1;
+	unsigned int		link_checking:1;
+	unsigned int		link_open_suspend:1;
+	unsigned int		link_state:1;
+	unsigned int		link_remote_wakeup:1;
 };
 
 static inline struct usb_driver *driver_of(struct usb_interface *intf)
@@ -106,6 +118,12 @@ struct driver_info {
 #define FLAG_MULTI_PACKET	0x2000
 #define FLAG_RX_ASSEMBLE	0x4000	/* rx packets may span >1 frames */
 
+/* some drivers may not update link state in .status */
+#define FLAG_LINK_UPDATE_BY_DRIVER	0x8000
+
+/* device support remote wakeup by link change */
+#define FLAG_LINK_SUPPORT_REMOTE_WAKEUP	0x10000
+
 	/* init device ... can sleep, or cause probe() failure */
 	int	(*bind)(struct usbnet *, struct usb_interface *);
 
@@ -161,6 +179,7 @@ extern int usbnet_suspend(struct usb_interface *, pm_message_t);
 extern int usbnet_resume(struct usb_interface *);
 extern void usbnet_disconnect(struct usb_interface *);
 extern void usbnet_link_change(struct usbnet *dev, int link, int need_reset);
+extern void usbnet_link_updated(struct usbnet *dev);
 
 /* Drivers that reuse some of the standard USB CDC infrastructure
  * (notably, using multiple interfaces according to the CDC
-- 
1.7.9.5
