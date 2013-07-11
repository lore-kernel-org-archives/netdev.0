From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 08/50] USB: legousbtower: spin_lock in complete() cleanup
Date: Thu, 11 Jul 2013 17:05:31 +0800
Message-ID: <1373533573-12272-9-git-send-email-ming.lei@canonical.com>
References: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	linux-input@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-media@vger.kernel.org, alsa-devel@alsa-project.org,
	Ming Lei <ming.lei@canonical.com>,
	Juergen Stuber <starblue@users.sourceforge.net>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:50418 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932090Ab3GKJHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 05:07:43 -0400
In-Reply-To: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Complete() will be run with interrupt enabled, so change to
spin_lock_irqsave().

Cc: Juergen Stuber <starblue@users.sourceforge.net>
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/usb/misc/legousbtower.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/usb/misc/legousbtower.c b/drivers/usb/misc/legousbtower.c
index 8089479..4044989 100644
--- a/drivers/usb/misc/legousbtower.c
+++ b/drivers/usb/misc/legousbtower.c
@@ -771,6 +771,7 @@ static void tower_interrupt_in_callback (struct urb *urb)
 	struct lego_usb_tower *dev = urb->context;
 	int status = urb->status;
 	int retval;
+	unsigned long flags;
 
 	dbg(4, "%s: enter, status %d", __func__, status);
 
@@ -788,7 +789,7 @@ static void tower_interrupt_in_callback (struct urb *urb)
 	}
 
 	if (urb->actual_length > 0) {
-		spin_lock (&dev->read_buffer_lock);
+		spin_lock_irqsave (&dev->read_buffer_lock, flags);
 		if (dev->read_buffer_length + urb->actual_length < read_buffer_size) {
 			memcpy (dev->read_buffer + dev->read_buffer_length,
 				dev->interrupt_in_buffer,
@@ -799,7 +800,7 @@ static void tower_interrupt_in_callback (struct urb *urb)
 		} else {
 			printk(KERN_WARNING "%s: read_buffer overflow, %d bytes dropped", __func__, urb->actual_length);
 		}
-		spin_unlock (&dev->read_buffer_lock);
+		spin_unlock_irqrestore (&dev->read_buffer_lock, flags);
 	}
 
 resubmit:
-- 
1.7.9.5
