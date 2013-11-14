From: wangbiao <biao.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH V3] usbnet: fix race condition caused spinlock bad magic
 issue
Date: Thu, 14 Nov 2013 10:03:15 +0800
Message-ID: <1384394595.4229.24.camel@wangbiao>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org,
	rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org, william.douglas-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	di.zhang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, biao.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: oneukum-l3A5Bk7waGM@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Ingo Molnar <mingo.kernel.org-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: wang, biao <biao.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date: Mon, 11 Nov 2013 10:23:40 +0800
Subject: [PATCH] usbnet: fix race condition caused spinlock bad magic issue

there is race between usbnet_terminate_urbs and usbnet_bh.
for example:
    cpu 0                                     cpu 1
                                          usbnet_suspend
usbnet_bh {                               ->usbnet_terminate_urbs {
                                              dev->wait = &unlink_wakeup;
                                              while(....){..}//break
    if(dev->wait) is true
                       		              dev->wait=NULL
                                          }//unlink_wakeup is invalid
    __wake_up(dev->wait)//garbage value
}

the race is due to unprotection of dev->wait, so this patch involves a
spinlock to avoid it.

Signed-off-by: wang, biao <biao.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Zhang, Di <di.zhang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 drivers/net/usb/usbnet.c |   16 ++++++++++++++--
 1 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 90a429b..f7df1af 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -86,6 +86,7 @@ static const char driver_name [] = "usbnet";
 
 /* use ethtool to change the level for any given device */
 static int msg_level = -1;
+static spinlock_t dev_wait_lock = __SPIN_LOCK_UNLOCKED(dev_wait_lock);
 module_param (msg_level, int, 0);
 MODULE_PARM_DESC (msg_level, "Override default message level");
 
@@ -764,11 +765,14 @@ static void usbnet_terminate_urbs(struct usbnet *dev)
 	DECLARE_WAIT_QUEUE_HEAD_ONSTACK(unlink_wakeup);
 	DECLARE_WAITQUEUE(wait, current);
 	int temp;
+	unsigned long flags;
 
 	/* ensure there are no more active urbs */
 	add_wait_queue(&unlink_wakeup, &wait);
 	set_current_state(TASK_UNINTERRUPTIBLE);
+	spin_lock_irqsave(&dev_wait_lock, flags);
 	dev->wait = &unlink_wakeup;
+	spin_unlock_irqrestore(&dev_wait_lock, flags);
 	temp = unlink_urbs(dev, &dev->txq) +
 		unlink_urbs(dev, &dev->rxq);
 
@@ -782,7 +786,9 @@ static void usbnet_terminate_urbs(struct usbnet *dev)
 				  "waited for %d urb completions\n", temp);
 	}
 	set_current_state(TASK_RUNNING);
+	spin_lock_irqsave(&dev_wait_lock, flags);
 	dev->wait = NULL;
+	spin_unlock_irqrestore(&dev_wait_lock, flags);
 	remove_wait_queue(&unlink_wakeup, &wait);
 }
 
@@ -1424,6 +1430,7 @@ static void usbnet_bh (unsigned long param)
 	struct usbnet		*dev = (struct usbnet *) param;
 	struct sk_buff		*skb;
 	struct skb_data		*entry;
+	unsigned long           flags;
 
 	while ((skb = skb_dequeue (&dev->done))) {
 		entry = (struct skb_data *) skb->cb;
@@ -1447,13 +1454,18 @@ static void usbnet_bh (unsigned long param)
 	clear_bit(EVENT_RX_KILL, &dev->flags);
 
 	// waiting for all pending urbs to complete?
+	spin_lock_irqsave(&dev_wait_lock, flags);
 	if (dev->wait) {
 		if ((dev->txq.qlen + dev->rxq.qlen + dev->done.qlen) == 0) {
-			wake_up (dev->wait);
+			wake_up(dev->wait);
 		}
+		spin_unlock_irqrestore(&dev_wait_lock, flags);
+		return;
+	}
+	spin_unlock_irqrestore(&dev_wait_lock, flags);
 
 	// or are we maybe short a few urbs?
-	} else if (netif_running (dev->net) &&
+	if (netif_running(dev->net) &&
 		   netif_device_present (dev->net) &&
 		   netif_carrier_ok(dev->net) &&
 		   !timer_pending (&dev->delay) &&
-- 
1.7.0.4



--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
