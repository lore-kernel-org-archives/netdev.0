From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 11/50] USB: serial: digi_acceleportldusb: spin_lock in complete() cleanup
Date: Thu, 11 Jul 2013 17:05:34 +0800
Message-ID: <1373533573-12272-12-git-send-email-ming.lei@canonical.com>
References: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	linux-input@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-media@vger.kernel.org, alsa-devel@alsa-project.org,
	Ming Lei <ming.lei@canonical.com>,
	Peter Berger <pberger@brimson.com>,
	Al Borchers <alborchers@steinerpoint.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:60401 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932090Ab3GKJIG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 05:08:06 -0400
In-Reply-To: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Complete() will be run with interrupt enabled, so change to
spin_lock_irqsave().

Cc: Peter Berger <pberger@brimson.com>
Cc: Al Borchers <alborchers@steinerpoint.com>
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/usb/serial/digi_acceleport.c |   23 +++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)

diff --git a/drivers/usb/serial/digi_acceleport.c b/drivers/usb/serial/digi_acceleport.c
index 19b467f..95b1959 100644
--- a/drivers/usb/serial/digi_acceleport.c
+++ b/drivers/usb/serial/digi_acceleport.c
@@ -988,6 +988,7 @@ static void digi_write_bulk_callback(struct urb *urb)
 	struct digi_serial *serial_priv;
 	int ret = 0;
 	int status = urb->status;
+	unsigned long flags;
 
 	/* port and serial sanity check */
 	if (port == NULL || (priv = usb_get_serial_port_data(port)) == NULL) {
@@ -1006,15 +1007,15 @@ static void digi_write_bulk_callback(struct urb *urb)
 	/* handle oob callback */
 	if (priv->dp_port_num == serial_priv->ds_oob_port_num) {
 		dev_dbg(&port->dev, "digi_write_bulk_callback: oob callback\n");
-		spin_lock(&priv->dp_port_lock);
+		spin_lock_irqsave(&priv->dp_port_lock, flags);
 		priv->dp_write_urb_in_use = 0;
 		wake_up_interruptible(&port->write_wait);
-		spin_unlock(&priv->dp_port_lock);
+		spin_unlock_irqrestore(&priv->dp_port_lock, flags);
 		return;
 	}
 
 	/* try to send any buffered data on this port */
-	spin_lock(&priv->dp_port_lock);
+	spin_lock_irqsave(&priv->dp_port_lock, flags);
 	priv->dp_write_urb_in_use = 0;
 	if (priv->dp_out_buf_len > 0) {
 		*((unsigned char *)(port->write_urb->transfer_buffer))
@@ -1037,7 +1038,7 @@ static void digi_write_bulk_callback(struct urb *urb)
 	/* lost the race in write_chan(). */
 	schedule_work(&priv->dp_wakeup_work);
 
-	spin_unlock(&priv->dp_port_lock);
+	spin_unlock_irqrestore(&priv->dp_port_lock, flags);
 	if (ret && ret != -EPERM)
 		dev_err_console(port,
 			"%s: usb_submit_urb failed, ret=%d, port=%d\n",
@@ -1388,6 +1389,7 @@ static int digi_read_inb_callback(struct urb *urb)
 	unsigned char *data = ((unsigned char *)urb->transfer_buffer) + 3;
 	int flag, throttled;
 	int status = urb->status;
+	unsigned long flags;
 
 	/* do not process callbacks on closed ports */
 	/* but do continue the read chain */
@@ -1404,7 +1406,7 @@ static int digi_read_inb_callback(struct urb *urb)
 		return -1;
 	}
 
-	spin_lock(&priv->dp_port_lock);
+	spin_lock_irqsave(&priv->dp_port_lock, flags);
 
 	/* check for throttle; if set, do not resubmit read urb */
 	/* indicate the read chain needs to be restarted on unthrottle */
@@ -1438,7 +1440,7 @@ static int digi_read_inb_callback(struct urb *urb)
 			tty_flip_buffer_push(&port->port);
 		}
 	}
-	spin_unlock(&priv->dp_port_lock);
+	spin_unlock_irqrestore(&priv->dp_port_lock, flags);
 
 	if (opcode == DIGI_CMD_RECEIVE_DISABLE)
 		dev_dbg(&port->dev, "%s: got RECEIVE_DISABLE\n", __func__);
@@ -1469,6 +1471,7 @@ static int digi_read_oob_callback(struct urb *urb)
 	int opcode, line, status, val;
 	int i;
 	unsigned int rts;
+	unsigned long flags;
 
 	/* handle each oob command */
 	for (i = 0; i < urb->actual_length - 3;) {
@@ -1496,7 +1499,7 @@ static int digi_read_oob_callback(struct urb *urb)
 			rts = tty->termios.c_cflag & CRTSCTS;
 		
 		if (tty && opcode == DIGI_CMD_READ_INPUT_SIGNALS) {
-			spin_lock(&priv->dp_port_lock);
+			spin_lock_irqsave(&priv->dp_port_lock, flags);
 			/* convert from digi flags to termiox flags */
 			if (val & DIGI_READ_INPUT_SIGNALS_CTS) {
 				priv->dp_modem_signals |= TIOCM_CTS;
@@ -1524,12 +1527,12 @@ static int digi_read_oob_callback(struct urb *urb)
 			else
 				priv->dp_modem_signals &= ~TIOCM_CD;
 
-			spin_unlock(&priv->dp_port_lock);
+			spin_unlock_irqrestore(&priv->dp_port_lock, flags);
 		} else if (opcode == DIGI_CMD_TRANSMIT_IDLE) {
-			spin_lock(&priv->dp_port_lock);
+			spin_lock_irqsave(&priv->dp_port_lock, flags);
 			priv->dp_transmit_idle = 1;
 			wake_up_interruptible(&priv->dp_transmit_idle_wait);
-			spin_unlock(&priv->dp_port_lock);
+			spin_unlock_irqrestore(&priv->dp_port_lock, flags);
 		} else if (opcode == DIGI_CMD_IFLUSH_FIFO) {
 			wake_up_interruptible(&priv->dp_flush_wait);
 		}
-- 
1.7.9.5
