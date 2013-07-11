From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 09/50] USB: usbtest: spin_lock in complete() cleanup
Date: Thu, 11 Jul 2013 17:05:32 +0800
Message-ID: <1373533573-12272-10-git-send-email-ming.lei@canonical.com>
References: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	linux-input@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-media@vger.kernel.org, alsa-devel@alsa-project.org,
	Ming Lei <ming.lei@canonical.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:51414 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932090Ab3GKJHv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 05:07:51 -0400
In-Reply-To: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Complete() will be run with interrupt enabled, so change to
spin_lock_irqsave().

Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/usb/misc/usbtest.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/usb/misc/usbtest.c b/drivers/usb/misc/usbtest.c
index 8b4ca1c..5c73df5 100644
--- a/drivers/usb/misc/usbtest.c
+++ b/drivers/usb/misc/usbtest.c
@@ -804,11 +804,12 @@ static void ctrl_complete(struct urb *urb)
 	struct usb_ctrlrequest	*reqp;
 	struct subcase		*subcase;
 	int			status = urb->status;
+	unsigned long		flags;
 
 	reqp = (struct usb_ctrlrequest *)urb->setup_packet;
 	subcase = container_of(reqp, struct subcase, setup);
 
-	spin_lock(&ctx->lock);
+	spin_lock_irqsave(&ctx->lock, flags);
 	ctx->count--;
 	ctx->pending--;
 
@@ -907,7 +908,7 @@ error:
 	/* signal completion when nothing's queued */
 	if (ctx->pending == 0)
 		complete(&ctx->complete);
-	spin_unlock(&ctx->lock);
+	spin_unlock_irqrestore(&ctx->lock, flags);
 }
 
 static int
@@ -1552,8 +1553,9 @@ struct iso_context {
 static void iso_callback(struct urb *urb)
 {
 	struct iso_context	*ctx = urb->context;
+	unsigned long		flags;
 
-	spin_lock(&ctx->lock);
+	spin_lock_irqsave(&ctx->lock, flags);
 	ctx->count--;
 
 	ctx->packet_count += urb->number_of_packets;
@@ -1593,7 +1595,7 @@ static void iso_callback(struct urb *urb)
 		complete(&ctx->done);
 	}
 done:
-	spin_unlock(&ctx->lock);
+	spin_unlock_irqrestore(&ctx->lock, flags);
 }
 
 static struct urb *iso_alloc_urb(
-- 
1.7.9.5
