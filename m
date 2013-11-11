From: wangbiao <biao.wang@intel.com>
Subject: [PATCH] usbnet: fix race condition caused spinlock bad magic issue
Date: Mon, 11 Nov 2013 11:08:35 +0800
Message-ID: <1384139315.2179.9.camel@wangbiao>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, mingo@elte.hu, a.p.zijlstra@chello.nl,
	rusty@rustcorp.com.au, william.douglas@intel.com,
	biao.wang@intel.com
To: oneukum@suse.de, netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:33696 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751003Ab3KKD05 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Nov 2013 22:26:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: wang, biao <biao.wang@intel.com>
Date: Mon, 11 Nov 2013 10:23:40 +0800
Subject: [PATCH] usbnet: fix race condition caused spinlock bad magic issue

there is race between usbnet_terminate_urbs and usbnet_bh, when
unlink_wakeup used in usbnet_bh, it may be already freed and used by
other function as unlink_wakeup was a local var on stack.

btw, dev->wait should be judged again before use it as there is race
too.

Signed-off-by: wang, biao <biao.wang@intel.com>
---
 drivers/net/usb/usbnet.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 90a429b..22fc27f 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -86,6 +86,7 @@ static const char driver_name [] = "usbnet";
 
 /* use ethtool to change the level for any given device */
 static int msg_level = -1;
+static wait_queue_head_t unlink_wakeup;
 module_param (msg_level, int, 0);
 MODULE_PARM_DESC (msg_level, "Override default message level");
 
@@ -761,7 +762,6 @@ EXPORT_SYMBOL_GPL(usbnet_unlink_rx_urbs);
 // precondition: never called in_interrupt
 static void usbnet_terminate_urbs(struct usbnet *dev)
 {
-	DECLARE_WAIT_QUEUE_HEAD_ONSTACK(unlink_wakeup);
 	DECLARE_WAITQUEUE(wait, current);
 	int temp;
 
@@ -1448,8 +1448,10 @@ static void usbnet_bh (unsigned long param)
 
 	// waiting for all pending urbs to complete?
 	if (dev->wait) {
+		wait_queue_head_t *wait_d = dev->wait;
 		if ((dev->txq.qlen + dev->rxq.qlen + dev->done.qlen) == 0) {
-			wake_up (dev->wait);
+			if (wait_d)
+				wake_up(wait_d);
 		}
 
 	// or are we maybe short a few urbs?
@@ -1602,6 +1604,7 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 	init_timer (&dev->delay);
 	mutex_init (&dev->phy_mutex);
 	mutex_init(&dev->interrupt_mutex);
+	init_waitqueue_head(&unlink_wakeup);
 	dev->interrupt_count = 0;
 
 	dev->net = net;
-- 
1.7.0.4
