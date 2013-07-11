From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 04/50] USB: adutux: spin_lock in complete() cleanup
Date: Thu, 11 Jul 2013 17:05:27 +0800
Message-ID: <1373533573-12272-5-git-send-email-ming.lei@canonical.com>
References: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	linux-input@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-media@vger.kernel.org, alsa-devel@alsa-project.org,
	Ming Lei <ming.lei@canonical.com>,
	Lisa Nguyen <lisa@xenapiadmin.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:46240 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755838Ab3GKJHI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 05:07:08 -0400
In-Reply-To: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Complete() will be run with interrupt enabled, so change to
spin_lock_irqsave().

Cc: Lisa Nguyen <lisa@xenapiadmin.com>
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/usb/misc/adutux.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/usb/misc/adutux.c b/drivers/usb/misc/adutux.c
index eb3c8c1..387c75e 100644
--- a/drivers/usb/misc/adutux.c
+++ b/drivers/usb/misc/adutux.c
@@ -195,12 +195,13 @@ static void adu_interrupt_in_callback(struct urb *urb)
 {
 	struct adu_device *dev = urb->context;
 	int status = urb->status;
+	unsigned long flags;
 
 	dbg(4, " %s : enter, status %d", __func__, status);
 	adu_debug_data(5, __func__, urb->actual_length,
 		       urb->transfer_buffer);
 
-	spin_lock(&dev->buflock);
+	spin_lock_irqsave(&dev->buflock, flags);
 
 	if (status != 0) {
 		if ((status != -ENOENT) && (status != -ECONNRESET) &&
@@ -229,7 +230,7 @@ static void adu_interrupt_in_callback(struct urb *urb)
 
 exit:
 	dev->read_urb_finished = 1;
-	spin_unlock(&dev->buflock);
+	spin_unlock_irqrestore(&dev->buflock, flags);
 	/* always wake up so we recover from errors */
 	wake_up_interruptible(&dev->read_wait);
 	adu_debug_data(5, __func__, urb->actual_length,
@@ -241,6 +242,7 @@ static void adu_interrupt_out_callback(struct urb *urb)
 {
 	struct adu_device *dev = urb->context;
 	int status = urb->status;
+	unsigned long flags;
 
 	dbg(4, " %s : enter, status %d", __func__, status);
 	adu_debug_data(5, __func__, urb->actual_length, urb->transfer_buffer);
@@ -254,10 +256,10 @@ static void adu_interrupt_out_callback(struct urb *urb)
 		goto exit;
 	}
 
-	spin_lock(&dev->buflock);
+	spin_lock_irqsave(&dev->buflock, flags);
 	dev->out_urb_finished = 1;
 	wake_up(&dev->write_wait);
-	spin_unlock(&dev->buflock);
+	spin_unlock_irqrestore(&dev->buflock, flags);
 exit:
 
 	adu_debug_data(5, __func__, urb->actual_length,
-- 
1.7.9.5
