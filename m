From: Eugene Shatokhin <eugene.shatokhin@rosalab.ru>
Subject: [PATCH] usbnet: Fix two races between usbnet_stop() and the BH
Date: Fri, 14 Aug 2015 19:58:36 +0300
Message-ID: <1439571516-11862-1-git-send-email-eugene.shatokhin@rosalab.ru>
References: <55CE1D7E.2070400@rosalab.ru>
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Eugene Shatokhin <eugene.shatokhin@rosalab.ru>
To: Oliver Neukum <oneukum@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from collab.rosalab.ru ([195.19.76.181]:34371 "EHLO
	collab.rosalab.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755509AbbHNQ7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 12:59:24 -0400
In-Reply-To: <55CE1D7E.2070400@rosalab.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both races may happen when a device (e.g. YOTA 4G LTE Modem) is
unplugged while the system is downloading a large file from the Net.

Hardware breakpoints and Kprobes with delays were used to confirm that
the races do actually happen.

1. The first race is on skb_queue ('next' pointer) between usbnet_stop()
and rx_complete(), which, in turn, calls usbnet_bh().

Here is a part of the call stack with the code where the changes to the
queue happen. The line numbers are for the kernel 4.1.0:

*0 __skb_unlink (skbuff.h:1517)
    prev->next = next;
*1 defer_bh (usbnet.c:430)
    spin_lock_irqsave(&list->lock, flags);
    old_state = entry->state;
    entry->state = state;
    __skb_unlink(skb, list);
    spin_unlock(&list->lock);
    spin_lock(&dev->done.lock);
    __skb_queue_tail(&dev->done, skb);
    if (dev->done.qlen == 1)
        tasklet_schedule(&dev->bh);
    spin_unlock_irqrestore(&dev->done.lock, flags);
*2 rx_complete (usbnet.c:640)
    state = defer_bh(dev, skb, &dev->rxq, state);

At the same time, the following code repeatedly checks if the queue is
empty and reads these values concurrently with the above changes:

*0  usbnet_terminate_urbs (usbnet.c:765)
    /* maybe wait for deletions to finish. */
    while (!skb_queue_empty(&dev->rxq)
        && !skb_queue_empty(&dev->txq)
        && !skb_queue_empty(&dev->done)) {
            schedule_timeout(msecs_to_jiffies(UNLINK_TIMEOUT_MS));
            set_current_state(TASK_UNINTERRUPTIBLE);
            netif_dbg(dev, ifdown, dev->net,
                  "waited for %d urb completions\n", temp);
    }
*1  usbnet_stop (usbnet.c:806)
    if (!(info->flags & FLAG_AVOID_UNLINK_URBS))
        usbnet_terminate_urbs(dev);

As a result, it is possible, for example, that the skb is removed from
dev->rxq by __skb_unlink() before the check
"!skb_queue_empty(&dev->rxq)" in usbnet_terminate_urbs() is made. It is
also possible in this case that the skb is added to dev->done queue
after "!skb_queue_empty(&dev->done)" is checked. So
usbnet_terminate_urbs() may stop waiting and return while dev->done
queue still has an item.

Locking in defer_bh() and usbnet_terminate_urbs() was revisited to avoid
this race.

2. The second race is on dev->flags.

dev->flags is set to 0 here:
*0  usbnet_stop (usbnet.c:816)
    /* deferred work (task, timer, softirq) must also stop.
     * can't flush_scheduled_work() until we drop rtnl (later),
     * else workers could deadlock; so make workers a NOP.
     */
    dev->flags = 0;
    del_timer_sync (&dev->delay);
    tasklet_kill (&dev->bh);

And here, the code clears EVENT_RX_KILL bit in dev->flags, which may
execute concurrently with the above operation:
*0 clear_bit (bitops.h:113, inlined)
*1 usbnet_bh (usbnet.c:1475)
    /* restart RX again after disabling due to high error rate */
    clear_bit(EVENT_RX_KILL, &dev->flags);

It seems, setting dev->flags to 0 is not necessarily atomic w.r.t.
clear_bit() and other bit operations with dev->flags. It is safer to
make it atomic and this way, make the race harmless.

While at it, the checking of EVENT_NO_RUNTIME_PM bit of dev->flags in
usbnet_stop() was fixed too: the bit should be checked before dev->flags
is cleared.

Signed-off-by: Eugene Shatokhin <eugene.shatokhin@rosalab.ru>
---
 drivers/net/usb/usbnet.c   | 49 ++++++++++++++++++++++++++++++++--------------
 include/linux/usb/usbnet.h | 33 +++++++++++++++++++------------
 2 files changed, 54 insertions(+), 28 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 3c86b10..a53124c 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -428,12 +428,18 @@ static enum skb_state defer_bh(struct usbnet *dev, struct sk_buff *skb,
 	old_state = entry->state;
 	entry->state = state;
 	__skb_unlink(skb, list);
-	spin_unlock(&list->lock);
-	spin_lock(&dev->done.lock);
+
+	/* defer_bh() is never called with list == &dev->done.
+	 * spin_lock_nested() tells lockdep that it is OK to take
+	 * dev->done.lock here with list->lock held. *
+	 */
+	spin_lock_nested(&dev->done.lock, SINGLE_DEPTH_NESTING);
+
 	__skb_queue_tail(&dev->done, skb);
 	if (dev->done.qlen == 1)
 		tasklet_schedule(&dev->bh);
-	spin_unlock_irqrestore(&dev->done.lock, flags);
+	spin_unlock(&dev->done.lock);
+	spin_unlock_irqrestore(&list->lock, flags);
 	return old_state;
 }
 
@@ -749,6 +755,20 @@ EXPORT_SYMBOL_GPL(usbnet_unlink_rx_urbs);
 
 /*-------------------------------------------------------------------------*/
 
+static void wait_skb_queue_empty(struct sk_buff_head *q)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&q->lock, flags);
+	while (!skb_queue_empty(q)) {
+		spin_unlock_irqrestore(&q->lock, flags);
+		schedule_timeout(msecs_to_jiffies(UNLINK_TIMEOUT_MS));
+		set_current_state(TASK_UNINTERRUPTIBLE);
+		spin_lock_irqsave(&q->lock, flags);
+	}
+	spin_unlock_irqrestore(&q->lock, flags);
+}
+
 // precondition: never called in_interrupt
 static void usbnet_terminate_urbs(struct usbnet *dev)
 {
@@ -762,14 +782,11 @@ static void usbnet_terminate_urbs(struct usbnet *dev)
 		unlink_urbs(dev, &dev->rxq);
 
 	/* maybe wait for deletions to finish. */
-	while (!skb_queue_empty(&dev->rxq)
-		&& !skb_queue_empty(&dev->txq)
-		&& !skb_queue_empty(&dev->done)) {
-			schedule_timeout(msecs_to_jiffies(UNLINK_TIMEOUT_MS));
-			set_current_state(TASK_UNINTERRUPTIBLE);
-			netif_dbg(dev, ifdown, dev->net,
-				  "waited for %d urb completions\n", temp);
-	}
+	wait_skb_queue_empty(&dev->rxq);
+	wait_skb_queue_empty(&dev->txq);
+	wait_skb_queue_empty(&dev->done);
+	netif_dbg(dev, ifdown, dev->net,
+		  "waited for %d urb completions\n", temp);
 	set_current_state(TASK_RUNNING);
 	remove_wait_queue(&dev->wait, &wait);
 }
@@ -778,7 +795,8 @@ int usbnet_stop (struct net_device *net)
 {
 	struct usbnet		*dev = netdev_priv(net);
 	struct driver_info	*info = dev->driver_info;
-	int			retval, pm;
+	int			retval, pm, mpn;
+	int			e;
 
 	clear_bit(EVENT_DEV_OPEN, &dev->flags);
 	netif_stop_queue (net);
@@ -813,14 +831,15 @@ int usbnet_stop (struct net_device *net)
 	 * can't flush_scheduled_work() until we drop rtnl (later),
 	 * else workers could deadlock; so make workers a NOP.
 	 */
-	dev->flags = 0;
+	mpn = !test_and_clear_bit(EVENT_NO_RUNTIME_PM, &dev->flags);
+	for (e = 0; e < EVENT_NUM_EVENTS; ++e)
+		clear_bit(e, &dev->flags);
 	del_timer_sync (&dev->delay);
 	tasklet_kill (&dev->bh);
 	if (!pm)
 		usb_autopm_put_interface(dev->intf);
 
-	if (info->manage_power &&
-	    !test_and_clear_bit(EVENT_NO_RUNTIME_PM, &dev->flags))
+	if (info->manage_power && mpn)
 		info->manage_power(dev, 0);
 	else
 		usb_autopm_put_interface(dev->intf);
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index 6e0ce8c..39a57f5 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -22,6 +22,23 @@
 #ifndef	__LINUX_USB_USBNET_H
 #define	__LINUX_USB_USBNET_H
 
+enum usbnet_event_bits {
+	EVENT_TX_HALT =		0,
+	EVENT_RX_HALT =		1,
+	EVENT_RX_MEMORY =	2,
+	EVENT_STS_SPLIT =	3,
+	EVENT_LINK_RESET =	4,
+	EVENT_RX_PAUSED =	5,
+	EVENT_DEV_ASLEEP =	6,
+	EVENT_DEV_OPEN =	7,
+	EVENT_DEVICE_REPORT_IDLE = 8,
+	EVENT_NO_RUNTIME_PM =	9,
+	EVENT_RX_KILL =		10,
+	EVENT_LINK_CHANGE =	11,
+	EVENT_SET_RX_MODE =	12,
+	EVENT_NUM_EVENTS	/* keep it last */
+};
+
 /* interface from usbnet core to each USB networking link we handle */
 struct usbnet {
 	/* housekeeping */
@@ -65,20 +82,10 @@ struct usbnet {
 	struct tasklet_struct	bh;
 
 	struct work_struct	kevent;
+
+	/* See enum usbnet_event_bits for the meaning of the individial
+	 * bits in 'flags'. */
 	unsigned long		flags;
-#		define EVENT_TX_HALT	0
-#		define EVENT_RX_HALT	1
-#		define EVENT_RX_MEMORY	2
-#		define EVENT_STS_SPLIT	3
-#		define EVENT_LINK_RESET	4
-#		define EVENT_RX_PAUSED	5
-#		define EVENT_DEV_ASLEEP 6
-#		define EVENT_DEV_OPEN	7
-#		define EVENT_DEVICE_REPORT_IDLE	8
-#		define EVENT_NO_RUNTIME_PM	9
-#		define EVENT_RX_KILL	10
-#		define EVENT_LINK_CHANGE	11
-#		define EVENT_SET_RX_MODE	12
 };
 
 static inline struct usb_driver *driver_of(struct usb_interface *intf)
-- 
2.3.2
