From: Denis Joseph Barrow <D.Barow@option.com>
Subject: [PATCH]  hso.c against 2.6.27-rc5 throttle/unthrottle to prevent
 loss of serial data
Date: Fri, 05 Sep 2008 11:35:38 +0200
Message-ID: <48C0FD6A.10706@option.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linux USB kernel mailing list <linux-usb@vger.kernel.org>,
	Linux netdev Mailing list <netdev@vger.kernel.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	=?ISO-8859-1?Q?N=E9meth_Tam=E1s?= <
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.option.com ([81.246.70.163]:38370 "EHLO
	mailer2.option.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750738AbYIEJfp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2008 05:35:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Greg, Jeff Alan Tamas & others,
please find a patch below, it isn't absolutely
vital that it makes it into the driver but it
would be nice if it did, if it is verified to be good.

I've verified that it does unthrottle & appears
to do the right thing I've yet to hear back
from our firmware diagnostic team at option
whether it really really works so I'm
posting this patch a bit prematurely.

The variable I'm most worried about in the patch is
int  curr_rx_urb_idx;
I depend in all cases that the URB callbacks
happen in order & the callback never fails.
If it does my driver might need to be insmodded
& rmmodded.

Tamas says my [PATCH] hso.c mutex fixups
doesn't apply properly do any of ye have
any problems with it?, is my emailer corrupting patches?

Well anyway find my latest patch below & give
me feedback on it. A about 3-4 times the modems serial
ports didn't didn't respond to commands while testing
I don't know whether this is a firmware problem
or a bug in my patch.

Alan you'll notice I'm calling tty_flip_buffer_push(tty)
i.e. flush_to_ldisc every 32 bytes as
TTY_THRESHOLD_THROTTLE in /drivers/char/n_tty.c is
only 128 bytes & I need to get unthrottled before
I lose characters it would be nice if the tty layer
could set the size of the throttle/unthrottle parameters
& the size of the n_tty ring buffer.


Patch to stop loss of characters on the hso modems,
this patch throttles & unthrottles the modem by
not putting out urbs until the tty/line discipline layer
has enough space for newly received packets.
serial ports. This is required for firmware diagnostics
being done at Option.
Signed-off-by: Denis Joseph Barrow <D.Barow@option.com>
Index: linux-2.6.27-rc5/drivers/net/usb/hso.c
===================================================================
--- linux-2.6.27-rc5.orig/drivers/net/usb/hso.c	2008-09-05 10:29:39.000000000 +0200
+++ linux-2.6.27-rc5/drivers/net/usb/hso.c	2008-09-05 11:05:22.000000000 +0200
@@ -92,9 +92,6 @@
 
 #define	HSO_NET_TX_TIMEOUT		(HZ*10)
 
-/* Serial port defines and structs. */
-#define HSO_SERIAL_FLAG_RX_SENT		0
-
 #define HSO_SERIAL_MAGIC		0x48534f31
 
 /* Number of ttys to handle */
@@ -179,6 +176,17 @@
 	unsigned long flags;
 };
 
+/*
+ * quarter of TTY_THRESHOLD_THROTTLE in /drivers/char/n_tty.c
+ */
+#define TTY_MAX_SEND_LEN     (32)
+
+enum rx_ctrl_state{
+	RX_IDLE,
+	RX_SENT,
+	RX_PENDING
+};
+
 struct hso_serial {
 	struct hso_device *parent;
 	int magic;
@@ -205,7 +213,7 @@
 	struct usb_endpoint_descriptor *in_endp;
 	struct usb_endpoint_descriptor *out_endp;
 
-	unsigned long flags;
+	enum rx_ctrl_state rx_state;
 	u8 rts_state;
 	u8 dtr_state;
 	unsigned tx_urb_used:1;
@@ -216,6 +224,15 @@
 	spinlock_t serial_lock;
 
 	int (*write_data) (struct hso_serial *serial);
+	/* Hacks required to get flow control
+	 * working on the serial receive buffers
+	 * so as not to drop characters on the floor.
+	 */
+	int  curr_rx_urb_idx;
+	u16  curr_rx_urb_offset;
+	u8   rx_urb_filled[MAX_RX_URBS];
+	struct tasklet_struct unthrottle_tasklet;
+	struct work_struct    retry_unthrottle_workqueue;
 };
 
 struct hso_device {
@@ -271,7 +288,7 @@
 static int hso_serial_tiocmset(struct tty_struct *tty, struct file *file,
 			       unsigned int set, unsigned int clear);
 static void ctrl_callback(struct urb *urb);
-static void put_rxbuf_data(struct urb *urb, struct hso_serial *serial);
+static int put_rxbuf_data(struct urb *urb, struct hso_serial *serial);
 static void hso_kick_transmit(struct hso_serial *serial);
 /* Helper functions */
 static int hso_mux_submit_intr_urb(struct hso_shared_int *mux_int,
@@ -287,6 +304,8 @@
 static void hso_free_shared_int(struct hso_shared_int *shared_int);
 static int hso_stop_net_device(struct hso_device *hso_dev);
 static void hso_serial_ref_free(struct kref *ref);
+static void hso_std_serial_read_bulk_callback(struct urb *urb);
+static int hso_mux_serial_read(struct hso_serial *serial);
 static void async_get_intf(struct work_struct *data);
 static void async_put_intf(struct work_struct *data);
 static int hso_put_activity(struct hso_device *hso_dev);
@@ -458,6 +477,17 @@
 }
 static DEVICE_ATTR(hsotype, S_IRUGO, hso_sysfs_show_porttype, NULL);
 
+static int hso_urb_to_index(struct hso_serial *serial, struct urb *urb)
+{
+	int idx;
+
+	for (idx = 0; idx < serial->num_rx_urbs; idx++)
+		if (serial->rx_urb[idx] == urb)
+			return idx;
+	dev_err(serial->parent->dev, "hso_urb_to_index failed\n");
+	return -1;
+}
+
 /* converts mux value to a port spec value */
 static u32 hso_mux_to_port(int mux)
 {
@@ -1039,6 +1069,158 @@
 	return;
 }
 
+static void hso_resubmit_rx_bulk_urb(struct hso_serial *serial, struct urb *urb)
+{
+	int result;
+#ifdef CONFIG_HSO_AUTOPM
+	usb_mark_last_busy(urb->dev);
+#endif
+	/* We are done with this URB, resubmit it. Prep the USB to wait for
+	 * another frame */
+	usb_fill_bulk_urb(urb, serial->parent->usb,
+			  usb_rcvbulkpipe(serial->parent->usb,
+					  serial->in_endp->
+					  bEndpointAddress & 0x7F),
+			  urb->transfer_buffer, serial->rx_data_length,
+			  hso_std_serial_read_bulk_callback, serial);
+	/* Give this to the USB subsystem so it can tell us when more data
+	 * arrives. */
+	result = usb_submit_urb(urb, GFP_ATOMIC);
+	if (result) {
+		dev_err(&urb->dev->dev, "%s failed submit serial rx_urb %d\n",
+			__func__, result);
+	}
+}
+
+
+
+
+static void put_rxbuf_data_and_resubmit_bulk_urb(struct hso_serial *serial)
+{
+	int count;
+	struct urb *curr_urb;
+
+	while (serial->rx_urb_filled[serial->curr_rx_urb_idx]) {
+		curr_urb = serial->rx_urb[serial->curr_rx_urb_idx];
+		count = put_rxbuf_data(curr_urb, serial);
+		if (count == -1)
+			return;
+		if (count == 0) {
+			serial->curr_rx_urb_idx++;
+			if (serial->curr_rx_urb_idx >= serial->num_rx_urbs)
+				serial->curr_rx_urb_idx = 0;
+			hso_resubmit_rx_bulk_urb(serial, curr_urb);
+		}
+	}
+}
+
+static void put_rxbuf_data_and_resubmit_ctrl_urb(struct hso_serial *serial)
+{
+	int count = 0;
+	struct urb *urb;
+
+	urb = serial->rx_urb[0];
+	if (serial->open_count > 0) {
+		count = put_rxbuf_data(urb, serial);
+		if (count == -1)
+			return;
+	}
+	/* Re issue a read as long as we receive data. */
+
+	if (count == 0 && ((urb->actual_length != 0) ||
+			   (serial->rx_state == RX_PENDING))) {
+		serial->rx_state = RX_SENT;
+		hso_mux_serial_read(serial);
+	} else
+		serial->rx_state = RX_IDLE;
+}
+
+
+/* read callback for Diag and CS port */
+static void hso_std_serial_read_bulk_callback(struct urb *urb)
+{
+	struct hso_serial *serial = urb->context;
+	int status = urb->status;
+
+	/* sanity check */
+	if (!serial) {
+		D1("serial == NULL");
+		return;
+	} else if (status) {
+		log_usb_status(status, __func__);
+		return;
+	}
+
+	D4("\n--- Got serial_read_bulk callback %02x ---", status);
+	D1("Actual length = %d\n", urb->actual_length);
+	DUMP1(urb->transfer_buffer, urb->actual_length);
+
+	/* Anyone listening? */
+	if (serial->open_count == 0)
+		return;
+
+	if (status == 0) {
+		if (serial->parent->port_spec & HSO_INFO_CRC_BUG) {
+			u32 rest;
+			u8 crc_check[4] = { 0xDE, 0xAD, 0xBE, 0xEF };
+			rest =
+			    urb->actual_length %
+			    serial->in_endp->wMaxPacketSize;
+			if (((rest == 5) || (rest == 6))
+			    && !memcmp(((u8 *) urb->transfer_buffer) +
+				       urb->actual_length - 4, crc_check, 4)) {
+				urb->actual_length -= 4;
+			}
+		}
+		/* Valid data, handle RX data */
+		spin_lock(&serial->serial_lock);
+		serial->rx_urb_filled[hso_urb_to_index(serial, urb)] = 1;
+		put_rxbuf_data_and_resubmit_bulk_urb(serial);
+		spin_unlock(&serial->serial_lock);
+	} else if (status == -ENOENT || status == -ECONNRESET) {
+		/* Unlinked - check for throttled port. */
+		D2("Port %d, successfully unlinked urb", serial->minor);
+		spin_lock(&serial->serial_lock);
+		serial->rx_urb_filled[hso_urb_to_index(serial, urb)] = 0;
+		hso_resubmit_rx_bulk_urb(serial, urb);
+		spin_unlock(&serial->serial_lock);
+	} else {
+		D2("Port %d, status = %d for read urb", serial->minor, status);
+		return;
+	}
+}
+
+/*
+ * This needs to be a tasklet otherwise we will
+ * end up recursively calling this function.
+ */
+void hso_unthrottle_tasklet(struct hso_serial *serial)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&serial->serial_lock, flags);
+	if ((serial->parent->port_spec & HSO_INTF_MUX))
+		put_rxbuf_data_and_resubmit_ctrl_urb(serial);
+	else
+		put_rxbuf_data_and_resubmit_bulk_urb(serial);
+	spin_unlock_irqrestore(&serial->serial_lock, flags);
+}
+
+static	void hso_unthrottle(struct tty_struct *tty)
+{
+	struct hso_serial *serial = get_serial_by_tty(tty);
+
+	tasklet_hi_schedule(&serial->unthrottle_tasklet);
+}
+
+void hso_unthrottle_workfunc(struct work_struct *work)
+{
+	struct hso_serial *serial =
+	    container_of(work, struct hso_serial,
+			 retry_unthrottle_workqueue);
+	hso_unthrottle_tasklet(serial);
+}
+
 /* open the requested serial port */
 static int hso_serial_open(struct tty_struct *tty, struct file *filp)
 {
@@ -1064,13 +1246,18 @@
 	tty->driver_data = serial;
 	serial->tty = tty;
 
-	/* check for port allready opened, if not set the termios */
+	/* check for port already opened, if not set the termios */
 	serial->open_count++;
 	if (serial->open_count == 1) {
 		tty->low_latency = 1;
-		serial->flags = 0;
+		serial->rx_state = RX_IDLE;
 		/* Force default termio settings */
 		_hso_serial_set_termios(tty, NULL);
+		tasklet_init(&serial->unthrottle_tasklet,
+			     (void (*)(unsigned long))hso_unthrottle_tasklet,
+			     (unsigned long)serial);
+		INIT_WORK(&serial->retry_unthrottle_workqueue,
+			  hso_unthrottle_workfunc);
 		result = hso_start_serial_device(serial->parent, GFP_KERNEL);
 		if (result) {
 			hso_stop_serial_device(serial->parent);
@@ -1117,9 +1304,13 @@
 		}
 		if (!usb_gone)
 			hso_stop_serial_device(serial->parent);
+		tasklet_kill(&serial->unthrottle_tasklet);
+		cancel_work_sync(&serial->retry_unthrottle_workqueue);
 	}
+
 	if (!usb_gone)
 		usb_autopm_put_interface(serial->parent->interface);
+
 	mutex_unlock(&serial->parent->mutex);
 }
 
@@ -1422,15 +1613,21 @@
 								   (1 << i));
 			if (serial != NULL) {
 				D1("Pending read interrupt on port %d\n", i);
-				if (!test_and_set_bit(HSO_SERIAL_FLAG_RX_SENT,
-						      &serial->flags)) {
+				spin_lock(&serial->serial_lock);
+				if (serial->rx_state == RX_IDLE) {
 					/* Setup and send a ctrl req read on
 					 * port i */
-					hso_mux_serial_read(serial);
+				if (!serial->rx_urb_filled[0]) {
+						serial->rx_state = RX_SENT;
+						hso_mux_serial_read(serial);
+					} else
+						serial->rx_state = RX_PENDING;
+
 				} else {
 					D1("Already pending a read on "
 					   "port %d\n", i);
 				}
+				spin_unlock(&serial->serial_lock);
 			}
 		}
 	}
@@ -1532,16 +1729,10 @@
 	if (req->bRequestType ==
 	    (USB_DIR_IN | USB_TYPE_OPTION_VENDOR | USB_RECIP_INTERFACE)) {
 		/* response to a read command */
-		if (serial->open_count > 0) {
-			/* handle RX data the normal way */
-			put_rxbuf_data(urb, serial);
-		}
-
-		/* Re issue a read as long as we receive data. */
-		if (urb->actual_length != 0)
-			hso_mux_serial_read(serial);
-		else
-			clear_bit(HSO_SERIAL_FLAG_RX_SENT, &serial->flags);
+		serial->rx_urb_filled[0] = 1;
+		spin_lock(&serial->serial_lock);
+		put_rxbuf_data_and_resubmit_ctrl_urb(serial);
+		spin_unlock(&serial->serial_lock);
 	} else {
 		hso_put_activity(serial->parent);
 		if (serial->tty)
@@ -1552,90 +1743,44 @@
 }
 
 /* handle RX data for serial port */
-static void put_rxbuf_data(struct urb *urb, struct hso_serial *serial)
+static int put_rxbuf_data(struct urb *urb, struct hso_serial *serial)
 {
 	struct tty_struct *tty = serial->tty;
+	int write_length_remaining = 0;
+	int curr_write_len;
 
 	/* Sanity check */
 	if (urb == NULL || serial == NULL) {
 		D1("serial = NULL");
-		return;
+		return -2;
 	}
 
 	/* Push data to tty */
-	if (tty && urb->actual_length) {
+	if (tty) {
+		write_length_remaining = urb->actual_length -
+			serial->curr_rx_urb_offset;
 		D1("data to push to tty");
-		tty_insert_flip_string(tty, urb->transfer_buffer,
-				       urb->actual_length);
-		tty_flip_buffer_push(tty);
+		while (write_length_remaining) {
+			if (test_bit(TTY_THROTTLED, &tty->flags))
+				return -1;
+			curr_write_len = min(write_length_remaining,
+					     TTY_MAX_SEND_LEN);
+			serial->curr_rx_urb_offset += tty_insert_flip_string
+				(tty, urb->transfer_buffer +
+				 serial->curr_rx_urb_offset,
+				 curr_write_len);
+			tty_flip_buffer_push(tty);
+			write_length_remaining -= curr_write_len;
+		}
+	}
+	if (write_length_remaining == 0) {
+		serial->curr_rx_urb_offset = 0;
+		serial->rx_urb_filled[hso_urb_to_index(serial, urb)] = 0;
 	}
+	return write_length_remaining;
 }
 
-/* read callback for Diag and CS port */
-static void hso_std_serial_read_bulk_callback(struct urb *urb)
-{
-	struct hso_serial *serial = urb->context;
-	int result;
-	int status = urb->status;
-
-	/* sanity check */
-	if (!serial) {
-		D1("serial == NULL");
-		return;
-	} else if (status) {
-		log_usb_status(status, __func__);
-		return;
-	}
 
-	D4("\n--- Got serial_read_bulk callback %02x ---", status);
-	D1("Actual length = %d\n", urb->actual_length);
-	DUMP1(urb->transfer_buffer, urb->actual_length);
-
-	/* Anyone listening? */
-	if (serial->open_count == 0)
-		return;
-
-	if (status == 0) {
-		if (serial->parent->port_spec & HSO_INFO_CRC_BUG) {
-			u32 rest;
-			u8 crc_check[4] = { 0xDE, 0xAD, 0xBE, 0xEF };
-			rest =
-			    urb->actual_length %
-			    serial->in_endp->wMaxPacketSize;
-			if (((rest == 5) || (rest == 6))
-			    && !memcmp(((u8 *) urb->transfer_buffer) +
-				       urb->actual_length - 4, crc_check, 4)) {
-				urb->actual_length -= 4;
-			}
-		}
-		/* Valid data, handle RX data */
-		put_rxbuf_data(urb, serial);
-	} else if (status == -ENOENT || status == -ECONNRESET) {
-		/* Unlinked - check for throttled port. */
-		D2("Port %d, successfully unlinked urb", serial->minor);
-	} else {
-		D2("Port %d, status = %d for read urb", serial->minor, status);
-		return;
-	}
-
-	usb_mark_last_busy(urb->dev);
-
-	/* We are done with this URB, resubmit it. Prep the USB to wait for
-	 * another frame */
-	usb_fill_bulk_urb(urb, serial->parent->usb,
-			  usb_rcvbulkpipe(serial->parent->usb,
-					  serial->in_endp->
-					  bEndpointAddress & 0x7F),
-			  urb->transfer_buffer, serial->rx_data_length,
-			  hso_std_serial_read_bulk_callback, serial);
-	/* Give this to the USB subsystem so it can tell us when more data
-	 * arrives. */
-	result = usb_submit_urb(urb, GFP_ATOMIC);
-	if (result) {
-		dev_err(&urb->dev->dev, "%s failed submit serial rx_urb %d",
-			__func__, result);
-	}
-}
 
 /* Base driver functions */
 
@@ -1794,9 +1939,13 @@
 		return -ENODEV;
 
 	for (i = 0; i < serial->num_rx_urbs; i++) {
-		if (serial->rx_urb[i])
+		if (serial->rx_urb[i]) {
 				usb_kill_urb(serial->rx_urb[i]);
+				serial->rx_urb_filled[i] = 0;
+		}
 	}
+	serial->curr_rx_urb_idx = 0;
+	serial->curr_rx_urb_offset = 0;
 
 	if (serial->tx_urb)
 		usb_kill_urb(serial->tx_urb);
@@ -2740,6 +2889,7 @@
 	.chars_in_buffer = hso_serial_chars_in_buffer,
 	.tiocmget = hso_serial_tiocmget,
 	.tiocmset = hso_serial_tiocmset,
+	.unthrottle = hso_unthrottle
 };
 
 static struct usb_driver hso_driver = {

-- 
best regards,
D.J. Barrow
