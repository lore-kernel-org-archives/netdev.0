From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 19/50] USB: serial: ti_usb_3410_5052: spin_lock in complete() cleanup
Date: Thu, 11 Jul 2013 17:05:42 +0800
Message-ID: <1373533573-12272-20-git-send-email-ming.lei@canonical.com>
References: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	linux-input@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-media@vger.kernel.org, alsa-devel@alsa-project.org,
	Ming Lei <ming.lei@canonical.com>,
	Johan Hovold <jhovold@gmail.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:42188 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932259Ab3GKJJJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 05:09:09 -0400
In-Reply-To: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Complete() will be run with interrupt enabled, so change to
spin_lock_irqsave().

Cc: Johan Hovold <jhovold@gmail.com>
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/usb/serial/ti_usb_3410_5052.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/usb/serial/ti_usb_3410_5052.c b/drivers/usb/serial/ti_usb_3410_5052.c
index 7182bb7..4b984e9 100644
--- a/drivers/usb/serial/ti_usb_3410_5052.c
+++ b/drivers/usb/serial/ti_usb_3410_5052.c
@@ -1081,6 +1081,7 @@ static void ti_bulk_in_callback(struct urb *urb)
 	struct device *dev = &urb->dev->dev;
 	int status = urb->status;
 	int retval = 0;
+	unsigned long flags;
 
 	switch (status) {
 	case 0:
@@ -1116,20 +1117,20 @@ static void ti_bulk_in_callback(struct urb *urb)
 				__func__);
 		else
 			ti_recv(port, urb->transfer_buffer, urb->actual_length);
-		spin_lock(&tport->tp_lock);
+		spin_lock_irqsave(&tport->tp_lock, flags);
 		port->icount.rx += urb->actual_length;
-		spin_unlock(&tport->tp_lock);
+		spin_unlock_irqrestore(&tport->tp_lock, flags);
 	}
 
 exit:
 	/* continue to read unless stopping */
-	spin_lock(&tport->tp_lock);
+	spin_lock_irqsave(&tport->tp_lock, flags);
 	if (tport->tp_read_urb_state == TI_READ_URB_RUNNING)
 		retval = usb_submit_urb(urb, GFP_ATOMIC);
 	else if (tport->tp_read_urb_state == TI_READ_URB_STOPPING)
 		tport->tp_read_urb_state = TI_READ_URB_STOPPED;
 
-	spin_unlock(&tport->tp_lock);
+	spin_unlock_irqrestore(&tport->tp_lock, flags);
 	if (retval)
 		dev_err(dev, "%s - resubmit read urb failed, %d\n",
 			__func__, retval);
-- 
1.7.9.5
