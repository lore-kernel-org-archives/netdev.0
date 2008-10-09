From: Denis Joseph Barrow <D.Barow@option.com>
Subject: [PATCH] hso modem signals data carrier detect etc. patch
Date: Thu, 09 Oct 2008 17:26:06 +0200
Message-ID: <48EE228E.7090602@option.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010303000002090907090808"
To: Linux USB kernel mailing list <linux-usb@vger.kernel.org>,
	Linux netdev Mailing list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.option.com ([81.246.70.162]:23884 "EHLO
	mailer1.option.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753350AbYJIP0L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 11:26:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010303000002090907090808
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hi,
This isn't a vital patch it is primarily done for completeness
of the hso modem implementation.

It's unfortunate that my mutex patch etc. hasn't made it
into linuses kernel yet this means the maintainers will have
a lot more work to do as my patches are gathering code rot
from not being used. The patches will no longer apply cleanly
on top of each other

I've added a tiny test app dcdtest so that one can see the modem
signals working.

Makes TIOCM ioctls for Data Carrier Detect & related functions
work like /drivers/serial/serial-core.c potentially needed 
for pppd & similar user programs.   
Signed-off-by: Denis Joseph Barrow <D.Barow@option.com>
---
Index: linux-2.6.27-rc9/drivers/net/usb/hso.c
===================================================================
--- linux-2.6.27-rc9.orig/drivers/net/usb/hso.c	2008-10-09 15:55:31.000000000 +0200
+++ linux-2.6.27-rc9/drivers/net/usb/hso.c	2008-10-09 17:13:26.000000000 +0200
@@ -39,8 +39,11 @@
  *		port is opened, as this have a huge impact on the network port
  *		throughput.
  *
- * Interface 2:	Standard modem interface - circuit switched interface, should
- *		not be used.
+ * Interface 2:	Standard modem interface - circuit switched interface, this
+ *		can be used to make a standard ppp connection however it
+ *              should not be used in conjunction with the IP network interface
+ *              enabled for USB performance reasons i.e. if using this set
+ *              ideally disable_net=1.
  *
  *****************************************************************************/
 
@@ -63,6 +66,8 @@
 #include <linux/usb/cdc.h>
 #include <net/arp.h>
 #include <asm/byteorder.h>
+#include <linux/serial_core.h>
+#include <linux/serial.h>
 
 
 #define DRIVER_VERSION			"1.2"
@@ -179,6 +184,41 @@
 	unsigned long flags;
 };
 
+#define BM_REQUEST_TYPE (0xa1)
+#define B_NOTIFICATION  (0x20)
+#define W_VALUE         (0x0)
+#define W_INDEX         (0x2)
+#define W_LENGTH        (0x2)
+
+#define B_OVERRUN       (0x1<<6)
+#define B_PARITY        (0x1<<5)
+#define B_FRAMING       (0x1<<4)
+#define B_RING_SIGNAL   (0x1<<3)
+#define B_BREAK         (0x1<<2)
+#define B_TX_CARRIER    (0x1<<1)
+#define B_RX_CARRIER    (0x1<<0)
+
+struct hso_serial_state_notification {
+	u8 bmRequestType;
+	u8 bNotification;
+	u16 wValue;
+	u16 wIndex;
+	u16 wLength;
+	u16 UART_state_bitmap;
+} __attribute__((packed));
+
+struct hso_tiocmget {
+	struct mutex mutex;
+	wait_queue_head_t waitq;
+	int    intr_completed;
+	struct usb_endpoint_descriptor *endp;
+	struct urb *urb;
+	struct hso_serial_state_notification serial_state_notification;
+	u16    prev_UART_state_bitmap;
+	struct uart_icount icount;
+};
+
+
 struct hso_serial {
 	struct hso_device *parent;
 	int magic;
@@ -216,6 +256,7 @@
 	spinlock_t serial_lock;
 
 	int (*write_data) (struct hso_serial *serial);
+	struct hso_tiocmget  *tiocmget;
 };
 
 struct hso_device {
@@ -291,7 +332,7 @@
 static void async_put_intf(struct work_struct *data);
 static int hso_put_activity(struct hso_device *hso_dev);
 static int hso_get_activity(struct hso_device *hso_dev);
-
+static void tiocmget_intr_callback(struct urb *urb);
 /*****************************************************************************/
 /* Helping functions                                                         */
 /*****************************************************************************/
@@ -1210,25 +1251,217 @@
 
 	return chars;
 }
+int tiocmget_submit_urb(struct hso_serial *serial,
+			struct hso_tiocmget  *tiocmget,
+			struct usb_device *usb)
+{
+	int result;
+
+	if (serial->parent->usb_gone)
+		return -ENODEV;
+	usb_fill_int_urb(tiocmget->urb, usb,
+			 usb_rcvintpipe(usb,
+					tiocmget->endp->
+					bEndpointAddress & 0x7F),
+			 &tiocmget->serial_state_notification,
+			 sizeof(struct hso_serial_state_notification),
+			 tiocmget_intr_callback, serial,
+			 tiocmget->endp->bInterval);
+	result = usb_submit_urb(tiocmget->urb, GFP_ATOMIC);
+	if (result) {
+		dev_warn(&usb->dev, "%s usb_submit_urb failed %d\n", __func__,
+			 result);
+	}
+	return result;
+
+}
+
+static void tiocmget_intr_callback(struct urb *urb)
+{
+	struct hso_serial *serial = urb->context;
+	struct hso_tiocmget *tiocmget;
+	int status = urb->status;
+	u16 UART_state_bitmap, prev_UART_state_bitmap;
+	struct uart_icount *icount;
+	struct hso_serial_state_notification *serial_state_notification;
+	struct usb_device *usb;
+
+	/* Sanity checks */
+	if (!serial)
+		return;
+	if (status) {
+		log_usb_status(status, __func__);
+		return;
+	}
+	tiocmget = serial->tiocmget;
+	if (!tiocmget)
+		return;
+	usb = serial->parent->usb;
+	serial_state_notification = &tiocmget->serial_state_notification;
+	if (serial_state_notification->bmRequestType != BM_REQUEST_TYPE ||
+	    serial_state_notification->bNotification != B_NOTIFICATION ||
+	    le16_to_cpu(serial_state_notification->wValue) != W_VALUE ||
+	    le16_to_cpu(serial_state_notification->wIndex) != W_INDEX ||
+	    le16_to_cpu(serial_state_notification->wLength) != W_LENGTH) {
+		dev_warn(&usb->dev,
+			 "hso received invalid serial state notification\n");
+		DUMP(serial_state_notification,
+		     sizeof(hso_serial_state_notifation))
+	} else {
+
+		UART_state_bitmap = le16_to_cpu(serial_state_notification->
+						UART_state_bitmap);
+		prev_UART_state_bitmap = tiocmget->prev_UART_state_bitmap;
+		icount = &tiocmget->icount;
+		spin_lock(&serial->serial_lock);
+		if ((UART_state_bitmap & B_OVERRUN) !=
+		   (prev_UART_state_bitmap & B_OVERRUN))
+			icount->parity++;
+		if ((UART_state_bitmap & B_PARITY) !=
+		   (prev_UART_state_bitmap & B_PARITY))
+			icount->parity++;
+		if ((UART_state_bitmap & B_FRAMING) !=
+		   (prev_UART_state_bitmap & B_FRAMING))
+			icount->frame++;
+		if ((UART_state_bitmap & B_RING_SIGNAL) &&
+		   !(prev_UART_state_bitmap & B_RING_SIGNAL))
+			icount->rng++;
+		if ((UART_state_bitmap & B_BREAK) !=
+		   (prev_UART_state_bitmap & B_BREAK))
+			icount->brk++;
+		if ((UART_state_bitmap & B_TX_CARRIER) !=
+		   (prev_UART_state_bitmap & B_TX_CARRIER))
+			icount->dsr++;
+		if ((UART_state_bitmap & B_RX_CARRIER) !=
+		   (prev_UART_state_bitmap & B_RX_CARRIER))
+			icount->dcd++;
+		tiocmget->prev_UART_state_bitmap = UART_state_bitmap;
+		spin_unlock(&serial->serial_lock);
+		tiocmget->intr_completed = 1;
+		wake_up_interruptible(&tiocmget->waitq);
+	}
+	memset(serial_state_notification, 0,
+	       sizeof(struct hso_serial_state_notification));
+	tiocmget_submit_urb(serial,
+			    tiocmget,
+			    serial->parent->usb);
+}
+
+/*
+ * next few functions largely stolen from drivers/serial/serial_core.c
+ */
+/* Wait for any of the 4 modem inputs (DCD,RI,DSR,CTS) to change
+ * - mask passed in arg for lines of interest
+ *   (use |'ed TIOCM_RNG/DSR/CD/CTS for masking)
+ * Caller should use TIOCGICOUNT to see which one it was
+ */
+static int
+hso_wait_modem_status(struct hso_serial *serial, unsigned long arg)
+{
+	DECLARE_WAITQUEUE(wait, current);
+	struct uart_icount cprev, cnow;
+	struct hso_tiocmget  *tiocmget;
+	int ret;
+
+	tiocmget = serial->tiocmget;
+	if (!tiocmget)
+		return -ENOENT;
+	/*
+	 * note the counters on entry
+	 */
+	spin_lock_irq(&serial->serial_lock);
+	memcpy(&cprev, &tiocmget->icount, sizeof(struct uart_icount));
+	spin_unlock_irq(&serial->serial_lock);
+	add_wait_queue(&tiocmget->waitq, &wait);
+	for (;;) {
+		spin_lock_irq(&serial->serial_lock);
+		memcpy(&cnow, &tiocmget->icount, sizeof(struct uart_icount));
+		spin_unlock_irq(&serial->serial_lock);
+		set_current_state(TASK_INTERRUPTIBLE);
+		if (((arg & TIOCM_RNG) && (cnow.rng != cprev.rng)) ||
+		    ((arg & TIOCM_DSR) && (cnow.dsr != cprev.dsr)) ||
+		    ((arg & TIOCM_CD)  && (cnow.dcd != cprev.dcd))) {
+			ret = 0;
+			break;
+		}
+		schedule();
+		/* see if a signal did it */
+		if (signal_pending(current)) {
+			ret = -ERESTARTSYS;
+			break;
+		}
+		cprev = cnow;
+	}
+	current->state = TASK_RUNNING;
+	remove_wait_queue(&tiocmget->waitq, &wait);
+
+	return ret;
+}
+
+/*
+ * Get counter of input serial line interrupts (DCD,RI,DSR,CTS)
+ * Return: write counters to the user passed counter struct
+ * NB: both 1->0 and 0->1 transitions are counted except for
+ *     RI where only 0->1 is counted.
+ */
+static int hso_get_count(struct hso_serial *serial,
+			  struct serial_icounter_struct __user *icnt)
+{
+	struct serial_icounter_struct icount;
+	struct uart_icount cnow;
+	struct hso_tiocmget  *tiocmget = serial->tiocmget;
+
+	if (!tiocmget)
+		 return -ENOENT;
+	spin_lock_irq(&serial->serial_lock);
+	memcpy(&cnow, &tiocmget->icount, sizeof(struct uart_icount));
+	spin_unlock_irq(&serial->serial_lock);
+
+	icount.cts         = cnow.cts;
+	icount.dsr         = cnow.dsr;
+	icount.rng         = cnow.rng;
+	icount.dcd         = cnow.dcd;
+	icount.rx          = cnow.rx;
+	icount.tx          = cnow.tx;
+	icount.frame       = cnow.frame;
+	icount.overrun     = cnow.overrun;
+	icount.parity      = cnow.parity;
+	icount.brk         = cnow.brk;
+	icount.buf_overrun = cnow.buf_overrun;
+
+	return copy_to_user(icnt, &icount, sizeof(icount)) ? -EFAULT : 0;
+}
+
 
 static int hso_serial_tiocmget(struct tty_struct *tty, struct file *file)
 {
-	unsigned int value;
+	int retval;
 	struct hso_serial *serial = get_serial_by_tty(tty);
-	unsigned long flags;
+	struct hso_tiocmget  *tiocmget;
+	u16 UART_state_bitmap;
 
 	/* sanity check */
 	if (!serial) {
 		D1("no tty structures");
 		return -EINVAL;
 	}
-
-	spin_lock_irqsave(&serial->serial_lock, flags);
-	value = ((serial->rts_state) ? TIOCM_RTS : 0) |
+	spin_lock_irq(&serial->serial_lock);
+	retval = ((serial->rts_state) ? TIOCM_RTS : 0) |
 	    ((serial->dtr_state) ? TIOCM_DTR : 0);
-	spin_unlock_irqrestore(&serial->serial_lock, flags);
+	tiocmget = serial->tiocmget;
+	if (tiocmget) {
 
-	return value;
+		UART_state_bitmap = le16_to_cpu(
+			tiocmget->prev_UART_state_bitmap);
+		if (UART_state_bitmap & B_RING_SIGNAL)
+			retval |=  TIOCM_RNG;
+		if (UART_state_bitmap & B_RX_CARRIER)
+			retval |=  TIOCM_CD;
+		if (UART_state_bitmap & B_TX_CARRIER)
+			retval |=  TIOCM_DSR;
+	}
+	spin_unlock_irq(&serial->serial_lock);
+	return retval;
 }
 
 static int hso_serial_tiocmset(struct tty_struct *tty, struct file *file,
@@ -1270,6 +1503,32 @@
 			       USB_CTRL_SET_TIMEOUT);
 }
 
+static int hso_serial_ioctl(struct tty_struct *tty, struct file *file,
+			    unsigned int cmd, unsigned long arg)
+{
+	struct hso_serial *serial =  get_serial_by_tty(tty);
+	void __user *uarg = (void __user *)arg;
+	int ret = 0;
+	D4("IOCTL cmd: %d, arg: %ld", cmd, arg);
+
+	if (!serial)
+		return -ENODEV;
+	switch (cmd) {
+	case TIOCMIWAIT:
+		ret = hso_wait_modem_status(serial, arg);
+		break;
+
+	case TIOCGICOUNT:
+		ret = hso_get_count(serial, uarg);
+		break;
+	default:
+		ret = -ENOIOCTLCMD;
+		break;
+	}
+	return ret;
+}
+
+
 /* starts a transmit */
 static void hso_kick_transmit(struct hso_serial *serial)
 {
@@ -1781,7 +2040,10 @@
 		serial->shared_int->use_count++;
 		mutex_unlock(&serial->shared_int->shared_int_lock);
 	}
-
+	if (serial->tiocmget)
+		tiocmget_submit_urb(serial,
+				    serial->tiocmget,
+				    serial->parent->usb);
 	return result;
 }
 
@@ -1789,6 +2051,7 @@
 {
 	int i;
 	struct hso_serial *serial = dev2ser(hso_dev);
+	struct hso_tiocmget  *tiocmget;
 
 	if (!serial)
 		return -ENODEV;
@@ -1797,6 +2060,11 @@
 		if (serial->rx_urb[i])
 				usb_kill_urb(serial->rx_urb[i]);
 	}
+	tiocmget = serial->tiocmget;
+	if (tiocmget) {
+		wake_up_interruptible(&tiocmget->waitq);
+		usb_kill_urb(tiocmget->urb);
+	}
 
 	if (serial->tx_urb)
 		usb_kill_urb(serial->tx_urb);
@@ -2157,6 +2425,20 @@
 	return NULL;
 }
 
+static void hso_free_tiomget(struct hso_serial *serial)
+{
+	struct hso_tiocmget *tiocmget = serial->tiocmget;
+	if (tiocmget) {
+		kfree(tiocmget);
+		if (tiocmget->urb) {
+			usb_free_urb(tiocmget->urb);
+			tiocmget->urb = NULL;
+		}
+		serial->tiocmget = NULL;
+
+	}
+}
+
 /* Frees an AT channel ( goes for both mux and non-mux ) */
 static void hso_free_serial_device(struct hso_device *hso_dev)
 {
@@ -2175,6 +2457,7 @@
 		else
 			mutex_unlock(&serial->shared_int->shared_int_lock);
 	}
+	hso_free_tiomget(serial);
 	kfree(serial);
 	hso_free_device(hso_dev);
 }
@@ -2186,6 +2469,7 @@
 	struct hso_device *hso_dev;
 	struct hso_serial *serial;
 	int num_urbs;
+	struct hso_tiocmget *tiocmget;
 
 	hso_dev = hso_create_device(interface, port);
 	if (!hso_dev)
@@ -2198,8 +2482,27 @@
 	serial->parent = hso_dev;
 	hso_dev->port_data.dev_serial = serial;
 
-	if (port & HSO_PORT_MODEM)
+	if (port & HSO_PORT_MODEM) {
 		num_urbs = 2;
+		serial->tiocmget = kzalloc(sizeof(struct hso_tiocmget),
+					   GFP_KERNEL);
+		/* it isn't going to break our heart if serial->tiocmget
+		 *  allocation fails don't bother checking this.
+		 */
+		if (serial->tiocmget) {
+			tiocmget = serial->tiocmget;
+			tiocmget->urb = usb_alloc_urb(0, GFP_KERNEL);
+			if (tiocmget->urb) {
+				mutex_init(&tiocmget->mutex);
+				init_waitqueue_head(&tiocmget->waitq);
+				tiocmget->endp = hso_get_ep(
+					interface,
+					USB_ENDPOINT_XFER_INT,
+					USB_DIR_IN);
+			} else
+				hso_free_tiomget(serial);
+		}
+	}
 	else
 		num_urbs = 1;
 
@@ -2234,6 +2537,7 @@
 exit:
 	if (hso_dev && serial)
 		hso_serial_common_free(serial);
+	hso_free_tiomget(serial);
 	kfree(serial);
 	hso_free_device(hso_dev);
 	return NULL;
@@ -2736,6 +3040,7 @@
 	.close = hso_serial_close,
 	.write = hso_serial_write,
 	.write_room = hso_serial_write_room,
+	.ioctl = hso_serial_ioctl,
 	.set_termios = hso_serial_set_termios,
 	.chars_in_buffer = hso_serial_chars_in_buffer,
 	.tiocmget = hso_serial_tiocmget,


-- 
best regards,
D.J. Barrow

--------------010303000002090907090808
Content-Type: text/x-diff;
 name="hso_modem_signals.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="hso_modem_signals.patch"

Makes TIOCM ioctls for Data Carrier Detect & related functions
work like /drivers/serial/serial-core.c potentially needed 
for pppd & similar user programs.   
Signed-off-by: Denis Joseph Barrow <D.Barow@option.com>
---
Index: linux-2.6.27-rc9/drivers/net/usb/hso.c
===================================================================
--- linux-2.6.27-rc9.orig/drivers/net/usb/hso.c	2008-10-09 15:55:31.000000000 +0200
+++ linux-2.6.27-rc9/drivers/net/usb/hso.c	2008-10-09 17:13:26.000000000 +0200
@@ -39,8 +39,11 @@
  *		port is opened, as this have a huge impact on the network port
  *		throughput.
  *
- * Interface 2:	Standard modem interface - circuit switched interface, should
- *		not be used.
+ * Interface 2:	Standard modem interface - circuit switched interface, this
+ *		can be used to make a standard ppp connection however it
+ *              should not be used in conjunction with the IP network interface
+ *              enabled for USB performance reasons i.e. if using this set
+ *              ideally disable_net=1.
  *
  *****************************************************************************/
 
@@ -63,6 +66,8 @@
 #include <linux/usb/cdc.h>
 #include <net/arp.h>
 #include <asm/byteorder.h>
+#include <linux/serial_core.h>
+#include <linux/serial.h>
 
 
 #define DRIVER_VERSION			"1.2"
@@ -179,6 +184,41 @@
 	unsigned long flags;
 };
 
+#define BM_REQUEST_TYPE (0xa1)
+#define B_NOTIFICATION  (0x20)
+#define W_VALUE         (0x0)
+#define W_INDEX         (0x2)
+#define W_LENGTH        (0x2)
+
+#define B_OVERRUN       (0x1<<6)
+#define B_PARITY        (0x1<<5)
+#define B_FRAMING       (0x1<<4)
+#define B_RING_SIGNAL   (0x1<<3)
+#define B_BREAK         (0x1<<2)
+#define B_TX_CARRIER    (0x1<<1)
+#define B_RX_CARRIER    (0x1<<0)
+
+struct hso_serial_state_notification {
+	u8 bmRequestType;
+	u8 bNotification;
+	u16 wValue;
+	u16 wIndex;
+	u16 wLength;
+	u16 UART_state_bitmap;
+} __attribute__((packed));
+
+struct hso_tiocmget {
+	struct mutex mutex;
+	wait_queue_head_t waitq;
+	int    intr_completed;
+	struct usb_endpoint_descriptor *endp;
+	struct urb *urb;
+	struct hso_serial_state_notification serial_state_notification;
+	u16    prev_UART_state_bitmap;
+	struct uart_icount icount;
+};
+
+
 struct hso_serial {
 	struct hso_device *parent;
 	int magic;
@@ -216,6 +256,7 @@
 	spinlock_t serial_lock;
 
 	int (*write_data) (struct hso_serial *serial);
+	struct hso_tiocmget  *tiocmget;
 };
 
 struct hso_device {
@@ -291,7 +332,7 @@
 static void async_put_intf(struct work_struct *data);
 static int hso_put_activity(struct hso_device *hso_dev);
 static int hso_get_activity(struct hso_device *hso_dev);
-
+static void tiocmget_intr_callback(struct urb *urb);
 /*****************************************************************************/
 /* Helping functions                                                         */
 /*****************************************************************************/
@@ -1210,25 +1251,217 @@
 
 	return chars;
 }
+int tiocmget_submit_urb(struct hso_serial *serial,
+			struct hso_tiocmget  *tiocmget,
+			struct usb_device *usb)
+{
+	int result;
+
+	if (serial->parent->usb_gone)
+		return -ENODEV;
+	usb_fill_int_urb(tiocmget->urb, usb,
+			 usb_rcvintpipe(usb,
+					tiocmget->endp->
+					bEndpointAddress & 0x7F),
+			 &tiocmget->serial_state_notification,
+			 sizeof(struct hso_serial_state_notification),
+			 tiocmget_intr_callback, serial,
+			 tiocmget->endp->bInterval);
+	result = usb_submit_urb(tiocmget->urb, GFP_ATOMIC);
+	if (result) {
+		dev_warn(&usb->dev, "%s usb_submit_urb failed %d\n", __func__,
+			 result);
+	}
+	return result;
+
+}
+
+static void tiocmget_intr_callback(struct urb *urb)
+{
+	struct hso_serial *serial = urb->context;
+	struct hso_tiocmget *tiocmget;
+	int status = urb->status;
+	u16 UART_state_bitmap, prev_UART_state_bitmap;
+	struct uart_icount *icount;
+	struct hso_serial_state_notification *serial_state_notification;
+	struct usb_device *usb;
+
+	/* Sanity checks */
+	if (!serial)
+		return;
+	if (status) {
+		log_usb_status(status, __func__);
+		return;
+	}
+	tiocmget = serial->tiocmget;
+	if (!tiocmget)
+		return;
+	usb = serial->parent->usb;
+	serial_state_notification = &tiocmget->serial_state_notification;
+	if (serial_state_notification->bmRequestType != BM_REQUEST_TYPE ||
+	    serial_state_notification->bNotification != B_NOTIFICATION ||
+	    le16_to_cpu(serial_state_notification->wValue) != W_VALUE ||
+	    le16_to_cpu(serial_state_notification->wIndex) != W_INDEX ||
+	    le16_to_cpu(serial_state_notification->wLength) != W_LENGTH) {
+		dev_warn(&usb->dev,
+			 "hso received invalid serial state notification\n");
+		DUMP(serial_state_notification,
+		     sizeof(hso_serial_state_notifation))
+	} else {
+
+		UART_state_bitmap = le16_to_cpu(serial_state_notification->
+						UART_state_bitmap);
+		prev_UART_state_bitmap = tiocmget->prev_UART_state_bitmap;
+		icount = &tiocmget->icount;
+		spin_lock(&serial->serial_lock);
+		if ((UART_state_bitmap & B_OVERRUN) !=
+		   (prev_UART_state_bitmap & B_OVERRUN))
+			icount->parity++;
+		if ((UART_state_bitmap & B_PARITY) !=
+		   (prev_UART_state_bitmap & B_PARITY))
+			icount->parity++;
+		if ((UART_state_bitmap & B_FRAMING) !=
+		   (prev_UART_state_bitmap & B_FRAMING))
+			icount->frame++;
+		if ((UART_state_bitmap & B_RING_SIGNAL) &&
+		   !(prev_UART_state_bitmap & B_RING_SIGNAL))
+			icount->rng++;
+		if ((UART_state_bitmap & B_BREAK) !=
+		   (prev_UART_state_bitmap & B_BREAK))
+			icount->brk++;
+		if ((UART_state_bitmap & B_TX_CARRIER) !=
+		   (prev_UART_state_bitmap & B_TX_CARRIER))
+			icount->dsr++;
+		if ((UART_state_bitmap & B_RX_CARRIER) !=
+		   (prev_UART_state_bitmap & B_RX_CARRIER))
+			icount->dcd++;
+		tiocmget->prev_UART_state_bitmap = UART_state_bitmap;
+		spin_unlock(&serial->serial_lock);
+		tiocmget->intr_completed = 1;
+		wake_up_interruptible(&tiocmget->waitq);
+	}
+	memset(serial_state_notification, 0,
+	       sizeof(struct hso_serial_state_notification));
+	tiocmget_submit_urb(serial,
+			    tiocmget,
+			    serial->parent->usb);
+}
+
+/*
+ * next few functions largely stolen from drivers/serial/serial_core.c
+ */
+/* Wait for any of the 4 modem inputs (DCD,RI,DSR,CTS) to change
+ * - mask passed in arg for lines of interest
+ *   (use |'ed TIOCM_RNG/DSR/CD/CTS for masking)
+ * Caller should use TIOCGICOUNT to see which one it was
+ */
+static int
+hso_wait_modem_status(struct hso_serial *serial, unsigned long arg)
+{
+	DECLARE_WAITQUEUE(wait, current);
+	struct uart_icount cprev, cnow;
+	struct hso_tiocmget  *tiocmget;
+	int ret;
+
+	tiocmget = serial->tiocmget;
+	if (!tiocmget)
+		return -ENOENT;
+	/*
+	 * note the counters on entry
+	 */
+	spin_lock_irq(&serial->serial_lock);
+	memcpy(&cprev, &tiocmget->icount, sizeof(struct uart_icount));
+	spin_unlock_irq(&serial->serial_lock);
+	add_wait_queue(&tiocmget->waitq, &wait);
+	for (;;) {
+		spin_lock_irq(&serial->serial_lock);
+		memcpy(&cnow, &tiocmget->icount, sizeof(struct uart_icount));
+		spin_unlock_irq(&serial->serial_lock);
+		set_current_state(TASK_INTERRUPTIBLE);
+		if (((arg & TIOCM_RNG) && (cnow.rng != cprev.rng)) ||
+		    ((arg & TIOCM_DSR) && (cnow.dsr != cprev.dsr)) ||
+		    ((arg & TIOCM_CD)  && (cnow.dcd != cprev.dcd))) {
+			ret = 0;
+			break;
+		}
+		schedule();
+		/* see if a signal did it */
+		if (signal_pending(current)) {
+			ret = -ERESTARTSYS;
+			break;
+		}
+		cprev = cnow;
+	}
+	current->state = TASK_RUNNING;
+	remove_wait_queue(&tiocmget->waitq, &wait);
+
+	return ret;
+}
+
+/*
+ * Get counter of input serial line interrupts (DCD,RI,DSR,CTS)
+ * Return: write counters to the user passed counter struct
+ * NB: both 1->0 and 0->1 transitions are counted except for
+ *     RI where only 0->1 is counted.
+ */
+static int hso_get_count(struct hso_serial *serial,
+			  struct serial_icounter_struct __user *icnt)
+{
+	struct serial_icounter_struct icount;
+	struct uart_icount cnow;
+	struct hso_tiocmget  *tiocmget = serial->tiocmget;
+
+	if (!tiocmget)
+		 return -ENOENT;
+	spin_lock_irq(&serial->serial_lock);
+	memcpy(&cnow, &tiocmget->icount, sizeof(struct uart_icount));
+	spin_unlock_irq(&serial->serial_lock);
+
+	icount.cts         = cnow.cts;
+	icount.dsr         = cnow.dsr;
+	icount.rng         = cnow.rng;
+	icount.dcd         = cnow.dcd;
+	icount.rx          = cnow.rx;
+	icount.tx          = cnow.tx;
+	icount.frame       = cnow.frame;
+	icount.overrun     = cnow.overrun;
+	icount.parity      = cnow.parity;
+	icount.brk         = cnow.brk;
+	icount.buf_overrun = cnow.buf_overrun;
+
+	return copy_to_user(icnt, &icount, sizeof(icount)) ? -EFAULT : 0;
+}
+
 
 static int hso_serial_tiocmget(struct tty_struct *tty, struct file *file)
 {
-	unsigned int value;
+	int retval;
 	struct hso_serial *serial = get_serial_by_tty(tty);
-	unsigned long flags;
+	struct hso_tiocmget  *tiocmget;
+	u16 UART_state_bitmap;
 
 	/* sanity check */
 	if (!serial) {
 		D1("no tty structures");
 		return -EINVAL;
 	}
-
-	spin_lock_irqsave(&serial->serial_lock, flags);
-	value = ((serial->rts_state) ? TIOCM_RTS : 0) |
+	spin_lock_irq(&serial->serial_lock);
+	retval = ((serial->rts_state) ? TIOCM_RTS : 0) |
 	    ((serial->dtr_state) ? TIOCM_DTR : 0);
-	spin_unlock_irqrestore(&serial->serial_lock, flags);
+	tiocmget = serial->tiocmget;
+	if (tiocmget) {
 
-	return value;
+		UART_state_bitmap = le16_to_cpu(
+			tiocmget->prev_UART_state_bitmap);
+		if (UART_state_bitmap & B_RING_SIGNAL)
+			retval |=  TIOCM_RNG;
+		if (UART_state_bitmap & B_RX_CARRIER)
+			retval |=  TIOCM_CD;
+		if (UART_state_bitmap & B_TX_CARRIER)
+			retval |=  TIOCM_DSR;
+	}
+	spin_unlock_irq(&serial->serial_lock);
+	return retval;
 }
 
 static int hso_serial_tiocmset(struct tty_struct *tty, struct file *file,
@@ -1270,6 +1503,32 @@
 			       USB_CTRL_SET_TIMEOUT);
 }
 
+static int hso_serial_ioctl(struct tty_struct *tty, struct file *file,
+			    unsigned int cmd, unsigned long arg)
+{
+	struct hso_serial *serial =  get_serial_by_tty(tty);
+	void __user *uarg = (void __user *)arg;
+	int ret = 0;
+	D4("IOCTL cmd: %d, arg: %ld", cmd, arg);
+
+	if (!serial)
+		return -ENODEV;
+	switch (cmd) {
+	case TIOCMIWAIT:
+		ret = hso_wait_modem_status(serial, arg);
+		break;
+
+	case TIOCGICOUNT:
+		ret = hso_get_count(serial, uarg);
+		break;
+	default:
+		ret = -ENOIOCTLCMD;
+		break;
+	}
+	return ret;
+}
+
+
 /* starts a transmit */
 static void hso_kick_transmit(struct hso_serial *serial)
 {
@@ -1781,7 +2040,10 @@
 		serial->shared_int->use_count++;
 		mutex_unlock(&serial->shared_int->shared_int_lock);
 	}
-
+	if (serial->tiocmget)
+		tiocmget_submit_urb(serial,
+				    serial->tiocmget,
+				    serial->parent->usb);
 	return result;
 }
 
@@ -1789,6 +2051,7 @@
 {
 	int i;
 	struct hso_serial *serial = dev2ser(hso_dev);
+	struct hso_tiocmget  *tiocmget;
 
 	if (!serial)
 		return -ENODEV;
@@ -1797,6 +2060,11 @@
 		if (serial->rx_urb[i])
 				usb_kill_urb(serial->rx_urb[i]);
 	}
+	tiocmget = serial->tiocmget;
+	if (tiocmget) {
+		wake_up_interruptible(&tiocmget->waitq);
+		usb_kill_urb(tiocmget->urb);
+	}
 
 	if (serial->tx_urb)
 		usb_kill_urb(serial->tx_urb);
@@ -2157,6 +2425,20 @@
 	return NULL;
 }
 
+static void hso_free_tiomget(struct hso_serial *serial)
+{
+	struct hso_tiocmget *tiocmget = serial->tiocmget;
+	if (tiocmget) {
+		kfree(tiocmget);
+		if (tiocmget->urb) {
+			usb_free_urb(tiocmget->urb);
+			tiocmget->urb = NULL;
+		}
+		serial->tiocmget = NULL;
+
+	}
+}
+
 /* Frees an AT channel ( goes for both mux and non-mux ) */
 static void hso_free_serial_device(struct hso_device *hso_dev)
 {
@@ -2175,6 +2457,7 @@
 		else
 			mutex_unlock(&serial->shared_int->shared_int_lock);
 	}
+	hso_free_tiomget(serial);
 	kfree(serial);
 	hso_free_device(hso_dev);
 }
@@ -2186,6 +2469,7 @@
 	struct hso_device *hso_dev;
 	struct hso_serial *serial;
 	int num_urbs;
+	struct hso_tiocmget *tiocmget;
 
 	hso_dev = hso_create_device(interface, port);
 	if (!hso_dev)
@@ -2198,8 +2482,27 @@
 	serial->parent = hso_dev;
 	hso_dev->port_data.dev_serial = serial;
 
-	if (port & HSO_PORT_MODEM)
+	if (port & HSO_PORT_MODEM) {
 		num_urbs = 2;
+		serial->tiocmget = kzalloc(sizeof(struct hso_tiocmget),
+					   GFP_KERNEL);
+		/* it isn't going to break our heart if serial->tiocmget
+		 *  allocation fails don't bother checking this.
+		 */
+		if (serial->tiocmget) {
+			tiocmget = serial->tiocmget;
+			tiocmget->urb = usb_alloc_urb(0, GFP_KERNEL);
+			if (tiocmget->urb) {
+				mutex_init(&tiocmget->mutex);
+				init_waitqueue_head(&tiocmget->waitq);
+				tiocmget->endp = hso_get_ep(
+					interface,
+					USB_ENDPOINT_XFER_INT,
+					USB_DIR_IN);
+			} else
+				hso_free_tiomget(serial);
+		}
+	}
 	else
 		num_urbs = 1;
 
@@ -2234,6 +2537,7 @@
 exit:
 	if (hso_dev && serial)
 		hso_serial_common_free(serial);
+	hso_free_tiomget(serial);
 	kfree(serial);
 	hso_free_device(hso_dev);
 	return NULL;
@@ -2736,6 +3040,7 @@
 	.close = hso_serial_close,
 	.write = hso_serial_write,
 	.write_room = hso_serial_write_room,
+	.ioctl = hso_serial_ioctl,
 	.set_termios = hso_serial_set_termios,
 	.chars_in_buffer = hso_serial_chars_in_buffer,
 	.tiocmget = hso_serial_tiocmget,

--------------010303000002090907090808
Content-Type: text/x-csrc;
 name="dcdtest.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="dcdtest.c"

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/time.h>
#include <time.h>  
#include <signal.h>
#include <unistd.h>
#include <errno.h>
#include <stdlib.h>
//#include <termios.h>
#include <asm/ioctls.h>
#include <asm/termios.h>
#include <linux/serial.h>

int main(int argc,char *argv[])
{
	int fd;
	int integer;
	struct serial_icounter_struct icnt;

	if (argc != 2) {
		fprintf(stderr,"Usage:\n"
			"dcdtest <devicename>\n");
		return -1;
	}
	fd=open(argv[1], O_RDONLY);
	if (fd<0) {
		perror("open failed");
		return -1;
	}
	while(1) {

		if(ioctl(fd,TIOCMIWAIT, TIOCM_RNG | TIOCM_DSR | TIOCM_CD)) {
			perror("ioctl failed");
			return -1;
		}
		if(ioctl(fd,TIOCMGET,&integer)) {
			perror("ioctl failed");
			return -1;
		}
		printf("TIOCMGET integer=%x\n",integer);
		if(ioctl(fd,TIOCGICOUNT,&icnt)) {
			perror("ioctl failed");
			return -1;
		}
	}
	close(fd);
}

--------------010303000002090907090808--
