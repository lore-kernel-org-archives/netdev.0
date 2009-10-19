From: Oliver Neukum <oliver@neukum.org>
Subject: [rft]aggressive power management for cdc-ether
Date: Mon, 19 Oct 2009 15:51:46 +0200
Message-ID: <200910191551.46300.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Brownell <dbrownell@users.sourceforge.net>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:54405 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751534AbZJSNtp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2009 09:49:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this implements usb autosuspend for online cdc-ether devices
that support remote wakeup? What do you think?

	Regards
		Oliver

--

commit 956c214d266fc1764ceb931b039c7aadded4eb24
Author: Oliver Neukum <oliver@neukum.org>
Date:   Mon Oct 19 15:07:54 2009 +0200

    usb:usbnet&cdc-ether:full aggressive autosuspend
    
    autosuspend for cdc-ether devices while online if
    the device supports remote wakeup

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 4a6aff5..8ee5bd7 100644
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
@@ -570,6 +577,7 @@ static struct usb_driver cdc_driver = {
 	.disconnect =	usbnet_disconnect,
 	.suspend =	usbnet_suspend,
 	.resume =	usbnet_resume,
+	.supports_autosuspend = 1,
 };
 
 
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index ca5ca5a..c9938d5 100644
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
@@ -611,15 +612,36 @@ EXPORT_SYMBOL_GPL(usbnet_unlink_rx_urbs);
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
+	dev->wait = &unlink_wakeup;
+	temp = unlink_urbs(dev, &dev->txq) +
+		unlink_urbs(dev, &dev->rxq);
+
+	/* maybe wait for deletions to finish. */
+	while (!skb_queue_empty(&dev->rxq)
+		&& !skb_queue_empty(&dev->txq)
+		&& !skb_queue_empty(&dev->done)) {
+			schedule_timeout(UNLINK_TIMEOUT_MS);
+			if (netif_msg_ifdown(dev))
+				devdbg(dev, "waited for %d urb completions",
+					temp);
+	}
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
 
@@ -641,25 +663,8 @@ int usbnet_stop (struct net_device *net)
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
 
@@ -672,7 +677,10 @@ int usbnet_stop (struct net_device *net)
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
@@ -753,6 +761,12 @@ int usbnet_open (struct net_device *net)
 
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
@@ -882,6 +896,7 @@ kevent (struct work_struct *work)
 	if (test_bit (EVENT_TX_HALT, &dev->flags)) {
 		unlink_urbs (dev, &dev->txq);
 		status = usb_clear_halt (dev->udev, dev->out);
+		usb_autopm_put_interface(dev->intf);
 		if (status < 0
 				&& status != -EPIPE
 				&& status != -ESHUTDOWN) {
@@ -953,17 +968,20 @@ static void tx_complete (struct urb *urb)
 	if (urb->status == 0) {
 		dev->net->stats.tx_packets++;
 		dev->net->stats.tx_bytes += entry->length;
+		usb_autopm_put_interface_async(dev->intf);
 	} else {
 		dev->net->stats.tx_errors++;
 
 		switch (urb->status) {
 		case -EPIPE:
+			/* we do not allow autosuspension */
 			usbnet_defer_kevent (dev, EVENT_TX_HALT);
 			break;
 
 		/* software-driven interface shutdown */
 		case -ECONNRESET:		// async unlink
 		case -ESHUTDOWN:		// hardware gone
+			usb_autopm_put_interface_async(dev->intf);
 			break;
 
 		// like rx, tx gets controller i/o faults during khubd delays
@@ -971,6 +989,7 @@ static void tx_complete (struct urb *urb)
 		case -EPROTO:
 		case -ETIME:
 		case -EILSEQ:
+			usb_mark_last_busy(dev->udev);
 			if (!timer_pending (&dev->delay)) {
 				mod_timer (&dev->delay,
 					jiffies + THROTTLE_JIFFIES);
@@ -979,8 +998,10 @@ static void tx_complete (struct urb *urb)
 							urb->status);
 			}
 			netif_stop_queue (dev->net);
+			usb_autopm_put_interface_async(dev->intf);
 			break;
 		default:
+			usb_autopm_put_interface_async(dev->intf);
 			if (netif_msg_tx_err (dev))
 				devdbg (dev, "tx err %d", entry->urb->status);
 			break;
@@ -1058,6 +1079,23 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
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
+		dev->deferred = urb;
+		/* no use to process more packets */
+		netif_stop_queue(net);
+		spin_unlock_irqrestore(&dev->txq.lock, flags);
+		goto deferred;
+	}
+#endif
 
 	switch ((retval = usb_submit_urb (urb, GFP_ATOMIC))) {
 	case -EPIPE:
@@ -1088,6 +1126,7 @@ drop:
 		devdbg (dev, "> tx, len %d, type 0x%x",
 			length, skb->protocol);
 	}
+deferred:
 	return NETDEV_TX_OK;
 }
 EXPORT_SYMBOL_GPL(usbnet_start_xmit);
@@ -1363,13 +1402,23 @@ int usbnet_suspend (struct usb_interface *intf, pm_message_t message)
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
@@ -1383,10 +1432,32 @@ EXPORT_SYMBOL_GPL(usbnet_suspend);
 int usbnet_resume (struct usb_interface *intf)
 {
 	struct usbnet		*dev = usb_get_intfdata(intf);
-
-	if (!--dev->suspend_count)
+	struct sk_buff          *skb;
+	struct urb              *res;
+	int                     retval;
+	
+	if (!--dev->suspend_count) {
+		spin_lock_irq(&dev->txq.lock);
+		res = dev->deferred;
+		dev->deferred = NULL;
+		clear_bit(EVENT_DEV_ASLEEP, &dev->flags);
+		spin_unlock_irq(&dev->txq.lock);
+		if (res) {
+			retval = usb_submit_urb(res, GFP_NOIO);
+			if (retval < 0) {
+				usb_free_urb(res);
+				netif_start_queue(dev->net);
+				usb_autopm_put_interface_async(dev->intf);
+			} else {
+				skb = (struct sk_buff *)res->context;
+				dev->net->trans_start = jiffies;
+				__skb_queue_tail (&dev->txq, skb);
+				if (!(dev->txq.qlen >= TX_QLEN(dev)))
+					netif_start_queue(dev->net);
+			}
+		}
 		tasklet_schedule (&dev->bh);
-
+	}
 	return 0;
 }
 EXPORT_SYMBOL_GPL(usbnet_resume);
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index f814730..e418c0b 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -55,6 +55,7 @@ struct usbnet {
 	struct sk_buff_head	done;
 	struct sk_buff_head	rxq_pause;
 	struct urb		*interrupt;
+	struct urb		*deferred;
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
 

