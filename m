From: Per Hallsmark <per.hallsmark@t2data.se>
Subject: [PATCH] usbnet autosuspend
Date: Tue, 14 Oct 2008 10:28:31 +0200
Message-ID: <48F4582F.3010808@t2data.se>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090603030706090709080807"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.t2data.se ([212.247.174.230]:3732 "EHLO mail.t2data.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755490AbYJNIgq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Oct 2008 04:36:46 -0400
Received: from [94.191.142.252] by t2data.se (Cipher TLSv1:RC4-MD5:128) (MDaemon PRO v9.6.6)
	with ESMTP id md50000477611.msg
	for <netdev@vger.kernel.org>; Tue, 14 Oct 2008 10:28:34 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090603030706090709080807
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hello,

Per request this patch, which sent to linux-usb maillist, is also sent 
to this maillist.
In brief, patch enables autosuspend more aggresively in usbnet.

Best regards,
Per

--------------090603030706090709080807
Content-Type: text/x-diff;
 name="linux-2.6.27-usbnet-autosuspend.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.6.27-usbnet-autosuspend.patch"

diff -rup linux-2.6.27.orig/drivers/net/usb/usbnet.c linux-2.6.27/drivers/net/usb/usbnet.c
--- linux-2.6.27.orig/drivers/net/usb/usbnet.c	2008-10-10 00:13:53.000000000 +0200
+++ linux-2.6.27/drivers/net/usb/usbnet.c	2008-10-13 16:21:03.000000000 +0200
@@ -87,6 +87,8 @@ static int msg_level = -1;
 module_param (msg_level, int, 0);
 MODULE_PARM_DESC (msg_level, "Override default message level");
 
+static void waker(struct work_struct *work);
+
 /*-------------------------------------------------------------------------*/
 
 /* handles CDC Ethernet and many other network "bulk data" interfaces */
@@ -325,6 +327,7 @@ static void rx_submit (struct usbnet *de
 	if (netif_running (dev->net)
 			&& netif_device_present (dev->net)
 			&& !test_bit (EVENT_RX_HALT, &dev->flags)) {
+		usb_mark_last_busy(dev->udev);
 		switch (retval = usb_submit_urb (urb, GFP_ATOMIC)) {
 		case -EPIPE:
 			usbnet_defer_kevent (dev, EVENT_RX_HALT);
@@ -496,6 +499,7 @@ static void intr_complete (struct urb *u
 		return;
 
 	memset(urb->transfer_buffer, 0, urb->transfer_buffer_length);
+	usb_mark_last_busy(dev->udev);
 	status = usb_submit_urb (urb, GFP_ATOMIC);
 	if (status != 0 && netif_msg_timer (dev))
 		deverr(dev, "intr resubmit --> %d", status);
@@ -589,7 +593,10 @@ static int usbnet_stop (struct net_devic
 	dev->flags = 0;
 	del_timer_sync (&dev->delay);
 	tasklet_kill (&dev->bh);
-	usb_autopm_put_interface(dev->intf);
+
+	dev->used--;
+
+	dev->intf->needs_remote_wakeup = 0;
 
 	return 0;
 }
@@ -669,6 +676,12 @@ static int usbnet_open (struct net_devic
 
 	// delay posting reads until we're fully open
 	tasklet_schedule (&dev->bh);
+
+	dev->used++;
+
+	dev->intf->needs_remote_wakeup = 1;
+	usb_autopm_put_interface(dev->intf);
+
 	return retval;
 done:
 	usb_autopm_put_interface(dev->intf);
@@ -921,7 +934,7 @@ static void usbnet_tx_timeout (struct ne
 
 /*-------------------------------------------------------------------------*/
 
-static int usbnet_start_xmit (struct sk_buff *skb, struct net_device *net)
+static int __usbnet_start_xmit (struct sk_buff *skb, struct net_device *net)
 {
 	struct usbnet		*dev = netdev_priv(net);
 	int			length;
@@ -955,6 +968,7 @@ static int usbnet_start_xmit (struct sk_
 	entry->state = tx_start;
 	entry->length = length;
 
+	dev->tx_goingon = 1;
 	usb_fill_bulk_urb (urb, dev->udev, dev->out,
 			skb->data, skb->len, tx_complete, skb);
 
@@ -972,6 +986,7 @@ static int usbnet_start_xmit (struct sk_
 
 	spin_lock_irqsave (&dev->txq.lock, flags);
 
+	usb_mark_last_busy(dev->udev);
 	switch ((retval = usb_submit_urb (urb, GFP_ATOMIC))) {
 	case -EPIPE:
 		netif_stop_queue (net);
@@ -987,6 +1002,7 @@ static int usbnet_start_xmit (struct sk_
 		if (dev->txq.qlen >= TX_QLEN (dev))
 			netif_stop_queue (net);
 	}
+
 	spin_unlock_irqrestore (&dev->txq.lock, flags);
 
 	if (retval) {
@@ -1002,9 +1018,32 @@ drop:
 		devdbg (dev, "> tx, len %d, type 0x%x",
 			length, skb->protocol);
 	}
+
 	return retval;
 }
 
+static int usbnet_start_xmit(struct sk_buff *skb, struct net_device *net)
+{
+	struct usbnet		*dev = netdev_priv(net);
+	int			retval;
+	unsigned long		flags;
+
+	spin_lock_irqsave(&dev->txq.lock, flags);
+	if (dev->suspend_count) {
+		netif_stop_queue(net);
+		dev->tx_skb = skb;
+		if (!schedule_work (&dev->waker))
+			deverr(dev, "waker may have been dropped");
+		else
+			devdbg(dev, "waker scheduled");
+		spin_unlock_irqrestore(&dev->txq.lock, flags);
+		return NET_XMIT_SUCCESS;
+	}
+	spin_unlock_irqrestore(&dev->txq.lock, flags);
+
+	retval = __usbnet_start_xmit(skb, net);
+	return retval;
+}
 
 /*-------------------------------------------------------------------------*/
 
@@ -1024,6 +1063,7 @@ static void usbnet_bh (unsigned long par
 			rx_process (dev, skb);
 			continue;
 		case tx_done:
+			dev->tx_goingon = 0;
 		case rx_cleanup:
 			usb_free_urb (entry->urb);
 			dev_kfree_skb (skb);
@@ -1043,6 +1083,7 @@ static void usbnet_bh (unsigned long par
 	} else if (netif_running (dev->net)
 			&& netif_device_present (dev->net)
 			&& !timer_pending (&dev->delay)
+			&& !dev->suspend_count
 			&& !test_bit (EVENT_RX_HALT, &dev->flags)) {
 		int	temp = dev->rxq.qlen;
 		int	qlen = RX_QLEN (dev);
@@ -1161,6 +1202,7 @@ usbnet_probe (struct usb_interface *udev
 	dev->bh.func = usbnet_bh;
 	dev->bh.data = (unsigned long) dev;
 	INIT_WORK (&dev->kevent, kevent);
+	INIT_WORK (&dev->waker, waker);
 	dev->delay.function = usbnet_bh;
 	dev->delay.data = (unsigned long) dev;
 	init_timer (&dev->delay);
@@ -1269,24 +1311,62 @@ EXPORT_SYMBOL_GPL(usbnet_probe);
  * resume only when the last interface is resumed
  */
 
+static void waker(struct work_struct *work)
+{
+        struct usbnet *dev = container_of(work, struct usbnet, waker);
+
+        if (!usb_autopm_get_interface(dev->intf)) {
+                usb_autopm_put_interface(dev->intf);
+        } else {
+                devdbg(dev, "autoresume failed");
+        }
+}
+
+static void stop_traffic(struct usbnet *dev)
+{
+	int			temp;
+	DECLARE_WAIT_QUEUE_HEAD_ONSTACK (unlink_wakeup);
+	DECLARE_WAITQUEUE (wait, current);
+
+	// ensure there are no more active urbs
+	add_wait_queue (&unlink_wakeup, &wait);
+	dev->wait = &unlink_wakeup;
+	temp = unlink_urbs (dev, &dev->txq) + unlink_urbs (dev, &dev->rxq);
+
+	// maybe wait for deletions to finish.
+	while (!skb_queue_empty(&dev->rxq)
+			&& !skb_queue_empty(&dev->txq)
+			&& !skb_queue_empty(&dev->done)) {
+		msleep(UNLINK_TIMEOUT_MS);
+		if (netif_msg_ifdown (dev))
+			devdbg (dev, "waited for %d urb completions", temp);
+	}
+	dev->wait = NULL;
+	remove_wait_queue (&unlink_wakeup, &wait);
+
+	usb_kill_urb(dev->interrupt);
+}
+
 int usbnet_suspend (struct usb_interface *intf, pm_message_t message)
 {
 	struct usbnet		*dev = usb_get_intfdata(intf);
 
-	if (!dev->suspend_count++) {
-		/*
-		 * accelerate emptying of the rx and queues, to avoid
-		 * having everything error out.
-		 */
-		netif_device_detach (dev->net);
-		(void) unlink_urbs (dev, &dev->rxq);
-		(void) unlink_urbs (dev, &dev->txq);
-		/*
-		 * reattach so runtime management can use and
-		 * wake the device
-		 */
-		netif_device_attach (dev->net);
+	if (dev->suspend_count++)
+		return 0;
+
+	/* check for ongoing tx traffic */
+	if (dev->tx_goingon && dev->udev->auto_pm) {
+		dev->suspend_count--;
+		return -EBUSY;
 	}
+
+	stop_traffic(dev);
+
+	/* cancel work */
+	dev->flags = 0;
+	del_timer_sync(&dev->delay);
+	cancel_work_sync(&dev->kevent);
+
 	return 0;
 }
 EXPORT_SYMBOL_GPL(usbnet_suspend);
@@ -1294,9 +1374,41 @@ EXPORT_SYMBOL_GPL(usbnet_suspend);
 int usbnet_resume (struct usb_interface *intf)
 {
 	struct usbnet		*dev = usb_get_intfdata(intf);
+	int                     status;
+
+	devdbg(dev, "%s: begin", __FUNCTION__);
+
+	if (--dev->suspend_count)
+		return 0;
+
+	if (dev->used) {
+		status = init_status (dev, dev->intf);
+		if (status) {
+			devdbg(dev, "init_status failed");
+			return status;
+		}
+
+		/* start any status interrupt transfer */
+		if (dev->interrupt) {
+			status = usb_submit_urb (dev->interrupt, GFP_NOIO);
+			if (status < 0) {
+				devdbg(dev, "usb_submit intr urb failed");
+				return status;
+			}
+		}
+
+		tasklet_schedule(&dev->bh);
+
+		/* transmit package that triggered resume */
+		if (dev->tx_skb) {
+			status = __usbnet_start_xmit(dev->tx_skb, dev->net);
+			dev->tx_skb = NULL;
+		}
+
+		netif_wake_queue(dev->net);
+	}
 
-	if (!--dev->suspend_count)
-		tasklet_schedule (&dev->bh);
+	devdbg(dev, "%s: end", __FUNCTION__);
 
 	return 0;
 }
diff -rup linux-2.6.27.orig/include/linux/usb/usbnet.h linux-2.6.27/include/linux/usb/usbnet.h
--- linux-2.6.27.orig/include/linux/usb/usbnet.h	2008-10-10 00:13:53.000000000 +0200
+++ linux-2.6.27/include/linux/usb/usbnet.h	2008-10-13 16:18:26.000000000 +0200
@@ -64,6 +64,12 @@ struct usbnet {
 #		define EVENT_RX_MEMORY	2
 #		define EVENT_STS_SPLIT	3
 #		define EVENT_LINK_RESET	4
+
+	/* autosuspend helpers */
+	struct work_struct	waker;
+	int                     used;
+	int			tx_goingon;
+	struct sk_buff		*tx_skb; /* skb queued during suspend */
 };
 
 static inline struct usb_driver *driver_of(struct usb_interface *intf)

--------------090603030706090709080807--

