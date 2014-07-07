From: Olivier Sobrie <olivier@sobrie.be>
Subject: [PATCH 2/2] hso: fix deadlock when receiving bursts of data
Date: Mon,  7 Jul 2014 11:06:07 +0200
Message-ID: <1404723967-24245-2-git-send-email-olivier@sobrie.be>
References: <1404723967-24245-1-git-send-email-olivier@sobrie.be>
Cc: linux-kernel@vger.kernel.org, Olivier Sobrie <olivier@sobrie.be>
To: Jan Dumon <j.dumon@option.com>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:33528 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752176AbaGGJHe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2014 05:07:34 -0400
In-Reply-To: <1404723967-24245-1-git-send-email-olivier@sobrie.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the module sends bursts of data, sometimes a deadlock happens in
the hso driver when the tty buffer doesn't get the chance to be flushed
quickly enough.

To avoid this, first, we remove the endless while loop in
put_rx_bufdata() which is the root cause of the deadlock.
Secondly, when there is no room anymore in the tty buffer, we set up a
timer of 100 msecs to give a chance to the upper layer to flush the tty
buffer and make room for new data.

Signed-off-by: Olivier Sobrie <olivier@sobrie.be>
---
 drivers/net/usb/hso.c |   51 +++++++++++++++++++++++++++++++++----------------
 1 file changed, 35 insertions(+), 16 deletions(-)

diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index 9ca2b41..1dff74f 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -106,6 +106,8 @@
 
 #define MAX_RX_URBS			2
 
+#define UNTHROTTLE_TIMEOUT		100 /* msecs */
+
 /*****************************************************************************/
 /* Debugging functions                                                       */
 /*****************************************************************************/
@@ -261,6 +263,7 @@ struct hso_serial {
 	u16  curr_rx_urb_offset;
 	u8   rx_urb_filled[MAX_RX_URBS];
 	struct tasklet_struct unthrottle_tasklet;
+	struct timer_list unthrottle_timer;
 };
 
 struct hso_device {
@@ -1161,13 +1164,18 @@ static void put_rxbuf_data_and_resubmit_bulk_urb(struct hso_serial *serial)
 	while (serial->rx_urb_filled[serial->curr_rx_urb_idx]) {
 		curr_urb = serial->rx_urb[serial->curr_rx_urb_idx];
 		count = put_rxbuf_data(curr_urb, serial);
-		if (count == -1)
-			return;
 		if (count == 0) {
 			serial->curr_rx_urb_idx++;
 			if (serial->curr_rx_urb_idx >= serial->num_rx_urbs)
 				serial->curr_rx_urb_idx = 0;
 			hso_resubmit_rx_bulk_urb(serial, curr_urb);
+		} else if (count > 0) {
+			mod_timer(&serial->unthrottle_timer,
+				  jiffies
+					+ msecs_to_jiffies(UNTHROTTLE_TIMEOUT));
+			break;
+		} else {
+			break;
 		}
 	}
 }
@@ -1251,6 +1259,11 @@ static	void hso_unthrottle(struct tty_struct *tty)
 	tasklet_hi_schedule(&serial->unthrottle_tasklet);
 }
 
+static void hso_unthrottle_schedule(unsigned long data)
+{
+	tasklet_schedule((struct tasklet_struct *)data);
+}
+
 /* open the requested serial port */
 static int hso_serial_open(struct tty_struct *tty, struct file *filp)
 {
@@ -1286,6 +1299,10 @@ static int hso_serial_open(struct tty_struct *tty, struct file *filp)
 		tasklet_init(&serial->unthrottle_tasklet,
 			     (void (*)(unsigned long))hso_unthrottle_tasklet,
 			     (unsigned long)serial);
+		serial->unthrottle_timer.function = hso_unthrottle_schedule;
+		serial->unthrottle_timer.data =
+				(unsigned long)&serial->unthrottle_tasklet;
+		init_timer(&serial->unthrottle_timer);
 		result = hso_start_serial_device(serial->parent, GFP_KERNEL);
 		if (result) {
 			hso_stop_serial_device(serial->parent);
@@ -1333,6 +1350,7 @@ static void hso_serial_close(struct tty_struct *tty, struct file *filp)
 		tty_port_tty_set(&serial->port, NULL);
 		if (!usb_gone)
 			hso_stop_serial_device(serial->parent);
+		del_timer_sync(&serial->unthrottle_timer);
 		tasklet_kill(&serial->unthrottle_tasklet);
 	}
 
@@ -2012,22 +2030,23 @@ static int put_rxbuf_data(struct urb *urb, struct hso_serial *serial)
 
 	tty = tty_port_tty_get(&serial->port);
 
+	if (tty && test_bit(TTY_THROTTLED, &tty->flags)) {
+		tty_kref_put(tty);
+		return -1;
+	}
+
 	/* Push data to tty */
-	write_length_remaining = urb->actual_length -
-		serial->curr_rx_urb_offset;
 	D1("data to push to tty");
-	while (write_length_remaining) {
-		if (tty && test_bit(TTY_THROTTLED, &tty->flags)) {
-			tty_kref_put(tty);
-			return -1;
-		}
-		curr_write_len = tty_insert_flip_string(&serial->port,
-			urb->transfer_buffer + serial->curr_rx_urb_offset,
-			write_length_remaining);
-		serial->curr_rx_urb_offset += curr_write_len;
-		write_length_remaining -= curr_write_len;
-		tty_flip_buffer_push(&serial->port);
-	}
+	write_length_remaining = urb->actual_length -
+					serial->curr_rx_urb_offset;
+	curr_write_len =
+		tty_insert_flip_string(&serial->port,
+				       urb->transfer_buffer
+						+ serial->curr_rx_urb_offset,
+				       write_length_remaining);
+	serial->curr_rx_urb_offset += curr_write_len;
+	write_length_remaining -= curr_write_len;
+	tty_flip_buffer_push(&serial->port);
 	tty_kref_put(tty);
 
 	if (write_length_remaining == 0) {
-- 
1.7.9.5
