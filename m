From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 10/50] USB: serial: cyberjack: spin_lock in complete() cleanup
Date: Thu, 11 Jul 2013 17:05:33 +0800
Message-ID: <1373533573-12272-11-git-send-email-ming.lei@canonical.com>
References: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	linux-input@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-media@vger.kernel.org, alsa-devel@alsa-project.org,
	Ming Lei <ming.lei@canonical.com>,
	Matthias Bruestle and Harald Welte <support@reiner-sct.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:39578 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932090Ab3GKJH6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 05:07:58 -0400
In-Reply-To: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Complete() will be run with interrupt enabled, so change to
spin_lock_irqsave().

Cc: Matthias Bruestle and Harald Welte <support@reiner-sct.com>
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/usb/serial/cyberjack.c |   15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/usb/serial/cyberjack.c b/drivers/usb/serial/cyberjack.c
index 7814262..0ab0957 100644
--- a/drivers/usb/serial/cyberjack.c
+++ b/drivers/usb/serial/cyberjack.c
@@ -271,11 +271,12 @@ static void cyberjack_read_int_callback(struct urb *urb)
 	/* React only to interrupts signaling a bulk_in transfer */
 	if (urb->actual_length == 4 && data[0] == 0x01) {
 		short old_rdtodo;
+		unsigned long flags;
 
 		/* This is a announcement of coming bulk_ins. */
 		unsigned short size = ((unsigned short)data[3]<<8)+data[2]+3;
 
-		spin_lock(&priv->lock);
+		spin_lock_irqsave(&priv->lock, flags);
 
 		old_rdtodo = priv->rdtodo;
 
@@ -290,7 +291,7 @@ static void cyberjack_read_int_callback(struct urb *urb)
 
 		dev_dbg(dev, "%s - rdtodo: %d\n", __func__, priv->rdtodo);
 
-		spin_unlock(&priv->lock);
+		spin_unlock_irqrestore(&priv->lock, flags);
 
 		if (!old_rdtodo) {
 			result = usb_submit_urb(port->read_urb, GFP_ATOMIC);
@@ -317,6 +318,7 @@ static void cyberjack_read_bulk_callback(struct urb *urb)
 	short todo;
 	int result;
 	int status = urb->status;
+	unsigned long flags;
 
 	usb_serial_debug_data(dev, __func__, urb->actual_length, data);
 	if (status) {
@@ -330,7 +332,7 @@ static void cyberjack_read_bulk_callback(struct urb *urb)
 		tty_flip_buffer_push(&port->port);
 	}
 
-	spin_lock(&priv->lock);
+	spin_lock_irqsave(&priv->lock, flags);
 
 	/* Reduce urbs to do by one. */
 	priv->rdtodo -= urb->actual_length;
@@ -339,7 +341,7 @@ static void cyberjack_read_bulk_callback(struct urb *urb)
 		priv->rdtodo = 0;
 	todo = priv->rdtodo;
 
-	spin_unlock(&priv->lock);
+	spin_unlock_irqrestore(&priv->lock, flags);
 
 	dev_dbg(dev, "%s - rdtodo: %d\n", __func__, todo);
 
@@ -359,6 +361,7 @@ static void cyberjack_write_bulk_callback(struct urb *urb)
 	struct cyberjack_private *priv = usb_get_serial_port_data(port);
 	struct device *dev = &port->dev;
 	int status = urb->status;
+	unsigned long flags;
 
 	set_bit(0, &port->write_urbs_free);
 	if (status) {
@@ -367,7 +370,7 @@ static void cyberjack_write_bulk_callback(struct urb *urb)
 		return;
 	}
 
-	spin_lock(&priv->lock);
+	spin_lock_irqsave(&priv->lock, flags);
 
 	/* only do something if we have more data to send */
 	if (priv->wrfilled) {
@@ -411,7 +414,7 @@ static void cyberjack_write_bulk_callback(struct urb *urb)
 	}
 
 exit:
-	spin_unlock(&priv->lock);
+	spin_unlock_irqrestore(&priv->lock, flags);
 	usb_serial_port_softint(port);
 }
 
-- 
1.7.9.5
