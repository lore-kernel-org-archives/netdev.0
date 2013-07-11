From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 18/50] USB: serial: symbolserial: spin_lock in complete() cleanup
Date: Thu, 11 Jul 2013 17:05:41 +0800
Message-ID: <1373533573-12272-19-git-send-email-ming.lei@canonical.com>
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
Received: from mail-pb0-f53.google.com ([209.85.160.53]:50089 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932090Ab3GKJJC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 05:09:02 -0400
In-Reply-To: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Complete() will be run with interrupt enabled, so change to
spin_lock_irqsave().

Cc: Johan Hovold <jhovold@gmail.com>
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/usb/serial/symbolserial.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/usb/serial/symbolserial.c b/drivers/usb/serial/symbolserial.c
index 9b16489..b4f5cbe 100644
--- a/drivers/usb/serial/symbolserial.c
+++ b/drivers/usb/serial/symbolserial.c
@@ -41,6 +41,7 @@ static void symbol_int_callback(struct urb *urb)
 	int status = urb->status;
 	int result;
 	int data_length;
+	unsigned long flags;
 
 	switch (status) {
 	case 0:
@@ -81,7 +82,7 @@ static void symbol_int_callback(struct urb *urb)
 	}
 
 exit:
-	spin_lock(&priv->lock);
+	spin_lock_irqsave(&priv->lock, flags);
 
 	/* Continue trying to always read if we should */
 	if (!priv->throttled) {
@@ -92,7 +93,7 @@ exit:
 							__func__, result);
 	} else
 		priv->actually_throttled = true;
-	spin_unlock(&priv->lock);
+	spin_unlock_irqrestore(&priv->lock, flags);
 }
 
 static int symbol_open(struct tty_struct *tty, struct usb_serial_port *port)
-- 
1.7.9.5
