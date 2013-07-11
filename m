From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 24/50] input: cm109: spin_lock in complete() cleanup
Date: Thu, 11 Jul 2013 17:05:47 +0800
Message-ID: <1373533573-12272-25-git-send-email-ming.lei@canonical.com>
References: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	linux-input@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-media@vger.kernel.org, alsa-devel@alsa-project.org,
	Ming Lei <ming.lei@canonical.com>,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:48258 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932278Ab3GKJJv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 05:09:51 -0400
In-Reply-To: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Complete() will be run with interrupt enabled, so change to
spin_lock_irqsave().

Cc: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Cc: linux-input@vger.kernel.org
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/input/misc/cm109.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/input/misc/cm109.c b/drivers/input/misc/cm109.c
index 082684e..cac4e37 100644
--- a/drivers/input/misc/cm109.c
+++ b/drivers/input/misc/cm109.c
@@ -340,6 +340,7 @@ static void cm109_urb_irq_callback(struct urb *urb)
 	struct cm109_dev *dev = urb->context;
 	const int status = urb->status;
 	int error;
+	unsigned long flags;
 
 	dev_dbg(&dev->intf->dev, "### URB IRQ: [0x%02x 0x%02x 0x%02x 0x%02x] keybit=0x%02x\n",
 	     dev->irq_data->byte[0],
@@ -379,7 +380,7 @@ static void cm109_urb_irq_callback(struct urb *urb)
 
  out:
 
-	spin_lock(&dev->ctl_submit_lock);
+	spin_lock_irqsave(&dev->ctl_submit_lock, flags);
 
 	dev->irq_urb_pending = 0;
 
@@ -403,7 +404,7 @@ static void cm109_urb_irq_callback(struct urb *urb)
 				__func__, error);
 	}
 
-	spin_unlock(&dev->ctl_submit_lock);
+	spin_unlock_irqrestore(&dev->ctl_submit_lock, flags);
 }
 
 static void cm109_urb_ctl_callback(struct urb *urb)
@@ -411,6 +412,7 @@ static void cm109_urb_ctl_callback(struct urb *urb)
 	struct cm109_dev *dev = urb->context;
 	const int status = urb->status;
 	int error;
+	unsigned long flags;
 
 	dev_dbg(&dev->intf->dev, "### URB CTL: [0x%02x 0x%02x 0x%02x 0x%02x]\n",
 	     dev->ctl_data->byte[0],
@@ -421,7 +423,7 @@ static void cm109_urb_ctl_callback(struct urb *urb)
 	if (status)
 		dev_err(&dev->intf->dev, "%s: urb status %d\n", __func__, status);
 
-	spin_lock(&dev->ctl_submit_lock);
+	spin_lock_irqsave(&dev->ctl_submit_lock, flags);
 
 	dev->ctl_urb_pending = 0;
 
@@ -442,7 +444,7 @@ static void cm109_urb_ctl_callback(struct urb *urb)
 		}
 	}
 
-	spin_unlock(&dev->ctl_submit_lock);
+	spin_unlock_irqrestore(&dev->ctl_submit_lock, flags);
 }
 
 static void cm109_toggle_buzzer_async(struct cm109_dev *dev)
-- 
1.7.9.5
