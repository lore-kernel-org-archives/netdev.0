From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: Re: [patch]USB autosuspend for cdc-ether
Date: Wed, 25 Nov 2009 09:39:33 +0100
Message-ID: <200911250939.33127.oliver@neukum.org>
References: <OFCBC12A15.7006C53A-ON80257678.00524557-80257678.005373C0@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org,
	"Torgny Johansson" <torgny.johansson-IzeFyvvaP7pWk0Htik3J/w@public.gmane.org>
To: Steve.Glendinning-sdUf+H5yV5I@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <OFCBC12A15.7006C53A-ON80257678.00524557-80257678.005373C0-sdUf+H5yV5I@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Dienstag, 24. November 2009 16:11:28 schrieb Steve.Glendinning-sdUf+H5yV5I@public.gmane.org:
> Interesting patch, I'm going to try and add support for this
> to smsc95xx.
> 
> A few things I noticed:
> 

Hi,

this version should fix what you mentioned.

	Regards
		Oliver

Signed-off-by: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>

--

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 21e1ba1..ed55024 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -411,6 +411,12 @@ static int cdc_bind(struct usbnet *dev, struct usb_interface *intf)
 	return 0;
 }
 
+static int cdc_manage_power(struct usbnet *dev, int on)
+{
+	dev->intf->needs_remote_wakeup = on;
+	return 0;
+}
+
 static const struct driver_info	cdc_info = {
 	.description =	"CDC Ethernet Device",
 	.flags =	FLAG_ETHER,
@@ -418,6 +424,7 @@ static const struct driver_info	cdc_info = {
 	.bind =		cdc_bind,
 	.unbind =	usbnet_cdc_unbind,
 	.status =	cdc_status,
+	.manage_power =	cdc_manage_power,
 };
 
 /*-------------------------------------------------------------------------*/
@@ -610,6 +617,7 @@ static struct usb_driver cdc_driver = {
 	.disconnect =	usbnet_disconnect,
 	.suspend =	usbnet_suspend,
 	.resume =	usbnet_resume,
+	.supports_autosuspend = 1,
 };
 
 
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index ca5ca5a..50a48e2 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -353,7 +353,8 @@ static void rx_submit (struct usbnet *dev, struct urb *urb, gfp_t flags)
 
 	if (netif_running (dev->net)
 			&& netif_device_present (dev->net)
-			&& !test_bit (EVENT_RX_HALT, &dev->flags)) {
+			&& !test_bit (EVENT_RX_HALT, &dev->flags)
+			&& !test_bit (EVENT_DEV_ASLEEP, &dev->flags)) {
 		switch (retval = usb_submit_urb (urb, GFP_ATOMIC)) {
 		case -EPIPE:
 			usbnet_defer_kevent (dev, EVENT_RX_HALT);
@@ -611,15 +612,39 @@ EXPORT_SYMBOL_GPL(usbnet_unlink_rx_urbs);
 /*-------------------------------------------------------------------------*/
 
 // precondition: never called in_interrupt
+static void usbnet_terminate_urbs(struct usbnet *dev)
+{
+	DECLARE_WAIT_QUEUE_HEAD_ONSTACK (unlink_wakeup);
+	DECLARE_WAITQUEUE (wait, current);
+	int temp;
+
+	/* ensure there are no more active urbs */
+	add_wait_queue(&unlink_wakeup, &wait);
+	set_current_state(TASK_UNINTERRUPTIBLE);
+	dev->wait = &unlink_wakeup;
+	temp = unlink_urbs(dev, &dev->txq) +
+		unlink_urbs(dev, &dev->rxq);
+
+	/* maybe wait for deletions to finish. */
+	while (!skb_queue_empty(&dev->rxq)
+		&& !skb_queue_empty(&dev->txq)
+		&& !skb_queue_empty(&dev->done)) {
+			schedule_timeout(UNLINK_TIMEOUT_MS);
+			set_current_state(TASK_UNINTERRUPTIBLE);
+			if (netif_msg_ifdown(dev))
+				devdbg(dev, "waited for %d urb completions",
+					temp);
+	}
+	set_current_state(TASK_RUNNING);
+	dev->wait = NULL;
+	remove_wait_queue(&unlink_wakeup, &wait);
+}
 
 int usbnet_stop (struct net_device *net)
 {
 	struct usbnet		*dev = netdev_priv(net);
 	struct driver_info	*info = dev->driver_info;
-	int			temp;
 	int			retval;
-	DECLARE_WAIT_QUEUE_HEAD_ONSTACK (unlink_wakeup);
-	DECLARE_WAITQUEUE (wait, current);
 
 	netif_stop_queue (net);
 
@@ -641,25 +666,8 @@ int usbnet_stop (struct net_device *net)
 				info->description);
 	}
 
-	if (!(info->flags & FLAG_AVOID_UNLINK_URBS)) {
-		/* ensure there are no more active urbs */
-		add_wait_queue(&unlink_wakeup, &wait);
-		dev->wait = &unlink_wakeup;
-		temp = unlink_urbs(dev, &dev->txq) +
-			unlink_urbs(dev, &dev->rxq);
-
-		/* maybe wait for deletions to finish. */
-		while (!skb_queue_empty(&dev->rxq)
-				&& !skb_queue_empty(&dev->txq)
-				&& !skb_queue_empty(&dev->done)) {
-			msleep(UNLINK_TIMEOUT_MS);
-			if (netif_msg_ifdown(dev))
-				devdbg(dev, "waited for %d urb completions",
-					temp);
-		}
-		dev->wait = NULL;
-		remove_wait_queue(&unlink_wakeup, &wait);
-	}
+	if (!(info->flags & FLAG_AVOID_UNLINK_URBS))
+		usbnet_terminate_urbs(dev);
 
 	usb_kill_urb(dev->interrupt);
 
@@ -672,7 +680,10 @@ int usbnet_stop (struct net_device *net)
 	dev->flags = 0;
 	del_timer_sync (&dev->delay);
 	tasklet_kill (&dev->bh);
-	usb_autopm_put_interface(dev->intf);
+	if (info->manage_power)
+		info->manage_power(dev, 0);
+	else
+		usb_autopm_put_interface(dev->intf);
 
 	return 0;
 }
@@ -753,6 +764,12 @@ int usbnet_open (struct net_device *net)
 
 	// delay posting reads until we're fully open
 	tasklet_schedule (&dev->bh);
+	if (info->manage_power) {
+		retval = info->manage_power(dev, 1);
+		if (retval < 0)
+			goto done;
+		usb_autopm_put_interface(dev->intf);
+	}
 	return retval;
 done:
 	usb_autopm_put_interface(dev->intf);
@@ -881,11 +898,16 @@ kevent (struct work_struct *work)
 	/* usb_clear_halt() needs a thread context */
 	if (test_bit (EVENT_TX_HALT, &dev->flags)) {
 		unlink_urbs (dev, &dev->txq);
+		status = usb_autopm_get_interface(dev->intf);
+		if (status < 0)
+			goto fail_pipe;
 		status = usb_clear_halt (dev->udev, dev->out);
+		usb_autopm_put_interface(dev->intf);
 		if (status < 0
 				&& status != -EPIPE
 				&& status != -ESHUTDOWN) {
 			if (netif_msg_tx_err (dev))
+fail_pipe:
 				deverr (dev, "can't clear tx halt, status %d",
 					status);
 		} else {
@@ -896,11 +918,16 @@ kevent (struct work_struct *work)
 	}
 	if (test_bit (EVENT_RX_HALT, &dev->flags)) {
 		unlink_urbs (dev, &dev->rxq);
+		status = usb_autopm_get_interface(dev->intf);
+		if (status < 0)
+			goto fail_halt;
 		status = usb_clear_halt (dev->udev, dev->in);
+		usb_autopm_put_interface(dev->intf);
 		if (status < 0
 				&& status != -EPIPE
 				&& status != -ESHUTDOWN) {
 			if (netif_msg_rx_err (dev))
+fail_halt:
 				deverr (dev, "can't clear rx halt, status %d",
 					status);
 		} else {
@@ -919,7 +946,12 @@ kevent (struct work_struct *work)
 			clear_bit (EVENT_RX_MEMORY, &dev->flags);
 		if (urb != NULL) {
 			clear_bit (EVENT_RX_MEMORY, &dev->flags);
+			status = usb_autopm_get_interface(dev->intf);
+			if (status < 0)
+				goto fail_lowmem;
 			rx_submit (dev, urb, GFP_KERNEL);
+			usb_autopm_put_interface(dev->intf);
+fail_lowmem:
 			tasklet_schedule (&dev->bh);
 		}
 	}
@@ -929,11 +961,18 @@ kevent (struct work_struct *work)
 		int			retval = 0;
 
 		clear_bit (EVENT_LINK_RESET, &dev->flags);
+		status = usb_autopm_get_interface(dev->intf);
+		if (status < 0)
+			goto skip_reset;
 		if(info->link_reset && (retval = info->link_reset(dev)) < 0) {
+			usb_autopm_put_interface(dev->intf);
+skip_reset:
 			devinfo(dev, "link reset failed (%d) usbnet usb-%s-%s, %s",
 				retval,
 				dev->udev->bus->bus_name, dev->udev->devpath,
 				info->description);
+		} else {
+			usb_autopm_put_interface(dev->intf);
 		}
 	}
 
@@ -971,6 +1010,7 @@ static void tx_complete (struct urb *urb)
 		case -EPROTO:
 		case -ETIME:
 		case -EILSEQ:
+			usb_mark_last_busy(dev->udev);
 			if (!timer_pending (&dev->delay)) {
 				mod_timer (&dev->delay,
 					jiffies + THROTTLE_JIFFIES);
@@ -987,6 +1027,7 @@ static void tx_complete (struct urb *urb)
 		}
 	}
 
+	usb_autopm_put_interface_async(dev->intf);
 	urb->dev = NULL;
 	entry->state = tx_done;
 	defer_bh(dev, skb, &dev->txq);
@@ -1058,13 +1099,33 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 	}
 
 	spin_lock_irqsave (&dev->txq.lock, flags);
+	retval = usb_autopm_get_interface_async(dev->intf);
+	if (retval < 0) {
+		spin_unlock_irqrestore (&dev->txq.lock, flags);
+		goto drop;
+	}
+
+#ifdef CONFIG_PM
+	/* if this triggers the device is still a sleep */
+	if (test_bit(EVENT_DEV_ASLEEP, &dev->flags)) {
+		/* transmission will be done in resume */
+		usb_anchor_urb(urb, &dev->deferred);
+		/* no use to process more packets */
+		netif_stop_queue(net);
+		spin_unlock_irqrestore(&dev->txq.lock, flags);
+		devdbg(dev, "Delaying transmission for resumption");
+		goto deferred;
+	}
+#endif
 
 	switch ((retval = usb_submit_urb (urb, GFP_ATOMIC))) {
 	case -EPIPE:
 		netif_stop_queue (net);
 		usbnet_defer_kevent (dev, EVENT_TX_HALT);
+		usb_autopm_put_interface_async(dev->intf);
 		break;
 	default:
+		usb_autopm_put_interface_async(dev->intf);
 		if (netif_msg_tx_err (dev))
 			devdbg (dev, "tx: submit urb err %d", retval);
 		break;
@@ -1088,6 +1149,7 @@ drop:
 		devdbg (dev, "> tx, len %d, type 0x%x",
 			length, skb->protocol);
 	}
+deferred:
 	return NETDEV_TX_OK;
 }
 EXPORT_SYMBOL_GPL(usbnet_start_xmit);
@@ -1255,6 +1317,7 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 	dev->bh.func = usbnet_bh;
 	dev->bh.data = (unsigned long) dev;
 	INIT_WORK (&dev->kevent, kevent);
+	init_usb_anchor(&dev->deferred);
 	dev->delay.function = usbnet_bh;
 	dev->delay.data = (unsigned long) dev;
 	init_timer (&dev->delay);
@@ -1363,13 +1426,23 @@ int usbnet_suspend (struct usb_interface *intf, pm_message_t message)
 	struct usbnet		*dev = usb_get_intfdata(intf);
 
 	if (!dev->suspend_count++) {
+		spin_lock_irq(&dev->txq.lock);
+		/* don't autosuspend while transmitting */
+		if (dev->txq.qlen && (message.event & PM_EVENT_AUTO)) {
+			spin_unlock_irq(&dev->txq.lock);
+			return -EBUSY;
+		} else {
+			set_bit(EVENT_DEV_ASLEEP, &dev->flags);
+			spin_unlock_irq(&dev->txq.lock);
+		}
 		/*
 		 * accelerate emptying of the rx and queues, to avoid
 		 * having everything error out.
 		 */
 		netif_device_detach (dev->net);
-		(void) unlink_urbs (dev, &dev->rxq);
-		(void) unlink_urbs (dev, &dev->txq);
+		usbnet_terminate_urbs(dev);
+		usb_kill_urb(dev->interrupt);
+		
 		/*
 		 * reattach so runtime management can use and
 		 * wake the device
@@ -1383,10 +1456,34 @@ EXPORT_SYMBOL_GPL(usbnet_suspend);
 int usbnet_resume (struct usb_interface *intf)
 {
 	struct usbnet		*dev = usb_get_intfdata(intf);
+	struct sk_buff          *skb;
+	struct urb              *res;
+	int                     retval;
+	
+	if (!--dev->suspend_count) {
+		spin_lock_irq(&dev->txq.lock);
+		while ((res = usb_get_from_anchor(&dev->deferred))) {
+
+			printk(KERN_INFO"Called %s with delayed data\n", __func__);
+			skb = (struct sk_buff *)res->context;
+			retval = usb_submit_urb(res, GFP_ATOMIC);
+			if (retval < 0) {
+				dev_kfree_skb_any(skb);
+				usb_free_urb(res);
+				usb_autopm_put_interface_async(dev->intf);
+			} else {
+				dev->net->trans_start = jiffies;
+				__skb_queue_tail (&dev->txq, skb);
+			}
+		}
 
-	if (!--dev->suspend_count)
+		smp_mb();
+		clear_bit(EVENT_DEV_ASLEEP, &dev->flags);
+		spin_unlock_irq(&dev->txq.lock);
+		if (!(dev->txq.qlen >= TX_QLEN(dev)))
+			netif_start_queue(dev->net);
 		tasklet_schedule (&dev->bh);
-
+	}
 	return 0;
 }
 EXPORT_SYMBOL_GPL(usbnet_resume);
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index f814730..e75ba0e 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -55,6 +55,7 @@ struct usbnet {
 	struct sk_buff_head	done;
 	struct sk_buff_head	rxq_pause;
 	struct urb		*interrupt;
+	struct usb_anchor	deferred;
 	struct tasklet_struct	bh;
 
 	struct work_struct	kevent;
@@ -65,6 +66,8 @@ struct usbnet {
 #		define EVENT_STS_SPLIT	3
 #		define EVENT_LINK_RESET	4
 #		define EVENT_RX_PAUSED	5
+#             define EVENT_DEV_WAKING 6 
+#             define EVENT_DEV_ASLEEP 7 
 };
 
 static inline struct usb_driver *driver_of(struct usb_interface *intf)
@@ -107,6 +110,9 @@ struct driver_info {
 	/* see if peer is connected ... can sleep */
 	int	(*check_connect)(struct usbnet *);
 
+	/* (dis)activate runtime power management */
+	int	(*manage_power)(struct usbnet *, int);
+
 	/* for status polling */
 	void	(*status)(struct usbnet *, struct urb *);
 
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
