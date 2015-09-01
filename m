From: Eugene Shatokhin <eugene.shatokhin@rosalab.ru>
Subject: [PATCH] usbnet: Fix a race between usbnet_stop() and the BH
Date: Tue,  1 Sep 2015 17:05:33 +0300
Message-ID: <1441116333-5377-1-git-send-email-eugene.shatokhin@rosalab.ru>
References: <1441094336.3328.1.camel@suse.com>
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Eugene Shatokhin <eugene.shatokhin@rosalab.ru>
To: Oliver Neukum <oneukum@suse.de>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441094336.3328.1.camel@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The race may happen when a device (e.g. YOTA 4G LTE Modem) is
unplugged while the system is downloading a large file from the Net.

Hardware breakpoints and Kprobes with delays were used to confirm that
the race does actually happen.

The race is on skb_queue ('next' pointer) between usbnet_stop()
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

Signed-off-by: Eugene Shatokhin <eugene.shatokhin@rosalab.ru>
---
 drivers/net/usb/usbnet.c | 39 ++++++++++++++++++++++++++++-----------
 1 file changed, 28 insertions(+), 11 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index e049857..b4cf107 100644
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
+	 * dev->done.lock here with list->lock held.
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
-- 
2.3.2
