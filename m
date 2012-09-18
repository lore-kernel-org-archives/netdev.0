From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [RFC PATCH v1 3/3] usbnet: support runtime PM triggered by link change
Date: Tue, 18 Sep 2012 22:23:21 +0800
Message-ID: <1347978201-6219-4-git-send-email-ming.lei@canonical.com>
References: <1347978201-6219-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>, Fink Dmitry <finik-l0cyMroinI0@public.gmane.org>,
	Rafael Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1347978201-6219-1-git-send-email-ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

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

Signed-off-by: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 drivers/net/usb/sierra_net.c |    3 +-
 drivers/net/usb/usbnet.c     |  269 +++++++++++++++++++++++++++++++++++++++++-
 include/linux/usb/usbnet.h   |   20 ++++
 3 files changed, 286 insertions(+), 6 deletions(-)

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
index dc4ff47..14aa39e 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -91,6 +91,12 @@ static int msg_level = -1;
 module_param (msg_level, int, 0);
 MODULE_PARM_DESC (msg_level, "Override default message level");
 
+/* link runtime PM: auto check time */
+static int link_autocheck_time = 3;
+module_param_named(autocheck, link_autocheck_time, int, 0644);
+MODULE_PARM_DESC(autocheck, "default link auto check time in second");
+
+
 /*-------------------------------------------------------------------------*/
 
 /* handles CDC Ethernet and many other network "bulk data" interfaces */
@@ -677,8 +683,228 @@ static void usbnet_terminate_urbs(struct usbnet *dev)
 	remove_wait_queue(&unlink_wakeup, &wait);
 }
 
-void usbnet_link_change(struct usbnet *dev, int link, int need_reset)
+void usbnet_link_updated(struct usbnet *dev)
+{
+	complete(&dev->link_update_completion);
+}
+EXPORT_SYMBOL(usbnet_link_updated);
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
 {
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
+	queue_delayed_work(system_freezable_wq, &dev->link_detect_work,
+			   link_autocheck_time * HZ);
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
+		spin_lock_irq(&dev->udev->dev.power.lock);
+		dev->old_autosuspend_delay =
+			dev->udev->dev.power.autosuspend_delay;
+		spin_unlock_irq(&dev->udev->dev.power.lock);
+		pm_runtime_set_autosuspend_delay(&dev->udev->dev, 1);
+	} else {
+		dev->intf->needs_remote_wakeup = 1;
+	}
+
+	if (!netif_carrier_ok(dev->net) && dev->link_rpm_supported) {
+		dev->link_open_suspend = 1;
+		usbnet_link_suspend(dev);
+	}
+}
+
+/* called by usbnet_stop */
+static void disable_link_runtime_pm(struct usbnet *dev)
+{
+	int delay;
+
+	if (!dev->link_rpm_enabled)
+		return;
+
+	dev->link_rpm_enabled = 0;
+	end_link_detect(dev, 1);
+
+	if (dev->link_open_suspend) {
+		usbnet_link_resume(dev);
+		dev->link_open_suspend = 0;
+	}
+
+	if (dev->link_remote_wakeup) {
+		dev->intf->needs_remote_wakeup = 0;
+		return;
+	}
+
+	spin_lock_irq(&dev->udev->dev.power.lock);
+	delay = dev->udev->dev.power.autosuspend_delay;
+	spin_unlock_irq(&dev->udev->dev.power.lock);
+
+	/*
+	 * If autosuspend delay has been changed after
+	 * enable_link_runtime_pm(), just keep the latest delay.
+	 *
+	 * FIXME: the delay might be changed after the above
+	 * lock is released and before the lock is held in
+	 * pm_runtime_set_autosuspend_delay(), looks no
+	 * big effect.
+	 */
+	if (delay == 1) {
+		delay = dev->old_autosuspend_delay;
+		pm_runtime_set_autosuspend_delay(&dev->udev->dev,
+						 delay);
+	}
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
+	if (dev->link_remote_wakeup &&
+	    !device_can_wakeup(&dev->udev->dev)) {
+		dev_err(&dev->udev->dev,
+			"I don't support remote wakeup\n");
+		dev->link_remote_wakeup = 0;
+	}
+
+	dev->link_state = 1;
+}
+
+static void __usbnet_link_change(struct usbnet *dev, int link,
+				 int need_reset)
+{
+	dev_dbg(&dev->intf->dev, "%s: old_link=%d link=%d\n", __func__,
+		dev->link_state, link);
+
 	if (link)
 		netif_carrier_on(dev->net);
 	else
@@ -686,6 +912,25 @@ void usbnet_link_change(struct usbnet *dev, int link, int need_reset)
 
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
+}
+
+void usbnet_link_change(struct usbnet *dev, int link, int need_reset)
+{
+	/*
+	 * Suppose the low level driver may support link runtime PM
+	 * if it can detect the link change via usbnet_link_change.
+	 */
+	dev->link_rpm_supported = 1;
+
+	__usbnet_link_change(dev, link, need_reset);
 }
 EXPORT_SYMBOL(usbnet_link_change);
 
@@ -731,8 +976,10 @@ int usbnet_stop (struct net_device *net)
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
@@ -807,6 +1054,9 @@ int usbnet_open (struct net_device *net)
 		if (retval < 0)
 			goto done_manage_power_error;
 		usb_autopm_put_interface(dev->intf);
+	} else {
+		if (need_link_runtime_pm(dev))
+			enable_link_runtime_pm(dev);
 	}
 	return retval;
 
@@ -1499,7 +1749,9 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 	netif_device_attach (net);
 
 	if (dev->driver_info->flags & FLAG_LINK_INTR)
-		usbnet_link_change(dev, 0, 0);
+		__usbnet_link_change(dev, 0, 0);
+
+	init_link_rpm(dev);
 
 	return 0;
 
@@ -1550,6 +1802,9 @@ int usbnet_suspend (struct usb_interface *intf, pm_message_t message)
 		 * wake the device
 		 */
 		netif_device_attach (dev->net);
+
+		if (PMSG_IS_AUTO(message))
+			start_link_detect(dev);
 	}
 	return 0;
 }
@@ -1564,8 +1819,10 @@ int usbnet_resume (struct usb_interface *intf)
 
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
@@ -1598,6 +1855,8 @@ int usbnet_resume (struct usb_interface *intf)
 				netif_tx_wake_all_queues(dev->net);
 			tasklet_schedule (&dev->bh);
 		}
+
+		end_link_detect(dev, 0);
 	}
 	return 0;
 }
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index 1937b74..d23dae5 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -68,6 +68,19 @@ struct usbnet {
 #		define EVENT_RX_PAUSED	5
 #		define EVENT_DEV_ASLEEP 6
 #		define EVENT_DEV_OPEN	7
+
+	/* link down triggered runtime PM */
+	struct delayed_work	link_detect_work;
+	struct completion	link_update_completion;
+	int			link_update_timeout;
+	int			old_autosuspend_delay;
+	unsigned int		link_rpm_supported:1;
+	unsigned int		link_rpm_enabled:1;
+	unsigned int		link_check_started:1;
+	unsigned int		link_checking:1;
+	unsigned int		link_open_suspend:1;
+	unsigned int		link_state:1;
+	unsigned int		link_remote_wakeup:1;
 };
 
 static inline struct usb_driver *driver_of(struct usb_interface *intf)
@@ -106,6 +119,12 @@ struct driver_info {
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
 
@@ -161,6 +180,7 @@ extern int usbnet_suspend(struct usb_interface *, pm_message_t);
 extern int usbnet_resume(struct usb_interface *);
 extern void usbnet_disconnect(struct usb_interface *);
 extern void usbnet_link_change(struct usbnet *dev, int link, int need_reset);
+extern void usbnet_link_updated(struct usbnet *dev);
 
 /* Drivers that reuse some of the standard USB CDC infrastructure
  * (notably, using multiple interfaces according to the CDC
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
