From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 05/50] USB: misc: uss720: spin_lock in complete() cleanup
Date: Thu, 11 Jul 2013 17:05:28 +0800
Message-ID: <1373533573-12272-6-git-send-email-ming.lei@canonical.com>
References: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	linux-input@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-media@vger.kernel.org, alsa-devel@alsa-project.org,
	Ming Lei <ming.lei@canonical.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:42148 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755838Ab3GKJHP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 05:07:15 -0400
In-Reply-To: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Complete() will be run with interrupt enabled, so change to
spin_lock_irqsave().

Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/usb/misc/uss720.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/usb/misc/uss720.c b/drivers/usb/misc/uss720.c
index e129cf6..f7d15e8 100644
--- a/drivers/usb/misc/uss720.c
+++ b/drivers/usb/misc/uss720.c
@@ -121,6 +121,7 @@ static void async_complete(struct urb *urb)
 		dev_err(&urb->dev->dev, "async_complete: urb error %d\n",
 			status);
 	} else if (rq->dr.bRequest == 3) {
+		unsigned long flags;
 		memcpy(priv->reg, rq->reg, sizeof(priv->reg));
 #if 0
 		dev_dbg(&priv->usbdev->dev,
@@ -131,8 +132,11 @@ static void async_complete(struct urb *urb)
 			(unsigned int)priv->reg[6]);
 #endif
 		/* if nAck interrupts are enabled and we have an interrupt, call the interrupt procedure */
-		if (rq->reg[2] & rq->reg[1] & 0x10 && pp)
+		if (rq->reg[2] & rq->reg[1] & 0x10 && pp) {
+			local_irq_save(flags);
 			parport_generic_irq(pp);
+			local_irq_restore(flags);
+		}
 	}
 	complete(&rq->compl);
 	kref_put(&rq->ref_count, destroy_async);
-- 
1.7.9.5
