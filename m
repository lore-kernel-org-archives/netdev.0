From: Denis Joseph Barrow <D.Barow@option.com>
Subject: [PATCH] hso set tty->low_latency to 0
Date: Mon, 19 Jan 2009 16:46:59 +0100
Message-ID: <4974A073.3060102@option.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080503000109070901020205"
To: Linux Serial <linux-serial@vger.kernel.org>,
	Linux USB kernel mailing list <linux-usb@vger.kernel.org>,
	Linux netdev Mailing list <netdev@vger.kernel.org>
Return-path: <linux-serial-owner@vger.kernel.org>
Sender: linux-serial-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080503000109070901020205
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hi all,
Alan Cox wanted low_latency set to 0,
this I believe does the job & throttling & unthrottling.
Let me know if there are any problems.

Sets tty->low_latency to 0 gets rid of the unthrottle
tasklet which is no longer neccessary with low_latency=0
& infinite loops which would manifest themselves in
put_rxbuf_data as a result of setting low_latency to 0.
Signed-off-by: Denis Joseph Barrow <D.Barow@option.com>
---
Index: linux-2.6/drivers/net/usb/hso.c
===================================================================
--- linux-2.6.orig/drivers/net/usb/hso.c	2009-01-19 16:30:59.000000000 +0100
+++ linux-2.6/drivers/net/usb/hso.c	2009-01-19 16:31:20.000000000 +0100
@@ -269,7 +269,6 @@
 	int  curr_rx_urb_idx;
 	u16  curr_rx_urb_offset;
 	u8   rx_urb_filled[MAX_RX_URBS];
-	struct tasklet_struct unthrottle_tasklet;
 };
 
 struct hso_device {
@@ -1240,27 +1239,17 @@
 	}
 }
 
-/*
- * This needs to be a tasklet otherwise we will
- * end up recursively calling this function.
- */
-void hso_unthrottle_tasklet(struct hso_serial *serial)
+
+static	void hso_unthrottle(struct tty_struct *tty)
 {
-	unsigned long flags;
+	struct hso_serial *serial = get_serial_by_tty(tty);
 
-	spin_lock_irqsave(&serial->serial_lock, flags);
+	spin_lock_irq(&serial->serial_lock);
 	if ((serial->parent->port_spec & HSO_INTF_MUX))
 		put_rxbuf_data_and_resubmit_ctrl_urb(serial);
 	else
 		put_rxbuf_data_and_resubmit_bulk_urb(serial);
-	spin_unlock_irqrestore(&serial->serial_lock, flags);
-}
-
-static	void hso_unthrottle(struct tty_struct *tty)
-{
-	struct hso_serial *serial = get_serial_by_tty(tty);
-
-	tasklet_hi_schedule(&serial->unthrottle_tasklet);
+	spin_unlock_irq(&serial->serial_lock);
 }
 
 /* open the requested serial port */
@@ -1295,13 +1284,9 @@
 	/* check for port already opened, if not set the termios */
 	serial->open_count++;
 	if (serial->open_count == 1) {
-		tty->low_latency = 1;
 		serial->rx_state = RX_IDLE;
 		/* Force default termio settings */
 		_hso_serial_set_termios(tty, NULL);
-		tasklet_init(&serial->unthrottle_tasklet,
-			     (void (*)(unsigned long))hso_unthrottle_tasklet,
-			     (unsigned long)serial);
 		result = hso_start_serial_device(serial->parent, GFP_KERNEL);
 		if (result) {
 			hso_stop_serial_device(serial->parent);
@@ -1355,7 +1340,6 @@
 		spin_unlock_irq(&serial->serial_lock);
 		if (!usb_gone)
 			hso_stop_serial_device(serial->parent);
-		tasklet_kill(&serial->unthrottle_tasklet);
 	}
 
 	if (!usb_gone)
@@ -1885,12 +1869,11 @@
 				if (serial->rx_state == RX_IDLE) {
 					/* Setup and send a ctrl req read on
 					 * port i */
-				if (!serial->rx_urb_filled[0]) {
+					if (!serial->rx_urb_filled[0]) {
 						serial->rx_state = RX_SENT;
 						hso_mux_serial_read(serial);
 					} else
 						serial->rx_state = RX_PENDING;
-
 				} else {
 					D1("Already pending a read on "
 					   "port %d\n", i);
@@ -2048,6 +2031,15 @@
 				(tty, urb->transfer_buffer +
 				 serial->curr_rx_urb_offset,
 				 write_length_remaining);
+			if (curr_write_len == 0) {
+				/* Setting TTY_THROTTLED is ugly but
+				   we need a the hso_unthrottle callback
+				   to say we can start resubmitting URBS.
+				*/
+				set_bit(TTY_THROTTLED, &tty->flags);
+				tty_kref_put(tty);
+				return -1;
+			}
 			serial->curr_rx_urb_offset += curr_write_len;
 			write_length_remaining -= curr_write_len;
 			tty_flip_buffer_push(tty);

-- 
best regards,
D.J. Barrow

Linux Kernel Developer
Option NV, Gaston Geenslaan 14, 3001 Leuven, Belgium
 
T: +32 16 311 621
F: +32 16 207 164
d.barow@option.com
www.option.com

Disclaimer:
http://www.option.com/company/disclaimer.shtml

--------------080503000109070901020205
Content-Type: text/x-diff;
 name="hso_low_latency_fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="hso_low_latency_fix.patch"

Sets tty->low_latency to 0 gets rid of the unthrottle
tasklet which is no longer neccessary with low_latency=0
& infinite loops which would manifest themselves in
put_rxbuf_data as a result of setting low_latency to 0.
Signed-off-by: Denis Joseph Barrow <D.Barow@option.com>
---
Index: linux-2.6/drivers/net/usb/hso.c
===================================================================
--- linux-2.6.orig/drivers/net/usb/hso.c	2009-01-19 16:30:59.000000000 +0100
+++ linux-2.6/drivers/net/usb/hso.c	2009-01-19 16:31:20.000000000 +0100
@@ -269,7 +269,6 @@
 	int  curr_rx_urb_idx;
 	u16  curr_rx_urb_offset;
 	u8   rx_urb_filled[MAX_RX_URBS];
-	struct tasklet_struct unthrottle_tasklet;
 };
 
 struct hso_device {
@@ -1240,27 +1239,17 @@
 	}
 }
 
-/*
- * This needs to be a tasklet otherwise we will
- * end up recursively calling this function.
- */
-void hso_unthrottle_tasklet(struct hso_serial *serial)
+
+static	void hso_unthrottle(struct tty_struct *tty)
 {
-	unsigned long flags;
+	struct hso_serial *serial = get_serial_by_tty(tty);
 
-	spin_lock_irqsave(&serial->serial_lock, flags);
+	spin_lock_irq(&serial->serial_lock);
 	if ((serial->parent->port_spec & HSO_INTF_MUX))
 		put_rxbuf_data_and_resubmit_ctrl_urb(serial);
 	else
 		put_rxbuf_data_and_resubmit_bulk_urb(serial);
-	spin_unlock_irqrestore(&serial->serial_lock, flags);
-}
-
-static	void hso_unthrottle(struct tty_struct *tty)
-{
-	struct hso_serial *serial = get_serial_by_tty(tty);
-
-	tasklet_hi_schedule(&serial->unthrottle_tasklet);
+	spin_unlock_irq(&serial->serial_lock);
 }
 
 /* open the requested serial port */
@@ -1295,13 +1284,9 @@
 	/* check for port already opened, if not set the termios */
 	serial->open_count++;
 	if (serial->open_count == 1) {
-		tty->low_latency = 1;
 		serial->rx_state = RX_IDLE;
 		/* Force default termio settings */
 		_hso_serial_set_termios(tty, NULL);
-		tasklet_init(&serial->unthrottle_tasklet,
-			     (void (*)(unsigned long))hso_unthrottle_tasklet,
-			     (unsigned long)serial);
 		result = hso_start_serial_device(serial->parent, GFP_KERNEL);
 		if (result) {
 			hso_stop_serial_device(serial->parent);
@@ -1355,7 +1340,6 @@
 		spin_unlock_irq(&serial->serial_lock);
 		if (!usb_gone)
 			hso_stop_serial_device(serial->parent);
-		tasklet_kill(&serial->unthrottle_tasklet);
 	}
 
 	if (!usb_gone)
@@ -1885,12 +1869,11 @@
 				if (serial->rx_state == RX_IDLE) {
 					/* Setup and send a ctrl req read on
 					 * port i */
-				if (!serial->rx_urb_filled[0]) {
+					if (!serial->rx_urb_filled[0]) {
 						serial->rx_state = RX_SENT;
 						hso_mux_serial_read(serial);
 					} else
 						serial->rx_state = RX_PENDING;
-
 				} else {
 					D1("Already pending a read on "
 					   "port %d\n", i);
@@ -2048,6 +2031,15 @@
 				(tty, urb->transfer_buffer +
 				 serial->curr_rx_urb_offset,
 				 write_length_remaining);
+			if (curr_write_len == 0) {
+				/* Setting TTY_THROTTLED is ugly but
+				   we need a the hso_unthrottle callback
+				   to say we can start resubmitting URBS.
+				*/
+				set_bit(TTY_THROTTLED, &tty->flags);
+				tty_kref_put(tty);
+				return -1;
+			}
 			serial->curr_rx_urb_offset += curr_write_len;
 			write_length_remaining -= curr_write_len;
 			tty_flip_buffer_push(tty);

--------------080503000109070901020205--
